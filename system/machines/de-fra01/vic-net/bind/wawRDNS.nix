let
  # copied from nixpkgs lib
  range =
    first: last: if first > last then [ ] else builtins.genList (n: first + n) (last - first + 1);
in
builtins.concatStringsSep "\n" [
  ''
    $TTL 24h
    $ORIGIN 0.32.10.in-addr.arpa.

    @ IN SOA ns1.vic.iw. contact.itsvic.dev. (
      2026011101  ; serial
      3h          ; refresh
      1h          ; retry
      24h         ; expire
      60          ; min TTL
    )
    @     IN  NS  ns1.vic.iw.

    1     IN  PTR waw.isp.vic.iw.
  ''
]
++ (map (
  a:
  let
    b = toString a;
  in
  "${b} IN PTR 10.32.0.${b}.isp.vic.iw."
) (range 10 200))
