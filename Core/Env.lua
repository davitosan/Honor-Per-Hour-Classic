local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

-- Default options
hph_options_defaults = {
	["chat_combat"] = true,
	["tooltip_enemy"] = true,
	["tooltip_corpse"] = true,
	["honortab"] = true,
	["time_reset"] = 8,
	["error"] = false,
	["honorspy"] = false,
	["moveable"] = false,
	["show"] = true,
	["font"] = "Expressway",
	["font_size"] = 13,
	["chat_system_honor"] = true,
	["chat_system_type"] = "VerboseColored",
	["chat_message_color_r"] = 255,
	["chat_message_color_g"] = 251,
	["chat_message_color_b"] = 0,
}

-- Init Character State
if hph_killsdb == nil then hph_killsdb = {} end
if hph_today == nil then hph_today = {} end
if hph_week == nil then hph_week = {} end
if hph_options == nil then hph_options = {} end

-- Init Session State
HPH.locale = GetLocale()
HPH.timeAtLogin = GetTime()
HPH.honor_today = 0
HPH.honor_week = 0
HPH.hk_today_nominal = 0
HPH.hk_today_real = 0
HPH.honor_session = 0
HPH.honorSumNom = 0
HPH.honorSumReal = 0
HPH.killsInFight = 0
HPH.systemColor = "|cfffffb00"
HPH.optionsFrames = {}
HPH.hph_playersdb = {}
