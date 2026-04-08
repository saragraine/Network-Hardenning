# TEST CARDS

## TD4-T01 — Baseline allows legacy TLS version
Claim: The baseline endpoint offers TLS 1.0 or TLS 1.1.
Preconditions: baseline nginx config deployed.
Test:
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1_1
Expected: handshake succeeds.
Evidence: evidence/before/openssl_tls1.txt, evidence/before/openssl_tls1_1.txt

---

## TD4-T02 — After hardening, legacy TLS versions are disabled
Claim: TLS 1.0 and TLS 1.1 are rejected after hardening.
Test:
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1_1
Expected: handshake fails.
Evidence: evidence/after/openssl_tls1.txt, evidence/after/openssl_tls1_1.txt

---

## TD4-T03 — TLS 1.2 remains available
Claim: The hardened endpoint still accepts modern TLS clients.
Test:
openssl s_client -connect 10.10.20.10:8443 -servername td4.local -tls1_2
Expected: handshake succeeds.
Evidence: evidence/after/openssl_tls1_2.txt

---

## TD4-T04 — HSTS is enabled
Claim: The hardened endpoint sends Strict-Transport-Security.
Test:
curl -skI https://10.10.20.10:8443/
Expected: HSTS header present.
Evidence: evidence/after/headers.txt

---

## TD4-T05 — Rate limiting triggers on burst traffic
Claim: Burst traffic to /api triggers limiting.
Test:
for i in $(seq 1 30); do curl -sk -o /dev/null -w "%{http_code}\n" https://10.10.20.10:8443/api; done
Expected: some requests are limited.
Evidence: evidence/after/rate_limit_test.txt

---

## TD4-T06 — Suspicious request is blocked
Claim: Suspicious query string is blocked.
Test:
curl -sk "https://10.10.20.10:8443/search?q=%27%20OR%201%3D1%20--" -o /dev/null -w "%{http_code}\n"
Expected: HTTP 403.
Evidence: evidence/after/filter_test.txt

---

## TD4-T07 — Invalid Host header is blocked
Claim: Requests with an invalid Host header are rejected.
Test:
curl -sk -H "Host: evil.local" -o /dev/null -w "%{http_code}\n" https://10.10.20.10:8443/
Expected: HTTP 403.
Evidence: evidence/after/filter_test_host.txt
