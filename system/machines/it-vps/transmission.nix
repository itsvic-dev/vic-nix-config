{ config, pkgs, ... }:
let
  doneScript = pkgs.writeScript "vic-torrent-done" ''
    #!${pkgs.runtimeShell}
    JSON_TEMPLATE='{embeds: [{title: "Finished downloading torrent", description: $name, color: 65280, footer: {text: $ver}}]}'
    JSON_DATA="$(
      ${pkgs.jq}/bin/jq -n \
      --arg name "$TR_TORRENT_NAME" \
      --arg ver "Transmission v$TR_APP_VERSION" \
      "$JSON_TEMPLATE"
    )"
    ${pkgs.curl}/bin/curl \
      -X POST "$(cat ${config.sops.secrets."transmissionWebhook".path})" \
      -H 'Content-Type: application/json' \
      --data "$JSON_DATA"
  '';
in
{
  services.transmission = {
    enable = true;
    home = "/mnt/hdd/transmission";
    webHome = pkgs.flood-for-transmission;
    settings = {
      script-torrent-done-enabled = true;
      script-torrent-done-filename = doneScript;
      incomplete-dir-enabled = true;
      watch-dir-enabled = true;
      watch-dir = "${config.services.transmission.home}/Torrents";
      umask = 0;
    };
    openPeerPorts = true;
    downloadDirPermissions = "777";
    credentialsFile = config.sops.secrets."transmission".path;
  };

  services.nginx.virtualHosts."trdata.itsvic.dev" = {
    root = config.services.transmission.settings.download-dir;
    extraConfig = ''
      autoindex on;
      fancyindex on;
      fancyindex_exact_size off;
    '';
  };

  sops.secrets."transmission" = {
    owner = config.services.transmission.user;
    restartUnits = [ "transmission.service" ];
    sopsFile = ../../../secrets/it-vps.yaml;
  };
  sops.secrets."transmissionWebhook" = {
    owner = config.services.transmission.user;
    sopsFile = ../../../secrets/it-vps.yaml;
  };
}
