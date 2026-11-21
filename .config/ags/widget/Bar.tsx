import app from "ags/gtk4/app";
import { Astal, Gtk, Gdk } from "ags/gtk4";
import { execAsync } from "ags/process";
import { createPoll } from "ags/time";
// import Tray from "gi://AstalTray"
import { createBinding, createState, For } from "gnim";
import Tray from "gi://AstalTray"


const [showDate, setShowDate] = createState(false);
const date = createPoll("", 5000, "date '+ %d-%m-%Y (%A)'");
const timeText = createPoll("", 1000, "date '+ %H:%M:%S'");
const calTooltip = createPoll("", 60000, "cal");

const btData = createPoll(
  { text: "\u{f00af}", tooltip: "Bluetooth" },
  2000,
  [
    "sh",
    "-c",
    'if ! bluetoothctl show 2>/dev/null | grep -q \'Powered: yes\'; then echo \'{"text": "\\udb80\\udcb2", "tooltip": "Bluetooth выключен"}\'; exit 0; fi; devs=$(bluetoothctl devices Connected 2>/dev/null | cut -d \' \' -f 3-); count=$(echo "$devs" | sed \'/^$/d\' | wc -l); if [ "$count" -gt 0 ]; then list=$(echo "$devs" | sed \':a;N;$!ba;s/\\n/\\\\n/g\'); echo "{\\"text\\": \\"\\udb80\\udcb1 $count\\", \\"tooltip\\": \\"Подключено:\\\\n$list\\"}"; else echo \'{"text": "\\udb80\\udcaf", "tooltip": "Bluetooth включен (нет подключений)"}\'; fi',
  ],
  (out) => {
    try {
      return JSON.parse(out);
    } catch {
      return { text: "\u{f00af}", tooltip: "Bluetooth" };
    }
  },
);

// --- Вспомогательный запуск команд с обработкой ошибок ---
const run = (cmd: string) => execAsync(["sh", "-c", cmd]).catch(() => {});

// --- 1. Часы ---
const time = createPoll("", 500, "date '+ %H:%M:%S'");

// --- 2. Uptime (время работы системы) ---
const uptime = createPoll("00:00:00", 1000, [
  "sh",
  "-c",
  'awk \'{print int($1/3600)":"int(($1%3600)/60)":"int($1%60)}\' /proc/uptime | awk -F: \'{printf "%02d:%02d:%02d", $1, $2, $3}\'',
]);

// --- 3. Батарея (статус + процент) ---
const battery = createPoll("100%", 3000, [
  "sh",
  "-c",
  'cap=$(cat /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -n1); status=$(cat /sys/class/power_supply/BAT*/status 2>/dev/null | head -n1); if [ "$status" = "Full" ] || [ "$status" = "Not charging" ]; then echo "PLUG ${cap}%"; else echo "${cap}%"; fi',
]);

// --- 4. Раскладка клавиатуры ---
const lang = createPoll("EN", 200, [
  "sh",
  "-c",
  "hyprctl devices -j | jq -r '.keyboards[] | select(.main == true) | .active_keymap' | cut -c1-2 | tr '[:lower:]' '[:upper:]'",
]);

// --- 5. CPU, GPU (nvidia-smi) и RAM ---
const cpu = createPoll("CPU:0%", 2000, [
  "sh",
  "-c",
  "top -bn1 | grep 'Cpu(s)' | awk '{printf \"CPU:%.0f%%\", 100 - $8}'",
]);

const gpu = createPoll("GPU:0%", 2000, [
  "sh",
  "-c",
  'nvidia-smi --query-gpu=utilization.gpu --format=csv,noheader,nounits 2>/dev/null | awk \'{print "GPU:" $1 "%"}\'',
]);

const ram = createPoll("RAM:0G", 2000, [
  "sh",
  "-c",
  "free -m | awk '/^Mem:/ {printf \"RAM:%.1fG/%.1fG\", $3/1024, $2/1024}'",
]);

// --- 6. Вывод звука (OUT) и Микрофон (INP) ---
const audioOut = createPoll("OUT: 0%", 100, [
  "sh",
  "-c",
  'wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk \'{if ($3 == "[MUTED]") print "OUT: Выкл"; else printf "OUT: %.0f%%", $2 * 100}\'',
]);

const audioIn = createPoll("INP: Вкл", 100, [
  "sh",
  "-c",
  'wpctl get-volume @DEFAULT_AUDIO_SOURCE@ | awk \'{if ($3 == "[MUTED]") print "INP: Выкл"; else print "INP: Вкл"}\'',
]);

// --- 7. Подсветка (LIGHT) ---
const backlight = createPoll("LIGHT:100%", 100, [
  "sh",
  "-c",
  'cur=$(cat /sys/class/backlight/intel_backlight/brightness 2>/dev/null | head -n1); max=$(cat /sys/class/backlight/intel_backlight/max_brightness 2>/dev/null | head -n1); if [ -n "$cur" ] && [ -n "$max" ]; then awk -v c=$cur -v m=$max \'BEGIN {printf "LIGHT:%.0f%%", (c/m)*100}\'; fi',
]);

// --- 8. Ваш кастомный USB-виджет ---
const usbData = createPoll(
  { text: "", tooltip: "" },
  1000,
  [
    "sh",
    "-c",
    'paths=($(findmnt -ln -o TARGET | grep \'^/run/media/rdf-2041/\')); count=${#paths[@]}; if [ $count -eq 0 ]; then echo \'{"text": "", "tooltip": ""}\'; exit 0; fi; idx=$(cat /tmp/active_usb_idx 2>/dev/null || echo 0); if [ $idx -ge $count ] || [ $idx -lt 0 ]; then idx=0; echo 0 > /tmp/active_usb_idx; fi; active_path=${paths[$idx]}; active_name=$(basename "$active_path"); echo "{\\"text\\": \\"  $active_name ($((idx+1))/$count)\\", \\"tooltip\\": \\"Путь: $active_path\\"}"',
  ],
  (out) => {
    try {
      return JSON.parse(out);
    } catch {
      return { text: "", tooltip: "" };
    }
  },
);

// --- 9. Ваш кастомный MPRIS-плеер ---
const mprisData = createPoll(
  { text: "", tooltip: "" },
  100,
  [
    "sh",
    "-c",
    'players=($(playerctl --list-all 2>/dev/null)); count=${#players[@]}; if [ $count -eq 0 ]; then echo \'{"text": "", "tooltip": ""}\'; exit 0; fi; idx=$(cat /tmp/active_player_idx 2>/dev/null || echo 0); if [ $idx -ge $count ] || [ $idx -lt 0 ]; then idx=0; echo 0 > /tmp/active_player_idx; fi; active_player=${players[$idx]}; status=$(playerctl -p "$active_player" status 2>/dev/null); name_lower=$(echo "$active_player" | tr \'[:upper:]\' \'[:lower:]\'); text=$(playerctl -p "$active_player" metadata --format \'{{title}} - {{artist}}\' 2>/dev/null | sed \'s/"/\\\\"/g\'); if [ -z "$text" ] || [ "$text" = " - " ]; then text=$(playerctl -p "$active_player" metadata --format \'{{xesam:title}}\' 2>/dev/null | sed \'s/"/\\\\"/g\'); fi; if [ ${#text} -gt 40 ]; then text_short=$(echo "$text" | cut -c1-37)"..."; else text_short="$text"; fi; if [ "$status" = "Paused" ]; then icon="▶ "; else if [[ "$name_lower" == *spotify* ]]; then icon=" "; elif [[ "$name_lower" == *firefox* ]] || [[ "$name_lower" == *mozilla* ]]; then icon=" "; elif [[ "$name_lower" == *vlc* ]]; then icon="   "; else icon="🎵 "; fi; fi; pos_raw=$(playerctl -p "$active_player" position 2>/dev/null || echo 0); pos_sec=${pos_raw%%.*}; len_raw=$(playerctl -p "$active_player" metadata mpris:length 2>/dev/null || echo 0); len_sec=$((len_raw / 1000000)); if [ $len_sec -gt 0 ]; then time_str=$(printf "[%02d:%02d / %02d:%02d]" $((pos_sec / 60)) $((pos_sec % 60)) $((len_sec / 60)) $((len_sec % 60))); else time_str=$(printf "[%02d:%02d]" $((pos_sec / 60)) $((pos_sec % 60))); fi; echo "{\\"text\\": \\"$icon $text_short $time_str ($((idx+1))/$count)\\", \\"tooltip\\": \\"Плеер: $active_player\\\\nНазвание: $text\\\\nВремя: $time_str\\"}"',
  ],
  (out) => {
    try {
      return JSON.parse(out);
    } catch {
      return { text: "", tooltip: "" };
    }
  },
);

// --- 10. Рабочие столы Hyprland (под вашу Lua-сборку) ---
const wsState = createPoll(
  { active: 1, list: [1] },
  100,
  [
    "sh",
    "-c",
    'active=$(hyprctl activeworkspace -j | jq -r \'.id\'); list=$(hyprctl workspaces -j | jq -c \'[.[].id | select(. > 0)] | sort\'); echo "{\\"active\\": $active, \\"list\\": $list}"',
  ],
  (out) => {
    try {
      return JSON.parse(out);
    } catch {
      return { active: 1, list: [1] };
    }
  },
);

const btopTooltip = createPoll("Загрузка...", 2000, [
    "sh",
    "-c",
    "python3 ~/.config/ags/scripts/sysinfo_btop.py"
]);

const memTooltip = createPoll("Загрузка...", 2000, [
    "sh",
    "-c",
    "python3 ~/.config/ags/scripts/meminfo_btop.py"
]);

// --- Компонент системного трея (GTK4) ---
function SysTray() {
  const tray = Tray.get_default();
  const items = createBinding(tray, "items");

  return (
    <box cssClasses={["tray"]} spacing={0}>
      <For each={items}>
        {(item) => (
          <menubutton
            cssClasses={["tray-item"]}
            tooltipMarkup={createBinding(item, "tooltipMarkup")}
            menuModel={createBinding(item, "menuModel")}
            $={(self) => {
              self.insert_action_group("dbusmenu", item.actionGroup);
              const id = item.connect("notify::action-group", () => {
                self.insert_action_group("dbusmenu", item.actionGroup);
              });
              self.connect("destroy", () => item.disconnect(id));

              const lclick = new Gtk.GestureClick({
                button: 1,
                propagationPhase: Gtk.PropagationPhase.CAPTURE,
              });
              lclick.connect("pressed", () => {
                if (item.isMenu) self.popup();
                else item.activate(0, 0);
              });
              self.add_controller(lclick);
            }}
          >
            <image gicon={createBinding(item, "gicon")} pixelSize={14} />
          </menubutton>
        )}
      </For>
    </box>
  );
}



// --- Главная верхняя панель ---
export default function Bar(gdkmonitor: Gdk.Monitor) {
  const { TOP, LEFT, RIGHT } = Astal.WindowAnchor;

  return (
    <window
      visible
      name="bar"
      cssClasses={["Bar"]}
      gdkmonitor={gdkmonitor}
      exclusivity={Astal.Exclusivity.EXCLUSIVE}
      anchor={TOP | LEFT | RIGHT}
      application={app}
    >
      <centerbox cssClasses={["bar-container"]}>
        {/* === ЛЕВАЯ ЧАСТЬ === */}
        <box $type="start" spacing={6}>
          {/* Launcher */}
          <button
            cssClasses={["launcher"]}
            onClicked={() =>
              run(
                "rofi -show drun -theme-str 'window { location: center; anchor: center; y-offset: 0px; }'",
              )
            }
          >
            <label label=" 󰣇 " />
          </button>

          {/* Диспетчер процессов */}
          <button
            cssClasses={["procs"]}
            tooltipText="Диспетчер процессов"
            $={(self) => {
              const click = new Gtk.GestureClick({ button: 3 });
              click.connect("pressed", () => run("kitty sudo btop"));
              self.add_controller(click);
            }}
            onClicked={() => run("rofi -show 'Процессы'")}
          >
            <label label="" />
          </button>

          {/* Системный трей */}
          <SysTray />

          {/* Рабочие столы Hyprland (без пересоздания кнопок) */}
          <box cssClasses={["workspaces"]} spacing={2}>
            {[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].map((id) => (
              <button
                visible={wsState((s) => s.list.includes(id) || s.active === id)}
                cssClasses={wsState((s) =>
                  s.active === id ? ["focused"] : [],
                )}
                onClicked={() =>
                  run(`hyprctl dispatch 'hl.dsp.focus({ workspace = ${id} })'`)
                }
              >
                <label label={String(id)} />
              </button>
            ))}
            <button
              cssClasses={["add-ws"]}
              onClicked={() =>
                run("hyprctl dispatch 'hl.dsp.focus({ workspace = \"+1\" })'")
              }
            >
              <label label="+" />
            </button>
          </box>

          {/* Кастомный USB-модуль */}
          <button
            cssClasses={["usb"]}
            visible={usbData((u) => u.text !== "")}
            tooltipText={usbData((u) => u.tooltip)}
            onClicked={() =>
              run(
                'paths=($(findmnt -ln -o TARGET | grep \'^/run/media/rdf-2041/\')); idx=$(cat /tmp/active_usb_idx 2>/dev/null || echo 0); active_path=${paths[$idx]}; [ -d "$active_path" ] && dolphin "$active_path"',
              )
            }
            $={(self) => {
              const rclick = new Gtk.GestureClick({ button: 3 });
              rclick.connect("pressed", () =>
                run(
                  'paths=($(findmnt -ln -o TARGET | grep \'^/run/media/rdf-2041/\')); idx=$(cat /tmp/active_usb_idx 2>/dev/null || echo 0); active_path=${paths[$idx]}; active_name=$(basename "$active_path"); if [ -n "$active_path" ]; then pkill -f "dolphin $active_path"; udiskie-umount "$active_path" && notify-send "USB-накопитель" "Диск $active_name успешно извлечен!"; echo 0 > /tmp/active_usb_idx; fi',
                ),
              );
              self.add_controller(rclick);

              const scroll = new Gtk.EventControllerScroll({
                flags: Gtk.EventControllerScrollFlags.VERTICAL,
              });
              scroll.connect("scroll", (_, _dx, dy) => {
                const dir = dy < 0 ? "+ 1" : "- 1 + count";
                run(
                  `paths=($(findmnt -ln -o TARGET | grep '^/run/media/rdf-2041/')); count=\${#paths[@]}; if [ $count -gt 1 ]; then idx=$(cat /tmp/active_usb_idx 2>/dev/null || echo 0); idx=$(( (idx ${dir}) % count )); echo $idx > /tmp/active_usb_idx; fi`,
                );
              });
              self.add_controller(scroll);
            }}
          >
            <label label={usbData((u) => u.text)} />
          </button>
        </box>

        <box $type="center" spacing={10}>
          <button
            cssClasses={["mpris"]}
            visible={mprisData((m) => m.text !== "")}
            tooltipText={mprisData((m) => m.tooltip)}
            onClicked={() =>
              run(
                'players=($(playerctl --list-all 2>/dev/null)); idx=$(cat /tmp/active_player_idx 2>/dev/null || echo 0); active_player=${players[$idx]}; [ -n "$active_player" ] && playerctl -p "$active_player" play-pause',
              )
            }
            $={(self) => {
              const rclick = new Gtk.GestureClick({ button: 3 });
              rclick.connect("pressed", () =>
                run(
                  'players=($(playerctl --list-all 2>/dev/null)); idx=$(cat /tmp/active_player_idx 2>/dev/null || echo 0); active_player=${players[$idx]}; [ -n "$active_player" ] && playerctl -p "$active_player" next',
                ),
              );
              self.add_controller(rclick);

              const mclick = new Gtk.GestureClick({ button: 2 });
              mclick.connect("pressed", () =>
                run(
                  'players=($(playerctl --list-all 2>/dev/null)); idx=$(cat /tmp/active_player_idx 2>/dev/null || echo 0); active_player=${players[$idx]}; [ -n "$active_player" ] && playerctl -p "$active_player" previous',
                ),
              );
              self.add_controller(mclick);

              const scroll = new Gtk.EventControllerScroll({
                flags: Gtk.EventControllerScrollFlags.VERTICAL,
                propagationPhase: Gtk.PropagationPhase.CAPTURE,
              });

              scroll.connect("scroll", (_, _dx, dy) => {
                const dir = dy < 0 ? "+ 1" : "- 1 + count";
                run(
                  `players=($(playerctl --list-all 2>/dev/null)); count=\${#players[@]}; if [ $count -gt 1 ]; then idx=$(cat /tmp/active_player_idx 2>/dev/null || echo 0); idx=$(( (idx ${dir}) % count )); echo $idx > /tmp/active_player_idx; fi`,
                );
              });
              self.add_controller(scroll);
            }}
          >
            <label label={mprisData((m) => m.text)} />
          </button>

          <label cssClasses={["uptime"]} label={uptime} />
          <label cssClasses={["battery"]} label={battery} />
          <button
            cssClasses={["clock"]}
            tooltipText={calTooltip}
            onClicked={() => setShowDate(!showDate.get())}
            $={(self) => {
              const rclick = new Gtk.GestureClick({
                button: 3,
                propagationPhase: Gtk.PropagationPhase.CAPTURE,
              });
              rclick.connect("pressed", () =>
                run(
                  "pkill yad || yad --calendar --width=250 --height=200 --undecorated --fixed --posx=830 --posy=45",
                ),
              );
              self.add_controller(rclick);

              const mclick = new Gtk.GestureClick({
                button: 2,
                propagationPhase: Gtk.PropagationPhase.CAPTURE,
              });
              mclick.connect("pressed", () => run("gnome-calendar"));
              self.add_controller(mclick);
            }}
          >
            <box>
              <label visible={showDate((d) => !d)} label={timeText} />
              <label visible={showDate} label={date} />
            </box>
          </button>

          <button
            cssClasses={["language"]}
            onClicked={() => run("hyprctl switchxkblayout all next")}
          >
            <label label={lang} />
          </button>
        </box>

        <box $type="end" spacing={8}>
          <button
    cssClasses={["cpu"]}
    tooltipMarkup={btopTooltip}
    onClicked={() => execAsync("kitty -e btop")}
>
    <label label={cpu} />
</button>
<button
    cssClasses={["gpu"]}
    tooltipMarkup={btopTooltip}
    onClicked={() => execAsync("kitty -e btop")}
>
    <label label={gpu} />
</button>

          <button
    cssClasses={["memory"]}
    tooltipMarkup={memTooltip}
    onClicked={() => execAsync("kitty -e btop")}
>
    <label label={ram} />
</button>


          <button
            cssClasses={["volume"]}
            onClicked={() => execAsync("pavucontrol")}
            $={(self) => {
              const scroll = new Gtk.EventControllerScroll({
                flags: Gtk.EventControllerScrollFlags.VERTICAL,
              });
              scroll.connect("scroll", (_, _dx, dy) => {
                if (dy < 0) {
                  run(
                    "V=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}'); NEW=$(( ((V + 4) / 5) * 5 + 5 )); [ $NEW -le 100 ] && wpctl set-volume @DEFAULT_AUDIO_SINK@ ${NEW}%",
                  );
                } else {
                  run(
                    "V=$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)}'); NEW=$(( ((V - 1) / 5) * 5 - 5 )); [ $NEW -ge 0 ] && wpctl set-volume @DEFAULT_AUDIO_SINK@ ${NEW}% || wpctl set-volume @DEFAULT_AUDIO_SINK@ 0%",
                  );
                }
              });
              self.add_controller(scroll);
            }}
          >
            <label label={audioOut} />
          </button>

          <button
            cssClasses={["mic"]}
            onClicked={() => execAsync("pavucontrol")}
          >
            <label label={audioIn} />
          </button>

          <button
            cssClasses={["backlight"]}
            onClicked={() =>
              run("brightness-controller || generic-bl-slider || nwg-displays")
            }
            $={(self) => {
              const scroll = new Gtk.EventControllerScroll({
                flags: Gtk.EventControllerScrollFlags.BOTH_AXES,
                propagationPhase: Gtk.PropagationPhase.CAPTURE,
              });
              scroll.connect("scroll", (_, _dx, dy) => {
                if (dy !== 0) {
                  run(
                    dy < 0
                      ? "brightnessctl -d intel_backlight set +5%"
                      : "brightnessctl -d intel_backlight set 5%-",
                  );
                }
                return true;
              });
              self.add_controller(scroll);
            }}
          >
            <label label={backlight} />
          </button>

          <button
            cssClasses={["bluetooth"]}
            tooltipText={btData((b) => b.tooltip)}
            onClicked={() => execAsync("blueman-manager")}
          >
            <label label={btData((b) => b.text)} />
          </button>

          <button
            cssClasses={["power"]}
            onClicked={() => run("~/.config/waybar/scripts/powermenu.sh")}
          >
            <label label="⏻" />
          </button>
        </box>
      </centerbox>
    </window>
  );
}
