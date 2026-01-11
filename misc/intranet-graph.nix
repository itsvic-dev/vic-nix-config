# the intranet has handy wires now, so we can generate an SVG with graphviz
{
  lib,
  intranet,
  runCommand,
  writeTextFile,
  graphviz,
}:
let
  normalizeName = builtins.replaceStrings [ "-" ] [ "_" ];

  servers = lib.filterAttrs (name: peer: !(peer ? isClient)) intranet.peers;

  serverNodes = builtins.mapAttrs (
    name: peer: "${normalizeName name}[label=\"${name}\\n${peer.ip}\"]"
  ) servers;

  connections = map (wire: "${normalizeName wire.from} -> ${normalizeName wire.to}") intranet.wires;

  intranetDot = writeTextFile {
    name = "intranet.dot";
    text = ''
      digraph net {
        ${builtins.concatStringsSep "\n" (builtins.attrValues serverNodes)}

        ${builtins.concatStringsSep "\n" connections}
      }
    '';
  };
in
runCommand "intranet.svg" { nativeBuildInputs = [ graphviz ]; } ''
  dot -Tsvg -o $out ${toString intranetDot}
''
