#!/usr/bin/env bash
set -u

OUTDIR="${1:?Usage: $0 <outdir>}"
OUTFILE="$OUTDIR/R3_remote_access.txt"
TARGET="10.10.20.10"
USER_NAME="adminX"

exec > >(tee "$OUTFILE") 2>&1

echo "=== R3_remote_access ==="
echo "What it tests: unauthorized SSH should fail; approved path should succeed if VPN is active"
echo "Expected result: non-approved direct SSH fails"
echo "Timestamp: $(date)"
echo

echo "--- TCP reachability to SSH ---"
nc -vz -w 3 "$TARGET" 22
NC_RC=$?
echo "TCP/22 return code: $NC_RC"
echo

echo "--- Direct SSH probe (credential/policy level) ---"
ssh -o BatchMode=yes -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$USER_NAME@$TARGET" "echo ok"
DIRECT_RC=$?
echo "Direct SSH return code: $DIRECT_RC"
echo

echo "--- Optional VPN/interface state ---"
ip -br a
echo

if [ $DIRECT_RC -ne 0 ]; then
  echo "RESULT: PASS (unauthorized direct SSH not usable)"
  exit 0
else
  echo "RESULT: FAIL (direct SSH unexpectedly succeeded)"
  exit 1
fi
