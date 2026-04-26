---
name: notify-blame
description: 'Notify git blame authors on Slack when you modify their code.'
when_to_use: 'Use when the user asks to message people whose code you touched in a given branch. Trigger phrases: "notify blame", "tell the blame authors", "ping the people I modified".'
argument-hint: '[mr-url (e.g. https://gitlabdev.paciolan.info/.../merge_requests/306)]'
allowed-tools:
    - Bash(python3 *)
    - Bash(glab mr list*)
    - Bash(git *)
    - mcp__claude_ai_Slack__slack_search_users
    - Skill
---

# Notify Blame Authors

Send a Slack DM to each person whose code was modified on this branch, linking them to the merge request for review.

## Step 1: Run the Blame Script

```bash
python3 ${CLAUDE_SKILL_DIR}/scripts/git-blame-authors.py
```

This outputs JSON with:

- `base` — the merge-base commit SHA
- `repoName` — the repository name (e.g. `template-ms`)
- `mrUrl` — the GitLab MR URL (auto-detected via `glab` CLI), or `null`
- `mrNumber` — the MR number, or `null`
- `authors` — list of blame authors, each with `name`, `email`, `lines`, `files`, and `diff`

If `authors` is empty, inform the user that no other authors' code was modified and stop.

## Step 2: Resolve the MR URL

Use the first available source:

1. `mrUrl` from the script output (auto-detected)
2. The argument passed to this command
3. An MR URL mentioned earlier in this chat
4. Search using the GitLab CLI: `glab mr list --source-branch=$(git branch --show-current)`
5. Otherwise, ask the user for a GitLab Merge Request URL. Do not continue until you have one.

Extract from the resolved URL:

- **repo name**: the last path segment before `/-/` (e.g. `catalog-mgmt-ms`) — or use `repoName` from the script
- **MR number**: the number after `/merge_requests/` — or use `mrNumber` from the script
- **Full MR URL**: the entire URL as-is

## Step 3: Summarize Changes Per Author

For each blame author, the script output includes a `diff` field with the full diff for their files. Review each author's diff and write a **brief, one-to-three sentence summary** of what was changed in their code, from the MR author's perspective. Focus on _what_ and _why_, not line-by-line details. For example:

- "Replaced your `AxiosOptions` interface with a direct import from axios, since it was a duplicate."
- "Optimized the SQL query you wrote in `sql-constants.ts` to remove an unnecessary subselect."
- "Removed unused utility functions from `slp-util.ts`."

Each author gets their own personalized summary based on the specific code of theirs that was modified.

## Step 4: Look Up Authors on Slack

Invoke the `person-to-user-map` skill to resolve each blame author's git email to a Slack user ID. That skill handles cache lookups and falls back to `slack_search_users` (by full name, then email prefix) on misses, and updates the cache with new entries.

If a person cannot be resolved, note them for the final report and skip — do not block on missing entries.

## Step 5: Send DMs

For each author found on Slack, send a DM using `slack_send_message` with this exact message:

```
:claude: **I touched your code!**
No obligation, but you may be interested in reviewing [<repo-name>!<MR#>](<full MR URL>)

> <personalized summary>
```

Replace:

- `<repo-name>`, `<MR#>`, and `<full MR URL>` with the values from Step 2
- `<personalized summary>` with the author-specific summary from Step 3

Send messages in parallel where possible.

## Step 6: Report Results

Summarize in a table:

- Each author, their line count, and whether the Slack message was sent or they couldn't be found
- Note any authors who were skipped or not found on Slack
