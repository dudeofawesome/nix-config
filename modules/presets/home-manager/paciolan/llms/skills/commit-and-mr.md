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
4. Create a commit with a descriptive message and use conventional commits
    - If you are aware of a Jira story (e.g., INVT-1234), include it in the commit message

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

## Step 4: Open Merge Request

Create a merge request on GitLab.

Use the template from `.gitlab/merge_request_templates/Default.md`:

Use the GitLab MCP tools or the GitLab CLI to create the merge request, then provide the user with the MR URL.
