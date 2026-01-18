{ config, pkgs, ... }:
{
  services.nginx.virtualHosts = {
    "wiki.iw" = {
      listenAddresses = [ "10.21.0.1" ];
      enableACME = true;
      forceSSL = true;
      locations."/" = {
        proxyPass = "http://localhost:4567";
      };
    };
  };

  services.gollum = {
    enable = true;
    stateDir = "/opt/iw-wiki";
    no-edit = true;
    h1-title = true;
  };

  systemd.services."intraweb-wiki-update" = {
    serviceConfig = {
      Type = "oneshot";
      User = config.services.gollum.user;
      Group = config.services.gollum.group;
      WorkingDirectory = config.services.gollum.stateDir;
    };

    path = with pkgs; [
      git
      python3
    ];

    script = ''
      if [ ! -d .git ]; then
        git clone https://github.com/itsvic-dev/intraweb-wiki.git .
      else
        git pull
      fi
    '';
  };

  systemd.timers."intraweb-wiki-update" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "hourly";
      Unit = "intraweb-wiki-update.service";
    };
  };

  security.acme.certs."wiki.iw".server = "https://acme.iw/acme/directory";
}
