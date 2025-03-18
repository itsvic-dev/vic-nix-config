{ osConfig, lib, pkgs, ... }: {
  config = lib.mkIf osConfig.vic-nix.desktop.enable {
    programs.mpv = {
      enable = true;
      package = if (pkgs.stdenv.isDarwin) then pkgs.mpv-unwrapped else pkgs.mpv;
      config = {
        hwdec = "auto-safe";
        vo = "gpu";
        profile = "gpu-hq";
        "gpu-context" = "wayland";
      };
    };
  };
}
