{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "tabmaster";
  # renovate: datasource=github-releases depName=tabmaster packageName=Tormak9970/TabMaster
  version = "3.0.1";

  src = fetchzip {
    url = "https://github.com/Tormak9970/TabMaster/releases/download/v${finalAttrs.version}/TabMaster_v${finalAttrs.version}.zip";
    hash = "sha256-Bq8ToM8ugfT79qXUPxA9uvs5UHLnG/ft/lpAu8s1lLQ=";
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
