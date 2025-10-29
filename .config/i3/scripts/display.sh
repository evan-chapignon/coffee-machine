#!/bin/bash

# Détecter les écrans connectés
external=$(xrandr | awk '/ connected/ && $1 !~ /eDP|LVDS/ {print $1; exit}')
internal=$(xrandr | awk '/ connected/ && $1 ~ /eDP|LVDS/ {print $1; exit}')

mode=$1  # paramètre : dual | internal | external

case "$mode" in
  dual)
    if [ -n "$external" ] && [ -n "$internal" ]; then
      echo "→ Mode double écran"
      xrandr --output "$external" --primary --auto --pos 0x0 \
             --output "$internal" --auto --right-of "$external"
    else
      echo "⚠️ Impossible : un seul écran détecté."
    fi
    ;;
  internal)
    if [ -n "$internal" ]; then
      echo "→ Mode écran interne uniquement"
      xrandr --output "$internal" --primary --auto \
             $( [ -n "$external" ] && echo --output "$external" --off )
    else
      echo "⚠️ Aucun écran interne détecté."
    fi
    ;;
  external)
    if [ -n "$external" ]; then
      echo "→ Mode écran externe uniquement"
      xrandr --output "$external" --primary --auto \
             $( [ -n "$internal" ] && echo --output "$internal" --off )
    else
      echo "⚠️ Aucun écran externe détecté."
    fi
    ;;
  *)
    echo "Utilisation : $0 {dual|internal|external}"
    exit 1
    ;;
esac
