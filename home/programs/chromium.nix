{
  nixosConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = nixosConfig.vic-nix.desktop;
in
{
  config = lib.mkIf cfg.enable {
    # stylix theme for chromium is barely a theme and it sucks and clashes with the GTK theme
    stylix.targets.chromium.enable = false;
    programs.chromium = {
      enable = true;
      package = if pkgs.system == "x86_64-linux" then pkgs.google-chrome else pkgs.chromium;
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
        { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # I don't care about cookies
        { id = "ijcpiojgefnkmcadacmacogglhjdjphj"; } # Shinigami Eyes
      ];
    };
  };
}
