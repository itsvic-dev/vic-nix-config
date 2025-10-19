{ config, pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  vic-nix = {
    desktop = {
      enable = true;
      forDev = true;
    };
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  environment.systemPackages = with pkgs; [
    nixfmt-classic
    gnupg
    rustup
    cargo-binutils
  ];

  programs.gnupg.agent.enable = true;

  sops.secrets.nixAccessTokens = {
    group = "admin";
    sopsFile = ../../../secrets/nix-auth.conf;
    format = "binary";
    mode = "0440";
  };
  nix.extraOptions = ''
    !include ${config.sops.secrets.nixAccessTokens.path}
  '';
}
