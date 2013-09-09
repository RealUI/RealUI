local L = LibStub("AceLocale-3.0"):GetLocale("Skada", false)

local Skada = Skada

local mod = Skada:NewModule(L["Overhealing"])

function mod:OnEnable()
	mod.metadata = {showspots = true, columns = {Overheal = true, Percent = true}}

	Skada:AddMode(self)
end

function mod:OnDisable()
	Skada:RemoveMode(self)
end

-- Called by Skada when a new player is added to a set.
function mod:AddPlayerAttributes(player)
	if not player.overhealing then
		player.overhealing = 0
	end
end

-- Called by Skada when a new set is created.
function mod:AddSetAttributes(set)
	if not set.overhealing then
		set.overhealing = 0
	end
end

function mod:GetSetSummary(set)
	return Skada:FormatNumber(set.overhealing)
end

function mod:Update(win, set)
	local nr = 1
	local max = 0

	for i, player in ipairs(set.players) do
		if player.overhealing > 0 then

			local d = win.dataset[nr] or {}
			win.dataset[nr] = d

			d.id = player.id
			d.value = player.overhealing
			d.label = player.name

			d.valuetext = Skada:FormatValueText(
											Skada:FormatNumber(player.overhealing), self.metadata.columns.Overheal,
											string.format("%02.1f%%", player.overhealing / math.max(1, player.healing) * 100), self.metadata.columns.Percent
										)
			d.class = player.class

			if player.overhealing > max then
				max = player.overhealing
			end
			nr = nr + 1
		end
	end

	win.metadata.maxvalue = max
end

