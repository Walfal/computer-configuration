# computer-configuration

Personal setup for a new machine (Ubuntu on WSL2 + Windows host).

| Folder / file | Applied by `install.sh` as | Contents |
|---|---|---|
| `zsh/` | symlinks to `~/.zshrc`, `~/.config/starship.toml` | zsh config: oh-my-zsh, starship, fnm, aliases, functions |
| `.gitconfig` | symlink to `~/.gitconfig` | Git config |
| `wezterm/` | **copy** to `%USERPROFILE%\.wezterm.lua` | WezTerm: WSL + Git Bash domains, Shift+Enter for Claude Code |
| `.vscode/` | manual | VS Code settings, keybindings, extensions |
| `zed/` | manual | Zed theme |

WezTerm is copied, not symlinked, because Windows can't follow a symlink into the WSL
filesystem. After editing `wezterm/.wezterm.lua` in the repo, re-run `install.sh`.

## 1. Bootstrap

```sh
git clone https://github.com/Walfal/computer-configuration.git ~/dev/tools/computer-configuration
~/dev/tools/computer-configuration/install.sh
```

It installs packages, oh-my-zsh and plugins, starship, rust + cargo tools, fnm and
Claude Code, then links/copies the config above. It is safe to re-run.

Then restart the terminal (`wsl --shutdown` from Windows if the default shell didn't change).

## 2. Claude Code skills (global)

Requires node: run `fnm i` in a project, or `fnm install --lts`.

```sh
npx skills add leonardomso/rust-skills --global
npx skills add obra/superpowers/skills/test-driven-development --global
npx skills add vercel-labs/agent-skills/skills/web-design-guidelines --global
npx skills add vercel-labs/agent-skills/skills/react-best-practices --global
for skill in obviously-awesome clean-code refactoring-patterns software-design-philosophy \
             pragmatic-programmer domain-driven-design clean-architecture steve-jobs-design-review; do
  npx skills add "wondelai/skills/$skill" --global
done
```

## Not captured here

- `~/.claude/settings.json` and `~/.claude/statusline.sh` are not in the repo yet.
- Docker (`docker-ce`) was attempted but never confirmed to work; not scripted.
