local addon = DXE
local L = addon.L
local name_to_unit = addon.Roster.name_to_unit
local name_to_class = addon.Roster.name_to_class

local window
local pfl

---------------------------------------
-- BARS
---------------------------------------
local bars = {}
local bar_pool = {}

local function Destroy(self)
	self.destroyed = true
	self:Hide()
	self.curr = nil
	self.lastd = nil
	self.dblank = true
	self.left:SetText("")
	self.right:SetText("")
	self.statusbar:SetValue(1)
end

local function CreateBar()
	local bar = CreateFrame("Frame",nil,window.content)
	bar:Hide()

	local icon = bar:CreateTexture(nil,"ARTWORK")
	icon:SetTexture("Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes")
	bar.icon = icon

	local statusbar = CreateFrame("StatusBar",nil,bar)
	statusbar:SetMinMaxValues(0,1)
	addon:RegisterStatusBar(statusbar)
	bar.statusbar = statusbar

	local name = statusbar:CreateFontString(nil,"ARTWORK")
	name:SetShadowOffset(1,-1)
	addon:RegisterFontString(name,pfl.Proximity.NameFontSize)
	bar.name = name

	-- format "%d".."%02d"
	--         ^     ^
	--         left  right

	local left = statusbar:CreateFontString(nil,"ARTWORK")
	left:SetShadowOffset(1,-1)
	addon:RegisterFontString(left,pfl.Proximity.TimeFontSize)
	bar.left = left

	local right = statusbar:CreateFontString(nil,"ARTWORK")
	right:SetPoint("BOTTOMLEFT",left,"BOTTOMRIGHT")
	right:SetShadowOffset(1,-1)
	addon:RegisterFontString(right,pfl.Proximity.TimeFontSize * 2/3)
	bar.right = right

	bar.Destroy = Destroy

	return bar
end

local function GetBar()
	local bar = next(bar_pool)
	if not bar then
		return CreateBar()
	else
		bar_pool[bar] = nil
		return bar
	end
end

---------------------------------------
-- SETTERS
--------------------------------------
local rows

local function UpdateBars()
	local content = window.content
	local width = content:GetWidth()
	local height = content:GetHeight()/rows
	for i,bar in ipairs(bars) do
		local r,g,b = bar.statusbar:GetStatusBarColor()
		bar.statusbar:SetStatusBarColor(r,g,b,pfl.Proximity.BarAlpha)
		bar.name:SetFont(bar.name:GetFont(),pfl.Proximity.NameFontSize)
		bar.left:SetFont(bar.left:GetFont(),pfl.Proximity.TimeFontSize)
		bar.right:SetFont(bar.right:GetFont(),pfl.Proximity.TimeFontSize * 2/3)

		bar:SetWidth(width)
		bar:SetHeight(height)
		bar:SetPoint("TOP",content,"TOP",0,-(i-1)*height)
		bar.icon:SetWidth(height-2)
		bar.icon:SetHeight(height-2)
		bar.statusbar:SetHeight(height-2)

		bar.name:ClearAllPoints()
		bar.name:SetPoint(pfl.Proximity.NameAlignment,pfl.Proximity.NameOffset,0)
		bar.left:ClearAllPoints()
		bar.left:SetPoint("RIGHT",pfl.Proximity.TimeOffset,0)

		bar.icon:ClearAllPoints()
		bar.statusbar:ClearAllPoints()
		if pfl.Proximity.IconPosition == "LEFT" then
			bar.icon:SetPoint("LEFT",bar,"LEFT",2,0)
			bar.statusbar:SetPoint("LEFT",bar.icon,"RIGHT")
			bar.statusbar:SetPoint("RIGHT",bar,"RIGHT")
		elseif pfl.Proximity.IconPosition == "RIGHT" then
			bar.icon:SetPoint("RIGHT",bar,"RIGHT",-2,0)
			bar.statusbar:SetPoint("RIGHT",bar.icon,"LEFT")
			bar.statusbar:SetPoint("LEFT",bar,"LEFT")
		end
	end
end

local function UpdateRows()
	for i=1,rows do
		if not bars[i] then
			bars[i] = GetBar()
		end
	end

	for i=rows+1,#bars do
		local bar = bars[i]
		bar:Destroy()
		bar_pool[bar] = true
		bars[i] = nil
	end
end

---------------------------------------
-- WINDOW CREATION
--------------------------------------
local ProximityFuncs = addon:GetProximityFuncs()
local range -- yds
local invert
local delay
local rangefunc -- proximity function

local OnUpdate
local counter = 0

do
	local ICON_COORDS = {}
	local e = 0.02
	for class,coords in pairs(CLASS_ICON_TCOORDS) do
		local l,r,t,b = unpack(coords)
		ICON_COORDS[class] = {l+e,r-e,t+e,b-e}
	end

	local unpack,select = unpack,select
	local CN = addon.CN
	local RAID_CLASS_COLORS = RAID_CLASS_COLORS
	local floor = math.floor

	function OnUpdate(_,elapsed)
		if delay > 0 then
			counter = counter + elapsed
			if counter < delay then return end
		end
		counter = 0
		local n = 0
		for name in pairs(name_to_unit) do
			-- Use CheckInteractDistance (rangefunc) to take the z-axis into account
			local class = name_to_class[name]
			if name ~= addon.PNAME and rangefunc(name) and pfl.Proximity.ClassFilter[class] then
				local d = addon:GetDistanceToUnit(name)
				local flag = true
				if d and d > range then flag = false end
				if flag then
					n = n + 1
					local bar = bars[n]
					if not bar then break
					elseif bar.curr ~= name then
						bar.curr = name
						bar.name:SetText(CN[name])
						bar.icon:SetTexCoord(unpack(ICON_COORDS[class]))
						local c = RAID_CLASS_COLORS[class]
						bar.statusbar:SetStatusBarColor(c.r,c.g,c.b,pfl.Proximity.BarAlpha)
						bar.destroyed = nil
						bar:Show()
					end
					if d then
						if d ~= bar.lastd then
							local perc = d / range
							bar.statusbar:SetValue(invert and (1-perc) or perc)
							local sec = floor(d)
							bar.left:SetFormattedText("%d",sec)
							bar.right:SetFormattedText("%02d",100*(d - sec))
							bar.dblank = nil
							bar.lastd = d
						end
					elseif not bar.dblank then
						bar.left:SetText("")
						bar.right:SetText("")
						bar.statusbar:SetValue(1)
						bar.dblank = true
						bar.lastd = nil
					end
				end
			end
		end
		for i=n+1,#bars do
			local bar = bars[i]
			if pfl.Proximity.Dummy then
				bar.name:SetText("Abracadabrah")
				bar.icon:SetTexCoord(unpack(ICON_COORDS["WARRIOR"]))
				local c = RAID_CLASS_COLORS["WARRIOR"]
				bar.statusbar:SetStatusBarColor(c.r,c.g,c.b,pfl.Proximity.BarAlpha)
				bar.destroyed = nil
				bar.left:SetFormattedText("%d",15)
				bar.right:SetFormattedText("%02d",75)
				bar:Show()
			else
				if not bar.destroyed then bar:Destroy() end
			end
		end
	end
end

local function UpdateTitle()
	window:SetTitle(format("%s - %d",L["Proximity"],range))
end

local function OpenOptions()
	addon:ToggleConfig()
	if not addon.Options then return end
	if LibStub("AceConfigDialog-3.0").OpenFrames.DXE then LibStub("AceConfigDialog-3.0"):SelectGroup("DXE","windows_group","proximity_group") end
end

local function OnShow(self)
	counter = 0
end

local function OnHide(self)
	for i,bar in ipairs(bars) do bar:Destroy() end
end

local function CreateWindow()
	window = addon:CreateWindow(L["Proximity"],110,100)
	window:Hide()
	window:SetContentInset(1)
	local content = window.content

	window:RegisterCallback("OnSizeChanged",UpdateBars)

	window:SetScript("OnUpdate",OnUpdate)
	window:SetScript("OnShow",OnShow)
	window:SetScript("OnHide",OnHide)

	window:AddTitleButton("Interface\\AddOns\\DXE\\Textures\\Pane\\Menu.tga",OpenOptions,L["Options"])
	addon:UpdateProximitySettings()

	window:Show()
	CreateWindow = nil
end

---------------------------------------
-- API
---------------------------------------

function addon:Proximity(popup,enc_range)
	if popup and not pfl.Proximity.AutoPopup then return end
	if window then window:Show()
	else CreateWindow() end
	range = enc_range or pfl.Proximity.Range
	UpdateTitle()
end

function addon:HideProximity()
	if window then window:Hide() end
end

addon:RegisterWindow(L["Proximity"],function() addon:Proximity() end)

---------------------------------------
-- SETTINGS
---------------------------------------

function addon:UpdateProximitySettings()
	addon:HideRadar()
	rows = pfl.Proximity.Rows
	range = pfl.Proximity.Range
	delay = pfl.Proximity.Delay
	invert = pfl.Proximity.Invert
	rangefunc = range <= 10 and ProximityFuncs[10] or (range <= 11 and ProximityFuncs[11] or ProximityFuncs[18])

	if window then
		UpdateTitle()
		UpdateRows()
		UpdateBars()
	end
end

local function RefreshProfile(db)
	pfl = db.profile
	addon:UpdateProximitySettings()
end
addon:AddToRefreshProfile(RefreshProfile)
