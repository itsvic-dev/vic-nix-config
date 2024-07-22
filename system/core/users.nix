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

    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQ9kubQPsQKJdtOLG35DApD9IWNU5gR6Dm+e2cy2L83 vic@e6nix"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwzZPUNnSF9PNKp4RlYL8xggd52nE139qFAKQdpPKYf" # Termius on Pixel 8
    ];
  };

  users.mutableUsers = false;
}
