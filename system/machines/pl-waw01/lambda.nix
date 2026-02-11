{ pkgs, lib, ... }:
let
  variants = [
    "gnome"
    "kde"
    "installer"
  ];
in
{
  systemd.tmpfiles.rules = [
    "d '/opt/lambda-downloads' 0755 nobody nogroup -"
  ];

  systemd.services = builtins.listToAttrs (
    map (
      variant:
      lib.nameValuePair "lambda-update-${variant}" {
        path = with pkgs; [
          curl
          jq
        ];
        script = ''
          cd /opt/lambda-downloads
          # as long as hydra is on the same system, this should work fine
          path=$(curl -s -L -H "Accept: application/json" \
            https://hydra.vic/job/lambda/trunk/${variant}-update/latest \
            | jq -r .buildoutputs.out.path)

          echo "new path: $path"
          if [ "$path" == "$(readlink ${variant})" ]; then
            echo "no updates"
            exit
          fi

          rm -f ${variant}
          ln -s "$path" ${variant}
        '';
      }
    ) variants
  );

  systemd.timers = builtins.listToAttrs (
    map (
      variant:
      lib.nameValuePair "lambda-update-${variant}" {
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnUnitActiveSec = "30m";
          Unit = "lambda-update-${variant}.service";
        };
      }
    ) variants
  );

  services.nginx.virtualHosts."lambda.itsvic.dev" = {
    enableACME = true;
    forceSSL = true;

    locations = {
      "/" = {
        return = 403;
      };

      "/downloads/" = {
        alias = "/opt/lambda-downloads/";
        extraConfig = ''
          autoindex on;
        '';
      };
    };
  };
}
