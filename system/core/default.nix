{ pkgs, ... }:
{
  imports = [
    ./appimage.nix
    ./i18n.nix
    ./users.nix
    ./nix.nix
    ./bootloader.nix
  ];

  boot.tmp.useTmpfs = true;
  networking.nameservers = [
    # IPv4
    "1.1.1.1"
    "1.0.0.1"

    # IPv6
    "2606:4700:4700::1111"
    "2606:4700:4700::1001"
  ];
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved";
  };
  services.resolved.enable = true;

  sops = {
    defaultSopsFile = ../../secrets/global.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # don't change this
  system.stateVersion = "23.05";
}
