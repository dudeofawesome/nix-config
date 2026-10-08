{ ... }:
{
  programs = {
    codex.enable = true;

    claude-code = {
      context = ./CLAUDE.md;

      skills = {
      };
    };
  };
}
