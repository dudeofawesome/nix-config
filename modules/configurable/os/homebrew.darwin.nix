{ config, lib, ... }:
{
  homebrew.casks = lib.pipe (builtins.attrValues config.home-manager.users) [
    (builtins.map (user: user.homebrew.casks))
    lib.flatten
  ];
}
