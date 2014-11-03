local MAJOR, MINOR = "LibItemUpgradeInfo-1.0", 99

local lib = _G.LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local upgradeTable = {
	[  1] = { upgrade = 1, max = 1, ilevel = 8 },
	[373] = { upgrade = 1, max = 2, ilevel = 4 },
	[374] = { upgrade = 2, max = 2, ilevel = 8 },
	[375] = { upgrade = 1, max = 3, ilevel = 4 },
	[376] = { upgrade = 2, max = 3, ilevel = 4 },
	[377] = { upgrade = 3, max = 3, ilevel = 4 },
	[378] = {                       ilevel = 7 },
	[379] = { upgrade = 1, max = 2, ilevel = 4 },
	[380] = { upgrade = 2, max = 2, ilevel = 4 },
	[445] = { upgrade = 0, max = 2, ilevel = 0 },
	[446] = { upgrade = 1, max = 2, ilevel = 4 },
	[447] = { upgrade = 2, max = 2, ilevel = 8 },
	[451] = { upgrade = 0, max = 1, ilevel = 0 },
	[452] = { upgrade = 1, max = 1, ilevel = 8 },
	[453] = { upgrade = 0, max = 2, ilevel = 0 },
	[454] = { upgrade = 1, max = 2, ilevel = 4 },
	[455] = { upgrade = 2, max = 2, ilevel = 8 },
	[456] = { upgrade = 0, max = 1, ilevel = 0 },
	[457] = { upgrade = 1, max = 1, ilevel = 8 },
	[458] = { upgrade = 0, max = 4, ilevel = 0 },
	[459] = { upgrade = 1, max = 4, ilevel = 4 },
	[460] = { upgrade = 2, max = 4, ilevel = 8 },
	[461] = { upgrade = 3, max = 4, ilevel = 12 },
	[462] = { upgrade = 4, max = 4, ilevel = 16 },
	[465] = { upgrade = 0, max = 2, ilevel = 0 },
	[466] = { upgrade = 1, max = 2, ilevel = 4 },
	[467] = { upgrade = 2, max = 2, ilevel = 8 },
	[468] = { upgrade = 0, max = 4, ilevel = 0 },
	[469] = { upgrade = 1, max = 4, ilevel = 4 },
	[470] = { upgrade = 2, max = 4, ilevel = 8 },
	[471] = { upgrade = 3, max = 4, ilevel = 12 },
	[472] = { upgrade = 4, max = 4, ilevel = 16 },
	[491] = { upgrade = 0, max = 4, ilevel = 0 },
	[492] = { upgrade = 1, max = 4, ilevel = 4 },
	[493] = { upgrade = 2, max = 4, ilevel = 8 },
	[494] = { upgrade = 0, max = 6, ilevel = 0 },
	[495] = { upgrade = 1, max = 6, ilevel = 4 },
	[496] = { upgrade = 2, max = 6, ilevel = 8 },
	[497] = { upgrade = 3, max = 6, ilevel = 12 },
	[498] = { upgrade = 4, max = 6, ilevel = 16 },
	[504] = { upgrade = 3, max = 4, ilevel = 12 },
	[505] = { upgrade = 4, max = 4, ilevel = 16 },
	[506] = { upgrade = 5, max = 6, ilevel = 20 },
	[507] = { upgrade = 6, max = 6, ilevel = 24 },
}
do
	local stub = { ilevel = 0 }
	setmetatable(upgradeTable, { __index = function(t, key)
		return stub
	end})
end

-- GetUpgradeID(itemString)
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Number - The upgrade ID (possibly 0), or nil if the input is invalid or
--            does not contain upgrade info
function lib:GetUpgradeID(itemString)
	return tonumber(itemString:match("item:%d+:%d+:%d+:%d+:%d+:%d+:%-?%d+:%-?%d+:%d+:(%d+)"))
	--return tonumber(itemString:match("item:%d+:%d+:%d+:%d+:%d+:%d+:%-?%d+:%-?%d+:%d+:%d+:(%d+)"))
end

-- GetCurrentUpgrade(id)
--
-- Returns the current upgrade level of the item, e.g. 1 for a 1/2 item.
--
-- Arguments:
--   id - Number - The upgrade ID of the item (obtained via GetUpgradeID())
--
-- Returns:
--   Number - The current upgrade level of the item. Returns nil if the item
--            cannot be upgraded
function lib:GetCurrentUpgrade(id)
	return upgradeTable[id].upgrade
end

-- GetMaximumUpgrade(id)
--
-- Returns the maximum upgrade level of the item, e.g. 2 for a 1/2 item.
--
-- Arguments:
--   id - Number - The upgrade ID of the item (obtained via GetUpgradeID())
--
-- Returns:
--   Number - The maximum upgrade level of the item. Returns nil if the item
--            cannot be upgraded
function lib:GetMaximumUpgrade(id)
	return upgradeTable[id].max
end

-- GetItemLevelUpgrade(id)
--
-- Returns the item level increase that this upgrade is worth, e.g. 4 for a
-- 1/2 item or 8 for a 2/2 item.
--
-- Arguments:
--   id - Number - The upgrade ID of the item (obtained via GetUpgradeID())
--
-- Returns:
--   Number - The item level increase of the item. Returns 0 if the item
--            cannot be or has not been upgraded
function lib:GetItemLevelUpgrade(id)
	return upgradeTable[id].ilevel
end

-- GetItemUpgradeInfo(itemString)
--
-- Returns the current upgrade level, maximum upgrade level, and item level
-- increase for an item.
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns if the item can be upgraded:
--   Number - The current upgrade level of the item
--   Number - The maximum upgrade level of the item
--   Number - The item level increase of the item
-- or if the item cannot be upgraded:
--   nil
--   nil
--   0
-- or if the item is invalid or does not contain upgrade info:
--   nil
function lib:GetItemUpgradeInfo(itemString)
	local id = self:GetUpgradeID(itemString)
	if id then
		local cur = self:GetCurrentUpgrade(id)
		local max = self:GetMaximumUpgrade(id)
		local delta = self:GetItemLevelUpgrade(id)
		return cur, max, delta
	end
	return nil
end

-- GetUpgradedItemLevel(itemString)
--
-- Returns the true item level of the item, including upgrades.
--
-- Arguments:
--   itemString - String - An itemLink or itemString denoting the item
--
-- Returns:
--   Number - The true item level of the item, or nil if the input is invalid
function lib:GetUpgradedItemLevel(itemString)
	local ilvl = select(4, _G.GetItemInfo(itemString))
	local id = self:GetUpgradeID(itemString)
	if ilvl and id then
		ilvl = ilvl + self:GetItemLevelUpgrade(id)
	end
	return ilvl
end

--[===========[ ]===========]
--[===[ Debug utilities ]===]
--[===========[ ]===========]


local function compareTables(t1, t2)
	local seen = {}
	for k, v1 in pairs(t1) do
		seen[k] = true
		local v2 = rawget(t2, k)
		if not v2 then return false end
		if type(v1) ~= type(v2) then return false end
		if type(v1) == "table" then
			if not compareTables(v1, v2) then return false end
		elseif v1 ~= v2 then return false end
	end
	for k in pairs(t2) do
		if not seen[k] then return false end
	end
	return true
end

-- prints the table rows in red and green
-- omits the lead { and the trailing }
local function printDiffTable(t1, t2)
	local keys, seen = {}, {}
	for k in pairs(t1) do
		keys[#keys+1] = k
		seen[k] = true
	end
	for k in pairs(t2) do
		if not seen[k] then
			keys[#keys+1] = k
		end
	end
	table.sort(keys)
	local function formatTable(t)
		local comps = {}
		for k, v in pairs(t) do
			comps[#comps+1] = ("%s = %d"):format(k, v)
		end
		return "{ " .. table.concat(comps, ", ") .. " }"
	end
	for _, k in ipairs(keys) do
		local v1, v2 = rawget(t1, k), rawget(t2, k)
		local equal
		if type(v1) == "table" and type(v2) == "table" then equal = compareTables(v1, v2)
		else equal = v1 == v2 end
		if not equal then
			if v1 then
				print(("|cffff0000    [%d] = %s,|r"):format(k, formatTable(v1)))
			end
			if v2 then
				print(("|cff00ff00    [%d] = %s,|r"):format(k, formatTable(v2)))
			end
		end
	end
end

-- Scans the first 10000 upgrade IDs
-- Run this with /run LibStub:GetLibrary("LibItemUpgradeInfo-1.0"):_CheckUpgradeTable()
-- If you don't have Aspirant's Staff of Harmony cached it may error out, just try again.
do
	local debugFrame
	local worker
	local newTable
	local debugTooltip
	function lib:_CheckUpgradeTable()
		if worker then
			print("|cffff0000LibItemUpgradeInfo-1.0: upgrade check already in progress")
			return
		end
		if not debugFrame then
			debugFrame = _G.CreateFrame("frame")
			debugFrame:Hide()
			debugFrame:SetScript("OnUpdate", function()
				local ok, result, count, max = pcall(worker)
				if not ok or result then
					debugFrame:Hide()
					worker = nil
				end
				if not ok then
					print("|cffff0000LibItemUpgradeInfo-1.0 error: " .. result .. "|r")
				elseif result then
					print("LibItemUpgradeInfo-1.0: scan complete")
					if compareTables(upgradeTable, newTable) then
						print("LibItemUpgradeInfo-1.0: |cff00ff00No changes|r")
					else
						print("LibItemUpgradeInfo-1.0: |cffff0000New table:|r {")
						printDiffTable(upgradeTable, newTable)
						print("}")
					end
				else
					print("LibItemUpgradeInfo-1.0: scanning " .. count .. "/" .. max)
				end
			end)
		end
		if not debugTooltip then
			debugTooltip = _G.CreateFrame("GameTooltip", "LibItemUpgradeInfoTooltip", nil, "GameTooltipTemplate")
			debugTooltip:SetOwner(_G.WorldFrame, "ANCHOR_NONE")
		end
		newTable = {}
		local itemLink = "|cff0070dd|Hitem:89551:0:0:0:0:0:0:0:90:0:0|h[Aspirant's Staff of Harmony]|h|r"
		local itemLevel = select(4, _G.GetItemInfo(itemLink))
		assert(itemLevel, "Can't find item level for itemLink")
		local count, max, batchsize = 0, 10000, 200
		worker = function()
			for i = count, math.min(max, count+batchsize) do
				local link = itemLink:gsub("%d+|h", i.."|h")
				debugTooltip:ClearLines()
				debugTooltip:SetHyperlink(link)
				local upgrade, max
				local curLevel, maxLevel = _G.LibItemUpgradeInfoTooltipTextLeft3:GetText():match("^Upgrade Level: (%d+)/(%d+)")
				local ilvl = tonumber(_G.LibItemUpgradeInfoTooltipTextLeft2:GetText():match("Item Level (%d+)"))
				assert(ilvl ~= nil, "Can't find ItemLevel in tooltip: " .. _G.LibItemUpgradeInfoTooltipTextLeft2:GetText())
				if curLevel or maxLevel or ilvl ~= itemLevel then
					newTable[i] = { upgrade = tonumber(curLevel), max = tonumber(maxLevel), ilevel = ilvl - itemLevel }
				end
			end
			count = count + batchsize
			return (count > max), count, max
		end
		debugFrame:Show()
	end
end
