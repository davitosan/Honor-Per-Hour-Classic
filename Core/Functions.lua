local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

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

-- Parse Honor Message for nominal honor
local function GetHonor(inp)
    return tonumber(string.match(inp, "%d+"))
end
HPH.GetHonor = GetHonor

-- Parse Honor Message for name and return it with server suffix
local function GetName(inp)
	local msgName = string.match(inp or "", "^([^%s]+)")
	
	-- In World
	if GetNumBattlefieldScores() == 0 then 
		return msgName .. "-" .. GetRealmName()
	end

	-- Look at Combat Log Cache first
	if HPH.hph_playersdb[msgName] ~= nil then
		return msgName .. "-" .. HPH.hph_playersdb[msgName][1]
	end	
	
	-- Look at Battleground scoreboard
	for i=1,GetNumBattlefieldScores(),1 do 
		local name = GetBattlefieldScore(i) or ""
		if string.find(name, "-") or 0 > 0 then -- Player from other realm
			if string.match(name, "(.-)-%s*") == msgName then
				return name
			end
		elseif name == msgName then  -- Player from own realm
			return name .. "-" .. GetRealmName()
		end
	end
	
	-- In BG, but empty player name on scoreboard
	return msgName .. "-Unknown" 
end
HPH.GetName = GetName

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

local function GetFactionByRace(Race)
	if Race ~= nil then
		if Race == "Tauren" or Race == "Scourge" or Race == "Orc" or Race == "Troll" then
			return "Horde"
		end

		if Race == "Human" or Race == "Gnome" or Race == "NightElf" or Race == "Dwarf" then
			return "Alliance"
		end
	end

	return "Unknown"
end
HPH.GetFactionByRace = GetFactionByRace

local function addComas(str)
	return #str % 3 == 0 and str:reverse():gsub("(%d%d%d)", "%1."):reverse():sub(2) or str:reverse():gsub("(%d%d%d)", "%1."):reverse()
end
HPH.addComas = addComas

local function DumpKillsDB(editBox)
	if hph_killsdb ~= nil then
		for i=getn(hph_killsdb),1,-1 do 
			editBox:Insert(("Name: " .. hph_killsdb[i][1] .. " Honor(Real): " .. hph_killsdb[i][2] .. " Honor(Nominal): " .. hph_killsdb[i][3] .. " Time: " .. hph_killsdb[i][4]) .. "\n")
		end
	end

	if hph_killsdb == nil or getn(hph_killsdb) == 0 then
		editBox:Insert("EMPTY")
	end
end

local function DumpPlayersDB(editBox)
	local count = 0
	if HPH.hph_playersdb ~= nil then
		for k, v in pairs(HPH.hph_playersdb) do
			editBox:Insert("Name: " .. k .. " Server: " .. v[1] .. " Class: " .. v[2] .. "\n")
			count = count + 1
		end
	end

	if count == 0 then
		editBox:Insert("EMPTY")
	end
end

local function DebugDumpDatabase(database)
	--Setup Frame
	local editFrame = CreateFrame("ScrollFrame", "DebugDBDumpFrame", UIParent, "InputScrollFrameTemplate")
	editFrame:SetPoint("CENTER")
	editFrame:SetSize(700, 500)
	editFrame:Hide()
	--So interface options and this frame will open on top of each other.
	if InterfaceOptionsFrame:IsShown() then
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

	if database == "killsdb" then
		DumpKillsDB(editBox)
	elseif database == "playersdb" then
		DumpPlayersDB(editBox)
	end

	editFrame:Show()
	editBox:HighlightText()
	editBox:SetFocus()
end
HPH.DebugDumpDatabase = DebugDumpDatabase
