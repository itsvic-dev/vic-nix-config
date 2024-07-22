{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.vic-nix.server;
in
{
  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      settings.PasswordAuthentication = false;
    };

    sops.secrets.pamWebhook = { };

    security.pam.services.sshd.rules.session.vic-webhook =
      let
        webhookTrigger =
          with pkgs;
          writeScript "sshd-webhook-trigger" ''
            #!${pkgs.runtimeShell}
            JSON_TEMPLATE='{content: $content}'

            case "$PAM_TYPE" in
              open_session)
                CONTENT="User \`$PAM_USER\` logged into \`$HOSTNAME\` from address \`$PAM_RHOST\`."
                ;;
              close_session)
                CONTENT="User \`$PAM_USER\` signed out of \`$HOSTNAME\` from address \`$PAM_RHOST\`."
                ;;
            esac

            if [ -n "$CONTENT" ]; then
              JSON_DATA="$(
                ${pkgs.jq}/bin/jq -n --arg content "$CONTENT" "$JSON_TEMPLATE"
              )"
              ${pkgs.curl}/bin/curl -X POST "$(cat ${config.sops.secrets.pamWebhook.path})" -H "Content-Type: application/json" --data "$JSON_DATA"
            fi
          '';
      in
      {
        control = "optional";
        modulePath = "pam_exec.so";
        args = [ (toString webhookTrigger) ];
        order = 999999;
      };
  };
}
