local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

function nibRealUI:MiniPatch(ver)
	if ver == "81r1" then
        SetCVar("countdownForCooldowns", 0)
		if IsAddOnLoaded("Aurora") then
			if AuroraConfig then
				AuroraConfig["useButtonGradientColour"] = false
				AuroraConfig["chatBubbles"] = false
				AuroraConfig["bags"] = false
				AuroraConfig["tooltips"] = false
				AuroraConfig["loot"] = false
				AuroraConfig["useCustomColour"] = false
				AuroraConfig["enableFont"] = false
				AuroraConfig["buttonSolidColour"] = {0.09, 0.09, 0.09, 1}
			end
		end
		if IsAddOnLoaded("DBM-StatusBarTimers") then
			if DBT_PersistentOptions["DBM"] then
				DBT_PersistentOptions["DBM"]["HugeTimerY"] = 300
				DBT_PersistentOptions["DBM"]["HugeBarXOffset"] = 0
				DBT_PersistentOptions["DBM"]["Scale"] = 1
				DBT_PersistentOptions["DBM"]["TimerX"] = 400
				DBT_PersistentOptions["DBM"]["TimerPoint"] = "CENTER"
				DBT_PersistentOptions["DBM"]["HugeBarYOffset"] = 9
				DBT_PersistentOptions["DBM"]["HugeScale"] = 1
				DBT_PersistentOptions["DBM"]["HugeTimerPoint"] = "CENTER"
				DBT_PersistentOptions["DBM"]["BarYOffset"] = 9
				DBT_PersistentOptions["DBM"]["HugeTimerX"] = -400
				DBT_PersistentOptions["DBM"]["TimerY"] = 300
				DBT_PersistentOptions["DBM"]["BarXOffset"] = 0
			end
		end
		if IsAddOnLoaded("BugSack") then
			if BugSackLDBIconDB then
				BugSackLDBIconDB["hide"] = false
			end
		end
	elseif ver == "81r2" then
		if IsAddOnLoaded("Grid2") then
			local group20 = {
				{
					["maxColumns"] = 4,
					["type"] = "raid",
					["sortMethod"] = "INDEX",
					["groupBy"] = "GROUP",
					["unitsPerColumn"] = 5,
					["groupFilter"] = "1,2,3,4",
					["groupingOrder"] = "1,2,3,4",
				}, -- [1]
				["meta"] = {
					["solo"] = true,
					["raid10"] = true,
					["party"] = true,
					["raid40"] = true,
					["pvp"] = true,
					["raid25"] = true,
					["arena"] = true,
					["raid20"] = true,
					["raid15"] = true,
				},
				["defaults"] = {
					["showSolo"] = true,
					["showRaid"] = true,
					["showPlayer"] = true,
					["showParty"] = true,
					["toggleForVehicle"] = true,
				},
			}
			local group30 = {
				{
					["maxColumns"] = 6,
					["type"] = "raid",
					["sortMethod"] = "INDEX",
					["groupBy"] = "GROUP",
					["unitsPerColumn"] = 5,
					["groupFilter"] = "1,2,3,4,5,6",
					["groupingOrder"] = "1,2,3,4,5,6",
				}, -- [1]
				["meta"] = {
					["solo"] = true,
					["raid10"] = true,
					["party"] = true,
					["raid40"] = true,
					["pvp"] = true,
					["raid25"] = true,
					["arena"] = true,
					["raid20"] = true,
					["raid15"] = true,
				},
				["defaults"] = {
					["showSolo"] = true,
					["showRaid"] = true,
					["showPlayer"] = true,
					["showParty"] = true,
					["toggleForVehicle"] = true,
				},
			}
			if Grid2DB["namespaces"]["Grid2Layout"]["global"] and Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"] then
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 20"] = group20
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 30"] = group30
			else
				Grid2DB["namespaces"]["Grid2Layout"]["global"] = {}
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"] = {}
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 20"] = group20
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 30"] = group30
			end
		end
	elseif ver == "81r4" then
		if IsAddOnLoaded("Grid2") then
			local group20 = {
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "1",
					["sortMethod"] = "INDEX",
				}, -- [1]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "2",
					["sortMethod"] = "INDEX",
				}, -- [2]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "3",
					["sortMethod"] = "INDEX",
				}, -- [3]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "4",
					["sortMethod"] = "INDEX",
				}, -- [4]
				["meta"] = {
					["solo"] = true,
					["raid10"] = true,
					["party"] = true,
					["raid40"] = true,
					["pvp"] = true,
					["raid25"] = true,
					["arena"] = true,
					["raid20"] = true,
					["raid15"] = true,
				},
				["defaults"] = {
					["showSolo"] = true,
					["showRaid"] = true,
					["showPlayer"] = true,
					["showParty"] = true,
					["toggleForVehicle"] = true,
				},
			}
			local group30 = {
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "1",
					["sortMethod"] = "INDEX",
				}, -- [1]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "2",
					["sortMethod"] = "INDEX",
				}, -- [2]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "3",
					["sortMethod"] = "INDEX",
				}, -- [3]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "4",
					["sortMethod"] = "INDEX",
				}, -- [4]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "5",
					["sortMethod"] = "INDEX",
				}, -- [5]
				{
					["maxColumns"] = 1,
					["type"] = "raid",
					["groupFilter"] = "6",
					["sortMethod"] = "INDEX",
				}, -- [6]
				["meta"] = {
					["solo"] = true,
					["raid10"] = true,
					["party"] = true,
					["raid40"] = true,
					["pvp"] = true,
					["raid25"] = true,
					["arena"] = true,
					["raid20"] = true,
					["raid15"] = true,
				},
				["defaults"] = {
					["showSolo"] = true,
					["showRaid"] = true,
					["showPlayer"] = true,
					["showParty"] = true,
					["toggleForVehicle"] = true,
				},
			}
			if Grid2DB["namespaces"]["Grid2Layout"]["global"] and Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"] then
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 20"] = group20
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 30"] = group30
			else
				Grid2DB["namespaces"]["Grid2Layout"]["global"] = {}
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"] = {}
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 20"] = group20
				Grid2DB["namespaces"]["Grid2Layout"]["global"]["customLayouts"]["By Group 30"] = group30
			end
		end
	end
end
