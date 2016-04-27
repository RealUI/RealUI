local _, private = ...

-- Lua Globals --
local _G = _G
--local next, ipairs = _G.next, _G.ipairs
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

function PointTracking:GetResource()
    if ClassPowerID and ClassPowerType then
        if PlayerClass == "WARLOCK" then
            return {{type = ClassPowerType, id = ClassPowerID}, {type = "BURNING_EMBERS", id = _G.SPELL_POWER_BURNING_EMBERS}}
        else
            return {{type = ClassPowerType, id = ClassPowerID}}
        end
    end
end

local UpdateTexture do 
    local textures = {
        circle = {
            coords = {0.125, 0.9375, 0.0625, 0.875},
            bg = [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_BG]],
            border = [[Interface\Addons\nibRealUI\Media\PointTracking\Round_Large_Surround]]
        },
        shard = {
            coords = {0.0625, 0.8125, 0.0625, 0.875},
            bg = [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_BG]],
            border = [[Interface\Addons\nibRealUI\Media\PointTracking\SoulShard_Surround]]
        },
        holyPower = {
            [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower1]],
            [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower2]],
            [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower3]],
            [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower4]],
            [[Interface\Addons\nibRealUI\Media\PointTracking\HolyPower5]]
        }
    }

    function UpdateTexture(ClassIcons)
        local texture, color
        if (PlayerClass == "MAGE") then
            texture = textures.circle
            color = _G.PowerBarColor["ARCANE_CHARGES"]
        elseif (PlayerClass == "MONK") then
            texture = textures.circle
            color = _G.PowerBarColor["CHI"]
        elseif (PlayerClass == "PRIEST") then
            texture = textures.circle
            color = {r = 0.40, g = 0, b = 0.80}
        elseif (PlayerClass == "PALADIN") then
            texture = textures.holyPower
        elseif (PlayerClass == "WARLOCK") then
            texture = textures.shard
            color = _G.PowerBarColor["SOUL_SHARDS"]
        else
            texture = textures.circle
            color = _G.PowerBarColor["COMBO_POINTS"] or {r = 1.00, g = 0.96, b = 0.41}
        end

        for i = 1, #ClassIcons do
            local icon = ClassIcons[i]
            if texture.bg then
                local coords = texture.coords
                icon.bg:SetTexture(texture.bg)
                icon.bg:SetVertexColor(color.r, color.g, color.b)
                icon.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
                icon.border:SetTexture(texture.border)
                icon.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
            else
                icon.bg:SetTexture(texture[i])
            end
        end
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
                icon.bg:SetVertexColor(0.7, 0, 0)
            else
                PointTracking:debug("not isAP")
                -- Does not have AP; Revert color
                local color = _G.PowerBarColor["COMBO_POINTS"] or {r = 1.00, g = 0.96, b = 0.41}
                icon.bg:SetVertexColor(color.r, color.g, color.b)
            end
        else
            PointTracking:debug("Inactive", i)
            -- This is not an active combo point
            if i <= points then
                PointTracking:debug("isAP")
                -- Has AP; Show and change color to light red
                icon:Show()
                icon.bg:SetVertexColor(1.0, 0.5, 0.5)
            else
                PointTracking:debug("not isAP")
                -- Does not have AP; Revert color and Hide
                local color = _G.PowerBarColor["COMBO_POINTS"] or {r = 1.00, g = 0.96, b = 0.41}
                icon.bg:SetVertexColor(color.r, color.g, color.b)
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

    local point, size = db.reverse and "RIGHT" or "LEFT", db.size
    local gap = db.reverse and -(size.gap) or size.gap
    for index = 1, (isBeta and 8 or 6) do
        local Icon = _G.CreateFrame("Frame", nil, ClassIcons)
        Icon:SetSize(size.width, size.height)
        if PlayerClass == "PALADIN" then
            Icon:SetPoint("CENTER")
        else
            if index == 1 then
                Icon:SetPoint(point)
            else
                Icon:SetPoint(point, ClassIcons[index-1], db.reverse and "LEFT" or "RIGHT", gap, 0)
            end
        end

        local bg = Icon:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()

        local border = Icon:CreateTexture(nil, "BORDER")
        border:SetAllPoints()

        Icon.bg = bg
        Icon.border = border
        ClassIcons[index] = Icon
    end
    ClassIcons.UpdateTexture = UpdateTexture
    unitFrame.ClassIcons = ClassIcons
    iconFrames.ClassIcons = ClassIcons

    if not isBeta and PlayerClass == "WARLOCK" then
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
        CombatFader:RegisterFrameForFade(MODNAME, BurningEmbers)
        BurningEmbers:SetAllPoints(ClassIcons)
        for index = 1, 4 do
            local ember = unitFrame:CreateAngleFrame("Status", 28, 11, unitFrame, info)
            ember:SetStatusBarColor(color[1], color[2], color[3])
            if index == 1 then
                ember:SetPoint(point, BurningEmbers)
            else
                ember:SetPoint(point, BurningEmbers[index-1], iconData.reverse and "LEFT" or "RIGHT", gap, 0)
            end
            BurningEmbers[index] = ember
        end
        unitFrame.BurningEmbers = BurningEmbers
        iconFrames.BurningEmbers = BurningEmbers
    end
    if not isBeta and PlayerClass == "ROGUE" then
        unitFrame:RegisterEvent("UNIT_AURA", GetAnticipation)
    end
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

        if PlayerClass == "PALADIN" then
            classDB.size.width = 64
            classDB.size.height = 64

            classDB.position.x = 0
            classDB.position.y = -115
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

    if (PlayerClass == "MONK") then
        ClassPowerType = "CHI"
    elseif (PlayerClass == "PALADIN") then
        ClassPowerType = "HOLY_POWER"
    elseif (not isBeta and PlayerClass == "PRIEST") then
        ClassPowerType = "SHADOW_ORBS"
    elseif (PlayerClass == "WARLOCK") then
        ClassPowerType = "SOUL_SHARDS"
    elseif (PlayerClass == "ROGUE" or PlayerClass == "DRUID") then
        ClassPowerType = "COMBO_POINTS"
    elseif (isBeta and PlayerClass == "MAGE") then
        ClassPowerType = "ARCANE_CHARGES"
    end
    if ClassPowerType then
        ClassPowerID = _G["SPELL_POWER_"..ClassPowerType]
    end

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    CombatFader:RegisterModForFade(MODNAME, db.combatfade)
    RealUI:RegisterConfigModeModule(self)
end

function PointTracking:OnEnable()
    --[[
    CreateTables()
    CreateFrames()
    
    -- Turn off Config Mode
    for ic,vc in next, Types do
        for it,vt in ipairs(Types[ic].points) do
            local tid = Types[ic].points[it].id
            db[ic].types[tid].configmode.enabled = false
        end
    end
    
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TALENT_UPDATE")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")]]
end
