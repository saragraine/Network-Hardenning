# Risk Register

| ID | Risk | Impact | Likelihood | Current control | Residual risk | Next action |
|---|---|---:|---:|---|---|---|
| R1 | Unauthorized administrative access | High | Medium | SSH hardening and access restrictions | Medium | Enforce VPN-only administration and key rotation |
| R2 | TLS downgrade or weak configuration drift | High | Medium | Hardened TLS config and regression check | Medium | Add configuration review cadence |
| R3 | Firewall policy drift | High | Medium | Reachability matrix and regression tests | Medium | Add change validation checklist |
| R4 | Detection gaps or blind spots | Medium | Medium | IDS placement and alert validation | Medium | Expand rule coverage and tune signatures |
| R5 | Manual evidence collection is incomplete | Medium | Medium | Structured repository and evidence folders | Medium | Automate log collection |
