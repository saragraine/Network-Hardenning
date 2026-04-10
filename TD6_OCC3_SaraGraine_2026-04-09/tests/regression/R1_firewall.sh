#!/usr/bin/env bash
set -u

OUTDIR="${1:?Usage: $0 <outdir>}"
OUTFILE="$OUTDIR/R1_firewall.txt"
TARGET="10.10.20.10"

exec > >(tee "$OUTFILE") 2>&1

echo "=== R1_firewall ==="
echo "What it tests: allowed HTTPS flow and blocked forbidden port"
echo "Expected result: 443 works; 22 fails"
echo "Timestamp: $(date)"
echo

echo "--- Positive test: HTTPS to $TARGET:443 ---"
curl -kI --max-time 5 "https://$TARGET"
POS_RC=$?
echo "Positive return code: $POS_RC"
echo

echo "--- Negative test: TCP/22 to $TARGET ---"
nc -vz -w 3 "$TARGET" 22
NEG_RC=$?
echo "Negative return code: $NEG_RC"
echo

if [ $POS_RC -eq 0 ] && [ $NEG_RC -ne 0 ]; then
  echo "RESULT: PASS"
  exit 0
else
  echo "RESULT: FAIL"
  exit 1
fi
