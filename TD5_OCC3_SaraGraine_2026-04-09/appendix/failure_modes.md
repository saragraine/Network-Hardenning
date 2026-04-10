
# Appendix — Failure Modes and Troubleshooting Notes

## Introduction

The lab did not progress in a straight line from configuration to success. Several failures appeared during the deployment, especially while adapting the previous lab topology into a two-site layout. These problems were useful because they exposed the difference between a configuration that looks correct on paper and one that actually works across interfaces, routes, and services.

The list below summarizes the main issues encountered during the work, the symptoms that made them visible, and the actions that resolved them.

---

## FM-01 — WAN interface reused with the wrong address

One of the first problems came from the fact that the existing gateway configuration still reflected the previous lab structure. Instead of carrying a WAN address, an interface was still holding an old DMZ address. As a result, the two gateways were not really connected on the intended `10.10.99.0/24` segment.

The symptom was immediate: the gateways could not reliably reach each other on the WAN, and IPsec could not start correctly because the underlying path did not exist.

The issue was fixed by flushing the stale addressing and assigning the expected WAN IPs:
- `10.10.99.1/24` on `gw-fw`
- `10.10.99.2/24` on `gw-fw-b`

---

## FM-02 — IPsec debugging started before WAN validation

At one point, troubleshooting effort focused on strongSwan before the WAN path had been fully validated. This made the problem look like an IPsec negotiation issue when the real problem was more basic: gateway-to-gateway connectivity was not stable yet.

The correction was methodological rather than technical. Connectivity checks were moved earlier in the process:
- verify interface addresses
- verify routes
- verify ping over the WAN
- only then validate IPsec

This reduced confusion and made later debugging much faster.

---

## FM-03 — Residual addressing on the cloned gateway

The cloned gateway inherited configuration remnants that did not belong to the new role. In particular, one interface briefly held overlapping or incorrect addressing, which made packet flow inconsistent and difficult to reason about.

The problem became visible when interface output showed addresses that did not match the intended design. The fix was to flush the interfaces explicitly and reapply only the required addresses.

This was a reminder that cloned systems often keep more state than expected.

---

## FM-04 — Static routes and VPN logic interfered during troubleshooting

Before the final tunnel behavior became stable, static routes used for pre-IPsec validation sometimes remained in place while VPN troubleshooting was already underway. This could make traffic appear to follow the wrong path, especially when trying to understand whether packets were being routed normally or matched by IPsec policy.

The solution was to separate the phases clearly:
- first validate routing in plain form
- then activate IPsec
- then review whether any route or policy state needed to be cleaned

This helped avoid mixing plain routed behavior with protected behavior.

---

## FM-05 — SSH hardening looked correct but password login still worked

This was one of the most instructive issues in the whole lab. The main SSH configuration file had been edited with the expected hardening directives, yet password-based login was still possible.

The root cause was an override file loaded from `/etc/ssh/sshd_config.d/50-cloud-init.conf`, which still contained `PasswordAuthentication yes`.

This meant that checking only `/etc/ssh/sshd_config` was not enough. The final fix required updating both the main configuration and the include file, then validating the daemon configuration and restarting the service.

---

## FM-06 — Service restart confusion with strongSwan

During the VPN phase, there was a moment of uncertainty around the service name used to restart strongSwan. Depending on the distribution and package layout, the expected service name was not always the one first attempted.

The correct operational approach was to rely on the installed service names actually present on the system and to use `ipsec statusall` as the functional check rather than assuming that a restart command alone proved anything.

---

## FM-07 — Debugging too high in the stack

Several of the delays in the lab came from looking too high in the stack too early. When a VPN does not establish, the instinct is often to inspect proposals, authentication, or daemon state first. In this lab, the more productive approach was to walk upward layer by layer:

1. interface addressing  
2. route correctness  
3. local and remote reachability  
4. daemon and tunnel state  
5. traffic verification

This simple ordering prevented repeated false starts.

---

## FM-08 — Misunderstanding expected post-IPsec behavior

There was also a moment where the expected result after enabling IPsec was not entirely clear. The tunnel does not replace connectivity with failure. It is supposed to preserve connectivity while changing how traffic appears on the transit path.

The correct interpretation was:

- before IPsec, connectivity works and traffic is visible normally
- after IPsec, connectivity still works, but the path is protected and the tunnel status confirms the negotiated protection

That clarification helped align the tests with the real objective.

---

## Conclusion

Most of the failures observed during TD5 were not caused by advanced cryptographic issues. They were caused by inherited configuration, interface misuse, routing ambiguity, and service overrides. In other words, the main lesson was that secure network design depends on clean fundamentals.

Once the addressing, routes, and service behavior were brought back under control, the SSH hardening and the IPsec tunnel behaved as expected.
