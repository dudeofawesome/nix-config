{ pkgs, ... }:
{
  imports = [
  ];

  environment = {
    systemPackages = with pkgs; [
      k6
    ];
  };

  homebrew = {
    casks = [
      "zoom"
    ];
  };
}
