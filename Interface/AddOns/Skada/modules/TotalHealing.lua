
Skada:AddLoadableModule("TotalHealing", function(Skada, L)
	if Skada.db.profile.modulesBlocked.TotalHealing then return end

	local mod = Skada:NewModule(L["Total healing"])

	-- Called by Skada when a new player is added to a set.
	function mod:AddPlayerAttributes(player)
	end

	-- Called by Skada when a new set is created.
	function mod:AddSetAttributes(set)
	end

	function mod:GetSetSummary(set)
		return Skada:FormatNumber(set.healing + set.overhealing)
	end

	local function sort_by_healing(a, b)
		return a.healing > b.healing
	end

	local green = {r = 0, g = 255, b = 0, a = 1}
	local red = {r = 255, g = 0, b = 0, a = 1}

	function mod:Update(win, set)
		-- Calculate the highest total healing.
		-- How to get rid of this iteration?
		local maxvalue = 0
		for i, player in ipairs(set.players) do
			if player.healing + player.overhealing > maxvalue then
				maxvalue = player.healing + player.overhealing
			end
		end

		local nr = 1

		for i, player in ipairs(set.players) do
			if player.healing > 0 or player.overhealing > 0 then

				local mypercent = (player.healing + player.overhealing) / maxvalue

				local d = win.dataset[nr] or {}
				win.dataset[nr] = d

				d.id = player.id
				d.value = player.healing
				d.label = player.name
				d.valuetext = Skada:FormatNumber(player.healing).." / "..Skada:FormatNumber(player.overhealing)
				d.color = green
				d.backgroundcolor = red
				d.backgroundwidth = mypercent
				d.class = player.class
                d.role = player.role

				nr = nr + 1
			end
		end

		win.metadata.maxvalue = maxvalue
	end

	function mod:OnEnable()
		mod.metadata = {showspots = true}

		Skada:AddMode(self)
	end

	function mod:OnDisable()
		Skada:RemoveMode(self)
	end
end)

