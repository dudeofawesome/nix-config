{ lib, pkgs, ... }: {
  programs.ssh.settings =
    let
      hostUnreachable = (host: ''host ${host} !exec "ping -c1 -q -t1 '%h' 2> /dev/null"'');

      wake = pkgs.writeShellScript "ssh-wake-on-lan.sh" ''
        # @param host[:port]
        # @param MAC address[es]

        set -u

        host_and_port="$1"
        shift

        if [[ "$host_and_port" == *:* ]]; then
          host="''${host_and_port%:*}"
          port="''${host_and_port##*:}"
        else
          host="$host_and_port"
          port=22
        fi

        function is_reachable() {
          ${lib.getExe pkgs.netcat} -z -w 1 "$host" "$port" \
            > /dev/null 2>&1
        }

        if ! is_reachable; then
          ${lib.getExe pkgs.wakeonlan} "$@"

          attempts=0
          until is_reachable || [[ "$attempts" -ge 60 ]]; do
            sleep 1
            attempts=$((attempts + 1))
          done
        fi

        exec ${lib.getExe pkgs.netcat} "$host" "$port"
      '';
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

      "olympus".ProxyCommand = "${wake} 'olympus' 'c8:7f:54:6a:3f:56' 'c8:7f:54:6a:45:b7'";

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
