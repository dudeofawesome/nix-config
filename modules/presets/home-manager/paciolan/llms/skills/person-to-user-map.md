---
description: 'Maps people to user IDs / names across platforms.'
when_to_use: 'Use before looking up any user ID, username, or email — including your own. Check the cache first; only hit external APIs on a miss.'
user-invocable: false
disable-model-invocation: false
allowed-tools:
    - mcp__claude_ai_Atlassian__lookupJiraAccountId
    - mcp__claude_ai_Slack__slack_search_users
    - mcp__claude_ai_Gitlab__get_users
    - mcp__gitlab__get_users
    - mcp__plugin_claude-code-home-manager_gitlab__get_users
---

Read and written by LLM tooling — keep entries compact and updated.
Lookup tips for users NOT in this cache:

- Slack: `slack_search_users` — search by full name, then by email prefix
- GitLab: `mcp__gitlab__get_users` — try first-initial + last name (dsakamoto),
  then full first + last (joshuagibbs), then first name only (laercio)
- Jira: `mcp__claude_ai_Atlassian__lookupJiraAccountId`
  cloudId: `paciolan.atlassian.net`, search by full name

The map is a list of people with props such as name, emails, slack_id, gitlab_user id and username, jira_id
eg:

```yaml
- name: John Appleseed
  nicknames:
      - Jonny
  emails:
      - john@appleseed.com
  slack_id: U12345
  gitlab:
      id: 56481
      username: jappleseed
  jira_id: 81170:00000000-0000-4000-0000-000000000000
```

The map is stored as a YAML document at $XDG_DATA_HOME/person-to-user-map.yaml (usually ~/.local/share/person-to-user-map.yaml)
