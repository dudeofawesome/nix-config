{
  lib,
  podman,
  symlinkJoin,
  makeWrapper,
  stdenv,
  podman-mac-helper,
  krunkit ? null,
  ...
}:
let
  runtimeDeps =
    let
      inherit (stdenv.targetPlatform) isDarwin isAarch64;
    in
    lib.flatten [
      (lib.optional isDarwin podman-mac-helper)
      (lib.optional (isDarwin && isAarch64) krunkit)
    ];
in
if !stdenv.targetPlatform.isDarwin then
  podman
else
  symlinkJoin {
    inherit (podman)
      pname
      version
      passthru
      ;
    name = "${podman.pname or "podman"}-${podman.version}";
    meta = podman.meta // {
      outputsToInstall = [ "out" ];
    };

    paths = [ podman ];
    nativeBuildInputs = [ makeWrapper ];

    postBuild = ''
      rm "$out/bin/podman"
      makeWrapper ${lib.getExe podman} "$out/bin/podman" \
        --prefix PATH : ${lib.makeBinPath runtimeDeps}
    '';
  }
