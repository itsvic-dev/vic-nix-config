# vic-nix-config

## Remote deployment

Use `deploy operation host`, where `operation` is the operation passed to `switch-to-configuration`, and `host` is the target host.

## ISO

To build the ISO profile, run:

```sh
nom build .\#nixosConfigurations.x64iso.config.system.build.isoImage
```
