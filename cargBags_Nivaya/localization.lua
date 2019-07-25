local _, ns = ...

local L = {}
local gl = _G.GetLocale()

L.Search = _G.SEARCH
L.Armor = _G.AUCTION_CATEGORY_ARMOR
L.BattlePet = _G.AUCTION_CATEGORY_BATTLE_PETS
L.Consumables = _G.AUCTION_CATEGORY_CONSUMABLES
L.Gem = _G.AUCTION_CATEGORY_GEMS
L.Quest = _G.AUCTION_CATEGORY_QUEST_ITEMS
L.Trades = _G.AUCTION_CATEGORY_TRADE_GOODS
L.Weapon = _G.AUCTION_CATEGORY_WEAPONS
L.bagCaptions = {
    ["cBniv_Bank"]          = _G.BANK,
    ["cBniv_BankReagent"]   = _G.REAGENT_BANK,
    ["cBniv_BankSets"]      = _G.LOOT_JOURNAL_ITEM_SETS,
    ["cBniv_BankArmor"]     = _G.BAG_FILTER_EQUIPMENT,
    ["cBniv_BankQuest"]     = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    ["cBniv_BankPet"]       = _G.AUCTION_CATEGORY_BATTLE_PETS,
    ["cBniv_BankTrade"]     = _G.BAG_FILTER_TRADE_GOODS,
    ["cBniv_BankCons"]      = _G.BAG_FILTER_CONSUMABLES,
    ["cBniv_Junk"]          = _G.BAG_FILTER_JUNK,
    ["cBniv_ItemSets"]      = _G.LOOT_JOURNAL_ITEM_SETS,
    ["cBniv_Armor"]         = _G.BAG_FILTER_EQUIPMENT,
    ["cBniv_Quest"]         = _G.AUCTION_CATEGORY_QUEST_ITEMS,
    ["cBniv_Consumables"]   = _G.BAG_FILTER_CONSUMABLES,
    ["cBniv_TradeGoods"]    = _G.BAG_FILTER_TRADE_GOODS,
    ["cBniv_BattlePet"]     = _G.AUCTION_CATEGORY_BATTLE_PETS,
    ["cBniv_Bag"]           = _G.INVENTORY_TOOLTIP,
    ["cBniv_Keyring"]       = _G.KEYRING,
}

if gl == "deDE" then
-- German
    L.bagParts                  = "Handwerk: Teile"
    L.bagJewelcrafting          = "Handwerk: Juwelenschleifen"
    L.bagCloth                  = "Handwerk: Stoff"
    L.bagLeatherworking         = "Handwerk: Lederverarbeitung"
    L.bagMetalStone             = "Handwerk: Metall & Stein"
    L.bagCooking                = "Handwerk: Kochen"
    L.bagHerb                   = "Handwerk: Kräuter"
    L.bagElemental              = "Handwerk: Elementar"
    L.bagEnchanting             = "Handwerk: Verzauberkunst"
    L.bagInscription            = "Handwerk: Inschrift"
    L.bagMechagonTinkering      = "Mechagon-Basteln"
    L.bagTravelTeleportation    = "Reise & Teleportation"
    L.bagArchaeology            = "Archäologie"
    L.bagTabards                = "Wappenröcke"
elseif gl == "ruRU" then
-- Russian
    L.bagParts                  = "Tradeskill: запчасти"
    L.bagJewelcrafting          = "Tradeskill: ювелирное дело"
    L.bagCloth                  = "Tradeskill: Ткань"
    L.bagLeatherworking         = "Профессия: кожевничество"
    L.bagMetalStone             = "Tradeskill: металл и камень"
    L.bagCooking                = "Tradeskill: Кулинария"
    L.bagHerb                   = "Традескилл: трава"
    L.bagElemental              = "Традескилл: Элементаль"
    L.bagEnchanting             = "Tradeskill: Enchanting"
    L.bagInscription            = "Tradeskill: надпись"
    L.bagMechagonTinkering      = "Mechagon Tinkering"
    L.bagTravelTeleportation    = "Путешествия и телепортация"
    L.bagArchaeology            = "археология"
    L.bagTabards                = "накидки"
elseif gl == "zhTW" then
-- Chinese (Taiwan)
    L.bagParts                  = "Tradeskill：零件"
    L.bagJewelcrafting          = "Tradeskill：珠宝加工"
    L.bagCloth                  = "Tradeskill：布料"
    L.bagLeatherworking         = "Tradeskill：制皮"
    L.bagMetalStone             = "Tradeskill：金属和石头"
    L.bagCooking                = "Tradeskill：烹饪"
    L.bagHerb                   = "Tradeskill：草药"
    L.bagElemental              = "Tradeskill：元素"
    L.bagEnchanting             = "Tradeskill：附魔"
    L.bagInscription            = "Tradeskill：铭文"
    L.bagMechagonTinkering      = "Mechagon Tinkering"
    L.bagTravelTeleportation    = "旅行和传送"
    L.bagArchaeology            = "考古学"
    L.bagTabards                = "战袍"
elseif gl == "zhCN" then
-- Chinese (China)
    L.bagParts                  = "Tradeskill：零件"
    L.bagJewelcrafting          = "Tradeskill：珠宝加工"
    L.bagCloth                  = "Tradeskill：布料"
    L.bagLeatherworking         = "Tradeskill：制皮"
    L.bagMetalStone             = "Tradeskill：金属和石头"
    L.bagCooking                = "Tradeskill：烹饪"
    L.bagHerb                   = "Tradeskill：草药"
    L.bagElemental              = "Tradeskill：元素"
    L.bagEnchanting             = "Tradeskill：附魔"
    L.bagInscription            = "Tradeskill：铭文"
    L.bagMechagonTinkering      = "Mechagon Tinkering"
    L.bagTravelTeleportation    = "旅行和传送"
    L.bagArchaeology            = "考古学"
    L.bagTabards                = "战袍"
elseif gl == "koKR" then
-- Korean
    L.bagParts                  = "Tradeskill : 부품"
    L.bagJewelcrafting          = "Tradeskill : 보석 세공"
    L.bagCloth                  = "Tradeskill : 천"
    L.bagLeatherworking         = "상인 : 가죽 세공"
    L.bagMetalStone             = "Tradeskill : 금속 및 석재"
    L.bagCooking                = "Tradeskill : 요리"
    L.bagHerb                   = "Tradeskill : 허브"
    L.bagElemental              = "트레이드 스킬 : 정령"
    L.bagEnchanting             = "트레이드 스킬 : 마법 부여"
    L.bagInscription            = "Tradeskill : 비문"
    L.bagMechagonTinkering      = "메카 곤 땜질"
    L.bagTravelTeleportation    = "여행 및 순간 이동"
    L.bagArchaeology            = "고고학"
    L.bagTabards                = "휘장"
elseif gl == "frFR" then
-- French
    L.bagParts                  = "Artisanat: Pièces"
    L.bagJewelcrafting          = "Artisanat: joaillerie"
    L.bagCloth                  = "Artisanat: Tissu"
    L.bagLeatherworking         = "Artisanat: travail du cuir"
    L.bagMetalStone             = "Artisanat: métal et pierre"
    L.bagCooking                = "Artisanat: Cuisine"
    L.bagHerb                   = "Artisanat: herbe"
    L.bagElemental              = "Artisanat: élémentaire"
    L.bagEnchanting             = "Artisanat: Enchantement"
    L.bagInscription            = "Artisanat: Inscription"
    L.bagMechagonTinkering      = "Bricolage Mechagon"
    L.bagTravelTeleportation    = "Voyage et téléportation"
    L.bagArchaeology            = "Archéologie"
    L.bagTabards                = "Tabards"
elseif gl == "itIT" then
-- Italian
    L.bagParts                  = "Tradeskill: Parti"
    L.bagJewelcrafting          = "Tradeskill: creazione di gioielli"
    L.bagCloth                  = "Tradeskill: Cloth"
    L.bagLeatherworking         = "Tradeskill: pelletteria"
    L.bagMetalStone             = "Tradeskill: metallo e pietra"
    L.bagCooking                = "Tradeskill: Cooking"
    L.bagHerb                   = "Tradeskill: Herb"
    L.bagElemental              = "Tradeskill: Elemental"
    L.bagEnchanting             = "Tradeskill: Incantevole"
    L.bagInscription            = "Tradeskill: iscrizione"
    L.bagMechagonTinkering      = "Mechagon Tinkering"
    L.bagTravelTeleportation    = "Viaggi e teletrasporto"
    L.bagArchaeology            = "Archeologia"
    L.bagTabards                = "tabards"
else
    L.bagParts                  = "Tradeskill: Parts"
    L.bagJewelcrafting          = "Tradeskill: Jewelcrafting"
    L.bagCloth                  = "Tradeskill: Cloth"
    L.bagLeatherworking         = "Tradeskill: Leatherworking"
    L.bagMetalStone             = "Tradeskill: Metal & Stone"
    L.bagCooking                = "Tradeskill: Cooking"
    L.bagHerb                   = "Tradeskill: Herb"
    L.bagElemental              = "Tradeskill: Elemental"
    L.bagEnchanting             = "Tradeskill: Enchanting"
    L.bagInscription            = "Tradeskill: Inscription"
    L.bagMechagonTinkering      = "Mechagon Tinkering"
    L.bagTravelTeleportation    = "Travel & Teleportation"
    L.bagArchaeology            = "Archaeology"
    L.bagTabards                = "Tabards"
end


if gl == "deDE" then
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "Cooles Zeugs"
    L.bagCaptions.cBniv_NewItems = "Neue Items"
elseif gl == "ruRU" then
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "Разное"
    L.bagCaptions.cBniv_NewItems = "Новые предметы"
elseif gl == "zhTW" then
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "施法材料"
    L.bagCaptions.cBniv_NewItems = "新增"
elseif gl == "zhCN" then
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "施法材料"
    L.bagCaptions.cBniv_NewItems = "新增"
elseif gl == "koKR" then
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "지정"
    L.bagCaptions.cBniv_NewItems = "신규"
elseif gl == "frFR" then
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "Divers"
    L.bagCaptions.cBniv_NewItems = "Nouveaux Objets"
elseif gl == "itIT" then
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "Cose Interessanti"
    L.bagCaptions.cBniv_NewItems = "Oggetti Nuovi"
else
    L.ResetCategory = "Reset Category"
    L.bagCaptions.cBniv_Stuff = "Cool Stuff"
    L.bagCaptions.cBniv_NewItems = "New Items"
end

ns.L = L
