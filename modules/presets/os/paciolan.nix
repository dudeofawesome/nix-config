{
  lib,
  users,
  machine-class,
  ...
}:
{
  homebrew = {
    casks =
      let
        skipSha = name: {
          inherit name;
          args = {
            require_sha = false;
          };
        };
        noQuarantine = name: {
          inherit name;
          args = {
            no_quarantine = true;
          };
        };
      in
      lib.flatten [
        (lib.optionals (machine-class == "pc") [
          "figma"
        ])
      ];
    masApps =
      { }
      // (lib.mkIf (machine-class == "pc") {
        # "Global Protect" = 1400555706; # TODO: https://github.com/mas-cli/mas/issues/321
        # "Microsoft Remote Desktop" = 1295203466;
      });
  };
}
