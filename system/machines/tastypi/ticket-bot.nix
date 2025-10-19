{ pkgs, lib, config, secretsPath, ... }:
let
  pp = pkgs.python3Packages;
  deps = pkgs.callPackage ./ticket-bot-deps.nix { inherit pp; };

  botSrc = builtins.fetchGit {
    url = "https://github.com/itsvic-dev/comms-tickets.git";
    rev = "edd0ab70453e088206ff9f2ec7723f108669e988";
  };

  python = pkgs.python3.withPackages
    (ps: [ ps.discordpy ps.pyyaml deps.tortoiseORM deps.aerich ]);
in {
  sops.secrets.ticket-bot-config = {
    format = "yaml";
    sopsFile = "${secretsPath}/ticket-bot.yml";
    key = "";

    restartUnits = [ "ticket-bot.service" ];
  };

  systemd.services."ticket-bot" = {
    wantedBy = [ "multi-user.target" ];
    wants = [ "network-online.target" ];

    serviceConfig = {
      DynamicUser = true;
      StateDirectory = "ticket-bot";
      Restart = "always";
      WorkingDirectory = "/var/lib/ticket-bot";
      LoadCredential =
        [ "config.yml:${config.sops.secrets.ticket-bot-config.path}" ];
    };
    script = ''
      set -e
      # HACK: put the files in the right place for the ticket bot
      rm -f .config.yml vic_tickets migrations pyproject.toml
      ln -s "''${CREDENTIALS_DIRECTORY}/config.yml" .config.yml
      ln -s "${botSrc}/migrations" ./
      ln -s "${botSrc}/vic_tickets" ./
      ln -s "${botSrc}/pyproject.toml" ./

      # upgrade DB first
      ${lib.getExe python} -m aerich upgrade

      # run the bot
      exec ${lib.getExe python} ${botSrc}/main.py
    '';
  };
}
