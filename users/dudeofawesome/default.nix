{ pkgs, ... }:

{
  home = {
    stateVersion = "23.05";

    packages = with pkgs; [
      atuin
      bat
      bottom
      most
      ripgrep
    ];
  };

  programs = {
    fish = {
      enable = true;
      plugins = [
        {
          name = "tide";
          src = pkgs.fishPlugins.tide.src;
        }
        {
          name = "autopair.fish";
          src = pkgs.fishPlugins.autopair-fish.src;
        }
        {
          name = "node-binpath";
          src = pkgs.fetchFromGitHub {
            owner = "dudeofawesome";
            repo = "plugin-node-binpath";
            rev = "3d190054a4eb49b1cf656de4e3893ded33ce3023";
            sha256 = "8MQQ6LUBNgvUkgXu7ZWmfo2wRghCML4jXVxYUAXiwRc=";
          };
          # src = fish-plugin-node-binpath;
        }
        {
          name = "node-version";
          src = pkgs.fetchFromGitHub {
            owner = "dudeofawesome";
            repo = "fish-plugin-node-version";
            rev = "9dbebdb2494852a7a95b8b8bfb20477fce69a51d";
            sha256 = "vuc4OqUtMMvL61lFhwNVT0zcnwpTNG6U6o/BDBTsXhs=";
          };
          # src = fish-plugin-node-version;
        }
        {
          name = "fishtape";
          src = pkgs.fetchFromGitHub {
            owner = "jorgebucaran";
            repo = "fishtape";
            rev = "e6e5fc23dd062ee5ed11828951bf2c85d6798db5";
            sha256 = "Sp2IarJe2SVBH1pD7pdDnXrndG4h3b5G4f3SMBceShw=";
          };
        }
      ];
    };

    git = {
      enable = true;

      userName = "Louis Orleans";
      userEmail = "louis@orleans.io";

      ignores = [
        ".DS_Store"
      ];

      signing = {
        signByDefault = true;
        key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN2YSc/BayEsyCgPLWQZ17/WElA5UI5bChLzMHeXYCXb";
      };

      extraConfig = {
        gpg = {
          format = "ssh";
        };

        "gpg \"ssh\"" = {
          program = "/Applications/1Password.app/Contents/MacOS/op-ssh-sign";
        };
      };
    };
  };
}
