{ config, pkgs, lib, defaultSecretsFile, intranet, ... }:
let useNM = config.vic-nix.desktop.enable;
in {
  imports = [
    ./appimage.nix
    ./i18n.nix
    ./users.nix
    ./nix.nix
    ./bootloader.nix
    ./impermanence.nix
    ./plymouth.nix
  ];

  config = lib.mkMerge [
    {
      boot.tmp.useTmpfs = true;
      networking = {
        useNetworkd = !config.networking.networkmanager.enable;
        networkmanager.enable = lib.mkDefault useNM;
        nameservers = if (config.vic-nix.noSecrets) then [
          "1.1.1.1"
          "1.0.0.1"
        ] else
          [ intranet.nameserver ];
      };
      services.resolved = {
        enable = true;
        fallbackDns = [ "1.1.1.1" "1.0.0.1" ];
      };

      security.pki.certificateFiles = [ (intranet.caCert) ];

      # don't change this
      system.stateVersion = "23.05";
    }

    (lib.mkIf (!config.vic-nix.noSecrets) {
      sops = {
        defaultSopsFile = defaultSecretsFile;

        age.sshKeyPaths = [
          (if config.vic-nix.tmpfsAsRoot then
            "/persist/etc/ssh/ssh_host_ed25519_key"
          else
            "/etc/ssh/ssh_host_ed25519_key")
        ];
      };
    })
  ];
}
