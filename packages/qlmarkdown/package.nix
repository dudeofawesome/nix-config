{
  lib,
  stdenv,
  fetchurl,
  nix-update-script,
  unzip,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "qlmarkdown";
  version = "1.5.0";

  src = fetchurl {
    url = "https://github.com/sbarex/QLMarkdown/releases/download/${finalAttrs.version}/QLMarkdown.zip";
    hash = "sha256-gFLis4lkS1gg6WSXTYfRo64omS0QPa7dmlIr7atrR1E=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/"{Applications,bin}
    mv QLMarkdown.app "$out/Applications/"
    ln -s "$out/Applications/QLMarkdown.app/Contents/Resources/qlmarkdown_cli" "$out/bin/qlmarkdown_cli"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Quick Look extension for Markdown files";
    homepage = "https://github.com/sbarex/QLMarkdown";
    changelog = "https://github.com/sbarex/QLMarkdown/releases";
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "qlmarkdown_cli";
  };
})
