final: prev: {
  # set of custom pkgs, either written or updated, that havent entered nixpkgs yet
  libtorrent = with prev;
    prev.libtorrent.overrideAttrs (final: prev: rec {
      version = "0.15.3";
      src = fetchFromGitHub {
        owner = "rakshasa";
        repo = "libtorrent";
        rev = "v${version}";
        hash = "sha256-7WviN4KA236esXXCGKi+TiqRIg4hD+5EblTFqQRiRks=";
      };
    });

  rtorrent = with prev;
    prev.rtorrent.overrideAttrs (final: prev: rec {
      version = "0.15.3";
      src = fetchFromGitHub {
        owner = "rakshasa";
        repo = "rtorrent";
        rev = "v${version}";
        hash = "sha256-etaigf7lx+WAf34NPN6KmsMB5jW4woA7f3VauIZNRfM=";
      };
    });
}
