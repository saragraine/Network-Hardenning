
# TD5 GroupX 2026-04-09

## Reused original VMs
- gw-fw = siteA-gw
- client-kali = siteA-client
- gw-fw-b = siteB-gw
- srv-web = siteB-srv
- sensor-ids = optional for WAN/DMZ capture

## Topology
### Site A
- gw-fw: 10.10.10.1/24 (LAN), 10.10.99.1/24 (WAN)
- client-kali: 10.10.10.10/24

### Site B
- gw-fw-b: 10.10.20.1/24 (DMZ), 10.10.99.2/24 (WAN)
- srv-web: 10.10.20.10/24

## Networks
- NH-LAN: 10.10.10.0/24
- NH-DMZ: 10.10.20.0/24
- NH-WAN: 10.10.99.0/24

## Objective
- Harden SSH on srv-web
- Build an IKEv2 IPsec tunnel between gw-fw and gw-fw-b
- Provide proof through configs, tests, logs, and IPsec status
