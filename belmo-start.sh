#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"

: "${SQL_DSN:?SQL_DSN must be configured in Belmo runtime variables}"
: "${SESSION_SECRET:?SESSION_SECRET must be configured in Belmo runtime variables}"
export PORT="${PORT:-3000}"
if [[ ! "$PORT" =~ ^[0-9]{1,5}$ ]] || (( 10#$PORT < 1 || 10#$PORT > 65535 )); then
  echo 'START_FAIL: PORT must be an integer from 1 to 65535' >&2
  exit 1
fi
export PORT="$((10#$PORT))"

# Go's soft memory target leaves headroom within the 512 MB service limit.
export GOMEMLIMIT="${GOMEMLIMIT:-384MiB}"
export GOMAXPROCS="${GOMAXPROCS:-1}"
export GIN_MODE="${GIN_MODE:-release}"
printf 'START: New API on port %s; runtime initialization precedes HTTP readiness\n' "$PORT"
exec ./app "$@"
