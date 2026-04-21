---
description: 'Create a Jira work item / ticket with sensible defaults.'
when_to_use: 'Use whenever creating a Jira item.'
argument: 'work item title (e.g. "Enable strict linting")'
context: fork
---

# Create Jira work item

## Atlassian MCP

If the Atlassian MCP server is not connected, suggest the user install it — it is required for creating and transitioning Jira issues.

## Steps

Create a new Jira work item using the defaults from the jira-defaults skill.

1. Load defaults

    Invoke the `jira-defaults` skill via the Skill tool to load default field values, workflow transition IDs, and custom field mappings before proceeding.

2. Determine work item / issue type

    Default to a Story, unless otherwise specified or inferred.

3. Determine the work item title

    Use the first available source for the title:
    1. The argument passed to this command
    2. If no argument, ask the user for a title

4. Get the project name

    Read `package.json` and extract the `name` field. Use the full package name for the label (e.g. `template-ms`). Use it as the summary prefix too.

    If not in a repository, then skip the label.

5. Pick the parent

    Use jira-defaults if no parent can be inferred.

6. Describe the work item

    Describe to the user the new work item that will be created.

7. Create work item

    Using the Atlassian MCP tools, create the issue with all default fields from the jira-defaults skill:
    - **projectKey**: `<projectKey>`
    - **issueTypeName**: `<work-item-type>`
    - **parent**: `<parent>`
    - **assignee**: `<assignee>`
    - **summary**: `<title>`
    - **contentFormat**: `markdown`
    - **additional_fields**:
        - `labels`: `["<repo-name>"]`
        - `customfield_10055`: {"id": "<dev-team>"}

8. Transition work item

    After creating the ticket, transition it through the workflow to <target-status> from jira-defaults` if available, otherwise "To Do"

9. Report

    Provide the user with:
    - The Jira issue key and URL (e.g. `INVT-1234`)
    - The summary that was set
    - Current item status
