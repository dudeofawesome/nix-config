{ lib, ... }:
{
  imports = [
    ../../../modules/defaults/home-manager
  ];

  home.stateVersion = "23.05";

  programs.git = {
    signing.signByDefault = lib.mkForce false;
    settings.user.name = "Lauren";
  };
}
