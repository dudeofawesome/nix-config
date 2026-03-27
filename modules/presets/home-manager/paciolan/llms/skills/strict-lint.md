# Enable Strict Linting

Enable strict code-style by removing all `/lenient` config extensions from ESLint, TypeScript, and codestyleinitrc, then check for and offer to fix any linting errors.

## Step 1: Apply the strict-lint patch

Run the following command to apply the patch:

```bash
git apply .claude/patches/strict-lint.patch
```

If the patch fails (e.g. files already modified or patch already applied), check if the lenient configs are already removed. If so, skip to Step 2. If the files have been modified in some other way, inform the user and stop.

## Step 2: Run lint

Run `npm run lint` and capture the output.

- If there are **no errors**, inform the user that strict linting is enabled and the codebase is already compliant.
- If there are **errors**, show the user a summary of the errors grouped by rule, then ask if they'd like you to fix them.

## Step 3: Fix errors (if requested)

If the user wants fixes:

1. Fix all auto-fixable issues with `npm run lint:js -- --fix`
2. Manually fix any remaining issues
3. Run `npm run lint` again to verify all errors are resolved
4. Repeat until clean
