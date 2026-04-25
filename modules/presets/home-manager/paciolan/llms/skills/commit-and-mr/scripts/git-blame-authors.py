#!/usr/bin/env python3
"""
Outputs JSON with blame authors for lines changed on the current branch
relative to the base branch (master or main).

Output format:
{
  "base": "<commit-sha>",
  "repoName": "<repo-name>",
  "mrUrl": "<gitlab-mr-url>" | null,
  "mrNumber": "<mr-number>" | null,
  "authors": [
    {
      "name": "...",
      "email": "...",
      "lines": N,
      "files": ["..."],
      "diff": "..."
    }
  ]
}
"""

import json
import re
import subprocess
import sys


def run(cmd: list[str]) -> str:
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip()


def run_or_none(cmd: list[str]) -> str | None:
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.stdout.strip() if result.returncode == 0 else None


def get_base_commit() -> str:
    base = run_or_none(["git", "merge-base", "master", "HEAD"])
    if not base:
        base = run_or_none(["git", "merge-base", "main", "HEAD"])
    if not base:
        print('{"error": "Could not determine base branch."}', file=sys.stderr)
        sys.exit(1)
    return base


def get_remote_info() -> tuple[str, str]:
    """Returns (repo_name, gitlab_web_url) from the git remote."""
    remote_url = run_or_none(["git", "remote", "get-url", "origin"]) or ""

    # Extract repo name
    stripped = re.sub(r"\.git$", "", remote_url)
    name_match = re.search(r"[/:]([^/:]+)$", stripped)
    repo_name = name_match.group(1) if name_match else "unknown"

    # Build GitLab web URL from SSH or HTTPS remote
    # SSH:   git@host:group/path/repo.git
    # HTTPS: https://host/group/path/repo.git
    web_url = ""
    ssh_match = re.match(r"git@([^:]+):(.+?)(?:\.git)?$", remote_url)
    https_match = re.match(r"https?://([^/]+)/(.+?)(?:\.git)?$", remote_url)
    if ssh_match:
        web_url = f"https://{ssh_match.group(1)}/{ssh_match.group(2)}"
    elif https_match:
        web_url = f"https://{https_match.group(1)}/{https_match.group(2)}"

    return repo_name, web_url


def find_mr_url(web_url: str) -> tuple[str | None, str | None]:
    """Try to find the open MR URL for the current branch using the GitLab API via glab CLI."""
    if not web_url:
        return None, None

    branch = run_or_none(["git", "branch", "--show-current"])
    if not branch:
        return None, None

    # Try glab CLI first
    mr_info = run_or_none(["glab", "mr", "view", branch, "--output", "json"])
    if mr_info:
        try:
            data = json.loads(mr_info)
            return data.get("web_url"), str(data.get("iid", ""))
        except (json.JSONDecodeError, KeyError):
            pass

    # Fallback: construct the URL pattern for branch-based MR lookup
    # GitLab merge_requests?scope=all&source_branch=<branch>
    # This won't give us the MR number, so return None
    return None, None


def get_excluded_emails() -> set[str]:
    """Build a set of all emails belonging to the current user via transitive closure."""
    current_name = run(["git", "config", "user.name"])
    current_email = run(["git", "config", "user.email"])

    excluded_names = {current_name}
    excluded_emails = {current_email}

    # Parse all name|email pairs from git log
    log_output = run(["git", "log", "--all", "--format=%aN|%aE"])
    pairs: set[tuple[str, str]] = set()
    for line in log_output.splitlines():
        if "|" in line:
            name, email = line.split("|", 1)
            pairs.add((name, email))

    # Transitive closure: name->emails->names->emails...
    changed = True
    while changed:
        changed = False
        for name, email in pairs:
            if name in excluded_names and email not in excluded_emails:
                excluded_emails.add(email)
                changed = True
            if email in excluded_emails and name not in excluded_names:
                excluded_names.add(name)
                changed = True

    return excluded_emails


def get_changed_ranges(base: str) -> list[tuple[str, int, int]]:
    """Parse git diff to extract (file, start, end) tuples for changed/deleted lines.

    Uses -M (rename detection) so renamed files are handled correctly.
    The '--- a/' path is the old path on the base commit, which is what we need for blame.

    Uses --no-ext-diff to bypass any user-configured diff.external (e.g. difftastic),
    which would otherwise produce non-unified output that this parser cannot read.
    """
    diff_output = run(["git", "diff", "--no-ext-diff", f"{base}..HEAD", "--unified=0", "-M"])
    ranges: list[tuple[str, int, int]] = []
    current_file = None

    for line in diff_output.splitlines():
        if line.startswith("--- a/"):
            current_file = line[6:]
        elif line.startswith("--- /dev/null"):
            # New file, nothing to blame
            current_file = None
        elif line.startswith("@@") and current_file:
            match = re.search(r"@@ -(\d+)(?:,(\d+))? ", line)
            if match:
                start = int(match.group(1))
                count = int(match.group(2)) if match.group(2) else 1
                if count > 0:
                    ranges.append((current_file, start, start + count - 1))

    return ranges


def get_author_diffs(base: str, authors: list[dict]) -> None:
    """Populate each author's 'diff' field with the relevant diff content."""
    # Cache diffs per file to avoid running git diff multiple times for the same file
    diff_cache: dict[str, str] = {}

    for author in authors:
        diff_parts: list[str] = []
        for file in author["files"]:
            if file not in diff_cache:
                diff_cache[file] = run(["git", "diff", "--no-ext-diff", f"{base}..HEAD", "-M", "--", file])
            diff_parts.append(diff_cache[file])
        author["diff"] = "\n".join(diff_parts)


def blame_ranges(
    base: str,
    ranges: list[tuple[str, int, int]],
    excluded_emails: set[str],
) -> list[dict]:
    """Run git blame on each range and aggregate by author."""
    authors: dict[str, dict] = {}  # keyed by email

    for file, start, end in ranges:
        result = subprocess.run(
            ["git", "blame", "--no-ext-diff", "-L", f"{start},{end}", "--line-porcelain", base, "--", file],
            capture_output=True,
            text=True,
        )
        if result.returncode != 0:
            continue

        blame_name = None
        for line in result.stdout.splitlines():
            if line.startswith("author "):
                blame_name = line[7:]
            elif line.startswith("author-mail "):
                blame_email = line[13:].strip("<>")

                if blame_email in excluded_emails:
                    continue

                if blame_email not in authors:
                    authors[blame_email] = {
                        "name": blame_name,
                        "email": blame_email,
                        "lines": 0,
                        "files": set(),
                    }

                authors[blame_email]["lines"] += 1
                authors[blame_email]["files"].add(file)

    # Sort by line count descending, convert file sets to sorted lists
    sorted_authors = sorted(authors.values(), key=lambda a: a["lines"], reverse=True)
    for author in sorted_authors:
        author["files"] = sorted(author["files"])

    return sorted_authors


def main():
    base = get_base_commit()
    repo_name, web_url = get_remote_info()
    mr_url, mr_number = find_mr_url(web_url)
    excluded_emails = get_excluded_emails()
    ranges = get_changed_ranges(base)

    if not ranges:
        print(json.dumps({
            "base": base,
            "repoName": repo_name,
            "mrUrl": mr_url,
            "mrNumber": mr_number,
            "authors": [],
        }))
        return

    authors = blame_ranges(base, ranges, excluded_emails)
    get_author_diffs(base, authors)

    print(json.dumps({
        "base": base,
        "repoName": repo_name,
        "mrUrl": mr_url,
        "mrNumber": mr_number,
        "authors": authors,
    }, indent=2))


if __name__ == "__main__":
    main()
