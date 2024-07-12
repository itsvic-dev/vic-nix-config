{
  writeShellApplication,
  nix-output-monitor,
  nix,
  openssh,
  ...
}:
writeShellApplication {
  name = "deploy";
  runtimeInputs = [
    nix-output-monitor
    nix
    openssh
  ];

  text = ''
    set -e
    HOST="$2"
    OPERATION="$1"

    # build the system configuration
    nom build -o /tmp/vic-nix-rebuild .\#nixosConfigurations."$HOST".config.system.build.toplevel

    # copy it to the target host
    DERIVATION="$(readlink /tmp/vic-nix-rebuild)"
    nix-copy-closure --to "$HOST" "$DERIVATION"
    rm /tmp/vic-nix-rebuild

    # and finally, deploy it on the host
    if [[ "$OPERATION" == "switch" ]] || [[ "$OPERATION" == "boot" ]]; then
      ssh "$HOST" -- sudo nix-env -p /nix/var/nix/profiles/system --set "$DERIVATION"
    fi
    ssh "$HOST" -- sudo "$DERIVATION"/bin/switch-to-configuration "$OPERATION"
  '';
}
