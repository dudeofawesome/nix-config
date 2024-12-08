{
  pkgs,
  pkgs-unstable,
  machine-class,
  ...
}:
with pkgs.stdenv.targetPlatform;
{
  home.packages =
    with pkgs;
    [
      # Utilities
      awscli2
      glab
      k6
      terraform
    ]
    ++ (
      if (machine-class == "pc") then
        [
          # ansible
          gitlab-runner
          pkgs-unstable.postman
          pkgs-unstable.slack
          pkgs-unstable.tableplus
          pkgs-unstable.zoom-us
        ]
      else
        [ ]
    );
}
