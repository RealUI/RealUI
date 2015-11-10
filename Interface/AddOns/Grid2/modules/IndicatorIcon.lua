--[[ Icon indicator, created by Grid2 original authors, modified by Michael ]]-- 

local Grid2 = Grid2
local GetTime = GetTime
local fmt = string.format

local function Icon_Create(self, parent)
	local f = self:CreateFrame("Frame", parent)
	if not f:IsShown() then	f:Show() end
	
	local Icon = f.Icon or f:CreateTexture(nil, "ARTWORK")
	f.Icon = Icon
	Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
	Icon:SetAllPoints()
	if not Icon:IsShown() then Icon:Show() end
	
	if not self.disableCooldown then
		local Cooldown
		if self.dbx.disableOmniCC then
			Cooldown = f.Cooldown or CreateFrame("Cooldown", nil, f, "CooldownFrameTemplate")
			Cooldown.noCooldownCount = true 
		else
			local name = self.name:gsub("%-","")
			local i,j = parent:GetName():match("Grid2LayoutHeader(%d+)UnitButton(%d+)")
			Cooldown = f.Cooldown or CreateFrame("Cooldown", fmt("Grid2%s%02d%02d",name,i,j) , f, "CooldownFrameTemplate")
			Cooldown.noCooldownCount = nil
			Cooldown:SetDrawEdge(false) -- Without this omnicc uses only "Recharges color"
		end
		Cooldown:SetReverse(self.dbx.reverseCooldown)
		Cooldown:SetHideCountdownNumbers(true)
		Cooldown:Hide()
		f.Cooldown = Cooldown
	end
	
	if not self.disableStack then
		local TextFrame
		if self.disableCooldown then
			if f.TextFrame then f.TextFrame:Hide() end
			TextFrame = f
		else
			TextFrame = f.TextFrame or CreateFrame("Frame", nil, f)
			TextFrame:SetAllPoints()
			TextFrame:Show()
			f.TextFrame = TextFrame	
		end
		local CooldownText = f.CooldownText or f:CreateFontString(nil, "OVERLAY")	
		CooldownText:SetParent(TextFrame)
		CooldownText:SetFontObject(GameFontHighlightSmall)
		CooldownText:SetFont(self.textfont, self.dbx.fontSize, self.dbx.fontFlags or "OUTLINE" )
		local c = self.dbx.stackColor
		if c then CooldownText:SetTextColor(c.r, c.g, c.b, c.a) end	
		CooldownText:Hide()
		f.CooldownText = CooldownText
	end	

end

local function Icon_GetBlinkFrame(self, parent)
	return parent[self.name]
end

local function Icon_AnimationOnUpdate(frame, elapsed)
	local status = frame.status
	local duration = status.animDuration
	elapsed = elapsed + frame.animElapsed
	if elapsed < duration then
		frame.animElapsed = elapsed
		elapsed = elapsed / duration
		if elapsed>0.5 then elapsed = 1-elapsed end
		frame:SetScale( 1 + elapsed*status.animScale )
	else
		frame.animElapsed = nil
		frame:SetScript("OnUpdate", nil)
		frame:SetScale(1)
	end
end

local function Icon_OnUpdate(self, parent, unit, status)
	local Frame = parent[self.name]
	if not status then Frame:Hide()	return end
	
	local Icon = Frame.Icon
	
	Icon:SetTexture(status:GetIcon(unit))
	Icon:SetTexCoord(status:GetTexCoord(unit))
	Icon:SetVertexColor(status:GetVertexColor(unit))

	local r,g,b,a = status:GetColor(unit)
	if self.useStatusColor or status:GetBorder(unit) then
		Frame:SetBackdropBorderColor(r,g,b,a) 
	elseif self.borderSize then
		local c = self.color
		Frame:SetBackdropBorderColor(c.r, c.g, c.b, c.a) 
	else
		Frame:SetBackdropBorderColor(0,0,0,0)
	end
	Icon:SetAlpha(a or 1)

	if not self.disableStack then
		local count = status:GetCount(unit)
		if count>1 then 
			Frame.CooldownText:SetText(count)
			Frame.CooldownText:Show()
		else
			Frame.CooldownText:Hide()
		end
	end

	if not self.disableCooldown then
		local expiration, duration = status:GetExpirationTime(unit), status:GetDuration(unit)
		if expiration and duration then
			Frame.Cooldown:SetCooldown(expiration - duration, duration)
			Frame.Cooldown:Show()
		else
			Frame.Cooldown:Hide()	
		end
	end	

	if self.animEnabled and (not Frame.animElapsed) then
		Frame.status = self
		Frame.animElapsed = 0
		Frame:SetScript("OnUpdate", Icon_AnimationOnUpdate )
	end
	
	Frame:Show()
end

local function Icon_Layout(self, parent)
	local f = parent[self.name]

	local level = parent:GetFrameLevel() + self.frameLevel
	f:ClearAllPoints()
	f:SetPoint(self.anchor, parent.container, self.anchorRel, self.offsetx, self.offsety)
	f:SetFrameLevel(level)

	local Icon = f.Icon
	local r,g,b,a = f:GetBackdropBorderColor()
	local borderSize = self.borderSize
	if borderSize then
		Icon:SetPoint("TOPLEFT", f ,"TOPLEFT", borderSize, -borderSize)
		Icon:SetPoint("BOTTOMRIGHT", f ,"BOTTOMRIGHT", -borderSize, borderSize)
	else
		Icon:SetAllPoints(f)
	end
	f:SetBackdrop(self.backdrop)
	f:SetBackdropBorderColor(r, g, b, a)
	
	local size = self.dbx.size
	f:SetSize(size,size)
	
	if not self.disableStack then
		if f.TextFrame then	f.TextFrame:SetFrameLevel(level+1) end
		local CooldownText = f.CooldownText
		local justifyH = self.dbx.fontJustifyH or "CENTER"
		local justifyV = self.dbx.fontJustifyV or "MIDDLE"
		CooldownText:SetJustifyH( justifyH )
		CooldownText:SetJustifyV( justifyV  )
		CooldownText:ClearAllPoints()
		CooldownText:SetPoint("TOP")
		CooldownText:SetPoint("BOTTOM")
		CooldownText:SetPoint("LEFT" , justifyH=="LEFT"  and 0 or -size, 0)
		CooldownText:SetPoint("RIGHT", justifyH=="RIGHT" and 2 or  size+2, 0)
	end
	
end

local function Icon_Disable(self, parent)
	local f = parent[self.name]
	f:Hide()
	f.Icon:Hide()
	if f.Cooldown then f.Cooldown:Hide() end
	if f.CooldownText then f.CooldownText:Hide() end
	self.GetBlinkFrame = nil
	self.Layout = nil
	self.OnUpdate = nil
end

local function Icon_UpdateDB(self, dbx)
	dbx = dbx or self.dbx
	-- location
	local l = dbx.location
	self.anchor    = l.point
	self.anchorRel = l.relPoint
	self.offsetx   = l.x
	self.offsety   = l.y
	-- misc variables
	self.disableCooldown = dbx.disableCooldown
	self.disableStack    = dbx.disableStack
	self.frameLevel      = dbx.level
	self.borderSize      = dbx.borderSize
	self.useStatusColor  = dbx.useStatusColor
	self.color           = Grid2:MakeColor(dbx.color1)
	self.textfont        = Grid2:MediaFetch("font", dbx.font or Grid2Frame.db.profile.font) or STANDARD_TEXT_FONT
	-- animation
	self.animEnabled  = dbx.animEnabled
	if dbx.animEnabled then
		self.animScale    = ((dbx.animScale or 1.5)-1) * 2
		self.animDuration = dbx.animDuration or 0.7
	end	
	-- backdrop
	local backdrop    = self.backdrop   or {}
	backdrop.insets   = backdrop.insets or {}
	local borderSize  = self.borderSize or 1
	backdrop.edgeFile = "Interface\\Addons\\Grid2\\media\\white16x16"
	backdrop.edgeSize = borderSize
	local insets      = backdrop.insets
	insets.left       = borderSize
	insets.right      = borderSize
	insets.top        = borderSize
	insets.bottom     = borderSize
	self.backdrop     = backdrop
	-- methods
	self.Create        = Icon_Create
	self.GetBlinkFrame = Icon_GetBlinkFrame
	self.Layout        = Icon_Layout
	self.OnUpdate      = Icon_OnUpdate
	self.Disable       = Icon_Disable
	self.UpdateDB      = Icon_UpdateDB
	--
	self.dbx = dbx
end


local function CreateIcon(indicatorKey, dbx)
	local existingIndicator = Grid2.indicators[indicatorKey]
	local indicator = existingIndicator or Grid2.indicatorPrototype:new(indicatorKey)
	Icon_UpdateDB(indicator, dbx)
	Grid2:RegisterIndicator(indicator, { "icon" })
	return indicator
end

Grid2.setupFunc["icon"] = CreateIcon
