{ pkgs, config, lib, ... }: {
  imports = [ ../../system/core/nix.nix ];

  system.stateVersion = 6;

  system.build.applications = lib.mkForce (pkgs.buildEnv {
    name = "system-applications";
    paths = config.environment.systemPackages
      ++ config.home-manager.users.vic.home.packages;
    pathsToLink = "/Applications";
  });

  # disable HM's default linking behaviour (does not play well with Launchpad or Spotlight)
  home-manager.users.vic.targets.darwin.linkApps.enable = false;

  # install ncurses (has better clear :P)
  environment.systemPackages = with pkgs; [ ncurses ];
}
