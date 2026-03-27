{ ... }:
{
  programs.claude-code = {
    enable = true;

    skills = {
      commit-and-mr = ./skills/commit-and-mr.md;
      create-jira-item = ./skills/create-jira-item.md;
      notify-blame = ./skills/notify-blame.md;
      person-to-user-map = ./skills/person-to-user-map.md;
      strict-lint = ./skills/strict-lint.md;
    };
  };

  home.file = {
    # "git/paciolan/AGENTS.md".source = ./memories/git-paciolan.md;
    # "git/paciolan/CLAUDE.md".content = "@AGENTS.md";
  };
}
