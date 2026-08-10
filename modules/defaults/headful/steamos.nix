{
  owner,
  pkgs,
  ...
}:
{
  imports = [
    ./gnome.nix
    ../jovian.nix
    ../plymouth.nix
  ];

  # Jovian's Game Mode starts Steam Big Picture in Gamescope directly at boot.
  jovian = {
    steam = {
      enable = true;
      autoStart = true;
      user = owner;
    };
    decky-loader = {
      enable = true;
      extraPackages = with pkgs; [
        procps
        systemd
      ];
      user = owner;

      plugins = [
        pkgs.decky-launch-options
      ];
    };
  };
}
