{ inputs, config, pkgs, system, ... }: {
  nixpkgs.config.packageOverrides = prev: {
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
    };

    vimPlugins = prev.vimPlugins // { vim-lumen = inputs.vim-lumen; };

    vscodeExtensions = inputs.nix-vscode-extensions;

    dotfiles = {
      dudeofawesome = inputs.dudeofawesome_dotfiles;
      upaymeifixit = inputs.upaymeifixit_dotfiles;
    };
  };

  nixpkgs.overlays = [
    inputs.nur.overlay

    (final: prev: {
      stable = import inputs.nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
      };
    })

    (final: prev: {
      mkalias = prev.mkalias.overrideAttrs (old: {
        src = prev.fetchFromGitHub {
          owner = "dudeofawesome";
          repo = "mkalias";
          rev = "feat/stdout-hex-data";
          hash = "sha256-pPIMLnbpx8A9nvKsrOFFcsSu2v260dLr+4HQAc8A9xc=";
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
