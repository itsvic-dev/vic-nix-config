{
  config,
  lib,
  inputs,
  ...
}:
{
  config = lib.mkIf config.vic-nix.tmpfsAsRoot {
    imports = [ inputs.impermanence.nixosModules.impermanence ];

    # automatically set up tmpfs on root
    fileSystems."/" = {
      device = "none";
      fsType = "tmpfs";
      options = [
        "defaults"
        "size=25%"
        "mode=755"
      ];
    };

    environment.persistence."/persist" = {
      hideMounts = true;
      directories = [
        "/var/log"
        "/var/lib/nixos"
        "/var/lib/systemd/coredump"
        "/etc/NetworkManager/system-connections"
        "/etc/ssh"
      ] ++ lib.mkIf config.vic-nix.hardware.bluetooth [ "/var/lib/bluetooth" ];

      files = [ "/etc/machine-id" ];
    };
  };
}
