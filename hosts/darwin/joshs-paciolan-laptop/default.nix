{
  pkgs,
  pkgs-unstable,
  lib,
  machine-class,
  ...
}:
{
  # Temporary - this is broken for me, but I don't need to use it
  nix.linux-builder.enable = false;

  imports = lib.flatten [
    (lib.optional (machine-class == "pc") ../../../modules/presets/os/paciolan.nix)
  ];

  environment = {
    systemPackages = with pkgs; [
      # Utilities
      arduino-cli
      ffmpeg
      gitlab-runner
      imagemagick
      k6
      lynx
      nmap
      pkgs-unstable.claude-code

      # Languages
      go
      go-outline
      gopls
    ];
  };

  homebrew = {
    casks = [
      "zoom"
    ];
  };

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
  system.stateVersion = 6; # Did you read the comment?
}
