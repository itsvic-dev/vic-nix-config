{ config, lib, ... }:
{
  config = lib.mkIf config.vic-nix.desktop.enable {
    programs.adb.enable = true;
    users.users.vic.extraGroups = [ "adbusers" ];
  };
}
