---
name: commit-and-mr
description: 'Commit the current changes, push to a branch, and open a GitLab merge request with reviewers picked from git blame.'
when_to_use: 'Use when the user asks to commit and open an MR/PR, "ship this", "open a merge request", or wants the full commit-push-MR cycle. Skip for plain commits with no MR.'
argument-hint: '[branch-name] [jira=<KEY>|jira=none]'
disable-model-invocation: true
allowed-tools:
    - Bash(git *)
    - Bash(python3 *)
    - Bash(whoami)
    - Bash(glab *)
    - AskUserQuestion
    - Skill
    - mcp__plugin_claude-code-home-manager_gitlab__get_users
---

# Commit Changes and Open Merge Request

Follow these steps to create a branch, commit, push, and open a merge request for the current changes.

## Step 1: Check Current Branch

First, check the current git branch:

```bash
git branch --show-current
```

- If the current branch is `master`, `main`, or `develop`:
    - Come up with a branch name (unless the user provided one)
    - Create and checkout the new branch: `git checkout -b <branch-name>`
    - Proceed to Step 2

- If the current branch is NOT `master`, `main`, or `develop`:
    - Inform the user which branch they are currently on
    - Ask them to confirm one of the following options:
        1. Create a new branch off the current branch
        2. Use the current branch as-is and skip branch creation
    - Wait for user response before proceeding

## Step 2: Commit Changes

1. Run `git status` to see all changes
2. Run `git diff` to review the changes
3. Stage all relevant changes with `git add`
4. Determine the Jira issue:
    - If `$ARGUMENTS` contains `jira=<KEY>` (e.g. `jira=INVT-1234`), use that key — do not ask.
    - If `$ARGUMENTS` contains `jira=none`, treat as no Jira issue — do not ask.
    - Otherwise, if a Jira key was already established earlier in the conversation, use it — do not ask.
    - Otherwise, use the `AskUserQuestion` tool to ask whether there is an associated Jira issue (e.g., INVT-1234), with options like "No Jira issue" and "Yes, I'll provide it". Wait for their response before proceeding.
5. Create a commit with a descriptive message and use conventional commits
    - If there is a Jira story (e.g., INVT-1234), include it in the commit message

## Step 3: Push Changes

1. Push the branch to the remote:

    ```bash
    git push -u origin <branch-name>
    ```

2. **If the push fails:**
    - Retry the push command once (the connection can be flaky)
    - If it fails again, inform the user:
        > "Push failed twice. Please check that you're connected to the VPN and let me know when you're ready to try again."
    - Wait for the user to confirm before retrying

## Step 4: Determine Reviewers from Git Blame

Run the blame script to find authors of the code being modified on this branch:

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/git-blame-authors.py
```

This outputs JSON with an `authors` list, each entry containing `name`, `email`, `lines`, and `files`. The current user is excluded automatically.

For each blame author, resolve their email to a GitLab user ID. Skip any author who cannot be resolved (note them for the final report, but don't block MR creation).

Collect the resolved GitLab user IDs to pass as `reviewer_ids` in the next step. If `authors` is empty, create the MR without reviewers.

## Step 5: Open Merge Request

Create a merge request on GitLab.

Use the template from `.gitlab/merge_request_templates/Default.md`:

Use actual newlines in the MR description string — never literal `\n` escape sequences.

Assign the MR to the current user: run `whoami` to get a starting username, then resolve it to a GitLab user ID and pass it as `assignee_ids`.

Pass the reviewer IDs collected in Step 4 as `reviewer_ids`.

Create the merge request, then provide the user with the MR URL.

Always pass `remove_source_branch: true` when creating the merge request — the GitLab API does not honor the project's "delete source branch" default, so it must be set explicitly.

**Do not** pass `squash`. Omitting it lets GitLab fall back to the repository's configured squash commit settings. Only include it if the user explicitly asks to override the project default for a specific MR.

## Step 6: Link MR on Jira Issue

If a Jira issue was associated with this work (from Step 2), add a comment to the Jira issue with a link to the merge request.

The comment should include the MR title and URL, e.g.:

> Merge request: [<MR title>](<MR URL>)

Skip this step if no Jira issue was associated with the work.
