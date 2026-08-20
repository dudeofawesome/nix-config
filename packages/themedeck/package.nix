{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
  yt-dlp,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "themedeck";
  version = "3.0.1";

  src = fetchzip {
    url = "https://github.com/BrenticusMaximus/ThemeDeck/releases/download/v${finalAttrs.version}/ThemeDeck-v${finalAttrs.version}.zip";
    hash = "sha256-AY14QkqtyrQmtsArFrxcONfN4J8mOnCOHulI2ht2oVY=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"

    runHook postInstall
  '';

  passthru = {
    runtimeDependencies = [ yt-dlp ];

    updateScript = nix-update-script {
      extraArgs = [ "--flake" ];
    };
  };

  meta = {
    description = "Decky plugin for adding custom music to Steam game pages";
    homepage = "https://github.com/BrenticusMaximus/ThemeDeck";
    changelog = "https://github.com/BrenticusMaximus/ThemeDeck/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
