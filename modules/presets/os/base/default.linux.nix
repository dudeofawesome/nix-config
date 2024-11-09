{ machine-class, arch, os, hostname, pkgs, lib, config, ... }: {
  imports = [
    ../../../defaults/boot/systemd-boot.nix
    ../../../defaults/boot/ssh.nix
  ];

  nixpkgs.hostPlatform = lib.mkDefault "${arch}-${os}";

  boot = {
    # Let's live life on the edge
    kernelPackages = pkgs.linuxPackages_latest;

    loader.systemd-boot.enable = lib.mkDefault true;
  };

  environment = {
    systemPackages = with pkgs; [
      cryptsetup
      graphviz
      lshw
      usbutils
    ]
    ++ (if (machine-class == "pc") then [
      zgrviewer
    ] else [ ])
    ;
  };

  services = {
    automatic-timezoned.enable = true;
    avahi.enable = true;
    vscode-server.enable = true;
  };

  console = {
    # TODO: set custom console font
    #   https://github.com/Anomalocaridid/dotfiles/blob/fcd37335d9799a9efd5e0c9aacdd12ab6283a259/modules/theming.nix#L4
    # enable setting TTY keybaord layout
    useXkbConfig = true;
  };

  system = {
    # This option defines the first version of NixOS you have installed on this particular machine,
    # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
    #
    # Most users should NEVER change this value after the initial install, for any reason,
    # even if you've upgraded your system to a new NixOS release.
    #
    # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
    # so changing it will NOT upgrade your system.
    #
    # This value being lower than the current NixOS release does NOT mean your system is
    # out of date, out of support, or vulnerable.
    #
    # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
    # and migrated your data accordingly.
    #
    # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
    stateVersion = lib.mkDefault "23.05"; # Did you read the comment?
  };
}
