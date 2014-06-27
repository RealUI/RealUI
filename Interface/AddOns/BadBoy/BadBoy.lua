
-- GLOBALS: BADBOY_NOREPORT, BADBOY_POPUP, BADBOY_BLACKLIST, BadBoyLog, BNGetFriendInviteInfo, BNGetNumFriends, BNGetNumFriendToons, BNGetFriendToonInfo, BNReportFriendInvite
-- GLOBALS: CanComplainChat, ChatFrame1, GetTime, print, wipe, REPORT_SPAM_CONFIRMATION, ReportPlayer, StaticPopup_Show, StaticPopup_Resize
-- GLOBALS: strsplit, tonumber, type, UnitInParty, UnitInRaid, ChatHistory_GetAccessID, BNGetNumFriendInvites, CalendarGetDate, SetCVar
local myDebug = false

local reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Spam blocked, click to report!]|h|r <<<"
local throttleMsg = "|cFF33FF99BadBoy|r: Please wait ~7 seconds between reports to prevent being disconnected (Blizzard bug)"
local reportBnet = "BadBoy: >>> |cfffe2ec8Battle.net invite blocked from |cffffff00%s|r|r <<<"
do
	local L = GetLocale()
	if L == "frFR" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Spam bloqué, cliquez pour signaler !]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: Veuillez patienter ~7 secondes entre les signalements afin d'éviter d'être déconnecté (bug de Blizzard)"
		reportBnet = "BadBoy: >>> |cfffe2ec8Battle.net inviter bloqué à partir de |cffffff00%s|r|r <<<"
	elseif L == "deDE" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Spam geblockt, zum Melden klicken!]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: Bitte warte ca. 7 Sekunden zwischen Meldungen um einen Disconnect zu verhindern (Blizzard Bug)"
		reportBnet = "BadBoy: >>> |cfffe2ec8Battle.net-Freundschaftsanfrage von |cffffff00%s|r geblockt|r <<<"
	elseif L == "zhTW" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[發出的垃圾訊息已被阻擋, 點擊以舉報 !]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: 請等候~7秒在回報時，為了防止斷線(暴雪的bug)"
		reportBnet = "BadBoy: >>> |cfffe2ec8已忽略來自 |cffffff00%s|r 的Battle.net邀請|r <<<"
	elseif L == "zhCN" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[垃圾信息已被阻挡，点击举报!]|h|r"
		throttleMsg = "|cFF33FF99BadBoy|r: 请在举报时等待~7 秒以防断线（暴雪的bug）"
	elseif L == "esES" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Spam bloqueado. Clic para informar!]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: Por favor espere ~7 segundos entre los informes para evitar que se desconecte (error de Blizzard)"
		reportBnet = "BadBoy: >>> |cfffe2ec8Invitación de Battle.net bloqueado por|r |cffffff00%s|r <<<"
	elseif L == "esMX" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Spam bloqueado. Clic para informar!]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: Por favor espere ~7 segundos entre los informes para evitar que se desconecte (error de Blizzard)"
		reportBnet = "BadBoy: >>> |cfffe2ec8Invitación de Battle.net bloqueado por|r |cffffff00%s|r <<<"
	elseif L == "ruRU" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Спам заблокирован. Нажмите, чтобы сообщить!]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: Пожалуйста, подождите ~7 секунды между донесениями, чтобы избежать отключения (ошибка Blizzard)"
		reportBnet = "BadBoy: >>> |cfffe2ec8приглашение Battle.net от |cffffff00%s|r блокировано|r <<<"
	elseif L == "koKR" then

	elseif L == "ptBR" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Spam bloqueado, clique para denunciar!]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: Por favor aguarde ~7 segundos entre denúncias para evitar ser desconectado (erro de Blizzard)"
	elseif L == "itIT" then
		reportMsg = "BadBoy: >>> |cfffe2ec8|Hbadboy:%s:%d:%d:%s|h[Spam bloccata, clic qui per riportare!]|h|r <<<"
		throttleMsg = "|cFF33FF99BadBoy|r: Prego aspetta ~7 secondi tra una segnalazione e l'altra per far si che tu non venga disconnesso (bug della Blizzard)"
		reportBnet = "BadBoy: >>> |cfffe2ec8Invito Battle.net bloccato da |cffffff00%s|r|r <<<"
	end
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
	"trusted",
	"well?come",

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

	--Chinese
	"金币", --gold currency
	"大家好", --hello everyone

	--Russian
	"з[o0]л[o0]т[ao0]", --gold
	"гoлд", --gold
	"дocтaвкa", --delivery
	"cкидкa", --discount [russian]
	"oплaт", --payment [russian]
	"пpoдaжa", --sale [serbian]
	"нaличии", --stock/presence
	"цeнe", --price [serbian]
	"пoкупкe", --buy/buying/purchase [russian]
	"купи", --buy [serbian]
	"быcтpo", --fast/quickly
	"ищemпocтaвщикoв", --ищем поставщиков --looking for suppliers
}

--These entries add +2 points
local heavyList = {
	"ourgamecenter[<c][o0@]m", --March 12
	"cicigamec[o0@]m", --April 12
	"[\226\130\172%$\194\163]+%d+.?%d*[fp][oe]r%d+[%.,]?%d*[kg]", --Add separate line if they start approx prices
	"[\226\130\172%$\194\163]+%d+[%.,]?%d*[/\\=]%d+[%.,]?%d*[kg]",
	"%d+[%.,]?%d*eur?o?s?[fp][oe]r%d+[%.,]?%d*[kg]",
	"%d+[%.,]?%d*[\226\130\172%$\194\163]+[/\\=>]+%d+[%.,]?%d*[kg]",
	"%d+[%.,]?%d*[kg][/\\=][\226\130\172%$\194\163]+%d+",
	"%d+[%.,]?%d*[kg][/\\=]%d+[%.,]?%d*[\226\130\172%$\194\163]+",
	"%d+[%.,]?%d*[kg][/\\=]%d+[%.,]?%d*e[uv]",
	"%d+[%.,]?%d*[kg][%.,]?only%d+[%.,]?%d*eu",
	"%d+[%.,]?%d*[kg]for%d+[%.,]?%d*eu",
	"%d+o?[kg][/\\=]%$?%d+[%.,]%d+", --1OK=9.59
	"%d+[%.,]?[%do]*[/\\=]%d+[%.,]?%d*[kge]",
	"%d+[%.,]?%d*eur?[o0]?s?[/\\=<>]+%d+[%.,]?[%do]*[kg]",
	"%d+[%.,]?%d*eur?[o0]?s?[/\\=<>]+l[0o]+[kg]",
	"%d+[%.,]?%d*usd[/\\=]%d+[%.,]?%d*[kg]",
	"%d+[%.,]?%d*usd[fp][oe]r%d+[%.,]?%d*[kg]",
	"%d+[%.,]?%d*[kg][/\\=]%d+[%.,]?%d*usd",
	"%d+[%.,]?[o%d]*[kg]%d+bonus[/\\=]%d+[%.,]?[o%d]+",
	"%d+[%.,]?%d*[кp]+зa%d+[%.,]?%d*[pк]+", --14к за 21р / 17р за 1к
}

--These entries add +2 points, but only 1 entry will count
local heavyRestrictedList = {
	"www[%.,]",
	"[%.,]c[%.,]*[o0@][%.,]*m",
	"[%.,]net",
	"dotc[o0@]m",
}

--These entries add +1 point, but only 1 entry will count
local restrictedIcons = {
	"{%l%l%d}",
	"{цp%d}",
	"{star}",
	"{circle}",
	"{diamond}",
	"{triangle}",
	"{moon}",
	"{square}",
	"{cross}",
	"{x}",
	"{skull}",
	"{diamant}",
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

--These entries remove -2 points
local whiteList = {
	"recrui?t",
	"dkp",
	"lookin?g", --guild
	"lf[gm]",
	"|cff",
	"raid",
	"roleplay",
	"appl[iy]", --apply/application
	"contender", --Contender's Silk
	"enjin%.com",
	"guildlaunch%.com",
	"corplaunch%.com",
	"wowstead%.com",
	"guildportal%.com",
	"guildomatic%.com",
	"shivtr%.com",
	"own3d%.tv",
	"ustream%.tv",
	"twitch%.tv",
	"justin%.tv",
	"social",
	"fortunecard",
	"house",
	"progres",
	"transmor?g",
	"arena",
	"boost",
	"player",
	"portal",
	"town",
	"vialofthe",
	"[235]v[235]",
	"sucht", --de
	"gilde", --de
	"rekryt", --se
	"soker", --se
	"kilta", --fi
	"etsii", --fi
	"sosyal", --tr
	"дкп", --ru, dkp
	"peкpут", --ru, recruit
	"нoвoбpaн", --ru, recruits
	"лфг", --ru, lfg
	"peйд", --ru, raid
}

--Any entry here will instantly report/block
local instantReportList = {
	--[[  Personal Whispers  ]]--
	"so?rr?y.*%d+[kg].*stock.*buy", --sry to bother, we have 60k g in stock today. do u wanna buy some?:)
	"server.*purchase.*gold.*deliv", --sorry to bother,currently we have 29200g on this server, wondering if you might purchase some gold today? 15mins delivery:)
	"free.*powerleveling.*level.*%d+.*interested", --Hello there! I am offering free powerleveling from level 70-80! Perhaps you are intrested? :)v
	"friend.*price.*%d+k.*gold", --dear friend.. may i tell you the price for 10k wow gold ?^^
	"we.*%d+k.*stock.*realm", --hi, we got 25k+++ in stock on this realm. r u interested?:P
	"we.*%d+k.*gold.*buy", --Sorry to bother. We got around 27.4k gold on this server, wondering if you might buy some quick gold with face to face trading ingame?
	"so?rr?y.*interest.*cheap.*gold", --sorry to trouble you , just wondering whether you have  any interest in getting some cheap gold at this moment ,dear dude ? ^^
	"we.*%d+k.*stock.*interest", --hi,we have 40k in stock today,interested ?:)
	"we.*%d%d%d+g.*stock.*price", --hi,we have the last 23600g in stock now ,ill give you the bottom price.do u need any?:D
	"hi.*%d%d+k.*stock.*interest", --hi ,30k++in stock any interest?:)
	"wondering.*you.*need.*buy.*g.*so?r?ry", --I am sunny, just wondering if you might need to buy some G. If not, sry to bother.:)
	"buy.*wow.*curr?ency.*deliver", --Would u like to buy WOW CURRENCY on our site?:)We deliver in 5min:-)
	"interest.*%d+kg.*price.*delive", --:P any interested in the last 30kg with the bottom price.. delivery within 5 to 10 mins:)
	"sorr?y.*bother.*another.*wow.*account.*use", --Hi,mate,sorry to bother,may i ask if u have another wow account that u dont use?:)
	"hello.*%d%d+k.*stock.*buy.*now", --hello mate :) 40k stock now,wanna buy some now?^^
	"price.*%d%d+g.*sale.*gold", --Excuse me. Bottom price!.  New and fresh 30000 G is for sale. Are you intrested in buying some gold today?
	"so?rr?y.*you.*tellyou.*%d+k.*wow.*gold", --sorry to bother you,may i tell you how much for 5k wow gold
	"excuse.*do.*need.*buy.*wow.*gold", --Excuse me,do u need to buy some wowgold?
	"bother.*%d%d%d+g.*server.*quick.*gold", --Sry to bother you, We have 57890 gold on this server do you want to purchase some quick gold today?
	"hey.*interest.*some.*fast.*%d+kg.*left", --hey,interested in some g fast?got 27kg left atm:)
	"know.*need.*buy.*gold.*delivery", --hi,its kitty here. may i know if you need to buy some quick gold today. 20-50 mins delivery speed,
	"may.*know.*have.*account.*don.*use", -- Hi ,May i know if you have an useless account that you dont use now ? :)
	"company.*le?ve?l.*char.*%d%d.*free", --our company  can lvl your char to lvl 80 for FREE.
	"so?r?ry.*need.*cheap.*gold.*%d+", --sorry to disurb you. do you need some cheap gold 20k just need 122eur(108GBP)
	"stock.*gold.*wonder.*buy.*so?rr?y", --Full stock gold! Wondering you might wanna buy some today ? sorry for bothering you.
	"hi.*you.*need.*gold.*we.*promotion", --[hi.do] you need some gold atm?we now have a promotion for it ^^

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

	--[[  Runescape Trading  ]]--
	--WTB RS gold paying WoW GOLD
	"wt[bs]rsgold.*wowgold", --WTB rs gold trading wow gold PST
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

	--[[ CS:GO ]]--
	"^wtbcsgoskin.*info", --WTB CS GO skins /w for more infomation
	"^wtbsomecsgoskin.*info", --WTB some CSGO skins and sell some /w for more info

	--[[ Hearthstone ]]--
	"^sellinghearthstonebeta", --SELLING HEARTHSTONE BETA KEY FOR GOLD /w ME YOUR PRICE
	"^wtshearthstonebeta", --WTS Hearthstone beta, whisper offers people! :)

	--[[  SC 2 ]]--
	"^wtsstarcraft.*cdkey.*gold", --WTS Starcraft Heart of Swarm cd key for wow golds.

	--[[  Dota 2 ]]--
	"^sellingdota2", --Selling 2 Dota2 for wow gold! /W me
	--wtt dota 2 keys w
	--wts dota 2beta key 10k
	"^wt[bst]dota2", --WTB Dota 2 hero/store items,/W me what you have

	--[[  Steam  ]]--
	"^wtssteamaccount", --WTS Steam account with 31 games (full valve pack+more) /w me with offers
	"^sellingborderlands2", --Selling Borderlands 2 cd-key cheap for gold (I bought it twice by mistake. Can send pictures of both confirmations emails without the cd-keys, if you dont trust me)

	--[[  League of Legends  ]]--
	"^wt[bs]lolacc$", --WTB LoL acc
	"^wt[bs]%d?x?leagueoflegends?account", --WTS 2x League of Legend accounts for 1 price !
	--WTT My LoL Account for WoW gold, Its a platiunum almost diamond ranked account atm on EUW if u want more information /w me
	"^wt[bst]m?y?lolaccount", --WTS LOL ACCOUNT LEVEL 30 with 27 SKINS and 14k IP
	"^sellingloleuw?acc.*info", --Selling LOL EUW acc pm for more info
	"^wt[bs].*leagueoflegends.*points.*pay", --WTB 100 DOLLARS OF LEAGUE OF LEGENDS RIOT POINTS PST. YOU PAY WITH YOUR PHONE. PST PAYING A LOT.
	"wts.*leagueoflegends.*acc.*info", --{rt1}wts golden{rt1} League of Legends{rt1} acc /w me for more info{rt1}
	"sellingm?y?leagueoflegends", --Selling my league of legends account, 100 champs 40 skins 2-3 legendary 4 runepage, gold. /EUW /W

	--[[  Account Buy/Sell  ]]--
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

	--[[  Illegal Items ]]--
	"selling.*mount.*pet.*pvp.*purchase", --Selling all rare mounts, TGC pets, all PvP services, and much more! We offer great savings for combo purchases! Pst!
	"wts.*timelost.*mount.*char", --WTS [Reins of the Time-Lost Proto-Drake] [Reins of the Phosphorescent Stone Drake]{rt1}World MOUNTS{rt6}non-sharing acc{rt4}transfer characters
	"wts.*mounts.*sale.*skype", --{rt1}{rt3}WTS [Reins of the Spectral Tiger] [Reins of the Swift Spectral Tiger] {rt3}{rt2} cool mounts on sale!! {rt3}pst!!!~~~skype:ah4pgirl
	"%[.*%].*%[.*%].*facebook.com/buyboe", --Win Free[Volcano][Spire of Scarlet Pain][Obsidium Cleaver]from a simple contest, go www.facebook.com/buyboe now!
	--WTS 6PETS [Cenarion Hatchling],Lil'Rag,XT,KT,Moonkin,Panda 8K each;Prepaid gametimecard 10K;Flying Mounts[Winged Guardian],[Celestial Steed]20K each.
	"wts.*gamet?i?m?e?card.*mount", --WTS 90 Day Pre-Paid Game Card 35K Also selling mount from BLZ STORE,25k for golden dragon/lion
	--if you want buy pets/ mounts/gametimecard/ Spectral Tiger/whisper me!^^
	"pets.*mount.*gametimecard", --wts 6pets .mounts .rocket. gametimecard .Change camp. variable race. turn area. change a name. ^_^!
	"wts.*gametime.*mount.*pet", --WTS Prepaid gametime code 8k per month. the mount [Winged Guardian]'[Celestial Steed] 15K each and the pets 6k each, if u are interested,PST
	"wts.*monthgametime.*%d+k", --WTS 1 Month Gametime 10k. 3 Month Gameitme 25k. 6 Month Gametime 40k
	--[Winged Guardian] 25k  [Heart of the Aspects]25k  [Celestial Steed]20k and prepaid gametimecard
	"%[.*%].*%[.*%].*gamet?i?m?e?card", --wts [Heart of the Aspects]25k [Winged Guardian]25k and prepaid gametimecard
	--WTS [Heart of the Aspects]25K [Winged Guardian]25K [Celestial Steed]20K AND prepaid gametimecard
	--WTS [Celestial Steed]  [Winged Guardian]  [Heart of the Aspects] and prepaid gametimecard / 60k for half year
	"wts.*steed.*gamet?i?m?e?card", --{skull} WTS Winged Guardian 15K.Heart of the Aspects 15K Celestial Steed 15K 90 Day Pre-Paid Game Card 35K {skull}
	--VK [Phiole der Sande][Theresas Leselampe][Maldos Shwertstock],25 Minuten Lieferung auf <buyboe(dot)de>
	"%[.*%].*buyboe.*dot.*[fcd][ro0e]", --WTS [Theresa's Booklight] [Vial of the Sands] [Heaving Plates of Protection] 15mins delivery on<buyboe dot com>
	"code.*hatchling.*gamet?i?m?e?card", --WTS Codes redeem:6PETS [Cenarion Hatchling],Lil Rag,KT,XT,Moonkin,Pandaren 5k each;Prepaid gametimecard 6K;Flying mount[Celestial Steed] 15K.PST
	"gamet?i?m?e?card.*deliver", --{rt6}{rt1} 19=10k,90=51K+gamecard+rocket? deliver10mins
	--40$ for 10k gold or 45$ for  10k gold + 1 rocket  + one month  time card  .   25$ for  a  rocket .  we have  all boe items and 264 gears selled . if u r interested in .  plz whsiper me . :) ty
	--$45=10k + one X-53 Touring Rocket, $107=30K + X-53 Touring Rocket, the promotion will be done in 10 minutes, if you like it, plz whisper me :) ty
	"%$.*rocket.*%$.*rocket.*ple?a?[sz]", --$45 for 10k with a rocket {star} and 110$ for 30k with a Rocket{moon},if you like,plz pst
	--WTS X-53 Touring Rocket.( the only 2 seat flying mount you can aslo get a free month game time) .. pst
	--WTS [X-53 Touring Rocket], the only 2seats flying mount, PST
	"wts.*touringrocket.*mount", --!!!!!! WTS*X-53 TOURING ROCKET Mount(2seats)for 10000G (RAF things), you also can get a free month game time,PST me !!!
	"^wts.*x53touringrocket", --WTS[Celestial Steed],[X-53 Touring Rocket],Race,Xfer 15K,TimeCard 6K,[Cenarion Hatchling]*Rag*KT*XT*Moonk*Panda 5K
	--{rt1}WTS TCG mount and g01d {rt6}. {Reins of the Swift Spectral Tiger} {Reins of the Spectral Tiger} Tabard of the Lightbringer {Magic Rooster Egg} {rt6}lvl80 char . if you wanna get a lv80 char in 30mins /w me for more info{rt6}
	"wts.*g[o0][1l]d.*tabard.*rooster", --WTS gO1d and TCG mounts and Tabard of the Lightbringer and maig rooster egg^^/w me:)
	"sell.*rocket.*pet.*gametimecard", --sell  [X-53 Touring Rocket] &2mounts,6pets,gametimecard,CATA/WLK CD-key
	--WTS[Bladeshatter Treads][Splinterfoot Sandals][Rooftop Griptoes]&all 397 epic boot on <g2500 dot com>.
	"wts.*%[.*%].*g2500.*com", --WTS[Foundations of Courage][Leggings of Nature's Champion]Search for more wow items on <g2500 dot com>. With discount code G2500OKYO5097 to order now.
	"wts.*%[.*%].*good4game", --WTS[Blazing Hippogryph][Amani Dragonhawk][Big Battle Bear]buy TCG Mounts on good4game.c{circle}m
	"wts.*%[.*%].*%[.*%].*wealso.*cheapestg", --WTS [Reins of the Crimson Deathcharger] [Mechano-Hog] [Big Battle Bear]and we also have the cheapest G
	"wts.*%[.*%].*%d+usd.*%d+k", --WTS [Reins of the Crimson Deathcharger] [Vial of the Sands] [Reins of Poseidus],170usd=100k+a rocket for free
	"boe.*sale.*upitems", --wts [Krol Decapitator] we have all the Boe items,mats and 378 items for sale .<www.upitems.com>!!
	"wts.*%[.*%].*$%d+.*%[.*%].*$%d+", --wts[Blauvelt's Family Crest]$34.00[Gilnean Ring of Ruination]$34.99[Signet of High Arcanist Savor]$34.90pst
	"pet.*panda.*gametimecard", --Vends 6PETS [Bébé hippogriffe cénarien],Mini'Rag,XT,KT,Sélénien,Panda 12K each;payé d'avance gametimecard 15K;Bâtis volants[Gardien ailé],[Palefroi célest
	"wts.*deliver.*cheap.*price", --WTS [Reins of Poseidus],deliver fast,cheaper price ,pst,plz
	"wts.*%[.*%].*%[.*%].*cheap.*stock", --wts [Reins of the Swift Spectral Tiger] [Reins of the Spectral Tiger] [Vial of the Sands],cheapst ,in stock ,pst
	"wts.*%[.*%].*%[.*%].*cheap.*safe", --WTS [Reins of the Swift Spectral Tiger] [Tabard of the Lightbringer] [Magic Rooster Egg]Cheapest & Safest Online Trad
	"wts.*%[.*%].*order.*stock", --Wts [prestiges mount] order over 50k will get it free  250k in stock-------- (lots of random characters)
	"^wts.*spectraltiger.*alsootheritems$", --WTS [Magic Rooster Egg] [Reins of the Spectral Tiger] [Reins of the Swift Spectral Tiger] Also other items
	--WTS [Magic Rooster Egg] [Reins of the Spectral Tiger]  [Reins of the Swift Spectral Tiger]cheap mount and gold
	"^wts.*%[.*%].*%[.*%].*cheapmounta?n?d?gold", --WTS [Magic Rooster Egg] [Reins of the Spectral Tiger]  [Reins of the Swift Spectral Tiger]cheap mount&gold
	--WTS Blizzard Store Mounts (25k) and Blizzard Store Pets (10k)
	"wts.*mount.*pet.*%d+k", --WTS {star}flying mounts:[Celestial Steed] and [Winged Guardian]30k each {star}PETS:Lil'Ragnaros/Lil'XT/Lil'K.T./Moonkin/Pandaren/Cenarion Hatchling 12k each,{star}prepaid timecards 15k each.{star}
	"wts.*%[.*%].*powerle?ve?l.*chea", --wts [Reins of the Swift Spectral Tiger] [Reins of the Spectral Tiger] [Wooly White Rhino],and g ,powerlvling ,chea
	"selling%d+.*prepaidtimecard", --selling 60 day prepaid time card /w me for the price
	"need.*gametime.*rocket.*info", --Does someone need WoW Gametime & X53 Rocket's Mount  /w me for more info
	--WTS 60days game time card very checp
	--wts  180days gametime card  {rt1} {rt2}\ cheaps\
	--wts  90days gametime code  {rt2}{rt2}{rt2}
	"^wts%d+days?gametime", --wts 60 days gametime cde. and more stuff from blizzstore
	--wts 60days gamecard for gold /w for more info.
	"^wts%d+days?gamecard", --wts 60 days game card /w me
	"wts.*steed.*prepaidgame", --WTS [Winged Guardian]25K [Heart of the Aspects]25K [Celestial Steed]20K prepaid game
	"gamecard.*gold.*money.*info", -- I am offer Game Card for gold or money, for more info /w me
	--WTB Game Time CODE Buy gold
	--WTS Game time/Diablo and Unmarged accounts for gold!
	"wt[bs].*gametime.*gold", --WTB 1 Month Game Time CODE Buy gold
	"steed.*gc%d+day.*sale", --WTS [Winged Guardian] [Heart of the Aspects] [Celestial Steed]Each 15k gc90days=25KPet sales
	--WTS BLIZZ MOUNTS PETS GAMERTIME OR ANY CODES FOR GOLD
	"wts.*mount.*gamer?time", --WTS Mounts[Heart of the Aspects] and Pets/ GameTimecard
	"mount.*account.*sell.*discount", --Get every single rare mount on your own account now! (including incredibly rare & unobtainables) Also selling all PvP achievies: Gladiator, Hero of Ally, 2200/2400 arenas/RBGs and more! Great discounts for MoP preorders! Message me! Skype: Baddieisboss
	"raiditems.*buy.*email.*price.*wowpve%.c", --{rt1}{rt1}T{rt1}{rt1}S raid items ，397/410/416 token ，achive dragon (ICC,ULD,CATA,FL),416 weapons and so on.If u want to buy,our team will carry u to the instance to get it. U can email me anytime,I will give u a price. [wowpve.com]
	--WTS cheap gold /w me for more info ( no chineese website etc...)
	"^wtscheapgold", --WTS cheap gold /w me for more info
	"^wtscheapandfastgold", --WTS cheap and fast gold ( no chineese website) /w me for more info
	"^wtbgold.*gametime", --WTB GOLD, OR TRADE GOLD FOR GAMETIME!!
	"honorbuddy.*bot.*gold.*skype", --WTS 1 sessions and 3 sessions of HONORBUDDY (WoW bot) For golds....It rly good way to earn golds,if you are interested contact me on skype : Stimar12
	--WTS G A M E T I M E /W
	--WTS {rt1} GAMETIME {rt1}
	--WTS gametime card 60days Very cheap
	--WTS Gametime-Subscribtion /w me
	"^wt[bs]gametime", --WTS {rt1} GAMETIME {rt1} {rt8} MoP Upgrade{rt8}
	"^wts%d+days?gc$", --WTS 60days GC
	"^anyonesellinggametime", --anyone selling game time
	"^lookingforgametime", --LOOKING FOR GAME TIME
	--Wts gamecard 60days very cheap
	"^wt[bs]gamecard", --WTB GAME CARD
	"^wt[bs]gamecode", --wtb game codes
	"^wt[bs]%d+day.*gamecard", --WTS 60 DAYS PREPAID GAMECARD
	"^wt[bs]%d+month.*gametime", --WTS 2 Month(60Days) Gametime-Cards w/ me ! {rt1}
	"month.*gametime.*cdkey", --WTS 1 MONTH RAF - 2 MONTHS GAME TIME - MOP CD KEY - CATA CD KEY. WISP ME FOR MORE INFO
	"sell.*gameca?rd.*month.*whisp", --Selling GameC*rd - 2 months! Whisper for skype and Price
	"sell.*gamecard.*day.*whisp", --Greetings! Currently im selling two different kinds of gamecards! {star} The one with 30 days! And the other one with 60 days! Don't be shy to /whisper me! {skull}
	"^wts.*blizzstoremount.*%d+k", --WTS Any of the Blizz Store mounts 20k
	"rafmount.*gametime.*char", --{rt1}{rt6}WTS RAF mount(Heart of the Nightwing) for 16k ^^ {rt1} Game time for 60k/60days {rt1}{rt6}WTS lvl80 char all class in 30mins!!{rt1} etc{rt1}{rt6}}Whisper skype :nan072487
	"rafmount.*mopkey.*g[o0]ld.*char", --{rt1}WTS RAF mount(Heart of the Nightwing) and MOP KEY{rt6}lvl80 char for g0ld,if you wanna get a  lv80 char in 30mins /w me for more info{rt6}
	"looking.*ebay.*sale.*skype", --Looking for someone that has LOADS of EBAY Experienced! )Come and earn 20% of your Sale Products! )Skype = Donz.Gold (dot between the donz.gold) ADD SKYPE
	--WTS: MoP cd keys (cheap) ! and faction change, tranfer, [GC.!] / skype : atmetheskill
	--{rt8} WTB MoP Cd key {rt8}
	"^wt[bs]mopc?d?key", --{rt1} WTS MoP Key 1x /w me {rt1}
	"wtsrafmount.*nightwing", --wts  raf mount   [Heart of the Nightwing] w/m
	"^selling%d+.*gamecard", --Selling 60time gamecard!
	"%d+day.*gametimecard.*cheap", --{diamond} {diamond} {diamond} {diamond} WTS TWO last 180 days game time card, cheaper! {diamond} {diamond} {diamond} {diamond}
	"^wts.*website.*paypal.*deliver", --WTS Custom Guild Website + 12 months of maintenance + hosting + seo ($100 paypal of 100kg in game) (1-3 days to deliver custom guild website)
	"^wts.*prepaid.*wowingamecurrency", --WTS Rchange/Transfer/Prepaid for WoW ingame currency! {rt4}
	"^wts.*tiger.*rooster.*timecard", --WTS  [Reins of the Swift Spectral Tiger]240k[Magic Rooster Egg]120k and Prepaid Timecard,Panda [MOP.Faction] change and Race change Pst.
	"mount.*code.*dving[%.,]net", --Achievements, Mounts, Loot-Codes, PVE / PVP - Dving.net
	"sale.*loot.*dving[%.,]net", --5.4 content on sale! Hardmodes and Loot Raids for Siege of Orgrimmar! - Dving.net
	"arena.*help.*dving[%.,]net", --Offering arena/RBG help. Season 14. 2200/2400/2650 - Dving.net
	"gold.*heroic.*dving[%.,]net", --Challenge Conqueror: Gold. Itemlevel of 560 or 570! Garrosh Heroic! Glory of the raider! - [Dving.net] {rt8}
	--Any achievements for you(skype: DvingHelp)
	--Help you with 2200/2400/2600(hero) skype: DvingHelp
	"you.*skype.*dvinghelp", --Help you with The Bloodthirsty(72 hours), Sun Horde/Ally(48hours) skype: DvingHelp
	"wts.*rbg.*challenge.*powerle?ve?l.*diablo", --{star}{star}{star}WTS Iphone game: Clash of Clans Gems ---- Cheap {star}{star}2200/2400/2700 RBG,finish within 12 hours {star}{star}Challenge Mode, finish in 1-2 days{star}{star}Achievement/Level Powerlvling{star}{star}Paragon lvling on Diablo3 {star}{star}
	--wtswow gold. tier 15 set,weapons and trinket tot,toes,hof and msv full clearpst now, skype:zl8579888
	"^wtswowgold.*%d+", --WTS wow gold...order 100k give u [Heart of the Nightwing] mount for free
	"^wtsmount.*blizzardstore.*safe.*info", --{rt1} WTS mounts from Blizzard Store, 10k each, safe trade! /w for more info. {rt1}
	--WTS GIFT-codes  [Swift Windsteed] [Winged Guardian] 10k /w me
	"^wtsgiftcode", --WTS GIFT-codes  [Heart of the Aspects] [Celestial Steed] 10k /w me
	"^wtscheape?r?gold.*boost", --{rt6}{rt1} wts cheaper gold and LFM RBG boost service  run!! ! {rt1}{rt6}
	"^wts.*gold.*day.*gametime", --WTS [Heart of the Nightwing]for gold!  And 30 days game time for 20K!pst!
	"cheap.*mounts.*rbg.*boost", --{rt6}{rt1} wts cheaper TCG mounts and LFM RBG boost service  run!! ! {rt1}{rt6}
	"rbg.*boost.*cheap.*mounts", --{rt6}{rt1} LFM RBG boost service run!! and wts cheaper TCG mounts {rt1}{rt6}
	"wts.*%[.*%].*xbox.*points", --WTS [Reins of the Swift Spectral Tiger] for XBOX Live Points Card
	"wts.*%[.*%].*[0o]rder.*gear.*cheap", --wts [obsidian nightwing],0rder 50k will get one for free,wts t15 set and t15.5 set,ilvl522 gears/weapons/trinkets,cheaptest price pst! q 1506040674
	"wts.*%[.*%].*boefans.*deliver", --wts[Magic Rooster Egg][Falling Blossom Cowl]{rt6}{rt6}on boefans.c{rt2}m,4 years Exp,fast and safe delivery{rt6}
	"wts.*nightwing.*gametime", --WTS [Heart of the Nightwing] for 14k.wts 30day gametime for 10k.60k for 16k
	"^wts%d+kgolds?.*euro.*paypal", --WTS 95K Golds for 25 euro! Transaction is done via paypal!
	"feat.*mount.*koroboost", --Get feat of strength [Cutting Edge: Garrosh Hellscream (25 player)] - Heroic mount as GIFT at Koroboost.com
	--Any pve runs . normal 25 180 euro. flex from 65 euro, heroic 25 hc  LOOT runs With LOOT GUARANTEED , all tier pack in single run.  Cheapest mount from Garrosh Heroic 170 eu. Also have D3 boost. Koroboost.com {rt1}
	"cheap.*koroboost[%.,]com", --Cheapest [Challenge Conqueror: Gold] in 2-3hours. 44 eu. Selfplay possible. Take it before enf of season. Koroboost.com
	"wts.*account.*mount.*skype", --{rt1} {rt1}  WTS Old Unmerged WoW Accounts {rt1}  Get old achivements/mounts/pets/titles from Vanilla/TBC/WOTLK on your main {rt1} Already seen: Scarab Lord, Old Gladiators etc Skype: kubadoman11 (only skype name) Site:
	"wts.*drake.*skype.*discount", --WTS BOP[Reins of the Time-Lost Proto-Drake][Reins of the Phosphorescent Stone Drake]Pst Skype:tlpd.bop super discount{rt1}
	"rbg.*gold.*sale.*mount", --Gladiator, Rank 1, 2200-2700 Arena & RBG, CM: Gold and much more for sale! Also selling rare & unobtainable mounts/titles (including scarab lord) - Pst!
	"wts.*%[.*%].*gametime.*days", --WTS [Armored Bloodwing] [Enchanted Fey Dragon] [Iron Skyreaver] and gametime30-60-90-180days{star}WOD{rt1}
	"boost.*mount.*euro.*skype", --BoostFull Heroic 14/14 SoO Clear (Siege of Orgrimmar Heroic) + Your Class Loot + Garrosh Mount + [Heroic: Garrosh Hellscream] 179.95 euro - MORE Info @ Skype: MRD BOOST

	--[[  RBG  ]]--
	"gold.*boost.*service.*skype", --[Challenge Conqueror: Gold] Boosting Service. We can start right now! Fastest(2hours), Really good conditions. Skype: CMGBOOST
	"rbg.*2[%.,]2.*quick.*skype", --{rt8}WTS RBG Boost! We boosts any rating 2.2, 2.4, 2.7(HERO), 3k and more! Cap games also! Quickly, efficiently, safely! Test game included.{rt8} Details on skype {rt1}wowbooster666{rt1}
	--{rt8} Get your RBG rating fast and safe! 2200|2400|HERO. No account sharing. 3850+ conquest points per week. Mount, 16+ achievements and 14 titles. Access to elite gear & T2 weap. We have website and business PayPal! Skype - Deni1189 {rt8}
	"rbg.*2200.*account.*skype", --New unique RBG boost. 2200,2400.2600. [Hero.Cap.] No account sharing, you play for your character. Skype Axelretreem
	--{rt1} Get your Rated BG rating today! We can boost you really fast rating to 2.2k/2.4k/2.6k(depends on your wish).No account sharing,you play your character,so its 100% legally. You will get for sure best Elite PVP Gear+extended CP cap!1 game free. /w
	"rating.*2[%.,]2.*account.*gear", --{rt1}Get your Rated BG rating boosted up to 2.2k|2.4k|2.6k fast and for near to nothing. No account sharing, you play your character, so its 100% legit.  You get extended Conquest Points cap, best PvP gear, and other benefits.trial games!Pm me
	--{rt2} Get your RBG rating fast and safe! 2200/2400/Hero/CP Cap! No account sharing, you play your character, so its 100% legit. We have website and business paypal! /w me for information to join your rbg boost today. Autumn discount!!! {rt2}
	--Guild "RBG BOOST" Wir helfen Sie mit der Rating von 2200 - 2400 - 2650, fur alle Fraktionen. Schnell  und risikofrei. Ohne Sharing des Accounts. Deutsch/Englisch Support. Weinachts Discounts. Unser Webseite: [RBGBOOSTING.COM]
	--Guild "RBG BOOST" will help with the ratings of 2200 - 2400 - 2650, all fractions. Fast and safe. No sharing account. All legally. Deutsch/English Support. Christmas discounts. Our site: [RBGBOOSTING.COM]
	"rbg.*2200.*account.*discount", --{rt2} RBG BOOST! 2200/2400/Hero/CP CAP! No account sharing, you play your character, so its 100% legit. We have website and business paypal! /w me for information to join your rbg boost today. Autumn discount!!! {rt2}
	"boost.*rating.*legal.*price", --{rt8} WTS RBG [BOOST.Any]rating:2200,2400,Hero. Absolutely legal - you play yourself, no account sharing. Best prices in Europe. Boost's provided in a very short space of [time.Be]the first to obtain great titles and elite gear!
	--{rt1}RBG help! Get 2.2/2.4/HERO/CAP only in few hours!NO share acc! We're 1 in world do not take account!Cap 3800+ every week.21 rbg achievs. Access to Elite gear!All legally! 1 Test game!Website - 100% guarantees! For more info /w me
	"rbg.*share.*account.*legal", --{rt1}RBG BOOST help! Get 2.2/2.4/HERO/CAP only in few hours!NO share acc! We're 1 in world do not take account!Cap 3800+ every week.21 rbg achievs. Access to Elite gear!All legally! 1 Test game!Website - 100% guarantees!Cheapest & Fastest service! /w
	--{star} new pvp guild {star}get your rbg{star} will help you with 2200||2400||hero. 3850 cp a week, access to elite gear and t2 weapon. get your rating today! {star} /w me for more information! {star}
	"rbg.*2200.*elitegear.*rating", --{skull} new guild <get your rbg rate>.we are helping with 2200||2400||hero.you play yourself in our group!3850 cp a week,mount,16+achievements and 14 titles. access to elite gear and t2 weapon.get your rating today!wisp me for more information! {skull}
	--{rt1}{rt1}{rt1}WTS: WOW & D3 Gold {rt1}{rt1}2200/2400/2700 RBG {rt1}{rt1}Achievement/Level Powerlvling{rt1}{rt1}Challenge Mode--Gold{rt1}{rt1}{rt1}paragon lvling on diablo3 {rt1} {rt1} {rt1}
	"rbg.*powerle?ve?l.*gold.*diablo", --{rt1}{rt1}{rt1}WTS 2200/2400/2700 RBG Rating, finish in 8 hours{rt1}{rt1}Achievement Powerlvling{rt1}{rt1}Challenge Mode--Gold{rt1}{rt1}{rt1}paragon lvling on diablo3  {rt1} {rt1} {rt1}
	"interest.*conquest.*gear.*mount.*detail", --{rt8} Are you interesting in becoming *?Do you want to have big conquest cap and access to elite gear? How about being one of the first to get full elite gear this season?What about getting rare mounts? Message me for details! {rt8}
	"rating.*account.*character.*paypal", --Get ur rbg rating boosted up to  2200 2400 2600+  , no account sharing.u play ur character,so its 100% safe. we have website and business paypal!
	"sellingboost.*account.*elitegear.*cheap", --SELLING BOOST TO 2.2, 2.4k & HERO! NO ACCOUNT SHARING - GET YOUR ELITE GEAR TODAY!-  - VERY FAST GAMES & CHEAP!! CAN BOOST WHENEVER YOU GOT TIME!
	"rbg.*account.*legit.*website", --{rt1}Selling Rbg Boost {rt1} , No account Sharing ,100% legit , Get your Rating in few Hours , 2200,2400, hero , 3850+ Conquest Cap , We accept Gold offers , We have website {rt1}
	"rbghelp.*achie?v.*gear.*safe", --{rt1}Rbg help any rbg achivements and t2 gear. You play yourself and all is safe and fast. all info in pm {rt1}
	--{rt1} Rated Battleground help, experienced team will help to get 2200, 2400 and Hero. {rt1} All achievements and titles, any amount of conquest points per week, t2 weapon, access to elite gear. For more info whisp (/w) to me {rt1}
	--{star} assisting in rated battleground, our guild will help in gaining 2200, 2400 and hero.{star} 3000+ conquest points per week, access to elite gear, t2 weapon, all achievements and titles, everything you wanted. for more info whisp (/w) to me {star}
	--{star} rbg assisting, our guild will help to gain 2200, 2400 and hero. {star}also 3000+ conquest points per week, access to elite gear, t2 weapon, all achievements and titles, everything you ever dreamed. for more info pls whisp (/w) to me {star}
	"2200.*hero.*conquest.*elitegear.*wh?isp", --{rt1} Help in rated battleground, our team will help in gaining 2200, 2400 and Hero. Weekly Conquest points (3000+), t2 weapon, access to elite gear, all titles and achievements, everything you wanted. {rt1} For more info whisp (/w) to me {rt1}
	"pvpguild.*rbg.*2200.*skype.*icq", -- ---------PVP guild will help you with RBG 2200/2400/hero....... all questions on Skype alexooo46 icq 477788799---------
	"helpyou.*rbg.*character.*fast.*safe", --{rt1}We will help you to get 2.2 - 2.6k on RBG. You playing your character. All is very fast,safe and confidence.{rt1}
	"battleground.*2200.*account.*skype", --SUPER OFFER in RATED BATTLEGROUND /2200/2400/VIP-HERO2650 bonus FREE CAP/farm win/no sharing account/up 1-90  / skype [help.exclusiwe.rbg]
	--provide RBG1800+ 2000+ 2200+ 2400+ 2600+ boost (High warlord  title)No account sharing!100%safety and fast . wishpe me for more infor^^ to join our RBG BOOST TODAY!!
	--{rt1}RBG Assist{rt1} help in gaining 2200|2400|HERO. 3850+ CP per week, access to elite gear, t2 weapon, 16+ achievements and 14 titles, everything you've ever dreamed. Fast, secure, and without account sharing. {rt1}For more info /w to me {rt1}
	"rbg.*2200.*account.*info", --{rt1}Fastest RBG boost in the world. 2.2k, 2.4k, 2.6k for some hours. You play your character, no account sharing. Test game. For more info pm{rt1}
	"rbg.*2200.*price.*skype", --RBG boost GET U'R T2,obtain rare titles, weapons and unique equip at 2 hrs! 2200/2400/2700, weekly CAP, TEST GAMES included! SAFE ,You play yourself!Best prices in Europe.[ skype - nikolya_90 ]
	--WTS:{rt5}{rt1}{rt5}RBG2650/2400/2200---75/150/300wins Achievement+mounts!{rt5}{rt1}{rt5}Gold Challenge Conqueror{rt1}{rt5}{rt1}DISCOUNT on skype: Jasminelingling1{rt5}{rt1}{rt5}QQ:1046224892
	"rbg.*2200.*discount.*skype", --WTS:RBG2560/2400/2200/Caps per weekGold Challenge ConquerorNever scam, trustworthy website!!DISCOUNT on skype: Jasminelingling1QQ:1046224892
	"boost.*2200.*cheap.*price", --{rt1}Selling boost to 2200{rt1} rbg tier 2 3600 cap /w me not accepting gold! GUARANTEED TIER 2 FOR CHEAPEST PRICES
	"rbg.*purchase.*rating.*acc", --{rt2}{rt2} RBG Boosting is Back!! Be ready to purchase rating, titles, conquest cap of 3k and of course new PVP GEAR and Weapons! You play yourself, no acc sharing. skype RBGcarryBoost
	"rbg.*2200.*bonus.*mount", --Hi everyone! We can help you RBG with your ratings! 2200/2400/2700/bonus free 1-3 weekly cap/Mount for 75/cap 4-10 win/fast game 1-3 hour(2200)/ pm
	"rbg.*2[%.,]2.*paypal.*skype", --{rt1}{rt1}{rt1}RBG: 2.2/2.4/2.7. Guarantees: Website, Bussines PayPal, Test Game. [Skype: Romaboost]
	"rbgboost.*gear.*account.*paypal", --{rt2} WTS RBG BOOST! Obtain great titles and elite gear! NO ACCOUNT SHARING, you play youself! We have website and business paypal! /w me for information to join your rbg boost today. Winter discouts!!! {rt2}
	"rbg.*2[%.,]2.*order.*contact.*price", --{rt1}{rt1}WTS RBG Boosts! We're boosting your char to 2.2k 2.4k 2.8k which is Hero of the alliance! All oders done in 72hours! You play your own Char! Contact us now for prices and more. We are also verrified on ownedcore {rt1}{rt1}
	"sell.*rbg.*2%.4.*quick.*quality", --{rt1} Selling RBG boost up to 2.4k. Quick and reliable. Quality comes first, if you have any requests or questions. Ask us! /w me more info {rt1}
	"rbg.*free.*rating.*2[%.,]2.*skype", --{rt8}WTS RBG Boost! Test game for FREE!!! ANY Rating (2.2,2.4,2.7,3k and more!) {rt8} Details on skype {rt1}wtspvp{rt1}
	"sell.*2[%.,]2.*rbg.*gear.*sale", --Selling 2.2k/2.4k and hota boost on rbg!tired of getting scrub groups all the time?Get ur elite gear and +3850 cap now!We do accept gold!Xmas sale is up for few days only.Fast and cheap!
	"rbg.*2200.*paypal.*skype", --{rt1}RBG: 2200 - 100euro, 2400 - 140euro, 2700 - 180euro. Guarantees: Website, Bussines PayPal, Test Game. [Skype: Romaboost]
	"rbgboost.*2[%.,]2.*achie?vement.*character", --{rt1} {rt7}WTS arena-RBG Boost for gold. 3v3-5v5 and RBG  2k 2,2k 2.4k and HERO achivement, 100%legit. you play on your own character{rt1} {rt7}
	"2[%.,]2.*rbg.*account.*cheap", --Selling 2.2k/2.4k hota boost on rbg! NO account sharing!We also do it for gold now!Cheap and fast!Get ur great rewards now!
	"rbg.*2200.*cheap.*fast", --WTS RBG BOOST TO 2200/2400 GOING NOW CHEAP AND FAST /W ME!
	"rbg.*2200.*elitegear.*skype", --{rt1} RBG Boosting all classes from 0-2200 tonight! Get your T2 Elite gear + 3500 conquest cap each week! Skype: Marcz-90 for info. {rt1}
	"2200.*rbg.*account.*skype", --{rt1} Want 2200/2400/2700+ on RBG? Get it fast n safe! CAP support 3800+ every week! No share account! Elite gear and 21 RBG achievements! Test game! add skype: nucleear1986_26 {rt1}
	"rbg.*22[0o][0o].*rating.*info", --WTs RBG B00ST 22OO & 24OO Rating, /w for more info!
	"rbg.*2[%.,]2.*account.*info", --{rt1}Fastest RBG boost in the world. 2.2k, 2.4k, 2.6k for some hours. You play your character, no account sharing. Test game. For more info pm{rt1}
	"rbg.*2[%.,]2.*legal.*info", --Selling RBG BOOST - 2 k // 2.2 k // 2.4 k ++ Hero of the Alliance/ CHEEP AND EASY. 100 % win games ( RUSSIAN GAMING SYSTEM )    Legal and quick. Information given. GET you elite T2 gear TODAY.
	"russian.*team.*rbg.*2200", --The best Russian team will help you with RBG rating 2200/2400/2700+!
	"%d+k.*powerle?ve?l.*skype", --also: 100k-250k hk and power leveling! Guarantees, if you're really interested then Add Skype: Mmoboostpro
	"rbg.*2200.*paypal.*info", --WTS RBG BOOST! 2200/2400/Hero/CP CAP! You play yourself, no acc sharing, so its 100% legit. We have website and business paypal! /w me for information to join your rbg boost today!
	"rbg.*cap.*rating.*portal.*gear", --WTS RBG CARRY - Marshal, Grand Marshal and higher. Cap games, Any [Ratings.we'll] Rise your Progres on RBG + achievs. Your "portal" to new Gear, weapon. /w me
	--{star} Increase your ranking on R&B&G to 2OOO~22OO~24OO or higher.+385O cp capp.+ELITE gear and other titles and achieves. Need minimal of your time. Waiting for you on s*k*y*p*e : Grafus123 {star}
	"rbg.*2%.?2[o0][o0].*gear.*skype", --{rt1}WTS- RBG boost 2.200+2.400+.2.650+ .. No gear requirements. if your interested please add me on Skype: nickonexz.{rt1}
	"rbg.*2[%.,]2.*achie?v.*legit", --{rt7}{rt1}WTS RBG Boost for all classes! We offer you 2,2k, 2,4k and Glad achievement! You play yourself, 100% legit!(accept gold){rt1}{rt7}
	"rbg.*2200.*account.*achie?v", --/2 Hi dude u wanna fast boost 2.2/2.4/Hero(aliance/horde) ,fast work right now =) skype BGboost up you RBG ratings! 2200/2400/HERO /cap/no sharing account /Dungeon challenges -gold/glory hero-raider-guild raider all achivemets /pm
	"rbg.*2200.*legit.*paypal", --WTS RBG CARRY! 0-2200,2400,2750,CAP! No acc sharing, 100% legit. Our boost costs less than anyones' else in EU. We have business Paypal and website! /w me
	"2[%.,]2.*legit.*rbg.*price", --WTS 2.2/2.4k Legit RBG [Boost.Cheapest] prices [EU.PST] for info!
	"rbg.*2200.*boost.*skype", --{rt2} RBG Super Offer  new season!  fast T13/ RBG 2200/2400/HERO - /cap 3850/ boost today /skype BGboost
	"2200.*accoun?t.*paypal.*skype", --ASSISTANCE: 2000-2200-2400 No sharing accout. Site, Bussines PayPal, Test Game.  Skype: Mike222eu{rt1}
	"rbg.*2[24]00.*sale.*skype", --Help with RBG rat/cap, the best prices!2400/hero we are working 5th season. SALE RIGHT NOW. skype: kkboosting
	"rbg.*2[%.,]2.*legit.*paypal", --WTS RBG BOOST! Any rating and CAP 2.2k,2.4k & Hero of the Horde/Alliance! No acc sharing, 100% legit, you play youself. Our boost costs less than anyones' else in [EU.We] have website + Paypal verified, OwnedCore verified. /w me
	"quickest.*safi?est.*rbg.*legit.*account", --The 13th season has just started! And we're ready to provide you the quickest and safiest RBG PUSH! Any Rating! 100% legit - no account sharing required. Be the first to obtain elite gear, lots of achievements, titles and mounts! PM ME FOR MORE INFO.
	"pvpforce.*professional.*2200.*skype", --{rt1}{rt1}{rt1} Become a part of new PvP force. Play with professionals to be among the first to get 2200/2400/HERO. 3850+ cp per week, T2 in Only 7 weeks! Skype: [***] {rt1}{rt1}{rt1}
	"rbg.*2200.*site.*mount", --{rt6}Get your RBG rating right now! 2000/2200/2400/HERO.{rt6}without acc share..  Site.. {rt6}3850+cp per [week.mount,16+] and /w me for more info.
	"rbg.*2200.*character.*mount", --{rt6}Get your RBG rating today! 2000/2200/2400/HERO.{rt6}You play your own character. {rt6}3850+cp per [week.mount,16+] and /w me for more info.
	"safe.*rbg.*elitegear.*skype", --{rt8} Offering extremely safe and qualified RBG boosting to ANY rating you want. NO ACCOUNT SHARING. 3850+ conquest points per week. Epic titles and elite gear are waiting for you! For more info contact me on skype: iboosting {rt8}
	"2200.*gold.*sale.*skype", --Gladiator, 2200-2700 Arena & RBG, Malevolent Gladiator (rank 1!), gold challenge modes and much more for sale! Also selling rare & unobtainable mounts/titles (including scarab lord)! Skype: wowpvpcarry
	"visit.*pvp.*elitegear.*skype", --Visit ArenaCarry DotCom for all of your PvP needs! Gladiator, hero of ally/horde, fastest elite gear, highest CP cap, and much more! Skype: Baddieisboss
	"rbg.*2200.*challenge.*transmog", --wts:rbg 2200/2400/2700cp capschallenge mode: transmog setitem upgrade 463/470/495/503 no transfer!---pst
	"wts.*account.*cap.*conquest.*elitegear", --WTS [General] or high, you play with us, no account share. Runing them right now. Increase your cap to over 3500+ conquest. Get your elite gear. /w info
	"rbg.*2[%.,][24].*account.*skype", --the fastest rbg boost in the world. 2.k, 2.4k, 2.6k for some hours. you play your character, no acount sharing. 3850+ conquest points per week.mount, 16+ achievements and 14 titles. add skype premium_boost
	"2200.*account.*rbg.*skype", --Cap/2200/2400/Hero only in few hours! We don't need your account, you play with us! We make your RBG Cap every week. We offer access to elite gear and 21 rbg achievs. Test game! Guarantees. Add SKYPE for more info: rbgsupport
	"elitegear.*rbg.*legit.*skype", --{rt8} Be first with ELITE gear, get RBG Boosting in this season. No account sharing, 100% legit and bonuses with high rating order. Any rating available, for lowrated characters TEST GAME for free! {rt8} Details on skype {rt1}wtspvp{rt1}
	"rating.*professional.*2200.*skype", --{rt1}{rt1}{rt1} Get your rating to where you want it to be. Play with professionals to be among the first to get 2200/2400/HERO. 3850+ cp per week, T2 in under 7 weeks! Skype: [Ryan.Lotten] {rt1}{rt1}{rt1}
	"wts.*character.*account.*rating.*test", --WTS [Marshal] and [High Warlord]. We also sell weekly caps. You play on your character,no account share. Get rating - increase your cap to 3800+ conq. Write me and set up your run right now! Test game. For more info /w.
	"rbg.*2200.*legit.*boost.*test", --{rt8}WTS RBG BOOST! EU & US. 2200/2400/Hero/CP CAP! You play yourself, no acc sharing, so its 100% legit. /w me for information to join your rbg boost today! + proofs + test games + Im VERIFIED!
	"rpgbox.*price.*skype", --{circle} site [RPGBOX.ORG] don't wait for the season end! Put on the best pvp item now! any reting in the Rated Battleground ! 5 seasons of experience! best price ! start today !/skype BGboost
	--W.T.S Ratted BGs: 1800-2750+/HER0/ Conq.points/ NEW Enchants & NEW Tabard! only in few hours! NO share acount! You play on toon! 1 Tesst game! [We.b.si].te. + guarantees! A.d.d S.K.Y.P.E to know more: Robert_rbg
	"1800.*acc?ount.*tess?t.*s%.?k%.?y%.?p%.?e", --{star} W.T.S Ratted BGs: 1800-2650+/Conq.points only in few hours! NO share acount! You play on toon! 3800+ points per week.Acces to elite gear and 21 achievs.1 Test game! We.b.si.te. 3 years we play! A.d.d S.K.Y.P.E to know more: Robert_rbg {star}
	"2200.*achiev.*test.*website", --{star} Raise your RatedBG rating to 2000|2200|2400|Hero! Play your own toon! 3850+ conquest points per week. +Achieves and titles. Take a Test Run to check everything out! Website! S.kype: kekcique {star}
	"rbg.*boost.*paypal.*skype", --{rt1}Best RBG boosting team ready for action!{rt1} | We sell boost to ANY rating AND cap games! | Get Grand Marshal/High Warlord Title+Gear! | 110% SAFE using business PayPal! | 1250+ orders done! | {rt6} Add me on Skype for info: [chef.fred1] {rt6}
	"rbg.*2200.*hero.*gladiator.*trusted", --Get your {rt6}RBG RATING{rt6} today! CAP/2000/2200/2400/2500/HERO. Arena 2200/2400/Gladiator/R1.Got the BEST & MOST TRUSTED WOW players ADVERTISING for us. Whisper ME and get in touch with US!
	"2200.*toon.*test.*s%.?k%.?y%.?p%.?e", --{rt1}WTS Rated BG services: 1800||2000||2200||2400||HER0 title||WINS for conquest points. You play your own toon!  Take a Test Run to check everything out! We have Web5site! 2 years expirience! S.kype: kekcique{rt1}
	"2200.*rbg.*skype.*pric[ie]", --{rt6} Multi glads now offering 2200/2400. Arena/Crossrealm Rbgs. Message me on Skype for more details- soft.nchewy{rt1} Competitive Pricing! :D
	"blastboost%.com.*2200.*skype", --{rt8} [BlastBoost.com] Offers You service on RBG. 0-2200, 0-2400, 0-3000 and CAP. You play youself. Test game. Time of increasing: 1-4 hours. Payment can made in several parts. Add us on Skype: [BlastBoost.com] (Wien, Austria) {rt8}
	"rbg.*boost.*2[%.,]2.*skype", --{rt1}{rt4}{rt3}{rt8} Selling RBG Boost to 2k/2.2k/2.3k / Game Time Cards / Realm/Faction change / Blizzard Store Pets/Mounts for gold! Add my skype for more information: RBGService11 {rt4}{rt2}{rt3}{rt5}
	"safe.*rbg.*account.*skype", --{rt8} Offering extremely safe and qualified RBG boosting to ANY rating you want. NO ACCOUNT SHARING. Epic titles, cap games, pve boosts, powerleveling, gold !  For more info contact me on skype: MatBoosting {rt8}
	"rbg.*2200.*hero.*arena.*whisper", --Get your {rt6} RBG RATING {rt6} today! CAP/2000/2200/2400/2500/HERO. ARENA 2200/2400/Gladiator/R1.Whisper ME and get in touch with US! You Won't regret it{rt6}
	"challenge.*gold.*fast.*cheap.*character", --Looking for someone to help you get [CHALLENGE CONQUEROR:GOLD] fast ? Our team is  fastest (2.5h for all 9 ) and cheapest . You play your own character ofc.
	"elitegear.*achiev.*toon.*skype", --The squad will aid to purchase  a high ranking on R&B&Gs. Also propose 35OO - 385O c0nq.capp. A few hours of your time. Your path to elite gear and achievements. You play your toon. Don't be shy, for more inf0 add on SK*Y*PE - Grafus123
	"selling.*gladiator.*achiev.*rbg.*arena.*gold.*coaching", --Selling Gladiator/R1, every achieve in RBG/Arena, Challenge Mode: Gold, T15.5, and more! Elo/Coaching in LoL too
	"2200.*account.*points.*skype", --{rt2} SUPER OFFER ! 2200|2400|HERO. NO ACCOUNT SHARING. 3850+ conquest points per week. Mount, 16+ achievements and 14 titles/skype BGboost{rt2}
	--prommote.me will help you gain any RBG rating (2200, 2400 an higher), fill the weekly cap, acquire T2 weapons and become the Gladiator and Hero of the Horde/Alliance Good pricing, no transfer/account sharing required
	--prommote.me will help you get any PVE/PVP and other achievements, mounts, titles and top raid gear, and help you gain 20300 achievement points. PM for details.
	"prommote%.me.*helpyou", --prommote.me will help you gear up in T15 HM raids and get 13/13 progress.
	--prommote.me now offers special summer prices for the [Glory of the Pandaria Raider]
	"prommote%.me.*prices?forthe", --prommote.me, fast service and modest prices for the [Challenge Conqueror: Gold]
	"2200.*account.*mount.*skype", --{circle} SUPER OFFER ! 2200|2400|HERO. NO ACCOUNT SHARING. 3850+ conquest points per week. Mount, 16+ achievements and 14 titles/skype BGboost{circle}
	"rbg.*challenge.*arena.*glad.*info", --WTS Rbg boost / challenge mode boost / arena v2/ v3 /v 5 boost and glad /w for more information
	"powerle?ve?l.*honor.*arena.*ownedcore", --{rt6}|Powerleveling |{rt6} Powerleveling , Honor Farming , Or Arena cap , Many other Service , Our team work for you !Trusted on OwnedCore and Epicnpc ! /w me
	"help.*rbg.*rating.*gold.*skype", --We can help you with ANY RBG rating for GOLD(partial payments accepted) skype: battleboost1337
	"rbg.*2200.*gold.*skype", --{rt6}{rt2}{rt2} ТНЕ Bеst PRICE  RBG 2200/2400/HЕRО/ Arеnа 2200/2400/Glad /Big cаp 3850+ / Pve /Gold challenge 9/9 / ALL INFO IN SKYPE -{rt8}   MAINBOOST   /w me {rt2}{rt2}
	"rbg.*2200.*payment.*skype", --{rt8} RBG BOOST: 1800-2000-2200-2400-Hero, NEW MOUNT(40 WINS). Test game. Partial payments. Very quickly. Skype: PRO_RATING {rt8}
	"rbg.*2000.*test.*skype", --{rt8}RBG RATING.1800-2000-2200-2400-HERO. Test Game. Fastest. Skype:RBG-SUPPORT{rt8}
	"rbg.*sale.*2200.*skype", --{rt1} The best EU/RU RBGboosting without sharing acc! 6th season in work! Lowest prices! Good sales! cap/2200/2400/3000 Our skype: kkboosting
	"selling.*arena.*boost.*rbg.*skype", --{rt8} {rt8}  {rt8} Selling 5v5,3v3 ArenaBoost. You playing your character. Also any 2v2 raiting with acc sharing, and 3v3 coaching. RBG/3v3 Arena cap games. 250.000k HKs just in 2 days!| skype: alex_flame2 (Nederland){rt8}  {rt8} {rt8}
	"rbg.*mount.*payment.*skype", --{rt8} {rt8}WTS RBG BOOST! Any rating, CAP Games, Wins. Get the mount, 21+achievements,16 titles, top gear, tabard with us. Test game, partial payments, self playing. For more info add me in skype AltisRBG
	"rbg.*mount.*discount.*skype", --{rt1}WTS RBG CAP/40wins/75wins{rt1} || SELF PLAY || RBG achivements and MOUNTS! || 100% positive feedback on the ownedcore || FLEXIBLE DISCOUNTS || challenge modes || {rt1} Add Skype: Azpirox {rt1}
	"selling.*gold.*rating.*top", --Elitist-gaming,com Selling SoO runs in heroic or normal. CM: gold, reins of galakras, Kor'kron Juggernaut. Any 3v3/5v5 rating including Glad and Rank 1. Our suppliers are top 30 U.S. guilds and top level pvp players. Check us out!largest in the US
	"selling.*boost.*gold.*skype", --Selling CM Boost 9/9Gold, Flex 1-4, you self play! accept gold payment, preorder for New season RBG 22OO! have proofs skype FBOOSTX
	"selling.*service.*2400.*mount", --Selling basically every PvP & PvE service! 2400+ Arena/RBG/Gladiator/Rank 1/Arena Master | T16/Gold Challenges/Mounts/Pets. Pst!
	"selling.*achiev.*rbg.*discount", --Selling Gladiator/R1, every achieve in RBG/Arena, Challenge Mode: Gold, T16, and more! Preorder for discounts!
	"selling.*service.*rbg.*mount", --Selling PvP services: Gladiator, 2700 Arena & RBG, Rank 1! Also selling rare mounts (including scarab lord!) and many PvE services. Msg me!
	"boost.*safe.*paypal.*skype", --WTS BOOST RBG/ARENA,CAP/WINS GAMES,GOLD CHALLENGE MODE,PVE:SoO HC/N/Flex 14/14+loot(mount)! Best prices in Europe! FAST AND SAFE! It's the 7th season of our work. We have website+business Paypal.SKYPE: BLLIZZIK
	"boosting[%.,]pro.*discount", --[H] <DND>[Jedrict]: {skull}{skull}{skull} [www.Boosting.Pro] - Premium Arena boosting - {circle} SUPER DISCOUNTS ON ALL RATINGS {circle} Over 50 successful Gladiator orders in season 14! {skull}{skull}{skull}
	"boosting[%.,]pro.*sale", --[H] <DND>[Jedrict]: {square}{square}{square} [www.Boosting.Pro] - Elite PvE Services: {circle} HC LOOT RUN + GARROSH MOUNT {circle} on Sale now! Only 25 man raids, warforged loot, weapons and trinkets are included! {square}{square}{square}
	"rating.*rbg.*epiccarry[%.,]com", --{rt2} Arena rating\Rbg wins\Arena wins on epiccarry.com {rt1}
	"flex.*realm.*epiccarry[%.,]com", --{rt2} SOO Flex\Normal\Heroic\Glory + T15+T14 contents selfplay, no realm transfer on epiccarry.com {rt1}
	"arenahelp[%.,]eu.*boost.*skype", --{rt1} Arenahelp.eu - Offering LEGIT boosts in RBG and Arena by the top players!!!  Check website or Skype: [arenahelp.eu.] Ownedcore verified. Consider our prices.

	--[[  Russian  ]]--
	--[skull]Ovoschevik.rf[skull] continues to harm the enemy, to please you with fresh [circle]vegetables! BC 450. Operators of girls waiting for you!
	"oвoщeвик%.pф.*cвeжиmи", --[skull]Овощевик.рф[skull] продолжает, на зло врагaм, радовaть вас свежими [circle]oвoщaми! Бл 450. oператoры девyшки ждyт вaс!
	-- [[MMOSHOP.RU]] [circle] ot23r] real price [WM BL:270] [ICQ:192625006 Skype:MMOSHOP.RU, chat on the site] [Webmoney,Yandex,other]
	"mmoshop%.ru.*цeнa.*skype", -- [ [MMOSHOP.RU]] [circle] от23р] реальная цена [WM BL:270] [ICQ:192625006 Skype:MMOSHOP.RU, Чат на сайте] [Вебмани,Яндекс,другие]
	--[square] [RPGdealer.ru] [square] gives you quick access to wealth. Always on top!
	"rpgdealer%.ru.*бoгaтcтву", --[square] [RPGdealer.ru] [square] предоставит Вам быстрый доступ к богатству. Всегда на высоте!
	--GOLD WOW + SATELLITE PRESENT EACH! Lotteries 2 times a month of valuable prizes [circle] Site : [RPGdealer.ru] [circle] ICQ: 485552474. BL 360 Info on the site.
	"з[o0]л[o0]т[ao0].*rpgdealer%.ru", --ЗОЛОТО WOW + СПУТНИК В ПОДАРОК КАЖДОМУ! Розыгрыши 2 раза в мес ценных призов [circle] Сайт: [RPGdealer.ru] [circle] ICQ: 485552474. BL 360 Инфа на сайте.
	--Buy "funny coins" from [star]FUNY-MONY.RF[star]. Delivery 10 minutes. Always in stock. All the details on the FUNY-MONY.RF
		--Покупайте "Весёлые монетки" от [star]ФАНИ-МАНИ.РФ[star]. Доставка 10 минут. Всегда в наличии. Все подробности на ФАНИ-МАНИ.РФ
	--Buy MERRY COINS on the funny-money.rf Funny price:)
		--Купи ВЕСЕЛЫЕ МОНЕТКИ на фани-мани.рф Смешные цены:)
	--Buy GOLD at [circle]funny-money.rf[circle] Price Calculator on the site.
	"куп.*фaни-maни%.pф", --Купи ЗОЛОТО на [circle]фани-мани.рф[circle] Калькулятор цен на сайте.
	--[COINS] of 23 per 1OOO | website | INGMONEY. RU | | SALE + Super Award - Spectral Tiger! ICQ 77-21-87 | | Skype INGMONEY. RU
	"ingmoney%.ru.*skype", --[МОНЕТЫ]  от 23 за 1OOO | сайт | INGMONEY. RU ||АКЦИЯ + Супер Приз - Спектральный Тигр! ICQ 77-21-87 || Skype INGMONEY. RU
	--Sell 55kg of potatoes at a low price quickly! Skype v_techno_delo [circle] 8 = 1kg
	"пpoдam.*кapтoшки.*cpoчнo.*cкaйп", --Продам 55кг картошки по дешевке  срочно! скайп v_techno_delo  [circle] 8 = 1кг
	--Gold Exchange Invitation to participate suppliers and shops. With our more than 800 suppliers and 100 stores. GexDex.ru
	"з[o0]л[o0]т[ao0].*gexdex%.ru", --[skull][skull][skull] Биржа золота приглaшaет к учaстию постaвщиков и магазины. С нами болee 800 постaвщиков и 100 магaзинов. GеxDеx.ru
	--Cheapest price only here! Price 1000 gold-20R, from 40k-18r on, from-60k to 17p! Website [playwowtime.vipshop.ru]! ICQ 196-353-353, skype nickname playwowtime2011!
	"vipshop%.ru.*skype", --Самые дешевые цены только у нас! Цены 1000 золотых- 20р , от 40к -по 18р , от 60к-по 17р ! Сайт [playwowtime.vipshop.ru] ! ICQ 196-353-353 , skype ник playwowtime2011!
	--we are help with RAITING BATTLE GROUND -2200-2400-2650 /admission of cap/PVP set for honor points/mount/leveling 1-90/ skype - [RPGBOX.RU] icq  819-207 site [rpgbox.ru]
	"cкaйп.*rpgbox%.ru", --поможем РЕЙТИНГ ПОЛЕ БОЯ -2200-2400-2650 /набор капа/ПВП сет за очки чести/маунт/прокачка 1-90/ скайп - [RPGBOX.RU] ася  819-207 сайт [rpgbox.ru]
	--website [RPGBOX.RU] RBG 2200-2400-2650 / cap/PVP set for honor points/mount/UP 1-90 /farm kills 250K /any progress in raids and dungeons for players and guilds
	"rpgbox%.ru.*2200.*maунт", --сайт [RPGBOX.RU] РПБ 2200-2400-2650 / кап/ПВП сет за очки чести/маунт/UP  1-90 /фарм килов 250к /любые достижения в рейдах  и подземельях для игроков и гильдмй
	--Sell! [gold] 16r-1000g. Looking for suppliers. Quality levelling of character's, honor point's and profession's. ICQ: 406-887-855 Skуре: WoW-Crabbs  Webmoney BL [360]
		--Продаю! [золото] 16р-1000г. Ищу поставщиков. Качественно прокачаю персонажей, очки чести и профессии. ICQ: 406-887-855 Skуре: WoW-Crabbs  Webmoney BL [360]
	--Selling [GOLD]! 16r-1k Instant delivery any quantatys. Levelling characters, prof, honor. Attestat WM BL 350 ICQ 406-8878-55 Skype wow-crabbs
		--Продам [GOLD]! 16р-1к Моментальная доставка любых количеств. Прокачка персонажей, проф, хонора. Аттестат WM BL 350 ICQ 406-8878-55 Скайп wow-crabbs
	--Buying gold!looking for suppliers.Leveling characters, proffesions, honor TimeCards60days-80k gold Game payment 1month-45k gold. Attestat [BL 350] ICQ 406-8878-55 Skype wow-crabbs
	"icq.*wowcrabbs", --Скупаю голд!ищу поставщиков.Прокачка персонажей, профессий, хонора ТК60дн-80к Проплата 1мес-45к. Аттестат [BL 350] ICQ 406-8878-55 Скайп wow-crabbs
	--[MMOah.ru]  [circle] Gold at competitive prices [circle] BL85+ IСQ  49-48-48 , online chat on the site, we are accepted any kind of payments WM/YM/Visa/qiwi/Robokassa/SMS, we are produce recruitment of suppl
	"mmoah%.ru.*зoлoтo.*icq", --[MMOah.ru]  [circle] Золото по выгодным ценам [circle] BL85+ IСQ  49-48-48 , на сайте онлайн чат, принимаем все виды оплат WM/ЯД/Visa/qiwi/Robokassa/SMS, производим набор пост
	--Seling [G[circle]LD], Fast, reliably, any kind of payments. Attestat of seller's. Looking for supplier's details to pm.
	"g{.*}ld.*быcтpo.*oплaты.*пocтaвщикoв", --Продам [G[circle]LD], Быстро, надежно, различные способы оплаты. Аттестат продовца. Ищем поставщиков подробности в пм.
	--selling [circle] 1k at 13 rub
	"^пpoдam.*{.*}.*%d+кзa%d+pуб", --продам [circle] 1к за 13 руб
	--Help with RPBБ. [blue square] 2200 - 2400 - 2600. CAP [blue square]. Fast and safe. Best service. Without share of your account. You are play yourself. Site, BL 320+. Skype: R
	"быcтpo.*бeзoпacнo.*cepвиc.*aккaунтa.*cкaйп", --Помощь с РПБ. [blue square] 2200 - 2400 - 2600. КАП [blue square]. Быстро и безопасно. Лучший сервис. Без передачи аккаунта. Вы играете сами. Сайт, БЛ 320+. Скайп: R
	--Help with RBG raiting  2200.2400.2600. Cap. Detail in skype Axelretreem
	"пomoжem.*pбгpeйтингom.*%d%d%d%d.*cкaйп", --Поможем с РБГ рейтингом  2200.2400.2600. Кап. Подробнее в скайп Axelretreem
	--[PLAY-START_RU] G[circle]l0d0 from 14,8r, any kind of payment, delivery 5-15min. Reiiably. Attestat of seller's. We are looking for suppliers details in pm.
	"playstart[%.,]?ru.*oплaты.*дocтaвкa", --[PLAY-START_RU] З[circle]л0т0 от 14,8р, различные способы оплаты, доставка 5-15мин. Надежно. Аттестат продовца. Ищем поставщиков подробности в пм.
	--Sell shiny little coins guarantees [circle]
	--Продам блестяшки гарантии [circle]
	--sell shiny little coins [circle]
	"^пpoдamблecтяшки", --продам блестяшки [circle]
	--We are help with Arena and RBG 2200\2400\2700. Hero of Alliance\Horde [Dving.ru]
		--Поможем с Ареной и РБГ 2200\2400\2700. Герой Альянс\Орды [Dving.ru]
	--Honor points , Conquest, Valor on site [Dving.ru]
		--Очки чести , Завоеваний, Доблести на [Dving.ru]
	--We are help with GCR, GDSR, GFR on site [Dving.ru].
		--Поможем с СРК , СРДД, СРОП на [Dving.ru].
	--We are sell Glory of the Hero of Pandaria [Dving.ru]
		--Продадим Славу Героя Пандарии [Dving.ru]
	--Personal service and individual orders for [Dving.ru]
	"д.*dving%.ru$", --Персональное обслуживание и индивидуальные заказы на [Dving.ru]
	--[square][skull][Gold] at 14r for 1000 on site [WHISPERS RU].Raids,BG,Arena,levelling,professions,mounts and pets.Windsteed and timecard for gold Skype [Whispers.ru] ICQ634-810-845[star]
	"whispers%.?ru.*гoлд.*cкaйп", --[square][skull][Золото] от l4p за l ООО на [WHISPERS RU].Рейды,БГ,Арена,прокачка,профессии,маунты и петы.Ветророг и тk за голд Скайп [Whispers.ru] ICQ634-810-845[star]
	--[circle]15 for 1000! Website [Gann-money.ru]! All kinds of payments! Gifts wholesalers! High BL! ICQ 9937937 skype Gann-money or operator on the site!
	"gannmoney%.ru.*skype", --[circle]по 15 за 1000! Сайт [Gann-money.ru] ! Все виды оплат! Подарки оптовикам! Высокий БЛ! ICQ 9937937 skype Gann-money или оператору на сайте!
	--{квадрат} Продаём баклажаны от 16р за 1к.  Bcе виды оплат. BL245+. Сайт WoWMoney.гu. Связь через icq З84829 или cкайп wowmoneyally .{квадрат}
	--{треугольник} Продаём {круг} от 16р за 1к.  Сайт WoWMoney.гu. BL245+. Bсe виды оплат. Связь чeрeз скайп wowmoneyally или icq З84829 {треугольник}
	"пpoдaem.*wowmoney%..*icq", --{звезда} Пpодaём голдец от 16p зa 1к.  BL245+. Bсe виды оплaт. Caйт WoWMoney.гu. Cвязь чepeз скaйп wowmoneyally или icq З8-48-29 .{звезда}

	--[[  Chinese  ]]--
	--嗨 大家好  团购金币送代练 炼金龙 还有各职业账号 详情请咨询 谢谢$18=10k;$90=50k+1000G free;$180=100k+2000g+月卡，也可用G 换月卡
	--{rt3}{rt1} 春花秋月何时了，买金知多少.小楼昨夜又东风，金价不堪回首月明中. 雕栏玉砌金犹在，只是价格改.问君能有几多愁，恰似我家金价在跳楼.QQ:1069665249
	--大家好，金币现价：19$=10k,90$=50k另外出售火箭月卡，还有70,80,85账号，全手工代练，技能代练，荣誉等，华人价格从优！！买金币还是老牌子可靠，sky牌金币，您最好的选择！
	"only%d+.*for%d+k.*rocket.*card", --only 20d for 10k,90d for 50k,X-53 rocket,recuit month card ,pst for more info{rt1}另外出售火箭月卡，买金送火箭月卡，账号，代练等，华人价格从优！！
	"金币.*%d+k.*惊喜大奖", --卖坐骑啦炽热角鹰兽白色毛犀牛大小幽灵虎红色DK马等拉风坐骑热销中，金币价格170$/105k,更有惊喜大奖等你拿=D
	--17=10k 160=100K 359BOE LVL85 Account For SaIe 疯狂甩卖 P0werleveling 1-85 only need 7days 还有大小幽灵虎
	"%d+=%d+k.*boe.*p[0o]we?rle?ve?ling.*虎", --17=10k 160=100K 359BOE疯狂甩卖 P0werleveling 1-85还有大小幽灵虎等你来拿PST
	"%d+=%d+k.*r0cket.*p[0o]we?rle?ve?ling", --$50=30k $80=50K+X-53T0uring R0cket+1 M0nth G@me Time , 378B0Es For SaIe 疯狂甩卖 P0werleveling 1-85 only 7 days, Help Do Bloodbathed Frostbrood Vanquisher Achivement!代打ICC成就龙,华人优惠哦
	"金.*%d+=%d+k.*boe.*虎", --暑假WOW大促销啦@，金币超低价 <200=100k+10kextra> , 国服/美服1-85效率代练5天完成，378BOE各种装备甩卖，各职业帐号，大小幽灵虎等稀有坐骑现货，金币换火箭，月卡牛
	"only.*%d+k.*deliver.*售", --only 17d for 10k,160d for 100k,deliver in 5mins, pst for more info另出售装备，账号，坐骑，85代练，华人价格从优！！!
	"专业代练.*安全快速发货", --17美元=10k  大量金币薄利多销，货比三家，专业代练1-85，练技能，账号，火箭月卡，还有各种378BOE装备，各种新材料，大小幽灵虎，专业团队代打ICC成就龙，刷荣誉等，安全快速发货
	"cheap.*sale.*囤货", --WTS [Blazing Hippogryph] [Amani Dragonhawk]cheapest for sale,pst,plz 龙鹰和角鹰兽囤货，需要速密，谢谢
	"金币.*卖.*买金币", --感恩大回馈金币大甩卖 ,买金币送坐骑，送代练，需要的请M,另外有378装备，代练，帐号，月卡出售。大、小幽灵虎，犀牛，角鹰兽， 魔法公鸡，赤红DK战马,战斗熊等
	"wts.*%[.*%].*gear.*%d+k.*gift", --WTS大卖 [Dragonbelly Bracers] [Boots of Fungoid Growth] lvl384 or 397 pattern gear Gem 150$=100k+a free gift,17$=10k, pst withi more offer
	"wts.*%[.*%].*cheap.*囤货甩卖", --WTS [Savage Raptor] [Blazing Hippogryph] [X-51 Nether-Rocket X-TREME] cheap pst,囤货甩卖，需要的
	"wts.*%[.*%].*cheapgold.*%d+k", --WTS大卖 [Pattern: Bladeshadow Wristguards] [Pattern: World Mender's Pants] and cheap gold 10k for 15,100k for 140 pst
	--WOW龙魂8H效率团低价出售橙匕+WOW各版本橙武。 397/403/410/416装备。带刷成就龙(ICC,ULD,CATA,FL)。帅气坐骑.死翼坐骑/火鹰/等。带刷RBG荣誉.1-85手工代练美金消费欢迎咨询QQ: 1416781477
	"出售.*成就.*欢迎.*qq", --WOW龙魂8H美金消费团出售橙匕+WOW各版本橙武。 397/403/410/416装备。带刷成就龙(ICC,ULD,CATA,FL)。低价出售帅气坐骑.死翼坐骑/火鹰/等。带刷RBG荣誉.1-85手工代练欢迎咨询QQ: 1416781477
	"wts.*nightwing.*order.*gametime", --WTS[Heart of the Nightwing]order 50k will get a free one plus 30days game time{star}买金送招募坐骑,炼金龙和DK马,大小幽灵虎特价出售,另有各种代练和账号{diamond}QQ：1933089703
	"freemount.*[0o]rder.*stock.*skype", --get free mount with 50k 0rder,300k in stock, skype: sue861029,24/7 online。金币14刀一W，纯手工做任务专业代练，85-90仅需一天，价格优惠。更有稀有坐骑10只打包特卖，大小幽灵虎，白犀牛，大战熊，魔法公鸡쾰
	"^wts.*challenge.*transmog.*mount.*qq%d+", --wts challenge mode:transmog set and mount qq:498890740
	"金币.*服包团.*便宜卖.*QQ", --{rt3}金币100刀10w,15w送幽灵坐骑哦{rt3}金牌挑战特价，当天完成{rt3}TOT 全通，lvl522武器饰品，t15套装特价，无需转服{rt3}MSV/HOF/TOES跨服包团，各等级，专业代练便宜卖{rt3}{rt3}QQ：1933089703
	"gold.*powerlvl?ing.*fast.*best.*skype", --WTS{rt3}{rt3}Gold Challenge Conqueror{rt3}{rt3}Powerlving1-90/85-90/1-85{rt3}{rt5}{rt3}Fast & Best services{rt1}{rt1}Pst for details--Skype:tessg4p--{rt1}{rt1}金牌挑战模式，等级代练，请Q：2584052418--
	"坐骑.*rbg.*2200.*skype", --{diamond}代打金牌挑战模式***各类职业。奖励。奖励一套拉风幻化装，凤凰坐骑一枚+等级代练，RBG2200/2400/2600/2700/...+每周混分-skype:tessg4p--幽灵虎团队 778587316

	--[[  Advanced URL's/Misc  ]]--
	"happygolds.*stock.*receive", --[Enchanted Elementium Bar]{RT3}{RT3}{RT2}Feldrake{RT3}hàppygôlds,Cô.m{RT4}{RT3}{RT2}WE HAVE 800K in stock and you can receive within 5-10minutes {RT3}{RT3}hàppygôlds,Cô.m{RT4}{RT3}E
	"%d+eu.*deliver.*credible.*kcq[%.,]", --12.66EUR/10000G 10 minutes delivery.absolutely credible. K C Q .< 0 M
	"deliver.*gears.*g4p", --Fast delivery for Level 359/372 BoE gears!Vist <www.g4pitem.com> to get whatever you need!
	"pkpkg.*boe.*deliver", --[PKPKG.COM] sells all kinds of 346,359lvl BOE gears. fast delivery. your confidence is all garanteed
	"service.*pst.*info.*%d+k.*usd", --24 hrs on line servicer PST for more infor. Thanks ^_^  10k =32 u s d  -happy friday :)
	"okgolds.*only.*%d+.*euro", --WWW.okgolds.COM,10000G+2000G.only.15.99EURO}/2
	"mmo4store.*%d+[kg].*good.*choice", --{square}MMO4STORE.C0M{square}14/10000G{square}Good Choice{square}
	"promotion.*serve.*%d+k", --Special promotion in this serve now, 21$ for 10k
	"pkpkg.*gear.*pet", --WWW.PkPkg.C{circle}M more gears,mount,pet and items on
	"euro.*gold.*safer.*trade", --Only 1.66 Euros per 1000 gold, More safer trade model.
	--WWW.PVPBank.C{circle}MCODE=itempvp(20% price off)
	"www[%.,]pvpbank[%.,]c.*%d+", --Wir haben mehr Ausr?stungen, Mounts und Items, die Sie mochten. Professionelles Team fuer 300 Personen sind 24 Stunde fuer Sie da.Wenn Sie Fragen haben,wenden Sie an uns bitteWWW.PVPBank.C{circle}M7 Tage 24 Uhr Service.
	"wts.*boeitems.*sale.*ignah", --wts [Lightning-Infused Leggings] [Carapace of Forgotten Kings] we have all the Boe items,mats and t10/t10.5 for sale .<www.ignah.com>!!
	"mmoarm2teeth.*wanna.*gear.*season.*wowgold", --hey,this is [3w.mmoarm2teeth.com](3w=www).do you wanna get heroic ICC gear,season8 gear and wow gold?
	"skillcopper.*wow.*mount.*gold", --skillcopper.eu Oldalunk ujabb termekekel bovult WoWTCG Loot Card-okal pl.:(Mount: Spectral Tiger, pet: Tuskarr Kite, Spectral Kitten Fun cuccok: Papa Hummel es meg sok mas) Gold, GC, CD kulcsok Akcio! Latogass el oldalunkra skillcopper.eu
	"meingd[%.,]de.*eur.*gold", --[MeinGD.de] - 0,7 Euro - 1000 Gold - [MeinGD.de]
	"%$.*boe.*deliver.*interest", --{rt3}{rt1} WTS WOW G for $$. 10k for 20$, 52k for 100$. 105k for 199$. all item level 359 BOE gear. instant delivery! PST if ya have insterest in it. ^_^
	"^wtscheapergold/whisper$", --{square} WTS CHeaper gold /whisper {square}
	"wowhelp%.1click%.hu", --{square}Have a nice day, enjoy the game!{square} - {star} [http://wowhelp.1-click.hu/] - One click for all WoW help! {star}
	"g4p.*gold.*discount", --Saray Daily Greetings ? thanks for your previous support on G4P,here I am reminding you of our info, you may need it again :web:G4Pgold,Discount code:saray,introducer ID:saray
	"%d+k.*deliver.*item", --$20=10K, $100=57k,$200=115k with instant delivery,all lvl378 items,pst
	"money.*gold.*gold2sell", --Ingame gold for real money! Real gold for Ingame gold! Ingame gold for a account key! If you're intrested, then check out: "gold2sell.org" now!
	"wtsgold.*mount.*tar?bard.*acc", --WTS gold and some TCG mounts and Tarbard of the lightbringer and 80lvl acc
	"%d+[/\\=]%d+.*gold4power", --?90=5oK Google:Gold4Power, Introducer ID:saray
	"k%.?4g[o0]ldcom.*code", --{star}.W{star}.W{star}W {square} k{triangle}.4{triangle}g{triangle}o{triangle}l{triangle}d {square} c{star}o{star}m -------{square}- c{star}o{star}d{star}e : CF \ CO \ CK
	"kb8g[o0]ld.*%d+.*st[o0]ck", --KB8GOLD com 8.5EUR = 10000,269K IN STOCK NOW!
	--www K4power c@m.Lowest Price + 10% Free G.{Code:4Power}--
	--~~K.4.p.0.W.e.r,C,o,m~~ 4.€.~1O0O0
	"k[%.,]*4[%.,]*p[%.,]*[o0][%.,]*w[%.,]*e[%.,]*r.*%d[%do]+", --WWW K4POWER C0M {Code:Xmas}->>Xmas Promotions{18th Dec-26th Dec}->35% Free,0rder 50k More->X-53 Rocket Mount For Free!
	"%d[%do]+.*k[%.,]*4[%.,]*p[%.,]*[o0][%.,]*w[%.,]*e[%.,]*r", --4e<> 10O0O @ k4põwér C'Q'M @
	"deliver.*g[@o]ldw[@o]w2012", --$$ Lv 1-85=127EUR+7days $$ 397-410 professional equipment,TCG Loot card,rare mount $$ fast delivery within 24 horus $$ g@ldW@W2012 C@M $$
	"wts.*%[.*%].*cheap.*gold.*%d+%$", --WTS [Reins of the Swift Spectral Tiger] [Tabard of the Lightbringer]{rt3}{rt3}cheapest gold,110$=100k,pst with more offer,plz!!!!
	"wts.*euro.*boe.*deliver", --WTS RBG 2400 RATING, 3.88 "euro"=10 K,Also kinds of BOE 11in store.fast delivery,Pst me for detail
	"msn.*salliaes7587.*%d[%do]+", --1K 1TL ! MSN Adresi salliaes7587@hotmail.c@m !isteyene referans gosterilir :)MSNden eklemeniz yeterli!1OOk 9O TL :)
	"gear.*%d+=%d+.*ourgamecenter", --WTS gear & item 410/416, 25m raid team{star}10000=8 ,50000=40{star}wwvv-OurGameCenter-< om{star}waiting for u!!!
	"like.*facebook.*goldsdepot", --{diamant}anyone who {diamant}LIKE {diamant}our FACEBOOK{dreieck}goldsdepot{dreieck}can get 4000  free G !!!
	"g[0o]ld.*deliver.*bonus", --3WG0ldsDepot C0M SAVE UP 40% 15Mins DELIVERY 10000=5.99 NEW MEMEBER CAN GET 10% BONUS,NICE CUST0MER ASSISTANT say “NO” to “ ST0LEN G0LD “!!!
	--{square}G0lDSDEP0T C..0..M {square}{star}10mns.. {star}{diamond} 10k=5.99 {diamond}
	"g[%.,]*[0o][%.,]*[l1][%.,]*d[%.,]*s[%.,]*d[%.,]*e[%.,]*p[%.,]*[o0][%.,]*t.*%d[%do]+[%.,]*[kg]", --{square}G01dsDepot{square}c..0..m {square}10k=5.99{square}Refuse St01en G01d{square}
	"g[%.,]*[0o][%.,]*[l1][%.,]*d[%.,]*s[%.,]*d[%.,]*e[%.,]*p[%.,]*[o0][%.,]*t.*d[%.,]*e?[%.,]*[l1][%.,]*i[%.,]*v[%.,]*e?[%.,]*r", --{diamond} G.0.l.d.s.d.e.p.o.t,C,o,m {diamond}10m,in Dlivry,10000=5.99, 10% Extra G for Easter
	"k[%.,]*4[%.,]*g[%.,]*u[%.,]*i[%.,]*l[%.,]*d.*d[%.,]*e[%.,]*[l1][%.,]*i[%.,]*v[%.,]*e", --3.W,K.4.G.U.I.L.D,C.@.m 4.5 Êürõ--10k+1O%Disçòünt, Délìvèry 6 M.i.n.s
	"k[%.,]*4[%.,]*p[%.,]*[o0][%.,]*w[%.,]*e[%.,]*r.*d[%.,]*e[%.,]*[l1][%.,]*i[%.,]*v[%.,]*e", --3.w,K.4.P.0.W.E.R,c.@.m 4 èü // 1Ok,Délìvèry 6 M.i.n.s
	--Vend RBG 2400{star} 3.88“euro”=10k{moon}rapide et sûre.{star}D'autres types de BOE est également en vente.
	"vend.*prix.*livraison.*wow%.po", --Vend Po à prix interessant Livraison instantanée. Paiement par SMS/Tel ou Paypal, me contacter Skype: wow.po
	"verkauf.*hotgolds.*%d+g", --Gréat Vérkauf! .Hôtgôlds.côrn10000G.only.2.éUR.Hôtgôlds.côrnWWWé habén 783k spéichért und k?nnén Sié érhaltén innérhalb von 5-10 Minutén.wénn Sié kaufén ,  4403
	"%d[%do]+=%d+%.?%d*e.*bonus.*skype", --@1òòòO=5.52ё.5% BòNuS.5-15mins can Gёt./w me for skype@
	"hotg01ds.*%d[%do]+k", --Hôtg01ds. côrn 1Ok=2.99 8081
	--{star}www.OurGameCenter.com{star} 10000=4.69 WTS Smoldering Egg of Millagazor and all 410/416 items droped from DS {star} including achieve,mount,legendary dagger,etc.( 8/8H DS &7/7H FL)
	"ourgamecenter.*wts.*legendary", --www.OurGameCenter.com10K=4.69 we have 8/8H DS 25m raid team ,WTS 410/416lvl BOP items,achiev,mount,legendary dagger,etc. {star} Smoldering Egg of Millagazor
	"billiggull.*koster.*skype", --{star} Interessert i billig GULL? 100k koster 700 NOK (7 NOK pr 1k) – Bet: Pay Pal og nettbank. Bare nor,swe,dk kunder! Lei av kineserene? Jeg er mye sikrere, instant gull etter bet, online ofte og billig! Add meg på SKYPE for mer info: Nolixz1 {star}
	"order.*nightwing.*%d+k.*stock", --WTS{star}50K Order can get <heart of the nightwing> for free,100k Order can get it for free,500k in stock,pst{square}
	"kb8g[0o][1l]d.*deliver", --1OK // 7.9 E { www,Kb8G01d,Com } <5Mins Delivery>
	"mmomarket.*gold.*boost", --{rt1}{rt1} We are MMO-market.com!!! WE are all you ever going to NEED: GOLD / CHARACTERS(from 150$ char to 5000$ char)/ BOOSTs in PvE or ARENA BOOSTs in PvP! FULLY PROFESSIONAL. Come and check us! [MMO-MARKET.COM]{rt1}{rt1}
	"complete.*gold.*challenge.*$%d+.*hurry", --complete all the Gold dungeon challenge (\n?) achievements now only $200 (\n?) paladin(tank) (\n?) shaman), Hurry contact me, you will complete all the Gold dungeon challenge quickly.
	"cheap.*fast.*gold.*item.*skype", --{rt3}{rt3}To get cheap,fast gold and hot items in a great deal, please add my skype {rt3} linda871230 {rt3}for more information!{rt3}{rt3}
	"rbg.*challenge.*mount.*boost", --WTS Iphone game: Clash of Clans  Gems----much cheaper than APP store2200/2400/2700 RGB,get your cool titles todayChallenge Mode, fast get ur Xmogs and mountT14.5 set boosted by 16/16H raid group
	"goldpreise.*server.*skype", --Bieten Top Goldpreise auf allen deutschen Servern! an /w me bei Interesse oder add hambulaa/Skype!!! 55k
	"gold.*challenge.*achiev.*%$%d+.*sk[py][yp]e", --{rt5}{rt5}spots open for Complete all the Gold dungeon challenge achievements， only $79, lvl522 item $100 each piece ,  raid progress TOT12/12,offer t15set, lvl522 lvl535 weapons,trinket etc,  PST to get more info or add skpye jolinvipservice
	"fast4gold.*%d+k.*stock", --[Blazefury, Reborn]Feldrakefast4gold,Cô.mWE HAVE 800K in stock and you can receive within 5-10minutes fast4gold,Cô.mE--------------7286
	"skype.*chefboosting[%.,]com", --{rt6}| WTS RBG Boost|{rt6}, Challenge Mode boost, Power leveling & SoR accounts // Must trusted boosting website in the world, supported by top Twitch Streamers!  contact skype :  chef-xtrem or [www.chefboosting.com]
	"sellgold.*only%d+euro", --{rt1}Sell GOLD! 10.000 GOLD Only 5 Euro!{rt1}
	"mia911[%.,]c.*skype", --{rt6}{rt6}{rt6}{rt6}{rt6}{rt6}{rt6}{rt6}{rt6}[www.mia911.cQm]{rt4}{rt4}{rt4}{rt4}{rt4}{rt4}800K G in sotck{rt5}{rt5}10000=8USD{rt5}{rt5}pl add skype;mia9116{rt5}{rt5}mia911.cQm{rt5}{rt5}{RT
}

--This is the replacement table. It serves to deobfuscate words by replacing letters with their English "equivalents".
local repTbl = {
	["а"]="a", ["à"]="a", ["á"]="a", ["ä"]="a", ["â"]="a", ["ã"]="a", ["å"]="a", --First letter is Russian "\208\176". Convert > \97
	["с"]="c", ["ç"]="c", --First letter is Russian "\209\129". Convert > \99
	["е"]="e", ["è"]="e", ["é"]="e", ["ë"]="e", ["ё"]="e",["ê"]="e", --First letter is Russian "\208\181". Convert > \101
	["ì"]="i", ["í"]="i", ["ï"]="i", ["î"]="i", --Convert > \105
	["Μ"]="m", ["м"]="m",--First letter is capital Greek μ "\206\156". Convert > \109
	["о"]="o", ["ò"]="o", ["ó"]="o", ["ö"]="o", ["ō"]="o", ["ô"]="o", ["õ"]="o", --First letter is Russian "\208\190". Convert > \111
	["р"]="p", --First letter is Russian "\209\128". Convert > \112
	["ù"]="u", ["ú"]="u", ["ü"]="u", ["û"]="u", --Convert > \117
}

local strfind = string.find
local IsSpam = function(msg, num)
	for i=1, #instantReportList do
		if strfind(msg, instantReportList[i]) then
			if myDebug then print("Instant", instantReportList[i]) end
			return true
		end
	end

	local points, phishPoints = num, num
	for i=1, #whiteList do
		if strfind(msg, whiteList[i]) then
			points = points - 2
			phishPoints = phishPoints - 2 --Remove points for safe words
			if myDebug then print(whiteList[i], points, phishPoints) end
		end
	end
	for i=1, #commonList do
		if strfind(msg, commonList[i]) then
			points = points + 1
			if myDebug then print(commonList[i], points, phishPoints) end
		end
	end
	for i=1, #heavyList do
		if strfind(msg, heavyList[i]) then
			points = points + 2 --Heavy section gets 2 points
			if myDebug then print(heavyList[i], points, phishPoints) end
		end
	end
	for i=1, #heavyRestrictedList do
		if strfind(msg, heavyRestrictedList[i]) then
			points = points + 2
			phishPoints = phishPoints + 1
			if myDebug then print(heavyRestrictedList[i], points, phishPoints) end
			break --Only 1 trigger can get points in the strict section
		end
	end
	for i=1, #phishingList do
		if strfind(msg, phishingList[i]) then
			phishPoints = phishPoints + 1
			if myDebug then print(phishingList[i], points, phishPoints) end
		end
	end
	if points > 3 or phishPoints > 3 then
		return true
	end
end

--[[ Chat Scanning ]]--
local Ambiguate, gsub, next, tremove, prevLineId, result, chatLines, chatPlayers, prevWarn = Ambiguate, gsub, next, tremove, 0, nil, {}, {}, 0
local filter = function(_, event, msg, player, _, _, _, flag, channelId, channelNum, _, _, lineId, guid, arg13)
	local trimmedPlayer
	if lineId == prevLineId then
		return result --Incase a message is sent more than once (registered to more than 1 chatframe)
	else
		if not lineId then --Still some addons floating around breaking stuff :-/
			local t = GetTime()
			if t-prevWarn > 30 then --Throttle this warning as I imagine it could get quite spammy
				prevWarn = t
				print("|cFF33FF99BadBoy|r: One of your addons is breaking critical chat data I need to work properly :(")
			end
			return
		end
		prevLineId, result = lineId, nil
		trimmedPlayer = Ambiguate(player, "none")
		if event == "CHAT_MSG_CHANNEL" and (channelId == 0 or type(channelId) ~= "number") then return end --Only scan official custom channels (gen/trade)
		if not myDebug and (not CanComplainChat(lineId) or UnitInRaid(trimmedPlayer) or UnitInParty(trimmedPlayer)) then return end --Don't scan ourself/friends/GMs/guildies or raid/party members
		if event == "CHAT_MSG_WHISPER" then --These scan prevention checks only apply to whispers, it would be too heavy to apply to all chat
			if flag == "GM" or flag == "DEV" then return end --GM's can't get past the CanComplainChat call but "apparently" someone had a GM reported by the phishing filter which I don't believe, no harm in having this check I guess
			--RealID support, don't scan people that whisper us via their character instead of RealID
			--that aren't on our friends list, but are on our RealID list. CanComplainChat should really support this...
			local _, num = BNGetNumFriends()
			for i=1, num do
				local toon = BNGetNumFriendToons(i)
				for j=1, toon do
					local _, rName, rGame = BNGetFriendToonInfo(i, j)
					--don't bother checking server anymore as bnet has been bugging up a lot lately
					--returning "" as server/location (probably other things too) making the check useless
					if rName == trimmedPlayer and rGame == "WoW" then
						return
					end
				end
			end
		end
	end
	local debug = msg --Save original message format
	msg = msg:lower() --Lower all text, remove capitals

	--They like to use raid icons to avoid detection
	local icon = 0
	if strfind(msg, "{", nil, true) then --Only run the icon removal code if the chat line has raid icons that need removed
		local found = 0
		for i=1, #restrictedIcons do
			msg, found = gsub(msg, restrictedIcons[i], "")
			if found > 0 then
				icon = 1
			end
		end
		if myDebug and icon == 1 then print("Removing icons, adding 1 point.") end
	end
	--End icon removal

	--Symbol & space removal
	msg = gsub(msg, "[%*%-%(%)\"`'_%+#%%%^&;:~{} ]", "")
	msg = gsub(msg, "¨", "")
	msg = gsub(msg, "”", "")
	msg = gsub(msg, "“", "")
	--End symbol & space removal

	--They like to replace English letters with UTF-8 "equivalents" to avoid detection
	if strfind(msg, "[аàáäâãåсçеèéëёêìíïîΜмоòóöōôõрùúüû]+") then --Only run the string replacement if the chat line has letters that need replaced
		--This is no where near as resource intensive as I originally thought, it barely uses any CPU
		for k,v in next, repTbl do --Parse over the 'repTbl' table and replace strings
			msg = gsub(msg, k, v)
		end
		if myDebug then print("Running replacements for chat") end
	end
	--End string replacements

	--20 line text buffer, this checks the current line, and blocks it if it's the same as one of the previous 20
	for i=1, #chatLines do
		if chatLines[i] == msg and chatPlayers[i] == trimmedPlayer then --If message same as one in previous 20 and from the same person...
			result = true return true --...filter!
		end
		if i == 20 then tremove(chatLines, 1) tremove(chatPlayers, 1) end --Don't let the DB grow larger than 20
	end
	chatLines[#chatLines+1] = msg
	chatPlayers[#chatPlayers+1] = trimmedPlayer
	--End text buffer

	if IsSpam(msg, icon) then
		if BadBoyLog and not myDebug then
			BadBoyLog("BadBoy", event, trimmedPlayer, debug)
		end
		if myDebug then
			print("|cFF33FF99BadBoy_REPORT|r: ", debug, "-", event, "-", trimmedPlayer)
		else
			if BADBOY_POPUP then --Manual reporting via popup
				local dialog = StaticPopup_Show("CONFIRM_REPORT_SPAM_CHAT", trimmedPlayer, nil, lineId)
				dialog.text:SetFormattedText("BadBoy: %s \n\n %s", REPORT_SPAM_CONFIRMATION:format(trimmedPlayer), debug) --Add original spam line to Blizzard popup message
				StaticPopup_Resize(dialog, "CONFIRM_REPORT_SPAM_CHAT")
			else
				--Show block message
				if not BADBOY_NOREPORT and (not BADBOY_BLACKLIST or not BADBOY_BLACKLIST[guid]) then
					-- This code is replicated from Blizzard's ChatFrame.lua code.
					-- The intention here is to add the "extraData" flag to our AddMessage,
					-- the same way Blizz adds that data to normal messages. Then we can use the
					-- RemoveMessagesByExtraData functionality later.
					local eventType = event:sub(10) -- Trim down to CHANNEL, WHISPER, etc.
					local chatTarget
					if eventType == "CHANNEL" then
						eventType = eventType .. channelNum -- Set to CHANNEL1, CHANNEL2, etc, to separate General from Trade, etc.
						chatTarget = channelNum
					elseif eventType == "WHISPER" or eventType == "AFK" or eventType == "DND" then
						chatTarget = player:upper() -- Set to PLAYERNAME
					end
					local extraData = ChatHistory_GetAccessID(eventType, chatTarget, guid or arg13)
					-- Finally, add the message
					ChatFrame1:AddMessage(reportMsg:format(player, lineId, extraData, guid), 0.2, 1, 0.6, nil, nil, nil, extraData)
				end
			end
		end
		result = true
		return true
	end
end

--[[ Configure report links ]]--
do
	local SetHyperlink, prevReport = ItemRefTooltip.SetHyperlink, 0
	function ItemRefTooltip:SetHyperlink(link, ...)
		local badboy, player, lineId, extraData, guid = strsplit(":", link)
		if badboy and badboy == "badboy" then
			lineId = tonumber(lineId)
			extraData = tonumber(extraData)
			if CanComplainChat(lineId) then
				local t = GetTime()
				if (t-prevReport) > 8 then --Throttle reports to try and prevent disconnects, please fix it Blizz.
					prevReport = t
					ReportPlayer("spam", lineId)
					BADBOY_BLACKLIST[guid] = true
					--ChatFrame1:RemoveMessagesByExtraData(extraData) -- ReportPlayer already runs this
				else
					ChatFrame1:AddMessage(throttleMsg, 1, 1, 1, nil, nil, nil, extraData)
				end
			end
		else
			SetHyperlink(self, link, ...)
		end
	end
end

--[[ Add Filters ]]--
ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_DND", filter)
ChatFrame_AddMessageEventFilter("CHAT_MSG_AFK", filter)

--[[ BNet Invites ]]--
do
	local f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_LOGIN")
	f:SetScript("OnEvent", function(frame,event,bnEvent)
		if event == "PLAYER_LOGIN" or bnEvent == "FRIEND_REQUEST" or bnEvent == "FRIEND_PENDING" then
			if event == "PLAYER_LOGIN" then
				SetCVar("spamFilter", 1)

				-- Throw blacklist DB setup in here
				if not BADBOY_BLACKLIST then BADBOY_BLACKLIST = {} end
				local _, _, day = CalendarGetDate()
				if BADBOY_BLACKLIST.dayFromCal ~= day then wipe(BADBOY_BLACKLIST) end
				BADBOY_BLACKLIST.dayFromCal = day

				frame:RegisterEvent("CHAT_MSG_BN_INLINE_TOAST_ALERT")
				frame:UnregisterEvent("PLAYER_LOGIN")
			end
			for i=BNGetNumFriendInvites(), 1, -1 do
				local id, player, _, msg = BNGetFriendInviteInfo(i)
				if type(msg) == "string" then
					local debug = msg
					msg = msg:lower() --Lower all text, remove capitals

					--Symbol & space removal
					msg = gsub(msg, "[%*%-%(%)\"`'_%+#%%%^&;:~{} ]", "")
					msg = gsub(msg, "¨", "")
					msg = gsub(msg, "”", "")
					msg = gsub(msg, "“", "")
					--End symbol & space removal

					--They like to replace English letters with UTF-8 "equivalents" to avoid detection
					if strfind(msg, "[аàáäâãåсçеèéëёêìíïîΜмоòóöōôõùúüû]+") then --Only run the string replacement if the chat line has letters that need replaced
						--This is no where near as resource intensive as I originally thought, it barely uses any CPU
						for k,v in next, repTbl do --Parse over the 'repTbl' table and replace strings
							msg = gsub(msg, k, v)
						end
						if myDebug then print("Running replacements for BNET") end
					end
					--End string replacements

					if IsSpam(msg, 0) then
						if myDebug then
							print("BNET invite", i, "is spam from player:", player)
						else
							ChatFrame1:AddMessage(reportBnet:format(player), 0.2, 1, 0.6)
							if BadBoyLog then
								BadBoyLog("BadBoy", "CHAT_MSG_BNET_INVITE", "", debug)
							end
							BNReportFriendInvite(id, "SPAM", "")
						end
					end
				end
			end
		end
	end)
end

