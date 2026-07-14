#!/bin/bash
# Asegura que wallclock y launcher estén activos sin duplicar
pgrep -f "qs .*wallclock/shell.qml" >/dev/null 2>&1 || qs -p ~/.config/quickshell/wallclock/shell.qml &
pgrep -f "qs .*launcher/shell.qml" >/dev/null 2>&1 || qs -p ~/.config/quickshell/launcher/shell.qml &
