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
  version = "1.24012.1";

  src = fetchurl {
    url = "https://downloads.claude.ai/releases/darwin/universal/${finalAttrs.version}/Claude-0adcaed55041a881be363f2c4a4729f67a8b27d7.zip";
    hash = "sha256-3igztg2qvb8OkjfZ+PO4EC7xlBjjVBF7GbMh0KOhLm8=";
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
