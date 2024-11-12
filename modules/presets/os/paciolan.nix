{ pkgs, users, machine-class, ... }: {
  homebrew = {
    casks =
      let
        skipSha = name: {
          inherit name;
          args = { require_sha = false; };
        };
        noQuarantine = name: {
          inherit name;
          args = { no_quarantine = true; };
        };
      in
      [
      ] ++ (if (machine-class == "pc") then [
        "figma"
        "postman"
      ] else [ ]);
    masApps = { } // (
      if (machine-class == "pc") then {
        # "Global Protect" = 1400555706; # TODO: https://github.com/mas-cli/mas/issues/321
        "Nexus Access Client" = 1246738113;
        "Microsoft Remote Desktop" = 1295203466;
      } else { }
    );
  };
}
