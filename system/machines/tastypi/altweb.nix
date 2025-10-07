{ pkgs, lib, defaultSecretsFile, config, inputs, ... }: {
  containers.altweb = {
    autoStart = true;
    privateNetwork = true;
    localAddress = "2.0.0.1";

    bindMounts = {
      "/etc/ssh/ssh_host_ed25519_key" = {
        hostPath = "/etc/ssh/ssh_host_ed25519_key";
        isReadOnly = true;
      };
    };

    extraVeths.pi-ix = {
      localAddress = "192.168.169.2";
      hostAddress = "192.168.169.1";
    };

    config = { config, pkgs, ... }: {
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
            Address = "2.0.0.1/16";
          };
        };
        "20-pi-ix" = {
          matchConfig.Name = "pi-ix";
          networkConfig = { DHCP = "no"; };
          addresses = [{
            Address = "192.168.169.2/32";
            Peer = "192.168.169.1/32";
          }];
        };
      };

      networking.wireguard.interfaces.wg-aw-pl = {
        ips = [ "192.168.170.1/24" ];
        listenPort = 51822;
        privateKeyFile = config.sops.secrets.altweb-wg-sk.path;

        peers = [{
          publicKey = "1EhjMgu5HobrdK1Vg1W28ze0REARZTcexNpQRoq30gY=";
          allowedIPs = [ "192.168.170.0/24" ];
        }];
      };

      services.nginx = {
        enable = true;
        recommendedGzipSettings = true;
        recommendedBrotliSettings = true;

        virtualHosts."2.0.0.1" = {
          default = true;
          root = ./altweb-root;
        };
      };

      services.frr = {
        bgpd.enable = true;
        config = ''
          line vty
          service integrated-vtysh-config
          router bgp 65001
            np bgp egbp-requires-policy
            neighbor 192.168.170.2 remote-as 65002
            address-family ipv4 unicast
              network 2.0.0.0/16
              neighbor 192.168.170.2 soft-reconfiguration inbound
              neighbor 192.168.170.2 distribute-list 11 in
              neighbor 192.168.170.2 distribute-list 10 out
            exit-address-family

          access-list 10 seq 5 permit 2.0.0.0/16
          access-list 11 seq 5 permit any
        '';
      };

      system.stateVersion = "25.05";
    };
  };

  networking = {
    firewall = {
      allowedUDPPorts = [ 51822 ];
      extraCommands = ''
        iptables -t nat -A POSTROUTING -o pi-ix -j MASQUERADE
      '';
      extraStopCommands = ''
        iptables -t nat -D POSTROUTING -o pi-ix -j MASQUERADE
      '';
    };
    nat.forwardPorts = [{
      destination = "192.168.169.2:51822";
      sourcePort = 51822;
      proto = "udp";
    }];
  };
}
