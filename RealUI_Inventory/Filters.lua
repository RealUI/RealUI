local _, private = ...

-- Lua Globals --
-- luacheck: globals tinsert ipairs

-- RealUI --
local Inventory = private.Inventory

private.filters = {}
private.filterList = {}
local function CreateFilter(tag, info)
    private.filters[tag] = info
    tinsert(private.filterList, tag)
end

CreateFilter("junk", {
    name = _G.BAG_FILTER_JUNK,
    filter = function(slot)
        local _, _, _, quality, _, _, _, _, noValue = _G.GetContainerItemInfo(slot:GetBagAndSlot())
        return quality == _G.LE_ITEM_QUALITY_POOR and not noValue
    end,
})

CreateFilter("consumables", {
    name = _G.AUCTION_CATEGORY_CONSUMABLES,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_CONSUMABLE
    end,
})

CreateFilter("questitems", {
    name = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_QUESTITEM
    end,
})

local prefix = _G.BAG_FILTER_TRADE_GOODS .. ": %s"
local tradegoods
if Inventory.isPatch then
    tradegoods = _G.C_AuctionHouse.GetAuctionItemSubClasses(_G.LE_ITEM_CLASS_TRADEGOODS)
else
    tradegoods = {_G.GetAuctionItemSubClasses(_G.LE_ITEM_CLASS_TRADEGOODS)}
end

for i = 1, #tradegoods do
    local subClassID = tradegoods[i]
    local name = _G.GetItemSubClassInfo(_G.LE_ITEM_CLASS_TRADEGOODS, subClassID)
    CreateFilter("tradegoods_"..subClassID, {
        name = prefix:format(name),
        filter = function(slot)
            local _, _, _, _, _, typeID, subTypeID = _G.GetItemInfoInstant(slot.item:GetItemID())
            return typeID == _G.LE_ITEM_CLASS_TRADEGOODS and subTypeID == subClassID
        end,
    })
end

CreateFilter("equipment", {
    name = _G.BAG_FILTER_EQUIPMENT,
    filter = function(slot)
        local _, _, _, _, _, typeID = _G.GetItemInfoInstant(slot.item:GetItemID())
        return typeID == _G.LE_ITEM_CLASS_ARMOR or typeID == _G.LE_ITEM_CLASS_WEAPON
    end,
})


local travel = {
    [140493] = true,     -- Adept's Guide to Dimensional Rifting
    [128353] = true,     -- Admiral's Compass
    [46874] = true,      -- Argent Crusader's Tabard
    [22589] = true,      -- Atiesh, Greatstaff of the Guardian
    [63379] = true,      -- Baradin's Wardens Tabard
    [129276] = true,     -- Beginner's Guide to Dimensional Rifting
    [118662] = true,     -- Bladespire Relic
    [32757] = true,      -- Blessed Medallion of Karabor
    [50287] = true,      -- Boots of the Bay
    [166560] = true,     -- Captain's Signet of Command
    [65274] = true,      -- Cloak of Coordination
    [64360] = true,      -- Cloak of Coordination
    [166559] = true,     -- Commander's Signet of Battle
    [140192] = true,     -- Dalaran Hearthstone
    [93672] = true,      -- Dark Portal
    [30542] = true,      -- Dimensional Ripper - Area 52
    [18984] = true,      -- Dimensional Ripper - Everlook
    [37863] = true,      -- Direbrew's Remote
    [139599] = true,     -- Empowered Ring of the Kirin Tor
    [54452] = true,      -- Ethereal Portal
    [129929] = true,     -- Ever-Shifting Mirror
    [141605] = true,     -- Flight Master's Whistle
    [110560] = true,     -- Garrison Hearthstone
    [162973] = true,     -- Greatfater Winter's Hearthstone
    [163045] = true,     -- Headless Horseman's Hearthstone
    [6948] = true,       -- Hearthstone
    [63378] = true,      -- Hellscream's Reach Tabard
    [128502] = true,     -- Hunter's Seeking Crystal
    [64488] = true,      -- The Innkeeper's Daughter
    [52251] = true,      -- Jaina's Locket
    [152964] = true,     -- Krokul Flute
    [95567] = true,      -- Kirin Tor Beacon
    [64457] = true,      -- The Last Relic of Argus
    [87548] = true,      -- Lorewalker's Lodestone
    [165669] = true,     -- Lunar Elder's Hearthstone
    [21711] = true,      -- Lunar Festival Invitation
    [128503] = true,     -- Master Hunter's Seeking Crystal
    [140324] = true,     -- Mobile Telemancy Beacon
    [165670] = true,     -- Peddlefeet's Lovely Hearthstone
    [58487] = true,      -- Potion of Deepholm
    [144392] = true,     -- Pugilist's Powerful Punching Ring
    [118663] = true,     -- Relic of Karabor
    [44935] = true,      -- Ring of the Kirin Tor
    [28585] = true,      -- Ruby Slippers
    [37118] = true,      -- Scroll of Recall
    [44314] = true,      -- Scroll of Recall II
    [44315] = true,      -- Scroll of Recall III
    [141016] = true,     -- Scroll of Town Portal: Faronaar
    [141015] = true,     -- Scroll of Town Portal: Kal'delar
    [141017] = true,     -- Scroll of Town Portal: Lian'tril
    [43824] = true,      -- The Schools of Arcane Magic - Mastery
    [63352] = true,      -- Shroud of Cooperation
    [63353] = true,      -- Shroud of Cooperation
    [40585] = true,      -- Signet of the Kirin Tor
    [95568] = true,      -- Sunreaver Beacon
    [103678] = true,     -- Time-Los Artifact
    [18986] = true,      -- Ultrasafe Transporter: Gadgetzan
    [30544] = true,      -- Ultrasafe Transporter: Toshley's Station
    [142469] = true,     -- Violet Seal of the Grand Magus
    [112059] = true,     -- Wormhole Centrifuge
    [48933] = true,      -- Wormhole Generator: Northrend
    [87215] = true,      -- Wormhole Generator: Pandaria
    [63206] = true,      -- Wrap of Unity
    [63207] = true,      -- Wrap of Unity
}
CreateFilter("travel", {
    name = _G.TUTORIAL_TITLE35,
    filter = function(slot)
        return travel[slot.item:GetItemID()]
    end,
})

