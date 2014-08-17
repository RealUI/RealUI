local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local MODNAME = "ClassResource_Resolve"
local Resolve = nibRealUI:NewModule(MODNAME)

Resolve.special = {
	["DEATHKNIGHT"] = true,
	["MONK"] = true,
}
Resolve.scale = {
	8, --lvl 10
	8,
	9,
	9,
	10,
	10,
	11,
	11,
	12,
	12,
	13,
	13,
	14,
	14,
	15,
	15,
	16,
	16,
	17,
	17,
	18,
	18,
	19,
	19,
	20,
	20,
	21,
	21,
	22,
	22,
	23,
	23,
	24,
	24,
	25,
	25,
	26,
	26,
	27,
	27,
	28,
	28,
	29,
	29,
	30,
	30,
	31,
	31,
	32,
	32,
	32,
	35,
	37,
	39,
	39,
	40,
	40,
	41,
	44,
	44,
	44,
	44,
	44,
	45,
	46,
	49,
	49,
	50,
	50,
	51,
	51,
	52,
	52,
	54,
	56,
	57,
	60,
	61,
	62,
	64,
	67,
	101,
	118,
	139,
	162,
	190,
	225,
	234,
	242,
	252,
	261, --lvl 100
}

------------------------
---- Resolve Scan ----
------------------------
-- Scan the tooltip and extract the Resolve value
do
	local regions = {}
	local tooltipBufferResolve = CreateFrame("GameTooltip","RealUIBufferTooltip_Resolve",nil,"GameTooltipTemplate")
	tooltipBufferResolve:SetOwner(WorldFrame, "ANCHOR_NONE")

	local function makeTable(t, ...)
		wipe(t)
		for i = 1, select("#", ...) do
			t[i] = select(i, ...)
		end
	end

	function Resolve:UpdateCurrent()
		local name = UnitAura("player", self.name)
		if name then
			-- Buff found, copy it into the buffer for scanning
			tooltipBufferResolve:ClearLines()
			tooltipBufferResolve:SetUnitBuff("player", name)

			-- Grab all regions, stuff em into our table
			makeTable(regions, tooltipBufferResolve:GetRegions())

			-- Convert FontStrings to strings, replace anything else with ""
			for i=1, #regions do
				local region = regions[i]
				regions[i] = region:GetObjectType() == "FontString" and region:GetText() or ""
			end

			-- Find the number, save it
			self.current = tonumber(string.match(table.concat(regions),"%d+")) or 0
			self:UpdateMax()
		else
			self.current = 0
			self.percent = 0
		end
	    --print("Current Resolve:", Resolve.current)
	end
end

---------------------------
---- Resolve Updates ------
---------------------------
function Resolve:UpdateMax()
	--print("UpdateMax")
	if self.current > self.max then
		self.max = self.max + 100
	elseif (self.max > 100) and (self.current < (self.max / 4)) then
		self.max = self.max - 100
	end

	self.percent = nibRealUI:Clamp(self.current / self.max, 0, 1)
	--print("Resolve:", self.percent, self.max)
end

function Resolve:UpdateBase(event, unit)
	--print("UpdateBase", event, unit)
	if (unit and (unit ~= "player")) then
		return
	end

	-- From the beta TC thread: Stamina / (250 * ItemScaling[PlayerLevel])
	self.base = UnitStat("player", LE_UNIT_STAT_STAMINA) / (250 * self.scale[UnitLevel("player") - 9]) * 100
	--print("UpdateBase", self.base)
end

------------
function Resolve:OnInitialize()
	self.name = GetSpellInfo(158300)
	self.max = 100
end
