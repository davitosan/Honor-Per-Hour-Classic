local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

-- Get Rank Color
local rankColors = 
{
	hph_systemColor, --Rank 0 (Unknown)
	"|cff8ea18d", --Rank 1 8ea18d HSV 117°, 12%, 63%
	"|cff8aa888", --Rank 2 8aa888 HSV 117°, 19%, 66%
	"|cff84b082", --Rank 3 84b082 HSV 117°, 26%, 69%
	"|cff7eb87b", --Rank 4 7eb87b HSV 117°, 33%, 72%
	"|cff77bf73", --Rank 5 77bf73 HSV 117°, 40%, 75%
	"|cff6ec769", --Rank 6 6ec769 HSV 117°, 47%, 78%
	"|cff65cf5f", --Rank 7 65cf5f HSV 118°, 54%, 81%
	"|cff5bd654", --Rank 8 5bd654 HSV 118°, 61%, 84%
	"|cff4fde47", --Rank 9 4fde47 HSV 118°, 68%, 87%
	"|cff42e639", --Rank 10 42e639 HSV 118°, 75%, 90%
	"|cff34ed2b", --Rank 11 34ed2b HSV 118°, 82%, 93%
	"|cff26f51b", --Rank 12 26f51b HSV 120°, 89%, 96%
	"|cff16fc0a", --Rank 13 16fc0a HSV 120°, 96%, 99%
	"|cff00ff00", --Rank 14 00ff00 HSV 120°, 100%, 100%
} 

local function GetVictimOutput(victim)
	local optChatType = HPH.GetOption("chat_system_type")
	if optChatType ~= "VerboseColored" then
		return hph_systemColor .. victim
	end

	-- Look at Combat Log Cache first
	if HPH.hph_playersdb[victim] ~= nil then
		local englishClass = HPH.hph_playersdb[victim][2]
		if englishClass == "SHAMAN" then
			return "|cff0070DE" .. victim
		else
			local rPerc, gPerc, bPerc, argbHex = GetClassColor(englishClass)
			return "|c" .. argbHex .. victim
		end
	end

	--Look at Scoreboard
	local classScoreboard = nil
	for i=1,GetNumBattlefieldScores(),1 do 
		local name, killingBlows, honorableKills, deaths, honorGained, faction, _, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i)
		if (name ~= nill) and (faction ~= nil) and (faction ~= UnitFactionGroup("player")) then
			if (name == victim) or (string.find(name, "-") or 0 > 0) and (string.match(name, "(.-)-%s*") == victim) then -- Player from other realm
				classScoreboard = class
			end
		end
	end

	if classScoreboard ~= nil then
		if classScoreboard == "SHAMAN" then
			return "|cff0070DE" .. victim
		else
			local rPerc, gPerc, bPerc, argbHex = GetClassColor(classScoreboard)
			return "|c" .. argbHex .. victim
		end
	end

	--Crapped out
	return hph_systemColor .. victim
end

local function GetServerOutput(victim)
	local server = "Unknown"
	--Look at Combat Log Cache first
	if HPH.hph_playersdb[victim] ~= nil then
		server = HPH.hph_playersdb[victim][1]
	end

	--Look at Scoreboard
	if server == "Unknown" then
		for i=1,GetNumBattlefieldScores(),1 do 
			local name = GetBattlefieldScore(i) or ""
			if string.find(name, "-") or 0 > 0 then -- Player from other realm
				if string.match(name, "(.-)-%s*") == victim then
					server = string.match(name, "-(.*)")
				end
			elseif name == victim then  -- Player from own realm
				server = GetRealmName()
			end
		end
	end

	local serverOutput = ""
	local optChatType = HPH.GetOption("chat_system_type")
	if optChatType == "VerboseColored" or optChatType == "Verbose" then
		serverOutput = hph_systemColor .. "-" .. server .. hph_systemColor .. " | "
	end
	
	return serverOutput
end

local function GetRankOutput(rank)
	local opt = HPH.GetOption("chat_system_type")
	local rankLabel = HPH.Localize("Rank") .. ":"
	local rankIndex = 0

	if PVP_RANK_5_0 == rank or PVP_RANK_5_1== rank then
		rankIndex = 1
	elseif PVP_RANK_6_0 == rank or PVP_RANK_6_1 == rank then
		rankIndex = 2
	elseif PVP_RANK_7_0 == rank or PVP_RANK_7_1 == rank then
		rankIndex = 3
	elseif PVP_RANK_8_0 == rank or PVP_RANK_8_1 == rank then
		rankIndex = 4
	elseif PVP_RANK_9_0 == rank or PVP_RANK_9_1 == rank then
		rankIndex = 5
	elseif PVP_RANK_10_0 == rank or PVP_RANK_10_1 == rank then
		rankIndex = 6
	elseif PVP_RANK_11_0 == rank or PVP_RANK_11_1 == rank then
		rankIndex = 7
	elseif PVP_RANK_12_0 == rank or PVP_RANK_12_1 == rank then
		rankIndex = 8
	elseif PVP_RANK_13_0 == rank or PVP_RANK_13_1 == rank then
		rankIndex = 9
	elseif PVP_RANK_14_0 == rank or PVP_RANK_14_1 == rank then
		rankIndex = 10
	elseif PVP_RANK_15_0 == rank or PVP_RANK_15_1 == rank then
		rankIndex = 11
	elseif PVP_RANK_16_0 == rank or PVP_RANK_16_1 == rank then
		rankIndex = 12
	elseif PVP_RANK_17_0 == rank or PVP_RANK_17_1 == rank then
		rankIndex = 13
	elseif PVP_RANK_18_0 == rank or PVP_RANK_18_1 == rank then
		rankIndex = 14
	else
		rank = "Unknown"
		rankIndex = 0
	end

	local rankColor = hph_systemColor
	if opt == "VerboseColored" then
		rankColor = rankColors[rankIndex + 1]
	end

	return rankLabel .. rankColor .. " " .. rank .. " " .. hph_systemColor .. "(" .. rankColor .. rankIndex .. hph_systemColor.. ")"
end

--honor_msg = [VICTIM] dies, honorable kill Rank: [RANK] (Estimated Honor Points: [EST_HONOR])
local function ColorizeOutput(honor_msg, nameandserver, timesKilled, honor_real)
	local msg = ""
	local honor_gain_pattern = string.gsub(COMBATLOG_HONORGAIN, "%(", "%%(")
	honor_gain_pattern = string.gsub(honor_gain_pattern, "%)", "%%)")
	honor_gain_pattern = string.gsub(honor_gain_pattern, "(%%s)", "(.+)")
	honor_gain_pattern = string.gsub(honor_gain_pattern, "(%%d)", "(%%d+)")
	
	--Victim, Rank, Est_honor
	local victim, rank, est_honor = honor_msg:match(honor_gain_pattern)
	--Victim Output
	local victimOutput = GetVictimOutput(victim)
	--Server Output
	local serverOutput = GetServerOutput(victim)
	--Rank Output
	local rankOutput = GetRankOutput(rank)

	local discount, discountHex = HPH.GetDiscountRate(timesKilled)
	local coef = 1 - discount

	local optChatType = HPH.GetOption("chat_system_type")
	if optChatType == "VerboseColored" then
		msg = victimOutput .. serverOutput .. rankOutput .. hph_systemColor .. " | Kills: |r" .. discountHex .. timesKilled + 1 .. hph_systemColor .. " | " .. hph_systemColor .. "Honor: " .. discountHex .. math.floor(honor_real) .. hph_systemColor .. " (" .. discountHex .. coef * 100 .. "%" .. hph_systemColor .. ")|r"
	elseif optChatType == "Verbose" then
		msg = hph_systemColor .. victimOutput .. serverOutput .. rankOutput .. " | Kills: " .. timesKilled + 1 .. " | Honor: " .. math.floor(honor_real) .. " (" .. coef * 100 .. "%)"
	elseif optChatType == "Compact" then
		msg = hph_systemColor .. "+honor - " .. math.floor(honor_real) .. " of " .. est_honor .. " (|r" .. discountHex .. coef * 100 .. "%|r" .. hph_systemColor .. ")|r"
	end

	return msg
end
HPH.ColorizeOutput = ColorizeOutput

local function UpdateCombatSummary(eventname)
	if HPH.GetOption("chat_combat") == false or UnitIsPVP("player") == false then
		return
	end

	local msg = ""

	if eventname == "PLAYER_REGEN_DISABLED" then
		msg = "-Combat entered"
		HPH.killsInFight = 0
		HPH.honorSumNom = 0
		HPH.honorSumReal = 0
	elseif eventname == "PLAYER_REGEN_ENABLED" then
		local optChatType = HPH.GetOption("chat_system_type")
			--Compact
			if optChatType == "Compact" or optChatType == "None" then
				msg = ("-Combat ended: " .. math.floor(HPH.honorSumReal) .. " of " .. HPH.honorSumNom .. " (" ..  HPH.killsInFight .. " kills)")
			else
				msg = "-Combat ended"
				local pct = 0
				local discount = 0
				local discountHex = "|r"
				--VerboseColor
				if HPH.honorSumNom > 0 then
					pct = math.floor(100 * HPH.honorSumReal / HPH.honorSumNom)
					if optChatType == "VerboseColored" then
						discount, discountHex = HPH.GetDiscountRate(10 - math.floor(pct / 10))
					end
				end

				msg = "-Combat ended: Kills: " .. HPH.killsInFight .. " | Honor: |r" .. discountHex .. math.floor(HPH.honorSumReal) .. "|r of |r" .. discountHex .. HPH.honorSumNom .. "|r | (" .. discountHex .. pct .. "%|r)"
			end
	end

	HPH.Print(msg)
end
HPH.UpdateCombatSummary = UpdateCombatSummary

--Accepts both types of RGB.
local function RGBToHex(r, g, b)
	r = tonumber(r)
	g = tonumber(g)
	b = tonumber(b)

	--Check if whole numbers.
	if (r == math.floor(r)) and (g == math.floor(g)) and (b == math.floor(b)) and (r > 1 or g > 1 or b > 1) then
		r = r <= 255 and r >= 0 and r or 0;
		g = g <= 255 and g >= 0 and g or 0;
		b = b <= 255 and b >= 0 and b or 0;
		return string.format("%02x%02x%02x", r, g, b);
	else
		return string.format("%02x%02x%02x", r*255, g*255, b*255);
	end
end
HPH.RGBToHex = RGBToHex
