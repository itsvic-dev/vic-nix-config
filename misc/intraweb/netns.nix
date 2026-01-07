{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.iw.networking.namespaces;
  ip = "${pkgs.iproute2}/bin/ip";
in
{
  options.iw.networking.namespaces = lib.mkOption {
    type = lib.types.listOf lib.types.str;
    default = [ ];
    example = lib.literalExpression ''[ "intraweb" ]'';
    description = ''
      List of network namespaces to be created on network.target.

      They will also get systemd units such as "netns-{name}.service".
    '';
  };

  config = {
    systemd.services = lib.genAttrs' cfg (
      name:
      let
        escapedName = lib.escapeShellArg name;
      in
      lib.nameValuePair ("netns-" + name) {
        restartIfChanged = false;
        stopIfChanged = false;
        wantedBy = [ "network.target" ];

        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;
          ExecStop = "${ip} netns del ${escapedName}";
        };

        script = ''
          if [ ! -f /run/netns/${escapedName} ]; then
            ${ip} netns add ${escapedName}
          fi
          ${ip} -n ${escapedName} link set dev lo up
        '';
      }
    );
  };
}
