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
  pname = "git-fork";
  version = "2.57.1";
  src = fetchurl {
    url = "https://cdn.fork.dev/mac/Fork-${finalAttrs.version}.dmg";
    hash = "sha256-hIrR655lCKBDkZS6cF7BD+WMvX13T9180rpAfUYc8YA=";
  };

  sourceRoot = ".";

  nativeBuildInputs = [ undmg ];

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/"{bin,Applications}
    mv Fork.app "$out/Applications/"
    ln -s "$out/Applications/Fork.app/Contents/Resources/fork_cli" "$out/bin/fork"

    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "git-fork-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      libxml2
      openssl
    ];
    text = ''
      release_feed="https://fork.dev/update/feed.xml"

      url="$(
        curl --fail --location --silent "$release_feed" \
          | xmllint --xpath 'string((//*[local-name()="item"][1]/*[local-name()="enclosure"]/@url)[1])' -
      )"

      version=''${url##*/Fork-}
      version=''${version%.dmg}

      hash="sha256-$(
        curl --fail --location --silent "$url" \
          | openssl dgst -sha256 -binary \
          | openssl base64
      )"

      sed -i -E \
        -e 's@(version = )"[0-9]+\.[0-9]+(\.[0-9]+)?";@\1"'"$version"'";@' \
        -e 's@(hash = )("sha256-[A-Za-z0-9+/]+="|null);@\1"'"$hash"'";@' \
        ./packages/git-fork/package.nix
    '';
  });

  meta = {
    description = "Git client";
    homepage = "https://git-fork.com";
    license = lib.licenses.unfree;
    # maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.darwin;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    mainProgram = "fork";
  };
})
