local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "AngleStatusBar"
local AngleStatusBar = nibRealUI:NewModule(MODNAME)

local min, max, abs, floor = math.min, math.max, math.abs, math.floor

local dontSmooth
local smoothing = {}
local function SetBarPosition(bar, per)
	bar.value = per
	if not bar.reverse then
		bar:SetWidth(bar.fullWidth * (1 - bar.value))
	else
		bar:SetWidth(bar.fullWidth * bar.value)
	end

	per = floor(per * 100) / 100
	bar:SetShown((not(bar.reverse) and (per < 1)) or (bar.reverse and (per > 0)))
end

local function SetBarValue(bar, per)
	per = per + (1 / bar.fullWidth)
	if per ~= bar.value then
		smoothing[bar] = per
	else
		SetBarPosition(bar, per)
		smoothing[bar] = nil
	end
end

local smoothUpdateFrame = CreateFrame("Frame")
smoothUpdateFrame:SetScript("OnUpdate", function()
	local limit = 30 / GetFramerate()
	for bar, per in pairs(smoothing) do
		local setPer = per * bar.fullWidth
		local setCur = bar.value * bar.fullWidth
		local new = setCur + min((setPer - setCur) / 2, max(setPer - setCur, limit * bar.fullWidth))
		if new ~= new then
			new = per * bar.fullWidth
		end
		SetBarPosition(bar, new / bar.fullWidth)
		if setCur == setPer or abs(new - setPer) < 2 then
			SetBarPosition(bar, setPer / bar.fullWidth)
			smoothing[bar] = nil
		end
	end
end)

function AngleStatusBar:SetValue(bar, per, ignoreSmooth)
	if bar.smooth and not(dontSmooth) and not(ignoreSmooth) then
		SetBarValue(bar, per)
	else
		SetBarPosition(bar, per)
	end
end

function AngleStatusBar:SetBarColor(bar, color)
	for r = 1, #bar.row do
		bar.row[r]:SetTexture(unpack(color))
	end
end

function AngleStatusBar:SetReverseDirection(bar, val, x, y)
	if val then
		bar.direction = (bar.direction == "LEFT") and "RIGHT" or "LEFT"
		bar:ClearAllPoints()
		bar:SetPoint(bar.endPoint, bar.parent, bar.endPoint, x, y)
	else
		bar.direction = bar.origDirection
		bar:ClearAllPoints()
		bar:SetPoint(bar.startPoint, bar.parent, bar.startPoint, bar.x, bar.y)
	end
end

function AngleStatusBar:NewBar(parent, x, y, width, height, typeStart, typeEnd, direction, smooth)
	local bar = CreateFrame("Frame", nil, parent)
	bar.fullWidth, bar.typeStart, bar.typeEnd, bar.direction, bar.value, bar.smooth = width, typeStart, typeEnd, direction, 1, smooth, true
	bar.origDirection = bar.direction

	-- Growth direction of Bar Start and End
	local startAngle, endAngle
	startAngle = (typeStart == "LEFT") and -1 or (typeStart == "RIGHT") and 1 or 0
	endAngle = (typeEnd == "LEFT") and -1 or (typeEnd == "RIGHT") and 1 or 0

	-- Start and End positions
	local startPoint, endPoint
	startPoint = (direction == "LEFT") and "TOPRIGHT" or "TOPLEFT"
	endPoint = (startPoint == "TOPRIGHT") and "TOPLEFT" or "TOPRIGHT"
	bar:SetPoint(startPoint, parent, startPoint, x, y)

	bar.parent = parent
	bar.startPoint = startPoint
	bar.endPoint = endPoint
	bar.x = x
	bar.y = y

	-- Size
	bar:SetHeight(height)

	-- Rows
	bar.row = {}
	local rX, rY, endX = 0, 0, 0
	for r = 1, height do
		bar.row[r] = bar:CreateTexture(nil, "ARTWORK")
		bar.row[r]:SetPoint(startPoint, bar, startPoint, rX, rY)
		bar.row[r]:SetPoint(endPoint, bar, endPoint, endX, rY)
		bar.row[r]:SetHeight(1)
		rX = rX + startAngle
		endX = endX + endAngle
		rY = rY - 1
		if r > height then
			bar.row[r]:Hide()
		end
	end

	bar:SetWidth(1)
	bar:Hide()
	self:SetValue(bar, 0, true)

	return bar
end

-------------
function AngleStatusBar:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	if ndb.settings.powerMode == 2 then
		dontSmooth = true
	end
end