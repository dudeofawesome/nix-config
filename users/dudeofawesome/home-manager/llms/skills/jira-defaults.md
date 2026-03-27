---
name: jira-defaults
description: "Use when creating, updating, or transitioning Jira work items. Provides default field values, workflow transition IDs, and custom field mappings."
---

# Jira defaults

## Atlassian MCP

If the Atlassian MCP server is not connected, suggest the user install it — it is required for creating and transitioning Jira issues.

cloudId: `paciolan.atlassian.net`

## Defaults

Unless the user specifies otherwise, use these values when creating Jira work items:

| Field              | Value                                                                   |
| ------------------ | ----------------------------------------------------------------------- |
| projectKey         | `INT`                                                                  |
| parent             | `INT-128`                                                              |
<!-- TODO: use the person-to-ID mapping skill -->
| assignee           | `712020:8b122fa4-b68a-4f8e-a116-6e2633f25126`                          |
| Dev Team (required) | `customfield_10055`: `{"id": "10271"}` (Inventory)                     |

### Custom Fields

| Custom Field         | ID                  | Notes                                          |
| -------------------- | ------------------- | ---------------------------------------------- |
| Dev Team             | `customfield_10055` | Required. Inventory = `{"id": "10271"}`        |
| Fixed in Build       | `customfield_10041` | Set to the pipeline URL after merging          |

## Workflow Transitions

### Forward transitions

| From            | To              | ID     | Notes                                                        |
| --------------- | --------------- | ------ | ------------------------------------------------------------ |
| Open            | Refined         | `1221` |                                                              |
| Refined         | To Do           | `1211` |                                                              |
| To Do           | In Dev          | `1081` |                                                              |
| In Dev          | Code Review     | `1141` |                                                              |
| Code Review     | Dev Complete    | `1171` | Skips UX review                                              |
| Dev Complete    | In QA           | `1071` |                                                              |
| In QA           | Resolved        | `1151` | Requires `fixVersions: [{"name": "RELEASE NOT NEEDED"}]`    |
| Resolved        | Ready for Prod  | `2`    |                                                              |
| Ready for Prod  | Closed          | `1111` |                                                              |

When transitioning to Resolved, include the required field: `{"fixVersions": [{"name": "RELEASE NOT NEEDED"}]}`.

### Back transitions

| From         | To     | ID     |
| ------------ | ------ | ------ |
| Code Review  | In Dev | `1231` |
| In QA        | In Dev | `1251` |

### Global transitions (available from any state)

| To        | ID     |
| --------- | ------ |
| Open      | `841`  |
| Refined   | `1221` |
| Cancelled | `1191` |

## Transitioning Through Multiple States

When asked to move a story to a specific state (e.g. "move to In Dev"), transition through each intermediate state in order. For example, Open → In Dev requires: Open → Refined → To Do → In Dev.
