{ config, lib, ... }: {
  # we don't need network shit on servers
  config = lib.mkIf config.vic-nix.desktop.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      jack.enable = true; # needed by some audio workstation apps
    };
  };
}
