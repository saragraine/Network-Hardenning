# Failure modes

## FM-01 Locked out of SSH
Symptom: no access after modifying sshd_config.
Fix: keep a console open and validate with `sshd -t`.

## FM-02 Password auth still enabled
Symptom: password login remains possible.
Fix: check `/etc/ssh/sshd_config.d/50-cloud-init.conf`.

## FM-03 IKEv2 negotiation fails
Symptom: `ipsec statusall` shows no SA.
Fix: verify PSK, left/right, subnets, and logs.

## FM-04 VPN up but no traffic
Symptom: SA established but ping fails.
Fix: verify static routes, ip_forward, and firewall rules.

## FM-05 Proposal mismatch
Symptom: NO_PROPOSAL_CHOSEN.
Fix: align `ike=` and `esp=` exactly on both sides.

## FM-06 WAN attachment issue
Symptom: gateways cannot reach each other on 10.10.99.0/24.
Fix: verify VirtualBox adapters and the exact internal network name `NH-WAN`.
EOF
