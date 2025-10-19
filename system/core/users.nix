{ config, lib, pkgs, ... }: {

  config = lib.mkMerge [
    {
      users = {
        mutableUsers = false;

        users.vic = {
          isNormalUser = true;
          extraGroups = [ "wheel" "video" "render" "netdev" ];
          shell = pkgs.zsh;

          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPQ9kubQPsQKJdtOLG35DApD9IWNU5gR6Dm+e2cy2L83 vic@e6nix"
          ];
        };
      };
    }

    (lib.mkIf (!config.vic-nix.noSecrets) {
      sops.secrets.vic-password.neededForUsers = true;

      users.users.vic.hashedPasswordFile =
        config.sops.secrets.vic-password.path;
    })
  ];
}
