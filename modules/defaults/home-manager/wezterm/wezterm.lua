local wezterm = require 'wezterm'

local config = wezterm.config_builder()

local system_appearance = wezterm.gui.get_appearance()
local system_appearance_light = string.match(system_appearance, 'Light')

config.color_scheme = system_appearance_light
  and 'Ocean (light) (terminal.sexy)'
  or 'Oceanic-Next'
-- config.font = wezterm.font_with_fallback { 'Fira Code' }

config.initial_rows = 60
config.initial_cols = 200

-- https://github.com/wez/wezterm/issues/5990
config.front_end = "WebGpu"

local act = wezterm.action
config.keys = {
  -- tab navigation
  { mods = 'SUPER|ALT', key = "LeftArrow", action = act.ActivateTabRelative(-1) },
  { mods = 'SUPER|ALT', key = "RightArrow", action = act.ActivateTabRelative(1) },

  -- cursor control
  -- { mods = 'SUPER', key = "LeftArrow", action = act.CopyMode 'MoveToStartOfLine' },
  -- { mods = 'SUPER', key = "RightArrow", action = act.CopyMode 'MoveToEndOfLineContent' },

  -- command pallette
  { mods = 'SUPER|SHIFT', key = "P", action = act.ActivateCommandPalette },
}

config.default_cursor_style = 'BlinkingBar'

return config
