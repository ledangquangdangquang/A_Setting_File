local wezterm = require("wezterm")
local config = wezterm.config_builder()
local brightness = 0.03

-- Lấy thư mục home
local user_home = os.getenv("HOME") or os.getenv("USERPROFILE")

-- Đường dẫn thư mục ảnh (chỉnh sửa đúng cú pháp cho Windows)
local background_folder = "D:/IMAGE"

-- Chọn ảnh nền ngẫu nhiên từ thư mục
local function pick_random_background(folder)
  local handle = io.popen('dir /b "' .. folder .. '"')
  if handle then
    local files = handle:read("*a")
    handle:close()

    local images = {}
    for file in string.gmatch(files, "[^\r\n]+") do
      table.insert(images, file)
    end

    if #images > 0 then
      return folder .. "/" .. images[math.random(#images)]
    end
  end
  return nil
end

-- Cài đặt hình nền mặc định
local bg_image = user_home .. "/.config/nvim/bg/bg.jpg"
config.window_background_image = bg_image
config.window_background_image_hsb = {
  brightness = brightness,
  hue = 1.0,
  saturation = 0.8,
}

-- Cài đặt cửa sổ
config.window_background_opacity = 0.90
config.window_padding = {
  left = 2,
  right = 2,
  top = 2,
  bottom = 2,
}
config.window_decorations = "NONE"
config.enable_tab_bar = false
config.hide_tab_bar_if_only_one_tab = true

-- Giao diện
config.color_scheme = "Tokyo Night"
config.font = wezterm.font("FiraCode Nerd Font Mono", { weight = "Medium", stretch = "Expanded" })
config.font_size = 16
config.default_cursor_style = "BlinkingUnderline"
config.cursor_thickness = 2
config.default_prog = { "C:\\Users\\quang\\scoop\\apps\\git\\current\\bin\\bash.exe", "-l" }
config.default_cwd = "D:\\"


-- Phím tắt
config.keys = {
  {
    key = 'n',
    mods = 'SHIFT|CTRL',
    action = wezterm.action.ToggleFullScreen,
  },
  {
    key = "b",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window)
      local new_bg = pick_random_background(background_folder)
      if new_bg then
        bg_image = new_bg
        window:set_config_overrides({
          window_background_image = bg_image,
        })
        wezterm.log_info("New bg: " .. bg_image)
      else
        wezterm.log_error("Could not find bg image")
      end
    end),
  },
  {
    key = "L",
    mods = "CTRL|SHIFT",
    action = wezterm.action.OpenLinkAtMouseCursor,
  },
  {
    key = ">",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window)
      brightness = math.min(brightness + 0.01, 1.0)
      window:set_config_overrides({
        window_background_image_hsb = {
          brightness = brightness,
          hue = 1.0,
          saturation = 0.8,
        },
        window_background_image = bg_image
      })
    end),
  },
  {
    key = "<",
    mods = "CTRL|SHIFT",
    action = wezterm.action_callback(function(window)
      brightness = math.max(brightness - 0.01, 0.01)
      window:set_config_overrides({
        window_background_image_hsb = {
          brightness = brightness,
          hue = 1.0,
          saturation = 0.8,
        },
        window_background_image = bg_image
      })
    end),
  },
}

return config
