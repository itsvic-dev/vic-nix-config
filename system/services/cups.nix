{ pkgs, config, ... }: {
  services.printing = {
    enable = config.vic-nix.desktop.enable;
    drivers = [ pkgs.hplip ];
  };
}
