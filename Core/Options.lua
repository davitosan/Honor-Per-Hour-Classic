local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")
local fonts = SM:List("font")

local chatWindows = {}

local function GetOptionsTable()
	local optionsTbl = {
		type = "group",
		name = HPH.Localize("HPH"),
		args = {
			General = {
				name = "General",
				desc = "General Settings",
				type = "group",
				order = 1,
				args = {
					intro = {
						name = "Session stats and Honor Today",
						type = "description",
						order = 1,
					},	
					time_reset = {
						order = 2,
						type = "input",
						name = "Server Reset Hour",
						desc = "...",
						width = .6,		
						get = function(info) return tostring(HPH.GetOption("time_reset")) end,
						set = function(info, value) 
							local inp = tonumber(value)
							if 'number' == type(inp) and inp <= 24 and inp >= 0 then
								hph_options["time_reset"] = inp
								hph_today = {}
								HPH.SetToday()
								HPH.Print("HPH: Reset hour set to: " .. hph_options["time_reset"])
							else
								HPH.Print("HPH: You must input a positive number less than 25")
							end
						end,
					},	
					times = {
						name = "\nServer Time:  " ..
							(function() 
								local timestamp_hour, timestamp_min = _G.GetGameTime() 
								return (tonumber(timestamp_hour) < 10 and "0" .. timestamp_hour or timestamp_hour) .. ":" .. 
									(tonumber(timestamp_min) < 10 and "0" .. timestamp_min or timestamp_min)
							end)() ..
							"\nLocal Time:  " ..
							(function() 
								return date("%H:%M",time())
							end)(),
						type = "description",
						order = 3,
					},	
					honorday = {
						name = "Local Honor Day: " ..
							"\n" .. date("%d-%m-%y %H:%M",hph_today[1]) ..
							" to\n" .. date("%d-%m-%y %H:%M",hph_today[2]) .. "\n",
						type = "description",
						order = 4,
					},	
					recalc = {
						name = "Re-calc",
						desc = "Re-calculate Honor Day",
						type = 'execute',
						order = 5,					
						width = .6,					
						func = function()
							hph_today = {}
							HPH.SetToday()
						end
					},
					debugkillsdumptitle = {
						name = "----------Debug----------",
						type = "description",
						order = 6,
					},	
					debugkillsdump = {
						name = "Debug Kills DB",
						desc = "Debug Logging of Honor Database",
						type = 'execute',
						order = 7,
						width = 1,
						func = function()
							HPH.DebugDumpDatabase("killsdb")
						end
					},
					debugplayersdump = {
						name = "Debug Player Cache",
						desc = "Debug Logging of Honor Database",
						type = 'execute',
						order = 8,
						width = 1,
						func = function()
							HPH.DebugDumpDatabase("playersdb")
						end
					},
				}, 	
			},
			Window = {
				order = 2,
				type = "group",
				name = "Window",
				desc = "Window",
				args = {
					locked = {
						order = 1,
						type = "toggle",
						name = "Lock",
						desc = "...",
						width = "full",
						get = function(info) return not HPH.GetOption("moveable") end,
						set = function(info, value) 
							hph_options["moveable"] = not HPH.GetOption("moveable")
							if value then
								HPH.Window:SetScript("OnDragStart", nil)
								HPH.Window:SetScript("OnDragStop", nil)
							else
								HPH.Window:SetScript("OnDragStart", HPH.Window.StartMoving)
								HPH.Window:SetScript("OnDragStop", HPH.Window.StopMovingOrSizing)
							end
						end,
					},
					show = {
						order = 2,
						type = "toggle",
						name = "Show",
						desc = "...",
						width = "full",
						get = function(info) return HPH.GetOption("show") end,
						set = function(info, value) 
							hph_options["show"] = not HPH.GetOption("show")
							HPH.UpdateFrameState()
						end,
					},
					reset = {
						name = "Reset",
						desc = "Resets Window Position",
						type = 'execute',
						order = 3,					
						width = .6,					
						func = function()
							HPH.Window:SetUserPlaced(false)
							HPH.Window:SetPoint("CENTER", WorldFrame, "CENTER", 0,0)
							C_UI.Reload()
						end
					},
					error_display = {
						order = 4,
						type = "toggle",
						name = "Show Error",
						desc = "...",
						width = "full",
						get = function(info) return HPH.GetOption("error") end,
						set = function(info, value) 
							hph_options["error"] = not HPH.GetOption("error")
						end,
					},
					font = {
						type = "select",
						order = 5,
						name = "Font",
						desc = "...",
						values = fonts,
						disabled  = HPH.locale == "zhCN" or HPH.locale == "zhTW" or HPH.locale == "koKR", --No Font support for glyph languages
						get = function()
							for info, value in next, fonts do
								if value == HPH.GetOption("font") then
									return info
								end
							end
						end, 
						set = function(_, value)
							hph_options["font"] = fonts[value]
							HPH.UpdateFont()
						end,
					},
					font_size = {
						order = 6,
						type = "input",
						name = "Size",
						desc = "...",
						width = .6,		
						get = function(info) return tostring(HPH.GetOption("font_size")) end,
						set = function(info, value) 
							local inp = tonumber(value)
							if 'number' == type(inp) and inp > 0 then
								hph_options["font_size"] = inp
								HPH.UpdateFont()
							else
								HPH.Print("HPH: You must input a positive number higher than 0")
							end
						end,
					},
				},
			},
			Chat = {
				name = "Chat",
				desc = "Chat",
				type = "group",
				order = 3,
				args = {
					chatsytemcolor = {
						order = 1,
						type = "color",
						name = "Message Color",
						desc = "..",
						width = "full",
						hasAlpha = false,
						get = function(info)
							return HPH.GetOption("chat_message_color_r"), HPH.GetOption("chat_message_color_g"), HPH.GetOption("chat_message_color_b")
						end,
						set = function(info, r, g, b, a)
							hph_options["chat_message_color_r"] = r
							hph_options["chat_message_color_g"] = g
							hph_options["chat_message_color_b"] = b
							hph_systemColor = "|cff" .. HPH.RGBToHex(r, g, b)
						end,				
					},
					chatwindowselection = {
						order = 2,
						type = "select",
						name = "Chat Window",
						desc = "...",
						values = function()
							local j = 0
							for i = 1, NUM_CHAT_WINDOWS do
								local name, fontSize, r, g, b, alpha, shown, locked, docked, uninteractable = GetChatWindowInfo(i)
								if name ~= nil and name ~= "" then
									j = j + 1
									chatWindows[j] = name
								end
							end
							return chatWindows
						end,
						get = function()
							for info, value in next, chatWindows do
								if value == HPH.GetOption("chat_window") then
									return info
								end
							end
						end, 
						set = function(_, value)
							hph_options["chat_window"] = chatWindows[value]
						end,
					},
					chatsystemtype = {
						order = 3,
						type = "select",
						name = "Chat Type",
						desc = "...",
						values = function()
							localizedChatTypes = {}
							localizedChatTypes[1] = HPH.Localize("None")
							localizedChatTypes[2] = HPH.Localize("Compact")
							localizedChatTypes[3] = HPH.Localize("Verbose")
							localizedChatTypes[4] = HPH.Localize("VerboseColored")
							return localizedChatTypes
						end,
						get = function()
							return hph_options["chat_type_index"] or hph_options_defaults["chat_type_index"]
						end, 
						set = function(_, value)
							hph_options["chat_type_index"] = value
						end,
					},
					chatcombat = {
						order = 4,
						type = "toggle",
						name = "Print Combat Summary",
						desc = "...",
						width = "full",
						get = function(info) return HPH.GetOption("chat_combat") end,
						set = function(info, value) 
							hph_options["chat_combat"] = not HPH.GetOption("chat_combat")	
						end,
					},
					chatsystemhonor = {
						order = 5,
						type = "toggle",
						name = "Suppress System Honor Gain Message",
						desc = "Hides system messages related to Honor Gain",
						width = "full",
						get = function(info) return HPH.GetOption("chat_system_honor") end,
						set = function(info, value) 
							hph_options["chat_system_honor"] = not HPH.GetOption("chat_system_honor")	
						end,
					},
				},
			},
			Honortab = {
				name = "Honortab",
				desc = "Honortab",
				type = "group",
				order = 4,
				args = {	
					honortoday = {
						order = 1,
						type = "toggle",
						name = "Replace 'Dishonorable Kills Today' with 'Honor Today'",
						desc = "...",
						width = "full",
						get = function(info) return HPH.GetOption("honortab") end,
						set = function(info, value) 
							hph_options["honortab"] = not HPH.GetOption("honortab")
						end,
					},		
					honorspy = {
						order = 2,
						type = "toggle",
						name = "Hide Honorspy Predictions",
						desc = "...",
						width = "full",
						get = function(info) return HPH.GetOption("honorspy") end,
						set = function(info, value) 
							hph_options["honorspy"] = not HPH.GetOption("honorspy")	
						end,
					},		
				}, 	
			},
			Tooltip = {
				name = "Tooltip",
				desc = "Tooltip",
				type = "group",
				order = 5,
				args = {
					enemy = {
						order = 1,
						type = "toggle",
						name = "Show Diminishing Returns on Enemy Tooltip",
						desc = "...",
						width = "full",
						get = function(info) return HPH.GetOption("tooltip_enemy") end,
						set = function(info, value) 
							hph_options["tooltip_enemy"] = not HPH.GetOption("tooltip_enemy")	
						end,
					},		
					corpse = {
						order = 2,
						type = "toggle",
						name = "Show Diminishing Returns on Corpse Tooltip",
						desc = "...",
						width = "full",
						get = function(info) return HPH.GetOption("tooltip_corpse") end,
						set = function(info, value) 
							hph_options["tooltip_corpse"] = not HPH.GetOption("tooltip_corpse")	
						end,
					},		
				}, 	
			},
		},
	}

	return optionsTbl
end

LibStub("AceConfigRegistry-3.0"):RegisterOptionsTable(HPH.Localize("HPH"), GetOptionsTable)
HPH.optionsFrames.HPH      = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(HPH.Localize("HPH"), HPH.Localize("HPH"),      nil,                 HPH.Localize("General"))
HPH.optionsFrames.Window   = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(HPH.Localize("HPH"), HPH.Localize("Window"),   HPH.Localize("HPH"), HPH.Localize("Window"))
HPH.optionsFrames.Chat     = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(HPH.Localize("HPH"), HPH.Localize("Chat"),     HPH.Localize("HPH"), HPH.Localize("Chat"))
HPH.optionsFrames.Honortab = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(HPH.Localize("HPH"), HPH.Localize("Honortab"), HPH.Localize("HPH"), HPH.Localize("Honortab"))
HPH.optionsFrames.Tooltip  = LibStub("AceConfigDialog-3.0"):AddToBlizOptions(HPH.Localize("HPH"), HPH.Localize("Tooltip"),  HPH.Localize("HPH"), HPH.Localize("Tooltip"))
