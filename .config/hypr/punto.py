#!/usr/bin/env python3
import subprocess

en_chars = "qwertyuiop[]asdfghjkl;'zxcvbnm,.QWERTYUIOP{}ASDFGHJKL:\"ZXCVBNM<>"
ru_chars = "йцукенгшщзхъфывапролджэячсмитьбюЙЦУКЕНГШЩЗХЪФЫВАПРОЛДЖЭЯЧСМИТЬБЮ"

print(f"EN length: {len(en_chars)}")
print(f"RU length: {len(ru_chars)}")


to_ru = str.maketrans(en_chars, ru_chars)
to_en = str.maketrans(ru_chars, en_chars)

try:
    # Чистое чтение текста из буфера обмена Wayland
    text = subprocess.check_output(["copyq", "-n"], text=True).strip()
    if text:
        # Переводим буквы по словарю раскладок
        fixed = text.translate(to_en) if any(c in ru_chars for c in text) else text.translate(to_ru)

        # Записываем исправленный текст обратно в буфер
        process = subprocess.Popen(["copyq"], stdin=subprocess.PIPE, text=True)
        process.communicate(input=fixed)
except Exception:
    pass

