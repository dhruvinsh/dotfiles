#!/usr/bin/env bash
# Start xob reading volume values from a FIFO. Idempotent (safe for exec_always).
set -u

fifo="${XDG_RUNTIME_DIR:-/tmp}/xob.fifo"
[[ -p $fifo ]] || { rm -f "$fifo" && mkfifo "$fifo"; }

command -v xob >/dev/null || exit 0

pkill -u "$EUID" -x xob 2>/dev/null

# Opening the FIFO read-write means xob never sees EOF between writers
# (tail -f would poll a FIFO once a second, delaying the OSD).
nohup xob -s default <>"$fifo" >/dev/null 2>&1 &
