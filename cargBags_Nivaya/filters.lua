local _, ns = ...
local cargBags = ns.cargBags
local gl = _G.GetLocale()

-- Lua Globals --
local next, ipairs = _G.next, _G.ipairs
local cbNivaya = cargBags:NewImplementation("Nivaya")
cbNivaya:RegisterBlizzard()
local filters = ns.filters
local itemClass = ns.itemClass

ns.existsBankBag = { Armor = true, Quest = true, TradeGoods = true, Consumables = true, BattlePet = true }
ns.filterEnabled = { Armor = true, Quest = true, TradeGoods = true, Consumables = true, Junk = true, Stuff = true, ItemSets = true, BattlePet = true }

-- Item IDs for classification purposes
local itemIDs = {

    -- Mechagon Tinkering
    mechagon = {
        168327, -- Chain Ignitercoil
        166971, -- Empty Energy Cell
        166970, -- Energy Cell
        168832, -- Galvanic Oscillator
        167562, -- Ionized Minnow
        169610, -- S.P.A.R.E. Crate
        166846  -- Spare Parts
    },

    -- Travel/teleportation
    travel = {
        140493, -- Adept's Guide to Dimensional Rifting
        128353, -- Admiral's Compass
        46874,  -- Argent Crusader's Tabard
        22589,  -- Atiesh, Greatstaff of the Guardian
        63379,  -- Baradin's Wardens Tabard
        129276, -- Beginner's Guide to Dimensional Rifting
        118662, -- Bladespire Relic
        32757,  -- Blessed Medallion of Karabor
        50287,  -- Boots of the Bay
        166560, -- Captain's Signet of Command
        65274,  -- Cloak of Coordination
        64360,  -- Cloak of Coordination
        166559, -- Commander's Signet of Battle
        140192, -- Dalaran Hearthstone
        93672,  -- Dark Portal
        30542,  -- Dimensional Ripper - Area 52
        18984,  -- Dimensional Ripper - Everlook
        37863,  -- Direbrew's Remote
        139599, -- Empowered Ring of the Kirin Tor
        54452,  -- Ethereal Portal
        129929, -- Ever-Shifting Mirror
        141605, -- Flight Master's Whistle
        110560, -- Garrison Hearthstone
        162973, -- Greatfater Winter's Hearthstone
        163045, -- Headless Horseman's Hearthstone
        6948,   -- Hearthstone
        63378,  -- Hellscream's Reach Tabard
        128502, -- Hunter's Seeking Crystal
        64488,  -- The Innkeeper's Daughter
        52251,  -- Jaina's Locket
        152964, -- Krokul Flute
        95567,  -- Kirin Tor Beacon
        64457,  -- The Last Relic of Argus
        87548,  -- Lorewalker's Lodestone
        165669, -- Lunar Elder's Hearthstone
        21711,  -- Lunar Festival Invitation
        128503, -- Master Hunter's Seeking Crystal
        140324, -- Mobile Telemancy Beacon
        165670, -- Peddlefeet's Lovely Hearthstone
        58487,  -- Potion of Deepholm
        144392, -- Pugilist's Powerful Punching Ring
        118663, -- Relic of Karabor
        44935,  -- Ring of the Kirin Tor
        28585,  -- Ruby Slippers
        37118,  -- Scroll of Recall
        44314,  -- Scroll of Recall II
        44315,  -- Scroll of Recall III
        43824,  -- The Schools of Arcane Magic - Mastery
        63352,  -- Shroud of Cooperation
        63353,  -- Shroud of Cooperation
        40585,  -- Signet of the Kirin Tor
        95568,  -- Sunreaver Beacon
        103678, -- Time-Los Artifact
        18986,  -- Ultrasafe Transporter: Gadgetzan
        30544,  -- Ultrasafe Transporter: Toshley's Station
        142469, -- Violet Seal of the Grand Magus
        112059, -- Wormhole Centrifuge
        48933,  -- Wormhole Generator: Northrend
        87215,  -- Wormhole Generator: Pandaria
        63206,  -- Wrap of Unity
        63207   -- Wrap of Unity
    },

    -- Archaeology
    archaeology = {
        109586, -- Brittle Cartography Journal
        142113, -- Crate of Arakkoa Fragments
        164625, -- Crate of Demon Fragments
        87534,  -- Crate of Draenei Fragments
        142114, -- Crate of Draenor Clans Fragments
        87533,  -- Crate of Dwarven Fragments
        87535,  -- Crate of Fossil Fragments
        164626, -- Crate of Highborne Fragments
        164627, -- Crate of Highmountain Tauren Fragments
        117388, -- Crate of Manti Fragments
        117387, -- Crate of Mogu Fragments
        87537,  -- Crate of Nerubian Fragments
        87536,  -- Crate of Night Elf Fragments
        142115, -- Crate of Ogre Fragments
        87538,  -- Crate of Orc Fragments
        117386, -- Crate of Pandaren Fragments
        87539,  -- Crate of Tol'vir Fragments
        87540,  -- Crate of Troll Fragments
        87541,  -- Crate of Vrykul Fragments
        136419, -- Excavator's Notebook
        130903, -- Acnient Suramar Scroll
        109585, -- Arakkoa Cipher
        64394,  -- Draenei Tome
        108439, -- Draenor Clan Orator Cane
        52843,  -- Dwarf Rune Stone
        154990, -- Etched Drust Bone
        63127,  -- Highborne Scroll
        130904, -- Highmountain Ritual-Stone
        95373,  -- Mantid Amber Sliver
        130905, -- Mark of the Deceiver
        79869,  -- Mogu Statue Piece
        64396,  -- Nerubian Obelisk
        109584, -- Ogre Missive
        64392,  -- Orc Blood Text
        79868,  -- Pandaren Pottery Shard
        64397,  -- Tol'vir Hieroglyphic
        63128,  -- Troll Tablet
        64395,  -- Vrykul Rune Stick
        154989  -- Zandalari Idol
    },

    -- Cooking
    cooking = {
        44835,  -- Autumnal Herbs
        62786,  -- Cocoa Beans
        5051,   -- Dig Rat
        44853,  -- Honey
        13757,  -- Lightning Eel
        162515, -- Midnight Salmon
        2678,   -- Mild Spices
        43007,  -- Northern Spices
        30817   -- Simple Flour
    }
}

local bagNames = {}
if gl == "deDE" then
-- German
    bagNames.bagParts                  = "Handwerk: Teile"
    bagNames.bagJewelcrafting          = "Handwerk: Juwelenschleifen"
    bagNames.bagCloth                  = "Handwerk: Stoff"
    bagNames.bagLeatherworking         = "Handwerk: Lederverarbeitung"
    bagNames.bagMetalStone             = "Handwerk: Metall & Stein"
    bagNames.bagCooking                = "Handwerk: Kochen"
    bagNames.bagHerb                   = "Handwerk: Kräuter"
    bagNames.bagElemental              = "Handwerk: Elementar"
    bagNames.bagEnchanting             = "Handwerk: Verzauberkunst"
    bagNames.bagInscription            = "Handwerk: Inschrift"
    bagNames.bagMechagonTinkering      = "Mechagon-Basteln"
    bagNames.bagTravelTeleportation    = "Reise & Teleportation"
    bagNames.bagArchaeology            = "Archäologie"
    bagNames.bagTabards                = "Wappenröcke"
elseif gl == "ruRU" then
-- Russian
    bagNames.bagParts                  = "Tradeskill: запчасти"
    bagNames.bagJewelcrafting          = "Tradeskill: ювелирное дело"
    bagNames.bagCloth                  = "Tradeskill: Ткань"
    bagNames.bagLeatherworking         = "Профессия: кожевничество"
    bagNames.bagMetalStone             = "Tradeskill: металл и камень"
    bagNames.bagCooking                = "Tradeskill: Кулинария"
    bagNames.bagHerb                   = "Традескилл: трава"
    bagNames.bagElemental              = "Традескилл: Элементаль"
    bagNames.bagEnchanting             = "Tradeskill: Enchanting"
    bagNames.bagInscription            = "Tradeskill: надпись"
    bagNames.bagMechagonTinkering      = "Mechagon Tinkering"
    bagNames.bagTravelTeleportation    = "Путешествия и телепортация"
    bagNames.bagArchaeology            = "археология"
    bagNames.bagTabards                = "накидки"
elseif gl == "zhTW" then
-- Chinese (Taiwan)
    bagNames.bagParts                  = "Tradeskill：零件"
    bagNames.bagJewelcrafting          = "Tradeskill：珠宝加工"
    bagNames.bagCloth                  = "Tradeskill：布料"
    bagNames.bagLeatherworking         = "Tradeskill：制皮"
    bagNames.bagMetalStone             = "Tradeskill：金属和石头"
    bagNames.bagCooking                = "Tradeskill：烹饪"
    bagNames.bagHerb                   = "Tradeskill：草药"
    bagNames.bagElemental              = "Tradeskill：元素"
    bagNames.bagEnchanting             = "Tradeskill：附魔"
    bagNames.bagInscription            = "Tradeskill：铭文"
    bagNames.bagMechagonTinkering      = "Mechagon Tinkering"
    bagNames.bagTravelTeleportation    = "旅行和传送"
    bagNames.bagArchaeology            = "考古学"
    bagNames.bagTabards                = "战袍"
elseif gl == "zhCN" then
-- Chinese (China)
    bagNames.bagParts                  = "Tradeskill：零件"
    bagNames.bagJewelcrafting          = "Tradeskill：珠宝加工"
    bagNames.bagCloth                  = "Tradeskill：布料"
    bagNames.bagLeatherworking         = "Tradeskill：制皮"
    bagNames.bagMetalStone             = "Tradeskill：金属和石头"
    bagNames.bagCooking                = "Tradeskill：烹饪"
    bagNames.bagHerb                   = "Tradeskill：草药"
    bagNames.bagElemental              = "Tradeskill：元素"
    bagNames.bagEnchanting             = "Tradeskill：附魔"
    bagNames.bagInscription            = "Tradeskill：铭文"
    bagNames.bagMechagonTinkering      = "Mechagon Tinkering"
    bagNames.bagTravelTeleportation    = "旅行和传送"
    bagNames.bagArchaeology            = "考古学"
    bagNames.bagTabards                = "战袍"
elseif gl == "koKR" then
-- Korean
    bagNames.bagParts                  = "Tradeskill : 부품"
    bagNames.bagJewelcrafting          = "Tradeskill : 보석 세공"
    bagNames.bagCloth                  = "Tradeskill : 천"
    bagNames.bagLeatherworking         = "상인 : 가죽 세공"
    bagNames.bagMetalStone             = "Tradeskill : 금속 및 석재"
    bagNames.bagCooking                = "Tradeskill : 요리"
    bagNames.bagHerb                   = "Tradeskill : 허브"
    bagNames.bagElemental              = "트레이드 스킬 : 정령"
    bagNames.bagEnchanting             = "트레이드 스킬 : 마법 부여"
    bagNames.bagInscription            = "Tradeskill : 비문"
    bagNames.bagMechagonTinkering      = "메카 곤 땜질"
    bagNames.bagTravelTeleportation    = "여행 및 순간 이동"
    bagNames.bagArchaeology            = "고고학"
    bagNames.bagTabards                = "휘장"
elseif gl == "frFR" then
-- French
    bagNames.bagParts                  = "Artisanat: Pièces"
    bagNames.bagJewelcrafting          = "Artisanat: joaillerie"
    bagNames.bagCloth                  = "Artisanat: Tissu"
    bagNames.bagLeatherworking         = "Artisanat: travail du cuir"
    bagNames.bagMetalStone             = "Artisanat: métal et pierre"
    bagNames.bagCooking                = "Artisanat: Cuisine"
    bagNames.bagHerb                   = "Artisanat: herbe"
    bagNames.bagElemental              = "Artisanat: élémentaire"
    bagNames.bagEnchanting             = "Artisanat: Enchantement"
    bagNames.bagInscription            = "Artisanat: Inscription"
    bagNames.bagMechagonTinkering      = "Bricolage Mechagon"
    bagNames.bagTravelTeleportation    = "Voyage et téléportation"
    bagNames.bagArchaeology            = "Archéologie"
    bagNames.bagTabards                = "Tabards"
elseif gl == "itIT" then
-- Italian
    bagNames.bagParts                  = "Tradeskill: Parti"
    bagNames.bagJewelcrafting          = "Tradeskill: creazione di gioielli"
    bagNames.bagCloth                  = "Tradeskill: Cloth"
    bagNames.bagLeatherworking         = "Tradeskill: pelletteria"
    bagNames.bagMetalStone             = "Tradeskill: metallo e pietra"
    bagNames.bagCooking                = "Tradeskill: Cooking"
    bagNames.bagHerb                   = "Tradeskill: Herb"
    bagNames.bagElemental              = "Tradeskill: Elemental"
    bagNames.bagEnchanting             = "Tradeskill: Incantevole"
    bagNames.bagInscription            = "Tradeskill: iscrizione"
    bagNames.bagMechagonTinkering      = "Mechagon Tinkering"
    bagNames.bagTravelTeleportation    = "Viaggi e teletrasporto"
    bagNames.bagArchaeology            = "Archeologia"
    bagNames.bagTabards                = "tabards"
else
    bagNames.bagParts                  = "Tradeskill: Parts"
    bagNames.bagJewelcrafting          = "Tradeskill: Jewelcrafting"
    bagNames.bagCloth                  = "Tradeskill: Cloth"
    bagNames.bagLeatherworking         = "Tradeskill: Leatherworking"
    bagNames.bagMetalStone             = "Tradeskill: Metal & Stone"
    bagNames.bagCooking                = "Tradeskill: Cooking"
    bagNames.bagHerb                   = "Tradeskill: Herb"
    bagNames.bagElemental              = "Tradeskill: Elemental"
    bagNames.bagEnchanting             = "Tradeskill: Enchanting"
    bagNames.bagInscription            = "Tradeskill: Inscription"
    bagNames.bagMechagonTinkering      = "Mechagon Tinkering"
    bagNames.bagTravelTeleportation    = "Travel & Teleportation"
    bagNames.bagArchaeology            = "Archaeology"
    bagNames.bagTabards                = "Tabards"
end

--------------------
--Basic filters
--------------------
filters.fBags = function(item) return item.bagID >= _G.BACKPACK_CONTAINER and item.bagID <= _G.NUM_BAG_SLOTS end
filters.fBank = function(item) return item.bagID == _G.BANK_CONTAINER or item.bagID >= _G.NUM_BAG_SLOTS + 1 and item.bagID <= _G.NUM_BAG_SLOTS + _G.NUM_BANKBAGSLOTS end
filters.fBankReagent = function(item) return item.bagID == _G.REAGENTBANK_CONTAINER end
filters.fBankFilter = function() return _G.cBnivCfg.FilterBank end
filters.fHideEmpty = function(item)
    if _G.cBnivCfg.CompressEmpty then
        return item.link ~= nil
    else
        return true
    end
end

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

-- Checks the supplied table(s) for the existence
-- of an item with a particular name
-- If/Once found, returns true, otherwise, returns false
--
-- src   :: table(s) to check
-- check :: name to check for
--
-- luacheck:ignore type
function cbNivaya:CheckTable(src,check)
    local rtrn = 0
    for index, value in ipairs(src) do
        if type(value) == "table" then
            cbNivaya:CheckTable(value,check)
        else
            if index == "name" and value == check then rtrn = true end
        end
        if rtrn then break end
    end
    return rtrn
end

function cbNivaya:ClassifyItem(item)
    local bags = _G.cB_CustomBags

    -- Gives us access to more information about the item
    if item.bagID == -2 then
        -- keyring
        itemClass[item.id] = "Keyring"
    elseif _G.cBniv_CatInfo[item.id] then
        -- user assigned containers
        itemClass[item.id] = _G.cBniv_CatInfo[item.id]
    elseif item.rarity == 0 and item.sellPrice >= 1 then
        -- junk (only classify items as junk that are 0 rarity AND can be sold to a vendor)
        itemClass[item.id] = "Junk"
    elseif item.typeID then
        -- type based filters
        if (item.typeID == _G.LE_ITEM_CLASS_ARMOR) or (item.typeID == _G.LE_ITEM_CLASS_WEAPON) or _G.IsArtifactRelicItem(item.link or item.id) then
            itemClass[item.id] = "Armor"
        elseif (item.typeID == _G.LE_ITEM_CLASS_QUESTITEM) then
            itemClass[item.id] = "Quest"
        elseif (item.typeID == _G.LE_ITEM_CLASS_TRADEGOODS) then
            -- Better item filtering
            -- Default to Trade Goods
            itemClass[item.id] = "TradeGoods"
            -- Tradeskill specific
            if item.subTypeID == 1 and cbNivaya:CheckTable(bags,bagNames.bagParts) then
                itemClass[item.id] = bagNames.bagParts
            elseif item.subTypeID == 4 and cbNivaya:CheckTable(bags,bagNames.bagJewelcrafting) then
                itemClass[item.id] = bagNames.bagJewelcrafting
            elseif item.subTypeID == 5 and cbNivaya:CheckTable(bags,bagNames.bagCloth) then
                itemClass[item.id] = bagNames.bagCloth
            elseif item.subTypeID == 6 and cbNivaya:CheckTable(bags,bagNames.bagLeatherworking) then
                itemClass[item.id] = bagNames.bagLeatherworking
            elseif item.subTypeID == 7 and cbNivaya:CheckTable(bags,bagNames.bagMetalStone) then
                itemClass[item.id] = bagNames.bagMetalStone
            elseif item.subTypeID == 8 and cbNivaya:CheckTable(bags,bagNames.bagCooking) then
                itemClass[item.id] = bagNames.bagCooking
            elseif item.subTypeID == 9 and cbNivaya:CheckTable(bags,bagNames.bagHerb) then
                itemClass[item.id] = bagNames.bagHerb
            elseif item.subTypeID == 10 and cbNivaya:CheckTable(bags,bagNames.bagElemental) then
                itemClass[item.id] = bagNames.bagElemental
            elseif item.subTypeID == 12 and cbNivaya:CheckTable(bags,bagNames.bagEnchanting) then
                itemClass[item.id] = bagNames.bagEnchanting
            elseif item.subTypeID == 16 and cbNivaya:CheckTable(bags,bagNames.bagInscription) then
                itemClass[item.id] = bagNames.bagInscription
            end
        elseif (item.typeID == _G.LE_ITEM_CLASS_CONSUMABLE) then
            itemClass[item.id] = "Consumables"
        elseif(item.typeID == _G.LE_ITEM_CLASS_BATTLEPET) then
            itemClass[item.id] = "BattlePet"
        elseif item.typeID == 9 then
            itemClass[item.id] = "Recipes"
        end
        if item.equipLoc == "INVTYPE_TABARD" and cbNivaya:CheckTable(bags,bagNames.bagTabards) then
            itemClass[item.id] = bagNames.bagTabards
        end

        -- Mechagon Tinkering
        for _,v in ipairs(itemIDs.mechagon) do
            if v == item.id and cbNivaya:CheckTable(bags,bagNames.bagMechagonTinkering) then
                itemClass[item.id] = bagNames.bagMechagonTinkering
                break
            end
        end
        -- Travel & Teleportation
        for _,v in ipairs(itemIDs.travel) do
            if v == item.id and cbNivaya:CheckTable(bags,bagNames.bagTravelTeleportation) then
                itemClass[item.id] = bagNames.bagTravelTeleportation
                break
            end
        end
        -- Archaeology
        for _,v in ipairs(itemIDs.archaeology) do
            if v == item.id and cbNivaya:CheckTable(bags,bagNames.bagArchaeology) then
                itemClass[item.id] = bagNames.bagArchaeology
                break
            end
        end
        -- Cooking
        for _,v in ipairs(itemIDs.cooking) do
            if v == item.id and cbNivaya:CheckTable(bags,bagNames.bagCooking) then
                itemClass[item.id] = bagNames.bagCooking
                break
            end
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
local function IsItemNew(item)
    if ns.newItems[item.link] then
        return true
    elseif _G.C_NewItems.IsNewItem(item.bagID, item.slotID) then
        ns.newItems[item.link] = true
        return true
    end
    return false
end

filters.fNewItems = function(item)
    if not _G.cBnivCfg.NewItems then return false end
    if not ((item.bagID >= 0) and (item.bagID <= 4)) then return false end
    if not item.link then return false end

    return IsItemNew(item)
end

-----------------------------------------
-- Item Set filter and related functions
-----------------------------------------
local item2setIR = {} -- ItemRack
local item2setOF = {} -- Outfitter
local IR = _G.IsAddOnLoaded('ItemRack')
local OF = _G.IsAddOnLoaded('Outfitter')

filters.fItemSets = function(item)
    --print("fItemSets", item, item.link, item.isInSet)
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
