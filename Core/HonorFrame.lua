local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

local function UpdateHonorFrame()
	-- Overwrite honorspy predictions
	if HPH.GetOption("honorspy") then
		HonorFrameCurrentHKValue:SetText(HPH.hk_today_nominal)
		HonorFrameThisWeekContributionValue:SetText(HPH.honor_week)
	end
	
	-- Swap DK with Honor for Today
	if HPH.GetOption("honortab") then
		HonorFrameCurrentDKText:SetText("Honor")
		HonorFrameCurrentDKValue:SetTextColor(255,251,0,1)
		HonorFrameCurrentDKValue:SetText(floor(HPH.honor_today))
	else
		HonorFrameCurrentDKText:SetText("Dishonorable Kills")
		HonorFrameCurrentDKValue:SetTextColor(255,0,0,1)
		HonorFrameCurrentDKValue:SetText(0)
	end

end
HPH.UpdateHonorFrame = UpdateHonorFrame

