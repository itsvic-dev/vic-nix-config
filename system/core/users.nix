{ config, pkgs, ... }:
{
  sops.secrets.vic-password.neededForUsers = true;

  users.groups = {
    uinput = { };
  };

  users.users.vic = {
    isNormalUser = true;
    hashedPasswordFile = config.sops.secrets.vic-password.path;
    extraGroups = [
      "wheel"
      "uinput"
      "adbusers"
      "docker"
      "wireshark"
      "video"
      "render"
    ];
    shell = pkgs.zsh;
  };

  users.mutableUsers = false;
}
