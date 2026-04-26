---
name: full-feature-workflow
description: 'End-to-end feature workflow: create a Jira item (if needed), implement the change, wait for review, commit & open MR, and notify blame authors.'
argument-hint: '[jira-key|confluence-url|path|description]'
disable-model-invocation: true
allowed-tools:
    - Skill
    - Read
    - Edit
    - Write
    - Glob
    - Grep
    - Bash
    - TodoWrite
    - AskUserQuestion
    - mcp__claude_ai_Atlassian__getJiraIssue
    - mcp__claude_ai_Atlassian__getConfluencePage
    - mcp__claude_ai_Atlassian__addCommentToJiraIssue
    - mcp__claude_ai_Atlassian__createJiraIssue
---

# Full feature workflow

Orchestrator that runs an entire feature from intake to Slack notifications by delegating to other skills.

**Resume semantics:** if any step stops to wait for the user or a sub-skill halts (e.g. push failure, missing MR URL), this skill also stops at that step. On re-invocation, resume from the first incomplete step using context already in the conversation. Use `TodoWrite` to track step state.

## Step 1: Identify the spec

Resolve `$ARGUMENTS` to a concrete spec. Set `JIRA_KEY`, `SPEC_TITLE`, `SPEC_BODY`, `SPEC_URL` for later steps:

| Input | Action | Sets |
| --- | --- | --- |
| Jira key (e.g. `INVT-1234`) | `getJiraIssue` | `JIRA_KEY`, `SPEC_TITLE`, `SPEC_BODY` |
| Confluence URL | `getConfluencePage` | `SPEC_TITLE`, `SPEC_BODY`, `SPEC_URL` |
| File path | `Read` the file | `SPEC_BODY` (title from filename or first heading) |
| Plain description | use directly | `SPEC_BODY` |

If the input is ambiguous (could match multiple types), ask the user to clarify before proceeding.

## Step 2: Ensure a Jira story exists

If `JIRA_KEY` is already set from Step 1, skip this step.

Otherwise:

1. Use `AskUserQuestion` to confirm: "Create a Jira story for this work?" Options: `Yes`, `No, skip Jira`.
2. If **No**: set `JIRA_KEY=none` and continue.
3. If **Yes**: invoke `create-jira-item` with `$ARGUMENTS` set to `SPEC_TITLE`. After it returns, also:
    - Add `SPEC_BODY` to the issue description (edit the issue if `create-jira-item` did not include it).
    - If `SPEC_URL` is set (Confluence), add a remote issue link to that URL.
    - Record the new issue key as `JIRA_KEY`.

## Step 3: Execute the work

Implement the change. Run the relevant project checks. **Do not commit yet.**

If Step 4 sends you back here more than once, offer to create a checkpoint commit on the working branch before continuing — long iteration loops should not pile up uncommitted changes.

## Step 4: Wait for user review

Show the user the diff (`git diff` for unstaged, `git status` for the file list) and a one-paragraph summary of what changed and why. Then stop and wait for explicit approval.

Approval requires an unambiguous affirmative (e.g. "looks good", "ship it", "approved", "lgtm"). Treat anything else — questions, silence, partial responses, "ok" without context — as not-yet-approved and wait. If the user requests changes, return to Step 3.

## Step 5: Commit and open MR

Invoke `commit-and-mr` with `$ARGUMENTS` set to `jira=<JIRA_KEY>` (use `jira=none` if Step 2 was skipped). Record the resulting MR URL as `MR_URL`.

If `commit-and-mr` halts (push failure, branch question, etc.), this skill halts too — resume on next invocation.

## Step 6: Notify blame authors

Invoke `notify-blame` with `$ARGUMENTS` set to `MR_URL`.

## Step 7: Final report

Pass through `notify-blame`'s author table verbatim, then add:

- Jira: `JIRA_KEY` + URL (or "skipped")
- MR: `MR_URL`
