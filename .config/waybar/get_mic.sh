#!/bin/bash
# Получаем громкость микрофона по умолчанию и убираем лишние знаки %
pactl get-source-volume @DEFAULT_SOURCE@ | awk '{print $5}' | head -n1 | tr -d '%'

