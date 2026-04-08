# TD4 TLS Audit and Hardening

## Lab topology
- client: 10.10.10.10
- srv-web: 10.10.20.10
- service: https://10.10.20.10:8443

## Reproduction
1. Deploy weak baseline on srv-web with native nginx.
2. Generate a self-signed certificate.
3. Run before scans from client.
4. Harden TLS settings and add edge controls.
5. Run after scans from client.
6. Test rate limiting and filtering.
7. Collect logs and complete the report.

## Main deliverables
- report.md
- config/nginx_before.conf
- config/nginx_after.conf
- config/change_log.md
- config/cert_info_before.txt
- config/cert_info_after.txt
- evidence/before/
- evidence/after/
- tests/TEST_CARDS.md
- appendix/failure_modes.md
- appendix/triage.md

## Note
The certificate is self-signed for the lab trust model. No private key is included in the repo.
