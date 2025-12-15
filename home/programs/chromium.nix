{
  osConfig,
  lib,
  pkgs,
  ...
}:
let
  cfg = osConfig.vic-nix.desktop;
in
{
  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.chromium = {
      enable = true;
      package =
        if pkgs.stdenv.hostPlatform.system == "x86_64-linux" then pkgs.google-chrome else pkgs.chromium;
      extensions = [
        { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
        { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
        { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
        {
          id = "fihnjjcciajhdojfnbdddfaoknhalnja";
        } # I don't care about cookies
        { id = "ijcpiojgefnkmcadacmacogglhjdjphj"; } # Shinigami Eyes
      ];
    };
  };
}
