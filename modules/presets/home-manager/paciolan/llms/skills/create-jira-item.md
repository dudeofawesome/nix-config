---
name: create-jira-item
description: 'Create a Jira work item / ticket with sensible defaults. Use whenever creating a Jira item.'
argument: 'work item title (e.g. "Enable strict linting")'
---

# Create Jira work item

## Atlassian MCP

If the Atlassian MCP server is not connected, suggest the user install it — it is required for creating and transitioning Jira issues.

cloudId: `paciolan.atlassian.net`

## Steps

Create a new Jira work item using the defaults from the jira-defaults skill.

1. Determine work item / issue type

    Default to a Story, unless otherwise specified or inferred.

2. Determine the work item title

    Use the first available source for the title:
    1. The argument passed to this command
    2. If no argument, ask the user for a title

3. Get the project name

    Read `package.json` and extract the `name` field. Use the full package name for the label (e.g. `template-ms`). Use it as the summary prefix too.

    If not in a repository, then skip the label.

4. Pick the parent

5. Describe the work item

    Describe to the user the new work item that will be created.

6. Create work item

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

7. Transition work item

    After creating the ticket, transition it through the workflow to "To Do"

8. Report

    Provide the user with:
    - The Jira issue key and URL (e.g. `INVT-1234`)
    - The summary that was set
    - Current item status
