#!/usr/bin/env bash

print_ws() {
  active_ws=$(hyprctl activeworkspace -j | jq -r '.id // empty')
  workspaces=$(hyprctl workspaces -j | jq -r '.[].id | select(. > 0)' | sort -n)

  if [ -n "$active_ws" ] && ! echo "$workspaces" | grep -qw "$active_ws"; then
    workspaces=$(printf "%s\n%s" "$workspaces" "$active_ws" | sort -n | sed '/^$/d')
  fi

  output=""
  for ws in $workspaces; do
    if [ "$ws" = "$active_ws" ]; then
      output+="[ $ws ] "
    else
      output+=" $ws "
    fi
  done

  printf '{"text": "%s", "tooltip": "ЛКМ / Вниз: +1 | ПКМ / Вверх: -1"}\n' "${output% }"
}

# Выводим статус сразу при запуске Waybar
print_ws

# Слушаем сокет Hyprland и обновляем панель мгновенно при любом изменении столов
socat -U - UNIX-CONNECT:"$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock" | while read -r line; do
  case "$line" in
  workspace* | createworkspace* | destroyworkspace* | focusedmon*)
    print_ws
    ;;
  esac
done
