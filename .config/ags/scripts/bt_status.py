#!/usr/bin/env python3
import json, subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

powered = "Powered: yes" in run(["bluetoothctl", "show"])
if not powered:
    print(json.dumps({"powered": False, "text": "\udb80\udcb2", "tooltip": "Bluetooth выключен", "devices": []}))
    raise SystemExit(0)

conn_raw = run(["bluetoothctl", "devices", "Connected"])
conn_macs = {line.split()[1] for line in conn_raw.splitlines() if len(line.split()) >= 2}
conn_names = [" ".join(line.split()[2:]) for line in conn_raw.splitlines() if len(line.split()) >= 3]

paired_raw = run(["bluetoothctl", "devices", "Paired"])
devices = []
for line in paired_raw.splitlines():
    parts = line.split()
    if len(parts) >= 3:
        mac = parts[1]
        name = " ".join(parts[2:])
        devices.append({"mac": mac, "name": name, "connected": mac in conn_macs})

count = len(conn_names)
if count > 0:
    text = f"\udb80\udcb1 {count}"
    tooltip = "Подключено:\n" + "\n".join(conn_names)
else:
    text = "\udb80\udcaf"
    tooltip = "Bluetooth включен (нет подключений)"

print(json.dumps({"powered": True, "text": text, "tooltip": tooltip, "devices": devices}))
