{
  writeShellApplication,
  nix-output-monitor,
  nix,
  openssh,
  nix-eval-jobs,
  jq,
  ...
}:
writeShellApplication {
  name = "deploy";
  runtimeInputs = [
    nix-output-monitor
    jq
    nix-eval-jobs
    nix
    openssh
  ];

  text = ''
    set -e
    HOST="$2"
    OPERATION="$1"
    FLAKE=".#nixosConfigurations.$HOST.config.system.build.toplevel"

    echo "Evaluating... (this may take a while)"
    DRV_PATH="$(nix-eval-jobs --flake "$FLAKE" | jq -r .drvPath)"

    echo "Derivation: $DRV_PATH"
    nom build -o /tmp/vic-nix-rebuild "$DRV_PATH"'^*'

    # copy it to the target host
    OUTPUT="$(readlink /tmp/vic-nix-rebuild)"
    nix-copy-closure -s --to "$HOST" "$OUTPUT"
    rm /tmp/vic-nix-rebuild

    # and finally, deploy it on the host
    if [[ "$OPERATION" == "switch" ]] || [[ "$OPERATION" == "boot" ]]; then
      ssh "$HOST" -- sudo nix-env -p /nix/var/nix/profiles/system --set "$OUTPUT"
    fi
    ssh "$HOST" -- sudo "$OUTPUT"/bin/switch-to-configuration "$OPERATION"
  '';
}
