{
  lib,
  stdenv,
  fetchurl,
  unzip,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  version = "1.5354.0";

  src = fetchurl {
    # releaseFeed = "https://downloads.claude.ai/releases/darwin/universal/RELEASES.json";
    url = "https://downloads.claude.ai/releases/darwin/universal/${finalAttrs.version}/Claude-9a9e3d5a4a368f0f49a80dc303b0ed1a18bfedad.zip";
    hash = "sha256-MJaDa0VLJGxMojB2rcAJEGE4/+kt5r4pg3LvqdZ9xMQ=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv Claude.app "$out/Applications/"

    runHook postInstall
  '';

  meta = {
    description = "Anthropic Claude desktop app for macOS";
    homepage = "https://claude.com/download";
    changelog = "https://docs.claude.com/en/release-notes/claude-apps";
    license = lib.licenses.unfree;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
