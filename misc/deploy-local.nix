{
  writeShellApplication,
  nix-output-monitor,
  nix,
  nix-eval-jobs,
  jq,
  ...
}:
writeShellApplication {
  name = "deploy-local";
  runtimeInputs = [
    nix-output-monitor
    nix-eval-jobs
    nix
    jq
  ];

  text = ''
    set -e
    HOST="''${2:-$(hostname)}"
    OPERATION="$1"
    FLAKE=".#nixosConfigurations.$HOST.config.system.build.toplevel"

    echo "Evaluating... (this may take a while)"
    DRV_PATH="$(nix-eval-jobs --flake "$FLAKE" | jq -r .drvPath)"

    echo "Derivation: $DRV_PATH"
    nom build -o /tmp/vic-nix-rebuild "$DRV_PATH"'^*'

    OUTPUT="$(readlink /tmp/vic-nix-rebuild)"
    rm /tmp/vic-nix-rebuild
    if [[ "$OPERATION" == "switch" ]] || [[ "$OPERATION" == "boot" ]]; then
      sudo nix-env -p /nix/var/nix/profiles/system --set "$OUTPUT"
    fi
    sudo "$OUTPUT"/bin/switch-to-configuration "$OPERATION"
  '';
}
