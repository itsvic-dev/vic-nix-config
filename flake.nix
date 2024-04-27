{
  description = "vic's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland = {
      url = "github:hyprwm/Hyprland";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      hyprland,
      kmonad,
      ...
    }:
    {
      nixosConfigurations = {
        "e6nix" = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };

          modules = [
            kmonad.nixosModules.default
            hyprland.nixosModules.default
            ./cachix.nix

            ./configuration.nix

            ./hw/base.nix
            ./hw/nvidia.nix

            ./modules/hddbackup.nix
            ./modules/ptero.nix
          ];
        };
      };
    };
}
