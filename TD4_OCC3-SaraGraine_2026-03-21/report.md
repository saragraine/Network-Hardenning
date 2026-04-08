# TD4 Report

## 1. Threat model

Asset: the web service exposed by srv-web at 10.10.20.10:8443.

Adversary: an on-path attacker on the lab LAN/DMZ or a remote scanner probing the service.

Main threats:
- downgrade to TLS 1.0 or TLS 1.1
- negotiation of weak cipher suites
- certificate warnings or trust issues caused by self-signed deployment
- missing reverse-proxy controls for burst traffic or suspicious requests

Security goals:
- allow only TLS 1.2 and TLS 1.3
- prefer forward-secret modern cipher suites
- document the certificate trust model
- enforce basic edge controls
- prove changes with before/after evidence

## 2. TLS profile

The hardened profile restricts the service to TLS 1.2 and TLS 1.3 only. Legacy versions TLS 1.0 and TLS 1.1 are removed. The cipher strategy is restricted to forward-secret modern suites centered on AES-GCM and ChaCha20. The certificate remains self-signed for the lab and this is documented as part of the trust model. HSTS is enabled with a short max-age of 300 seconds to demonstrate the mechanism while keeping rollback easy in a lab environment.

## 3. Before / after comparison

| Item | Before | After | Evidence |
|---|---|---|---|
| TLS 1.0 | offered | not offered | evidence/before/openssl_tls1.txt, evidence/after/openssl_tls1.txt |
| TLS 1.1 | offered | not offered | evidence/before/openssl_tls1_1.txt, evidence/after/openssl_tls1_1.txt |
| TLS 1.2 | offered | offered | evidence/before/openssl_tls1_2.txt, evidence/after/openssl_tls1_2.txt |
| HSTS | absent | enabled | evidence/before/headers.txt, evidence/after/headers.txt |
| Certificate model | self-signed | self-signed | config/cert_info_before.txt, config/cert_info_after.txt |
| Config posture | weak baseline | hardened profile | config/nginx_before.conf, config/nginx_after.conf |

## 4. Edge controls

Rate limiting was applied to /api using limit_req_zone and limit_req. Burst traffic generated from the client VM caused limiting responses and demonstrated a basic availability control.

Request filtering was applied by rejecting invalid Host headers and blocking suspicious query-string patterns on /search. Crafted malicious-looking requests returned blocking responses while clean requests remained allowed.

Evidence:
- config/nginx_after.conf
- evidence/after/rate_limit_test.txt
- evidence/after/filter_test.txt
- evidence/after/filter_test_host.txt
- evidence/after/nginx_access_log_rate.txt
- evidence/after/nginx_access_log_filter.txt

## 5. Triage note

The observed events were generated intentionally from the client VM to validate edge protections. Repeated requests to /api triggered rate limiting. Separate crafted requests to /search and requests with an invalid Host header triggered blocking behavior. In a real environment, these signals could indicate scanning or low-effort abuse.

Fields used for triage:
- source IP
- timestamp
- path
- HTTP status code

Log excerpt:
Paste one exact line here from evidence/after/nginx_access_log_filter.txt or evidence/after/nginx_access_log_rate.txt.

Classification:
Benign in the lab because the source and purpose were known. In a real SOC, the same activity would require correlation and possible source blocking.

## 6. Residual risks

The certificate is self-signed and unsuitable for production. Expiry monitoring is manual. The request filtering is intentionally simple and not equivalent to a full WAF. Rate-limiting thresholds may require tuning to avoid blocking legitimate traffic.
