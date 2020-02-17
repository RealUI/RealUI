local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- RealUI --
local RealUI = private.RealUI
local db, pointDB, barDB

local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")

local MODNAME = "ClassResource"
local ClassResource = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local playerClass = RealUI.charInfo.class.token
local powerToken
local powerTextures = {
    circle = [[Interface\Addons\nibRealUI\Media\PointTracking\Point]],
    SOUL_SHARDS = [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard]],
    HOLY_POWER = {
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower1]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower2]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower3]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower4]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower5]]
    }
}

local MAX_RUNES = 6
local MAX_POINTS = 10
local hasPoints = false

function ClassResource:GetResources()
    return self.points and self.points.info, self.bar and self.bar.info
end

function ClassResource:ForceUpdate()
    if ClassResource.points then
        ClassResource.points:ForceUpdate()
    end
    if ClassResource.bar then
        ClassResource.bar:ForceUpdate()
    end
    CombatFader:RefreshMod()
end

local function PositionRune(rune, index)
    ClassResource:debug("PositionRune", rune, index)
    local size = pointDB.size
    local gap, middle, mod = size.gap + 2, (MAX_RUNES / 2) + 0.5
    if index < middle then
        mod = index - _G.min(middle)
    else
        mod = index - _G.max(middle)
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
        if event == "gap" then
            local frame = self.points
            for i = 1, #frame do
                local icon = frame[i]
                if hasPoints then
                    icon:ClearAllPoints()
                    PositionIcon(icon, i, frame[i-1])
                else
                    PositionRune(frame[i], i)
                end
            end
        elseif event == "size" then
            local frame = self.points
            for i = 1, #frame do
                local icon = frame[i]
                icon:SetSize(settings.size.width, settings.size.height)
                if not hasPoints then
                    PositionRune(frame[i], i)
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
    unitFrame.ClassPower = _G.CreateFrame("Frame", nil, unitFrame)
    local ClassPower = unitFrame.ClassPower
    ClassPower:SetSize(16, 16)

    local texture, size = powerTextures[powerToken] or powerTextures.circle, pointDB.size
    for index = 1, MAX_POINTS do
        local name, icon = "ClassPower"..index
        if playerClass == "WARLOCK" then
            icon = unitFrame:CreateAngle("StatusBar", name, ClassPower)
            icon:SetSize(size.width, size.height)
            icon:SetAngleVertex(2, 3)
            icon:SetMinMaxValues(0, 1)
        else
            icon = _G.CreateFrame("StatusBar", name, ClassPower)
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
            PositionIcon(icon, index, ClassPower[index-1])
            tex = texture
        end

        icon:SetStatusBarTexture(tex)
        icon.bg:SetTexture(tex)
        icon.bg.multiplier = 0.5

        ClassPower[index] = icon
    end

    CombatFader:RegisterFrameForFade(MODNAME, ClassPower)
    if hasPoints then
        FramePoint:PositionFrame(self, ClassPower, {"class", "points", "position"})
    else
        ClassPower:SetPoint("CENTER", -160, -40.5)
    end

    function ClassPower.PostUpdate(element, cur, max, hasMaxChanged, powerType)
        self:debug("ClassPower:PostUpdate", cur, max, hasMaxChanged, powerType)
        for i = 1, max or 0 do -- max is nil for classes without a secondary power
            local icon, isUnused = element[i], i > cur
            self:debug("Icon", i, isUnused)
            if isUnused then
                if not pointDB.hideempty or self.configMode then
                    icon:Show()
                else
                    icon:Hide()
                end
            end
        end
    end

    unitFrame.ClassPower = ClassPower
    return ClassPower
end
function ClassResource:CreateRunes(unitFrame, unit)
    self:debug("CreateRunes", unit)
    unitFrame.Runes = _G.CreateFrame("Frame", nil, unitFrame)
    local Runes = unitFrame.Runes
    Runes:SetSize(16, 16)
    Runes.colorSpec = true

    local size = pointDB.size
    for index = 1, MAX_RUNES do
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

    return Runes
end
function ClassResource:CreateStagger(unitFrame, unit)
    self:debug("CreateStagger", unit)
    unitFrame.Stagger = unitFrame:CreateAngle("StatusBar", nil, unitFrame)
    local Stagger = unitFrame.Stagger

    Stagger:SetSize(barDB.size.width, barDB.size.height)
    Stagger:SetAngleVertex(1, 3)

    FramePoint:PositionFrame(self, Stagger, {"class", "bar", "position"})

    function Stagger.PostUpdate(element, cur, max)
        local r, g, b = element:GetStatusBarColor()
        self:debug("Stagger:PostUpdate", cur, max, r, g, b)
        if self.configMode then
            cur = max * 0.3
            element:SetValue(cur)
            local color = unitFrame.colors.power[_G.BREWMASTER_POWER_BAR_NAME][2]
            r, g, b = color[1], color[2], color[3]
        end
        element:SetShown(cur > 0)
        element:SetStatusBarColor(RealUI.ColorDarken(0.5, r, g, b))
    end

    return Stagger
end

local classPowers = {
    DEATHKNIGHT = "RUNES",
    DRUID = "COMBO_POINTS",
    MAGE = "ARCANE_CHARGES",
    MONK = "CHI",
    PALADIN = "HOLY_POWER",
    ROGUE = "COMBO_POINTS",
    WARLOCK = "SOUL_SHARDS",
}
function ClassResource:Setup(unitFrame, unit)
    -- Points
    local points = self:CreateClassPower(unitFrame, unit)
    if playerClass == "DEATHKNIGHT" then
        points = self:CreateRunes(unitFrame, unit)
    end

    if powerToken and points then
        self.points = points
        self.points.info = {token = powerToken, name = _G[powerToken]}
    end

    -- Bars
    if playerClass == "MONK" then
        self.bar = self:CreateStagger(unitFrame, unit)
        self.bar.info = _G.GetSpellInfo(124255)
    end
end

function ClassResource:ToggleConfigMode(isConfigMode)
    if self.configMode == isConfigMode then return end
    self.configMode = isConfigMode

    if isConfigMode then
        if self.points then
            self.points:SetAlpha(1)
            if hasPoints then
                for i = 1, 5 do
                    self.points[i]:SetShown(isConfigMode)
                end
                self.points:PostUpdate(isConfigMode and 3 or 0, isConfigMode and 5 or 0, true, powerToken)
            else
                for i = 1, MAX_RUNES do
                    self.points[i]:SetValue(i / MAX_RUNES)
                end
            end
        end
        if self.bar then
            local maxHealth = _G.UnitHealthMax("player")
            self.bar:SetMinMaxValues(0, maxHealth)
            self.bar:PostUpdate(maxHealth * 0.4, maxHealth)
        end
    else
        ClassResource:ForceUpdate()
    end
end

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

    local isEnabled = RealUI:GetModuleEnabled(MODNAME)

    -- Setup resources
    powerToken = classPowers[playerClass]
    hasPoints = powerToken and powerToken ~= "RUNES"

    if not isEnabled then
        if powerToken then
            self.points = {}
            self.points.info = {token = powerToken, name = _G[powerToken]}
        end
        if playerClass == "MONK" then
            self.bar = {}
            self.bar.info = _G.GetSpellInfo(124255)
        end
    end

    self:SetEnabledState(isEnabled)
end

function ClassResource:OnEnable()
    self:debug("OnEnable")

    CombatFader:RegisterModForFade(MODNAME, "class", "combatfade")
    FramePoint:RegisterMod(self)
end
