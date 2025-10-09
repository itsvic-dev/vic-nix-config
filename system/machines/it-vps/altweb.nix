{ inputs, defaultSecretsFile, ... }: {
  containers.altweb = {
    autoStart = true;
    privateNetwork = true;
    localAddress = "2.1.0.1";

    bindMounts = {
      "/etc/ssh/ssh_host_ed25519_key" = {
        hostPath = "/etc/ssh/ssh_host_ed25519_key";
        isReadOnly = true;
      };
    };

    extraVeths.it-ix = {
      localAddress = "192.168.150.2";
      hostAddress = "192.168.150.1";
    };

    config = { pkgs, config, ... }: {
      imports = [ inputs.sops-nix.nixosModules.sops ];
      sops = {
        age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
        secrets.altweb-wg-sk.sopsFile = defaultSecretsFile;
      };

      environment.systemPackages = with pkgs; [
        iptables
        tcpdump
        nettools
        inetutils
        mtr
      ];

      networking = {
        useHostResolvConf = false;
        enableIPv6 = false;
        useDHCP = false;
        firewall.enable = false;
        useNetworkd = true;
      };

      systemd.network.enable = true;
      systemd.network.networks = {
        "10-lan" = {
          matchConfig.Name = "eth0";
          networkConfig = {
            DHCP = "no";
            Address = "2.1.0.1/16";
          };
        };
        "20-it-ix" = {
          matchConfig.Name = "it-ix";
          networkConfig = { DHCP = "no"; };
          addresses = [{
            Address = "192.168.150.2/32";
            Peer = "192.168.150.1/32";
          }];
        };
        "20-pl-ix" = {
          matchConfig.Name = "pl-ix";
          addresses = [{ Address = "192.168.169.2/24"; }];
          routes = [{
            Destination = "192.168.170.2";
            Gateway = "192.168.169.1";
          }];
        };
      };

      services.frr = {
        bgpd.enable = true;
        config = ''
          line vty
          service integrated-vtysh-config
          router bgp 65002
            np bgp egbp-requires-policy
            neighbor 192.168.170.2 egbp-multihop
            neighbor 192.168.170.2 remote-as 65001
            address-family ipv4 unicast
              network 2.1.0.0/16
              neighbor 192.168.170.2 soft-reconfiguration inbound
              neighbor 192.168.170.2 distribute-list 11 in
              neighbor 192.168.170.2 distribute-list 10 out
            exit-address-family

          access-list 10 seq 5 permit 2.1.0.0/16
          access-list 11 seq 5 permit any
        '';
      };

      networking.wireguard.interfaces.pl-ix = {
        ips = [ "192.168.169.2/24" ];
        listenPort = 51820;
        privateKeyFile = config.sops.secrets.altweb-wg-sk.path;
        allowedIPsAsRoutes = false; # FRR/BGP will handle it

        peers = [{
          publicKey = "s/CPpyHD2xZJNaQ5UcxkDYR9m3SFyfaZ9FssifIw9zs=";
          endpoint = "192.168.150.1:51822";
          allowedIPs = [ "0.0.0.0/0" ];
        }];
      };

      system.stateVersion = "25.05";
    };
  };

  networking = {
    firewall = {
      extraCommands = ''
        iptables -t nat -A PREROUTING -s 192.168.150.2 -d 192.168.150.1 -p udp --dport 51822 -j DNAT --to-destination 31.179.32.196:51822
        iptables -t nat -A POSTROUTING -p udp -d 31.179.32.196 --dport 51822 -j MASQUERADE
      '';
      extraStopCommands = ''
        iptables -t nat -D PREROUTING -s 192.168.150.2 -d 192.168.150.1 -p udp --dport 51822 -j DNAT --to-destination 31.179.32.196:51822
        iptables -t nat -D POSTROUTING -p udp -d 31.179.32.196 --dport 51822 -j MASQUERADE
      '';
    };
  };
}
