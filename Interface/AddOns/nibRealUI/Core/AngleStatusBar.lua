local _, private = ...

-- Lua Globals --
local _G = _G
local abs, floor = _G.math.abs, _G.math.floor
local tinsert, next, type = _G.table.insert, _G.next, _G.type

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local ndb

local MODNAME = "AngleStatusBar"
local AngleStatusBar = RealUI:NewModule(MODNAME)

local isBeta = RealUI.isBeta
local Lerp = RealUI.Lerp

local bars = {}
local dontSmooth, smooth
local function debug(isDebug, ...)
    if isDebug then
        -- isDebug should be a string describing what the bar is.
        -- eg. "playerHealth", "targetAbsorbs", etc
        AngleStatusBar:debug(isDebug, ...)
    end
end

local FrameDeltaLerp
if isBeta then
    FrameDeltaLerp = _G.FrameDeltaLerp
else
    local function GetTickTime()
        return RealUI.Round((1000 / _G.GetFramerate())) / 1000
    end
    local TARGET_FRAME_PER_SEC = 60.0
    function FrameDeltaLerp(startValue, endValue, amount)
        return Lerp(startValue, endValue, RealUI.Clamp(amount * GetTickTime() * TARGET_FRAME_PER_SEC, 0.0, 1.0))
    end
end

local smoothBars = {}

local function SetBarPosition(self, value)
    local metadata = bars[self]
    if metadata then
        metadata.value = value
        local width
        debug(self.debug, "value", value, metadata.minVal, metadata.maxVal)
        -- Take the value, and adjust it to within the bounds of the bar.
        if metadata.reverse then
            -- This makes `width` smaller when `value` gets larger and vice versa.
            width = metadata.maxVal == 0 and metadata.maxWidth or Lerp(metadata.maxWidth, metadata.minWidth, (value / metadata.maxVal))
        else
            width = metadata.maxVal == 0 and metadata.minWidth or Lerp(metadata.minWidth, metadata.maxWidth, (value / metadata.maxVal))
        end
        self.bar:SetWidth(width)
        debug(self.debug, "width", width, metadata.minWidth, metadata.maxWidth)

        --value = floor(value * metadata.maxVal) / metadata.maxVal
        --debug(self.debug, "Floored", value, metadata.reverse)
        debug(self.debug, "show", metadata.reverse and value < metadata.maxVal or value > metadata.minVal)
        if metadata.reverse then
            self.bar:SetShown(value < metadata.maxVal)
        else
            self.bar:SetShown(value > metadata.minVal)
        end
    else
        self.value = value
        if not self.reverse then
            self:SetWidth(self.fullWidth * (1 - value))
        else
            self:SetWidth(self.fullWidth * value)
        end

        value = floor(value * 100) / 100
        debug(self.debug, "Floored", self:GetParent():GetParent().unit, self.reverse, value)
        self:SetShown((not(self.reverse) and (value < 1)) or (self.reverse and (value > 0)))
    end
end

local function SetBarValue(self, value)
    value = value + (1 / self.fullWidth)
    if value ~= self.value then
        smoothBars[self] = value
    else
        SetBarPosition(self, value)
        smoothBars[self] = nil
    end
end

local function ProcessSmoothStatusBars()
    for bar, targetValue in next, smoothBars do
        local newValue = FrameDeltaLerp(bar.value or bars[bar].value, targetValue, .25)
        if abs(newValue - targetValue) < .005 then
            smoothBars[bar] = nil
        end

        SetBarPosition(bar, newValue)
    end
end
_G.C_Timer.NewTicker(0, ProcessSmoothStatusBars)

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
        if isBeta then
            bar.row[i]:SetColorTexture(r, g, b, a or 1)
        else
            bar.row[i]:SetTexture(r, g, b, a or 1)
        end
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

function AngleStatusBar:NewBar(parent, x, y, width, height, typeStart, typeEnd, direction, smoothFill)
    local bar = _G.CreateFrame("Frame", nil, parent)
    bar.fullWidth, bar.typeStart, bar.typeEnd, bar.direction, bar.value, bar.smooth = width, typeStart, typeEnd, direction, 1, smoothFill or true
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


-- New Status bars

--[[ Internal Functions ]]--
local function GetOffSets(leftAngle, rightAngle, height)
    -- These conditions keep the textures within the frame.
    -- Doing this removes the need to make a bunch of offsets elsewhere.
    local leftX = (leftAngle == [[/]]) and height - 1 or 0
    local rightX = (rightAngle == [[\]]) and -(height - 1) or 0
    return leftX, rightX
end

--[[ API Functions ]]--
local api = {}

function api:SetStatusBarColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local row = self.bar.row
    for i = 1, #row do
        if isBeta then
            row[i]:SetColorTexture(r, g, b, a or 1)
        else
            row[i]:SetTexture(r, g, b, a or 1)
        end
    end
end
function api:SetBackgroundColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local lines = self.lines
    for i = 1, #lines do
        if isBeta then
            lines[i]:SetColorTexture(r, g, b, a or 1)
        else
            if lines.isCols then
                lines[i]:SetVertexColor(r, g, b, a or 1)
            else
                lines[i]:SetTexture(r, g, b, a or 1)
            end
        end
    end
end

function api:SetMinMaxValues(minVal, maxVal)
    debug(self.debug, "SetMinMaxValues", minVal, maxVal)
    local metadata = bars[self]

    local targetValue = smoothBars[self]
    if targetValue then
        local ratio = 1
        if maxVal ~= 0 and metadata.maxVal and metadata.maxVal ~= 0 then
            ratio = maxVal / (metadata.maxVal or maxVal)
        end

        smoothBars[self] = targetValue * ratio
    end

    metadata.minVal = minVal
    metadata.maxVal = maxVal
end
function api:GetMinMaxValues()
    debug(self.debug, "GetMinMaxValues")
    local metadata = bars[self]
    return metadata.minVal, metadata.maxVal
end

-- This should except a percentage or discrete value.
function api:SetValue(value, ignoreSmooth)
    debug(self.debug, "SetValue", value, ignoreSmooth)
    local metadata = bars[self]
    if value == metadata.value then return end
    
    if not metadata.minVal then self:SetMinMaxValues(0, value) end
    if value > metadata.maxVal then value = metadata.maxVal end
    if metadata.smooth and not(ignoreSmooth) then
        smoothBars[self] = value
    else
        SetBarPosition(self, value)
    end
end

-- Setting this to true will make the bars fill from right to left
function api:SetReverseFill(val)
    debug(self.debug, "SetReverseFill", val)
    local metadata = bars[self]
    self.bar:ClearAllPoints()
    if val then
        self.bar:SetPoint(metadata.endPoint, self, -2, 0)
    else
        self.bar:SetPoint(metadata.startPoint, self, 2, 0)
    end
end
function api:GetReverseFill()
    debug(self.debug, "GetReverseFill", self.bar:GetPoint())
    return self.bar:GetPoint() == bars[self].endPoint
end

-- Setting this to true will make the bars show full when at 0%.
function api:SetReversePercent(reverse)
    debug(self.debug, "SetReversePercent", reverse)
    local metadata = bars[self]
    metadata.reverse = reverse
    SetBarPosition(self, metadata.value)
end
function api:GetReversePercent()
    debug(self.debug, "GetReversePercent", self.bar:GetPoint())
    return bars[self].reverse
end

--[[ Frame Construction ]]--
local function CreateAngleBG(width, height, parent, info)
    debug(info.debug, "CreateAngleBG", width, height, parent, info)
    local bg = _G.CreateFrame("Frame", nil, parent)
    bg:SetSize(width, height)

    --[[
    local test = bg:CreateTexture(nil, "BACKGROUND", nil, -8)
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(bg)
    --]]

    local leftX, rightX = GetOffSets(info.leftAngle, info.rightAngle, height)
    local bgColor = RealUI.media.background

    debug(info.debug, "CreateBG", leftX, rightX)
    local top = bg:CreateTexture(nil, "BORDER")
    if isBeta then
        top:SetColorTexture(0, 0, 0)
    else
        top:SetTexture(0, 0, 0)
    end
    top:SetHeight(1)
    top:SetPoint("TOPLEFT", leftX, 0)
    top:SetPoint("TOPRIGHT", rightX, 0)
    bg.top = top

    --[=[
    local top = bg:CreateTexture(nil, "BORDER")
    top:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line]])
    top:SetVertexColor(0, 0, 0)
    RealUI:DrawLine(top, bg, (leftX), 0, (width - rightX), 0, 8, "TOPLEFT")
    bg.top = top
    ]=]

    bg.lines = {}
    local maxRows, maxCols = height - 2, width - (height + 1)
    if maxRows <= maxCols then
        debug(info.debug, "CreateRows", maxRows, maxCols)
        for i = 1, maxRows do
            local tex = bg:CreateTexture(nil, "BACKGROUND")
            -- tex:SetTexture(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
            if isBeta then
                tex:SetColorTexture(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
            else
                tex:SetTexture(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
            end
            tex:SetHeight(1)
            if leftX == 0 then
                tex:SetPoint("TOPLEFT", top, "TOPLEFT", (i + 1), -i)
            else
                tex:SetPoint("TOPLEFT", top, "TOPLEFT", -(i - 1), -i)
            end
            if rightX == 0 then
                tex:SetPoint("TOPRIGHT", top, "TOPRIGHT", -(i + 1), -i)
            else
                tex:SetPoint("TOPRIGHT", top, "TOPRIGHT", (i - 1), -i)
            end
            _G.tinsert(bg.lines, tex)
        end
    else
        debug(info.debug, "CreateColumns", maxRows, maxCols)
        bg.lines.isCols = true
        for i = 1, maxCols do
            if isBeta then
                local ofs = height * 0.64
                local idx = i * 0.64
                local tex = bg:CreateLine(nil, "BACKGROUND")
                tex:SetColorTexture(bgColor[1], bgColor[2], bgColor[3])
                tex:SetThickness(0.5)
                if leftX == 0 then
                    tex:SetColorTexture(1, 0, 0)
                    tex:SetStartPoint("TOPLEFT", idx, 0)
                    tex:SetEndPoint("BOTTOMLEFT", ofs + idx, 0)
                else
                    tex:SetColorTexture(1, 1, 0)
                    tex:SetStartPoint("BOTTOMLEFT", idx, 0)
                    tex:SetEndPoint("TOPLEFT", ofs + idx, 0)
                end
                _G.tinsert(bg.lines, tex)
            else
                local ofs = maxRows + 1
                local tex = bg:CreateTexture(nil, "BACKGROUND")
                tex:SetVertexColor(bgColor[1], bgColor[2], bgColor[3])
                if leftX == 0 then
                    tex:SetVertexColor(1, 0, 0)
                    RealUI:DrawLine(tex, bg, i + 1, -1, (ofs + i), -ofs, 16, "TOPLEFT")
                else
                    tex:SetVertexColor(1, 1, 0)
                    RealUI:DrawLine(tex, bg, -(i + 1), -1, -(ofs + i), -ofs, 16, "TOPRIGHT")
                end
                _G.tinsert(bg.lines, tex)
            end
        end
    end

    local ofs = maxRows + 1
    local bottom = bg:CreateTexture(nil, "BORDER")
    if isBeta then
        bottom:SetColorTexture(0, 0, 0)
    else
        bottom:SetTexture(0, 0, 0)
    end
    bottom:SetHeight(1)
    if leftX == -rightX then
        if leftX == 0 then -- \ /
            bottom:SetPoint("BOTTOMLEFT", ofs, 0)
            bottom:SetPoint("BOTTOMRIGHT", -ofs, 0)
        else -- / \
            bottom:SetPoint("BOTTOMLEFT", 0, 0)
            bottom:SetPoint("BOTTOMRIGHT", 0, 0)
        end
    else
        bottom:SetPoint("BOTTOMLEFT", -rightX, 0)
        bottom:SetPoint("BOTTOMRIGHT", -leftX, 0)
    end
    bg.bottom = bottom

    if isBeta then
        ofs = ofs * 0.65
        local left = bg:CreateLine(nil, "BORDER")
        left:SetColorTexture(0, 0, 0)
        left:SetThickness(0.5)
        if leftX == 0 then
            --left:SetColorTexture(1, 0, 0)
            left:SetStartPoint("TOPLEFT", 0, 0)
            left:SetEndPoint("TOPLEFT", ofs, -ofs)
        else
            --left:SetColorTexture(1, 1, 0)
            left:SetStartPoint("BOTTOMLEFT", 0, 0)
            left:SetEndPoint("BOTTOMLEFT", ofs, ofs)
        end
        left:Show()

        local right = bg:CreateLine(nil, "BORDER")
        right:SetColorTexture(0, 0, 0)
        right:SetThickness(0.5)
        if rightX == 0 then
            --right:SetColorTexture(0, 1, 0)
            right:SetStartPoint("TOPRIGHT", 0, 0)
            right:SetEndPoint("TOPRIGHT", -ofs, -ofs)
        else
            --right:SetColorTexture(0, 1, 1)
            right:SetStartPoint("BOTTOMRIGHT", 0, 0)
            right:SetEndPoint("BOTTOMRIGHT", -ofs, ofs)
        end
        right:Show()
    else
        local left = bg:CreateTexture(nil, "BORDER")
        left:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line]])
        left:SetVertexColor(0, 0, 0)
        if leftX == 0 then
            --left:SetVertexColor(1, 0, 0)
            RealUI:DrawLine(left, bg, 1, -1, ofs, -ofs, 16, "TOPLEFT")
            --DrawRouteLine(left, bg, 1, -1, ofs, -ofs, 16, "TOPLEFT")
        else
            --left:SetVertexColor(1, 1, 0)
            RealUI:DrawLine(left, bg, 1, 1, ofs, ofs, 16, "BOTTOMLEFT")
            --DrawRouteLine(left, bg, 1, 1, ofs, ofs, 16, "BOTTOMLEFT")
        end

        local right = bg:CreateTexture(nil, "BORDER")
        right:SetTexture([[Interface\AddOns\nibRealUI_Init\textures\line]])
        right:SetVertexColor(0, 0, 0)
        if rightX == 0 then
            --right:SetVertexColor(0, 1, 0)
            RealUI:DrawLine(right, bg, -1, -1, -ofs, -ofs, 16, "TOPRIGHT")
            --DrawRouteLine(right, bg, -1, -1, -ofs, -ofs, 16, "TOPRIGHT")
        else
            --right:SetVertexColor(0, 1, 1)
            RealUI:DrawLine(right, bg, -1, 1, -ofs, ofs, 16, "BOTTOMRIGHT")
            --DrawRouteLine(right, bg, -1, 1, -ofs, ofs, 16, "BOTTOMRIGHT")
        end
    end
    return bg
end

local function CreateAngleBar(width, height, parent, info)
    debug(info.debug, "CreateAngleBar", width, height, parent, info)

    -- info is meta data for the status bar itself, regardles of what it's used for.
    info.maxWidth, info.minWidth = width - 4, height - 2
    info.startPoint = "TOPLEFT"
    info.endPoint = "TOPRIGHT"

    local bar = _G.CreateFrame("Frame", nil, parent)
    debug(info.debug, "CreateBar", bar, parent)
    bar:SetPoint(info.startPoint, parent, 2, 0)
    bar:SetHeight(info.minWidth)
    bar:SetScript("OnSizeChanged", function(self, barWidth, barHeight)
        if self.isTrapezoid then
            debug(info.debug, "OnSizeChanged", barWidth)
            local row = self.row
            local prevWidth = barWidth
            for i = 1, #row do
                local rowWidth = row[i]:GetWidth()
                debug(info.debug, i, rowWidth, prevWidth, rowWidth > prevWidth)
                if rowWidth > prevWidth then
                    row[i]:Hide()
                else
                    row[i]:Show()
                    prevWidth = rowWidth
                end
            end
        end
    end)

    --[[
    local test = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    if isBeta then
        test:SetColorTexture(1, 1, 1, 0.2)
    else
        test:SetTexture(1, 1, 1, 0.1)
    end
    test:SetAllPoints(bar)
    --]]
 
    local leftX, rightX = GetOffSets(info.leftAngle, info.rightAngle, info.minWidth)

    local row, prevRow = {}
    bar.isTrapezoid = leftX == abs(rightX)
    debug(info.debug, "isTrapezoid", bar.isTrapezoid, leftX, rightX)
    for i = 1, info.minWidth do
        local tex = bar:CreateTexture(nil, "ARTWORK")
        tex:SetHeight(1)
        if bar.isTrapezoid and leftX > 0 then
            if i == 1 then
                tex:SetPoint("BOTTOMLEFT", bar, 0, -1)
                tex:SetPoint("BOTTOMRIGHT", bar, 0, -1)
            else
                tex:SetPoint("BOTTOMLEFT", prevRow, 1, 1) -- /
                tex:SetPoint("BOTTOMRIGHT", prevRow, -1, 1) -- \
            end
        else
            if i == 1 then
                tex:SetPoint("TOPLEFT", bar, leftX, -1)
                tex:SetPoint("TOPRIGHT", bar, rightX, -1)
            else
                if leftX == 0 then
                    tex:SetPoint("TOPLEFT", prevRow, 1, -1) -- \
                else
                    tex:SetPoint("TOPLEFT", prevRow, -1, -1) -- /
                end
                if rightX == 0 then
                    tex:SetPoint("TOPRIGHT", prevRow, -1, -1) -- /
                else
                    tex:SetPoint("TOPRIGHT", prevRow, 1, -1) -- \
                end
            end
        end
        prevRow = tex
        row[i] = tex
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

function AngleStatusBar:CreateAngleFrame(frameType, width, height, parent, info)
    local status, bar
    if frameType == "Frame" then
        status = CreateAngleBG(width, height, parent, info)
        status.SetBackgroundColor = api.SetBackgroundColor
        status:SetFrameLevel(5)
        return status
    elseif frameType == "Bar" then
        bar, info = CreateAngleBar(width, height, parent, info)
        -- Do this to maintain a consistant hierarchy without having to use self.bar for direct manipulation.
        status = bar
        status:SetFrameLevel(4)
    elseif frameType == "Status" then
        status = CreateAngleBG(width, height, parent, info)
        bar, info = CreateAngleBar(width, height, status, info)
        status:SetFrameLevel(2)
        bar:SetFrameLevel(3)
    end

    for key, func in next, api do
        status[key] = func
    end

    status.bar = bar
    status.debug = info.debug
    bars[status] = {
        smooth = info.smooth ~= nil and info.smooth or smooth,
        startPoint = info.startPoint,
        endPoint = info.endPoint,
        minWidth = info.minWidth,
        maxWidth = info.maxWidth,
        value = 0
    }
    --status:SetValue(0, true)
    return status
end
oUF:RegisterMetaFunction("CreateAngleFrame", AngleStatusBar.CreateAngleFrame) -- oUF magic

local testBars -- /run RealUI:TestASB()
function RealUI:TestASB(reverseFill, reversePer)
    testBars = {}
    local info = {
        {
            leftAngle = [[\]],
            rightAngle = [[\]],
            --debug = "testLeftLeft"
        },
        {
            leftAngle = [[\]],
            rightAngle = [[/]],
            --debug = "testLeftRight"
        },
        {
            leftAngle = [[/]],
            rightAngle = [[\]],
            debug = "testRightLeft"
        },
        {
            leftAngle = [[/]],
            rightAngle = [[/]],
            --debug = "testRightRight"
        },
    }
    local width, height = 100, 10
    local val, minVal, maxVal = 10, 0, 250
    for i = 1, #info do
        local barInfo = info[i]
        local test = AngleStatusBar:CreateAngleFrame("Status", width, height, _G.UIParent, barInfo)
        test:SetMinMaxValues(minVal, maxVal)
        test:SetValue(val, true)
        test:SetStatusBarColor(1, 0, 0, 1)
        test:SetReverseFill(reverseFill)
        test:SetReversePercent(reversePer)
        if i == 1 then
            test:SetPoint("TOP", _G.UIParent, "CENTER", 0, 0)
        else
            test:SetPoint("TOP", testBars[i-1], "BOTTOM", 0, -10)
        end
        tinsert(testBars, test)
        --test:Show()
        --test.bar:Show()
    end

    -- Normal status bar as a baseline
    local status = _G.CreateFrame("StatusBar", "RealUITestStatus", _G.UIParent)
    status:SetPoint("TOP", testBars[#info], "BOTTOM", 0, -10)
    status:SetSize(width, height)

    local bg = status:CreateTexture(nil, "BACKGROUND")
    if isBeta then
        bg:SetColorTexture(1, 1, 1, 0.5)
    else
        bg:SetTexture(1, 1, 1, 0.5)
    end
    bg:SetAllPoints(status)

    local tex = status:CreateTexture(nil, "ARTWORK")
    local color = {1,0,0}
    if isBeta then
        tex:SetColorTexture(color[1], color[2], color[3])
    else
        tex:SetTexture(color[1], color[2], color[3])
    end
    status:SetStatusBarTexture(tex)

    status:SetMinMaxValues(minVal, maxVal)
    status:SetValue(val)
    status:SetReverseFill(reverseFill)

    tinsert(testBars, status)
end

-- /run RealUI:TestASBSet("Value", 50)
-- /run RealUI:TestASBSet("ReverseFill", true)
-- /run RealUI:TestASBSet("ReversePercent", true)
function RealUI:TestASBSet(method, ...)
    for i = 1, #testBars do
        local bar = testBars[i]
        bar["Set"..method](bar, ...)
    end
end

-------------
function AngleStatusBar:OnInitialize()
    ndb = RealUI.db.profile

    if ndb.settings.powerMode == 2 then -- Economy
        smooth = false
        dontSmooth = true
    else
        smooth = true
    end
end
