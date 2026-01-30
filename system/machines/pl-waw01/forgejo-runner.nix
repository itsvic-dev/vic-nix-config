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
    iptables -t nat -A POSTROUTING -s 172.17.0.0/16 -d 10.21.0.0/24 -j MASQUERADE
  '';
  networking.firewall.extraStopCommands = ''
    iptables -t nat -D POSTROUTING -s 172.17.0.0/16 -d 10.21.0.0/24 -j MASQUERADE
  '';

  sops.secrets.forgejo-runner-token = { };
}
