#!/usr/bin/env bash
set -eu

: "${SQL_DSN:?SQL_DSN is missing from this build check}"
: "${SESSION_SECRET:?SESSION_SECRET is missing from this build check}"

export DEBUG=false
export PORT="${PORT:-3000}"

./app &
pid=$!
trap 'kill "$pid" 2>/dev/null || true; wait "$pid" 2>/dev/null || true' EXIT

end=$((SECONDS + 600))

while [ "$SECONDS" -lt "$end" ]; do
  if ! kill -0 "$pid" 2>/dev/null; then
    if wait "$pid"; then code=0; else code=$?; fi
    printf 'BOOT_FAIL: application exited with code %s\n' "$code"
    exit 1
  fi

  response=$(curl -fsS --connect-timeout 1 --max-time 3 \
    "http://127.0.0.1:$PORT/api/status" 2>/dev/null) || response=''

  if [[ "$response" =~ \"success\"[[:space:]]*:[[:space:]]*true ]]; then
    echo 'BOOT_OK: application returned success=true'
    exit 0
  fi

  sleep 1
done

echo 'BOOT_FAIL: no successful status response within 600 seconds'
exit 1
