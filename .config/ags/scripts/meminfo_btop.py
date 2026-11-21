#!/usr/bin/env python3

def bar(pct, width=22, color="#a6e3a1"):
    pct = max(0.0, min(100.0, pct))
    filled = int(round((pct / 100.0) * width))
    return f'<span foreground="{color}">{"█" * filled}</span><span foreground="#45475a">{"░" * (width - filled)}</span>'

mem = {}
with open("/proc/meminfo") as f:
    for line in f:
        parts = line.split()
        if len(parts) >= 2:
            mem[parts[0].rstrip(":")] = int(parts[1]) / (1024 * 1024)  # GiB

total = mem.get("MemTotal", 1.0)
free = mem.get("MemFree", 0.0)
avail = mem.get("MemAvailable", 0.0)
buffers = mem.get("Buffers", 0.0)
cached = mem.get("Cached", 0.0) + mem.get("SReclaimable", 0.0) - mem.get("Shmem", 0.0)
used = max(0.0, total - avail)

swap_total = mem.get("SwapTotal", 0.0)
swap_free = mem.get("SwapFree", 0.0)
swap_used = max(0.0, swap_total - swap_free)

p_used = (used / total) * 100.0
p_avail = (avail / total) * 100.0
p_cached = (cached / total) * 100.0
p_free = (free / total) * 100.0

lines = []
lines.append(f'<span foreground="#6c7086">┌─</span> <b>mem</b> <span foreground="#6c7086">───────────────────────────────</span> <b>{total:.1f} GiB</b> <span foreground="#6c7086">─┐</span>')
lines.append(f'<b>Used:</b>      {bar(p_used, 20, "#f38ba8")} <span foreground="#f38ba8">{p_used:3.0f}%</span>  <span foreground="#cdd6f4">{used:5.2f} GiB</span>')
lines.append(f'<b>Available:</b> {bar(p_avail, 20, "#f9e2af")} <span foreground="#f9e2af">{p_avail:3.0f}%</span>  <span foreground="#cdd6f4">{avail:5.2f} GiB</span>')
lines.append(f'<b>Cached:</b>    {bar(p_cached, 20, "#89dceb")} <span foreground="#89dceb">{p_cached:3.0f}%</span>  <span foreground="#cdd6f4">{cached:5.2f} GiB</span>')
lines.append(f'<b>Free:</b>      {bar(p_free, 20, "#a6e3a1")} <span foreground="#a6e3a1">{p_free:3.0f}%</span>  <span foreground="#cdd6f4">{free:5.2f} GiB</span>')

if swap_total > 0:
    p_swap = (swap_used / swap_total) * 100.0
    lines.append(f'<span foreground="#6c7086">├──────────────────────────────────────────────┤</span>')
    lines.append(f'<b>Swap:</b>      {bar(p_swap, 20, "#cba6f7")} <span foreground="#cba6f7">{p_swap:3.0f}%</span>  <span foreground="#cdd6f4">{swap_used:.2f}/{swap_total:.1f}G</span>')
else:
    lines.append(f'<span foreground="#6c7086">└──────────────────────────────────────────────┘</span>')

print('<span font_family="JetBrainsMono Nerd Font" size="9500">' + "\n".join(lines) + '</span>')
