local _, ns = ...
local cargBags = ns.cargBags

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs

local cbNivaya = cargBags:NewImplementation("Nivaya")
cbNivaya:RegisterBlizzard()
local filters = ns.filters
local itemClass = ns.itemClass

ns.existsBankBag = { Armor = true, Quest = true, TradeGoods = true, Consumables = true, BattlePet = true }
ns.filterEnabled = { Armor = true, Quest = true, TradeGoods = true, Consumables = true, Junk = true, Stuff = true, ItemSets = true, BattlePet = true }

--------------------
--Basic filters
--------------------
filters.fBags = function(item) return item.bagID >= _G.BACKPACK_CONTAINER and item.bagID <= _G.NUM_BAG_SLOTS end
filters.fBank = function(item) return item.bagID == _G.BANK_CONTAINER or item.bagID >= _G.NUM_BAG_SLOTS + 1 and item.bagID <= _G.NUM_BAG_SLOTS + _G.NUM_BANKBAGSLOTS end
filters.fBankReagent = function(item) return item.bagID == _G.REAGENTBANK_CONTAINER end
filters.fBankFilter = function() return _G.cBnivCfg.FilterBank end
filters.fHideEmpty = function(item) if _G.cBnivCfg.CompressEmpty then return item.link ~= nil else return true end end

------------------------------------
-- General Classification (cached)
------------------------------------
filters.fItemClass = function(item, container)
    if not item.id then return false end
    if not itemClass[item.id] or itemClass[item.id] == "ReClass" then
        cbNivaya:ClassifyItem(item)
    end

    local t, bag = itemClass[item.id]

    local isBankBag = item.bagID == -1 or (item.bagID >= 5 and item.bagID <= 11)
    if isBankBag then
        bag = (ns.existsBankBag[t] and _G.cBnivCfg.FilterBank and ns.filterEnabled[t]) and "Bank"..t or "Bank"
    else
        bag = (t ~= "NoClass" and ns.filterEnabled[t]) and t or "Bag"
    end

    return bag == container
end

function cbNivaya:ClassifyItem(item)
    if item.bagID == -2 then
        -- keyring
        itemClass[item.id] = "Keyring"
    elseif _G.cBniv_CatInfo[item.id] then
        -- user assigned containers
        itemClass[item.id] = _G.cBniv_CatInfo[item.id]
    elseif item.rarity == 0 then
        -- junk
        itemClass[item.id] = "Junk"
    elseif item.typeID then
        -- type based filters
        if (item.typeID == _G.LE_ITEM_CLASS_ARMOR) or (item.typeID == _G.LE_ITEM_CLASS_WEAPON)  then
            itemClass[item.id] = "Armor"
        elseif (item.typeID == _G.LE_ITEM_CLASS_QUESTITEM) then
            itemClass[item.id] = "Quest"
        elseif (item.typeID == _G.LE_ITEM_CLASS_TRADEGOODS) then
            itemClass[item.id] = "TradeGoods"
        elseif (item.typeID == _G.LE_ITEM_CLASS_CONSUMABLE) then
            itemClass[item.id] = "Consumables"
        elseif(item.typeID == _G.LE_ITEM_CLASS_BATTLEPET) then
            itemClass[item.id] = "BattlePet"
        end
    end

    if not item.typeID or not item.rarity then
        itemClass[item.id] = "ReClass"
    elseif not itemClass[item.id] then
        itemClass[item.id] = "NoClass"
    end
end

------------------------------------------
-- New Items filter and related functions
------------------------------------------
filters.fNewItems = function(item)
    if not _G.cBnivCfg.NewItems then return false end
    if not ((item.bagID >= 0) and (item.bagID <= 4)) then return false end
    if not item.link then return false end
    if not _G.cB_KnownItems[item.id] then return true end
    return false
end

-----------------------------------------
-- Item Set filter and related functions
-----------------------------------------
local item2setIR = {} -- ItemRack
local item2setOF = {} -- Outfitter
local IR = _G.IsAddOnLoaded('ItemRack')
local OF = _G.IsAddOnLoaded('Outfitter')

filters.fItemSets = function(item)
    --print("fItemSets", item, item.isInSet)
    if not ns.filterEnabled["ItemSets"] then return false end
    if not item.link then return false end
    local tC = _G.cBniv_CatInfo[item.id]
    if tC then return (tC == "ItemSets") and true or false end
    -- Check ItemRack sets:
    if item2setIR[item.link:match("item:(.+):%-?%d+")] then return true end
    -- Check Outfitter sets:
    local _,_,itemStr = item.link:find("^|c%x+|H(.+)|h%[.*%]")
    if item2setOF[itemStr] then return true end
    -- Check Equipment Manager sets:
    if item.isInSet then return true end
   return false
end

-- ItemRack related
if IR then
    local function cacheSetsIR()
        _G.wipe(item2setIR)
        local IRsets = _G.ItemRackUser.Sets
        for i in next, IRsets do
            if not i:find("^~") then
                for _, item in next, IRsets[i].equip do
                    if item then item2setIR[item] = true end
                end
            end
        end
        cbNivaya:UpdateAll()
    end

    cacheSetsIR()
    local function ItemRackOpt_CreateHooks()
        local IRsaveSet = _G.ItemRackOpt.SaveSet
        function _G.ItemRackOpt.SaveSet(...) IRsaveSet(...); cacheSetsIR() end
        local IRdeleteSet = _G.ItemRackOpt.DeleteSet
        function _G.ItemRackOpt.DeleteSet(...) IRdeleteSet(...); cacheSetsIR() end
    end
    local IRtoggleOpts = _G.ItemRack.ToggleOptions
    function _G.ItemRack.ToggleOptions(...) IRtoggleOpts(...) ItemRackOpt_CreateHooks() end
end

-- Outfitter related

if OF then
    local pLevel = _G.UnitLevel("player")
    local function createItemString(i) return ("item:%d:%d:%d:%d:%d:%d:%d:%d:%d"):format(i.Code, i.EnchantCode or 0, i.JewelCode1 or 0, i.JewelCode2 or 0, i.JewelCode3 or 0, i.JewelCode4 or 0, i.SubCode or 0, i.UniqueID or 0, pLevel) end

    local function cacheSetsOF()
        _G.wipe(item2setOF)
        for _, id in ipairs(_G.Outfitter_GetCategoryOrder()) do
            local OFsets = _G.Outfitter_GetOutfitsByCategoryID(id)
            for _, vSet in next, OFsets do
                for _, item in next, vSet.Items do
                    if item then item2setOF[createItemString(item)] = true end
                end
            end
        end
        cbNivaya:UpdateAll()
    end


    _G.Outfitter_RegisterOutfitEvent("ADD_OUTFIT", cacheSetsOF)
    _G.Outfitter_RegisterOutfitEvent("DELETE_OUTFIT", cacheSetsOF)
    _G.Outfitter_RegisterOutfitEvent("EDIT_OUTFIT", cacheSetsOF)
    if _G.Outfitter:IsInitialized() then
        cacheSetsOF()
    else
        _G.Outfitter_RegisterOutfitEvent('OUTFITTER_INIT', cacheSetsOF)
    end
end
