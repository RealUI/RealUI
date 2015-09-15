--[[
	Layouts test mode
--]]

local Grid2Layout= Grid2:GetModule("Grid2Layout")
local Grid2Frame= Grid2:GetModule("Grid2Frame")
local texture
local colCount
local rowCount
local colColors
local frameLayout
local frames
local layoutName
local layoutFrameWidth
local layoutFrameHeight
local savedScale

function Grid2Layout:ShowFrames(enabled)
	for type, headers in pairs(self.groups) do
		for i = 1, self.indexes[type] do
			local g = headers[i]
			if enabled then
				g:Show()
			else
				g:Hide()
			end
		end
	end
end

local function LayoutGetTestFrame(i)
	local f
	if frames then
		f= frames[i]
	else
		frames= {}
	end
	if not f then
		f= CreateFrame("Frame", nil, frameLayout)
		frames[i]= f
	end
	f:SetBackdrop({
		bgFile = texture, tile = false, tileSize = 0,
		edgeFile = "Interface\\Addons\\Grid2\\media\\white16x16", edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	})
	return f
end

local LayoutGetVectors
do
	local vectors= {
	 ["TOPLEFT"]    = { 1,0, 0, 1, 0, 0},
	 ["TOPRIGHT"]   = {-1,0, 0, 1, 1, 0},
	 ["BOTTOMLEFT"] = { 1,0, 0,-1, 0, 1},
	 ["BOTTOMRIGHT"]= {-1,0, 0,-1, 1, 1},
	}
	LayoutGetVectors= function(anchor, horizontal, ox,oy, w,h, cols, rows)
		local ux,uy,vx,vy,px,py= unpack(vectors[anchor])
		if horizontal then
			return vx*w,vy*h,ux*w,uy*h,px*(rows-1)*w+ox,py*(cols-1)*h+oy,rows,cols
		else
			return ux*w,uy*h,vx*w,vy*h,px*(cols-1)*w+ox,py*(rows-1)*h+oy,cols,rows
		end
	end
end

local function LayoutHide(restoreRealLayout)
	if layoutName then
		local framesCount= colCount*rowCount
		for i=1,framesCount do
			frames[i]:Hide()
		end
		if savedScale then
			Grid2Layout:SavePosition()
			Grid2Layout.frame:SetScale(savedScale)
			Grid2Layout:RestorePosition()
			savedScale= nil
		end
		if restoreRealLayout then
			layoutName= nil
			Grid2Layout:ShowFrames(true)
			Grid2Layout:UpdateSize()
		end
	end
end

local LayoutLoad
do
	local colorsTable= {
		["partypet"]= { r=0,g=1,b=0, a=0.35},
		["raidpet"] = { r=0,g=1,b=0, a=0.35},
		["spacer"]  = { r=0,g=0,b=0, a=0},
	}
	LayoutLoad= function(name, width, height, maxPlayers)
		if layoutName then LayoutHide(false) end
		if not texture then
			local media = LibStub("LibSharedMedia-3.0", true)
			texture = media:Fetch("statusbar", Grid2Frame.db.profile.frameTexture) or "Interface\\Addons\\Grid2\\media\\gradient32x32"
		end
		if not frameLayout then frameLayout= Grid2Layout.frame end
		savedScale= frameLayout:GetScale()
		Grid2Layout:SavePosition()
		frameLayout:SetScale( Grid2Layout.db.profile.ScaleSize * (Grid2Layout.db.profile.layoutScales[name] or 1) )
		Grid2Layout:RestorePosition()
		colColors= {}
		local layout = Grid2Layout.layoutSettings[name]
		if layout then
			layout = Grid2.CopyTable(layout)
			if not layout[1] then
				local m = math.ceil( (maxPlayers or 40)/5 )
				for i=1,m do layout[i]= {} end
			end
			local defaults = layout.defaults or {}
			colCount= 0
			rowCount= 0
			local col= 1
			for i, l in ipairs(layout) do
				local unitPerColumn, maxColumns
				if (l=="auto" or l.groupFilter=="auto") and maxPlayers then
					unitPerColumn = 5
					maxColumns    = math.ceil(maxPlayers/5)
				else
					unitPerColumn = l.unitsPerColumn or defaults.unitsPerColumn or 5
					maxColumns    = l.maxColumns or defaults.maxColumns or 1
				end
				colCount = colCount + maxColumns
				rowCount = max(rowCount,unitPerColumn)
				local c = l.type and colorsTable[l.type] or RAID_CLASS_COLORS[ CLASS_SORT_ORDER[((i-1)%#CLASS_SORT_ORDER)+1] ]
				for j=1,maxColumns do
					colColors[col] = { c.r*0.5, c.g*0.5, c.b*0.5, c.a or 0.75}
					col = col + 1
				end
			end
			layoutName= name
			layoutFrameWidth = width
			layoutFrameHeight = height
			return true
		end
	end
end

local function LayoutRefresh()
	if not layoutName then return end

    Grid2Layout:ShowFrames(false)

	local width= layoutFrameWidth  or Grid2Frame.db.profile.frameWidths[layoutName]  or Grid2Frame.db.profile.frameWidth
	local height= layoutFrameHeight or Grid2Frame.db.profile.frameHeights[layoutName] or Grid2Frame.db.profile.frameHeight

	local settings= Grid2Layout.db.profile
	local inset= Grid2Frame.db.profile.frameBorder
	local frameLevel= frameLayout:GetFrameLevel() + 1
	local Spacing= settings.Spacing
	local Padding= settings.Padding
	local w= width - inset*2
	local h= height- inset*2
    local ux,uy,vx,vy,px,py,realCols,realRows= LayoutGetVectors(
												settings.groupAnchor, settings.horizontal,
												Spacing, Spacing, width+Padding, height+Padding,
												colCount, rowCount)
	px= px + inset
	py= py + inset
	local i= 1
	for nx=0,colCount-1 do
		local r,g,b,a= unpack(colColors[nx+1])
		for ny=0,rowCount-1 do
			local x= nx*ux + ny*vx + px
			local y= nx*uy + ny*vy + py
			local frame= LayoutGetTestFrame(i)
			frame:ClearAllPoints()
			frame:SetPoint("TOPLEFT", frameLayout, "TOPLEFT", x, -y )
			frame:SetSize( w,h )
			frame:SetBackdropColor( r,g,b,a )
			frame:SetBackdropBorderColor(0,0,0,1)
			frame:SetFrameLevel(frameLevel)
			frame:Show()
			r,g,b= r*0.7, g*0.7, b*0.7
			i= i + 1
		end
	end
	local layWidth = Spacing*2 + realCols * (width+Padding) - Padding
	local layHeight= Spacing*2 + realRows * (height+Padding) - Padding
	frameLayout:SetSize(layWidth,layHeight)
	Grid2Layout:SetSize(layWidth,layHeight)
end

local function LayoutEnable(self, name, width, height, size)
	if name and name ~= layoutName then
		if LayoutLoad(name, width, height, size) then
			LayoutRefresh()
			return true
		end
	else
		LayoutHide(true)
		return false
	end
end

Grid2Options.LayoutTestEnable= LayoutEnable
Grid2Options.LayoutTestRefresh= LayoutRefresh
