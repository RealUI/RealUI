--[[ Map sizes database module
	GetPlayerMapPosition() returns coordinate values betwen 0 and 1
    We need the width and height of each map to convert the coordinates to yards.
	x, y = GetPlayerMapPosition()
	x_in_yards = x * map_width
	y_in_yards = y * map_height
	Maps tables format: ['MapName'] = { floor1_width,floor1_height, floor2_width,floor2_height, floor3_width,floor3_height, ... }
--]]

--[[local Maps= {
	['AhnQiraj'] = { 2777.544,1851.690, 977.560,651.700, 577.560,385.040, },
	['AhnQirajTheFallenKingdom'] = { 4050.000,2700.000, },
	['Ahnkahet'] = { 972.418,648.279, },
	['AlteracValley'] = { 4237.500,2825.000, },
	['Arathi'] = { 3477.083,2318.750, },
	['ArathiBasin'] = { 1756.250,1170.833, },
	['Ashenvale'] = { 5766.666,3843.750, },
	['Aszhara'] = { 5514.583,3677.083, },
	['AuchenaiCrypts'] = { 742.540,495.027, 817.540,545.027, },
	['Azeroth'] = { 40741.182,27149.688, },
	['AzjolNerub'] = { 752.974,501.983, 292.974,195.316, 367.500,245.000, },
	['AzuremystIsle'] = { 4070.833,2714.583, },
	['Badlands'] = { 3070.833,2045.833, },
	['BaradinHold'] = { 585.000,390.000, },
	['Barrens'] = { 5745.833,3831.250, },
	['BattleforGilneas'] = { 889.583,593.750, },
	['BlackTemple'] = { 1252.250,834.833, 975.000,650.000, 1005.000,670.000, 440.001,293.334, 670.000,446.667, 705.000,470.000, 355.000,236.667, },
	['BlackfathomDeeps'] = { 884.220,589.480, 884.220,589.480, 284.224,189.483, },
	['BlackrockCaverns'] = { 1019.508,679.672, 1019.508,679.672, },
	['BlackrockDepths'] = { 1407.061,938.041, 1507.061,1004.707, },
	['BlackrockSpire'] = { 886.839,591.226 }, -- 7 floors (but same size)
	['BlackwingDescent'] = { 849.694,566.462, 999.693,666.462, },
	['BlackwingLair'] = { 499.428,332.950, 649.427,432.950, 649.427,432.950, 649.427,432.950, },
	['BladesEdgeMountains'] = { 5425.000,3616.666, },
	['BlastedLands'] = { 3662.500,2441.666, },
	['BloodmystIsle'] = { 3262.499,2175.000, },
	['BoreanTundra'] = { 5764.583,3843.750, },
	['BurningSteppes'] = { 3152.083,2100.000, },
	['CoTHillsbradFoothills'] = { 2331.250,1554.167, },
	['CoTMountHyjal'] = { 2500.000,1666.667, },
	['CoTStratholme'] = { 1825.000,1216.667, 1125.300,750.200, },
	['CoTTheBlackMorass'] = { 1087.500,725.000, },
	['CoilfangReservoir'] = { 1575.003,1050.002, },
	['CrystalsongForest'] = { 2722.917,1814.583, },
	['Dalaran'] = { 830.015,553.340, 563.224,375.490, },
	['Darkshore'] = { 6464.583,4310.416, },
	['Darnassus'] = { 1539.583,1027.083, },
	['DeadwindPass'] = { 2500.000,1666.667, },
	['Deepholm'] = { 5100.000,3400.000, },
	['Desolace'] = { 4495.833,2997.917, },
	['DireMaul'] = { 1275.000,850.000, 525.000,350.000, 487.500,325.000, 750.000,500.000, 800.001,533.334, 975.000,650.000, },
	['Dragonblight'] = { 5608.333,3739.583, },
	['DrakTharonKeep'] = { 619.941,413.294, 619.941,413.294, },
	['DunMorogh'] = { 4897.917,3264.583, },
	['Durotar'] = { 5287.500,3525.000, },
	['Duskwood'] = { 2700.000,1800.000, },
	['Dustwallow'] = { 5250.000,3500.000, },
	['EasternPlaguelands'] = { 4031.250,2687.500, },
	['Elwynn'] = { 3470.833,2314.583, },
	['EversongWoods'] = { 4925.000,3283.333, },
	['Felwood'] = { 6062.500,4041.666, },
	['Feralas'] = { 6950.000,4633.333, },
	['Firelands'] = { 1587.500,1058.333, 375.000,250.000, 1440.000,960.000, },
	['Ghostlands'] = { 3300.000,2200.000, },
	['Gilneas'] = { 3145.833,2097.917, },
	['GilneasCity'] = { 889.583,593.750, },
	['Gnomeregan'] = { 769.668,513.112, 769.668,513.112, 869.668,579.778, 869.670,579.780, },
	['GrimBatol'] = { 869.047,579.365, },
	['GrizzlyHills'] = { 5250.000,3500.000, },
	['GruulsLair'] = { 525.000,350.000, },
	['Gundrak'] = { 905.033,603.350, },
	['HallsofLightning'] = { 566.235,377.490, 708.237,472.160, },
	['HallsofOrigination'] = { 1531.751,1021.167, 1272.755,848.503, 1128.769,752.513, },
	['HallsofReflection'] = { 879.020,586.020, },
	['Hellfire'] = { 5164.583,3443.750, },
	['HellfireRamparts'] = { 694.560,463.040, },
	['HillsbradFoothills'] = { 4862.500,3241.667, },
	['Hinterlands'] = { 3850.000,2566.667, },
	['HowlingFjord'] = { 6045.833,4031.250, },
	['HrothgarsLanding'] = { 3677.083,2452.084, },
	['Hyjal'] = { 4245.833,2831.250, },
	['IcecrownCitadel'] = { 1355.470,903.647, 1067.000,711.334, 195.470,130.315, 773.710,515.810, 1148.740,765.820, 373.710,249.130, 293.260,195.507, 247.930,165.288, },
	['IcecrownGlacier'] = { 6270.833,4181.250, },
	['Ironforge'] = { 790.625,527.604, },
	['IsleofConquest'] = { 2650.000,1766.667, },
	['Kalimdor'] = { 36799.811,24533.200, },
	['Karazhan'] = { 550.049,366.699, 257.860,171.906, 345.149,230.100, 520.049,346.699, 234.150,156.100, 581.549,387.699, 191.549,127.699, 139.351,92.900, 
					 760.049,506.699, 450.250,300.166, 271.050,180.699, 595.049,396.699, 529.049,352.699, 245.250,163.500, 211.150,140.766, 101.250,67.500, 341.250,227.500, },
	['Kezan'] = { 1352.083,900.000, },
	['LakeWintergrasp'] = { 2975.000,1983.333, },
	['LochModan'] = { 2758.333,1839.583, },
	['LostCityofTolvir'] = { 970.833,647.917, },
	['MagistersTerrace'] = { 530.334,353.556, 530.334,353.556, },
	['MagtheridonsLair'] = { 556.000,370.667, },
	['ManaTombs'] = { 823.285,548.857, },
	['Maraudon'] = { 975.000,650.000, 1637.500,1091.666, },
	['MoltenCore'] = { 1264.800,843.199, },
	['MoltenFront'] = { 1189.583,793.750, },
	['Moonglade'] = { 2308.333,1539.583, },
	['Mulgore'] = { 5450.000,3633.333, },
	['Nagrand'] = { 5525.000,3683.333, },
	['Naxxramas'] = { 1093.830,729.220, 1093.830,729.220, 1200.000,800.000, 1200.330,800.220, 2069.810,1379.880, 655.940,437.290, },
	['Netherstorm'] = { 5575.000,3716.667, },
	['NetherstormArena'] = { 2270.833,1514.583, },
	['Nexus80'] = { 514.707,343.139, 664.707,443.139, 514.707,343.139, 294.701,196.464, },
	['Northrend'] = { 17751.398,11834.265, },
	['OnyxiasLair'] = { 483.118,322.079, },
	['Orgrimmar'] = { 1739.375,1159.583, },
	['PitofSaron'] = { 1533.333,1022.917, },
	['Ragefire'] = { 738.864,492.576, },
	['RazorfenDowns'] = { 709.049,472.700, },
	['RazorfenKraul'] = { 736.450,490.960, },
	['Redridge'] = { 2568.750,1712.500, },
	['RuinsofAhnQiraj'] = { 2512.500,1675.000, },
	['RuinsofGilneas'] = { 3145.833,2097.917, },
	['RuinsofGilneasCity'] = { 889.583,593.750, },
	['ScarletEnclave'] = { 3162.500,2108.333, },
	['ScarletMonastery'] = { 619.984,413.323, 320.191,213.460, 612.697,408.460, 703.300,468.867, },
	['Scholomance'] = { 320.049,213.365, 440.049,293.366, 410.078,273.386, 531.042,354.028, },
	['SearingGorge'] = { 2231.250,1487.500, },
	['SethekkHalls'] = { 703.495,468.997, 703.495,468.997, },
	['ShadowLabyrinth'] = { 841.522,561.015, },
	['ShadowfangKeep'] = { 352.430,234.953, 212.427,141.618, 152.430,101.620, 152.430,101.625, 152.430,101.625, 198.430,132.287, 272.430,181.620, },
	['ShadowmoonValley'] = { 5500.000,3666.666, },
	['ShattrathCity'] = { 1306.250,870.833, },
	['SholazarBasin'] = { 4356.250,2904.167, },
	['Silithus'] = { 4058.333,2706.250, },
	['SilvermoonCity'] = { 1211.458,806.771, },
	['Silverpine'] = { 4200.000,2800.000, },
	['Skywall'] = { 2018.725,1345.818, },
	['SouthernBarrens'] = { 7412.500,4941.667, },
	['StonetalonMountains'] = { 5900.000,3933.333, },
	['StormwindCity'] = { 1737.500,1158.333, },
	['StrandoftheAncients'] = { 1743.750,1162.500, },
	['StranglethornJungle'] = { 4100.000,2733.333, },
	['StranglethornVale'] = { 6552.083,4368.750, },
	['Stratholme'] = { 705.720,470.480, 1005.720,670.480, },
	['Sunwell'] = { 3327.083,2218.749, },
	['SunwellPlateau'] = { 465.000,310.000, },
	['SwampOfSorrows'] = { 2508.333,1672.917, },
	['Tanaris'] = { 7212.500,4808.333, },
	['Teldrassil'] = { 5875.000,3916.667, },
	['TempestKeep'] = { 1575.000,1050.000, },
	['TerokkarForest'] = { 5400.000,3600.000, },
	['TheArcatraz'] = { 689.684,459.789, 546.048,364.032, 636.684,424.456, },
	['TheArgentColiseum'] = { 369.986,246.658, 739.996,493.330, },
	['TheArgentColiseum'] = { 369.986,246.658, },
	['TheBastionofTwilight'] = { 1078.335,718.890, 778.343,518.895, 1042.342,694.895, },
	['TheBloodFurnace'] = { 1003.519,669.013, },
	['TheBotanica'] = { 757.402,504.935, },
	['TheCapeOfStranglethorn'] = { 3945.833,2631.250, },
	['TheDeadmines'] = { 559.264,372.843, 499.263,332.842, },
	['TheExodar'] = { 1056.771,704.688, },
	['TheEyeofEternity'] = { 430.070,286.713, },
	['TheForgeofSouls'] = { 1448.100,965.400, },
	['TheLostIsles'] = { 4514.583,3010.417, },
	['TheMaelstrom'] = { 1550.000,1033.333, },
	['TheMechanar'] = { 676.238,450.825, 676.238,450.825, },
	['TheNexus'] = { 1101.281,734.188, },
	['TheNexusLegendary'] = { 1101.284,734.190, },
	['TheObsidianSanctum'] = { 1162.500,775.000, },
	['TheRubySanctum'] = { 752.083,502.083, },
	['TheShatteredHalls'] = { 1063.747,709.165, },
	['TheSlavePens'] = { 890.058,593.372, },
	['TheSteamvault'] = { 876.764,584.509, 876.764,584.509, },
	['TheStockade'] = { 378.153,252.102, },
	['TheStonecore'] = { 1317.129,878.087, },
	['TheStormPeaks'] = { 7112.500,4741.666, },
	['TheTempleOfAtalHakkar'] = { 695.029,463.353, },
	['TheUnderbog'] = { 894.920,596.613, },
	['ThousandNeedles'] = { 4400.000,2933.333, },
	['ThroneofTides'] = { 998.172,665.448, }, -- two floors same size
	['ThroneoftheFourWinds'] = { 1500.000,1000.000, },
	['ThunderBluff'] = { 1043.750,695.833, },
	['Tirisfal'] = { 4518.750,3012.500, },
	['TolBarad'] = { 2014.583,1343.750, },
	['TolBaradDailyArea'] = { 1837.500,1225.000, },
	['TwilightHighlands'] = { 5270.833,3514.583, },
	['TwinPeaks'] = { 1214.583,810.417, },
	['Uldaman'] = { 893.668,595.779, 492.570,328.380, },
	['Ulduar'] = { 3287.500,2191.667, 669.451,446.300, 1328.461,885.640, 910.500,607.000, 1569.460,1046.300, 619.469,412.980, },
	['Ulduar77'] = { 920.196,613.466, },
	['Uldum'] = { 6193.750,4129.167, },
	['Undercity'] = { 959.375,640.104, },
	['UngoroCrater'] = { 3700.000,2466.667, },
	['UtgardeKeep'] = { 734.581,489.722, 481.081,320.720, 736.581,491.055, },
	['UtgardePinnacle'] = { 548.936,365.957, 756.180,504.119, },
	['Vashjir'] = { 6945.833,4631.250, },
	['VashjirDepths'] = { 4075.000,2716.667, },
	['VashjirKelpForest'] = { 2802.083,1868.750, },
	['VashjirRuins'] = { 4850.000,3233.333, },
	['VaultofArchavon'] = { 1398.255,932.170, },
	['VioletHold'] = { 256.229,170.820, },
	['WailingCaverns'] = { 936.475,624.317, },
	['WarsongGulch'] = { 1145.833,764.583, },
	['WesternPlaguelands'] = { 4300.000,2866.667, },
	['Westfall'] = { 3500.000,2333.333, },
	['Wetlands'] = { 4135.417,2756.250, },
	['Winterspring'] = { 6150.000,4100.000, },
	['Zangarmarsh'] = { 5027.083,3352.083, },
	['ZulAman'] = { 1268.750,845.833, },
	['ZulDrak'] = { 4993.750,3329.167, },
	['ZulFarrak'] = { 1383.333,922.917, },
	['ZulGurub'] = { 2120.833,1414.583, },
	-- 4.3 patch
	['HourofTwilight'] = { 3043.762, 2029.162, 375,250, },
	['WellofEternity'] = { 1252.082, 833.334, },
	['EndTime'] = { 3295.854,2198,  562.5,375, 865.619,577.079, 475,316.7, 696.9,464.6, 453.135,302.093, }, 
	['DragonSoul'] = { 3106.708,2063.065, 397.5,265, 427.5,285, 185.2,123.5, 1.5,1, 1.5,1, 1108.352,739, },
	-- MoP
	['AmmenValeStart'] = { 1818.750,1212.500, },
	['AncientMoguCrypt'] = { 645.000,430.000, 335.500,223.667, },
	['CampNaracheStart'] = { 1766.668,1177.082, },
	['ColdridgeValley'] = { 964.583,643.750, },
	['DarkmoonFaireIsland'] = { 1858.333,1239.583, },
	['DeathknellStart'] = { 1089.584,727.083, },
	['DreadWastes'] = { 5352.083,3568.751, },
	['EastTemple'] = { 550.000,366.667, 198.000,132.000, },
	['HeartofFear'] = { 700.000,466.667, 1440.004,960.003, },
	['Krasarang'] = { 4687.501,3125.000, },
	['KunLaiPassScenario'] = { 970.833,647.917, },
	['KunLaiSummit'] = { 6258.333,4172.917, },
	['KunLaiSummitScenario'] = { 729.166,485.417, },
	['MogushanPalace'] = { 735.000,490.000, 540.000,360.000, 747.510,498.340, },
	['MogushanVaults'] = { 687.510,458.340, 432.510,288.340, 750.000,500.000, },
	['NewTinkertownStart'] = { 1850.000,1233.332, },
	['Northshire'] = { 968.750,645.834, },
	['ProvingGrounds'] = { 212.490,141.660, },
	['ScarletCathedral'] = { 343.020,228.680, 600.000,400.000, },
	['ScarletHalls'] = { 465.000,310.000, 468.000,312.000, },
	['ShadowglenStart'] = { 1450.001,966.667, },
	['ShadowpanHideout'] = { 310.000,206.667, 210.000,140.000, 390.000,260.000, },
	['SiegeofNiuzaoTemple'] = { 290.010,193.340, 290.010,193.340, },
	['StormstoutBrewery'] = { 260.001,173.334, 260.001,173.334, 340.000,226.667, 230.001,153.334, },
	['SunstriderIsleStart'] = { 1600.000,1066.667, },
	['TempleofKotmogu'] = { 839.583,560.416, },
	['TerraceOfEndlessSpring'] = { 702.084,468.750, },
	['TheGreatWall'] = { 1300.000,866.667, 222.520,148.347, },
	['TheHiddenPass'] = { 1793.750,1195.833, },
	['TheJadeForest'] = { 6983.333,4654.167, },
	['TheJadeForestScenario'] = { 925.000,616.667, },
	['TheWanderingIsle'] = { 2670.833,1779.167, },
	['ThunderKingRaid'] = { 1285.0,856.667, 1550.010,1033.340, 1030.0,686.667, 591.280,394.187, 1030.0,686.667, 910.0,606.667, 810.0,540.0, 617.5,411.667, },
	['TownlongWastes'] = { 5743.749,3829.166, },
	['Tyrivess'] = { 2683.333,1789.582, },
	['ValeofEternalBlossoms'] = { 2533.334,1687.501, },
	['ValleyOfPowerScenario'] = { 839.583,560.416, },
	['ValleyofTrialsStart'] = { 1350.000,900.000, },
	['ValleyoftheFourWinds'] = { 3925.001,2616.667, },
}]]

local AOEM = Grid2:GetModule("Grid2AoeHeals")
local MapLib = LibStub("LibMapData-1.0")

local GetMapInfo = GetMapInfo
local SetMapToCurrentZone = SetMapToCurrentZone
local GetPlayerMapPosition = GetPlayerMapPosition
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local strfind,strsub = strfind, strsub

local frame, curMap, curFloor, curMapWidth, curMapHeight

--local function GetMapTable(mapName)
--	local map = Maps[mapName]
--	if not map then
--		local index = strfind( mapName,"_terrain%d")  -- maybe its is a phased zone, format: "mapname_terrain%d"
--		if index then
--			map = Maps[ strsub(mapName,1,index-1) ]  -- remove "_terrain%d" from de map name
--		end
--	end
--	return map
--end

--local function GetMapSize( mapName,floorIndex )
--	local map = GetMapTable( mapName )
--	if map then
--		local index = (floorIndex and floorIndex>0 and (floorIndex-1)*2) or 0
--		if index>=#map then	index = 0 end
--		return map[index+1], map[index+2]
--	end
--end

local function ZoneChanged()
	if not WorldMapFrame:IsVisible() then 
		SetMapToCurrentZone()
		local x,y = GetPlayerMapPosition("player")
		if x ~= 0 or y ~= 0 then
			local newMap = GetMapInfo()
			if newMap then
				local newFloor = GetCurrentMapDungeonLevel()
				if newMap ~= curMap or newFloor ~= curFloor then
					curMap, curFloor = newMap, newFloor
					curMapWidth, curMapHeight = MapLib:MapArea(newMap, newFloor)
					AOEM:Debug("Zone changed:", curMap, curFloor, curMapWidth, curMapHeight)
				end
				return
			end	
		end	
		curMapWidth, curMapHeight = nil, nil	
	end
end

--{{ Public methods

-- Enable zone change tracking
function AOEM:MapEnable()
	if not frame then
		frame = CreateFrame("Frame") 
		frame:SetScript("OnEvent", ZoneChanged )
	end
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ZONE_CHANGED")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("ZONE_CHANGED_INDOORS")
	ZoneChanged()
end

-- Disable zone change tracking
function AOEM:MapDisable()
	if frame then frame:UnregisterAllEvents() end
end

-- Returns current zone width and height
function AOEM:MapGetSize()
	if curFloor ~= GetCurrentMapDungeonLevel() then 
		ZoneChanged()  -- Seems WOW does not call ZoneChanged when floor changes
	end
	return curMapWidth, curMapHeight
end
--}}

--[[ 
-- Code to calculate map size using mage 20 yards blink.
-- Uncomment the code, take a mage, find a plain floor on the map, face north/south or west/east, 
-- start move, adjust carefully player direction until error disappear, then blink
do	
	local t,z,w = 0,0,0
	CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)
		t = t + elapsed
		if t<0.25 then return end
		t = 0
		SetMapToCurrentZone()
		local x,y = GetPlayerMapPosition("player")
		if x ~= 0 and y ~= 0 and z ~= 0 and w ~= 0 then
			local dx,dy,dd = math.abs(x-z), math.abs(y-w), true
			if dy>dx then dx,dy,dd = dy,dx,false end
			if dx>0 then
				local err= dy/dx
				if err<0.005 then
					print( string.format("Map [%s] Floor [%d] Estimated %s: [%.12f] yards Err: %.12f", (GetMapInfo()), GetCurrentMapDungeonLevel(), dd and "width" or "height", 20/dx, err) )
				else
					print( string.format( "Map [%s] Floor [%d] Adjust player direction, Err: %.12f", (GetMapInfo()), GetCurrentMapDungeonLevel(), err ) )
				end	
			end	
		else
			print("No valid map", x , y)
		end
		z,w = x,y
	end)
end
--]]
