## Repos

`~/git/Paciolan/` is a git-sync mirror of every Paciolan repo (GitLab under `Gitlab/<group>/<name>`, GitHub under `Github/<name>`, Bitbucket under `Bitbucket/<slug>`). Already cloned — never clone. If installed, see the local-repos skill for the full workflow.

## VPN

The VPN is finicky. On a host-unresolvable / connection-refused / DNS / timeout error, just retry — it usually works the second time.

## Permissions

The auto-mode classifier — not the user — sometimes denies a tool call. The user is far more permissive. If a denied call should be allowed, stop and ask the user; they can tell the auto-mode agent to grant it. Asking beats a workaround that lowers code quality or wastes tokens.

## Jira

When accessing Jira, the INT team name must be quoted.
