{
  config,
  pkgs,
  intranet,
  ...
}:
{
  services.bird = {
    enable = true;
    package = pkgs.bird2;

    config = ''
      define OWNIP = ${intranet.ips.${config.networking.hostName}};
      router id OWNIP;

      include "${intranet.birdShared}";

      ${intranet.getAllIBGP config}

      # protocol bgp isp_funny {
      #   enable extended messages on;
      #   local as OWNAS;
      #   neighbor fe80::1247:aa59:7a3c:f8e0%end0 as 4266660003;

      #   ipv4 {
      #     import where is_valid_network() && !is_self_net();
      #     export where is_valid_network() && source ~ [RTS_STATIC, RTS_BGP];
      #     import limit 1000 action block;
      #     extended next hop on;
      #   };
      # }
    '';
  };

  services.bird-lg.proxy = {
    enable = true;
    allowedIPs = [ "10.0.0.0/8" ];
    listenAddresses = "${intranet.ips.${config.networking.hostName}}:60134";
  };

  networking.firewall.allowedTCPPorts = [
    179
    60134
  ];
}
