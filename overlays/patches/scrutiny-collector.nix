{ lib, prev }:
prev.scrutiny-collector.overrideAttrs (old: {
  patches = (old.patches or [ ]) ++ [ ./scrutiny-collector-darwin-host-id.patch ];

  meta = old.meta // {
    platforms = lib.platforms.all;
  };
})
