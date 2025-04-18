local lvgl = require("lvgl")
local font = require("font")

-- BEGIN WIDGET PATCH
local lvgl = require("lvgl")
local power = require("power")
local bluetooth = require("bluetooth")
local font = require("font")
local database = require("database")
local theme = require("theme")
local images = require("images")
local widgets = require("widgets")
local main_menu = require("main_menu")
local backstack = require("backstack")

local img = {
  db = lvgl.ImgData("//lua/img/db.png"),
  chg = lvgl.ImgData("//lua/img/bat/chg.png"),
  chg_outline = lvgl.ImgData("//lua/img/bat/chg_outline.png"),
  bat_100 = lvgl.ImgData("//lua/img/bat/100.png"),
  bat_80 = lvgl.ImgData("//lua/img/bat/80.png"),
  bat_60 = lvgl.ImgData("//lua/img/bat/60.png"),
  bat_40 = lvgl.ImgData("//lua/img/bat/40.png"),
  bat_20 = lvgl.ImgData("//lua/img/bat/20.png"),
  bat_0 = lvgl.ImgData("//lua/img/bat/0.png"),
  bt_conn = lvgl.ImgData("//lua/img/bt_conn.png"),
  bt = lvgl.ImgData("//lua/img/bt.png")
}

local bindings_meta = {}
bindings_meta["__add"] = function(a, b)
  return setmetatable(table.move(a, 1, #a, #b + 1, b), bindings_meta)
end

function widgets.StatusBar(parent, opts)
  local root = parent.root:Object {
    flex = {
      flex_direction = "row",
      justify_content = "flex-start",
      align_items = "center",
      align_content = "center",
    },
    w = lvgl.HOR_RES(),
    h = lvgl.SIZE_CONTENT,
    pad_top = 1,
    pad_bottom = 1,
    pad_left = 4,
    pad_right = 4,
    pad_column = 1,
    scrollbar_mode = lvgl.SCROLLBAR_MODE.OFF,
  }

  if not opts.transparent_bg then
    theme.set_subject(root, "header")
  end
  theme.set_subject(root, "status_bar")

  if not opts.back_cb then
    opts.back_cb = function()
      theme.load_theme("/sd/.themes/tanqua.lua")
      backstack.reset(main_menu:new())
    end
  end
  if opts.title == "" or not opts.title then
    opts.title = "< Reload theme"
  end

  if opts.back_cb or true then
    local back = root:Button {
      w = lvgl.SIZE_CONTENT,
      h = lvgl.SIZE_CONTENT,
    }
    back:Image{src=images.back}
    theme.set_subject(back, "back_button")
    widgets.Description(back, "Back")
    back:onClicked(opts.back_cb)
    back:onevent(lvgl.EVENT.FOCUSED, function()
      local first_view = parent.content
      if not first_view then return end
      while first_view:get_child_cnt() > 0 do
        first_view = first_view:get_child(0)
      end
      if first_view then
        first_view:scroll_to_view_recursive(1)
      end
    end)
  end

  local title = root:Label {
    w = lvgl.PCT(100),
    h = lvgl.SIZE_CONTENT,
    text_font = font.fusion_10,
    text = "",
    align = lvgl.ALIGN.CENTER,
    flex_grow = 1,
    pad_left = 2,
  }
  if opts.title then
    title:set { text = opts.title }
  end
  theme.set_subject(title, "status_bar_title")

  local db_updating = root:Image { src = img.db }
  theme.set_subject(db_updating, "database_indicator")
  local bt_icon = root:Image {}
  local battery_icon = root:Image {}
  local charge_icon = battery_icon:Image { src = img.chg }
  local charge_icon_outline = battery_icon:Image { src = img.chg_outline }
  charge_icon_outline:center();
  charge_icon:center()

  local is_charging = nil
  local percent = nil
  local charge_state = nil

  local function update_battery_icon()
    if is_charging == nil or percent == nil or charge_state == nil then return end
    local src
    theme.set_subject(battery_icon, "battery")
    if percent >= 95 then
      theme.set_subject(battery_icon, "battery_100")
      src = img.bat_100
    elseif percent >= 75 then
      theme.set_subject(battery_icon, "battery_80")
      src = img.bat_80
    elseif percent >= 55 then
      theme.set_subject(battery_icon, "battery_60")
      src = img.bat_60
    elseif percent >= 35 then
      theme.set_subject(battery_icon, "battery_40")
      src = img.bat_40
    elseif percent >= 15 then
      theme.set_subject(battery_icon, "battery_20")
      src = img.bat_20
    else
      theme.set_subject(battery_icon, "battery_0")
      src = img.bat_0
    end
    theme.set_subject(battery_icon, "battery_state_" .. charge_state)
    if is_charging then
      theme.set_subject(battery_icon, "battery_charging")
      theme.set_subject(charge_icon, "battery_charge_icon")
      theme.set_subject(charge_icon, "battery_charge_icon_state_" .. charge_state)
      theme.set_subject(charge_icon_outline, "battery_charge_outline")
      theme.set_subject(charge_icon_outline, "battery_charge_icon_outline_state_" .. charge_state)
      charge_icon:clear_flag(lvgl.FLAG.HIDDEN)
      charge_icon_outline:clear_flag(lvgl.FLAG.HIDDEN)
    else
      charge_icon:add_flag(lvgl.FLAG.HIDDEN)
      charge_icon_outline:add_flag(lvgl.FLAG.HIDDEN)
    end
    battery_icon:set_src(src)
  end

  parent.bindings = {
    database.updating:bind(function(yes)
      if yes then
        db_updating:clear_flag(lvgl.FLAG.HIDDEN)
      else
        db_updating:add_flag(lvgl.FLAG.HIDDEN)
      end
    end),
    power.battery_pct:bind(function(pct)
      percent = pct
      update_battery_icon()
    end),
    power.charge_state:bind(function(state)
      charge_state = state
      update_battery_icon()
    end),
    power.plugged_in:bind(function(p)
      is_charging = p
      update_battery_icon()
    end),
    bluetooth.enabled:bind(function(en)
      if en then
        bt_icon:clear_flag(lvgl.FLAG.HIDDEN)
      else
        bt_icon:add_flag(lvgl.FLAG.HIDDEN)
      end
    end),
    bluetooth.connected:bind(function(connected)
      theme.set_subject(bt_icon, "bluetooth_icon")
      if connected then
        bt_icon:set_src(img.bt_conn)
      else
        bt_icon:set_src(img.bt)
      end
    end),
  }
  setmetatable(parent.bindings, bindings_meta)
end
-- END WIDGET PATCH

local background_color = "#ffffff"
local background_muted = "#f2f2f2"
local text_color = "#000000"
local icon_enabled_color = text_color --"#ff82bc"
local icon_disabled_color = "#999999"
local border_color = "#888888"

local highlight_start_color = "#0499d1"
local highlight_end_color = "#0e6bb1"

local disabled_highlight_start_color = "#d1d1d1"
local disabled_highlight_end_color = "#b1b1b1"

local battery_width = 17.0
local battery_low_img = lvgl.ImgData("//sd/.themes/tanqua/battery_low.png")

local function highlighted_bg(obj)
  obj = obj or {}
  obj.bg_opa = lvgl.OPA(100)
  obj.text_color = "#ffffff"
  obj.bg_color = highlight_start_color
  obj.bg_grad_dir = 1
  obj.bg_grad_color = highlight_end_color
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
      margin_top = 2,
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
    }},
    {lvgl.PART.MAIN | lvgl.STATE.FOCUSED, highlighted_bg()},
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
    {lvgl.PART.INDICATOR | lvgl.STATE.CHECKED, highlighted_bg()},
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
    {lvgl.PART.MAIN, lvgl.Style {
      height = 8,
      margin_right = 2,
      margin_bottom = 2,
      bg_opa = lvgl.OPA(0),
      bg_image_opa = lvgl.OPA(100),
      bg_image_src = lvgl.ImgData("//sd/.themes/tanqua/battery_high.png"),
      bg_image_tiled = true,
      image_opa = lvgl.OPA(0),
    }},
  },
  battery_0 = {
    {lvgl.PART.MAIN, lvgl.Style {
      width = 1.0,
      bg_image_src = battery_low_img,
    }},
  },
  battery_20 = {
    {lvgl.PART.MAIN, lvgl.Style {
      width = battery_width * 0.2,
      bg_image_src = battery_low_img,
    }},
  },
  battery_40 = {
    {lvgl.PART.MAIN, lvgl.Style {
      width = battery_width * 0.4,
      bg_image_src = battery_low_img,
    }},
  },
  battery_60 = {
    {lvgl.PART.MAIN, lvgl.Style {
      width = battery_width * 0.6,
    }},
  },
  battery_80 = {
    {lvgl.PART.MAIN, lvgl.Style {
      width = battery_width * 0.8,
    }},
  },
  battery_100 = {
    {lvgl.PART.MAIN, lvgl.Style {
      width = battery_width * 1.0,
    }},
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
