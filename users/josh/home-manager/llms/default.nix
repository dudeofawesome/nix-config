{ ... }:
{
  programs = {
    codex.enable = true;

    claude-code = {
      context = ./CLAUDE.md;

      skills = {
      };

      settings = {
        # Days to keep chat transcripts before Claude Code deletes them at
        # startup. Upstream default is 30; this is ~6 months.
        cleanupPeriodDays = 180;
      };
    };
  };
}
