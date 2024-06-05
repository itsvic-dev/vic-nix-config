{ config, ... }:
{
  programs.adb.enable = config.vic-nix.desktop.enable;
}
