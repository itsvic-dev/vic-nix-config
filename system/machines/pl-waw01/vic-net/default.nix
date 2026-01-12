{
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    intranet.sysctls
    intranet.transfers
    intranet.dummy

    (intranet.wgClientNet {
      hosts = [
        "mbp"
        "iphone"
      ];
      ip = "10.21.0.241/28";
      listenPort = 51820;
    })
  ];

  sops.secrets.vic-net-sk = { };
  networking.firewall.allowedUDPPorts = [ 6696 ];
}
