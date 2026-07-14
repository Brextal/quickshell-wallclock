# Quickshell Wallclock

Widget flotante con reloj, panel musical con carátula circular giratoria, equalizer de audio (CAVA) y stats del sistema para **Hyprland** con **Quickshell**.

## Dependencias

- [Quickshell](https://quickshell.outfoxxed.me/) (0.3.0+)
- QtQuick, QtQuick.Window, Qt5Compat.GraphicalEffects
- Hyprland
- [pywal](https://github.com/dylanaraps/pywal) o [pywal16](https://github.com/eylles/pywal16)
- [CAVA](https://github.com/karlstav/cava) — visualizer de audio
- `mpv` + `mpv-mpris` — reproducción musical
- `sensors` (lm_sensors) — temperatura CPU/GPU
- `free`, `df` — RAM y disco
- Nerd Fonts

## Instalación

```bash
git clone https://github.com/Brextal/quickshell-wallclock.git ~/.config/quickshell/wallclock
ln -s ~/.config/quickshell/shared ~/.config/quickshell/wallclock/shared
```

## Funciones

### Reloj flotante
Reloj digital grande en la parte superior de la pantalla con stats de sistema (CPU, GPU, RAM, disco) en la parte inferior.

### Panel musical (Super+K)
- **Carátula circular giratoria** — se extrae de la carpeta del disco (`cover.jpg`, `Cover.jpg`, `folder.jpg`) y gira suavemente cuando la música está reproduciendo
- **Controles** — play/pause, anterior, siguiente, abrir carpeta
- **Equalizer** — visualizer de audio en tiempo real via CAVA
- **Metadata** — artista, título, duración

### Atajos de teclado

| Atajo | Acción |
|---|---|
| Super+K | Abrir/cerrar panel musical |

## Archivos

| Archivo | Descripción |
|---|---|
| `shell.qml` | Archivo principal — reloj, panel musical, stats |
| `RingArc.qml` | Componente de arco para gauges |
| `cava-read.sh` | Pipe de CAVA a `/tmp/cava_bars` |
| `find-cover.sh` | Busca carátula en la carpeta del disco |
| `stats.sh` | Recolecta CPU/GPU temp, RAM, disco |

## Recargar después de cambios

```bash
~/.config/quickshell/wallclock/reload.sh
```

## Notas

- La carátula se busca automáticamente en la carpeta del archivo que se está reproduciendo, subiendo hasta 3 niveles de directorio
- CAVA escribe los datos del visualizer a `/tmp/cava_bars` via FIFO
- Los colores de acento se sincronizan con pywal
