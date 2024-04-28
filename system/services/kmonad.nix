{
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

          (deflayer colemak
            q  w  f  p  g  j  l  u  y  ;
            a  r  s  t  d  h  n  e  i  o
            z  x  c  v  b  k  m
          )
        '';
      };
    };
  };

  services.udev.extraRules = ''
    # KMonad user access to /dev/uinput
    KERNEL=="uinput", MODE="0660", GROUP="uinput", OPTIONS+="static_node=uinput"
  '';
}
