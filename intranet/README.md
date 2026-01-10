# Intranet overview

vic!Intranet now lives within the Intraweb (other name TBD) as AS4266660001.

## IP ranges used

- `10.21.0.0/24` - server devices
- `10.21.1.0/24` - client devices
- `fd21:f01f:ca75::/64` - Wireguard encapsulation layer
- `fd21:f01f:d4a6::/64` - GRE layer

## Interface names

- `vn-dummy` - the actual IP of the device inside the net
- `vn-wg-HOST` - the Wireguard tunnel encapsulating the GRE tunnel
- `vn-gre-HOST` - the GRE tunnel connecting two hosts together
