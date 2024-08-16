{
  config,
  lib,
  inputs,
  ...
}:
{
  imports = [ inputs.impermanence.nixosModules.impermanence ];

  config = lib.mkIf config.vic-nix.tmpfsAsRoot {
    environment.persistence."/persist" = {
      hideMounts = true;
      directories =
        [
          "/var/log"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
          "/etc/NetworkManager/system-connections"
          "/etc/ssh"
        ]
        ++ lib.optionals config.vic-nix.hardware.bluetooth [ "/var/lib/bluetooth" ]
        ++ lib.optionals config.vic-nix.secureBoot [ "/etc/secureboot" ] # sbctl keys
        ++ lib.optionals config.services.accounts-daemon.enable [ "/var/lib/AccountsService" ] # pfp and last session data
        ++ lib.optionals config.vic-nix.software.libvirt [ "/var/lib/libvirt" ];
      ;

      files = [ "/etc/machine-id" ];
    };
  };
}
