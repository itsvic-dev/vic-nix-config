{
  programs.chromium = {
    enable = true;
    extensions = [
      { id = "nngceckbapebfimnlniiiahkandclblb"; } # Bitwarden
      { id = "eimadpbcbfnmbkopoojfekhnkhdbieeh"; } # Dark Reader
      { id = "cjpalhdlnbpafiamejdnhcphjbkeiagm"; } # uBlock Origin
      { id = "fihnjjcciajhdojfnbdddfaoknhalnja"; } # I don't care about cookies
      { id = "ijcpiojgefnkmcadacmacogglhjdjphj"; } # Shinigami Eyes
    ];
  };
}
