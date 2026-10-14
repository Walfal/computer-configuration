-- ~/.wezterm.lua  (or %USERPROFILE%\.wezterm.lua on Windows)
-- Minimal config: keep WezTerm defaults for everything else (fonts, colors,
-- tab bar, keybindings...). Only what you actually asked for:
--   1) WSL (Rust) + bash.exe (dotnet) as two selectable shells
--   2) Dynamic, per-project session restore across reboots (via workspaces)

local wezterm = require("wezterm")
local config = wezterm.config_builder()

config.color_scheme = 'Windows NT (base16)'

-- A stray ESC (\u{1b}) reaches the renderer at startup and no font has a glyph
-- for it, which pops a "no fonts contain glyphs" toast. Harmless, so silence it.
config.warn_about_missing_glyphs = false

-- ============================================================
-- 1) Two shells side by side
-- ============================================================
config.wsl_domains = {
  {
    name = "WSL:Ubuntu",
    distribution = "Ubuntu",   -- check exact name with: wsl -l -v
    default_cwd = "~",
  },
}

config.default_domain = "WSL:Ubuntu"

config.exec_domains = {
  wezterm.exec_domain("bash.exe", function(cmd)
    cmd.args = { "C:\\Users\\x2034603\\AppData\\Local\\Programs\\Git\\bin\\bash.exe", "--login", "-i" }
    return cmd
  end),
}

-- ============================================================
-- 2) Shift+Enter inserts a newline in Claude Code (sends Esc+Enter)
-- ============================================================
config.keys = {
  {
    key = "Enter",
    mods = "SHIFT",
    action = wezterm.action.SendString("\x1b\r"),
  },
}

return config
