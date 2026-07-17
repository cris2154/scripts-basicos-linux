# Scripts para Linux Básicos

Este repositorio contiene una colección de scripts prácticos en Bash y Go para automatizar tareas comunes en entornos Linux (especialmente útiles en configuraciones de escritorio basadas en Wayland/Hyprland).

## Scripts incluidos

1. **`letraS` (Bubbletea TUI):** Muestra de forma sincronizada y fluida la letra de la canción que se esté reproduciendo actualmente en Spotify local.
2. **`despertador` (Bash):** Alarma programable para cualquier hora (por defecto las 05:00 AM) que muestra una cuenta regresiva, lanza una notificación de sistema crítica y reproduce alertas sonoras.
3. **`spotify_alarm.sh` (Bash):** Alarma inteligente para las 5:00 AM que sube el volumen del sistema y de Spotify al 100%, inicia el reproductor y arranca la música automáticamente.

---

## Dependencias de los scripts

Para que todos los scripts funcionen correctamente sin errores, necesitas instalar las siguientes herramientas del sistema:

- `playerctl` (para leer y controlar el estado del reproductor de Spotify)
- `libnotify` / `notify-send` (para lanzar notificaciones de escritorio)
- `libcanberra` (para reproducir alertas de audio a través de los temas del sistema)
- `curl` (para descargar las portadas de álbumes de Spotify)
- `jq` (para la codificación y análisis de texto en llamadas a APIs de letras y carátulas)

---

## Comando de instalación de dependencias "de golpe"

Ejecuta el comando correspondiente al gestor de paquetes de tu distribución para instalar todas las dependencias juntas:

### En Arch Linux (pacman)
```bash
sudo pacman -S --needed playerctl libnotify libcanberra curl jq
```

### En Ubuntu / Debian / Pop!_OS (apt)
```bash
sudo apt update && sudo apt install -y playerctl libnotify-bin libcanberra-gtk-module curl jq
```

### En Fedora (dnf)
```bash
sudo dnf install -y playerctl libnotify libcanberra-gtk-module curl jq
```
