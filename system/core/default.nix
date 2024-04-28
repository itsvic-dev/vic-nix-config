{ pkgs, ... }:
{
  imports = [
    ./boot-${pkgs.system}.nix
    ./appimage.nix
    ./i18n.nix
    ./users.nix
  ];

  boot.tmp.useTmpfs = true;

  networking.networkmanager.enable = true;
}
