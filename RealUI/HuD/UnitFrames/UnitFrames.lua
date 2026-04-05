local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db, ndb -- luacheck: ignore

local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")

local MODNAME = "UnitFrames"
local UnitFrames = RealUI:NewModule(MODNAME, "AceEvent-3.0")
local refreshRetryPending = false

UnitFrames.units = {}

-- Maps position anchor to {dialog-side anchor, offsetX, offsetY}
local auraPositionMap = {
    TOPLEFT = {"TOPLEFT", 0, 20},
    TOPRIGHT = {"TOPRIGHT", 0, 20},
    BOTTOMLEFT = {"BOTTOMLEFT", 0, -20},
    BOTTOMRIGHT = {"BOTTOMRIGHT", 0, -20},
    LEFT = {"LEFT", -10, 0},
    RIGHT = {"RIGHT", 10, 0},
    LEFTTOP = {"TOPLEFT", -10, 0},
    LEFTBOTTOM = {"BOTTOMLEFT", -10, 0},
    RIGHTTOP = {"TOPRIGHT", 10, 0},
    RIGHTBOTTOM = {"BOTTOMRIGHT", 10, 0},
}

function UnitFrames.GetInitialAnchor(growthX, growthY)
    return ((growthY == "DOWN") and "TOP" or "BOTTOM") .. ((growthX == "LEFT") and "RIGHT" or "LEFT")
end

function UnitFrames.SetAuraPosition(auraFrame, parent, posAnchor, initialAnchor)
    local pos = auraPositionMap[posAnchor] or auraPositionMap.TOPLEFT
    auraFrame:ClearAllPoints()
    auraFrame:SetPoint(initialAnchor, parent, pos[1], pos[2], pos[3])
end

local units = {
    "Player",
    "Target",
    "Focus",
    "FocusTarget",
    "Pet",
    "TargetTarget",
}

function UnitFrames:RefreshUnits(event) --luacheck: ignore 561
    -- Swap oUF.colors.health based on alternative bar style (only affects angled bars via UpdateColor override)
    oUF.colors.health = oUF:CreateColor(0.66, 0.22, 0.22)

    for i = 1, #units do
        local frame = _G["RealUI" .. units[i] .. "Frame"]
        if not frame then
            self:debug("Unit frame not found:", units[i])
        else
            local unitKey = frame.unit
            local unitData = UnitFrames[unitKey]

            -- Update class color settings
            if frame.Health then
                local unitDB = db.units[unitKey]
                local hb = unitDB and unitDB.healthBar
                local colorByClass = db.overlay.classColor or (hb and hb.colorForegroundByClass)
                frame.Health.colorClass = colorByClass
                frame.Health.colorReaction = colorByClass
                frame.Health.colorHealth = not colorByClass

                -- Update alternative bar style
                if frame.Health and frame.Health.bg then
                    if db.misc.alternativeBarStyle then
                        if not frame.HealthBG then
                            -- Create HealthBG on demand
                            local unitData2 = UnitFrames[unitKey]
                            if unitData2 and unitData2.health and unitData2.health.leftVertex then
                                local hb2 = unitDB and unitDB.healthBar
                                local bgColor = (hb2 and hb2.background) or {0.78, 0.15, 0.15}
                                local bgOpacity = (hb2 and hb2.backgroundOpacity) or 1.0
                                local HealthBG = frame:CreateAngle("StatusBar", nil, frame.overlay)
                                HealthBG:SetAngleVertex(unitData2.health.leftVertex, unitData2.health.rightVertex)
                                HealthBG:SetSize(frame.Health:GetWidth(), frame.Health:GetHeight())
                                HealthBG:SetPoint("TOP"..(unitData2.health.point or "RIGHT"), frame)
                                HealthBG:SetFrameLevel(frame.Health:GetFrameLevel())
                                HealthBG.bg:SetAlpha(0)
                                HealthBG.top:Hide()
                                HealthBG.bottom:Hide()
                                HealthBG.left:Hide()
                                HealthBG.right:Hide()
                                HealthBG.fill:SetDrawLayer("BORDER")
                                HealthBG:SetMinMaxValues(0, 1)
                                HealthBG:SetValue(1)
                                HealthBG:SetStatusBarColor(bgColor[1], bgColor[2], bgColor[3], bgOpacity)
                                frame.HealthBG = HealthBG
                            end
                        else
                            frame.HealthBG:Show()
                        end
                    elseif frame.HealthBG then
                        frame.HealthBG:Hide()
                    end
                end

                -- Update fill direction: natural direction based on side, reverseFill toggles it
                local natural = false
                if unitData and unitData.health and unitData.health.point then
                    natural = unitData.health.point == "RIGHT"
                end
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

            -- Update aura toggles/counts on target frame
            if unitKey == "target" then
                if frame.Debuffs then
                    if db.units.target.showTargetDebuffs then
                        frame.Debuffs.num = db.units.target.debuffCount
                        frame.Debuffs:Show()
                    else
                        frame.Debuffs.num = 0
                        frame.Debuffs:Hide()
                    end

                    -- Update debuff layout from config
                    local debuffLayout = db.units.target.auraLayout and db.units.target.auraLayout.debuffs
                    if debuffLayout then
                        if debuffLayout.growthX then frame.Debuffs.growthX = debuffLayout.growthX end
                        if debuffLayout.growthY then frame.Debuffs.growthY = debuffLayout.growthY end
                        frame.Debuffs.initialAnchor = UnitFrames.GetInitialAnchor(frame.Debuffs.growthX or "RIGHT", frame.Debuffs.growthY or "UP")
                        UnitFrames.SetAuraPosition(frame.Debuffs, frame, debuffLayout.anchor or "TOPLEFT", frame.Debuffs.initialAnchor)
                        -- Update frame size based on maxWidth
                        if debuffLayout.maxWidth then
                            local debuffSize = frame.Debuffs.size or 24
                            local debuffSpacing = frame.Debuffs.spacing or 2
                            local debuffFrameWidth = (debuffLayout.maxWidth > 0 and debuffLayout.maxWidth) or frame:GetWidth()
                            local debuffCols = _G.math.floor((debuffFrameWidth + debuffSpacing) / (debuffSize + debuffSpacing))
                            local debuffRows = _G.math.ceil(frame.Debuffs.num / _G.math.max(debuffCols, 1))
                            frame.Debuffs:SetWidth(debuffFrameWidth)
                            frame.Debuffs:SetHeight(debuffRows * (debuffSize + debuffSpacing))
                        end
                        frame.Debuffs:ForceUpdate()
                    end
                end
                if frame.Buffs then
                    if db.units.target.showTargetBuffs then
                        frame.Buffs.num = db.units.target.buffCount
                        frame.Buffs:Show()
                    else
                        frame.Buffs.num = 0
                        frame.Buffs:Hide()
                    end

                    -- Update buff layout from config
                    local buffLayout = db.units.target.auraLayout and db.units.target.auraLayout.buffs
                    if buffLayout then
                        if buffLayout.growthX then frame.Buffs.growthX = buffLayout.growthX end
                        if buffLayout.growthY then frame.Buffs.growthY = buffLayout.growthY end
                        frame.Buffs.initialAnchor = UnitFrames.GetInitialAnchor(frame.Buffs.growthX or "LEFT", frame.Buffs.growthY or "UP")
                        UnitFrames.SetAuraPosition(frame.Buffs, frame, buffLayout.anchor or "TOPRIGHT", frame.Buffs.initialAnchor)
                        if buffLayout.maxWidth then
                            local buffSize = frame.Buffs.size or 20
                            local buffSpacing = frame.Buffs.spacing or 2
                            local buffFrameWidth = (buffLayout.maxWidth > 0 and buffLayout.maxWidth) or frame:GetWidth()
                            local buffCols = _G.math.floor((buffFrameWidth + buffSpacing) / (buffSize + buffSpacing))
                            local buffRows = _G.math.ceil(frame.Buffs.num / _G.math.max(buffCols, 1))
                            frame.Buffs:SetWidth(buffFrameWidth)
                            frame.Buffs:SetHeight(buffRows * (buffSize + buffSpacing))
                        end
                        frame.Buffs:ForceUpdate()
                    end
                end
            end

            -- Update aura toggles/counts on player frame
            if unitKey == "player" then
                if frame.Buffs then
                    if db.units.player.showPlayerBuffs then
                        frame.Buffs.num = db.units.player.buffCount
                        frame.Buffs:Show()
                    else
                        frame.Buffs.num = 0
                        frame.Buffs:Hide()
                    end

                    local buffLayout = db.units.player.auraLayout and db.units.player.auraLayout.buffs
                    if buffLayout then
                        if buffLayout.growthX then frame.Buffs.growthX = buffLayout.growthX end
                        if buffLayout.growthY then frame.Buffs.growthY = buffLayout.growthY end
                        frame.Buffs.initialAnchor = UnitFrames.GetInitialAnchor(frame.Buffs.growthX or "RIGHT", frame.Buffs.growthY or "UP")
                        UnitFrames.SetAuraPosition(frame.Buffs, frame, buffLayout.anchor or "TOPLEFT", frame.Buffs.initialAnchor)
                        if buffLayout.maxWidth then
                            local buffSize = frame.Buffs.size or 20
                            local buffSpacing = frame.Buffs.spacing or 2
                            local buffFrameWidth = (buffLayout.maxWidth > 0 and buffLayout.maxWidth) or frame:GetWidth()
                            local buffCols = _G.math.floor((buffFrameWidth + buffSpacing) / (buffSize + buffSpacing))
                            local buffRows = _G.math.ceil(frame.Buffs.num / _G.math.max(buffCols, 1))
                            frame.Buffs:SetWidth(buffFrameWidth)
                            frame.Buffs:SetHeight(buffRows * (buffSize + buffSpacing))
                        end
                        frame.Buffs:ForceUpdate()
                    end
                end
            end

            -- Toggle Private Auras
            if frame._privateAurasFrame then
                if db.misc.showPrivateAuras then
                    if not frame.PrivateAuras then
                        frame.PrivateAuras = frame._privateAurasFrame
                        frame:EnableElement("PrivateAuras", frame.unit)
                    end
                else
                    if frame.PrivateAuras then
                        frame:DisableElement("PrivateAuras")
                        frame.PrivateAuras = nil
                    end
                end
            end

            -- Toggle Health Prediction sub-widgets
            if frame.Health then
                local predictionWidgets = {"HealingAll", "DamageAbsorb", "HealAbsorb"}
                for _, wn in ipairs(predictionWidgets) do
                    local widget = frame.Health[wn]
                    if widget then
                        if db.misc.showPrediction then
                            widget:Show()
                        else
                            widget:Hide()
                        end
                    end
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
                local hb = db.units.boss and db.units.boss.healthBar
                local colorByClass = db.overlay.classColor or (hb and hb.colorForegroundByClass)
                frame.Health.colorClass = colorByClass
                frame.Health.colorReaction = colorByClass
                frame.Health.colorHealth = not colorByClass

                -- Update alternative bar style on boss frames
                if frame.HealthBG then
                    if db.misc.alternativeBarStyle then
                        frame.HealthBG:Show()
                    else
                        frame.HealthBG:Hide()
                    end
                end

                if frame.Health.text then
                    frame:Untag(frame.Health.text)
                    frame:Tag(frame.Health.text, UnitFrames.GetHealthTagString(db.misc.statusText))
                end
            end

            if frame.Debuffs then
                if db.boss.showBossDebuffs then
                    frame.Debuffs.num = db.boss.debuffCount
                    frame.Debuffs:Show()
                else
                    frame.Debuffs.num = 0
                    frame.Debuffs:Hide()
                end
            end
            if frame.Buffs then
                if db.boss.showBossBuffs then
                    frame.Buffs.num = db.boss.buffCount
                    frame.Buffs:Show()
                else
                    frame.Buffs.num = 0
                    frame.Buffs:Hide()
                end
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
                frame.Health.colorReaction = db.overlay.classColor
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
    Boss = 5,
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

    -- During early login, profile updates can fire before oUF frames are spawned.
    -- Delay one tick so frame reposition/refresh does not run against nil frames.
    if not _G.RealUIPlayerFrame then
        if not refreshRetryPending then
            refreshRetryPending = true
            self:ScheduleTimer(function()
                refreshRetryPending = false
                if self:IsEnabled() then
                    self:RefreshMod()
                end
            end, 0.5)
        end
        return
    end

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
                showPrediction = true,
                showPrivateAuras = true,
                alternativeBarStyle = false,
                textColors = {
                    health = nil,
                    power = nil,
                    name = nil,
                },
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
                    buffCount = 16,
                    showPlayerBuffs = true,
                    auraLayout = {
                        buffs = {
                            anchor = "TOPLEFT",
                            growthX = "RIGHT",
                            growthY = "UP",
                            maxWidth = 0,
                        },
                    },
                    healthBar = {
                        foreground = {0.08, 0.08, 0.08},
                        foregroundOpacity = 0.8,
                        background = {0.78, 0.15, 0.15},
                        backgroundOpacity = 1.0,
                        colorForegroundByClass = false,
                        colorBackgroundByClass = false,
                    },
                },
                target = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHeight = 0.6, --percentage of the unit height used by the healthbar
                    reverseFill = false,
                    framePoint = {},
                    debuffCount = 16,
                    buffCount = 16,
                    showTargetDebuffs = true,
                    showTargetBuffs = true,
                    auraLayout = {
                        debuffs = {
                            anchor = "TOPLEFT",
                            growthX = "RIGHT",
                            growthY = "UP",
                            maxWidth = 0,
                        },
                        buffs = {
                            anchor = "TOPRIGHT",
                            growthX = "LEFT",
                            growthY = "UP",
                            maxWidth = 0,
                        },
                    },
                    healthBar = {
                        foreground = {0.08, 0.08, 0.08},
                        foregroundOpacity = 0.8,
                        background = {0.78, 0.15, 0.15},
                        backgroundOpacity = 1.0,
                        colorForegroundByClass = false,
                        colorBackgroundByClass = false,
                    },
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
                    healthBar = {
                        foreground = {0.08, 0.08, 0.08},
                        foregroundOpacity = 0.8,
                        background = {0.78, 0.15, 0.15},
                        backgroundOpacity = 1.0,
                        colorForegroundByClass = false,
                        colorBackgroundByClass = false,
                    },
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
                debuffCount = 16,
                buffCount = 16,
                showBossDebuffs = true,
                showBossBuffs = true,
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
    -- Mute the new oUF 13.4.0 class-power colors to match RealUI's subdued palette
    oUF.colors.power.ICICLES = RealUI.ColorDesaturate(0.15, oUF.colors.power.ICICLES)
    oUF.colors.power.TIP_OF_THE_SPEAR = RealUI.ColorDesaturate(0.15, oUF.colors.power.TIP_OF_THE_SPEAR)
    self:InitializeLayout()
end
