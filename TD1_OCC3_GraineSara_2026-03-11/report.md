# Report

## Packet capture analysis

### Observation 1
- Timestamp range:2026-03-11 09:04:50 --> 09:04:56
- Flow matrix row reference:F01
- What you observed:SSH traffic from client-kali to srv-webover TCP port 22
- Why it matters for hardening: admin access to srv-web is possible from the LAN, whici increases attack surface.
- Proposed control:Restrict SSH to admins
- Evidence pointer: packets 236,237, 238

### Observation 2
- Timestamp range:2026-03-11 09:02:08 --> 09:02:19
- Flow matrix row reference:F04
- What you observed:HTTP traffic from clien-kali to srv-web over TCP port 80.
- Why it matters for hardening: It shows that it is reachable across the trust boundary and that it is active.
- Proposed control:Keep it allowed only in the required source. Consider redirecting HTTPS
- Evidence pointer:5, 7, 19, 21

### Observation 3
- Timestamp range:2026-03-11 09:03:11
- Flow matrix row reference:F05
- What you observed:ICMP echo and replly traffic.
- Why it matters for hardening:Good for troobleshooting and connectivity tests, but unrestricted ICMP can help attackers map reachable hosts.
- Proposed control:Restric by source zone
- Evidence point: 29 --> 65
 
### Observation 4
- Timestamp range: same as obsr 1
- Flow matrix row reference:1
- What you observed: http filter returns traffic while tls returns none. The http exchange is unencrypted traffic.
- Why it matters for hardening: Unencrypted web traffic can expose requests and content to anyone who can read the segment.
- Proposed control:add HTTPS on port 443 with TLS and reduce/redirect plain HTTP
- Evidence pointer:same as obsr 1

### Observation 5
- Timestamp range: 0
- Flow matrix row reference:F02
- What you observed:No DNS exchange
- Why it matters for hardening:It is not required
- Proposed control:remove or keep in review DNS until a real service needs it.
- Evidence pointer:


## Top 10 risks

- `srv-web` can be reached from the LAN on port 80.
- `srv-web` can also be reached on port 22 for SSH.
- The web service is using HTTP, not HTTPS.
- The firewall policy is not clearly enforced yet.
- A compromised DMZ server could be used to move further in the lab.
- Admin access and normal application access are mixed together.
- ICMP may be allowed more broadly than necessary.
- Monitoring access to `sensor-ids` is not clearly defined.
- No firewall deny logging has been shown.
- Some extra local services are running on infrastructure hosts.

## Top 5 quick wins

- Keep only the flows that are really needed.
- Restrict or disable SSH on `srv-web`.
- Add clear firewall rules on `gw-fw`.
- Turn on deny logging at the firewall.
- Move the web service to HTTPS if possible.
