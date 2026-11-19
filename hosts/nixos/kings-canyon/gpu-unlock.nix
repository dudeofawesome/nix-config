{
  config,
  pkgs,
  ...
}:
let
  version = "2.0.0";
  nvidiaVersion = "610.43.03";
  src = pkgs.fetchFromGitHub {
    owner = "Zagitta";
    repo = "gpu-unlock";
    # Boot-level code, so update it by hand rather than through Renovate.
    rev = "7eb51bccae0a0b7e599e084d971170e9a1e82d0c";
    hash = "sha256-1KD/J1S1uyI5GGoTwQ1cU/sXeEKlG54exSvi6U+j73M=";
  };

  # Only used to extract firmware; independent of the driver the host runs.
  nvidiaSource = pkgs.fetchurl {
    url = "https://download.nvidia.com/XFree86/NVIDIA-kernel-module-source/NVIDIA-kernel-module-source-${nvidiaVersion}.tar.xz";
    hash = "sha256-fhGJI8eiPtw2EU1jJzpG4+BOmvmGlaQiA+esLf6fwdw=";
  };
  nvidiaInstaller = pkgs.fetchurl {
    url = "https://download.nvidia.com/XFree86/Linux-x86_64/${nvidiaVersion}/NVIDIA-Linux-x86_64-${nvidiaVersion}-no-compat32.run";
    hash = "sha256-4IRFHbcwpt8p09dPZVdJxNI248lF99lLUgXoQxj+L5A=";
  };

  firmware = pkgs.stdenvNoCC.mkDerivation {
    pname = "gpu-unlock-firmware";
    inherit version src;

    nativeBuildInputs = with pkgs; [
      python3
      zstd
    ];

    buildPhase = ''
      runHook preBuild
      mkdir inputs
      ln -s ${nvidiaSource} inputs/${nvidiaSource.name}
      ln -s ${nvidiaInstaller} inputs/${nvidiaInstaller.name}
      make firmware INPUTS="$PWD/inputs" ASSETS="$PWD/assets"
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      make install-firmware \
        ASSETS="$PWD/assets" \
        DESTDIR="$out" \
        FWDIR=/lib/firmware/gpu-unlock/${nvidiaVersion} \
        LICENSEDIR=/share/licenses
      runHook postInstall
    '';
  };

  kernelPackages = config.boot.kernelPackages;
  inherit (kernelPackages) kernel;

  module = kernel.stdenv.mkDerivation {
    pname = "gpu-unlock";
    version = "${version}-${kernel.version}";
    inherit src;

    sourceRoot = "${src.name}/kernel/gpu_unlock";
    nativeBuildInputs = kernel.moduleBuildDependencies;
    hardeningDisable = [ "pic" ];

    makeFlags = kernelPackages.kernelModuleMakeFlags ++ [
      "-C"
      "${kernel.dev}/lib/modules/${kernel.modDirVersion}/build"
      "M=$(NIX_BUILD_TOP)/$(sourceRoot)"
    ];
    buildFlags = [ "modules" ];
    installFlags = [ "INSTALL_MOD_PATH=$(out)" ];
    installTargets = [ "modules_install" ];
  };
in
{
  # Run the tensor cores at full rate on FP16/BF16/TF32 with FP32 accumulation.
  boot = {
    extraModulePackages = [ module ];
    # Must load from the initrd: the unlock is refused once nvidia binds a card,
    # and the systemd-modules-load in the real root ignores a softdep on nvidia.
    initrd.kernelModules = [ "gpu_unlock" ];
    # List new cards here as they are installed; unlisted cards stay stock.
    kernelParams = [ "gpu_unlock.targets=0000:81:00.0,0000:82:00.0,0000:c2:00.0" ];
  };

  # The initrd copies in the firmware that the module declares.
  hardware.firmware = [ firmware ];
}
