{ pkgs, config, ... }:
{
  vic-nix.software.docker = true;

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      url = "https://git.vic.iw";
      labels = [
        "debian-latest:docker://node:25-bullseye"
        "steamrt-sniper:docker://registry.gitlab.steamos.cloud/steamrt/sniper/sdk"
      ];
      tokenFile = config.sops.secrets.forgejo-runner-token.path;
    };
  };

  sops.secrets.forgejo-runner-token = { };
}
