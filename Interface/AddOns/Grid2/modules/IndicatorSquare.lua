--[[ Square indicator, created by Grid2 original authors, modified by Michael ]]--

local Grid2 = Grid2

local function Square_Create(self, parent)
	local Square = self:CreateFrame("Frame", parent)
	Square:SetBackdropBorderColor(0,0,0,1)
	Square:SetBackdropColor(1,1,1,1)
end

local function Square_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Square_OnUpdate(self, parent, unit, status)
	local Square = parent[self.name]
	if status then
		Square:SetBackdropColor(status:GetColor(unit))
		if self.borderSize then
			local c = self.color
			Square:SetBackdropBorderColor( c.r, c.g, c.b, c.a )
		end
		Square:Show()
	else
		Square:Hide()
	end
end

local function Square_Layout(self, parent)
	local Square, container = parent[self.name], parent.container
	Square:ClearAllPoints()
	Square:SetFrameLevel(parent:GetFrameLevel() + self.frameLevel)
	Square:SetPoint(self.anchor, container, self.anchorRel, self.offsetx, self.offsety)
	Square:SetWidth( self.width or container:GetWidth() )
	Square:SetHeight( self.height or container:GetHeight() )
	local r1,g1,b1,a1 = Square:GetBackdropColor()
	local r2,g2,b2,a2 = Square:GetBackdropBorderColor()
	Square:SetBackdrop(self.backdrop)
	Square:SetBackdropColor(r1,g1,b1,a1)
	Square:SetBackdropBorderColor(r2,g2,b2,a2)
end

local function Square_Disable(self, parent)
	parent[self.name]:Hide()
	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = nil
end

local function Square_UpdateDB(self, dbx)
	dbx = dbx or self.dbx
	-- variables
	local l = dbx.location
	self.anchor = l.point
	self.anchorRel = l.relPoint
	self.offsetx = l.x
	self.offsety = l.y
	self.frameLevel = dbx.level
	self.color = Grid2:MakeColor(dbx.color1)
	self.borderSize = dbx.borderSize
	self.width = dbx.size or dbx.width
	if self.width==0 then self.width= nil end
	self.height= dbx.size or dbx.height
	if self.height==0 then self.height= nil end
	-- backdrop
	local backdrop    = self.backdrop   or {}
	backdrop.insets   = backdrop.insets or {}
	local borderSize  = self.borderSize or 0
	backdrop.tile     = false
	backdrop.tileSize = 0
	backdrop.bgFile   = Grid2:MediaFetch("statusbar", dbx.texture, "Grid2 Flat")
	backdrop.edgeFile = borderSize>0 and "Interface\\Addons\\Grid2\\media\\white16x16" or nil
	backdrop.edgeSize = borderSize>0 and borderSize or nil
	local insets      = backdrop.insets
	insets.left       = borderSize
	insets.right      = borderSize
	insets.top        = borderSize
	insets.bottom     = borderSize
	self.backdrop     = backdrop
	-- Methods
	self.Create = Square_Create
	self.GetBlinkFrame = Square_GetBlinkFrame
	self.Layout = Square_Layout
	self.OnUpdate = Square_OnUpdate
	self.Disable = Square_Disable
	self.UpdateDB = Square_UpdateDB
	self.dbx = dbx
end


local function Create(indicatorKey, dbx)
	local existingIndicator = Grid2.indicators[indicatorKey]
	local indicator = existingIndicator or Grid2.indicatorPrototype:new(indicatorKey)
	Square_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "square" })
	return indicator
end

Grid2.setupFunc["square"] = Create
 