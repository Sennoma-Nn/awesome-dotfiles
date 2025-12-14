-- ===================================================================
-- Network Widget for re0 in FreeBSD
-- ===================================================================

local awful = require('awful')
local wibox = require('wibox')
local gears = require('gears')
local naughty = require('naughty') 
local dpi = require('beautiful').xresources.apply_dpi
local clickable_container = require('widgets.clickable-container')

local config_dir = gears.filesystem.get_configuration_dir()
local widget_icon_dir = config_dir .. 'icons/network/'

local return_button = function()

	local widget = wibox.widget {
		{
			id = 'icon',
			image = widget_icon_dir .. 'wired.svg',
			widget = wibox.widget.imagebox,
			resize = true
		},
		layout = wibox.layout.align.horizontal
	}

	local widget_button = wibox.widget {
		{
			widget,
			margins = dpi(7),
			widget = wibox.container.margin
		},
		widget = clickable_container
	}
	
	widget_button:buttons(
		gears.table.join(
			awful.button({}, 1, nil,
				function()
					if apps.network_manager and apps.network_manager ~= "" then
						awful.spawn(apps.network_manager, false)
					end
				end
			)
		)
	)

	local network_tooltip = awful.tooltip {
		text = 'Checking network status...',
		objects = {widget_button},
		mode = 'outside',
		align = 'right',
		preferred_positions = {'left', 'right', 'top', 'bottom'},
		margin_leftright = dpi(8),
		margin_topbottom = dpi(8)
	}

	local check_network_status = function()
		awful.spawn.easy_async_with_shell(
			"sh -c 'ifconfig re0 2>/dev/null | grep -q \"status: active\" && echo \"connected\" || echo \"disconnected\"'",
			function(stdout)
				local cleaned_stdout = stdout:gsub('%s+', '')
				local is_connected = cleaned_stdout:match('connected')
				
				if is_connected then
					awful.spawn.easy_async_with_shell(
						"sh -c 'ifconfig re0 | grep \"inet \" | awk \"{print \\$2}\"'",
						function(ip_stdout)
							local ip = ip_stdout:gsub('%s+', '')
							if ip == "" then
								ip = "No IP address"
							end
							
							awful.spawn.easy_async_with_shell(
								"sh -c 'ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1 && echo \"internet_ok\" || echo \"no_internet\"'",
								function(internet_stdout)
									local internet_cleaned = internet_stdout:gsub('%s+', '')
									local has_internet = internet_cleaned:match('internet_ok')
									
									if has_internet then
										widget.icon:set_image(widget_icon_dir .. 'wired.svg')
										network_tooltip:set_markup('(re0) Network connected\nIP address: ' .. ip .. '\nInternet: available')
									else
										widget.icon:set_image(widget_icon_dir .. 'wired-alert.svg')
										network_tooltip:set_markup('(re0) etwork connected but no internet\nIP address: ' .. ip .. '\nInternet: unavailable')
									end
								end
							)
						end
					)
				else
					widget.icon:set_image(widget_icon_dir .. 'wired-off.svg')
					network_tooltip:set_markup('(re0) Network not connected\nStatus: Inactive')
				end
			end
		)
	end

	check_network_status()

	local network_updater = gears.timer {
		timeout = 5,
		autostart = true,
		call_now = true,
		callback = function()
			check_network_status()
		end	
	}

	return widget_button
end

return return_button
