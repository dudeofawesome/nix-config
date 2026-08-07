{
  lib,
  stdenv,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "asimov";
  version = "0.12.0";

  src = fetchFromGitHub {
    owner = "stevegrunwell";
    repo = "asimov";
    rev = "v${finalAttrs.version}";
    hash = "sha256-w3mmSu56vtiqoet6P2OFWcUVCdME2ckMTj3k7PRzw8I=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 asimov "$out/bin/asimov"
    # install -Dm644 com.stevegrunwell.asimov.plist \
    #   "$out/Library/LaunchAgents/com.stevegrunwell.asimov.plist"

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "Automatically exclude development dependencies from Time Machine backups";
    homepage = "https://github.com/stevegrunwell/asimov";
    license = lib.licenses.mit;
    platforms = lib.platforms.darwin;
    mainProgram = "asimov";
  };
})
