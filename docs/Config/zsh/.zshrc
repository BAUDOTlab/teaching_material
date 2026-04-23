# Personal PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/scripts/tools"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme and plugins
ZSH_THEME="robbyrussell"
plugins=(git github tmux vscode)

# Oh My Zsh settings should be defined before sourcing it.
zstyle ':omz:update' mode auto
HIST_STAMPS="yyyy-mm-dd"

source "$ZSH/oh-my-zsh.sh"

# User configuration

## Use RStudio as Git editor when launched from RStudio
if [ -n "$RSTUDIO" ]; then
  export GIT_EDITOR="rstudio"
fi

# Colours for shell
autoload -U colors && colors
if command -v dircolors >/dev/null 2>&1; then
  eval "$(dircolors -b)"
fi

# File colours for listings and completion menus
LS_COLORS_EXTRA=""

# Core file types
LS_COLORS_EXTRA+="di=1;38;5;39:"
LS_COLORS_EXTRA+="ln=1;36:"
LS_COLORS_EXTRA+="so=1;35:"
LS_COLORS_EXTRA+="pi=33:"
LS_COLORS_EXTRA+="ex=1;32:"

# Devices and special permissions
LS_COLORS_EXTRA+="bd=1;33;44:"
LS_COLORS_EXTRA+="cd=1;33;44:"
LS_COLORS_EXTRA+="su=37;41:"
LS_COLORS_EXTRA+="sg=30;43:"
LS_COLORS_EXTRA+="tw=30;42:"
LS_COLORS_EXTRA+="ow=34;42:"
LS_COLORS_EXTRA+="st=37;44:"
LS_COLORS_EXTRA+="mi=05;37;41:"
LS_COLORS_EXTRA+="or=31;01:"

# Archives and compressed files
LS_COLORS_EXTRA+="*.tar=1;31:"
LS_COLORS_EXTRA+="*.gz=1;31:"
LS_COLORS_EXTRA+="*.zip=1;31:"
LS_COLORS_EXTRA+="*.xz=1;31:"
LS_COLORS_EXTRA+="*.bz2=1;31:"
LS_COLORS_EXTRA+="*.7z=1;31:"

# Documents and media
LS_COLORS_EXTRA+="*.pdf=1;35:"
LS_COLORS_EXTRA+="*.png=1;35:"
LS_COLORS_EXTRA+="*.jpg=1;35:"
LS_COLORS_EXTRA+="*.jpeg=1;35:"
LS_COLORS_EXTRA+="*.svg=1;35:"
LS_COLORS_EXTRA+="*.mp4=1;35:"
LS_COLORS_EXTRA+="*.mp3=1;35:"

# Scripts and source code
LS_COLORS_EXTRA+="*.sh=1;32:"
LS_COLORS_EXTRA+="*.py=1;32:"
LS_COLORS_EXTRA+="*.R=1;32:"

# Markup, data, and configuration
LS_COLORS_EXTRA+="*.qmd=1;33:"
LS_COLORS_EXTRA+="*.Rmd=1;33:"
LS_COLORS_EXTRA+="*.yml=1;33:"
LS_COLORS_EXTRA+="*.yaml=1;33:"
LS_COLORS_EXTRA+="*.json=1;33:"
LS_COLORS_EXTRA+="*.toml=1;33:"
LS_COLORS_EXTRA+="*.md=1;33:"
LS_COLORS_EXTRA+="*.service=1;33:"
LS_COLORS_EXTRA+="*.desktop=1;33:"
LS_COLORS_EXTRA+="*.conf=1;33:"
LS_COLORS_EXTRA+="*.ini=1;33:"
LS_COLORS_EXTRA+="*.zshrc=1;33:"
LS_COLORS_EXTRA+="*.bashrc=1;33:"
LS_COLORS_EXTRA+="*.gitconfig=1;33"

export LS_COLORS="${LS_COLORS:+${LS_COLORS}:}${LS_COLORS_EXTRA}"

# Prefer eza when available, otherwise fall back to GNU ls.
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first --icons'
  alias ll='eza -lh --group-directories-first --icons --git'
  alias la='eza -lah --group-directories-first --icons --git'
  alias lt='eza --tree --level=2 --icons'
else
  alias ls='ls --color=auto -F --group-directories-first'
  alias ll='ls -lh --color=auto -F --group-directories-first'
  alias la='ls -lah --color=auto -F --group-directories-first'
  alias lt='ls --color=auto -F'
fi

# Reuse listing colours in completion menus.
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
