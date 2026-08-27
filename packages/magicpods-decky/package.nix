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
  pname = "magicpods-decky";
  version = "2.0.15";

  artifactHash = "7799922e8ae4d9a119ade0f1fc562448e6c0ba78c1e9023508d97e80c5ebc7ee";

  src = fetchzip {
    url = "https://cdn.tzatzikiweeb.moe/file/steam-deck-homebrew/versions/${finalAttrs.artifactHash}.zip";
    hash = "sha256-bu5TYScPpWo21gy8h6TS0u9/o/k8+hNaH448Ta5WIck=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"

    runHook postInstall
  '';

  passthru.updateScript = lib.getExe (writeShellApplication {
    name = "magicpods-decky-update-script";
    runtimeInputs = [
      cacert
      curl
      gnused
      jq
      nix
    ];
    text = ''
      release_feed="https://plugins.deckbrew.xyz/plugins?query=MagicPods"
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
        ./packages/magicpods-decky/package.nix
    '';
  });

  meta = {
    description = "Decky plugin for monitoring and controlling supported Bluetooth headphones";
    homepage = "https://github.com/steam3d/MagicPodsDecky";
    license = lib.licenses.gpl3Only;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = [ "x86_64-linux" ];
  };
})
