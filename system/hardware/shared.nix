{ pkgs, ... }: {
  # hardware.enableAllFirmware = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = pkgs.system == "x86_64-linux"
      && config.vic-nix.desktop.forGaming;
  };
}
