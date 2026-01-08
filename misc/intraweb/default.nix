# intraweb.nix entrypoint - simply imports everything else
{
  imports = [
    ./netns.nix
    ./birdShared.nix
  ];

  config = {
    boot.kernel.sysctl = {
      "net.ipv4.conf.all.rp_filter" = 0;
      "net.ipv4.conf.default.rp_filter" = 0;
    };
  };
}
