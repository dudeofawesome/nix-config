{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    concatMap
    concatStringsSep
    filter
    imap1
    mapAttrsToList
    mkEnableOption
    mkIf
    mkOption
    optional
    optionalString
    types
    ;

  cfg = config.hardware.nct6775;

  nullable = type: {
    type = types.nullOr type;
    default = null;
  };

  dutyOption = description: nullable (types.ints.between 0 255) // { inherit description; };
  durationOption = description: nullable types.ints.unsigned // { inherit description; };
  temperatureOption = description: nullable (types.ints.between 0 127) // { inherit description; };

  curvePoint = types.submodule {
    options = {
      temperature = mkOption {
        type = types.ints.between 0 127;
        description = "Temperature for this curve point, in degrees Celsius.";
      };

      pwm = mkOption {
        type = types.ints.between 0 255;
        description = "PWM duty at this curve point, from 0 to 255.";
      };
    };
  };

  channelModule = types.submodule {
    options = {
      mode = mkOption (
        nullable (
          types.enum [
            "fullSpeed"
            "manual"
            "thermalCruise"
            "fanSpeedCruise"
            "smartFanIII"
            "smartFanIV"
          ]
        )
        // {
          description = ''
            Hardware fan-control mode. A null value preserves the mode selected
            by firmware.
          '';
        }
      );

      outputMode = mkOption (
        nullable (
          types.enum [
            "dc"
            "pwm"
          ]
        )
        // {
          description = "Fan output signaling mode, or null to preserve the firmware setting.";
        }
      );

      manualDuty = mkOption (dutyOption "PWM duty used in manual mode.");
      temperatureSource = mkOption (
        nullable (types.ints.between 1 255)
        // {
          description = ''
            Index of the primary tempX_input source. This mapping is
            motherboard-specific.
          '';
        }
      );
      secondaryTemperatureSource = mkOption (
        nullable (types.ints.between 0 255)
        // {
          description = ''
            Index of the secondary weighted temperature source. Zero disables
            secondary temperature control.
          '';
        }
      );
      secondaryDutyStep = mkOption (dutyOption "PWM step for the secondary temperature source.");
      secondaryTemperatureStep = mkOption (
        temperatureOption "Temperature step for secondary temperature control."
      );
      secondaryTemperatureBase = mkOption (
        temperatureOption "Temperature at which secondary temperature control begins."
      );
      secondaryTemperatureTolerance = mkOption (
        temperatureOption "Tolerance for secondary temperature control."
      );

      targetTemperature = mkOption (temperatureOption "Target temperature used by Thermal Cruise mode.");
      temperatureTolerance = mkOption (temperatureOption "Temperature tolerance, in degrees Celsius.");
      criticalTemperatureTolerance = mkOption (
        temperatureOption "Critical temperature tolerance, in degrees Celsius."
      );
      startDuty = mkOption (dutyOption "Duty required to start a stopped fan in Thermal Cruise mode.");
      floorDuty = mkOption (dutyOption "Minimum duty used by Thermal Cruise mode.");
      stepUpTime = mkOption (durationOption "Delay before increasing fan duty, in milliseconds.");
      stepDownTime = mkOption (durationOption "Delay before decreasing fan duty, in milliseconds.");
      stopTime = mkOption (durationOption "Delay before stopping a fan, in milliseconds.");

      targetSpeed = mkOption (
        nullable types.ints.unsigned
        // {
          description = "Target fan speed used by Fan Speed Cruise mode, in RPM.";
        }
      );
      speedTolerance = mkOption (
        nullable types.ints.unsigned
        // {
          description = "Fan-speed tolerance used by Fan Speed Cruise mode, in RPM.";
        }
      );

      curve = mkOption {
        type = types.listOf curvePoint;
        default = [ ];
        description = ''
          Smart Fan IV curve. When set, its length must match the curve-point
          count exposed by the chip, temperatures must strictly increase, PWM
          values must not decrease, and the final point must use full duty.
        '';
      };
    };
  };

  modeValue = {
    fullSpeed = 0;
    manual = 1;
    thermalCruise = 2;
    fanSpeedCruise = 3;
    smartFanIII = 4;
    smartFanIV = 5;
  };

  milliDegrees = value: value * 1000;

  optionalWrite =
    attribute: value:
    optional (value != null) {
      inherit attribute;
      value = toString value;
    };

  channelWrites =
    channel: settings:
    let
      prefix = "pwm${channel}";
    in
    optionalWrite "${prefix}_mode" (
      if settings.outputMode == null then
        null
      else if settings.outputMode == "pwm" then
        1
      else
        0
    )
    ++ optionalWrite prefix settings.manualDuty
    ++ optionalWrite "${prefix}_temp_sel" settings.temperatureSource
    ++ optionalWrite "${prefix}_weight_temp_sel" settings.secondaryTemperatureSource
    ++ optionalWrite "${prefix}_weight_duty_step" settings.secondaryDutyStep
    ++ optionalWrite "${prefix}_weight_temp_step" (
      if settings.secondaryTemperatureStep == null then
        null
      else
        milliDegrees settings.secondaryTemperatureStep
    )
    ++ optionalWrite "${prefix}_weight_temp_step_base" (
      if settings.secondaryTemperatureBase == null then
        null
      else
        milliDegrees settings.secondaryTemperatureBase
    )
    ++ optionalWrite "${prefix}_weight_temp_step_tol" (
      if settings.secondaryTemperatureTolerance == null then
        null
      else
        milliDegrees settings.secondaryTemperatureTolerance
    )
    ++ optionalWrite "${prefix}_target_temp" (
      if settings.targetTemperature == null then null else milliDegrees settings.targetTemperature
    )
    ++ optionalWrite "${prefix}_temp_tolerance" (
      if settings.temperatureTolerance == null then null else milliDegrees settings.temperatureTolerance
    )
    ++ optionalWrite "${prefix}_crit_temp_tolerance" (
      if settings.criticalTemperatureTolerance == null then
        null
      else
        milliDegrees settings.criticalTemperatureTolerance
    )
    ++ optionalWrite "${prefix}_start" settings.startDuty
    ++ optionalWrite "${prefix}_floor" settings.floorDuty
    ++ optionalWrite "${prefix}_step_up_time" settings.stepUpTime
    ++ optionalWrite "${prefix}_step_down_time" settings.stepDownTime
    ++ optionalWrite "${prefix}_stop_time" settings.stopTime
    ++ optionalWrite "fan${channel}_target" settings.targetSpeed
    ++ optionalWrite "fan${channel}_tolerance" settings.speedTolerance
    ++ concatMap (
      point:
      optionalWrite "${prefix}_auto_point${toString point.index}_temp" (
        milliDegrees point.value.temperature
      )
      ++ optionalWrite "${prefix}_auto_point${toString point.index}_pwm" point.value.pwm
    ) (imap1 (index: value: { inherit index value; }) settings.curve)
    # Select the requested mode only after all of its parameters are installed.
    ++ optionalWrite "${prefix}_enable" (
      if settings.mode == null then null else modeValue.${settings.mode}
    );

  writes = concatMap (channel: channelWrites channel.name channel.value) (
    mapAttrsToList (name: value: { inherit name value; }) cfg.channels
  );

  curveChecks = mapAttrsToList (
    channel: settings:
    let
      temperatures = map (point: point.temperature) settings.curve;
      duties = map (point: point.pwm) settings.curve;
      increasing =
        values:
        lib.all (index: builtins.elemAt values index < builtins.elemAt values (index + 1)) (
          lib.range 0 (builtins.length values - 2)
        );
      nondecreasing =
        values:
        lib.all (index: builtins.elemAt values index <= builtins.elemAt values (index + 1)) (
          lib.range 0 (builtins.length values - 2)
        );
    in
    [
      {
        assertion = builtins.match "[1-7]" channel != null;
        message = "`hardware.nct6775.channels` keys must be integers from 1 through 7; got `${channel}`.";
      }
      {
        assertion = settings.curve == [ ] || settings.mode == "smartFanIV";
        message = "`hardware.nct6775.channels.${channel}.curve` requires `mode = \"smartFanIV\"`.";
      }
      {
        assertion = settings.curve == [ ] || builtins.length settings.curve >= 2;
        message = "`hardware.nct6775.channels.${channel}.curve` requires at least two points.";
      }
      {
        assertion = builtins.length temperatures < 2 || increasing temperatures;
        message = "Temperatures in `hardware.nct6775.channels.${channel}.curve` must strictly increase.";
      }
      {
        assertion = builtins.length duties < 2 || nondecreasing duties;
        message = "PWM values in `hardware.nct6775.channels.${channel}.curve` must not decrease.";
      }
      {
        assertion = duties == [ ] || lib.last duties == 255;
        message = "The final point in `hardware.nct6775.channels.${channel}.curve` must use PWM duty 255.";
      }
      {
        assertion = settings.manualDuty == null || settings.mode == "manual";
        message = "`hardware.nct6775.channels.${channel}.manualDuty` requires `mode = \"manual\"`.";
      }
      {
        assertion =
          (
            settings.targetTemperature == null
            && settings.startDuty == null
            && settings.floorDuty == null
            && settings.stopTime == null
          )
          || settings.mode == "thermalCruise";
        message = "Thermal Cruise settings on `hardware.nct6775.channels.${channel}` require `mode = \"thermalCruise\"`.";
      }
      {
        assertion =
          (settings.targetSpeed == null && settings.speedTolerance == null)
          || settings.mode == "fanSpeedCruise";
        message = "Fan Speed Cruise settings on `hardware.nct6775.channels.${channel}` require `mode = \"fanSpeedCruise\"`.";
      }
    ]
  ) cfg.channels;

  curvePreflight = concatStringsSep "\n" (
    filter (line: line != "") (
      mapAttrsToList (
        channel: settings:
        optionalString (settings.curve != [ ]) ''
          shopt -s nullglob
          curve_points=("$hwmon"/pwm${channel}_auto_point*_temp)
          shopt -u nullglob
          if (( ''${#curve_points[@]} != ${toString (builtins.length settings.curve)} )); then
            echo "pwm${channel}: expected ${toString (builtins.length settings.curve)} curve points, found ''${#curve_points[@]}" >&2
            exit 1
          fi
        ''
      ) cfg.channels
    )
  );

  writeCommands = concatStringsSep "\n" (
    map (
      write:
      "apply ${
        lib.escapeShellArgs [
          write.attribute
          write.value
        ]
      }"
    ) writes
  );

  applySettings = pkgs.writeShellScript "apply-nct6775-fan-control" ''
    set -Eeuo pipefail

    declare -a matches=()
    for candidate in /sys/class/hwmon/hwmon*; do
      if [[ -r "$candidate/name" ]] && IFS= read -r name < "$candidate/name" &&
        [[ "$name" == ${lib.escapeShellArg cfg.device} ]]
      then
        matches+=("$candidate")
      fi
    done

    if (( ''${#matches[@]} != 1 )); then
      echo "expected exactly one ${cfg.device} hwmon device, found ''${#matches[@]}" >&2
      exit 1
    fi

    hwmon="''${matches[0]}"
    ${curvePreflight}

    ${concatStringsSep "\n" (
      map (write: ''
        if [[ ! -r "$hwmon/${write.attribute}" || ! -w "$hwmon/${write.attribute}" ]]; then
          echo "unsupported or unwritable attribute: ${write.attribute}" >&2
          exit 1
        fi
      '') writes
    )}

    declare -a changed_paths=()
    declare -a original_values=()

    rollback() {
      trap - ERR
      for ((index = ''${#changed_paths[@]} - 1; index >= 0; index--)); do
        printf '%s\n' "''${original_values[index]}" > "''${changed_paths[index]}" || true
      done
    }
    trap rollback ERR

    apply() {
      local attribute="$1"
      local value="$2"
      local path="$hwmon/$attribute"
      local original

      IFS= read -r original < "$path"
      changed_paths+=("$path")
      original_values+=("$original")
      printf '%s\n' "$value" > "$path"
    }

    ${writeCommands}
    trap - ERR
  '';
in
{
  options.hardware.nct6775 = {
    enable = mkEnableOption "NCT6775-family hardware fan control";

    device = mkOption {
      type = types.str;
      default = "nct6775";
      example = "nct6798";
      description = "Exact hwmon device name to configure.";
    };

    channels = mkOption {
      type = types.attrsOf channelModule;
      default = { };
      description = "NCT6775-family PWM channels to configure.";
    };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.channels != { };
        message = "`hardware.nct6775.channels` must configure at least one channel.";
      }
    ]
    ++ lib.flatten curveChecks;

    boot.kernelModules = [ "nct6775" ];

    systemd.services.nct6775-fan-control = {
      description = "Configure NCT6775-family hardware fan control";
      wantedBy = [ "multi-user.target" ];
      after = [ "systemd-modules-load.service" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = applySettings;
      };
    };

    powerManagement.resumeCommands = ''
      ${lib.getExe' pkgs.systemd "systemctl"} restart nct6775-fan-control.service
    '';
  };
}
