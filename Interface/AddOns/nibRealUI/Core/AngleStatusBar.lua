-- Lua Globals --
local _G = _G
local min, max, abs, floor = _G.math.min, _G.math.max, _G.math.abs, _G.math.floor
local tinsert, next, type = _G.table.insert, _G.next, _G.type

-- WoW Globals --
local CreateFrame, UIParent = _G.CreateFrame, _G.UIParent

-- Libs --
local oUF = oUFembed

-- RealUI --
local RealUI =  _G.RealUI
local db, ndb, ndbc
local isTest = RealUI.isTest
local Lerp = RealUI.Lerp

local MODNAME = "AngleStatusBar"
local AngleStatusBar = RealUI:CreateModule(MODNAME)

local bars = {}
local dontSmooth, smooth
local smoothing = {}
local function debug(self, ...)
    if self.debug then
        -- self.debug should be a string describing what the bar is.
        -- eg. "playerHealth", "targetAbsorbs", etc
        AngleStatusBar:debug(self.debug, ...)
    end
end

local function SetBarPosition(self, value)
    local metadata = bars[self]
    if metadata then
        metadata.value = value
        local width
        -- Take the value, and adjust it to within the bounds of the bar.
        if metadata.reverse then
            -- This makes `width` smaller when `value` gets larger and vice versa.
            width = Lerp(metadata.maxWidth, metadata.minWidth, (value / metadata.maxVal))
        else
            width = Lerp(metadata.minWidth, metadata.maxWidth, (value / metadata.maxVal))
        end
        self.bar:SetWidth(width)
        debug(self, "width", width, metadata.minWidth, metadata.maxWidth)
        debug(self, "value", value, metadata.minVal, metadata.maxVal)

        --value = floor(value * metadata.maxVal) / metadata.maxVal
        --debug(self, "Floored", value, metadata.reverse)
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
        debug(self, "Floored", self:GetParent():GetParent().unit, self.reverse, value)
        self:SetShown((not(self.reverse) and (value < 1)) or (self.reverse and (value > 0)))
    end
end

local function SetBarValue(self, value)
    local metadata = bars[self]
    if metadata then
        if value ~= metadata.value then
            smoothing[self] = value
        else
            SetBarPosition(self, value)
            smoothing[self] = nil
        end
    else
        value = value + (1 / self.fullWidth)
        if value ~= self.value then
            smoothing[self] = value
        else
            SetBarPosition(self, value)
            smoothing[self] = nil
        end
    end
end

local smoothUpdateFrame = CreateFrame("Frame")
smoothUpdateFrame:SetScript("OnUpdate", function()
    local limit = 30 / _G.GetFramerate()
    for bar, per in next, smoothing do
        local metadata = bars[bar]
        local maxWidth = metadata and metadata.maxWidth or bar.fullWidth
        local setPer = per * maxWidth
        local setCur = (metadata and metadata.value or bar.value) * maxWidth
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

--[[ Internal Functions ]]--
local function GetOffSets(leftAngle, rightAngle, height)
    local leftX, rightX = 0, 0
    -- These conditions keep the textures within the frame.
    -- Doing this removes the need to make a bunch of offsets elsewhere.
    leftX = (leftAngle == [[/]]) and height - 1 or 0
    rightX = (rightAngle == [[\]]) and -(height - 1) or 0
    return leftX, rightX
end

local function DrawLine(tex, anchor, x, ofs, leftX, rightX)
    if leftX == 0 then
        tex:SetVertexColor(1, 0, 0)
        RealUI:DrawLine(tex, anchor, x, -1, ofs, -ofs, 16, "TOPLEFT")
    else
        tex:SetVertexColor(1, 1, 0)
        RealUI:DrawLine(tex, anchor, x, 1, ofs, ofs, 16, "BOTTOMLEFT")
    end
    if rightX then
        if rightX == 0 then
            tex:SetVertexColor(0, 1, 0)
            RealUI:DrawLine(tex, anchor, -x, -1, -ofs, -ofs, 16, "TOPRIGHT")
        else
            tex:SetVertexColor(0, 1, 1)
            RealUI:DrawLine(tex, anchor, -x, 1, -ofs, ofs, 16, "BOTTOMRIGHT")
        end
    end
end

--[[ API Functions ]]--
local api = {
    SetStatusBarColor = function(self, r, g, b, a)
        if type(r) == "table" then
            r, g, b, a = r[1], r[2], r[3], r[4]
        end
        local row = self.bar.row
        for i = 1, #row do
            if isTest then
                row[i]:SetColorTexture(r, g, b, a or 1)
            else
                row[i]:SetTexture(r, g, b, a or 1)
            end
        end
    end,
    SetBackgroundColor = function(self, r, g, b, a)
        if type(r) == "table" then
            r, g, b, a = r[1], r[2], r[3], r[4]
        end
        local tex = self.col or self.row
        for i = 1, #tex do
            if self.col then
                tex[i]:SetVertexColor(r, g, b, a or 1)
            else
                if isTest then
                    tex[i]:SetColorTexture(r, g, b, a or 1)
                else
                    tex[i]:SetTexture(r, g, b, a or 1)
                end
            end
        end
    end,

    SetMinMaxValues = function(self, minVal, maxVal)
        debug(self, "SetMinMaxValues", minVal, maxVal)
        local metadata = bars[self]
        metadata.minVal = minVal
        metadata.maxVal = maxVal
    end,
    GetMinMaxValues = function(self)
        debug(self, "GetMinMaxValues")
        local metadata = bars[self]
        return metadata.minVal, metadata.maxVal
    end,

    -- This should except a percentage or discrete value.
    SetValue = function(self, value, ignoreSmooth)
        debug(self, "SetValue", value, ignoreSmooth)
        local metadata = bars[self]
        if value == metadata.value then return end
        
        if not metadata.minVal then self:SetMinMaxValues(0, value) end
        if value > metadata.maxVal then value = metadata.maxVal end
        if metadata.smooth and not(ignoreSmooth) then
            SetBarValue(self, value)
        else
            SetBarPosition(self, value)
        end
    end,

    -- Setting this to true will make the bars fill from right to left
    SetReverseFill = function(self, val)
        debug(self, "SetReverseFill", self, self.bar, val)
        local metadata = bars[self]
        self.bar:ClearAllPoints()
        if val then
            self.bar:SetPoint(metadata.endPoint, self, -2, 0)
        else
            self.bar:SetPoint(metadata.startPoint, self, 2, 0)
        end
    end,
    GetReverseFill = function(self)
        debug(self, "GetReverseFill", self.bar:GetPoint())
        return self.bar:GetPoint() == bars[self].endPoint
    end,

    -- Setting this to true will make the bars show full when at 0%.
    SetReversePercent = function(self, reverse)
        debug(self, "SetReversePercent", reverse)
        local metadata = bars[self]
        metadata.reverse = reverse
        SetBarPosition(self, metadata.value)
    end,
    GetReversePercent = function(self)
        debug(self, "GetReversePercent", self.bar:GetPoint())
        return bars[self].reverse
    end
}

--[[ Frame Construction ]]--
local function CreateAngleBG(self, width, height, parent, info)
    debug(info, "CreateAngleBG", width, height, parent, info)
    local bg = CreateFrame("Frame", nil, parent)
    bg:SetSize(width, height)

    --[[
    local test = bg:CreateTexture(nil, "BACKGROUND", nil, -8)
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(bg)
    --]]

    local leftX, rightX = GetOffSets(info.leftAngle, info.rightAngle, height)
    local bgColor = RealUI.media.background

    debug(info, "CreateBG", leftX, rightX)
    local top = bg:CreateTexture(nil, "BORDER")
    if isTest then
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

    local maxRows = height - 2 --abs(leftX ~= 0 and leftX or rightX)
    local maxCols = width - (height + 1) --width - maxRows
    debug(info, "CreateRows", maxRows, maxCols)
    if maxRows <= maxCols then
        local row = {}
        for i = 1, maxRows do
            local tex = bg:CreateTexture(nil, "BACKGROUND")
            -- tex:SetTexture(bgColor[1], bgColor[2], bgColor[3], bgColor[4])
            if isTest then
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
            _G.tinsert(row, tex)
        end
        bg.row = row
    else
        local col = {}
        for i = 1, maxCols do
            local ofs = maxRows + 1
            local tex = bg:CreateTexture(nil, "BACKGROUND")
            tex:SetVertexColor(bgColor[1], bgColor[2], bgColor[3])
            --DrawLine(tex, bg, i + 1, ofs, leftX)
            if leftX == 0 then
                tex:SetVertexColor(1, 0, 0)
                RealUI:DrawLine(tex, bg, i + 1, -1, (ofs + i), -ofs, 16, "TOPLEFT")
            else
                tex:SetVertexColor(1, 1, 0)
                RealUI:DrawLine(tex, bg, -(i + 1), -1, -(ofs + i), -ofs, 16, "TOPRIGHT")
            end
            --[[if rightX == 0 then
                tex:SetVertexColor(0, 1, 0)
                RealUI:DrawLine(tex, bg, 0, 0, -ofs, -ofs, 16, "TOPRIGHT")
            else
                tex:SetVertexColor(0, 1, 1)
                RealUI:DrawLine(tex, bg, 0, 0, -ofs, ofs, 16, "BOTTOMRIGHT")
            end]]
            _G.tinsert(col, tex)
        end
        bg.col = col
    end

    local ofs = maxRows + 1
    local bottom = bg:CreateTexture(nil, "BORDER")
    if isTest then
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

    if isTest then
        local left = bg:CreateLine(nil, "BORDER")
        left:SetColorTexture(0, 0, 0)
        left:SetThickness(16)
        if leftX == 0 then
            --left:SetColorTexture(1, 0, 0)
            left:SetStartPoint("TOPLEFT", 1, -1)
            left:SetEndPoint("TOPLEFT", ofs, -ofs)
        else
            --left:SetColorTexture(1, 1, 0)
            left:SetStartPoint("BOTTOMLEFT", 1, 1)
            left:SetEndPoint("BOTTOMLEFT", ofs, ofs)
        end
        left:Show()

        local right = bg:CreateLine(nil, "BORDER")
        right:SetColorTexture(0, 0, 0)
        right:SetThickness(16)
        if rightX == 0 then
            --right:SetColorTexture(0, 1, 0)
            right:SetStartPoint("TOPRIGHT", -1, -1)
            right:SetEndPoint("TOPRIGHT", -ofs, -ofs)
        else
            --right:SetColorTexture(0, 1, 1)
            right:SetStartPoint("BOTTOMRIGHT", -1, 1)
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

local function CreateAngleBar(self, width, height, parent, info)
    debug(info, "CreateAngleBar", width, height, parent, info)

    -- info is meta data for the status bar itself, regardles of what it's used for.
    info.maxWidth, info.minWidth = width - 4, height - 2
    info.startPoint = "TOPLEFT"
    info.endPoint = "TOPRIGHT"

    local bar = CreateFrame("Frame", nil, parent)
    debug(info, "CreateBar", bar, parent)
    bar:SetPoint(info.startPoint, parent, 2, 0)
    bar:SetHeight(info.minWidth)

    --[[
    local test = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    if isTest then
        test:SetColorTexture(1, 1, 1, 0.1)
    else
        test:SetTexture(1, 1, 1, 0.1)
    end
    test:SetAllPoints(bar)
    --]]
 
    local leftX, rightX = GetOffSets(info.leftAngle, info.rightAngle, info.minWidth)

    local row, prevRow = {}
    for i = 1, info.minWidth do
        row[i] = bar:CreateTexture(nil, "ARTWORK")
        row[i]:SetHeight(1)
        if i == 1 then
            row[i]:SetPoint("TOPLEFT", bar, leftX, -1)
            row[i]:SetPoint("TOPRIGHT", bar, rightX, -1)
        else
            if leftX == 0 then
                row[i]:SetPoint("TOPLEFT", prevRow, 1, -1) -- \
            else
                row[i]:SetPoint("TOPLEFT", prevRow, -1, -1) -- /
            end
            if rightX == 0 then
                row[i]:SetPoint("TOPRIGHT", prevRow, -1, -1) -- /
            else
                row[i]:SetPoint("TOPRIGHT", prevRow, 1, -1) -- \
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
        status.SetBackgroundColor = api.SetBackgroundColor
        status:SetFrameLevel(5)
        return status
    elseif frameType == "Bar" then
        bar, info = CreateAngleBar(self, width, height, parent, info)
        -- Do this to maintain a consistant hierarchy without having to use self.bar for direct manipulation.
        status = bar
        status:SetFrameLevel(4)
    elseif frameType == "Status" then
        status = CreateAngleBG(self, width, height, parent, info)
        bar, info = CreateAngleBar(self, width, height, status, info)
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
oUF:RegisterMetaFunction("CreateAngleFrame", CreateAngleFrame) -- oUF magic

local testBars -- /run RealUI:TestASB()
function RealUI:TestASB(reverseFill, reversePer)
    testBars = {}
    local info = {
        {
            leftAngle = [[\]],
            rightAngle = [[\]],
            debug = "testLeftLeft"
        },
        {
            leftAngle = [[\]],
            rightAngle = [[/]],
            debug = "testLeftRight"
        },
        {
            leftAngle = [[/]],
            rightAngle = [[\]],
            debug = "testRightLeft"
        },
        {
            leftAngle = [[/]],
            rightAngle = [[/]],
            debug = "testRightRight"
        },
    }
    for i = 1, #info do
        local barInfo = info[i]
        local test = CreateAngleFrame(UIParent, "Status", 200, 8, UIParent, barInfo)
        test:SetMinMaxValues(0, 200)
        test:SetValue(10, true)
        test:SetStatusBarColor(1, 0, 0, 1)
        if reverseFill then
            test:SetReverseFill(true)
        end
        if reversePer then
            test:SetReversePercent(true)
        end
        test:SetPoint("TOP", UIParent, "CENTER", 0, -(10 * i))
        tinsert(testBars, test)
        test:Show()
        test.bar:Show()
    end
end

-- /run RealUI:TestASBSet("Value", 200)
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
    ndbc = RealUI.db.char

    if ndb.settings.powerMode == 2 then -- Economy
        smooth = false
        dontSmooth = true
    else
        smooth = true
    end
end
