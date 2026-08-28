{
  lib,
  stdenvNoCC,
  cacert,
  curl,
  fetchzip,
  gnused,
  jq,
  ludusavi,
  nix,
  writeShellApplication,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "decky-ludusavi";
  version = "1.2.2";

  artifactHash = "8a69f45aadce763406b5c27bfef194761006d5e01c5e8841badeb13a27dd0d88";

  src = fetchzip {
    url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/${finalAttrs.artifactHash}.zip";
    hash = "sha256-Q8fCylHrdyJDIva+g05ZILM3wg79q4E8WlwCmF+zEiM=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"

    runHook postInstall
  '';

  passthru = {
    runtimeDependencies = [ ludusavi ];

    updateScript = lib.getExe (writeShellApplication {
      name = "decky-ludusavi-update-script";
      runtimeInputs = [
        cacert
        curl
        gnused
        jq
        nix
      ];
      text = ''
        release_feed="https://plugins.deckbrew.xyz/plugins?query=Ludusavi"
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
          ./packages/decky-ludusavi/package.nix
      '';
    });
  };

  meta = {
    description = "Decky plugin for backing up, restoring, and syncing game saves with Ludusavi";
    homepage = "https://github.com/GedasFX/decky-ludusavi";
    license = lib.licenses.bsd3;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
