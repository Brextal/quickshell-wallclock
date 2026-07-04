#!/bin/bash
cpu_temp=$(sensors -u 2>/dev/null | awk '/^k10temp/ {f=1} f && /temp1_input/ {print int($2); exit}')
[ -z "$cpu_temp" ] && cpu_temp=0

gpu_temp=$(sensors -u 2>/dev/null | awk '/^amdgpu/ {f=1} f && /temp1_input/ {print int($2); exit}')
[ -z "$gpu_temp" ] && gpu_temp=0

eval $(free -b | awk '/Mem:/ {printf "ram_used=%.1f;ram_total=%.1f;ram_percent=%d", $3/1073741824, $2/1073741824, $3/$2 * 100}')
[ -z "$ram_percent" ] && ram_percent=0
[ -z "$ram_used" ] && ram_used=0
[ -z "$ram_total" ] && ram_total=0

disk_percent=$(df / | awk 'NR==2 {gsub(/%/,""); print $5}')
[ -z "$disk_percent" ] && disk_percent=0

echo "{\"cpuTemp\":$cpu_temp,\"gpuTemp\":$gpu_temp,\"ramPercent\":$ram_percent,\"diskPercent\":$disk_percent}"
