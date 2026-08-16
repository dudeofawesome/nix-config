{
  description = "My multi-machine, multi-arch, multi-user, multi-os Nix config";

  inputs = {
    # TODO: use `nixpkgs-YY.MM-darwin` for Darwin
    nixpkgs-linux-stable.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-darwin-stable.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3";

    nur = {
      url = "github:nix-community/NUR";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    nix-std.url = "github:chessai/nix-std";

    disko = {
      # 1265 fixes bcachefs subvolume provisioning
      url = "github:nix-community/disko/pull/1265/head";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    jovian = {
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };
    home-manager-master = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin-stable";
    };

    sops = {
      url = "github:Mic92/sops-nix";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    nixos-raspberrypi = {
      url = "github:nvmd/nixos-raspberrypi/main";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    vscode-server = {
      url = "github:nix-community/nixos-vscode-server";
      # TODO: how to follow nixpkgs-darwin-stable when on macOS?
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    dudeofawesome_dotfiles = {
      url = "github:dudeofawesome/dotfiles";
      flake = false;
    };

    upaymeifixit_dotfiles = {
      url = "github:upaymeifixit/dotfiles";
      flake = false;
    };

    vim-lumen = {
      url = "github:vimpostor/vim-lumen";
      flake = false;
    };

    fish-osx = {
      url = "github:oh-my-fish/plugin-osx";
      flake = false;
    };

    fish-node-binpath = {
      url = "github:dudeofawesome/plugin-node-binpath";
      flake = false;
    };

    fish-node-version = {
      url = "github:dudeofawesome/fish-plugin-node-version";
      flake = false;
    };

    fish-shell-integrations = {
      url = "github:dudeofawesome/fish-plugin-shell-integrations";
      flake = false;
    };

    fish-editor-updater = {
      url = "github:dudeofawesome/fish-plugin-editor-updater";
      flake = false;
    };

    fish-nvm = {
      url = "github:jorgebucaran/nvm.fish";
      flake = false;
    };

    op-shell-plugins = {
      url = "github:1Password/shell-plugins";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    claude-code-nix = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };

    decky-openrgb = {
      url = "github:dudeofawesome/decky-openrgb";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };

    wolf-nvidia-vol = {
      url = "github:altano/flakes?dir=wolf-nvidia-vol";
      inputs.nixpkgs.follows = "nixpkgs-linux-stable";
    };
  };

  outputs =
    inputs@{
      nixpkgs-linux-stable,
      ...
    }:
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
            import nixpkgs-linux-stable {
              inherit system;
              config.allowUnfree = true;
            }
          )
        );

      nixosConfigurations = import ./hosts/nixos params;
      darwinConfigurations = import ./hosts/darwin params;
    in
    {
      packages = forAllSystems (pkgs: import ./packages { inherit lib; } (pkgs // { inherit lib; }));

      nixosModules.default = import ./modules/configurable/os {
        inherit lib;
        os = "linux";
      };
      darwinModules.default = import ./modules/configurable/os {
        inherit lib;
        os = "darwin";
      };
      homeModules.default = import ./modules/configurable/home-manager;

      inherit nixosConfigurations darwinConfigurations;
      homeConfigurations = lib.pipe (nixosConfigurations // darwinConfigurations) [
        (lib.filterAttrs (_: host: host.config ? home-manager))
        (lib.mapAttrsToList (
          hostname: host:
          lib.mapAttrs' (username: config: {
            name = "${username}@${hostname}";
            value = {
              activationPackage = config.home.activationPackage;
              inherit config;
            };
          }) host.config.home-manager.users
        ))
        lib.mergeAttrsList
      ];

      # run `nix fmt` to format all files
      formatter = forAllSystems (nixpkgs: nixpkgs.nixfmt);
    };
}
