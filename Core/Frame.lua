local HPH = LibStub("AceAddon-3.0"):GetAddon("HPH")
local SM = LibStub:GetLibrary("LibSharedMedia-3.0")

SM:Register("font", "Expressway", [[Interface\AddOns\HPH\Fonts\Expressway.ttf]])
SM:Register("font", "PT Sans Narrow", [[Interface\AddOns\HPH\Fonts\PTSansNarrow.ttf]])

local function UpdateFont()
	HPH.Window.text:SetFont(SM:Fetch("font",HPH.GetOption("font")), HPH.GetOption("font_size"), "OUTLINE")
end
HPH.UpdateFont = UpdateFont

local function UpdateFrameState()
	if HPH.GetOption("show") then
		HPH.Window:Show()
	else
		HPH.Window:Hide()
	end
	if not HPH.GetOption("moveable") then
		HPH.Window:SetScript("OnDragStart", nil)
		HPH.Window:SetScript("OnDragStop", nil)
	else
		HPH.Window:SetScript("OnDragStart", HPH.Window.StartMoving)
		HPH.Window:SetScript("OnDragStop", HPH.Window.StopMovingOrSizing)
	end
end
HPH.UpdateFrameState = UpdateFrameState

HPH.Window = CreateFrame("Frame","HPHTxtFrame",UIParent)
HPH.Window:SetMovable(true)
HPH.Window:EnableMouse(true)
HPH.Window:RegisterForDrag("LeftButton")
HPH.Window:SetWidth(150)
HPH.Window:SetHeight(50)
HPH.Window:SetAlpha(1.)
HPH.Window:SetPoint("CENTER",0,0)
HPH.Window.text = HPH.Window:CreateFontString(nil,"ARTWORK") 
HPH.UpdateFont()
HPH.Window.text:SetPoint("LEFT", HPH.Window, "LEFT", 10)
HPH.Window.text:SetJustifyH("LEFT")
HPH.Window.text:SetText("Something is wrong")
HPH.Window:SetUserPlaced(true)
HPH.Window:SetScript("OnUpdate", function(self) 
	-- Update honor today at reset
	if (hph_today[2] or 0) < time() then HPH.honor_today = HPH.GetHonorDay() end
	
	local Time = GetTime() - HPH.timeAtLogin
	local TimeTotal = math.floor(Time / 60)
    local TimeHours = math.floor(TimeTotal / 60)
    local TimeElapsed = TimeHours .. "h" .. TimeTotal - TimeHours * 60 .. "m"
	
	local txtWeekly = HPH.GetOption("error") and 
		"Honor: " .. HPH.addComas(tostring(floor(HPH.honor_today+HPH.honor_week))) .. " ± (e < " .. HPH.hk_today_real  .. ")" or
		"Honor: " .. HPH.addComas(tostring(floor(HPH.honor_today+HPH.honor_week)))
	local txtHonorToday = HPH.addComas(tostring(floor(HPH.honor_today)))
	local txtPastHour = floor(HPH.GetHonorLastHour()/100)/10 .. "k"
	local txtSession = floor(HPH.honor_session/100)/10 .. "k"
	local txtHonorPerHourSession = floor(math.floor(3600 * HPH.honor_session / Time)/100)/10 .. "k"

    local txt = (txtWeekly ..
		"\nHonor Today: " .. txtHonorToday ..
		"\nHonor Past Hour: " .. txtPastHour ..
		"\nHonor Session: " .. txtSession ..
		"\nHonor/h: " .. txtHonorPerHourSession ..
		"\nSession: " .. TimeElapsed
		)

	self.text:SetText(txt)
	if HonorFrame:IsVisible() then HPH.UpdateHonorFrame() end
	
end)