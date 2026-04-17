---
description: 'Provides default field values, workflow transition IDs, and custom field mappings.'
when_to_use: 'Use when creating, updating, or transitioning Jira work items.'
user-invocable: false
disable-model-invocation: false
---

# Jira defaults

## Defaults

Unless the user specifies otherwise, use these values when creating Jira work items:

| Field               | Value                                               |
| ------------------- | --------------------------------------------------- |
| projectKey          | `INT`                                               |
| parent              | `INT-128`                                           |
| assignee            | `Louis Orleans`                                     |
| Dev Team (required) | `customfield_10055`: {"id": "10279"} (Integrations) |

### Custom Fields

| Custom Field   | ID                  | Notes                                 |
| -------------- | ------------------- | ------------------------------------- |
| Fixed in Build | `customfield_10041` | Set to the pipeline URL after merging |

## Workflow Transitions

### Forward transitions

| From           | To             | ID     | Notes                                                    |
| -------------- | -------------- | ------ | -------------------------------------------------------- |
| Open           | Refined        | `1221` |                                                          |
| Refined        | To Do          | `1211` |                                                          |
| To Do          | In Dev         | `1081` |                                                          |
| In Dev         | Code Review    | `1141` |                                                          |
| Code Review    | Dev Complete   | `1171` | Skips UX review                                          |
| Dev Complete   | In QA          | `1071` |                                                          |
| In QA          | Resolved       | `1151` | Requires `fixVersions: [{"name": "RELEASE NOT NEEDED"}]` |
| Resolved       | Ready for Prod | `2`    |                                                          |
| Ready for Prod | Closed         | `1111` |                                                          |

When transitioning to Resolved, include the required field: `{"fixVersions": [{"name": "RELEASE NOT NEEDED"}]}`.

### Back transitions

| From        | To     | ID     |
| ----------- | ------ | ------ |
| Code Review | In Dev | `1231` |
| In QA       | In Dev | `1251` |

### Global transitions (available from any state)

| To        | ID     |
| --------- | ------ |
| Open      | `841`  |
| Refined   | `1221` |
| Cancelled | `1191` |

### Transitioning Through Multiple States

When asked to move a story to a specific state (e.g. "move to In Dev"), transition through each intermediate state in order. For example, Open → In Dev requires: Open → Refined → To Do → In Dev.
