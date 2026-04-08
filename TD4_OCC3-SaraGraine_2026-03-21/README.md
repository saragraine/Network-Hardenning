````md
# TD4 — TLS Audit and Hardening with Nginx

## Overview

This lab focuses on auditing and hardening a TLS configuration on an Nginx web server. The goal was to start from a deliberately weak HTTPS setup, identify the main problems, improve the configuration, and then verify the result with repeatable tests.

The work is organized as an evidence pack. That means every important claim in the report is backed by a configuration file, a command output, or a log extract saved in the repository.

## Lab topology

The lab is based on four virtual machines:

| VM | Role | IP |
|---|---|---|
| `client` | testing and audit machine | `10.10.10.10` |
| `gw-fw` | gateway / firewall | `10.10.10.1 / 10.10.20.1` |
| `srv-web` | nginx web server with TLS | `10.10.20.10` |
| `sensor-ids` | IDS / optional packet capture | `10.10.20.50` |

Network segmentation:
- LAN: `10.10.10.0/24`
- DMZ: `10.10.20.0/24`

## What was done

The lab was completed in five main phases:

1. Deploy a weak TLS configuration on Nginx
2. Run a baseline TLS audit from the client VM
3. Harden the Nginx TLS settings
4. Re-run the same tests and compare the results
5. Add simple edge controls such as rate limiting and request filtering

## Repository contents

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
````

## Main tools used

* `nginx`
* `openssl`
* `curl`
* `testssl.sh`
* `tcpdump`
* `nftables`

## Reproduction summary

### 1. Weak baseline

A self-signed certificate was generated on `srv-web`, and Nginx was configured with older TLS settings, including TLS 1.0 and TLS 1.1.

### 2. Baseline audit

From `client`, the service was tested with:

* `openssl s_client`
* `curl -vk`
* `testssl.sh`

The outputs were saved in `evidence/before/`.

### 3. Hardening

The TLS configuration was updated to:

* allow only TLS 1.2 and TLS 1.3
* use stronger cipher suites
* enable HSTS
* improve server-side cipher control

The final config is saved in `config/nginx_after.conf`.

### 4. Validation

The same tests were repeated after hardening, and the results were saved in `evidence/after/`.

### 5. Edge controls

Two extra protections were added:

* rate limiting on `/api`
* request filtering for suspicious requests

These tests and logs are also included in `evidence/after/`.

## Important note

The certificate is self-signed because this is a lab environment. This is acceptable for testing, but it would not be appropriate for production without a proper CA-based trust model.

## Result

The final configuration removed support for legacy TLS versions, reduced the accepted cipher surface, enabled HSTS, and added basic reverse-proxy protections. The full analysis is in `report.md`.

````

