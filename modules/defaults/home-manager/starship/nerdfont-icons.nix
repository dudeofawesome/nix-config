{
  pkgs,
  pkgs-unstable,
  lib,
  config,
  osConfig,
  ...
}:
{
  programs = {
    starship = {
      settings = {
        # Here is how you can shorten some long paths by text replacement
        # similar to mapped_locations in Oh My Posh:
        directory.substitutions = {
          "Documents" = "󰈙 ";
          "Downloads" = " ";
          "Music" = " ";
          "Pictures" = " ";
          # Keep in mind that the order matters. For example:
          # "Important Documents" = " 󰈙 "
          # will not be replaced, because "Documents" was already substituted before.
          # So either put "Important Documents" before "Documents" or use the substituted version:
          # "Important 󰈙 " = " 󰈙 "
        };

        aws.symbol = " ";
        azure.symbol = " ";
        gcloud.symbol = "󱇶 ";
        kubernetes.symbol = "󱃾 ";
        docker_context.symbol = " ";
        nix_shell.symbol = " ";
        guix_shell.symbol = " ";

        conda.symbol = " ";
        package.symbol = "󰏗";
        gradle.symbol = " ";

        directory.read_only = " 󰌾";
        directory.home_symbol = " ";
        git_branch.symbol = "";
        git_commit.tag_symbol = "  ";
        fossil_branch.symbol = "";
        hg_branch.symbol = "";
        pijul_channel.symbol = "";

        buf.symbol = "";
        c.symbol = "";
        crystal.symbol = "";
        dart.symbol = "";
        elixir.symbol = "";
        elm.symbol = "";
        fennel.symbol = "";
        golang.symbol = "";
        haskell.symbol = "";
        haxe.symbol = "";
        java.symbol = "";
        julia.symbol = "";
        kotlin.symbol = "";
        lua.symbol = "";
        meson.symbol = "󰔷";
        nim.symbol = "󰆥";
        nodejs.symbol = "";
        ocaml.symbol = " ";
        perl.symbol = " ";
        php.symbol = "";
        python.symbol = " ";
        rlang.symbol = "󰟔 ";
        ruby.symbol = "";
        rust.symbol = "󱘗";
        scala.symbol = "";
        swift.symbol = "";
        zig.symbol = "";

        hostname.ssh_symbol = "";
        memory_usage.symbol = "󰍛";
        os.symbols = {
          Alpaquita = "";
          Alpine = " ";
          AlmaLinux = " ";
          Amazon = "";
          Android = " ";
          Arch = " ";
          Artix = " ";
          CentOS = " ";
          Debian = " ";
          DragonFly = " ";
          Emscripten = " ";
          EndeavourOS = " ";
          Fedora = " ";
          FreeBSD = " ";
          Garuda = "󰛓 ";
          Gentoo = " ";
          HardenedBSD = "󰞌";
          Illumos = "󰈸";
          Kali = " ";
          Linux = "";
          Mabox = "";
          Macos = " ";
          Manjaro = " ";
          Mariner = " ";
          MidnightBSD = "";
          Mint = " ";
          NetBSD = " ";
          NixOS = " ";
          OpenBSD = "󰈺 ";
          openSUSE = " ";
          OracleLinux = "󰌷 ";
          Pop = " ";
          Raspbian = " ";
          Redhat = " ";
          RedHatEnterprise = " ";
          RockyLinux = " ";
          Redox = "󰀘 ";
          Solus = "󰠳 ";
          SUSE = " ";
          Ubuntu = " ";
          Unknown = "";
          Void = " ";
          Windows = "󰍲 ";
        };
      };
    };
  };
}
