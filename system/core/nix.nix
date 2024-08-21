{ inputs, ... }:
{
  nix = {
    # pin system nixpkgs to the flake input
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };
    nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      trusted-users = [
        "root"
        "@wheel"
      ];
    };
  };

  nixpkgs.config.allowUnfree = true;
}
