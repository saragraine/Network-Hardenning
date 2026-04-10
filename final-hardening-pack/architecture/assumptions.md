# Assumptions

- The lab uses the following nodes:
  - client-kali (client/test host) — 10.10.10.10
  - gw-fw (gateway/firewall) — 10.10.10.1 / 10.10.20.1
  - srv-web (DMZ web service) — 10.10.20.10
  - sensor-ids (IDS sensor) — 10.10.20.50
- The DMZ web service exposes HTTPS on TCP/443.
- Direct access to forbidden services such as SSH from unauthorized paths should fail.
- TLS hardening has been applied on srv-web.
- IDS is positioned to observe relevant DMZ or boundary traffic.
- IPsec/SSH hardening from TD5 is available, at least partially, for validation.
- All tests remain inside the lab environment.
