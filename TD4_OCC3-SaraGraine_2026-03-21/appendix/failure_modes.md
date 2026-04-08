# Failure modes

| ID | Failure | Symptom | Fix |
|---|---|---|---|
| FM-01 | Nginx syntax error | nginx -t fails | Fix config before reload |
| FM-02 | Wrong port | Connection refused on 8443 | Check listen directive |
| FM-03 | Hostname mismatch | TLS warnings | Use -servername td4.local and document trust model |
| FM-04 | Self-signed warning | Scanner or browser warning | Expected in lab, document it |
| FM-05 | Legacy TLS still enabled | After scan still shows TLS 1.0/1.1 | Check active config and reload nginx |
| FM-06 | Rate limit too aggressive | Too many requests blocked | Tune rate and burst |
| FM-07 | Filter false positives | Benign requests get 403 | Narrow the filter |
