{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "protondb-decky";
  version = "1.3.3";

  src = fetchzip {
    url = "https://github.com/bschelst/protondb-decky/releases/download/v${finalAttrs.version}/protondb-decky.zip";
    hash = "sha256-xiLEgY90f629Yxuk+uBXFya/Gb0ytmHJ66d41T9Y/3c=";
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
    description = "Decky Loader plugin that displays ProtonDB badges on Steam game pages";
    homepage = "https://github.com/bschelst/protondb-decky";
    changelog = "https://github.com/bschelst/protondb-decky/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
