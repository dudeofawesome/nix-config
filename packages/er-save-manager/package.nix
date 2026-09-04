{
  lib,
  appimageTools,
  fetchurl,
  nix-update-script,
  ...
}:

let
  pname = "er-save-manager";
  version = "1.10.1";

  src = fetchurl {
    url = "https://github.com/Hapfel1/er-save-manager/releases/download/v${version}/er-save-manager_${version}_Linux.AppImage";
    hash = "sha256-oAYa/ngDi4atgAXFiYmWWI3BacYAfvV0Cu2fBr//h0w=";
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 \
      ${appimageContents}/er-save-manager.desktop \
      $out/share/applications/er-save-manager.desktop
    install -Dm444 \
      ${appimageContents}/er-save-manager.png \
      $out/share/icons/hicolor/256x256/apps/er-save-manager.png
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Elden Ring save file editor, backup manager, and corruption fixer";
    homepage = "https://github.com/Hapfel1/er-save-manager";
    license = lib.licenses.unfree;
    mainProgram = "er-save-manager";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
