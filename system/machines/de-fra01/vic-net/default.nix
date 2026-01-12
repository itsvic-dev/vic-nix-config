{
  intranet,
  ...
}:
{
  imports = [
    ./bird.nix
    ./bind
    intranet.sysctls
    intranet.transfers
    intranet.dummy
  ];

  sops.secrets.vic-net-sk = { };
  networking.firewall.allowedUDPPorts = [ 6696 ];
}
