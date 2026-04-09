````md
# TD3 — IDS Detection Engineering with Proof using Suricata

**Module:** Network Hardening  
**Topic:** IDS/IPS Detection Engineering and Alert Tuning  
**Tool used:** Suricata  
**Lab environment:** Isolated virtual network

---

## 1. Introduction

The objective of this lab was to deploy and validate a Suricata-based intrusion detection workflow in a segmented network. The work focused on four main aspects: confirming that the IDS sensor could observe the relevant traffic, verifying that Suricata was correctly configured and loading rules, validating both community and custom detections, and reducing repetitive alerts through basic tuning.

The lab was conducted in a controlled environment composed of a LAN, a DMZ, and an IDS sensor connected to the DMZ. All test traffic remained internal to the lab.

---

## 2. Lab Topology

The network used in this TD was composed of the following hosts:

| Host | Role | IP Address |
|---|---|---|
| client-kali | Client, traffic generator, validation host | 10.10.10.10 |
| gw-fw | Gateway / firewall | 10.10.10.1 / 10.10.20.1 |
| srv-web | Target web server in the DMZ | 10.10.20.10 |
| sensor-ids | IDS monitoring host | 10.10.20.50 |

The DMZ segment was the main monitoring target because it carried the exchanges between the gateway and the web server.

---

## 3. Objectives

The work performed in this TD aimed to:

1. Identify the correct monitoring interface on `sensor-ids`
2. Enable passive observation of DMZ traffic
3. Validate packet visibility with `tcpdump`
4. Confirm Suricata configuration and rule loading
5. Trigger a deterministic community-rule alert
6. Create and validate a custom Suricata rule
7. Perform positive and negative testing of the custom rule
8. Apply threshold-based tuning to reduce repetitive alerts
9. Collect technical evidence for the final deliverable

---

## 4. Interface Selection and Visibility Validation

### 4.1 Selected Interface

The selected interface on `sensor-ids` was:

- `enp0s3`

This interface was chosen because it was connected to the **10.10.20.0/24 DMZ network**, which carries the traffic exchanged with `srv-web`. Since the IDS had to inspect traffic traversing this segment, this was the relevant capture interface.

### 4.2 Promiscuous Mode

Promiscuous mode was enabled on the selected interface so that the sensor could capture packets not directly addressed to its own IP address.

Example command used:

```bash
sudo ip link set enp0s3 promisc on
````

### 4.3 Visibility Check

Traffic visibility was validated by generating HTTP and ICMP traffic from `client-kali` to `srv-web` and observing it on `sensor-ids` with `tcpdump`.

Example commands:

On `client-kali`:

```bash
curl -s http://10.10.20.10/ > /dev/null
ping -c 3 10.10.20.10
```

On `sensor-ids`:

```bash
sudo tcpdump -i enp0s3 -c 10 'host 10.10.20.10'
```

### 4.4 Result

The sensor successfully observed packets to and from `10.10.20.10`, confirming that the selected interface was correct and that the IDS had visibility over the DMZ traffic of interest.

---

## 5. Suricata Configuration Validation

After confirming traffic visibility, the next step was to verify that Suricata was properly configured.

The following elements were checked:

* Presence of `local.rules` in `suricata.yaml`
* Presence of the threshold configuration reference
* Definition of `HOME_NET`
* Syntax validation of the configuration
* Correct service restart after configuration checks

Example verification commands:

```bash
grep -n "rule-files" /etc/suricata/suricata.yaml
grep -n "local.rules" /etc/suricata/suricata.yaml
grep -n "threshold-file" /etc/suricata/suricata.yaml
grep -n "HOME_NET" /etc/suricata/suricata.yaml
sudo suricata -T -c /etc/suricata/suricata.yaml -i enp0s3
sudo systemctl restart suricata
sudo systemctl status suricata --no-pager
```

### Result

The configuration test completed successfully, indicating that Suricata was able to load the active configuration, including local rules and threshold settings.

---

## 6. Baseline Detection with Community Rules

To validate that the IDS was functioning with standard detection content, a deterministic scan was launched from `client-kali` toward `srv-web` using `nmap`.

Command used:

```bash
nmap -sS -sV -p 1-1000 10.10.20.10
```

Before the scan, the alert log was cleared to simplify analysis:

```bash
sudo truncate -s 0 /var/log/suricata/fast.log
sudo systemctl restart suricata
```

After the scan, alerts were inspected using:

```bash
sudo grep "Nmap" /var/log/suricata/fast.log
```

### Result

Suricata generated alerts associated with Nmap activity. This confirmed that the IDS engine was operational and that the loaded community rules were capable of detecting reconnaissance behavior in the lab.

---

## 7. Custom Rule Engineering

### 7.1 Rule Objective

A custom rule was added to detect HTTP requests targeting the `/admin` URI on the web server.

### 7.2 Rule Used

The rule used during the TD was:

```suricata
alert http $HOME_NET any -> $HOME_NET 80 (msg:"TD3 CUSTOM - HTTP request to /admin detected"; flow:to_server,established; http.uri; content:"/admin"; sid:9000001; rev:1; classtype:policy-violation;)
```

### 7.3 Rule Logic

This rule inspects HTTP traffic directed to TCP port 80 and triggers when the request URI contains `/admin`. The detection is based on the request path, not on the server response. This means the alert can still be valid even if the server returns a `404 Not Found`.

---

## 8. Custom Rule Validation

### 8.1 Positive Test

The rule was tested using a request that should match the signature:

```bash
curl -s http://10.10.20.10/admin
```

The alert log was checked using:

```bash
sudo grep "9000001" /var/log/suricata/fast.log
sudo grep "TD3 CUSTOM" /var/log/suricata/fast.log
```

### Result

The request generated an alert for SID `9000001`, confirming that the custom rule was correctly loaded and triggered as intended.

---

### 8.2 Negative Test

A second request was sent to a different URI that should not match the rule:

```bash
curl -s http://10.10.20.10/index.html
```

The number of alerts for SID `9000001` was checked before and after the request:

```bash
sudo grep -c "9000001" /var/log/suricata/fast.log
```

### Result

No new alert was added for SID `9000001` during the negative test. This confirmed that the rule was selective and did not trigger on unrelated HTTP requests.

---

## 9. Alert Tuning with Thresholds

### 9.1 Problem

During the baseline Nmap scan, repeated alerts were produced for a noisy rule, which reduced readability and increased alert volume.

A candidate noisy rule identified during the lab was:

* **SID 2024364**
* **Message:** `ET SCAN Possible Nmap User-Agent Observed`

### 9.2 Tuning Method

To reduce repeated alerts while still preserving analyst visibility, a threshold rule was applied through `/etc/suricata/threshold.config`.

Threshold entry used:

```txt
threshold gen_id 1, sig_id 2024364, type limit, track by_src, count 1, seconds 60
```

This configuration limits the alert to one occurrence per source within a 60-second period.

### 9.3 Measurement Method

The same Nmap scan was executed before and after tuning:

```bash
nmap -sS -sV -p 1-1000 10.10.20.10
```

The alert count was compared using:

```bash
sudo grep -c "2024364" /var/log/suricata/fast.log
```

### 9.4 Result

After the threshold was applied, the number of repeated alerts for SID `2024364` decreased. At least one alert remained visible, which preserved awareness of the event while reducing unnecessary repetition.

### 9.5 Interpretation

This tuning improved the signal-to-noise ratio of the IDS output. The event was still detectable, but the alert stream became more concise and easier to analyze.

---

## 10. Evidence Collected

The following files were prepared as part of the deliverable:

| File                               | Description                                               |
| ---------------------------------- | --------------------------------------------------------- |
| `commands.txt`                     | Full command history organized by phase                   |
| `config/local.rules`               | Local Suricata rule set                                   |
| `config/threshold.config`          | Threshold tuning configuration                            |
| `config/interface_selection.txt`   | Justification of the selected capture interface           |
| `evidence/visibility_proof.txt`    | `tcpdump` output showing DMZ traffic visibility           |
| `evidence/alerts_excerpt.txt`      | Alert excerpts showing community and custom detections    |
| `evidence/before_after_counts.txt` | Summary of alert count comparison before and after tuning |

These files provide proof of configuration, testing, and results.

---

## 11. Discussion

This TD demonstrated a complete IDS validation workflow in a small segmented environment. The first requirement for an IDS is visibility, and this was confirmed by selecting the correct DMZ-facing interface and validating packet capture. Once visibility was established, Suricata configuration checks ensured that the engine was operating with the intended rule set.

The use of both community and custom rules showed two complementary aspects of detection engineering. Community rules provided generic coverage for known suspicious activity such as scanning, while the custom rule illustrated how a detection can be tailored to a specific behavior of interest. The positive and negative tests were important because they showed not only that the rule fired when expected, but also that it did not fire on unrelated traffic.

The final tuning step highlighted another important aspect of IDS operation: reducing repetitive alerts without suppressing meaningful visibility. In practice, detection quality depends not only on whether alerts are generated, but also on whether those alerts remain actionable for an analyst.

---

## 12. Conclusion

The objectives of the TD were achieved. The IDS sensor was placed on the correct interface, traffic visibility on the DMZ was confirmed, Suricata configuration was validated, community and custom rules were successfully tested, and basic threshold tuning was applied to reduce alert noise.

Overall, the lab demonstrated the essential stages of IDS detection engineering:

* sensor placement and packet visibility
* configuration validation
* rule testing with controlled triggers
* positive and negative verification
* alert tuning for improved usability

The resulting evidence shows that the Suricata deployment was functional, the custom detection behaved as intended, and the tuning improved the quality of the generated alerts.

---


```
