{ config, lib, pkgs, ... }: {

  config = lib.mkIf (!config.vic-nix.noSecrets) {
    sops.secrets.vic-password.neededForUsers = true;

    users = {
      mutableUsers = false;

      users.vic = {
        isNormalUser = true;
        hashedPasswordFile = config.sops.secrets.vic-password.path;
        extraGroups = [ "wheel" "video" "render" "netdev" ];
        shell = pkgs.zsh;

        openssh.authorizedKeys.keys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQ9kubQPsQKJdtOLG35DApD9IWNU5gR6Dm+e2cy2L83 vic@e6nix"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICwzZPUNnSF9PNKp4RlYL8xggd52nE139qFAKQdpPKYf" # Termius on Pixel 8
        ];
      };
    };
  };
}
