# SSH hardening

Target: srv-web (10.10.20.10)

## Applied settings
- PasswordAuthentication no
- PermitRootLogin no
- AllowUsers adminX
- PubkeyAuthentication yes
- MaxAuthTries 3
- LoginGraceTime 30
- KbdInteractiveAuthentication no

## Rationale
- removes password-based access
- blocks direct root SSH login
- restricts access to a dedicated admin account
- reduces brute-force opportunities
- improves auditability
