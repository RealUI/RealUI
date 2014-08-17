local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "WeakAurasSkin"
local WeakAurasSkin = nibRealUI:NewModule(MODNAME)

local function SkinAura(frame)
	frame.icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	frame.icon.SetTexCoord = function() end
end

local function CreateAura(parent, data)
	local region = WeakAuras.regionTypes.icon._create(parent, data)
	SkinAura(region)
	
	return region
end

local function ModifyAura(parent, region, data)
	WeakAuras.regionTypes.icon._modify(parent, region, data)

	SkinAura(region)
end

function WeakAurasSkin:Skin()
	if not WeakAuras then return end
	WeakAuras.regionTypes.icon._create = WeakAuras.regionTypes.icon.create
	WeakAuras.regionTypes.icon.create = CreateAura
	
	WeakAuras.regionTypes.icon._modify = WeakAuras.regionTypes.icon.modify
	WeakAuras.regionTypes.icon.modify = ModifyAura
	
	for wa, _ in pairs(WeakAuras.regions) do
		if WeakAuras.regions[wa].regionType == "icon" then
			SkinAura(WeakAuras.regions[wa].region)
		end
	end
end
----------

function WeakAurasSkin:OnInitialize()
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Weak Auras")
end

function WeakAurasSkin:OnEnable()
	if Aurora and IsAddOnLoaded("WeakAuras") then
		self:Skin()
	end
end