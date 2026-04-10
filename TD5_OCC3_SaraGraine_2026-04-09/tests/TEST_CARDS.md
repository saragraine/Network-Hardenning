
## TD5-T01 — Key-based SSH login works for the authorized admin

**Claim**

The `adminX` account can access `srv-web` using the provisioned SSH key.

**Execution context**

Run from `client-kali`.

**Command**

```bash
ssh -i ~/.ssh/id_td5 adminX@10.10.20.10 "echo SSH_KEY_OK"

Expected result

The command returns:

SSH_KEY_OK

Evidence

evidence/ssh_tests.txt
TD5-T02 — Password-based SSH authentication is disabled

Claim

A user cannot log in to srv-web with password-only SSH authentication.

Execution context

Run from client-kali.

Command

ssh -o PubkeyAuthentication=no -o PreferredAuthentications=password -o BatchMode=yes adminX@10.10.20.10 "echo SHOULD_NOT_WORK"

Expected result

The connection fails with a public key related denial, for example:

Permission denied (publickey)

Evidence

evidence/ssh_tests.txt
evidence/authlog_excerpt.txt
TD5-T03 — Direct root SSH login is disabled

Claim

The server does not accept direct root login over SSH.

Execution context

Run from client-kali.

Command

ssh -i ~/.ssh/id_td5 -o BatchMode=yes root@10.10.20.10 "echo SHOULD_NOT_WORK"

Expected result

The connection is denied.

Evidence

evidence/ssh_tests.txt
TD5-T04 — SSH access is restricted to the intended user

Claim

Remote SSH access is scoped to the declared administrative account rather than being open to arbitrary users.

Execution context

Run from client-kali.

Command

ssh testuser@10.10.20.10

Expected result

The connection is refused.

Evidence

config/sshd_config_excerpt.txt
evidence/authlog_excerpt.txt
TD5-T05 — SSH authentication events are logged

Claim

The system records both successful and failed SSH authentication attempts.

Execution context

Run on srv-web.

Command

sudo tail -n 50 /var/log/auth.log

Expected result

The log contains at least:

one successful public key login for adminX
one failed authentication event

Evidence

evidence/authlog_excerpt.txt
TD5-T06 — Site A client can reach its local gateway

Claim

Basic local routing on Site A is functional.

Execution context

Run from client-kali.

Command

ping -c 4 10.10.10.1

Expected result

The gateway responds with no packet loss.

Evidence

evidence/preflight_topology.txt
TD5-T07 — WAN connectivity exists between both gateways

Claim

The two gateways can communicate directly across the WAN segment.

Execution context

Run from gw-fw.

Command

ping -c 4 10.10.99.2

Expected result

The remote WAN address responds successfully.

Evidence

evidence/preflight_topology.txt
TD5-T08 — Inter-site connectivity works before and after VPN validation

Claim

client-kali can reach srv-web across the two-site topology.

Execution context

Run from client-kali.

Command

ping -c 4 10.10.20.10

Expected result

The destination responds with no packet loss.

Evidence

evidence/preflight_topology.txt
evidence/tunnel_ping.txt
TD5-T09 — The IPsec tunnel is established

Claim

The gateways successfully negotiate and install the IPsec tunnel.

Execution context

Run on either gateway.

Command

sudo ipsec statusall

Expected result

The status output shows an established IKE SA and an installed CHILD SA for traffic between the two declared subnets.

Evidence

evidence/ipsec_status.txt
TD5-T10 — Tunnel scope is limited to the intended subnets

Claim

The IPsec configuration protects only 10.10.10.0/24 and 10.10.20.0/24, not arbitrary traffic.

Execution context

Inspect the configuration files.

Command

grep -E 'leftsubnet|rightsubnet' config/ipsec_siteA.conf config/ipsec_siteB.conf

Expected result

The configuration shows only the Site A LAN and Site B DMZ subnets.

Evidence

config/ipsec_siteA.conf
config/ipsec_siteB.conf
TD5-T11 — Inter-site traffic remains functional once the tunnel is active

Claim

The VPN protects the path without breaking connectivity.

Execution context

Run from client-kali.

Command

ping -c 4 10.10.20.10

Expected result

The destination remains reachable after tunnel establishment.

Evidence

evidence/tunnel_ping.txt
evidence/ipsec_status.txt
TD5-T12 — SSH hardening is not bypassed by cloud-init defaults

Claim

The final effective SSH behavior is not undermined by the cloud-init include file.

Execution context

Inspect the include file on srv-web.

Command

sudo cat /etc/ssh/sshd_config.d/50-cloud-init.conf

Expected result

The include file no longer re-enables password authentication.
