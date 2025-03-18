inputs@{ nixpkgs, nix-darwin, home-manager, ... }: {
  "Victors-MacBook-Pro" = nix-darwin.lib.darwinSystem {
    modules = [
      ./core
      ../system/options.nix

      home-manager.darwinModules.home-manager

      ../home
      ./machines/mbp
    ];
    specialArgs = { inherit inputs; };
  };
}
