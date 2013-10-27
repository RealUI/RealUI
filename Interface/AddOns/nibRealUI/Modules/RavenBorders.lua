local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "RavenBorders"
local RavenBorders = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")
local SpiralBorder = nibRealUI:GetModule("SpiralBorder")

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Raven Borders",
		desc = "Adds cooldown spiral borders to Raven icons.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Raven Borders",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Adds cooldown spiral borders to Raven icons.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Raven Borders module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 30,
			},
		},
	}
	end
	return options
end

local barFrames = {
	PlayerDebuffs = true,
	TargetDebuffs = true,
}
local iconFrames = {
	PlayerBuffs = true,
	TargetBuffs = true,
	ClassBuffs = true,
}

local barBackgroundPositions = {
	PlayerDebuffs = {tx = -2, ty = 1, bx = -3, by = -1},
	TargetDebuffs = {tx = 2, ty = 1, bx = 1, by = -1},
}

local iconInset = 3

local function AttachBarBackground(bg, bar)
	-- Create or show Background
	if not bar.frame.bd then 
		bar.frame.bd = nibRealUI:CreateBDFrame(bar.frame)
		bar.frame.bd.lastGroup = ""

		-- Truncate bar names
		hooksecurefunc(bar.labelText, "SetText", function(self)
			if self.inHook then return end
			self.inHook = true
			local label = self:GetText()
			if strlen(label) > 22 then
				self:SetText(strsub(label, 1, 21).."..")
			end
			self.inHook = false
		end)
	else
		bar.frame.bd:Show()
	end
	
	-- Position for specific bar groups
	if (bar.frame.bd.lastGroup ~= bg.name) then
		bar.frame.bd:ClearAllPoints()
		bar.frame.bd:SetPoint("TOPLEFT", bar.frame, barBackgroundPositions[bg.name].tx, barBackgroundPositions[bg.name].ty)
		bar.frame.bd:SetPoint("BOTTOMRIGHT", bar.frame, barBackgroundPositions[bg.name].bx, barBackgroundPositions[bg.name].by)
	end
	bar.frame.bd.lastGroup = bg.name
end

-- Hook Raven frame creation
local function HookBars()
	-- local Animations = nibRealUI:GetModule("Animations", true)
	-- if Animations and not(nibRealUI:GetModuleEnabled("Animations")) then Animations = nil end

	Nest_CreateBar_ = Raven.Nest_CreateBar
	Raven.Nest_CreateBar = function(bg, name)
		bar = Nest_CreateBar_(bg, name)
		bar.frame:Show()
		bar.container:Show()

		-- Bars
		if barFrames[bg.name] then
			if bar.frame.ssID then SpiralBorder:RemoveSpiral(bar, bar.frame.ssID, true) end
			AttachBarBackground(bg, bar)

		-- Icons
		elseif iconFrames[bg.name] then
			if bar.frame.bd then bar.frame.bd:Hide() end
			SpiralBorder:AttachSpiral(bar, iconInset, true)

			-- if Animations then
			-- 	Animations:Animate_Aura(bar)
			-- end

		-- Untouched Bar Groups
		else
			if bar.frame.ssID then SpiralBorder:RemoveSpiral(bar, bar.frame.ssID, true) end
			if bar.frame.bd then bar.frame.bd:Hide() end
		end
		
		return bar
	end
	
	Nest_DeleteBar_ = Raven.Nest_DeleteBar
	Raven.Nest_DeleteBar = function(bg, bar)
		-- Would be nice to keep them attached, but Raven recycles frames for Icons AND Bars and intermixes them
		if bar.frame.ssID then SpiralBorder:RemoveSpiral(bar, bar.frame.ssID, true) end
		bar.endTime = nil

		bar.frame:Hide()
		bar.container:Hide()
		Nest_DeleteBar_(bg, bar)
	end
end

function RavenBorders:PLAYER_ENTERING_WORLD()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	HookBars()
end

---- INITIALIZE
function RavenBorders:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {},
	})
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function RavenBorders:OnEnable()
	if IsAddOnLoaded("Raven") then
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	end
end