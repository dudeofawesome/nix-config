{ ... }:
{
  homebrew = {
    # Declare Homebrew using Nix-Darwin
    enable = true;
    # caskArgs.no_quarantine = true;
    onActivation = {
      autoUpdate = false; # Auto update packages
      upgrade = false;
      cleanup = "zap"; # Uninstall not listed packages and casks
    };
  };
}
