local _, private = ...

-- Lua Globals --
-- luacheck: globals next max floor ceil type

-- RealUI --
local RealUI = private.RealUI
local db, pointDB, barDB

local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")

local MODNAME = "ClassResource"
local ClassResource = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local playerClass = RealUI.charInfo.class.token
local power
local powerTextures = {
    circle = [[Interface\Addons\RealUI\Media\PointTracking\Point]],
    SOUL_SHARDS = [[Interface\Addons\RealUI\Media\PointTracking\SoulShard]],
    HOLY_POWER = {
        [[Interface\Addons\RealUI\Media\PointTracking\HolyPower1]],
        [[Interface\Addons\RealUI\Media\PointTracking\HolyPower2]],
        [[Interface\Addons\RealUI\Media\PointTracking\HolyPower3]],
        [[Interface\Addons\RealUI\Media\PointTracking\HolyPower4]],
        [[Interface\Addons\RealUI\Media\PointTracking\HolyPower5]]
    }
}

function ClassResource:GetResources()
    return self.points.info, self.bar and self.bar.info
end

function ClassResource:ForceUpdate()
    local pts, bar = ClassResource.points, ClassResource.bar
    if pts and pts.ForceUpdate then
        pts:ForceUpdate()
    end
    if bar and bar.ForceUpdate then
        bar:ForceUpdate()
    end
    CombatFader:RefreshMod()
end

local function PositionRune(rune, index)
    ClassResource:debug("PositionRune", rune, index)
    local size = pointDB.size
    local gap, middle, mod = size.gap + 2, (power.max / 2) + 0.5
    if index < middle then
        mod = index - _G.floor(middle)
    else
        mod = index - _G.ceil(middle)
    end
    rune:SetPoint("CENTER", (size.width + gap) * mod, 0)
end
local function PositionIcon(icon, index, prevIcon)
    local point, size = pointDB.reverse and "RIGHT" or "LEFT", pointDB.size
    local gap = pointDB.reverse and -(size.gap) or size.gap
    if index == 1 then
        icon:SetPoint(point)
    else
        icon:SetPoint(point, prevIcon, pointDB.reverse and "LEFT" or "RIGHT", gap, 0)
    end
end


function ClassResource:SettingsUpdate(kind, event)
    self:debug("SettingsUpdate", kind, event)
    local settings = db[kind]
    if kind == "points" then
        local frame = self.points
        for i = 1, #frame do
            local point = frame[i]
            if self.isRunes then
                point:SetSize(settings.size.width, settings.size.height)
                PositionRune(point, i)
            else
                if event == "gap" then
                    point:ClearAllPoints()
                    PositionIcon(point, i, frame[i-1])
                elseif event == "size" then
                    point:SetSize(settings.size.width, settings.size.height)
                end
            end
        end
    elseif kind == "bar" then
        if event == "size" then
            self.bar:SetSize(settings.size.width, db.size.height)
        end
    end
end

function ClassResource:CreateClassPower(unitFrame, unit)
    self:debug("CreateClassPower", unit)
    local ClassPower = {}
    local holder = _G.CreateFrame("Frame", nil, unitFrame)
    holder:SetSize(16, 16)
    ClassPower.frame = holder

    local texture, size = powerTextures[power.token], pointDB.size
    for index = 1, power.max do
        local name, icon = "ClassPower"..index
        if playerClass == "WARLOCK" then
            icon = unitFrame:CreateAngle("StatusBar", name, holder)
            icon:SetSize(size.width, size.height)
            icon:SetAngleVertex(2, 3)
            icon:SetMinMaxValues(0, 1)
        else
            icon = _G.CreateFrame("StatusBar", name, holder)
            icon:SetSize(size.width, size.height)

            local bg = icon:CreateTexture(nil, "BACKGROUND")
            bg:SetAllPoints()
            icon.bg = bg
        end

        local tex
        if playerClass == "PALADIN" then
            icon:SetPoint("CENTER")
            tex = texture[index]
        else
            PositionIcon(icon, index, ClassPower[index - 1])
            tex = texture
        end

        if not tex then
            tex = powerTextures.circle
        end
        icon:SetStatusBarTexture(tex)
        icon.bg:SetTexture(tex)
        icon.bg.multiplier = 0.5

        ClassPower[index] = icon
    end

    CombatFader:RegisterFrameForFade(MODNAME, holder)
    if self.isRunes then
        holder:SetPoint("CENTER", -160, -40.5)
    else
        FramePoint:PositionFrame(self, holder, {"class", "points", "position"})
    end

    local lastChargedIndex
    function ClassPower.PostUpdate(element, curPoints, maxPoints, hasMaxChanged, powerType, chargedIndex)
        if not curPoints or not powerType then return end
        self:debug("ClassPower:PostUpdate", curPoints, maxPoints, hasMaxChanged, powerType, chargedIndex)

        local showUnused = not pointDB.hideempty or self.configMode
        local hasPartial = (curPoints - floor(curPoints)) > 0
        local hasChargedPoint = chargedIndex and chargedIndex <= curPoints
        self:debug("data", showUnused, hasPartial, hasChargedPoint)

        local color = element.__owner.colors.power[powerType]
        local r, g, b = color[1], color[2], color[3]
        local mu = element[1].bg.multiplier

        if lastChargedIndex and lastChargedIndex ~= chargedIndex then
            element[lastChargedIndex].bg:SetVertexColor(r * mu, g * mu, b * mu)
            element[lastChargedIndex]:SetStatusBarColor(r, g, b)
        end
        lastChargedIndex = chargedIndex

        for i = 1, maxPoints or 0 do
            local icon = element[i]
            local isPartial = hasPartial and ceil(curPoints) == i
            local isUnused = i > ceil(curPoints)
            self:debug("Icon", i, isPartial, isUnused)

            if i == chargedIndex then
                if hasChargedPoint then
                    r, g, b = 0.25, 0.75, 1
                    icon.bg:SetVertexColor(r * mu, g * mu, b * mu)
                    icon:SetStatusBarColor(r, g, b)
                end
            end

            if hasPartial and isPartial then
                icon:SetAlpha(0.5)
            else
                icon:SetAlpha(1)
            end

            if isUnused then
                if showUnused or (chargedIndex and i <= chargedIndex) then
                    icon:Show()
                else
                    icon:Hide()
                end
            else
                icon:Show()
            end
        end

        if curPoints > 0 then
            for i = 1, ceil(curPoints) do
                if element[i] then
                    element[i]:Show()
                end
            end
        end
    end

    unitFrame.ClassPower = ClassPower
    return ClassPower
end
function ClassResource:CreateRunes(unitFrame, unit)
    self:debug("CreateRunes", unit)
    local Runes = _G.CreateFrame("Frame", nil, unitFrame)
    Runes:SetSize(16, 16)
    Runes.colorSpec = true

    local size = pointDB.size
    for index = 1, power.max do
        local Rune = _G.CreateFrame("StatusBar", nil, Runes)
        Rune:SetOrientation("VERTICAL")
        Rune:SetSize(size.width, size.height)
        PositionRune(Rune, index)

        local tex = Rune:CreateTexture(nil, "ARTWORK")
        tex:SetTexture(RealUI.textures.plain)
        Rune:SetStatusBarTexture(tex)
        Rune.tex = tex

        local runeBG = Rune:CreateTexture(nil, "BACKGROUND")
        runeBG:SetTexture(RealUI.textures.plain)
        runeBG:SetPoint("TOPLEFT", Rune, -1, 1)
        runeBG:SetPoint("BOTTOMRIGHT", Rune, 1, -1)
        runeBG.multiplier = 0.2
        Rune.bg = runeBG

        Runes[index] = Rune
    end

    CombatFader:RegisterFrameForFade(MODNAME, Runes)
    FramePoint:PositionFrame(self, Runes, {"class", "points", "position"})

    function Runes.PostUpdate(element, runemap)
        local rune, runeReady, _
        for index, runeID in next, runemap do
            rune = element[index]
            _, _, runeReady = _G.GetRuneCooldown(runeID)
            if runeReady then
                rune.tex:SetAlpha(1)
            else
                rune.tex:SetAlpha(0.5)
            end
        end
    end

    unitFrame.Runes = Runes
    return Runes
end
function ClassResource:CreateStagger(unitFrame, unit)
    self:debug("CreateStagger", unit)
    local Stagger = unitFrame:CreateAngle("StatusBar", nil, unitFrame)

    Stagger:SetSize(barDB.size.width, barDB.size.height)
    Stagger:SetAngleVertex(1, 3)

    FramePoint:PositionFrame(self, Stagger, {"class", "bar", "position"})

    function Stagger.PostUpdateColor(element, r, g, b)
        self:debug("Stagger:PostUpdateColor", r, g, b)
        if self.configMode then
            local color = unitFrame.colors.power[_G.BREWMASTER_POWER_BAR_NAME][2]
            r, g, b = color[1], color[2], color[3]
        end
        element:SetStatusBarColor(RealUI.ColorDarken(0.5, r, g, b))
    end
    function Stagger.PostUpdate(element, cur, max)
        local r, g, b = element:GetStatusBarColor()
        self:debug("Stagger:PostUpdate", cur, max, r, g, b)
        if self.configMode then
            cur = max * 0.3
            element:SetValue(cur)
        end
        element:SetShown(cur > 0)
    end

    unitFrame.Stagger = Stagger
    return Stagger
end

function ClassResource:Setup(unitFrame, unit)
    local isEnabled = ClassResource:IsEnabled()
    -- Points
    if isEnabled then
        if playerClass == "DEATHKNIGHT" then
            self.points = self:CreateRunes(unitFrame, unit)
        else
            self.points = self:CreateClassPower(unitFrame, unit)
        end
    else
        self.points = {}
    end
    self.points.info = {token = power.token, name = _G[power.token]}

    -- Bars
    if playerClass == "MONK" then
        self.bar = isEnabled and self:CreateStagger(unitFrame, unit) or {}
        self.bar.info = _G.C_Spell.GetSpellInfo(124255)
    end
end

function ClassResource:ToggleConfigMode(isConfigMode)
    if self.configMode == isConfigMode then return end
    self.configMode = isConfigMode

    if isConfigMode then
        local pts, bar = self.points, self.bar
        local ptsFrame = pts and pts.frame
        if ptsFrame and ptsFrame.SetAlpha then
            ptsFrame:SetAlpha(1)
            for i = 1, power.max do
                if self.isRunes then
                    if pts[i] and pts[i].SetValue then
                        pts[i]:SetValue(i / power.max)
                    end
                else
                    if pts[i] and pts[i].SetShown then
                        pts[i]:SetShown(isConfigMode)
                    end
                    if pts.PostUpdate then
                        pts:PostUpdate(isConfigMode and 3 or 0, isConfigMode and 5 or 0, true, power.type)
                    end
                end
            end
        end
        if bar and bar.SetMinMaxValues and bar.PostUpdate then
            local maxHealth = _G.UnitHealthMax("player")
            bar:SetMinMaxValues(0, maxHealth)
            bar:PostUpdate(maxHealth * 0.4, maxHealth)
        end
    else
        ClassResource:ForceUpdate()
    end
end

local classPowers = {
    default = {type = _G.Enum.PowerType.ComboPoints, token = "COMBO_POINTS"},
    DEATHKNIGHT = {
        type = _G.Enum.PowerType.Runes,
        token = "RUNES",
        max = 6
    },
    MAGE = {type = _G.Enum.PowerType.ArcaneCharges, token = "ARCANE_CHARGES"},
    MONK = {type = _G.Enum.PowerType.Chi, token = "CHI"},
    PALADIN = {
        type = _G.Enum.PowerType.HolyPower,
        token = "HOLY_POWER",
        max = 5
    },
    WARLOCK = {type = _G.Enum.PowerType.SoulShards, token = "SOUL_SHARDS"},
    EVOKER = {type = _G.Enum.PowerType.Essence, token = "POWER_TYPE_ESSENCE"},
}
function ClassResource:OnInitialize()
    self:debug("OnInitialize")
    local points do
        points = {
            hideempty = true, -- Only show used icons
            reverse = false, -- Points start on the right
            size = {
                width = 13,
                height = 13,
                gap = 2,
            },
            position = {
                x = -160,
                y = -40.5,
                point = "CENTER",
            },
        }

        if playerClass == "DEATHKNIGHT" then
            points.size.width = 9
            points.size.height = 38
            points.size.gap = 1

            points.position.x = 0
            points.position.y = -110
        elseif playerClass == "PALADIN" then
            points.size.width = 64
            points.size.height = 64

            points.position.x = 0
            points.position.y = -110
        elseif playerClass == "WARLOCK" then
            points.size.width = 22
            points.size.height = 13
            points.size.gap = -5
        end
    end

    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        class = {
            locked = true,
            bar = {
                size = {
                    width = 200,
                    height = 8,
                },
                position = {
                    x = 0,
                    y = -128,
                    point = "CENTER",
                },
            },
            points = points,
            combatfade = {
                enabled = true,
                opacity = {
                    incombat = 1,
                    harmtarget = .8,
                    target = .8,
                    hurt = .5,
                    outofcombat = playerClass == "DEATHKNIGHT" and 0 or .3,
                }
            }
        }
    })
    db = self.db.class
    pointDB, barDB = db.points, db.bar

    power = classPowers[playerClass] or classPowers.default
    power.max = power.max or 10
    self.isRunes = power.type == _G.Enum.PowerType.Runes

    local isEnabled = RealUI:GetModuleEnabled(MODNAME)
    self:SetEnabledState(isEnabled)
end

function ClassResource:OnEnable()
    self:debug("OnEnable")

    CombatFader:RegisterModForFade(MODNAME, "class", "combatfade")
    FramePoint:RegisterMod(self)
end

function ClassResource:OnDisable()
    self:debug("OnEnable")
end
