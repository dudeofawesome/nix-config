{
  cask-installed = import ./cask-installed.nix;
  mkWirelessProfile = import ./mkWirelessProfile.nix;
  normalize = import ./normalize.nix;
  pkg-installed = import ./pkg-installed.nix;
  try-import = import ./try-import.nix;
}
