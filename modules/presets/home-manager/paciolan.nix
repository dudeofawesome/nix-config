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
    lib.flatten [
      # Utilities
      awscli2
      glab
      k6
      terraform
      (lib.optionals (machine-class == "pc") [
        # ansible
        gitlab-runner
        pkgs-unstable.postman
        pkgs-unstable.slack
        pkgs-unstable.tableplus
        pkgs-unstable.zoom-us
      ])
    ];
}
