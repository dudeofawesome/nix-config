{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

buildGoModule rec {
  pname = "podman-mac-helper";
  version = "5.4.1";

  src = fetchFromGitHub {
    owner = "containers";
    repo = "podman";
    rev = "v${version}";
    sha256 = "sha256-RirMBb45KeBLdBJrRa86WxI4FiXdBar+RnVQ2ezEEYc=";
  };

  subPackages = [ "cmd/podman-mac-helper" ];

  # VENDOR HASH PLACEHOLDER: You must calculate this hash for Go modules.
  # See instructions below.
  vendorHash = null;

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Helper binary for running Podman on macOS";
    homepage = "https://github.com/containers/podman";
    license = licenses.asl20;
    platforms = platforms.darwin;
  };
}
