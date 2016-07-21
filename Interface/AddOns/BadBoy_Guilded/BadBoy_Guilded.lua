
local strfind, Ambiguate = string.find, Ambiguate
local prevLineId, result, triggers = 0, nil, {
	"wowstead%.com",
	"guildlaunch%.com",
	"gamerlaunch%.com",
	"corplaunch%.com",
	"wowlaunch%.com",
	"guildportal%.com",
	"shivtr%.com",
	"enjin%.com",
	"%.wix%.com",
	"guildomatic%.com",
	"guildwork.com",
	"guildhosting.org",
	"re[cq]rui?t",
	"^wt[bs] guild",
	"wt[bs] %d+%+? guild",
	"wt[bs] %d+%+? le?ve?l guild",
	"wt[bs] le?ve?l %d+%+? guild",
	"selling le?ve?l ?%d+ ?guild", --selling lvl25guild 100k
	"^wtb a guild", --WTB a guild around lvl 15, make me an offer!
	"^wtb low le?ve?l guild", --wtb low lvl guild for cheap money, any lvl will do
	"looking for.*join [ou][us]r?",--<> is Looking for Dedicated and skilled DPS and Healer classes to join us in the current 10 man  raids and expand to 25 man raids. Raids on mon,wed,thurs,sunday 21.00-24.00 18+
	"www.*apply", --pls go to www.*.com to apply or wisp me for extra info.
	"looking.*members", -- <<>> is a social levelling looking for all members no lvl requirement, Once we have more members were looking to do Raids and PvP premades, /w if you would like to join please or  /w me for info.
	"levell?in.*guild", --<> Easy Going Leveling Guild LFM of any levels, we are friendly, helpfull and have 6 guild tabs available.
	"apply.*www", --<> We Are Looking For people Item lvl 333+ for our25man Cataclysm Raiding team. Must Be over 18+ to Apply or Have some insane Skills. If you Got Any Questions Go to www.<>.net Or contact me or a officer.
	"social.*guild.*info", --<> is a newly formed social guild for all classes and levels. Our aim is to have fun and we hope to do raids when we are big enough. For any more info or an invite /w me. Thank You.
	"pvp.*pve.*wh?isper", --instead of joining solo and end up loosing with randoms. Ofcourse we group up for Random HCs with both PvP and PvE players aswell and if the PvE group need an extra player for the raid, PvP guys can get invited. Whisper me for more info.
	"whisper.*info.*http", --Whisper me for more info or visit http://*.com/
	"looking for.*http", --<> Looking for: Resto shaman&Tank. You need skill, focus and patience to learn and pass the fights. If you want to clear bosses before the nerfs then this is the right place for you /w or go to http://<>.info
	"guild.*pst",--<> an adult guild looking for more players who are active ,like to have fun ,talk in vent & will help others. LVL 5 GUILD !we'd like fun people to enjoy the new content of CATA,all lvls, classes, races are welcome PST FOR MORE INFO/INVI
	"guild.*bank.*tabs", --Looking for a guild to relax after a hard day of work or school? <> is layed back and alota fun. We are a lev 7 guild and have 7 Guild Bank tabs. we have vent as well so stop by and check us out. come run some dungeons..
	"guild.*wh?isper m[ey]", -- <> is a layed-back social level 10  heroic/raiding guild. We organize a few heroics/raids a week and ALWAYS use teamspeak while doing so. Is this something you like to do? Whisper me!
	"looking.*strengthen.*raid", --<> is looking for, 1 ele sham, 1 balance druid, 1 holy pala,  to strengthen our raid teams for the current 10 man raids. Raids 21.00-24.00 Mon,Wed,Thurs,Sun. 349+ gear req age 18+
	"guild.*welcome", -->< is a new dungeon/raid guild we are setting up our raid/HC group. ofc every lvl is welcome in our guild but we preff 60-85 all classes/races. You also have to be an active player
	"guild.*looking", -->< raiding guild. (5/12) we are looking for exp/dedicated players for our 10mans. slowly moving into 25mans. must have a ilvl 350+ (need 1 tank, 2 ranged(pref. boomkin), 1 melee(pref enhance)
	"lookk?ing.*welcome", --<> is a lvl 11 recuiting for their 10man group, lookking for people with experiance with a min 348 ilvl (2ranged dps ) all other players are welcome we are 6/12 with cataclysm bosses - raid times are mon - thurs 8:00pm to 12:00am (midnight) Pst
	"le?ve?l.*open.*raid", --<> <lvl 23> has openings in its' 25 man raid group, Raids are Sunday - Thurs 9-12. see xyz.com for info
	"looking.*raidtimes.*/w", --Knixxs Order of the Darkside -  Lvl 25. We are on the lookout for Tanks and Healers for our raidteam. We are currently 5/12 and looking to progress further. Our raidtimes are: Wed, Thurs and Sunday, 21:15 realm time. For more info /w me. Thanks :)
	"social.*leveling.*looking", --<> <level 6> Is a social leveling looking for people to fill out raiding spots. Currently in need of dps and healers. Starting firelands trash runs & eventually boss runs.
	"looking.*player.*social", --<> (6) Looking for more players to set our first raiding team and also our first RBG team! We are looking for social players that is experienced of either Raiding or PvP. Whisper me if you want more information about us and our plans!
	"team.*looking.*raiders", --<> is trying to gather a exceptional raiding team to raid FL hc and DS, we are curently looking for skilled raiders who knows the bosses, have decent gear and have a fair amount of raiding exp, we raid Mondays and Thursday 20:00 - 23:00
	"looking for.*raid.*progress", --<> is currently looking for a Warlock ready for raiding DS10 HC. We're currently 5/8 HC and progressing every week. You have to know what you're doing and your gear must be ready to go tonight. We prefer Swedes
	"social.*looking.*join", --Hello there! :D  * (lvl25)  is looking for socials. We're looking for pvp, old raid, chat or leveling oriented ppl or ppl who like to chat. We got spots for social/alt raids aswell, if u like to raid. Fancy joining? /W me! hf :D
	"new.*guild.*rate", --<*> is a newly formed pvp guild, aiming to do rated bgs. No lvl requirement atm
	"need.*apply", --[*]  7/8 HC ,in need of 1x melee  DPS &1x range dps and 1x healer . exceptionals are always  welcome to apply @ *, com  , /w for more info
	"progress.*raid.*interest", --<*>  is 1/8 DS 10 HC, working @ progress in DS Heroic. We look for ppl who love progress like a team. Atm we need all clases. We raid Wednesday and Thursday (alt run). /w me if u are interested to progress.
	"social.*member.*inv", --* Focus on PvP, we are social and friendly. We do lots of random BG's 2gether, Arenas and also RBG! We got TS server. We give you FREE Gems! we care about our members. For more info or an invite just /w me. Req is lvl 85.
	"le?ve?l.*looking.*social", --<*> [lvl 25] is currently expanding!. looking for more social and enthusiastic PvP'ers. Hpala/Rshamans pref /w me for a short chat! only taking 2k+ arena or RBG. the exp must be on current char.
	"le?ve?l.*looking.*experience", -- * (lvl25) Is looking for, 1 exceptional holy paladin. And a resto druid/shaman with a dps offspec. we're raiding 5 days a week. /w me with your experience and interests. You need to be a cut above the rest.
	"join.*social.*guild", --Lowbies of Azeroth, join <*>> (level 23) and level together in this social & fun guild. ! Earn gold by doing guild challenges!
	"join.*le?ve?l.*guild", --Join our level 19 PVP guild! And get paid 30g per arena win! while playin' with guildies!
	"guild.*casual.*repair", --* (level 25 guild) is LF more pvers to complete our raiding teams! We are a casual raiding guild. (Some HC) We have guild funded repairs,  our own vent, active old raid achi runs, etc. We have many achievements unlocked.
	"raid.*social.*progress", --Are you a dedicated raider that wants in a regular team and like to socialise? Are you that player that is trustworthy and shows up at the raid? Then your the guy we want. ATM all classes are accepted, progress: 8/8, 2/8 hc ds. Whisper me for more info.
	"looking.*active.*join", --<*> [3] Is looking for active players to join the ranks and start raiding. Looking for all roles for Dragon Soul /w For Inv
	"social.*guild.*invite", --<*> (Lvl: 20) Social Raiding guild, raid 2 nights a week. Currently 8/8 10N 1/8 10HC. Invites are open for all.
	"searching.*people.*progress", --<*> Is searching for more people for our 10 man raiding team! we are full on healers and need some imba dpses and 1 tank to continue our progress right now we are 8/8 normal /w me!!
	"le?ve?l.*looking.*class", --<*>lvl 25 5/8hc is looking for 1tank  and 1rdps(prefsp or lock ) for our DS 10man hc raid group  we raid at sun-mon-wed ftom19:00-23:00 be at least 390ilvl and know your class 100% then /w me so we can speak
	"looking.*social.*guild", --LOOKING FOR 25 SOCIAL GUILD ROGUE LVL 85!!
	"looking.*progress.*info", --<*> is seeking a Tank for our DS10 Runs. Bring ilvl 395+. We have 4/8 HC. Looking to progress to 5/8 HC asap.  Raid days are Wed / Fri 20:00 - 23:00. /w for more info
	"player.*clear.*info", --<*> LF PVE Player  We Cleared DS 10 Man and We need  1 Healer (Druid or Paladin) 2 Spot For RDPS Warlock and Boomkin  /w me for more info
	"searching.*raiders.*progress", -- * We are searching for hardcore raiders for HC DS progression, You will need 395+ Ilvl, Achievement (8/8 Normal, Minimum), Microphone and to be above 16+. Searching for Druid (Tank) or a Death Knight (Tank).
	"guild.*seeking.*exp", --REGAIN {skull}25 lvl{skull} 8/8 HC DS raiding guild seeking for raiders/pvpers and socials for MoP. RBG team leaded by 2.4k experienced pvpers.
	"guild.*classes.*members", --* are currently lvl 17 and are rebuilding the guild so were accepting all classes and lvls, we are not interested in what item lvl you have we are interested in social members and want people to enjoy the game,whisp for info :)
	"looking for.*player.*class", --* lv 25 We are looking for solid players who are wanting to be part of a guild that will be competitive and will advance quickly in MOP.We are a active friendly raiding guild currently accepting all classes.we are 8/8 heroic DS
	"looking for.*pvp.*whisper", -->* is looking for more PvPers to fill our ranks. If you're level 85 and enjoy killing Alliance then whisper me now for an invite. Come get ready for the big adventure into MOP.
	"guild.*dungeons.*mount", --* Are LF more 85's to do guild heroics and dungeons Also working on Filling out our raid teams As well as giving away great prizes every lvl gain as well as choppers .We do mount runs all over the place
	"new guild.*join", --New guild formed : * : is a new harcore pvp guild req to join is 2400 exp in arena or rbg , doing rbg every week so be active
	"lv%d+.*guild.*need.*wh?isp", --{rt1}{rt3} * LV25 guild. Is LF heals for rbg team. we need a extra shamen, holy and disc. do you have gear/skills wisp me {rt3}{rt1}
	"<.*>.*looking.*%d/%d", --<*> Currently looking for Healers with atleast 6/6 experiance, prefer Druids/Paladin & Warlock/DK Dps  we currently have 6/6 down in MsV10 & 2/6 HoF! Whisper me for more information!
	"[12][05]m.*progress", --{rt3} * {rt3} (10man) (6/6 MSV)(2/6 HoF). Our core is in need of tank (dk,druid) and 1 ranged dps (hunter,druid). If you are skilled and want to progress in new raids, feel free to whisper (18+). Raid days / time: Wed, Thur, Sun / 20:00-23:00
	"looking for experienced raiders", --<*> is looking for experienced raiders! What we need 1tank:Druid,DK,War / 1heal: Shaman,Druid (with good dps os) / some dps: Mage, Shaman(elemental with good heal os), Moonkin(with good heal os), Rogue / We raid 3-4times a week 19:30-22:00
	"social.*guild.*join", --* lvl 1 asocial guild open for members. Join us if you want a guild tag and a tabard.
	"%d+m.*looking.*raiders.*need", --<*> 25man 16/16N  66/16H Looking for Solid raiders. Ranged DPS needed. (SP / Mage / Lock / Boomkin / Ele Sham. www.*.com RAID TIME MTW 10:30pm-1:30am Server
	"friendly.*active.*guild.*relax", --~~Tired of being on the sideline in your guild with no one to talk to? Want a more friendly yet active guild? Have a sense of humor? Come and relax in ~~*~~ (20) and make some new friends =)
	"looking.*active.*people.*info", --{rt1}* Looking for Active, Skilled and experienced people for RBG/Arena | Even WorldPvP, funny events | In need of Rshamans,Wlocks and 1 hpala | Bring 1600+ exp, Skype/TS3 and good gear | /w for more information|{rt1}
	"pvp.*searching.*people.*guild", --== * == (Hardcore PVP) is now searching people with 2k + arena or rbg exp. Achivments has to be provided - No exceptions. (THIS IS --- NOT--- PILAVS GUILD. )
	"team.*looking.*people.*tactic", --<*> LFM for our raiding team,We are looking for people with excellent communication skills whom are willing to put an effort into raiding with us! We are very patient when it comes to raiding and new people learning the tactics.
	"guild.*active.*social", --Hello, are you looking for a guild that is active for real? We "*" have events each night of the week, a HC 10m team, a 25m normal team, a RBG team, and enough social events to enjoy:) if you are social and mature, we can fit you in:)
	"guild.*members.*community", --* new PvP guild, has already 150+members and great leaders we will shortly become the best pvp guild for the long term on * if you are 2.4+ cr/ RBG 2.4+ or hero pm me - already has alot of good players and good community
	"team.*raid.*visit", --<*> 12HC LF Skilled , Dedicated & Exceptional HC raiders for our team to expand for SoO/WoD 20m. We advocate patience, respect & communication - working together to provide a strong & enjoyable raid experience! Visit our site or /w me
	"guild.*player.*info", --{rt8} * {rt8} Persian 14/14 HC guild, switching to 25-man raiding for final resets of MOP, need more DPS players.9 HCs+25man HC raiding XP required, Times: Wed, Fri, Sun, Tues 18:30 - 22:00. /w for more - info
	"le?ve?l%d+.*progress.*whisp", --<*> <lvl 25> <14/14 n soo> we are in need of dps and healers to increase to 25 man we raid wed/sun/mon 8pm please be 560 item level and have 14/14 progress to start hc. we in need of mage and warlock the most.please whisper.
	"looking.*raiders.*interest", --{rt6} * (lvl25) {rt6} is currently looking for serious Raiders for our WoD team. We need R-Dps(mage,druid), Tank(monk), Healer(priest,shaman). If you interested /w me and let's have a chat !
	"guild.*missing.*info", --Guild {rt1} <*> (10M) Have Downed 7/14 Hc , We are Re-Building Again, We are Missing 2 tanks and 2RDps (Hunter) And 1 dps With Os heal) Have atleast 570+ And atleast 6/14 Hc exp , We Raid At Wed-Thurs-Mon 6 To 9:00 ST /W For more Info
	"social.*community.*pv[ep]", --[*] Are you looking for a social And Mature Community? That focus's on all Aspects of Wow! So if you Enjoy PvE, PvP or just want to be social then we're the place for you! Interested? head over to * (16+) or /w me!
	"looking.*player.*mature", --* is looking for more experienced and willing players for WoD raiding, We'll be raiding Mythic and so we request you to optimise your gameplay:) All we ask is mature and positve behaviour. Please /w me if interested
	"looking.*friendly.*team", --<*> is currently looking for friendly and raid experienced players for WoD raiding team. We need mostly DPS but also some healers. /w me for some more info
	"join.*guild.*info", --Are you sick and tired of playing alone? Do you want to join a guild that treasures its community and values clearing WOD content together? Then wait no longer and join <*>, we'll be clearing raids, RBGs and enjoy guild events. /w for more info
	"guild.*mature.*social", -- -*- is a large social guild with lots of friendly mature people, who enjoy the social side of the game we do classic raids, achies, rep runs if youre after a friendly social guild look no further than * and give me a wisper  :)
	"looking.*community.*accepting", --<*> Are looking for more people. We are creating a mature and active community to participate in dungeon runs and casual raiding in WoD. Accepting all classes, whisper for more info or an invite.
	"team.*looking.*people", --<*> LF Healer   for our raiding team,We are looking for people with excellent communication skills whom are willing to put an effort into raiding with us!
	"looking.*progress.*/w", --<*> (7/7N 2/7HC) Is looking for skilled DPS + Healers for our progression to close out highmaul and move further into HC. iLvl is no prerequisite, we are looking for loyalty and potential. Sound like your kind of environment? Give me a /w!
	"team.*social.*welcome", --<*> Lfm for fresh raid team starting with highmaul normal , ts3 , mondays at 8:30pm to 10:30pm realm time. socials also welcome  ,whisper me for info/invite.
	--* is looking for more experienced and willing DPS and a tank or healer for our second raid team, your dps and movement needs to be brilliant:) All we ask is mature and positive behaviour. Please /w me if interested
	"looking.*experi[ae]nced.*raid", --"*" 7/7 N - 6/7 HC. is curently Looking for more raid experianced ppl For moving Mythic were kinda low on warlocks and a good boomkin might do wonders :D We raid Mon/Tues and Thursdays 19.30 server time. Have a nice game :)
	"dedicated.*player.*looking", --<*> Currently 7/7 HC HM and 7/10 HC BRF. Searching for mature and dedicated players to join our ranks! Raid times; Wed, Thu, Sun 2000-2400 (Sevrer time.) Looking for 1 Tank (Pref BM), 1 Resto druid and DPS
	"need.*casual.*guild.*", --* 9/10 NM 2/10 HC is in need of a tank (DK pref.), A good mix of some ranged and meellee dps - and a healer (no priest)! We are a fun, casual raiding guild, with a weird sense of humor! Come and join the funhouse :D!
	"looking.*require.*raid", --<*>  BRF 9/10 HC are currently looking for a MW monk, uh dk, ele shaman, and a warr, for our prog in  BRF,We do require that you are 18+ and can raid wednes-, sun- and mondays 20.00-23:00 and have min 670 ilvl req
	"join.*team.*player", --{rt8} * {rt8} Want you to join our core raid team! LF 670+ players who want a softcore raid team. We raid Fri 20-23 and Sun 20-23 (Sat as alternative day) To fulfill the core team, LF Healers and ranged DPS pref you being 7/10 HC BRF.
	"friendly.*team.*whisp", --Apart from that, we want a friendly, helpful environment in order to be able to work as a team, not individuals. Everything from Farming Honorable Kills for The Bloodthirsty title to Glory of The Raider achievements. Whisper me for a chat, thank you.
	"looking.*team.*info", --* is looking for more strong DPS and a strong healer for our main team. For our second team, DPS and healing spots are open, Our main team is 7/10 HC, our second team 8/10 N and 3/10 HC. If you are interested please /w me for more info
	"searching.*raid.*info", --<*>  (6/7M HM) (6/10 BRF M) We are Searching For an Exceptional Tank + Mage/Ele/Rogue/Moonkin! We raid wed,thurs,sun (19:30-23:00) Head over to [http://www.*.com/] or wisp me for info!

	--Dutch
	"guild.*zoek naar.*social", -- [25] Nederlands sprekende Guild <*> zijn op zoek naar Tanks: Geen / Melee dps: Warrior / Ranger dps: warlock, Mage / Healers: Paladin / raid tijden ma, di ,do van 20:00ST tot 23:00ST, social invite is ook mogelijk whisper voor meer info.
	"recruut.*guild.*welkom", --<*> recruut momenteel 1 Boomkin en 1 frost mage voor ons RBG team. Cleanse is een Nederlands talige pvp guild. Alle nederlandstalige spelers zijn welkom om te joinen. Onze we spelen op donderdagen en zondagen om 20:00. Whisp voor meer info
	"guild.*gezellige", --<*> is een nederlandstalige casual/raiding guild. We zijn op zoek naar casual mensen die onze gezellige guild willen joinen. /w mij of * voor meer info
	"guild.*op zoek", --<*> HM (7/7 heroic) en BRF (3/10 HC) is een nederlandstalige casual/raiding guild. We zijn op zoek naar mensen met raid experience voor ons mythic team. We raiden 3 dagen per week /w me voor meer info

	--Swedish
	"rekryt", --<*> rekryterar. Vi söker aktiva spelare från Sverige och Norge. Vi är i behov av DPS (SPriest, Boomkin, DK) och en tank (warr, DK) med dps OS. Progress: 3/8 HC, raidar onsd, sön & mån 20-23. Socials är alltid välkomna!. /w för mer info
	"guild.*söker", -- *  är ett svenskt  LvL25  guild som nu söker nya members. Vi kör Dragon Soul 10-manna. Vi söker PvE till Raid, PvP:are till RBG:s och även sociala spelare som vill ha ett bra ställe att hänga på :)
	"guild.*folk.*whisp", --<*> Nystartad, svensk, seriös PvE-guild som satsar på att få in seriöst folk till våra 10-manna DS Heroics. Raidar fre 20-00 samt sön 19-22. Låter detta intressant så whispar DU mig för vidare information.
	"söker.*guild", --<*> Söker nu efter aktiva gamers som vill ingå ett helt fresh RBG team inom guilden. Vårat mål är 2.4-HOTA. T2/legendary/Bra pve items är STORT PLUS. REQ: 2.2k exp RBG/ARENA. Störst behov: Boomkin, Rshaman eller Rdruid och Disc
	"söker.*progg?ress", --<*> DS 2/8 HC Söker nu efter 1 healer (hpala,dpriest,rshammy) för HC proggress i DS /w mig så tar vi ett snack.
	"guild.*info.*välkommna", --HEJ ! nu startar vi en ny svensk guild för barna runt 13 år . Vi kommer köra raids som BH , FL , DS kanske börja lite lätt med BwD och BoT , vi vill gärna att ni ska ha skype :) w spec och class / w för mer info!!! ni är välkommna :)
	"letar.*söker.*info", --<*> letar efter raiders till vårat DS 10 manna team. Just nu så söker vi efter 1 warrior tank och en paladin tank, 1 disc präst och 1 holy paladin och 1 Mage. Vi kommer att raida från 19:00-22:30.  Viska mig för mer info
	--Guilden "*" Letar efter nya spelare till Ds 10, Vi har 4 hc on farm och letar efter mer folk som kan bidra till en full Hcclear inom sin tid!
	--Är du svensk och letar efter en svensk guild?Vi i Guildet "*" är en nystartad i level 11 och letar alla sorters medlemmar, vi är just nu en social guild som kommer satsa på Raiding och förhoppningsvis PVP också.
	"guild.*letar", --* 10m semi-hardcore raiding guild letar efter en healer (ej paladin) för fortsatt progress. Även en hunter/eleshaman/spriest/boomkin eftertraktas. Hör av dig om du är intresserad!
	"gille.*söker", --<<<<*>>>> Vi är ett 10 manna gille som söker fler spelare till våran core grupp.Vihar 1/6 Hc MSV 6/6 HOF 3/4 ToES vi söker 1 Healer 1 Meele  ilvl 480+ 18+ om du är inresserad hör av dig för mer info...
	"letar.*raid.*social", --<*>(25) letar efter erfarna  rutinerad Warlock, Spriest & Reserver med healing os med sinne för humor till vårt core team för raids i MsV/HoF och annat kul, Raidtider Ons och Mån/Tis 19-23 /w för mer info (socials är välkommn
	"söker.*spelare.*classer", --{rt1}*{rt1} Söker seriösa spelare som är intresserade av PVP och vill joina ett nytt RBG-team. Vi söker just nu alla classer!!! Du behöver 1,9k rating i RBG eller 1750 i arena. Finns några Reqs men whispra mig så tar vi dom.

	--Norwegian
	"søker.*medlemmer", --"*" Søker flere norske medlemmer. Vi er nyoppstarta og begynner med DS10 + noen HC i denne uka. /w for mer info. Social er også velkomne
	"rekruterer", -->>>*<<< Er en Norsk social /raiding guild. Vi rekruterer for å starte en ny 10man group får å cleare alt som kan cleares. Guilden er lvl 25 og nyflyttet fra bloodfeather, Vis du vil bli med bare gi oss en whisper, alle er velkommen!
	"søger.*team.*dedikeret", --{rt1}{rt1}*{rt1}{rt1} 14/14 hc pre 6.0. Søger pt 1 healer(druid/monk) 3 dps(rogue/lock/moonkin til vores WOD mythic raid team. vi raider ons-søn-man 20.00-23.00. forventer du kender din class, du er en dedikeret raider. 18år +

	--Danish
	"søger.*medlemmer", --* søger flere medlemmer danskere svenskere og nordmæn
	"leder efter.*members.*social", --* er lvl3 atm leder efter flere members til raid mangler healers tanks og ranged dps alle er velkommen selv om i vil raid eller være sociale bare kom med det gode humør du skal være dansk for at join eller kunne snakke det nogen lunde rent.
	"guild.*søger", --<*> Dansk guild, søger holy/disc priest til at begynde raid. holdet består af 9/10 irl venner indtil videre.
	"spillere.*søger.*class", --* står overfor en fornyelse. Vi er en håndfuld spillere der, efter længere tids fravær, har besluttet os at starte igen. Vi søger derfor folk til at starte fra bunden af det nuværende Tier. Alle classes og specs vil blive overvejet.

	--Finnish
	"kilta.*etsii", --*, Suomalainen PvE-kilta joka etsii vain pelaajia jotka osaavat liikkua tulesta ja joita kiinnostaisi raidata 10man DS normaalia ja heroiccia jatkossa, tähtäämme parempaan tasoon kuin suurin osa servun suomikilloista! /w jos kysyttävää
	"etsimme.*pelaajia.*yhteyttä", --<*> lvl 25 Progress DS 1/8 hc. Etsimme hc koitoksiin aktiivisia pelaajia. Erityiseti healerille on tarvetta. Myös 85 lvl sosiaalit on tervetulleita. Ota yhteyttä jos kiinnostuit.
	"etsii.*kilta", --<*> Etsii suomalaisia pelaajia joukkoonsa. Kilta on casual PvE/PvP/social. Kaikki ovat tervetulleita! Nyt haetaan pelaajia aloittamaan DS10 progress.
	"etsii.*ihmisiä.*progress", --[*] Etsii suomalaisia, raidaamisesta kiinnostuneita motivoituneita ihmisiä liittymään meidän HC Main-raid grouppiin. Nykyinen progress 5/8 Hc ja eteenpäin mennään.
	"kilta.*tarvetta olisi", --<*> On juuri tehty Suomalainen PvP Kilta rennolla meiningillä. Aloitamme rbg:een kunhan saamme kelvollisen setupin. Tarvetta olisi Fc:lle (Warru), Hiiluja (Pally, Shaman, Priest) ja depsuja melkein kaikki classit. Whisperillä lisää infoa.
	"etsii.*tervetulleita", --{rt3}*{rt3} 1/6hc MSV, 5/6 HoF Etsii osaavaa depsiä (pref rogue/mage) core porukkaansa. /w jos haluat tietää lisää. Sossut ovat myös tervetulleita.

	--German
	"sucht.*willkommen", --<> sucht für ihre 10er Raids Mi + Fr 19.30-23.00 (10/12) noch tatkräftige Unterstützung! Hirn, flinke Finger, wache Augen und ein sehr! gutes Klassenverständnis sind uns in jeder Klasse willkommen. www.xyz.de
	"such[et]n?.*%.de", --Die "" (Glvl5) suchen noch Mitglieder, egal ob groß oder klein, zum gemeinsamen leveln, Instanzen(und HC's)-, PvP- und später Cata-Raid erleben. Weitere Infos findet ihr auf www.xyz.de  Ts Vorhanden
	"such[et]n?.*gilde", --Hi wir suchen für unsere LvL-Gilde <>(Stufe 2) noch Member. Wir wollen zusammen Leveln und Instanzen laufen. Den 5% ep Bonus gibts auch dazu. Hast du lust? Dann melde dich bei mir :)
	"bewerbung.*www.*/w", --noch gute und zuverlässige Member für weitere 10er Stammgruppen später 25er.Gesucht werden:Heiler;Pala,Dudu - DD;Eule,Feral,Mage,Verstärker!Raidzeiten Mi,Do,So 19-22:30!Bewerbung unter www.xyz.de für Infos /w me
	"gu?ilde?.*pvp.*raid", --Die PvP und Twink Gilde <> sucht gute PvPler für gemeinsame Events,Raids und Bgs. Aufgenommen wird ab lvl.50! w me oder Geilertyp
	"gu?ilde?.*raid.*bank", --Die neue Gilde "<>" sucht noch nette Mitspieler zum Leveln, Questen, Raiden und Spaß haben. Ts³ und Gildenbank ist vorhanden.
	"gilde.*such[et]", --Moin, der lustige Haufen (Gilde) "<>" suchen noch ältere Spieler (22+) für Instanzen, Questen, Heros und 10er; Spielspaß ist dabei die absolute Mussbedingung! Wenn du dich angesprochen fühlst, schreib uns einfach mal:) www.<>.de
	"gilde.*inte?rr?esse", --Die Gilde <> sucht nette Mitspieler zum gemeinsamen questen, spass haben, heros abfarmen, pvp zocken usw... Sind keine raidgilde und wollen es auch nicht werden. Neuanfänger sowie lowlvl gerne willkommen. Intresse? pls w/m

	--Turkish
	"raid.*deneyimi.*aran?maktadır", --*  5/8 HC  Raidlere düzenli katılım saglayacak Hc deneyimi olan Mage  ve Holy Pala aranmaktadır
	"ekibi.*oyuncu.*sosyal", --*/10m  5/8 HC  2. RAID ekibi için  390 ve üstü ilvl a sahip, raidlere düzenli takılabilecek HER CLASS VE SPECC ten oyuncu alımları yapılacaktır. Sosyal alımlarımız bulunmaktadır. Basvuru ıcın /w
	"guild.*aranıyor", --Guildimize beraber lvl kasmak isteyen arkadaşlar aranıyor. 1lvl %50 deyiz......
	--* [25] 5/8 HC  Progressimize Düzenli katilim saglayacan Heroic deneyimi olan Mage,Lock aramaktadir.Social alimi da gerceklestirilmektedir . Detayli bilgi icin /w
	"progres.*so[cs][iy]al", --* [25 Lvl]10M5/8 HC Progresimizi ilerletmeye yardimci olabilecek HC Tecrubesi olan Mage Lock sp alimi yapilacaktir. Ayrica sosyal alimimiz da vardir
	"progres.*ar[iı]+yor", --* (25 lvl) 6/8 hc progress, Spine ve Madness progressine katkıda bulunabilecek online süresi yüksek yeterli gear ve oyunculuk seviyesine sahip 1 melee dps arıyor. Bilgi için /w
	"progres.*aran?maktadır", --*/10m  5/8 HC  ACIL OLARAK, PROGRESS ekibi için en az 3 boss HC deneyimi olan 395-400 arasında ilvl a sahip, raidlere düzenli takılabilecek ELEM SHMY, BLANCE DRUID ve LOCK oyuncular aranmaktadır. Basvuru ve bilgi icin /w.
	"progres.*gu[iı]+ld", --8:30 da basliycak olan hc progresimize 1 burst dps gerek! guild run 6/8 hc progresimiz war Spine hc icin sabırlı 1 dps lazim ''*'' !!! Spine dan baslanıcak!!!
	"aran?maktadır.*progres", --*  - * yeni transfer olmustur ve suanki tier ve MOP icin kadrosuna classina hakim oyuncular aramaktadır ,Suanki 1/8 HC progressimiz devam ettirmek istiyoruz oncelikli Tank ve Healer alimi vardir.
	"gu[iı]+ld.*raid.*oyuncu", --* guildi kurulmuş olan 25 man kadrosunu güçlendiriyor. Raidlere istekli katılacak, saygılı ve paylaşımı seven türk oyuncuları bekliyoruz.
	"başvuru.*www", --Hurish Başvuru için lütfen "www.*.com" adresine giriş yaparak formu doldurunuz.
	--{rt3} * {rt3} 1/6HC 15/16 normal main kadrosu icin  haftada 4 aksam 8-12 arasi raid yapabilecek yetenekli, classina hakim oyuncular aramaktadir. Tercih edilen classlar (lock/ele shammy/SP) Bilgi icin /w
	"aran?maktad[iı]+r.*bilgi.*/w", --* (7/8 Hc) Hc Madness ve MoP icin Off-tank(warrior-paladin) aranmaktadır. Daha fazla bilgi icin /w
	"classlara.*ihtiyacı olup.*ulassın", -- -*- MoP Paketinde Yeniden Yapılandırma Surecinde Olan Guildimizin Raider Classlara Ihtiyacı Olup , Online Suresi Yuksek, Classına Hakim Range/Caster Dps  Alımı Yapacaktır.Ilgilenenler Ulassın . Tesekkurler.
	"le?ve?l.*gu[iı]+ld.*whisper", --<*> Level 25 * dan *'a yeni transfer edilen guildimize main kadroya healer(Resto Druid/Shaman/Monk) ve Tank(DK/Pala/Druid) arıyoruz. Ilgilenenler whisper atabilir.
	"le?ve?l.*gu[iı]+ld.*/w", --&&& * &&& 25 LVL PVP Guıldimize Rbg için Resto Druıd ve Resto Shaman alınacaktır. /w me
	"guild.*%d%dm.*bilgi", ---*- Semi-Hardcore Guildimizi 25man e cevirmek amaclı classına hakim online suresi yuksek raider arkadaslara ihtiyac duyulmaktadır.Gerekli bilgi icin lutfen ulasın.Tesekkurler..
	"gu[iı]+ld.*progres", --(*) Guıdimize 10 man progresi crsm cuma  ve cmts gunlerı raıd e katılcak gear duzeyı ıyı olan karekterıne hakım  arkadasları beklıyoruz ( TANK VE HEALER  )
	"ar[iı]+yoruz.*günleri.*bilgi", --<*> (13/14 Hc  10m) 6.0 SoO Mythic ve  WOD için Healer (Priest , Monk)  ve Dps ( Rogue , Warlock ) arıyoruz.   Raid günleri [Perşembe-Cuma-P.tesi] 21:30 - 00:30. Bilgi için /w
	"dps.*oyuncu.*ar[iı]+yor", --{rt1}{rt1}*{rt1}{rt1} BRF Heroic Kadrosuna yetenek fakiri olmayıp, yeri geldiginde atesden kacacak,yeri geldiginde dispel atacak.. ya ben neden ölüp duruyorum demeyip loglara bakabilecek,bu arada da dps \heal yapabilecek oyuncular ariyoruz.

	--Croatian
	"le?ve?l.*primamo.*igrace", -- * (lvl25) za sve one koji ovo razumeju. Primamo sve zainteresovane igrace 85lvl koji igru pre svega shvataju kao zabavu a ne obavezu. Za vise informacija/w
	"guild.*trazimo ljude", --* je balkanski guild lvl25 i trazimo ljude za pvp a i ostali clanovi su dobrodosli, trenutni fokus je na rbg i arenama, a i pravit ce se tim za pve progress,Clanova: 104 atm Svi  su dobrodosli{rt8}

	--Hungarian
	"guild.*játékos.*keres", --* Guild játékosokat keres.Létszámtól függően Old Dungeon,RBG,Content Raid szervezése.Fejlödö szintü karaktereket is várunk.
	"guild.*info.*wh?isp", --Hali ! * lvl 25 guild tagfelvételt hirdet minden class számára! Raidek szombaton és vasárnap délután MOP-tól! További info wisp: *
	"klán.*raid.*karakter", --A * klán (lvl25) felnött vagy felnött gondolkodású embereket keres raidezésre, pvp-re és egyéb szórakozásokra. Nem számít a karakter vagy a felszerelés szintje, csak az igény a könnyed, stresszmentes szórakozásra.
	"klán.*jelentkezését", --* lvl 25-ös klán újra aktív. Aktív játékosok jelentkezését várjuk, akik Pandaria altt is raidelni szeretnénke majd. Infóért írjatok rám nyugodtan.
	"guild.*keress?ünk", --* guild tagfelvételt hírdet, amit keresünk az heal( pap,Shaman) és dps( rugó, Hunter,)! Célunk az aktuális content minél elöbbi kitakarítása normálban(ill. hcban)! Részletek whispben.
	--<*>  (7/7 HC HM , 9/10 norm , 4/10 HC  BRF ) guild összeszokott raidcsapattal  keres raidelésre aktív játékosokat. Részletek whispben :-)
	"guild.*keres.*játékos", --<*> Frissen alakult Magyar guild tagokat keres. Várunk szeretettel minden játékost szint/gear megkötés nélkül! Ha szeretnél tagja lenni egy aktív csapatnak írj bátran nekem, vagy Woolfie-nak!
	"raider.*keres.*info", --* [14/16] aktív raider jelentkezöket keres 10 fös csapatába! Bövebb információk a www.*.in weblapon.
	"guild.*keres.*szivesen", --* guild keres olyan playereket akik már a WoD-ra készülnek.Célunk WoDra egy ütőképes társaság kialakítása.A maradék MoP időben fun raid.A klán magja 10/14HC expel rendelkezik. Mindenkit szivesen látunk :)
	"keresi.*aktív", --Sziasztok! Az * keresi aktív, raidelni vágyó játékosait a jelenlegi contentre és a következõ kiegre! Tapasztalt, jól müködõ, jó hangulatú csapat vagyunk! Mindenkit szeretettel várunk! infoért /w me!
	"klán.*aktív", --Az * klán (* elsőszámú magyar Allis PvP guildje) várja az aktív, PVP kedvelő játékosokat, geartől és classtól függetlenül. Célunk a következő RBG szezon megnyerése *. Bővebb infoért /w  vagy www.*.hu
	"guild.*www", --A visszatero <*> guild TGF-et hirdet aktiv jatekosoknak. Esti raidek, felnott, skilled jatekosok, sajat TS, igazsagos lootosztas (DKP rendszer), garantalt jo hangulat. Info /w vagy www.*.hu!
	"klán.*h[íi]+rdet", --* pve klán tgf-et hírdet! Elsösorban egy Roguenak vagy egy Monk dpsnek. Raid napjaink: Szerda, csütörtök és vasárnap! Infóért /w.
	"guild.*hírdet", --* (Pve/Pvp) Guild Általános TGF-et hírdet. Level és Gear nem számít. Szeretettel várunk mindenkit.
	"hirdet.*info", --* tagfelvételt hirdet! Ha kezdõ vagy és segítségre van szülséged, esetleg raidelni is szeretnél de még nincs kivel és hol akkor itt a helyed. Normal dungeon, hc, raid, transmog farm, pvp és minden egyéb sok röhögéssel! info /w
	"guild.*keres.*tagjait", --A * PVP guild keresi magyar tagjait arénázásra, rbg-zésre,Mivel új guild igy kialakult fix rbg teamünk nincs, minden spot open. Ha lenne valami kérdésed bátran whisp!
	"hirdet.*csapat", --A <*> felvételt hirdet elsősorban tankok számára, de mindent meghallgatunk. Összeszokott progress csapat (HM HC 7/7, BRF norm 9/10, BRF HC 4/10), jó hangulat.

	--Polish
	"gildia.*szuka", --Polska gildia RP-PvE szuka graczy do wspolnej zabawy. Chcemy stworzyc porzadna ekipe do gry zarówno PvE jak i PvP! Jednoczesnie chcemy aby w "*" panowała miła atmosfera. Gildia stworzona przez ludzi z duzym doswiadczeniem w WoW i innych grach MMO
	"gildia.*poszukuje", --Gildia "*" (11/14 HC SoO) poszukuje aktywnych graczy do zasilenia grupy raidowej w 6.0 i WoD. Rekrutujemy zarowno raiderow jak i sociali. Gwarantujemy dobra zabawe i wsparcie doswiadczonych graczy.Masz jakies pytania? Whispuj smialo! :D Zapraszamy
	"rekrutuje", --{rt1}Polska gildia * rekrutuje! {rt1}Zapraszamy wszystkich chetnych do stworzenia zgranej paczki, ktora z pelna para rusz na Draenor! Kazdy jest mile widziany. Goraco zapraszamy!
	"poszukuje.*gildii", --<*> poszukuje ludzi do reaktywacji gildii w WoD. Zapraszamy wszystkich chetnych do wspolnej gry. W planach: rozwoj sekcji pvp (grupa RBG) oraz pve. Zapewniamy wsparcie wielu doswiadczonych graczy oraz wlasny serwer ts3 oraz strone internetowa.
	"poszukuje.*ludzi.*sklad", --< * >  Poszukuje ludzi by wzmocnic sklad na Mythic raidy w WoD. Potrzebujemy healerow i dpsow.  W razie pytan /w Robiko , Amka
	"gildia.*zaprasza", --Polska Gildia <*> zaprasza wszytkich do wspolnej gry. Pomagamy i przygotowujemy druzyne na nowy dodatek

	--Lithuanian
	"gu?ildija.*iesko", --Gildija * ruosiasi WoD'ui ir ta proga iesko daugiau zmoniu mythic raidinimui. Del daugiau info pm *, *, *, *.
	"gu?ildija.*aktyviu", --*-Nauja Lietuviu guildija ieskanti aktyviu nariu! Naujame expansione planuojame surinkti groupa ir valyti raidus draugiskoje aplinkoje. Priimam visus be issimciu!

	--Bulgarian
	"набира.*членове.*нуждаем", --* набира нови членове от всички класове и специализации за прогрес на BRF Mythic,най-вече се нуждаем от Танк (Warrior, Paladin, Monk).
}

ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", function(_,event,msg,player,_,_,_,_,chanId,_,_,_,lineId)
	if lineId == prevLineId then
		return result
	else
		prevLineId, result = lineId, nil
		if chanId == 0 or chanId == 25 then return end --Don't scan custom channels or GuildRecruitment channel
		local trimmedPlayer = Ambiguate(player, "none")
		if not CanComplainChat(lineId) or UnitIsInMyGuild(trimmedPlayer) then return end --Don't filter ourself/friends
		msg = msg:lower() --Lower all text, remove capitals
		for i = 1, #triggers do
			if strfind(msg, triggers[i]) then --Found a match
				if BadBoyLog then BadBoyLog("Guilded", event, trimmedPlayer, msg) end
				result = true
				return true --found a trigger, filter
			end
		end
	end
end)


local whispers = {
	"would.*join my.*guild", --Would you like to join my social raiding guild?.. lv1 but it will grow fast with your help :D and lottery. u can win 50g a week. MORE later!!
	"wanna.*join my.*guild", --wanna join my guild im not one of those f*gs that spamf*ck the trade but you have to start from somewhere well pst if u want in if u dont idc i only have me and my best friend in it right now and we have only been using it for storage...
	"would.*join our.*guild", --Would you like to join our guild ? if you join We will pay your all repair costrs...
	"would.*join a.*guild", --Would You Like To Join a New Guild ? Help us Grow. That Will Give You Free Repair When You Reach Lvl 5! wen you reach 85 u will Get 2000g
	"would.*join.*social.*guild", --Hello <>,how are you? would you like to join <> a newly created socialplayer guild!
	"would.*join.*team.*members", --Hey you! Would you like to join *? We will make a core raiding team when we got the ppl for it. If we get many members we can also make more than 1 raiding team, and maybe when we have enough we could make it a 25 man raid.
	"want.*join.*social.*guild", --hey m8 u want to join in 14 level social guild with 10% more xp from quest and 30 gold every day free repair??
	"invite.*social.*guild.*join", --Hello *! You have been invited to * a newly founded social guild, hope you join! Cant wait to see you!:)
	"wanna.*join.*guild.*le?ve?l", --Heya wanna join Guild * lvl 25 for faster lvling? :)
	"hello.*intere?sted.*join.*guild", --Hello,  intersted in joining a guild? :)
	"would.*join.*please.*accept", --Would you like to join [[*]] please press Accept!o _O
	"interest.*join.*le?ve?l", --Hey bro are you interested in joining *? We just reformed currently leveling and setting up going to be raiding once we're ready!

	"looking for.*members.*join", --Hello, <> is looking for more members to join our ranks, we are both recruiting socials/levelers and raiders for our raiding team! We would like you, <>, to join our ranks.
	"raid.*guild.*looking for", --Social casual raiding Guild 8/8 <> is looking for raiders for our DS run, we are in need of 3 healers. perfer with os dps. our main raidday is wednesday...
	"recruit.*member.*join", --<> is recruiting members. We raid,quest and dungeon together feel free to join.

	"social guild.*wh?ant.*players", --Hello. Were a social guild that whants to help new players to get better. In oure stab we have a Raid Leader from the guild <> and a member of the guild. With good experience from DS and been playing Since TBC. And we whant to help you to get better !
	"guild.*recruit.*social", --Hello, were a lvl 2 guild looking to recruit members of all lvl's.We're a social guild looking for members to help us reach lvl 25
	"new.*social guild.*repair", --Greetings <>! <> is a newly started social guild where you have a possibility to advance into high-end content. We'll soon be providing with guild repairs as well as hosting events! Come, take part of the community! We have 10% XP, REP an
	"join.*guild.*member", --Hi * , please join our Level 15 guild for for weekly raids & rbgs and %10 extra XP. We do dungeon runs to help our low level members too.
	"social.*guild.*repair.*join", --Hi, * is a fun, friendly social guild. enjoy the free guild repairs and boosts.. and also our 1st ever perk..  =>=>  [Fast Track] <=<=.. so why dont you join our community??? u wont regret it :)

	"guild.*please come.*bonus", --Our guild have %10 xp %10 Mount Speed and % 100 Spirit speed boost please come and lvl at our guild if you hit from 80 lvl to 85 lvl while in this guild you will get a bonus 1.5 k gold
	"join.*community.*gbank", --Hello <> Come And Join <> now and be part of a fast growing community we have a Gbank :) we may be lvl 1 but we are aiming high for the sky and thats why we need you
	"%d.*perks.*social.*guild", --<> 6/8 HC DS , Take advatage of our perks and socials lvl 25 guild.
	"guild.*friendly.*player.*repair", --Hey, we are a levelling guild that plans to be very friendly and reward our players for helping the guild. We will provide higher rewards for pro-active players. Once the guild properly starts guild repairs will be provided for everyone. Give us a shot!!
	"new.*guild.*casual.*raid", --* is a new started Guild, that will be a Casual guild from the start. But when we get peoples we will start doing Rbg, Raids etc. On a casual level
	"recruit.*player.*raid.*whisp", --"*" now recruiting new players! Need all classes and all specs! Ready for raiding, but we just need the people, Whisper for more! Levelers and pvpers welcome!
	"social guild.*member.*join", --Hello *. * (25) is a  social guild with 900+ members join us and have fun
	"guild.*invite.*boost.*join", --THIS IS THE BEST GUILD YOU'LL EVER BE INVITED TO, SO GO ON AND DO WHAT YOU KNOW YOU MUST DO ......... accept the invite ;) plus there's a 10% exp boost for joining :P
	"guild.*recruit.*faster", --Hi! * <<*>> is the BEST Guild in THE WORLD and WE are recruiting YOU cause YOU PWN, does that make sense?? - NO... but who cares? (((( 5% xp bonus (soon 10%) and 10% faster mount))))
	"recruit.*player.*social", --Hello *, * is recruiting players of all levels and skills as socials along with end game experienced raiders for our newly formed friendly guild, english speaking mature players, click accept now to join :)
	"guild.*join.*repair", --Hello *, sorry to bother you but * is a lvl 25 guild and is the biggest growing guild on the server! Join us and gain Guild Repair and 10% more XP, Honor and Justice Points! We have hundreds of level 85 characters already!
	"guild.*looking.*member", --<*> is a level 3 guild looking for members. Come enjoy [Fast Track], [Mount Up] and more!
	"recr?uit.*casual.*repair", --<*> is now recuiting! We are a casual and fun guild atm but will focus on both PvE and PvP when the time is right! We want you who is active and like to play much! We will soon have guild repair and a open guildbank!
	"want.*friendly.*pv[pe].*environment", --Do you want to a friendly environment with both PvE and PvP events every week. We are altso capable of helping with your character. "specc - gemming and how to optimize your dps/healing. We hope you will find our environment suited for you!
	"social.*le?ve?l.*guild", --* Its only for the sirs of sirs so if you think your sir enough for the sirs of sirs then whisper the best sir of sirs (me) and join the soon to be best social,leveling,questing,SIRING,raiding,pvping guild EVER!! .......Like a Sir!
	"join.*le?ve?l.*mount.*rep", --Join for Faster leveling! Faster Mount! More reputation gains and more!!
	"guild.*recruit.*repair", --Hi, <*> is a newly formed leveling and questing level 16 guild which is now recruiting more people ! Come on * , give it a shot ! Guild repairs are also available !
	"hello.*guild.*raid.*join", --Hello there Fancy a guild that doesnt just focus on it's 10 man  team with friendships made and other stuff apart from just raiding? Then this might be the guild for you From a rebuilt transferred guild we offer u the chance to join in on our WoW exp.
	"guild.*looking.*social", --Hello, * is a newly formed guild transfered from *, with DS experienced leadership. We are currenlty looking for active people to help us level up the guild, and continue our DS progress. Socials are always welcome aswell.
	"guild.*raid.*le?ve?l.*join", --Hey mate :) <*> is a new PvP Guild! Our main focus will ofc be in MoP! We will also set up Raids, and have a few groups for raiding :) In the beginning we will focus on levling, getting people geared, skilled and exp'ed. Please join if u PvP:
	"guild.*repair.*join", --Hey there!, i noticed your new? ;D. i've just started off a guild with free repairs, and bank tab use, along with perks to come, care to join? :) ... Let me know :)!
	"re[cq]ruit.*guild.*join", --Hello *! <*> is now recruiting!Awsome guild!, join now!
	"guild.*le?ve?l.*raid.*player", --Guild * Level 9. HI *. We are a good guild and there you can do everything. RAID ARENA RBG BG DG achiv. You say us wht you want to do and we try to organise it! we are not too much so you will be in a great family of good player
	"le?ve?l.*bonus.*join.*guild", --Hi * ! We've got 2 guild bank tabs filled with FREE items and enchants to help You leveling aswell as bonus 5% exp from Fast Track perk. Join our guild and lvl up faster!
	"le?ve?l.*guild.*repair", --* LvL 16 Guild! Be active and mature! 100g FREE Guild repair everyday!
	"guild.*social.*welcome", --Hello :) * is Level 25 guild : %10 more exp, %10 Mount speed, Mass Summon, Mass Resurrection, Bountiful Bags (proc on your professions!!),  Raiding, Leveling and social guild. All welcome and Feel free to invite everyone :)
	"le?ve?l.*recruit.*guild", --<*> (level 12) is now recruiting. Do you just love PvP? Then this is the guild for you! We will be doing World PvP/ RBG/ arenas/ premades. And much more! We will have weekly events aswell.
	"join.*le?ve?l.*guild", --Hello *! Wanna join *? we are lvl 18!! Its  a leveling guild. 10% more xp
	"extra.*durability.*join", --Hi *, want to get an extra 10% xp? And other bonuses like profession points and durability free? With over 550 members, you should join us!
	"guild.*join.*le?ve?l", --Hi my friend. Me and some others has just started a new guild and we would like if you join.  we are a pvp guild and we do doungens too. And our level 85 people would love you help you level up.
	"partof.*guild.*invite", --*? Well, hopefully not. But you can be part of an epic guild called * if you like. I'll shoot you an invite chief, you decide.
	"join.*repair.*le?ve?l", --Would you like to join *? Free repairs to all, Where tking all lvl's
	"guild.*invite.*recruit", --Hey, I see that you are not in a Guild, So I thought I could invite you to my guild "*" :) You see we are recruiting players like is lvling, gearing and such. why not join and get several Gold Rewards on your way to the top :)?
	"join.*le?ve?l.*repair", --Hello *! Would you like to join * level (24)? Enjoy perks such as 10% extra EXP/Honor and free repairs! We run arenas, bg's, dungeons and more. Don't hesitate to join us today!
	"guild.*players.*join", --Hey!>>*<< Is a Raiding/PvP/Leveling guild. And we want more players to come join for our RBG's And DS. We are Very Friendly. We will use Ventrilo for our RBG's And DS. We will go one with DS HC soon.
	"guild.*players.*looking", --<*> is a PvP Guild formed by two super active players from other realm. We're looking for more ppl to play Arenas, Heroics and Bg's with!
	"join.*guild.*[ei]nviron?ment", --Hello , join to * and enjoy the adventures of WoW.We r making this guild to get prepared for cataclysm.We r offering a pleasant inviroment and a lot of fun.We will do bgs and dungeons to help u out. Join!
	"looking.*people.*guild", --<*> - We are looking for people who have a big interrest in PvP, the guild offers arena capping, rbg, and world pvping. You don't have to be Danish! We are lf Officers. /w me for more info!
	"recruit.*join.*guild", --YOLO Gaming Recruiting Peeps for Arenas, Rbgs, And Raiding.. join now for guild perks!
	"guild.*bonus.*perk", --* is a lvl 7 guild and are here to have fun :) We also got 10% xp bonus for levlers and other nice perks.
	"need.*join.*repair", --Mighty soldier we need your steel and magic in the defence of this world, join with us in <*> and fight our enimies and gain their riches. We will assist you with your armor repair, items and any other things you require while you slay your enemies
	"repair.*join.*guild", --Would you like to get free repairs and 10% more exp?! Then join *! You're very welcome to our guild, *!
	"le?ve?l.*looking.*players", --<*>lvl 1  looking for starting players, we helping get new gear, helping in dungeons and raids and giving gold. Looking players who need  achievements and who want go raid to get achievements
	"le?ve?l.*repair.*join", --* LVL 22. We do have 50g repair everyday for everyone and we're trying to be helpfull to those few members who actually joins.
	"join.*boost.*repair", --Join * - have a chance on winning 10 000g/week, FREE Boosts and Repairs CMON & Support the WoW Community!
	"looking.*social.*members", --<*> Is looking for more social members to chat and play bgs, dungeons and stuff with us!
	"looking.*member.*le?ve?l", --<<*>> looking member who need help with level and gear, we helping how we can, with gold level up and gear
	"guild.*looking.*people", --Hello New GUild * is looking for new people to join are core DS group and rbg group /w for inv.
	"new.*guild.*looking", --<*> is a new formed Pve,Pvp guild currently looking for all classes for our raid team/rbg team. We are gonna do Hc's also allot of dungeons and arena's. For more info or inv w/me.
	"recruit.*social.*player", --<*> Level 25 Recruiting for Dragon Soul 10 20:00 – 23:00 ST Mon, Tue, Thur / Tank: All Welcome / Healer: All Welcome / DPS: All Welcome. Also social players are welcome.
	"guild.*le?ve?l.*repair", --<*> RBG Guild for 1.7k+ XP'd PvP'ers!Looking for levelers, free repairs,help and advice! [:
	"guild.*le?ve?l.*join", --*, Newly formed guild rapidly leveling Join Us Now!
	"join.*rbg.*repair", --Join for arena partners and RBGs. Free repairs to come!
	"le?ve?l.*guild.*inte?rest", --Hello. I want to extend a invitation to you for a  new level 15 PvE guild. We just started this week and we are 3/8 Heroic in the Dragon Soul. If you are 385+ and know Dragon Soul then wisper me back if you are intrested in a guild spot and possibly core.
	"guild.*join.*recruit", --If you are already in a guild then you are still welcome to join but just know this message is automatic and it we did not check if you were guild. We are just recruiting your class.
	"guild.*members.*join", --Pvp/pve guild. over 300 active members accept and join us today!
	"new.*guild.*rbg.*accept", --<*> Is a newly formed PvP Guild! We are going to do lots of RBG's and normal BG's together. We dont play serious hardcore RBGs, we do it for fun! :) We will record YouTube vids of our events and BG's! Press Accept and become a PvPer TODAY!(:
	"join.*social.*perk", --Come and meet friendly ppl, while lvling up new chars, explore new areas and have a great time! Would you like to join us for some social fun? :) got nice perks :)
	"join.*guild.*repair", --JOIN OUR GUILD, FREE BANK REPAIRS + 500G to the most active player every week!
	"looking.*member.*guild", --* is looking for more friendly members! We have everything other guilds have but what makes us unique is our competition system where we hand out thousands of gold each week! We also have a website with irl introductions and pictures etc!
	"new.*le?ve?l.*guild.*join", --"<>" We are a new lvl 1 guild and we need you to join the ARMY :D JOIN US NOW!!! We are a nice guild :)
	"recruit.*guild.*welcome", --Hello! <> is recruiting! I will give everyone doing dungeons with me 100g per run! We will become a Raiding guild, but  right now everyone is welcome!
	"guild.*welcome.*friendly", --LV 25 GuildActive peps Active pvp,questing..ect All LV's welcome friendly Come have fun before MIST!!!
	"wanna.*join.*repair.*buff", --Hey, wanna join us :) ? Free repairs, 5% exp buff
	"recruit.*raid.*need", --Hi there! We are recruiting for MoP for main focus will be raiding, we are currently in need of 1 healer and multiple dps for our core group. raid goes from 9pm to ? We have weekly contests for gold and other prizes for the person that gets the most xp
	"would.*join.*guild.*perk", --Would you like to join this awsome guild of doom? You get all the perks you need to level faster! :)
	"looking.*perk.*repair", --<*> is looking for more players to fill roster! We can offer you all useful perks & Free repairs!
	"gameplay.*join.*guild", --Take your gameplay to the next level! Er… actually, take a few steps back. Kick up your feet. Stop the grind and join the coolest laid-back guild in the land! It’s “cool” to call yourself “cool”.
	"social.*guild.*perk", --<*> is one of the biggest and most active social 25 guild on the realm. We got all perks, all mounts, companions, cauldrons, recipes etc etc. We are now preparing for MoP and we will be doing guilddungeons, raids and much more! :) Welcome!
	"noticed.*guild.*invite", --Hey i noticed u wernt in a guild and i was wondering if ud like to raid come MoP ill gladly invite you =)
	"join.*le?ve?l.*recruit", --Join * <level3> recruiting all Going to start PVP AND PVE when MoP Comes OUT JOIN YOU WILL HAVE FUN! :)
	"le?ve?l.*recruit.*join", --Hello, <*> (level15) is recruiting for MoP! Join us for raiding, pvp, and leveling! Please accept invite!!
	"guild.*fun.*pvp.*raid", --(*) We are a guild that aims to provide a fun experience for everyone that wishes to participate in various guild activites like PVP including Arena and RBG, Raiding / Dungeon, we will be doing everything in Mist of Pandaria.
	"player.*recruit.*perk", --<*> (13) Looking for more players for MoP based PvE and PvP. Open Recruitment with many perks!
	"need.*player.*pay.*active", --<*> needs players! I pay 1,000g to the most active member every monday!
	"social.*guild.*player", --Hello *. * is a social guild that is intended to provide players a good experience of WOW. We look for players who want to do raids normal and heroic, dungeons, levelling out classes, etc. We have with you!!!
	"recruit.*casual.*progres", --<*> <1> Is Now Recruiting. Formed by an 8/8HM experienced GM. <*> aims to become one of the major casual hubs for coming MoP, while at the same time, allowing for progression in a HM environemnt. Aus weeknight raiding (Late Night US).
	"open.*repair.*join", --<*> We're open for everyone to come chill while playing. Free Repairs! No requirements or expectations. Press Accept to Join
	"recruit.*bonus.*exp", --<*> of * recruiting! Earn 5% BONUS experience with *!
	"join.*bonus.*exp", --<*> Join us for 5% BONUS Experience!
	"le?ve?l.*guild.*perk", --Enjoy level 25 guild perks without responsibility.
	"le?ve?l.*guild.*info", --<*> is just form and we pay you to lvl! 10g for lvl10 and 20g for lvl 20 and so on! 300g for lvl 85! (must lvl while in guild) Pst for more info and invite! (looking for some good ppl to be officers!)
	"wonder.*wanted.*join.*cool", --Hey * ... I was wondering you know... If you wanted to join <*>... It's pretty cool. We like to party. And pants. Sorry. I'll go now.
	"pve.*players.*join", --Hey! do you enjoy PVP, PVE, and hanging with other players? join <*> !
	"currently.*le?ve?l.*guild", --<*> Currently Running Heroic MoP dugneons - lf people leveling or who are already at 90! Casual laid back guild with alot of experience
	"le?ve?l.*friendly.*pst", --Lfm for * . lvl 25 .friendly and light raiding . pst for invite or info Ty
	"join.*le?ve?l.*fun.*activ", --JOIN <*> level9 we are fun activive and freindly and wanna grow so come joing and just chill
	"le?ve?l.*want.*raid.*www", --<*> lvl 25 WANTS YOU for raids and rbgs. www.*.com
	"guild.*repair.*invite", --* is a pvp guild with repair for levelling toons, let me know if you would like an invite!
	"guild.*invite.*le?ve?l", --Hey there.. I know you probably get sapmmed a lot by these guys becasue you're guildless.. but would you like an invite to one? We all use vent and are a good group yo level with and gear up.
	"^enterinvitemessagehere", --Enter invite message here...
	"^alltheguildperksyouneed", --All the guild perks you need :)
	"hello.*join my guild.*free", --Hello *! JOIN MY GUILD FOR FREE SHIZZ HAHA AND GET FREE GOLD
	"invite.*guild.*social", --Hey, I’d like to invite you to * guild, which is a social and nice group of WoW players. We are going to take as much fun from playing WoW as it's possible. Also, some PVP & PVE contents are in plans tho.
	"guild.*perk.*social", --Hey! I apologize for the spontaneous request, but I would like to hear if you would like to become a part of this brand new guild <*>, We've only just reached lvl 6. Our goal is not only to provide perks, but also to create a social community!-GM
	"guild.*le?ve?l.*accept", --Greetings! Do you want to be a part of a Guild, which is a leveling guild atm. but will later be a pvp guild? then press accept :=)
	"recruit.*welcome.*info", --<*> is recruiting new players of all kind as we will try to cover all aspects of the game. We are currently mainly looking for raiders but everyone is welcome /w for more info or inv
	"le?ve?l.*guild.*looking", --Hi, I am the GM of <Guild Name> a level 25 guild looking for additional members, interested? We have great benefits!
	"le?ve?l.*raid.*guild.*gold", --If you are going to lvl you might as well have fun doing it. We are a raid guild that allows lvlers to come enjoy the atmosphere. We offer weekly games up to 1k gold winners!!! stick around to raid or whatever. come win gold while u lvl!!!
	"le?ve?l.*perks.*raffle.*alts", --Hey there, sorry for interrupting you but if you're going to be leveling you might aswell take advantage of our PERKS! Get some extra XP, honor, and even enter to win our WEEKLY BOE RAFFLE! Bank ALTS accepted!
	"community.*play.*social.*welcome", --<*> is forming a powerful PvP community. We will help you get arena or RBG capped weekly, or even get some decent RBG rating. Come and play with experienced leaders; socials are welcomed too. If you dont wanna get /w again pls tell me.

	"gilde.*kommen.*le?ve?l", --Hättest du lust in meine Gilde zu kommen? Nur bist du 90 bist oder was besseres geunden hast oder so? Damit du nebenbei meine Gilde mit Leveln würdest, haben schon Stufe 4
	"gilde.*rbg.*begrüßen", --Hi hast du lust in die Gilde * zu kommen? Machen gemeinsame Inis, Bgs, Erfolge usw. Sind im Neuaufbau daher sind für RBG Gruppe und Raid Gruppe noch Plätze frei! Würden uns freuen dich bei uns begrüßen zu dürfen =)
	"gilde.*wilkommen.*suchen", --Möchten sie meiner Gilde beitreten ? Wir sind eine Fun-LvL gilde jeder Spieler ist herzlich wilkommen uns beizutreten ! Wir suchen neue mitglieder da die Gilde momentan ziehmlich klein ist. Sie könnten teil von etwas grossem werden ! :)
	"gilde.*sucht.*interesse", --Hallo Die Gilde <*> 25 - sucht noch paar Aktive & Freundliche spieler... TS3 / Gildenfächer / grosse Freude & Aktivität vorhanden... Raiden ist momentan nicht geplant... wird aber eingeführt später :) Interesse ?
}

local tbl, whispPrevLineId, whispResult = {}, 0, nil
ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", function(_,event,msg,player,_,_,_,flag,_,_,_,_,lineId)
	if lineId == whispPrevLineId then
		return whispResult
	else
		whispPrevLineId, whispResult = lineId, nil
		local trimmedPlayer = Ambiguate(player, "none")
		if not BADBOY_GWHISPER or tbl[trimmedPlayer] or not CanComplainChat(lineId) or UnitIsInMyGuild(trimmedPlayer) or UnitInRaid(trimmedPlayer) or UnitInParty(trimmedPlayer) or flag == "GM" or flag == "DEV" then return end
		msg = msg:lower() --Lower all text, remove capitals
		for i = 1, #whispers do
			if strfind(msg, whispers[i]) then --Found a match
				--print(whispers[i])
				if BadBoyLog then BadBoyLog("Guilded", event, trimmedPlayer, msg) end
				whispResult = true
				return true --found a trigger, filter
			end
		end
	end
end)

ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", function(_,_,_,player)
	local trimmedPlayer = Ambiguate(player, "none")
	if BADBOY_GWHISPER and not tbl[trimmedPlayer] then tbl[trimmedPlayer] = true end
end)

