```md
# TD4 Report — TLS Audit and Hardening with Nginx

## 1. Introduction

This lab was about testing and improving the TLS configuration of an Nginx web server. The idea was to begin with a weak HTTPS setup, observe its problems, then harden it and check whether the result matched a more secure profile.

The objective was not just to “make HTTPS work”, but to document the process clearly and keep evidence of each step. For that reason, the work was done with a before/after approach using saved command outputs, configuration files, and log extracts.

---

## 2. Lab environment

The lab used four virtual machines:

| VM Name | Role | IP Address |
|---|---|---|
| `client` | testing and audit machine | `10.10.10.10` |
| `gw-fw` | gateway / firewall | `10.10.10.1 / 10.10.20.1` |
| `srv-web` | web server running nginx | `10.10.20.10` |
| `sensor-ids` | IDS / optional monitoring | `10.10.20.50` |

The network was split into two main zones:
- LAN: `10.10.10.0/24`
- DMZ: `10.10.20.0/24`

The web service was hosted in the DMZ, and the client VM was used to test it from the LAN side.

---

## 3. Threat model

The main asset in this lab is the web service exposed by `srv-web`. The attacker model is simple: either an internal on-path attacker in the lab network or a remote scanner probing the service.

The most relevant threats were:
- downgrade to old TLS versions such as TLS 1.0 or TLS 1.1
- negotiation of weak cipher suites
- certificate warnings caused by a weak or incomplete trust setup
- lack of reverse-proxy protections against abusive or suspicious requests

The security objective was to end with a service that only offers modern TLS versions, uses stronger cipher suites with forward secrecy, documents the lab certificate model clearly, and includes basic edge protections.

---

## 4. Tools used

The following tools were used durinThe laboratory is based on a segmented virtual network composed of four virtual machines.g the lab:

- `nginx`
- `openssl s_client`
- `curl`
- `testssl.sh`
- `tcpdump`
- `nftables`

These tools were enough to deploy, test, harden, and observe the service.

---

## 5. Weak baseline deployment

A self-signed certificate was first created on `srv-web`:

```bash
openssl req -x509 -nodes -days 7 \
-newkey rsa:2048 \
-keyout server.key \
-out server.crt \
-subj "/CN=td4.local"
````

Then a deliberately weak TLS configuration was applied in Nginx:

```nginx
ssl_protocols TLSv1 TLSv1.1 TLSv1.2;
ssl_ciphers HIGH:MEDIUM:!aNULL;
```

This baseline was intentionally insecure enough to demonstrate meaningful hardening later.

### Weaknesses in the baseline

The initial configuration had several issues:

* TLS 1.0 and TLS 1.1 were still enabled
* the cipher policy was too broad
* CBC-based suites could still be accepted
* HSTS was not enabled
* forward secrecy was not fully enforced

This kind of setup is realistic for a legacy service that has never been cleaned up properly.

---

## 6. Baseline audit

The next step was to test the weak configuration from the `client` VM.

### OpenSSL test

```bash
openssl s_client -connect 10.10.20.10:8443 -tls1
```

The TLS 1.0 handshake succeeded, which confirmed that the server still accepted deprecated protocol versions.

### curl test

```bash
curl -vk https://10.10.20.10:8443
```

The HTTPS connection worked, but the verbose output confirmed that the service was still reachable with the weak baseline.

### TLS scan

```bash
./testssl.sh --fast --warnings batch https://10.10.20.10:8443
```

This scan gave a broader overview of the supported protocols and cipher behavior.

### Baseline summary

| Item            | Result      |
| --------------- | ----------- |
| TLS 1.0         | Supported   |
| TLS 1.1         | Supported   |
| TLS 1.2         | Supported   |
| Weak ciphers    | Present     |
| Forward secrecy | Partial     |
| Certificate     | Self-signed |
| HSTS            | Not enabled |

The baseline clearly exposed older protocol support and a wider cipher surface than necessary.

---

## 7. TLS hardening

Once the weak baseline had been documented, the Nginx configuration was hardened.

```nginx
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE+AESGCM:ECDHE+CHACHA20:!aNULL:!MD5:!RC4;
ssl_prefer_server_ciphers on;

add_header Strict-Transport-Security "max-age=300" always;
```

### Why these changes were made

The objective of the hardening step was to remove outdated protocol support and narrow the accepted TLS posture to modern settings.

The main improvements were:

* TLS 1.0 and TLS 1.1 were removed
* stronger cipher suites were preferred
* ECDHE-based suites were used to improve forward secrecy
* HSTS was added to force HTTPS at the browser level

This profile is consistent with the general direction recommended in NIST SP 800-52 Rev.2 and with modern TLS 1.3 practices described in RFC 8446.

---

## 8. Post-hardening audit

After applying the new configuration, the exact same tests were run again.

### Protocol testing

```bash
openssl s_client -connect 10.10.20.10:8443 -tls1
```

Result:

* handshake failed
* TLS 1.0 was rejected

```bash
openssl s_client -connect 10.10.20.10:8443 -tls1_2
```

Result:

* handshake succeeded
* a secure cipher suite was negotiated

### Comparison table

| Item            | Before      | After     |
| --------------- | ----------- | --------- |
| TLS 1.0         | Supported   | Rejected  |
| TLS 1.1         | Supported   | Rejected  |
| TLS 1.2         | Supported   | Supported |
| TLS 1.3         | Not enabled | Enabled   |
| Weak ciphers    | Present     | Removed   |
| Forward secrecy | Partial     | Enforced  |
| HSTS            | Disabled    | Enabled   |

The results show a clear improvement between the two states. The same service remained functional, but the attack surface was reduced significantly.

---

## 9. Edge security controls

After TLS hardening, two simple reverse-proxy protections were added.

### 9.1 Rate limiting

Configuration:

```nginx
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;

location /api {
    limit_req zone=api_limit burst=5 nodelay;
    return 200 "API response\n";
}
```

Test:

```bash
for i in $(seq 1 30)
do
curl -sk -o /dev/null -w "%{http_code}\n" https://10.10.20.10:8443/api
done
```

Observed result:

* the first requests returned `200`
* later requests returned `503`

This confirmed that burst traffic was being limited.

### 9.2 Request filtering

Configuration:

```nginx
if ($http_user_agent ~* "sqlmap|nikto|dirbuster") {
    return 403;
}
```

Test:

```bash
curl -k -A "sqlmap" https://10.10.20.10:8443
```

Observed result:

* normal request returned `200`
* suspicious User-Agent returned `403`

This demonstrated a basic request-filtering rule at the reverse-proxy layer.

These controls are simple and do not replace a real WAF, but they show how Nginx can enforce and log security decisions.

---

## 10. Log analysis and triage

One blocked request appeared in the logs with a format similar to:

```text
10.10.10.10 - - [date] "GET / HTTP/1.1" 403 "-" "sqlmap"
```

### Interpretation

From this line, the useful indicators are:

* source IP: `10.10.10.10`
* request path: `/`
* status code: `403`
* User-Agent: `sqlmap`

This means the request matched the filtering rule and was denied by the reverse proxy.

### Classification

In this lab, this was expected test traffic, so the activity is benign. In a real environment, the same pattern would be treated as suspicious scanning activity until proven otherwise.

### Possible response in a real SOC

* monitor whether the same source repeats the behavior
* correlate the event with IDS or firewall logs
* check whether other paths or services were targeted
* tighten or extend filtering rules if needed

---

## 11. Problems encountered during the lab

Several issues came up during the exercise:

* no Internet access at first because NAT was not configured
* the NAT interface did not immediately receive an IP address
* some confusion between `nginx.conf` and `sites-available`
* rate limiting did not work at first because the directive was placed incorrectly
* optional packet capture did not always see traffic depending on where it was launched

These problems were resolved during the lab and are part of the normal troubleshooting process in this kind of setup.

---

## 12. Project structure

```text
TD4/
├── README.md
├── report.md
├── config/
│   ├── nginx_before.conf
│   ├── nginx_after.conf
│   ├── change_log.md
│   ├── cert_info_before.txt
│   └── cert_info_after.txt
├── evidence/
│   ├── before/
│   └── after/
├── tests/
│   ├── commands.txt
│   └── TEST_CARDS.md
└── appendix/
    ├── failure_modes.md
    └── triage.md
```

---

## 13. Conclusion

This lab shows that TLS security depends heavily on configuration quality.

The initial setup was functional, but weak. It still allowed deprecated protocol versions and accepted a wider range of cipher behavior than necessary. After hardening, the service only exposed modern TLS versions, used a stricter cipher policy, enabled HSTS, and included basic edge protections.

The most important result is not just that the final setup is stronger. It is that the changes were tested, compared, and documented with evidence. That is what makes the result defensible.

---

## 14. References

* NIST SP 800-52 Rev.2 — Guidelines for the Selection, Configuration, and Use of TLS Implementations
* RFC 8446 — The Transport Layer Security (TLS) Protocol Version 1.3
* Nginx documentation
* testssl.sh documentation
