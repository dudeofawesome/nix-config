{ ... }:
{
  imports = [
    ./workman-keyboard-layout.darwin.nix
  ];

  config = {
    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
