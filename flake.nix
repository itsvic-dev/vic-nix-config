{
  description = "vic's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    hyprland = {
      url = "github:hyprwm/Hyprland/v0.39.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "github:kmonad/kmonad?dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      hyprland,
      kmonad,
      home-manager,
      ...
    }:
    let
      common = [
        kmonad.nixosModules.default
        hyprland.nixosModules.default
        home-manager.nixosModules.home-manager
        ./cachix.nix

        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.vic = import ./home;
            extraSpecialArgs = {
              inherit inputs;
            };
          };
        }
      ];

      defineAMD64System =
        hostname: modules:
        nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            inherit inputs;
          };

          modules = common ++ modules ++ [ ./machines/${hostname}.nix ];
        };
    in
    {
      nixosConfigurations = {
        "e6nix" = defineAMD64System "e6nix" [
          ./hw/15imh05.nix
          ./hw/nvidia.nix

          ./modules/hddbackup.nix
          ./modules/ptero.nix
        ];
      };
    };
}
