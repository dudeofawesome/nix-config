{
  lib,
  stdenv,
  fetchFromGitHub,
  ...
}:

stdenv.mkDerivation {
  pname = "workman";
  version = "1.0";

  src = fetchFromGitHub {
    owner = "workman-layout";
    repo = "Workman";
    rev = "ec91fc378978d7322db5c3910d51ef079cd72e69";
    hash = "sha256-0SzjXqbJjJO5/F2nURTgj4MreTubkqQgIrQJPSAQvxc=";
  };

  installPhase = ''
    runHook preInstall

    mkdir -p "$out/Library/Keyboard Layouts"
    cp -R mac/Workman.bundle "$out/Library/Keyboard Layouts/"

    runHook postInstall
  '';

  meta = {
    description = "Alternative English keyboard layout";
    homepage = "https://workmanlayout.org/";
    license = lib.licenses.publicDomain;
    platforms = lib.platforms.darwin;
  };
}
