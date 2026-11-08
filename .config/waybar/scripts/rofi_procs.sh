#!/usr/bin/env bash

if [ -n "$1" ]; then
  if [[ "$1" == "ДА, УБИТЬ:"* ]]; then
    pid=$(echo "$1" | awk '{print $3}')
    kill -9 "$pid" 2>/dev/null || sudo -n /usr/bin/kill -9 "$pid"
    exit 0
  elif [[ "$1" == "Отмена"* ]]; then
    exit 0
  else
    pid=$(echo "$1" | awk '{print $1}')
    cmd=$(echo "$1" | awk '{print $5}' | xargs basename 2>/dev/null)
    printf "ДА, УБИТЬ: %s (%s)\0icon\x1fprocess-stop\nОтмена\0icon\x1fedit-undo\n" "$pid" "$cmd"
    exit 0
  fi
fi

# Выводим ВСЕ процессы (-e) и подставляем имя исполняемого файла как имя иконки
ps -eo pid=,pcpu=,pmem=,user=,comm=,args= --sort=-pcpu | while read -r pid cpu mem user comm args; do
  printf "%-7s %5s%% CPU  %5s%% MEM  %-10s %s\0icon\x1f%s\n" "$pid" "$cpu" "$mem" "$user" "$args" "$comm"
done
