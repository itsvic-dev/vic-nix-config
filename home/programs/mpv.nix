{ osConfig, lib, pkgs, ... }: {
  config = lib.mkIf osConfig.vic-nix.desktop.enable {
    programs.mpv = {
      enable = true;
      config = {
        hwdec = "auto-safe";
        vo = "gpu";
        profile = "gpu-hq";
        "gpu-context" = "wayland";
      };
    };
  };
}
