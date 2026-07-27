{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asimov";
  version = "0.10.0";

  src = fetchFromGitHub {
    owner = "stevegrunwell";
    repo = "asimov";
    rev = "v${finalAttrs.version}";
    hash = "sha256-+HlOEmuom5Wdfq+725bSDromkYUJuwoAVzQif8Ptc24=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 asimov "$out/bin/asimov"
    # install -Dm644 com.stevegrunwell.asimov.plist \
    #   "$out/Library/LaunchAgents/com.stevegrunwell.asimov.plist"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Automatically exclude development dependencies from Time Machine backups";
    homepage = "https://github.com/stevegrunwell/asimov";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "asimov";
  };
})
