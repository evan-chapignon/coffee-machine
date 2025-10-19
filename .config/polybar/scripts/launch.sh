#!/bin/bash

# --- Kill bars déjà en cours ---
killall -q polybar

# Attend qu'elles soient bien fermées
while pgrep -x polybar >/dev/null; do sleep 0.5; done

# --- Détection automatique des interfaces ---
export IFACE=$(ip route | awk '/default/ {print $5; exit}')
export BAT=$(ls /sys/class/power_supply/ | grep -m 1 BAT)
export ADP=$(ls /sys/class/power_supply/ | grep -m 1 AC)

# --- Lancer ta barre ---
polybar Newbie &

echo "Polybar lancé avec :"
echo "  IFACE = $IFACE"
echo "  BAT   = $BAT"
echo "  ADP   = $ADP"
