#!/usr/bin/env python3
import json, os, subprocess

def run(cmd):
    try:
        return subprocess.check_output(cmd, text=True, stderr=subprocess.DEVNULL).strip()
    except Exception:
        return ""

players = [p for p in run(["playerctl", "--list-all"]).splitlines() if p]
count = len(players)
if count == 0:
    print(json.dumps({"text": "", "tooltip": "", "player": "", "title": "", "artist": "", "status": "Stopped", "pos": 0, "len": 0, "timeStr": "00:00", "count": 0, "idx": 0}))
    raise SystemExit(0)

idx_file = "/tmp/active_player_idx"
idx = 0
if os.path.exists(idx_file):
    try:
        idx = int(open(idx_file).read().strip())
    except Exception:
        idx = 0
if idx >= count or idx < 0:
    idx = 0
    open(idx_file, "w").write("0")

ap = players[idx]
status = run(["playerctl", "-p", ap, "status"])
nl = ap.lower()
title = run(["playerctl", "-p", ap, "metadata", "--format", "{{title}}"]) or run(["playerctl", "-p", ap, "metadata", "--format", "{{xesam:title}}"])
artist = run(["playerctl", "-p", ap, "metadata", "--format", "{{artist}}"])

full_text = f"{title} - {artist}" if (title and artist) else (title or ap)
short_text = (full_text[:37] + "...") if len(full_text) > 40 else full_text

if status == "Paused":
    icon = "▶ "
elif "spotify" in nl:
    icon = " "
elif "firefox" in nl or "mozilla" in nl:
    icon = " "
elif "vlc" in nl:
    icon = "   "
else:
    icon = "🎵 "

try:
    pos = float(run(["playerctl", "-p", ap, "position"]) or 0)
except Exception:
    pos = 0.0
try:
    len_sec = int(run(["playerctl", "-p", ap, "metadata", "mpris:length"]) or 0) // 1000000
except Exception:
    len_sec = 0

p_i = int(pos)
if len_sec > 0:
    t_str = f"[{p_i//60:02d}:{p_i%60:02d} / {len_sec//60:02d}:{len_sec%60:02d}]"
else:
    t_str = f"[{p_i//60:02d}:{p_i%60:02d}]"

print(json.dumps({
    "text": f"{icon} {short_text} {t_str} ({idx+1}/{count})",
    "tooltip": f"Плеер: {ap}\nНазвание: {full_text}\nВремя: {t_str}",
    "player": ap,
    "title": title or "Без названия",
    "artist": artist or "Неизвестный исполнитель",
    "status": status,
    "pos": pos,
    "len": len_sec,
    "timeStr": t_str,
    "count": count,
    "idx": idx
}))
