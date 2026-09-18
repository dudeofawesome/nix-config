{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bosl";
  version = "1.0.3";

  src = fetchFromGitHub {
    owner = "revarbat";
    repo = "BOSL";
    tag = "v${finalAttrs.version}";
    hash = "sha256-FHHZ5MnOWbWnLIL2+d5VJoYAto4/GshK8S0DU3Bx7O8=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 *.scad LICENSE -t "$out/share/openscad/libraries/BOSL"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Belfry OpenSCAD library of shapes, masks, and manipulators";
    homepage = "https://github.com/revarbat/BOSL";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.all;
  };
})
