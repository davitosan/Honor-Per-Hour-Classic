local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

-- Get Rank Color
local rankColors = 
{
	HPH.systemColor, --Rank 0 (Unknown) fffb00
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

local function GetRankOutput(rank)
	local opt = HPH.GetOption("chat_system_type")
	local rankLabel = "Rank:"
	local rankIndex = 0

	if "Scout" == rank or "Private" == rank then
		rankIndex = 1
	elseif "Grunt" == rank or "Corporal" == rank then
		rankIndex = 2
	elseif "Sergeant" == rank or "Sergeant" == rank then
		rankIndex = 3
	elseif "Senior Sergeant" == rank or "Master Sergeant" == rank then
		rankIndex = 4
	elseif "First Sergeant" == rank or "Sergeant Major" == rank then
		rankIndex = 5
	elseif "Stone Guard" == rank or "Knight" == rank then
		rankIndex = 6
	elseif "Blood Guard" == rank or "Knight-Lieutenant" == rank then
		rankIndex = 7
	elseif "Legionnaire" == rank or "Knight-Captain" == rank then
		rankIndex = 8
	elseif "Centurion" == rank or "Knight-Champion" == rank then
		rankIndex = 9
	elseif "Champion" == rank or "Lieutenant Commander" == rank then
		rankIndex = 10
	elseif "Lieutenant General" == rank or "Commander" == rank then
		rankIndex = 11
	elseif "General" == rank or "Marshal" == rank then
		rankIndex = 12
	elseif "Warlord" == rank or "Field Marshal" == rank then
		rankIndex = 13
	elseif "High Warlord" == rank or "Grand Marshal" == rank then
		rankIndex = 14
	else
		rank = "Unknown"
		rankIndex = 0
	end

	local rankColor = HPH.systemColor
	if opt == "VerboseColored" then
		rankColor = rankColors[rankIndex + 1]
	end

	return rankLabel .. rankColor .. " " .. rank .. " " .. HPH.systemColor .. "(" .. rankColor .. rankIndex .. HPH.systemColor.. ")"
end

local function GetServerOutput(victim)
	local server = "Unknown"
	--Look at Combat Log Cache first
	if HPH.hph_playersdb[victim] ~= nil then
		server = HPH.hph_playersdb[victim][1]
	end

	--Look at Scoreboard
	if server == "Unknown" then

	end

	local serverOutput = ""
	local optChatType = HPH.GetOption("chat_system_type")
	if optChatType == "VerboseColored" or optChatType == "Verbose" then
		serverOutput = HPH.systemColor .. "-" .. server .. "|r | " .. HPH.systemColor
	end
	
	return serverOutput
end

local function GetVictimOutput(victim)
	local optChatType = HPH.GetOption("chat_system_type")
	if optChatType ~= "VerboseColored" then
		return victim
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
	return HPH.systemColor .. victim
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
		msg = victimOutput .. serverOutput .. rankOutput .. HPH.systemColor .. " | Kills: |r" .. discountHex .. timesKilled + 1 .. HPH.systemColor .. " | " .. HPH.systemColor .. "Honor: " .. discountHex .. math.floor(honor_real) .. HPH.systemColor .. " (" .. discountHex .. coef * 100 .. "%" .. HPH.systemColor .. ")|r"
	elseif optChatType == "Verbose" then
		msg = HPH.systemColor .. victimOutput .. serverOutput .. rankOutput .. " | Kills: " .. timesKilled + 1 .. " | Honor: " .. math.floor(honor_real) .. " (" .. coef * 100 .. "%)"
	elseif optChatType == "Compact" then
		msg = HPH.systemColor .. "+honor - " .. math.floor(honor_real) .. " of " .. honor_nominal .. " (|r" .. discountHex .. coef * 100 .. "%|r" .. HPH.systemColor .. ")|r"
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

	print(msg)
end
HPH.UpdateCombatSummary = UpdateCombatSummary