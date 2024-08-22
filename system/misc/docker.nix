{ config, lib, ... }:
{
  config = lib.mkIf config.vic-nix.software.docker {
    virtualisation.docker.enable = true;
    users.users.vic.extraGroups = [ "docker" ];
  };
}
