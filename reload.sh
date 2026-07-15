#!/bin/bash
# Recarga wallclock si no está activo
pgrep -f "qs .*wallclock/shell.qml" >/dev/null 2>&1 || qs -p ~/.config/quickshell/wallclock/shell.qml &
