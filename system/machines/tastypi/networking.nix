{ config, ... }: {
  sops.secrets.akos-ipv6-pk = { };

  networking.wireguard.interfaces = {
    akos-ipv6 = {
      ips = [ "2a0e:97c0:7c5::2/48" ];
      listenPort = 51821;
      privateKeyFile = config.sops.secrets.akos-ipv6-pk.path;
      peers = [{
        publicKey = "z0FLHeJGlkRlp+e5WXJuQz2O3xSCJs74s++4dWDlZ1s=";
        allowedIPs = [ "::/0" ];
        endpoint = "70.34.254.174:999";
        persistentKeepalive = 25;
      }];
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
