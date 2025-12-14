--      ███╗   ██╗ ██████╗ ████████╗██╗███████╗██╗ ██████╗ █████╗ ████████╗██╗ ██████╗ ███╗   ██╗███████╗
--      ████╗  ██║██╔═══██╗╚══██╔══╝██║██╔════╝██║██╔════╝██╔══██╗╚══██╔══╝██║██╔═══██╗████╗  ██║██╔════╝
--      ██╔██╗ ██║██║   ██║   ██║   ██║█████╗  ██║██║     ███████║   ██║   ██║██║   ██║██╔██╗ ██║███████╗
--      ██║╚██╗██║██║   ██║   ██║   ██║██╔══╝  ██║██║     ██╔══██║   ██║   ██║██║   ██║██║╚██╗██║╚════██║
--      ██║ ╚████║╚██████╔╝   ██║   ██║██║     ██║╚██████╗██║  ██║   ██║   ██║╚██████╔╝██║ ╚████║███████║
--      ╚═╝  ╚═══╝ ╚═════╝    ╚═╝   ╚═╝╚═╝     ╚═╝ ╚═════╝╚═╝  ╚═╝   ╚═╝   ╚═╝ ╚═════╝ ╚═╝  ╚═══╝╚══════╝

local awful = require("awful")
local wibox = require("wibox")
local clickable_container = require("widgets.clickable-container")
local gears = require("gears")
local naughty = require("naughty")
local dpi = require("beautiful").xresources.apply_dpi

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. "icons/notifications/"

local icon_on = widget_icon_dir .. "notifications-on.svg"
local icon_off = widget_icon_dir .. "notifications-off.svg"

local widget = wibox.widget {
   {
      id = "icon",
      widget = wibox.widget.imagebox,
      resize = true
   },
   layout = wibox.layout.fixed.horizontal
}

local widget_button = clickable_container(wibox.container.margin(widget, dpi(6), dpi(6), dpi(6), dpi(6)))

local notifications_tooltip = awful.tooltip({
   objects = {widget_button},
   mode = "outside",
   align = "left",
   preferred_positions = {"right", "left", "top", "bottom"}
})

local notifications_paused = false
local original_naughty_notify = naughty.notify

-- 更新小部件显示
local function update_widget_display()
   if notifications_paused then
      widget.icon:set_image(icon_off)
      notifications_tooltip.text = "Do Not Disturb"
   else
      widget.icon:set_image(icon_on)
      notifications_tooltip.text = "Notifications ON"
   end
end

-- 切换通知状态
local function toggle_notifications()
   if not notifications_paused then
      naughty.suspended = true
      notifications_paused = true
      naughty.notify = function() return nil end
   else
      naughty.suspended = false
      notifications_paused = false
      naughty.notify = original_naughty_notify
   end
   update_widget_display()
end

widget_button:buttons(
   gears.table.join(
      awful.button({}, 1, nil,
         function()
            toggle_notifications()
         end
      )
   )
)

update_widget_display()

return widget_button
