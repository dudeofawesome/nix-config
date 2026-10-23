{
  lib,
  stdenv,
  cacert,
  curl,
  fetchurl,
  gnused,
  jq,
  openssl,
  unzip,
  writeShellApplication,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "claude-desktop";
  # renovate: datasource=custom.claude depName=claude-desktop packageName=claude-desktop
  version = "3.6556.2";

  src = fetchurl {
    url = "https://downloads.claude.ai/releases/darwin/universal/${finalAttrs.version}/Claude-20c019a1e61fa5b687616af57d31f97bb3181723.zip";
    hash = "sha256-Xz42vQxQDw4CzKhISPXK9FM3IRfsZkFT2xh7NydUxno=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ unzip ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv Claude.app "$out/Applications/"

    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "claude-desktop-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      jq
      openssl
    ];
    text = ''
      release_feed="https://downloads.claude.ai/releases/darwin/universal/RELEASES.json"

      release=$(curl --fail --location --silent "$release_feed")

      version=$(jq --raw-output '.currentRelease' <<< "$release")
      url=$(jq --raw-output --arg version "$version" '.releases[] | select(.version == $version) | .updateTo.url' <<< "$release")
      filename=''${url##*/}
      replacement_url="https://downloads.claude.ai/releases/darwin/universal/\''${finalAttrs.version}/$filename"
      hash="sha256-$(
        curl --fail --location --silent "$url" \
          | openssl dgst -sha256 -binary \
          | openssl base64
      )"

      sed -i -E \
        -e 's@(version = )"[0-9]+\.[0-9]+\.[0-9]+";@\1"'"$version"'";@' \
        -e 's@(url = )"https://downloads\.claude\.ai/releases/darwin/universal/[^"]+";@\1"'"$replacement_url"'";@' \
        -e 's@(hash = )("sha256-[A-Za-z0-9+/]+="|null);@\1"'"$hash"'";@' \
        ./packages/claude-desktop/package.nix
    '';
  });

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
