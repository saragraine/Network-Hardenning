#!/usr/bin/env bash
set -u

OUTDIR="${1:?Usage: $0 <outdir>}"
OUTFILE="$OUTDIR/R4_detection.txt"
TARGET="10.10.20.10"

exec > >(tee "$OUTFILE") 2>&1

echo "=== R4_detection ==="
echo "What it tests: generation of a known detectable flow"
echo "Expected result: test traffic generated; IDS alert must be confirmed separately on sensor"
echo "Timestamp: $(date)"
echo

echo "--- Generate simple scan/test traffic ---"
nmap -Pn -sS -p 80,443,22 "$TARGET"
GEN_RC=$?
echo "Traffic generation return code: $GEN_RC"
echo

echo "NOTE: Confirm corresponding alert/log on sensor-ids and copy excerpt into evidence/after/"
echo

if [ $GEN_RC -eq 0 ]; then
  echo "RESULT: PASS"
  exit 0
else
  echo "RESULT: FAIL"
  exit 1
fi
