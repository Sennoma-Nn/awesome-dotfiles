--      ████████╗ ██████╗ ██████╗     ██████╗  █████╗ ███╗   ██╗███████╗██╗
--      ╚══██╔══╝██╔═══██╗██╔══██╗    ██╔══██╗██╔══██╗████╗  ██║██╔════╝██║
--         ██║   ██║   ██║██████╔╝    ██████╔╝███████║██╔██╗ ██║█████╗  ██║
--         ██║   ██║   ██║██╔═══╝     ██╔═══╝ ██╔══██║██║╚██╗██║██╔══╝  ██║
--         ██║   ╚██████╔╝██║         ██║     ██║  ██║██║ ╚████║███████╗███████╗
--         ╚═╝    ╚═════╝ ╚═╝         ╚═╝     ╚═╝  ╚═╝╚═╝  ╚═══╝╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")
local wibox = require("wibox")
local gears = require("gears")
local clickable_container = require("widgets.clickable-container")

local dpi = beautiful.xresources.apply_dpi

-- define module table
local top_panel = {}


-- ===================================================================
-- Bar Creation
-- ===================================================================


top_panel.create = function(s)

   local panel = wibox({
      screen = s,
      position = "top",
      ontop = true,
      visible = true,
      height = beautiful.top_panel_height,
      width = s.geometry.width,
      bg = "#00000000",
      type = "dock",
   })

   panel:struts({
      top = beautiful.top_panel_height
   })

   local right_container = wibox.layout.fixed.horizontal()
   right_container:add(wibox.container.margin(nil, dpi(4), 0, 0, 0))
   right_container:add(wibox.layout.margin(wibox.widget.systray(), dpi(8), dpi(8), dpi(8), dpi(8)))
   right_container:add(require("widgets.notifications-toggle"))
   right_container:add(require("widgets.volume"))
   right_container:add(require("widgets.network4re0")())
   right_container:add(require("widgets.calendar").create(s))
   right_container:add(wibox.container.margin(nil, dpi(12), 0, 0, 0))
   
   local right_bg_clickable = clickable_container()
   right_bg_clickable:set_widget(right_container)
   local corner_radius_clickable = 12
   right_bg_clickable.shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, corner_radius_clickable)
   end
   
   local right_bg = wibox.container.background()
   right_bg:set_widget(right_bg_clickable)
   right_bg:set_bg(beautiful.bg_dark)  -- Set to theme.bg_dark
   right_bg.shape = function(cr, width, height)
      gears.shape.partially_rounded_rect(cr, width, height, false, false, true, true, corner_radius_clickable)
   end

   panel:setup {
      expand = "none",
      layout = wibox.layout.align.horizontal,
      {
         layout = wibox.layout.fixed.horizontal,
         wibox.container.margin(nil, beautiful.left_panel_width + dpi(14), 0, 0, 0),
         require("widgets.task-list").create(s),
      },
      nil,
      wibox.container.margin(right_bg, 0, dpi(14), 0, 0)  -- Add dpi(14) margin on the right side of the pill
   }

   local panel_bg = wibox({
      screen = s,
      position = "top",
      ontop = false,
      height = beautiful.top_panel_height,
      width = s.geometry.width,
      bg = beautiful.bg_dark,
      visible = false
   })


   -- ===================================================================
   -- Functionality
   -- ===================================================================


   -- hide panel when client is fullscreen
   local function change_panel_visibility(client)
      if client.screen == s then
         panel.ontop = not client.fullscreen
      end
   end

   -- connect panel visibility function to relevant signals
   client.connect_signal("property::fullscreen", change_panel_visibility)
   client.connect_signal("focus", change_panel_visibility)

   -- maximize panel if client is maximized
   local function toggle_maximize_top_panel(is_maximized)
      if s == awful.screen.focused() then
         if is_maximized then
            panel_bg.visible = true
         else
            panel_bg.visible = false
         end
      end
   end

   -- maximize if a client is maximized
   client.connect_signal("property::maximized", function(c)
      toggle_maximize_top_panel(c.maximized)
   end)

   client.connect_signal("manage", function(c)
      if awful.tag.getproperty(c.first_tag, "layout") == awful.layout.suit.max then
         toggle_maximize_top_panel(true)
      end
   end)

   -- unmaximize if a client is removed and there are no maximized clients left
   client.connect_signal("unmanage", function(c)
      local t = awful.screen.focused().selected_tag
      -- if client was maximized
      if c.maximized then
         -- check if any clients that are open are maximized
         for _, c in pairs(t:clients()) do
            if c.maximized then
               return
            end
         end
         toggle_maximize_top_panel(false)

      -- if tag was maximized
      elseif awful.tag.getproperty(t, "layout") == awful.layout.suit.max then
         -- check if any clients are open (and therefore maximized)
         for _ in pairs(t:clients()) do
            return
         end
         toggle_maximize_top_panel(false)
      end
   end)

   -- maximize if layout is maximized and a client is in the layout
   tag.connect_signal("property::layout", function(t)
      -- check if layout is maximized
      if (awful.tag.getproperty(t, "layout") == awful.layout.suit.max) then
         -- check if clients are open
         for _ in pairs(t:clients()) do
            toggle_maximize_top_panel(true)
            return
         end
         toggle_maximize_top_panel(false)
      else
         toggle_maximize_top_panel(false)
      end
   end)

   -- maximize if a tag is swapped to with a maximized client
   tag.connect_signal("property::selected", function(t)
      -- check if layout is maximized
      if (awful.tag.getproperty(t, "layout") == awful.layout.suit.max) then
         -- check if clients are open
         for _ in pairs(t:clients()) do
            toggle_maximize_top_panel(true)
            return
         end
         toggle_maximize_top_panel(false)
      else
         -- check if any clients that are open are maximized
         for _, c in pairs(t:clients()) do
            if c.maximized then
               toggle_maximize_top_panel(true)
               return
            end
         end
         toggle_maximize_top_panel(false)
      end
   end)

end

return top_panel
