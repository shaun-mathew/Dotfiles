-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
	naughty.notify({
		preset = naughty.config.presets.critical,
		title = "Oops, there were errors during startup!",
		text = awesome.startup_errors,
	})
end

-- Handle runtime errors after startup
do
	local in_error = false
	awesome.connect_signal("debug::error", function(err)
		-- Make sure we don't go into an endless error loop
		if in_error then
			return
		end
		in_error = true

		naughty.notify({
			preset = naughty.config.presets.critical,
			title = "Oops, an error happened!",
			text = tostring(err),
		})
		in_error = false
	end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() .. "mytheme.lua")

beautiful.useless_gap = 10

local bling = require("bling")

-- This is used later as the default terminal and editor to run.
terminal = "kitty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
	awful.layout.suit.tile,
	awful.layout.suit.floating,
	awful.layout.suit.tile.bottom,
	awful.layout.suit.fair.horizontal,
	bling.layout.mstab,
	bling.layout.centered,
	awful.layout.suit.max,
	-- awful.layout.suit.max.fullscreen,
	awful.layout.suit.magnifier,
	-- awful.layout.suit.corner.ne,
	-- awful.layout.suit.corner.sw,
	-- awful.layout.suit.corner.se,
}

--[[ callback = awful.client.setslave ]]
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu

local term_scratch = bling.module.scratchpad({
	command = "kitty --class spad", -- How to spawn the scratchpad
	rule = { instance = "spad" }, -- The rule that the scratchpad will be searched by
	sticky = true, -- Whether the scratchpad should be sticky
	autoclose = false, -- Whether it should hide itself when losing focus
	floating = true, -- Whether it should be floating (MUST BE TRUE FOR ANIMATIONS)
	geometry = { x = 360, y = 90, height = 900, width = 1200 }, -- The geometry in a floating state
	reapply = false, -- Whether all those properties should be reapplied on every new opening of the scratchpad (MUST BE TRUE FOR ANIMATIONS)
	dont_focus_before_close = false, -- When set to true, the scratchpad will be closed by the toggle function regardless of whether its focused or not. When set to false, the toggle function will first bring the scratchpad into focus and only close it on a second call
})
myawesomemenu = {
	{
		"hotkeys",
		function()
			hotkeys_popup.show_help(nil, awful.screen.focused())
		end,
	},
	{ "manual", terminal .. " -e man awesome" },
	{ "edit config", editor_cmd .. " " .. awesome.conffile },
	{ "restart", awesome.restart },
	{
		"quit",
		function()
			awesome.quit()
		end,
	},
}

mymainmenu = awful.menu({
	items = {
		{ "awesome", myawesomemenu, beautiful.awesome_icon },
		{ "open terminal", terminal },
	},
})

mylauncher = awful.widget.launcher({ image = beautiful.awesome_icon, menu = mymainmenu })

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock()

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
	awful.button({}, 1, function(t)
		t:view_only()
	end),
	awful.button({ modkey }, 1, function(t)
		if client.focus then
			client.focus:move_to_tag(t)
		end
	end),
	awful.button({}, 3, awful.tag.viewtoggle),
	awful.button({ modkey }, 3, function(t)
		if client.focus then
			client.focus:toggle_tag(t)
		end
	end),
	awful.button({}, 4, function(t)
		awful.tag.viewnext(t.screen)
	end),
	awful.button({}, 5, function(t)
		awful.tag.viewprev(t.screen)
	end)
)

local tasklist_buttons = gears.table.join(
	awful.button({}, 1, function(c)
		if c == client.focus then
			c.minimized = true
		else
			c:emit_signal("request::activate", "tasklist", { raise = true })
		end
	end),
	awful.button({}, 3, function()
		awful.menu.client_list({ theme = { width = 250 } })
	end),
	awful.button({}, 4, function()
		awful.client.focus.byidx(1)
	end),
	awful.button({}, 5, function()
		awful.client.focus.byidx(-1)
	end)
)

local function set_wallpaper(s)
	-- Wallpaper
	if beautiful.wallpaper then
		local wallpaper = beautiful.wallpaper
		-- If wallpaper is a function, call it with the screen
		if type(wallpaper) == "function" then
			wallpaper = wallpaper(s)
		end
		gears.wallpaper.maximized(wallpaper, s, true)
	end
end

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
	-- Wallpaper
	set_wallpaper(s)

	-- Each screen has its own tag table.
	awful.tag({ "1", "2", "3", "4", "5", "6" }, s, {
		awful.layout.layouts[1],
		awful.layout.layouts[5],
		awful.layout.layouts[1],
		awful.layout.layouts[7],
		awful.layout.layouts[2],
		awful.layout.layouts[2],
	})

	-- Create a promptbox for each screen
	s.mypromptbox = awful.widget.prompt()
	-- Create an imagebox widget which will contain an icon indicating which layout we're using.
	-- We need one layoutbox per screen.
	s.mylayoutbox = awful.widget.layoutbox(s)
	s.mylayoutbox:buttons(gears.table.join(
		awful.button({}, 1, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 3, function()
			awful.layout.inc(-1)
		end),
		awful.button({}, 4, function()
			awful.layout.inc(1)
		end),
		awful.button({}, 5, function()
			awful.layout.inc(-1)
		end)
	))
	-- Create a taglist widget
	s.mytaglist = awful.widget.taglist({
		screen = s,
		filter = awful.widget.taglist.filter.all,
		buttons = taglist_buttons,
	})

	-- Create a tasklist widget
	s.mytasklist = awful.widget.tasklist({
		screen = s,
		filter = awful.widget.tasklist.filter.currenttags,
		buttons = tasklist_buttons,
	})

	-- Create the wibox
	s.mywibox = awful.wibar({ position = "left", screen = s, visible = true, width = 35, bg = "#11111b" })

	s.mywibox:setup({

		{
			mylauncher,
			{
				s.mytaglist,
				direction = "west",
				widget = wibox.container.rotate,
			},
			layout = wibox.layout.fixed.vertical,

			spacing = 10,
		},
		{
			layout = wibox.layout.fixed.vertical,
		},
		--[[ { ]]
		--[[ 	{ ]]
		--[[ 		s.mytasklist, ]]
		--[[ 		direction = "west", ]]
		--[[ 		widget = wibox.container.rotate, ]]
		--[[ 	}, ]]
		--[[]]
		--[[ 	layout = wibox.layout.fixed.vertical, ]]
		--[[ }, ]]
		{
			{
				mytextclock,
				direction = "west",
				widget = wibox.container.rotate,
			},
			wibox.widget.systray(),
			s.mylayoutbox,
			layout = wibox.layout.fixed.vertical,
		},

		layout = wibox.layout.align.vertical,
	})

	-- Add widgets to the wibox
	--[[ s.mywibox:setup({ ]]
	--[[ 	layout = wibox.layout.align.horizontal, ]]
	--[[ 	{ -- Left widgets ]]
	--[[ 		layout = wibox.layout.fixed.horizontal, ]]
	--[[ 		mylauncher, ]]
	--[[ 		s.mytaglist, ]]
	--[[ 		s.mypromptbox, ]]
	--[[ 	}, ]]
	--[[ 	s.mytasklist, -- Middle widget ]]
	--[[ 	{ -- Right widgets ]]
	--[[ 		layout = wibox.layout.fixed.horizontal, ]]
	--[[ 		mykeyboardlayout, ]]
	--[[ 		wibox.widget.systray(), ]]
	--[[ 		mytextclock, ]]
	--[[ 		s.mylayoutbox, ]]
	--[[ 	}, ]]
	--[[ }) ]]
end)
-- }}}

-- {{{ Mouse bindings
root.buttons(gears.table.join(
	awful.button({}, 3, function()
		mymainmenu:toggle()
	end),
	awful.button({}, 4, awful.tag.viewnext),
	awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(
	awful.key({ modkey, "Shift" }, "/", hotkeys_popup.show_help, { description = "show help", group = "awesome" }),
	awful.key({ modkey }, "Left", awful.tag.viewprev, { description = "view previous", group = "tag" }),
	awful.key({ modkey }, "Right", awful.tag.viewnext, { description = "view next", group = "tag" }),

	awful.key({ modkey }, "w", function()
		awful.spawn.with_shell("$HOME/.config/rofi/launchers/launcher_switch.sh")
	end, { description = "show window switcher", group = "awesome" }),

	awful.key({ modkey }, "d", function()
		bling.module.window_swallowing.toggle() -- activates window swallowing
	end, { description = "toggle devour", group = "awesome" }),

	awful.key({ modkey }, "]", function()
		awful.client.focus.byidx(1)
	end, { description = "focus next by index", group = "client" }),
	awful.key({ modkey }, "[", function()
		awful.client.focus.byidx(-1)
	end, { description = "focus previous by index", group = "client" }),

	-- Layout manipulation
	--
	awful.key({ modkey }, "h", function()
		awful.client.focus.global_bydirection("left")
		if client.focus then
			client.focus:raise()
		end
	end),
	awful.key({ modkey }, "j", function()
		awful.client.focus.global_bydirection("down")
		if client.focus then
			client.focus:raise()
		end
	end),
	awful.key({ modkey }, "k", function()
		awful.client.focus.global_bydirection("up")
		if client.focus then
			client.focus:raise()
		end
	end),
	awful.key({ modkey }, "l", function()
		awful.client.focus.global_bydirection("right")
		if client.focus then
			client.focus:raise()
		end
	end),

	awful.key({ modkey, "Shift" }, "h", function()
		awful.client.swap.global_bydirection("left")
	end),
	awful.key({ modkey, "Shift" }, "j", function()
		awful.client.swap.global_bydirection("down")
	end),
	awful.key({ modkey, "Shift" }, "k", function()
		awful.client.swap.global_bydirection("up")
	end),
	awful.key({ modkey, "Shift" }, "l", function()
		awful.client.swap.global_bydirection("right")
	end),

	awful.key({ modkey, "Control" }, "j", function()
		awful.screen.focus_relative(1)
	end, { description = "focus the next screen", group = "screen" }),
	awful.key({ modkey, "Control" }, "k", function()
		awful.screen.focus_relative(-1)
	end, { description = "focus the previous screen", group = "screen" }),

	awful.key({ modkey }, "u", awful.client.urgent.jumpto, { description = "jump to urgent client", group = "client" }),
	awful.key({ modkey }, "Tab", function()
		local c = awful.client.focus.history.list[2]
		client.focus = c
		local t = client.focus and client.focus.first_tag or nil
		if t then
			t:view_only()
		end
		c:raise()
	end, { description = "go back", group = "client" }),

	-- Standard program
	awful.key({ modkey }, "Return", function()
		awful.spawn(terminal)
	end, { description = "open a terminal", group = "launcher" }),

	awful.key({ modkey, "Control" }, "Return", function()
		term_scratch:toggle() -- toggles the scratchpads visibility
	end, { description = "open a terminal scratchpad", group = "launcher" }),
	awful.key({ modkey, "Control" }, "r", awesome.restart, { description = "reload awesome", group = "awesome" }),
	awful.key({ modkey, "Shift" }, "Escape", awesome.quit, { description = "quit awesome", group = "awesome" }),

	awful.key({ modkey, "Control" }, "l", function()
		awful.tag.incmwfact(0.05)
	end, { description = "increase master width factor", group = "layout" }),
	awful.key({ modkey, "Control" }, "h", function()
		awful.tag.incmwfact(-0.05)
	end, { description = "decrease master width factor", group = "layout" }),

	awful.key({ modkey, "Shift" }, "=", function()
		awful.tag.incnmaster(1, nil, true)
	end, { description = "increase the number of master clients", group = "layout" }),
	awful.key({ modkey, "Shift" }, "-", function()
		awful.tag.incnmaster(-1, nil, true)
	end, { description = "decrease the number of master clients", group = "layout" }),

	awful.key({ modkey }, "space", function()
		awful.layout.inc(1)
	end, { description = "select next", group = "layout" }),
	awful.key({ modkey, "Shift" }, "space", function()
		awful.layout.inc(-1)
	end, { description = "select previous", group = "layout" }),

	awful.key({ modkey, "Shift" }, "0", function()
		local c = awful.client.restore()
		-- Focus restored client
		if c then
			c:emit_signal("request::activate", "key.unminimize", { raise = true })
		end
	end, { description = "restore minimized", group = "client" }),

	-- Prompt
	--[[ awful.key({ modkey }, "r", function() ]]
	--[[ 	awful.spawn.with_shell("$HOME/.config/rofi/launchers/launcher.sh") ]]
	--[[ end, { description = "run prompt", group = "launcher" }), ]]

	awful.key({ modkey }, "r", function()
		awful.spawn.with_shell("ulauncher-toggle")
	end, { description = "run prompt", group = "launcher" }),

	awful.key({ modkey, "Mod1" }, "h", function()
		bling.module.tabbed.pick_by_direction("left") -- picks a client based on direction ("up", "down", "left" or "right")
	end),

	awful.key({ modkey, "Mod1" }, "j", function()
		bling.module.tabbed.pick_by_direction("down") -- picks a client based on direction ("up", "down", "left" or "right")
	end),
	awful.key({ modkey, "Mod1" }, "k", function()
		bling.module.tabbed.pick_by_direction("up") -- picks a client based on direction ("up", "down", "left" or "right")
	end),
	awful.key({ modkey, "Mod1" }, "l", function()
		bling.module.tabbed.pick_by_direction("right") -- picks a client based on direction ("up", "down", "left" or "right")
	end),
	awful.key({ modkey }, "p", function()
		bling.module.tabbed.pop()
	end),
	awful.key({ modkey }, ".", function()
		bling.module.tabbed.iter() -- iterates through the currently focused tabbing group
	end),
	awful.key({}, "Print", function()
		local screenshot = function(c)
			return awful.rules.match(c, { class = "gnome-screenshot" })
		end

		local found = false

		for _, c in ipairs(client.get()) do
			if c.name == "Screenshot" then
				found = true
				c:move_to_tag(mouse.screen.selected_tag)
			end
		end

		if not found then
			awful.util.spawn("gnome-screenshot -i", {
				floating = true,
				tag = mouse.screen.selected_tag,
				placement = awful.placement.center,
			})
		end
	end),

	awful.key({ modkey }, "t", function()
		awful.layout.set(awful.layout.suit.tile)
	end)

	-- Menubar
	--[[ awful.key({ modkey }, "p", function() ]]
	--[[ 	menubar.show() ]]
	--[[ end, { description = "show the menubar", group = "launcher" }) ]]

	--[[ awful.key({ modkey }, "Tab", function() ]]
	--[[ 	awesome.emit_signal("bling::window_switcher::turn_on") ]]
	--[[ end, { description = "Window Switcher", group = "bling" }) ]]
)

clientkeys = gears.table.join(
	awful.key({ modkey }, "f", function(c)
		c.fullscreen = not c.fullscreen
		c:raise()
	end, { description = "toggle fullscreen", group = "client" }),

	awful.key({ modkey }, "s", function(c)
		c.sticky = not c.sticky
	end),

	awful.key({ modkey, "Shift" }, "c", function(c)
		c:kill()
	end, { description = "close", group = "client" }),
	awful.key(
		{ modkey, "Shift" },
		"f",
		awful.client.floating.toggle,
		{ description = "toggle floating", group = "client" }
	),
	awful.key({ modkey, "Shift" }, "Return", function(c)
		local master = awful.client.getmaster(awful.screen.focused())
		local last_focused_window = awful.client.focus.history.get(awful.screen.focused(), 1, nil)
		if c == master then
			if not last_focused_window then
				return
			end
			client.focus = last_focused_window
			c:swap(last_focused_window)
			client.focus = c
		else
			client.focus = master
			c:swap(master)
			client.focus = c
		end
	end, { description = "move to master", group = "client" }),

	awful.key({ modkey }, "o", function(c)
		c:move_to_screen()
	end, { description = "move to screen", group = "client" }),

	awful.key({ modkey }, "0", function(c)
		-- The client currently has the input focus, so it cannot be
		-- minimized, since minimized clients can't have the focus.
		c.minimized = true
	end, { description = "minimize", group = "client" }),
	awful.key({ modkey }, "m", function(c)
		c.maximized = not c.maximized
		c:raise()
	end, { description = "(un)maximize", group = "client" }),
	awful.key({ modkey }, "c", awful.placement.centered)
)

-- Bind all key numbers to tags.
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
	globalkeys = gears.table.join(
		globalkeys,
		-- View tag only.
		awful.key({ modkey }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				tag:view_only()
			end
		end, { description = "view tag #" .. i, group = "tag" }),
		-- Toggle tag display.
		awful.key({ modkey, "Control" }, "#" .. i + 9, function()
			local screen = awful.screen.focused()
			local tag = screen.tags[i]
			if tag then
				awful.tag.viewtoggle(tag)
			end
		end, { description = "toggle tag #" .. i, group = "tag" }),
		-- Move client to tag.
		awful.key({ modkey, "Shift" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:move_to_tag(tag)
				end
			end
		end, { description = "move focused client to tag #" .. i, group = "tag" }),
		-- Toggle tag on focused client.
		awful.key({ modkey, "Mod1" }, "#" .. i + 9, function()
			if client.focus then
				local tag = client.focus.screen.tags[i]
				if tag then
					client.focus:toggle_tag(tag)
				end
			end
		end, { description = "toggle focused client on tag #" .. i, group = "tag" })
	)
end

clientbuttons = gears.table.join(
	awful.button({}, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
	end),
	awful.button({ modkey }, 1, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.move(c)
	end),
	awful.button({ modkey }, 3, function(c)
		c:emit_signal("request::activate", "mouse_click", { raise = true })
		awful.mouse.client.resize(c)
	end)
)

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
	-- All clients will match this rule.
	{
		rule = {},
		properties = {
			border_width = beautiful.border_width,
			border_color = beautiful.border_normal,
			focus = awful.client.focus.filter,
			raise = true,
			keys = clientkeys,
			buttons = clientbuttons,
			screen = awful.screen.preferred,
			placement = awful.placement.no_overlap + awful.placement.no_offscreen,
		},
	},

	{
		rule = { name = "Screenshot" },
		properties = {
			floating = true,
			width = 1200,
			height = 900,
			placement = awful.placement.align.centered + awful.placement.no_overlap,
		},
	},

	{
		rule_any = {
			name = { "ulauncher", "Ulauncher Preferences" },
			class = { "ulauncher", "Ulauncher" },
		},

		properties = { floating = true, border_width = 0 },
	},

	-- Floating clients.
	{
		rule_any = {
			instance = {
				"DTA", -- Firefox addon DownThemAll.
				"copyq", -- Includes session name in class.
				"pinentry",
			},
			class = {
				"Arandr",
				"Blueman-manager",
				"Gpick",
				"Kruler",
				"MessageWin", -- kalarm.
				"Sxiv",
				"Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
				"Wpa_gui",
				"veromix",
				"xtightvncviewer",
				"Zoom",
				"gnome-screenshot",
			},

			-- Note that the name property shown in xprop might be set slightly after creation of the client
			-- and the name shown there might not match defined rules here.
			name = {
				"Event Tester", -- xev.
				"Screenshot",
				"Zoom",
				"Calculator",
				"Authenticate",
			},
			role = {
				"AlarmWindow", -- Thunderbird's calendar.
				"ConfigManager", -- Thunderbird's about:config.
				"pop-up", -- e.g. Google Chrome's (detached) Developer Tools.
			},
		},
		properties = { floating = true },
	},

	-- Spawn floating clients centered
	--[[ { rule_any = { floating = true }, properties = { ]]
	--[[ 	placement = awful.placement.centered, ]]
	--[[ } }, ]]

	-- Add titlebars to normal clients and dialogs
	{ rule_any = { type = { "normal", "dialog" } }, properties = { titlebars_enabled = false } },

	-- Set Firefox to always map on the tag named "2" on screen 1.
	{ rule = { class = "firefox" }, properties = { screen = 1, tags = { "2", "4" } } },
	{ rule = { name = "Thunderbird" }, properties = { tags = { "6" }, maximized = true, urgent = false } },
}
-- }}}
--

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
	-- Set the windows at the slave,
	-- i.e. put it at the end of others instead of setting it master.
	if not awesome.startup then
		awful.client.setslave(c)
	end

	if awesome.startup and not c.size_hints.user_position and not c.size_hints.program_position then
		-- Prevent clients from being unreachable after screen count changes.
		awful.placement.no_offscreen(c)
	end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
	-- buttons for the titlebar
	local buttons = gears.table.join(
		awful.button({}, 1, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.move(c)
		end),
		awful.button({}, 3, function()
			c:emit_signal("request::activate", "titlebar", { raise = true })
			awful.mouse.client.resize(c)
		end)
	)

	awful.titlebar(c):setup({
		{ -- Left
			awful.titlebar.widget.iconwidget(c),
			buttons = buttons,
			layout = wibox.layout.fixed.horizontal,
		},
		{ -- Middle
			{ -- Title
				align = "center",
				widget = awful.titlebar.widget.titlewidget(c),
			},
			buttons = buttons,
			layout = wibox.layout.flex.horizontal,
		},
		{ -- Right
			awful.titlebar.widget.floatingbutton(c),
			awful.titlebar.widget.maximizedbutton(c),
			awful.titlebar.widget.stickybutton(c),
			awful.titlebar.widget.ontopbutton(c),
			awful.titlebar.widget.closebutton(c),
			layout = wibox.layout.fixed.horizontal(),
		},
		layout = wibox.layout.align.horizontal,
	})
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
	c:emit_signal("request::activate", "mouse_enter", { raise = false })
end)

client.connect_signal("focus", function(c)
	c.border_color = beautiful.border_focus
end)
client.connect_signal("unfocus", function(c)
	c.border_color = beautiful.border_normal
end)

-- this may be a little sus because if you get spammed with urgent calls, you would jump
-- to each urgent client
--[[ client.connect_signal("property::urgent", function(c) ]]
--[[ 	c.minimized = false ]]
--[[ 	c:jump_to() ]]
--[[ end) ]]
-- }}}

--[[ bling.module.flash_focus.enable() ]]
bling.module.window_swallowing.stop() -- activates window swallowing

--picom --experimental-backend --config ~/.config/picom/picom.conf
-- awful.spawn.with_shell("picom --experimental-backend --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("picom --experimental-backend --config ~/.config/picom/picom.conf")
awful.spawn.with_shell("/usr/libexec/polkit-gnome-authentication-agent-1")
awful.spawn.with_shell(
	"GDK_BACKEND=x11 WEBKIT_DISABLE_COMPOSITING_MODE=1 /usr/bin/ulauncher --hide-window --no-window-shadow"
)

awful.spawn.with_shell("fusuma -d")
--[[ awful.spawn.with_shell("flatpak run org.mozilla.Thunderbird") ]]
--[[ awful.spawn.with_shell("autorandr --change") ]]
--[[ awful.spawn.with_shell("flatpak run org.discordapp.Discord") ]]
-- picom -b --experimental-backends --backend glx
