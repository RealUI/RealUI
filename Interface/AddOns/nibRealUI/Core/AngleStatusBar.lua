local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "AngleStatusBar"
local AngleStatusBar = nibRealUI:NewModule(MODNAME)
local oUF = oUFembed

local min, max, abs, floor = math.min, math.max, math.abs, math.floor

local dontSmooth
local smoothing = {}
local function SetBarPosition(self, value)
    self.value = value
    if self.info then
        local info = self.info
        local width
        if self.reverse then
            -- This will take the raw value, percent or exact, and adjust it to within the bounds of the bar.
            width = (((value - self.min) * (info.maxWidth - info.minWidth)) / (self.max - self.min)) + info.minWidth
        else
            width = (((value - self.min) * (info.minWidth - info.maxWidth)) / (self.max - self.min)) + info.maxWidth
        end
        self.bar:SetWidth(width)

        value = floor(value * self.max) / self.max
        --print("Floored", self:GetParent():GetParent().unit, self.reverse, value)
        self.bar:SetShown((not(self.reverse) and (value < self.max)) or (self.reverse and (value > self.min)))
    else
        if not self.reverse then
            self:SetWidth(self.fullWidth * (1 - value))
        else
            self:SetWidth(self.fullWidth * value)
        end

        value = floor(value * 100) / 100
        --print("Floored", self:GetParent():GetParent().unit, reverse, value)
        self:SetShown((not(self.reverse) and (value < 1)) or (self.reverse and (value > 0)))
    end
end

local function SetBarValue(self, value)
    if not self.info then
        value = value + (1 / self.fullWidth)
    end
    if value ~= self.value then
        smoothing[self] = value
    else
        SetBarPosition(self, value)
        smoothing[self] = nil
    end
end

local smoothUpdateFrame = CreateFrame("Frame")
smoothUpdateFrame:SetScript("OnUpdate", function()
    local limit = 30 / GetFramerate()
    for bar, per in next, smoothing do
        local maxWidth = bar.info and bar.info.maxWidth or bar.fullWidth
        local setPer = per * maxWidth
        local setCur = bar.value * maxWidth
        local new = setCur + min((setPer - setCur) / 2, max(setPer - setCur, limit * maxWidth))
        if new ~= new then
            new = per * maxWidth
        end
        SetBarPosition(bar, new / maxWidth)
        if setCur == setPer or abs(new - setPer) < 2 then
            SetBarPosition(bar, setPer / maxWidth)
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

function AngleStatusBar:SetBarColor(bar, r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    for i = 1, #bar.row do
        bar.row[i]:SetTexture(r, g, b, a or 1)
    end
end

function AngleStatusBar:ReverseBarDirection(bar, val, x, y)
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

function AngleStatusBar:SetReverseFill(bar, reverse)    -- Reverse fill style (reverse: 100% = full)
    bar.reverse = reverse
    self:SetValue(bar, bar.value, true)
end

function AngleStatusBar:NewBar(parent, x, y, width, height, typeStart, typeEnd, direction, smooth)
    local bar = CreateFrame("Frame", nil, parent)
    bar.fullWidth, bar.typeStart, bar.typeEnd, bar.direction, bar.value, bar.smooth = width, typeStart, typeEnd, direction, 1, smooth, true
    bar.origDirection = bar.direction

    -- Growth direction of Bar Start and End
    local startAngle, endAngle  -- / <-- LEFT   RIGHT --> \
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

    -- Create pixel lines for the actual bar
    bar:SetHeight(height)
    bar.row = {}
    local rX, rY, endX = 0, 0, 0
    for r = 1, height do
        bar.row[r] = parent:CreateTexture(nil, "ARTWORK")
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

    bar:SetScript("OnHide", function()
        for r = 1, #bar.row do
            bar.row[r]:Hide()
        end
    end)
    bar:SetScript("OnShow", function()
        for r = 1, #bar.row do
            bar.row[r]:Show()
        end
    end)

    bar:SetWidth(1)
    bar:Hide()
    self:SetValue(bar, 0, true)

    return bar
end


-- New Status bars WIP

--[[ Internal functions ]]--

local function GetOffSets(leftAngle, rightAngle, height)
    local leftX, rightX = 0, 0
    -- These conditions keep the textures within the frame.
    -- Doing this removes the need to make a bunch of offsets elsewhere.
    leftX = (leftAngle == [[/]]) and height - 1 or 0
    rightX = (rightAngle == [[\]]) and -(height - 1) or 0
    return leftX, rightX
end

--[[ API Functions ]]--
-- This should be converted to AngleStatusBar once everything is finalized.
local ASB = {}

function ASB:SetStatusBarColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local row = self.bar.row
    for i = 1, #row do
        row[i]:SetTexture(r, g, b, a or 1)
    end
end

function ASB:SetBackgroundColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local row = self.row
    for i = 1, #row do
        row[i]:SetTexture(r, g, b, a or 1)
    end
end

-- If SetMinMaxValues is not called, default to min = 0, max = 1.
function ASB:SetMinMaxValues(min, max)
    --print("SetMinMaxValues", min, max)
    self.min = min
    self.max = max
end

-- This should except a percentage or discrete value.
function ASB:SetValue(value, ignoreSmooth)
    --print("SetValue", value, ignoreSmooth)
    if not self.min then self:SetMinMaxValues(0, 1) end
    if value > self.max then value = self.max end
    if self.info.smooth and not(dontSmooth) and not(ignoreSmooth) then
        SetBarValue(self, value)
    else
        SetBarPosition(self, value)
    end
end

-- In Blizz's API, SetReverseFill() is functionaly the same as our ReverseBarDirection.
-- Thus, in an effort to emulate the Blizz API as much as posible ReverseBarDirection has taken that name.
function ASB:SetReverseFill(val)
    --print("SetReverseFill", reverse)
    if val then
        self.growDirection = (self.growDirection == "LEFT") and "RIGHT" or "LEFT"
        self.bar:ClearAllPoints()
        self.bar:SetPoint(self.endPoint, self:GetParent(), self.endPoint, -(self.info.x), -1)
    else
        self.growDirection = self.origDirection
        self.bar:ClearAllPoints()
        self.bar:SetPoint(self.startPoint, self:GetParent(), self.startPoint, self.info.x, -1)
    end
end

-- Setting this to true will make the bars show full when at 0%.
function ASB:SetReversePercent(reverse)
    --print("SetReversePercent", reverse)
    self.reverse = reverse
    self:SetValue(self.value, true)
end

--[[ Frame Construction ]]--

local function CreateAngleBG(self, width, height, parent, info)
    --print("CreateAngleBG", self.unit, width, height, parent, info)
    local bg = CreateFrame("Frame", nil, parent)
    bg:SetSize(width, height)

    --[[
    local test = bg:CreateTexture(nil, "BACKGROUND", nil, -8)
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(bg)
    --]]

    local leftX, rightX = GetOffSets(info.leftAngle, info.rightAngle, height)
    local bgColor = nibRealUI.media.background

    --print("CreateBG", leftX, rightX)
    local top = bg:CreateTexture(nil, "BACKGROUND")
    top:SetTexture(0, 0, 0)
    top:SetHeight(1)
    top:SetPoint("TOPLEFT", leftX, 0)
    top:SetPoint("TOPRIGHT", rightX, 0)
    bg.top = top

    local maxRows = height - 2 --abs(leftX ~= 0 and leftX or rightX)
    local row, left, right = {}
    for i = 1, maxRows do
        row[i] = bg:CreateTexture(nil, "BACKGROUND")
        row[i]:SetTexture(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
        row[i]:SetHeight(1)
        if leftX == 0 then
            row[i]:SetPoint("TOPLEFT", top, "TOPLEFT", (i + 1), -i)
        else
            row[i]:SetPoint("TOPLEFT", top, "TOPLEFT", -(i - 1), -i)
        end
        if rightX == 0 then
            row[i]:SetPoint("TOPRIGHT", top, "TOPRIGHT", -(i + 1), -i)
        else
            row[i]:SetPoint("TOPRIGHT", top, "TOPRIGHT", (i - 1), -i)
        end
    end
    bg.row = row

    bottom = bg:CreateTexture(nil, "BACKGROUND")
    bottom:SetTexture(0, 0, 0)
    bottom:SetHeight(1)
    bottom:SetPoint("BOTTOMLEFT", -rightX, 0)
    bottom:SetPoint("BOTTOMRIGHT", -leftX, 0)
    bg.bottom = bottom

    left = bg:CreateTexture(nil, "BACKGROUND")
    left:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line]])
    left:SetVertexColor(0, 0, 0)
    if leftX == 0 then
        DrawRouteLine(left, bg, 2, -2, maxRows, -maxRows, 1, "TOPLEFT")
    else
        DrawRouteLine(left, bg, 2, 2, maxRows, maxRows, 1, "BOTTOMLEFT")
    end

    right = bg:CreateTexture(nil, "BACKGROUND")
    right:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line]])
    right:SetVertexColor(0, 0, 0)
    if rightX == 0 then
        DrawRouteLine(right, bg, -2, -2, -maxRows, -maxRows, 1, "TOPRIGHT")
    else
        DrawRouteLine(right, bg, -2, 2, -maxRows, maxRows, 1, "BOTTOMRIGHT")
    end
    return bg
end

local function CreateAngleBar(self, width, height, parent, info)
    --print("CreateAngleBar", self.unit, info)

    -- info is meta data for the status bar itself, regardles of what it's used for.
    info.maxWidth, info.minWidth, info.origDirection = width - 4, height - 2, info.growDirection
    info.startPoint = (info.growDirection == "LEFT") and "TOPRIGHT" or "TOPLEFT"
    info.endPoint = (info.startPoint == "TOPRIGHT") and "TOPLEFT" or "TOPRIGHT"

    local bar = CreateFrame("Frame", nil, parent)
    info.x = (info.startPoint == "TOPRIGHT") and -2 or 2
    bar:SetPoint(info.startPoint, parent, info.x, -1)
    bar:SetHeight(info.minWidth)

    --[[
    local test = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(bar)
    --]]
 
    local leftX, rightX = GetOffSets(info.leftAngle, info.rightAngle, height)

    if leftX == 0 then
        rightX = rightX + 2
    else
        leftX = leftX - 2
    end

    local row, prevRow = {}
    for i = 1, info.minWidth do
        -- Created from "parent" to ensure proper layering
        row[i] = parent:CreateTexture(nil, "ARTWORK")
        row[i]:SetHeight(1)
        if i == 1 then
            row[i]:SetPoint("TOPLEFT", bar, leftX, 0)
            row[i]:SetPoint("TOPRIGHT", bar, rightX, 0)
        else
            if leftX == 0 then
                row[i]:SetPoint("TOPLEFT", prevRow, 1, -1)
            else
                row[i]:SetPoint("TOPLEFT", prevRow, -1, -1)
            end
            if rightX == 0 then
                row[i]:SetPoint("TOPRIGHT", prevRow, -1, -1)
            else
                row[i]:SetPoint("TOPRIGHT", prevRow, 1, -1)
            end
        end
        prevRow = row[i]
    end
    bar.row = row

    bar:SetScript("OnHide", function()
        for r = 1, #row do
            row[r]:Hide()
        end
    end)
    bar:SetScript("OnShow", function()
        for r = 1, #row do
            row[r]:Show()
        end
    end)

    return bar, info
end

local function CreateAngleFrame(self, frameType, width, height, parent, info)
    local status, bar
    if frameType == "Frame" then
        status = CreateAngleBG(self, width, height, parent, info)
        status.SetBackgroundColor = ASB.SetBackgroundColor
        return status
    elseif frameType == "Bar" then
        bar, info = CreateAngleBar(self, width, height, parent, info)
        -- Do this to maintain a consistant hierarchy without having to use self.bar for direct manipulation.
        status = bar
    elseif frameType == "Status" then
        status = CreateAngleBG(self, width, height, parent, info)
        bar, info = CreateAngleBar(self, width, height, status, info)
    end

    local mt = getmetatable(status).__index
    for key, func in next, ASB do
        if not mt[key] then
            mt[key] = func
        end
    end

    status.bar = bar
    status.info = info
    status.value = 0
    status:SetValue(0, true)
    return status
end
oUF:RegisterMetaFunction("CreateAngleFrame", CreateAngleFrame) -- oUF magic

-------------
function AngleStatusBar:OnInitialize()
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    if ndb.settings.powerMode == 2 then
        dontSmooth = true
    end
end
