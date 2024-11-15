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
      inputs._1password-shell-plugins.hmModules.default

      ./configurable/home-manager/default.nix
    ];
  };
}
