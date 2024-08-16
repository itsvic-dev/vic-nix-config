{ config, ... }:
{
  sops.secrets = {
    akos-ipv6-pk.sopsFile = ../../../secrets/tastypi.yaml;
    testlab-pk.sopsFile = ../../../secrets/tastypi.yaml;
  };

  networking.wireguard.interfaces = {
    akos-ipv6 = {
      ips = [ "2a0e:97c0:7c5::2/48" ];
      listenPort = 51820;
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

    testlab = {
      ips = [ "2a0e:97c0:7c5:e621::1/64" ];
      listenPort = 51821;
      privateKeyFile = config.sops.secrets.testlab-pk.path;

      postSetup = ''
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i testlab -o akos-ipv6 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -A FORWARD -i akos-ipv6 -o testlab -j ACCEPT
      '';

      postShutdown = ''
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i testlab -o akos-ipv6 -j ACCEPT
        ${pkgs.iptables}/bin/ip6tables -D FORWARD -i akos-ipv6 -o testlab -j ACCEPT
      '';

      peers = [
        {
          publicKey = "s+g8KhlC/hL/E51v1Sn++Ggm0qiHuQ/NIRZb3s2ZnBo=";
          allowedIPs = [ "2a0e:97c0:7c5:e621::/64" ];
        }
      ];
    };
  };

  boot.kernel.sysctl = {
    # If you want to use it for ipv6
    "net.ipv6.conf.all.forwarding" = true;
    "net.ipv6.conf.default.forwarding" = true;
  };

  networking.firewall.allowedUDPPorts = [ 51821 ];

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
