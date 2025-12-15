{ pkgs, config, ... }:
{
  # hardware.enableAllFirmware = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = pkgs.stdenv.hostPlatform.system == "x86_64-linux" && config.vic-nix.desktop.forGaming;
  };
}
