{ pkgs, ... }:
{
  config = {
    programs.git-fork = {
      enable = pkgs.stdenv.targetPlatform.isDarwin;
    };
  };
}
