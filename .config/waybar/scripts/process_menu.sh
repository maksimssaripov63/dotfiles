#!/bin/bash

# Получаем список ТОП-20 процессов по потреблению памяти/процессора
# Формат: "PID  CPU%  MEM%  Имя_процесса"
PROCESS_LIST=$(ps -eo pid,pcpu,pmem,comm --sort=-pcpu | awk 'NR>1 {printf "%-6s | CPU: %-4s%% | MEM: %-4s%% | %s\n", $1, $2, $3, $4}' | head -n 20)

# Запускаем Rofi в режиме меню
SELECTION=$(echo "$PROCESS_LIST" | rofi -dmenu -i -p "Процессы" -theme-str 'window {width: 500px;}')

# Если пользователь выбрал процесс, извлекаем PID и завершаем его
if [ -not -z "$SELECTION" ]; then
    PID=$(echo "$SELECTION" | awk '{print $1}')
    
    # Запрос подтверждения удаления
    CONFIRM=$(echo -e "Нет\nДа" | rofi -dmenu -i -p "Завершить процесс $PID?" -theme-str 'window {width: 300px; height: 150px;}')
    
    if [ "$CONFIRM" = "Да" ]; then
        kill -9 "$PID" && notify-send "Процессы" "Процесс $PID успешно завершен"
    fi
fi
