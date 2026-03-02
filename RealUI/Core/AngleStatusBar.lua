local _, private = ...

-- Lua Globals --
local abs = _G.math.abs
local next, type = _G.next, _G.type

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local MODNAME = "AngleStatusBar"
local AngleStatusBar = RealUI:NewModule(MODNAME)

local bars = {}

local Lerp = _G.Lerp

--[[ Core bar fill logic — simplified for oUF-native values (no secret arithmetic) ]]--
local function SetBarValue(self, value)
    local meta = bars[self]
    if not meta then return end

    -- Secret values from WoW APIs cannot be compared or used in arithmetic
    if _G.issecretvalue(value) then
        meta.value = 0
        -- The native engine may have already sized fill. Read back width.
        local width = self.fill:GetWidth()
        if not _G.issecretvalue(width) and width > 0.001 then
            self.fill:SetShown(true)
            if meta.isTrapezoid then
                if width < (meta.minWidth * 2) then
                    local vertexOfs = width / 2
                    self.fill:SetPoint(meta.isTrapezoid, 0, (meta.minWidth - vertexOfs) * (meta.isTrapezoid == "TOP" and -1 or 1))
                    self.fill:SetVertexOffset(meta.leftVertex, vertexOfs, 0)
                    self.fill:SetVertexOffset(meta.rightVertex, -vertexOfs, 0)
                    meta.isLess = true
                elseif meta.isLess then
                    self.fill:SetPoint(meta.isTrapezoid)
                    self.fill:SetVertexOffset(meta.leftVertex, meta.minWidth, 0)
                    self.fill:SetVertexOffset(meta.rightVertex, -meta.minWidth, 0)
                    meta.isLess = false
                end
            end
        else
            -- Width is secret or zero — just show fill and let native handle it
            self.fill:SetShown(true)
        end
        return
    end

    meta.value = value
    local maxVal = meta.maxVal
    if not maxVal or maxVal == 0 then
        self.fill:SetWidth(_G.max(meta.minWidth, 0.001))
        self.fill:SetShown(false)
        return
    end

    local percent = value / maxVal
    if percent < 0 then percent = 0 end
    if percent > 1 then percent = 1 end

    local minWidth, maxWidth = meta.minWidth, meta.maxWidth
    local left, right, top, bottom = 0, 1, 0, 1

    if meta.isReverseFill then
        left = Lerp(1, 0, percent)
    else
        right = Lerp(0, 1, percent)
    end

    local width = Lerp(minWidth, maxWidth, percent)
    if width < 0.001 then width = 0.001 end
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

    self.fill:SetShown(not _G.issecretvalue(value) and value > meta.minVal)
end

--[[ Smooth bar animation ]]--
local smoothBars do
    local FrameDeltaLerp, Clamp = _G.FrameDeltaLerp, _G.Clamp
    smoothBars = {}

    local function IsCloseEnough(bar, newValue, targetValue)
        local min, max = bar:GetMinMaxValues()
        if _G.issecretvalue(min) or _G.issecretvalue(max) then
            return true
        end
        local range = max - min
        if range > 0.0 then
            return abs((newValue - targetValue) / range) < .00001
        end
        return true
    end

    local function ProcessSmoothStatusBars()
        for bar, targetValue in next, smoothBars do
            if _G.issecretvalue(targetValue) then
                smoothBars[bar] = nil
            else
                local meta = bars[bar]
                local min, max
                if meta and meta.hasSecretRange then
                    -- Read from native StatusBar when we have secret range
                    local nativeGetMinMax = _G.getmetatable(bar).__index.GetMinMaxValues
                    if nativeGetMinMax then
                        min, max = nativeGetMinMax(bar)
                    end
                else
                    min, max = bar:GetMinMaxValues()
                end
                if _G.issecretvalue(min) or _G.issecretvalue(max) then
                    smoothBars[bar] = nil
                else
                    local effectiveTargetValue = Clamp(targetValue, min, max)
                    local newValue = FrameDeltaLerp(bar:GetValue(), effectiveTargetValue, .25)

                    if IsCloseEnough(bar, newValue, effectiveTargetValue) then
                        newValue = effectiveTargetValue
                        smoothBars[bar] = nil
                    end

                    SetBarValue(bar, newValue)
                end
            end
        end
    end
    _G.C_Timer.NewTicker(0, ProcessSmoothStatusBars)
end

--[[ Vertex geometry (unchanged) ]]--
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

--[[ Base mixin — shared by all angle types ]]--
local Frame_SetWidth = _G.getmetatable(_G.UIParent).__index.SetWidth
local Frame_SetSize = _G.getmetatable(_G.UIParent).__index.SetSize
local BaseAngleMixin = {}
function BaseAngleMixin:SetWidth(width)
    local meta = bars[self]
    if meta and meta.isPredictionWidget then
        Frame_SetWidth(self, width)
    else
        Frame_SetWidth(self, meta.minWidth + width)
    end
    if meta and meta.isTex then
        OnSizeChanged(self, width, self:GetHeight())
    end
end
function BaseAngleMixin:SetSize(width, height)
    Frame_SetSize(self, height + width, height)
    -- Always call OnSizeChanged synchronously so meta.maxWidth/minWidth are set
    -- before the first SetValue call (the script fires asynchronously in WoW).
    -- For textures (isTex), pass the logical width; for StatusBars, pass the frame width.
    local meta = bars[self]
    if meta and meta.isTex then
        OnSizeChanged(self, width, height)
    else
        OnSizeChanged(self, height + width, height)
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
    else
        meta.isTrapezoid = nil
    end
    UpdateAngle(self)

    if meta.children and #meta.children > 0 then
        for i = 1, #meta.children do
            meta.children[i]:SetAngleVertex(leftVertex, rightVertex)
        end
    end
end

--[[ AngleFrame mixin — for "Frame" type ]]--
local AngleFrameMixin = _G.Mixin({}, BaseAngleMixin)
function AngleFrameMixin:SetBackgroundColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end
    local color = bars[self].bgColor
    color.r, color.g, color.b, color.a = r, g, b, a
    if (color.r) and (color.g) and (color.b) then
        self.bg:SetColorTexture(r, g, b, a)
    end
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

--[[ AngleStatusBar mixin — oUF StatusBar interface ]]--
local AngleStatusBarMixin = _G.Mixin({}, BaseAngleMixin)

function AngleStatusBarMixin:SetStatusBarColor(r, g, b, a)
    if type(r) == "table" then
        r, g, b, a = r[1], r[2], r[3], r[4]
    end

    local meta = bars[self]
    local color = meta.fillColor
    if r == nil then
        r = color.r or 1
        g = color.g or 1
        b = color.b or 1
        a = color.a or 1
    else
        a = a or color.a or 1
    end
    color.r, color.g, color.b, color.a = r, g, b, a

    if not meta.texture or meta.texture == "" then
        self.fill:SetColorTexture(r, g, b, a)
    else
        self.fill:SetVertexColor(r, g, b, a)
    end

    -- Forward to native StatusBar so the fill (which is the native texture)
    -- shows correct color when driven by the C++ timer engine (secret values)
    local nativeSetColor = _G.getmetatable(self).__index.SetStatusBarColor
    if nativeSetColor then
        nativeSetColor(self, r, g, b, a)
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
        if self.fill then
            self.fill:SetTexture(texture)
        end
        if layer and self.fill then
            self.fill:SetDrawLayer(layer)
        end
    else
        self.fill = texture
    end
end
function AngleStatusBarMixin:GetStatusBarTexture()
    if self.fill then
        return self.fill
    end
    return nil
end

function AngleStatusBarMixin:SetMinMaxValues(minVal, maxVal)
    local meta = bars[self]
    local oldMaxVal = meta.maxVal

    -- Forward to native StatusBar so oUF/WoW can read values back
    local nativeSetMinMax = _G.getmetatable(self).__index.SetMinMaxValues
    if nativeSetMinMax then
        nativeSetMinMax(self, minVal, maxVal)
    end

    -- Secret values from WoW APIs cannot be used in arithmetic
    if _G.issecretvalue(minVal) or _G.issecretvalue(maxVal) then
        meta.minVal = 0
        meta.maxVal = 0
        meta.hasSecretRange = true
        smoothBars[self] = nil
        return
    end

    meta.hasSecretRange = false
    meta.minVal = minVal
    meta.maxVal = maxVal

    local targetValue = smoothBars[self]
    if targetValue then
        local ratio = 1
        if oldMaxVal and oldMaxVal ~= 0 and maxVal ~= 0 then
            ratio = maxVal / oldMaxVal
        end
        smoothBars[self] = targetValue * ratio
    end
end
function AngleStatusBarMixin:GetMinMaxValues()
    local meta = bars[self]
    if meta.hasSecretRange then
        -- Return native values when we have secret range
        local nativeGetMinMax = _G.getmetatable(self).__index.GetMinMaxValues
        if nativeGetMinMax then
            return nativeGetMinMax(self)
        end
    end
    return meta.minVal, meta.maxVal
end

function AngleStatusBarMixin:SetValue(value)
    local meta = bars[self]

    -- Forward to native StatusBar so oUF/WoW can read values back.
    -- Since fill IS the native StatusBar texture, the C++ engine will
    -- automatically size fill based on the value (even secret values).
    local nativeSetValue = _G.getmetatable(self).__index.SetValue
    if nativeSetValue then
        nativeSetValue(self, value)
    end

    -- Secret values cannot be compared or used in arithmetic.
    -- The native StatusBar C++ engine has already sized our fill texture.
    -- Read back the computed width and use it for trapezoid vertex offsets.
    if _G.issecretvalue(value) then
        if meta.smooth then
            smoothBars[self] = nil
        end
        meta.hasSecretRange = true

        -- The native engine sized fill. Read back the width for vertex offsets.
        local width = self.fill:GetWidth()
        if not _G.issecretvalue(width) and width > 0.001 then
            -- We have a usable width — update trapezoid geometry
            self.fill:SetShown(true)
            if meta.isTrapezoid then
                if width < (meta.minWidth * 2) then
                    local vertexOfs = width / 2
                    self.fill:SetPoint(meta.isTrapezoid, 0, (meta.minWidth - vertexOfs) * (meta.isTrapezoid == "TOP" and -1 or 1))
                    self.fill:SetVertexOffset(meta.leftVertex, vertexOfs, 0)
                    self.fill:SetVertexOffset(meta.rightVertex, -vertexOfs, 0)
                    meta.isLess = true
                elseif meta.isLess then
                    self.fill:SetPoint(meta.isTrapezoid)
                    self.fill:SetVertexOffset(meta.leftVertex, meta.minWidth, 0)
                    self.fill:SetVertexOffset(meta.rightVertex, -meta.minWidth, 0)
                    meta.isLess = false
                end
            end
        else
            -- Width is also secret or zero — let native rendering show through
            self.fill:SetShown(true)
        end
        return
    end

    -- Non-secret value: ensure we're not in secret range mode
    if meta.hasSecretRange then
        meta.hasSecretRange = false
    end

    if type(meta.maxVal) == "number" and value > meta.maxVal then
        value = meta.maxVal
    end

    if meta.smooth then
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

function AngleStatusBarMixin:SetReverseFill(isReverseFill)
    bars[self].isReverseFill = isReverseFill
    -- Sync native StatusBar state for oUF compatibility (Defect 1.3)
    local nativeSetReverseFill = _G.getmetatable(self).__index.SetReverseFill
    if nativeSetReverseFill then
        nativeSetReverseFill(self, isReverseFill)
    end
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

function AngleStatusBarMixin:SetOrientation(orientation) -- luacheck: ignore
end
function AngleStatusBarMixin:GetOrientation()
    return "HORIZONTAL"
end

--[[ Frame Construction ]]--
local function SetPixels(texture)
    texture:SetTexelSnappingBias(0.0)
    texture:SetSnapToPixelGrid(false)
end

local function SetAngleFrameDefaults(frame)
    frame:SetScript("OnSizeChanged", OnSizeChanged)

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
end

local function CreateAngleFrame(name, parent)
    local frame = _G.CreateFrame("Frame", name, parent)
    SetAngleFrameDefaults(frame)
    return frame
end

local function CreateAngleStatusBar(name, parent)
    local bar = _G.CreateFrame("StatusBar", name, parent)
    SetAngleFrameDefaults(bar)
    bar.top:SetDrawLayer("OVERLAY")
    bar.bottom:SetDrawLayer("OVERLAY")
    bar.left:SetDrawLayer("OVERLAY")
    bar.right:SetDrawLayer("OVERLAY")
    bar:SetScript("OnSizeChanged", OnSizeChanged)
    _G.Mixin(bar, AngleFrameMixin)

    local fill = bar:CreateTexture(nil, "ARTWORK")
    fill:SetPoint("TOP")
    fill:SetPoint("BOTTOM")
    fill:SetPoint("LEFT")
    bar.fill = fill

    -- Set fill as the native StatusBar texture. This is critical for secret
    -- values (enemy health/cast): the native C++ engine sizes the fill texture
    -- directly when SetValue/SetTimerDuration is called with secret numbers.
    -- We can then read fill:GetWidth() to compute trapezoid vertex offsets.
    local nativeSetTexture = _G.getmetatable(bar).__index.SetStatusBarTexture
    if nativeSetTexture then
        nativeSetTexture(bar, fill)
    end

    return bar
end

--[[ CreateAngle factory ]]--
function AngleStatusBar:CreateAngle(frameType, name, parent)
    if frameType == "Texture" then
        local texture = parent:CreateTexture(name, "ARTWORK")
        _G.Mixin(texture, BaseAngleMixin)

        bars[texture] = {
            minWidth = 0,
            maxWidth = 0,
            leftVertex = 1,
            rightVertex = 4,
            isTex = true,
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
            hasBG = true,
        }
        _G.tinsert(bars[frame].regions, frame.bg)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, frame)
            frame:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return frame

    elseif frameType == "CastBar" then
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
            minVal = 0,
            maxVal = 0,
            leftVertex = 1,
            rightVertex = 4,
            smooth = true,
            value = 0,
            isReverseFill = false,
            hasSecretRange = false,
            hasBG = true,
        }
        _G.tinsert(bars[bar].regions, bar.bg)
        _G.tinsert(bars[bar].regions, bar.fill)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, bar)
            bar:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return bar

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
            minVal = 0,
            maxVal = 0,
            leftVertex = 1,
            rightVertex = 4,
            smooth = true,
            value = 0,
            isReverseFill = false,
            hasSecretRange = false,
            hasBG = true,
        }
        _G.tinsert(bars[bar].regions, bar.bg)
        _G.tinsert(bars[bar].regions, bar.fill)

        local parentMeta = bars[parent]
        if parentMeta then
            _G.tinsert(parentMeta.children, bar)
            bar:SetAngleVertex(parentMeta.leftVertex, parentMeta.rightVertex)
        end

        return bar
    end
end
oUF:RegisterMetaFunction("CreateAngle", AngleStatusBar.CreateAngle)

--[[ Utility: attach a frame to an angled bar with vertex-aware offset ]]--
local pointToVertex = {
    ["TOPLEFT"] = 1,
    ["BOTTOMLEFT"] = 2,
    ["TOPRIGHT"] = 3,
    ["BOTTOMRIGHT"] = 4,
}
--[[ Test utility: expose bar metadata for property tests ]]--
function AngleStatusBar:GetBarMeta(bar)
    return bars[bar]
end

--[[ Expose SetBarValue for external callers (e.g. CastBar OnUpdate) ]]--
function AngleStatusBar:SetBarValue(bar, value)
    SetBarValue(bar, value)
end

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
