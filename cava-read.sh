#!/bin/bash
# Continuously pipes cava output to /tmp/cava_bars
# Kill this script to stop cava too
cleanup() { kill $CAVA_PID 2>/dev/null; rm -f /tmp/cava_fifo; exit 0; }
trap cleanup TERM INT

rm -f /tmp/cava_fifo
mkfifo /tmp/cava_fifo

cava -p "$HOME/.config/cava/config" > /tmp/cava_fifo 2>/dev/null &
CAVA_PID=$!

while read line < /tmp/cava_fifo; do
    [ -z "$line" ] && continue
    printf '%s' "$line" > /tmp/cava_bars
done
