--      ████████╗██╗████████╗██╗     ███████╗██████╗  █████╗ ██████╗
--      ╚══██╔══╝██║╚══██╔══╝██║     ██╔════╝██╔══██╗██╔══██╗██╔══██╗
--         ██║   ██║   ██║   ██║     █████╗  ██████╔╝███████║██████╔╝
--         ██║   ██║   ██║   ██║     ██╔══╝  ██╔══██╗██╔══██║██╔══██╗
--         ██║   ██║   ██║   ███████╗███████╗██████╔╝██║  ██║██║  ██║
--         ╚═╝   ╚═╝   ╚═╝   ╚══════╝╚══════╝╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local gears = require("gears")
local wibox = require("wibox")
local dpi = require("beautiful").xresources.apply_dpi


-- ===================================================================
-- Titlebar Creation
-- ===================================================================


-- Add a titlebar
client.connect_signal("request::titlebars", function(c)
   local drag_widget = wibox.widget {
      widget = wibox.widget.background
   }
   
   drag_widget:buttons(gears.table.join(
      awful.button({}, 1, function()
         client.focus = c
         c:raise()
         awful.mouse.client.move(c)
      end),
      awful.button({}, 3, function()
         client.focus = c
         c:raise()
         awful.mouse.client.resize(c)
      end)
   ))

   awful.titlebar(c, {
      size = dpi(32),
      position = "left"
   }):setup {
      {
         -- AwesomeWM native buttons (images loaded from theme)
         wibox.layout.margin(awful.titlebar.widget.closebutton(c), dpi(5), dpi(5), dpi(11), dpi(5)),
         wibox.layout.margin(awful.titlebar.widget.minimizebutton(c), dpi(5), dpi(5), dpi(4), dpi(5)),
         wibox.layout.margin(awful.titlebar.widget.maximizedbutton(c), dpi(5), dpi(5), dpi(4), dpi(5)),
         layout = wibox.layout.fixed.vertical
      },
      drag_widget, -- Middle area for dragging
      nil,
      layout = wibox.layout.align.vertical
   }
end)
