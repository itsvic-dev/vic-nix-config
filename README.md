# vic-nix-config

## Deployment

> [!WARNING]
> This deployment method has been mostly deprecated.
> In production we now use [Hydra](https://hydra.vic) with [vic-nix-autoupdate](./system/services/autoupdate.nix).
>
> This is still useful for testing system changes. It's not very useful when bootstrapping either way though...

Use `deploy operation host`, where `operation` is the operation passed to `switch-to-configuration`, and `host` is the target host.

## Bootstrapping

If you are bootstrapping a new system, please follow these steps:

1. Set up the new machine with `{ vic-nix.noSecrets = true; }`.
2. Generate new host keys with `ssh-keygen -A`.
3. Add the new machine's public ED25519 key to `.sops.yaml` and run `sops updatekeys secrets/global.yaml`.
4. Remove `{ vic-nix.noSecrets = true; }`, **add to vic!Intranet**, commit and push.
5. Run `nixos-rebuild switch --flake github:itsvic-dev/vic-nix-config` on the target machine.
