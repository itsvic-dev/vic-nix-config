{
  description = "vic's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    vncpy = {
      url = "github:itsvic-dev/vncpy";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bob-website = {
      url = "github:bob-discord-bot/website";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ nixpkgs, disko, ... }:
    let
      defineShell =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
          deployOn = pkgs.callPackage ./misc/deploy.nix { };
        in
        with pkgs;
        mkShell {
          buildInputs = [
            sops
            age
            deployOn
            disko.packages.${system}.disko
          ];
        };
    in
    {
      nixosConfigurations = import ./system inputs;

      devShells = {
        x86_64-linux.default = defineShell "x86_64-linux";
        aarch64-linux.default = defineShell "aarch64-linux";
      };
    };
}
