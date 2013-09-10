local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "Animations"
local Animations = nibRealUI:NewModule(MODNAME, "AceHook-3.0")
local db

local iconFrames = {
	PlayerBuffs = true,
	TargetBuffs = true,
	ClassBuffs = true,
	FocusBuffs = true,
	FocusDebuffs = true,
	ToTDebuffs = true,
}

local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Animations",
		desc = "Animate UI elements.",
		arg = MODNAME,
		-- order = 112,
		args = {
			header = {
				type = "header",
				name = "Animations",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Animate UI elements.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Animations module.",
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

function Animations:Animate_Aura(bar)
	if db.animate.auras then
		bar.growTimer = CreateFrame("Frame")
		bar.growTimer.origHeight = 35--bar.frame:GetHeight()
		bar.growTimer.curHeight = 0
		bar.growTimer:SetScript("OnUpdate", function(self, elapsed)
			self.curHeight = self.curHeight + 1
			if self.curHeight <= self.origHeight then
				bar.frame:SetHeight(self.curHeight)
				bar.iconTexture:SetHeight(max(self.curHeight - 10, 1))
			end
		end)
	end
end

function Animations:Animate()
	
end

----------
function Animations:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			animate = {
				auras = true,
			},
		},
	})
	db = self.db.profile

	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function Animations:OnEnable()
	self:Animate()
end