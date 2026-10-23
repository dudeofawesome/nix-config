{
  lib,
  fetchurl,
  unzip,
  stdenv,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "thaw";
  version = "2.1.0";

  src = fetchurl {
    url = "https://github.com/thaw-app/Thaw/releases/download/${finalAttrs.version}/Thaw_${finalAttrs.version}.zip";
    hash = "sha256-I/6FDda24/girwCi2nbG1GE1wvqKDe746PoJ0e/T7sE=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv Thaw.app "$out/Applications/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--use-github-releases"
    ];
  };

  meta = {
    description = "Powerful menu bar manager for macOS";
    homepage = "https://github.com/thaw-app/Thaw";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
