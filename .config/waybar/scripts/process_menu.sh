#!/usr/bin/env bash

# 1. Выводим список процессов и получаем выбранную строку
selected=$(ps -eo pid=,pcpu=,pmem=,user=,args= --sort=-pcpu | sed 's/^[ \t]*//' | rofi -dmenu -i -p "Процесс:" -theme-str 'window {width: 60%;}')

# Если пользователь нажал Esc или ничего не выбрал, просто выходим
if [ -z "$selected" ]; then
  exit 0
fi

# 2. Извлекаем PID и имя команды для отображения в окне подтверждения
pid=$(echo "$selected" | awk '{print $1}')
cmd=$(echo "$selected" | awk '{print $5}' | xargs basename 2>/dev/null)

# 3. Запускаем второе меню Rofi для подтверждения действия
confirm=$(printf "Да\nНет" | rofi -dmenu -i -p "Убить $cmd (PID: $pid)?" -theme-str 'window {width: 25%;} listview {lines: 2;}')

# 4. Завершаем процесс только при точном выборе "Да"
if [ "$confirm" = "Да" ]; then
  kill -9 "$pid" 2>/dev/null || sudo -n /usr/bin/kill -9 "$pid"
fi
