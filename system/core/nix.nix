{ lib, inputs, config, pkgs, ... }: {
  nix = {
    # pin system nixpkgs to the flake input
    registry = { nixpkgs.flake = inputs.nixpkgs; };
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    settings = lib.mkMerge [
      {
        experimental-features = [ "nix-command" "flakes" ];
        trusted-users =
          [ "root" (if pkgs.stdenv.isLinux then "@wheel" else "@admin") ];
      }

      (lib.mkIf (!config.vic-nix.noSecrets) {
        substituters = [ "https://cache.vic" ];

        trusted-public-keys =
          [ "cache.vic:CnhOE+6KqHwCPD+x6Tbv0wJsh2LmpBqxOd3Ze+3kxOk=" ];
      })
    ];

    optimise.automatic = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../pkgs) ];
  };
}
