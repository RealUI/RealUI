local _, private = ...
if private.RealUI.isBeta then return end

-- Lua Globals --
local _G = _G
local next = _G.next

-- Libs --
local LibWin = _G.LibStub("LibWindow-1.1")

-- RealUI --
local RealUI = private.RealUI
local isBeta = RealUI.isBeta
local db

local CombatFader = RealUI:GetModule("CombatFader")

local MODNAME = "PointTracking"
local PointTracking = RealUI:GetModule(MODNAME)

local PlayerClass = RealUI.class
local ClassPowerID, ClassPowerType

local MAX_RUNES = 6
local classPowers = {
    DEATHKNIGHT = "RUNES",
    DRUID = "COMBO_POINTS",
    MAGE = isBeta and "ARCANE_CHARGES",
    MONK = "CHI",
    PALADIN = "HOLY_POWER",
    PRIEST = not isBeta and "SHADOW_ORBS",
    ROGUE = "COMBO_POINTS",
    WARLOCK = "SOUL_SHARDS",
}
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

function PointTracking:GetResource()
    if ClassPowerID and ClassPowerType then
        if PlayerClass == "WARLOCK" then
            return {{type = ClassPowerType, id = ClassPowerID}, {type = "BURNING_EMBERS", id = _G.SPELL_POWER_BURNING_EMBERS}}
        else
            return {{type = ClassPowerType, id = ClassPowerID}}
        end
    end
end

function PointTracking:Lock()
    if not db.locked then
        db.locked = true
        local frame = self.Runes or self.ClassIcons
        frame:EnableMouse(false)
        frame.bg:Hide()
    end
    if not RealUI.isInTestMode then
        self:ToggleConfigMode(false)
    end
end
function PointTracking:Unlock()
    if not RealUI.isInTestMode then
        self:ToggleConfigMode(true)
    end
    if db.locked then
        db.locked = false
        local frame = self.Runes or self.ClassIcons
        frame:EnableMouse(true)
        frame.bg:Show()
    end
end

local function PositionRune(rune, index)
    PointTracking:debug("PositionRune", rune, index)
    local size = db.size
    local gap, middle, mod = size.gap + 2, (MAX_RUNES / 2) + 0.5
    if index < middle then
        mod = index - _G.min(middle)
    else
        mod = index - _G.max(middle)
    end
    rune:SetPoint("CENTER", (size.width + gap) * mod, 0)
end
local function PositionIcon(icon, index, prevIcon)
    local point, size = db.reverse and "RIGHT" or "LEFT", db.size
    local gap = db.reverse and -(size.gap) or size.gap
    if index == 1 then
        icon:SetPoint(point)
    else
        icon:SetPoint(point, prevIcon, db.reverse and "LEFT" or "RIGHT", gap, 0)
    end
end

function PointTracking:SettingsUpdate(event)
    self:debug("SettingsUpdate", event)
    if event == "gap" then
        local size = db.size
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
                icon:SetSize(db.size.width, db.size.height)
                if element == "Runes" then
                    PositionRune(frame[i], i)
                end
            end
        end
    elseif event == "position" then
        local frame = self.Runes or self.ClassIcons
        frame:RestorePosition()
    end
end

local function GetAnticipation(unitFrame)
    local ClassIcons = unitFrame.ClassIcons
    local index, id = 1, 115189
    local points = 0
    repeat
        local name, _, _, count, _, _, _, _, _, _, spellID = _G.UnitAura("player", index, "HELPFUL")
        PointTracking:debug("Spell", index, name, spellID, count)
        if (spellID == id) then
            points = count
        end

        index = index + 1
    until(not spellID)

    local cur, max = _G.UnitPower("player", ClassPowerID), _G.UnitPowerMax("player", ClassPowerID)
    PointTracking:debug("points", points)
    for i = 1, max do
        local icon = ClassIcons[i]
        if i <= cur then
            PointTracking:debug("Active", i)
            -- This is an active combo point
            if i <= points then
                PointTracking:debug("isAP")
                -- Has AP; Change color to dark red
                icon:SetVertexColor(0.7, 0, 0)
            else
                PointTracking:debug("not isAP")
                -- Does not have AP; Revert color
                local color = _G.PowerBarColor["COMBO_POINTS"] or {r = 1.00, g = 0.96, b = 0.41}
                icon:SetVertexColor(color.r, color.g, color.b)
            end
        else
            PointTracking:debug("Inactive", i)
            -- This is not an active combo point
            if i <= points then
                PointTracking:debug("isAP")
                -- Has AP; Show and change color to light red
                icon:Show()
                icon:SetVertexColor(1.0, 0.5, 0.5)
            else
                PointTracking:debug("not isAP")
                -- Does not have AP; Revert color and Hide
                local color = _G.PowerBarColor["COMBO_POINTS"] or {r = 1.00, g = 0.96, b = 0.41}
                icon:SetVertexColor(color.r, color.g, color.b)
                icon:Hide()
            end
        end
    end
end

function PointTracking:CreateClassIcons(unitFrame, unit)
    self:debug("CreateClassIcons", unit)
    local ClassIcons = _G.CreateFrame("Frame", nil, _G.UIParent)
    CombatFader:RegisterFrameForFade(MODNAME, ClassIcons)
    ClassIcons:SetSize(16, 16)

    LibWin:Embed(ClassIcons)
    ClassIcons:RegisterConfig(db.position)
    ClassIcons:RestorePosition()
    ClassIcons:SetMovable(true)
    ClassIcons:RegisterForDrag("LeftButton")
    ClassIcons:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    ClassIcons:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
    end)

    local bg = ClassIcons:CreateTexture()
    bg:SetTexture(1, 1, 1, 0.5)
    bg:SetAllPoints(ClassIcons)
    bg:Hide()
    ClassIcons.bg = bg

    function ClassIcons:PostUpdate(cur, max, hasMaxChanged, event)
        PointTracking:debug("ClassIcons:PostUpdate", cur, max, hasMaxChanged, event, db.hideempty, PointTracking.configMode)
        if not db.hideempty or (event == "ForceUpdate" or PointTracking.configMode) then
            for i = 1, max or 0 do -- max will be nil when the icon is disabled
                local iconBG = self[i].bg
                local alpha = RealUI.Lerp(db.combatfade.opacity.incombat, db.combatfade.opacity.outofcombat, self:GetAlpha())
                iconBG:SetDesaturated(i > cur)
                iconBG:SetAlpha(iconBG:IsDesaturated() and alpha or 1)
                self[i]:SetShown(PointTracking.configMode or not db.hideempty)
            end
        end
    end

    local texture, size = powerTextures[ClassPowerType] or powerTextures.circle, db.size
    for index = 1, (isBeta and 8 or 6) do
        local icon = _G.CreateFrame("Frame", "ClassIcon"..index, ClassIcons)
        icon:SetSize(size.width, size.height)

        local iconBG = icon:CreateTexture(nil, "BACKGROUND")
        iconBG:SetAllPoints()
        icon.bg = iconBG

        if PlayerClass == "PALADIN" then
            icon:SetPoint("CENTER")
            iconBG:SetTexture(texture[index])
        else
            PositionIcon(icon, index, ClassIcons[index-1])

            local coords = texture.coords
            iconBG:SetTexture(texture.bg)
            iconBG:SetTexCoord(coords[1], coords[2], coords[3], coords[4])

            local border = icon:CreateTexture(nil, "BORDER")
            border:SetAllPoints()
            border:SetTexture(texture.border)
            border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        end

        function icon:SetVertexColor(r, g, b)
            PointTracking:debug("icon:SetVertexColor", index, r, g, b)
            iconBG:SetVertexColor(r, g, b)
        end

        ClassIcons[index] = icon
    end
    unitFrame.ClassIcons = ClassIcons
    PointTracking.ClassIcons = ClassIcons

    if not isBeta and PlayerClass == "ROGUE" then
        unitFrame:RegisterEvent("UNIT_AURA", GetAnticipation)
    end
end

function PointTracking:CreateRunes(unitFrame, unit)
    self:debug("CreateRunes", unit)
    local Runes = _G.CreateFrame("Frame", nil, _G.UIParent)
    CombatFader:RegisterFrameForFade(MODNAME, Runes)
    Runes:SetSize(16, 16)

    LibWin:Embed(Runes)
    Runes:RegisterConfig(db.position)
    Runes:RestorePosition()
    Runes:SetMovable(true)
    Runes:RegisterForDrag("LeftButton")
    Runes:SetScript("OnDragStart", function(...)
        LibWin.OnDragStart(...)
    end)
    Runes:SetScript("OnDragStop", function(...)
        LibWin.OnDragStop(...)
    end)

    local bg = Runes:CreateTexture()
    if isBeta then
        bg:SetColorTexture(1, 1, 1, 0.5)
    else
        bg:SetTexture(1, 1, 1, 0.5)
    end
    bg:SetAllPoints(Runes)
    bg:Hide()
    Runes.bg = bg

    local size = db.size
    for index = 1, MAX_RUNES do
        local Rune = _G.CreateFrame("StatusBar", "Rune"..index, Runes)
        Rune:SetOrientation("VERTICAL")
        Rune:SetSize(size.width, size.height)
        PositionRune(Rune, index)

        local tex = Rune:CreateTexture(nil, "ARTWORK")
        local color = unitFrame.colors.power.RUNES
        if isBeta then
            tex:SetColorTexture(color[1], color[2], color[3])
        else
            tex:SetTexture(color[1], color[2], color[3])
        end
        Rune:SetStatusBarTexture(tex)

        local runeBG = Rune:CreateTexture(nil, "BACKGROUND")
        if isBeta then
            runeBG:SetColorTexture(0, 0, 0)
        else
            runeBG:SetTexture(0, 0, 0)
        end
        runeBG:SetPoint("TOPLEFT", tex, -1, 1)
        runeBG:SetPoint("BOTTOMRIGHT", tex, 1, -1)

        Runes[index] = Rune
    end

    unitFrame.Runes = Runes
    self.Runes = Runes
end

function PointTracking:CreateBurningEmbers(unitFrame, unit)
    self:debug("CreateBurningEmbers", unit)
    local info = {
        leftAngle = [[\]],
        rightAngle = [[\]],
        smooth = false,
    }
    local color
    if _G.IsSpellKnown(_G.WARLOCK_GREEN_FIRE) then
        color = {0.2, 0.8, 0.2}
    else
        color = {0.8, 0.2, 0.2}
    end

    local BurningEmbers = _G.CreateFrame("Frame", nil, _G.UIParent)
    BurningEmbers:SetAllPoints(unitFrame.ClassIcons)
    CombatFader:RegisterFrameForFade(MODNAME, BurningEmbers)

    function BurningEmbers:PostUpdate(curFull, curRaw, maxFull, maxRaw, event)
        PointTracking:debug("BurningEmbers:PostUpdate", curFull, curRaw, maxFull, maxRaw, event, db.hideempty, PointTracking.configMode)
        for i = 1, (maxFull or 0) do
            local ember = self[i]
            local alpha = RealUI.Lerp(db.combatfade.opacity.incombat, db.combatfade.opacity.outofcombat, self:GetAlpha())
            if i <= curFull then
                ember:SetStatusBarColor(color[1] * 2, color[2] * 2, color[3] * 2)
                ember:Show()
            elseif i == curFull+1 and curRaw % 10 > 0 then
                ember:SetStatusBarColor(color[1], color[2], color[3])
                ember:SetAlpha(alpha * 2)
                ember:Show()
            elseif not db.hideempty or (event == "ForceUpdate" or PointTracking.configMode) then
                ember:SetStatusBarColor(color[1], color[2], color[3])
                ember:SetAlpha(alpha)
                ember:Show()
            end
        end
    end

    local size, sizeMod = db.size, 2
    for index = 1, 4 do
        local ember = unitFrame:CreateAngleFrame("Status", size.width + sizeMod, size.height - sizeMod, BurningEmbers, info)
        if index == 1 then
            ember:SetPoint("LEFT")
        else
            ember:SetPoint("LEFT", BurningEmbers[index-1], "RIGHT", size.gap, 0)
        end
        BurningEmbers[index] = ember
    end
    unitFrame.BurningEmbers = BurningEmbers
    self.BurningEmbers = BurningEmbers
end

function PointTracking:Setup(unitFrame, unit)
    if PlayerClass == "DEATHKNIGHT" then
        self:CreateRunes(unitFrame, unit)
    else
        self:CreateClassIcons(unitFrame, unit)
        if not isBeta and PlayerClass == "WARLOCK" then
            self:CreateBurningEmbers(unitFrame, unit)
        end
    end
end

function PointTracking:ForceUpdate()
    if self.ClassIcons then
        self.ClassIcons:ForceUpdate()
    end
    if self.BurningEmbers then
        self.BurningEmbers:ForceUpdate()
    end
end

function PointTracking:ToggleConfigMode(val)
    if self.configMode == val then return end
    self.configMode = val

    self:ForceUpdate()
end

function PointTracking:OnInitialize()
    self:debug("OnInitialize")
    local classDB do
        classDB = {
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
            combatfade = {
                enabled = true,
                opacity = {
                    incombat = 1,
                    harmtarget = .8,
                    target = .8,
                    hurt = .5,
                    outofcombat = .3,
                }
            }
        }

        if PlayerClass == "DEATHKNIGHT" then
            classDB.size.width = 9
            classDB.size.height = 38
            classDB.size.gap = 1

            classDB.position.x = 0
            classDB.position.y = -110

            classDB.combatfade.opacity.outofcombat = 0
        elseif PlayerClass == "PALADIN" then
            classDB.size.width = 64
            classDB.size.height = 64

            classDB.position.x = 0
            classDB.position.y = -110
        elseif PlayerClass == "WARLOCK" then
            classDB.size.width = 24
            classDB.size.height = 13
            classDB.size.gap = -5
        end
    end

    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        class = classDB
    })
    db = self.db.class

    ClassPowerType = classPowers[PlayerClass]
    ClassPowerID = ClassPowerType and _G["SPELL_POWER_"..ClassPowerType]
    self:SetEnabledState(ClassPowerType and RealUI:GetModuleEnabled(MODNAME))
end

function PointTracking:OnEnable()
    self:debug("OnEnable")

    CombatFader:RegisterModForFade(MODNAME, db.combatfade)
    RealUI:RegisterConfigModeModule(self)
end
