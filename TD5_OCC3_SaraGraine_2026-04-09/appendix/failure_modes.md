# Failure modes

## FM-01 Locked out of SSH
Symptôme: plus d'accès après modification de sshd_config.
Fix: garder une console ouverte, valider avec `sshd -t`.

## FM-02 Password auth still enabled
Symptôme: login par mot de passe encore possible.
Fix: vérifier `/etc/ssh/sshd_config.d/50-cloud-init.conf`.

## FM-03 IKEv2 negotiation fails
Symptôme: `ipsec statusall` sans SA.
Fix: vérifier PSK, left/right, sous-réseaux, journaux.

## FM-04 VPN up but no traffic
Symptôme: SA établie mais ping KO.
Fix: vérifier routes statiques, ip_forward, firewall.

## FM-05 Proposal mismatch
Symptôme: NO_PROPOSAL_CHOSEN.
Fix: aligner exactement `ike=` et `esp=` des deux côtés.

## FM-06 WAN attachment issue
Symptôme: les gateways ne se joignent pas sur 10.10.99.0/24.
Fix: vérifier les adapters VirtualBox et le bon réseau interne `NH-WAN`.
