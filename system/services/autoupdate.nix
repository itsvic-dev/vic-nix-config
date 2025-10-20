{ pkgs, config, lib, ... }: {
  config = lib.mkIf config.vic-nix.autoUpdate {
    systemd.services."vic-nix-autoupdate" = {
      description = "Check for new system builds";
      requires = [ "network-online.target" ];

      script = ''
        system_path=$(${pkgs.curl}/bin/curl \
          -L -H "Accept: application/json" \
          https://hydra.vic/job/config/main/${config.networking.hostName}/latest \
          | ${pkgs.jq}/bin/jq -r .buildoutputs.out.path)

        echo "new system: $system_path"
        if [ "$system_path" == "$(readlink /run/current-system)" ]; then
          echo "new system is the same as current system, assuming no change"
          exit
        fi

        ${pkgs.nix}/bin/nix-env -p /nix/var/nix/profiles/system --set "$system_path"
        /nix/var/nix/profiles/system/bin/switch-to-configuration switch & disown
      '';
    };

    systemd.timers."vic-nix-autoupdate" = {
      description = "Check for new system builds";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "hourly";
        Unit = "vic-nix-autoupdate.service";
      };
    };
  };
}
