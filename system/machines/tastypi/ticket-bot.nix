{ pkgs, lib, config, secretsPath, ... }:
let
  pp = pkgs.python3Packages;
  deps = pkgs.callPackage ./ticket-bot-deps.nix { inherit pp; };

  botSrc = builtins.fetchGit {
    url = "git@github.com:itsvic-dev/comms-tickets";
    rev = "a0d06a07355b95de47e753704d6a08218cfb35a4";
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
