{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin = {
      defaults."abnerworks.Typora" = {
        useSeparateDarkTheme = true;
        theme = "Github";
        darkTheme = "Night";

        send_usage_info = false;
        restoreWhenLaunch = "2";
        can_collapse_outline_panel = true;

        relativePathWithDot = true;
        use_relative_path_for_img = true;

        strict_mode = true;
        prettyIndent = false;
        enable_subscript = true;
        enable_superscript = true;
        match_pari_markdown = true;
        indentSize = config.editorconfig.settings."*.md".indent_size;
      };
    };
  };
}
