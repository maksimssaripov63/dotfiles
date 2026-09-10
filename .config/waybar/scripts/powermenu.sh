#!/usr/bin/env bash

# Кнопки с большими Nerd-иконками
shutdown="⏻  Выкл"
reboot="Перезапуск"
lock="Блок"
suspend="Сон"
logout="Выход"

# Вызываем кастомное окно rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout"
CHOSEN=$(echo -e "$options" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi -p "Питание:")

case "$CHOSEN" in
$shutdown)
  systemctl poweroff
  ;;
$reboot)
  systemctl reboot
  ;;
$lock)
  hyprlock
  ;;
$suspend)
  systemctl suspend
  ;;
$logout)
  hyprctl dispatch exit
  ;;
*)
  exit 0
  ;;
esac
