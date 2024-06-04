{ pkgs, ... }:
let
  # note: assuming amd64
  wingsBinary = pkgs.fetchurl {
    url = "https://github.com/pterodactyl/wings/releases/download/v1.11.13/wings_linux_amd64";
    sha256 = "sha256-KwbNJm40NOWT71UuTByh5FzEsGuVeGT5gJTuMXeWuPw=";
    executable = true;
  };
in
{
  systemd.services."wings-demo" = {
    wantedBy = [ "network-online.target" ];
    serviceConfig = {
      # ugh, wings expects to be able to write to the config. we can't do this declaratively
      ExecStart = "${wingsBinary} --config /etc/pterodactyl/demo-config.yml";
      Restart = "always";
    };
  };
  networking.firewall.allowedTCPPorts = [ 8443 ];

  systemd.services."wings-develop" = {
    wantedBy = [ "network-online.target" ];
    serviceConfig = {
      ExecStart = "${wingsBinary} --config /etc/pterodactyl/config.yml";
      Restart = "always";
    };
  };
}
