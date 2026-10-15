#!/usr/bin/env bash
# Bootstrap a fresh Ubuntu/WSL machine. Idempotent: safe to re-run.
# Prerequisite for corporate networks (Zscaler): see README.md, step 0.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
have() { command -v "$1" >/dev/null 2>&1; }

link() { # link <source> <target>
  mkdir -p "$(dirname "$2")"
  if [ -e "$2" ] && [ ! -L "$2" ]; then mv "$2" "$2.bak"; fi
  ln -sfn "$1" "$2"
}

echo "==> apt packages"
sudo apt update
sudo apt install -y zsh git curl build-essential unzip jq xclip bat highlight \
  ca-certificates lazygit

echo "==> yazi (apt repo)"
if ! have yazi; then
  curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | sudo tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null
  echo 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' | sudo tee /etc/apt/sources.list.d/yazi.list >/dev/null
  sudo apt update && sudo apt install -y yazi
fi

echo "==> oh-my-zsh + plugins"
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended --keep-zshrc
fi
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
[ -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ] || \
  git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
[ -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ] || \
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "==> starship"
have starship || curl -sS https://starship.rs/install.sh | sh -s -- -y

echo "==> rust (rustup + cargo tools)"
have cargo || curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
# shellcheck disable=SC1091
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
have cargo-binstall || cargo install cargo-binstall --locked
for crate in make release watch machete nextest llvm-cov sort; do
  have cargo-$crate || cargo binstall --no-confirm "cargo-$crate"
done
have cog || cargo binstall --no-confirme cocogitto

echo "==> fnm (node)"
have fnm || [ -x "$HOME/.local/share/fnm/fnm" ] || \
  curl -fsSL https://fnm.vercel.app/install | bash -s -- --skip-shell

echo "==> mise"
have mise || [ -x "$HOME/.local/bin/mise" ] || \
  curl -fsSL https://mise.run/zsh | sh

echo "==> claude code"
have claude || curl -fsSL https://claude.ai/install.sh | bash

echo "==> dotfiles (symlinks)"
link "$REPO/zsh/.zshrc"        "$HOME/.zshrc"
link "$REPO/zsh/starship.toml" "$HOME/.config/starship.toml"
link "$REPO/.gitconfig"        "$HOME/.gitconfig"

echo "==> wezterm (Windows side, copied: Windows can't follow WSL symlinks)"
if have cmd.exe && have wslpath; then
  WIN_HOME="$(wslpath -u "$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null | tr -d '\r')")"
  cp "$REPO/wezterm/.wezterm.lua" "$WIN_HOME/.wezterm.lua"
else
  echo "    not on WSL, skipped"
fi

echo "==> windows terminal (copied, so the repo holds the real file)"
if have cmd.exe && have wslpath; then
  WIN_LOCALAPPDATA="$(wslpath -u "$(cmd.exe /c 'echo %LOCALAPPDATA%' 2>/dev/null | tr -d '\r')")"
  WT_DIR="$WIN_LOCALAPPDATA/Packages/Microsoft.WindowsTerminal_8wekyb3d8bbwe/LocalState"
  if [ -d "$WT_DIR" ]; then
    cp "$REPO/windows/terminal/settings.json" "$WT_DIR/settings.json"
  else
    echo "    Windows Terminal not found, skipped (launch it once first)"
  fi
else
  echo "    not on WSL, skipped"
fi

echo "==> default shell"
[ "$(basename "$SHELL")" = "zsh" ] || chsh -s "$(command -v zsh)"

echo "Done. Manual steps remaining: see README.md (ssh key, claude skills)."
