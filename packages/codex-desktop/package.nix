{
  lib,
  stdenv,
  fetchurl,
  unzip,
  ...
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    sources = {
      aarch64-darwin = {
        appcast = "https://persistent.oaistatic.com/codex-app-prod/appcast.xml";
        url = "https://persistent.oaistatic.com/codex-app-prod/Codex-darwin-arm64-${finalAttrs.version}.zip";
        hash = "sha256-OmIp1/asWnoUfqT+NBAodKCtGoeJNH3gzq55e9hj3Jc=";
      };
      x86_64-darwin = {
        appcast = "https://persistent.oaistatic.com/codex-app-prod/appcast-x64.xml";
        url = "https://persistent.oaistatic.com/codex-app-prod/Codex-darwin-x64-${finalAttrs.version}.zip";
        hash = null;
      };
    };

    source =
      sources.${stdenv.hostPlatform.system}
        or (throw "Unsupported system for codex-desktop: ${stdenv.hostPlatform.system}");
  in
  {
    pname = "codex-desktop";
    version = "26.429.30905";

    src = fetchurl {
      inherit (source) url hash;
    };

    sourceRoot = ".";

    nativeBuildInputs = [ unzip ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications"
      mv Codex.app "$out/Applications/"

      runHook postInstall
    '';

    meta = {
      description = "OpenAI Codex desktop app for macOS";
      homepage = "https://openai.com/codex/";
      changelog = "https://developers.openai.com/codex/changelog?type=codex-app";
      downloadPage = source.appcast;
      license = lib.licenses.unfree;
      platforms = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  }
)
