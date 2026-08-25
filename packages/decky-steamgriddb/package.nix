{
  lib,
  stdenvNoCC,
  cacert,
  curl,
  fetchzip,
  gnused,
  jq,
  nix,
  writeShellApplication,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "decky-steamgriddb";
  version = "1.7.1";

  artifactHash = "6d6eca184677dc9ff7736439ee7a575ca8ab386c5ffb1627d446bc43dbd1ecf3";

  src = fetchzip {
    url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/${finalAttrs.artifactHash}.zip";
    hash = "sha256-hYPsrC5QA0eX/fYkEnzIDB0p77Feo4IkKrJ6IKfjtFw=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"

    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "decky-steamgriddb-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      jq
      nix
    ];
    text = ''
      release_feed="https://plugins.deckbrew.xyz/plugins?query=SteamGridDB"
      release=$(curl --fail --location --silent "$release_feed" | jq '.[0].versions[0]')

      version=$(jq --raw-output '.name' <<< "$release")
      artifact_hash=$(jq --raw-output '.hash' <<< "$release")
      url="https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/$artifact_hash.zip"
      prefetch_hash=$(nix-prefetch-url --unpack "$url")
      hash=$(nix hash convert --hash-algo sha256 --to sri "$prefetch_hash")

      sed -i -E \
        -e 's@(version = )"[^"]+";@\1"'"$version"'";@' \
        -e 's@(artifactHash = )"[a-f0-9]+";@\1"'"$artifact_hash"'";@' \
        -e 's@(hash = )("sha256-[A-Za-z0-9+/]+="|lib\.fakeHash);@\1"'"$hash"'";@' \
        ./packages/decky-steamgriddb/package.nix
    '';
  });

  meta = {
    description = "Decky plugin for applying and managing custom Steam artwork";
    homepage = "https://github.com/SteamGridDB/decky-steamgriddb";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
