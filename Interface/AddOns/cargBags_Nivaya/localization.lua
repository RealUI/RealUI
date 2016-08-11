cBnivL = {}
local gl = GetLocale()

cBnivL.Search = SEARCH
cBnivL.Armor = AUCTION_CATEGORY_ARMOR
cBnivL.BattlePet = AUCTION_CATEGORY_BATTLE_PETS
cBnivL.Consumables = AUCTION_CATEGORY_CONSUMABLES
cBnivL.Gem = AUCTION_CATEGORY_GEMS
cBnivL.Quest = AUCTION_CATEGORY_QUEST_ITEMS
cBnivL.Trades = AUCTION_CATEGORY_TRADE_GOODS
cBnivL.Weapon = AUCTION_CATEGORY_WEAPONS
cBnivL.bagCaptions = {
	["cBniv_Bank"] 			= BANK,
	["cBniv_BankReagent"]	= REAGENT_BANK,
	["cBniv_BankSets"]		= LOOT_JOURNAL_ITEM_SETS,
	["cBniv_BankArmor"]		= BAG_FILTER_EQUIPMENT,
	["cBniv_BankQuest"]		= AUCTION_CATEGORY_QUEST_ITEMS,
	["cBniv_BankTrade"]		= BAG_FILTER_TRADE_GOODS,
	["cBniv_BankCons"]		= BAG_FILTER_CONSUMABLES,
	["cBniv_Junk"]			= BAG_FILTER_JUNK,
	["cBniv_ItemSets"]		= LOOT_JOURNAL_ITEM_SETS,
	["cBniv_Armor"]			= BAG_FILTER_EQUIPMENT,
	["cBniv_Quest"]			= AUCTION_CATEGORY_QUEST_ITEMS,
	["cBniv_Consumables"]	= BAG_FILTER_CONSUMABLES,
	["cBniv_TradeGoods"]	= BAG_FILTER_TRADE_GOODS,
	["cBniv_BattlePet"]		= AUCTION_CATEGORY_BATTLE_PETS,
	["cBniv_Bag"]			= INVENTORY_TOOLTIP,
	["cBniv_Keyring"]		= KEYRING,
}	

if gl == "deDE" then
	cBnivL.MarkAsNew = "Als neu markieren"
	cBnivL.MarkAsKnown = "Als bekannt markieren"
	cBnivL.bagCaptions.cBniv_Stuff = "Cooles Zeugs"
	cBnivL.bagCaptions.cBniv_NewItems = "Neue Items"
elseif gl == "ruRU" then
	cBnivL.MarkAsNew = "Перенести в Новые предметы"
	cBnivL.MarkAsKnown = "Перенести в Известные предметы"
	cBnivL.bagCaptions.cBniv_Stuff = "Разное"
	cBnivL.bagCaptions.cBniv_NewItems = "Новые предметы"
elseif gl == "zhTW" then
	cBnivL.MarkAsNew = "Mark as New"
	cBnivL.MarkAsKnown = "Mark as Known"
	cBnivL.bagCaptions.cBniv_Stuff = "施法材料"
	cBnivL.bagCaptions.cBniv_NewItems = "新增"
elseif gl == "zhCN" then
	cBnivL.MarkAsNew = "Mark as New"
	cBnivL.MarkAsKnown = "Mark as Known"
	cBnivL.bagCaptions.cBniv_Stuff = "施法材料"
	cBnivL.bagCaptions.cBniv_NewItems = "新增"
elseif gl == "koKR" then
	cBnivL.MarkAsNew = "Mark as New"
	cBnivL.MarkAsKnown = "Mark as Known"
	cBnivL.bagCaptions.cBniv_Stuff = "지정"
	cBnivL.bagCaptions.cBniv_NewItems = "신규"
elseif gl == "frFR" then
	cBnivL.MarkAsNew = "Marquer comme Neuf"
	cBnivL.MarkAsKnown = "Marquer comme Connu"
	cBnivL.bagCaptions.cBniv_Stuff = "Divers"
	cBnivL.bagCaptions.cBniv_NewItems = "Nouveaux Objets"
elseif gl == "itIT" then
    cBnivL.MarkAsNew = "Segna come Nuovo"
    cBnivL.MarkAsKnown = "Segna come Conosciuto"
	cBnivL.bagCaptions.cBniv_Stuff = "Cose Interessanti"
	cBnivL.bagCaptions.cBniv_NewItems = "Oggetti Nuovi"
else
	cBnivL.MarkAsNew = "Mark as New"
	cBnivL.MarkAsKnown = "Mark as Known"
	cBnivL.bagCaptions.cBniv_Stuff = "Cool Stuff"
	cBnivL.bagCaptions.cBniv_NewItems = "New Items"
end
