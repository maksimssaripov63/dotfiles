#!/usr/bin/env bash

if [ -n "$1" ]; then
  addr=$(echo "$1" | awk '{print $1}')
  hyprctl dispatch focuswindow "address:$addr" >/dev/null
  exit 0
fi

# Передаем класс окна в нижнем регистре в тег \0icon\x1f для подхвата системной иконки
hyprctl clients -j | jq -r '.[] | select(.mapped == true) | "\(.address)  [WS:\(.workspace.id)]  \(.class) — \(.title)\u0000icon\u001f\(.class | ascii_downcase)"'
