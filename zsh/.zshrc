# Symlinked to ~/.zshrc by install.sh. Real config lives in the modules below.
ZSH_CONF="${ZSH_CONF:-$HOME/dev/tools/computer-configuration/zsh}"

HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

export ZSH="$HOME/.oh-my-zsh"
export PATH="$HOME/.local/bin:$PATH"
export BROWSER="/mnt/c/Users/x2034603/AppData/Local/Vivaldi/Application/vivaldi.exe"

plugins=(
  git
  colored-man-pages
  command-not-found
  common-aliases
  sudo
  zsh-autosuggestions
  zsh-syntax-highlighting
)

source "$ZSH/oh-my-zsh.sh"
eval "$(starship init zsh)"
eval "$(/home/raph/.local/bin/mise activate zsh)"

# fnm (node version manager)
FNM_PATH="$HOME/.local/share/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="$FNM_PATH:$PATH"
  eval "$(fnm env --shell zsh)"
fi

source "$ZSH_CONF/aliases.zsh"
source "$ZSH_CONF/functions.zsh"

