# Intranet overview

vic!Intranet now lives within the Intraweb as AS4266660001.

## About the `vic` TLD

This TLD will be phased out in favor of the `vic.iw` domain on the Intraweb. The vic!Intranet root CA will be phased out as we shift to Intraweb ACME.

## IP ranges used

- `10.21.0.0/24` - server devices
- `10.21.1.0/24` - client devices
- `fd21:f01f:ca75::/64` - Wireguard encapsulation layer

## Interface names

- `vn-dummy` - the actual IP of the device inside the net
- `vn-wg-HOST` - the Wireguard tunnel encapsulating the GRE tunnel
- `vn-gre-HOST` - the GRE tunnel connecting two hosts together
