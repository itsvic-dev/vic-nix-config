{ pkgs, ... }:
{
    nixpkgs.hostPlatform = "aarch64-darwin";

    fonts.packages = with pkgs; [ nerd-fonts.jetbrains-mono ];

    environment.systemPackages = with pkgs; [ nixfmt-classic gnupg ];

    programs.gnupg.agent.enable = true;
}
