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
        postman

        (lib.optionals isDarwin [
          pkgs-unstable.tableplus
        ])
      ])
    ];

  programs = {
    slack = {
      enable = machine-class == "pc";
      package = pkgs-unstable.slack;
    };
    zoom-us = {
      enable = machine-class == "pc";
      package = pkgs-unstable.zoom-us;
    };
  };
}
