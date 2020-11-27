local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")

SLASH_HPHSC1 = "/hph"
function SlashCmdList.HPHSC(msg)
	local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")
	if cmd == "week" then
		-- date("%A") == "Wednesday"
		for i=6,0,-1 do 
			local txtDate = date("%d-%m-%y",time()-24*60*60*i)
			local msg = hph_week[txtDate]
			if msg ~= nil then HPH.Print("HPH: " .. txtDate .. " - " .. msg) end
		end
		return
	end
	if cmd == "search" then
		HPH.Print("HPH: " .. (args:gsub("^%l", string.upper)) .. " killed " .. HPH.GetTimesKilled((args:gsub("^%l", string.upper))) .. " times today.")
		return
	end
	
	InterfaceOptionsFrame_OpenToCategory(HPH.optionsFrames.HPH)
	InterfaceOptionsFrame_OpenToCategory(HPH.optionsFrames.HPH)
end