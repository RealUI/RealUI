
-- GLOBALS: BADBOY_BLACKLIST, BADBOY_OPTIONS, BadBoyLog, ChatFrame1, GetTime, print, ReportPlayer, CalendarGetDate, SetCVar
-- GLOBALS: GameTooltip, C_Timer, IsEncounterInProgress, GameTooltip_Hide
local L
do
	local _
	_, L = ...
end

--These entries add +1 point
local commonList = {
	--English
	"bonus",
	"buy",
	"cheap",
	"code",
	"coupon",
	"customer",
	"deliver",
	"discount",
	"express",
	"g[0o]ld",
	"lowest",
	"mount",
	"order",
	"powerle?ve?l",
	"price",
	"promoti[on][gn]",
	"reduced",
	"rocket",
	"sa[fl]e",
	"server",
	"service",
	"stock",
	"store",
	"trusted",
	"well?come",
	"%d+k[\\/=]%d+euro",
	"%d+%$[\\/=]%d+g",

	--French
	"livraison", --delivery
	"moinscher", --least expensive
	"prix", --price
	"commande", --order

	--German
	"billigster", --cheapest
	"lieferung", --delivery
	"preis", --price
	"willkommen", --welcome

	--Spanish
	"barato", --cheap
	"gratuito", --free
	"rapid[oe]", --fast [[ esES:rapido / frFR:rapide ]]
	"seguro", --safe/secure
	"servicio", --service
}

--These entries add +1 point to the phishing count
local phishingList = {
	--English
	"account",
	"blizz",
	"claim",
	"congratulations",
	"free",
	"gamemaster",
	"gift",
	"investigat", --investigate/investigation
	"launch",
	"log[io]n",
	"luckyplayer",
	"mount",
	"pleasevisit",
	"receive",
	"service",
	"surprise",
	"suspe[cn][td]", --suspect/suspend
	"system",
	"validate",

	--German
	"berechtigt", --entitled
	"erhalten", --get/receive
	"deaktiviert", --deactivated
	"konto", --acount
	"kostenlos", --free
	"qualifiziert", --qualified
}

local boostingList = {
	"paypal",
	"skype",
	"b[o0][o0]st",
	"arena",
	"rbg",
	"gladiator",
	"service",
	"cheap",
	"fast",
	"safe",
	"price",
	"account",
	"rating",
	"legal",
	"guarantee",
	"m[o0]unt",
	"sale",
	"season",
	"professional",
	"customer",
	"discount",
	"selfplay",
	"coaching",
	"mythic",
	"leveling",
	"accshar[ei]",
	"secure",
	"delivery",
	"store",
	"pri?est[ie]ge",
	"quality",
	"pil[o0]ted",
}
local boostingWhiteList = {
	"members",
	"guild",
	"social",
	"|hspell",
	"%d+k[/\\]dungeon",
	"onlyacceptinggold",
	"goldonly",
	"goldprices",
	"forgold",
	"tonight",
	"gametime",
	"servertime",
}

--These entries remove -2 points
local whiteList = {
	"%.battle%.net/",
	"recrui?t",
	"dkp",
	"looking",
	"lf[gm]",
	"|cff",
	"cardofomen",
	"raid",
	"scam",
	"roleplay",
	"physical",
	"appl[iy]", --apply/application
	"enjin%.com",
	"guildlaunch%.com",
	"gamerlaunch%.com",
	"corplaunch%.com",
	"wowlaunch%.com",
	"wowstead%.com",
	"guildwork.com",
	"guildportal%.com",
	"guildomatic%.com",
	"guildhosting.org",
	"%.wix%.com",
	"shivtr%.com",
	"own3d%.tv",
	"ustream%.tv",
	"twitch%.tv",
	"social",
	"fortunecard",
	"house",
	"join",
	"community",
	"guild",
	"progres",
	"transmor?g",
	"arena",
	"boost",
	"players",
	"portal",
	"town",
	"vialofthe",
	"synonym",
	"[235]v[235]",
	"sucht", --de
	"gilde", --de
	"rekryt", --se
	"soker", --se
	"kilta", --fi
	"etsii", --fi
	"sosyal", --tr
	"дкп", --ru, dkp
	"peкpуt", --ru, recruit
	"нoвoбpaн", --ru, recruits
	"лфг", --ru, lfg
	"peйд", --ru, raid
}

--Any entry here will instantly report/block
local instantReportList = {
	--[[  Casino  ]]--
	"%d+.*d[ou][ub]ble.*%d+.*trip", --10 minimum 400 max\roll\61-97 double, 98-100 triple, come roll,
	"casino.*%d+x2.*%d+x3", --{star} CASINO {star} roll 64-99x2 your wager roll 100x3 your wager min bet 50g max 10k will show gold 100% legit (no inbetween rolls plz){diamond} good luck {diamond}
	"casino.*%d+.*double.*%d+.*tripp?le", --The Golden Casino is offering 60+ Doubles, and 80+ Tripples!
	"casino.*whisper.*info", --<RollReno's Casino> <Whisper for more information!>
	"d[ou][ub]ble.*%d+.*tripp?le", --come too the Free Roller  gaming house!  and have ur luck of winning gold! :) pst me for invite:)  double is  62-96 97-100 tripple we also play blackjack---- u win double if you beat the host in blackjack
	"casino.*bet.*%d+", --Casino time. You give me your bet, Than You roll from 1-11 unlimited times.Your rolls add up. If you go over 21 you lose.You can stop before 21.When you stop I do the same, and if your closer to 21 than me than you get back 2 times your bet
	"roll.*%d+.*roll.*%d+.*bet", --Roll 63+ x2 , Roll 100 x3, Roll 1 x4 NO MAX BETS
	"casino.*roll.*double", --CASINO IS BACK IN TOWN COME PAY ME ROLL +65 AND GET DOUBLE
	"casino.*roll.*%d+.*roll.*%d+", --Casino is back in town !! Roll over 65 + and get your gold back 2X !!  Roll 100 and get your gold back 3X !!
	"double.*tripp?le.*casino", --Hey there wanna double your money in casino? or triple or even quad it? give me a whisp if you want to join my casino :)
	"casino.*legit.*safe.*casino", --LEGIT CASINO IN TRADE DESTRICT! /w * for a legit and safe casino!
	"luck.*roll.*%d+k.*minutes.*pst", --test your luck. all you gotta do is roll. make 1-100k+ in minutes. pst for details.
	"roll.*win.*double.*min.*max", --Game 2 Roll Wars. Trade wager then roll. We both rol. Highest Roll wins. If you win ill double your wager 500g Minimum 5k Maximum
	"casino.*/w.*%d+.*roll", --CASINO /W ME 50/50 ROLL

	--[[  Runescape Trading  ]]--
	--WTB RS gold paying WoW GOLD
	--WTT RS3 Gold to Wow Gold (i want wow gold) pm for info
	"wt[bst]rs3?gold.*wowgold", --WTB rs gold trading wow gold PST
	"wt[bs]wowgold.*rsgold", --WTS Wow gold for rs gold
	"wt[bs]wowgold.*rscoint?s", --WTS Wow gold for rs coints
	--WTS RUNESCAPE GOLD !~!~!~ PST
	--WTB RUNESCAPE GOLD WITH WOW GOLD PST
	"wt[bs]runescapegold", --WTB Runescape Gold, Trading WOW Gold, PST -- I will trade first.
	"exchangingrsgold", --Exchanging RS gold for WoW gold. I have 400m PST
	--WTS level 25 guild with 80k gold for runescape gold
	"goldforrunescapegold", --Exchanging WoW gold for Runescape gold pst me better price for higher amount.
	--Buying runescape account! :D Add me on skype "*"
	"buying?runescape[ag]", --buyin runescape g
	"wt[bs]runescapeaccount", --WTB runescape accounts ( pure only ) or money! i pay with wow gold. GOT 170k gold atm.
	"wt[bs]runescapepure", --WTB runescape pure ( STR PURE IS A $$ PAYING EXTRA FOR STR PURE )!
	--WTB big amount of runescape money. 2mil = 1k gold. ONLY LEGIT PEOPLE.
	"wt[bs].*runescapemoney.*%d+k", --WTB runescape money. 3mil = 1k in wow! easy money making.
	"^wt[bs]rsaccount", --wts rs acount 10k .... lvl 95 with items for over 15 mil with 6 year old holiday
	"^wt[bs]%d+rsaccount", --WTS 137 RS ACCOUNT /W ME
	--WTS awesome rs account with 99's /w me
	--WTS an awesome rs account /w me details
	"^wt[bs]a?n?awesomersaccount", --wts awesome rs account /w me
	"runescapegoldforwowgold", --Selling my runescape gold for wow gold
	"^buyingrs3stuff", --Buying RS3 stuff for gold

	--[[ CS:GO ]]--
	"^wt[bst]somecsgoskin", --WTB some CSGO skins and sell some /w for more info
	--WTS CS:GO Skins
	--WTB CS.GO SKINS/KEYS FOR GOLD!
	"^wt[bst]cs%.?goskin", --WTB CS GO skins /w for more infomation
	"^wt[bst]csgokey", --{rt1} WTB CS:GO KEYS & SKINS FOR GOLD {rt1}
	"^wt[bst]csgoacc", --WTS CS GO ACC UNRANK
	"^wt[bst]csgokni[fv]e", --WTSCS GO knife M9 Bayonet Stained in (minimal wear) /w and give me offer
	"^wt[bst]csgoitem", --WTB CS:GO Items for Gold! /W me your items!!
	"^wt[bst]csgocase", --WTB Cs Go Case keys or a Knife .
	"^wt[bst]anycsgoskin", --{rt1} WTB ANY CS:GO SKINS FOR WOW GOLD {rt1}
	--{rt1}{rt8} Buying cs.g0 skins {rt8} {rt1}
	"^buyingcs%.?g[0o]skin", --{rt1}{rt3} Buying CS:GO Skins & Keys for WoW Gold | Paying good  {rt3}{rt1}
	"^buyingcheapcsgoskin", --Buying cheap CS:GO skins (1-5 eu each) I can go first!
	"^buyingcsgokey", --{rt3}Buying Cs:Go Key's for {rt4}4k{rt4} Per key! Buying high amount! Whisper for more information!{rt3}
	"^buyingcsgokni[fv]e", --Buying CS:GO Knives and Skins! Trusted trader with feedback! /w me for more info. Serious people only please.
	"^sellingcsgoskin", --Selling CS:GO skins for wow gold!
	"^sellingsomecsgocase", --Selling some CS:GO cases! PM ME!
	"^sellingcsgocase", --Selling CS:GO cases! PM ME!
	"^sellingcsgoitem", --{rt1} SELLING CS GO ITEMS FOR GOLD {rt1}
	"^wt[bst]csskins", --wtb cs skins /w me what u have 300k +
	"^wt[bst]keysincsgo", --WTB Keys in CS:GO for 3k each!
	"wanttobuy[/\\]sellcsgoitem", --Want to buy/sell CS:GO items whisper me for more information :)
	"wanttosell[/\\]buycsgoitem", --Want to sell/buy CS:GO items for wow gold, whisper me for more information :)
	"wowgoldforcsgokey", --{rt6} Want to trade WoW Gold for CS:GO Keys  Whisper me for more info!! / Swish till svenskar {rt6}
	"^wt[bst]csgocamo", --WTS CS:GO CAMOS
	"^wt[bst]cheapcsgoskin", --WTB CHEAP CS:GO SKINS /W ME !
	"^wt[bst]csgocdkee?y", --WTB CS GO CD KEEY PAY GOLD AND GOOD WISP ME YOUR OFFER WTB CS GO KNIFE SKINS
	"^tradingcsgo.*gold", --Trading Cs:GO Knife for Gold /w me for more information!!!
	"^wt[bst]csgocheap", --WTB CS GO CHEAPS BELOW 5 EURO WITH WOW GOLD!
	"^wt[bst]goldforcsgo", --WTS gold for cs:go knife, i will pay good if its  a good one, add me and /w if you are intrested
	"^wt[bst]mywowgold.*csgoskin", --WTT: My WOW Gold for your CSGO Skins. Offer 3k per 1€ skin value. No selling, Just trading! /w me for a chat.
	"^sellinggolds?forcsgo", --Selling golds for CS:GO skins !!
	"^wt[bst]csgosteamgift", --WTB CS GO STEAM GIFT  (it cost 8.36 EUROS) FROM G2A FOR GOLD AND I'M OFFERING A GOOD PRICE !!!

	--[[ SC 2 ]]--
	"^wtsstarcraft.*cdkey.*gold", --WTS Starcraft Heart of Swarm cd key for wow golds.

	--[[  Dota 2 ]]--
	"^sellingdota2", --Selling 2 Dota2 for wow gold! /W me
	--wtt dota 2 keys w
	--wts dota 2beta key 10k
	"^wt[bst]dota2", --WTB Dota 2 hero/store items,/W me what you have
	"^buyingdotaitems", --buying dota items w/Me i got  [Ethereal Soul-Trader] [Jade Panther] :)
	"^buyingdota2", --buying dota 2 skins w/me
	"^wt[bst]alldota2", --WTB ALL DOTA 2 SKINS W/ME <3

	--[[  Steam  ]]--
	"^wtssteamaccount", --WTS Steam account with 31 games (full valve pack+more) /w me with offers
	"^sellingborderlands2", --Selling Borderlands 2 cd-key cheap for gold (I bought it twice by mistake. Can send pictures of both confirmations emails without the cd-keys, if you dont trust me)
	"^wtssteamwalletcode", --WTS Steam wallet codes/CS GO skins /W

	--[[  League of Legends  ]]--
	"^wt[bs]lolacc$", --WTB LoL acc
	"^wt[bs]%d?x?leagueoflegends?account", --WTS 2x League of Legend accounts for 1 price !
	--WTT My LoL Account for WoW gold, Its a platiunum almost diamond ranked account atm on EUW if u want more information /w me
	"^wt[bst]m?y?lolaccount", --WTS LOL ACCOUNT LEVEL 30 with 27 SKINS and 14k IP
	"^sellingloleuw?acc.*info", --Selling LOL EUW acc pm for more info
	"^wt[bs].*leagueoflegends.*points.*pay", --WTB 100 DOLLARS OF LEAGUE OF LEGENDS RIOT POINTS PST. YOU PAY WITH YOUR PHONE. PST PAYING A LOT.
	"wts.*leagueoflegends.*acc.*info", --{rt1}wts golden{rt1} League of Legends{rt1} acc /w me for more info{rt1}
	"sellingm?y?leagueoflegends", --Selling my league of legends account, 100 champs 40 skins 2-3 legendary 4 runepage, gold. /EUW /W
	"^wt[bs]lolacc.*cheap", --WTS LOL ACC PLAT 4 1600 NORMAL WINS, EUW 40 SKINS, 106 CHAMPS  CHEAP!!
	"^wt[bs]lolacc.*skins", --WTS LoL acc level 30 EUW name ** got about 50 skins /w me for info include 3200 RP!
	"^wt[bst]mygold%d*leagueoflegends", --WTT My Gold 3 League of Legends account for some sick CS:GO skins! 116 Champions, 158 Skins, 6 rune pages. /w me for more info/skype!
	"^sellingwowgoldforleagueoflegends", --SELLING WOW GOLD FOR LEAGUE OF LEGENDS RP! /W ME

	--[[  Account Buy/Sell  ]]--
	"selling.*accounts?forgold", --Selling Spotify,Netflix Accounts for gold!!! /w me
	"wtsnonemergeacc.*lvl?%d+char", --!WTS none-merge acc(can get a lv80 char)./W me for more info!
	--! WTS lvl 80 char.{all class}.Diablo3 g0ld /W me for more info !
	--^{diamond}lv80 char all class./w me for more info if you WTB^
	"lvl?%d+char%.?allclass.*info", --^{Square} WTS lvl 80 char all class ! /w me for more info{square}^
	"lvl?%d+char.*fast.*g[o0]ld", --# WTS lvl 80 char .TCG mount.cheap fast D3 g0ld/w me for more #
	"%d+lvloldaccounts?tosell", --80lvl old account to sell
	"wtswowaccount.*epic", --y WTS WOW ACCOUNT 401 ITEM LEVEL ROGUES WITH FIRST STAGE LEGENDARY FULL CATA!! WITH 1X VIAL OF SANDS/CRIMSON DEATHCHARGER FULL EPIC GEMED 1X ROGUE 1 X WARRIOR PVP AIMED ADD SKYPE * AND I ALSO HAVE FULL HIERLOOM FOR EVER SINGLE CHARACTER A
	"^wanttotradeaccount", --Want to trade account full cata rogue on * with full epic 50 agil gems(vial of the sands and crimson dk and warrior with 1 cata and mechanohog it is on * wt t for a class with full cata on * /w me!!!!!
	"^wttacc.*epic.*mount.*/w", --WTT ACC MINE HAS FULL CATA+FULL EPIC GEMS  ROGUE WITH NICE MOUNTS WTT FOR AND ACC WITH FULL CATA  RESTO SHAMAN!! /W ME!!
	"^wttacc?ount.*gear.*char", --WTT Acount Resto/Enha shaman / Resto / Balance druid / Prot warr / Mage / Paladin for just one full cata geared pvp character /w me with info
	--WTS wow account 85human Rogue with LEGENDARIES + JC BS.  u pay with gold./w me for more info
	"^wt[st]wowaccount", --WTT Wow account /w me for more info
	"^wt[bs]mopcode", --WTS MoP Code /w me for info
	"^wttaccountfor.*youget.*tier", --WTT Account for a 90 tier 1 ROGUE, you get 90mage(tier1)90druid (tier1) 85 priest, 85 rogue, 85 warrior /wme
	--WTS ACCOUNT with 90 rogue, and 90 priest for gold /wme
	--WTS Account with free lvl 80 And GAME  TIME!! /w me
	"^wt[st]accountwith", --WTT ACCOUNT with 90 mage(TIER1) 90 Feral (TIER1) 85 priest, 85 warrior, 85 rogue for 90 ROGUE with TIER 1/wme
	"^wt[bst]legionkey", --WTS Legion key for gold
	"^wt[bst]legioncdkey", --WTS Legion CD-Key for gold!

	--[[  Brazzers, yes, really...  ]]--
	"sell.*brazzersaccount.*info", --Hey there! I'm here to sell you Brazzers account /w me for more info!
	"^wtsbrazzersaccount", --WTS BRAZZERS ACCOUNT UNLIMITED TIME /W OFFER

	--[[  Diablo 3  ]]--
	"^wttrade%d+kgold.*diablo", --WT trade 6k gol;d for 300k in diablo 3. /w me
	"^wttwowgold.*diablo", --WTT wow gold for diablo gold. /w if interested.
	"^wtbd3forgold", --WTB D3 for gold!
	--SELLING DIABLO 3 / 60 DAYS PREPAIDGAMECARD - PRICES IN DND!! CHEAP
	"^sellingdiablo3", --Selling Diablo 3 CD Key.Fast & Smooth Deal.
	"^sellingd3account", --Selling D3 account cheap /w for more !
	"^wtscheapfastd3g", --*WTS cheap fast D3 G,/W for skype*
	"^wt[bs]d3key", --WTs D3 key Wisp me for info and price!
	"^wts.*%d+day.*diablo.*account", --WTS [Winged Guardian] [Heart of the Aspects] [Celestial Steed]Each 22k gc90days=30Kdiablo III Account for=70k
	"tradediablo3?goldforwowgold", --anyone want to trade diablo gold for wow gold?
	--SELLING 60 DAYS GAMECARD - VERY CHEAP - ALSO SELL DIABLO ! -SAFE
	"^selling.*gamecard.*diablo", --SELLING 60 DAY GAMECARDS & DIABLO 3!!!!
	"^wt[bs]d3account", --WTS D3 account /w for more !
	"^wtsd3.*transfer.*item", --WTS D3/faction/race change server transfer and other items!
	--WTS Diablo 3 code 30 K !!
	--WTS Diablo 3 CD KEY
	--WTB Diablo 3 key cheap
	--WTB Diablo3 Gold for WoW Gold! /w me D3Gold per WoWGold!
	"^wt[bs]diablo3", --WTB Diablo 3 Gold!
	--WTB WOW GOLDS WITH D3 GOLDS ASAP
	"^wt[bst]wowgold.*d3gold", --WTT Wow Gold For D3 Gold! /w me with your price!
	--{rt1}{rt1}{rt1}WTT my WoW gold for your D3 gold. EU softcore. MSG.
	"wowgoldfory?o?u?r?d3gold", --T> My WoW gold for D3 gold
	--T> My WoW gold for Diablo 3 gold
	--Trading My WoW gold for Diablo 3 gold
	"wowgold.*fordiablo3?gold", --T> My WoW gold (15,000g) for Diablo 3 gold
	"tradediablo3?gold.*wowgold", --LF someone that wants to trade diablo 3 gold for my wow gold
	"^wt[bs]diablogold", --wtb diablo gold for wow gold!
	"trading.*fordiablo3?gold", --TRADING LVL 25 GUILD FOR DIABLO GOLD!!!!!!!!!!!!!
	"diablogoldforwowgold", --WTT my diablo gold for wow gold
	--WTT D3 gold to WoW gold! /w me!
	--WTT 270mil D3 gold to WoW gold! /w me!
	"^wt[bst].*d3gold.*wowgold", --WTB d3 golds for wow golds !
	"^wtt.*mygold.*diablo3gold", --WTT all my gold, 8783g for about 30m Diablo 3 gold, any takers?
	"wowgoldforyourdiablo3?gold", --{rt1}Looking to trade my 10k wow gold for your diablo 3 gold, we can do in trades as low as 0.5k wow gold at a time for safety reasons{rt1}
	"wts.*diablo3goldfor%d+", --wts 150 mill Diablo 3 gold for 50k

	--[[ Items ]]--
	"^wtscheapgold", --WTS cheap gold /w me for more info
	"^wtscheapandfastgold", --WTS cheap and fast gold ( no chineese website) /w me for more info
	"^wtbgold.*gametime", --WTB GOLD, OR TRADE GOLD FOR GAMETIME!!
	"^wtbgold.*mount", --WTB Gold paying decent(also TCG pets,mounts)/w me!
	"^wt[bs]gametime", --WTS {rt1} GAMETIME {rt1} {rt8} MoP Upgrade{rt8}
	"^wt[bs]prepaidcard", --WTS prepaid card (30,60,90 days), mounts
	"^wt[bs]gamecard", --WTB GAME CARD
	"^wt[bs]gamecode", --wtb game codes
	"^wt[bs]prepaidgamecard", --WTS *Pre-Paid Game Card 60 Days* - Can prove I've got loads in stock /w me offers
	"^wt[bs]%d+day.*gamecard", --WTS 60 DAYS PREPAID GAMECARD
	"^wt[bs]%d+month.*gametime", --WTS 2 Month(60Days) Gametime-Cards w/ me ! {rt1}
	"^wt[bs][36]0days?prepaidgametime", --WTS 60day Prepaid Gametime  Card and WOD
	"^wts%d+days?gametime", --wts 60 days gametime cde. and more stuff from blizzstore
	"^wts%d+days?gamecard", --wts 60 days game card /w me
	"^wts%d+kfor%d+euro", --WTS 950K FOR 35EURO(PayPal) /w me !

	--[[  2016  ]]--
	"titaniumbay.*extra", ---= TitaniumBay =- Get 10 % extra {rt2}! Fast and safe delivery!
	"titaniumbay.*livraison", ---= TitaniumBay =- Obtenez 10% supplémentaire! Livraison rapide et sûr!
	"titaniumbay.*obtenez", --TitaniumBay - Obtenez 40% plus d'or en 15 min! le plus fameux et valeureux de la ville!
	"titaniumbay.*minut[eo]", --TitaniumBay - Erhalten Sie 40% mehr Gold in 15 Minuten! Das beste Angebot in der Stadt!
	"titaniumbay.*gold", -- -= TitaniumBay =- Get up to 30% more gold compared to WoW Token
	"titaniumbay.*gratis", ---= TiвtaniumBay =- Oferta Limitada >> Obtenga el 50% extra oro Gratis!
	"boost.*mythic.*also.*10lvl.*key", --Boost 8\8 10\10 mythic(mythic+),also we can do 10lvl(i have key) key at once
	--WTS [Keystone Conqueror] (2-10lvl) ►ŠELFPLĄY◄ Teâm Is Reâdy To Gø Right Nøw! ŠKYPĒ: FindGuys
	"skype.*findguys", --Hello. Im sorry but I cant write here all prices. For all info and prices please add me in Skype: FindGuys
	"mythic.*loot.*bestboost[%.,]c", --WTS: EN 7/7| Mythic+2-10 |LVL 100-110| Loot Run | Selfplay/Piloted | Master loot | SSL | More info>>> Best-boost .c0m <<
	"best.*gear.*achiev.*mythic.*visit", -->> Best Boost here! We will help u with full PVE and PVP gear, achievs, mythic, raids and more. Visit web: Best-boost .c0m <<
	"keystone.*mythic.*boost.*skype", --WTS Mythic+ CHEST RUN, Mythic+ (up keystone), Mythic dungeons boost. SKYPE - fastchallenge
	"helpyou.*heroic.*personal.*key.*info", -- ---Help you with  Emerald Nightmare Heroic\Normal (Master loot\ Personal loot)… Up your KEY 2+ 4+ 6+ 8+ 10+ for more info /W ---
	"hero.*master.*mythic.*le?ve?ling", -->>>>>>>>>>>>>>>>>>> Emerald Nightmare (Normal,Hero)   Master loot Persona loot  Mythic Legion dungeons  8/10 & 10/10 , leveling 100-110 (12 hours) <<<<<<<<<<<<<<<<<<<
	"wtsmythic.*runs.*gear.*anyilvl.*840", --WTS Mythic+, 10/10Mythic runs, gear you up from any ilvl to 840+/w
	--WTS 10/10 Mythic and Heroic all info in skype: qReaper_bst
	"skype.*qreaperbst", --Add skype: qReaper_bst foк price and info
	--EN HC/M LOOTRUNS, KARAZHAN, POWERLEVELING, MYTH+ TRIAL OF VALOR  AND MUCH MORE >>> [JUSTBOOST.NET] <<<
	"power.*justboost[%.,]net", --EN Myth/HC LootRuns, Karazhan, Powerleveling, Mounts,  Myth+ Boosting and more>>> [JUSTBOOST.NET] <<<
	"mythic.*justboost[%.,]net", --WTS MYTHIC EN,  chests run, levelin 100-110 - [JUSTBOOST.NET]
	-->>>[JUSTBOOST.NET]<<< EMERALD NIGHTMARE NORMAL/HC, MYTHIC+ RUNS, LEVELLING, ACHIEVEMENTS AND MORE<<<
	"justboost[%.,]net.*mythic", --[JUSTBOOST.NET]  Legion services. Leveling 100-110, PVE equip 840+, 850+ Emerald Nightmare, Glory of the Legion Hero, Mythic Dungeons and MORE<<<<
	--5% off just for today Emerald Nightmare Normal ML fast run. Start at 21:00 server time. [justboost.net]
	"normal.*justboost[%.,]ne", --WTS Emerald Nightmare normal/heroic personal loot and other pvp/pve stuff more info [justboost.ne]
	"wts.*help.*mythic.*dungeon.*gear.*info", --█ WTS █ Help with Heroic and Mythic dungeon runs and full gear - running today! /w me for info
	"wts.*le?ve?ling.*power.*farming.*info", --█ WTS █ Level 100-110 Character Leveling and Artifact Power farming - get your character ready for raiding! /w for more info
	"wts.*spot.*heroic.*raid.*loot.*spec.*invite", --█ WTS █ SPOTS in Emerald Nightmare Normal/Heroic raid next week, all loot for your spec is yours. /w to get invited!
	"wts.*help.*honor.*prestige.*season.*info", --█ WTS █ Help with PvP Honor or Prestige levels and PvP Rewards today - season is starting soon! /w for info
	"selling.*glory.*fast.*stress.*ilvl.*info", --█ Selling █ Glory of the Legion Hero - get your Leyfeather Hippogryph fast and with no stress! No ilvl requirements - /w for info
	"loot.*piloted.*today.*%d%d%d%d.*whisper", --WTS: ▌▌THE EMERALD NIGHTMARE 7/7 (MYTHIC) ▌▌LOOT RUN ▌▌ SELFPLAY/PILOTED ▌▌MASTER LOOT ▌▌TODAY 21:00 CET▌▌Whisper me! ▌▌
	"loot.*piloted.*now.*discount.*whisper", --WTS:  ▌▌ TRIAL OF VALOR 3/3 (HEROIC) ▌▌LOOT RUN ▌▌SELFPLAY/PILOTED ▌▌MASTER LOOT ▌▌RIGHT NOW! ▌▌ DISCOUNT for CLOTH, MAIL and PLATE! ▌▌ Whisper me! ▌▌
	--WTS: ▓▓ XAVIUS (HEROIC) KILL ▓▓ PERSONAL LOOT ▓▓ SELFPLAY/PILOTED ▓▓ TODAY 00:00 CET ▓▓ SUPER PRICE! Whisper me! ▓▓
	"loot.*piloted.*%d%d%d%d.*price.*whisper", --WTS: ▓▓▓▓HELLFIRE CITADEL: 13/13 (MYTHIC)! ▓▓MASTER LOOT, PILOTED!▓▓TOMORROW 20:00 CET▓▓ 100% SAFE! NEW SUPER PRICE! Whisper me! ▓▓▓▓▓▓▓▓
	--[Boostila.com] BEST PRICE FOR RAID BOOSTS,Mythic Dungeons, Character lvling, Geek Accessories and more! See on [Boostila.com]
	"mythic.*boostila[%.,]com", --[Boostila.com] BEST PRICE FOR BOOST on THE EMERALD NIGHTMARE (NM-HC),Artifact power quests farm, Mythic Dungeons, Character lvling and more!  SEE ON [Boostila.com]
	"wts.*cheap.*fast.*loot.*mythic.*dungeon.*wisp.*everyday", --WTS cheap & fast Emerald Nightmare lootraids, Mythic15++ Dungeons. Wisp! Everyday!
	"wts.*arena.*rbg.*rating.*loot.*info", --WTS Arena/Rbg ratings 1800-2400 , WTS 7/7HC emerald lootrun /w for info
	"wts.*dungeon.*fast.*prestige.*emerald.*info", --[WTS] <<New Mythic/Heroic Dungeons>> | <<Artifact farm>> | <<Fast 100-110>> | <<Honor & Prestige Leveling>> | Emerald Nightmare Normal/Heroic/Mythic Raids and more. /W for more info
	"wts.*fast.*dungeon.*rbg.*emerald.*info", --[WTS] <<Fast 100-110>> | <<New Mythic/Mythic+ Dungeons>> | <<Honor/Prestige leveling>> | <<RBG Wins> || Emerald Nightmare Normal/Heroic/Mythic Raids and more. /W for more info
	"wts.*fast.*dungeon.*pvp.*emerald.*info", --[WTS] <<Fast 100-110>> | <<New Mythic/Heroic Dungeons>> | <<Full Dungeon Gear>> | <<Full PVP Gear>> || Emerald Nightmare Normal/Heroic/Mythic Raids and more. /W for more info
	"wts.*character.*dungeon.*pvp.*emerald.*info", --[WTS] <<Character ↑↑ 100-110 ↑↑ lvl>> | <<New Mythic/Heroic Dungeons>> | <<Full Dungeon Gear>> | <<Full PVP Gear>> || Emerald Nightmare Normal/Heroic/Mythic Raids and more. /W for more info
	"wts.*lift.*dungeon.*pvp.*emerald.*info", --<<Character lift 100-110 lvl>> | <<New Mythic/Heroic Dungeons>> | <<Full Dungeon Gear>> | <<Full PVP Gear>> || Emerald Nightmare Normal/Heroic/Mythic Raids and more. /W for more info
	"wts.*boost.*dungeon.*pvp.*emerald.*info", --[WTS] <<Character boost 100-110 lvl>> | <<New Mythic/Heroic Dungeons>> | <<Full Dungeon Gear>> | <<Full PVP Gear>> || Emerald Nightmare Normal/Heroic/Mythic Runs and more. /W for more info
	"wts.*le?ve?ll?i?n?g?.*dungeon.*pvp.*emerald.*info", --[WTS] <<Character leveling 100-110 lvl>> | <<New Mythic/Heroic Dungeons>> | <<Full Dungeon Gear>> | <<Full PVP Gear>> || Soon Emerald Nightmare Runs and more. /W for more info.
	"selling.*rbg.*honor.*mount.*selfplay", --██Selling RBG 1-75wins(honor rank/Priestige),40/75wins mounts [Vicious War Trike] and  [Vicious Warstrider]self play,PST
	"selling.*mount.*honor.*gear.*accshare.*", --selling 1-75winsEarn mount +honor rank+ priestige/legendary gears 6vicious mount  ;also selling[Vicious War Trike]and[Vicious Saddle]},no acc share .PST
	"rbg.*artifact.*mount.*accshar", --▓▓WTS RBGs,1-75wins(get HR and artifact power and 6vicious mounts)[Vicious War Trike]and[Vicious Saddle]right now,no accshare▓PST
	"heroic.*amazingprice.*strong.*group.*gua?rantee.*drop.*spot", --Wts Emerald nightmare Heroic 7/7 clear for amazing price with strong guide groupe we gurantee you Full heroic loot that drop for your class on tonight 19:00 st only 2 spots ! w me for more infos.
	--WTS Mythic + KEY~/+2/+3/+6/+8/+9/+10 key,write me for info.
	"wtsmythic.*key.*%d/%d/%d.*write.*info", --WTS Mythic + KEY~/+2/+3/+6/+8/+9/+10 /Write me for info.
	"mythicstore[%.,]com.*skype", --For more details visit https://mythic-store.com , or write in skype: mythic-store
	"wts.*tonight.*arena.*rbg.*mythic.*coaching", --WTS Emerald Nightmare 7/7 MYTHIC with ML tonight , 1 spot for now / Arena/RBG/Mythics/Coaching /w for info
	--Legion 139Toman Game Time 30Toman Gold har 1k 450Toman Level Up ham Anjam midim |Web: www.iran-blizzard.com  Tel: 000000000000
	"legion.*gametime.*iranblizzard[%.,]com", --Legion 140T - Game Time 30Day 35T - 60Day 70Toman - www.iran-blizzard.com
	--=>>[www.bank4dh.com]<<=19E=100K. 5-15 mins Trade. More L895   Gears for sale!<<skype:bank4dh>> LVL835-870 Classpackage  Hot Sale! /2 =>>[www.bank4dh.com]<<=
	"bank4dh.*skype", --=>>[www.bank4dh.com]<<=32U=100K. 5-15 mins Trade. More More cheapest   Gears for sale!<<skype:bank4dh>> LVL835-870 Classpackage  Hot Sale! Buy more than 200k will get 10%  or [Obliterum]*7 or  [Vial of the Sands]as bounes   [www.bank4dh.com]
	"bank4dh.*%d+k", --=>>[www.bank4dh.com]<<=19E=100K. 5-15 m
	"trusted.*bank4dh", --WTS BOE class set, 860 Six-Feather Fan, Best BOE gears for rading and alt [lvling.Trusted] seller,K+ feedback from OC. Plz vistor www bank4dh com Cheaper than AH.
	"wts.*mythic.*powerle?ve?l.*glory.*info", --▲ WTS RUN in Emerald Nightmare (Normal or heroic) TODAY ▲ Mythic+ ▲ Power leveling 100-110 ▲ All Glory ▲ we have a lot runs every day ▲ and more other ▲ /W for more information ▲
	"perfectway[%.,]one.*prestige", --(Perfectway.one) Dungeons Mythic/ Mythic+, EN normal/heroic, PvP PRESTIGE RANKS (Perfectway.one)
	"rbg.*mount.*prestige.*accshare", --███WTS RBG40&75wins/Vicious Saddle/all 6 vicious mounts/honor rank/prestige[Vicious War Trike]and[Vicious Warstrider]no acc share,carry right now/w me
	"mythic.*boostinglive.*faster", --Mythic dungeons, Heroic raids, and more on [boostinglive.com] !Dress up your character faster than others!
	"koroboost.*everyday.*mythic", --Top guild "Koroboost" inviting you everyday from 1:00 pm CET  to mythic/mythic + dungeons. Became [Brokenly Epic] within 4 hours. Msg me!
	"doyouwant.*level110.*12h.*noproblem.*msgme.*info", --Do you want [Level 110] within 12h? No problem, Msg me for info ♥♥
	"gamesales[%.,]pro.*service.*arena", --[Gamesales.pro] - an assistance in PvP and PvE services: starting from training and ending with achievement of the highest ranks in the arena. [Gamesales.pro-] an opportunity to get the best in a short time. Find out more at [http://www.gamesales.pro]
	"rbg.*artifact.*honor.*mount.*carry", --█░█WTS RBG 1-75wins(Artifact Power+Honor Rank)6Vicious mount[Vicious Saddle]also[Reins of the Long-Forgotten Hippogryph]carry u right now ▲PST
	"^wtspowerleveling.*fast", --WTS Powerleveling (Fastest available)
	"help.*le?ve?ling.*demonboost[%.,]com", --Helping with lvling 100-110. Emerald Nightmare, Return to Karazhan, Mythic+ dungeons. [Demon-Boost.com]
	"fast.*leveling.*honor.*в[o0][o0]st", -- ►►►Fastest leveling 100-110 (6-12 hours), 850+ gear, Honor Ranks and MUCH MORE on [RРD-В00SТ,С0М]◄◄◄
	"^wtsmythickarazhandungeons[,.]*whispme", --WTS Mythić+ & Kârazhan Dungeøns. Whísp me.
	"^wtskarazhanboost[,.]mythic.*mythicdungeons?boost.*info", --WTS Karazhan boost, Mythic+ CHEST RUN, Mythic dungeons boost. /w for info
	"^wtskarazhan[,.]mythic.*mythic+dungeon$", --WTS karazhan. mythic and mythic+ dungeon
	"^wtsboostkarazhan[,.]mythic[,.]mythicdungeon", --WTS boost karazhan. mythic. mythic+ dungeon
	"^wtskarazhan.*,mythic.*mythicdungeons?boost$", --WTS Karazhan,Mythic+,10/10Mythic dungeon boost
	"^wtsemeraldnightmaremythiclootrun.*mlselfplay.*price.*gold", --WTS EmeraldNightmare Mythic lootrun (ML+selfplay) , price in gold : 4000k
	"^wtsemeraldnightmaremythiclootrun.*mlselfplay.*20.*realmtime", --WTS EmeraldNightmare Mythic lootrun (ML+selfplay) 20.00 realm time
	"^wtsmythicemeraldnightmare.*20.*realmtimeml", --Wts Mythic Emerald NIghtmare tonigth 20.00 realm time (ML) /w
	"rbg.*boost.*2200.*yourself.*account.*sharing.*info", --{RBG PUSH} Wts RBG Boost /1800/2000/2200/HOTA . You play yourself/NO account SHARING /w for more info  :)
	"rbg.*honor.*priestige.*mount.*selfplay", --WTS RBG 1-75wins(honor rank/Priestige),6RBG mounts[Vicious Saddle]and BOP mount[Reins of the Long-Forgotten Hippogryph]},self play .PST
	--[TOPBOOST.PRO] - WTS HEROIC EN (PL) at 18.00 Server time. MYTHIC +10. KATAZHAN RUN and MORE
	-->>> [TOPBOOST.PRO] <<< EMERALD NIGHTMARE HEROIC, NORMAL, MYTHIC+ RUNS, ACHIEVEMENTS AND MORE! DISCOUNTS ON MYTHIC EMERALD NIGHTMARE!
	"topboost[,.]pr.*mythic", --[TOPBOOST.PRO] - , HEROIC EN - 180 EURO (ML). HEROIC PL - 90 EURO.  MYTHIC +10 180 EURO
	"powerle?ve?l.*yourspuregame[,.]com", --EN Myth/HC lootRuns,Karazhan,Powerlevling,Mounts,Myth+Boosting and more in >>> www.yourspuregame.com <<<
	"xperiencedparty.*runs.*walkthrough.*mythic.*glory.*karazhan", --xperienced party 880+ (more than 45 runs) will help you to walkthrough mythic, mythic+, Glory of the Legion Hero, Karazhan.
	"wh?isp.*skype.*igor.*price", --Wisp in Skype [] for Detal/Prices.
	"elitistgaming[,.]com.*mount", --Elitist-gaming,com Selling Emerald Nightmare on ALL difficulties, [Ahead of the Curve: Xavius]MYTHIC + dungeons and NIGHTBANE MOUNT, all self play  & more whisper for schedules
	"instant.*delivery.*purchase.*gold.*extra", --Instant delivery!!Purchase 100k gold get extra 10k or  [Obliterum]*4! 200k get  [Obliterum] *10!! w me
	"promotion.*order.*gold.*coupon.*code", --Halloween Promotion!! Order gold from our site, and u will get  [Obliterum] or 10% gold for free!!! w me get coupon code!Happy Halloween^^!!!
	"juststarted.*leveling.*twink.*gear.*dungeon.*more", --● Just Started The Legion or leveling a twink ? Need To Gear Up ? Try Our Karazhan, Emerald Nightmare N/HC/M, Dungeons+ Runs and More ●
	"wts.*saddle.*carry.*hour.*start.*info", --█ [WTS] Vicious saddle. 100 3v3 wins carry just in 3 hours. We can start right now, whisper me for information █
	"getgearup.*karazhan.*nightmare.*dungeons.*runs.*more", --● Get gear up  ►►► Karazhan, Emerald Nightmare N/HC/M, Dungeons+ Runs and More ●
	"wts.*mythic.*master.*loot.*mythic.*details.*private", --EN WTS Mythic/HC Master - Loot, Karazhan, Mythic+ and more in >> details private messeng
	"wts.*nightmare.*boosting.*loot.*mythic.*glory", --WTS Emerald Nightmare Mythic/Heroic/Normal boosting +loot, Karazhan boost, Mythic Keystone Boost 1-10+lvl, Mythic dungeons boost, Glory of the Legion Hero
	"skype.*landroshop", --WTS [Keystone Conqueror] (2-10 lvl) and Karazhan, fast, smooth and fair. Details in skype: Landroshop
	"pewpewshop.*loot", --[WTS] [►►►PewPewShop.Pro] — Emerald Nightmare Mythic with loot and selfplay! ►►► Mythic dungeons+, Karazhan time run with loot and mount!►►►
	"wtskarazhan.*timerun.*mount.*mythic.*dungeonboost", --WTS Karazhan8/8,Timerun with 100% mount,Mythic+,10/10Mythic dungeon boost
	--▄▀▄ WTS Artifact Leveling █ Emerald Nightmare Loot Runs █ Karazhan & Mythic+ Dungeons █ [Vicious Saddle] + Honor 1-50 + Prestige █ [Conquest-Capped.com] ▄▀▄
	"saddle.*conquestcapped[%.,]com", -- ▄▀▄ WTS Full Conquest Cap █ [Vicious Saddle] + 27,000 Conquest Points █ [Conquest-Capped.com]█ /w to get 5% discount ▄▀▄
	"^wts.*good.*fast.*powerle?ve?l", --WTS good and fast power leveling
	"service.*mythic.*raid.*pay.*price", --▲▲▲/GUILD SERVICE/-/Emerald Nightmare/-/Mythic+/-/Trust raids-pay after b00st/-/RAID TODAY/-/Best prices/-/No resell. And many more   ▲▲▲
	"wts.*karazhan.*mount.*nightmare.*hc.*dungeon.*run.*more", --● WTS  ►►► Karazhan(mount+), Emerald Nightmare N/HC/M, Dungeons+ Runs and More ●
	"offer.*honor.*prestige.*boost.*pvp.*mount", --Offer Honor and Prestige boosts : Unlock all PvP talents, 840-870 PvP gear, mounts, artifact power & appearance and a lot more ! /w me for more détails !
	"brb2game.*sale", --=>>www.brb2game.com<<=28$=100K 5-15 mins Trade.CODE:USWOW  More L895   Gears for sale! LVL835-870 Classpackage  Hot Sale! /2 =>>www.brb2game.com<<=
	"^wtsemeraldnightmare.*heroic.*pl.*tonight.*8.*fastrun.*highquality", --WTS EMERALD NIGHTMARE 7/7 Heroic with PL. Raid tonight at 8 pm. Fast run. High quality.
	"elitegamerboosting[%.,]de.*skype", --Return to Karazhan! Organisiere dir durch und mit uns einen unbeschwerten Ausflug in die neue Instanz - Erfolge, Loot und Mount inklusive! Alle Angebote auf [elite-gamer-boosting.de] | Skype: [real.elite.gamer] | Ab sofort 3% sparen mit dem Code: SIMON
	"wts.*nightmare.*mythic.*loot.*dungeon.*pvp.*glory", --►►►[WTS] The Emerald Nightmare Mythic/Heroic/Normal with loot, Mythic+ dungeons,► PvP help◄, Glory of the Legion hero & more!◄◄◄
	"juststarted.*legion.*gearup.*karazhan.*nightmare.*dungeon.*more", --Just Started The Legion ? Need To Gear Up ? Try Our KARAZHAN, EMERALD NIGHTMARE, +DUNGEONS AND MORE runs WTS!
	"bestboost[%.,]club.*service", --►►► [[BESTBOOST.CLUB]] - 100-110 BOOST, MYTHIC AND MYTHIC+ DUNGEONS 10/10, THE EMERALD NIGHTMARE RAID NORMAL/HEROIC/MYTHIC, RETURN TO KARAZHAN AND OTHER SERVICES [[BESTBOOST.CLUB]] ◄◄◄
	"%d+k.*giveaway.*guild.*selling.*karazhan.*mount.*mythic.*dungeon.*nightmare.*raid", --100K weekly giveaway from our guild! By the way we are selling Karazhan with mount, Mythic Dungeons+, Emerald Nightmare raids
	"l[o0][o0]tcl[o0]ud.*b[o0][o0][s5]t", --▲▲▲■■■LFB?>-L00tcl0ud?c0m?-GUILD B005T/-/EN HC 69e/-/Mythic+/-/Trust raids/Karazhan/-/Best offers/ And many more here-?L00tcl0ud?com?   ▲▲▲■■■
	"wtskara.*fasttimerun.*guarantee.*mount", --WTS KARAZHAN // fast time runs with guaranteed awesome MOUNT! /w me for more info.
	"wtsarena.*boost.*2%.?200.*2%.?400.*gladiator.*info", --WTS ARENA BOOST // 2.200 // 2.400 // 2.600 // 2.800 // GLADIATOR / /w Me for more info!
	--««WTS Emerald Nightmare Mythic/Heroic/Normal with Master Loot, Quick Raids everyday! Write me for info»
	"wts.*nightmare.*mythic.*master.*loot.*quickraids.*everyday.*write", --««WTS Emerald Nightmare Heroic/Mythic with Master Loot or Personal, Quick Raids everyday! Write me for info»»
	"2.*2%.4.*glad.*le?ve?ling.*100110.*info$", --B00st 2k/2.4+ 3s 2s, (glad/r1), Leveling 100-110, Want to get 2/2.2k+ playing yourself with r1? /w me for more info
	"2.*2%.4.*glad.*coach.*100110.*info$", --B0ost! Help 2.2/2.2/2.4, (glad/r1), Coaching from glads, Leveling 100-110 /w me for more info
	"arena.*2%.4.*2.*glad.*teammates.*push", --Arena 2k/2.4/2.7+ (glad, r1), cant find teammates for push rating? /w me
	"b[o0][o0]st.*2%.4.*2.*glad.*livestream.*info$", --B0ost 2.2/2.4/2.7+ (glad, r1), live streams, cant find teammates for push rating? /w me for info
	"b[o0][o0]st.*2%.4.*2.*glad.*selfplay.*info$", --B0ost 2k/2.4/2.7+ (glad, r1), Want get 2k or more selfplay? /w for info
	--B0ost arena 2.2/2.4/2.7+ (glad, r1), live streams, cant find teammates for push rating? /w me for info
	"arena.*2%.4.*2.*glad.*livestream.*info$", --B0ost arena 2.2/2.4/2.7+ (glad, r1), live streams, Want get 2k or more selfplay? /w me for info
	"wtsemeraldnightmarelootraids.*heroic.*mythic.*dungeons.*wisp$", --WTS Emerald Nightmare lootraids, Heroic/Mythic Dungeons. Wisp!
	"wts.*mythic.*boosting.*loot.*keystone.*dungeon.*glory", --WTS EN and Trial of Valor Mythic/Heroic/Normal boosting +loot, Karazhan boost, Mythic Keystone Boost 1-10+lvl, Mythic+ dungeons chests runs,  Mythic dungeons boost, Glory of the Legion Hero
	"selling.*professional.*team.*mount.*loot", --Selling <<Mythic+>>/<<Karazhan(mount)>>/<<EMERALD NIGHTMARE heroic>> by a professional team! Come get your mount and loot! Going Now pst for detail
	"^wtslegiondungeons.*mythic,karazhan$", --WTS Legion dungeons(myhic,mythic +),karazhan
	"wts.*valor.*lootrun.*mythic.*mount.*prestige", --[WТS] Trial of Valor normal & heroic lootrun; Emerald Nightmare Mythic/Heroic/Normal with loot; Karazhan lootrun+mount, Mythic+ dungeons,► Honor & Prestige lvl◄ & more! /w for info!◄◄◄
	--Hello! Offer 2000/2200/2400, (glad/r1), Coaching from glads, Leveling 100-110 /w me for more info
	"hello.*2200.*glad.*le?ve?ling.*info", --Hello! Offer 2000/2200/2400, (glad/r1), Leveling 100-110, Want to get 2k+ playing yourself? /w me for more info
	"karazhanmount.*nightmareruns.*spotsleft.*contact.*details$", --Karazhan mount, Emerald Nightmare runs. Few spots left! Contact for more details
	"trial.*karazhanmount.*nightmareruns.*spotsleft.*contact.*details$", --Trial of Valor, Karazhan mount, Emerald Nightmare runs. Few spots left! Contact for more details
	"wts.*heroic.*raid.*fast.*quality.*discount.*selfplay", --WTS EMERALD NIGHTMARE 7/7 Heroic with PL. Raid right now. Fast run. High [quality.Discount] for selfplay tonight!!!
	"^wts.*emeraldnightmare.*masterloottoday.*cheapandfast.*whisperme$", --WTS the Emerald Nightmare 7/7 HC Master Loot today,cheap and fast,whisper me
	"wtsrbg.*wins.*mount.*carry.*reins", --█ █WTS RBG 1-75wins(AP+HR)6Vicious [mount.carry] u right [now.also][Reins of the Long-Forgotten Hippogryph]and[Voidtalon of the Dark Star]█PST
	"^wts.*viciousmounts.*saddle.*star.*getrightnow", --Wts 6vicious mounts[Vicious Saddle]/[Voidtalon of the Dark Star]}get right Now! /Pst
	"wts.*today.*nightmare.*lootrun.*masterloot.*bestprice", --WTS: |=Today EMERALD NIGHTMARE MYTHIC Lootrun (7/7)||Master Loot|| Best Price!!!
	"wts.*valor.*lootrun.*mount.*mythic.*glory", --WTS: |=TRIALS OF VALOR N/HC=|=KARAZHAN Lootrun+Mount=|=Mythic+ Dungeons=|=Glory of the Legion Hero=|W/me!!!
	"^wtsgamingservices.*pve/pvp.*write.*info", --WTS gaming services in PvE/PvP write me for info
	"^wtsenandtov.*mythic.*heroic.*boosting.*loot.*karazhan.*dungeonsboost", --WTS EN and ToV Mythic/Heroic/Normal boosting +loot, Karazhan Boost, Mythic+ Dungeons Boost
	"gold.*g4game[%.,]c[o0]m", --WTS 60000 Gold=$20----------------------------- WWW.G4GAME.C0M.-----------------------------Buy Now
	"gold.*g[o0]ldce[o0][%.,]c[o0]m", --Sell Cheap Gold Welcome to WWW.G0LDCE0.C0M    WWW.G0LDCE0.C0M  WWW.G0LDCE0.C0M    WWW.G0LDCE0.C0M
	"^onespotleft.*nightmare.*mythicboost.*clear.*loot.*amazingprice.*raidstarts", --"one spot Left"Wts Emerald nightmare Mythic boost 7/7 clear including 8-12 loot Minimum for amazing price , raid starts at 15:00 st ! w me
	"trial.*valor.*nightmare.*myth.*karazhan.*powerleveling.*muchmor", --TRIAL OF VALOR, EMERALD NIGHTMARE HC/MYTH, KARAZHAN, POWERLEVELING, MYTH+ AND MUCH MOR >>>
	"^wts.*nightmare.*mythicboost.*clear.*loot.*amazingprice.*raidstarts", --Wts Emerald nightmare Mythic boost 7/7 clear including 8-12 loot Minimum for amazing price , raid starts at 18:00 st! w me .
	--Doing Honor and Prestige boosts : Unlock all PvP talents, 840-870 PvP gear, PvP Saddle, artifact power & appearance and a lot more ! visit [www.prestige-wow.com] for more details !
	"boo+sl?t.*talents.*prestigewow[%.,]c", --Offering Honor and Prestige boosts : Unlock all PvP talents, 840-870 PvP gear, mounts, artifact power & appearance, golds and a lot more ! With [www.prestige-wow.com1]
	"wts%d+kgoldfor%d+eu", --WTS 800k GOLD FOR  35 EURO NOW !
	"skype.*vf3399", --[5000+ forums vouches]wts virtual currency 0.23$/k,safe gold guaranteed,mmogoldbay.NET,{laugh} my skype is vf3399
	"wtskarazhanwithmount.*mythicdungeons.*valor.*nightmare", --BLACK FRIDAY SALES! DON'T MISS IT! WTS Karazhan with mount, Mythic Dungeons+, Trial of Valor, Emerald Nightmare raids
	"loot.*mount.*mythic.*dungeons.*ask", --►►► [WТS] ► Trial of Valor Normal/Heroic with loot ► Emerald Nightmare Heroic/Mythic with loot ► Karazhan lootrun + mount ► Mythic+ 0-15 lvl dungeons - TUESDAY SALE 20% OFF ◄ ask me to get more info!
	"sale.*mount.*loot.*mythic.*dungeons", --►►► [WТS] ► SUNDAY Sale! Karazhan lootrun + mount 20% OFF► Trial of Valor Normal/Heroic with loot ► Emerald Nightmare Heroic/Mythic with loot ► Mythic+ 1-15 lvl dungeons ◄ ask me to get more info!
	"wts.*mythic.*lootrun.*master.*fast.*cheap.*ready.*info", --[WTS] Now Emerald Nightmare Mythic Lootrun!Master Loot!Fast and Cheap!Ready to go in 15 min,/w me for more info
	"selling.*nightmare.*heroic.*masterloot.*boost.*server.*info", --Selling Emerald Nightmare Heroic Masterloot boost, tomorrow at 19:00 server time, /w me for more info!!
	"trial.*speedruncharacter[%.,]net", --WTS BEST OFFERS EMERALD NIGHTMARE HC/MYTH,TRIAL OF VALOR, KARAZHAN,MYTH+ AND MUCH MORE SALE START [SPEEDRUNCHARACTER.NET]
	"wts.*xavius.*boost.*completed500.*curve.*%d+.*me.*info", --WTS HC Xavius boost we completed 500+ run take your curve next run 16:40 server time /w me more info !!
	"^wtsenmythiclootruntonight.*goldpossible.*w", --WTS EN Mythic Lootrun tonight (ML, gold possible) ./w
	"^wts.*keystoneconqueror.*karazhan.*fast,smoothandfair.*whisp", --WTS [Keystone Conqueror] (2-12 lvl) and Karazhan, fast, smooth and fair. Whisper for more info.

	--[[ Chinese ]]--
	"ok4gold.*skype", --纯手工100-110升级█翡翠英雄团█5M代刷 大秘境2-10层（橙装代刷）█代刷神器点数 解锁神器第三槽█金币20刀=10w█微信ok4gold█QQ或微信549965838█skype；gold4oks█微信ok4gold█v
	"qq.*549965838", --金币最低价20刀10w 微信ok4gold   微信或者QQ549965838 微信ok4gold  百万库存20刀=10w 百万库存20刀=10w QQ或者微信549965838 微信ok4gold  微信或者QQ549965838 微信ok4gold
	"qq.*1505381907", --特价[Reins of the Swift Spectral Tiger]，金币28刀十万，量大优惠。等级代练，大秘境(刷橙装），荣誉等级(送坐骑），翡翠团本代练;,QQ:1505381907或者微信：babey1123
	"qq.*593837031", --纯手工100-110 低价，大秘境1-10层热销中，翡翠梦境英雄普通包团毕业。橙装，神器三插槽，金币大量，感兴趣的联系QQ:593837031 skype:wspamela 微信 593837031
	"100110.*q228102174", --100-110纯手工升级低价热卖，无敌飞机头 ，星光龙热卖1-2周保证拿到，，翡翠梦魇普通包团毕业火热销售中,职业大厅，神器点数，神器解锁三插槽 [，金币大量QQ228102174,微信894580231。skype.raulten1234]
	"style.*强力销售.*%d+lvl.*100110", --style公会团强力销售825等级英雄5人本毕业840LVL史诗5人本毕业英雄史诗翡翠865 880+装备，手工100-110等级加神器任务和大秘境代打欢迎预定
	"100110.*苏拉玛任务.*星空龙", --纯手工90-100-110任务升级（任务全做，开启声望）。苏拉玛任务11/8。神器三插槽。荣誉50等级~（送邪气鞍座）。军团6大声望 [~手工金币30刀十万，现货秒发。200MB=10万.星空龙~无敌] 飞机头 1-2CD必出
	--小号代练--翡翠英雄本特价大秘镜3箱(橙装代刷),苏拉玛任务，堕落精灵声望，神器点代刷，解锁神器第三插槽,金币169=10万需要微信17788955341
	--***大秘境12层保底885特价+++微信17788955341 ***超效率便宜翡翠H团***卡拉赞坐骑***金币159十万
	--出售[Reins of the Swift Spectral Tiger].,.金币179RMB=10W,899RMB=500K.QQ微信17788955341
	"微信.*17788955341", --特价Six-Feather Fan-,六禽羽扇855/860特价,179RMB=10万,99刀=40万--11层大秘境《刷橙》,翡翠英雄团,KLZ梦魇龙,成就声望另售幽灵虎微信/QQ: 17788955341
	"qq.*1433535628", --N/H翡翠梦境包团毕业， 大秘境（刷箱子刷橙装 ）， 地下城， 荣誉解锁送神器点数 ，装绑装备和材料以及各种坐骑， 金币和飞行解锁。欢迎咨询QQ:1433535628  skype：forgotmylove
	--低层三箱刷橙 10层低保，新开11层12层低保 KLZ梦魇坐骑和全通 需要的加Q 1292706134
	"低层三.*q1292706134", --大酋长团队 接大秘境维护1-10层，低层三箱刷橙，团本毕业，等级100-110，需要的加QQQ1292706134
	"微信.*sesegold", --特价大小老虎,鸡蛋军马各TCG长期供货,金币169RMB=10万,98-110等级代练,大秘境保底,翡翠梦境H/M包团,5M代刷套餐特价-需要微信sesegold
	"%d+.*万金.*支付宝", --100人民币=10万金，有30，个人出售，支付宝微信，骗子移步
	"qq.*2278048179", --特价[Six-Feather Fan]850等级 金币32刀 10万 现货秒发。。大小老虎卡牌坐骑。 十年信誉品牌 欢迎咨询 QQ: 2278048179
	"金.*778587316", --亲，出售金币,10w29刀，-专业快速代练100-110 纯任务升级**苏拉吗9/11,解锁世界任务，神器三槽，，代练声望，翡翠梦境包团，重返卡拉赞+梦之魇坐骑，pvp邪气鞍座等微信：mia11125 Q778587316
	"100110.*送坐骑.*tiger", --100-110级纯手工练级------G币28刀十万,现货秒发；荣誉等级(送坐骑），大秘境刷箱子（橙装掉率很高），翡翠梦境团本，大小tiger坐骑有需要的M我
	"100110.*币.*幽灵虎", --纯手工100-110升级    G币20刀十万    翡翠英雄团 5M代刷 大秘境2-10层（橙装掉率很高） 卡拉赞前置任务代做 卡拉赞副本通关 代刷神器点数 解锁神器第三槽 苏拉码任务8/11  大小幽灵虎，有需要的M
	"^marine.*在秒回", --Marine5人本类业务，卡拉赞，5Mx10 大秘境10层低保ilvl880 及大秘境15层幻化解锁-----人在秒回
	"881.*安全便宜快速.*ip", --881装等双橙大号出售自营AH绿色G，安全便宜快速，非工作室黑G，北美IP交易，买G最重要就是安全！全场最低 要的速M 人在就10分钟！
	"特价出售黄金.*稀有坐骑", --特价出售黄金，等级代练纯手工，荣誉等级(送坐骑），大秘境刷箱子（橙装掉率很高），翡翠梦境团本，稀有坐骑有需要的MMMMMMM
	"200万手工金币.*paypal", --→→活动促销200万手工金币2.8刀1万 低价甩~ 买的多还送坐骑 安全 效率 要的老板密→支持淘宝、paypal 多种付款 薄利多销 另售卡牌坐骑 承接各种代练
	"qq.*153874069", --华哥超低黄金27刀10万安全效率 大小幽灵虎坐骑请咨询 承接各种代练 支持淘宝、paypal 多种付款+微信QQ：153874069
	"qq.*3450345", --PGP工作室 H翡翠包团200刀可单买，团长分配保证6+拾取，新客户可免费再带一周。100-110代  练纯手工快速 12小时，代清世界任务，卡拉赞坐骑，联系QQ或微信都是 3450345
	"练级.*bearwow[,.]com", --承接WOW 100-110练级、大秘境、卡拉赞、世界任务、神器外观、神器第三槽解锁等,纯手工，市场最低价，请登陆网站：w w w.bearwow.c o m
	"100110.*手工金币.*%d+mb=%d+", --绝对纯手工100-110任务升级（任务全做，开启声望）。苏拉玛任务11/8。神器三插槽。荣誉50等级~（送邪气鞍座）。军团6大声望 ~手工金币26刀十万，现货秒发。170MB=10万
	"出售特价金.*双11金币大甩卖", --出售特价金  20 for 100K    11.11    11.11 出售特价金  20 for 100K    11.11    11.11    11.11出售特价金  20 for 100K    双11金币大甩卖，需要的M  11.11    11.11 出售特价金 11.11
	"出售特价金.*100110", --出售特价金  20 for 10W    纯手工100-110升级 翡翠英雄团 5M代刷 大秘境2-10层（橙装掉率很高） 卡拉赞前置任务代做通关 代刷神器点数 神器三槽  星空龙 无敌 飞机头 大小幽灵虎，需要mmmmm
	"特价出售金.*稀有坐骑", --特价出售金25for100K，等级代练纯手工，神器点数，荣誉等级(送坐骑），大秘境刷箱子（橙装掉率很高），翡翠梦境团本，稀有坐骑等等业务，需要的mmmmmm
	"黄金.*神器点数.*稀有坐骑", --黄金25刀10万，等级代练纯手工，神器点数，荣誉等级(送坐骑），大秘境刷箱子（低层掉橙装和高层拿低保），苏拉玛1-8章,翡翠梦境团本代练，稀有坐骑,需要的mmm
	--特价[Reins of the Swift Spectral Tiger]，金币25for100K，等级代练纯手工，荣誉等级(送坐骑），大秘境刷箱子（橙装掉率很高），翡翠梦境团本，稀有坐骑,需要的mmmmmmm
	--特价[Reins of the Swift Spectral Tiger]，金币25刀10万，等级代练纯手工，神器点数，荣誉等级，大秘境刷箱子，苏拉玛1-8章,翡翠梦境团本代练，稀有坐骑,需要的mmm
	"特价.*tiger.*稀有坐骑", --特价[Reins of the Swift Spectral Tiger]，黄金,26for100K，等级代练纯手工，荣誉等级(送坐骑），大秘境刷箱子（橙装掉率很高），翡翠梦境团本，稀有坐骑,需要的mmmmmm
	--出售特价金  20 for 100K    纯手工100-110升级 翡翠英雄团 5M代刷 大秘境2-10层（橙装掉率很高） 卡拉赞前置任务代做通关 代刷神器点数 解锁神器第三槽 苏拉码任务8/11  大小幽灵虎，需要M我
	"出售特价金.*%d+for%d+k.*100110", --出售特价金  20 for 100K    纯手工100-110升级 翡翠英雄团 5M代刷 大秘境2-10层（橙装掉率很高） 卡拉赞前置任务代做通关 代刷神器点数 神器三槽 特价Reins of the Spectral Tiger，需要M我
	"拿任意橙.*神器三槽.*110", --2层箱子热卖,脱非入櫛§，不在遥远.无限2箱,拿任意橙督。 8-10层大秘境,箱子+周奖励,快捷提升袛等.H梦魇包团,毕业,] 个人拾取热销中。神器三槽,110等级代练,苏拉玛任务声望代练接单.
	--100-110手工任务，清世界任务，荣誉等级（送坐骑），825装等毕业，5人M本840+毕业。神器三槽。大密境，苏拉玛1-8章，翡翠梦境团本。各种稀有坐骑~金25刀10万。
	"100110.*神器.*金", --纯手工100-110，世界任务~神器三槽~苏拉玛11/8。荣誉等级（送坐骑），金币-26刀10W。星空龙~无敌 飞机头。
	"qq.*100845995", --●橙装必备(大秘境无限刷低层箱子)√●提升装等必备(850-885装绑)√●长期在售 大秘境高层保底/卡拉赞坐骑/翡翠梦境(H/M)+勇气试炼团本/稀有坐骑~ 欢迎各wower老板咨询QQ:100845995 微信:446298161
	"100110.*%dv%d.*神器点数", --100-110快速练级，荣誉等级50解锁，3v3马鞍，卡拉赞坐骑H翡翠包团毕业，8到10层大秘境拿2箱奖 励和低保，快速提升装等。2-3层无限刷橙子和神器点数需要的M
	"解锁橙色物品.*欢迎咨询购买", --苏拉玛声望尊敬要塞科技第六层，解锁橙色物品（可以多带一个橙色备），包含解锁神器第三插槽 世界任务大秘境2-3层3箱子无限刷包橙业务，欢迎咨询购买
	"业定制神器.*种最低价坐骑控", --H，M翡翠梦魇包团加支持自己上号毕业定制 神器维护加绝版坐骑T3黑市代秒各种版本成就龙坐骑,3大秘境高层2-3层3箱子无限刷，卡牌坐骑 ，各种最低价坐骑控M
	"作室强力销售.*840.*100110", --精英工作室强力销售825等级英雄5人本毕业840LVL史诗5人本毕业英雄史诗翡翠865 880+装备，手工 100-110等级加神器任务和大秘境代打欢迎预定
	"游戏业务专卖.*金币.*送坐骑", --游戏业务专卖，金币25刀=10万，等级代练纯手工，神器点数，荣誉等级(送坐骑），大秘境刷箱子（低层掉橙装和高层拿低保），苏拉玛1-8章,英雄，史诗翡翠梦境团本代练，稀有坐骑,需要的联系
	"感恩节大甩卖金子.*橙装掉率很高", --感恩节大甩卖金子 翡翠英雄团 5M代刷 大秘境2-10层（橙装掉率很高） 卡拉赞前置任务代做通关 代刷神器点数 神器三槽  星空龙 无敌 飞机头 大小幽灵虎，感恩节大甩卖金子，金子感恩节大甩卖
	"送坐骑.*金%d+刀%d+万", --等级代练纯手工任务，KLZ龙，荣誉等级（送坐骑），神器三槽。5人H-M本毕业。大密境（刷箱子），苏拉玛1-8章，KLZ龙，翡翠梦境团本最低价。星空龙，无敌，飞机头。金25刀10万。

	--[[  Spanish  ]]--
	"oro.*tutiendawow.*barato", --¿Todavía sin tu prepago actualizada? ¡CÓMPRALA POR ORO EN WWW.TUTIENDAWOW.COM! ¡PRECIOS ANTICRISIS! ¡65KS 60 DÍAS! Visita nuestra web y accede a nuestro CHAT EN VIVO. ENTREGAS INMEDIATAS. MAS BARATO QUE FICHA WOW.

	--[[  French  ]]--
	"osboosting[%.,]com.*tarifs.*remise", --☼ www.os-boosting.com ☼ Le meilleur du boosting WoW à des tarifs imbattables. Donjons mythique 10/10 - Raids Cauchemar d'Emeraude 7/7 Normal & Héroïque - Métiers 700-800 - Pack 12 Pets TCG - Réputations Legion - Gold   | Code remise 5%: OS5%
	"wallgaming.*loot.*keystone", --¤ www.WallGaming.com ¤ Raids Cauchemar d'Emeraude HM 7/7 6 loots/+ | Gloire au héros de Legion | Donjons Mythique 10/10 +5keystone | Arène 2c2 3c3 2000 & 2200 | Honneur PvP niveau 50 | Pets & Montures TCG |  N°1 FR
	"profitez.*loot.*wallgaming", --☺♥ Profitez des dernières nouveautés de Legion maintenant  ♥☺ Cauchemar d'Emeraude HM Master Loot | Gloire au héros de Legion | Donjons Mythique+ / Karazhan 9/9 Mythique | Selle Vicieuse | Stuff PvE & PvP | www.wallgaming.com  Team FR
	"gold.*site.*prestigewow[%.,]fr", --Propose PL Honneur et Prestige ; Débloque tous les talents pvp, équipement 840-870 ilvl, monture, puissance d'artefact & nouveau skin pour l'arme artefact, gold et bien plus encore ! Visitez notre site web : www.prestige-wow.fr pour plus d'infos !

	--[[ Danish ]]--
	"^sælgerguldfor%d+", --sælger guld for 170kr pr. 100k (w for andre servere)
	"^sælgerg[ou]ld.*mobilepay", --Sælger guld, forgår over mobile pay, 100k - 150 kr
	"tilbud.*sælger%d+k.*mobilepay", --Dagens tilbud: Sælger 200 K for blot 280 kr - whisper for mere info: Mobilepay & Swipp
	"^sælgerguld.*skype", --Sælger guld 20k 33kr og 100k til 149kr, skype ...
	"sælgerlidtguld.*mobilepay", --Hej, jeg sælger lidt guld via. mobilepay. Tilbud : 100k for 150kr , 250k for 350kr - Skriv for mere info. :)
	"^sælgerg.*%d+kr?pr", --sælger g / w 1k pr. 1k

	--[[ Swedish ]]--
	"saljerguld.*detail.*stock", --Säljer guld 1.7kore details Stock: 3000k
	-->>>>Säljer Guld Via Swish!<<<<
	--Säljer guld via Swish! 130kr / 100k Leverans direkt!
	--Säljer guld via Swish. 1,3kr per 1k alltså 130kr för 100k. Snabbt och smidigt. /w för mer info.
	--Säljer guld via swish, /w vid intresse!!
	--Säljer Guld Via Swish! /w mig!
	"^saljerguldviaswish", --Säljer guld via swish 135kr för 100k /w för mer info eller adda Skype Dobzen2
	"^saljergviaswish", --Säljer g via swish 1.7kr per 1k /w mig =D [minsta köp 50k]
	"^saljerguldsnabbtviaswish", --Säljer guld snabbt via Swish 100k=170SEK 1.7kr/1000g Billigare vid bulk  /Whispra mig och chilla på svar
	--köper wow guld via swish
	"^koperw?o?w?guldviaswish", --Köper guld via swish
	"guld.*salu.*swish.*info", --Guld finns till salu via SWISH, /w för mer info
	"^saljerwowguld.*viaswish", --Säljer wow guld för 140kr per 100k, via Swish! /W
	"^saljer%d+kguldfor.*viaswish", --Säljer 600k guld för 800kr, via swish! Nu eller aldrig
	"^saljerguld,swish", --Säljer guld, swish
	"guldkvar.*viaswish", --100k guld kvar! 1,8kr/1000g betalning sker via swish! /w mig vid intresse! 50k är minsta köp!
	"^guldviaswish", --Guld via swish /w :)
	"^guld%d+k.*kr.*skype", --Guld 20k til 30kr og 100k til 129kr, skype
	"^saljerviaswish", --Säljer via swish /w vid Intresse
	"^gfinnsswish$", --g finns swish
	"^gfinnsbilligt$", --g finns billigt
	"^gfinns@swish", --G finns @ swîsh /w
	--900k finns att köpa Billigt @swish
	"^%d+kfinns.*@swish", --700k finns @ swish /w
	"^nagonsomsaljerguldviaswish", --NÅGON SOM SÄLJER GULD VIA SWISH?
	"^behoverdug@swish", --behöver du g? @ swish /w
	"^gfinnsatt?kopa.*swish", --G finns att köpa genom swish

	--[[ German ]]--
	"besten.*skype.*sarmael.*coaching", --[Melk Trupp]Der Marktführer kanns einfach am Besten, nun sogar als aktueller Blizzconsieger! Melde Dich bei mir im Skype:Sarmael123456 und überzeuge Dich selbst! Ob Arena, Dungeons, Coachings oder Raids-Bei uns bekommst du jede Hilfe, die Du benötigst!
	--[mmo-prof.com] raffle: Hellfire Citadel (Difficulty level: Mythic) 13/13 including loot. Eligibility requirements to be found on [mmo-prof.com]; Heroic raids, CM GOLD, mounts, PVP and more can be found , too. We're looking forward to your visit!
	"mmoprof.*loot.*gold", --{rt2} [mmo-prof.com] {rt2} BRF Heroic / Highmaul Heroic , Mystisch Lootruns !! Arena 2,2k - Gladiator .. Jegliche TCG Mounts , Play in a Pro Guild (Helfen euch einer absoluten Top Gilde beizutreten, alles für Gold !! Schau vorbei {rt2} [mmo-prof.com] {rt2}
	"mythic.*coaching.*mmoprof", --Bieten Smaragdgrüner Alptraum Mythic/Heroic/Normal Lootruns. Mythic + Instanzen 2-10! Item-Level Push. Coaching für dich! Play with a Pro! Oder komm ich deine Traumgilde und erspiele dir mit Profis deine Erfolge! [mmo-prof.de]
	"lootrun.*selfplay.*piloted.*gunstig", --WTS: ▌▌DIE PRÜFUNG DER TAPFERKEIT 3/3 (Heroisch) LOOTRUN▌▌SELFPLAY/PILOTED ▌▌ MASTER LOOT(Plündermeister ) ▌▌HEUTE 21:00 CET▌▌SEHR GÜNSTIG ▌▌ Ermäßigung für Stoff, Kette und Platte ▌▌ /w ▌▌
	"rocketgaming.*mount.*skype", --RocketGaming die 1.Slots verfügbaren IDs von Emerald Nightmare HC/Myth, auch Nighthold sei der erste mit dem Guldan Mount! Hol dir die ClasshallTruhe der Mythic+ Inis für dein BiS Item, jede ID! Gladi/R1 Titel+Mount! Adde Skype: [christoph.rocket-gaming.]
	"wts.*alptraum.*mythisch.*boost.*boost.*glory", --WTS Der Smaragdgrüne Alptraum Mythisch/Heroisch/Normal boosting,Karazhan boost, Mythischer Schlüsselstein boost 1-10+lvl, Mythisch dungeons boost, Glory of the Legion Hero
}

local repTbl = {
	--Symbol & space removal
	["[%*%-%(%)\"!%?`'_%+#%%%^&;:~{} ]"]="",
	["¨"]="", ["”"]="", ["“"]="", ["▄"]="", ["▀"]="", ["█"]="", ["▓"]="", ["▲"]="", ["◄"]="", ["►"]="", ["▼"]="",
	["░"]="", ["♥"]="", ["♫"]="", ["●"]="", ["■"]="", ["☼"]="", ["¤"]="", ["☺"]="", ["↑"]="", ["«"]="", ["»"]="",
	["▌"]="", ["√"]="", ["《"]="", ["》"]="",

	--This is the replacement table. It serves to deobfuscate words by replacing letters with their English "equivalents".
	["а"]="a", ["à"]="a", ["á"]="a", ["ä"]="a", ["â"]="a", ["ã"]="a", ["å"]="a", ["Ą"]="a", ["ą"]="a", --First letter is Russian "\208\176". Convert > \97. Note: Ą fail with strlower, include both.
	["с"]="c", ["ç"]="c", ["Ć"]="c", ["ć"]="c", --First letter is Russian "\209\129". Convert > \99. Note: Ć fail with strlower, include both.
	["е"]="e", ["è"]="e", ["é"]="e", ["ë"]="e", ["ё"]="e", ["ę"]="e", ["ė"]="e", ["ê"]="e", ["Ě"]="e", ["ě"]="e", ["Ē"]="e", ["ē"]="e", ["Έ"]="e", ["έ"]="e", ["Ĕ"]="e", ["ĕ"]="e", --First letter is Russian "\208\181". Convert > \101. Note: Ě, Ē, Έ, Ĕ fail with strlower, include both.
	["Ğ"]="g", ["ğ"]="g", ["Ĝ"]="g", ["ĝ"]="g", -- Convert > \103. Note: Ğ, Ĝ fail with strlower, include both.
	["ì"]="i", ["í"]="i", ["ï"]="i", ["î"]="i", ["ĭ"]="i", ["İ"]="i", --Convert > \105
	["к"]="k", ["ķ"]="k", -- First letter is Russian "\208\186". Convert > \107
	["Μ"]="m", ["м"]="m", -- First letter is capital Greek μ "\206\156". Convert > \109
	["о"]="o", ["ò"]="o", ["ó"]="o", ["ö"]="o", ["ō"]="o", ["ô"]="o", ["õ"]="o", ["ő"]="o", ["ø"]="o", ["Ǿ"]="o", ["ǿ"]="o", ["Θ"]="o", ["θ"]="o", ["○"]="o", --First letter is Russian "\208\190". Convert > \111. Note: Ǿ, Θ fail with strlower, include both.
	["р"]="p", --First letter is Russian "\209\128". Convert > \112
	["Ř"]="r", ["ř"]="r", ["Ŕ"]="r", ["ŕ"]="r", ["Ŗ"]="r", ["ŗ"]="r", --Convert > \114. -- Note: Ř, Ŕ, Ŗ fail with strlower, include both.
	["Ş"]="s", ["ş"]="s", ["Š"]="s", ["š"]="s", --Convert > \115. -- Note: Ş, Š fail with strlower, include both.
	["т"]="t", --Convert > \116
	["ù"]="u", ["ú"]="u", ["ü"]="u", ["û"]="u", --Convert > \117
	["ý"]="y", ["ÿ"]="y", --Convert > \121
}

local strfind = string.find
local myDebug = false
local IsSpam = function(msg)
	for i=1, #instantReportList do
		if strfind(msg, instantReportList[i]) then
			if myDebug then print("Instant", instantReportList[i]) end
			return true
		end
	end

	local points, phishPoints, boostingPoints = 0, 0, 0
	for i=1, #whiteList do
		if strfind(msg, whiteList[i]) then
			points = points - 2
			phishPoints = phishPoints - 2 --Remove points for safe words
			if myDebug then print("whiteList", whiteList[i], points, phishPoints, boostingPoints) end
		end
	end
	for i=1, #commonList do
		if strfind(msg, commonList[i]) then
			points = points + 1
			if myDebug then print("commonList", commonList[i], points, phishPoints, boostingPoints) end
		end
	end
	for i=1, #phishingList do
		if strfind(msg, phishingList[i]) then
			phishPoints = phishPoints + 1
			if myDebug then print("phishingList", phishingList[i], points, phishPoints, boostingPoints) end
		end
	end

	for i=1, #boostingWhiteList do
		if strfind(msg, boostingWhiteList[i]) then
			boostingPoints = boostingPoints - 1
			if myDebug then print("boostingWhiteList", boostingWhiteList[i], points, phishPoints, boostingPoints) end
		end
	end
	for i=1, #boostingList do
		if strfind(msg, boostingList[i]) then
			boostingPoints = boostingPoints + 1
			if myDebug then print("boostingList", boostingList[i], points, phishPoints, boostingPoints) end
		end
	end

	if points > 3 or phishPoints > 3 or boostingPoints > 3 then
		return true
	end
end

--[[ Chat Scanning ]]--
local Ambiguate, BNGetGameAccountInfoByGUID, gsub, lower, next, type, tremove = Ambiguate, BNGetGameAccountInfoByGUID, gsub, string.lower, next, type, tremove
local IsCharacterFriend, IsGuildMember, UnitInRaid, UnitInParty, CanComplainChat = IsCharacterFriend, IsGuildMember, UnitInRaid, UnitInParty, CanComplainChat
local blockedLineId, chatLines, chatPlayers = 0, {}, {}
local spamCollector, spamLogger, prevShow = {}, {}, 0
local btn, reportFrame
local function BadBoyIsFriendly(name, flag, lineId, guid)
	if not guid then return true end -- LocalDefense automated prints
	local _, characterName = BNGetGameAccountInfoByGUID(guid)
	if characterName or not CanComplainChat(lineId) or IsGuildMember(guid) or IsCharacterFriend(guid) or UnitInRaid(name) or UnitInParty(name) or flag == "GM" or flag == "DEV" then
		return true
	end
end
local function BadBoyCleanse(msg)
	msg = lower(msg) --Lower all text, remove capitals
	for k,v in next, repTbl do
		msg = gsub(msg, k, v)
	end
	return msg
end
local eventFunc = function(_, event, msg, player, _, _, _, flag, channelId, channelNum, _, _, lineId, guid)
	blockedLineId = 0
	if event == "CHAT_MSG_CHANNEL" and (channelId == 0 or type(channelId) ~= "number") then return end --Only scan official custom channels (gen/trade)

	local trimmedPlayer = Ambiguate(player, "none")
	if BadBoyIsFriendly(trimmedPlayer, flag, lineId, guid) then return end

	local debug = msg --Save original message format
	msg = BadBoyCleanse(msg)

	--20 line text buffer, this checks the current line, and blocks it if it's the same as one of the previous 20
	if event == "CHAT_MSG_CHANNEL" then
		for i=1, #chatLines do
			if chatLines[i] == msg and chatPlayers[i] == guid then --If message same as one in previous 20 and from the same person...
				blockedLineId = lineId
				--
				if spamCollector[guid] and IsSpam(msg) then -- Reduce the chances of a spam report expiring (line id is too old) by refreshing it
					spamCollector[guid] = lineId
					if BADBOY_OPTIONS.tipSpam then
						spamLogger[guid] = debug
					end
				end
				--
				return
			end
			if i == 20 then tremove(chatLines, 1) tremove(chatPlayers, 1) end --Don't let the DB grow larger than 20
		end
		chatLines[#chatLines+1] = msg
		chatPlayers[#chatPlayers+1] = guid
	end
	--End text buffer

	if IsSpam(msg) then
		if BadBoyLog and not myDebug then
			BadBoyLog("BadBoy", event, trimmedPlayer, debug)
		end
		if myDebug then
			print("|cFF33FF99BadBoy_REPORT|r: ", debug, "-", event, "-", trimmedPlayer)
		else
			if (not BADBOY_BLACKLIST or not BADBOY_BLACKLIST[guid]) and not IsEncounterInProgress() then
				spamCollector[guid] = lineId
				if BADBOY_OPTIONS.tipSpam then
					spamLogger[guid] = debug
					if btn:IsShown() and reportFrame:IsMouseOver() then
						GameTooltip_Hide()
						reportFrame:GetScript("OnEnter")(reportFrame) -- Add more spam to tooltip if shown
					end
				end

				local t = GetTime()
				if t-prevShow > 90 then
					if prevShow == 0 then
						prevShow = t+25
						-- Delay the first one to grab more spam on really bad realms
						C_Timer.After(25, function() btn:Show() end)
					else
						prevShow = t
						btn:Show()
					end
				end
			end
		end
		blockedLineId = lineId
		return
	end
end
local filterFunc = function(_, _, _, _, _, _, _, _, _, _, _, _, lineId)
	if blockedLineId == lineId then
		return true
	end
end

do
	btn = CreateFrame("Frame", nil, ChatFrame1)
	btn:SetWidth(50)
	btn:SetHeight(50)
	btn:SetPoint("BOTTOMRIGHT", 18, -20)
	btn:SetFrameStrata("DIALOG")
	local tx = btn:CreateTexture()
	tx:SetAllPoints(btn)
	tx:SetMask("Interface\\CharacterFrame\\TempPortraitAlphaMask")
	tx:SetTexture(132360) -- Interface/Icons/Ability_Warrior_ShieldMastery
	local animGroup = btn:CreateAnimationGroup()
	animGroup:SetLooping("REPEAT")
	local scale = animGroup:CreateAnimation("Scale")
	scale:SetOrder(1)
	scale:SetFromScale(0.25,0.25)
	scale:SetToScale(1,1)
	scale:SetDuration(0.4)
	local scale2 = animGroup:CreateAnimation("Scale")
	scale2:SetOrder(2)
	scale2:SetFromScale(1,1)
	scale2:SetToScale(0.25,0.25)
	scale2:SetDuration(0.4)
	scale2:SetEndDelay(8)
	animGroup:Play()
	btn:Hide()

	reportFrame = CreateFrame("Button", nil, btn)
	reportFrame:SetAllPoints(ChatFrame1)
	reportFrame:SetFrameStrata("DIALOG")
	local ticker = nil
	local tickerFunc = function()
		local canReport = false
		for k, v in next, spamCollector do
			if CanComplainChat(v) then
				canReport = true
			else
				spamCollector[k] = nil
				spamLogger[k] = nil
			end
		end
		if not canReport then
			btn:Hide()
		end
	end
	btn:SetScript("OnShow", function()
		if ticker then ticker:Cancel() end
		ticker = C_Timer.NewTicker(5, tickerFunc)
		tickerFunc()
		-- Don't animate if the feature is disabled
		if animGroup:IsPlaying() and BADBOY_OPTIONS.noAnim then
			btn:SetWidth(12)
			btn:SetHeight(12)
			animGroup:Stop()
			btn:ClearAllPoints()
			btn:SetPoint("BOTTOMRIGHT", 0, -5)
		elseif not animGroup:IsPlaying() and not BADBOY_OPTIONS.noAnim then
			btn:SetWidth(46)
			btn:SetHeight(46)
			animGroup:Play()
			btn:ClearAllPoints()
			btn:SetPoint("BOTTOMRIGHT", 18, -20)
		end
	end)
	btn:SetScript("OnHide", function()
		if ticker then
			ticker:Cancel()
			ticker = nil
		end
	end)
	reportFrame:SetScript("OnClick", function(self, btn)
		if IsAltKeyDown() then -- Dismiss
			prevShow = GetTime() -- Refresh throttle so we don't risk showing again straight after reporting
			self:GetParent():Hide()
			for k, v in next, spamCollector do
				spamCollector[k] = nil
				spamLogger[k] = nil
			end
		else -- Report
			prevShow = GetTime() -- Refresh throttle so we don't risk showing again straight after reporting
			self:GetParent():Hide()

			local systemMsg = {GetFramesRegisteredForEvent("CHAT_MSG_SYSTEM")} -- Don't show the "Complaint Registered" message
			local infoMsg = {GetFramesRegisteredForEvent("UI_INFO_MESSAGE")} -- Don't show the "Thanks for the report" message
			local calendarError = {GetFramesRegisteredForEvent("CALENDAR_UPDATE_ERROR")} -- Remove calendar error popup (Blizz bug)
			local reportSubmit = {GetFramesRegisteredForEvent("PLAYER_REPORT_SUBMITTED")} -- Fix clearing chat that shouldn't be cleared (Blizz bug)
			for i = 1, #systemMsg do
				systemMsg[i]:UnregisterEvent("CHAT_MSG_SYSTEM")
			end
			for i = 1, #infoMsg do
				infoMsg[i]:UnregisterEvent("UI_INFO_MESSAGE")
			end
			for i = 1, #calendarError do
				calendarError[i]:UnregisterEvent("CALENDAR_UPDATE_ERROR")
			end
			for i = 1, #reportSubmit do
				reportSubmit[i]:UnregisterEvent("PLAYER_REPORT_SUBMITTED")
			end

			for k, v in next, spamCollector do
				if CanComplainChat(v) then
					BADBOY_BLACKLIST[k] = true
					ReportPlayer("spam", v)
				end
				spamCollector[k] = nil
				spamLogger[k] = nil
			end

			for i = 1, #systemMsg do
				systemMsg[i]:RegisterEvent("CHAT_MSG_SYSTEM")
			end
			for i = 1, #infoMsg do
				infoMsg[i]:RegisterEvent("UI_INFO_MESSAGE")
			end
			for i = 1, #calendarError do
				-- There's a delay before the event fires
				C_Timer.After(5, function() calendarError[i]:RegisterEvent("CALENDAR_UPDATE_ERROR") end)
			end
			for i = 1, #reportSubmit do
				reportSubmit[i]:RegisterEvent("PLAYER_REPORT_SUBMITTED")
			end
		end
	end)
	reportFrame:SetScript("OnEnter", function(self)
		GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
		GameTooltip:AddLine(L.spamBlocked, 1, 1, 1)
		GameTooltip:AddLine(L.clickToReport, 1, 1, 1)
		if next(spamLogger) then
			GameTooltip:AddLine(" ", 0.5, 0.5, 1)
			for k, v in next, spamLogger do
				GameTooltip:AddLine(v, 0.2, 1, 0)
			end
		end
		GameTooltip:Show()
	end)
	reportFrame:SetScript("OnLeave", GameTooltip_Hide)
end

--[[ Add Filters ]]--
do
	local f = CreateFrame("Frame")
	f:SetScript("OnEvent", eventFunc)
	local tbl = {
		"CHAT_MSG_CHANNEL",
		"CHAT_MSG_YELL",
		"CHAT_MSG_SAY",
		"CHAT_MSG_WHISPER",
		"CHAT_MSG_EMOTE",
		"CHAT_MSG_DND",
		"CHAT_MSG_AFK",
	}
	for i = 1, #tbl do
		local event = tbl[i]
		local frames = {GetFramesRegisteredForEvent(event)}
		f:RegisterEvent(event)
		ChatFrame_AddMessageEventFilter(event, filterFunc)
		for i = 1, #frames do
			local frame = frames[i]
			frame:UnregisterEvent(event)
			frame:RegisterEvent(event)
		end
	end
end

if myDebug then
	SlashCmdList.D = function(msg)
		msg = BadBoyCleanse(msg)
		if IsSpam(msg) then
			print("Yes")
		end
	end
	SLASH_D1 = "/d"
end

--[[ Blacklist ]]--
do
	local f = CreateFrame("Frame")
	f:RegisterEvent("ADDON_LOADED")
	f:RegisterEvent("PLAYER_LOGIN")
	f:SetScript("OnEvent", function(frame, event, addon)
		if addon == "BadBoy" then
			if type(BADBOY_OPTIONS) ~= "table" then BADBOY_OPTIONS = {} end
			if type(BADBOY_BLACKLIST) ~= "table" then BADBOY_BLACKLIST = {} end
			frame:UnregisterEvent(event)
		elseif event == "PLAYER_LOGIN" then
			-- Blacklist DB setup, needed since Blizz nerfed ReportPlayer so hard the block sometimes only lasts a few minutes.
			local _, _, day = CalendarGetDate()
			if BADBOY_BLACKLIST.dayFromCal ~= day then
				BADBOY_BLACKLIST = {dayFromCal = day} -- Can't use ADDON_LOADED as CalendarGetDate isn't always ready on very first login.
			end
			SetCVar("spamFilter", 1)
			frame:UnregisterEvent(event)
			frame:SetScript("OnEvent", nil)
		end
	end)
end

_G.BadBoyIsFriendly = BadBoyIsFriendly
