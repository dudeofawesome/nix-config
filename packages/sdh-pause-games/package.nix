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
  pname = "sdh-pause-games";
  version = "1.0.2";

  releaseTag = "20260723060434";

  src = fetchzip {
    url = "https://github.com/wynn1212/SDH-PauseGames/releases/download/${finalAttrs.releaseTag}/SDH-PauseGames.zip";
    hash = "sha256-efa0kKvyUZ9+ZYQPUMlSIo6IqNBnsDU1gmkWa5eAwUk=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"

    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "sdh-pause-games-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      jq
      nix
    ];
    text = ''
      release_feed="https://api.github.com/repos/wynn1212/SDH-PauseGames/releases/latest"
      release=$(curl --fail --location --silent "$release_feed")

      release_tag=$(jq --raw-output '.tag_name' <<< "$release")
      url=$(jq --raw-output '.assets[] | select(.name == "SDH-PauseGames.zip") | .browser_download_url' <<< "$release")
      version=$(
        curl --fail --location --silent \
          "https://raw.githubusercontent.com/wynn1212/SDH-PauseGames/$release_tag/package.json" \
          | jq --raw-output '.version'
      )
      prefetch_hash=$(nix-prefetch-url --unpack "$url")
      hash=$(nix hash convert --hash-algo sha256 --to sri "$prefetch_hash")

      sed -i -E \
        -e 's@(version = )"[^"]+";@\1"'"$version"'";@' \
        -e 's@(releaseTag = )"[^"]+";@\1"'"$release_tag"'";@' \
        -e 's@(hash = )("sha256-[A-Za-z0-9+/]+="|lib\.fakeHash);@\1"'"$hash"'";@' \
        ./packages/sdh-pause-games/package.nix
    '';
  });

  meta = {
    description = "Decky plugin for pausing and resuming games and applications";
    homepage = "https://github.com/wynn1212/SDH-PauseGames";
    changelog = "https://github.com/wynn1212/SDH-PauseGames/releases/tag/${finalAttrs.releaseTag}";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
