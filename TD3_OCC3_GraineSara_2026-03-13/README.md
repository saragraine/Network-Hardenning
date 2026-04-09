# TD3 — IDS Detection Engineering with Suricata

This lab focused on the deployment, validation, and tuning of a Suricata-based IDS in a segmented lab network. The objective was to verify that the sensor could observe relevant traffic on the DMZ segment, confirm that Suricata was correctly loading both community and local rules, test a custom detection rule in positive and negative scenarios, and demonstrate a basic noise-reduction tuning approach using thresholds.

## Lab topology

- client-kali: 10.10.10.10
- gw-fw: 10.10.10.1 / 10.10.20.1
- srv-web: 10.10.20.10
- sensor-ids: 10.10.20.50

The IDS sensor was positioned to monitor the DMZ network where traffic between the gateway and the web server could be inspected.

## Objectives

The work completed in this TD included:

1. Identifying the correct monitoring interface on sensor-ids
2. Enabling promiscuous mode to allow passive observation of DMZ traffic
3. Validating traffic visibility with tcpdump
4. Confirming Suricata configuration and rule loading
5. Triggering a deterministic community rule using Nmap activity
6. Creating and validating a custom HTTP detection rule
7. Performing a positive and a negative test for the custom rule
8. Applying threshold-based tuning to reduce repeated alerts
9. Collecting configuration and alert evidence for submission

## Files included

- `commands.txt`  
  Reproducible command log for all phases of the TD

- `config/local.rules`  
  Local Suricata rules used during the lab

- `config/threshold.config`  
  Threshold tuning configuration used to reduce noisy alerts

- `config/interface_selection.txt`  
  Short justification of the chosen monitoring interface

- `evidence/visibility_proof.txt`  
  Packet-capture proof showing that sensor-ids could observe DMZ traffic

- `evidence/alerts_excerpt.txt`  
  Alert excerpts from Suricata showing both community-rule and custom-rule detections

- `evidence/before_after_counts.txt`  
  Summary of alert counts before and after threshold tuning

## Summary of work performed

The DMZ-facing interface on sensor-ids was identified and configured in promiscuous mode. Traffic from client-kali to srv-web was generated using HTTP requests and ICMP echo requests, then observed on the sensor using tcpdump. This confirmed that the chosen interface was appropriate for monitoring the DMZ segment.

Suricata configuration was then checked to verify that `local.rules` and the threshold configuration were referenced correctly in `suricata.yaml`. The configuration was validated using `suricata -T`, and the Suricata service was restarted.

To demonstrate baseline detection, a controlled Nmap scan was launched from client-kali to srv-web. Suricata generated alerts associated with scan activity, confirming that community rules were functioning correctly.

A custom rule was then tested to detect HTTP requests targeting `/admin`. A positive test using:

`curl http://10.10.20.10/admin`

successfully generated the custom alert with SID `9000001`. A negative test using:

`curl http://10.10.20.10/index.html`

did not generate a new alert for that SID, confirming that the rule behaved as intended.

Finally, alert noise was reduced by applying threshold tuning to a repeated Nmap-related SID. The same scan was executed before and after tuning, and the resulting alert counts were compared. The tuning reduced repeated alerts while preserving visibility of the event.

## Conclusion

This TD demonstrated a complete basic IDS workflow: sensor placement validation, traffic observation, Suricata configuration verification, rule testing, and alert tuning. The results show that the IDS was able to monitor the relevant segment, detect expected malicious or suspicious patterns, validate a local custom rule, and reduce excessive alert noise through thresholding.

## Notes

- All traffic generation was performed inside the isolated lab environment only.
- Interface names may vary depending on the VM configuration.
- Some HTTP tests may return `404 Not Found`; this does not invalidate detection if the request URI matched the Suricata rule.
