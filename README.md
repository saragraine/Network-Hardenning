
# Network Hardenning Coursework

## Overview

This repository contains the practical work completed for the **Network Hardening** module.  
It consolidates the different lab sessions into a single engineering-oriented evidence pack.

The objective of the coursework is not only to configure security controls, but to:

- define security requirements clearly,
- implement technical protections,
- validate them with reproducible tests,
- and preserve evidence that supports each security claim.

The work covers network segmentation, firewall filtering, intrusion detection, TLS hardening, and secure remote access.

---

## Module Scope

The coursework is structured as a progressive hardening project across multiple practical sessions:

- **TD1** — Network map and reachability contract
- **TD2** — Firewall policy design and validation
- **TD3** — IDS/IPS deployment and detection validation
- **TD4** — TLS audit and hardening with Nginx
- **TD5** — SSH hardening and secure remote access with IPsec VPN
- **TD6** — Final integration, regression testing, evidence review, and executive packaging

Each TD contributes controls, test evidence, and documentation to the final deliverable.

---

## Lab Environment

The lab is based on a segmented virtual environment with four main systems:

| Host | Role | Network | IP Address |
|---|---|---|---|
| `client-kali` | Test workstation, scanner, evidence collector | LAN | `10.10.10.10` |
| `gw-fw` | Gateway / firewall / trust boundary | LAN + DMZ | `10.10.10.1` / `10.10.20.1` |
| `srv-web` | Target web server (HTTP/HTTPS/SSH depending on TD) | DMZ | `10.10.20.10` |
| `sensor-ids` | Monitoring / IDS sensor | DMZ | `10.10.20.50` |

---

## Repository Structure

```text
Network-Hardenning/
├── README.md
├── TD1/
├── TD2/
├── TD3/
├── TD4/
├── TD5/
└── final-hardening-pack/
    ├── README.md
    ├── executive/
    ├── architecture/
    ├── controls/
    │   ├── firewall/
    │   ├── ids/
    │   ├── remote_access/
    │   ├── tls_edge/
    │   └── sdwan_zt/
    ├── evidence/
    │   ├── baseline/
    │   └── after/
    ├── tests/
    │   ├── TEST_CARDS.md
    │   └── regression/
    │       ├── run_all.sh
    │       ├── R1_firewall.sh
    │       ├── R2_tls.sh
    │       ├── R3_remote_access.sh
    │       ├── R4_detection.sh
    │       └── results/
    └── report/
        ├── Final_Report.md
        ├── Risk_Register.md
        ├── Peer_Review.md
        └── 30_60_90_Plan.md
````

---

## Coursework Objectives

The repository is designed to demonstrate the following engineering outcomes:

1. **Understand the network architecture**

   * identify assets, trust boundaries, and permitted flows,
   * formalize a reachability contract.

2. **Implement preventive controls**

   * firewall filtering,
   * service exposure reduction,
   * SSH hardening,
   * VPN-protected remote access,
   * TLS configuration hardening.

3. **Implement detective controls**

   * sensor placement,
   * alert validation,
   * traffic observation,
   * evidence preservation.

4. **Prove security claims**

   * by linking each claim to:

     * configuration,
     * a reproducible test,
     * and telemetry/log evidence.

5. **Build a regression workflow**

   * so the main claims can be revalidated quickly after any change.

---

## Summary of Practical Work

### TD1 — Network Mapping and Reachability Contract

This phase established the logical structure of the lab and documented which communications should be allowed or denied.
Deliverables typically include:

* network map,
* host inventory,
* reachability matrix,
* assumptions and trust boundaries.

### TD2 — Firewall Policy

This phase translated the intended communication policy into packet-filtering rules.
The focus was on least privilege and explicit validation.

Typical outputs:

* firewall rule set,
* test commands,
* allow/deny evidence,
* drop log excerpts.

### TD3 — Detection Engineering

This phase introduced IDS/IPS visibility and validation of detection logic.

Typical outputs:

* sensor placement,
* Suricata or IDS configuration,
* tuned detection rules,
* example alerts and logs,
* validation traffic.

### TD4 — TLS Audit and Hardening

This phase focused on securing the web service using HTTPS and modern TLS settings.

Typical outputs:

* initial weak TLS baseline,
* hardened Nginx configuration,
* certificate deployment,
* before/after audit evidence,
* protocol and cipher validation,
* log triage notes.

### TD5 — Secure Remote Access

This phase covered secure administration and site-to-site or policy-controlled remote access.

Typical outputs:

* SSH hardening,
* key-based authentication,
* restricted administrative access,
* IPsec VPN configuration,
* connectivity validation,
* remote access evidence.

### TD6 — Final Hardening Pack

This final phase consolidated the previous TDs into a professional deliverable.

Typical outputs:

* final claims table,
* regression test suite,
* engineering evidence pack,
* executive summary,
* risk register,
* peer review,
* 30/60/90 remediation plan.

---

## Final Hardening Pack

The `final-hardening-pack/` directory is the final project deliverable.

Its purpose is to convert technical work into a structured proof package.
The central idea is that every important security statement must be testable.

Examples of claims:

* only intended services are exposed,
* administrative access is restricted,
* TLS is hardened and active,
* IDS detects defined validation traffic.

Each claim should reference:

* a control location,
* a regression test,
* and a telemetry artifact.

---

## Regression Testing

A major part of the final coursework is the regression suite in:

```bash
final-hardening-pack/tests/regression/
```

### Scripts

* `run_all.sh` — runs all regression tests and stores outputs by timestamp
* `R1_firewall.sh` — validates allowed and forbidden service exposure
* `R2_tls.sh` — validates TLS availability and handshake behavior
* `R3_remote_access.sh` — validates remote administration policy
* `R4_detection.sh` — generates validation traffic and checks detection evidence

### Run the suite

```bash
cd final-hardening-pack
bash tests/regression/run_all.sh
```

### Expected behavior

* outputs are stored in:
  `tests/regression/results/<timestamp>/`
* critical failures return a non-zero exit code,
* failed tests indicate drift between intended policy and deployed state.

---

## Evidence Strategy

The coursework follows an evidence-driven method.

### Evidence categories

* **Baseline evidence**

  * what the initial state looked like before hardening

* **After evidence**

  * proof that controls were applied and validated

* **Telemetry**

  * logs, alerts, packet traces, or status outputs tied to tests

### Good evidence should be:

* reproducible,
* timestamped,
* clearly named,
* directly referenced in the report.

Examples:

* firewall test outputs,
* TLS handshake output,
* SSH access attempts,
* IDS alert excerpts,
* service status outputs.

---

## Reporting

The repository contains both technical and managerial reporting.

### Technical report

Located in:

```text
final-hardening-pack/report/Final_Report.md
```

This report documents:

* claims,
* controls,
* tests,
* evidence mapping,
* current findings,
* residual risks.

### Executive summary

Located in:

```text
final-hardening-pack/executive/Executive_Summary_1p.md
```

This summary is intended for a non-technical reader and focuses on:

* top risks,
* implemented controls,
* current security posture,
* unresolved issues,
* next actions.

### 30/60/90 plan

Located in:

```text
final-hardening-pack/report/30_60_90_Plan.md
```

This plan organizes improvements into:

* quick wins,
* medium-term architectural improvements,
* longer-term governance and automation actions.

---

## Main Security Principles Applied

Across the coursework, the following principles were used repeatedly:

* least privilege,
* deny by default,
* segmentation,
* explicit trust boundaries,
* auditable administration,
* modern cryptographic configuration,
* continuous validation through tests,
* evidence-backed reporting.

---

## Known Limitations

Depending on lab state, some controls may remain incomplete or partially validated.
Examples:

* HTTPS service may be unavailable due to service drift,
* SSH may still be reachable at TCP level while blocked by authentication policy,
* IDS validation may require manual confirmation of alert excerpts,
* some evidence may still depend on manual collection rather than automation.

These limitations should be documented honestly in the final report.

---



## Conclusion

This repository represents a progressive network hardening project built around testable claims rather than assumptions.
Its final value is not just the presence of configurations, but the ability to re-prove the security posture quickly and consistently after changes.

The final deliverable is therefore both:

* an engineering artifact for reproducibility,
* and a communication artifact for decision-making.

---
