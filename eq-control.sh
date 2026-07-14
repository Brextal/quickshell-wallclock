#!/bin/sh
SOCKET="$XDG_RUNTIME_DIR/EasyEffectsServer"
ACTION="$1"; shift

case "$ACTION" in
    set-band)
        echo -e "set_property:output:equalizer#0#left:band$1Gain:$2" | socat - UNIX-CONNECT:"$SOCKET"
        echo -e "set_property:output:equalizer#0#right:band$1Gain:$2" | socat - UNIX-CONNECT:"$SOCKET"
        ;;
    get-band)
        echo -e "get_property:output:equalizer#0#left:band$1Gain" | socat - UNIX-CONNECT:"$SOCKET" STDOUT
        ;;
    enable)
        echo -e "set_property:output:equalizer#0:bypass:false" | socat - UNIX-CONNECT:"$SOCKET"
        ;;
    disable)
        echo -e "set_property:output:equalizer#0:bypass:true" | socat - UNIX-CONNECT:"$SOCKET"
        ;;
    preset)
        echo -e "load_preset:output:$1" | socat - UNIX-CONNECT:"$SOCKET"
        ;;
esac
