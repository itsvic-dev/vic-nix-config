# intraweb.nix entrypoint - simply imports everything else
{
  imports = [
    ./netns.nix
  ];
}
