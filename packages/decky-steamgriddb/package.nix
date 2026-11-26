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
  # renovate: datasource=custom.decky depName=decky-steamgriddb packageName=SteamGridDB
  version = "1.8.1";

  artifactHash = "e84f5b1f111af8862b06218479491fbf61036e1bfd9f16f93f9901e9b9ebc5e0";

  src = fetchzip {
    url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/${finalAttrs.artifactHash}.zip";
    hash = "sha256-J/2vQhCAeBpWakz3jI3uihkrGNFCozYOLejTP4HVInU=";
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
