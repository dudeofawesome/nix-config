{
  fetchzip,
  unstableGitUpdater,
  installShellFiles,
  lib,
  stdenv,
  versionCheckHook,
}:

let
  appName = "AeroSpace.app";
  version = "0-unstable-2025-06-30";
  hash = "fa6ef92473b623dbc376b7e0df9fe3a60d2efdc1";
in
stdenv.mkDerivation {
  pname = "aerospace";

  inherit version;

  src = fetchzip {
    url = "https://github.com/acsandmann/aerospace-swipe/archive/${hash}.zip";
    sha256 = "sha256-rF4emnLNVE1fFlxExliN7clSBocBrPwQOwBqRtX9Q4o=";
  };

  nativeBuildInputs = [ installShellFiles ];

  installPhase = ''
    runHook preInstall
    # make install
    mkdir -p $out/Applications
    mv ${appName} $out/Applications
    cp -R bin $out
    mkdir -p $out/share
    runHook postInstall
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = unstableGitUpdater {
    # url = "https://github.com/acsandmann/aerospace-swipe.git";
  };

  meta = {
    license = lib.licenses.mit;
    mainProgram = "aerospace-swipe";
    homepage = "https://github.com/acsandmann/aerospace-swipe";
    description = "enables three finger swiping in aerospace";
    platforms = lib.platforms.darwin;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
