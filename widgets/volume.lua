--      ██╗   ██╗ ██████╗ ██╗     ██╗   ██╗███╗   ███╗███████╗
--      ██║   ██║██╔═══██╗██║     ██║   ██║████╗ ████║██╔════╝
--      ██║   ██║██║   ██║██║     ██║   ██║██╔████╔██║█████╗
--      ╚██╗ ██╔╝██║   ██║██║     ██║   ██║██║╚██╔╝██║██╔══╝
--       ╚████╔╝ ╚██████╔╝███████╗╚██████╔╝██║ ╚═╝ ██║███████╗
--        ╚═══╝   ╚═════╝ ╚══════╝ ╚═════╝ ╚═╝     ╚═╝╚══════╝

-------------------------------------------------
-- Volume Widget for Awesome Window Manager
-- Shows the current volume level
-------------------------------------------------


-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local watch = require("awful.widget.watch")
local wibox = require("wibox")
local clickable_container = require("widgets.clickable-container")
local gears = require("gears")
local dpi = require("beautiful").xresources.apply_dpi

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "icons/volume/"


-- ===================================================================
-- Widget Creation
-- ===================================================================


local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   layout = wibox.layout.fixed.horizontal
}

local widget_button = clickable_container(wibox.container.margin(widget, dpi(7), dpi(7), dpi(7), dpi(7)))
widget_button:buttons(
   gears.table.join(
      awful.button({}, 1, nil,
         function()
            awesome.emit_signal("volume_change")
         end
      )
   )
)

-- 创建工具提示
local volume_tooltip = awful.tooltip({
   objects = {widget_button},
   mode = "outside",
   align = "left",
   preferred_positions = {"right", "left", "top", "bottom"}
})

-- 获取当前音量
local function get_current_volume()
   awful.spawn.easy_async_with_shell(
      "pactl get-sink-volume @DEFAULT_SINK@ | grep -o '[0-9]*%' | head -1 | sed 's/%//'",
      function(stdout)
         local volume_level = tonumber(stdout)
         if volume_level == nil then
            volume_level = 0
         end
         
         awful.spawn.easy_async_with_shell(
            "sh -c 'LC_ALL=C pactl get-sink-mute @DEFAULT_SINK@ 2>/dev/null'",
            function(mute_stdout)
               local is_muted = false
               
               if mute_stdout:match("Mute:%s*yes") then
                  is_muted = true
               elseif mute_stdout:match("Mute:%s*no") then
                  is_muted = false
               end
               
               if is_muted then
                  widget.icon:set_image(widget_icon_dir .. "volume-off.png")
               else
                  if volume_level > 40 then
                     widget.icon:set_image(widget_icon_dir .. "volume.png")
                  elseif volume_level > 0 then
                     widget.icon:set_image(widget_icon_dir .. "volume-low.png")
                  else
                     widget.icon:set_image(widget_icon_dir .. "volume-off.png")
                  end
               end
               
               volume_tooltip.text = volume_level .. "%"
            end
         )
      end
   )
end

-- 监听音量变化信号
awesome.connect_signal("volume_change",
   function()
      get_current_volume()
   end
)

-- 定期更新音量显示
watch('pactl get-sink-volume @DEFAULT_SINK@', 2,
   function(_, stdout)
      get_current_volume()
   end,
   widget
)

-- 初始获取音量
get_current_volume()

return widget_button
