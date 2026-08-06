{ lib, config, ... }: {
  # assertions = [
  #   {
  #     assertion = config.services.tang.ipAddressAllow != [ ];
  #     message = "`services.tang.ipAddressAllow` must be set!";
  #   }
  # ];

  config = {
    services.tang = {
      enable = true;
      # ipAddressAllow = [ "10.0.0.0/24" ];
    };

    # TODO: assign ports based on interface
    networking.firewall.allowedTCPPorts = lib.pipe config.services.tang.listenStream [
      (map (
        stream:
        if (lib.isInt stream) then
          stream
        else if true then
          lib.pipe stream [
            (builtins.split "\:(\d+$)")
            (split: builtins.elemAt split 0)
          ]
        else
          abort "Unsupported tang listenStream: ${stream}"
      ))

      (map lib.toInt)
    ];
  };
}
