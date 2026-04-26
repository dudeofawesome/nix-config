---
name: update-nixpkgs
description: 'Update nixpkgs flake inputs (linux-stable, darwin-stable, and unstable).'
when_to_use: 'Use when the user asks to "update nixpkgs", "bump nixpkgs", "update the flake inputs", or wants the three nixpkgs channels refreshed. Trigger phrases: "update nixpkgs", "bump flake", "refresh inputs", "update channels".'
allowed-tools:
    - AskUserQuestion
    - Bash(nix flake update *)
---

# Update nixpkgs

Update the three nixpkgs flake inputs: `nixpkgs-linux-stable`, `nixpkgs-darwin-stable`, and `nixpkgs-unstable`.

## Step 1: Confirm

Use `AskUserQuestion` to confirm before running. This modifies `flake.lock`.

- Question: "Update all three nixpkgs flake inputs (linux-stable, darwin-stable, unstable)?"
- Header: "Confirm update"
- Options:
    1. Yes, update all three (Recommended)
    2. No, cancel

If the user picks "No" or "Other" with anything other than clear consent, stop and report cancellation.

## Step 2: Run

```sh
nix flake update nixpkgs-linux-stable nixpkgs-darwin-stable nixpkgs-unstable
```

## Step 3: Report

Summarize what changed: which inputs moved, old → new revs if shown. Suggest a follow-up `darwin-switch` or `nixos-rebuild` only if the user asks.
