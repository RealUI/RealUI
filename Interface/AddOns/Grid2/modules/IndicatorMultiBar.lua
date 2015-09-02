--[[ Created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2
local Grid2Frame = Grid2Frame
local min = min
local max = max
local pairs = pairs
local ipairs = ipairs

local AlignPoints = Grid2.AlignPoints
local SetSizeMethods = { HORIZONTAL = "SetWidth", VERTICAL = "SetHeight" }
local GetSizeMethods = { HORIZONTAL = "GetWidth", VERTICAL = "GetHeight" }

local function Bar_CreateHH(self, parent)
	local bar = self:CreateFrame("StatusBar", parent)
	bar.myIndicator = self
	bar.myValues = {}
	bar:SetStatusBarColor(0,0,0,0)
	bar:SetMinMaxValues(0, 1)
	bar:SetValue(0)
	bar:Show()
end

local function Bar_OnFrameUpdate(bar)
	local self        = bar.myIndicator
	local direction   = self.direction
	local horizontal  = self.horizontal
	local points      = self.alignPoints
	local barSize     = bar[self.GetSizeMethod](bar)
	local myTextures  = bar.myTextures
	local myValues    = bar.myValues
	local valueTo     = myValues[1] or 0
	local valueMax    = valueTo
	local maxIndex    = 0
	if self.reverse then
		valueMax, valueTo = 0, -valueTo
	else
		bar:SetValue(valueTo)
	end
	for i=2,bar.myMaxIndex do
		local texture = myTextures[i]
		local value = myValues[i] or 0
		if value>0 then
			local size, offset
			maxIndex = i
			if texture.myReverse then
				size    = min(value, valueTo)
				offset  = valueTo - size
				valueTo = valueTo - value
			elseif texture.myNoOverlap then
				size     = min(value, 1-valueMax)
				offset   = valueMax	
				valueTo  = valueMax + value
				valueMax = valueTo
			else
				offset   = max(valueTo,0)
				valueTo  = valueTo + value
				size     = min(valueTo,1) - offset
				valueMax = max(valueMax, valueTo)				
			end
			if size>0 then
				if horizontal then
					texture:SetPoint( points[1], bar, points[1], direction*offset*barSize, 0)
				else
					texture:SetPoint( points[1], bar, points[1], 0, direction*offset*barSize)
				end
				texture:mySetSize( size * barSize )
				texture:Show()
			else
				texture:Hide()
			end	
		else
			texture:Hide()
		end
	end
	bar.myMaxIndex = maxIndex
	if self.backColor then
		local texture = myTextures[#myTextures]
		local size = self.backMainAnchor and myValues[1] or valueMax
		if size<1 then
			texture:SetPoint( points[2], bar, points[2], 0, 0)
			texture:mySetSize( (1-size) * barSize )
			texture:Show()
		else
			texture:Hide()
		end	
	end
end

-- {{{ Optimization: Updating modified bars only on next frame repaint
local updates = {}
local EnableDelayedUpdates = function()
	CreateFrame("Frame", nil, Grid2LayoutFrame):SetScript("OnUpdate", function()
		for bar in pairs(updates) do
			Bar_OnFrameUpdate(bar)
		end
		wipe(updates)
	end)
	EnableDelayedUpdates = Grid2.Dummy
end	

-- Warning: This is an overrided indicator:Update() NOT the standard indicator:OnUpdate()
local function Bar_Update(self, parent, unit, status)
	if unit then
		local bar = parent[self.name]
		local values = bar.myValues
		if status then
			local index = self.priorities[status]
			-- local value = status:IsActive(unit) and status:GetPercent(unit) or 0; <- correct but more slow way
			local value = status:GetPercent(unit) or 0
			values[index] = value
			-- Optimization to avoid updating bars with zero value
			if value>0 and index>bar.myMaxIndex then bar.myMaxIndex = index	end
		else
			for i, status in ipairs(self.statuses) do
				-- values[i] = status:IsActive(unit) and status:GetPercent(unit) or 0; <- correct but more slow way
				values[i] = status:GetPercent(unit) or 0
			end
			bar.myMaxIndex = #self.statuses
		end
		updates[bar] = true
	end	
end
-- }}}

local function Bar_Layout(self, parent)
	local bar    = parent[self.name]
	local orient = self.orientation or Grid2Frame.db.profile.orientation
	local level  = parent:GetFrameLevel() + self.frameLevel
	local width  = self.width  or parent.container:GetWidth()
	local height = self.height or parent.container:GetHeight()	
	local color  = self.textureColor
	-- main bar
	bar:ClearAllPoints()
	bar:SetOrientation(orient)
	bar:SetReverseFill(self.reverseFill)
	bar:SetFrameLevel(level)
	bar:SetStatusBarTexture(self.texture)
	local barTexture = bar:GetStatusBarTexture()
	barTexture:SetDrawLayer("ARTWORK", 0)
	if color then bar:SetStatusBarColor(color.r, color.g, color.b, min(self.opacity, color.a or 1) ) end	
	bar:SetSize(width, height)
	bar:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	if self.reverse then bar:SetValue(0) end
	-- extra bars
	local textures = bar.myTextures or { barTexture }
	for i=1,self.barCount do
		local setup = self.bars[i]
		local texture = textures[i+1] or bar:CreateTexture()
		texture.mySetSize = texture[ self.SetSizeMethod ]		
		texture.myReverse = setup.reverse
		texture.myNoOverlap = setup.noOverlap
		texture:SetTexture( setup.texture or self.texture )
	    texture:SetDrawLayer("ARTWORK", setup.sublayer or 1)
		local c = setup.color 
		if c then texture:SetVertexColor( c.r, c.g, c.b, min(self.opacity, c.a or 1) ) end
		texture:ClearAllPoints()
		texture:SetSize( width, height )
		textures[i+1] = texture
	end
	for i=self.barCount+2,#textures do
		textures[i]:Hide()
	end
	bar.myTextures = textures
	bar.myMaxIndex = #self.statuses
end

local function Bar_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Bar_SetOrientation(self, orientation)
	self.orientation     = orientation
	self.dbx.orientation = orientation
end

local function Bar_Disable(self, parent)
	local bar = parent[self.name]
	if bar.myTextures then
		for _,texture in ipairs(bar.myTextures) do
			texture:Hide()
		end	
	end
	bar:Hide()	
	self.Layout = nil
	self.Update = nil
end

local function Bar_UpdateDB(self, dbx)
	dbx = dbx or self.dbx
	self.dbx = dbx
	self.orientation    = dbx.orientation
	local orient = self.orientation or Grid2Frame.db.profile.orientation
	self.SetSizeMethod  = SetSizeMethods[orient]
	self.GetSizeMethod  = GetSizeMethods[orient]	
	self.alignPoints    = AlignPoints[orient][not dbx.reverseFill]
	local l = dbx.location
	self.frameLevel     = dbx.level or 1
	self.anchor         = l.point
	self.anchorRel      = l.relPoint
	self.offsetx        = l.x
	self.offsety        = l.y
	self.width          = dbx.width
	self.height         = dbx.height
	self.direction      = dbx.reverseFill and -1 or 1
	self.horizontal     = (orient == "HORIZONTAL")
	self.reverseFill    = dbx.reverseFill
	self.textureColor   = dbx.textureColor
	self.backColor      = dbx.backColor
	self.backMainAnchor = dbx.backMainAnchor
	self.opacity        = dbx.opacity or 1
	self.reverse        = dbx.reverseMainBar
	self.backTexture    = Grid2:MediaFetch("statusbar", dbx.backTexture, "Gradient") 
	self.texture        = Grid2:MediaFetch("statusbar", dbx.texture, "Gradient")
	self.textureSublayer= 0
	self.bars           = {}
	self.barCount       = dbx.barCount or 0
	for i=1,self.barCount do
		local bar = self.bars[i] or {}	
		local setup = dbx["bar"..i]
		if setup then
			bar.texture   = Grid2:MediaFetch("statusbar", setup.texture or dbx.texture, "Gradient")
			bar.reverse   = setup.reverse
			bar.noOverlap = setup.noOverlap
			bar.color     = setup.color
			bar.sublayer  = i
		end
		self.bars[i] = bar
	end
	if self.backColor then
		self.barCount = self.barCount + 1
	    self.bars[self.barCount] = { texture = self.backTexture, color = dbx.backColor, sublayer = 0 }
	end
end

--{{ Bar Color indicator

local function BarColor_OnUpdate(self, parent, unit, status)
	if status then
		self:SetBarColor(parent, status:GetColor(unit))
	else
		self:SetBarColor(parent, 0, 0, 0, 0)
	end
end

local function BarColor_SetBarColor(self, parent, r, g, b, a)
	parent[self.BarName]:SetStatusBarColor(r, g, b, min(self.opacity,a or 1) )
end

local function BarColor_SetBarColorInverted(self, parent, r, g, b, a)
	parent[self.BarName]:SetStatusBarColor(0, 0, 0, min(self.opacity, 0.8) )
	parent.container:SetVertexColor(r, g, b, a)
end

local function BarColor_UpdateDB(self, dbx)
	dbx = dbx or self.dbx
	self.SetBarColor = dbx.invertColor and BarColor_SetBarColorInverted or BarColor_SetBarColor
	self.OnUpdate = dbx.textureColor and Grid2.Dummy or BarColor_OnUpdate
	self.opacity = dbx.opacity or 1
	self.dbx = dbx	
end

--- }}}

local function Create(indicatorKey, dbx)

	local Bar = Grid2.indicators[indicatorKey] or Grid2.indicatorPrototype:new(indicatorKey)
	-- Hack to caculate status index fast: statuses[priorities[status]] == status
	Bar.sortStatuses   = function (a,b) return Bar.priorities[a] < Bar.priorities[b] end
	Bar.Create         = Bar_CreateHH
	Bar.GetBlinkFrame  = Bar_GetBlinkFrame
	Bar.SetOrientation = Bar_SetOrientation
	Bar.Disable        = Bar_Disable	
	Bar.Layout         = Bar_Layout
	Bar.Update         = Bar_Update
	Bar.UpdateDB       = Bar_UpdateDB	
	Bar_UpdateDB(Bar,dbx)
	Grid2:RegisterIndicator(Bar, { "percent" }, true)
	EnableDelayedUpdates()
	
	local colorKey    = indicatorKey .. "-color"
	local BarColor    = Grid2.indicators[colorKey] or Grid2.indicatorPrototype:new(colorKey)
	BarColor.BarName  = indicatorKey
	BarColor.Create   = Grid2.Dummy
	BarColor.Layout   = Grid2.Dummy
	BarColor.UpdateDB = BarColor_UpdateDB
	BarColor_UpdateDB(BarColor, dbx)
	Grid2:RegisterIndicator(BarColor, { "color" })
	Bar.sideKick = BarColor
	
	return Bar, BarColor
end

Grid2.setupFunc["multibar"] = Create

Grid2.setupFunc["multibar-color"] = Grid2.Dummy
