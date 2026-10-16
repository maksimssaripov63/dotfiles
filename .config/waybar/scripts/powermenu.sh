#!/usr/bin/env bash

shutdown="⏻  Выкл"
reboot="Перезапуск"
lock="Блок"
suspend="Сон"
screenoff="Выключить дисплей"
logout="Выход"

# Вызываем кастомное окно rofi
options="$shutdown\n$reboot\n$lock\n$suspend\n$logout\n$screenoff"
CHOSEN=$(echo -e "$options" | rofi -dmenu -theme ~/.config/rofi/powermenu.rasi -p "Питание:")

case "$CHOSEN" in
$shutdown)
  systemctl poweroff
  ;;
$screenoff) # 3. ПРОПИСЫВАЕМ СИЛОВОЙ ВЫКЛЮЧАТЕЛЬ ЭКРАНА С ХАРДВЕРНЫМ АВТОПРОБУЖДЕНИЕМ!
  killall rofi
  sleep 0.2

  hyprlisten_msg dispatch dpms off 2>/dev/null || hyprctl dispatch 'hl.dsp.dpms({ action = "disable" })'
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
