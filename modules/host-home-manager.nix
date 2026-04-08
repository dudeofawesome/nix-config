params:
let
  inputs = params.inputs;
  users = params.users;
in
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;

    users = builtins.mapAttrs (key: val: val.home-manager) users;
    extraSpecialArgs = params;
    sharedModules = [
      inputs.sops.homeManagerModules.sops
      inputs.op-shell-plugins.hmModules.default
      {
        disabledModules = [ "programs/claude-code.nix" ];
        imports = [ "${inputs.home-manager-master}/modules/programs/claude-code.nix" ];
      }
      {
        disabledModules = [ "programs/codex.nix" ];
        imports = [ "${inputs.home-manager-master}/modules/programs/codex.nix" ];
      }

      ./configurable/home-manager/default.nix
    ];
  };

  # home-manager recommends setting this: https://nix-community.github.io/home-manager/options.xhtml#opt-xdg.portal.enable
  environment.pathsToLink = [
    "/share/xdg-desktop-portal"
    "/share/applications"
  ];
}
