local addonName, addon = ...
if not addon.healthCheck then return end
local L = addon.L

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local plugin = ldb:NewDataObject(addonName, {
	type = "data source",
	text = "0",
	icon = "Interface\\AddOns\\BugSack\\Media\\icon",
})

local BugGrabber = BugGrabber

function plugin.OnClick(self, button)
	if button == "RightButton" then
		InterfaceOptionsFrame_OpenToCategory(addonName)
		InterfaceOptionsFrame_OpenToCategory(addonName)
	else
		if IsShiftKeyDown() then
			ReloadUI()
		elseif IsAltKeyDown() then
			addon:Reset()
		elseif BugSackFrame and BugSackFrame:IsShown() then
			addon:CloseSack()
		else
			addon:OpenSack()
		end
	end
end

hooksecurefunc(addon, "UpdateDisplay", function()
	local count = #addon:GetErrors(BugGrabber:GetSessionId())
	plugin.text = count
	plugin.icon = count == 0 and "Interface\\AddOns\\BugSack\\Media\\icon" or "Interface\\AddOns\\BugSack\\Media\\icon_red"
end)

do
	local hint = L["|cffeda55fClick|r to open BugSack with the last bug. |cffeda55fShift-Click|r to reload the user interface. |cffeda55fAlt-Click|r to clear the sack."]
	local line = "%d. %s (x%d)"
	function plugin.OnTooltipShow(tt)
		local errs = addon:GetErrors(BugGrabber:GetSessionId())
		if #errs == 0 then
			tt:AddLine(L["You have no bugs, yay!"])
		else
			tt:AddLine(addonName)
			for i, err in next, errs do
				tt:AddLine(line:format(i, addon.ColorStack(err.message), err.counter), .5, .5, .5)
				if i > 8 then break end
			end
		end
		tt:AddLine(" ")
		tt:AddLine(hint, 0.2, 1, 0.2, 1)
	end
end

local f = CreateFrame("Frame")
f:SetScript("OnEvent", function()
	local icon = LibStub("LibDBIcon-1.0", true)
	if not icon then return end
	if not BugSackLDBIconDB then BugSackLDBIconDB = {} end
	icon:Register(addonName, plugin, BugSackLDBIconDB)
end)
f:RegisterEvent("PLAYER_LOGIN")

