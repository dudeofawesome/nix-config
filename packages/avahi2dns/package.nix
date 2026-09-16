{
  lib,
  buildGoModule,
  fetchFromGitHub,
  nix-update-script,
  ...
}:

buildGoModule (finalAttrs: {
  pname = "avahi2dns";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "LouisBrunner";
    repo = "avahi2dns";
    tag = finalAttrs.version;
    hash = "sha256-/FtgkDi7GRTQPBvtfT1CbTdrJ+VU2SRZbUILs/M5Dcw=";
  };

  # Generated mocks import packages that go mod vendor cannot discover yet.
  proxyVendor = true;
  vendorHash = "sha256-Sx+25D7DuAZQaC88mt8iC5jGlelHqVdon9YVNUnMQjo=";

  subPackages = [ "." ];
  env.CGO_ENABLED = 0;
  ldflags = [
    "-s"
    "-w"
  ];

  # Upstream's test mocks are generated rather than checked into the source.
  preCheck = ''
    go generate ./...
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [ "--flake" ];
  };

  meta = {
    description = "DNS server forwarding queries to Avahi over D-Bus";
    homepage = "https://github.com/LouisBrunner/avahi2dns";
    changelog = "https://github.com/LouisBrunner/avahi2dns/releases/tag/${finalAttrs.version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ dudeofawesome ];
    mainProgram = "avahi2dns";
    platforms = lib.platforms.unix;
  };
})
