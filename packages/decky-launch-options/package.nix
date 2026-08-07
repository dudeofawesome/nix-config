{
  lib,
  stdenvNoCC,
  fetchzip,
  nix-update-script,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "decky-launch-options";
  version = "1.14.0";

  src = fetchzip {
    url = "https://github.com/Wurielle/decky-launch-options/releases/download/v${finalAttrs.version}/decky-launch-options.zip";
    hash = "sha256-ZZRrF/EdAv8tpuQWorZQ8r6OOzE5JKXI2JXEpL74ASE=";
  };

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    cp -R . "$out"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Manage launch options for games with Decky Loader";
    homepage = "https://github.com/Wurielle/decky-launch-options";
    changelog = "https://github.com/Wurielle/decky-launch-options/releases/tag/v${finalAttrs.version}";
    license = with lib.licenses; [
      bsd3
      mit
    ];
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.linux;
  };
})
