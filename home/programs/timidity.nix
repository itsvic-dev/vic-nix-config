{ osConfig, lib, pkgs, ... }:
let cfg = osConfig.vic-nix.software;
in {
  config = lib.mkIf cfg.timidity {
    programs.timidity = {
      enable = true;
      extraConfig = ''
        soundfont ${pkgs.soundfont-fluid}/share/soundfonts/FluidR3_GM2-2.sf2
      '';
    };
  };
}
