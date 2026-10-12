{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "bosl2";
  # renovate: datasource=github-releases depName=bosl2 packageName=BelfrySCAD/BOSL2
  version = "2.0.770";

  src = fetchFromGitHub {
    owner = "BelfrySCAD";
    repo = "BOSL2";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Eqi3W1iA68RSx7tI0beBwecOfOZa5BMDAMv/Sgsz5P0=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 *.scad LICENSE -t "$out/share/openscad/libraries/BOSL2"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Belfry OpenSCAD library, version 2, of shapes, masks, and manipulators";
    homepage = "https://github.com/BelfrySCAD/BOSL2";
    license = lib.licenses.bsd2;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    platforms = lib.platforms.all;
  };
})
