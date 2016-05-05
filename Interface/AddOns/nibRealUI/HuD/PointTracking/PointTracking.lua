local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next
--local tinsert = _G.table.insert

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
local iconFrames = {}

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

do
    local locked = true
    function PointTracking:Lock()
        if not locked then
            locked = true
            local frame = iconFrames.Runes or iconFrames.ClassIcons
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
        if locked then
            locked = false
            local frame = iconFrames.Runes or iconFrames.ClassIcons
            frame:EnableMouse(true)
            frame.bg:Show()
        end
    end
end

local function PositionRune(rune, index)
    local size = db.size
    local gap, middle, mod = size.gap + 2, (MAX_RUNES / 2) + 0.5
    if index < middle then
        mod = index - _G.min(middle)
    else
        mod = index - _G.max(middle)
    end
    rune:SetPoint("CENTER", (size.width + gap) * mod, 0)
end

function PointTracking:SettingsUpdate(event)
    self:debug("SettingsUpdate", event)
    if event == "gap" then
        local size = db.size
        for element, frame in next, iconFrames do
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
                    local gap = db.reverse and -(size.gap) or size.gap
                    local point, _, relPoint = icon:GetPoint()
                    if i == 1 then
                        icon:SetPoint(point)
                    else
                        icon:SetPoint(point, frame[i-1], relPoint, gap, 0)
                    end
                end
            end
        end
    elseif event == "size" then
        for element, frame in next, iconFrames do
            for i = 1, #frame do
                local icon = frame[i]
                icon:SetSize(db.size.width, db.size.height)
                if element == "Runes" then
                    PositionRune(frame[i], i)
                end
            end
        end
    elseif event == "position" then
        local frame = iconFrames.Runes or iconFrames.ClassIcons
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

    local texture = powerTextures[ClassPowerType] or powerTextures.circle
    local point, size = db.reverse and "RIGHT" or "LEFT", db.size
    local gap = db.reverse and -(size.gap) or size.gap
    for index = 1, (isBeta and 8 or 6) do
        local Icon = _G.CreateFrame("Frame", "ClassIcon"..index, ClassIcons)
        Icon:SetSize(size.width, size.height)

        local bg = Icon:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()

        if PlayerClass == "PALADIN" then
            Icon:SetPoint("CENTER")
            bg:SetTexture(texture[index])
        else
            if index == 1 then
                Icon:SetPoint(point)
            else
                Icon:SetPoint(point, ClassIcons[index-1], db.reverse and "LEFT" or "RIGHT", gap, 0)
            end

            local coords = texture.coords
            bg:SetTexture(texture.bg)
            bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])

            local border = Icon:CreateTexture(nil, "BORDER")
            border:SetAllPoints()
            border:SetTexture(texture.border)
            border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        end

        function Icon:SetVertexColor(r, g, b)
            PointTracking:debug("Icon:SetVertexColor", index, r, g, b)
            bg:SetVertexColor(r, g, b)
        end

        ClassIcons[index] = Icon
    end
    unitFrame.ClassIcons = ClassIcons
    iconFrames.ClassIcons = ClassIcons

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

    local size = db.size
    for index = 1, MAX_RUNES do
        local Rune = _G.CreateFrame("StatusBar", "Rune"..index, Runes)
        Rune:SetOrientation("VERTICAL")
        Rune:SetSize(size.width, size.height)
        PositionRune(Rune, index)

        local tex = Rune:CreateTexture(nil, "ARTWORK")
        tex:SetTexture(0.8, 0.8, 0.8)
        Rune:SetStatusBarTexture(tex)

        local bg = Rune:CreateTexture(nil, "BACKGROUND")
        bg:SetTexture(0, 0, 0)
        bg:SetPoint("TOPLEFT", tex, -1, 1)
        bg:SetPoint("BOTTOMRIGHT", tex, 1, -1)

        Runes[index] = Rune
    end

    unitFrame.Runes = Runes
    iconFrames.Runes = Runes
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

    local size, sizeMod = db.size, 2
    for index = 1, 4 do
        local ember = unitFrame:CreateAngleFrame("Status", size.width + sizeMod, size.height - sizeMod, BurningEmbers, info)
        ember:SetStatusBarColor(color[1], color[2], color[3])
        if index == 1 then
            ember:SetPoint("LEFT")
        else
            ember:SetPoint("LEFT", BurningEmbers[index-1], "RIGHT", size.gap, 0)
        end
        BurningEmbers[index] = ember
    end
    unitFrame.BurningEmbers = BurningEmbers
    iconFrames.BurningEmbers = BurningEmbers
end

function PointTracking:ToggleConfigMode(val)
    local powerID, iconFrame
    if not isBeta and (PlayerClass == "WARLOCK" and _G.GetSpecialization() == _G.SPEC_WARLOCK_DESTRUCTION) then
        powerID = _G.SPELL_POWER_BURNING_EMBERS
        iconFrame = iconFrames.BurningEmbers
    else
        powerID = ClassPowerID
        iconFrame = iconFrames.ClassIcons
    end
    if RealUI:GetModuleEnabled(MODNAME) then
        for i = 1, _G.UnitPowerMax("player", powerID) do
            iconFrame[i]:SetShown(val)
        end
    end
end

function PointTracking:OnInitialize()
    self:debug("OnInitialize")
    local classDB do
        classDB = {
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
    self:SetEnabledState(ClassPowerType and RealUI:GetModuleEnabled(MODNAME))
end

function PointTracking:OnEnable()
    self:debug("OnEnable")
    ClassPowerID = _G["SPELL_POWER_"..ClassPowerType]

    CombatFader:RegisterModForFade(MODNAME, db.combatfade)
    RealUI:RegisterConfigModeModule(self)
end
