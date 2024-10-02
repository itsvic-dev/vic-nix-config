{ config, pkgs, ... }:
{
  sops.secrets = {
    akos-ipv6-pk.sopsFile = ../../../secrets/tastypi.yaml;
    vic-wg-pk.sopsFile = ../../../secrets/tastypi.yaml;
  };

  networking.wireguard.interfaces = {
    akos-ipv6 = {
      ips = [ "2a0e:97c0:7c5::2/48" ];
      listenPort = 51821;
      privateKeyFile = config.sops.secrets.akos-ipv6-pk.path;
      peers = [
        {
          publicKey = "z0FLHeJGlkRlp+e5WXJuQz2O3xSCJs74s++4dWDlZ1s=";
          allowedIPs = [ "::/0" ];
          endpoint = "70.34.254.174:999";
          persistentKeepalive = 25;
        }
      ];
    };

    vic-wg = {
      ips = [ "10.200.200.1/24" ];
      listenPort = 51820;
      privateKeyFile = config.sops.secrets.vic-wg-pk.path;

      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.200.200.0/24 -o end0 -j MASQUERADE
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.200.200.0/24 -o end0 -j MASQUERADE
      '';

      peers = [
        {
          publicKey = "Z2M4NeR3ulHlsSOOyubhKui2qsWd14wgWR9lTTWVg2E=";
          allowedIPs = [ "10.200.200.2/24" ];
        }
      ];
    };
  };

  networking = {
    firewall.allowedUDPPorts = [ config.networking.wireguard.interfaces.vic-wg.listenPort ];
    nat = {
      enable = true;
      externalInterface = "end0";
      internalInterfaces = [ "vic-wg" ];
    };
  };

  environment.etc."gai.conf".text = ''
    label  ::1/128       0
    label  ::/0          1
    label  2002::/16     2
    label ::/96          3
    label ::ffff:0:0/96  4
    precedence  ::1/128       50
    precedence  ::/0          40
    precedence  2002::/16     30
    precedence ::/96          20
    precedence ::ffff:0:0/96  100
  '';
}
