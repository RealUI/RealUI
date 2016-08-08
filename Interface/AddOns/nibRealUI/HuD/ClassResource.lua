local _, private = ...

-- Lua Globals --
local _G = _G
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
    circle = {
        coords = {0.125, 0.9375, 0.0625, 0.875},
        bg = [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_BG]],
        border = [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_Surround]]
    },
    SOUL_SHARDS = {
        coords = {0.0625, 0.8125, 0.0625, 0.875},
        bg = [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_BG]],
        border = [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_Surround]]
    },
    HOLY_POWER = {
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower1]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower2]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower3]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower4]],
        [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower5]]
    }
}

local MAX_RUNES = 6
local MAX_POINTS = 8

function ClassResource:GetResources()
    return self.points, self.bar
end

local dragBG
local function GetFrame(kind)
    return kind == "points" and (ClassResource.Runes or ClassResource.ClassIcons) or ClassResource.resource
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
            local size = settings.size
            for _, element in next, {"Runes", "BurningEmbers", "ClassIcons"} do
                local frame = self[element]
                self:debug("element", element, #frame)
                for i = 1, #frame do
                    local icon = frame[i]
                    if element == "Runes" then
                        PositionRune(frame[i], i)
                    elseif element == "BurningEmbers" then
                        if i == 1 then
                            icon:SetPoint("LEFT")
                        else
                            icon:SetPoint("LEFT", frame[i-1], "RIGHT", size.gap, 0)
                        end
                    elseif element == "ClassIcons" then
                        icon:ClearAllPoints()
                        PositionIcon(icon, i, frame[i-1])
                    end
                end
            end
        elseif event == "size" then
            for _, element in next, {"Runes", "BurningEmbers", "ClassIcons"} do
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
            local frame = self.Runes or self.ClassIcons
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

function ClassResource:CreateClassIcons(unitFrame, unit)
    self:debug("CreateClassIcons", unit)
    local ClassIcons = _G.CreateFrame("Frame", nil, _G.UIParent)
    CombatFader:RegisterFrameForFade(MODNAME, ClassIcons)
    ClassIcons:SetSize(16, 16)

    LibWin:Embed(ClassIcons)
    ClassIcons:RegisterConfig(pointDB.position)
    ClassIcons:RestorePosition()
    ClassIcons:SetMovable(true)
    ClassIcons:RegisterForDrag("LeftButton")
    ClassIcons:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    ClassIcons:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
    end)

    dragBG = ClassIcons:CreateTexture()
    dragBG:SetColorTexture(1, 1, 1, 0.5)
    dragBG:Hide()

    function ClassIcons.PostUpdate(element, cur, max, hasMaxChanged, power, event)
        self:debug("ClassIcons:PostUpdate", cur, max, hasMaxChanged, power, event, pointDB.hideempty, self.configMode)
        if not pointDB.hideempty or (event == "ForceUpdate" or self.configMode) then
            for i = 1, max or 0 do -- max will be nil when the icon is disabled
                local iconBG = element[i].bg
                local alpha = _G.Lerp(db.combatfade.opacity.incombat, db.combatfade.opacity.outofcombat, element:GetAlpha())
                iconBG:SetDesaturated(i > cur)
                iconBG:SetAlpha(iconBG:IsDesaturated() and alpha or 1)
                element[i]:SetShown(self.configMode or not pointDB.hideempty)
            end
        end
    end

    local texture, size = powerTextures[powerToken] or powerTextures.circle, pointDB.size
    for index = 1, MAX_POINTS do
        local icon = _G.CreateFrame("Frame", "ClassIcon"..index, ClassIcons)
        icon:SetSize(size.width, size.height)

        local iconBG = icon:CreateTexture(nil, "BACKGROUND")
        iconBG:SetAllPoints()
        icon.bg = iconBG

        if playerClass == "PALADIN" then
            icon:SetPoint("CENTER")
            iconBG:SetTexture(texture[index])
        else
            PositionIcon(icon, index, ClassIcons[index-1])

            local color = unitFrame.colors.power[powerToken or 'COMBO_POINTS']
            local coords = texture.coords
            iconBG:SetTexture(texture.bg)
            iconBG:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            iconBG:SetVertexColor(color[1], color[2], color[3])

            local border = icon:CreateTexture(nil, "BORDER")
            border:SetAllPoints()
            border:SetTexture(texture.border)
            border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        end

        ClassIcons[index] = icon
    end
    unitFrame.ClassIcons = ClassIcons
    ClassResource.ClassIcons = ClassIcons
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

    function Runes:PostUpdate(rune, rid, start, duration, runeReady)
        local color = unitFrame.colors.power.RUNES
        if runeReady then
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
    local info = {
        leftAngle = [[/]],
        rightAngle = [[\]],
        smooth = false,
    }

    local size = barDB.size
    local stagger = unitFrame:CreateAngleFrame("Status", size.width, size.height, _G.UIParent, info)

    LibWin:Embed(stagger)
    stagger:RegisterConfig(barDB.position)
    stagger:RestorePosition()
    stagger:SetMovable(true)
    stagger:RegisterForDrag("LeftButton")
    stagger:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    stagger:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
    end)

    function stagger.PostUpdate(element, maxHealth, curStagger, perStagger, r, g, b)
        if self.configMode then
            curStagger = maxHealth * 0.3
            element:SetValue(curStagger)
            local color = unitFrame.colors.power[_G.BREWMASTER_POWER_BAR_NAME][2]
            r, g, b = color[1], color[2], color[3]
        end
        element:SetShown(curStagger > 0)
        element:SetStatusBarColor(RealUI:ColorDarken(0.5, r, g, b))
    end

    unitFrame.Stagger = stagger
    self.resource = stagger
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
    self:CreateClassIcons(unitFrame, unit)
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

    self.ClassIcons:PostUpdate(3, 6, false, powerToken, "ForceUpdate")
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
            points.size.width = 24
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
