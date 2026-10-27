#!/usr/bin/env bash
set -eu

# --version exits in common.InitEnv(), before database initialization.
# Build validation must never start a server or use the production database.
test -x ./app
test -s web/dist/index.html
env -i PATH="$PATH" ./app --version
echo 'BUILD_OK: binary and embedded frontend present; no server started'
