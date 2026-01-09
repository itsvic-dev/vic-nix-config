{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
let
  cfg = config.iw.networking.namespaces;

  namespaceOpts =
    { ... }:
    {
      options = {
        dummy = mkOption {
          description = "Whether to enable the dummy interface.";
          default = true;
          type = types.bool;
        };

        ipAddress = mkOption {
          description = "The IP address to use for the dummy interface of this namespace.";
          example = "10.10.0.0/16";
          type = types.str;
        };

        ifname = mkOption {
          description = "The name of the dummy interface.";
          default = "dummy";
          example = "du0";
          type = types.str;
        };
      };
    };
in
{
  options.iw.networking.namespaces = mkOption {
    description = ''
      Network namespaces.

      They will be created under /run/netns, and get a `netns-{name}.service` unit.
    '';
    default = { };
    type = with types; attrsOf (submodule namespaceOpts);
  };

  config = {
    systemd.services = lib.mapAttrs' (
      name: values:
      let
        escapedName = lib.escapeShellArg name;
      in
      lib.nameValuePair ("netns-" + name) {
        description = "Network namespace ${name}";
        wantedBy = [ "network.target" ];

        serviceConfig = {
          Type = "oneshot";
          User = "root";
          RemainAfterExit = true;
          ExecStop = "${pkgs.iproute2}/bin/ip netns del ${escapedName}";
        };

        path = [ pkgs.iproute2 ];

        script = ''
          if [ ! -f /run/netns/${escapedName} ]; then
            ip netns add ${escapedName}
          fi
          ip -n ${escapedName} link set dev lo up
          ${optionalString values.dummy ''
            ip -n ${escapedName} link add dev ${escapeShellArg values.ifname} type dummy
            ip -n ${escapedName} addr add ${escapeShellArg values.ipAddress} dev ${escapeShellArg values.ifname}
            ip -n ${escapedName} link set up dev ${escapeShellArg values.ifname}
          ''}
        '';
      }
    ) cfg;
  };
}
