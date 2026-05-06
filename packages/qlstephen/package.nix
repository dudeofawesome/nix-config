{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
  unzip,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qlstephen";
  version = "1.5.1";

  src = fetchurl {
    url = "https://github.com/whomwah/qlstephen/releases/download/${finalAttrs.version}/QLStephen.qlgenerator.${finalAttrs.version}.zip";
    hash = "sha256-H0phBGh9jGR5MW3qN6iOsalIdbCBR0S53DB0kuslnAQ=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Library/QuickLook"
    mv QLStephen.qlgenerator "$out/Library/QuickLook/"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Quick Look plugin for plaintext files without an extension";
    homepage = "https://whomwah.github.io/qlstephen/";
    changelog = "https://github.com/whomwah/qlstephen/releases";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
