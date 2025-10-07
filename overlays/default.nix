{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.config.packageOverrides =
    prev:
    let
      build-inputs = (
        prev
        // {
          inherit lib;
        }
      );
    in
    {
      git-fork = import ../packages/git-fork build-inputs;
      gitup = import ../packages/gitup build-inputs;
      podman-mac-helper = import ../packages/podman-mac-helper build-inputs;

      fishPlugins = prev.fishPlugins // {
        osx = {
          name = "osx";
          src = inputs.fish-osx;
        };
        node-binpath = {
          name = "node-binpath";
          src = inputs.fish-node-binpath;
        };
        node-version = {
          name = "node-version";
          src = inputs.fish-node-version;
        };
        shell-integrations = {
          name = "shell-integrations";
          src = inputs.fish-shell-integrations;
        };
        editor-updater = {
          name = "editor-updater";
          src = inputs.fish-editor-updater;
        };
        nvm-fish = {
          name = "nvm.fish";
          src = inputs.fish-nvm;
        };
      };

      vimPlugins = prev.vimPlugins // {
        vim-lumen = inputs.vim-lumen;
      };

      dotfiles = {
        dudeofawesome = inputs.dudeofawesome_dotfiles;
        upaymeifixit = inputs.upaymeifixit_dotfiles;
      };
    };

  nixpkgs.overlays = [
    inputs.nur.overlays.default

    (final: prev: {
      scrutiny-collector = prev.scrutiny-collector.overrideAttrs (old: {
        meta = old.meta // {
          platforms = lib.platforms.all;
        };
      });
    })

    # TODO: create overlays to make programs recognize configs in XDG's ~/.config
    # (final: prev: {
    #   # Respect XDG conventions, damn it!
    #   # https://github.com/hlissner/dotfiles/blob/089f1a9da9018df9e5fc200c2d7bef70f4546026/modules/hardware/nvidia.nix
    #   (writeScriptBin "nvidia-settings" ''
    #     #!${stdenv.shell}
    #     mkdir -p "$XDG_CONFIG_HOME/nvidia"
    #     exec ${config.boot.kernelPackages.nvidia_x11.settings}/bin/nvidia-settings --config="$XDG_CONFIG_HOME/nvidia/settings"
    #   '')
    # })
  ];
}
