# Final Hardening Pack

## Purpose
This repository consolidates TD1–TD5 into a reproducible final security hardening pack with:
- explicit security claims,
- regression tests,
- evidence artifacts,
- executive and engineering reporting.

## Scope
This repository covers:
- network reachability and segmentation,
- firewall policy validation,
- IDS / detection evidence,
- TLS hardening and validation,
- SSH hardening and remote access controls,
- VPN validation where applicable.

## Repository layout
- `architecture/` — diagrams, assumptions, reachability contract
- `controls/` — config snippets by control family
- `evidence/` — baseline and after hardening artifacts
- `tests/` — test cards and regression suite
- `report/` — final report, risk register, peer review, 30/60/90 plan
- `executive/` — manager-readable summary

## Lab assets
- client-kali: 10.10.10.10
- gw-fw: 10.10.10.1 / 10.10.20.1
- srv-web: 10.10.20.10
- sensor-ids: 10.10.20.50

## Objective
Re-prove the key security claims quickly after any change using the regression suite in `tests/regression/`.
