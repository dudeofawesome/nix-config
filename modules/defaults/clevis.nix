{
  pkgs,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    clevis
  ];

  boot = {
    initrd = {
      clevis = {
        enable = true;
      };
    };
  };
}
