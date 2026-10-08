## Documentation rules

- **Name things by what they are — never by metaphor or codename. Applies to everything you write: docs, code comments, commit/MR messages.** A coined name ("the oracle", "the salvage") is only cheaper for the writer who already holds the referent; every reader pays to map it back, and the next writer coins another name on top of it, so the distance from the literal thing compounds every session. Use the plain descriptive name ("the uopy proxy", not "the oracle"). A descriptive abbreviation is fine; an analogy is not. This is a readability rule, NOT a token-efficiency one.
- **Before authoring or editing Claude *config*** (skills, commands, hooks, agents, CLAUDE.md/AGENTS.md) invoke the `write-claude-tooling` skill first.
