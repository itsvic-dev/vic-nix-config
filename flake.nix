{
  description = "vic's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";

    hyprland = {
      url = "github:hyprwm/Hyprland";
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
          overlays = [ hyprland.overlays.default ];

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
