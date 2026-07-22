{
  lib,
  stdenv,
  fetchurl,
  cacert,
  curl,
  gnused,
  libxml2,
  openssl,
  unzip,
  writeShellApplication,
  ...
}:

stdenv.mkDerivation (
  finalAttrs:
  let
    sources = {
      aarch64-darwin = {
        appcast = "https://persistent.oaistatic.com/codex-app-prod/appcast.xml";
        url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-arm64-${finalAttrs.version}.zip";
        hash = "sha256-ulBk8u8/4cKF6fGJzqDA7sT1OtzFYEstmoJdCYlRMxg=";
      };
      x86_64-darwin = {
        appcast = "https://persistent.oaistatic.com/codex-app-prod/appcast-x64.xml";
        url = "https://persistent.oaistatic.com/codex-app-prod/ChatGPT-darwin-x64-${finalAttrs.version}.zip";
        hash = "sha256-onrfTJevY3C/g/dypOu6sK50/MJWHYhhqC5zrkzdqJE=";
      };
    };

    source =
      sources.${stdenv.hostPlatform.system}
        or (throw "Unsupported system for chatgpt: ${stdenv.hostPlatform.system}");
  in
  {
    pname = "chatgpt-desktop";
    version = "26.715.71837";

    src = fetchurl {
      inherit (source) url hash;
    };

    sourceRoot = ".";

    nativeBuildInputs = [ unzip ];

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications"
      mv ChatGPT.app "$out/Applications/"

      runHook postInstall
    '';

    passthru.updateScript = lib.getExe (writeShellApplication {
      name = "chatgpt-update-script";
      runtimeInputs = [
        cacert
        curl
        gnused
        libxml2
        openssl
      ];
      text = ''
        get_url() {
          curl --fail --location --silent "$1" \
            | xmllint --xpath 'string((//*[local-name()="item"][1]/*[local-name()="enclosure"]/@url)[1])' -
        }

        get_hash() {
          curl --fail --location --silent "$1" \
            | openssl dgst -sha256 -binary \
            | openssl base64
        }

        arm_appcast="https://persistent.oaistatic.com/codex-app-prod/appcast.xml"
        x86_appcast="https://persistent.oaistatic.com/codex-app-prod/appcast-x64.xml"

        arm_url=$(get_url "$arm_appcast")
        x86_url=$(get_url "$x86_appcast")

        version=''${arm_url##*-}
        version=''${version%.zip}

        arm_hash="sha256-$(get_hash "$arm_url")"
        x86_hash="sha256-$(get_hash "$x86_url")"

        sed -i -E \
          -e 's@(version = )"[0-9]+\.[0-9]+\.[0-9]+";@\1"'"$version"'";@' \
          -e '/aarch64-darwin = \{/,/};/ s@(hash = )("sha256-[A-Za-z0-9+/]+="|null);@\1"'"$arm_hash"'";@' \
          -e '/x86_64-darwin = \{/,/};/ s@(hash = )("sha256-[A-Za-z0-9+/]+="|null);@\1"'"$x86_hash"'";@' \
          ./packages/chatgpt/package.nix
      '';
    });

    meta = {
      description = "OpenAI ChatGPT desktop app for macOS";
      homepage = "https://chatgpt.com/download/";
      changelog = "https://developers.openai.com/codex/changelog?type=codex-app";
      downloadPage = "https://chatgpt.com/download/";
      license = lib.licenses.unfree;
      platforms = [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    };
  }
)
