# auto-updates registry and runs the whois server
{ pkgs, ... }:
{
  systemd.services."intraweb-registry-update" = {
    serviceConfig = {
      Type = "oneshot";
      User = "iwreg";
      Group = "iwreg";
      WorkingDirectory = "/opt/registry";
    };

    path = with pkgs; [
      git
      python3
    ];

    script = ''
      if [ ! -d .git ]; then
        git clone https://git.vic/itsvicdev/intraweb-registry.git .
      else
        git pull
      fi
      python3 ./utils/generate_zone.py
    '';
  };

  systemd.services."intraweb-bind-reloader" = {
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl reload bind.service";
    };
  };

  systemd.paths."intraweb-bind-reloader" = {
    wantedBy = [ "multi-user.target" ];
    pathConfig = {
      Unit = "intraweb-bind-reloader.service";
      PathChanged = "/opt/registry/iw.db";
    };
  };

  systemd.timers."intraweb-registry-update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "intraweb-registry-update.service";
    };
  };

  systemd.tmpfiles.rules = [
    "d '/opt/registry' 0755 iwreg iwreg - -"
    "f '/opt/registry/iw.db' 0755 iwreg iwreg - ''"
  ];

  systemd.services."intraweb-whois" = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.python3}/bin/python3 utils/whois.py -H 10.21.0.1";
      WorkingDirectory = "/opt/registry";
    };
  };

  networking.firewall.allowedTCPPorts = [ 43 ];

  users.users."iwreg" = {
    group = "iwreg";
    isSystemUser = true;
    home = "/opt/registry";
  };

  users.groups.iwreg = { };
}
