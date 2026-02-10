local wezterm = require 'wezterm'
local config = wezterm.config_builder()

config.default_prog = { 'pwsh.exe' }

config.font_dirs = { 'C:\\Windows\\Fonts' }
config.font_size = 12.0
config.font = wezterm.font_with_fallback ({
  {family='Monaspace Radon Var', weight=450, stretch='Normal', style='Normal'},
  'Fira Code',
  'SourceCodeVF',
  'iA Writer Duo V',
})

config.front_end = "OpenGL"
config.freetype_load_target = "Light"
config.freetype_render_target = "HorizontalLcd"

config.window_decorations = "RESIZE"
config.use_fancy_tab_bar = false
config.color_scheme = 'Tomorrow Night Burns'

config.window_padding = {
  left = 20, right = 20, top = 20, bottom = 20,
}

return config
