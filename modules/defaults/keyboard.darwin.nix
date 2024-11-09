{ ... }:
{
  config = {
    homebrew.casks = [ "workman" ];

    system.keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
  };
}
