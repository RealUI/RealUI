local _, private = ...

-- Lua Globals --
local abs = _G.math.abs
local tinsert, next, type = _G.table.insert, _G.next, _G.type

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local MODNAME = "AngleStatusBar"
local AngleStatusBar = RealUI:NewModule(MODNAME)

local bars = {}
local function debug(isDebug, ...) -- luacheck: ignore
    if isDebug then
        -- debug(self:GetName(), ...)
        return AngleStatusBar:debug(isDebug, ...)
    end
end

local Lerp = _G.Lerp
local function SetBarValue(self, value)
    local meta = bars[self]
    meta.value = value
    local isMaxed, isReversePerc, isReverseFill = meta.maxVal == 0, self:GetReversePercent(), self:GetReverseFill()
    local minWidth, maxWidth, width = meta.minWidth, meta.maxWidth
    local left, right, top, bottom = 0, 1, 0, 1

    -- Take the value, and adjust it to within the bounds of the bar.
    if isReversePerc then
        if isMaxed then
            width = maxWidth
        else
            -- This makes `width` smaller when `value` gets larger and vice versa.
            width = Lerp(maxWidth, minWidth, (value / meta.maxVal))
            if isReverseFill then
                left = Lerp(0, 1, (value / meta.maxVal))
            else
                right = Lerp(1, 0, (value / meta.maxVal))
            end
        end
    else
        if isMaxed then
            width = minWidth
        else
            width = Lerp(minWidth, maxWidth, (value / meta.maxVal))
            if isReverseFill then
                left = Lerp(1, 0, (value / meta.maxVal))
            else
                right = Lerp(0, 1, (value / meta.maxVal))
            end
        end
    end

    self.fill:SetWidth(width)
    if meta.isTrapezoid then
        if width < (minWidth * 2) then
            local vertexOfs = width / 2
            self.fill:SetPoint(meta.isTrapezoid, 0, (minWidth - vertexOfs) * (meta.isTrapezoid == "TOP" and -1 or 1))
            self.fill:SetVertexOffset(meta.leftVertex, vertexOfs, 0)
            self.fill:SetVertexOffset(meta.rightVertex, -vertexOfs, 0)
            meta.isLess = true
        elseif meta.isLess then
            self.fill:SetPoint(meta.isTrapezoid)
            self.fill:SetVertexOffset(meta.leftVertex, minWidth, 0)
            self.fill:SetVertexOffset(meta.rightVertex, -minWidth, 0)
            meta.isLess = false
        end
    end

    if meta.texture then
        self.fill:SetTexCoord(left, right, top, bottom)
    end

    if isReversePerc then
        self.fill:SetShown(value < meta.maxVal)
    else
        self.fill:SetShown(value > meta.minVal)
    end
end

local smoothBars do
    local FrameDeltaLerp, Clamp = _G.FrameDeltaLerp, _G.Clamp
    smoothBars = {}

    local function IsCloseEnough(bar, newValue, targetValue)
        local min, max = bar:GetMinMaxValues()
        local range = max - min
        if range > 0.0 then
            return abs((newValue - targetValue) / range) < .00001
        end

        return true
    end

    local function ProcessSmoothStatusBars()
        for bar, targetValue in next, smoothBars do
            local effectiveTargetValue = Clamp(targetValue, bar:GetMinMaxValues())
            local newValue = FrameDeltaLerp(bar:GetValue(), effectiveTargetValue, .25)
            if IsCloseEnough(bar, newValue, effectiveTargetValue) then
                smoothBars[bar] = nil
            end

            SetBarValue(bar, newValue)
        end
    end
    _G.C_Timer.NewTicker(0, ProcessSmoothStatusBars)
end

local UpdateAngle do
    local function SetVertexOffset(tex, meta)
        for i = 1, 4 do
            tex:SetVertexOffset(i, 0, 0)
        end
        tex:SetVertexOffset(meta.leftVertex, meta.minWidth, 0)
        tex:SetVertexOffset(meta.rightVertex, -meta.minWidth, 0)
    end

    function UpdateAngle(self)
        if bars[self].minWidth <= 0 then
            -- We don't have a proper offset, bail early.
            return
        end

        local meta = bars[self]
        local minWidth = meta.minWidth
        if meta.regions then
            for index = 1, #meta.regions do
                SetVertexOffset(meta.regions[index], meta)
            end
        else
            SetVertexOffset(self, meta)
        end

        if meta.hasBG then
            if meta.leftVertex == 1 then
                self.top:SetPoint("TOPLEFT", minWidth, 0)
                self.bottom:SetPoint("BOTTOMLEFT", 0, 0)

                self.left:SetStartPoint("TOPLEFT", minWidth, 0)
                _G.C_Timer.After(0, function()
                    -- The line points don't seem to update properly if done together, so we separate them by one frame.
                    self.left:SetEndPoint("BOTTOMLEFT", 0, 0)
                end)
            else
                self.top:SetPoint("TOPLEFT", 0, 0)
                self.bottom:SetPoint("BOTTOMLEFT", minWidth, 0)

                self.left:SetStartPoint("TOPLEFT", 0, 0)
                _G.C_Timer.After(0, function()
                    self.left:SetEndPoint("BOTTOMLEFT", minWidth, 0)
                end)
            end

            if meta.rightVertex == 4 then
                self.top:SetPoint("TOPRIGHT", 0, 0)
                self.bottom:SetPoint("BOTTOMRIGHT", -minWidth, 0)

                self.right:SetStartPoint("TOPRIGHT", 0, 0)
                _G.C_Timer.After(0, function()
                    self.right:SetEndPoint("BOTTOMRIGHT", -minWidth, 0)
                end)
            else
                self.top:SetPoint("TOPRIGHT", -minWidth, 0)
                self.bottom:SetPoint("BOTTOMRIGHT", 0, 0)

                self.right:SetStartPoint("TOPRIGHT", -minWidth, 0)
                _G.C_Timer.After(0, function()
                    self.right:SetEndPoint("BOTTOMRIGHT", 0, 0)
                end)
            end
        end

        if meta.value then
            SetBarValue(self, meta.value)
        end
    end
end

local function OnSizeChanged(self, width, height)
    local meta = bars[self]
    meta.maxWidth = width
    meta.minWidth = height
    UpdateAngle(self)
end

local Frame_SetWidth = _G.getmetatable(_G.UIParent).__index.SetWidth
local Frame_SetSize = _G.getmetatable(_G.UIParent).__index.SetSize
local BaseAngleMixin = {}
function BaseAngleMixin:SetWidth(width)
    Frame_SetWidth(self, bars[self].minWidth + width)
    if bars[self].isTex then
        OnSizeChanged(self, width, self:GetHeight())
    end
end
function BaseAngleMixin:SetSize(width, height)
    Frame_SetSize(self, height + width, height)
    if bars[self].isTex then
        OnSizeChanged(self, width, height)
    end
end
function BaseAngleMixin:SetAngleVertex(leftVertex, rightVertex)
    local meta = bars[self]
    meta.leftVertex = leftVertex
    meta.rightVertex = rightVertex

    local leftMod, rightMod = leftVertex % 2, rightVertex % 2
    if leftMod == 1 and rightMod == 1 then
        meta.isTrapezoid = "TOP"
    elseif leftMod == 0 and rightMod == 0 then
        meta.isTrapezoid = "BOTTOM"
    end
    UpdateAngle(self)

    if meta.children and #meta.children > 0 then
        -- If we have any children, update them too.
        for i = 1, #meta.children do
            meta.children[i]:SetAngleVertex(leftVertex, rightVertex)
        end
    end
end

local AngleFrameMixin = _G.Mixin({}, BaseAngleMixin)
function AngleFrameMixin:SetBackgroundColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local color = bars[self].bgColor
    color.r, color.g, color.b, color.a = r, g, b, a
    self.bg:SetColorTexture(r, g, b, a)
end
function AngleFrameMixin:GetBackgroundColor()
    return self.bg:GetColorTexture()
end
function AngleFrameMixin:SetBackgroundBorderColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local color = bars[self].borderColor
    color.r, color.g, color.b, color.a = r, g, b, a
    self.top:SetColorTexture(r, g, b, a)
    self.bottom:SetColorTexture(r, g, b, a)
    self.left:SetColorTexture(r, g, b, a)
    self.right:SetColorTexture(r, g, b, a)
end
function AngleFrameMixin:GetBackgroundBorderColor()
    local color = bars[self].bgColor
    return color.r, color.g, color.b, color.a
end

local AngleStatusBarMixin = _G.Mixin({}, BaseAngleMixin)
function AngleStatusBarMixin:SetStatusBarColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end

    local meta = bars[self]
    local color = meta.fillColor
    color.r, color.g, color.b, color.a = r, g, b, a
    if not meta.texture or meta.texture == "" then
        self.fill:SetColorTexture(r, g, b, a)
    else
        self.fill:SetVertexColor(r, g, b, a)
    end
end
function AngleStatusBarMixin:GetStatusBarColor()
    local color = bars[self].fillColor
    return color.r, color.g, color.b, color.a
end

function AngleStatusBarMixin:SetStatusBarTexture(texture, layer)
    if not texture then return end
    local texType = type(texture)
    if texType == "string" or texType == "number" then
        bars[self].texture = texture
        self.fill:SetTexture(texture)

        if layer then
            self.fill:SetDrawLayer(layer)
        end
    else
        self.fill = texture
    end

end
function AngleStatusBarMixin:GetStatusBarTexture()
    return self.fill
end

function AngleStatusBarMixin:SetMinMaxValues(minVal, maxVal)
    local meta = bars[self]

    local targetValue = smoothBars[self]
    if targetValue then
        local ratio = 1
        if maxVal ~= 0 and meta.maxVal and meta.maxVal ~= 0 then
            ratio = maxVal / meta.maxVal
        end

        smoothBars[self] = targetValue * ratio
    end

    meta.minVal = minVal
    meta.maxVal = maxVal
end
function AngleStatusBarMixin:GetMinMaxValues()
    local meta = bars[self]
    return meta.minVal, meta.maxVal
end

-- This should except a percentage or discrete value.
function AngleStatusBarMixin:SetValue(value, ignoreSmooth)
    local meta = bars[self]
    if value > meta.maxVal then value = meta.maxVal end
    if meta.smooth and not ignoreSmooth then
        smoothBars[self] = value
    else
        SetBarValue(self, value)
    end
end
function AngleStatusBarMixin:GetValue()
    return bars[self].value
end

function AngleStatusBarMixin:SetSmooth(isSmooth)
    bars[self].smooth = isSmooth
end
function AngleStatusBarMixin:GetSmooth()
    return bars[self].smooth
end

-- Setting this to true will make the bars fill from right to left
function AngleStatusBarMixin:SetReverseFill(isReverseFill)
    bars[self].isReverseFill = isReverseFill
    self.fill:ClearAllPoints()
    self.fill:SetPoint("TOP")
    self.fill:SetPoint("BOTTOM")
    if isReverseFill then
        self.fill:SetPoint("RIGHT")
    else
        self.fill:SetPoint("LEFT")
    end
end
function AngleStatusBarMixin:GetReverseFill()
    return bars[self].isReverseFill
end

-- Setting this to true will make the bars show full when at 0%.
function AngleStatusBarMixin:SetReversePercent(isReversePerc)
    local meta = bars[self]
    meta.isReversePerc = isReversePerc
    SetBarValue(self, meta.value)
end
function AngleStatusBarMixin:GetReversePercent()
    return bars[self].isReversePerc
end

function AngleStatusBarMixin:SetOrientation(orientaion)
end
function AngleStatusBarMixin:GetOrientation()
    return "HORIZONTAL"
end

--[[ Frame Construction ]]--
local function SetPixels(texture)
    texture:SetTexelSnappingBias(0.0)
    texture:SetSnapToPixelGrid(false)
end
local function CreateAngleFrame(name, parent)
    local frame = _G.CreateFrame("Frame", name, parent)
    frame:SetScript("OnSizeChanged", OnSizeChanged)

    --[[
    local test = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(frame)
    --]]

    local bg = frame:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(0, 0, 0, 0.5)
    bg:SetAllPoints()
    SetPixels(bg)
    frame.bg = bg

    local top = frame:CreateTexture(nil, "BORDER")
    top:SetColorTexture(0, 0, 0)
    top:SetPoint("TOPLEFT")
    top:SetPoint("TOPRIGHT")
    top:SetHeight(1)
    SetPixels(top)
    frame.top = top

    local bottom = frame:CreateTexture(nil, "BORDER")
    bottom:SetColorTexture(0, 0, 0)
    bottom:SetPoint("BOTTOMLEFT")
    bottom:SetPoint("BOTTOMRIGHT")
    bottom:SetHeight(1)
    SetPixels(bottom)
    frame.bottom = bottom

    local left = frame:CreateLine(nil, "BORDER")
    left:SetColorTexture(0, 0, 0)
    left:SetThickness(0.5)
    left:SetStartPoint("TOPLEFT")
    left:SetEndPoint("BOTTOMLEFT")
    SetPixels(left)
    frame.left = left

    local right = frame:CreateLine(nil, "BORDER")
    right:SetColorTexture(0, 0, 0)
    right:SetThickness(0.5)
    right:SetStartPoint("TOPRIGHT")
    right:SetEndPoint("BOTTOMRIGHT")
    SetPixels(right)
    frame.right = right

    return frame
end

local function CreateAngleStatusBar(name, parent)
    local bar = CreateAngleFrame(name, parent)
    bar.top:SetDrawLayer("OVERLAY")
    bar.bottom:SetDrawLayer("OVERLAY")
    bar.left:SetDrawLayer("OVERLAY")
    bar.right:SetDrawLayer("OVERLAY")
    bar:SetScript("OnSizeChanged", OnSizeChanged)
    _G.Mixin(bar, AngleFrameMixin)

    --[[
    local test = bar:CreateTexture(nil, "BACKGROUND", nil, -8)
    test:SetColorTexture(1, 1, 1, 0.2)
    test:SetAllPoints(bar)
    --]]

    local fill = bar:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOP")
    fill:SetPoint("BOTTOM")
    fill:SetPoint("LEFT")
    bar.fill = fill

    return bar
end

function AngleStatusBar:CreateAngle(frameType, name, parent)
    if frameType == "Texture" then
        local texture = parent:CreateTexture(name, "ARTWORK")
        _G.Mixin(texture, BaseAngleMixin)

        bars[texture] = {
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            isTex = true
        }

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.regions, texture)
            texture:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return texture
    elseif frameType == "Frame" then
        local frame = CreateAngleFrame(name, parent)
        _G.Mixin(frame, AngleFrameMixin)

        bars[frame] = {
            regions = {},
            children = {},
            bgColor = {},
            borderColor = {},
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            hasBG = true
        }
        _G.tinsert(bars[frame].regions, frame.bg)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, frame)
            frame:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return frame
    elseif frameType == "StatusBar" then
        local bar = CreateAngleStatusBar(name, parent)
        _G.Mixin(bar, AngleStatusBarMixin)

        bars[bar] = {
            regions = {},
            children = {},
            fillColor = {},
            bgColor = {},
            borderColor = {},
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            smooth = true,
            value = 0,
            hasBG = true
        }
        _G.tinsert(bars[bar].regions, bar.bg)
        _G.tinsert(bars[bar].regions, bar.fill)
        bar:SetMinMaxValues(0, 0)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, bar)
            bar:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return bar
    end
end
oUF:RegisterMetaFunction("CreateAngle", AngleStatusBar.CreateAngle) -- oUF magic

local pointToVertex = {
    ["TOPLEFT"] = 1,
    ["BOTTOMLEFT"] = 2,
    ["TOPRIGHT"] = 3,
    ["BOTTOMRIGHT"] = 4,
}
function AngleStatusBar:AttachFrame(frame, point, bar, relPoint, xOffset, yOffset)
    local meta = bars[bar]

    local vertex = pointToVertex[relPoint]
    if vertex then
        if meta.leftVertex == vertex then
            xOffset = meta.minWidth
        end

        if meta.rightVertex == vertex then
            xOffset = -meta.minWidth
        end
    end

    frame:SetPoint(point, bar, relPoint, xOffset, yOffset)
end

local function TestASB(reverseFill, reversePer) -- luacheck: ignore
    local testBars = {}
    local info = {
        {
            leftVertex = 2,
            rightVertex = 3,
        },
        {
            leftVertex = 2,
            rightVertex = 4,
        },
        {
            leftVertex = 1,
            rightVertex = 3,
        },
        {
            leftVertex = 1,
            rightVertex = 4,
        },
    }
    local width, height = 100, 10
    local val, minVal, maxVal = 10, 0, 250
    for i = 1, #info do
        local barInfo = info[i]
        local test = AngleStatusBar:CreateAngle("StatusBar", "ASBTest"..i, _G.UIParent)
        test:SetSize(width, height)
        test:SetAngleVertex(barInfo.leftVertex, barInfo.rightVertex)
        test:SetStatusBarColor(1, 0, 0, 1)
        if i == 1 then
            test:SetPoint("TOP", _G.UIParent, "CENTER", 0, 0)
        else
            test:SetPoint("TOP", testBars[i-1], "BOTTOM", 0, -10)
        end

        test:SetMinMaxValues(minVal, maxVal)
        test:SetValue(val, true)
        test:SetReverseFill(reverseFill)
        test:SetReversePercent(reversePer)
        tinsert(testBars, test)
        --test:Show()
        --test.bar:Show()
    end

    -- Normal status bar as a baseline
    local status = _G.CreateFrame("StatusBar", "RealUITestStatus", _G.UIParent)
    status:SetPoint("TOP", testBars[#info], "BOTTOM", 0, -10)
    status:SetSize(width, height)

    local bg = status:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 1, 0.5)
    bg:SetAllPoints(status)

    local tex = status:CreateTexture(nil, "ARTWORK")
    local color = {1,0,0}
    tex:SetColorTexture(color[1], color[2], color[3])
    status:SetStatusBarTexture(tex)

    status:SetMinMaxValues(minVal, maxVal)
    status:SetValue(val)
    status:SetReverseFill(reverseFill)

    tinsert(testBars, status)

    -- /run RealUI:TestASBSet("Value", 50)
    -- /run RealUI:TestASBSet("ReverseFill", true)
    -- /run RealUI:TestASBSet("ReversePercent", true)
    -- /run RealUI:TestASBSet("AngleVertex", 1, 4)
    function RealUI:TestASBSet(method, ...)
        for i = 1, #testBars do
            local bar = testBars[i]
            if bar["Set"..method] then
                bar["Set"..method](bar, ...)
            end
        end
    end
end

-------------
function AngleStatusBar:OnInitialize()
    --TestASB()
end
