#!/usr/bin/env bash
# Smoke tests for the steam-globalmenu daemon.
# Usage: VERSION=<expected> tests/smoke.sh ./steam-globalmenu
set -euo pipefail

bin=${1:?usage: smoke.sh <binary>}
expected=${VERSION:?VERSION must be set}

out=$("$bin" --version)
[ "$out" = "steam-globalmenu $expected" ] || { echo "FAIL --version: '$out'"; exit 1; }
echo "ok --version"

"$bin" --help | grep -q -- '--silent' || { echo "FAIL --help does not mention --silent"; exit 1; }
echo "ok --help"

# Headless run: needs an X server (Xvfb) and a private session bus. There is no
# KDE registrar on that bus, so this checks the daemon survives without one.
if ! command -v xvfb-run >/dev/null || ! command -v dbus-run-session >/dev/null; then
    echo "skip headless run (xvfb-run or dbus-run-session not installed)"
    exit 0
fi

# shellcheck disable=SC2016  # $1/$pid are meant for the inner shell
xvfb-run -a dbus-run-session -- bash -c '
    "$1" --silent &
    pid=$!
    sleep 2
    kill -0 "$pid" 2>/dev/null || { echo "FAIL daemon exited early"; exit 1; }
    kill -TERM "$pid"
    rc=0
    wait "$pid" || rc=$?
    # 0 = handled SIGTERM, 143 = default SIGTERM disposition; both are a clean stop
    [ "$rc" -eq 0 ] || [ "$rc" -eq 143 ] || { echo "FAIL exit status $rc after SIGTERM"; exit 1; }
' _ "$bin"
echo "ok headless run"
