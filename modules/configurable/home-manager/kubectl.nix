{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.programs.kubectl;
in
{
  options = {
    programs.kubectl = {
      enable = lib.mkEnableOption "kubectl";

      package = lib.mkPackageOption pkgs "kubectl" {
        default = [ "kubectl" ];
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [
      cfg.package
      pkgs.kubectx
      pkgs.kubectl-cnpg
    ];

    programs.fish.shellAbbrs = {
      "k" = "kubectl";
      "ktx" = "kubectx";
      "kns" = "kubens";
    };

    xdg.configFile = {
      kubectxFishCompletion = {
        enable = config.programs.fish.enable;
        target = "fish/completions/kubectx.fish";
        source = "${pkgs.kubectx}/share/fish/vendor_completions.d/kubectx.fish";
      };

      kubensFishCompletion = {
        enable = config.programs.fish.enable;
        target = "fish/completions/kubens.fish";
        source = "${pkgs.kubectx}/share/fish/vendor_completions.d/kubens.fish";
      };
    };
  };
}
