local addon = DXE
local floor = math.floor

local Timer,prototype = {},{}
DXE.Timer = Timer

function Timer:New(parent,leftsize,rightsize)
	local timer = CreateFrame("Frame",nil,parent)
	for k,v in pairs(prototype) do timer[k] = v end

	timer:SetWidth(80); timer:SetHeight(20)

	local left = timer:CreateFontString(nil,"OVERLAY")
	left:SetPoint("LEFT",timer,"LEFT")
	left:SetWidth(60)
	left:SetHeight(20)
	left:SetJustifyH("RIGHT")
	addon:RegisterTimerFontString(left,leftsize or 20)
	timer.left = left

	local right = timer:CreateFontString(nil,"OVERLAY")
	right:SetPoint("BOTTOMLEFT",left,"BOTTOMRIGHT",0,2)
	right:SetWidth(20)
	right:SetHeight(12)
	right:SetJustifyH("LEFT")
	addon:RegisterTimerFontString(right,rightsize or 12)
	timer.right = right

	left:SetText("0:00")
	right:SetText("00")

	return timer
end

function prototype:SetTime(time)
	if time < 0 then time = 0 end
	local dec = (time - floor(time)) * 100
	local min = floor(time/60)
	local sec = time % 60
	self.left:SetFormattedText("%d:%02d",min,sec)
	self.right:SetFormattedText("%02d",dec)
end
