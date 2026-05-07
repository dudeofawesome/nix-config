{
  lib,
  stdenv,
  cacert,
  curl,
  fetchurl,
  gnused,
  libxml2,
  openssl,
  undmg,
  writeShellApplication,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "postico";
  version = "2.3.3";
  build = "9804";

  src = fetchurl {
    url = "https://downloads.eggerapps.at/postico/postico-${finalAttrs.build}.dmg";
    hash = "sha256-NH/gbP8b4dypMPNLWxMkK0VfjiK8hc+m80+Jrkg98R4=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Applications"
    mv "Postico 2.app" "$out/Applications/"

    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "postico-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      libxml2
      openssl
    ];
    text = ''
      appcast="https://releases.eggerapps.at/postico2/appcast.xml"
      feed=$(curl --fail --location --silent "$appcast")

      version="$(
        printf '%s' "$feed" \
          | xmllint --xpath 'string((//*[local-name()="enclosure"])[last()]/@*[local-name()="shortVersionString"])' - \
          | sed -E 's/[[:space:]]+/-/g'
      )"

      url="$(
        printf '%s' "$feed" \
          | xmllint --xpath 'string((//*[local-name()="enclosure"])[last()]/@url)' -
      )"

      build=''${url##*/postico-}
      build=''${build%.dmg}

      hash="sha256-$(
        curl --fail --location --silent "$url" \
          | openssl dgst -sha256 -binary \
          | openssl base64
      )"

      sed -i -E \
        -e 's@(version = )"[^"]+";@\1"'"$version"'";@' \
        -e 's@(build = )"[0-9]+";@\1"'"$build"'";@' \
        -e 's@(hash = )("sha256-[A-Za-z0-9+/]+="|lib\.fakeHash);@\1"'"$hash"'";@' \
        ./packages/postico/package.nix
    '';
  });

  meta = {
    description = "PostgreSQL client for macOS";
    homepage = "https://eggerapps.at/postico2/";
    changelog = "https://releases.eggerapps.at/postico2/changelog";
    license = lib.licenses.unfree;
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
})
