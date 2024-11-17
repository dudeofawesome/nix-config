{ pkgs, lib, ... }: {
  imports = [
    ../../../defaults/homebrew.nix
  ];

  environment = {
    # Use a custom configuration.nix location.
    # $ darwin-rebuild switch -I darwin-config=$HOME/.config/nixpkgs/darwin/configuration.nix
    darwinConfig = "$HOME/.config/nixpkgs/darwin/configuration.nix";

    systemPackages = with pkgs; [
      # GNU Utilities
      coreutils-prefixed
      darwin.lsusb
      findutils
      gnused
      gnutar

      gcc
      llvm

      docker
    ];
  };

  system = {
    # This option defines the first version of nix-darwin you have installed on this particular machine,
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
    # For more information, see https://daiderd.com/nix-darwin/manual/index.html#opt-system.stateVersion
    stateVersion = lib.mkDefault 4; # Did you read the comment?
  };
}
