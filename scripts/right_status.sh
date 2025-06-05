#!/usr/bin/env zsh

# Volume (amixer)
VOLUME=$(amixer get Master | grep -o "[0-9]*%" | head -1)

# IP address
IP=$(ip route get 1 | awk '{print $7}')

# VPN status (interface tun0 or wg0)
VPN_IF=$(ip a | grep -E "tun0|wg0" | awk '{print $2}' | sed 's/://')
VPN_STATUS="VPN: off"
if [ -n "$VPN_IF" ]; then
  VPN_STATUS="VPN: on"
fi

# Battery (if available)
if command -v upower &>/dev/null; then
  BATTERY=$(upower -i $(upower -e | grep BAT) | grep -E "percentage" | awk '{print $2}')
elif command -v acpi &>/dev/null; then
  BATTERY=$(acpi | cut -d "," -f 2 | tr -d " ")
else
  BATTERY="N/A"
fi

# Date + time
DATETIME=$(date "+%A, %d %B %Y %H:%M:%S")

# Output everything
echo "$VOLUME | IP: $IP | $VPN_STATUS | $BATTERY | $DATETIME"
