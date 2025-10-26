{ osConfig, lib, pkgs, ... }: {
  config = lib.mkIf (osConfig.vic-nix.desktop.enable && pkgs.stdenv.isLinux) {
    programs.mpv = {
      enable = true;
      package = pkgs.mpv;
      config = {
        hwdec = "auto-safe";
        vo = "gpu";
        profile = "gpu-hq";
        "gpu-context" = "wayland";
      };
    };
  };
}
