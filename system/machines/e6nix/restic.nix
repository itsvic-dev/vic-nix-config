{ config, secretsPath, ... }:
{
  sops.secrets =
    let
      sopsFile = "${secretsPath}/restic.yaml";
    in
    {
      restic-password = {
        inherit sopsFile;
      };
      rclone-config = {
        inherit sopsFile;
      };
    };

  services.restic.backups.e6nix = {
    repository = "rclone:onedrive:restic/e6nix";
    passwordFile = config.sops.secrets.restic-password.path;
    rcloneConfigFile = config.sops.secrets.rclone-config.path;

    paths = [ "/home/vic" ];

    # might need more excludes in the future. not sure
    exclude = [
      ".git"
      "/home/vic/.cache"
    ];
  };
}
