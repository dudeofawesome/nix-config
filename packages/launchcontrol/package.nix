{
  lib,
  stdenv,
  cacert,
  curl,
  fetchurl,
  gnused,
  libxml2,
  openssl,
  writeShellApplication,
  xz,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "launchcontrol";
  version = "2.10.3";

  src = fetchurl {
    url = "https://www.soma-zone.com/download/files/LaunchControl-${finalAttrs.version}_update.tar.xz";
    hash = "sha256-Qz9T+f2dAGSW48un4/jpvaPP+LzQBCGYmwFJ2yODj8s=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ xz ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv LaunchControl.app "$out/Applications/"

    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "launchcontrol-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      libxml2
      openssl
    ];
    text = ''
      release_feed="https://www.soma-zone.com/LaunchControl/a/appcast-update-2.xml"

      url="$(
        curl --fail --location --silent "$release_feed" \
          | xmllint --xpath 'string((//*[local-name()="item"][1]/*[local-name()="enclosure"]/@url)[1])' -
      )"

      version=''${url##*/LaunchControl-}
      version=''${version%_update.tar.xz}
      replacement_url="https://www.soma-zone.com/download/files/LaunchControl-\''${finalAttrs.version}_update.tar.xz"

      hash="sha256-$(
        curl --fail --location --silent "$url" \
          | openssl dgst -sha256 -binary \
          | openssl base64
      )"

      sed -i -E \
        -e 's@(version = )"[0-9]+\.[0-9]+(\.[0-9]+)?";@\1"'"$version"'";@' \
        -e 's@(url = )"https://www\.soma-zone\.com/download/files/LaunchControl-[^"]+\.tar\.xz";@\1"'"$replacement_url"'";@' \
        -e 's@(hash = )("sha256-[A-Za-z0-9+/]+="|lib\.fakeHash|null);@\1"'"$hash"'";@' \
        ./packages/launchcontrol/package.nix
    '';
  });

  meta = {
    description = "Graphical launchd service manager for macOS";
    homepage = "https://www.soma-zone.com/LaunchControl/";
    changelog = "https://www.soma-zone.com/LaunchControl/ReleaseNotes.html";
    downloadPage = "https://www.soma-zone.com/download/";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
