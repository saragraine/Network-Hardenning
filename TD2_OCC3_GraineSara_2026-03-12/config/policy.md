# TD2 Policy

## Zones
- LAN: `client-kali (10.10.10.10)`
- DMZ: `srv-web (10.10.20.10)`, `sensor-ids (10.10.20.50)`
- Gateway: `gw-fw (10.10.10.1 / 10.10.20.1)`

## Allow-list
- ALLOW `client-kali -> srv-web` TCP/80
- ALLOW `client-kali -> srv-web` TCP/22
- ALLOW `client-kali -> srv-web` ICMP echo
- ALLOW established/related return traffic

## Default stance
- FORWARD: DROP
- INPUT: DROP
- OUTPUT: ACCEPT

## Logging
- Log denied FORWARD traffic with `NFT_FWD_DENY`
- Log denied INPUT traffic with `NFT_IN_DENY`

## Exceptions
- Only allow rules that match the TD1 flow matrix
- Each exception needs a reason, owner, and review date
