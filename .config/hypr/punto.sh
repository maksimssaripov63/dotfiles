#!/bin/bash
# Имитируем нажатие Ctrl+Backspace, чтобы стереть неверное слово
hyprctl dispatch sendshortcut "CTRL, BackSpace, active"
sleep 0.05

# Получаем последний набранный текст из буфера и меняем буквы
text=$(wl-paste --primary 2>/dev/null || wl-paste 2>/dev/null)

# Словари символов
en="qwertyuiop[]asdfghjkl;'zxcvbnm,.QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>"
ru="йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ"

# Меняем раскладку текста и печатаем его обратно через wtype
if [[ "$text" =~ [а-яА-Я] ]]; then
  fixed=$(echo "$text" | tr "$ru" "$en")
else
  fixed=$(echo "$text" | tr "$en" "$ru")
fi

wtype "$fixed"
