{ config, pkgs, lib, globalSecretsFile, ... }: {
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
      networking.nameservers = if (config.vic-nix.noSecrets) then [
        "1.1.1.1"
        "1.0.0.1"
      ] else
        [ "10.21.0.1" ];
      services.resolved = {
        enable = true;
        fallbackDns = config.networking.nameservers;
      };

      security.pki.certificateFiles = [ ../../ca/ca-cert.pem ];

      # don't change this
      system.stateVersion = "23.05";
    }

    (lib.mkIf (!config.vic-nix.noSecrets) {
      sops = {
        defaultSopsFile = globalSecretsFile;

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
