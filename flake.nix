{
  description = "My multi-machine, multi-arch, multi-user, multi-os Nix config";

  inputs = {
    # TODO: use `nixpkgs-YY.MM-darwin` for Darwin
    # renovate-flake: datasource=git-refs depName=nixpkgs-linux-stable packageName=https://github.com/NixOS/nixpkgs versioning=nixpkgs currentValue=nixos-25.11 currentDigest=36a601196c4ebf49e035270e10b2d103fe39076b
    nixpkgs-linux-stable.url = "github:nixos/nixpkgs/nixos-25.11";
    # renovate-flake: datasource=git-refs depName=nixpkgs-darwin-stable packageName=https://github.com/NixOS/nixpkgs versioning=nixpkgs currentValue=nixpkgs-25.11-darwin currentDigest=d96b37bbeb9840f1c0ebfe90585ef5067b69bbb3
    nixpkgs-darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-25.11-darwin";
    # renovate-flake: datasource=git-refs depName=nixpkgs-unstable packageName=https://github.com/NixOS/nixpkgs versioning=nixpkgs currentValue=nixos-unstable currentDigest=68d8aa3d661f0e6bd5862291b5bb263b2a6595c9
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # renovate-flake: datasource=git-refs depName=nur packageName=https://github.com/nix-community/NUR versioning=git currentDigest=aa8c71ac75ddf246f72c5ba101e9cfca87081796
    nur = {
      url = "github:nix-community/NUR";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    # renovate-flake: datasource=git-refs depName=nix-std packageName=https://github.com/chessai/nix-std versioning=git currentDigest=31bbc925750cc9d8f828fe55cee1a2bd985e0c00
    nix-std.url = "github:chessai/nix-std";

    # renovate-flake: datasource=git-refs depName=disko packageName=https://github.com/nix-community/disko versioning=git currentDigest=0d8c6ad4a43906d14abd5c60e0ffe7b587b213de
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    # renovate-flake: datasource=git-refs depName=home-manager packageName=https://github.com/nix-community/home-manager versioning=git currentValue=release-25.11 currentDigest=0759e0e137305bc9d0c52c204c6d8dffe6f601a6
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };
    # renovate-flake: datasource=git-refs depName=home-manager-master packageName=https://github.com/nix-community/home-manager versioning=git currentValue=master currentDigest=9df3a639007cfe0d074433f7fc225ea94f877d08
    home-manager-master = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    # renovate-flake: datasource=git-refs depName=darwin packageName=https://github.com/nix-darwin/nix-darwin versioning=git currentValue=nix-darwin-25.11 currentDigest=ebec37af18215214173c98cf6356d0aca24a2585
    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs-darwin-stable";
    };

    # renovate-flake: datasource=git-refs depName=sops packageName=https://github.com/Mic92/sops-nix versioning=git currentDigest=49021900e69812ba7ddb9e40f9170218a7eca9f4
    sops = {
      url = "github:Mic92/sops-nix";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    # renovate-flake: datasource=git-refs depName=vscode-server packageName=https://github.com/nix-community/nixos-vscode-server versioning=git currentDigest=6d5f074e4811d143d44169ba4af09b20ddb6937d
    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    # renovate-flake: datasource=git-refs depName=dudeofawesome_dotfiles packageName=https://github.com/dudeofawesome/dotfiles versioning=git currentDigest=55fe7748db24f14148c5d3b59096921c6d7431b7
    dudeofawesome_dotfiles = {
      url = "github:dudeofawesome/dotfiles";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=upaymeifixit_dotfiles packageName=https://github.com/upaymeifixit/dotfiles versioning=git currentDigest=b41606c12f3f3bf98b9ca7596698fe8ce221d3c3
    upaymeifixit_dotfiles = {
      url = "github:upaymeifixit/dotfiles";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=vim-lumen packageName=https://github.com/vimpostor/vim-lumen versioning=git currentDigest=ac13c32c3e309f6c6a84ff6cad8dbb135e75f0e4
    vim-lumen = {
      url = "github:vimpostor/vim-lumen";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=fish-osx packageName=https://github.com/oh-my-fish/plugin-osx versioning=git currentDigest=27039b251201ec2e70d8e8052cbc59fa0ac3b3cd
    fish-osx = {
      url = "github:oh-my-fish/plugin-osx";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=fish-node-binpath packageName=https://github.com/dudeofawesome/plugin-node-binpath versioning=git currentDigest=3d190054a4eb49b1cf656de4e3893ded33ce3023
    fish-node-binpath = {
      url = "github:dudeofawesome/plugin-node-binpath";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=fish-node-version packageName=https://github.com/dudeofawesome/fish-plugin-node-version versioning=git currentDigest=d135a01b32473e7978d22d071e5704a8964159e1
    fish-node-version = {
      url = "github:dudeofawesome/fish-plugin-node-version";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=fish-shell-integrations packageName=https://github.com/dudeofawesome/fish-plugin-shell-integrations versioning=git currentDigest=72c9c7a6d1e2923c8d70da02a0e440c24744e9e4
    fish-shell-integrations = {
      url = "github:dudeofawesome/fish-plugin-shell-integrations";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=fish-editor-updater packageName=https://github.com/dudeofawesome/fish-plugin-editor-updater versioning=git currentDigest=0fb6a8f3c3405ee232c6aec92e2c5151d78fe2f3
    fish-editor-updater = {
      url = "github:dudeofawesome/fish-plugin-editor-updater";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=fish-nvm packageName=https://github.com/jorgebucaran/nvm.fish versioning=git currentDigest=a0892d0bb2304162d5faff561f030bb418cac34d
    fish-nvm = {
      url = "github:jorgebucaran/nvm.fish";
      flake = false;
    };

    # renovate-flake: datasource=git-refs depName=op-shell-plugins packageName=https://github.com/1Password/shell-plugins versioning=git currentDigest=7efd8bcd98db308d9314d798cf5c0b6b0dba111f
    op-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    # renovate-flake: datasource=git-refs depName=claude-code-nix packageName=https://github.com/sadjow/claude-code-nix versioning=git currentDigest=214fdf6592f40a8bb472e80283c029d01fb6653d
    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    # renovate-flake: datasource=git-refs depName=codex-cli-nix packageName=https://github.com/sadjow/codex-cli-nix versioning=git currentDigest=8be597476146c75f440708f9a7ad50ae489641c4
    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };
  };

  outputs =
    inputs@{ nixpkgs-linux-stable, nixpkgs-unstable, ... }:
    let
      lib = nixpkgs-linux-stable.lib;
      params = {
        inherit
          inputs
          lib
          ;
        location = "$HOME/git/dudeofawesome/nix-config";
        usersModule = import ./users { inherit lib; };
        packageOverlays = ./overlays;
      };

      forAllSystems =
        function:
        lib.genAttrs lib.systems.flakeExposed (
          system:
          function (
            import nixpkgs-unstable {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );
    in
    {
      nixosConfigurations = import ./hosts/nixos params;
      darwinConfigurations = import ./hosts/darwin params;

      # run `nix fmt` to format all files
      formatter = forAllSystems (nixpkgs: nixpkgs.nixfmt);
    };
}
