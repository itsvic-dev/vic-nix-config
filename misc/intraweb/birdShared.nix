{ lib, ... }:
{
  options.iw.birdSharedConfig = lib.mkOption { type = lib.types.str; };
  config.iw.birdSharedConfig = ''
    function is_self_net() -> bool {
       return net ~ OWNNET;
    }

    protocol device {
       scan time 60;
    }

    protocol kernel {
      scan time 20;

      ipv4 {
        import none;
        export filter {
          if source = RTS_STATIC then reject;
          krt_prefsrc = OWNIP;
          accept;
        };
      };
    }

    protocol static {
      route OWNNET reject;

      ipv4 {
        import all;
        export none;
      };
    }

    function is_valid_network() -> bool {
      return net ~ [
        10.0.0.0/8{24,32}
      ];
    }

    template bgp iwpeers {
      local as OWNAS;

      ipv4 {
        import filter {
          if is_valid_network() && !is_self_net() then accept;
          else reject;
        };

        export filter {
          if is_valid_network() && source ~ [RTS_STATIC, RTS_BGP] then accept;
          else reject;
        };
        import limit 9000 action block;
      };
    }
  '';
}
