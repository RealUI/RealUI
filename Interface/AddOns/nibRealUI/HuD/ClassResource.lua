local _, private = ...

-- Lua Globals --
local next = _G.next
--local tinsert = _G.table.insert

-- Libs --
local LibWin = _G.LibStub("LibWindow-1.1")

-- RealUI --
local RealUI = private.RealUI
local db, pointDB, barDB

local CombatFader = RealUI:GetModule("CombatFader")

local MODNAME = "ClassResource"
local ClassResource = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local playerClass = RealUI.class
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

function ClassResource:GetResources()
    return self.points, self.bar
end

local dragBG
local function GetFrame(kind)
    return kind == "points" and (ClassResource.Runes or ClassResource.ClassPower) or ClassResource.resource
end

function ClassResource:ForceUpdate()
    (ClassResource.Runes or ClassResource.ClassPower):ForceUpdate()
    if ClassResource.resource then
        ClassResource.resource:ForceUpdate()
    end
end

function ClassResource:Lock(kind)
    if not db[kind].locked then
        db[kind].locked = true
        local frame = GetFrame(kind)
        frame:EnableMouse(false)
        dragBG:ClearAllPoints()
        dragBG:Hide()
    end
    if not RealUI.isInTestMode then
        self:ToggleConfigMode(false)
    end
end
function ClassResource:Unlock(kind)
    if not RealUI.isInTestMode then
        self:ToggleConfigMode(true)
    end
    if db[kind].locked then
        db[kind].locked = false
        local frame = GetFrame(kind)
        frame:EnableMouse(true)
        dragBG:SetPoint("TOPLEFT", frame, -2, 2)
        dragBG:SetPoint("BOTTOMRIGHT", frame, 2, -2)
        dragBG:Show()
    end
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
            for _, element in next, {"Runes", "ClassPower"} do
                local frame = self[element]
                self:debug("element", element, #frame)
                for i = 1, #frame do
                    local icon = frame[i]
                    if element == "Runes" then
                        PositionRune(frame[i], i)
                    elseif element == "ClassPower" then
                        icon:ClearAllPoints()
                        PositionIcon(icon, i, frame[i-1])
                    end
                end
            end
        elseif event == "size" then
            for _, element in next, {"Runes", "ClassPower"} do
                local frame = self[element]
                for i = 1, #frame do
                    local icon = frame[i]
                    icon:SetSize(settings.size.width, settings.size.height)
                    if element == "Runes" then
                        PositionRune(frame[i], i)
                    end
                end
            end
        elseif event == "position" then
            local frame = self.Runes or self.ClassPower
            frame:RestorePosition()
        end
    elseif kind == "bar" then
        if event == "size" then
            self.resource:SetSize(settings.size.width, db.size.height)
        elseif event == "position" then
            self.resource:RestorePosition()
        end
    end
end

function ClassResource:CreateClassPower(unitFrame, unit)
    self:debug("CreateClassPower", unit)
    local ClassPower = _G.CreateFrame("Frame", nil, _G.UIParent)
    CombatFader:RegisterFrameForFade(MODNAME, ClassPower)
    ClassPower:SetSize(16, 16)

    LibWin:Embed(ClassPower)
    ClassPower:RegisterConfig(pointDB.position)
    ClassPower:RestorePosition()
    ClassPower:SetMovable(true)
    ClassPower:RegisterForDrag("LeftButton")
    ClassPower:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    ClassPower:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
    end)

    dragBG = ClassPower:CreateTexture()
    dragBG:SetColorTexture(1, 1, 1, 0.5)
    dragBG:Hide()

    function ClassPower.PostUpdate(element, cur, max, mod, hasMaxChanged, powerType)
        self:debug("ClassPower:PostUpdate", cur, max, mod, hasMaxChanged, powerType)
        for i = 1, max or 0 do -- max is nil for classes without a secondary power
            local icon, isUnused = element[i], i > _G.ceil(cur / mod)
            if isUnused then
                if not pointDB.hideempty or self.configMode then
                    icon:Show()
                else
                    icon:Hide()
                end
            end
        end
    end

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
    unitFrame.ClassPower = ClassPower
    ClassResource.ClassPower = ClassPower
end
function ClassResource:CreateRunes(unitFrame, unit)
    self:debug("CreateRunes", unit)
    local Runes = _G.CreateFrame("Frame", nil, _G.UIParent)
    CombatFader:RegisterFrameForFade(MODNAME, Runes)
    Runes:SetSize(16, 16)

    LibWin:Embed(Runes)
    Runes:RegisterConfig(pointDB.position)
    Runes:RestorePosition()
    Runes:SetMovable(true)
    Runes:RegisterForDrag("LeftButton")
    Runes:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    Runes:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
    end)

    local size = pointDB.size
    for index = 1, MAX_RUNES do
        local Rune = _G.CreateFrame("StatusBar", "Rune"..index, Runes)
        Rune:SetOrientation("VERTICAL")
        Rune:SetSize(size.width, size.height)
        PositionRune(Rune, index)

        local tex = Rune:CreateTexture(nil, "ARTWORK")
        Rune:SetStatusBarTexture(tex)
        Rune.tex = tex

        local runeBG = Rune:CreateTexture(nil, "BACKGROUND")
        runeBG:SetColorTexture(0, 0, 0)
        runeBG:SetPoint("TOPLEFT", tex, -1, 1)
        runeBG:SetPoint("BOTTOMRIGHT", tex, 1, -1)

        Runes[index] = Rune
    end

    Runes.colorSpec = true
    function Runes.PostUpdate(element, rune, runeID, start, duration, isReady)
        local color = unitFrame.colors.power.RUNES
        if isReady then
            rune.tex:SetColorTexture(color[1], color[2], color[3])
        else
            rune.tex:SetColorTexture(color[1], color[2], color[3], 0.4)
        end
    end
    unitFrame.Runes = Runes
    self.Runes = Runes
end
function ClassResource:CreateStagger(unitFrame, unit)
    self:debug("CreateStagger", unit)
    local size = barDB.size
    local Stagger = unitFrame:CreateAngle("StatusBar", nil, _G.UIParent)
    Stagger:SetSize(size.width, size.height)
    Stagger:SetAngleVertex(1, 3)

    LibWin:Embed(Stagger)
    Stagger:RegisterConfig(barDB.position)
    Stagger:RestorePosition()
    Stagger:SetMovable(true)
    Stagger:RegisterForDrag("LeftButton")
    Stagger:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    Stagger:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
    end)

    function Stagger.PostUpdate(element, cur, max, r, g, b)
        if self.configMode then
            cur = max * 0.3
            element:SetValue(cur)
            local color = unitFrame.colors.power[_G.BREWMASTER_POWER_BAR_NAME][2]
            r, g, b = color[1], color[2], color[3]
        end
        element:SetShown(cur > 0)
        element:SetStatusBarColor(RealUI:ColorDarken(0.5, r, g, b))
    end

    unitFrame.Stagger = Stagger
    self.resource = Stagger
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
    self:CreateClassPower(unitFrame, unit)
    if playerClass == "DEATHKNIGHT" then
        self:CreateRunes(unitFrame, unit)
    end

    -- Bars
    if playerClass == "MONK" then
        self:CreateStagger(unitFrame, unit)
    end
end

function ClassResource:ToggleConfigMode(val)
    if self.configMode == val then return end
    self.configMode = val

    self.ClassPower:PostUpdate(3, 6, 1, false, powerToken, "ForceUpdate")
    if self.resource then
        self.resource:ForceUpdate()
    end
end

function ClassResource:OnInitialize()
    self:debug("OnInitialize")
    local points do
        points = {
            hideempty = true, -- Only show used icons
            reverse = false, -- Points start on the right
            locked = true,
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
            bar = {
                locked = true,
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

    -- Setup resources
    powerToken = classPowers[playerClass]
    if powerToken then
        self.points = {token = powerToken, name = _G[powerToken]}
    end
    if playerClass == "MONK" then
        self.bar = _G.GetSpellInfo(124255) -- Stagger
    end

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function ClassResource:OnEnable()
    self:debug("OnEnable")

    CombatFader:RegisterModForFade(MODNAME, db.combatfade)
    RealUI:RegisterConfigModeModule(self)
end
