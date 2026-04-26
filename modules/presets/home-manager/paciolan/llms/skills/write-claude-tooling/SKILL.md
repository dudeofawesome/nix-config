---
name: write-claude-tooling
description: 'Token-efficient authoring rules for LLM-consumed docs and Claude Code configuration.'
when_to_use: 'Use whenever authoring or editing Claude Code configuration: skills (SKILL.md), slash commands, hooks, agents, CLAUDE.md, AGENTS.md, settings.json. Trigger phrases: "write a skill", "add a command", "update CLAUDE.md", "make a hook", "edit my agent", "improve this skill".'
paths:
    - '**/CLAUDE.md'
    - '**/AGENTS.md'
    - '**/SKILL.md'
    - '**/.claude/skills/**'
    - '**/.claude/commands/**'
    - '**/.claude/agents/**'
    - '**/.claude/hooks/**'
    - '**/.claude/settings*.json'
---

# Writing Claude Tooling

These files are for LLMs. Maximize signal per token.

## Principles

1. **Only document what Claude doesn't know.** Project-specific conventions, custom code, non-obvious decisions. Not standard frameworks, common patterns, or language idioms. Test: "Would Claude do the wrong thing without this?" If no, cut it.

2. **Prefer pointing to code over describing it.** `Read ./path/to/file.ts` or `@file` references beat duplicating content. If content is >5 lines and workflow-specific, put it in a skill and reference it. If 1-2 lines of universal context, inline in CLAUDE.md.

3. **Prefer scripts over instructions.** Deterministic tasks (setup, migrations, CI steps) belong in `.claude/scripts/`, referenced from commands. Scripts can't go stale — they either work or visibly break. Prose instructions silently rot.

4. **Show, don't tell.** One correct example replaces paragraphs of rules. Tables and bullets over prose.

## Structure

- **Skills**: frontmatter `description` lists trigger keywords. Body under ~80 lines.
- **Commands**: imperative steps, not explanations.
- **CLAUDE.md/AGENTS.md**: group by concern. Link to skills for detail.

## Example

Before (47 tokens):
```
## Error Handling
- Always use specific exception classes from @nestjs/common
- Never use generic HttpException
- Pass an object with contextual information as the parameter
- Include a message property in the object
- Include a context property with ClassName/methodName format
```

After (25 tokens):
```
## Errors
Use specific `@nestjs/common` exceptions, not `HttpException`. Pass context objects:
\`throw new BadRequestException({ message, context: \`${this.constructor.name}/${this.method.name}\` })\`
```