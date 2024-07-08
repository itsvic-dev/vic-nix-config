{ inputs, ... }:
{
  nix = {
    registry = {
      nixpkgs.flake = inputs.nixpkgs;
    };

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
