{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "sdh-css-loader";
  version = "2.1.2";

  src = fetchzip {
    url = "https://github.com/DeckThemes/SDH-CssLoader/releases/download/v${finalAttrs.version}/SDH-CSSLoader-Decky.zip";
    hash = "sha256-7FWCiGf9JqgpW/qzwc0qiYuZJfgJSbhvPdq1YVVaSyg=";
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
    description = "Decky plugin for loading custom CSS themes into the Steam UI";
    homepage = "https://github.com/DeckThemes/SDH-CssLoader";
    changelog = "https://github.com/DeckThemes/SDH-CssLoader/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.gpl2Plus;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
