# Test Cards

## FP-CLAIM-01
- Claim: Only HTTPS reaches DMZ web from authorized client path
- Setup: firewall policy deployed; srv-web listening on 443
- Action:
  - `curl -k https://10.10.20.10`
  - `nc -vz 10.10.20.10 22`
- Expected:
  - HTTPS succeeds
  - SSH fails
- Evidence:
  - `tests/regression/results/<timestamp>/R1_firewall.txt`
- Telemetry:
  - firewall log excerpt in `evidence/after/`

## FP-CLAIM-02
- Claim: TLS configuration enforces modern protocol settings
- Setup: hardened Nginx/OpenSSL config on srv-web
- Action:
  - `openssl s_client -connect 10.10.20.10:443 -servername 10.10.20.10`
- Expected:
  - valid TLS negotiation
  - protocol aligns with hardened config
- Evidence:
  - `tests/regression/results/<timestamp>/R2_tls.txt`
- Telemetry:
  - web/TLS config snippet in `controls/tls_edge/`

## FP-CLAIM-03
- Claim: Remote administration is restricted and controlled
- Setup: SSH hardening and VPN policy from TD5
- Action:
  - attempt SSH from unauthorized path
  - attempt SSH via approved path/VPN
- Expected:
  - unauthorized path fails
  - authorized path succeeds
- Evidence:
  - `tests/regression/results/<timestamp>/R3_remote_access.txt`
- Telemetry:
  - auth or VPN logs in `evidence/after/`

## FP-CLAIM-04
- Claim: IDS detects a known test flow
- Setup: IDS active with tuned rules
- Action:
  - generate known detection traffic
- Expected:
  - alert/log entry exists
- Evidence:
  - `tests/regression/results/<timestamp>/R4_detection.txt`
- Telemetry:
  - IDS alert excerpt in `evidence/after/`
