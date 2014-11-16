DraenorTreasures = LibStub("AceAddon-3.0"):NewAddon("DraenorTreasures", "AceBucket-3.0", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")

local HandyNotes = LibStub("AceAddon-3.0"):GetAddon("HandyNotes", true)
if not HandyNotes then return end

local iconDefaults = {
default = "Interface\\Icons\\TRADE_ARCHAEOLOGY_CHESTOFTINYGLASSANIMALS",
unknown = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\chest_normal_daily.tga",
hundredrare = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIconBlue.tga",
rare = "Interface\\Addons\\HandyNotes_DraenorTreasures\\Artwork\\RareIcon.tga",
swprare = "Interface\\Icons\\Trade_Archaeology_Fossil_SnailShell",
shrine = "Interface\\Icons\\inv_misc_statue_02",
glider = "Interface\\Icons\\inv_feather_04",
rocket = "Interface\\Icons\\ability_mount_rocketmount",
}
PlayerFaction, _ = UnitFactionGroup("player")
DraenorTreasures.nodes = { }
local nodes = DraenorTreasures.nodes

nodes["ShadowmoonValleyDR"] = {
--SMV Treasures
[55004500]={ "35581", "Alchemist's Satchel", "Herbs", "", "default", "SMVTreasures","109124"},
[52804840]={ "35584", "Ancestral Greataxe", "i519 2H Strength Axe", "Quest ID might be wrong - Treasure might stay active after looting", "default", "SMVTreasures","113560"},
[41502790]={ "33869", "Armored Elekk Tusk", "i518 Trinket Bonus Armor + Mastery on use", "", "default", "SMVTreasures","108902"},
[37704430]={ "33584", "Ashes of A'kumbo", "Consumable for Rested XP", "", "default", "SMVTreasures","113531"},
[49303750]={ "33867", "Astrologer's Box", "Toy", "", "default", "SMVTreasures","109739"},
[36804140]={ "33046", "Beloved's Offering", "Flavor Item - Offhand", "", "default", "SMVTreasures","113547"},
[37202310]={ "33613", "Bubbling Cauldron", "i516 Caster Offhand", "In a cave", "default", "SMVTreasures","108945"},
[84504470]={ "33885", "Cargo of the Raven Queen", "Garrison Resources", "", "default", "SMVTreasures","824"},
[33503970]={ "33569", "Carved Drinking Horn", "Reusable Mana Potion", "", "default", "SMVTreasures","113545"},
[61706790]={ "34743", "Crystal Blade of Torvath ", "Trash Item", "", "default", "SMVTreasures","111636"},
[20303060]={ "33575", "Demonic Cache", "i550 int neck", "", "default", "SMVTreasures","108904"},
[51803550]={ "33037", "False-Bottomed Jar", "Gold", "Often bugs out - Gold then gets delivered by Mail", "default", "SMVTreasures","824"},
[26500570]={ "34174", "Fantastic Fish", "Garrison Resources", "", "default", "SMVTreasures","824"},
[34404620]={ "33891", "Giant Moonwillow Cone", "i522 Wand", "", "default", "SMVTreasures","108901"},
[48704750]={ "35798", "Glowing Cave Mushroom", "Herbs", "", "default", "SMVTreasures","109130"},
[38504300]={ "33614", "Greka's Urn", "i528 Trinket Haste + Strength Proc", "", "default", "SMVTreasures","113408"},
[47104610]={ "33564", "Hanging Satchel", "i518 agi/int leather gloves", "", "default", "SMVTreasures","108900"},
[42106130]={ "33041", "Iron Horde Cargo Shipment", "Garrison Resources", "", "default", "SMVTreasures","824"},
[37505930]={ "33567", "Iron Horde Tribute", "Trinket Multistrike + DMG on use", "", "default", "SMVTreasures","108903"},
[57904530]={ "33568", "Kaliri Egg", "25 Garrison Resources", "", "default", "SMVTreasures","113271"},
[30301990]={ "35530", "Lunarfall Egg", "Garrison Resources", "Changes position to inside the garrison once it is built", "default", "SMVTreasures","824"},
[58902200]={ "35603", "Mikkal's Chest", "Trash Item", "mostly just for the XP", "default", "SMVTreasures","113215"},
[52902490]={ "37254", "Mushroom-Covered Chest", "25 Garrison Resources", "", "default", "SMVTreasures","113388"},
[66903350]={ "36507", "Orc Skeleton", "i526 Strength Ring", "", "default", "SMVTreasures","116875"},
[43806060]={ "33611", "Peaceful Offering 1", "Trash Items", "", "default", "SMVTreasures","107650"},
[45206050]={ "33610", "Peaceful Offering 2", "Trash Items", "", "default", "SMVTreasures","107650"},
[44506350]={ "33384", "Peaceful Offering 3", "Trash Items", "", "default", "SMVTreasures","107650"},
[44505920]={ "33612", "Peaceful Offering 4", "Trash Items", "", "default", "SMVTreasures","107650"},
[31303910]={ "33886", "Ronokk's Belongings", "i522 Strength Cloak", "", "default", "SMVTreasures","109081"},
[22803390]={ "33572", "Rotting Basket", "Trash Item", "", "default", "SMVTreasures","113373"},
[36704450]={ "33573", "Rovo's Dagger", "i520 Agility Dagger", "", "default", "SMVTreasures","113378"},
[67108430]={ "33565", "Scaly Rylak Egg", "Onetime Food without Buff", "mostly just for the XP", "default", "SMVTreasures","44722"},
[45802460]={ "33570", "Shadowmoon Exile Treasure", "25 Garrison Resources", "In a cave below Exile Rise", "default", "SMVTreasures","113388"},
[30004530]={ "35919", "Shadowmoon Sacrificial Dagger", "i524 Caster Dagger", "", "default", "SMVTreasures","113563"},
[28303930]={ "33571", "Shadowmoon Treasure", "Garrison Resources", "", "default", "SMVTreasures","824"},
[27100260]={ "35280", "Stolen Treasure", "Garrison Resources", "", "default", "SMVTreasures","824"},
[55801990]={ "35600", "Strange Spore", "Pet", "", "default", "SMVTreasures","118104"},
[37202610]={ "35677", "Sunken Fishing boat", "Flavor Items - Fish themed", "", "default", "SMVTreasures","110506"},
[28800710]={ "35279", "Sunken Treasure", "Garrison Resources", "", "default", "SMVTreasures","824"},
[55307480]={ "35580", "Swamplighter Hive", "Toy", "", "default", "SMVTreasures","117550"},
[35904090]={ "33540", "Uzko's Knickknacks", "i525 Agility/Intellect Leather Boots", "", "default", "SMVTreasures","113546"},
[34204350]={ "33866", "Veema's Herb Bag", "Herbs", "", "default", "SMVTreasures","109124"},
[51107910]={ "33574", "Vindicator's Cache", "Toy", "!!! LEVEL100 AREA !!!", "default", "SMVTreasures","113375"},
[39208380]={ "33566", "Waterlogged Chest  ", "i520 Strength Fist Weapon + Garrison Resources", "", "default", "SMVTreasures","113372"},
--SMVRares
[37203640]={ "33061", "Amaukwa", "i516 Agility/Intellect Mail Body", "", "rare", "SMVRares","109060"},
[50807880]={ "37356", "Aqualir", "i620 Intellect Ring", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119387"},
[68208480]={ "37410", "Avalanche", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "SMVHundred","823"},
[29600620]={ "35281", "Bahameye", "Fire Ammonite", "", "rare", "SMVRares","111666"},
[52801680]={ "35731", "Ba'ruun", "Reusable Food without Buff", "", "rare", "SMVRares","113540"},
[43807740]={ "33383", "Brambleking Fili", "i620 Agility Staff", "!!! Level 100 !!!", "hundredrare", "SMVHundred","117551"},
[48604360]={ "33064", "Dark Emanation", "i516 Intellect Fistweapon (without Spellpower)", "the missing Spellpower is most likely a bug", "rare", "SMVRares","109075"},
[41008300]={ "35448", "Darkmaster Go'vid", "i525 Intellect Staff + Lobstrok Summon", "", "rare", "SMVRares","113548"},
[49604200]={ "35555", "Darktalon", "i520 Agility Cloak", "", "rare", "SMVRares","113541"},
[46007160]={ "37351", "Demidos", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "SMVHundred","823"},
[67806380]={ "35688", "Enavra", "i523 Intellect Neck", "", "rare", "SMVRares","113556"},
[61606180]={ "35725", "Faebright", "i526 Agility/Intellect Leather Pants", "", "rare", "SMVRares","113557"},
[29603380]={ "33664", "Gorum", "i516 Agility/Intellect Ring", "", "rare", "SMVRares","113082"},
[37404880]={ "35558", "Hypnocroak", "Toy", "", "rare", "SMVRares","113631"},
[57404840]={ "35909", "Insha'tar", "i520 Agility/Intellect Mail Boots", "", "rare", "SMVRares","113571"},
[40804440]={ "33043", "Killmaw", "i516 Agility Dagger", "", "rare", "SMVRares","109078"},
[32203500]={ "33039", "Ku'targ the Voidseer", "i516 Agility/Intellect Mail Gloves", "", "rare", "SMVRares","109061"},
[48007760]={ "37355", "Lady Temptessa", "i620 Agility/Intellect Leather Boots", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119360"},
[37601460]={ "33055", "Leaf-Reader Kurri", "i518 Trinket Versatility + Heal Proc", "", "rare", "SMVRares","108907"},
[44802080]={ "35906", "Mad King Sporeon ", "i519 Agility Staff", "", "rare", "SMVRares","113561"},
[29605080]={ "37357", "Malgosh Shadowkeeper", "i620 Agility/Intellect Mail Helm", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119369"},
[51807920]={ "37353", "Master Sergeant Milgra", "i620 Agility/Intellect Mail Gloves", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119368"},
[38607020]={ "35523", "Morva Soultwister", "i520 1H Caster Mace", "", "rare", "SMVRares","113559"},
[44005760]={ "33642", "Mother Om'ra", "i522 Trinket Int + Mastery Proc", "", "rare", "SMVRares","113527"},
[58408680]={ "37409", "Nagidna", "unknown", "!!! Level 100 !!! In a Cave - Entrance is at 59,89", "hundredrare", "SMVHundred",""},
[50207240]={ "37352", "Quartermaster Hershak", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "SMVHundred","823"},
[48602260]={ "35553", "Rai'vosh", "Reusable Slowfall Item", "", "rare", "SMVRares","113542"},
[53005060]={ "34068", "Rockhoof", "i516 Strength Shield", "", "rare", "SMVRares","109077"},
[48208100]={ "37354", "Shadowspeaker Niir", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "SMVHundred","823"},
[61005520]={ "35732", "Shinri", "400% Ground Mount with Cooldown", "", "rare", "SMVRares","113543"},
[61408880]={ "37411", "Slivermaw", "i620 Strength 2H Sword", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119411"},
[27604360]={ "36880", "Sneevel", "i519 Cloth Pants", "", "rare", "SMVRares","118734"},
[21602100]={ "33640", "Veloss", "i516 Intellect Ring", "", "rare", "SMVRares","108906"},
[54607060]={ "33643", "Venomshade", "i516 Agility/Intellect Leather Boots", "", "rare", "SMVRares","108957"},
[31905720]={ "37359", "Voidreaver Urnae", "i620 Agility 1H Axe", "!!! Level 100 !!!", "hundredrare", "SMVHundred","119392"},
[32604140]={ "35847", "Voidseer Kalurg", "i516 Cloth Waist", "", "rare", "SMVRares","109074"},
[42804100]={ "33038", "Windfang Matriarch", "i516 Agility/Strength 1H Sword", "Is part of the Embaari Crystal Defense Event", "rare", "SMVRares","113553"},
[48806640]={ "33389", "Yggdrel", "Toy", "", "rare", "SMVRares","113570"},
}
nodes["FrostfireRidge"] = {
--FFRTreasures
[23102500]={ "33916", "Arena Master's War Horn", "Toy", "", "default", "FFRTreasures","108735"},
[42401970]={ "34520", "Burning Pearl", "i525 Trinket Multistrike + Mastery Proc", "", "default", "FFRTreasures","120341"},
[42703170]={ "33940", "Crag-Leaper's Cache", "i516 Agility/Intellect Mail Boots", "", "default", "FFRTreasures","112187"},
[40902010]={ "34473", "Envoy's Satchel", "Trash Item", "", "default", "FFRTreasures","110536"},
[43705550]={ "34841", "Forgotten Supplies", "Garrison Resources", "", "default", "FFRTreasures","824"},
[24204860]={ "34507", "Frozen Frostwolf Axe", "i516 Spellpower Axe", "", "default", "FFRTreasures","110689"},
[57105210]={ "34476", "Frozen Orc Skeleton ", "i516 Trinket Mastery + Pet Proc", "", "default", "FFRTreasures","111554"},
[51002280]={ "34521", "Glowing Obsidian Shard", "Garrison Resources", "", "default", "FFRTreasures","824"},
[25502040]={ "34648", "Gnawed Bone", "i516 Agility Dagger", "", "default", "FFRTreasures","111415"},
[66702640]={ "33948", "Goren Leftovers", "25 Garrison Resources", "", "default", "FFRTreasures","111543"},
[68204580]={ "33947", "Grimfrost Treasure", "Garrison Resources", "", "default", "FFRTreasures","824"},
[56707180]={ "36863", "Iron Horde Munitions", "Garrison Resources", "", "default", "FFRTreasures","824"},
[69006910]={ "33017", "Iron Horde Supplies", "Garrison Resources", "", "default", "FFRTreasures","824"},
[74505620]={ "34937", "Lady Sena's Other Materials Stash", "Garrison Resources", "", "default", "FFRTreasures","824"},
[21900960]={ "33926", "Lagoon Pool", "Toy", "", "default", "FFRTreasures","108739"},
[19201200]={ "34642", "Lucky Coin", "Flavor Item - Gold Coin", "Sells for 25g", "default", "FFRTreasures","111408"},
[38403780]={ "33502", "Obsidian Petroglyph", "Obsidian Frostwolf Petroglyph", "might be a profession skillbonus", "default", "FFRTreasures","112087"},
[21605070]={ "34931", "Pale Loot Sack", "Garrison Resources", "", "default", "FFRTreasures","824"},
[37205920]={ "34967", "Raided Loot", "Garrison Resources", "", "default", "FFRTreasures","824"},
[09804540]={ "34641", "Sealed Jug", "Flavor Item - Lore", "", "default", "FFRTreasures","111407"},
[27604280]={ "33500", "Slave's Stash", "Alcoholic Beverages", "", "default", "FFRTreasures","43696"},
[24001300]={ "34647", "Snow-Covered Strongbox", "Garrison Resources", "", "default", "FFRTreasures","824"},
[24202720]={ "33501", "Spectator's Chest", "Alcoholic Beverages", "", "default", "FFRTreasures","63293"},
[16104980]={ "33942", "Supply Dump", "Garrison Resources", "", "default", "FFRTreasures","824"},
[64702570]={ "33946", "Survivalist's Cache", "Garrison Resources", "", "default", "FFRTreasures","824"},
[34202350]={ "32803", "Thunderlord Cache", "Garrison Resources", "", "default", "FFRTreasures","824"},
[64406580]={ "33505", "Wiggling Egg", "Pet", "", "default", "FFRTreasures","112107"},
[63401480]={ "33525", "Young Orc Woman", "unknown", "", "default", "FFRTreasures","112206"},
--FFRRares
[88605740]={ "37525", "Ak'ox the Slaughterer", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[27405000]={ "34497", "Breathless", "Toy", "", "rare", "FFRRares","111476"},
[66403140]={ "33843", "Broodmother Reeg'ak", "i516 Trinket Intellect + Multistrike Proc", "", "rare", "FFRRares","111533"},
[34002320]={ "32941", "Canyon Icemother", "25 Garrison Resources", "", "rare", "FFRRares","101436"},
[41206820]={ "34843", "Chillfang", "i513 Agility/Intellect Leather Pants", "", "rare", "FFRRares","111953"},
[40404700]={ "33014", "Cindermaw", "i516 Caster Dagger", "", "rare", "FFRRares","111490"},
[50201860]={ "33531", "Clumsy Cragmaul Brute", "unknown", "", "rare", "FFRRares",""},
[25405500]={ "34129", "Coldstomp the Griever", "i516 Intellect Neck", "", "rare", "FFRRares","112066"},
[54606940]={ "34131", "Coldtusk", "i516 Agility/Strength 1H Sword", "", "rare", "FFRRares","111484"},
[67407820]={ "34477", "Cyclonic Fury", "i516 Cloth Shoulders", "", "rare", "FFRRares","112086"},
[86605180]={ "37403", "Earthshaker Holar", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[71404680]={ "33504", "Firefury Giant", "i516 Offhand", "", "rare", "FFRRares","107661"},
[54602220]={ "32918", "Giant-Slayer Kul", "i516 Trinket Versatility + Agility Proc", "", "rare", "FFRRares","111530"},
[72203600]={ "37380", "Gibblette the Cowardly", "unknown", "!!! Level 100 !!! If he isn't killed fast enough he just flees and despawns", "hundredrare", "FFRHundred",""},
[72203000]={ "xxx", "Gomtar the Agile", "unknown", "!!! Level 100 !!! Quest ID is missing - Rare will stay active after the kill", "hundredrare", "FFRHundred",""},
[70003600]={ "37562", "Gorg'ak the Lava Guzzler", "i620 Strength Fistweapon", "!!! Level 100 !!!", "hundredrare", "FFRHundred","111545"},
[38606300]={ "34865", "Grutush the Pillager", "i513 Agility/Intellect Mail Pants", "", "rare", "FFRRares","112077"},
[51806480]={ "34825", "Gruuk", "i513 Trinket Haste + Critical Strike", "", "rare", "FFRRares","111948"},
[47005520]={ "34839", "Gurun", "i513 Strength Cloak", "", "rare", "FFRRares","111955"},
[68801940]={ "37382", "Hoarfrost", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[58603420]={ "34130", "Huntmaster Kuang", "Garrison Resources", "", "rare", "FFRRares","824"},
[48202340]={ "37386", "Jabberjaw", "i620 Caster Shield", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119390"},
[85005220]={ "37556", "Jaluk the Pacifist", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[61602640]={ "34708", "Jehil the Climber", "i516 Agility/Intellect Leather Boots", "", "rare", "FFRRares","112078"},
[87004640]={ "37404", "Kaga the Ironbender", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[43002100]={ "37387", "Moltnoma", "i620 Cloth Shoulders", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119356"},
[70002700]={ "37381", "Mother of Goren", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[83604720]={ "37402", "Ogom the Mangler", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[28206620]={ "34470", "Pale Fishmonger", "Fish", "", "rare", "FFRRares","111666"},
[36803400]={ "33938", "Primalist Mur'og", "i516 Cloth Pants", "", "rare", "FFRRares","111576"},
[86604880]={ "37401", "Ragore Driftstalker", "i620 Agility/Intellect Leather Chest", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119359"},
[76406340]={ "34132", "Scout Goreseeker", "i516 Agility/Intellect Leather Body", "", "rare", "FFRRares","112094"},
[45001500]={ "37385", "Slogtusk the Corpse-Eater", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[38201600]={ "37383", "Son of Goramal", "i620 Caster Mace", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119399"},
[84404880]={ "xxx", "Taskmaster Kullah", "unknown", "!!! Level 100 !!! Quest ID is missing - Rare will stay active after the kill", "hundredrare", "FFRHundred",""},
[26803160]={ "34133", "The Beater", "i516 Strength 2H Mace", "", "rare", "FFRRares","111475"},
[72203300]={ "37361", "The Bone Crawler", "i620 Intellect/Strength Plate Chest", "!!! Level 100 !!!", "hundredrare", "FFRHundred","111534"},
[43600940]={ "37384", "Tor'goroth", "i620 Offhand", "!!! Level 100 !!!", "hundredrare", "FFRHundred","119379"},
[40601240]={ "34522", "Ug'lok the Frozen", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[72402420]={ "37378", "Valkor", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[70603900]={ "37379", "Vrok the Ancient", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "FFRHundred","823"},
[40402780]={ "34559", "Yaga the Scarred", "i516 Agility/Intellect Leather Waist", "", "rare", "FFRRares","111477"},
}
nodes["Gorgrond"] = {
--GorgrondTreasures
[41705300]={ "36506", "Brokor's Sack", "i538 Caster Staff (without Spellpower)", "the missing Spellpower is most likely a bug", "default", "GorgrondTreasures","118702"},
[42408340]={ "36625", "Discarded Pack", "Gold + Random Green", "", "default", "GorgrondTreasures",""},
[41807810]={ "36658", "Evermorn Supply Cache", "Random Green", "", "default", "GorgrondTreasures",""},
[40407660]={ "36621", "Explorer Canister", "50 Garrison Resources", "", "default", "GorgrondTreasures","118710"},
[40007230]={ "36170", "Femur of Improbability", "Trash Item", "", "default", "GorgrondTreasures","118715"},
[46105000]={ "36651", "Harvestable Precious Crystal", "Garrison Resources", "", "default", "GorgrondTreasures","824"},
[42604680]={ "35056", "Horned Skull", "Garrison Resources", "", "default", "GorgrondTreasures","824"},
[43704240]={ "36618", "Iron Supply Chest", "Garrison Resources", "", "default", "GorgrondTreasures","824"},
[44207420]={ "35709", "Laughing Skull Cache", "Garrison Resources", "", "default", "GorgrondTreasures","824"},
[43109290]={ "34241", "Ockbar's Pack", "Trash Item", "", "default", "GorgrondTreasures","118227"},
[52506690]={ "36509", "Odd Skull", "i535 Offhand", "", "default", "GorgrondTreasures","118717"},
[46204290]={ "36521", "Petrified Rylak Egg", "Trash Item", "", "default", "GorgrondTreasures","118707"},
[43606980]={ "36118", "Pile of Rubble", "Random Green", "", "default", "GorgrondTreasures",""},
[53107440]={ "36654", "Remains of Balik Orecrusher", "Trash Item", "", "default", "GorgrondTreasures","118714"},
[57805600]={ "36605", "Remains of Balldir Deeprock", "Trash Item", "", "default", "GorgrondTreasures","118703"},
[39006810]={ "36631", "Sasha's Secret Stash", "Gold + Random Green", "", "default", "GorgrondTreasures",""},
[45004260]={ "36634", "Sniper's Crossbow", "i539 Crossbow", "", "default", "GorgrondTreasures","118713"},
[48109340]={ "36604", "Stashed Emergency Rucksack", "Gold + Random Green", "", "default", "GorgrondTreasures",""},
[53008000]={ "34940", "Strange Looking Dagger", "i537 Agility Dagger", "", "default", "GorgrondTreasures","118718"},
[71906660]={ "xxx", "Sunken Treasure", "Garrison Resources", "Quest ID is missing - Treasure will stay active after looting", "default", "GorgrondTreasures","824"},
[45704970]={ "36610", "Suntouched Spear", "Trash Item", "", "default", "GorgrondTreasures","118708"},
[59406370]={ "36628", "Vindicator's Hammer", "i539 Strength 2H Mace", "", "default", "GorgrondTreasures","118712"},
[48904730]={ "36203", "Warm Goren Egg", "Egg which hatches into a Toy after 7 days", "", "default", "GorgrondTreasures","118705"},
[49304360]={ "36596", "Weapons Cache", "100 Garrison Resources", "", "default", "GorgrondTreasures","107645"},
--GorgrondRares
[58604120]={ "37371", "Alkali", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","823"},
[40007900]={ "35335", "Bashiok", "Toy", "", "rare", "GorgrondRares","118222"},
[69204460]={ "37369", "Basten, Nultra or Valstil", "Toy", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119432"},
[46003360]={ "37368", "Blademaster Ro'gor", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
[53404460]={ "35503", "Char the Burning", "i536 2H Caster Mace", "", "rare", "GorgrondRares","118212"},
[48202100]={ "37362", "Defector Dazgo", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
[57603580]={ "37370", "Depthroot", "i620 Agility Polearm", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119406"},
[50002380]={ "37366", "Durp the Hated", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
[72803580]={ "37373", "Firestarter Grash", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
[57406860]={ "36387", "Fossilwood the Petrified", "Toy", "", "rare", "GorgrondRares","118221"},
[41804540]={ "36391", "Gelgor of the Blue Flame", "i534 Trinket Versatility + Intellect Proc", "", "rare", "GorgrondRares","118230"},
[46205080]={ "36204", "Glut", "i534 Trinket Agility + Multistrike Proc", "", "rare", "GorgrondRares","118229"},
[52805360]={ "37413", "Gnarljaw", "i620 Intellect Fistweapon with Spellhit", "!!! Level 100 !!! The Spellhit is most likely supposed to be Spellpower", "hundredrare", "GorgrondHundred","119397"},
[46804320]={ "36186", "Greldrok the Cunning", "i534 Strength 1H Mace", "", "rare", "GorgrondRares","118210"},
[59604300]={ "37375", "Grove Warden Yal", "i620 Intellect Cloak", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119414"},
[52207020]={ "35908", "Hive Queen Skrikka", "i534 Spellpower Axe", "", "rare", "GorgrondRares","118209"},
[47002380]={ "37365", "Horgg", "i620 Agility/Intellect Mail Body", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119229"},
[55004660]={ "37377", "Hunter Bal'ra", "i620 Bow", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119412"},
[47603060]={ "37367", "Inventor Blammo", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
[50605320]={ "36178", "Mandrakor", "Pet", "", "rare", "GorgrondRares","118709"},
[49003380]={ "37363", "Maniacal Madgard", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
[61803930]={ "37376", "Mogamago", "i620 Strength Shield", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119391"},
[47002580]={ "37364", "Morgo Kain", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
[53407820]={ "34726", "Mother Araneae", "i534 Agility Dagger", "", "rare", "GorgrondRares","118208"},
[37608140]={ "36600", "Riptar", "i539 Caster Dagger", "", "rare", "GorgrondRares","118231"},
[47804140]={ "36393", "Rolkor", "i539 Trinket Strength + Critical Strike Proc", "", "rare", "GorgrondRares","118211"},
[54207240]={ "36837", "Stompalupagus", "i537 2H Agility/Strength Mace", "", "rare", "GorgrondRares","118228"},
[38206620]={ "35910", "Stomper Kreego", "Ogre Brewing Kit", "Can create Alcoholic Beverages every 7 days", "rare", "GorgrondRares","118224"},
[40205960]={ "36394", "Sulfurious", "Toy", "", "rare", "GorgrondRares","114227"},
[44609220]={ "36656", "Sunclaw", "i533 Agility Fistweapon", "", "rare", "GorgrondRares","118223"},
[70803400]={ "37374", "Swift Onyx Flayer", "i620 Agility/Intellect Mail Boots", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred","119367"},
[64006180]={ "36794", "Sylldross", "i540 Agility/Intellect Leather Boots", "", "rare", "GorgrondRares","118213"},
[76004200]={ "37405", "Typhon", "Apexis Crystals", "", "rare", "GorgrondRares","823"},
[63803160]={ "37372", "Venolasix", "unknown", "!!! Level 100 !!!", "hundredrare", "GorgrondHundred",""},
}
if (PlayerFaction == "Alliance") then
nodes["Gorgrond"][60805400]={ "36502", "Biolante", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","116159"}
nodes["Gorgrond"][46004680]={ "35816", "Charl Doomwing", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113457"}
nodes["Gorgrond"][42805920]={ "35812", "Crater Lord Igneous", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113449"}
nodes["Gorgrond"][40505100]={ "35809", "Dessicus of the Dead Pools", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113446"}
nodes["Gorgrond"][51804160]={ "35808", "Erosian the Violent", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113445"}
nodes["Gorgrond"][58006360]={ "35813", "Fungal Praetorian", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113453"}
nodes["Gorgrond"][52406580]={ "35820", "Khargax the Devourer", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113461"}
nodes["Gorgrond"][51206360]={ "35817", "Roardan the Sky Terror", "Quest Item for XP", "Flies around a lot, Coordinates are just somewhere on his route!You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113458"}
end
if (PlayerFaction == "Horde") then
nodes["Gorgrond"][60805400]={ "36503", "Biolante", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","116160"}
nodes["Gorgrond"][46004680]={ "35815", "Charl Doomwing", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113456"}
nodes["Gorgrond"][42805920]={ "35811", "Crater Lord Igneous", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113448"}
nodes["Gorgrond"][40505100]={ "35810", "Dessicus of the Dead Pools", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113447"}
nodes["Gorgrond"][51804160]={ "35807", "Erosian the Violent", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113444"}
nodes["Gorgrond"][58006360]={ "35814", "Fungal Praetorian", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113454"}
nodes["Gorgrond"][52406580]={ "35819", "Khargax the Devourer", "Quest Item for XP", "You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113460"}
nodes["Gorgrond"][51206360]={ "35818", "Roardan the Sky Terror", "Quest Item for XP", "Flies around a lot, Coordinates are just somewhere on his route!You must finish the quest before this element gets removed from the map", "rare", "GorgrondRares","113459"}
end
nodes["Talador"] = {
--TaladorTreasures
[36509610]={ "34182", "Aarko's Family Treasure", "i557 Crossbow", "", "default", "TaladorTreasures","117567"},
[62003240]={ "34236", "Amethyl Crystal", "100 Garrison Resources", "", "default", "TaladorTreasures","116131"},
[81803500]={ "34260", "Aruuna Mining Cart", "Ores", "", "default", "TaladorTreasures","109118"},
[62404800]={ "34252", "Barrel of Fish", "Fish", "", "default", "TaladorTreasures","110506"},
[33307670]={ "34259", "Bonechewer Remnants", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[37607490]={ "xxx", "Bonechewer Spear", "i566 Agility/Intellect Mail Gloves", "Quest ID is missing - Treasure will stay active after looting", "default", "TaladorTreasures","112371"},
[73505140]={ "34471", "Bright Coin", "i560 Trinket Versatility + Bonus Armor proc", "", "default", "TaladorTreasures","116127"},
[70100700]={ "36937", "Burning Blade Cache", "Apexis Crystal", "", "default", "TaladorTreasures","823"},
[77005000]={ "34248", "Charred Sword", "i563 2H Strength Sword", "", "default", "TaladorTreasures","116116"},
[66608690]={ "34239", "Curious Deathweb Egg", "Toy", "", "default", "TaladorTreasures","117569"},
[58901200]={ "33933", "Deceptia's Smoldering Boots", "Toy", "", "default", "TaladorTreasures","108743"},
[55206680]={ "34253", "Draenei Weapons", "100 Garrison Resources", "", "default", "TaladorTreasures","116118"},
[35509660]={ "34249", "Farmer's Bounty", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[57402670]={ "34238", "Foreman's Lunchbox", "Reusable Food/Drink", "", "default", "TaladorTreasures","116120"},
[64607920]={ "34251", "Iron Box", "i554 1H Strength Mace", "", "default", "TaladorTreasures","117571"},
[75003600]={ "33649", "Iron Scout", "unknown", "", "default", "TaladorTreasures",""},
[65501130]={ "34233", "Jug of Aged Ironwine", "Alcoholic Beverages", "", "default", "TaladorTreasures","117568"},
[75704140]={ "34261", "Keluu's Belongings  ", "Gold", "", "default", "TaladorTreasures",""},
[54002760]={ "34290", "Ketya's Stash", "Pet", "", "default", "TaladorTreasures","116402"},
[38201250]={ "34258", "Light of the Sea", "Garrison Resources", "", "default", "TaladorTreasures","824"},
[69905610]={ "34101", "Lightbearer", "Trash Item", "", "default", "TaladorTreasures","109192"},
[52502950]={ "34235", "Luminous Shell", "i557 Intellect Neck", "", "default", "TaladorTreasures","116132"},
[61107170]={ "34116", "Norana's Cache", "unknown", "", "default", "TaladorTreasures",""},
[78201480]={ "34263", "Pure Crystal Dust", "i554 Agility Ring", "", "default", "TaladorTreasures","117572"},
[75804480]={ "34250", "Relic of Aruuna", "Trash Item", "", "default", "TaladorTreasures","116128"},
[47009170]={ "34256", "Relic of Telmor", "Trash Item", "", "default", "TaladorTreasures","116128"},
[64901330]={ "34232", "Rook's Tacklebox", "+4 Fishing Line", "", "default", "TaladorTreasures","116117"},
[65908520]={ "34276", "Rusted Lockbox", "Random Green", "", "default", "TaladorTreasures",""},
[39505520]={ "34254", "Soulbinder's Reliquary", "i558 Intellect Ring", "", "default", "TaladorTreasures","117570"},
[74602930]={ "35162", "Teroclaw Nest 1", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[39307770]={ "35162", "Teroclaw Nest 10", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[73503070]={ "35162", "Teroclaw Nest 2", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[74303400]={ "35162", "Teroclaw Nest 3", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[72803560]={ "35162", "Teroclaw Nest 4", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[72403700]={ "35162", "Teroclaw Nest 5", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[70903550]={ "35162", "Teroclaw Nest 6", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[70803200]={ "35162", "Teroclaw Nest 7", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[54105630]={ "35162", "Teroclaw Nest 8", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[39807670]={ "35162", "Teroclaw Nest 9", "Pet", "Only one Teroclaw Nest can be looted", "default", "TaladorTreasures","112699"},
[38408450]={ "34257", "Treasure of Ango'rosh", "Flavor Item - Throwing Rock", "", "default", "TaladorTreasures","116119"},
[65508860]={ "34255", "Webbed Sac", "Gold", "", "default", "TaladorTreasures",""},
[40608950]={ "34140", "Yuuri's Gift", "Garrison Resources", "", "default", "TaladorTreasures","824"},
--TaladorRares
[46603520]={ "37338", "Avatar of Socrethar", "i620 Offhand", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119378"},
[44003800]={ "37339", "Bombardier Gu'gok", "i620 Crossbow", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119413"},
[37607040]={ "34165", "Cro Fleshrender", "i558 Strength 1H Mace", "", "rare", "TaladorRares","116123"},
[68201580]={ "34142", "Dr. Gloom", "Flavor Item - Stink Bombs", "", "rare", "TaladorRares","112499"},
[34205700]={ "34221", "Echo of Murmur", "Toy", "", "rare", "TaladorRares","113670"},
[50808380]={ "35018", "Felbark", "i554 Caster Shield", "", "rare", "TaladorRares","112373"},
[50203520]={ "37341", "Felfire Consort", "i620 Agility Ring", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119386"},
[46005500]={ "34145", "Frenzied Golem", "i563 Agility/Strength 1H Sword or i563 Caster Dagger", "", "rare", "TaladorRares","113287"},
[67408060]={ "34929", "Gennadian", "i558 Trinket Agility + Mastery Proc", "", "rare", "TaladorRares","116075"},
[31806380]={ "34189", "Glimmerwing", "Shorttime Speedbuff with limited charges", "", "rare", "TaladorRares","116113"},
[22207400]={ "36919", "Grrbrrgle", "unknown", "Restless Crate", "rare", "TaladorRares",""},
[47603900]={ "37340", "Gug'tol", "i620 Caster Sword", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119402"},
[48002500]={ "37312", "Haakun the All-Consuming", "i620 Strength 1H Sword", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119403"},
[62004600]={ "34185", "Hammertooth", "i558 Agility/Intellect Mail Body", "", "rare", "TaladorRares","116124"},
[78005040]={ "34167", "Hen-Mother Hami", "i556 Intellect Cloak", "", "rare", "TaladorRares","112369"},
[57207540]={ "34134", "Isaari", "i564 Agility Neck", "", "rare", "TaladorRares","117563"},
[56606360]={ "35219", "Kharazos the Triumphant/Galzomar/Sikthiss", "Toy", "One of them - loot once", "rare", "TaladorRares","116122"},
[66808540]={ "34498", "Klikixx", "Toy", "", "rare", "TaladorRares","116125"},
[37203760]={ "37348", "Kurlosh Doomfang", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","823"},
[33803780]={ "37346", "Lady Demlash", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","823"},
[37802140]={ "37342", "Legion Vanguard", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","823"},
[49009200]={ "34208", "Lo'marg Jawcrusher", "i558 Strength Neck", "", "rare", "TaladorRares","116070"},
[30502640]={ "37345", "Lord Korinak", "i620 Strength Ring", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119388"},
[39004960]={ "37349", "Matron of Sin", "i620 Cloth Gloves", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119353"},
[86403040]={ "34859", "No'losh", "i558 Trinket Versatility + Int Proc", "", "rare", "TaladorRares","116077"},
[31404750]={ "37344", "Orumo the Observer", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","823"},
[59505960]={ "34196", "Ra'kahn", "i563 Agility Fistweapon", "", "rare", "TaladorRares","116112"},
[41004200]={ "37347", "Shadowflame Terrorwalker", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","823"},
[41805940]={ "34671", "Shirzir", "i554 Agility/Intellect Leather Boots", "", "rare", "TaladorRares","112370"},
[67703550]={ "36858", "Steeltusk", "i559 Agility Polearm", "", "rare", "TaladorRares","117562"},
[46002740]={ "37337", "Strategist Ankor, Archmagus Tekar, Soulbinder Naylana", "Apexis Crystals", "!!! Level 100 !!! One of them - loot once", "hundredrare", "TaladorHundred","823"},
[59008800]={ "34171", "Taladorantula", "i565 Agility Sword", "", "rare", "TaladorRares","116126"},
[53909100]={ "34668", "Talonpriest Zorkra", "i560 Cloth Helm", "", "rare", "TaladorRares","116110"},
[63802070]={ "34945", "Underseer Bloodmane", "i554 Strength Ring", "don't kill his Pet", "rare", "TaladorRares","112475"},
[36804100]={ "37350", "Vigilant Paarthos", "i620 Intellect/Strength Plate Shoulders", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119383"},
[69603340]={ "34205", "Wandering Vindicator", "i554 Strength 1H Sword", "", "rare", "TaladorRares","112261"},
[38001460]={ "37343", "Xothear the Destroyer", "i620 Agility/Intellect Mail Shoulders", "!!! Level 100 !!!", "hundredrare", "TaladorHundred","119371"},
[53802580]={ "34135", "Yazheera the Incinerator", "i554 Agility/Intellect Mail Bracer", "", "rare", "TaladorRares","112263"},
}
nodes["SpiresOfArak"] = {
--SoATreasures
[40605500]={ "36458", "Abandoned Mining Pick", "i578 Strength 1H Axe", "Allows faster Mining in Draenor", "default", "SoATreasures","116913"},
[37705640]={ "36462", "An Old Key", "Key for a Chest in Admiral Taylors Garrison", "", "default", "SoATreasures","116020"},
[49203730]={ "36445", "Assassin's Spear", "i580 Agility Polearm", "", "default", "SoATreasures","116835"},
[55509080]={ "36366", "Campaign Contributions", "Gold", "", "default", "SoATreasures",""},
[68408900]={ "36453", "Coinbender's Payment", "Garrison Resources", "", "default", "SoATreasures","824"},
[43901500]={ "36395", "Elixir of Shadow Sight 1", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu)", "default", "SoATreasures","115463"},
[43802470]={ "36397", "Elixir of Shadow Sight 2", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu)", "default", "SoATreasures","115463"},
[69204330]={ "36398", "Elixir of Shadow Sight 3", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu)", "default", "SoATreasures","115463"},
[48906250]={ "36399", "Elixir of Shadow Sight 4", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu)", "default", "SoATreasures","115463"},
[55602200]={ "36400", "Elixir of Shadow Sight 5", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu)", "default", "SoATreasures","115463"},
[53108450]={ "xxx", "Elixir of Shadow Sight 6", "Elixir of Shadow Sight", "Elixir can be used at Shrine of Terrok for 1 of 6 i585 Weapons (see Gift of Anzu) QuestID is missing, will stay active after looting", "default", "SoATreasures","115463"},
[36505790]={ "36418", "Ephial's Dark Grimoire", "i579 Offhand", "", "default", "SoATreasures","116914"},
[50502210]={ "36401", "Fractured Sunstone", "Trash Item", "", "default", "SoATreasures","116919"},
[37204740]={ "36420", "Garrison Supplies", "Garrison Resources", "", "default", "SoATreasures","824"},
[41805050]={ "36451", "Garrison Workman's Hammer", "i580 Strength 1H Mace", "", "default", "SoATreasures","116918"},
[48604450]={ "36386", "Gift of Anzu", "i585 Crossbow", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118237"},
[57007900]={ "36390", "Gift of Anzu", "i585 Caster 1H Sword", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118241"},
[46904050]={ "36389", "Gift of Anzu", "i585 Agility/Strength Polearm", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118238"},
[52001960]={ "36392", "Gift of Anzu", "i585 Caster Staff", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118239"},
[42402670]={ "36388", "Gift of Anzu", "i585 Wand", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118242"},
[61105550]={ "36381", "Gift of Anzu", "i585 Agility/Strength 1H Sword", "Drink an Elixir of Shadow Sight near the Shrine to get the Gift of Anzu", "default", "SoATreasures","118240"},
[50402580]={ "36444", "Iron Horde Explosives", "Trash Item", "", "default", "SoATreasures","118691"},
[50702880]={ "36247", "Lost Herb Satchel", "Herbs", "", "default", "SoATreasures","109124"},
[47803610]={ "36411", "Lost Ring", "i578 Intellect Ring", "", "default", "SoATreasures","116911"},
[52404280]={ "36416", "Misplaced Scroll", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[42701830]={ "36244", "Misplaced Scrolls", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[63606740]={ "36454", "Mysterious Mushrooms", "Chameleon Lotus", "", "default", "SoATreasures","109130"},
[53305560]={ "36403", "Offering to the Raven Mother 1", "Consumeable for 5% rested XP", "", "default", "SoATreasures","118267"},
[48305260]={ "36405", "Offering to the Raven Mother 2", "Consumeable for 5% rested XP", "", "default", "SoATreasures","118267"},
[48905470]={ "36406", "Offering to the Raven Mother 3", "Consumeable for 5% rested XP", "", "default", "SoATreasures","118267"},
[51906460]={ "36407", "Offering to the Raven Mother 4", "Consumeable for 5% rested XP", "", "default", "SoATreasures","118267"},
[61006380]={ "36410", "Offering to the Raven Mother 5", "Consumeable for 5% rested XP", "", "default", "SoATreasures","118267"},
[58706030]={ "36340", "Ogron Plunder", "Trash Items", "", "default", "SoATreasures","116921"},
[36303940]={ "36402", "Orcish Signaling Horn", "i577 Trinket Multistrike + Strength Proc", "", "default", "SoATreasures","120337"},
[36801720]={ "36243", "Outcast's Belongings 1", "Gold + Random Green", "", "default", "SoATreasures",""},
[42102170]={ "36447", "Outcast's Belongings 2", "Gold + Random Green", "", "default", "SoATreasures",""},
[46903400]={ "36446", "Outcast's Pouch", "Gold + Random Green", "", "default", "SoATreasures",""},
[43001640]={ "36245", "Relics of the Outcasts 1", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[46004410]={ "36354", "Relics of the Outcasts 2", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[43202720]={ "36355", "Relics of the Outcasts 3", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[67403980]={ "36356", "Relics of the Outcasts 4", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[60205390]={ "36359", "Relics of the Outcasts 5", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[51904890]={ "36360", "Relics of the Outcasts 6", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[37305070]={ "36657", "Rooby's Roo", "i581 Strength Neck", "You need to feed the dog with Rooby Reat from the chef in the cellar", "default", "SoATreasures","116887"},
[44401200]={ "36377", "Rukhmar's Image", "Trash Item", "", "default", "SoATreasures","118693"},
[59109060]={ "xxx", "Sailor Zazzuk's 180-Proof Rum  ", "Alcoholic Beverages", "QuestID is missing, will stay active after looting", "default", "SoATreasures","116917"},
[68203880]={ "36375", "Sethekk Idol", "Trash Item", "", "default", "SoATreasures","118692"},
[71604850]={ "36450", "Sethekk Ritual Brew", "Healing Potions + Alcoholic Beverages", "", "default", "SoATreasures","109223"},
[56202880]={ "36362", "Shattered Hand Cache", "Garrison Resources", "", "default", "SoATreasures","824"},
[47903070]={ "36361", "Shattered Hand Lockbox", "True Steel Lockbox", "", "default", "SoATreasures","116920"},
[60908460]={ "36456", "Shredder Parts", "Garrison Resources", "", "default", "SoATreasures","824"},
[56304530]={ "36433", "Smuggled Apexis Artifacts", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[59708130]={ "36365", "Spray-O-Matic 5000 XT", "Garrison Resources", "", "default", "SoATreasures","824"},
[34102750]={ "36421", "Sun-Touched Cache 1", "Garrison Resources", "", "default", "SoATreasures","824"},
[33302730]={ "36422", "Sun-Touched Cache 2", "Archaeology Fragments", "Requires Archaeology and possibly a little bit of jumping", "default", "SoATreasures",""},
[54403240]={ "36364", "Toxicfang Venom", "100 Garrison Resources", "", "default", "SoATreasures","118695"},
[66505650]={ "36455", "Waterlogged Satchel", "Gold + Random Green", "", "default", "SoATreasures",""},
--SoARares
[58208460]={ "36291", "Betsi Boombasket", "i583 Gun", "", "rare", "SoARares","116907"},
[46802300]={ "35599", "Blade-Dancer Aeryx", "Trash Item", "", "rare", "SoARares","116839"},
[64006480]={ "36283", "Blightglow", "i586 Agility/Intellect Leather Shoulders", "", "rare", "SoARares","118205"},
[46402860]={ "36267", "Durkath Steelmaw", "i586 Agility/Intellect Mail Boots", "", "rare", "SoARares","118198"},
[69005400]={ "37406", "Echidna", "unknown", "!!! Level 100 !!!", "hundredrare", "SoAHundred",""},
[54803960]={ "36297", "Festerbloom", "i584 Offhand", "", "rare", "SoARares","118200"},
[25202420]={ "36943", "Gaze", "Garrison Resources", "", "rare", "SoARares","824"},
[74404280]={ "37390", "Glutonous Giant", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "SoAHundred","823"},
[33005900]={ "36305", "Gobblefin", "Trash Item", "", "rare", "SoARares","116836"},
[59201500]={ "36887", "Hermit Palefur", "i582 Cloth Helm", "", "rare", "SoARares","118279"},
[56609460]={ "36306", "Jiasska the Sporegorger", "i589 Trinket Haste + Int Proc", "", "rare", "SoARares","118202"},
[62603740]={ "36268", "Kalos the Bloodbathed", "i588 Cloth Body", "", "rare", "SoARares","118735"},
[53208900]={ "36396", "Mutafen", "i589 Strength 2H Mace", "", "rare", "SoARares","118206"},
[36405240]={ "36129", "Nas Dunberlin", "i578 Agility/Strength Polearm", "", "rare", "SoARares","116837"},
[66005500]={ "36288", "Oskiira the Vengeful", "i589 Agility Dagger", "", "rare", "SoARares","118204"},
[59403740]={ "36279", "Poisonmaster Bortusk", "i583 Trinket Multistrike + DMG on Use", "", "rare", "SoARares","118199"},
[38402780]={ "36470", "Rotcap", "Pet", "", "rare", "SoARares","118107"},
[69004880]={ "36276", "Sangrikrass", "i589 Agility/Intellect Leather Body", "", "rare", "SoARares","118203"},
[71203380]={ "37392", "Shadow Hulk", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "SoAHundred","823"},
[52003540]={ "36478", "Shadowbark", "i579 Caster Shield", "", "rare", "SoARares","118201"},
[51800720]={ "37394", "Solar Magnifier", "unknown", "!!! Level 100 !!!", "hundredrare", "SoAHundred",""},
[33402200]={ "36265", "Stonespite", "i577 Agility/Intellect Mail Pants", "", "rare", "SoARares","116858"},
[58604520]={ "36298", "Sunderthorn", "i578 Agility 1H Sword", "", "rare", "SoARares","116855"},
[52805480]={ "36472", "Swarmleaf", "i582 Caster Staff", "", "rare", "SoARares","116857"},
[54606320]={ "36278", "Talonbreaker", "i578 Agility Neck", "", "rare", "SoARares","116838"},
[57407400]={ "36254", "Tesska the Broken", "i578 Intellect Neck", "", "rare", "SoARares","116852"},
}
nodes["NagrandDraenor"] = {
--NagrandTreasures
[73001090]={ "35951", "A Pile of Dirt", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[67605980]={ "35759", "Abandoned Cargo", "Gold", "", "default", "NagrandTreasures",""},
[38404940]={ "36072", "Abu'Gar's Favorite Lure", "Abu'Gar's Favorite Lure", "Combine with the other Abu'Gar Parts for a follower", "default", "NagrandTreasures","114245"},
[85403870]={ "36089", "Abu'gar's Missing Reel", "Abu'Gar's Finest Reel", "Combine with the other Abu'Gar Parts for a follower", "default", "NagrandTreasures","114243"},
[65906120]={ "35711", "Abu'gar's Vitality", "Abu'gar's Vitality", "Combine with the other Abu'Gar Parts for a follower", "default", "NagrandTreasures","114242"},
[75806200]={ "36077", "Adventurer's Mace", "Gold", "", "default", "NagrandTreasures",""},
[82305660]={ "35765", "Adventurer's Pack", "Gold", "", "default", "NagrandTreasures",""},
[45605200]={ "35969", "Adventurer's Pack", "Gold", "", "default", "NagrandTreasures",""},
[69905240]={ "35597", "Adventurer's Pack", "Gold", "", "default", "NagrandTreasures",""},
[56607290]={ "36050", "Adventurer's Pouch", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[73901410]={ "35955", "Adventurer's Sack", "Gold", "", "default", "NagrandTreasures",""},
[81501300]={ "35953", "Adventurer's Staff", "Gold", "", "default", "NagrandTreasures",""},
[73107550]={ "35673", "Appropriated Warsong Supplies", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[62506710]={ "36116", "Bag of Herbs", "Herbs", "", "default", "NagrandTreasures","109124"},
[77302820]={ "35986", "Bone-Carved Dagger", "i597 Agility Dagger", "", "default", "NagrandTreasures","116760"},
[77101660]={ "36174", "Bounty of the Elements", "Garrison Resources", "Use the elemental Stones to access", "default", "NagrandTreasures","824"},
[81103720]={ "35661", "Brilliant Dreampetal", "Manareg Potion", "Take Explorer Renzo's Glider to get there [north-east of here]", "default", "NagrandTreasures","118262"},
[66901950]={ "35954", "Elemental Offering", "Trash Item", "", "default", "NagrandTreasures","118234"},
[78901550]={ "36036", "Elemental Shackles", "i605 Agility Ring", "", "default", "NagrandTreasures","118251"},
[53407320]={ "xxx", "Explorer Bibsi", "Nothing - Is required for 2 Treasures in the South", "You need to use a rocket to get to her [south-east of her position]", "glider", "NagrandTreasures",""},
[67601420]={ "xxx", "Explorer Dez", "Nothing - Is required for 2 Treasures [1 South-East, 1 South-West]", "You can reach him from the east starting at the elemental plateau", "glider", "NagrandTreasures",""},
[87204100]={ "xxx", "Explorer Garix", "Nothing", "Is required for 2 Treasures [1 south, 1 south-east]", "glider", "NagrandTreasures",""},
[75606460]={ "xxx", "Explorer Razzuk", "Nothing", "Is required for 3 Treasures [1 north, 1 east, 1 south]", "glider", "NagrandTreasures",""},
[83803380]={ "xxx", "Explorer Renzo", "Nothing", "Is required for 3 Treasures [2 north-east, 1 south-west]", "glider", "NagrandTreasures",""},
[45806630]={ "36020", "Fragment of Oshu'gun", "i607 Intellect Shield", "", "default", "NagrandTreasures","117981"},
[73102160]={ "35692", "Freshwater Clam", "Trash Item", "", "default", "NagrandTreasures","118233"},
[88901820]={ "35660", "Fungus-Covered Chest", "Garrison Resources", "Take Explorer Renzo's Glider to get there [south-west of here]", "default", "NagrandTreasures","824"},
[75404710]={ "36074", "Gambler's Purse", "Flavor Item", "", "default", "NagrandTreasures","118236"},
[43305750]={ "35987", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[48006010]={ "35999", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[48607270]={ "36008", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[44606750]={ "36002", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[55306820]={ "36011", "Genedar Debris", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[73006220]={ "35590", "Goblin Pack", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[47207430]={ "35576", "Goblin Pack", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[58205260]={ "35694", "Golden Kaliri Egg", "Trash Item", "", "default", "NagrandTreasures","118266"},
[38305880]={ "36109", "Goldtoe's Plunder", "Gold", "Key on the Parrot", "default", "NagrandTreasures",""},
[87107290]={ "36051", "Grizzlemaw's Bonepile", "Pet Toy", "", "default", "NagrandTreasures","118054"},
[87504500]={ "35622", "Hidden Stash", "Garrison Resources", "Take Explorer Garix's Glider to get there [north of here]", "default", "NagrandTreasures","824"},
[67404900]={ "36039", "Highmaul Sledge", "i605 Strength Ring", "", "default", "NagrandTreasures","118252"},
[75306570]={ "36099", "Important Exploration Supplies", "Alcoholic Beverages", "", "default", "NagrandTreasures","61986"},
[61805740]={ "36082", "Lost Pendant", "i593 Green Amulet", "", "default", "NagrandTreasures","116687"},
[70501390]={ "35643", "Mountain Climber's Pack", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[81007980]={ "36049", "Ogre Beads", "i605 Str Ring", "", "default", "NagrandTreasures","118255"},
[57806220]={ "36115", "Pale Elixir", "Manareg Potion", "", "default", "NagrandTreasures","118278"},
[58305940]={ "36021", "Pokkar's Thirteenth Axe", "i605 1H Strength Axe", "", "default", "NagrandTreasures","116688"},
[72706100]={ "36035", "Polished Saberon Skull", "i605 Agility/Strength Ring", "", "default", "NagrandTreasures","118254"},
[58507630]={ "xxx", "Rocket to Explorer Bibsi", "Nothing", "Is required to get to Explorer Bibsi", "rocket", "NagrandTreasures",""},
[75206500]={ "36102", "Saberon Stash", "Gold", "", "default", "NagrandTreasures",""},
[88913310]={ "36857", "Smuggler's Cache", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[40406860]={ "37435", "Spirit Coffer", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[50108220]={ "35577", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [north-east of here]", "default", "NagrandTreasures","824"},
[52708010]={ "35583", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Bibsi's Glider to get there [north of here]", "default", "NagrandTreasures","824"},
[77805190]={ "35591", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [south of here]", "default", "NagrandTreasures","824"},
[64601760]={ "33648", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Dez's Glider to get there [north-east of here]", "default", "NagrandTreasures","824"},
[70601860]={ "35646", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Dez's Glider to get there [north-west of here]", "default", "NagrandTreasures","824"},
[87602030]={ "35662", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Renzo's Glider to get there [south-west of here]", "default", "NagrandTreasures","824"},
[88204260]={ "35616", "Steamwheedle Supplies", "Garrison Resources", "Take Explorer Garix's Glider to get there [north-west of here]", "default", "NagrandTreasures","824"},
[64706580]={ "36046", "Telaar Defender Shield", "i605 Agility/Intellect Ring", "", "default", "NagrandTreasures","118253"},
[37707060]={ "34760", "Treasure of Kull'krosh", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[50006650]={ "35579", "Void-Infused Crystal", "i613 2H Strength Sword", "", "default", "NagrandTreasures","118264"},
[51706030]={ "35695", "Warsong Cache", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[52404440]={ "36073", "Warsong Helm", "i609 Mail Agility/Intellect Helm", "", "default", "NagrandTreasures","118250"},
[73007040]={ "35678", "Warsong Lockbox", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[76107000]={ "35682", "Warsong Spear", "Trash Item", "Take Explorer Razzuk's Glider to get there [north of here]", "default", "NagrandTreasures","118678"},
[80606060]={ "35593", "Warsong Spoils", "Garrison Resources", "Take Explorer Razzuk's Glider to get there [west of here]", "default", "NagrandTreasures","824"},
[89406580]={ "35976", "Warsong Supplies", "Garrison Resources", "", "default", "NagrandTreasures","824"},
[64703580]={ "36071", "Watertight Bag", "20 Slot Bag", "", "default", "NagrandTreasures","118235"},
--NagrandRares
[84605340]={ "35778", "Ancient Blademaster", "Garrison Resources", "", "rare", "NagrandRares","824"},
[51001600]={ "37210", "Aogexon", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118654"},
[62601680]={ "37211", "Bergruu", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118655"},
[77006400]={ "35735", "Berserk T-300 Series Mark II", "Garrison Resources", "In a cave, opened with a switch", "rare", "NagrandRares","824"},
[40001600]={ "37396", "Bonebreaker", "unknown", "!!! Level 100 !!!", "hundredrare", "NagrandHundred",""},
[43003640]={ "37400", "Brutag Grimblade", "i620 Intellect/Strength Plate Boots", "!!! Level 100 !!!", "hundredrare", "NagrandHundred","119380"},
[34607700]={ "34727", "Captain Ironbeard", "Toy + i607 Gun", "", "rare", "NagrandRares","118244"},
[50204120]={ "37221", "Dekorhan", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118656"},
[60003800]={ "37222", "Direhoof", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118657"},
[38602240]={ "37395", "Durg Spinecrusher", "i620 Agility 2H Mace", "!!! Level 100 !!!", "hundredrare", "NagrandHundred","119405"},
[89004120]={ "35623", "Explorer Nozzand ", "Trash Item", "", "rare", "NagrandRares","118679"},
[74801180]={ "35836", "Fangler", "Trash Items", "", "rare", "NagrandRares","116836"},
[70004180]={ "35893", "Flinthide", "i609 Strength Shield", "", "rare", "NagrandRares","116807"},
[48202220]={ "37223", "Gagrog the Brutal", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118658"},
[52205580]={ "35715", "Gar'lua", "i605 Trinket Multistrike + Wolf Proc", "", "rare", "NagrandRares","118246"},
[42207860]={ "34725", "Gaz'orda", "i602 Intellect Ring", "In the cave", "rare", "NagrandRares","116798"},
[66605660]={ "35717", "Gnarlhoof the Rabid", "i598 Trinket Multistrike + Agi Proc", "", "rare", "NagrandRares","116824"},
[93202820]={ "35898", "Gorepetal", "i602 Agility/Intellect Leather Gloves", "The gloves let you gather herbs faster while in Draenor", "rare", "NagrandRares","116916"},
[45003640]={ "37472", "Gortag Steelgrip", "unknown", "!!! Level 100 !!!", "hundredrare", "NagrandHundred",""},
[84603660]={ "36159", "Graveltooth", "i609 Agility/Intellect Leather Bracer", "", "rare", "NagrandRares","118689"},
[66805120]={ "35714", "Greatfeather", "i600 Cloth Body", "", "rare", "NagrandRares","116795"},
[86007160]={ "35784", "Grizzlemaw", "i610 Strength Cloak", "", "rare", "NagrandRares","118687"},
[80603040]={ "35923", "Hunter Blacktooth", "i609 Agility 2H Mace", "", "rare", "NagrandRares","118245"},
[87005500]={ "34862", "Hyperious", "i597 Trinket Haste + Mastery Proc", "", "rare", "NagrandRares","116799"},
[45803480]={ "37399", "Karosh Blackwind", "i620 Cloth Pants", "!!! Level 100 !!!", "hundredrare", "NagrandHundred","119355"},
[43803440]={ "37473", "Krahl Deadeye", "unknown", "!!! Level 100 !!!", "hundredrare", "NagrandHundred",""},
[58201200]={ "37398", "Krud the Eviscerator", "i620 Intellect/Strength Plate Waist", "!!! Level 100 !!!", "hundredrare", "NagrandHundred","119384"},
[52009000]={ "37408", "Lernaea", "unknown", "!!! Level 100 !!!", "hundredrare", "NagrandHundred",""},
[81206000]={ "35932", "Malroc Stonesunder ", "i597 Agility Staff", "", "rare", "NagrandRares","116796"},
[45801520]={ "36229", "Mr. Pinchy Sr.", "i616 Trinket Multistrike + Lobstrok Proc", "", "rare", "NagrandRares","118690"},
[34005100]={ "37224", "Mu'gra", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118659"},
[47607080]={ "35865", "Netherspawn", "Pet", "", "rare", "NagrandRares","116815"},
[42804920]={ "35875", "Ophiis", "i602 Cloth Pants", "", "rare", "NagrandRares","116765"},
[61806900]={ "35943", "Outrider Duretha", "i598 Agility/Intellect Leather Boots", "", "rare", "NagrandRares","116800"},
[58201800]={ "37637", "Pit Beast", "Apexis Crystals", "!!! Level 100 !!!", "hundredrare", "NagrandHundred","823"},
[38001960]={ "37397", "Pit Slayer", "i620 Strength Ring", "!!! Level 100 !!!", "hundredrare", "NagrandHundred","119389"},
[73605780]={ "35712", "Redclaw the Feral", "i604 Intellect Fistweapon (without spellpower)", "the missing Spellpower is most likely a bug", "rare", "NagrandRares","118243"},
[58008400]={ "35900", "Ru'klaa", "i608 Intellect/Strength Plate Shoulder", "", "rare", "NagrandRares","118688"},
[54806120]={ "35931", "Scout Pokhar", "i601 Strength 1H Axe", "", "rare", "NagrandRares","116797"},
[61804720]={ "35912", "Sean Whitesea", "Garrison Resources", "", "rare", "NagrandRares","824"},
[75606500]={ "36128", "Soulfang", "i597 Intellect Sword", "", "rare", "NagrandRares","116806"},
[63402960]={ "37225", "Thek'talon", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118660"},
[65003900]={ "35920", "Tura'aka", "i609 Agility Cloak", "", "rare", "NagrandRares","116814"},
[37003800]={ "37520", "Vileclaw", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","120172"},
[82607620]={ "34645", "Warmaster Blugthol", "i600 Strength/Intellect Plate Bracer", "", "rare", "NagrandRares","116805"},
[70602940]={ "35877", "Windcaller Korast", "i598 Caster Staff", "", "rare", "NagrandRares","116808"},
[41004400]={ "37226", "Xelganak", "Reputation Item for Steamwheedle Preservation Society", "!!! Level 100 !!!", "swprare", "NagrandSWP","118661"},
}
nodes["garrisonsmvalliance_tier1"] = {
[49604380]={ "35530", "Lunarfall Egg", "Garrison Resources", "on a wagon", "default", "SMVTreasures","824"},
[42405436]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "SMVTreasures","824"},
[50704850]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "SMVTreasures","824"},
[30802830]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "SMVTreasures","824"},
[49197683]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "SMVTreasures","824"},
 }
nodes["garrisonsmvalliance_tier2"] = {
[37306590]={ "35530", "Lunarfall Egg", "Garrison Resources", "on a wagon", "default", "SMVTreasures","824"},
[41685803]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51874545]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "SMVTreasures","824"},
[34972345]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "SMVTreasures","824"},
[46637608]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "SMVTreasures","824"},
 }
nodes["garrisonsmvalliance_tier3"] = {
[61277261]={ "35530", "Lunarfall Egg", "Garrison Resources", "in the tent", "default", "SMVTreasures","824"},
[60575515]={ "35381", "Pippers' Buried Supplies 1", "Garrison Resources", "", "default", "SMVTreasures","824"},
[37307491]={ "35382", "Pippers' Buried Supplies 2", "Garrison Resources", "", "default", "SMVTreasures","824"},
[37864378]={ "35383", "Pippers' Buried Supplies 3", "Garrison Resources", "", "default", "SMVTreasures","824"},
[61527154]={ "35384", "Pippers' Buried Supplies 4", "Garrison Resources", "", "default", "SMVTreasures","824"},
[51800110]={ "35289", "Spark's Stolen Supplies", "Garrison Resources", "in a cave in the lake", "default", "SMVTreasures","824"},
 }


 
 function GetItem(ID)
	if (ID == "824" or ID == "823") then
		local currency, _, _ = GetCurrencyInfo(ID)
		if (currency ~= nil) then
			return currency
		else
			return "Error loading CurrencyID"
		end
	else
		local _, item, _, _, _, _, _, _, _, _ = GetItemInfo(ID)
		if (item ~= nil) then
			return item
		else
			return "Error loading ItemID"
		end
	end
end	
 function GetIcon(ID)
	if (ID == "824" or ID == "823") then
		local _, _, icon = GetCurrencyInfo(ID)
		if (icon ~= nil) then
			return icon
		else
			return "Interface\\Icons\\inv_misc_questionmark"
		end
	else
		local _, _, _, _, _, _, _, _, _, icon = GetItemInfo(ID)
		if (icon ~= nil) then
			return icon
		else
			return "Interface\\Icons\\inv_misc_questionmark"
		end
	end
end	
function DraenorTreasures:OnEnter(mapFile, coord)
    if (not nodes[mapFile][coord]) then return end
	
	local tooltip = self:GetParent() == WorldMapButton and WorldMapTooltip or GameTooltip
	if ( self:GetCenter() > UIParent:GetCenter() ) then
		tooltip:SetOwner(self, "ANCHOR_LEFT")
	else
		tooltip:SetOwner(self, "ANCHOR_RIGHT")
	end
	tooltip:SetText(nodes[mapFile][coord][2])
	if (nodes[mapFile][coord][3] ~= nil) and (DraenorTreasures.db.profile.show_loot == true) then
		if ((nodes[mapFile][coord][7] ~= nil) and (nodes[mapFile][coord][7] ~= "")) then
			tooltip:AddLine(("Loot: " .. GetItem(nodes[mapFile][coord][7])), nil, nil, nil, true)
			tooltip:AddLine(("Lootinfo: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
		else
			tooltip:AddLine(("Loot: " .. nodes[mapFile][coord][3]), nil, nil, nil, true)
		end
		
	end
	if (nodes[mapFile][coord][4] ~= "") and (DraenorTreasures.db.profile.show_notes == true) then
	 tooltip:AddLine(("Notes: " .. nodes[mapFile][coord][4]), nil, nil, nil, true)
	end
	tooltip:Show()
end

function DraenorTreasures:OnLeave(mapFile, coord)
	if self:GetParent() == WorldMapButton then
		WorldMapTooltip:Hide()
	else
		GameTooltip:Hide()
	end
end

local options = {
 type = "group",
 name = "DraenorTreasures",
 desc = "Locations of treasures in Draenor.",
get = function(info) return DraenorTreasures.db.profile[info.arg] end,
set = function(info, v) DraenorTreasures.db.profile[info.arg] = v; DraenorTreasures:Refresh() end,
 args = {
   desc = {
   name = "General Settings",
   type = "description",
   order = 0,
  },
   icon_scale_treasures = {
   type = "range",
   name = "Icon Scale for Treasures",
   desc = "The scale of the icons",
   min = 0.25, max = 3, step = 0.01,
   arg = "icon_scale_treasures",
   order = 1,
  },
  icon_scale_rares = {
   type = "range",
   name = "Icon Scale for Rares",
   desc = "The scale of the icons",
   min = 0.25, max = 3, step = 0.01,
   arg = "icon_scale_rares",
   order = 2,
  },
  icon_alpha = {
   type = "range",
   name = "Icon Alpha",
   desc = "The alpha transparency of the icons",
   min = 0, max = 1, step = 0.01,
   arg = "icon_alpha",
   order = 20,
  },

  VisibilityOptions = {
  type = "group",
  name = "Visibility Settings",
  desc = "Visibility Settings",
  args = {


VisibilityGroup = {
	type = "group",
	order = 0,
	name = "Select what to show in which zone:",
	inline = true,
	args = {
SMVGroup = {
	name = "Shadowmoon Valley",
	desc = "Shadowmoon Valley",
	type = "header",
	order = 0,
	},
SMVTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "SMVTreasures",
   order = 1,
   width = "half",
  },
SMVRares = {
   type = "toggle",
   name = "Rares",
   arg = "SMVRares",
   order = 2,
   width = "half",
  },
SMVHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   desc = "Level 100 Rarespawns",
   arg = "SMVHundred",
   order = 3,
   width = "half",
  },
SMVShrines = {
   type = "toggle",
   name = "Shrines",
   arg = "SMVShrine",
   order = 4,
   width = "half",
  },
FFRGroup = {
	name = "Frostfire Ridge",
	desc = "Frostfire Ridge",
	type = "header",
	order = 10,
	},	
FFRTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "FFRTreasures",
   width = "half",
   order = 11,
  },
FFRRares = {
   type = "toggle",
   name = "Rares",
   arg = "FFRRares",
   width = "half",
   order = 12,
  },
FFRHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   desc = "Level 100 Rarespawns",
   arg = "FFRHundred",
   width = "half",
   order = 13,
  },
FFRShrines = {
   type = "toggle",
   name = "Shrines",
   arg = "FFRShrine",
   order = 14,
   width = "half",
  },
GorgrondGroup = {
	name = "Gorgrond",
	desc = "Gorgrond",
	type = "header",
	order = 20,
	},	
GorgrondTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "GorgrondTreasures",
   width = "half",
   order = 21,
  },
GorgrondRares = {
   type = "toggle",
   name = "Rares",
   arg = "GorgrondRares",
   width = "half",
   order = 22,
  },  
 GorgrondHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   arg = "GorgrondHundred",
   desc = "Level 100 Rarespawns",
   width = "normal",
   order = 23,
  },  
TaladorGroup = {
	name = "Talador",
	desc = "Talador",
	type = "header",
	order = 30,
	},	
TaladorTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "TaladorTreasures",
   width = "half",
   order = 31,
  },
TaladorRares = {
   type = "toggle",
   name = "Rares",
   arg = "TaladorRares",
   width = "half",
   order = 32,
  },  
TaladorHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   arg = "TaladorHundred",
   desc = "Level 100 Rarespawns",
   width = "normal",
   order = 33,
  },  
SoAGroup = {
	name = "Spires of Arak",
	desc = "Spires of Arak",
	type = "header",
	order = 40,
	},	  
SoATreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "SoATreasures",
   width = "half",
   order = 41,
  },
SoARares = {
   type = "toggle",
   name = "Rares",
   arg = "SoARares",
   width = "half",
   order = 42,
  },  
SoAHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   desc = "Level 100 Rarespawns",
   arg = "SoAHundred",
   width = "normal",
   order = 43,
  },  
NagrandGroup = {
	name = "Nagrand",
	desc = "Nagrand",
	type = "header",
	order = 50,
	},	    
  NagrandTreasures = {
   type = "toggle",
   name = "Treasures",
   arg = "NagrandTreasures",
   width = "half",
   order = 51,
  },
  NagrandRares = {
   type = "toggle",
   name = "Rares",
   arg = "NagrandRares",
   width = "half",
   order = 52,
  },
  NagrandHundredRares = {
   type = "toggle",
   name = "L100 Rares",
   arg = "NagrandHundred",
   desc = "Level 100 Rarespawns",
   width = "half",
   order = 53,
  },
  NagrandSWPRares = {
   type = "toggle",
   name = "SWP Rares",
   desc = "Steamwheedle Preservation Society Rares",
   arg = "NagrandSWP",
   width = "half",
   order = 53,
  },
	},
  },
  alwaysshow = {
   type = "toggle",
   name = "Also show already looted(killed) Treasures(Rares)",
   desc = "Show every treasure/rare regardless of looted status",
   arg = "alwaysshow",
   order = 100,
   width = "full",
  },
    show_loot = {
   type = "toggle",
   name = "Show Loot",
   desc = "Shows the Loot for each Treasure/Rare",
   arg = "show_loot",
   order = 101,
   },
  show_notes = {
   type = "toggle",
   name = "Show Notes",
   desc = "Shows the notes each Treasure/Rare if available",
   arg = "show_notes",
   order = 101,
   },
	 },
	},
  },
}

function DraenorTreasures:OnInitialize()
 local defaults = {
  profile = {
   icon_scale_treasures = 1.5,
   icon_scale_rares = 2.0,
   icon_alpha = 1.0,
   alwaysshow = false,
   save = true,
   SMVTreasures = true,
   SMVRares = true,
   SMVHundred = true,
   SMVShrine = true,
   FFRTreasures = true,
   FFRRares = true,
   FFRHundred = true,
   FFRShrine = true,
   GorgrondTreasures = true,
   GorgrondRares = true,
   GorgrondHundred = true,
   TaladorTreasures = true,
   TaladorRares = true,
   TaladorHundred = true,
   SoATreasures = true,
   SoARares = true,
   SoAHundred = true,
   NagrandTreasures = true,
   NagrandRares = true,
   NagrandHundred = true,
   NagrandSWP = true,
   show_loot = true,
   show_notes = true,
  },
 }

 self.db = LibStub("AceDB-3.0"):New("DraenorTreasuresDB", defaults, true)
 self:RegisterEvent("PLAYER_ENTERING_WORLD", "WorldEnter")
end

function DraenorTreasures:WorldEnter()
 self:UnregisterEvent("PLAYER_ENTERING_WORLD")
 self:ScheduleTimer("RegisterWithHandyNotes", 5)
end

function DraenorTreasures:RegisterWithHandyNotes()
do
	local function iter(t, prestate)
		if not t then return nil end
		local state, value = next(t, prestate)
		while state do
			    -- QuestID[1], Name[2], Loot[3], Notes[4], Icon[5], Tag[6], ItemID[7]
			    if (value[1] and self.db.profile[value[6]] and not DraenorTreasures:HasBeenLooted(value)) then
					if ((value[5] == "default") or (value[5] == "unknown")) then
						if ((value[7] ~= nil) and (value[7] ~= "")) then
							return state, nil, GetIcon(value[7]), DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
						else
							GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
							return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_treasures, DraenorTreasures.db.profile.icon_alpha
						end
					end
				if ((value[7] ~= nil) and (value[7] ~= "")) then
				 	GetIcon(value[7]) --this should precache the Item, so that the loot is correctly returned
				end
				 return state, nil, iconDefaults[value[5]], DraenorTreasures.db.profile.icon_scale_rares, DraenorTreasures.db.profile.icon_alpha
				end
			state, value = next(t, state)
		end
	end
	function DraenorTreasures:GetNodes(mapFile, isMinimapUpdate, dungeonLevel)
		return iter, nodes[mapFile], nil
	end
end
 HandyNotes:RegisterPluginDB("DraenorTreasures", self, options)
 self:RegisterBucketEvent({ "LOOT_CLOSED" }, 2, "Refresh")
 self:Refresh()
end
 
function DraenorTreasures:Refresh()
 if (not self.db.profile.save) then
  table.wipe(self.db.char)
 end
 self:SendMessage("HandyNotes_NotifyUpdate", "DraenorTreasures")
end

function DraenorTreasures:HasBeenLooted(value)
 if (self.db.profile.alwaysshow) then return false end
 if value[1] == "xxx" then return false end
 
 if (self.db.char[value[1]] and self.db.profile.save) then return true end
 
 if (IsQuestFlaggedCompleted(value[1])) then
  if (self.db.profile.save and not value[4]) then
   self.db.char[value[1]] = true;
  end
  
  return true
 end
  
 return false
end