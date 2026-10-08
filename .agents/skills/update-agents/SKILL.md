---
name: update-agents
description: 'Update the coding agent and VS Code extension flake inputs (claude-code-nix, codex-cli-nix, nix4vscode).'
when_to_use: 'Use when the user asks to update Claude Code, Codex, or VS Code extensions, or to bump the coding agents. Trigger phrases: "update claude code", "update codex", "update agents", "bump claude", "update nix4vscode", "update vscode extensions".'
allowed-tools:
    - AskUserQuestion
    - Bash(nix flake update *)
---

# Update coding agents

Update three flake inputs: `claude-code-nix`, `codex-cli-nix`, and `nix4vscode`.

## Step 1: Confirm

Use `AskUserQuestion` to confirm before running. This modifies `flake.lock`.

- Question: "Update the claude-code-nix, codex-cli-nix, and nix4vscode flake inputs?"
- Header: "Confirm update"
- Options:
    1. Yes, update all three (Recommended)
    2. No, cancel

If the user picks "No" or "Other" with anything other than clear consent, stop and report cancellation.

## Step 2: Run

```sh
nix flake update claude-code-nix codex-cli-nix nix4vscode
```

## Step 3: Report

Summarize what changed: which inputs moved, old → new revs if shown. Suggest a follow-up `darwin-switch` or `nixos-rebuild` only if the user asks.
