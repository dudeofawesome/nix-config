# Bash

Before running a bash command, format for readability if any apply:

- The command significantly exceeds 80 characters
- It contains pipes, logical operators, command substitution, multiple commands

# Markdown

Don't manually wrap paragraphs; diffs are larger

# Summaries

When debugging, show the main commands you used / steps you took to identify and solve the issue

# CLI auth

CLIs may auth via 1Password even when a non-interactive or sandboxed invocation reports missing credentials. Use the integration before login, new creds, or config changes.

- **Shell plugins (`gh`, `glab`, and other configured plugin CLIs):** invoke explicitly with `op plugin run -- <cli> <args>` with PTY
- **SSH and Git remotes:** use the existing SSH config and 1Password SSH agent, rather than wrapping `ssh` or `git` in `op plugin run`
- **AWS:** retrieves credentials through 1Password natively
- **Execution environment:** use a PTY outside sandbox for auth flows that can prompt
