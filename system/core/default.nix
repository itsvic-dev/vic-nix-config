{ config, pkgs, globalSecretsFile, ... }: {
  imports = [
    ./appimage.nix
    ./i18n.nix
    ./users.nix
    ./nix.nix
    ./bootloader.nix
    ./impermanence.nix
    ./plymouth.nix
  ];

  boot.tmp.useTmpfs = true;
  networking.nameservers = [ "10.21.0.1" ];
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
  services.resolved = {
    enable = true;
    fallbackDns = config.networking.nameservers;
  };

  sops = {
    defaultSopsFile = globalSecretsFile;

    age.sshKeyPaths = [
      (if config.vic-nix.tmpfsAsRoot then
        "/persist/etc/ssh/ssh_host_ed25519_key"
      else
        "/etc/ssh/ssh_host_ed25519_key")
    ];
  };

  # don't change this
  system.stateVersion = "23.05";
}
