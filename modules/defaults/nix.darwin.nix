{ lib, ... }:
{
  determinateNix = {
    customSettings.auto-optimise-store = lib.mkDefault true;

    nixosVmBasedLinuxBuilder = {
      enable = lib.mkDefault false;
    };

    determinateNixd = {
      builder.state = "disabled";

      garbageCollector.strategy = "automatic";
    };
  };
}
