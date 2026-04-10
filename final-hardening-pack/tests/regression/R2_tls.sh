#!/usr/bin/env bash
set -u

OUTDIR="${1:?Usage: $0 <outdir>}"
OUTFILE="$OUTDIR/R2_tls.txt"
TARGET="10.10.20.10:443"
SNI="10.10.20.10"

exec > >(tee "$OUTFILE") 2>&1

echo "=== R2_tls ==="
echo "What it tests: TLS handshake sanity and certificate/protocol visibility"
echo "Expected result: successful handshake with hardened TLS settings"
echo "Timestamp: $(date)"
echo

echo "--- openssl s_client ---"
echo | openssl s_client -connect "$TARGET" -servername "$SNI"
RC=$?
echo
echo "OpenSSL return code: $RC"
echo

if [ $RC -eq 0 ]; then
  echo "RESULT: PASS"
  exit 0
else
  echo "RESULT: FAIL"
  exit 1
fi
