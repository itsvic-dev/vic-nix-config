{ pkgs, config, ... }:
{
  vic-nix.software.docker = true;

  services.gitea-actions-runner = {
    package = pkgs.forgejo-runner;
    instances.default = {
      enable = true;
      name = "pl-waw01";
      url = "https://git.vic.iw";
      labels = [
        "debian-latest:docker://node:25-bullseye"
        "steamrt-sniper:docker://registry.gitlab.steamos.cloud/steamrt/sniper/sdk"
      ];
      tokenFile = config.sops.secrets.forgejo-runner-token.path;
    };
  };

  networking.firewall.extraCommands = ''
    iptables -t nat -I POSTROUTING 1 -s 172.17.0.0/16 -d 10.21.0.0/24 -j SNAT --to-source 10.21.0.4
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D POSTROUTING -s 172.17.0.0/16 -d 10.21.0.0/24 -j SNAT --to-source 10.21.0.4
  '';

  sops.secrets.forgejo-runner-token = { };
}
