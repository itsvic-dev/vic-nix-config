{ pkgs, ... }:
let
  ip = "${pkgs.iproute2}/bin/ip";
in
{
  systemd.services."intraweb-netns" = {
    restartIfChanged = false;
    stopIfChanged = false;
    wantedBy = [ "multi-user.target" ];
    requiredBy = [ "container@intraweb.service" ];

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

  containers.intraweb = {
    autoStart = true;
    networkNamespace = "/run/netns/intraweb";
    config = import ./container-config.nix;
  };
}
