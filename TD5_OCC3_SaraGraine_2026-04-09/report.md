
# TD5 Report — Secure Remote Access: SSH Hardening and Site-to-Site IPsec VPN

## 1. Introduction

This lab focused on securing administrative access across two sites. The work was split into two parts. The first part hardened SSH access on the target server so that remote administration no longer relied on passwords or unrestricted user access. The second part introduced a site-to-site IPsec tunnel so that traffic between the two sites was no longer exposed on the WAN segment.

The objective was not simply to “make SSH secure” or to “turn on a VPN”. The real objective was to translate a security policy into an actual technical configuration and then verify that the resulting behavior matched the intended design.

## 2. Lab topology

The original lab machines were reused and adapted to a two-site layout.

### Site A
- `client-kali` — admin workstation — `10.10.10.10/24`
- `gw-fw` — gateway — `10.10.10.1/24` and `10.10.99.1/24`

### Site B
- `srv-web` — managed server — `10.10.20.10/24`
- `gw-fw-b` — gateway — `10.10.20.1/24` and `10.10.99.2/24`

### Networks
- LAN: `10.10.10.0/24`
- DMZ: `10.10.20.0/24`
- WAN: `10.10.99.0/24`

The WAN segment connected the two gateways. Static routes and IP forwarding were enabled so that both sites could exchange traffic before the IPsec phase.

## 3. Threat model

The protected asset in this lab was remote administrative access to the server located on Site B. Two classes of threats were considered.

The first was direct compromise of SSH access through password guessing, weak account hygiene, or unrestricted login privileges. The second was interception or manipulation of traffic crossing the inter-site WAN segment.

From that perspective, the security goals were straightforward:

- only the designated administrator should be able to connect to the server over SSH
- password-based SSH authentication should be disabled
- direct root login should be blocked
- traffic between Site A and Site B should be encrypted and integrity protected
- the VPN should cover only the intended subnets and not create a broad full-tunnel path
- authentication and connection events should be observable in logs

## 4. SSH hardening

The target of the SSH hardening phase was `srv-web`. A dedicated administrative account named `adminX` was created specifically for remote management. An Ed25519 key pair was generated on `client-kali`, and the public key was installed for that user.

Before disabling passwords, key-based access was tested successfully. Only after this validation step was the SSH configuration tightened.

The final SSH posture was based on the following settings:

- `PasswordAuthentication no`
- `PermitRootLogin no`
- `AllowUsers adminX`
- `PubkeyAuthentication yes`
- `MaxAuthTries 3`
- `LoginGraceTime 30`
- `KbdInteractiveAuthentication no`

An additional issue was discovered during this phase. Even after updating the main `sshd_config` file, password login remained possible because `/etc/ssh/sshd_config.d/50-cloud-init.conf` still contained `PasswordAuthentication yes`. This override had to be corrected before the hardening became effective. This was an important reminder that the effective SSH policy may be distributed across multiple files.

Once the override was fixed and the service restarted, the expected behavior was obtained:

- `adminX` could connect using the configured key
- password-only authentication failed
- root login failed

This phase provided both configuration proof and behavioral proof.

## 5. IPsec site-to-site tunnel

The second part of the lab secured the inter-site path between `gw-fw` and `gw-fw-b` using strongSwan with IKEv2.

The chosen design was intentionally narrow in scope. The tunnel was defined only for traffic between the Site A LAN and the Site B DMZ:

- `10.10.10.0/24`
- `10.10.20.0/24`

This prevented the configuration from becoming an unintended full-tunnel design.

The deployed profile used PSK authentication because it was sufficient for a controlled lab exercise. In a production environment, certificate-based authentication would be the preferred approach because it scales better and avoids the weaknesses associated with shared secrets.

The resulting design on both gateways used:

- IKEv2
- AES-256
- SHA-256
- MODP2048
- explicit subnet scoping through `leftsubnet` and `rightsubnet`

After correcting early WAN misconfiguration issues, the tunnel was successfully established and traffic between both sites continued to function across the protected path.

## 6. Verification approach

Validation was performed at several layers rather than treating the lab as a single binary success or failure.

Before IPsec, the following had to work:

- client-to-gateway connectivity on Site A
- gateway-to-gateway connectivity on the WAN
- inter-site reachability from `client-kali` to `srv-web`

For SSH, three essential tests were used:

- successful key-based login for `adminX`
- failed password-based login
- failed root login

For IPsec, validation included:

- checking `ipsec statusall` for active SAs
- verifying continued inter-site reachability after activation
- confirming that the tunnel scope matched the intended subnets

This approach reduced ambiguity. Instead of assuming that a feature was working because a service was running, each claim was tied to observable behavior.

## 7. Main difficulties encountered

The most significant problems were not caused by cryptography or by strongSwan itself. They came from the lower layers.

The first major issue was incorrect WAN addressing inherited from the previous lab setup. One gateway still had an address associated with the old DMZ layout, which prevented the two gateways from communicating correctly over the WAN segment.

The second issue was a troubleshooting mistake: IPsec debugging began before the underlying WAN path had been fully validated. This caused time to be spent at the wrong layer.

Another issue came from residual policies and stale routing. During troubleshooting, static routes and leftover xfrm state created inconsistent behavior and made it less obvious whether traffic was following the intended path.

Finally, SSH hardening was briefly undermined by a cloud-init include file that silently re-enabled password authentication. This was resolved once the override file was identified and corrected.

These issues are documented in more detail in `appendix/failure_modes.md`.

## 8. Results

The final result satisfied the main objectives of the lab.

On the SSH side:
- access was limited to `adminX`
- key-based login worked
- password authentication was disabled
- root login was blocked
- log evidence was available

On the VPN side:
- the two gateways established an IKEv2 site-to-site tunnel
- the tunnel was scoped to the intended subnets only
- communication between Site A and Site B remained operational
- the design was aligned with the intended security policy

## 9. Residual risks and limits

Although the lab reached its objectives, several limits remain.

The use of a PSK is acceptable in a lab but would not be the preferred long-term design in production. Certificate-based authentication would improve trust management and reduce operational risk.

SSH access still depends on proper handling of the private key on the client side. A stolen private key would remain a major risk, especially if it were not protected by a passphrase or additional controls.

The deployment also does not include MFA, host posture validation, or a broader access-control layer around the administrative workflow.

## 10. Conclusion

This lab showed that secure remote access is not a single feature but a chain of dependencies. SSH hardening without transport protection leaves inter-site traffic exposed. A VPN without scoped access and clear administrative policy still leaves room for abuse. And neither works reliably if the underlying network is misconfigured.

The most useful outcome of the exercise was not only the final working setup, but the ability to explain exactly why access succeeded in some cases, why it failed in others, and where that behavior could be proven in the system.
