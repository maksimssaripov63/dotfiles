#!/usr/bin/env python3
import os, time, subprocess

def bar(pct, width=10):
    pct = max(0.0, min(100.0, pct))
    filled = int(round((pct / 100.0) * width))
    color = "#a6e3a1" if pct < 50 else ("#f9e2af" if pct < 80 else "#f38ba8")
    return f'<span foreground="{color}">{"█" * filled}</span><span foreground="#45475a">{"░" * (width - filled)}</span>'

def read_stat():
    res = {}
    with open("/proc/stat") as f:
        for line in f:
            if line.startswith("cpu"):
                parts = line.split()
                vals = list(map(int, parts[1:8]))
                idle = vals[3] + vals[4]
                total = sum(vals)
                res[parts[0]] = (idle, total)
    return res

s1 = read_stat()
time.sleep(0.15)
s2 = read_stat()

usage = {}
for k in s1:
    dt = s2[k][1] - s1[k][1]
    di = s2[k][0] - s1[k][0]
    usage[k] = 100.0 * (1.0 - di / dt) if dt > 0 else 0.0

freqs = []
for i in range(20):
    p = f"/sys/devices/system/cpu/cpu{i}/cpufreq/scaling_cur_freq"
    if os.path.exists(p):
        with open(p) as f:
            freqs.append(int(f.read().strip()) // 1000)
avg_mhz = sum(freqs) // len(freqs) if freqs else 0

pkg_temp = "N/A"
core_temps = []
try:
    out = subprocess.check_output(["sensors"], text=True, stderr=subprocess.DEVNULL)
    for line in out.splitlines():
        if "Package id 0:" in line:
            pkg_temp = line.split()[3].replace("+", "").replace(".0", "")
        elif line.startswith("Core "):
            core_temps.append(line.split()[2].replace("+", "").replace(".0", ""))
except Exception:
    pass

if pkg_temp == "N/A":
    for z in os.listdir("/sys/class/thermal"):
        tp = f"/sys/class/thermal/{z}/type"
        if os.path.exists(tp) and open(tp).read().strip() == "x86_pkg_temp":
            val = int(open(f"/sys/class/thermal/{z}/temp").read().strip()) // 1000
            pkg_temp = f"{val}°C"
            break

with open("/proc/loadavg") as f:
    la = " ".join(f.read().split()[:3])

gpu0_line = "<b>GPU0</b>  N/A"
try:
    nv = subprocess.check_output(
        ["nvidia-smi", "--query-gpu=utilization.gpu,memory.used,memory.total,temperature.gpu,power.draw", "--format=csv,noheader,nounits"],
        text=True, stderr=subprocess.DEVNULL
    ).strip().split(", ")
    gu = float(nv[0])
    mu = float(nv[1]) / 1024.0
    mt = float(nv[2]) / 1024.0
    gt = int(float(nv[3]))
    gp = float(nv[4])
    gpu0_line = (
        f'<b>GPU0</b> {bar(gu, 16)} <span foreground="#a6e3a1">{gu:3.0f}%</span>  '
        f'<span foreground="#cdd6f4">{mu:.1f}G/{mt:.1f}G</span>  '
        f'<span foreground="#89b4fa">{gt}°C</span> <span foreground="#74c7ec">{gp:.2f}W</span>'
    )
except Exception:
    pass

lines = []
lines.append(f'<span foreground="#6c7086">┌─</span> <b>13th Gen i7-13650HX</b> <span foreground="#6c7086">──────────────────</span> <b>{avg_mhz} MHz</b> <span foreground="#6c7086">─┐</span>')
lines.append(f'<b>CPU</b>  {bar(usage.get("cpu", 0), 24)} <span foreground="#a6e3a1">{usage.get("cpu", 0):3.0f}%</span>   <span foreground="#89b4fa">{pkg_temp}</span>')

for row in range(10):
    c_left, c_right = row, row + 10
    u_l = usage.get(f"cpu{c_left}", 0.0)
    u_r = usage.get(f"cpu{c_right}", 0.0)
    t_l = core_temps[row % len(core_temps)] if core_temps else pkg_temp
    t_r = core_temps[(row + 4) % len(core_temps)] if core_temps else pkg_temp
    lines.append(
        f'<b>C{c_left:<2}</b> {bar(u_l, 8)} <span foreground="#a6e3a1">{u_l:3.0f}%</span> <span foreground="#89b4fa">{t_l:>4}</span>'
        f' <span foreground="#6c7086">│</span> '
        f'<b>C{c_right:<2}</b> {bar(u_r, 8)} <span foreground="#a6e3a1">{u_r:3.0f}%</span> <span foreground="#89b4fa">{t_r:>4}</span>'
    )

lines.append(f'<span foreground="#6c7086">├───────────────────────────────────────────────────┤</span>')
lines.append(f'Load avg: <span foreground="#f9e2af">{la}</span>')
lines.append(gpu0_line)

print('<span font_family="JetBrainsMono Nerd Font" size="9500">' + "\n".join(lines) + '</span>')
