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
