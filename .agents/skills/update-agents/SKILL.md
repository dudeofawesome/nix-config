---
name: update-agents
description: 'Update the coding agent flake inputs (claude-code-nix, codex-cli-nix).'
when_to_use: 'Use when the user asks to update Claude Code or Codex, or to bump the coding agents. Trigger phrases: "update claude code", "update codex", "update agents", "bump claude".'
allowed-tools:
    - AskUserQuestion
    - Bash(nix flake update *)
---

# Update coding agents

Update the two coding agent flake inputs: `claude-code-nix` and `codex-cli-nix`.

## Step 1: Confirm

Use `AskUserQuestion` to confirm before running. This modifies `flake.lock`.

- Question: "Update the claude-code-nix and codex-cli-nix flake inputs?"
- Header: "Confirm update"
- Options:
    1. Yes, update both (Recommended)
    2. No, cancel

If the user picks "No" or "Other" with anything other than clear consent, stop and report cancellation.

## Step 2: Run

```sh
nix flake update claude-code-nix codex-cli-nix
```

## Step 3: Report

Summarize what changed: which inputs moved, old → new revs if shown. Suggest a follow-up `darwin-switch` or `nixos-rebuild` only if the user asks.
