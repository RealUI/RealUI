--------------------------------------------
--[[
DXE Radar - a graphical proximity check.
Some of the code is straight from BigWigs. Many thanks and credits to them.
This textures used are copyright BigWigs: alert_circle.blp and dot.tga
]]
--------------------------------------------
local addon = DXE
local L = addon.L
local name_to_unit = addon.Roster.name_to_unit
local name_to_class = addon.Roster.name_to_class

local window
local pfl

--Radial upvalues
local GetPlayerMapPosition = GetPlayerMapPosition
local GetPlayerFacing = GetPlayerFacing
local format = string.format
local UnitInRange = UnitInRange
local UnitIsDead = UnitIsDead
local UnitIsUnit = UnitIsUnit
local UnitClass = UnitClass
local GetTime = GetTime
local min = math.min
local pi = math.pi
local cos = math.cos
local sin = math.sin
local tremove = table.remove
local unpack = unpack
local activeMap

local configmode = false

local titleHeight = 12
local titleBarInset = 2

local DOTSIZE
local ICONBEHAVE

---------------------------------------
-- UTILITY
---------------------------------------
local function RadarSize()

	if window then
		local content = window.content
		local container = window.container
		local faux_window = window.faux_window
		container:ClearAllPoints()
		container:SetPoint("TOPLEFT",faux_window,"TOPLEFT",1,-titleHeight-titleBarInset)
		container:SetPoint("BOTTOMRIGHT",faux_window,"BOTTOMRIGHT",-1,1)
		container:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)
		window:SetContentInset(1)
		content:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)

		local scale = faux_window:GetScale()
		local range = pfl.Proximity.Range
		local w,h = content:GetSize()
		local ppy = min(w, h) / (range * 3)
		content.rangeCircle:SetSize(ppy * range * 2 * scale, ppy * range * 2 * scale)
	end
end
local function OnSize(...)
	if window then
		RadarSize()
		if configmode then
			testDots()
		end
	end
	return true
end

local hexColors = {}
local vertexColors = {}
for k, v in pairs(RAID_CLASS_COLORS) do
	hexColors[k] = ("|cff%02x%02x%02x"):format(v.r * 255, v.g * 255, v.b * 255)
	vertexColors[k] = { v.r, v.g, v.b }
end
local mapData = {
	StormwindCity = {
		{ 1737.499958992, 1158.3330078125},
	},
	Orgrimmar = {
		{ 1739.375, 1159.58349609375 },
	},
	TheBastionofTwilight = {
		{ 1078.33499908447, 718.889984130859 },
		{ 778.343017578125, 518.894958496094 },
		{ 1042.34202575684, 694.894958496094 },
	},
	BaradinHold = {
		{ 585.0, 390.0 },
	},
	BlackwingDescent = {
		{ 849.69401550293, 566.462341070175 },
		{ 999.692977905273, 666.462005615234 },
	},
	ThroneoftheFourWinds = {
		{ 1500.0, 1000.0 },
	},
	Firelands = {
		{ 1587.49993896484, 1058.3332824707 },
		{ 375.0, 250.0 },
		{ 1440.0, 960.0 },
	},
	DragonSoul = {
		{ 3106.7084960938, 2063.0651855469 },
		{ 397.49887572464, 264.99992263558 },
		{ 427.50311666243, 285.00046747363 },
		{ 185.19921875, 123.466796875 },
		{ 1.5, 1 },
		{ 1.5, 1 },
		{ 1108.3515625, 738.900390625 },
	},
	MogushanVaults = {
		{ 687.509765625, 458.33984375 },
		{ 432.509765625, 288.33984375 },
		{ 750.0, 500.0 },
	},
	HeartofFear = {
		{ 700.0, 466.666748046875 },
		{ 1440.0043802261353, 960.0029296875 },
	},
	TerraceOfEndlessSpring = {
		{ 702.083984375, 468.75 },
	},
	ThunderKingRaid = { 
		{ 1285.0, 856.6669921875 },
		{ 1550.009765625, 1033.33984375 },
		{ 1030.0, 686.6669921875 },
		{ 591.280029296875, 394.18701171875 },
		{ 1030.0, 686.6669921875 },
		{ 910.0, 606.6669921875 },
		{ 810.0, 540.0 },
		{ 617.5, 411.6669921875 },
	},
	--[[ThunderKingRaid = {
		{ 1285,856.6669921875 },
		{ 1550.009765625,1033.33984375 },
		{ 1030,686.6669921875 },
		{ 591.28002929688,394.18701171875 },
		{ 1030,686.6669921875 },
		{ 617.5,411.6669921875 },
		{ 910,606.6669921875 },
		{ 810,540 },
	},--]]
}

---------------------------------------
-- BARS
---------------------------------------
local bars = {}
local bar_pool = {}

---------------------------------------
-- WINDOW CREATION
--------------------------------------
local ProximityFuncs = addon:GetProximityFuncs()
local range -- yds
local invert
local delay
local rangefunc -- proximity function

local OnUpdate


local function OnShow(self)
	counter = 0
end

local function OnHide(self)
	for i,bar in ipairs(bars) do return true end
end

local function UpdateTitle()
	window:SetTitle(format("%s - %d",L["Radar"],range))
end

local function OpenOptions()
	addon:ToggleConfig()
	if not addon.Options then return end
	if LibStub("AceConfigDialog-3.0").OpenFrames.DXE then LibStub("AceConfigDialog-3.0"):SelectGroup("DXE","windows_group","proximity_group") end
end

local RadarDropDownMenu = CreateFrame("Frame", "RadarDropDownMenu")
RadarDropDownMenu.displayMode = "MENU"
RadarDropDownMenu.info = {}
RadarDropDownMenu.UncheckHack = function(dropdownbutton)
    _G[dropdownbutton:GetName().."Check"]:Hide()
end
RadarDropDownMenu.HideMenu = function()
    if UIDROPDOWNMENU_OPEN_MENU == RadarDropDownMenu then
        CloseDropDownMenus()
    end
end

RadarDropDownMenu.initialize = function(self, level)
    if not level then return end
    local info = self.info
    wipe(info)
    if level == 1 then
        info.isTitle = 1
        info.text = "Radar"
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        info.keepShownOnClick = 1
        info.disabled = nil
        info.isTitle = nil
        info.notCheckable = nil

        info.text = "Range"
        info.func = self.UncheckHack
        info.hasArrow = 1
		info.isNotRadio = 1
		info.notCheckable = true
        info.value = "submenu1"
        UIDropDownMenu_AddButton(info, level)

        --info.text = "Wxyz" -- Note .hasArrow and .func fallthrough from prev item.
        --info.value = "submenu2"
        --UIDropDownMenu_AddButton(info, level)

        -- Close menu item
        info.hasArrow     = nil
        info.value        = nil
        info.notCheckable = 1
        info.text         = CLOSE
        info.func         = self.HideMenu
        UIDropDownMenu_AddButton(info, level)

    elseif level == 2 then
        if UIDROPDOWNMENU_MENU_VALUE == "submenu1" then
            info.text = "2 yards"
			info.func = function()
				pfl.Proximity.Range = 2
				addon:UpdateProximityProfile()
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 2)

            UIDropDownMenu_AddButton(info, level)

            info.text = "3 yards"
			info.func = function()
				pfl.Proximity.Range = 3
				addon:UpdateProximityProfile()
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 3)
            UIDropDownMenu_AddButton(info, level)

            info.text = "4 yards"
			info.func = function()
				pfl.Proximity.Range = 4
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 4)
            UIDropDownMenu_AddButton(info, level)
			
            info.text = "5 yards"
			info.func = function()
				pfl.Proximity.Range = 5
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 5)
            UIDropDownMenu_AddButton(info, level)
			
            info.text = "6 yards"
			info.func = function()
				pfl.Proximity.Range = 6
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 6)
            UIDropDownMenu_AddButton(info, level)
			
            info.text = "8 yards"
			info.func = function()
				pfl.Proximity.Range = 8
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 8)
            UIDropDownMenu_AddButton(info, level)
			
            info.text = "10 yards"
			info.func = function()
				pfl.Proximity.Range = 10
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 10)
            UIDropDownMenu_AddButton(info, level)
			
            info.text = "12 yards"
			info.func = function()
				pfl.Proximity.Range = 12
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 12)
            UIDropDownMenu_AddButton(info, level)
			
            info.text = "15 yards"
			info.func = function()
				pfl.Proximity.Range = 15
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 15)
            UIDropDownMenu_AddButton(info, level)
			
            info.text = "18 yards"
			info.func = function()
				pfl.Proximity.Range = 18
				addon:UpdateProximityProfile() 
				RadarDropDownMenu.HideMenu()
			end
			info.checked = (pfl.Proximity.Range == 18)
            UIDropDownMenu_AddButton(info, level)
			
			
			
       --[[ elseif UIDROPDOWNMENU_MENU_VALUE == "submenu2" then
            info.text = "Moo"
            UIDropDownMenu_AddButton(info, level)

            info.text = "Lar"
            UIDropDownMenu_AddButton(info, level)
--]]
        end
    end
end

local function CreateWindow()
	window = addon:CreateWindow(L["Radar"],150,150)
	window:SetMinResize(100, 30)
	window:SetClampedToScreen(true)
	window:Hide()
	window:SetContentInset(1)

	window:RegisterCallback("OnSizeChanged",OnSize)
	window:RegisterCallback("OnScaleChanged",OnSize)
	window:SetScript("OnUpdate",OnUpdate)
	window:SetScript("OnShow",OnShow)
	window:SetScript("OnHide",OnHide)

	window:AddTitleButton("Interface\\AddOns\\DXE\\Textures\\Pane\\Menu.tga",OpenOptions,L["Options"])

	window:SetScript("OnMouseUp", function(self, btn)
        if btn == "RightButton" then
			ToggleDropDownMenu(1, nil, RadarDropDownMenu, 'cursor', 0, 0)
		end
	end)
	local faux_window = window.faux_window
	local container = window.container
	container:ClearAllPoints()
	container:SetPoint("TOPLEFT",faux_window,"TOPLEFT",1,-titleHeight-titleBarInset)
	container:SetPoint("BOTTOMRIGHT",faux_window,"BOTTOMRIGHT",-1,1)
	container:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)

	local content = window.content
	content:SetSize(faux_window:GetWidth()-1,faux_window:GetHeight()-titleHeight-titleBarInset)

	local rangeCircle = window:CreateTexture(nil, "ARTWORK", content)
	rangeCircle:SetTexture([[Interface\AddOns\DXE\Textures\alert_circle]])
	rangeCircle:SetPoint("CENTER",content)
	rangeCircle:SetBlendMode("ADD")
	local scale = faux_window:GetScale()
	local range = pfl.Proximity.Range
	local w,h = content:GetSize()
	local ppy = min(w, h) / (range * 3)
	rangeCircle:SetSize(ppy * range * 2 * scale, ppy * range * 2 * scale)
	content.rangeCircle = rangeCircle

	local playerDot = window:CreateTexture(nil, "OVERLAY", content)
	playerDot:SetTexture([[Interface\Minimap\MinimapArrow]])
	playerDot:SetSize(32, 32)
	playerDot:SetBlendMode("ADD")
	playerDot:SetPoint("CENTER",content)
	content.playerDot = playerDot

	window:Show()
	CreateWindow = nil

	addon:UpdateRadarSettings()
end

---------------------------------------
-- UPDATER
--------------------------------------

local updater = nil
local graphicalUpdater = nil

do
	local proxDots = {}
	local cacheDots = {}
	local cacheIcons = {}

	function addon:DotResize(dotsize)
		DOTSIZE = dotsize
		if cacheDots then
			for i=1,#cacheDots do
				cacheDots[i]:SetSize(DOTSIZE,DOTSIZE)
			end
		end
		if proxDots then
			for i=1,#proxDots do
				proxDots[i]:SetSize(DOTSIZE,DOTSIZE)
			end
		end
		if cacheIcons then
			for i=1,8 do
				if cacheIcons[i] then
					cacheIcons[i]:SetSize(DOTSIZE,DOTSIZE)
				end
			end
		end

	end

	function addon:dotter()
		if window then
			if not configmode then
				window:SetScript("OnUpdate",nil)
				testDots()
				configmode = true
			else
				window:SetScript("OnUpdate",OnUpdate)
				hideDots()
				window.content.rangeCircle:SetVertexColor(0, 1, 0)
				configmode = false
			end
		end
	end

	--local lastplayed = 0 -- When we last played an alarm sound for proximity.

	-- dx and dy are in yards
	-- class is player class
	-- facing is radians with 0 being north, counting up clockwise
	setDot = function(dx, dy, class, icon)
		local content = window.content
		local width, height = content:GetSize()
		-- range * 3, so we have 3x radius space
		local pixperyard = min(width, height) / (range * 3)

		-- rotate relative to player facing
		local rotangle = (2 * pi) - GetPlayerFacing()
		local x = (dx * cos(rotangle)) - (-1 * dy * sin(rotangle))
		local y = (dx * sin(rotangle)) + (-1 * dy * cos(rotangle))

		x = x * pixperyard
		y = y * pixperyard

		local dot = nil
		if #cacheDots > 0 then
			dot = tremove(cacheDots)
		else
			dot = content:CreateTexture(nil, "OVERLAY")
			dot:SetSize(DOTSIZE,DOTSIZE)
			dot:SetTexture([[Interface\AddOns\DXE\Textures\dot]])
		end
		proxDots[#proxDots + 1] = dot

		dot:ClearAllPoints()
		dot:SetPoint("CENTER", content, "CENTER", x, y)
		dot:SetVertexColor(unpack(vertexColors[class]))
		dot:Show()

		-- add icon if marked
		if icon and icon > 0 and icon < 9 and ICONBEHAVE ~= "NONE" then
			if not cacheIcons[icon] then
				local iconframe = content:CreateTexture(nil, "OVERLAY")
				iconframe:SetTexture(format([[Interface\TARGETINGFRAME\UI-RaidTargetingIcon_%d.blp]], icon))
				iconframe:SetSize(DOTSIZE,DOTSIZE)
				cacheIcons[icon] = iconframe
			end
			local iconframe = cacheIcons[icon]
			iconframe:ClearAllPoints()
			iconframe:SetPoint("CENTER", content, "CENTER", x, y)
			iconframe:SetDrawLayer("OVERLAY", 1)
			if ICONBEHAVE == "ABOVE" then
				iconframe:Show()
			elseif ICONBEHAVE == "REPLACE" then
				dot:Hide()
				iconframe:Show()
			end
		end
	end

	hideDots = function()
		-- shuffle existing dots into cacheDots
		-- hide those cacheDots
		while #proxDots > 0 do
			proxDots[1]:Hide()
			cacheDots[#cacheDots + 1] = tremove(proxDots, 1)
		end
		-- hide marks
		for i=1,8 do
			if cacheIcons[i] then
				cacheIcons[i]:Hide()
			end
		end
	end

	testDots = function()
		local content = window.content
		hideDots()
		setDot(8, 4, "WARLOCK", 0)
		setDot(2, 10, "HUNTER", 0)
		setDot(-10, -4, "MAGE", 7)
		setDot(0, -8, "PRIEST", 0)
		RadarSize()
		content.rangeCircle:SetVertexColor(1,0,0)
		content.rangeCircle:Show()
		content.playerDot:Show()
	end

	local function updateProximityRadar()
		local content = window.content
		local srcX, srcY = GetPlayerMapPosition("player")
		if srcX == 0 and srcY == 0 then
			SetMapToCurrentZone()
			srcX, srcY = GetPlayerMapPosition("player")
		end

		-- XXX This could probably be checked and set when the proximity
		-- XXX display is opened? We won't change dungeon floors while
		-- XXX it is open, surely.
		local id = nil
		if activeMap then
			local currentFloor = GetCurrentMapDungeonLevel()
			if currentFloor == 0 then currentFloor = 1 end
			id = activeMap[currentFloor]
		end

		local anyoneClose = nil

		-- XXX We can't show/hide dots every update, that seems excessive.
		hideDots()
		for i = 1, GetNumGroupMembers() do
			local n = format("raid%d", i)
			local class = select(2,UnitClass(n))
			if pfl.Proximity.ClassFilter[class] then -- Mop Added
				if UnitInRange(n) and not UnitIsDead(n) and not UnitIsUnit(n, "player") then
					local unitX, unitY = GetPlayerMapPosition(n)
					local dx = (unitX - srcX) * id[1]
					local dy = (unitY - srcY) * id[2]
					local prange = (dx * dx + dy * dy) ^ 0.5
					if prange < (range * 1.5) then
						local _,class= UnitClass(n)
						setDot(dx, dy, class, GetRaidTargetIndex(n))
						if prange <= range*1.1 then
							anyoneClose = true
						end
					end
				end
			end
		end
--[[
		-- party stuff for test
		if UnitInParty("player") then
			for i= 1, GetNumSubgroupMembers() do
				local n = format("party%d", i)
				if UnitInRange(n) and not UnitIsDead(n) and not UnitIsUnit(n, "player") then
					local unitX, unitY = GetPlayerMapPosition(n)
					local dx = (unitX - srcX) * id[1]
					local dy = (unitY - srcY) * id[2]
					local prange = (dx * dx + dy * dy) ^ 0.5
					if prange < (range * 1.5) then
						local _,class= UnitClass(n)
						setDot(dx, dy, class, GetRaidTargetIndex(n))
						if prange <= range*1.1 then  -- add 10% because of mapData inaccuracies, e.g. 6 yards actually testing for 5.5 on chimaeron = ouch
							anyoneClose = true
						end
					end
				end
			end
		end
		--@end-debug@]
--]]
		if not anyoneClose then
			--lastplayed = 0
			content.rangeCircle:SetVertexColor(0, 1, 0)
		else
			content.rangeCircle:SetVertexColor(1, 0, 0)
		end
	end

	local counter = 0
	local delay = 0.05

	-- 20x per second for radar mode
	function OnUpdate(self, elapsed)
		if delay > 0 then
			counter = counter + elapsed
			if counter < delay then return end
		end
		counter = 0
		updateProximityRadar()
	end
end


---------------------------------------
-- API
---------------------------------------

function addon:Radar(popup,enc_range)
	if popup and not pfl.Proximity.AutoPopup then return end
	if window then window:Show()
	else CreateWindow() end
	range = enc_range or pfl.Proximity.Range
	UpdateTitle()
	SetMapToCurrentZone()
	activeMap = mapData[(GetMapInfo())]
	--activeMap = addon:ReturnMapData() --[(GetMapInfo())]
	if activeMap then
		RadarSize()
		local content = window.content
		content.playerDot:Show()
		content.rangeCircle:Show()
	end
end

function addon:HideRadar()
	if window then window:Hide() end
end

addon:RegisterWindow(L["Radar"],function() addon:Radar() end)

---------------------------------------
-- SETTINGS
---------------------------------------

function addon:UpdateRadarSettings()
	addon:HideProximity()
	rows = pfl.Proximity.Rows
	range = pfl.Proximity.Range
	delay = pfl.Proximity.Delay
	invert = pfl.Proximity.Invert
	DOTSIZE = pfl.Proximity.DotSize
	ICONBEHAVE = pfl.Proximity.RaidIcons
	rangefunc = range <= 10 and ProximityFuncs[10] or (range <= 11 and ProximityFuncs[11] or ProximityFuncs[18])

	if window then
		UpdateTitle()
		RadarSize()
		addon:DotResize(DOTSIZE)
		if (pfl.Proximity.Dummy and not configmode) or (not pfl.Proximity.Dummy and configmode) then
			addon:dotter()
		elseif pfl.Proximity.Dummy and configmode then --bad hack
			addon:dotter()
			addon:dotter()
		end
	end
end

local function RefreshProfile(db)
	pfl = db.profile
	addon:UpdateRadarSettings()
end
addon:AddToRefreshProfile(RefreshProfile)
