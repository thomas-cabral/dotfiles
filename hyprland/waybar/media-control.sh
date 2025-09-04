#!/bin/bash

echo "$(date): Media control called with: $1" >> /tmp/waybar-media.log

case "$1" in
    toggle)
        playerctl play-pause 2>>/tmp/waybar-media.log
        echo "$(date): Toggle executed, exit code: $?" >> /tmp/waybar-media.log
        ;;
    next)
        playerctl next 2>>/tmp/waybar-media.log
        echo "$(date): Next executed, exit code: $?" >> /tmp/waybar-media.log
        ;;
    prev)
        playerctl previous 2>>/tmp/waybar-media.log
        echo "$(date): Previous executed, exit code: $?" >> /tmp/waybar-media.log
        ;;
esac