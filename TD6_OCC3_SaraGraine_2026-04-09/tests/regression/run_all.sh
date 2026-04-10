#!/usr/bin/env bash
set -u

BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
RESULT_ROOT="$BASE_DIR/results"
TS="$(date +%Y%m%d_%H%M%S)"
OUTDIR="$RESULT_ROOT/$TS"
mkdir -p "$OUTDIR"

echo "[*] Results directory: $OUTDIR"

FAIL=0

run_test() {
  local script_name="$1"
  echo
  echo "[*] Running $script_name"

  bash "$BASE_DIR/$script_name" "$OUTDIR"
  local rc=$?

  if [ $rc -ne 0 ]; then
    echo "[!] $script_name FAILED with exit code $rc"
    FAIL=1
  else
    echo "[+] $script_name PASSED"
  fi
}

run_test R1_firewall.sh
run_test R2_tls.sh
run_test R3_remote_access.sh
run_test R4_detection.sh

echo
if [ $FAIL -ne 0 ]; then
  echo "[!] One or more critical regression tests failed"
  exit 1
else
  echo "[+] All regression tests passed"
  exit 0
fi
