let
  builder = {
    hostName = "kings-canyon";
    protocol = "ssh-ng";
    sshUser = "nix-ssh";
    sshKey = "/etc/ssh/ssh_host_ed25519_key";
    maxJobs = 6;
    # Pin the builder's key for unattended daemon connections.
    publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSUFHby9SNzI1akdVeGVPdVR5M1BvVkZjSUEzYmk1ZWRSbHpjRTZoQWFNOGs=";
    supportedFeatures = [
      "nixos-test"
      "benchmark"
      "kvm"
      "big-parallel"
    ];
  };
in
[
  (
    builder
    // {
      systems = [ "x86_64-linux" ];
    }
  )
  (
    builder
    // {
      systems = [ "aarch64-linux" ];
      # User-mode emulation cannot provide ARM64 KVM virtualization.
      supportedFeatures = builtins.filter (feat: feat != "kvm") builder.supportedFeatures;
      speedFactor = 1;
    }
  )
]
