------------------------
-- Adjustable settings
local r, g, b, a = 0.7, 0.7, 0.7, 1 -- Overlay color & alpha
local terrainAlpha = 1 -- Terrain opacity
------------------------

local overlayFrame = CreateFrame("frame", nil, WorldMapDetailFrame)
overlayFrame:SetAllPoints()
overlayFrame:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel())

local terrainFrame = CreateFrame('frame', nil, overlayFrame)
terrainFrame:SetAllPoints()
terrainFrame:SetFrameLevel(WorldMapDetailFrame:GetFrameLevel())

local overlayTextures, terrainTextures = {}, {}
---[[
FoglightMode = 1
local showTerrain = false

local moads = {'Hybrid', 'Disabled', 'All Terrain', 'No Terrain'}
local menu = CreateFrame('frame', 'foglightmenu', WorldMapFrame.UIElementsFrame, 'UIDropDownMenuTemplate')
menu:SetPoint('BOTTOMLEFT', -19, -6)
--menu:SetFrameLevel(WORLDMAP_POI_FRAMELEVEL + 2)
menu:SetAlpha(0.8)

local function setMode(mode)
	if not moads[mode] then mode = 1 end
	UIDropDownMenu_SetSelectedID(foglightmenu, mode)
	if mode == 1 then -- hybrid
		overlayFrame:Show()
		for _,tx in pairs(terrainTextures) do tx:SetDrawLayer('ARTWORK', -2) end
		terrainFrame:SetShown(showTerrain)
	elseif mode == 2 then -- disabled
		overlayFrame:Hide()
	elseif mode == 3 then -- all terrain
		overlayFrame:Show()
		for _,tx in pairs(terrainTextures) do tx:SetDrawLayer('ARTWORK', 2) end
		terrainFrame:SetShown(showTerrain)
	elseif mode == 4 then -- no terrain
		terrainFrame:Hide()
		overlayFrame:Show()
	end
	FoglightMode = mode
end

local function menuOnClick(self)
	setMode(self:GetID())
end

local function initmenu()
	for i,v in ipairs(moads) do
		local info = UIDropDownMenu_CreateInfo()
		info.text = v
		info.func = menuOnClick
		--if i == FoglightMode then info.checked = true end
		UIDropDownMenu_AddButton(info)
	end
end

UIDropDownMenu_Initialize(foglightmenu, initmenu)
UIDropDownMenu_SetSelectedID(foglightmenu, 1)
UIDropDownMenu_SetWidth(foglightmenu, 85)

local addonName = ...
menu:SetScript('OnEvent', function(_, _, ...)
	if ... ~= addonName then return end
	FoglightMode = FoglightMode and moads[FoglightMode] and FoglightMode or 1
	setMode(FoglightMode)
end)
menu:RegisterEvent('ADDON_LOADED')
--]]

local TERRAIN_PATH, UNDERWATER_PATH, TERRAIN_MAGIC, TERRAIN_MAPS = 'world/minimaps/%s/map%02d_%02d', 'world/minimaps/%s/noliquid_map%02d_%02d', 1600/3, {[0]="azeroth",[1]="kalimdor",[30]="pvpzone01",[33]="shadowfang",[36]="deadminesinstance",[37]="pvpzone02",[47]="razorfenkraulinstance",[129]="razorfendowns",[169]="emeralddream",[189]="monasteryinstances",[209]="tanarisinstance",[269]="cavernsoftime",[289]="schoolofnecromancy",[309]="zul'gurub",[329]="stratholme",[451]="development",[469]="blackwinglair",[489]="pvpzone03",[509]="ahnqiraj",[529]="pvpzone04",[530]="expansion01",[531]="ahnqirajtemple",[532]="karazahn",[533]="stratholme raid",[534]="hyjalpast",[543]="hellfirerampart",[559]="pvpzone05",[560]="hillsbradpast",[562]="bladesedgearena",[564]="blacktemple",[566]="netherstormbg",[568]="zulaman",[571]="northrend",[572]="pvplordaeron",[573]="exteriortest",[574]="valgarde70",[575]="utgardepinnacle",[578]="nexus80",[580]="sunwellplateau",[585]="sunwell5manfix",[595]="stratholmecot",[599]="ulduar70",[600]="draktheronkeep",[601]="azjol_uppercity",[602]="ulduar80",[603]="ulduarraid",[604]="gundrak",[605]="development_nonweighted",[607]="northrendbg",[608]="dalaranprison",[609]="deathknightstart",[615]="chamberofaspectsblack",[616]="nexusraid",[617]="dalaranarena",[618]="orgrimmararena",[619]="azjol_lowercity",[624]="wintergraspraid",[628]="isleofconquest",[631]="icecrowncitadel",[632]="icecrowncitadel5man",[638]="gilneas",[643]="abyssalmaw_interior",[644]="uldum",[645]="blackrockspire_4_0",[646]="deephome",[648]="lostisles",[649]="argenttournamentraid",[650]="argenttournamentdungeon",[654]="gilneas2",[655]="gilneasphase1",[656]="gilneasphase2",[657]="skywalldungeon",[658]="quarryoftears",[659]="lostislesphase1",[660]="deephomeceiling",[661]="lostislesphase2",[668]="hallsofreflection",[669]="blackwingdescent",[670]="grimbatoldungeon",[671]="grimbatolraid",[719]="mounthyjalphase1",[720]="firelands1",[724]="chamberofaspectsred",[725]="deepholmedungeon",[726]="cataclysmctf",[727]="stv_mine_bg",[728]="thebattleforgilneas",[730]="maelstromzone",[731]="desolacebomb",[732]="tolbarad",[734]="ahnqirajterrace",[736]="twilighthighlandsdragonmawphase",[746]="uldumphaseoasis",[751]="redgridgeorcbomb",[754]="skywallraid",[755]="uldumdungeon",[757]="baradinhold",[761]="gilneas_bg_2",[764]="uldumphasewreckedcamp",[859]="zul_gurub5man",[860]="newracestartzone",[861]="firelandsdailies",[870]="hawaiimainland",[930]="scenarioalcazisland",[938]="cotdragonblight",[939]="cotwaroftheancients",[940]="thehouroftwilight",[951]="nexuslegendary",[959]="shadowpanhideout",[960]="easttemple",[961]="stormstoutbrewery",[962]="thegreatwall",[967]="deathwingback",[968]="eyeofthestorm2.0",[971]="jadeforestalliancehubphase",[972]="jadeforestbattlefieldphase",[974]="darkmoonfaire",[975]="turtleshipphase01",[976]="turtleshipphase02",[977]="maelstromdeathwingfight",[980]="tolvirarena",[994]="mogudungeon",[996]="moguexteriorraid",[998]="valleyofpower",[999]="bftalliancescenario",[1000]="bfthordescenario",[1001]="scarletsanctuaryarmoryandlibrary",[1004]="scarletmonasterycathedralgy",[1005]="brewmasterscenario01",[1007]="newscholomance",[1008]="mogushanpalace",[1009]="mantidraid",[1010]="mistsctf3",[1011]="mantiddungeon",[1014]="monkareascenario",[1019]="ruinsoftheramore",[1024]="pandafishingvillagescenario",[1028]="moguruinsscenario",[1029]="ancientmogucryptscenario",[1030]="ancientmogucyptdestroyedscenario",[1031]="provinggroundsscenario",[1035]="valleyofpowerscenario",[1043]="ringofvalorscenario",[1048]="brewmasterscenario03",[1049]="blackoxtemplescenario",[1050]="scenarioklaxxiisland",[1051]="scenariobrewmaster04",[1060]="leveldesignland-devonly",[1061]="hordebeachdailyarea",[1062]="alliancebeachdailyarea",[1064]="moguislanddailyarea",[1066]="stormwindgunshippandariastartarea",[1074]="orgrimmargunshippandariastart",[1075]="theramorescenariophase",[1076]="jadeforesthordestartingarea",[1095]="hordeambushscenario",[1098]="thunderislandraid",[1099]="navalbattlescenario",[1101]="defenseofthealehousebg",[1102]="hordebasebeachscenario",[1103]="alliancebasebeachscenario",[1104]="alittlepatiencescenario",[1105]="goldrushbg",[1106]="jainadalaranscenario",[1107]="warlockarea",[1112]="blacktemplescenario",[1116]="draenor",[1120]="thunderkinghordehub",[1121]="thunderislandalliancehub",[1123]="lightningforgemoguislandprogressionscenario",[1124]="shipyardmoguislandprogressionscenario",[1126]="hordehubmoguislandprogressionscenario",[1128]="moguislandeventshordebase",[1129]="moguislandeventsalliancebase",[1130]="shimmerridgescenario",[1131]="darkhordescenario",[1134]="shadopanarena",[1136]="orgrimmarraid",[1144]="heartoftheoldgodscenario",[1148]="provinggrounds",[1152]="fwhordegarrisonlevel1",[1153]="fwhordegarrisonlevel2",[1154]="fwhordegarrisonlevel3",[1155]="stormgarde keep",[1157]="halfhillscenario",[1158]="smvalliancegarrisonlevel1",[1159]="smvalliancegarrisonlevel2",[1160]="smvalliancegarrisonlevel3",[1161]="celestialchallenge",[1166]="smallbattlegrounda",[1168]="thepurgeofgrommarscenario",[1169]="smallbattlegroundb",[1171]="smallbattlegroundd",[1175]="ogrecompound",[1176]="mooncultisthideout",[1179]="warcraftheroes",[1182]="draenorauchindoun",[1187]="goralliancegarrisonlevel1",[1190]="blastedlands",[1191]="ashran",[1195]="warwharfsmackdown",[1200]="bonetownscenario",[1203]="frostfirefinalescenario",[1205]="blackrockfoundryraid",[1207]="taladorironhordefinalescenario",[1208]="blackrockfoundrytraindepot",[1209]="arakkoadungeon",[1220]="troll raid",[1228]="highmaulogreraid",[1235]="talalliancegarrisonlevel3",[1265]="tanaanjungleintro",[1268]="terongorsconfrontation",[1277]="defenseofkaraborscenario",[1279]="shaperdungeon",[1280]="trollraid2",[1307]="tanaanjungleintroforgephase",[1329]="grommasharscenario",[1330]="fwhordegarrisonleve2new",[1331]="smvalliancegarrisonlevel2new",[1402]="gorgrondfinalescenario",[1431]="sparringarenalevel3stadium",[1448]="hellfireraid62",[1451]="tanaanlegiontest",[1454]="artifactashbringerorigin",[1456]="nagadungeon",[1458]="7_dungeonexteriorneltharionslair",[1460]="brokenshorescenario",[1461]="azsunascenario",[1462]="illidansrock",[1463]="helhiemexteriorarea",[1464]="tanaanjungle",[1465]="tanaanjunglenohubsphase",[1466]="emerald_nightmare_valsharah_exterior",[1468]="wardenprison",[1469]="maelstromshaman",[1470]="legion dungeon",[1473]="garrisonallianceshipyard",[1474]="garrisonhordeshipyard",[1475]="themawofnashal",[1477]="valhallas",[1478]="valsharahtempleofelunescenario",[1479]="warriorartifactarea",[1480]="deathknightartifactarea",[1481]="legionnexus",[1489]="artifact-portalworldacqusition",[1492]="helheim",[1493]="wardenprisondungeon",[1494]="acquisitionviolethold",[1495]="acquisitionwarriorprot",[1498]="acquisitionhavoc",[1500]="artifactpaladinretacquisition",[1501]="blackrookholddungeon",[1503]="artifactshamanelementalacquisition",[1504]="blackrookholdarena",[1505]="nagrandarena2",[1511]="artifact-warriorfuryacquisition",[1512]="artifact-priesthunterorderhall",[1514]="artifact-monkorderhall",[1515]="hulnhighmountain",[1516]="suramarcatacombsdungeon",[1519]="artifactsdemonhunterorderhall",[1520]="nightmareraid",[1522]="artifactwarlockorderhallscenario",[1523]="mardumscenario",[1526]="artifact-whitetigertempleacquisition",[1527]="highmountain",[1528]="artifact-skywallacquisition",[1529]="karazhanscenario",[1530]="suramarraid",[1532]="highmountainmesa",[1533]="artifact-karazhanacquisition",[1536]="ursocslairscenario",[1537]="boostexperience",[1539]="artifact-acquisitionarmsholyshadow",[1540]="artifact-dreamway",[1541]="artifact-terraceofendlessspringacquisition",[1544]="legionvioletholddungeon",[1545]="artifact-acquisition-combatresto",[1549]="techtestseamlessworldtransitiona",[1550]="techtestseamlessworldtransitionb",[1552]="valsharaharena",[1553]="artifact-acquisition-underlight",[1554]="boostexperience2",[1557]="boostexperience2horde",[1571]="suramarcitydungeon",[1572]="maelstromshamanhubintroscenario",[1579]="udluarscenario",[1583]="artifact-dalaranvaultacquisition",[1584]="julientestland-devonly",[1586]="assualtonstormwind",[1588]="devmapa",[1589]="devmapb",[1590]="devmapc",[1591]="devmapd",[1592]="devmape",[1593]="devmapf",[1594]="devmapg",[1599]="artifactrestoacqusition",[1600]="artifactthroneofthetides",[1602]="skywalldungeon_orderhall",[1604]="artifact-portalworldnaskora",[1605]="firelandsartifact",[1607]="artifactacquisitionsubtlety",[1608]="hyjal instance",[1609]="acquisitiontempleofstorms",[1610]="artifact-serenitylegionscenario",[1611]="deathknightcampaign-lightshopechapel",[1612]="theruinsoffalanaar",[1616]="faronaar",[1617]="deathknightcampaign-undercity",[1618]="deathknightcampaign-scarletmonastery",[1620]="artifactstormwind",[1621]="blacktemple-legion",[1623]="magecampaign-theoculus",[1624]="battleofexodar",[1625]="trialoftheserpent",[1626]="thecollapsesuramarscenario",[1629]="netherlighttempleprison",[1630]="tolbarad1",[1632]="thearcwaysuramarscenario",[1646]="blackrooksenario"}
local OverlayInfo = { -- Generated on May 19th, 2016 by Semlar
["durotar"]={"valleyoftrials/254/258/304/312","senjinvillage/192/184/457/406","echoisles/330/255/429/413","tiragardekeep/210/200/462/298","razorhill/224/227/431/157","razormanegrounds/248/158/302/264","thunderridge/220/218/295/48","drygulchravine/236/196/415/60","skullrock/208/157/438/0","orgrimmar/259/165/309/0","northwatchfoothold/162/157/399/440","southfurywatershed/244/222/282/174"},
["mulgore"]={"baeldundigsite/218/192/226/220","bloodhoofvillage/302/223/319/273","palemanerock/172/205/248/321","ravagedcaravan/187/165/435/224","redcloudmesa/446/264/286/401","redrocks/186/185/514/43","stonetalonpass/237/184/201/0","thegoldenplains/186/216/448/101","therollingplains/260/243/527/291","theventurecomine/208/300/530/138","thunderbluff/373/259/208/62","thunderhornwaterwell/201/167/333/202","wildmanewaterwell/190/172/331/0","windfuryridge/222/202/400/0","winterhoofwaterwell/174/185/449/340"},
["barrens"]={"boulderlodemine/278/209/511/7","thesludgefen/257/249/403/6","dreadmistpeak/241/195/290/104","thedryhills/283/270/116/57","theforgottenpools/446/256/100/208","groldomfarm/243/217/448/127","farwatchpost/207/332/555/129","thornhill/239/231/481/254","thecrossroads/233/193/362/275","thestagnantoasis/336/289/344/379","ratchet/219/175/547/379","themerchantcoast/315/212/556/456","morshanrampart/261/216/258/6","thewailingcaverns/377/325/152/318"},
["arathi"]={"circleofwestbinding/220/287/85/24","northfoldmanor/227/268/132/105","bouldergor/249/278/171/123","stromgardekeep/284/306/21/269","faldirscove/273/268/77/400","circleofinnerbinding/228/227/201/312","thandolspan/237/252/261/416","boulderfisthall/252/258/327/367","refugepoint/196/270/293/145","witherbarkvillage/260/220/476/359","goshekfarm/306/248/430/249","dabyriesfarmstead/210/227/404/144","circleofeastbinding/183/238/506/126","hammerfall/270/271/581/118","cirecleofouterbinding/215/188/332/273","galensfall/212/305/0/144"},
["badlands"]={"agmondsend/342/353/230/315","angorfortress/285/223/230/68","apocryphansrest/252/353/0/66","campcagg/339/347/0/281","campkosh/236/260/504/19","hammertoesdigsite/209/196/411/116","lethlorravine/469/613/533/55","thedustbowl/214/285/144/99","uldaman/266/210/336/0","deathwingscar/328/313/175/178","campboff/274/448/407/220"},
["blastedlands"]={"dreadmaulhold/272/206/258/0","nethergardekeep/295/205/530/6","serpentscoil/218/183/459/97","altarofstorms/238/195/225/110","dreadmaulpost/235/188/327/182","thetaintedscar/308/226/144/175","nethergardesupplycamps/195/199/436/0","shattershore/240/270/578/91","sunveilexcursion/233/266/386/374","surwich/199/191/333/474","thedarkportal/370/298/368/179","theredreaches/268/354/533/268","thetaintedforest/348/357/132/311","riseofthedefiler/168/170/375/102"},
["tirisfal"]={"venomwebvale/250/279/752/150","scarletwatchpost/161/234/692/99","crusaderoutpost/175/210/686/232","balnirfarmstead/242/179/594/324","brightwaterlake/210/292/573/122","garrenshaunt/190/214/477/129","brill/199/182/480/252","coldhearthmanor/212/177/418/317","nightmarevale/225/281/347/325","agamandmills/285/260/324/90","sollidenfarmstead/286/225/201/192","deathknell/431/407/9/207","calstonestate/179/169/389/255","ruinsoflorderon/390/267/423/359","scarletmonastery/262/262/740/47","thebulwark/293/338/709/330"},
["silverpine"]={"theskitteringdark/227/172/236/0","fenrisisle/352/302/581/15","thesepulcher/218/200/341/157","deepelemmine/217/198/483/212","olsensfarthing/251/167/312/249","ambermill/283/243/509/250","shadowfangkeep/179/165/337/337","thegreymanewall/409/162/318/506","berensperil/318/263/505/405","forsakenhighcommand/361/175/445/0","forsakenrearguard/186/238/369/0","northtidesbeachhead/174/199/323/68","northtidesrun/281/345/147/0","thebattlefront/255/180/349/429","thedecrepitfields/176/152/471/156","theforsakenfront/152/189/433/327","valgansfield/162/172/461/77"},
["westernplaguelands"]={"darrowmerelake/492/314/510/354","caerdarrow/194/208/601/390","sorrowhill/368/220/261/448","thebulwark/316/316/48/235","felstonefield/241/212/229/228","thewrithinghaunt/169/195/472/332","northridgelumbercamp/359/182/231/123","hearthglen/432/271/235/0","gahrronswithering/241/252/495/213","theweepingcave/185/230/551/151","thondrorilriver/311/436/533/0","andorhal/464/325/96/343","dalsonsfarm/325/192/300/232","redpinedell/290/133/286/211"},
["easternplaguelands"]={"acherus/228/273/774/102","blackwoodlake/238/231/382/151","corinscrossing/186/213/493/289","crownguardtower/202/191/258/351","darrowshire/248/206/211/462","eastwalltower/181/176/541/184","lakemereldar/266/241/462/427","lightshopechapel/196/220/687/271","lightsshieldtower/243/162/391/271","northdale/265/232/570/61","northpasstower/250/192/401/69","plaguewood/328/253/144/40","quellithienlodge/277/175/351/0","ruinsofthescarletenclave/264/373/738/295","stratholme/310/178/118/0","terrordale/258/320/0/10","thefungalvale/274/216/183/211","thepestilentscar/182/320/383/348","themarrisstead/202/202/133/335","thenoxiousglade/297/299/650/55","theinfectisscar/177/266/595/263","theundercroft/280/211/56/457","thondorilriver/262/526/0/100","tyrshand/214/254/651/414","zulmashar/286/176/528/0"},
["hillsbradfoothills"]={"azurelodemine/180/182/287/399","chillwindpoint/447/263/555/68","corrahnsdagger/135/160/426/224","crushridgehold/134/124/463/101","dalarancrater/316/238/102/137","dandredsfold/258/113/341/0","darrowhill/147/160/425/279","dungarok/269/258/542/410","durnholdekeep/437/451/565/217","gallowscorner/155/147/451/140","gavinsnaze/116/129/344/254","growlesscave/171/136/359/191","hillsbradfields/302/175/191/302","lordamereinternmentcamp/250/167/194/216","mistyshore/158/169/321/42","nethandersteed/204/244/502/373","purgationisle/144/139/200/505","ruinsofalterac/189/181/347/85","slaughterhollow/148/120/413/55","soferasnaze/148/146/484/166","southpointtower/312/254/59/310","southshore/229/219/383/352","strahnbrad/275/193/505/44","tarrenmill/165/203/494/226","theheadland/105/148/390/255","theuplands/212/160/441/0"},
["hinterlands"]={"aeriepeak/238/267/0/236","plaguemistravine/191/278/133/105","queldanillodge/241/211/220/181","shadraalor/240/196/220/379","valorwindlake/199/212/286/269","agolwatha/208/204/367/159","thecreepingruin/199/199/390/252","thealtarofzul/225/196/357/343","seradane/303/311/475/5","skulkrock/176/235/490/195","shaolwatha/281/261/565/208","jinthaalor/287/289/487/334","theoverlookcliffs/244/401/677/267","zunwatha/226/225/152/284"},
["dunmorogh"]={"frostmanehold/437/249/50/227","golbolarquarry/198/251/663/288","helmsbedlake/218/234/760/268","amberstillranch/249/183/595/225","kharanos/184/188/449/220","thegrizzledden/211/160/374/287","coldridgepass/225/276/360/340","ironforge/376/347/398/0","coldridgevalley/398/302/100/366","frostmanefront/226/335/469/256","gnomeregan/409/318/0/27","ironforgeairfield/308/335/630/0","theshimmeringdeep/171/234/397/132","iceflowlake/236/358/263/0","thetundridhills/174/249/579/306","northgateoutpost/237/366/765/43"},
["searinggorge"]={"blackcharcave/375/307/0/361","blackrockmountain/304/244/243/424","dustfirevalley/392/355/588/0","firewatchridge/365/393/0/75","grimsiltworksite/441/266/531/241","thecauldron/481/360/232/171","thoriumpoint/429/301/255/38","tannercamp/571/308/413/360"},
["burningsteppes"]={"altarofstorms/182/360/0/0","blackrockmountain/281/388/79/0","blackrockpass/298/410/419/258","blackrockstronghold/320/385/235/0","dracodar/362/431/0/237","dreadmaulrock/274/263/568/151","morgansvigil/383/413/615/255","pillarofash/274/413/253/255","ruinsofthaurissan/324/354/421/0","terrorwingpath/0/0/0/0","terrorwingpath/350/341/646/7"},
["elwynn"]={"goldshire/276/231/247/294","fargodeepmine/269/248/240/420","northshirevalley/295/296/355/138","jerodslanding/230/206/396/430","towerofazora/270/241/529/287","brackwellpumpkinpatch/287/216/532/424","eastvaleloggingcamp/294/243/703/292","ridgepointtower/285/194/708/442","crystallake/220/207/417/327","stonecairnlake/340/272/552/186","stromwind/512/422/0/0","westbrookgarrison/269/313/116/355"},
["deadwindpass"]={"deadmanscrossing/617/522/83/0","thevice/350/449/433/208","karazhan/513/358/92/310"},
["duskwood"]={"thehushedbank/189/307/0/152","addlesstead/299/296/32/348","ravenhillcemetary/323/309/91/132","vulgologremound/268/282/228/355","theyorgenfarmstead/233/248/401/396","brightwoodgrove/279/399/497/112","therottingorchard/291/263/539/368","darkshire/329/314/640/128","manormistmantle/219/182/661/122","thedarkenedbank/931/235/71/26","racenhill/205/157/96/292","thetranquilgardenscemetary/291/244/627/344","thetwilightgrove/320/388/314/101"},
["lochmodan"]={"mogroshstronghold/294/249/549/52","theloch/330/474/340/81","silverstreammine/225/252/221/0","northgatepass/319/289/16/0","thefarstriderlodge/349/292/570/209","ironbandsexcavationsite/397/291/481/296","grizzlepawridge/273/230/245/324","thelsamar/455/295/0/146","stonesplintervalley/273/294/177/345","valleyofkings/310/345/0/311","stronewroughtdam/333/200/339/0"},
["redridge"]={"threecorners/323/406/0/256","lakeridgehighway/392/352/148/316","lakeeverstill/464/250/81/214","lakeshire/410/256/0/110","redridgecanyons/413/292/37/0","renderscamp/357/246/214/0","althersmill/228/247/350/139","rendersvalley/427/291/451/377","stonewatchfalls/316/182/525/302","galardellvalley/428/463/574/0","campeverstill/189/193/445/286","shalewindcanyon/306/324/688/283","stonewatchkeep/228/420/480/0"},
["stranglethornjungle"]={"baliamahruins/239/205/397/243","mizjahruins/157/173/387/246","gromgolbasecamp/167/179/298/228","moshoggogremound/234/206/543/253","lakenazferiti/240/228/413/95","kalairuins/139/150/354/184","balalruins/159/137/267/168","thevilereef/236/224/140/208","ruinsofzulkunda/228/265/158/0","nesingwarysexpedition/227/190/306/63","rebelcamp/302/166/306/0","kurzenscompound/244/238/499/0","zulgurub/376/560/626/0","bambala/190/176/566/164","fortlivingston/230/170/398/375","zuuldalaruins/324/263/9/22","mazthoril/350/259/488/364"},
["swampofsorrows"]={"bogpaddle/262/193/600/0","ithariuscave/268/316/7/242","marshtidewatch/330/342/478/0","mistyreedstrand/402/668/600/0","mistyvalley/268/285/0/80","pooloftears/257/229/575/238","sorrowmurk/229/418/703/80","splinterspearjunction/238/343/194/236","stagalbog/347/303/540/360","stonard/357/308/297/258","theharborage/266/284/161/79","theshiftingmire/292/360/331/24"},
["westfall"]={"thejansenstead/202/179/474/0","furlbrowspumpkinfarm/197/213/394/0","saldeansfarm/244/237/451/81","themolsenfarm/202/224/348/118","goldcoastquarry/235/306/199/79","thedeadacre/193/273/531/200","sentinelhill/229/265/404/226","moonbrook/232/213/308/325","alexstonfarmstead/346/222/167/263","demontsplace/201/195/203/376","westfalllighthouse/211/167/221/477","thedaggerhills/292/273/303/395","thedustplains/317/261/480/378","jangoloadmine/196/229/311/0","thegapingchasm/184/217/294/168"},
["wetlands"]={"menethilharbor/325/363/0/297","blackchannelmarsh/301/232/37/240","bluegillmarsh/321/248/31/102","whelgarsexcavationsite/298/447/185/195","sundownmarsh/276/243/121/63","ironbeardstomb/185/224/372/76","dunmodr/257/185/356/7","angerfangencampment/236/256/359/201","thelganrock/258/207/371/335","mosshidefen/369/235/506/232","raptorridge/256/245/599/123","direforgehills/329/228/506/34","dunalgaz/298/215/346/419","greenwardensgrove/250/269/460/102","satlspray/250/282/218/0","slabchiselssurvey/300/316/532/352"},
["teldrassil"]={"banethilhollow/175/235/374/221","darnassus/298/337/149/181","gnarlpinehold/198/181/347/355","lakealameth/289/202/422/310","poolsofarlithrien/140/210/345/243","shadowglen/241/217/481/104","starbreezevillage/187/196/544/217","theoracleglade/194/244/276/90","wellspringlake/165/249/382/83","rutheranvillage/317/220/329/448","thecleft/144/226/432/109","galardellvalley/178/186/466/237"},
["darkshore"]={"ruinsofmathystra/200/263/517/28","ametharan/326/145/294/330","themastersglaive/303/185/277/483","eyeofthevortex/330/192/300/239","lordanel/277/281/391/54","nazjvel/244/201/207/467","ruinsofauberdine/203/194/280/182","shatterspearvale/250/241/596/16","shatterspearwarcamp/245/147/565/0","wildbendriver/314/193/280/378","witheringthicket/328/250/305/118"},
["ashenvale"]={"thezoramstrand/262/390/0/0","lakefalathim/184/232/112/148","thistlefurvillage/314/241/255/78","astranaar/251/271/255/164","theruinsofstardust/236/271/210/331","thehowlingvale/325/239/473/97","raynewoodretreat/231/256/481/221","fallenskylake/287/276/529/385","nightrun/221/257/595/253","satyrnaar/235/236/696/154","boughshadow/166/211/836/148","warsonglumbercamp/231/223/771/265","felfirehill/277/333/714/317","maelstraspost/246/361/188/0","orendilsretreat/244/251/143/0","silverwindrefuge/347/308/338/335","theshrineofassenia/306/283/40/275","thunderpeak/203/310/377/121"},
["thousandneedles"]={"darkcloudpinnacle/317/252/169/116","freewindpost/436/271/276/186","highperch/246/380/0/134","razorfendowns/361/314/298/0","southseaholdfast/246/256/756/412","splithoofheights/431/410/571/49","thegreatlift/272/232/136/0","theshimmeringdeep/411/411/591/257","thetwilightwithering/374/339/347/329","twilightbulwark/358/418/125/241","westreachsummit/280/325/0/0","rustmauldivesite/234/203/527/465"},
["stonetalonmountains"]={"stonetalonpeak/305/244/265/0","mirkfallonlake/244/247/417/143","thecharredvale/277/274/199/368","sunrockretreat/222/222/353/285","windshearcrag/374/287/533/179","boulderslideravine/194/156/532/512","webwinderpath/267/352/468/263","malakajin/211/131/618/537","battlescarvalley/290/297/220/189","cliffwalkerpost/241/192/366/95","greatwoodvale/322/220/602/448","kromgarfortress/183/196/588/341","ruinsofeldrethar/221/235/367/411","thaldarahoverlook/210/189/252/121","unearthedgrounds/265/206/654/369","webwinderhollow/164/258/479/401","windshearhold/176/189/516/289"},
["desolace"]={"shadowbreakravine/292/266/637/402","mannoroccoven/326/311/381/357","gelkisvillage/274/196/207/472","shadowpreyvillage/222/299/142/369","kodograveyard/250/215/360/273","valleyofspears/321/275/170/196","thunderaxefortress/220/205/440/49","sargeron/317/293/655/0","nijelspoint/231/257/573/0","tethrisaran/274/145/399/0","cenarionwildlands/312/285/415/156","magramterritory/289/244/613/170","ranzjarisle/161/141/210/0","shokthokar/309/349/589/319","slitherbladeshore/338/342/208/24","thargadscamp/212/186/275/376"},
["feralas"]={"thetwincolossals/350/334/271/0","theforgottencoast/194/304/375/343","diremaul/265/284/485/101","ruinsofisildien/206/237/467/354","campmojache/174/220/671/181","gordunnioutpost/192/157/663/116","lowerwilds/207/209/756/191","darkmistruins/172/198/568/287","feathermoonstronghold/217/192/362/237","feralscar/191/179/457/281","grimtotemcompund/159/218/607/170","ruinsoffeathermoon/208/204/186/229","writhingdeep/232/206/652/298"},
["dustwallow"]={"theramoreisle/305/247/542/223","witchhill/270/353/428/0","thewyrmbog/436/299/359/369","alcazisland/206/200/656/21","blackhoofvillage/344/183/199/0","brackenwllvillage/384/249/133/59","direhornpost/279/301/358/169","mudsprocket/433/351/109/313","shadyrestinn/317/230/137/188"},
["tanaris"]={"thistleshrubvalley/221/293/185/280","southmoonruins/232/211/301/349","landsendbeach/224/216/431/452","eastmoonruins/173/163/380/341","thegapingchasm/225/187/448/364","southbreakshore/274/186/437/289","dunemaulcompound/231/177/305/257","thenoxiouslair/179/190/258/211","brokenpillar/195/163/413/211","abyssalsands/255/194/297/148","cavernsoftime/213/173/507/238","gadgetzan/189/180/412/92","sandsorrowwatch/214/149/293/99","zulfarrak/315/190/184/0","gadgetzanbay/254/341/479/9","lostriggercover/178/243/615/201","valleryofthewatchers/269/190/255/431"},
["aszhara"]={"theshatteredstrand/206/329/316/168","bitterreaches/321/247/477/0","towerofeldara/306/337/684/22","ruinsofeldarath/218/237/228/229","ravencrestmonument/295/267/476/401","lakemennar/210/232/245/377","bearshead/256/224/113/141","bilgewaterharbor/587/381/395/127","blackmawhold/260/267/204/53","darnassianbasecamp/243/262/343/3","gallywixpleasurepalace/250/230/70/222","orgimmarreargate/352/274/22/344","ruinsofarkkoran/219/193/575/121","stormcliffs/207/232/407/403","thesecretlab/184/213/353/396"},
["felwood"]={"felpawvillage/307/161/471/0","talonbranchglade/209/226/531/57","irontreewoods/261/273/406/55","jadefirerun/263/199/303/9","shatterscarvale/343/250/243/107","bloodvenomfalls/345/192/220/231","jaedenar/319/176/234/317","ruinsofconstellas/268/214/278/359","jadefireglen/229/210/288/458","emeraldsanctuary/274/212/394/382","deadwoodvillage/173/163/410/505","morlosaran/187/176/476/484"},
["ungorocrater"]={"fireplumeridge/321/288/356/192","golakkahotsprings/309/277/145/226","terrorrun/316/293/162/357","theslitheringscar/381/274/335/384","themarshlands/263/412/573/256","ironstoneplateau/197/222/706/201","lakkaritarpits/432/294/305/0","fungalrock/224/191/557/0","marshalsstand/204/170/462/330","mossypile/186/185/328/179","therollinggarden/337/321/565/39","thescreamingreaches/332/332/157/0"},
["moonglade"]={"lakeeluneara/431/319/219/273","nighthaven/346/244/370/135","shrineofremulos/271/296/209/91","stormragebarrowdens/275/346/542/210"},
["silithus"]={"thecrystalvale/329/246/126/0","hiveashi/405/267/345/4","southwindvillage/309/243/550/181","hivezora/542/367/0/206","hiveregal/489/358/380/310","thescarabwall/580/213/0/455","cenarionhold/292/260/427/143","valorsrest/315/285/614/0","twilightbasecamp/434/231/100/151"},
["winterspring"]={"everlook/194/229/482/195","frostfirehotsprings/376/289/93/118","frostsaberrock/332/268/304/0","frostwhispergorge/317/183/424/474","icethistlehills/249/217/581/314","lakekeltheril/271/258/372/268","mazthoril/257/238/399/340","owlwingthicket/254/150/556/439","starfallvillage/367/340/229/33","thehiddengrove/333/255/500/17","timbermawpost/362/252/92/302","winterfallvillage/221/209/588/181"},
["eversongwoods"]={"sunstriderisle/512/512/195/5","ruinsofsilvermoon/256/256/307/136","westsanctum/128/256/292/319","sunsailanchorage/256/128/231/404","northsanctum/256/256/361/298","eastsanctum/256/256/460/373","farstriderretreat/256/128/524/359","stillwhisperpond/256/256/474/314","duskwithergrounds/256/256/605/253","fairbreezevilliage/256/256/386/386","thelivingwood/128/248/511/420","torwatha/256/353/648/315","thescortchedgrove/256/128/255/507","silvermooncity/512/512/440/87","azurebreezecoast/256/256/669/228","elrendarfalls/128/256/580/399","goldenboughpass/256/128/243/469","lakeelrendar/128/197/584/471","runestonefalithas/256/172/378/496","runestoneshandor/256/174/464/494","satherilshaven/256/256/324/384","thegoldenstrand/128/253/183/415","thuronslivery/256/128/539/305","tranquilshore/256/256/215/298","zebwatha/128/193/554/475"},
["ghostlands"]={"tranquillien/256/512/365/2","suncrownvillage/512/256/460/0","goldenmistvillage/512/512/44/0","windrunnervillage/256/512/60/117","sanctumofthemoon/256/256/210/126","sanctumofthesun/256/512/448/150","dawnstarspire/427/256/575/0","farstriderenclave/429/256/573/136","howlingziggurat/256/449/340/219","deatholme/512/293/95/375","zebnowa/512/431/466/237","amanipass/404/436/598/232","windrunnerspire/256/256/40/287","bleedingziggurat/256/256/184/238","elrendarcrossing/512/256/326/0","isleoftribulations/256/256/585/0","thalassiapass/256/262/364/406"},
["azuremystisle"]={"ammenford/256/256/515/279","ammenvale/475/512/527/104","azurewatch/256/256/383/249","bristlelimbvillage/256/256/174/363","emberglade/256/256/488/24","fairbridgestrand/256/128/356/0","greezlescamp/256/256/507/350","moongrazewoods/256/256/449/183","odesyuslanding/256/256/352/378","podcluster/256/256/281/305","podwreckage/128/256/462/349","siltingshore/256/256/291/3","silvermystisle/256/222/23/446","stillpinehold/256/256/365/49","theexodar/512/512/74/85","valaarsberth/256/256/176/303","wrathscalepoint/256/247/220/421"},
["hellfire"]={"expeditionarmory/512/255/261/413","falconwatch/512/342/183/326","hellfirecitadel/256/458/338/210","honorhold/256/256/469/298","magharpost/256/256/206/110","poolsofaggonar/256/512/326/45","ruinsofshanaar/256/378/25/290","templeoftelhamat/512/512/38/152","thelegionfront/256/512/579/128","thestairofdestiny/256/512/737/156","thrallmar/256/256/467/154","throneofkiljaeden/512/256/477/6","zethgor/422/238/580/430","denofhaalesh/256/256/182/412","fallenskyridge/256/256/34/142","forgecamprage/512/512/478/25","voidridge/256/256/705/368","warpfields/256/260/308/408"},
["zangarmarsh"]={"angoroshgrounds/256/256/88/50","cenarionrefuge/308/256/694/321","feralfenvillage/512/336/314/332","thehewnbog/256/512/219/51","marshlightlake/256/256/81/152","quaggridge/256/343/141/325","telredor/256/512/569/112","thedeadmire/286/512/716/128","thelagoon/256/256/512/303","twinspireruins/256/256/342/249","umbrafenvillage/256/207/720/461","sporeggar/512/256/20/202","angoroshstronghold/256/128/124/0","coilfangreservoir/256/512/462/90","oreborharborage/256/512/329/25","thespawningglen/256/256/31/339","zabrajin/256/256/175/232","bloodscaleenclave/256/256/596/412"},
["shadowmoonvalley"]={"coilskarpoint/512/512/348/8","eclipsepoint/512/358/343/310","legionhold/512/512/104/155","netherwingledge/492/223/510/445","shadowmoonvilliage/512/512/116/35","theblacktemple/396/512/606/126","thedeathforge/256/512/290/129","thehandofguldan/512/512/394/90","thewardenscage/512/410/469/258","wildhammerstronghold/512/439/168/229","altarofshatar/256/256/520/93","illadarpoint/256/256/143/256","netherwingcliffs/256/256/554/308"},
["bladesedgemountains"]={"bashirlanding/256/256/422/0","bladedgulch/256/256/623/147","bladesiprehold/256/507/314/161","bloodmaulcamp/256/256/412/95","bloodmauloutpost/256/297/342/371","brokenwilds/256/256/733/109","circleofwrath/256/256/439/210","deathsdoor/256/419/512/249","forgecampanger/416/256/586/147","forgecampterror/512/252/144/416","forgecampwrath/256/256/254/176","grishnath/256/256/286/28","gruulslayer/256/256/527/81","jaggedridge/256/254/446/414","moknathalvillage/256/256/658/297","ravenswood/512/256/214/55","razorridge/256/336/533/332","ruuanweald/256/512/479/98","skald/256/256/673/71","sylvanaar/256/318/289/350","thecrystalpine/256/256/585/0","thunderlordstronghold/256/396/405/272","veillashh/256/240/271/428","veilruuan/256/128/563/151","vekhaarstand/256/256/629/406","vortexpinnacle/256/462/166/206","ridgeofmadness/256/410/554/258"},
["bloodmystisle"]={"amberwebpass/256/512/44/62","axxarien/256/256/297/136","blacksiltshore/512/242/177/426","bladewood/256/256/367/209","bloodscaleisle/239/256/763/256","bloodwatch/256/256/437/258","bristlelimbenclave/256/256/546/410","kesselscrossing/485/141/517/527","middenvale/256/256/414/406","mystwood/256/185/309/483","nazzivian/256/256/250/404","ragefeatherridge/256/256/481/117","ruinsofloretharan/256/256/556/216","talonstand/256/256/657/78","telathionscamp/128/128/180/216","thebloodcursedreef/256/256/729/54","thebloodwash/256/256/302/27","thecrimsonreach/256/256/555/87","thecryocore/256/256/293/285","thefoulpool/256/256/221/136","thehiddenreef/256/256/205/39","thelostfold/256/198/503/470","thevectorcoil/512/430/43/238","thewarppiston/256/256/451/29","veridianpoint/256/256/637/0","vindicatorsrest/256/256/232/242","wrathscalelair/256/256/598/338","wyrmscarisland/256/256/613/82"},
["nagrand"]={"forgecampfear/512/420/36/248","garadar/256/256/431/143","halaa/256/256/335/193","kilsorrowfortress/256/241/558/427","laughingskullruins/256/256/351/52","oshugun/512/334/168/334","sunspringpost/256/256/219/199","telaar/256/256/387/390","ringoftrials/256/256/533/267","throneoftheelements/256/256/504/53","warmaulhill/256/256/157/32","burningbladeruins/256/334/660/334","clanwatch/256/256/532/363","forgecamphate/256/256/162/154","southwindcleft/256/256/391/258","twilightridge/256/512/10/107","windyreedpass/256/256/598/79","windyreedvillage/256/256/666/233","zangarridge/256/256/277/54"},
["terokkarforest"]={"allerianstronghold/256/256/480/277","bleedinghollowclanruins/256/367/103/301","cenarionthicket/256/256/314/0","firewingpoint/385/512/617/149","grangolvarvilliage/512/256/143/171","skethylmountains/512/320/449/348","stonebreakerhold/256/256/397/165","tuurem/256/512/455/34","shattrathcity/512/512/104/4","raastokglade/256/256/505/154","thebarrierhills/256/256/116/4","razorthornshelf/256/256/478/19","bonechewerruins/256/256/521/275","auchenaigrounds/256/234/247/434","carrionhill/256/256/377/272","refugecaravan/128/256/316/268","ringofobservance/256/256/310/345","sethekktomb/256/256/245/289","smolderingcaravan/256/208/321/460","veilrhaze/256/256/222/362","writhingmound/256/256/417/327"},
["netherstorm"]={"area52/256/128/241/388","manaforgebanar/256/387/147/281","manaforgecoruu/256/179/357/489","manaforgeduro/256/256/465/336","manafrogeara/256/256/171/155","ruinedmanaforge/256/256/513/138","ruinsoffarahlon/512/256/354/49","tempestkeep/409/384/593/284","theheap/256/213/239/455","arklonruins/256/256/328/397","celestialridge/256/256/644/173","forgebaseog/256/256/237/22","kirinvarvillage/256/145/490/523","netherstone/256/256/411/20","ruinsofenkaat/256/256/253/301","sunfuryhold/256/217/454/451","thescrapfield/256/256/356/261","thestormspire/256/256/298/134","netherstormbridge/256/256/132/294","ecodomefarfield/256/256/396/10","etheriumstaginggrounds/256/256/481/208","socretharsseat/256/256/229/38"},
["boreantundra"]={"templecityofenkilah/290/292/712/15","steeljawscaravan/244/319/397/66","riplashstrand/382/258/293/383","kaskala/385/316/509/214","garroshslanding/267/378/153/238","deathsstand/289/279/707/181","coldarra/460/381/50/0","borgorokoutpost/396/203/314/0","amberledge/244/214/325/140","warsongstronghold/260/278/329/237","valiancekeep/259/302/457/264","torpsfarm/186/276/272/237","thegeyserfields/375/342/480/0","thedensofdying/203/209/662/11"},
["dragonblight"]={"rubydragonshrine/188/211/374/208","obsidiandragonshrine/304/203/256/104","newhearthglen/214/261/614/358","naxxramas/311/272/691/160","lightsrest/299/278/703/7","lakeindule/356/300/217/313","icemistvillage/235/337/134/165","galakrondsrest/258/225/433/118","emeralddragonshrine/196/218/543/362","coldwindheights/213/219/403/0","angrathar/306/242/210/0","agmarshammer/236/218/258/203","wyrmresttemple/317/353/453/219","westwindrefugeecamp/229/299/42/187","venomspite/226/212/661/264","theforgottenshore/301/286/698/332","thecrystalvice/229/259/487/0","scarletpoint/235/354/569/7"},
["grizzlyhills"]={"conquesthold/332/294/17/307","draktheronkeep/382/285/0/46","drakiljinruins/351/284/607/41","dunargol/455/400/547/257","granitesprings/356/224/7/207","grizzlemaw/294/227/358/187","ragefangshrine/475/362/312/294","thormodan/329/246/509/0","venturebay/274/207/18/461","voldrune/283/247/176/421","amberpinelodge/278/290/217/244","blueskylogginggrounds/249/235/232/129","camponeqwah/324/265/548/137","ursocsden/328/260/331/32"},
["howlingfjord"]={"cauldrosisle/181/178/490/161","campwinterhoof/223/209/354/0","apothecarycamp/263/265/99/37","vengeancelanding/223/338/664/25","steelgate/222/168/222/100","scalawagpoint/350/258/168/410","nifflevar/178/208/595/240","gjalerbron/242/189/225/0","explorersleagueoutpost/232/216/585/336","emberclutch/213/256/283/203","giantsrun/298/306/572/0","fortwildervar/251/192/490/0","ivaldsruin/193/201/668/223","halgrind/187/263/397/208","newagamand/284/308/415/360","skorn/238/232/343/108","thetwistedglade/266/210/420/57","utgardekeep/248/382/477/216","westguardkeep/347/220/90/180","ancientlift/177/191/342/351","baelgunsexcavationsite/244/305/621/327","baleheim/174/173/576/170","kamagua/333/265/99/278"},
["icecrownglacier"]={"corprethar/308/212/342/392","jotunheim/393/474/22/122","icecrowncitadel/308/202/392/466","onslaughtharbor/204/268/0/167","scourgeholme/245/239/690/267","sindragosasfall/300/343/626/31","thebrokenfront/283/231/558/329","thefleshwerks/219/283/218/291","theshadowvault/223/399/321/15","aldurthar/373/375/355/37","valhalas/238/240/217/50","valleyofechoes/269/217/715/390","ymirheim/223/207/444/276","theconflagration/227/210/327/305","thebombardment/248/243/538/181","argenttournamentground/314/224/616/30"},
["sholazarbasin"]={"riversheart/468/329/359/339","thesavagethicket/293/229/396/51","themosslightpillar/239/313/265/355","themakersoverlook/233/286/705/236","themakersperch/249/248/172/135","thesuntouchedpillar/455/316/82/186","rainspeakercanopy/207/235/427/244","thelifebloodpillar/312/369/501/134","theavalanche/322/265/596/92","theglimmeringpillar/294/327/308/34","kartakshold/329/293/76/375","thestormwrightsshelf/268/288/138/58"},
["thestormpeaks"]={"dunniffelem/309/383/481/285","templeoflife/182/270/570/113","brunnhildarvillage/305/298/339/370","borsbreath/322/195/109/375","valkyrion/228/158/98/318","ulduar/369/265/218/0","thunderfall/306/484/627/179","terraceofthemakers/363/341/292/122","templeofstorms/169/164/239/301","sparksocketminefield/251/200/242/468","snowdriftplains/205/232/162/143","nidavelir/221/200/108/206","narvirscradle/180/239/214/144","garmsbane/184/191/395/470","frosthold/244/220/134/429","engineofthemakers/210/179/316/296"},
["zuldrak"]={"gundrak/336/297/629/0","draksotrafields/286/265/326/358","amphitheaterofanguish/266/254/289/287","altarofsseratus/237/248/288/168","altarofrhunok/247/304/431/127","altarofquetzlun/261/288/607/251","altarofmamtoth/311/317/575/88","altarofharkoa/265/257/533/345","zimtorga/249/258/479/241","zeramas/307/256/7/412","voltarus/218/291/174/191","thrymsend/272/268/0/247","lightsbreach/321/305/181/363","kolramas/302/231/380/437"},
["sunwell"]={"sunsreachharbor/512/416/252/252","sunsreachsanctum/512/512/251/4"},
["crystalsongforest"]={"theazurefront/416/424/0/244","thedecrepitflow/288/222/0/0","sunreaverscommand/446/369/536/40","forlornwoods/544/668/129/0","windrunnersoverlook/558/285/444/383","violetstand/264/303/0/176","thegreattree/252/260/0/91","theunboundthicket/502/477/500/105"},
["thelostisles"]={"alliancebeachhead/177/172/129/348","bilgewaterlumberyard/248/209/462/43","gallywixdocks/173/180/351/21","hordebasecamp/222/190/244/458","ktcoilplatform/156/142/433/11","landingsite/142/133/377/359","ooomlotvillage/221/211/508/345","oostan/210/258/492/161","raptorrise/168/205/416/368","ruinsofvashelan/212/216/440/452","scorchedgully/305/288/323/185","shipwreckshore/172/175/189/408","skyfalls/190/186/416/131","thesavageglen/231/216/213/325","theslavepits/212/193/279/68","warchiefslookout/159/230/264/144","lostpeak/350/517/581/21"},
["gilneas"]={"crowleyorchard/210/166/261/427","duskhaven/286/178/272/333","emberstonemine/281/351/639/43","greymanemanor/244/241/141/202","hammondfarmstead/194/236/167/352","haywardfishery/177/219/293/449","keelharbor/280/342/298/95","korothsden/222/268/393/386","northernheadlands/267/314/387/0","northgatewoods/282/298/482/14","stormglenvillage/321/203/516/465","tempestsreach/350/345/652/290","theblackwald/280/224/504/394","theheadlands/328/336/160/0","gilneascity/282/263/483/210"},
["kezan"]={"kezanmap/1002/664/0/4"},
["hyjal"]={"ashenlake/282/418/6/78","darkwhispergorge/320/471/682/128","gatesofsothann/272/334/622/320","nordrassil/537/323/392/0","sethriasroost/277/232/139/436","shrineofgoldrinn/291/321/116/17","theregrowth/441/319/52/253","thescorchedplain/365/264/411/216","thethroneofflame/419/290/318/378","direforgehill/270/173/303/197","archimondesvengeance/270/300/320/5"},
["southernbarrens"]={"baelmodan/269/211/398/457","battlescar/384/248/274/307","forwardcommand/216/172/423/251","frazzlecrazmotherload/242/195/269/436","huntershill/218/178/300/64","northwatchhold/280/279/548/147","ruinsoftaurajo/285/171/244/286","theovergrowth/355/226/289/117","vendettapoint/254/214/267/196","honorsstand/315/170/201/0","razorfenkraul/214/140/273/528"},
["vashjirkelpforest"]={"gnawsboneyard/311/217/451/325","gubogglesledge/227/207/399/280","holdingpens/316/267/456/401","honorstomb/291/206/380/43","legionsfate/278/315/210/35","theaccursedreef/340/225/365/162","darkwhispergorge/220/189/528/228"},
["vashjirdepths"]={"abandonedreef/371/394/50/263","abyssalbreach/491/470/497/0","coldlightchasm/267/374/266/280","deepfinridge/363/262/275/32","fireplumetrench/298/251/315/110","korthunsend/370/385/412/283","lghorek/306/293/162/210","seabrush/225/250/415/183"},
["vashjirruins"]={"bethmoraridge/335/223/407/445","glimmeringdeepgorge/272/180/270/222","nespirah/286/269/460/261","ruinsoftherseral/197/223/554/175","ruinsofvashjir/349/361/217/268","shimmeringgrotto/339/278/400/0","silvertidehollow/480/319/150/32"},
["deepholm"]={"crimsonexpanse/462/400/540/12","deathwingsfall/454/343/549/297","needlerockchasm/378/359/20/0","needlerockslag/370/285/0/146","scouredreach/516/287/448/0","stonehearth/371/354/0/314","stormsfurywreckage/292/285/458/383","templeofearth/355/345/287/177","thepaleroost/467/273/85/0","therazanesthrone/274/156/434/0","theshatteredfield/430/230/141/438","twilightoverlook/411/248/570/420","twilightterrace/237/198/297/384"},
["thecapeofstranglethorn"]={"bootybay/225/255/289/341","crystalveinmine/271/204/528/73","gurubashiarena/238/260/345/0","jagueroisle/240/264/471/404","mistvalevalley/253/242/408/248","nekmaniwellspring/246/221/292/213","ruinsofaboraz/184/176/533/181","ruinsofjubuwal/155/221/468/119","thesundering/244/209/452/0","wildshore/236/276/340/392","hardwrenchhideaway/356/221/208/116"},
["gilneas_terrain1"]={"crowleyorchard/210/166/261/427","duskhaven/286/178/272/333","emberstonemine/281/351/639/43","greymanemanor/244/241/141/202","hammondfarmstead/194/236/167/352","haywardfishery/177/219/293/449","keelharbor/280/342/298/95","korothsden/222/268/393/386","northernheadlands/267/314/387/0","northgatewoods/250/298/482/14","stormglenvillage/321/203/516/465","tempestsreach/350/345/652/290","theblackwald/280/224/504/394","theheadlands/328/336/160/0","gilneascity/282/263/483/210"},
["gilneas_terrain2"]={"crowleyorchard/210/166/261/427","duskhaven/286/178/272/333","emberstonemine/281/351/639/43","greymanemanor/244/241/141/202","hammondfarmstead/194/236/167/352","haywardfishery/177/219/293/449","keelharbor/280/342/298/95","korothsden/222/268/393/386","northernheadlands/267/314/387/0","northgatewoods/282/298/482/14","stormglenvillage/321/203/516/465","tempestsreach/350/345/652/290","theblackwald/280/224/504/394","theheadlands/328/336/160/0","gilneascity/282/263/483/210"},
["thelostisles_terrain1"]={"alliancebeachhead/177/172/129/348","bilgewaterlumberyard/248/209/462/43","gallywixdocks/173/180/351/21","hordebasecamp/222/190/244/458","ktcoilplatform/156/142/433/11","landingsite/142/133/377/359","ooomlotvillage/221/211/508/345","oostan/210/258/492/161","raptorrise/168/205/416/368","ruinsofvashelan/212/216/440/452","scorchedgully/305/288/323/185","shipwreckshore/172/175/189/408","skyfalls/190/186/416/131","thesavageglen/231/216/213/325","theslavepits/212/193/279/68","warchiefslookout/159/230/264/144","lostpeak/350/517/581/21"},
["thelostisles_terrain2"]={"alliancebeachhead/177/172/129/348","bilgewaterlumberyard/248/209/462/43","gallywixdocks/173/180/351/21","hordebasecamp/222/190/244/458","ktcoilplatform/156/142/433/11","landingsite/142/133/377/359","ooomlotvillage/221/211/508/345","oostan/210/258/492/161","raptorrise/168/205/416/368","ruinsofvashelan/212/216/440/452","scorchedgully/305/288/323/185","shipwreckshore/172/175/189/408","skyfalls/190/186/416/131","thesavageglen/231/216/213/325","theslavepits/212/193/279/68","warchiefslookout/159/230/264/144","lostpeak/350/517/581/21"},
["hyjal_terrain1"]={"ashenlake/282/418/6/78","darkwhispergorge/320/471/682/128","gatesofsothann/272/334/622/320","nordrassil/537/323/392/0","sethriasroost/277/232/139/436","shrineofgoldrinn/291/321/116/17","theregrowth/441/319/52/253","thescorchedplain/365/264/411/216","thethroneofflame/419/290/318/378","direforgehill/270/173/303/197","archimondesvengeance/270/300/320/5"},
["ruinsofgilneas"]={"gilneaspuzzle/1002/668/0/0"},
["twilighthighlands"]={"bloodgulch/215/157/416/205","crucibleofcarnage/203/208/387/268","crushblow/182/195/370/447","dragonmawpass/283/206/76/120","dragonmawport/251/207/631/245","dunwaldruins/197/218/395/367","firebeardspatrol/215/181/499/265","glopgutshollow/174/190/291/89","gorshakwarcamp/194/170/543/220","grimbatol/230/276/83/223","highbank/220/227/697/403","highlandforest/239/232/482/330","humboldtconflaguration/143/141/344/89","kirthaven/308/267/482/0","obsidianforest/342/288/436/380","ruinsofdrakgor/206/182/296/0","slitheringcove/198/201/622/169","theblackbreach/211/210/498/121","thegullet/175/180/269/179","thekrazzworks/226/232/654/0","thetwilightbreach/199/212/312/192","thetwilightcitadel/361/354/151/314","thundermar/238/229/374/93","twilightshore/260/202/610/345","vermillionredoubt/324/264/71/16","victorypoint/177/159/302/306","wyrmsbend/191/198/205/232","weepingwound/214/190/358/0","thetwilightgate/165/199/327/356"},
["uldum"]={"akhenetfields/164/185/471/277","cradeloftheancient/202/169/341/402","hallsoforigination/269/242/599/184","khartutstomb/203/215/542/0","lostcityofthetolvir/233/321/527/291","marat/160/193/406/174","nahom/237/194/583/162","neferset/209/254/407/384","obeliskofthemoon/400/224/110/0","obeliskofthestars/196/170/551/121","obeliskofthesun/269/203/340/282","orsis/249/243/264/136","ramkahen/228/227/411/67","ruinsofahmtul/278/173/365/0","ruinsofammon/203/249/217/289","schnottzslanding/312/289/28/221","tahretgrounds/150/159/545/193","templeofuldum/296/209/132/127","thecursedlanding/237/316/752/170","thegateofunendingcycles/161/236/647/15","thetrailofdevestation/206/204/657/349","thevortexpinnacle/213/195/656/473","virnaaldam/151/144/479/215","throneofthefourwinds/270/229/229/433"},
["uldum_terrain1"]={"akhenetfields/164/185/471/277","cradeloftheancient/202/169/341/402","hallsoforigination/269/242/599/184","khartutstomb/203/215/542/0","lostcityofthetolvir/233/321/527/291","marat/160/193/406/174","nahom/237/194/583/162","neferset/209/254/407/384","obeliskofthemoon/400/224/110/0","obeliskofthestars/196/170/551/121","obeliskofthesun/269/203/340/282","orsis/249/243/264/136","ramkahen/228/227/411/67","ruinsofahmtul/278/173/365/0","ruinsofammon/203/249/217/289","schnottzslanding/312/289/28/221","tahretgrounds/150/159/545/193","templeofuldum/296/209/132/127","thecursedlanding/237/316/752/170","thegateofunendingcycles/161/236/647/15","thetrailofdevestation/206/204/657/349","thevortexpinnacle/213/195/656/473","throneofthefourwinds/270/229/229/433","virnaaldam/151/144/479/215"},
["twilighthighlands_terrain1"]={"bloodgulch/215/157/416/205","crucibleofcarnage/203/208/387/268","crushblow/182/195/370/447","dragonmawpass/283/206/76/120","dragonmawport/251/207/631/245","dunwaldruins/197/218/395/367","firebeardspatrol/215/181/499/265","glopgutshollow/174/190/291/89","gorshakwarcamp/194/170/543/220","grimbatol/230/276/83/223","highbank/220/227/697/403","highlandforest/239/232/482/330","humboldtconflaguration/143/141/344/89","kirthaven/308/267/482/0","obsidianforest/342/288/436/380","ruinsofdrakgor/206/182/296/0","slitheringcove/198/201/622/169","theblackbreach/211/210/498/121","thegullet/175/180/269/179","thekrazzworks/226/232/654/0","thetwilightbreach/199/212/312/192","thetwilightcitadel/361/354/151/314","thetwilightgate/165/199/327/356","thundermar/238/229/374/93","twilightshore/260/202/610/345","vermillionredoubt/324/264/71/16","victorypoint/177/159/302/306","weepingwound/214/190/358/0","wyrmsbend/191/198/205/232"},
["ahnqirajthefallenkingdom"]={"aqkingdom/887/668/115/0"},
["thejadeforest"]={"chuntianmonastery/227/198/300/56","dawnsblossom/234/210/325/178","dreamerspavillion/218/148/474/520","emperorsomen/202/204/430/21","glassfinvillage/278/310/525/358","grookinmound/253/229/182/214","hellscreamshope/196/166/181/75","jademines/236/142/400/146","nectarbreezeorchard/219/256/290/330","nookanooka/219/205/189/151","ruinsofganshi/196/158/316/0","serpentsspine/191/216/388/299","slingtailpits/179/180/428/416","templeofthejadeserpent/264/211/468/295","thearboretum/242/210/481/215","waywardlanding/219/186/346/482","windlessisle/251/348/539/43","wreckoftheskyshark/210/158/202/0"},
["valleyofthefourwinds"]={"cliffsofdispair/510/264/215/404","dustbackgorge/209/308/0/343","gildedfan/208/292/438/41","grandgranery/314/212/334/325","halfhill/206/245/438/177","harvesthome/260/251/5/239","kuzenvillage/199/304/224/74","mudmugsplace/230/217/561/161","nesingwarysafari/249/342/104/326","paoquanhollow/273/246/12/105","poolsofpurity/213/246/513/58","silkenfields/254/259/530/253","rumblingterrace/277/245/582/301","singingmarshes/175/291/170/130","stormsoutbrewery/257/288/227/380","theheartland/286/392/253/75","thunderfootfields/380/317/622/0","zhusdecent/303/323/699/114"},
["thewanderingisle"]={"thewoodofstaves/989/466/13/202","fe-fangvillage/234/286/134/9","morningbreezevillage/261/315/203/36","ridgeoflaughingwinds/313/321/183/198","poolofthepaw/220/188/297/324","pei-wuforest/651/262/351/406","skyfirecrash-site/346/263/124/405","mandorivillage/610/374/392/294","templeoffivedawns/607/461/395/182","thedawningvalley/677/668/325/0","thesingingpools/372/475/545/12","therows/385/373/504/295"},
["kunlaisummit"]={"binanvillage/240/198/607/470","fireboughnook/224/172/322/496","gateoftheaugust/261/162/449/506","kotapeak/252/257/233/360","mogujia/253/208/462/411","mountneverset/313/208/228/264","muskpawranch/229/262/603/313","peakofserenity/287/277/333/63","shadopanmonastery/385/385/88/92","templeofthewhitetiger/250/260/587/170","theburlaptrail/310/276/398/310","valleyofemperors/224/241/453/191","zouchinvillage/298/219/502/64","iseoflostsouls/259/233/602/4"},
["townlongwastes"]={"gaoranblockade/353/200/546/468","krivess/255/269/420/209","mingchicrossroads/247/221/417/447","niuzaotemple/296/359/213/241","osulmesa/238/296/560/185","palewindvillage/282/306/692/362","shadopangarrison/213/170/413/385","shanzedao/300/246/125/0","sikvess/261/235/306/433","srivess/294/283/92/192","thesumprushes/271/205/545/369"},
["valeofeternalblossoms"]={"guolairuins/337/349/87/3","mistfallvillage/310/305/200/363","mogushanpalace/373/385/629/22","settingsuntraining/350/429/0/234","thegoldenstair/242/254/328/16","thestairsascent/446/359/556/267","thetwinmonoliths/272/522/444/97","tushenburialground/267/308/349/316","whitemoonshrine/298/262/482/10","whitepetallake/267/281/278/170","winterboughglade/361/333/4/107"},
["krasarang"]={"anglersoutpost/265/194/545/205","cradleofchiji/272/250/176/376","dojaniriver/190/282/513/3","fallsongriver/214/393/218/77","zhusbastion/306/204/612/0","lostdynasty/217/279/589/27","nayelilagoon/246/240/343/373","redwingrefuge/212/265/317/63","ruinsofdojan/204/383/444/44","ruinsofkorja/211/395/125/88","templeoftheredcrane/219/259/300/215","thedeepwild/188/412/397/59","theforbiddenjungle/257/300/0/79","thesouthernisles/252/313/23/267","ungaingoo/258/170/330/498","krasarangcove/286/268/701/19"},
["dreadwastes"]={"brewgarden/250/218/351/0","brinymuck/325/270/214/311","clutchesofshekzeer/209/318/341/125","dreadwaterlake/322/211/437/313","heartoffear/262/293/191/122","horridmarch/323/194/441/224","klaxxivess/236/206/458/110","kyparivor/325/190/485/0","rikkitunvillage/218/186/236/32","soggysgamble/268/241/450/406","terraceofgurthan/209/234/593/92","zanvess/290/283/162/385"},
["stvdiamondminebg"]={"17467/385/146/206/173","17468/362/222/414/96","17469/164/191/565/289","17470/213/257/565/126"},
["thehiddenpass"]={"thehiddensteps/290/191/412/477","theblackmarket/479/493/371/175","thehiddencliffs/294/220/433/0"},
["dustwallow_terrain1"]={"alcazisland/206/200/656/21","blackhoofvillage/344/183/199/0","brackenwllvillage/384/249/133/59","direhornpost/279/301/358/169","mudsprocket/433/351/109/313","shadyrestinn/317/230/137/188","theramoreisle/305/247/542/223","thewyrmbog/436/299/359/369","witchhill/270/353/428/0"},
["krasarang_terrain1"]={"anglersoutpost/347/199/545/200","cradleofchiji/272/250/176/376","redwingrefuge/212/265/317/63","dojaniriver/190/282/513/3","fallsongriver/214/393/218/77","nayelilagoon/246/240/343/373","ruinsofdojan/204/383/444/44","ruinsofkorja/211/395/125/88","templeoftheredcrane/219/259/300/215","thedeepwild/188/412/397/59","theforbiddenjungle/257/300/0/79","lostdynasty/217/279/589/27","thesouthernisles/275/329/0/267","krasarangcove/295/293/701/19","ungaingoo/258/170/330/498","zhusbastion/306/204/612/0"},
--["isleofthethunderking"]={"alliance/490/290/256/378","horde/278/325/183/95","lock1/446/429/396/9","lock2/446/429/396/9","lock3/446/429/396/9","lock4/446/429/396/9"},
--["isleofthethunderkingscenario"]={"horde/278/325/183/95","lock2/446/429/396/9","lock3/446/429/396/9","lock1/446/429/396/9","lock4/446/429/396/9","alliance/490/290/256/378"},
["frostfireridge"]={"bladespirefortress/356/303/38/117","bloodmaulstronghold/258/217/311/4","bonesofagurak/273/349/729/319","daggermawravine/255/191/284/91","frostwinddunes/274/214/121/0","grimfrosthill/178/203/597/210","grombolash/217/239/483/33","gromgar/282/341/505/323","hordegarrison/267/257/336/327","ironsiegeworks/329/294/673/156","magnarok/213/278/609/33","ironwaystation/199/335/641/304","stonefangoutpost/251/191/306/281","theboneslag/256/210/290/192","thecracklingplains/266/293/439/137","worgol/317/233/72/292","nogarrison/267/257/336/327","shipyard/267/257/336/327"},
["tanaanjungle"]={"darkportal/333/437/637/136","draeneisw/174/208/81/367","fangrila/343/264/429/392","felforge/223/183/392/187","ironfront/209/245/0/264","ironharbor/189/294/303/62","kiljaeden/365/276/392/23","kranak/338/254/54/94","lionswatch/270/208/465/313","marshlands/246/218/296/383","shanaar/248/314/170/354","volmar/238/229/501/171","zethgol/274/251/118/194","hellfirecitadel/327/241/254/262"},
["talador"]={"aruuna/389/234/597/178","auchindoun/309/262/338/356","centerisles/252/280/546/228","courtofsouls/307/229/150/264","fortwrynn/292/235/567/42","gordalfortress/423/290/548/378","gulrok/278/270/165/364","northgate/398/149/571/0","orunaicoast/279/267/427/0","seentrance/308/276/685/298","shattrath/406/367/173/22","telmor/497/157/207/511","tomboflights/326/212/352/271","tuurem/225/224/472/148","zangarra/287/277/713/35"},
["shadowmoonvalleydr"]={"anguishfortress/309/264/140/160","darktideroost/282/201/468/467","elodor/291/266/426/0","embaari/346/252/270/158","garrison/223/279/194/0","gloomshade/229/240/319/5","gulvar/260/309/26/0","karabor/393/318/537/150","nogarrison/223/279/194/0","shazgul/282/225/259/315","shimmeringmoor/288/261/453/306","socrethar/202/201/383/411","swisland/173/160/309/460","shipyard/223/279/194/0"},
["spiresofarak"]={"bloodbladeredoubt/209/154/334/210","bloodmanevalley/229/246/410/350","centerravennest/188/190/444/255","clutchpop/217/224/533/382","eastmushrooms/182/244/649/155","emptygarrison/190/187/282/261","howlingcrag/382/274/459/0","nwcorner/314/304/102/0","sethekkhollow/238/295/520/127","skettis/371/174/289/0","solospirenorth/196/284/429/84","solospiresouth/169/178/374/276","southport/197/179/310/328","veilakraz/252/230/281/83","veilzekk/198/232/521/268","venturecove/226/193/465/475","writhingmire/229/213/197/198"},
["gorgrond"]={"bastionrise/324/161/283/507","beastwatch/166/161/383/371","easternruin/210/193/525/260","evermorn/297/181/281/444","foundry/211/221/455/74","foundrysouth/217/180/454/183","gronncanyon/279/241/258/213","highlandpass/285/323/547/73","highpass/209/225/411/250","irondocks/315/180/350/0","mushrooms/253/198/444/323","stonemaularena/217/178/259/335","stonemaulsouth/208/142/275/416","stripmine/250/232/312/77","tangleheart/262/221/451/372"},
["nagranddraenor"]={"ancestral/234/191/239/259","brokenprecipice/305/227/256/12","elementals/286/274/588/0","hallvalor/236/372/766/118","highmaul/471/437/0/0","ironfistharbor/236/242/283/354","lokrath/316/221/382/187","grommashar/256/301/600/367","margoks/249/288/753/380","mushrooms/250/287/746/25","oshugun/262/266/366/323","ringofblood/263/287/430/0","ringoftrials/354/315/523/159","sunspringwatch/274/254/312/98","telaar/296/272/461/353"},
["tanaanjungleintro"]={"tank/143/137/328/251"},
["blastedlands_terrain1"]={"riseofthedefiler/168/170/375/102","altarofstorms/238/195/225/110","dreadmaulhold/272/206/258/0","dreadmaulpost/235/188/327/182","nethergardekeep/295/205/530/6","nethergardesupplycamps/195/199/436/0","serpentscoil/218/183/459/97","shattershore/240/270/578/91","sunveilexcursion/233/266/386/374","surwich/199/191/333/474","thedarkportal/370/298/368/179","theredreaches/268/354/533/268","thetaintedforest/348/357/132/311","thetaintedscar/308/226/144/175"},
["azsuna"]={"faronaar/330/265/166/202","felblaze/239/303/594/0","greenway/247/184/450/95","isleofthewatchers/321/267/281/401","llothienhighlands/351/245/219/69","lostorchard/315/185/257/0","narthalas/272/192/441/173","oceanuscove/206/266/396/244","ruinedsanctum/220/288/523/233","templelights/181/243/481/340","zarkhenar/288/195/477/0"},
["stormheim"]={"aggrammarsvault/199/185/361/210","blackbeakoverlook/297/210/154/129","dreadwake/215/247/457/412","dreyrgrot/132/145/689/266","greywatch/173/163/648/339","hallsofvalor/252/280/585/372","haustvald/200/174/612/187","hrydshal/631/315/0/353","mawofnashal/509/251/17/0","morheim/150/180/741/313","nastrondir/241/194/345/95","qatchmansrock/135/162/623/81","runewood/194/214/592/226","shieldsrest/289/172/689/0","skoldashil/177/169/506/345","stormsreach/180/160/510/118","talonrest/291/208/316/282","tideskornharbor/205/199/479/183","valdisdall/186/158/522/288","weepingbluffs/386/314/56/185"},
["valsharah"]={"andutalah/241/240/587/250","blackrookhold/231/240/281/188","bradensbrook/311/244/259/275","dreamgrove/294/364/283/0","gloamingreef/239/301/136/274","groveofcenarius/171/150/457/351","lorlathil/177/156/467/413","mistvale/263/313/621/49","moonclawvale/254/281/549/380","shalanir/326/360/419/0","smolderhide/341/188/324/480","templeofelune/216/219/459/240","thastalah/218/168/342/416"},
["brokenshore"]={"brokenshoresouth/482/359/224/275","theblackcity/478/328/257/95","thelosttemple/337/289/613/126","tombofsargeras/414/281/373/0"},
["highmountain"]={"bloodhunthighlands/297/250/307/75","feltotem/256/326/172/31","frosthoofwatch/186/213/391/408","ironhornenclave/288/258/452/410","nightwatchersperch/344/295/0/244","pinerockbasin/217/148/323/249","riverbend/214/308/314/360","rockawayshallows/207/302/469/45","shipwreckcove/283/170/331/0","skyhorn/311/229/357/179","stonehoofwatch/341/328/494/236","sylvanfalls/445/326/0/342","thundertotem/244/199/332/302","trueshotlodge/172/204/249/236"},
["suramar"]={"ambervale/222/311/132/179","crimsonthicket/327/381/492/0","falanaar/248/317/23/136","felsoulhold/289/363/183/305","grandpromenade/355/291/344/285","jandvik/419/538/583/0","moonguardstronghold/480/245/58/0","moonwhispergulch/428/316/201/0","ruinsofeluneeth/221/224/264/226","suramarcity/470/337/390/331","telanor/387/372/327/0"},
["niskara"]={"marksman/262/188/269/233","deathknight/116/118/271/238"},
["aszunadungeonexterior"]={"eyeofazshara/848/668/39/0"},
}

local modf = math.modf
-- Handle checking for existance of textures
local TextureCache, TextureQueue = {}, {} -- Store result for future lookups
local TextureUpdater = CreateFrame('frame')
local function UpdateTextures(self, elapsed)
	if #TextureQueue ~= 0 then
		for i, tex in pairs(TextureQueue) do
			local texture, textureWidth, textureHeight = tex[1], tex[2], tex[3]
			local texturePath = texture:GetTexture() or ''
			if texturePath == '' then
				tremove(TextureQueue, i)
				if #TextureQueue == 0 then
					self:SetScript('OnUpdate', nil)
				end
			else
				local size = texture:GetWidth() or 0
				if size > 0 then
					if size > 10 then
						TextureCache[texturePath] = 1
						texture:SetSize(textureWidth, textureHeight)
						texture:Show()
					else
						TextureCache[texturePath] = 0
						texture:SetSize(textureWidth, textureHeight)
						texture:SetTexture(0,.113,.16)
						texture:Show()
					end
					tremove(TextureQueue, i)
					if #TextureQueue == 0 then
						self:SetScript('OnUpdate', nil)
					end
				end
			end
		end
	end
end

local function SuperSetTexture(texture, texturePath, textureWidth, textureHeight)
	--if texturePath == texture:GetTexture() then return end
	local cached = TextureCache[texturePath]
	if cached then
		if cached == 1 then
			texture:SetTexture(texturePath)
			texture:SetSize(textureWidth, textureHeight)
			texture:Show()
		else
			--texture:Hide()
			texture:SetSize(textureWidth, textureHeight)
			texture:SetTexture(0,.113,.16)
			texture:Show()
		end
	else
		texture:SetWidth(0) -- force dimensions
		texture:Hide()
		tinsert(TextureQueue, {texture, textureWidth, textureHeight})
		if #TextureQueue == 1 then TextureUpdater:SetScript('OnUpdate', UpdateTextures) end
		texture:SetTexture(texturePath)
	end
end

local cachedArea = ''
local function update_overlays()
	local areaID = GetCurrentMapAreaID()
	local mapName, _, _, isMicroDungeon, microDungeonPath = GetMapInfo()
	local floorNum, dBRx, dBRy, dTLx, dTLy = GetCurrentMapDungeonLevel()
	
	local currentArea = format('%d.%s', floorNum or 0, microDungeonPath or mapName or '')
	if currentArea == cachedArea then return end -- return if the map hasn't actually changed
	cachedArea = currentArea
	--print('new map', currentArea)
	
	local info = OverlayInfo[strlower(mapName or '')]
	local texNum = 1
	if info then
		local oOverlays = {}
		if not isMicroDungeon then
			local paf = "Interface\\WorldMap\\"..mapName.."\\"
			for i=1,GetNumMapOverlays() do
				local overlayName = GetMapOverlayInfo(i)
				oOverlays[overlayName:lower()] = true
			end
			for i, item in pairs(info) do
				local textureName, textureWidth, textureHeight, offsetX, offsetY = strsplit('/', item) --item:match("^([^/]+)/(%d+)/(%d+)/(%d+)/(%d+)$")
				textureName = paf..textureName
				if oOverlays[textureName] then
					tremove(info, i)
				else
					if textureName and textureName ~= '' then
						local numTexturesWide,numTexturesTall = ceil(textureWidth/256),ceil(textureHeight/256)
						for j=1,numTexturesTall do
							if j < numTexturesTall then
								texturePixelHeight = 256
								textureFileHeight = 256
							else
								texturePixelHeight = mod(textureHeight, 256)
								if texturePixelHeight == 0 then
									texturePixelHeight = 256
								end
								textureFileHeight = 16
								while(textureFileHeight < texturePixelHeight) do
									textureFileHeight = textureFileHeight * 2
								end
							end
							for k=1,numTexturesWide do
								if k < numTexturesWide then
									texturePixelWidth = 256
									textureFileWidth = 256
								else
									texturePixelWidth = mod(textureWidth, 256)
									if texturePixelWidth == 0 then
										texturePixelWidth = 256
									end
									textureFileWidth = 16
									while textureFileWidth < texturePixelWidth do
										textureFileWidth = textureFileWidth * 2
									end
								end
								local texture
								if not overlayTextures[texNum] then
									texture = overlayFrame:CreateTexture(nil, 'ARTWORK', nil, -1)
									texture:SetVertexColor(r,g,b,a)
									overlayTextures[texNum] = texture
								else
									texture = overlayTextures[texNum]
									texture:Show()
								end
								texNum = texNum + 1
								texture:SetSize(texturePixelWidth,texturePixelHeight)
								texture:SetTexCoord(0, texturePixelWidth/textureFileWidth, 0, texturePixelHeight/textureFileHeight)
								texture:SetPoint("TOPLEFT", overlayFrame, 'TOPLEFT', offsetX + (256 * (k-1)), -(offsetY + 256 * (j - 1)))
								texture:SetTexture(textureName..(((j - 1) * numTexturesWide) + k))
							end
						end
					end
				end
			end
		end
	end
	for i=texNum,#overlayTextures do
		if overlayTextures[i] then
			overlayTextures[i]:Hide()
		end
	end
	
	-- Draw terrain map
	--local _, _, _, isMicroDungeon = GetMapInfo()
	if info and not isMicroDungeon then
	--if not (select(2, GetCurrentMapAreaID())) then
		menu:Show()
		local terrainMapID = GetAreaMapInfo(areaID) or -1
		local _, TLx, TLy, BRx, BRy = GetCurrentMapZone()
		
		if DungeonUsesTerrainMap() then
			floorNum = floorNum - 1
		end
		
		if floorNum > 0 then
			TLx, TLy, BRx, BRy = dTLx, dTLy, dBRx, dBRy
		end
		
		if TLx and TLx ~= 0 and TERRAIN_MAPS[terrainMapID] and areaID ~= 640 and floorNum == 0 then
			local areaWidth, areaHeight = abs(BRx-TLx), abs(BRy-TLy)			
			local tileSize = 1002/areaWidth*TERRAIN_MAGIC
			local iTileX, fTileX = modf(32-TLx/TERRAIN_MAGIC)
			local iTileY, fTileY = modf(32-TLy/TERRAIN_MAGIC)
			local tileOffsetX, tileOffsetY = (TLx-((iTileX-32)*-TERRAIN_MAGIC))/areaWidth, (TLy-((iTileY-32)*-TERRAIN_MAGIC))/areaHeight
			local numTilesX, numTilesY = ceil((areaWidth+fTileX*TERRAIN_MAGIC)/TERRAIN_MAGIC), ceil((areaHeight+fTileY*TERRAIN_MAGIC)/TERRAIN_MAGIC)

			local n = 0
			for y=1,numTilesY do
				for x=1,numTilesX do
					n = n + 1
					if not terrainTextures[n] then
						terrainTextures[n] = terrainFrame:CreateTexture(nil, 'ARTWORK', nil, FoglightMode == 3 and 2 or -2)
						--terrainTextures[n]:SetNonBlocking(true)
						terrainTextures[n]:SetAlpha(terrainAlpha)
					end
					local texture = terrainTextures[n]
	
					-- Lots and lots of SetTexCoords!
					local textureWidth, textureHeight = tileSize, tileSize
					local textureOffsetX, textureOffsetY = tileOffsetX*1002+tileSize*(x-1), -tileOffsetY*668-tileSize*(y-1)
					local left, right, top, bottom = 0, 1, 0, 1
					if numTilesX == 1 and numTilesY == 1 then -- only 1 tile.. trim from all sides
						textureWidth, textureHeight = 1002, 668
						textureOffsetX, textureOffsetY = 0, 0
						left = fTileX
						top = fTileY
						right = (1002+fTileX*tileSize)/tileSize
						bottom = (668+fTileY*tileSize)/tileSize
					elseif numTilesX == 1 then -- only 1 tile wide, trim from left and right
						textureWidth = 1002
						textureOffsetX = 0
						left = fTileX
						right = (1002+fTileX*tileSize)/tileSize
					elseif numTilesY == 1 then -- only 1 tile tall, trim from top and bottom
						textureHeight = 668
						textureOffsetY = 0
						top = fTileY
						bottom = (668+fTileY*tileSize)/tileSize
					elseif y == 1 and x == 1 then -- top left corner, trim from top and left
						textureWidth, textureHeight = tileSize - fTileX*tileSize, tileSize - fTileY*tileSize
						textureOffsetX, textureOffsetY = 0, 0
						left = fTileX
						top = fTileY
					elseif y == 1 and x == numTilesX then -- top right corner
						textureWidth, textureHeight = 1002 - textureOffsetX, tileSize - fTileY*tileSize
						textureOffsetY = 0
						top = fTileY
						right = textureWidth/tileSize
					elseif y == numTilesY and x == numTilesX then -- bottom right corner
						textureWidth, textureHeight = 1002 - textureOffsetX, textureOffsetY + 668
						right = textureWidth/tileSize
						bottom = textureHeight/tileSize
					elseif y == numTilesY and x == 1 then -- bottom left corner
						textureWidth, textureHeight = tileSize - fTileX*tileSize, textureOffsetY + 668
						textureOffsetX = 0
						left = fTileX
						bottom = textureHeight/tileSize
					elseif y == 1 then -- top row
						textureHeight = tileSize - fTileY*tileSize
						textureOffsetY = 0
						top = fTileY
					elseif x == numTilesX then -- right column
						textureWidth = 1002 - textureOffsetX
						right = textureWidth/tileSize
					elseif y == numTilesY then -- bottom row
						textureHeight = textureOffsetY + 668
						bottom = textureHeight/tileSize
					elseif x == 1 then -- left column
						textureWidth = tileSize - fTileX*tileSize
						textureOffsetX = 0
						left = fTileX
					end
					
					texture:SetTexCoord(left, right, top, bottom)
					texture:SetPoint('TOPLEFT', textureOffsetX, textureOffsetY)
					
					--local texturePath = TERRAIN_PATH:format(TERRAIN_MAPS[terrainMapID], iTileX+(x-1), iTileY+(y-1))
					local paf = (areaID == 610 or areaID == 614 or areaID == 615) and UNDERWATER_PATH or TERRAIN_PATH
					local texturePath = paf:format(TERRAIN_MAPS[terrainMapID], iTileX+(x-1), iTileY+(y-1))
					texture:SetTexture(texturePath)
					texture:SetSize(textureWidth, textureHeight)
					texture:Show()
					--SuperSetTexture(texture, texturePath, textureWidth, textureHeight)
				end
			end
			
			for i=n+1,#terrainTextures do
				terrainTextures[i]:Hide()
			end
			
			showTerrain = true
			if FoglightMode == 1 or FoglightMode == 3 then
				terrainFrame:Show()
			end
			--if activeMode == button3 then WorldMapHighlight:SetParent(terrainFrame) end
		else
			showTerrain = false
			--if activeMode == button3 then WorldMapHighlight:SetParent(WorldMapDetailFrame) end
			terrainFrame:Hide()
			for i=1,#terrainTextures do
				terrainTextures[i]:Hide()
			end
		end
	else
		menu:Hide()
		--if activeMode == button3 then WorldMapHighlight:SetParent(WorldMapDetailFrame) end
		terrainFrame:Hide()
		showTerrain = false
		for i=1,#terrainTextures do
			terrainTextures[i]:Hide()
		end
	end
end

hooksecurefunc('WorldMapFrame_Update', update_overlays)