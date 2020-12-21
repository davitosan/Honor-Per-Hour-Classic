local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

local function GetCorpseName()
	local function frFR(Text)
		return Text:match("^Cadavre de ([^%s%p%d%c]+)$") or Text:match("^Cadavre d'([^%s%p%d%c]+)$") or ""
	end
	if not UnitExists("mouseover") and GetMouseFocus() == WorldFrame and GameTooltip:IsVisible() and GameTooltip:NumLines() <= 2 then
		local Text = GameTooltipTextLeft1:GetText();
		if HPH.locale == "ruRU" then
			return (Text ~= nil and string.match(Text, "^Труп ([^%s%p%d%c]+)$") or "")
		elseif HPH.locale == "deDE" then
			return (Text ~= nil and string.match(Text, "^Leichnam von ([^%s%p%d%c]+)$") or "")
		elseif HPH.locale == "frFR" then
			return (Text ~= nil and string.match(Text, frFR(Text)) or "")
		elseif HPH.locale == "esES" or HPH.locale == "esMX" then
			return (Text ~= nil and string.match(Text, "^Cadáver de ([^%s%p%d%c]+)$") or "")
		elseif HPH.locale == "zhTW" then
			return (Text ~= nil and string.match(Text, "^([^%s%p%d%c]+)的屍體$") or "")
		elseif HPH.locale == "zhCN" then
			return (Text ~= nil and string.match(Text, "^([^%s%p%d%c]+)的尸体$") or "")
		elseif HPH.locale == "ptPT" then
			return (Text ~= nil and string.match(Text, "^Cadáver de ([^%s%p%d%c]+)$") or "")
		elseif HPH.locale == "koKR" then
			return (Text ~= nil and string.match(Text, "^([^%s%p%d%c]+)의 시체$") or "")
		elseif HPH.locale == "itIT" then
			return (Text ~= nil and string.match(Text, "^Corpo di ([^%s%p%d%c]+)$") or "")
		else
			return (Text ~= nil and string.match(Text, "^Corpse of ([^%s%p%d%c]+)$") or "")
		end
	end
	return ""
end

local toolchanged = false
GameTooltip:HookScript("OnUpdate", function(self)
	-- Alive enemy
	if HPH.GetOption("tooltip_enemy") then
		if toolchanged == true and UnitIsEnemy("player","mouseover") and UnitIsPlayer("mouseover") then
			local unitNameFull = HPH.GetName(UnitName("mouseover"))

			if(unitNameFull == nil) or (string.match(unitNameFull, "-Unknown")) then
				return
			end

			local timesKilled = HPH.GetTimesKilled(unitNameFull)
			local discountRate, discountHex = HPH.GetDiscountRate(timesKilled)
			self:AddLine("|r" .. discountHex .. (1 - discountRate) * 100 .. "|r% - |r" .. discountHex .. timesKilled .. "|r " .. HPH.consts["Kills"] .. "|r")
			self:Show()
			toolchanged = false
			return
		end
	end

	-- Corpse
	if HPH.GetOption("tooltip_corpse") then
		local corpseName = GetCorpseName()
		if toolchanged == true and string.len(corpseName) > 0 then
			local corpseNameFull = HPH.GetName(corpseName)

			if(corpseNameFull == nil) or (string.match(corpseNameFull, "-Unknown")) then
				return
			end

			local timesKilled = HPH.GetTimesKilled(corpseNameFull)
			if timesKilled > 0 then
				local discountRate, discountHex = HPH.GetDiscountRate(timesKilled)
				local timeSinceKill = (HPH.GetTimeSinceLastKill(corpseNameFull) == 1 and "" or HPH.GetTimeSinceLastKill(corpseNameFull))
				self:AddLine("|r" .. discountHex .. (1 - discountRate) * 100 .. "|r% - |r" .. discountHex .. timesKilled .. "|r " .. HPH.consts["Kills"] .. " - " .. timeSinceKill .. " " .. HPH.consts["ago"] .. "|r")
				self:Show()
				toolchanged = false
				return
			end
		end
	end
end)

GameTooltip:HookScript("OnTooltipCleared", function(self) 
	toolchanged = true
end)