local defaults = {
	profile = {
		Enable = true,
		Scale = 1,
	}
}

local addon = DXE
local L = addon.L
local SM = addon.SM
local db,pfl

local module = addon:NewModule("Arrows")
addon.Arrows = module

local frames = {}
local units = {}
local CreateArrow

module.frames = frames

local function Sound(...)
	if pfl.MasterSound then
		PlaySoundFile(...,"Master")
	else
		PlaySoundFile(...)
	end
end

---------------------------------------
-- PROTOTYPE
---------------------------------------
local prototype = {}

do
	local name_to_unit = addon.Roster.name_to_unit
	local blend = addon.util.blend
	local CN = addon.CN
	local Sounds = addon.Media.Sounds

	local GetPlayerFacing = GetPlayerFacing
	local UnitIsVisible = UnitIsVisible
	local PI,PI2 = math.pi,math.pi*2
	local floor,atan2 = math.floor,math.atan2

	local ARROW_FILE = "Interface\\Addons\\DXE\\Textures\\Arrow"
	local NUM_CELLS = 108
	local NUM_COLUMNS = 9
	local CELL_WIDTH = 56
	local CELL_HEIGHT = 42
	local IMAGESIZE = 512
	local CELL_WIDTH_PERC = CELL_WIDTH / IMAGESIZE
	local CELL_HEIGHT_PERC = CELL_HEIGHT / IMAGESIZE
	local TRANS_TIME = 0.5

	local colors = {
		{r = 0, g = 1,    b = 0}, -- Green
		{r = 1, g = 1,    b = 0}, -- Yellow
		{r = 1, g = 0.65, b = 0}, -- Orange
		{r = 1, g = 0,    b = 0}, -- Red
	}

	local function GetColor(d,action,range1,range2,range3)
		if action == "TOWARD" then
			-- Faster than if-else chain
			local i = (d <= range1 and 1 or (d <= range2 and 2 or (d <= range3 and 3 or 4)))
			return colors[i]
		elseif action == "AWAY" then
			local i = (d <= range1 and 4 or (d <= range2 and 3 or (d <= range3 and 2 or 1)))
			return colors[i]
		end
	end

	local function TransitionFunc(self)
		local perc = (self.elapsed - self.st) / TRANS_TIME
		if perc < 1 then
			local r,g,b = blend(self.color,self.tcolor,perc)
			self.t:SetVertexColor(r,g,b)
		else
			local color = self.tcolor
			self.color = color
			self.t:SetVertexColor(color.r,color.g,color.b)
			self.tcolor = nil
			self.transFunc = nil
		end
	end

	function prototype:SetColor(d)
		local color = GetColor(d,self.action,self.range1,self.range2,self.range3)
		if self.color == color then return end
		-- Transition
		self.tcolor = color
		self.st = self.elapsed
		self.transFunc = TransitionFunc
	end

	function prototype:SetAngle(dx,dy)
		-- Calculate
		local angle_axis = atan2(dx,dy)
		local angle = (PI-(GetPlayerFacing()-angle_axis)) % PI2
		if self.action == "AWAY" then angle = (PI + angle) % PI2 end

		-- Simplified from Claidhaire's TomTom
		local cell = floor(angle / PI2 * NUM_CELLS + 0.5) % NUM_CELLS
		local col = (cell % NUM_COLUMNS) * CELL_WIDTH_PERC
		local row = floor(cell / NUM_COLUMNS) * CELL_HEIGHT_PERC

		self.t:SetTexCoord(col, col + CELL_WIDTH_PERC, row, row + CELL_HEIGHT_PERC)
	end

	function prototype:SetFixed(xpos,ypos)
		if xpos and ypos then
			self.fx,self.fy = xpos,ypos
		else
			self.fx,self.fy = addon:GetPlayerMapPosition(self.unit)
		end
	end

	local function OnUpdate(self,elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > self.persist then
			self:Destroy()
		else
			if not (self.fx and self.fy) and not UnitIsVisible(self.unit) then self:Destroy() return end
			local d,dx,dy = addon:GetDistanceToUnit(self.unit,self.fx,self.fy)

			if not d then self:Destroy() return end

			if self.action == "TOWARD" then
				if d <= self.range1 then self:Destroy() return end
			elseif self.action == "AWAY" then
				if d >= self.range3 then self:Destroy() return end
			end
			
			self:SetAngle(dx,dy)
			self.label2:SetFormattedText(self.fmt,d)

			if self.transFunc then
				self:transFunc()
			else
				self:SetColor(d)
			end
		end
	end

	-- @param action a string == "TOWARD" or "AWAY"
	function prototype:SetTarget(unit,persist,action,msg,spell,sound,fixed,xpos,ypos,range1,range2,range3)
		-- Factor in mute all toggle from Alerts
	--	print("ARROW SET",unit,msg,CN[unit])

		if sound and not addon.Alerts.db.profile.DisableSounds then Sound(Sounds:GetFile(sound)) end
		UIFrameFadeRemoveFrame(self)
		self.action = action
		self.unit = unit
		self.elapsed = 0
		self.persist = persist
		self.fmt = spell.." <|cffffff78%.0f|r> "..CN[unit]
		if not range1 then range1 = 10 end
		self.range1 = range1
		if not range2 then range2 = range1*2 end
		self.range2 = range2
		if not range3 then range3 = range1*3 end
		self.range3 = range3

		if fixed then self:SetFixed(xpos,ypos) end
		local d,dx,dy = addon:GetDistanceToUnit(unit,self.fx,self.fy)
		if not d then return end

		self:SetAngle(dx,dy)

		local color = GetColor(d,action,range1,range2,range3)
		self.color = color
		self.t:SetVertexColor(color.r,color.g,color.b)
		units[unit] = true
		self.label:SetText(msg)
		self.label2:SetFormattedText(self.fmt,d)
		self:SetAlpha(1)
		self:SetScript("OnUpdate",OnUpdate)
		self:Show()
	end

	function prototype:Destroy()
		units[self.unit] = nil
		self.unit = nil
		self.color = nil
		self.tcolor = nil
		self.fx = nil
		self.fy = nil
		self.fmt = nil
		self.transFunc = nil
		local fadeTable = self.fadeTable
		fadeTable.fadeTimer = 0
		fadeTable.finishedFunc = self.Hide
		UIFrameFade(self,fadeTable)
		self:SetScript("OnUpdate",nil)
	end

	local function Test_OnUpdate(self,elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed > 10 then 
			self:Destroy()
		else
			local angle = (self.elapsed*3) % PI2

			-- Simplified from Claidhaire's TomTom
			local cell = floor(angle / PI2 * NUM_CELLS + 0.5) % NUM_CELLS
			local col = (cell % NUM_COLUMNS) * CELL_WIDTH_PERC
			local row = floor(cell / NUM_COLUMNS) * CELL_HEIGHT_PERC

			self.t:SetTexCoord(col, col + CELL_WIDTH_PERC, row, row + CELL_HEIGHT_PERC)
		end
	end

	function prototype:Test()
		self.elapsed = 0
		self.unit = ""
		UIFrameFadeRemoveFrame(self)
		self:SetAlpha(1)
		self.t:SetVertexColor(0.66,0.66,0.66)
		self.label:SetText("Testing")
		self.label2:SetText("Test <10> Test")
		self:SetScript("OnUpdate",Test_OnUpdate)
		self:Show()
	end

	function CreateArrow(i)
		local self = CreateFrame("Frame","DXEArrow"..i,UIParent)
		self:SetWidth(56)
		self:SetHeight(42)
		self:Hide()

		local t = self:CreateTexture(nil,"OVERLAY")
		t:SetTexture(ARROW_FILE)
		t:SetAllPoints(true)
		self.t = t

		local label = self:CreateFontString(nil,"ARTWORK")
		label:SetFont(GameFontNormal:GetFont(),12,"THICKOUTLINE")
		label:SetPoint("TOP",self,"BOTTOM")
		self.label = label

		local label2 = self:CreateFontString(nil,"ARTWORK","GameFontNormalSmall")
		label2:SetPoint("TOP",label,"BOTTOM")
		label2:SetShadowOffset(1,-1)
		label2:SetShadowColor(0,0,0)
		self.label2 = label2

		self.fadeTable = {mode = "OUT", timeToFade = 0.5, startAlpha = 1, endAlpha = 0, finishedArg1 = self}

		for k,v in pairs(prototype) do self[k] = v end

		return self
	end
	
end

---------------------------------------
-- INITIALIZATION
---------------------------------------

function module:RefreshArrows()
	for i,arrow in ipairs(frames) do
		arrow:SetScale(pfl.Scale)
	end
end

function module:RefreshProfile()
	pfl = db.profile
	self:RefreshArrows()
end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("Arrows",defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	for i=1,3 do 
		local arrow = CreateArrow(i)
		local anchor = addon:CreateLockableFrame("ArrowsAnchor"..i,85,42,format("%s - %s",L["Arrows"],L["Anchor"].." "..i))
		addon:RegisterMoveSaving(anchor,"CENTER","UIParent","CENTER",0,-(25 + (i*65)))
		addon:LoadPosition("DXEArrowsAnchor"..i)
		arrow:SetPoint("CENTER",anchor,"CENTER")
		frames[i] = arrow
	end

	self:RefreshArrows()
	
end

function module:OnDisable()
	self:RemoveAll()
end

---------------------------------------
-- API
---------------------------------------

function module:AddTarget(unit,persist,action,msg,spell,sound,fixed,xpos,ypos,range1,range2,range3)
	if not pfl.Enable then return end
	--[===[@debug@
	assert(type(unit) == "string")
	assert(type(persist) == "number")
	assert(type(action) == "string")
	assert(type(msg) == "string")
	assert(type(spell) == "string")
	--@end-debug@]===]
	if UnitExists(unit) and UnitIsVisible(unit) then
		-- Can't move to yourself or away from yourself, so bail on arrows that do that.
		if ((not xpos and not ypos and action == "TOWARD") or (not fixed and action == "AWAY")) and UnitIsUnit(unit,"player") then
			return
		end

		-- Distinction test
		for k in pairs(units) do if UnitIsUnit(k,unit) then return end end

		for i,arrow in ipairs(frames) do
			if not arrow.unit then
				arrow:SetTarget(unit,persist,action,msg,spell,sound,fixed,xpos,ypos,range1,range2,range3)
				break
			end
		end
	end
end

function module:RemoveTarget(unit)
	if not pfl.Enable then return end
	for i,arrow in ipairs(frames) do
		if arrow.unit and UnitIsUnit(arrow.unit,unit) then
			arrow:Destroy()
			break
		end
	end
end

function module:RemoveAll()
	if not pfl.Enable then return end
	for i,arrow in ipairs(frames) do
		if arrow.unit then
			arrow:Destroy()
		end
	end
end
