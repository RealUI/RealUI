local AL = LibStub("AceLocale-3.0")

local silent = true

local L = AL:GetLocale("DXE")
if not L then
    local L = AL:NewLocale("DXE", "enUS", true, silent)
end

if L then
	-- Chat triggers
	local chat_ThroneOfThunder = AL:NewLocale("DXE Chat ThroneOfThunder", "enUS", true, silent)
	AL:GetLocale("DXE").chat_ThroneOfThunder = AL:GetLocale("DXE Chat ThroneOfThunder")
	-- NPC names
	local npc_ThroneOfThunder = AL:NewLocale("DXE NPC ThroneOfThunder", "enUS", true, silent)
	AL:GetLocale("DXE").npc_ThroneOfThunder = AL:GetLocale("DXE NPC ThroneOfThunder")
	if GetLocale() == "enUS" or GetLocale() == "enGB" then return end
end

local L = AL:NewLocale("DXE", "deDE")
if L then
	-- Chat triggers
	local chat_ThroneOfThunder = AL:NewLocale("DXE Chat ThroneOfThunder", "deDE")

	-- Horrison
	chat_ThroneOfThunder["(forces pour from the)"] = "(stürmen aus dem Stammestor)"
	chat_ThroneOfThunder["(stamps his tail!)"] = "(schlägt mit dem Schwanz)"
	
	-- Ji Kun
	chat_ThroneOfThunder["(lower nests begin to hatch)"] = "(Die Eier in einem der unteren Nester beginnen)"
	chat_ThroneOfThunder["(upper nests begin to hatch)"] = "(Die Eier in einem der oberen Nester beginnen)"
	chat_ThroneOfThunder["Lower"] = "Unten"
	chat_ThroneOfThunder["Upper"] = "Oben"
	chat_ThroneOfThunder["Upper & Lower"] = "Oben & Unten"
	chat_ThroneOfThunder["Nest Guardian"] = "Nestwächter"
	-- Megaera
	chat_ThroneOfThunder["(Megaera's rage subsides)"] = "(Megaeras Wut lässt nach)"
	chat_ThroneOfThunder["Breath"] = "Atem"
	-- Dark Animus
	chat_ThroneOfThunder["(The orb explodes!)"] = "(Die Kugel explodiert!)"

	AL:GetLocale("DXE").chat_ThroneOfThunder = AL:GetLocale("DXE Chat ThroneOfThunder")
	-- NPC names
	local npc_ThroneOfThunder = AL:NewLocale("DXE NPC ThroneOfThunder", "deDE")
	--npc_ThroneOfThunder["Dragonriders"] = "Drachenreiter"

	AL:GetLocale("DXE").npc_ThroneOfThunder = AL:GetLocale("DXE NPC ThroneOfThunder")
	return
end

local L = AL:NewLocale("DXE", "ruRU")
if L then
	-- Chat triggers
	local chat_ThroneOfThunder = AL:NewLocale("DXE Chat ThroneOfThunder", "ruRU")
	-- Jin'rokh
	chat_ThroneOfThunder["Move Out from the Pool"] = "Выйдите из бассейна"
	chat_ThroneOfThunder["Move Away from the Pool"] = "Отойдите дальше из бассейна"
	chat_ThroneOfThunder["GO TO HIM FOR POOL!"] = "Подойдите к нему для бассейна!"
	
	-- Horrison
	chat_ThroneOfThunder["(forces pour from the)"] = "(прибывают)"
	chat_ThroneOfThunder["(stamps his tail!)"] = "(бьет хвостом!)"
	chat_ThroneOfThunder["Orb of Control dropped"] = "Сфера контроля упала"
	chat_ThroneOfThunder["Next Door"] = "Следующие ворота"
	chat_ThroneOfThunder["Jumping down"] = "Спрыгнул"
	
	-- Council Of Elders
	chat_ThroneOfThunder["Possessed"] = "Одержимость"
	
	-- Ji Kun
	chat_ThroneOfThunder["(lower nests begin to hatch)"] = "(Яйца в одном из нижних гнезд начинают проклевываться!)"
	chat_ThroneOfThunder["(upper nests begin to hatch)"] = "(Яйца в одном из верхних гнезд начинают проклевываться!)"
	chat_ThroneOfThunder["Lower"] = "Нижний"
	chat_ThroneOfThunder["Upper"] = "Верхний"
	chat_ThroneOfThunder["Upper & Lower"] = "Верхний & Нижний"
	chat_ThroneOfThunder["Nest Guardian"] = "Страж гнезда"
	
	-- Durumu
	chat_ThroneOfThunder["Beam targets:"] = "Луч цели:"
	
	-- Megaera
	chat_ThroneOfThunder["(Megaera's rage subsides)"] = "(Ярость Мегеры идет на убыль)"
	chat_ThroneOfThunder["Breath"] = "Дыхания"
	-- Dark Animus
	chat_ThroneOfThunder["(The orb explodes!)"] = "(Сфера взрывается!)"
	
	-- Primordius
	chat_ThroneOfThunder["Mutation Debuffs"] = "Вредная мутация"
	chat_ThroneOfThunder["Mutation Buffs"] = "Полезная мутация"

	AL:GetLocale("DXE").chat_ThroneOfThunder = AL:GetLocale("DXE Chat ThroneOfThunder")
	-- NPC names
	local npc_ThroneOfThunder = AL:NewLocale("DXE NPC ThroneOfThunder", "ruRU")
	
	npc_ThroneOfThunder["Horridon"] = "Хорридон"
	npc_ThroneOfThunder["Twin Consorts"] = "Наложницы-близнецы"
	npc_ThroneOfThunder["Tortos"] = "Тортос"
	npc_ThroneOfThunder["Ra-den"] = "Ра-ден"
	npc_ThroneOfThunder["Primordius"] = "Изначалий"
	npc_ThroneOfThunder["Megaera"] = "Мегера"
	npc_ThroneOfThunder["Lei Shen"] = "Лэй шень"
	npc_ThroneOfThunder["Jin'rokh the Breaker"] = "Джин'рок Разрушитель"
	npc_ThroneOfThunder["Ji-Kun"] = "Цзи-Кунь"
	npc_ThroneOfThunder["Iron Qon"] = "Кон Железный"
	npc_ThroneOfThunder["Durumu the Forgotten"] = "Дуруму Позабытый"
	npc_ThroneOfThunder["Dark Animus"] = "Темный Анимус"
	npc_ThroneOfThunder["Council of Elders"] = "Совет старейшин"
	npc_ThroneOfThunder["Gurubashi Venom Priest"] = "Жрец яда из племени Гурубаши"
	npc_ThroneOfThunder["Farraki Wastewalker"] = "Фарракский странник пустошей"
	npc_ThroneOfThunder["Drakkari Frozen Warlord"] = "Морозный военачальник Драккари"
	npc_ThroneOfThunder["Amani Warbear"] = "Аманийский боевой медведь"
	npc_ThroneOfThunder["Amani'shi Beast Shaman"] = "Шаман-укротитель из племени Амани"

	AL:GetLocale("DXE").npc_ThroneOfThunder = AL:GetLocale("DXE NPC ThroneOfThunder")
	return
end

local L = AL:NewLocale("DXE", "zhCN")
if L then
	-- Chat triggers
	local chat_ThroneOfThunder = AL:NewLocale("DXE Chat ThroneOfThunder", "zhCN")

	-- Jin'rokh
	chat_ThroneOfThunder["GO TO HIM FOR POOL!"] = "ÒÆ¶¯ËûÄÇµÄË®ÌÁ£¡"
	chat_ThroneOfThunder["Move Out from the Pool"] = "ÒÆ³öË®ÌÁ"
	chat_ThroneOfThunder["Move Away from the Pool"] = "Ô¶ÀëË®ÌÁ"

	-- Horrison
	chat_ThroneOfThunder["Next Door"] = "ÏÂ´Î²¿×å´óÃÅ"
	chat_ThroneOfThunder["Orb of Control dropped"] = "¿ØÖÆ±¦ÖéµôÂä"
	chat_ThroneOfThunder["Jumping down"] = "Õ½ÉñÂäµØ"
	chat_ThroneOfThunder["(stamps his tail!)"] = "(²¢¿ªÊ¼ÅÄ´òËûµÄÎ²°Í£¡)"
	chat_ThroneOfThunder["(forces pour from the)"] = "(²¿×åÖ®ÃÅÖÐÓ¿³ö£¡)"

	-- Council Of Elders
	chat_ThroneOfThunder["Possessed"] = "ÓµÓÐ"
	
	-- Tortos
	chat_ThroneOfThunder["Incoming Bats!"] = "ÕÙ»½òùòð£¡"
	chat_ThroneOfThunder["Kick Turtle"] = "Ìß¹ê¿Ç"
	chat_ThroneOfThunder["Kickable Turtles:"] = "¿ÉÌß¹ê¿ÇÊý£º"

	-- Megaera
	chat_ThroneOfThunder["Arcane Adds Spawnning!"] = "Ðé¿Õ¸¡ÁúÕýÔÚ·õ»¯£¡"
	chat_ThroneOfThunder["Breath"] = "ÍÂÏ¢"
	chat_ThroneOfThunder["Arcane Adds"] = "Ðé¿Õ¸¡Áú"
	chat_ThroneOfThunder["(Megaera's rage subsides)"] = "(Ä«¸ñÈðÀ­µÄÅ­»ðÆ½Ï¢ÁË¡£)"

	-- JiKun
	chat_ThroneOfThunder["Nest Guardian"] = "ÏÂ¸ö³²Ñ¨ÊØÎÀ"
	chat_ThroneOfThunder["Lower"] = "ÏÂ²ã"
	chat_ThroneOfThunder["Nest"] = "³²Ñ¨"
	chat_ThroneOfThunder["Upper"] = "ÉÏ²ã"
	chat_ThroneOfThunder["Upper & Lower"] = "ÉÏ²ãºÍÏÂ²ã"
	chat_ThroneOfThunder["(lower nests begin to hatch)"] = "(ÏÂ²ãÄ³¸ö³²Ñ¨ÖÐµÄµ°¿ªÊ¼·õ»¯ÁË£¡)"
	chat_ThroneOfThunder["(upper nests begin to hatch)"] = "(ÉÏ²ãÄ³¸ö³²Ñ¨ÖÐµÄµ°¿ªÊ¼·õ»¯ÁË£¡)"

	-- Durumu
	chat_ThroneOfThunder["Beam targets:"] = "¹âÊøÄ¿±ê£º"
	chat_ThroneOfThunder["(The Infrared Light reveals a Crimson Fog!)"] = "(ºì¹âÕÕ³öÁËÒ»Ö»ÐÉºìÎíÐÐÊÞ£¡)"
	chat_ThroneOfThunder["(The Blue Rays reveal an Azure Eye!)"] = "(À¶¹âÕÕ³öÁËÒ»Ö»±ÌÀ¶ÎíÐÐÊÞ£¡)"

	-- DarkAnimus
	chat_ThroneOfThunder["(The orb explodes!)"] = "(±¦Öé±¬Õ¨ÁË£¡)"
	
	-- Primordius
	chat_ThroneOfThunder["Mutation Debuffs"] = "±äÒìÔöÒæ"
	chat_ThroneOfThunder["Mutation Buffs"] = "±äÒì¼õÒæ"

	-- TwinConsorts
	chat_ThroneOfThunder["(Just this once...)"] = "(Ö»´ËÒ»´Î...)"

	AL:GetLocale("DXE").chat_ThroneOfThunder = AL:GetLocale("DXE Chat ThroneOfThunder")
	-- NPC names
	local npc_ThroneOfThunder = AL:NewLocale("DXE NPC ThroneOfThunder", "zhCN")

	npc_ThroneOfThunder["Jin'rokh the Breaker"] = "»÷ËéÕß½ðÂÞ¿Ë"	
	npc_ThroneOfThunder["Horridon"] = "ºÕÀû¶«"
	npc_ThroneOfThunder["Council of Elders"] = "³¤ÕßÒé»á"
	npc_ThroneOfThunder["Tortos"] = "ÍÐ¶àË¹"
	npc_ThroneOfThunder["Megaera"] = "Ä«¸ñÈðÀ­"
	npc_ThroneOfThunder["Ji-Kun"] = "¼¾ûd"
	npc_ThroneOfThunder["Durumu the Forgotten"] = "ÒÅÍüÕß¶ÅÂ³Ä·"
	npc_ThroneOfThunder["Primordius"] = "ÆÕÀûÄªÐÞË¹"
	npc_ThroneOfThunder["Dark Animus"] = "ºÚ°µÒâÖ¾"
	npc_ThroneOfThunder["Iron Qon"] = "Ìúñ·"
	npc_ThroneOfThunder["Twin Consorts"] = "Ä§¹ÅË«ºó"
	npc_ThroneOfThunder["Lei Shen"] = "À×Éñ"
	npc_ThroneOfThunder["Ra-den"] = "À³µÇ"
	npc_ThroneOfThunder["Drakkari Frozen Warlord"] = "´ï¿¨À³±ùËªÁìÖ÷"
	npc_ThroneOfThunder["Gurubashi Venom Priest"] = "¹ÅÀ­°ÍÊ²¾ç¶¾¼ÀË¾"
	npc_ThroneOfThunder["Farraki Wastewalker"] = "·¨À­»ù·ÏÍÁÐÐÕß"
	npc_ThroneOfThunder["Amani Warbear"] = "°¢ÂüÄáÕ½ÐÜ"
	npc_ThroneOfThunder["Amani'shi Beast Shaman"] = "°¢ÂüÄáÒ°ÊÞÈøÂú"

	AL:GetLocale("DXE").npc_ThroneOfThunder = AL:GetLocale("DXE NPC ThroneOfThunder")
	return
end