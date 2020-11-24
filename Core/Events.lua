local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

HPH.Events = CreateFrame("Frame","BCTEvents",UIParent)

HPH.Events:RegisterEvent("PLAYER_LOGIN")
HPH.Events:RegisterEvent("PLAYER_ENTERING_WORLD")
HPH.Events:RegisterEvent("PLAYER_REGEN_DISABLED")
HPH.Events:RegisterEvent("PLAYER_REGEN_ENABLED")
HPH.Events:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")
HPH.Events:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

HPH.Events:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

ChatFrame_AddMessageEventFilter("CHAT_MSG_COMBAT_HONOR_GAIN", HPH.myChatFilter)

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
	if event == "PLAYER_ENTERING_WORLD" then
		HPH.hph_playersdb = {} --Reset our Player Cache
		return
	end
	if event == "COMBAT_LOG_EVENT_UNFILTERED" then
		local timestamp, subEvent, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, 
			destName, destFlags, destRaidFlags, _, spellName = CombatLogGetCurrentEventInfo();
		if destGUID ~= nil and destGUID ~= "" and destGUID ~= " " then
			localizedClass, englishClass, localizedRace, englishRace, sex, name, realm = GetPlayerInfoByGUID(destGUID)

			--Players Only
			local faction = HPH.GetFactionByRace(englishRace)
			if faction == "Unknown" then
				return
			end

			--Only add players of opposing faction
			if faction == UnitFactionGroup("player") then
				return
			end

			--Same realm
			if realm == "" then
				realm = GetRealmName()
			end

			if HPH.hph_playersdb[name] == nil then
				HPH.hph_playersdb[name] = {
					realm,
					englishClass
					}
			end
		end
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
				if optChatType ~= "None" then
					msg = HPH.ColorizeOutput(honor_msg, name, timesKilled, honor_real)
				end
			end
			
			if optChatType ~= "None" then print(msg) end
		end

		hph_week[date("%d-%m-%y",hph_today[1])] = HPH.honor_today
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		HPH.UpdateCombatSummary(event)
		return
	end
	
	if event == "PLAYER_REGEN_DISABLED" then
		HPH.UpdateCombatSummary(event)
		return
	end
end)
