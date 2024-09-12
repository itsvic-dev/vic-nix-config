{ config, lib, ... }:
{
  config = lib.mkIf config.vic-nix.software.docker (
    lib.mkMerge [
      {
        virtualisation.docker.enable = true;
        users.users.vic.extraGroups = [ "docker" ];
      }
      (lib.mkIf config.vic-nix.tmpfsAsRoot {
        environment.persistence."/persist".directories = [ "/var/lib/docker" ];
      })
    ]
  );
}
