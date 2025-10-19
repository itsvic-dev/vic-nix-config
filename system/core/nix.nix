{ inputs, pkgs, ... }: {
  nix = {
    # pin system nixpkgs to the flake input
    registry = { nixpkgs.flake = inputs.nixpkgs; };
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      trusted-users =
        [ "root" (if pkgs.stdenv.isLinux then "@wheel" else "@admin") ];
    };

    optimise.automatic = true;
  };

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [ (import ../pkgs) ];
  };
}
