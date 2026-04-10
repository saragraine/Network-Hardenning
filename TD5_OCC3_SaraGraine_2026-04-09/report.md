# TD5 Report — Secure Remote Access: SSH Hardening + Site-to-Site IPsec VPN

## 1. Threat model

Asset: administrative access to systems across two sites.

Adversary: external attacker on the WAN segment or compromised internal workstation.

Key threats:
- password attacks against SSH
- theft of an SSH private key
- interception of inter-site traffic if unprotected
- lateral movement if the VPN scope is too broad

Security goals:
- only the authorized admin user can log in with SSH
- password authentication is disabled
- direct root SSH login is disabled
- traffic between 10.10.10.0/24 and 10.10.20.0/24 is encrypted and integrity protected
- the tunnel is limited to the intended subnets
- successful and failed access attempts are auditable

## 2. Policy statement

Only the adminX account may administer srv-web over SSH using a public key. Password authentication is disabled. Direct root login is disabled. Traffic between Site A LAN and Site B DMZ is protected by an IKEv2 IPsec tunnel between gw-fw and gw-fw-b. The tunnel scope is limited to 10.10.10.0/24 <-> 10.10.20.0/24.

## 3. SSH configuration

See:
- config/ssh_hardening.md
- config/sshd_config_excerpt.txt

Applied controls:
- PasswordAuthentication no
- PermitRootLogin no
- AllowUsers adminX
- PubkeyAuthentication yes
- MaxAuthTries 3
- LoginGraceTime 30

## 4. IPsec configuration

See:
- config/ipsec_siteA.conf
- config/ipsec_siteB.conf
- config/ipsec.secrets

Design choices:
- IKEv2 with strongSwan
- PSK as a lab simplification
- production recommendation: certificates

Tunnel scope:
- Site A: 10.10.10.0/24
- Site B: 10.10.20.0/24

## 5. Test plan

Positive tests:
- SSH key-based login works for adminX
- IKEv2 tunnel establishes
- ping between client-kali and srv-web succeeds

Negative tests:
- SSH password login is refused
- root SSH login is refused

## 6. Telemetry proof

See:
- evidence/preflight_topology.txt
- evidence/ssh_tests.txt
- evidence/authlog_excerpt.txt
- evidence/ipsec_status.txt
- evidence/tunnel_ping.txt

## 7. Residual risks

- PSK is not suitable for production
- no SSH MFA
- no automated key rotation
- some restrictions depend on VPN availability
