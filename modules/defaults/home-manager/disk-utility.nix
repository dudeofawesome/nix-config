{ pkgs, lib, config, ... }: {
  config = lib.mkIf pkgs.stdenv.targetPlatform.isDarwin {
    targets.darwin.defaults."com.apple.DiskUtility" = {
      SidebarShowAllDevices = true;
      "OperationProgress DetailsVisible" = true;
    };
  };
}
