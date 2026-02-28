local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db, ndb

local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")

local MODNAME = "UnitFrames"
local UnitFrames = RealUI:NewModule(MODNAME, "AceEvent-3.0")

UnitFrames.units = {}

local units = {
    "Player",
    "Target",
    "Focus",
    "FocusTarget",
    "Pet",
    "TargetTarget",
}

function UnitFrames:RefreshUnits(event)
    for i = 1, #units do
        local frame = _G["RealUI" .. units[i] .. "Frame"]
        if not frame then
            self:debug("Unit frame not found:", units[i])
        else
            local unitKey = frame.unit
            local unitData = UnitFrames[unitKey]

            -- Update class color settings
            if frame.Health then
                frame.Health.colorClass = db.overlay.classColor
                frame.Health.colorHealth = not db.overlay.classColor

                -- Update fill direction: natural direction based on side, reverseFill toggles it
                local natural = false
                if unitData and unitData.health and unitData.health.point then
                    natural = unitData.health.point == "RIGHT"
                end
                local unitDB = db.units[unitKey]
                local reverseFill = natural
                if unitDB and unitDB.reverseFill then
                    reverseFill = not natural
                end

                if frame.Health.SetReverseFill then
                    frame.Health:SetReverseFill(reverseFill)
                end

                -- Retag health text
                if frame.Health.text then
                    frame:Untag(frame.Health.text)
                    frame:Tag(frame.Health.text, UnitFrames.GetHealthTagString(db.misc.statusText))
                end
            end

            -- Update power fill direction and retag power text
            if frame.Power then
                local natural = false
                if unitData and unitData.power and unitData.power.point then
                    natural = unitData.power.point == "RIGHT"
                end
                local unitDB = db.units[unitKey]
                local reverseFill = natural
                if unitDB and unitDB.reverseFill then
                    reverseFill = not natural
                end

                if frame.Power.SetReverseFill then
                    frame.Power:SetReverseFill(reverseFill)
                end

                if frame.Power.text then
                    frame:Untag(frame.Power.text)
                    local _, powerType = _G.UnitPowerType(unitKey)
                    frame:Tag(frame.Power.text, UnitFrames.GetPowerTagString(db.misc.statusText, powerType))
                end
            end

            -- Update aura counts on target frame
            if unitKey == "target" then
                if frame.Debuffs and db.units.target then
                    frame.Debuffs.num = db.units.target.debuffCount
                end
                if frame.Buffs and db.units.target then
                    frame.Buffs.num = db.units.target.buffCount
                end
            end

            frame:UpdateAllElements(event)
        end
    end

    -- Refresh boss frames
    for i = 1, 5 do
        local frame = _G["RealUIBossFrame" .. i]
        if frame then
            if frame.Health then
                frame.Health.colorClass = db.overlay.classColor
                frame.Health.colorHealth = not db.overlay.classColor

                if frame.Health.text then
                    frame:Untag(frame.Health.text)
                    frame:Tag(frame.Health.text, UnitFrames.GetHealthTagString(db.misc.statusText))
                end
            end

            if frame.Debuffs then
                frame.Debuffs.num = db.boss.debuffCount
            end
            if frame.Buffs then
                frame.Buffs.num = db.boss.buffCount
            end

            frame:UpdateAllElements(event)
        end
    end

    -- Refresh arena frames
    for i = 1, 5 do
        local frame = _G["RealUIArenaFrame" .. i]
        if frame then
            if frame.Health then
                frame.Health.colorClass = db.overlay.classColor
                frame.Health.colorHealth = not db.overlay.classColor

                if frame.Health.text then
                    frame:Untag(frame.Health.text)
                    frame:Tag(frame.Health.text, UnitFrames.GetHealthTagString(db.misc.statusText))
                end
            end

            frame:UpdateAllElements(event)
        end
    end
end

UnitFrames.steppoints = {
    default = {0.35, 0.25},
    health = {
        HUNTER  = {0.8, 0.2},
        PALADIN = {0.4, 0.2},
        WARRIOR = {0.35, 0.2},
    },
    power = {
        MAGE    = {0.7, 0.25},
        WARLOCK = {0.6, 0.4},
    },
}

local unitGroups = {
    Arena = 5,
    Boss = 5
}
function RealUI:DemoUnitGroup(unitType, toggle)
    local baseName = "RealUI" .. unitType .. "Frame"
    for i = 1, unitGroups[unitType] do
        local frame = _G[baseName .. i]
        if toggle then
            if not frame.__realunit then
                frame.__realunit = frame:GetAttribute("unit") or frame.unit
                frame:SetAttribute("unit", "player")
                frame.unit = "player"
                frame:Show()
            end
        else
            if frame.__realunit then
                frame:SetAttribute("unit", frame.__realunit)
                frame.unit = frame.__realunit
                frame.__realunit = nil
                frame:Hide()
            end
        end
    end
end

----------------------------
------ Initialization ------
----------------------------
function UnitFrames:RefreshMod()
    db = self.db.profile
    ndb = RealUI.db.profile
    self.layoutSize = RealUI.cLayout or RealUI.db.char.layout.current or 1

    -- Reposition unit frames for the new layout
    self:RepositionFrames()

    self:RefreshUnits("RefreshMod")
end

function UnitFrames:OnProfileUpdate(event, profile)
    -- Profile changed, refresh unit frames for the new profile's settings
    self:RefreshMod()
end

function UnitFrames:RepositionFrames()
    -- Get the positioner frame and force it to update its layout
    local positioner = _G["RealUIPositionersUnitFrames"]
    if positioner then
        -- Force the positioner frame to update its size/position immediately
        positioner:SetScript("OnUpdate", nil)  -- Clear any pending updates
        positioner:GetCenter()  -- Force layout calculation
    end

    -- Reposition player frame
    local player = _G["RealUIPlayerFrame"]
    if player and db.positions[self.layoutSize] then
        player:ClearAllPoints()
        player:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT",
            db.positions[self.layoutSize].player.x,
            db.positions[self.layoutSize].player.y)
    end

    -- Reposition target frame
    local target = _G["RealUITargetFrame"]
    if target and db.positions[self.layoutSize] then
        target:ClearAllPoints()
        target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT",
            db.positions[self.layoutSize].target.x,
            db.positions[self.layoutSize].target.y)
    end

    -- Reposition pet frame (anchored to player)
    local pet = _G["RealUIPetFrame"]
    if pet and db.positions[self.layoutSize] then
        pet:ClearAllPoints()
        pet:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame",
            db.positions[self.layoutSize].pet.x,
            db.positions[self.layoutSize].pet.y)
    end

    -- Reposition focus frame (anchored to player)
    local focus = _G["RealUIFocusFrame"]
    if focus and db.positions[self.layoutSize] then
        focus:ClearAllPoints()
        focus:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame",
            db.positions[self.layoutSize].focus.x,
            db.positions[self.layoutSize].focus.y)
    end

    -- Reposition focustarget frame (anchored to focus)
    local focustarget = _G["RealUIFocusTargetFrame"]
    if focustarget and db.positions[self.layoutSize] then
        focustarget:ClearAllPoints()
        focustarget:SetPoint("TOPLEFT", "RealUIFocusFrame", "BOTTOMLEFT",
            db.positions[self.layoutSize].focustarget.x,
            db.positions[self.layoutSize].focustarget.y)
    end

    -- Reposition targettarget frame (anchored to target)
    local targettarget = _G["RealUITargetTargetFrame"]
    if targettarget and db.positions[self.layoutSize] then
        targettarget:ClearAllPoints()
        targettarget:SetPoint("BOTTOMRIGHT", "RealUITargetFrame",
            db.positions[self.layoutSize].targettarget.x,
            db.positions[self.layoutSize].targettarget.y)
    end

    -- Force all frames to update their layout immediately
    if player then player:GetCenter() end
    if target then target:GetCenter() end
    if pet then pet:GetCenter() end
    if focus then focus:GetCenter() end
    if focustarget then focustarget:GetCenter() end
    if targettarget then targettarget:GetCenter() end

    -- Reposition boss frames
    for i = 1, 5 do
        local boss = _G["RealUIBossFrame" .. i]
        if boss and db.positions[self.layoutSize] then
            boss:ClearAllPoints()
            if i == 1 then
                boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT",
                    db.positions[self.layoutSize].boss.x,
                    db.positions[self.layoutSize].boss.y)
            else
                boss:SetPoint("TOP", _G["RealUIBossFrame" .. (i - 1)], "BOTTOM", 0, -db.boss.gap)
            end
        end
    end

    -- Reposition arena frames
    for i = 1, 5 do
        local arena = _G["RealUIArenaFrame" .. i]
        if arena and db.positions[self.layoutSize] then
            arena:ClearAllPoints()
            if i == 1 then
                arena:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT",
                    db.positions[self.layoutSize].boss.x,
                    db.positions[self.layoutSize].boss.y)
            else
                arena:SetPoint("TOP", _G["RealUIArenaFrame" .. (i - 1)], "BOTTOM", 0, -db.boss.gap)
            end
        end
    end
end

function UnitFrames:OnInitialize()
    ---[[
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            misc = {
                focusclick = true,
                focuskey = "shift",
                statusText = "smart",
                alwaysDisplayFullHealth = true,
                combatfade = {
                    enabled = true,
                    opacity = {
                        incombat = 1,
                        harmtarget = 0.85,
                        target = 0.75,
                        hurt = 0.6,
                        outofcombat = 0.25,
                    },
                },
            },
            units = {
                -- Eventually, these settings will be used to adjust unit frame size.
                player = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHeight = 0.6, --percentage of the unit height used by the healthbar
                    reverseFill = false,
                    reverseMissing = false,
                    reversePercent = false,
                    framePoint = {},
                },
                target = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHeight = 0.6, --percentage of the unit height used by the healthbar
                    reverseFill = false,
                    framePoint = {},
                    debuffCount = 16,
                    buffCount = 16,
                },
                targettarget = {
                    size = {x = 138, y = 10},
                    position = {x = 0, y = 0},
                    framePoint = {},
                },
                focus = {
                    size = {x = 138, y = 10},
                    position = {x = 0, y = 0},
                    framePoint = {},
                },
                focustarget = {
                    size = {x = 126, y = 10},
                    position = {x = 0, y = 0},
                    framePoint = {},
                },
                pet = {
                    size = {x = 126, y = 10},
                    position = {x = 0, y = 0},
                    framePoint = {},
                },
                arena = {
                    size = {x = 135, y = 22},
                    position = {x = 0, y = 0},
                    framePoint = {},
                },
                boss = {
                    size = {x = 135, y = 22},
                    position = {x = 0, y = 0},
                    framePoint = {},
                },
                party = {
                    size = {x = 100, y = 50},
                    position = {x = 0, y = 0},
                },
            },
            arena = {
                enabled = true,
                announceUse = true,
                announceChat = "GROUP",
                showCast = true,
                showPets = true,
            },
            boss = {
                gap = 3,
                buffCount = 3,
                debuffCount = 5,
                showPlayerAuras = true,
                showNPCAuras = true,
            },
            -- TODO: Convert to FramePoint
            positions = {
                [1] = {
                    player =       { x = 0,   y = 0},   -- Anchored to Positioner
                    pet =          { x = 51,  y = -84}, -- Anchored to Player
                    focus =        { x = 29,  y = -62}, -- Anchored to Player
                    focustarget =  { x = 11,  y = -2},  -- Anchored to Focus
                    target =       { x = 0,   y = 0},   -- Anchored to Positioner
                    targettarget = { x = -29, y = -62}, -- Anchored to Target
                    boss =         { x = 0,   y = 0},   -- Anchored to Positioner
                },
                [2] = {
                    player =       { x = 0,   y = 0},   -- Anchored to Positioner
                    pet =          { x = 60,  y = -91}, -- Anchored to Player
                    focus =        { x = 36,  y = -67}, -- Anchored to Player
                    focustarget =  { x = 12,  y = -2},  -- Anchored to Focus
                    target =       { x = 0,   y = 0},   -- Anchored to Positioner
                    targettarget = { x = -36, y = -67}, -- Anchored to Target
                    boss =         { x = 0,   y = 0},   -- Anchored to Positioner
                },
            },
            overlay = {
                bar = {
                    opacity = {
                        absorb = 0.25,          -- Absorb Bar
                    },
                },
                classColor = false,
                classColorNames = true,
            },
        },
    })
    db = self.db.profile
    ndb = RealUI.db.profile

    self.layoutSize = RealUI.cLayout or RealUI.db.char.layout.current or 1
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    CombatFader:RegisterModForFade(MODNAME, "profile", "misc", "combatfade")
    FramePoint:RegisterMod(self)
end

function UnitFrames:ResetPositions()
    -- Clear saved FramePoint positions for all units, restoring defaults
    for unitKey, unitConf in _G.next, db.units do
        if unitConf.framePoint then
            _G.wipe(unitConf.framePoint)
        end
    end
    FramePoint:RestorePosition(self)
end

function UnitFrames:OnEnable()
    -- Override the green that oUF uses
    oUF.colors.health = oUF:CreateColor(0.66, 0.22, 0.22)
    oUF.colors.power.MANA = RealUI.ColorDesaturate(0.1, oUF.colors.power.MANA)
    oUF.colors.power.MANA = RealUI.ColorShift(-0.07, oUF.colors.power.MANA)
    self:InitializeLayout()
end
