{ lib, pkgs, ... }: {
  programs.ssh.settings =
    let
      hostUnreachable = (host: ''host ${host} !exec "ping -c1 -q -t1 '%h' 2> /dev/null"'');
    in
    {
      "*".User = "dudeofawesome";

      "unifi".User = "root";
      "unifi-remote" = {
        header = "Match ${hostUnreachable "unifi"}";
        HostName = "red.orleans.io";
      };

      "badlands" = {
        User = "lorleans";
        HostName = "10.0.1.87";
      };

      "olympus" = {
        ProxyCommand = ''
          ${wake} 'olympus' 'c8:7f:54:6a:3f:56' 'c8:7f:54:6a:45:b7'
        '';
      };

      "home.powell.place".User = "louis";

      "home.saldivar.io" = {
        User = "edgar";
        Port = 69;
      };
      "terracompute" = {
        HostName = "192.168.4.225";
        User = "vast";
      };
      "terracompute-remote" = {
        header = "Match ${hostUnreachable "192.168.4.225"}";
        ProxyJump = "home.saldivar.io";
      };
    };
}
