{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tabmaster";
  version = "2.16.2";

  src = fetchzip {
    url = "https://github.com/Tormak9970/TabMaster/releases/download/v${finalAttrs.version}/TabMaster_v${finalAttrs.version}.zip";
    hash = "sha256-kUfEJ3X8Bwv8FIIfOvTUeMvmwmFpZdRr9apmC6cfOzM=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Decky plugin for customizing, adding, and removing Steam library tabs";
    homepage = "https://github.com/Tormak9970/TabMaster";
    changelog = "https://github.com/Tormak9970/TabMaster/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      bsd3
      gpl3Only
    ];
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
