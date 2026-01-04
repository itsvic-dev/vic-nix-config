{ pkgs, lib, ... }:
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

  systemd.network.networks."20-dont-touch-my-veths" = {
    matchConfig = {
      Name = "ve-intraweb-ntp";
    };
    linkConfig = {
      Unmanaged = true;
    };
  };

  systemd.services."intraweb-ntp-veth" = {
    requires = [ "intraweb-netns.service" ];
    requiredBy = [ "container@intraweb.service" ];

    serviceConfig = {
      Type = "oneshot";
      User = "root";
      RemainAfterExit = true;
      ExecStop = "${ip} link del ve-intraweb-ntp";
    };

    script = ''
      set -x
      # set up veth pair
      ${ip} link add ve-intraweb-ntp type veth peer ve-intraweb-ntp netns intraweb

      # set up guest side
      ${ip} -n intraweb addr add dev ve-intraweb-ntp 10.100.0.2
      ${ip} -n intraweb link set dev ve-intraweb-ntp up

      # set up host side
      ${ip} addr add dev ve-intraweb-ntp 10.100.0.1
      ${ip} link set dev ve-intraweb-ntp up

      # now route them together
      ${ip} route add 10.100.0.2 dev ve-intraweb-ntp
      ${ip} -n intraweb route add 10.100.0.1 dev ve-intraweb-ntp
    '';
  };

  containers.intraweb = {
    autoStart = true;
    networkNamespace = "/run/netns/intraweb";
    config = import ./container-config.nix;
    # for container's ntp
    additionalCapabilities = [ "CAP_SYS_TIME" ];
  };

  services.openntpd = {
    enable = true;
    extraConfig = ''
      listen on 10.100.0.1
    '';
  };

  networking.timeServers = lib.mkForce [
    "0.de.pool.ntp.org"
    "1.de.pool.ntp.org"
    "2.de.pool.ntp.org"
    "3.de.pool.ntp.org"
  ];
}
