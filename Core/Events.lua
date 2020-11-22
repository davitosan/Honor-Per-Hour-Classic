local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

HPH.Events = CreateFrame("Frame","BCTEvents",UIParent)

HPH.Events:RegisterEvent("PLAYER_LOGIN")
HPH.Events:RegisterEvent("PLAYER_REGEN_DISABLED")
HPH.Events:RegisterEvent("PLAYER_REGEN_ENABLED")
HPH.Events:RegisterEvent("PLAYER_ENTERING_WORLD")
HPH.Events:RegisterEvent("CHAT_MSG_COMBAT_HONOR_GAIN")

HPH.Events:RegisterEvent("UPDATE_BATTLEFIELD_SCORE")

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
		HPH.PlayerZoned()
		return
	end
	if event == "CHAT_MSG_COMBAT_HONOR_GAIN" then
		local honor_msg = select(1,...)
		if honor_msg ~= nil then
			local msg = ""
			local honor_nominal = HPH.GetHonor(honor_msg)

			if string.match(honor_msg, "%(") == nil then -- BG
				hph_killsdb[getn(hph_killsdb) + 1] = {
					"HPHBGHONORAWARDED",
					honor_nominal, 
					honor_nominal, 
					time()
					}
				HPH.honor_today = HPH.honor_today + honor_nominal
				HPH.honor_session = HPH.honor_session + honor_nominal
				msg = HPH.systemColor .. "+honor - " .. honor_nominal .. "|r (|cff0099ffBG" .. HPH.systemColor .. ")"
			else
				local name, classToken, rank = HPH.ParseHonorMessage(honor_msg)
				local timesKilled = HPH.GetTimesKilled(name)
				local discount, discountHex = HPH.GetDiscountRate(timesKilled)
				local coef = 1 - discount
				local honor_real = honor_nominal * coef
				local optChatType = HPH.GetOption("chat_system_type")

				--print("name: " .. name)
				--print("discount : " .. discount)
				--print("coef: " .. coef)
				--print("honor_real: " .. honor_real)
				
				HPH.hk_today_nominal, _ = GetPVPSessionStats()

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
					local rankOutput = HPH.GetHPHRankOutput(rank)
					local victimname = name
					local server = HPH.systemColor .. "-"
					if string.match(name, "-") then
						victimname, victimserver = name:match("([^,]+)-([^,]+)")
						server = HPH.systemColor .. "-" .. victimserver .. "|r | " .. HPH.systemColor
					end

					if optChatType == "VerboseColored" then
						--Get Class Color
						local sourceHex = "fffffb00"
						if classToken ~= nil then
							if classToken == "SHAMAN" then
								sourceHex = "ff0070DE"
							else
								_, _, _, sourceHex = GetClassColor(classToken)
							end
						end
						
						msg = "|c" .. sourceHex .. victimname .. server .. rankOutput .. "|r | " .. HPH.systemColor .. "Kills: |r" .. discountHex .. timesKilled + 1 .. "|r | " .. HPH.systemColor .. "Honor: " .. discountHex .. math.floor(honor_real) .. HPH.systemColor .. " (|r" .. discountHex .. coef * 100 .. "%|r" .. HPH.systemColor .. ")|r"
					elseif optChatType == "Verbose" then
						msg = HPH.systemColor .. victimname .. server .. rankOutput .. " | Kills: " .. timesKilled + 1 .. " | Honor: " .. math.floor(honor_real) .. " (" .. coef * 100 .. "%)"
					elseif optChatType == "Compact" then
						msg = HPH.systemColor .. "+honor - " .. math.floor(honor_real) .. " of " .. honor_nominal .. " (|r" .. discountHex .. coef * 100 .. "%|r" .. HPH.systemColor .. ")|r"
					end
				end
			end
			
			if optChatType ~= "None" then print(msg) end
		end

		hph_week[date("%d-%m-%y",hph_today[1])] = HPH.honor_today
		return
	end

	if event == "UPDATE_BATTLEFIELD_SCORE" then
		--print("UPDATE_BATTLEFIELD_SCORE")
		return
	end

	if event == "PLAYER_REGEN_DISABLED" then
		if HPH.GetOption("chat_combat") then 
			if UnitIsPVP("player") == false then
				return
			end

			local msg = "-Combat entered"
			print(msg) 
			HPH.killsInFight = 0
			HPH.honorSumNom = 0
			HPH.honorSumReal = 0
		end
		return
	end
	
	if event == "PLAYER_REGEN_ENABLED" then
		if HPH.GetOption("chat_combat") then 
			if UnitIsPVP("player") == false then
				return
			end

			local optChatType = HPH.GetOption("chat_system_type")

			--Compact
			if optChatType == "Compact" or optChatType == "None" then
				print("-Combat ended: " .. math.floor(HPH.honorSumReal) .. " of " .. HPH.honorSumNom .. " (" ..  HPH.killsInFight .. " kills)")
			
				return
			end

			local msg = "-Combat ended"
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
			
			print("-Combat ended: Kills: " .. HPH.killsInFight .. " | Honor: |r" .. discountHex .. math.floor(HPH.honorSumReal) .. "|r of |r" .. discountHex .. HPH.honorSumNom .. "|r | (" .. discountHex .. pct .. "%|r)")
		end
		return
	end
end)