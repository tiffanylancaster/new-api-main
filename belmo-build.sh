#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "$0")"

# No runtime credentials are needed to compile or inspect the binary.
unset SQL_DSN LOG_SQL_DSN SESSION_SECRET CRYPTO_SECRET
export CGO_ENABLED=0 GOTOOLCHAIN=auto GOWORK=off

test -s web/dist/index.html
version=$(tr -d '\r\n' < VERSION)
test -n "$version"
go build -p 1 -trimpath \
  -ldflags "-s -w -X github.com/QuantumNous/new-api/common.Version=$version" \
  -o app .
bash ./belmo-preflight.sh
