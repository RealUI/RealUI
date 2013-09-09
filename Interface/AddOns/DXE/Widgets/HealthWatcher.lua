-- Skinning is done externally
local addon = DXE

local HealthWatcher,prototype = {},{}
local MarkerCache = {}
DXE.HealthWatcher = HealthWatcher

local UnitHealth,UnitHealthMax = UnitHealth,UnitHealthMax
local UnitPower,UnitPowerMax,UnitPowerType = UnitPower,UnitPowerMax,UnitPowerType
local PowerBarColor = PowerBarColor
local UnitIsDead = UnitIsDead
local format = string.format
local DEAD = DEAD:upper()

-- Markers
local MarkerWidth = 1.5
local MarkerHeight = 20
local MarkerColor = {1, 0, 0, 0.5}
local TestMarker1 = {70, 25}
--ShowMarkers = true,

function HealthWatcher:New(parent)
	local hw = CreateFrame("Button",nil,parent)
	-- Embed
	for k,v in pairs(prototype) do hw[k] = v end
	hw.events = {}

	hw:SetWidth(220); hw:SetHeight(22)
	addon:RegisterBackground(hw,true)

	local healthbar = CreateFrame("StatusBar",nil,hw)
	healthbar:SetMinMaxValues(0,1)
	healthbar:SetPoint("TOPLEFT",2,-2)
	healthbar:SetPoint("BOTTOMRIGHT",-2,2)
	addon:RegisterStatusBar(healthbar)
	hw.healthbar = healthbar

--	if markers and type(markers) == "table" then
--		prototype:HandleMarkers(nil, hw, TestMarker1)
--	end
	
	local powerbar = CreateFrame("StatusBar",nil,hw)
	powerbar:SetMinMaxValues(0,1)
	powerbar:SetPoint("BOTTOMLEFT",healthbar,"BOTTOMLEFT")
	powerbar:SetPoint("BOTTOMRIGHT",healthbar,"BOTTOMRIGHT")
	powerbar:SetHeight(5)
	powerbar:SetFrameLevel(healthbar:GetFrameLevel()+1)
	powerbar:Hide()
	addon:RegisterStatusBar(powerbar)
	hw.powerbar = powerbar
	
	local border = CreateFrame("Frame",nil,hw)
	border:SetAllPoints(true)
	border:SetFrameLevel(healthbar:GetFrameLevel()+2)
	addon:RegisterBorder(border)
	hw.border = border

	-- parent for font strings so they appears above powerbar
	local region = CreateFrame("Frame",nil,healthbar)
	region:SetAllPoints(true)
	region:SetFrameLevel(healthbar:GetFrameLevel()+10)

	-- Add title text
	title = region:CreateFontString(nil,"ARTWORK")
	title:SetPoint("LEFT",healthbar,"LEFT",2,0)
	title:SetShadowOffset(1,-1)
	addon:RegisterFontString(title,10)
	hw.title = title

	-- Add health text
	health = region:CreateFontString(nil,"ARTWORK")
	health:SetPoint("RIGHT",healthbar,"RIGHT",-2,0)
	health:SetShadowOffset(1,-1)
	addon:RegisterFontString(health,12)
	hw.health = health

	local tracer = addon.Tracer:New()
	tracer:SetCallback(hw,"TRACER_UPDATE")
	tracer:SetCallback(hw,"TRACER_LOST")
	tracer:SetCallback(hw,"TRACER_ACQUIRED")
	hw.tracer = tracer

	return hw
end

--------------------------
-- PROTOTYPE
--------------------------

function prototype:SetCallback(event, func) self.events[event] = func end
function prototype:Fire(event, ...) if self.events[event] then self.events[event](self,event,...) end end
function prototype:Track(trackType,goal) self.tracer:Track(trackType,goal) end
function prototype:SetTitle(text) self.title:SetText("   "..text) end
function prototype:IsTitleSet() return self.title:GetText() ~= "..." end
function prototype:GetGoal() return self.tracer.goal end
function prototype:EnableUpdates() self.updates = true end
function prototype:SetNeutralColor(color) self.nr,self.ng,self.nb = unpack(color) end
function prototype:SetLostColor(color) self.lr,self.lg,self.lb = unpack(color) end

function prototype:ApplyNeutralColor() 
	self.healthbar:SetStatusBarColor(self.nr,self.ng,self.nb) 
	if not self.powercolor and self.power then self.powerbar:SetStatusBarColor(self.nr,self.ng,self.nb) end
end

function prototype:ApplyLostColor()
	self.healthbar:SetStatusBarColor(self.lr,self.lg,self.lb) 
	if not self.powercolor and self.power then self.powerbar:SetStatusBarColor(self.lr,self.lg,self.lb) end
end

function prototype:IsOpen() return self.tracer:IsOpen() end

function prototype:ShowPower()
	self.power = true
	self.powerbar:Show()
	self.powercolor = nil
end
function prototype:ShowMarker(hw,markers)
	--if markers and type(markers) == "table" then
	--print("sdf")
	--[[
		if i == 1 then
			local TestMarker1 = {70, 25}
			hw:ShowMarker(hw,TestMarker1)
		end
	--]]
		prototype:HandleMarkers(nil, hw, markers)
	-- Markers
	if self.markers then
		for i, marker in pairs(self.markers) do
			marker:Show()
			marker:SetWidth(MarkerWidth)
			marker:SetHeight(MarkerHeight - 4 * 2)
			marker.texture:SetTexture(unpack(MarkerColor))
			marker:SetPoint("LEFT", self, self:GetWidth() / 100 * marker.percent - MarkerWidth / 2, 0)
			marker:SetParent(self)
		end
	end
	--end
end
function prototype:Open(power)
	self.tracer:Open() 
end

function prototype:Close() 
	self.tracer:Close()
	self.title:SetText("")
	if self.power then
		self.power = nil
		self.powercolor = nil
		self.powerbar:Hide()
		self.powerbar:SetValue(0)
	end
	if self.markers then
		for i, marker in pairs(self.markers) do
			marker.percent = nil
			marker:ClearAllPoints()
			marker:Hide()
			tinsert(MarkerCache, marker)
		end
		self.markers = nil
	end
end

function prototype:SetInfoBundle(health,hperc,pperc)
	self.healthbar:SetValue(hperc)
	self.healthbar:SetStatusBarColor(hperc > 0.5 and ((1 - hperc) * 2) or 1, hperc > 0.5 and 1 or (hperc * 2), 0)
	self.health:SetText(health)
	if self.power and pperc then self.powerbar:SetValue(pperc) end
end

-- Events
function prototype:TRACER_LOST() self:ApplyLostColor() end

function prototype:TRACER_ACQUIRED() 
	local unit = self.tracer:First()
	self:Fire("HW_TRACER_ACQUIRED",unit)
	if not self.powercolor and self.power then
		-- Saurfang apparently returns three extra arguments
		local ix,type,r,g,b = UnitPowerType(unit)
		if r and g and b then
			self.powerbar:SetStatusBarColor(r,g,b)
		else
			-- numeric indexes are fallbacks according to blizzard
			local c = PowerBarColor[type] or PowerBarColor[ix]
			if not c then return end
			self.powerbar:SetStatusBarColor(c.r,c.g,c.b)
		end
		self.powercolor = true
	end
	if not IsEncounterInProgress() then
		addon:OpenWindows()
	end
end

function prototype:TRACER_UPDATE()
	local unit = self.tracer:First()
	if UnitIsDead(unit) then
		self:SetInfoBundle(DEAD, 0, 0)
	else
		local h, hm = UnitHealth(unit), UnitHealthMax(unit) 
		local hperc = h/hm
		local pperc
		if self.power then pperc = UnitPower(unit)/UnitPowerMax(unit) end
		self:SetInfoBundle(format("%0.0f%%", hperc*100), hperc, pperc)
	end
	if self.updates then
		self:Fire("HW_TRACER_UPDATE",self.tracer:First())
	end
end

-------------------
do
	function prototype:CreateMarker()
		local marker = table.remove(MarkerCache)
		if not marker then
			marker = CreateFrame("Frame", nil, UIParent)

			local t = marker:CreateTexture(nil, "OVERLAY")
			t:SetAllPoints()

			marker.texture = t
		end

		return marker
	end

	function prototype:HandleMarkers(db, bar, markers)
		for i, marker in pairs(markers) do
			local m = self:CreateMarker()
			m.percent = marker
			bar.markers = bar.markers or {}
			tinsert(bar.markers, m)
		end
	end
	
end
function prototype:ApplyTestMarkers(bar, markers) 
	self:HandleMarkers(nil, bar, markers)
end
