{ pkgs, inputs, ... }:
let
  paper =
    pkgs.callPackage "${inputs.nixpkgs}/pkgs/games/papermc/derivation.nix" {
      version = "1.21.8-11";
      hash = "sha256-lFfRJ578wglOgYyssvF2cNlHnl9rTqJRfrk6aj+s5R8=";
    };
in {
  services.minecraft-server = {
    enable = true;
    package = paper;
    eula = true;
  };

  networking.firewall.allowedTCPPorts = [ 25565 25585 ];
}
