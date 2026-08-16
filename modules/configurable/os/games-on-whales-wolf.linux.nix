{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.services.games-on-whales.wolf;

  wolfUdevRulesSource = pkgs.fetchurl {
    url = "https://raw.githubusercontent.com/games-on-whales/wolf/stable/85-wolf.rules";
    hash = "sha256-KpLtA8SIHpEestXAWZya5SaWSksXSJbc+fv38wUay8I=";
  };

  wolfUdevRules = pkgs.runCommand "wolf-udev-rules" { } ''
    install -Dm644 ${wolfUdevRulesSource} \
      $out/lib/udev/rules.d/85-wolf.rules
  '';

  wolfNvidiaVolume = inputs.wolf-nvidia-vol.lib.mkWolfNvidiaVol {
    inherit pkgs;
    nvidiaPackage = config.hardware.nvidia.package;
    extraLibs = [ pkgs.cudaPackages.cuda_nvrtc.lib ];
  };
in
{
  options.services.games-on-whales.wolf = {
    enable = lib.mkEnableOption "Wolf game streaming server";

    image = lib.mkOption {
      type = lib.types.str;
      default = "ghcr.io/games-on-whales/wolf:stable";
      description = "OCI image used to run Wolf.";
    };

    stateDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/wolf";
      description = "Host directory containing Wolf's mutable configuration and state.";
    };

    nvidia.enable = lib.mkOption {
      type = lib.types.bool;
      default = config.hardware.nvidia.enabled;
      defaultText = lib.literalExpression "config.hardware.nvidia.enabled";
      description = "Provide NVIDIA drivers to Wolf through an immutable Nix store volume.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Open the default Moonlight streaming ports in the firewall.";
    };

    environment = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = { };
      example = {
        WOLF_RENDER_NODE = "/dev/dri/renderD129";
      };
      description = "Additional environment variables passed to Wolf.";
    };

    extraOptions = lib.mkOption {
      type = with lib.types; listOf str;
      default = [ ];
      description = "Additional options passed to the Podman run command.";
    };
  };

  config = lib.mkIf cfg.enable {
    boot.kernelModules = [
      "uhid"
      "uinput"
    ]
    ++ lib.optional cfg.nvidia.enable "nvidia_uvm";

    services.udev.packages = [ wolfUdevRules ];

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [
        47984
        47989
        48010
      ];
      allowedUDPPorts = [
        47999
        48100
        48200
      ];
    };

    systemd.tmpfiles.settings."10-games-on-whales-wolf".${cfg.stateDirectory}.d = {
      mode = "0750";
      user = "root";
      group = "root";
    };

    systemd.services.podman-wolf = {
      after = [ "podman.socket" ];
      requires = [ "podman.socket" ];
    };

    virtualisation.oci-containers = {
      backend = "podman";
      containers.wolf = {
        inherit (cfg) image;
        environment =
          lib.optionalAttrs cfg.nvidia.enable {
            NVIDIA_DRIVER_VOLUME_NAME = toString wolfNvidiaVolume;
            WOLF_STOP_CONTAINER_ON_EXIT = "TRUE";
          }
          // cfg.environment;
        volumes = [
          "${cfg.stateDirectory}:/etc/wolf:rw"
          "/run/podman/podman.sock:/var/run/docker.sock:rw"
          "/dev:/dev:rw"
          "/run/udev:/run/udev:rw"
        ]
        ++ lib.optional cfg.nvidia.enable "${wolfNvidiaVolume}:/usr/nvidia:ro";
        devices = [
          "/dev/dri:/dev/dri"
          "/dev/uhid:/dev/uhid"
          "/dev/uinput:/dev/uinput"
        ]
        ++ lib.optionals cfg.nvidia.enable [
          "/dev/nvidia-caps/nvidia-cap1:/dev/nvidia-caps/nvidia-cap1"
          "/dev/nvidia-caps/nvidia-cap2:/dev/nvidia-caps/nvidia-cap2"
          "/dev/nvidia-modeset:/dev/nvidia-modeset"
          "/dev/nvidia-uvm-tools:/dev/nvidia-uvm-tools"
          "/dev/nvidia-uvm:/dev/nvidia-uvm"
          "/dev/nvidia0:/dev/nvidia0"
          "/dev/nvidiactl:/dev/nvidiactl"
        ];
        networks = [ "host" ];
        extraOptions = [
          "--device-cgroup-rule=c 13:* rmw"
          "--ipc=host"
          "--security-opt=label=disable"
        ]
        ++ cfg.extraOptions;
      };
    };
  };
}
