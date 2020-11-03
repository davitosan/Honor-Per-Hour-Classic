local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

HPH.Events = CreateFrame("Frame","BCTEvents",UIParent)

HPH.Events:RegisterEvent("PLAYER_LOGIN")
HPH.Events:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
HPH.Events:RegisterEvent("PLAYER_REGEN_DISABLED")
HPH.Events:RegisterEvent("PLAYER_REGEN_ENABLED")

HPH.Events:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" then
		HPH.SetToday()
		HPH.PurgeKillDB()
		HPH.UpdateFont()
		HPH.UpdateFrameState()
		HPH.honor_today = HPH.GetHonorDay()
		_, HPH.honor_week = GetPVPThisWeekStats()
		HPH.hk_today_nominal, _ = GetPVPSessionStats()
		HPH.hk_today_real = HPH.GetHKsToday()
		return
	end
	if event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
		local honor_msg = select(1,...)
		if honor_msg ~= nil then
			local name = HPH.GetName(honor_msg)
			local honor_nominal = HPH.GetHonor(honor_msg)
			local timesKilled = HPH.GetTimesKilled(name)
			local discount, discountHex = HPH.GetDiscountRate(timesKilled)
			local coef = 1 - discount
			local honor_real = honor_nominal * coef
			local optChatHonor = HPH.GetOption("chat_honor")
			local msg = ""
			
			--print(discount)
			--print(coef)
			--print(honor_nominal)
			--print(honor_real)
			
			HPH.hk_today_nominal, _ = GetPVPSessionStats()

			if string.match(honor_msg, "%(") == nil then -- BG
				hph_killsdb[getn(hph_killsdb) + 1] = {
					"HPHBGHONORAWARDED",
					honor_nominal, 
					honor_nominal, 
					time()
					}
				HPH.honor_today = HPH.honor_today + honor_nominal
				HPH.honor_session = HPH.honor_session + honor_nominal
				if optChatHonor then
					msg = "|cfffffb00+honor - " .. honor_nominal .. "|r (|cff0099ffBG|r|cfffffb00)"
				end
			else
				hph_killsdb[getn(hph_killsdb) + 1] = {
					name,
					honor_real, 
					honor_nominal, 
					time()
					}
				HPH.honor_today = HPH.honor_today + honor_real
				HPH.honor_session = HPH.honor_session + honor_real
				if honor_real > 0 then HPH.hk_today_real = HPH.hk_today_real + 1 end
				if HPH.GetOption("chat_combat") then 
					HPH.killsInFight = HPH.killsInFight + 1
					HPH.honorSumNom = HPH.honorSumNom + honor_nominal
					HPH.honorSumReal = HPH.honorSumReal + honor_real
				end
				if optChatHonor then
					msg = "|cfffffb00+honor - " .. honor_real .. " of " .. honor_nominal .. " (|r" .. discountHex .. coef * 100 .. "%|r|cfffffb00)|r"
				end
			end
			
			if optChatHonor then print(msg) end
		end

		hph_week[date("%d-%m-%y",hph_today[1])] = HPH.honor_today
		return
	end

	if event == "PLAYER_REGEN_DISABLED" then
		if HPH.GetOption("chat_combat") then 
			local msg = "-Combat entered"
			print(msg) 
			HPH.killsInFight = 0
			HPH.honorSumNom = 0
			HPH.honorSumReal = 0
		end
		return
	end
	
	if event == "PLAYER_REGEN_DISABLED" then
		if HPH.GetOption("chat_combat") then 
			local msg = ((HPH.killsInFight or 0) > 1 and
				"-Combat ended: " .. HPH.honorSumReal .. " of " .. HPH.honorSumNom .. " (" ..  HPH.killsInFight .. " kills)" or
				"-Combat ended" )
			print(msg) 
		end
		return
	end

end)