{ config, lib, ... }:
let
  cfg = config.vic-nix.desktop;
in
{
  config = lib.mkIf cfg.enable {
    users.groups.uinput = { };

    services.kmonad = {
      enable = true;
      keyboards = {
        thor300tkl = {
          device = "/dev/input/by-id/usb-SINO_WEALTH_Mechanical_Keyboard-if01-event-kbd";
          defcfg.enable = true;
          defcfg.fallthrough = true;
          config = ''
            (defsrc
              q  w  e  r  t  y  u  i  o  p
              a  s  d  f  g  h  j  k  l  ;
              z  x  c  v  b  n  m
            )
            (deflayer colemak_dh
              q  w  f  p  b  j  l  u  y  ;
              a  r  s  t  g  m  n  e  i  o
              x  c  d  v  z  k  h
            )
          '';
        };
      };
    };

    services.udev.extraRules = ''
      # KMonad user access to /dev/uinput
      KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
    '';
  };
}
