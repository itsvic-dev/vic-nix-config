{ config, lib, ... }: {
  config = lib.mkIf config.vic-nix.desktop.enable {
    boot = {
      plymouth.enable = true;
      initrd.systemd.enable = true;

      consoleLogLevel = 0;
      initrd.verbose = false;
      kernelParams = [
        "quiet"
        "splash"
        "boot.shell_on_fail"
        "loglevel=3"
        "rd.systemd.show_status=false"
        "rd.udev.log_level=3"
        "udev.log_priority=3"
      ];
    };
  };
}
