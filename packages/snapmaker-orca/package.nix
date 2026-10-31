{
  lib,
  stdenv,
  appimageTools,
  cacert,
  curl,
  fetchurl,
  gnused,
  jq,
  makeWrapper,
  openssl,
  writeShellApplication,
  _7zz,
  ...
}:

let
  pname = "snapmaker-orca";
  # renovate: datasource=github-releases depName=snapmaker-orca packageName=Snapmaker/OrcaSlicer
  version = "2.4.1";
  darwinHash = "sha256-elkIMKOYNdEDzQDwb1WOsDMvtP7adh6Tl3JMVUcggV8=";
  linuxHash = "sha256-K1EX4i0Eo6J7zfxahzxV0o/zt86XIZRt4fE0+pfSzAY=";

  src = fetchurl {
    url =
      "https://github.com/Snapmaker/OrcaSlicer/releases/download/v${version}/"
      + (
        if stdenv.hostPlatform.isDarwin then
          "Snapmaker_Orca_Mac_universal_V${version}.dmg"
        else
          "Snapmaker_Orca_Linux_AppImage_Ubuntu2404_V${version}.AppImage"
      );
    hash = if stdenv.hostPlatform.isDarwin then darwinHash else linuxHash;
  };

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "snapmaker-orca-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      jq
      openssl
    ];
    text = ''
      version=$(
        curl --fail --location --silent \
          https://api.github.com/repos/Snapmaker/OrcaSlicer/releases/latest \
          | jq --exit-status --raw-output '.tag_name | ltrimstr("v")'
      )
      base_url="https://github.com/Snapmaker/OrcaSlicer/releases/download/v$version"

      get_hash() {
        curl --fail --location --silent "$1" \
          | openssl dgst -sha256 -binary \
          | openssl base64 -A
      }

      darwin_hash="sha256-$(get_hash "$base_url/Snapmaker_Orca_Mac_universal_V$version.dmg")"
      linux_hash="sha256-$(get_hash "$base_url/Snapmaker_Orca_Linux_AppImage_Ubuntu2404_V$version.AppImage")"

      sed -i -E \
        -e 's@(version = )"[^"]+";@\1"'"$version"'";@' \
        -e 's@(darwinHash = )"[^"]+";@\1"'"$darwin_hash"'";@' \
        -e 's@(linuxHash = )"[^"]+";@\1"'"$linux_hash"'";@' \
        ./packages/snapmaker-orca/package.nix
    '';
  });

  meta = {
    description = "OrcaSlicer-based 3D printing slicer optimized for Snapmaker printers";
    homepage = "https://github.com/Snapmaker/OrcaSlicer";
    changelog = "https://github.com/Snapmaker/OrcaSlicer/releases/tag/v${version}";
    license = lib.licenses.agpl3Only;
    platforms = [
      "aarch64-darwin"
      "x86_64-darwin"
      "x86_64-linux"
    ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = pname;
  };
in
if stdenv.hostPlatform.isDarwin then
  stdenv.mkDerivation {
    inherit
      pname
      version
      src
      passthru
      meta
      ;

    sourceRoot = ".";
    # The release DMG uses APFS, which undmg does not support.
    nativeBuildInputs = [
      _7zz
      makeWrapper
    ];

    # Preserve the signatures on the upstream app bundle.
    dontFixup = true;

    installPhase = ''
      runHook preInstall

      mkdir -p "$out/Applications" "$out/bin"
      mv "Snapmaker Orca.app" "$out/Applications/"
      # Launch from inside the bundle so macOS resolves its metadata and Dock icon.
      makeWrapper "$out/Applications/Snapmaker Orca.app/Contents/MacOS/Snapmaker_Orca" \
        "$out/bin/${pname}"

      runHook postInstall
    '';
  }
else
  appimageTools.wrapType2 {
    inherit
      pname
      version
      src
      passthru
      meta
      ;

    # Upstream expects the WebKitGTK stack to be provided by the host.
    extraPkgs = pkgs: [
      pkgs.webkitgtk_4_1
      pkgs.glib-networking
    ];

    extraInstallCommands =
      let
        appimageContents = appimageTools.extractType2 {
          inherit pname version src;
        };
      in
      ''
        install -Dm444 \
          ${appimageContents}/io.github.Snapmaker.Snapmaker_Orca.desktop \
          "$out/share/applications/io.github.Snapmaker.Snapmaker_Orca.desktop"
        substituteInPlace "$out/share/applications/io.github.Snapmaker.Snapmaker_Orca.desktop" \
          --replace-fail 'Exec=AppRun' 'Exec=${pname}'
        install -Dm444 \
          ${appimageContents}/Snapmaker_Orca.png \
          "$out/share/icons/hicolor/192x192/apps/Snapmaker_Orca.png"
      '';
  }
