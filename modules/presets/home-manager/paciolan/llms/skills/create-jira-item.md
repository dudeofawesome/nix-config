---
description: 'Create a Jira work item with sensible defaults'
argument: 'work item title (e.g. "Enable strict linting")'
---

# Create Jira work item

Create a new Jira work item using the defaults from the jira skill.

1. Determine work item / issue type

   Default to a Story, unless otherwise specified.

2. Determine the work item title

    Use the first available source for the title:

    1. The argument passed to this command
    2. If no argument, ask the user for a title

3. Get the project name

    Read `package.json` and extract the `name` field. Use the full package name for the label (e.g. `template-ms`). Use it as the summary prefix too.

    If not in a repository, then skip the label.

4. Create the Story

    Using the Atlassian MCP tools, create the issue with all default fields from the jira-defaults skill:

    - **projectKey**: `INT`
    - **issueTypeName**: `<work-item-type>`
    <!-- TODO: pick a better parent -->
    - **parent**: `INVT-481`
    <!-- TODO: refactor out the user ID -->
    - **assignee**: `712020:bacc7c0f-d150-4a0c-922b-abfc4b40fa28`
    - **summary**: `<title>`
    - **contentFormat**: `markdown`
    - **additional_fields**:
        - `labels`: `["<repo-name>"]`
        <!-- TODO: refactor out the team ID -->
        - `customfield_10055`: `{"id": "10271"}`

5. Transition to In Dev

    After creating the story, transition it through the workflow to **To Do**:

    1. Open → Refined (transition `1221`)
    2. Refined → To Do (transition `1211`)
    3. To Do → In Dev (transition `1081`)

6. Report

    Provide the user with:

    - The Jira issue key and URL (e.g. `INVT-1234`)
    - The summary that was set
    - Current item status
