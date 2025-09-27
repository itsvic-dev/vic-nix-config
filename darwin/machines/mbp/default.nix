{ pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin";

  vic-nix = {
    desktop = {
      enable = true;
      forDev = true;
    };
  };

  fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

  environment.systemPackages = with pkgs; [ nixfmt-classic gnupg rustup cargo-binutils ];

  programs.gnupg.agent.enable = true;
}
