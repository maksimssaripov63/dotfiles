# export XDG_CONFIG_HOME="$HOME/dotfiles/.config"

# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="robbyrussell"

# ---- 🌓 ГЛОБАЛЬНЫЙ ТЁМНЫЙ РЕЖИМ ДЛЯ ВСЕХ ПРИЛОЖЕНИЙ ----
export GTK_THEME="Adwaita:dark"


# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change the frequency the auto-updater is run (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line to set how old an update must be before it's applied, manually or via the auto-updater (in days).
# zstyle ':omz:update' cooldown 10

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
    git
    zsh-autosuggestions
    sudo
    history
    zsh-syntax-highlighting
    you-should-use
    dirhistory
    colored-man-pages
    command-not-found
    extract
    python
    aliases
    alias-finder
    battery
    #zoxide
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='nvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

eval "$(starship init zsh)"
#eval "echo 'Dunaj-5.4'"
export STARSHIP_CONFIG="$HOME/dotfiles/.config/starship.toml"

alias ard='~/.platformio/penv/bin/pio device monitor --port /dev/ttyUSB0 --baud 9600'
alias ccat='batcat --style=numbers,changes --language=cpp'
alias color_log='~/.platformio/penv/bin/pio device monitor --port /dev/ttyUSB0 --baud 9600 | batcat --language=log'
export TERM=xterm-256color
alias cam="sudo modprobe v4l2loopback exclusive_caps=1 card_label='OBS Virtual Video' && obs --startvirtualcam & sleep 3 && qrca"

-s() {
    local query="$*"
    if [[ -n "$query" ]]; then
        local encoded_query="${(g:eo:)query}"
        firefox "https://www.google.com/search?client=ubuntu-sn&channel=fs&q=${encoded_query}" >/dev/null 2>&1 &
    else
        firefox >/dev/null 2>&1 &
    fi
}

-y() {
    local query="$*"
    if [[ -n "$query" ]]; then
        local encoded_query="${(g:eo:)query}"
        firefox "https://youtube.com/results?search_query=${encoded_query}" >/dev/null 2>&1 &
    else
        firefox "https://youtube.com" >/dev/null 2>&1 &
    fi
}

alias gemini="firefox 'https://www.google.com/search?hl=ru&atvm=1&mtid=R3o5aqqCGtDWwPAPy8HyuQM&ved=2ahUKEwiE2bqC4OCVAxXMNxAIHc7oH20Qoo4PegYIAggCEAU&udm=50&zs=1' > /dev/null 2>&1 &"

# Created by `pipx` on 2026-07-26 20:27:54
export PATH="$PATH:/home/rdf-2041/.local/bin"

# alias vs_mind="code . --profile 'Mindstorms'"
# alias vs_ard="code . --profile 'Arduino'"
alias zshrc="nvim ~/dotfiles/.zshrc"

zstyle ':completion:*' menu select

alias music="firefox 'https://music.yandex.ru/' >/dev/null 2>&1 &"
alias tg="telegram-desktop > /dev/null 2>&1 &"
alias vk="firefox 'https://vk.ru/feed'"

alias paint='pygmentize -f terminal256 -O style=default -g'

alias hack="python3 ~/Документы/Python/.vscode/script.py"

alias ds="discord > /dev/null 2>&1 &"
#alias obs="obs-studio > /dev/null 2>&1 &"
alias phone="kdeconnect-app > /dev/null 2>&1 &"


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

-c() {
    "clear"
}

alias kimi='firefox "https://www.kimi.com/ru" > /dev/null 2>&1 &'

alias ff="firefox > /dev/null 2>&1 &"

alias gh="firefox 'https://github.com/' > /dev/null 2>&1 &"

alias hypr="nvim ~/dotfiles/.config/hypr/hyprland.conf"
#source ~/powerlevel10k/powerlevel10k.zsh-theme

alias office="onlyoffice-desktopeditors > /dev/null 2>&1 &"

alias mindustry='steam steam://rungameid/1127400'

# Быстрое подключение к Bluetooth по имени
con() {
    if [ -z "$1" ]; then
        echo "Использование: con [Имя_Устройства]"
        return 1
    fi
    
    # Ищем MAC-адрес устройства по его имени среди сопряженных
    mac=$(bluetoothctl devices | grep -i "$1" | awk '{print $2}')
    
    if [ -z "$mac" ]; then
        echo "Устройство с именем '$1' не найдено в списке сопряженных."
        echo "Проверьте список доступных устройств командой: bluetoothctl devices"
        return 1
    fi
    
    echo "Найдено устройство: $1 ($mac). Подключаюсь..."
    bluetoothctl connect "$mac"
}

dis() {
    if [ -z "$1" ]; then
        echo "Использование: dis [Имя_Устройства]"
        return 1
    fi
    local mac
    mac=$(bluetoothctl devices | grep -i "$1" | head -n 1 | awk '{print $2}')
    if [ -z "$mac" ]; then
        echo "Устройство '$1' не найдено в списке сопряженных."
        return 1
    fi
    echo "Отключаюсь от: $1 ($mac)..."
    bluetoothctl disconnect "$mac"
}

# 3. Функция генерации списка имен для Tab-автодополнения
_bluetooth_devices_completion() {
    local -a devices
    # Извлекаем только человеческие имена сопряженных устройств (все поля после MAC-адреса)
    devices=("${(@f)$(bluetoothctl devices | awk '{for(i=3;i<=NF;i++) printf "%s ", $i; print ""}')}")
    # Передаем список в движок автодополнения Zsh
    compadd -a devices
}

# Регистрация автодополнения для обеих команд
compdef _bluetooth_devices_completion con
compdef _bluetooth_devices_completion dis

alias swifi="nmtui"

export EDITOR=nvim
export SUDO_EDITOR=nvim

alias ghostty-conf="nvim ~/dotfiles/.config/ghostty/config.ghostty"

alias swww="~/.local/bin/waypaper > /dev/null 2>&1 &"

alias гойда="echo 'пшёл нах...'" 

export PATH="$PATH:$HOME/.platformio/penv/bin"

alias pdf="pdftotext \"\$1\" - | less"

alias kde="kdeconnect-app &"
setopt prompt_subst

alias sync-dots="~/dotfiles/sync.sh"

alias gpa="cd ~/dotfiles && git add . && git commit -m \"Auto-backup: \$(date +\"%Y-%m-%d %H:%M:%S\")\" && git push -f origin main"

# быстрые команды для управления zapret
alias zapret-config='$HOME/zapret-configs/install.sh'
alias zapret-utils='$HOME/zapret-configs/utils-zapret.sh'

alias Dunaj="~/Documents/PlatformIO/Dunaj && figlet -f slant 'Dunaj'"
alias gpad="cd ~/Documents/PlatformIO/Dunaj && git add . && git commit -m \"Auto-backup: \$(date +\"%Y-%m-%d %H:%M:%S\")\" && git push -f origin master"

eval "figlet -f slant 'Dunaj' | lolcat"

alias msoffice="firefox 'https://onedrive.live.com/' > /dev/null 2>&1 &"

alias l='lsd -l'
alias la='lsd -a'
alias lla='lsd -la'
alias lt='lsd --tree'

# ---- 🛸 ОПТИМИЗИРОВАННЫЙ ЗАПУСК 3D-СТУДИИ BLENDER (60+ FPS) ----
alias bld="WAYLAND_DISPLAY= __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia blender &"

