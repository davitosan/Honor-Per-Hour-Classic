local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

-- Returns honor for current honor day
local function GetHonorDay()
	local honor_today = 0
	
	HPH.SetToday()

	if hph_killsdb ~= nil then
		for i=getn(hph_killsdb),1,-1 do 
			if HPH.IsTimestampToday(hph_killsdb[i][4]) then
				honor_today = honor_today + hph_killsdb[i][2]
			else
				return honor_today
			end
		end
	end

	return honor_today
end
HPH.GetHonorDay = GetHonorDay

local function GetHonorLastHour()
    local honorLastHour = 0

	if hph_killsdb ~= nil then
		for i=getn(hph_killsdb),1,-1 do 
			if hph_killsdb[i][4] > time()-60*60 then
				honorLastHour = honorLastHour + hph_killsdb[i][2]
			else
				return honorLastHour
			end
		end
	end
	
	return honorLastHour
end
HPH.GetHonorLastHour = GetHonorLastHour

-- Returns times killed for current honor day
local function GetTimesKilled(name)
	local timesKilled = 0

	if hph_killsdb ~= nil then
		for i=getn(hph_killsdb),1,-1 do 
			if HPH.IsTimestampToday(hph_killsdb[i][4]) then
				if hph_killsdb[i][1] == name then timesKilled = timesKilled + 1 end
			else
				return timesKilled
			end		
		end
	end
	
	return timesKilled
end
HPH.GetTimesKilled = GetTimesKilled

local function GetHKsToday()
	local hks_today_dr = 0
	
	if hph_killsdb ~= nil then
		for i=getn(hph_killsdb),1,-1 do 
			if HPH.IsTimestampToday(hph_killsdb[i][4]) then
				if hph_killsdb[i][2] == 0 then hks_today_dr = hks_today_dr + 1 end
			else
				return HPH.hk_today_nominal - hks_today_dr
			end		
		end
	end
	
	return HPH.hk_today_nominal - hks_today_dr
end
HPH.GetHKsToday = GetHKsToday

local function GetTimeSinceLastKill(name)

	if hph_killsdb ~= nil then
		for i=getn(hph_killsdb),1,-1 do 
			if hph_killsdb[i][1] == name then 
				local Time = time() - hph_killsdb[i][4] 
				local TimeTotal = math.floor(Time / 60)
				local TimeHours = math.floor(TimeTotal / 60)
				local TimeElapsed = TimeHours .. "h" .. TimeTotal - TimeHours * 60 .. "m"-- .. math.fmod(Time,60) .. "s"
				
				return TimeElapsed
			end
		end
	end
	
	return 1
end
HPH.GetTimeSinceLastKill = GetTimeSinceLastKill

-- Removes any kill entries not in current honor day from DB
local function PurgeKillDB()
	local newdb = {}

	if hph_killsdb ~= nil then 
		for i=1,getn(hph_killsdb),1 do 
			if HPH.IsTimestampToday(hph_killsdb[i][4]) then
				newdb[(getn(newdb) or 0) + 1] = hph_killsdb[i]
			end
		end
		
		hph_killsdb = newdb
		newdb = nil
	end

end
HPH.PurgeKillDB = PurgeKillDB