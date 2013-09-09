local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb

local _
local MODNAME = "HuDConfig_MSBT"
local HuDConfig_MSBT = nibRealUI:NewModule(MODNAME)

function HuDConfig_MSBT:UpdateFonts()
	local prof = "RealUI"
	if not(MSBTProfiles_SavedVars and MSBTProfiles_SavedVars["profiles"][prof]) then return end

	MSBTProfiles_SavedVars["profiles"][prof]["normalFontName"] = nibRealUI:Font(true)
end

function HuDConfig_MSBT:ApplySettings()
	if not(nibRealUI:DoesAddonMove("mikScrollingBattleText")) then return end
	if not IsAddOnLoaded("mikScrollingBattleText") then return end
	
	local prof = "RealUI"
	if not(MSBTProfiles_SavedVars and MSBTProfiles_SavedVars["profiles"][prof]) then return end
	
	local incWidth = MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Incoming"]["scrollWidth"] or 130
	local notifyWidth = MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Notification"]["scrollWidth"] or 300
	local xPos = ndb.positions[nibRealUI.cLayout]["HuDX"] 
				+ (ndb.positions[nibRealUI.cLayout]["UFHorizontal"] / 2)
				+ 45
	local yPos = ndb.positions[nibRealUI.cLayout]["HuDY"] + 48
	
	local MSBTPositions = {
		incoming = {x = -xPos - incWidth, y = yPos},
		outgoing = {x = xPos, y = yPos},
		notification = {
			x = ndb.positions[nibRealUI.cLayout]["HuDX"] - (notifyWidth / 2),
			y = ndb.positions[nibRealUI.cLayout]["HuDY"] + 98
		},
	}
	
	if MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Incoming"] then
		MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Incoming"]["offsetX"] = MSBTPositions.incoming.x
		MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Incoming"]["offsetY"] = MSBTPositions.incoming.y
	end
	if MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Outgoing"] then
		MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Outgoing"]["offsetX"] = MSBTPositions.outgoing.x
		MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Outgoing"]["offsetY"] = MSBTPositions.outgoing.y
	end
	if MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Notification"] then
		MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Notification"]["offsetX"] = MSBTPositions.notification.x
		MSBTProfiles_SavedVars["profiles"][prof]["scrollAreas"]["Notification"]["offsetY"] = MSBTPositions.notification.y
	end
end

----------
function HuDConfig_MSBT:OnInitialize()
	ndb = nibRealUI.db.profile
end