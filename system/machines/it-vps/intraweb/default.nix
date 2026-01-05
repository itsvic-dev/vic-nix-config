{
  config,
  pkgs,
  inputs,
  secretsPath,
  ...
}:
let
  ip = "${pkgs.iproute2}/bin/ip";
in
{
  imports = [
    inputs.intraweb.nixosModules.default
  ];

  sops.secrets.iw-backend-config = {
    format = "yaml";
    sopsFile = "${secretsPath}/intraweb-backend.yml";
    key = "";
    restartUnits = [ "intraweb-backend.service" ];
  };

  services.intraweb-backend = {
    enable = true;
    openFirewall = true;
    configFile = config.sops.secrets.iw-backend-config.path;
  };

  networking.firewall.allowedUDPPorts = [ 59808 ];

  systemd.services."intraweb-netns" = {
    restartIfChanged = false;
    stopIfChanged = false;
    wantedBy = [ "multi-user.target" ];
    requiredBy = [
      "intraweb-backend.service"
    ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      RemainAfterExit = true;
      ExecStop = "${ip} netns del intraweb";
    };

    script = ''
      if [ ! -f /run/netns/intraweb ]; then
        ${ip} netns add intraweb
      fi
      ${ip} -n intraweb link set dev lo up
    '';
  };
}
