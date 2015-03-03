-- Generate static LUA CODE for a Raid Debuffs module database
-- See for example: RaidDebuffsWoD.lua

local RDO = Grid2Options.RDO
local RDDB = RDO.RDDB

function RDO:GenerateModuleLuaCode(moduleName)

	local function GenerateZoneLuaCode(moduleName, zoneName)
		local spells, order = {}, {}
		local function CollectBossSpells(bossdata)
			if not bossdata then return end
			for index,spellId in ipairs(bossdata) do
				if not order[spellId] and (GetSpellInfo(spellId)) then
					local status = self.debuffsStatuses[spellId]
					spells[#spells+1] = spellId
					order[spellId] = status and self.statusesIndexes[status]*100+self.debuffsIndexes[spellId] or index*10000
				end
			end
		end
		local function GenerateBossCode(bossName, bossdata)
			local custombosses = self.db.profile.debuffs[zoneName]
			local lines = string.format('\t\t["%s"] = {\n',bossName)
			lines = lines .. string.format('\t\torder = %s, ejid = %s,\n', tonumber(bossdata.order) or "nil", tonumber(bossdata.ejid) or "nil")
			wipe(spells); wipe(order)
			CollectBossSpells(bossdata)
			CollectBossSpells(custombosses and custombosses[bossName])
			table.sort(spells, function(a,b) return order[a]<order[b] end)
			for _,spellId in ipairs(spells) do
				lines = lines .. string.format("\t\t%d, -- %s\n", spellId, GetSpellInfo(spellId) )
			end
			lines = lines .. "\t\t},\n"
			return lines, bossdata.order or 100
		end
		local bosses, order = {}, {}
		for bossName,bossdata in pairs(RDDB[moduleName][zoneName]) do
			local code, index = GenerateBossCode(bossName,bossdata)
			bosses[#bosses+1], order[code] = code, index
		end
		if moduleName ~= "[Custom Debuffs]" then
			local zone = self.db.profile.debuffs[zoneName]
			if zone then
				for bossName,bossdata in pairs(zone) do
					if not RDDB[moduleName][zoneName][bossName] then
						local code, index = GenerateBossCode(bossName,bossdata)
						bosses[#bosses+1], order[code] = code, index
					end	
				end
			end	
		end
		table.sort(bosses, function(a,b) return order[a]<order[b] end)
		local lines = string.format("\t[%d] = { -- %s \n", zoneName, GetMapNameByID(zoneName) or "" )	
		lines = lines .. table.concat(bosses)
		lines = lines .. "\t},\n"
		return lines
	end

	local lines = string.format('local RDDB = Grid2Options:GetRaidDebuffsTable()\n\nRDDB["%s"] = {\n', moduleName ~= "[Custom Debuffs]" and moduleName or "WoW Raid Debuffs")
	for zoneName in pairs(RDDB[moduleName]) do
		lines = lines .. GenerateZoneLuaCode(moduleName, zoneName)
	end
	lines = lines ..  "}\n"
	return lines
	
end	
	
