{ lib, ... }:
{
  imports = [ ./nerdfont-icons.nix ];

  programs.starship = {
    enable = true;
    enableTransience = false;

    settings =
      let
        groups = {
          clouds = [
            "aws"
            "azure"
            "gcloud"
            "kubernetes"
            "openstack"
          ];

          contexts = [
            "nix_shell"
            "guix_shell"
            "docker_context"
            "container"
            "direnv"
            "meson"
            "nats"
            # "shell"
            # "shlvl"
            "spack"
            "vcsh"
            "opa"
          ];

          languages = [
            "buf"
            "bun"
            "c"
            "cmake"
            "cobol"
            "crystal"
            "daml"
            "dart"
            "deno"
            "dotnet"
            "elixir"
            "elm"
            "erlang"
            "fennel"
            "gleam"
            "golang"
            "haskell"
            "haxe"
            "java"
            "julia"
            "kotlin"
            "lua"
            "mojo"
            "nim"
            "nodejs"
            "ocaml"
            "odin"
            "perl"
            "php"
            "pulumi"
            "purescript"
            "python"
            "quarto"
            "rlang"
            "raku"
            "red"
            "ruby"
            "rust"
            "scala"
            "solidity"
            "swift"
            "terraform"
            "typst"
            "vagrant"
            "vlang"
            "zig"
          ];

          package_managers = [
            "conda"
            "package"
            "gradle"
            "helm"
          ];

          vcs = [
            "git_branch"
            "git_status"
            "git_state"
            # "git_commit"
            # "git_metrics"
            "fossil_branch"
            # "fossil_metrics"
            "pijul_channel"
            "hg_branch"
          ];
        };

        colors = {
          system = "#44475a";
          directory = "blue";
          cloud = "bright-purple";
          duration = "yellow";
          vcs = "green";
          context = "purple";
          time = "#44475a";
          languages = "green";
        };
      in
      {
        format =
          lib.pipe
            [
              # left side
              "[](fg:${colors.system})"
              "[$os$username](bg:prev_fg)"
              "[](fg:prev_bg bg:${colors.directory})"
              "$directory"
              "([](fg:prev_bg bg:${colors.vcs})${
                lib.strings.concatStrings (builtins.map (vcs: "\$${vcs}") groups.vcs)
              })"
              "([](fg:prev_bg bg:${colors.context})${
                lib.strings.concatStrings (builtins.map (ctx: "\$${ctx}") groups.contexts)
              })"
              "([](fg:prev_bg bg:bright-yellow)[$sudo](fg:prev_fg bg:prev_gb))"
              "[](fg:prev_bg)"

              "$fill"

              # right side
              "([](bg:prev_bg fg:${colors.languages})${
                lib.strings.concatStrings (
                  builtins.map (item: "\$${item}") (groups.languages ++ groups.package_managers)
                )
              })"
              "([](bg:prev_bg fg:${colors.cloud})${
                lib.strings.concatStrings (builtins.map (item: "\$${item}") (groups.clouds))
              })"
              "([](bg:prev_bg fg:${colors.duration})$cmd_duration)"
              "[](bg:prev_bg fg:${colors.time})$time"
              "[](fg:prev_bg)"

              # prompt on new line
              "$line_break"
              "$character"
            ]
            [
              lib.flatten
              lib.strings.concatStrings
            ];

        fill = {
          symbol = "";
          style = "bright-black";
        };

        # Disable the blank line at the start of the prompt
        # add_newline = false

        # You can also replace your username with a neat symbol like   or disable this
        # and use the os module below
        username = {
          show_always = false;
          style_user = "bg:#prev_bg";
          style_root = "bg:#prev_bg";
          format = "[$user ]($style)";
          disabled = false;
        };

        sudo = {
          disabled = false;
          format = "[$symbol]($style)";
          symbol = "󱐋";
        };

        # An alternative to the username module which displays a symbol that
        # represents the current operating system
        os = {
          style = "bg:${colors.system}";
          disabled = false; # Disabled by default
        };
        directory = {
          style = "bg:prev_bg";
          format = "[ $path ]($style)";
          truncation_length = 3;
          truncation_symbol = "…/";
        };

        aws = {
          style = "bg:${colors.cloud}";
          format = ''[$symbol ($profile )($region )(\[$duration\] )]($style)'';
        };

        kubernetes = {
          disabled = false;
          style = "bg:blue";
          format = "[ $symbol$context(/$namespace) ]($style)";
        };

        nix_shell = {
          heuristic = true;
          style = "bg:prev_bg";
          format = "[ $symbol ]($style)";
        };

        git_branch = {
          style = "bg:${colors.vcs}";
          format = "[ $symbol $branch ]($style)";
        };
        git_status = {
          style = "bg:${colors.vcs}";
          format = "[$all_status$ahead_behind ]($style)";
        };

        docker_context = {
          style = "bg:#06969A";
          format = "[ $symbol $context ]($style)";
        };

        cmd_duration = {
          style = "fg:bold bg:yellow";
          min_time_to_notify = 5000; # ms
          format = ''[ $duration ]($style)'';
        };
        time = {
          disabled = false;
          time_format = "%R"; # Hour:Minute Format
          style = "bg:#44475a";
          format = "[ $time ]($style)";
        };
      }
      // lib.genAttrs (groups.languages ++ groups.package_managers) (lang: {
        style = "bg:${colors.languages}";
        format = "[ $symbol ($version) ]($style)";
      });
  };
}
