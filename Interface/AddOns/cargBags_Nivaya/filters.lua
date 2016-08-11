local addon, ns = ...
local cargBags = ns.cargBags

local cbNivaya = cargBags:NewImplementation("Nivaya")
cbNivaya:RegisterBlizzard()
function cbNivaya:UpdateBags()
	cargBags.debug("filters cbNivaya:UpdateBags")
	for i = -1, 11 do
		cbNivaya:UpdateBag(i)
	end
end

local L = cBnivL
cB_Filters = {}
cB_KnownItems = cB_KnownItems or {}
cBniv_CatInfo = {}
cB_ItemClass = {}

cB_existsBankBag = { Armor = true, Quest = true, TradeGoods = true, Consumables = true, BattlePet = true }
cB_filterEnabled = { Armor = true, Quest = true, TradeGoods = true, Consumables = true, Keyring = true, Junk = true, Stuff = true, ItemSets = true, BattlePet = true }

--------------------
--Basic filters
--------------------
cB_Filters.fBags = function(item) return item.bagID >= 0 and item.bagID <= 4 end
cB_Filters.fBank = function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end
cB_Filters.fBankReagent = function(item) return item.bagID == -3 end
cB_Filters.fBankFilter = function() return cBnivCfg.FilterBank end
cB_Filters.fHideEmpty = function(item) if cBnivCfg.CompressEmpty then return item.link ~= nil else return true end end

------------------------------------
-- General Classification (cached)
------------------------------------
cB_Filters.fItemClass = function(item, container)
	cargBags.debug("filters cB_Filters.fItemClass", item.name, item.id, container)
	if not item.id  then	return false	end
    if not cB_ItemClass[item.id] then
        cbNivaya:ClassifyItem(item)
    end
	
	local t, bag = cB_ItemClass[item.id]

	local isBankBag = item.bagID == -1 or (item.bagID >= 5 and item.bagID <= 11)
	if isBankBag then
		bag = (cB_existsBankBag[t] and cBnivCfg.FilterBank and cB_filterEnabled[t]) and "Bank"..t or "Bank"
	else
		bag = (t ~= "NoClass" and cB_filterEnabled[t]) and t or "Bag"
	end

	cargBags.debug("bag", bag)
	return bag == container
end

do
	local itemUpdater, last = CreateFrame("Frame"), 0
	itemUpdater:SetScript("OnUpdate", function(self, elapsed)
	    last = last + elapsed
	    if last > 1 and #itemUpdater > 0 then
	    	local item = table.remove(itemUpdater)
	    	cbNivaya:GetItemInfo(item.bagID, item.slotID, true)
	    	last = 0
	    end
	end)
	function cbNivaya:ClassifyItem(item)
		cargBags.debug("filters cbNivaya:ClassifyItem", item.name, item.id)

		if item.bagID == -2 then
			-- keyring
			cB_ItemClass[item.id] = "Keyring"
		elseif cBniv_CatInfo[item.id] then
			-- user assigned containers
			cB_ItemClass[item.id] = cBniv_CatInfo[item.id]
		elseif (item.rarity == 0) then
			-- junk
			cB_ItemClass[item.id] = "Junk"
		elseif item.typeID then
			-- type based filters
			cargBags.debug("typeID", item.typeID)
			if (item.typeID == _G.LE_ITEM_CLASS_ARMOR) or (item.typeID == _G.LE_ITEM_CLASS_WEAPON)	then
				cB_ItemClass[item.id] = "Armor"
			elseif (item.typeID == _G.LE_ITEM_CLASS_QUESTITEM) then
				cB_ItemClass[item.id] = "Quest"
			elseif (item.typeID == _G.LE_ITEM_CLASS_TRADEGOODS) then
				cB_ItemClass[item.id] = "TradeGoods"
			elseif (item.typeID == _G.LE_ITEM_CLASS_CONSUMABLE) then
				cB_ItemClass[item.id] = "Consumables"
			elseif(item.typeID == _G.LE_ITEM_CLASS_BATTLEPET) then
				cB_ItemClass[item.id] = "BattlePet"
			end
		end

		if not cB_ItemClass[item.id] then
			table.insert(itemUpdater, item)
			cB_ItemClass[item.id] = "NoClass"
		end
		
		cargBags.debug("Classified", cB_ItemClass[item.id])
	end
end

------------------------------------------
-- New Items filter and related functions
------------------------------------------
function cbNivaya:getItemCount(itemName)
	local tItemCount = 0
	for i = 0,4 do
		local tNumSlots = GetContainerNumSlots(i)
		if tNumSlots > 0 then
			for j = 1,tNumSlots do
				local tLink = GetContainerItemLink(i,j)
				local tName
				if tLink then
					if tLink:find("battlepet") then
						tName = select(2, strmatch(tLink, "|H(.-)|h(.-)|h"))
					else
						tName = GetItemInfo(tLink)
					end
				end
				if tName == itemName then
					local _,tStackCount = GetContainerItemInfo(i,j)
					tItemCount = tItemCount + tStackCount
				end
			end
		end
	end
	return tItemCount
end

cB_Filters.fNewItems = function(item)
	if not cBnivCfg.NewItems then return false end
	if not ((item.bagID >= 0) and (item.bagID <= 4)) then return false end
	if not item.link then return false end
	if not cB_KnownItems[item.id] then return true end
	local t = cbNivaya:getItemCount(item.id)
	return (t > cB_KnownItems[item.id]) and true or false
end

-----------------------------------------
-- Item Set filter and related functions
-----------------------------------------
local item2setIR = {} -- ItemRack
local item2setOF = {} -- Outfitter
local IR = IsAddOnLoaded('ItemRack')
local OF = IsAddOnLoaded('Outfitter')

cB_Filters.fItemSets = function(item)
	--print("fItemSets", item, item.isInSet)
	if not cB_filterEnabled["ItemSets"] then return false end
	if not item.link then return false end
	local tC = cBniv_CatInfo[item.name]
	if tC then return (tC == "ItemSets") and true or false end
	-- Check ItemRack sets:
	if item2setIR[string.match(item.link,"item:(.+):%-?%d+")] then return true end
	-- Check Outfitter sets:
	local _,_,itemStr = string.find(item.link, "^|c%x+|H(.+)|h%[.*%]")
	if item2setOF[itemStr] then return true end
	-- Check Equipment Manager sets:
	if cargBags.itemKeys["setID"](item) then return true end
   return false
end

-- ItemRack related
local function cacheSetsIR()
	for k in pairs(item2setIR) do item2setIR[k] = nil end
	local IRsets = ItemRackUser.Sets
	for i in next, IRsets do
		if not string.find(i, "^~") then 
			for _,item in pairs(IRsets[i].equip) do
				if item then item2setIR[item] = true end
			end
		end
	end
	cbNivaya:UpdateBags()
end

if IR then
	cacheSetsIR()
	local function ItemRackOpt_CreateHooks()
		local IRsaveSet = ItemRackOpt.SaveSet
		function ItemRackOpt.SaveSet(...) IRsaveSet(...); cacheSetsIR() end
		local IRdeleteSet = ItemRackOpt.DeleteSet
		function ItemRackOpt.DeleteSet(...) IRdeleteSet(...); cacheSetsIR() end
	end
	local IRtoggleOpts = ItemRack.ToggleOptions
	function ItemRack.ToggleOptions(...) IRtoggleOpts(...) ItemRackOpt_CreateHooks() end
end

-- Outfitter related
local pLevel = UnitLevel("player")
local function createItemString(i) return string.format("item:%d:%d:%d:%d:%d:%d:%d:%d:%d", i.Code, i.EnchantCode or 0, i.JewelCode1 or 0, i.JewelCode2 or 0, i.JewelCode3 or 0, i.JewelCode4 or 0, i.SubCode or 0, i.UniqueID or 0, pLevel) end

local function cacheSetsOF()
	for k in pairs(item2setOF) do item2setOF[k] = nil end
	for _,id in ipairs(Outfitter_GetCategoryOrder()) do
		local OFsets = Outfitter_GetOutfitsByCategoryID(id)
		for _,vSet in pairs(OFsets) do
			for _,item in pairs(vSet.Items) do
				if item then item2setOF[createItemString(item)] = true end
			end
		end
	end
	cbNivaya:UpdateBags()
end

if OF then
	Outfitter_RegisterOutfitEvent("ADD_OUTFIT", cacheSetsOF)
	Outfitter_RegisterOutfitEvent("DELETE_OUTFIT", cacheSetsOF)
	Outfitter_RegisterOutfitEvent("EDIT_OUTFIT", cacheSetsOF)
	if Outfitter:IsInitialized() then
		cacheSetsOF()
	else
		Outfitter_RegisterOutfitEvent('OUTFITTER_INIT', cacheSetsOF)
	end
end
