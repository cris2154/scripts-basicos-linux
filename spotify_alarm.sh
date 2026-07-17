#!/bin/bash
# spotify_alarm.sh

TARGET_TIME="05:00:00"
TARGET_EPOCH=$(date -d "$TARGET_TIME" +%s)
CURRENT_EPOCH=$(date +%s)

# Si las 5:00 AM ya pasaron hoy, programar para mañana
if [ "$TARGET_EPOCH" -lt "$CURRENT_EPOCH" ]; then
    TARGET_EPOCH=$((TARGET_EPOCH + 86400))
fi

SLEEP_SEC=$((TARGET_EPOCH - CURRENT_EPOCH))
HORAS=$((SLEEP_SEC / 3600))
MINUTOS=$(((SLEEP_SEC % 3600) / 60))

echo "Alarma programada. Durmiendo por $HORAS horas y $MINUTOS minutos hasta las 5:00 AM..."
sleep "$SLEEP_SEC"

echo "¡Es hora de despertar! Abriendo Spotify y subiendo el volumen..."

# 1. Subir volumen del sistema al 100% (PipeWire/PulseAudio)
wpctl set-volume @DEFAULT_AUDIO_SINK@ 1.0 2>/dev/null || pactl set-sink-volume @DEFAULT_SINK@ 100% 2>/dev/null

# 2. Iniciar Spotify si no está corriendo
if ! pgrep -x "spotify" > /dev/null; then
    spotify &
    sleep 7 # Darle tiempo a Spotify para cargar y registrar MPRIS
fi

# 3. Asegurar volumen interno de Spotify al máximo y reproducir
playerctl -p spotify volume 1.0 2>/dev/null
playerctl -p spotify play
