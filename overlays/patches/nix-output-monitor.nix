final: prev: {
  nix-output-monitor =
    assert prev.lib.assertMsg (!prev.lib.versionOlder "2.2.0" prev.nix-output-monitor.version) ''
      Recheck and remove overlays/patches/nix-output-monitor.nix: nom is newer than 2.2.0.
      Upstream PR #321 fixes unknown Determinate Nix activity and result types.
    '';
    prev.nix-output-monitor.override {
      extraComposeFunctions = [
        (prev.haskell.lib.compose.appendPatch (
          prev.fetchpatch2 {
            # https://github.com/maralorn/nix-output-monitor/pull/321
            url = "https://github.com/maralorn/nix-output-monitor/compare/c40cb120262d9e9b1b988898708b124f6ffc0913...f1c3b836d24b674d1fc843dd293dfcdacb3ed2e8.patch";
            relative = "nix-output-monitor";
            hash = "sha256-OVem8p/Q2MAo+fZk2MmqO8cBANDFRJQdtpd6ypUIdP0=";
          }
        ))
      ];
    };

  nh = prev.nh.override { inherit (final) nix-output-monitor; };
}
