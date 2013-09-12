--Deatknight Purgatory status
local Purgatory = Grid2.statusPrototype:new("dk-purgatory")

local UnitHealthMax = UnitHealthMax
local UnitDebuff = UnitDebuff
local fmt = string.format
local Purgatory_AuraName = GetSpellInfo(116888)

local Purgatory_cache = {}
local DK_UnitIDs = {}

function Purgatory:OnEnable()
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterEvent("UNIT_AURA")
	self:UpdateDKs()
end

function Purgatory:UpdateDKs()
	wipe(DK_UnitIDs)
	if IsInRaid() then
		for i=1, GetNumGroupMembers() do
			if select(2, UnitClass("raid"..i)) == "DEATHKNIGHT" then
				DK_UnitIDs["raid"..i] = true
			end
		end
	else
		for i=1, GetNumSubgroupMembers() do
			if select(2, UnitClass("party"..i)) == "DEATHKNIGHT" then
				DK_UnitIDs["party"..i] = true
			end
		end
		
		if select(2, UnitClass("player")) == "DEATHKNIGHT" then
			DK_UnitIDs["player"] = true
		end
	end
end

function Purgatory:UNIT_AURA(_, unit)
	if DK_UnitIDs[unit] then
		local old_amount = Purgatory_cache[unit]
		local new_amount = select(15, UnitDebuff(unit, Purgatory_AuraName))
		if old_amount ~= new_amount then
			Purgatory_cache[unit] = new_amount
			Purgatory:UpdateIndicators(unit)
		end
	end
end

function Purgatory:GROUP_ROSTER_UPDATE()
	self:UpdateDKs()
end

function Purgatory:OnDisable()
	self:UnregisterAllEvents()
end

function Purgatory:IsActive(unit)
	return Purgatory_cache[unit]
end

function Purgatory:GetPercent(unit)
	return Purgatory_cache[unit]/UnitHealthMax(unit)
end

function Purgatory:GetText(unit)
	return fmt("%.1fk", Purgatory_cache[unit] / 1000)
end

function Purgatory:GetIcon()
	return [[Interface\ICONS\INV_Misc_ShadowEgg.blp]]
end

Purgatory.GetColor = Grid2.statusLibrary.GetColor

Grid2.setupFunc["dk-purgatory"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Purgatory, {"color", "percent", "text", "icon"}, baseKey, dbx)

	return Purgatory
end

Grid2:DbSetStatusDefaultValue("dk-purgatory", {type = "dk-purgatory", color1 = {r=1,g=0,b=1,a=1}})
