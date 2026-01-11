--      ██████╗ ██╗   ██╗██╗     ███████╗███████╗
--      ██╔══██╗██║   ██║██║     ██╔════╝██╔════╝
--      ██████╔╝██║   ██║██║     █████╗  ███████╗
--      ██╔══██╗██║   ██║██║     ██╔══╝  ╚════██║
--      ██║  ██║╚██████╔╝███████╗███████╗███████║
--      ╚═╝  ╚═╝ ╚═════╝ ╚══════╝╚══════╝╚══════╝

-- ===================================================================
-- Initialization
-- ===================================================================


local awful = require("awful")
local beautiful = require("beautiful")

-- define screen height and width
local screen_height = awful.screen.focused().geometry.height
local screen_width = awful.screen.focused().geometry.width

-- define module table
local rules = {}


-- ===================================================================
-- Rules
-- ===================================================================


-- return a table of client rules including provided keys / buttons
function rules.create(clientkeys, clientbuttons)
   local rofi_rule = {
      rule_any = {name = {"rofi"}},
      properties = {floating = true, titlebars_enabled = false},
      callback = function(c)
         awful.placement.left(c)
      end
   }

   local borderless_apps = {
      {
         class = {"code - oss", "Code - OSS"},
         border_width = 2,
         titlebars_enabled = false
      },
      {
         class = {"org.gnome.Nautilus", "org.gnome.Nautilus"},
         border_width = 0,
         titlebars_enabled = false
      },
      {
         class = {"qq", "QQ"},
         border_width = 2,
         titlebars_enabled = false
      },
      {
         class = {"rofi", "Rofi"},
         border_width = 0,
         titlebars_enabled = false
      },
      {
         class = {"org.jackhuang.hmcl.Launcher", "org.jackhuang.hmcl.Launcher"},
         border_width = 0,
         titlebars_enabled = false
      },
      {
         class = {"Eterm 0.9.6", "Eterm"},
         border_width = 2,
         titlebars_enabled = false
      },
   }

   local borderless_rules = {}
   for _, app in ipairs(borderless_apps) do
      table.insert(borderless_rules, {
         rule_any = {class = app.class},
         properties = {
            border_width = app.border_width,
            titlebars_enabled = app.titlebars_enabled
         }
      })
   end

   return {
      -- All clients will match this rule.
      {
         rule = {},
         properties = {
            titlebars_enabled = beautiful.titlebars_enabled,
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.centered
         },
      },
      -- Floating clients.
      {
         rule_any = {
            instance = {
               "DTA",
               "copyq",
            },
            class = {
               "Nm-connection-editor"
            },
            name = {
               "Event Tester",
               "Steam Guard - Computer Authorization Required"
            },
            role = {
               "pop-up",
               "GtkFileChooserDialog"
            },
            type = {
               "dialog"
            }
         }, properties = {floating = true}
      },

      -- Fullscreen clients
      {
         rule_any = {
            class = {
               "Terraria.bin.x86",
            },
         }, properties = {fullscreen = true}
      },

      -- "Switch to tag"
      -- These clients make you switch to their tag when they appear
      {
         rule_any = {
            class = {
               "Firefox"
            },
         }, properties = {switchtotag = true}
      },

      -- Visualizer
      {
         rule_any = {name = {"cava"}},
         properties = {
            floating = true,
            maximized_horizontal = true,
            sticky = true,
            ontop = false,
            skip_taskbar = true,
            below = true,
            focusable = false,
            height = screen_height * 0.40,
            opacity = 0.6
         },
         callback = function (c)
            decorations.hide(c)
            awful.placement.bottom(c)
         end
      },

      -- rofi rule determined above
      rofi_rule,

      -- File chooser dialog
      {
         rule_any = {role = {"GtkFileChooserDialog"}},
         properties = {floating = true, width = screen_width * 0.55, height = screen_height * 0.65}
      },

      -- Pavucontrol & Bluetooth Devices
      {
         rule_any = {class = {"Pavucontrol"}, name = {"Bluetooth Devices"}},
         properties = {floating = true, width = screen_width * 0.55, height = screen_height * 0.45}
      },

      table.unpack(borderless_rules),
   }
end

-- return module table
return rules
