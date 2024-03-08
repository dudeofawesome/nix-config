{ pkgs, lib, arch, os, ... }: with lib; {
  imports = [
    ../configurable/headful/gnome.nix
  ];

  environment = {
    systemPackages = with pkgs; [
      _1password-gui
      # sublime4
      sunshine
      vscode
    ]
    ++ (if (arch == "x86_64") then [
      spotify
      cider
    ] else [ ])
    ;
  };
}
