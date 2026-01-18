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
  ];

  sops.secrets.vic-net-sk = { };
  networking.firewall.allowedUDPPorts = [ 6696 ];
}
