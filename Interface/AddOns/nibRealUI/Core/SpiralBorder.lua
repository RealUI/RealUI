local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "SpiralBorder"
local SpiralBorder = nibRealUI:NewModule(MODNAME)

local SpiralCount = 0
local Spirals = {}
local activeSpirals = {}
local inactiveSpiralIDs = {}

local max = max
local GetTime = GetTime

local SpiralLength = 104	-- Total length in pixels of spiral, used for dynamic updates
local UpdateVals = {
	{SpiralLength, 1/10},		-- Normal
	{SpiralLength * 1.5, 1/7},	-- Economy
	{SpiralLength, 1/15}		-- Turbo
}

local remPer
function SpiralBorder:SetSpiralValue(spiral, per)
	if per > 0.875 then
		if spiral.sect[1].curVal ~= 1 then spiral.sect[1]:SetValue(1) spiral.sect[1].curVal = 1 end
		if spiral.sect[2].curVal ~= 1 then spiral.sect[2]:SetValue(1) spiral.sect[2].curVal = 1 end
		if spiral.sect[3].curVal ~= 1 then spiral.sect[3]:SetValue(1) spiral.sect[3].curVal = 1 end
		if spiral.sect[4].curVal ~= 1 then spiral.sect[4]:SetValue(1) spiral.sect[4].curVal = 1 end

		remPer = (per - 0.875) / 0.125
		spiral.sect[5]:SetValue(remPer)
		spiral.sect[5].curVal = remPer
	
	elseif per > 0.625 then
		if spiral.sect[1].curVal ~= 1 then spiral.sect[1]:SetValue(1) spiral.sect[1].curVal = 1 end
		if spiral.sect[2].curVal ~= 1 then spiral.sect[2]:SetValue(1) spiral.sect[2].curVal = 1 end
		if spiral.sect[3].curVal ~= 1 then spiral.sect[3]:SetValue(1) spiral.sect[3].curVal = 1 end
		if spiral.sect[5].curVal ~= 0 then spiral.sect[5]:SetValue(0) spiral.sect[5].curVal = 0 end

		remPer = (per - 0.625) / 0.25
		spiral.sect[4]:SetValue(remPer)
		spiral.sect[4].curVal = remPer

	elseif per > 0.375 then
		if spiral.sect[1].curVal ~= 1 then spiral.sect[1]:SetValue(1) spiral.sect[1].curVal = 1 end
		if spiral.sect[2].curVal ~= 1 then spiral.sect[2]:SetValue(1) spiral.sect[2].curVal = 1 end
		if spiral.sect[4].curVal ~= 0 then spiral.sect[4]:SetValue(0) spiral.sect[4].curVal = 0 end
		if spiral.sect[5].curVal ~= 0 then spiral.sect[5]:SetValue(0) spiral.sect[5].curVal = 0 end

		remPer = ((per - 0.375) / 0.25)
		spiral.sect[3]:SetValue(remPer)
		spiral.sect[3].curVal = remPer

	elseif per > 0.125 then
		if spiral.sect[1].curVal ~= 1 then spiral.sect[1]:SetValue(1) spiral.sect[1].curVal = 1 end
		if spiral.sect[3].curVal ~= 0 then spiral.sect[3]:SetValue(0) spiral.sect[3].curVal = 0 end
		if spiral.sect[4].curVal ~= 0 then spiral.sect[4]:SetValue(0) spiral.sect[4].curVal = 0 end
		if spiral.sect[5].curVal ~= 0 then spiral.sect[5]:SetValue(0) spiral.sect[5].curVal = 0 end

		remPer = ((per - 0.125) / 0.25)
		spiral.sect[2]:SetValue(remPer)
		spiral.sect[2].curVal = remPer

	else
		if spiral.sect[2].curVal ~= 0 then spiral.sect[2]:SetValue(0) spiral.sect[2].curVal = 0 end
		if spiral.sect[3].curVal ~= 0 then spiral.sect[3]:SetValue(0) spiral.sect[3].curVal = 0 end
		if spiral.sect[4].curVal ~= 0 then spiral.sect[4]:SetValue(0) spiral.sect[4].curVal = 0 end
		if spiral.sect[5].curVal ~= 0 then spiral.sect[5]:SetValue(0) spiral.sect[5].curVal = 0 end

		remPer = per / 0.125
		spiral.sect[1]:SetValue(remPer)
		spiral.sect[1].curVal = remPer
	end

	for i = 1, 5 do
		if per > 0.5 then
			spiral.sect[i]:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
		else
			spiral.sect[i]:SetStatusBarColor(1, (per*2), 0)
		end
	end
end

function SpiralBorder:AttachSpiral(bar, inset, hasFrame)
	local barFame, barIcon
	if hasFrame then 
		barFrame = bar.frame
	else
		barFrame = bar
	end

	-- Recycle Spiral
	local nextInactiveKey, newID = next(inactiveSpiralIDs)
	if newID then
		tremove(inactiveSpiralIDs, nextInactiveKey)

		-- Reset old Spiral
		Spirals[newID].bar = bar
		Spirals[newID].barIcon = barIcon
		Spirals[newID].bar.endTime = nil
		barFrame.ssID = newID

		Spirals[newID]:SetParent(barFrame)
		Spirals[newID]:SetFrameLevel(1)

		for i = 1, 5 do
			Spirals[newID].sect[i]:SetValue(0)
			Spirals[newID].sect[i].curVal = 0
		end
		Spirals[newID].elapsed = 0
		Spirals[newID].interval = 0.05

		Spirals[newID]:Show()

	-- New Spiral
	else
		SpiralCount = SpiralCount + 1
		newID = SpiralCount

		-- Spiral Frame
		Spirals[newID] = CreateFrame("Frame", nil, barFrame)
		Spirals[newID]:SetFrameLevel(0)
			Spirals[newID]:SetBackdrop({
				bgFile = nibRealUI.media.textures.plain, 
				edgeFile = nibRealUI.media.textures.plain, 
				edgeSize = 1, 
			})
			Spirals[newID]:SetBackdropColor(0.1, 0.1, 0.1, 0.9)
			Spirals[newID]:SetBackdropBorderColor(0, 0, 0)
			Spirals[newID].bar = bar
			Spirals[newID].bar.endTime = nil
			barFrame.ssID = newID

		-- Status Bars
		Spirals[newID].sect = {}
		for i = 1, 5 do
			Spirals[newID].sect[i] = CreateFrame("StatusBar", nil, Spirals[newID])
				Spirals[newID].sect[i]:SetMinMaxValues(0, 1)
				Spirals[newID].sect[i]:SetValue(0)
				Spirals[newID].sect[i]:SetStatusBarTexture(nibRealUI.media.textures.plain)
				Spirals[newID].sect[i]:SetFrameLevel(20)
		end

		-- Top Right
		Spirals[newID].sect[1]:SetPoint("TOPLEFT", Spirals[newID], "TOP", 0, -1)
		Spirals[newID].sect[1]:SetPoint("BOTTOMRIGHT", Spirals[newID], "TOPRIGHT", -1, -2)

		-- Right
		Spirals[newID].sect[2]:SetOrientation("VERTICAL")
		Spirals[newID].sect[2]:SetReverseFill(true)
		Spirals[newID].sect[2]:SetPoint("TOPRIGHT", Spirals[newID], "TOPRIGHT", -1, -2)
		Spirals[newID].sect[2]:SetPoint("BOTTOMLEFT", Spirals[newID], "BOTTOMRIGHT", -2, 1)

		-- Bottom
		Spirals[newID].sect[3]:SetReverseFill(true)
		Spirals[newID].sect[3]:SetPoint("BOTTOMRIGHT", Spirals[newID], "BOTTOMRIGHT", -2, 1)
		Spirals[newID].sect[3]:SetPoint("TOPLEFT", Spirals[newID], "BOTTOMLEFT", 1, 2)

		-- Left
		Spirals[newID].sect[4]:SetOrientation("VERTICAL")
		Spirals[newID].sect[4]:SetPoint("BOTTOMLEFT", Spirals[newID], "BOTTOMLEFT", 1, 2)
		Spirals[newID].sect[4]:SetPoint("TOPRIGHT", Spirals[newID], "TOPLEFT", 2, -1)

		-- Top Left
		Spirals[newID].sect[5]:SetPoint("TOPLEFT", Spirals[newID], "TOPLEFT", 2, -1)
		Spirals[newID].sect[5]:SetPoint("BOTTOMRIGHT", Spirals[newID], "TOP", 0, -2)

		-- OnUpdate
		Spirals[newID].elapsed = 0
		Spirals[newID].interval = 0.05
		Spirals[newID]:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = self.elapsed + elapsed
			if self.elapsed >= self.interval then
				if self.bar.startTime and self.bar.offsetTime ~= nil and self.bar.duration and (self.bar.duration > 0) then
					-- Cooldown
					if not self.bar.endTime then
						self.interval = max(1 / (UpdateVals[ndb.settings.powerMode][1] / self.bar.duration), UpdateVals[ndb.settings.powerMode][2])
					end
					self.bar.endTime = (self.bar.startTime - self.bar.offsetTime) + self.bar.duration
					SpiralBorder:SetSpiralValue(self, (self.bar.endTime - GetTime()) / (self.bar.endTime - (self.bar.startTime - self.bar.offsetTime)))
				else
					-- No cooldown
					self.interval = 1
					self.bar.endTime = nil
					SpiralBorder:SetSpiralValue(self, 0)
				end
				self.elapsed = 0
			end
		end)
	end

	-- Apply Spiral
	activeSpirals[newID] = true

	Spirals[newID]:ClearAllPoints()
	Spirals[newID]:SetPoint("TOPLEFT", barFrame, inset, -inset)
	Spirals[newID]:SetPoint("BOTTOMRIGHT", barFrame, -inset, inset)
end

function SpiralBorder:RemoveSpiral(bar, id, hasFrame)
	local barFame
	if hasFrame then barFrame = bar.frame else barFrame = bar end
	
	if id and activeSpirals[id] then
		barFrame.ssID = nil
		Spirals[id]:Hide()
		activeSpirals[id] = nil
		tinsert(inactiveSpiralIDs, id)
	end
end

-------------
function SpiralBorder:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(true)
end