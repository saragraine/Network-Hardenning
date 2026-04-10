# SSH hardening

Target host: srv-web (10.10.20.10)

Controls applied:
- PasswordAuthentication no
- PermitRootLogin no
- AllowUsers adminX
- PubkeyAuthentication yes
- MaxAuthTries 3
- LoginGraceTime 30

Purpose:
- Disable password-based attacks
- Block direct root SSH access
- Restrict login to one admin account
- Keep authentication auditable
