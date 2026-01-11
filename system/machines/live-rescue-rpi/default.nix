{
  pkgs,
  config,
  inputs,
  modulesPath,
  lib,
  ...
}:
{
  imports = with inputs.nixos-raspberrypi.nixosModules; [
    inputs.nixos-raspberrypi.lib.inject-overlays
    raspberry-pi-5.base
    sd-image
    (inputs.nixos-raspberrypi + "/modules/installer/raspberrypi-installer.nix")
    inputs.nixos-raspberrypi.inputs.nixos-images.nixosModules.sdimage-installer
  ];

  disabledModules = [
    # disable the sd-image module that nixos-images uses
    (modulesPath + "/installer/sd-card/sd-image-aarch64-installer.nix")
  ];

  vic-nix.hardware.hasEFI = false;

  image.baseName =
    let
      cfg = config.boot.loader.raspberryPi;
    in
    lib.mkOverride 40 "nixos-installer-rpi${cfg.variant}-${cfg.bootloader}";

  boot.consoleLogLevel = 7;

  vic-nix.noSecrets = true;

  boot.loader.raspberryPi.bootloader = "kernel";

  environment.systemPackages = [
    inputs.disko.packages.${pkgs.stdenv.hostPlatform.system}.disko-install
  ];
}
