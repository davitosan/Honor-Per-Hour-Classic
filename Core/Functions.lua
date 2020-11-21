local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")
local timers = LibStub("AceTimer-3.0")

local RequestBattlefieldScoreDataTimer

local function GetOption(option)
	return (hph_options[option] == nil and hph_options_defaults[option] or hph_options[option])
end
HPH.GetOption = GetOption

-- this is called after eventg	ww
local function myChatFilter(_s, e, msg, ...)
	if HPH.GetOption("chat_system_honor") then
		return true
	end

	return false
end
HPH.myChatFilter = myChatFilter

--Called from Event "PLAYER_ENTERING_WORLD"
local function PlayerZoned()
	timers:ScheduleTimer(HPH.Check_ZONE_CHANGED_NEW_AREA, 0.5)
end
HPH.PlayerZoned = PlayerZoned

--Looking for Battleground to start RequestBattlefieldScoreData timer
local function Check_ZONE_CHANGED_NEW_AREA (...)
	local zoneName, zoneType, _, _, _, _, _, zoneMapID = GetInstanceInfo()
	if zoneType == "pvp" then --> battlegrounds
		HPH.BgScoreUpdate() -- RequestBattlefieldScoreData right away
		HPH.StartBgUpdater() -- Start the timer
	else
		if RequestBattlefieldScoreDataTimer ~= nil then
			timers:CancelTimer(RequestBattlefieldScoreDataTimer)
			RequestBattlefieldScoreDataTimer = nil
		end
	end
end
HPH.Check_ZONE_CHANGED_NEW_AREA = Check_ZONE_CHANGED_NEW_AREA

--Start the RequestBattlefieldScoreData timer
local function StartBgUpdater()
	RequestBattlefieldScoreDataTimer = timers:ScheduleRepeatingTimer(HPH.BgScoreUpdate, 30)
end
HPH.StartBgUpdater = StartBgUpdater

--Call RequestBattlefieldScoreData to get score info
local function BgScoreUpdate()
	--print("RequestBattlefieldScoreData()")
	RequestBattlefieldScoreData()
end
HPH.BgScoreUpdate = BgScoreUpdate

-- Creates a relation between server time (H:M) and local time (UNIX)
local function SetToday()
	local ST_hour, ST_min = _G.GetGameTime()									-- Server time
	local ST_hour_reset = HPH.GetOption("time_reset")							-- Hour of server reset (Server time)
	
	local isArrayEmpty = hph_today[1] == nil 									-- First startup
	local isNewDay = ST_hour == HPH.GetOption("time_reset") and ST_min == 00	-- Recalibrates start of day if user is logged in at reset, 
																				-- to avoid spillover caused by difference in ST and LT minutes
	local isNewDayAtLogin = (hph_today[2] or 0) < time() 						-- Checks if new honor day at login

	local secsSinceReset = (ST_hour >= ST_hour_reset and
		(ST_hour-ST_hour_reset)*60*60+ST_min*60 or 				-- Before 00
		ST_hour*60*60+ST_min*60+(24-ST_hour_reset)*60*60) 		-- After 00
	local secsUntilReset = 24*60*60-secsSinceReset
		
	if isArrayEmpty or isNewDay or isNewDayAtLogin then	
		hph_today = {
			time() - secsSinceReset, -- honor day start in local time
			time() + secsUntilReset, -- honor day end in local time
		}
	end
end
HPH.SetToday = SetToday

-- Check if a timestamp is in current honor day
local function IsTimestampToday(timestamp)
	return hph_today[1] < timestamp and timestamp < hph_today[2]
end
HPH.IsTimestampToday = IsTimestampToday

--Accepts both types of RGB.
local function RGBToHex(r, g, b)
	r = tonumber(r)
	g = tonumber(g)
	b = tonumber(b)

	--Check if whole numbers.
	if r == math.floor(r) and g == math.floor(g) and b == math.floor(b)
			and (r > 1 or g > 1 or b > 1) then
		r = r <= 255 and r >= 0 and r or 0;
		g = g <= 255 and g >= 0 and g or 0;
		b = b <= 255 and b >= 0 and b or 0;
		return string.format("%02x%02x%02x", r, g, b);
	else
		return string.format("%02x%02x%02x", r*255, g*255, b*255);
	end
end
HPH.RGBToHex = RGBToHex

-- Parse Honor Message for nominal honor
local function GetHonor(inp)
    return tonumber(string.match(inp, "%d+"))
end
HPH.GetHonor = GetHonor

-- Takes PlayerName and returns it with server suffix
local function GetNameServer(inp)
	local msgName = string.match(inp or "", "^([^%s]+)")

	-- In World
	if numBattlefieldScores == 0 then 
		return msgName .. "-" .. GetRealmName()
	end
	
	-- In BG
	for i=1,GetNumBattlefieldScores(),1 do 
		local name = GetBattlefieldScore(i) or ""
		if (string.find(name, "-") or 0 > 0) and (string.match(name, "(.-)-%s*") == msgName) then -- Player from other realm
			return name
		elseif name == msgName then  -- Player from own realm
			return name .. "-" .. GetRealmName()
		end
	end
	
	-- In BG, but empty player name on scoreboard
	return msgName .. "-Unknown" 
end
HPH.GetNameServer = GetNameServer

-- Parse Honor Message for name and returns name with server suffix, class name and rank
-- XXXX dies, honorable kill Rank: XXX (Estimated Honor Points: N)
local function ParseHonorMessage(inp)
	local honor_gain_pattern = string.gsub(COMBATLOG_HONORGAIN, "%(", "%%(")
	honor_gain_pattern = string.gsub(honor_gain_pattern, "%)", "%%)")
	honor_gain_pattern = string.gsub(honor_gain_pattern, "(%%s)", "(.+)")
	honor_gain_pattern = string.gsub(honor_gain_pattern, "(%%d)", "(%%d+)")
	local victim, rank, est_honor = inp:match(honor_gain_pattern)
	local numBattlefieldScores = GetNumBattlefieldScores()

	-- In World 
	if GetNumBattlefieldScores() == 0 then
		return victim .. "-" .. GetRealmName(), nil, rank
	end

	-- In BG
	for i=1,GetNumBattlefieldScores(),1 do 
		local name, killingBlows, honorableKills, deaths, honorGained, faction, _, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i)
		if (name ~= nill) and (faction ~= nil) and (faction ~= UnitFactionGroup("player")) then
			if (string.find(name, "-") or 0 > 0) and (string.match(name, "(.-)-%s*") == victim) then -- Player from other realm
				return name, classToken, rank
			elseif name == victim then  -- Player from own realm
				return name .. "-" .. GetRealmName(), classToken, rank
			end
		end
	end

--[=====[ 
	-- In BG, but empty player name on scoreboard
	print("|cffff3700[ERROR]Could not find player name on scoreboard? |r" .. victim)

	--Debug! DO IT AGAIN!
	print("numBattlefieldScores: " .. numBattlefieldScores)
	for i=1,GetNumBattlefieldScores(),1 do 
		local name, killingBlows, honorableKills, deaths, honorGained, faction, _, race, class, classToken, damageDone, healingDone, bgRating, ratingChange, preMatchMMR, mmrChange, talentSpec = GetBattlefieldScore(i)
		print("GetBattlefieldScore(i) i: " .. i .. " | name: " .. name .. " | faction: " .. faction .. " | classToken: " .. classToken)
		if (name ~= nill) and (faction ~= nil) and (faction ~= UnitFactionGroup("player")) then
			if (string.find(name, "-") or 0 > 0) and (string.match(name, "(.-)-%s*") == victim) then -- Player from other realm
				return name, classToken, rank
			elseif name == victim then  -- Player from own realm
				return name .. "-" .. GetRealmName(), classToken, rank
			end
		end
	end
--]=====]

	return victim .. "-Unknown ", nil, rank 
end
HPH.ParseHonorMessage = ParseHonorMessage

-- Get DR coefficient
local function GetDiscountRate(timesKilled)
	--return math.min(timesKilled/10,1) "|cff00ff00"

	if timesKilled == 9 then
		return .9, "|cffff3700"
	elseif timesKilled == 8 then
		return .8, "|cffff3700"
	elseif timesKilled == 7 then
		return .7, "|cffff3700"
	elseif timesKilled == 6 then
		return .6, "|cffff7b00"
	elseif timesKilled == 5 then
		return .5, "|cffff7b00"
	elseif timesKilled == 4 then
		return .4, "|cffff7b00"
	elseif timesKilled == 3 then
		return .3, "|cffffa200"
	elseif timesKilled == 2 then
		return .2, "|cffffa200"
	elseif timesKilled == 1 then
		return .1,  "|cffffa200"
	elseif timesKilled == 0 then
		return 0., "|cff00ff00"
	else
		return 1., "|cffff0000"
	end
end
HPH.GetDiscountRate = GetDiscountRate

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

local function GetHPHRankOutput(rank)
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
		--rank = "Unknown"
		rankIndex = 0
	end

	local rankColor = HPH.systemColor
	if opt == "VerboseColored" then
		rankColor = rankColors[rankIndex + 1]
	end

	return rankLabel .. rankColor .. " " .. rank .. " " .. HPH.systemColor .. "(" .. rankColor .. rankIndex .. HPH.systemColor.. ")"
end
HPH.GetHPHRankOutput = GetHPHRankOutput

function addComas(str)
	return #str % 3 == 0 and str:reverse():gsub("(%d%d%d)", "%1."):reverse():sub(2) or str:reverse():gsub("(%d%d%d)", "%1."):reverse()
end
HPH.addComas = addComas

function DebugDumpDatabase()
	--Setup Frame
	local editFrame = CreateFrame("ScrollFrame", "DebugDBDumpFrame", UIParent, "InputScrollFrameTemplate")
	editFrame:SetPoint("CENTER")
	editFrame:SetSize(700, 500)
	editFrame:Hide()
	--So interface options and this frame will open on top of each other.
	if (InterfaceOptionsFrame:IsShown()) then
		editFrame:SetFrameStrata("DIALOG")
	else
		editFrame:SetFrameStrata("HIGH")
	end

	--Setup EditBox
	local editBox = editFrame.EditBox
	editBox:SetFont("Fonts\\ARIALN.ttf", 13)
	editBox:SetWidth(editFrame:GetWidth()) 
	editBox:SetScript("OnEscapePressed", function(self)
		-- functions
		editBox:SetText("")
		editBox:ClearFocus()
		editFrame:Hide()
	end)
	editFrame:Hide()

	-- setup edit box closing button
	local btnClose = CreateFrame("Button", "DebugDBDumpFrameClose", editFrame, "UIPanelButtonTemplate")
	btnClose:SetPoint("TOPRIGHT")
	btnClose:SetSize(25, 25)
	btnClose:SetText("x")
	btnClose:SetFrameStrata("FULLSCREEN")
	btnClose:SetScript("OnClick", function(self)
		editBox:SetText("")
		editBox:ClearFocus()
		editFrame:Hide()
	end)

	if hph_killsdb ~= nil then
		for i=getn(hph_killsdb),1,-1 do 
			editBox:Insert(("Name: " .. hph_killsdb[i][1] .. " Honor(Real): " .. hph_killsdb[i][2] .. " Honor(Nominal): " .. hph_killsdb[i][3] .. " Time: " .. hph_killsdb[i][4]) .. "\n")
		end
	end

	editFrame:Show()
	editBox:HighlightText()
	editBox:SetFocus()
end
HPH.DebugDumpDatabase = DebugDumpDatabase
