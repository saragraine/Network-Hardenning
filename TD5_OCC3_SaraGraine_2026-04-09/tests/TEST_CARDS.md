# TEST CARDS

---

## TD5-T01 — SSH password auth is disabled
Claim: SSH password authentication is refused.
Procedure: attempt login with `PubkeyAuthentication=no`.
Expected: failure with `Permission denied (publickey)`.
Evidence: evidence/ssh_tests.txt, evidence/authlog_excerpt.txt

---

## TD5-T02 — Root login via SSH is disabled
Claim: direct root SSH login is blocked.
Procedure: attempt `ssh root@10.10.20.10`.
Expected: failure.
Evidence: evidence/ssh_tests.txt

---

## TD5-T03 — Key login works for adminX
Claim: adminX can log in with a public key.
Procedure: connect with `ssh -i ~/.ssh/id_td5 adminX@10.10.20.10`.
Expected: success.
Evidence: evidence/ssh_tests.txt

---

## TD5-T04 — SSH logs are auditable
Claim: SSH logs show both accept and deny events.
Procedure: inspect `/var/log/auth.log` after the tests.
Expected: success and failure records are visible.
Evidence: evidence/authlog_excerpt.txt

---

## TD5-T05 — Site A can reach Site B
Claim: the inter-site path works.
Procedure: ping `10.10.20.10` from `client-kali`.
Expected: success.
Evidence: evidence/preflight_topology.txt

---

## TD5-T06 — Tunnel is scoped to intended subnets
Claim: the IPsec config does not define a full tunnel.
Procedure: inspect `leftsubnet` and `rightsubnet`.
Expected: only 10.10.10.0/24 <-> 10.10.20.0/24.
Evidence: config/ipsec_siteA.conf, config/ipsec_siteB.conf

---

## TD5-T07 — WAN addresses are separated from DMZ
Claim: each gateway has coherent LAN/DMZ/WAN addressing.
Procedure: verify interface IP assignments.
Expected: gw-fw = 10.10.10.1 + 10.10.99.1, gw-fw-b = 10.10.20.1 + 10.10.99.2.
Evidence: evidence/preflight_topology.txt

---

## TD5-T08 — SSH hardening resists fallback auth
Claim: cloud-init does not re-enable PasswordAuthentication.
Procedure: inspect the cloud-init override file.
Expected: `PasswordAuthentication no`.
Evidence: config/sshd_cloudinit_excerpt.txt
