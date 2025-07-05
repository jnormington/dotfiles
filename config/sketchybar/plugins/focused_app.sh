#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then

case "$INFO" in
    "Firefox")
        ICON=":firefox:"
        ;;
    "Alacritty")
        ICON=":alacritty:"
        ;;
    "Finder")
        ICON=":finder:"
        ;;
    "Spotify")
        ICON=":spotify:"
        ;;
    "TablePlus")
        ICON=":tableplus:"
        ;;
    "Slack")
        ICON=":slack:"
        ;;
    *)
        ICON=":rain:"
        ;;
esac

echo "$INFO - $ICON" >> ~/.test

sketchybar --set "$NAME" label="$INFO" icon="$ICON"
fi
