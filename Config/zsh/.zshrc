# Personal PATH additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$PATH:$HOME/scripts/tools"

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.oh-my-zsh"
# Set name of the theme to load -
ZSH_THEME="robbyrussell"
# Example format: plugins=(rails git textmate ruby lighthouse)
plugins=(git github tmux vscode)

source $ZSH/oh-my-zsh.sh


# Change the auto-update behaviour
zstyle ':omz:update' mode auto      # update automatically without asking
# You can set one of the three optional formats:
HIST_STAMPS="yyyy-mm-dd"



# User configuration

## Use RStudio as a Git editor when launched from RStudio
if [ -n "$RSTUDIO" ]; then
  export GIT_EDITOR="rstudio"
fi

# You may need to set your language environment manually
# export LANG=en_US.UTF-8
