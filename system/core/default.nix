{ pkgs, ... }:
{
  imports = [
    ./appimage.nix
    ./i18n.nix
    ./users.nix
    ./nix.nix
  ];

  boot.tmp.useTmpfs = true;

  networking.networkmanager.enable = true;

  # don't change this
  system.stateVersion = "23.05";
}
