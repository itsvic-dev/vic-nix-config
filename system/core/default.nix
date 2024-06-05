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
  networking.networkmanager.enable = true;

  sops = {
    defaultSopsFile = ../../secrets/global.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  };

  # don't change this
  system.stateVersion = "23.05";
}
