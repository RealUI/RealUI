local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "MiscSkins"
local MiscSkins = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

function MiscSkins:Skin()
	local F, C
	if Aurora then 
		F = Aurora[1]
		C = Aurora[2]
	end

	-- Clique
	if F and CliqueSpellTab then
		local tab = CliqueSpellTab
		F.ReskinTab(CliqueSpellTab)

		tab:SetCheckedTexture(C.media.checked)

		local bg = CreateFrame("Frame", nil, tab)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(tab:GetFrameLevel()-1)
		F.CreateBD(bg)

		F.CreateSD(tab, 5, 0, 0, 0, 1, 1)

		select(6, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
	end

	-- Time Manager unnecessary buttons
	if TimeManagerMilitaryTimeCheck then TimeManagerMilitaryTimeCheck:Hide() end
	if TimeManagerLocalTimeCheck then TimeManagerLocalTimeCheck:Hide() end
	if TimeManagerFrame then
		TimeManagerFrame:SetHeight(TimeManagerFrame:GetHeight() - 60)
		TimeManagerAlarmEnabledButton:ClearAllPoints()
		TimeManagerAlarmEnabledButton:SetPoint("TOPLEFT", TimeManagerAlarmMessageEditBox, "BOTTOMLEFT", -6, -4)
	end
end

function MiscSkins:ADDON_LOADED(event, addon)
	if addon =="Blizzard_DebugTools" then
		-- EventTrace
		for i = 1, EventTraceFrame:GetNumRegions() do
			local region = select(i, EventTraceFrame:GetRegions())
			if region:GetObjectType() == "Texture" then
				region:SetTexture(nil)
			end
		end
		EventTraceFrame:SetHeight(600)
		EventTraceFrameScroll:Hide()
		if Aurora then Aurora[1].ReskinClose(EventTraceFrameCloseButton) end
	end
end
----------

function MiscSkins:OnInitialize()
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Miscellaneous")
end

function MiscSkins:OnEnable()
	self:Skin()
	self:RegisterEvent("ADDON_LOADED")
end