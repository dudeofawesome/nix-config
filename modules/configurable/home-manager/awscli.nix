{ lib, pkgs, config, ... }: with lib; let
  cfg = config.programs.awscli;
in
{
  options = { };

  config = mkIf (cfg.enable) {
    # An awscli2 [credential_process](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-sourcing-external.html)
    home.file._1password-awscli = {
      enable = true;
      executable = true;
      target = ".aws/1password-awscli";
      text = ''
        #!${pkgs.bash}/bin/bash

        op=${pkgs._1password}/bin/op
        jq=${pkgs.jq}/bin/jq

        item_id="$1"
        vault="$2"

        echo $(
          $op item get \
            --vault "$vault" \
            "$item_id" \
            --fields label='access key id','secret access key' \
            --format json \
          | $jq '{
              Version: 1,
              AccessKeyId: (.[] | select(.label == "access key id") | .value),
              SecretAccessKey: (.[] | select(.label == "secret access key") | .value),
            }'
        )
      '';
    };
  };
}