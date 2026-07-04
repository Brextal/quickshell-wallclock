#!/bin/bash
# Asegura que wallclock y launcher estén activos sin matar nada
pgrep -f "quickshell.*wallclock/shell.qml" >/dev/null 2>&1 || qs -p ~/.config/quickshell/wallclock/shell.qml &
pgrep -f "quickshell.*launcher/shell.qml" >/dev/null 2>&1 || qs -p ~/.config/quickshell/launcher/shell.qml &
