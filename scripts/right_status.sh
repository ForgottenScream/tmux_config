#!/usr/bin/env zsh

# Network check (no ping)
NET_STATUS="Disconnected"
IFACE=$(ip route | awk '/^default/ {print $5}')

if [[ -n "$IFACE" ]]; then
  HAS_IP=$(ip a show "$IFACE" | grep -q "inet " && echo yes)

  if [[ "$HAS_IP" == "yes" ]]; then
    WIFI_IFACES=($(iw dev | awk '$1=="Interface"{print $2}'))
    if [[ " ${WIFI_IFACES[@]} " =~ " $IFACE " ]]; then
      SSID=$(iw dev "$IFACE" link | grep SSID | cut -d ' ' -f2-)
      [[ -z "$SSID" ]] && SSID="unknown"
      NET_STATUS="WiFi: $SSID"
    else
      NET_STATUS="Eth: $IFACE"
    fi
  fi
fi

# VPN status
VPN_IF=$(ip a | grep -E "tun0|wg0" | awk '{print $2}' | sed 's/://')
VPN_STATUS="VPN:OFF"
[[ -n "$VPN_IF" ]] && VPN_STATUS="VPN:ON"

# Volume
VOLUME=$(amixer get Master | grep -o "[0-9]*%" | head -1)

# Battery
if command -v upower &>/dev/null; then
  BATTERY=$(upower -i $(upower -e | grep BAT) | grep -E "percentage" | awk '{print $2}')
elif command -v acpi &>/dev/null; then
  BATTERY=$(acpi | cut -d "," -f 2 | tr -d " ")
else
  BATTERY="N/A"
fi

# Date + time
DATETIME=$(date "+%A, %d %B %Y %H:%M:%S")

# Output
echo "$NET_STATUS | $VPN_STATUS | V:$VOLUME | B:$BATTERY | $DATETIME"
