local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "SkinGrid2"
local SkinGrid2 = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

function SkinGrid2:Skin()
	if not Grid2 then return end

	-- Grid2LayoutHeader1UnitButton1
	for k, frame in pairs(Grid2Frame.registeredFrames) do
		if not frame.realUISkinned then
			-- Border
			if not frame.newBorder then
				frame.newBorder = nibRealUI:CreateBDFrame(frame, 0)
					frame.newBorder:SetPoint("TOPLEFT", frame, 1, -1)
					frame.newBorder:SetPoint("BOTTOMRIGHT", frame, -1, 1)
			end

			-- Health Deficit
			if frame["health-deficit"] then
				frame["health-deficit"]:SetReverseFill(true)
			end

			frame.realUISkinned = true
		end
	end
end

----------

function SkinGrid2:OnInitialize()
	nibRealUI:RegisterSkin(MODNAME, "Grid2")
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
end

function SkinGrid2:OnEnable()
	if self.grid2Hooked then return end
	if not Grid2Layout then return end

	hooksecurefunc(Grid2Layout, "UpdateSize", function() SkinGrid2:Skin() end)
	
	self.grid2Hooked = true
end