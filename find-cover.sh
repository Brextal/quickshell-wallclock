#!/bin/sh
URL="$1"
[ -z "$URL" ] && exit 1

PATH_DECODED=$(echo "$URL" | sed 's|^file://||' | python3 -c 'import sys,urllib.parse;print(urllib.parse.unquote(sys.stdin.read().strip()))')
DIR=$(dirname "$PATH_DECODED")

NAMES="cover.jpg Cover.jpg cover.png Cover.png folder.jpg Folder.jpg album.jpg Album.jpg front.jpg Front.jpg"

for i in 0 1 2 3; do
    for name in $NAMES; do
        TEST="$DIR/$name"
        [ -f "$TEST" ] && echo "$TEST" && exit 0
    done
    DIR=$(dirname "$DIR")
done

exit 1
