local CrystalShell = Grid2.statusPrototype:new("tortos-crystal-shell")

local UnitHealthMax = UnitHealthMax
local UnitDebuff = UnitDebuff
local fmt = string.format
local CrystalShell_AuraName = GetSpellInfo(137633)

local CrystalShell_cache = {}

function CrystalShell:OnEnable()
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
end

function CrystalShell:UNIT_AURA(_, unit)
	local old_amount = CrystalShell_cache[unit]
	local new_amount = select(15, UnitDebuff(unit, CrystalShell_AuraName))
	if old_amount ~= new_amount then
		CrystalShell_cache[unit] = new_amount
		CrystalShell:UpdateIndicators(unit)
	end
end

function CrystalShell:GROUP_ROSTER_UPDATE()
	wipe(CrystalShell_cache)
end

function CrystalShell:OnDisable()
	self:UnregisterAllEvents()
end

function CrystalShell:IsActive(unit)
	return CrystalShell_cache[unit]
end

function CrystalShell:GetPercent(unit)
	return CrystalShell_cache[unit]/(UnitHealthMax(unit)*0.75)
end

function CrystalShell:GetText(unit)
	return fmt("%.1fk", CrystalShell_cache[unit] / 1000)
end

function CrystalShell:GetIcon()
	return [[Interface\ICONS\INV_DataCrystal01.blp]]
end

CrystalShell.GetColor = Grid2.statusLibrary.GetColor

Grid2.setupFunc["tortos-crystal-shell"] = function(baseKey, dbx)
	Grid2:RegisterStatus(CrystalShell, {"color", "percent", "text", "icon"}, baseKey, dbx)

	return CrystalShell
end

Grid2:DbSetStatusDefaultValue("tortos-crystal-shell", {type = "tortos-crystal-shell", color1 = {r=0.7,g=0,b=1,a=1}})
