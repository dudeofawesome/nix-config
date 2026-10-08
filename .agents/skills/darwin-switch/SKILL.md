---
name: darwin-switch
description: 'Apply the nix-darwin configuration to the current machine.'
when_to_use: 'Use when the user asks to "switch", "rebuild", "apply darwin config", "darwin-rebuild", or otherwise wants the current host''s nix-darwin configuration applied. Trigger phrases: "switch", "rebuild darwin", "apply the config", "rebuild this machine".'
allowed-tools:
    - AskUserQuestion
    - Bash(nh darwin switch *)
    - Bash(hostname)
---

# Darwin switch

Apply the nix-darwin configuration on this host.

## Step 1: Confirm

Use `AskUserQuestion` to confirm before running. The action rebuilds system state.

- Question: "Apply the nix-darwin configuration to this machine?"
- Header: "Confirm rebuild"
- Options:
    1. Yes, run `nh darwin switch` (Recommended)
    2. No, cancel

If the user picks "No" or "Other" with anything other than clear consent, stop and report cancellation.

## Step 2: Run

```sh
nh darwin switch ~/git/dudeofawesome/nix-config#$(hostname -s)
```

## Step 3: Report

Summarize the outcome: success plus the package diff nh prints, or any error. On failure, surface the relevant lines from the output — do not retry automatically.
