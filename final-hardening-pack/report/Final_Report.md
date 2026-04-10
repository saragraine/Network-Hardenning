# Final Report — Network Hardening Pack

## 1. Scope
This report consolidates TD1–TD5 into a final engineering-grade evidence pack. The objective is to define explicit security claims and attach each claim to configuration, regression tests, and telemetry.

## 2. Lab context
- client-kali: 10.10.10.10
- gw-fw: 10.10.10.1 / 10.10.20.1
- srv-web: 10.10.20.10
- sensor-ids: 10.10.20.50

## 3. Claims table

| Claim ID | Claim | Control location | Proof artifact | Current status |
|---|---|---|---|---|
| C1 | HTTPS should be the exposed application service for the DMZ web host. | controls/firewall/ and controls/tls_edge/ | tests/regression/results/20260410_210814/R1_firewall.txt | FAIL — TCP/443 unreachable, TCP/22 open |
| C2 | TLS should be active and negotiable on the DMZ web service. | controls/tls_edge/ | tests/regression/results/20260410_210814/R2_tls.txt | FAIL — connection refused on 443 |
| C3 | Unauthorized direct SSH access should not be usable from client-kali. | controls/remote_access/ | tests/regression/results/20260410_210814/R3_remote_access.txt | PASS at auth/policy level |
| C4 | A known validation flow should generate observable IDS evidence. | controls/ids/ | tests/regression/results/20260410_210814/R4_detection.txt | PARTIAL — traffic generated, sensor confirmation pending |

## 4. Regression methodology
The regression suite is designed as a rapid validation layer. It is not a full security assessment. Its role is to detect drift in core controls after changes.

## 5. Initial findings
The first regression run identified two material gaps:
- The web service was not reachable on TCP/443 from client-kali.
- The SSH service on TCP/22 was reachable at network level on srv-web.

This indicates either service drift, firewall drift, or both. The regression suite therefore succeeded in identifying a mismatch between intended policy and deployed state.

## 6. Evidence mapping
- R1 firewall regression: `tests/regression/results/20260410_210814/R1_firewall.txt`
- R2 TLS regression: `tests/regression/results/20260410_210814/R2_tls.txt`
- R3 remote access regression: `tests/regression/results/20260410_210814/R3_remote_access.txt`
- R4 detection regression: `tests/regression/results/20260410_210814/R4_detection.txt`

## 7. Residual risks
- Administrative surface may still be exposed on TCP/22 at the network layer.
- TLS-protected service is currently unavailable, which breaks the intended secure service publication model.
- IDS validation is incomplete until the alert excerpt is preserved as evidence.

## 8. Conclusion
At this stage, the evidence pack is already useful because it reveals configuration drift. The next step is to reconcile the deployed configuration with the intended contract, then rerun the regression suite and preserve the corrected evidence.
