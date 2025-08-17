local lvgl = require("lvgl")
local font = require("font")

local background_color = "#ffffff"
local background_muted = "#f2f2f2"
local text_color = "#000000"
local icon_enabled_color = text_color --"#ff82bc"
local icon_disabled_color = "#999999"
local border_color = "#888888"

local highlight_start_color = "#0499d1"
local highlight_end_color = "#0e6bb1"

local highlight_green_start_color = "#04d199"
local highlight_green_end_color = "#0eb16b"

local disabled_highlight_start_color = "#d1d1d1"
local disabled_highlight_end_color = "#b1b1b1"

local battery_full_width = 17.0
local battery_low_img = lvgl.ImgData("//sd/.themes/tanqua/battery_low.png")

local function highlighted_bg(obj, green)
  obj = obj or {}
  obj.bg_opa = lvgl.OPA(100)
  obj.text_color = "#ffffff"
  obj.bg_color = green and highlight_green_start_color or highlight_start_color
  obj.bg_grad_dir = 1
  obj.bg_grad_color = green and highlight_green_end_color or highlight_end_color
  obj.image_recolor_opa = lvgl.OPA(100)
  obj.image_recolor = "#ffffff"
  return lvgl.Style(obj)
end

local function disabled_highlighted_bg(obj)
  obj = obj or {}
  obj.bg_opa = lvgl.OPA(100)
  obj.text_color = "#ffffff"
  obj.bg_color = disabled_highlight_start_color
  obj.bg_grad_dir = 1
  obj.bg_grad_color = disabled_highlight_end_color
  obj.image_recolor_opa = lvgl.OPA(100)
  obj.image_recolor = "#ffffff"
  return lvgl.Style(obj)
end

local function battery_image(percentage, obj)
  obj = obj or {}

  local current_width = math.floor(battery_full_width * percentage)
  if current_width < 1 then
    current_width = 1
  end

  obj.margin_right = (battery_full_width - current_width) + 2.0
  obj.width = current_width
  if percentage <= 0.4 then
    obj.bg_image_src = battery_low_img
  end

  return lvgl.Style(obj)
end

local theme = {
  base = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(0),
      text_font = font.fusion_12,
    }},
  },
  root = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_image_opa = lvgl.OPA(0),
      bg_opa = lvgl.OPA(100),
      bg_color = background_color,
      text_color = text_color,
    }},
  },
  header = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      bg_color = background_color,
      margin_top = 1,
    }},
  },
  status_bar = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      bg_color = background_color,
      bg_image_opa = lvgl.OPA(100),
      bg_image_src = lvgl.ImgData("//sd/.themes/tanqua/statusbar.png"),
      bg_image_tiled = false,
      margin_top = 0,
      margin_bottom = 1,
      pad_top = 0,
    }},
  },
  status_bar_title = {
    {lvgl.PART.MAIN, lvgl.Style {
      translate_y = -2,
    }},
  },
  pop_up = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      bg_color = background_muted,
    }},
  },
  button = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      pad_left = 1,
      pad_right = 1,
      margin_all = 1,
      bg_color = background_color,
      radius = 4,
      border_color = border_color,
      border_width = 1,
      border_side = 9, -- Bottom right
      outline_color = border_color,
      outline_width = 1,
      image_recolor_opa = lvgl.OPA(100),
      image_recolor = text_color,
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, highlighted_bg()},
    {lvgl.PART.MAIN | lvgl.STATE.PRESSED, lvgl.Style {
      margin_left = 2,
      border_width = 0,
    }},
  },
  listbutton = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_recolor_opa = lvgl.OPA(100),
      image_recolor = text_color,
      flex_cross_place = lvgl.FLEX_ALIGN.CENTER,
      pad_column = 4,
      bg_image_src = lvgl.ImgData("//sd/.themes/tanqua/chevron.png"),
      bg_image_tiled = false,
      bg_image_opa = lvgl.OPA(100),
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, highlighted_bg({
      bg_image_recolor = background_color,
      bg_image_recolor_opa = lvgl.OPA(100),
    })},
  },
  bar = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
    }},
  },
  slider = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      bg_color = background_muted,
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
      border_color = border_color,
      border_width = 1,
      height = 8,
    }},
    {lvgl.PART.INDICATOR, highlighted_bg{
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
      border_color = border_color,
      border_width = 1,
    }},
    {lvgl.PART.KNOB, lvgl.Style {
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
      bg_color = background_muted,
      border_color = border_color,
      border_width = 1,
      border_side = 9,
      outline_color = border_color,
      outline_width = 1,
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, lvgl.Style {
      bg_color = background_muted,
    }},
    {lvgl.PART.KNOB | lvgl.STATE.FOCUSED, highlighted_bg()},
    {lvgl.PART.KNOB | lvgl.STATE.EDITED, lvgl.Style {
      pad_all = 2,
    }},
    {lvgl.PART.INDICATOR | lvgl.STATE.CHECKED, highlighted_bg()},
  },
  scrubber = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      bg_color = background_muted,
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
    }},
    {lvgl.PART.INDICATOR, highlighted_bg{
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
    }},
    {lvgl.PART.KNOB, lvgl.Style {
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
      bg_color = background_muted,
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, lvgl.Style {
      bg_color = background_muted,
    }},
    {lvgl.PART.KNOB | lvgl.STATE.FOCUSED, highlighted_bg{
      pad_all = 1,
    }},
    {lvgl.PART.KNOB | lvgl.STATE.EDITED, lvgl.Style {
      pad_all = 2,
    }},
    {lvgl.PART.INDICATOR | lvgl.STATE.CHECKED, highlighted_bg()},
  },
  switch = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      width = 18,
      height = 10,
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
      bg_color = background_muted,
      border_color = border_color,
      border_width = 1,
    }},
    {lvgl.PART.INDICATOR, lvgl.Style {
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
      bg_color = background_color,
    }},
    {lvgl.PART.INDICATOR | lvgl.STATE.CHECKED, highlighted_bg(nil, true)},
    {lvgl.PART.KNOB, lvgl.Style {
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
      bg_opa = lvgl.OPA(100),
      bg_color = background_muted,
      border_color = border_color,
      border_width = 1,
      border_side = 9,
      outline_color = border_color,
      outline_width = 1,
    }},
    {lvgl.PART.KNOB | lvgl.STATE.FOCUSED, highlighted_bg()},
  },
  dropdown = {
    {lvgl.PART.MAIN, lvgl.Style{
      bg_opa = lvgl.OPA(100),
      radius = 2, 
      pad_all = 2,
      bg_color = background_color,
      border_color = border_color,
      border_width = 1,
      border_side = 9,
      outline_color = border_color,
      outline_width = 1,
      image_recolor_opa = lvgl.OPA(100),
      image_recolor = text_color,
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, highlighted_bg()},
    {lvgl.PART.INDICATOR, lvgl.Style {
      image_recolor_opa = 255,
      image_recolor = text_color,
    }},
  },
  dropdownlist = {
    {lvgl.PART.MAIN, lvgl.Style{
      radius = 2, 
      pad_all = 2,
      border_width = 1,
      border_color = border_color,
      bg_opa = lvgl.OPA(100),
      bg_color = background_color
    }},
    {lvgl.PART.SELECTED | lvgl.STATE.CHECKED, highlighted_bg()},
  },
  database_indicator = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_recolor_opa = 180,
      image_recolor = text_color,
    }},
  },
  back_button = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_recolor_opa = 180,
      image_recolor = icon_enabled_color,
      bg_opa = lvgl.OPA(100),
      bg_color = background_color,
      pad_all = 0,
      translate_y = -1,
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, highlighted_bg()},
  },
  settings_title = {
   {lvgl.PART.MAIN, lvgl.Style {
      pad_top = 2,
      pad_bottom = 4,
      text_font = font.fusion_10,
      text_color = text_color,
    }},
  },
  icon_disabled = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_recolor_opa = 180,
      image_recolor = icon_disabled_color,
      bg_opa = lvgl.OPA(100),
      bg_color = background_color,
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, disabled_highlighted_bg()},
  },
  icon_enabled = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_recolor_opa = 180,
      image_recolor = icon_enabled_color,
      bg_opa = lvgl.OPA(100),
      bg_color = background_color,
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, highlighted_bg()},
  },
  now_playing = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_opa = lvgl.OPA(100),
      radius = 32767, -- LV_RADIUS_CIRCLE = 0x7fff
    }},
  },
  menu_icon = {
    {lvgl.PART.MAIN, lvgl.Style {
      pad_all = 4,
      radius = 4
    }},
  },
  bluetooth_icon = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_recolor_opa = 255,
      image_recolor = text_color,
    }},
  },
  battery = {
    {lvgl.PART.MAIN, battery_image(1.0, {
      height = 8,
      margin_bottom = 2,
      bg_opa = lvgl.OPA(0),
      bg_image_opa = lvgl.OPA(100),
      bg_image_src = lvgl.ImgData("//sd/.themes/tanqua/battery_high.png"),
      bg_image_tiled = true,
      image_opa = lvgl.OPA(0),
    })},
  },
  battery_0 = {
    {lvgl.PART.MAIN, battery_image(0.0)},
  },
  battery_20 = {
    {lvgl.PART.MAIN, battery_image(0.2)},
  },
  battery_40 = {
    {lvgl.PART.MAIN, battery_image(0.4)},
  },
  battery_60 = {
    {lvgl.PART.MAIN, battery_image(0.6)},
  },
  battery_80 = {
    {lvgl.PART.MAIN, battery_image(0.8)},
  },
  battery_100 = {
    {lvgl.PART.MAIN, battery_image(1.0)},
  },
  battery_charge_icon = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_opa = lvgl.OPA(0),
      bg_opa = lvgl.OPA(0),
      bg_image_opa = lvgl.OPA(100),
      bg_image_src = lvgl.ImgData("//sd/.themes/tanqua/battery_charging.png"),
    }},
  },
  battery_charge_icon_state_full_charge = {
    {lvgl.PART.MAIN, lvgl.Style {
      bg_image_src = lvgl.ImgData("//sd/.themes/tanqua/battery_charged.png"),
    }},
  },
  battery_charge_outline = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_opa = lvgl.OPA(0),
    }},
  },
  regulatory_icons = {
    {lvgl.PART.MAIN, lvgl.Style {
      image_recolor_opa = 255,
      image_recolor = text_color,
    }},
  },
}

return theme
