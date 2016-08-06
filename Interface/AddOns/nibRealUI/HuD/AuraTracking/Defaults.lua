local _, private = ...

-- Lua Globals --
local _G = _G
--local next = _G.next
local Lerp = _G.Lerp

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local MODNAME = "AuraTracking"
local AuraTracking = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")

local function debug(isDebug, ...)
    if isDebug then
        -- self.debug should be a string describing what the bar is.
        -- eg. "playerHealth", "targetAbsorbs", etc
        AuraTracking:debug(isDebug, ...)
    end
end
AuraTracking.trackerDebug = debug

local class, classID = RealUI.class, RealUI.classID
local maxComboPoints

local SavageRoar
local MirrorImage, IncantersFlow
local PowerStrikes--, GiftoftheOx
local Envenom, Rupture, SliceAndDice, Nightblade, EnvelopingShadows--, RollTheBones
local function PredictDuration(gap, base)
    local potential, color, max = "", {}
    local function postUnitAura(self, spellData, aura, hasAura)
        debug(spellData.debug, "postUnitAura", potential, color[1], hasAura)
        self.count:SetText(potential)
        self.count:SetTextColor(color[1], color[2], color[3])
        if hasAura then
            self.auraIndex = aura.index
            self.cd:Show()
            self.cd:SetCooldown(aura.endTime - aura.duration, aura.duration)
            self.icon:SetTexture(aura.texture)
            AuraTracking:AddTracker(self)
        elseif hasAura ~= nil then
            self.auraIndex = nil
            self.cd:SetCooldown(0, 0)
            self.cd:Hide()
            if self.isTransient then
                if self.slot then
                    AuraTracking:RemoveTracker(self)
                end
            else
                AuraTracking:RemoveTracker(self, self.isStatic)
            end
        end
    end

    -- Shows predicted debuff duration based on current CPs.
    return function(self, spellData, unit, powerType, updateMax)
        debug(spellData.debug, "UNIT_POWER_FREQUENT", unit, powerType, updateMax)
        if unit == "player" and powerType == "COMBO_POINTS" then
            debug(spellData.debug, "Main", unit, powerType)
            local comboPoints = _G.UnitPower("player", _G.SPELL_POWER_COMBO_POINTS)
            if comboPoints > maxComboPoints then
                -- If the player has Anticipation they can still only use 5 CPs at a time.
                comboPoints = maxComboPoints
            end

            potential, color[1], color[2], color[3] = "", 1, 1, 1
            if (comboPoints > 0) then
                potential = base + ((comboPoints - 1) * gap)
                if potential == max then
                    color[1], color[2], color[3] = 0, 1, 0
                end
            end
            postUnitAura(self, spellData)

            if not self.postUnitAura then
                self.postUnitAura = postUnitAura
            end
        elseif updateMax then
            debug(spellData.debug, "UpdateMax", base, maxComboPoints)
            max = base + ((maxComboPoints - 1) * gap)
        end
    end
end

if class == "DRUID" then
    maxComboPoints = 5
    SavageRoar = PredictDuration(4, 8)
    SavageRoar(nil, {debug="cpWatcher"}, nil, nil, true)
elseif class == "MAGE" then
    do -- MirrorImage
        local hasAura = false
        local start, duration = 0, 40

        local function postUnitAura(self, spellData)
            debug(spellData.debug, "postUnitAura", hasAura)
            self.cd:SetCooldown(start, duration)

            if hasAura and not self.slot then
                AuraTracking:AddTracker(self)
            elseif not hasAura and self.slot then
                AuraTracking:RemoveTracker(self)
            end
        end

        -- Shows Mirror Image progress.
        function MirrorImage(self, spellData, _, subEvent, _, srcGUID, _,_,_,_,_,_,_, spellID)
            if srcGUID == AuraTracking.playerGUID and spellID == spellData.spell then
                debug(spellData.debug, "COMBAT_LOG_EVENT_UNFILTERED", subEvent, _G.GetTime())

                if subEvent == "SPELL_AURA_APPLIED" and not hasAura then
                    AuraTracking:debug("MirrorImage", hasAura)
                    hasAura = true
                    start = _G.GetTime()
                elseif subEvent == "SPELL_AURA_REMOVED" and hasAura then
                    hasAura = false
                end
                postUnitAura(self, spellData)

                if not self.postUnitAura then
                    self.postUnitAura = postUnitAura
                end
            end
        end
    end
    do -- IncantersFlow
        local flowMax = 5
        local function postUnitAura(self, spellData, aura, hasAura)
            debug(spellData.debug, "postUnitAura", aura.count)
            if hasAura then
                self.auraIndex = aura.index
                self.cd:Show()
                self.cd:SetCooldown(aura.endTime - aura.duration, aura.duration)
                self.icon:SetTexture(spellData.customIcon or aura.texture)

                local flow = aura.count
                self.count:SetText(flow * 4)

                local xOfs = Lerp(0, self.icon:GetWidth(), (flow / flowMax))
                self.status:SetPoint("TOPLEFT", self, xOfs, 0)

                AuraTracking:AddTracker(self)
            elseif self.slot then
                self.auraIndex = nil
                self.cd:SetCooldown(0, 0)
                self.cd:Hide()
                self.count:SetText("")
                AuraTracking:RemoveTracker(self, self.isStatic)
            end
        end

        -- Shows Incanter's Flow progress.
        function IncantersFlow(self)
            self.postUnitAura = postUnitAura

            local status = self:CreateTexture(nil, "BORDER", nil, 0)
            status:SetColorTexture(0, 0, 0, 0.9)
            status:SetPoint("TOPLEFT")
            status:SetPoint("BOTTOMRIGHT")
            status:SetDesaturated(true)
            self.status = status
        end
    end
elseif class == "MONK" then
    do -- PowerStrikes
        local hadAura = false
        local start, duration = 0, 15
        local numNotUsed, threshold = 0, 2

        local function updateTime(self, spellData)
            debug(spellData.debug, "updateTime", hadAura, numNotUsed)
            start = _G.GetTime()
            self.cd:SetCooldown(start, duration)
            if hadAura then
                -- didn't use before refresh
                numNotUsed = numNotUsed + 1
            end
        end

        local function postUnitAura(self, spellData, aura, hasAura)
            debug(spellData.debug, "postUnitAura", self.id, hadAura, hasAura)

            if not hadAura and hasAura then
                local timer = self.timer
                if AuraTracking:TimeLeft(timer) > 0.5 then
                    debug(spellData.debug, "reset timer", AuraTracking:TimeLeft(timer))
                    AuraTracking:CancelTimer(timer)
                    updateTime(self, spellData)
                    self.timer = AuraTracking:ScheduleRepeatingTimer(updateTime, duration, self, spellData)
                end
            elseif hadAura and not hasAura then
                -- Just used, reset count
                numNotUsed = 0
            end

            debug(spellData.debug, "numNotUsed", numNotUsed)
            if numNotUsed <= threshold then
                self.auraIndex = aura.index
                AuraTracking:AddTracker(self)
            elseif numNotUsed > threshold and self.slot then
                -- Hide the tracker if the buff isn't used twice in a row
                AuraTracking:RemoveTracker(self, self.isStatic)
            end

            hadAura = hasAura
            self.icon:SetDesaturated(not hasAura)
        end

        -- Shows the current Power Strikes ICD.
        function PowerStrikes(tracker, spellData)
            tracker.timer = AuraTracking:ScheduleRepeatingTimer(updateTime, duration, tracker, spellData)

            tracker.postUnitAura = postUnitAura
        end
    end
    --[[do -- GiftoftheOx
        local timeNotUsed, threshold = 0, 60
        local spawnCounter, orbCounter = 0, 0
        local orbSummonID, orbSummonID2 = 124503, 124506
        local orbBurstID, orbBurstID2 = 178173, 124507
        local staggerDOT = 124255

        local function updateTime(self, spellData, reset)
            --debug(spellData.debug, "updateTime", spawnCounter, timeNotUsed)
            timeNotUsed = timeNotUsed + 1
        end

        local function postUnitAura(self, spellData)
            debug(spellData.debug, "postUnitAura", spawnCounter, orbCounter)

            if not self.postUnitAura then
                self.postUnitAura = postUnitAura
                self.timer = AuraTracking:ScheduleRepeatingTimer(updateTime, 1, self, spellData)

                local status = self:CreateTexture(nil, "BACKGROUND", nil, 0)
                status:SetTexture(spellData.customIcon)
                status:SetTexCoord(.08, .92, .08, .92)
                status:SetPoint("TOPLEFT")
                status:SetPoint("BOTTOMRIGHT")
                self.status = status
            end

            if spawnCounter > 0 or orbCounter > 0 then
                if spawnCounter > 0 then
                    local spawnMod = spawnCounter % 1
                    local right = Lerp(.08, .92, spawnMod) 
                    debug(spellData.debug, "right", right) 
                    self.status:SetTexCoord(.08, right, .08, .92) 

                    local xOfs = Lerp(-(self.icon:GetWidth()), 0, spawnMod) 
                    debug(spellData.debug, "xOfs", xOfs) 
                    self.status:SetPoint("BOTTOMRIGHT", self, xOfs, 0)
                    if spawnCounter > 1 then
                        spawnCounter = spawnCounter - 1
                    end
                end
                
                if orbCounter > 0 then
                    self.count:SetText(_G.tostring(orbCounter))
                    AuraTracking:AddTracker(self)
                    self.icon:SetDesaturated(true)
                else
                    self.count:SetText("")
                end
            elseif timeNotUsed > threshold and self.slot then
                AuraTracking:RemoveTracker(self, self.isStatic)
            end
        end

        -- Shows progress until the next GotO orb.
        function GiftoftheOx(self, spellData, _, subEvent, _, srcGUID, _,_,_, destGUID, _,_,_, ...)
            local srcIsPlayer, destIsPlayer = srcGUID == AuraTracking.playerGUID, destGUID == AuraTracking.playerGUID
            debug(spellData.debug, subEvent, srcIsPlayer, destIsPlayer)

            if subEvent == "SPELL_CAST_SUCCESS" and srcIsPlayer then
                local spellID, spellName = ...
                debug(spellData.debug, "spellCast", spellID, spellName)
                if spellID == orbSummonID or spellID == orbSummonID2 then
                    orbCounter = orbCounter + 1
                    postUnitAura(self, spellData)
                end
            elseif subEvent == "SPELL_HEAL" and (srcIsPlayer and destIsPlayer) then
                local spellID, spellName = ...
                debug(spellData.debug, "spellHeal", spellID, spellName)
                if spellID == orbBurstID or spellID == orbBurstID2 then
                    orbCounter = orbCounter - 1
                    postUnitAura(self, spellData)
                end
            elseif subEvent:find("_DAMAGE") and destIsPlayer and not srcIsPlayer then
                -- BaseOrbChance = (DamageTakenBeforeAbsorbsOrStagger / MaxHealth)
                -- TalentedOrbChance = BaseOrbChance * (1 + 0.6 * (1 - (HealthBeforeDamage - DamageTakenBeforeAbsorbsOrStagger) / MaxHealth))
                local prefix, mod = _G.strsplit("_", subEvent)
                debug(spellData.debug, "prefix", prefix, mod)
                local spellID, spellName, _, damage, absorbed
                if prefix == "SWING" then
                    damage, _,_,_,_, absorbed = ...
                elseif prefix == "SPELL" or prefix == "RANGE" then
                    spellID, spellName, _, damage, _,_,_,_, absorbed = ...
                    debug(spellData.debug, "spellDamage", spellID, spellName)
                    if spellID == staggerDOT then
                        return
                    end
                else
                    return
                end
                debug(spellData.debug, "damage", damage, absorbed)
                local damagePreStagger = damage + absorbed
                spawnCounter = spawnCounter + (damagePreStagger / _G.UnitHealthMax("player"))
                timeNotUsed = 0
                postUnitAura(self, spellData)
            end
        end
    end]]
elseif class == "ROGUE" then
    Envenom = PredictDuration(1, 2)
    Rupture = PredictDuration(4, 8)
    SliceAndDice = PredictDuration(6, 12)
    Nightblade = PredictDuration(2, 8)
    EnvelopingShadows = PredictDuration(6, 6)
    --[[do RollTheBones
        local buffFunction = PredictDuration(6, 12)

        local function postUnitAura(self, spellData, aura, hasAura)
            debug(spellData.debug, "postUnitAura", aura.name, hasAura)
            if hasAura then
                if self.slot then
                    AuraTracking:RemoveTracker(self)
                end
            else
                AuraTracking:AddTracker(self)
                AuraTracking:RemoveTracker(self, self.isStatic)
            end
        end

        -- Setup trackers for each buff gained from Roll the Bones
        function RollTheBones(self, spellData, updateMax)
            if updateMax then
                buffFunction(nil, spellData, nil, nil, true)
            elseif not self.postUnitAura then
                debug("RollTheBones", "Init", _G.getmetatable(spellData))
                for index, spellID in next, spellData.spell do
                    local customSpellData = RealUI:DeepCopy(spellData)
                    customSpellData.debug = spellData.debug..spellID
                    customSpellData.order = index
                    customSpellData.spell = spellID
                    customSpellData.eventUpdate.event = "UNIT_POWER_FREQUENT"
                    customSpellData.eventUpdate.func = buffFunction
                    local newTracker = AuraTracking:CreateNewTracker(customSpellData)
                    newTracker.isTransient = true
                    newTracker:Enable()
                    AuraTracking:RemoveTracker(newTracker)
                end
                self:RegisterUnitEvent("UNIT_POWER_FREQUENT", spellData.unit)
                self["UNIT_POWER_FREQUENT"] = buffFunction
                self.postUnitAura = postUnitAura
            end
        end
    end]]
    do -- Deeper Stratagem
        -- This updates the max potential duration depending on if the player 
        -- has Deerper Stratagem, which allows finishers to use up to 6 CPs
        local cpWatcher = _G.CreateFrame("Frame", nil, _G.UIParent)
        cpWatcher.debug = "cpWatcher"
        cpWatcher:RegisterEvent("PLAYER_TALENT_UPDATE")
        cpWatcher:SetScript("OnEvent", function(self, event, ...)
            debug(self.debug, event, ...)
            local oldMax = maxComboPoints
            local _, selectedTalent = _G.GetTalentTierInfo(3, 1)
            debug(self.debug, "selectedTalent", selectedTalent)
            if selectedTalent == 1 then
                maxComboPoints = 6
            else
                maxComboPoints = 5
            end
            debug(self.debug, "UpdateComboPoints", oldMax, maxComboPoints)
            if oldMax ~= maxComboPoints then
                Envenom(nil, self, nil, nil, true)
                Rupture(nil, self, nil, nil, true)
                SliceAndDice(nil, self, nil, nil, true)
                Nightblade(nil, self, nil, nil, true)
                EnvelopingShadows(nil, self, nil, nil, true)
                --RollTheBones(nil, self, true)
            end
        end)
    end
end

local classDefaults
function AuraTracking:SetupDefaultTracker()
    self:debug("Setup default tracker")
    local specs = {}
    for i = 1, _G.GetNumSpecializationsForClassID(classID) do
        AuraTracking:debug("Specs", i)
        specs[i] = true
    end
    local classTrackers = classDefaults[class]
    classTrackers["**"] = {
        spell = L["AuraTrack_SpellNameID"],
        minLevel = 1,
        auraType = "buff", -- buff|debuff
        unit = "player", -- player|target|pet
        specs = specs, -- Default to true for all specs
        talent = {},
        order = 0, -- Tracker will be static if greater than 0
        hideStacks = false, -- hide stack count (useful for auras with a passive 1 stack)
        noExclude = false, -- Don't add this aura to Raven's exclution lists
        shouldLoad = true,
        debug = false
        --[[ Possible Spec specific settings
        specs = {
            ["**"] = defaultSpec,
            [1] = {   
                talent = {},
                order = 0,
            },
            [3] = false
        }
        ]]
        --[=[
        customIcon = [[Interface\Icons\Spell_Fire_Fireball02]],
        customName = _G.GetSpellInfo(12345),
        eventUpdate = {
            event = "UNIT_POWER_FREQUENT",
            func = SpecialFunc
        }
        ]=]
    }
    classDefaults = nil
    return classTrackers
end

--[[ Retired IDs
9ab78043
857dac62
99868b0a
bd56d2d6
965917ad
a5bdd6b2
b6cce35c

]]

classDefaults = {
    ["DEATHKNIGHT"] = {
        -- Static Player Auras
            ["6-987a58fe-1"] = {   -- Blood Shield (Blood)
                spell = 77535,
                minLevel = 80,
                specs = {true, false, false},
                order = 1,
            },
            ["6-9eeb4ba5-1"] = {   -- Bone Shield (Blood)
                spell = 195181,
                minLevel = 55,
                specs = {true, false, false},
                order = 2,
            },
            ["6-ab29032c-1"] = {   -- Dark Transformation (Unholy)
                spell = 63560,
                minLevel = 74,
                unit = "pet",
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
            ["6-a4a87f4c-1"] = {   -- Blood Plague
                spell = 55078,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 1,
            },
            ["6-ac6e45ce-1"] = {   -- Frost Fever
                spell = 55095,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 1,
            },
            ["6-8621f38d-1"] = {   -- Festering Wound
                spell = 194310,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
            ["6-a6a32ca3-1"] = {   -- Virulent Plague
                spell = 191587,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 2,
            },
        -- Free Player Auras
            ["6-986c8a80-1"] = {   -- Dancing Rune Weapon (Blood)
                spell = 81256,
                minLevel = 57,
                specs = {true, false, false},
            },
            ["6-80713fed-1"] = {   -- Vampiric Blood (Blood)
                spell = 55233,
                minLevel = 57,
                specs = {true, false, false},
            },
            ["6-8f813ae5-1"] = {   -- Crimson Scourge (Blood)
                spell = 81141,
                minLevel = 63,
                specs = {true, false, false},
            },
            ["6-9dae73fe-1"] = {   -- Rime (Frost)
                spell = 59052,
                minLevel = 58,
                specs = {false, true, false},
            },
            ["6-a27ed53e-1"] = {   -- Killing Machine (Frost)
                spell = 51124,
                minLevel = 63,
                specs = {false, true, false},
            },
            ["6-9af9ad7e-1"] = {   -- Pillar of Frost (Frost)
                spell = 51271,
                minLevel = 68,
                specs = {false, true, false},
            },
            ["6-9334862e-1"] = {   -- Icebound Fortitude (Frost, Unholy)
                spell = 48792,
                minLevel = 65,
                specs = {false, true, true},
            },
            ["6-8ea694c4-1"] = {   -- Sudden Doom (Unholy)
                spell = 81340,
                minLevel = 64,
                specs = {false, false, true},
            },
            ["6-a543932b-1"] = {spell = 48707},    -- Anti-Magic Shell
        -- Free Target Auras
    },

    ["DEMONHUNTER"] = {
        -- Static Player Auras
            ["12-86dc5f08-1"] = {   -- Demon Spikes (Veng)
                spell = 203819,
                minLevel = 98,
                specs = {false, true},
                order = 1,
            },
        -- Static Target Auras
        -- Free Player Auras
            ["12-bf917422-1"] = {   -- Blur (Havok)
                spell = 212800,
                minLevel = 98,
                specs = {true, false},
                talent = {
                    tier = 4,
                    column = 1,
                    mustHave = false,
                },
            },
            ["12-96a15d91-1"] = {   -- Netherwalk (Havok) (Talent)
                spell = 196555,
                minLevel = 104,
                specs = {true, false},
                talent = {
                    tier = 4,
                    column = 1,
                    mustHave = true,
                },
            },
            ["12-8f8a7deb-1"] = {   -- Momentum (Havok) (Talent)
                spell = 208628,
                minLevel = 106,
                specs = {true, false},
                talent = {
                    tier = 5,
                    column = 1,
                    mustHave = true,
                },
            },
            ["12-bf27cce4-1"] = {   -- Chaos Blades (Havok) (Talent)
                spell = 211048,
                minLevel = 110,
                specs = {true, false},
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = true,
                },
            },
            ["12-9d8e1b35-1"] = {   -- Immolation Aura (Veng)
                spell = 178740,
                minLevel = 98,
                specs = {false, true},
            },
            ["12-a34a80e5-1"] = {   -- Empower Wards (Veng)
                spell = 218256,
                minLevel = 98,
                specs = {false, true},
            },
            ["12-95b80fdf-1"] = {   -- Metamorphosis
                spell = {162264, 187827}, -- Havok, Veng
                minLevel = 98,
            },
            ["12-81347abb-1"] = {   -- Spectral Sight
                spell = 188501,
                minLevel = 98,
            },
            ["12-8281137d-1"] = {   -- Nether Bond (Veng) (Talent)
                spell = 207810,
                minLevel = 110,
                specs = {false, true},
                talent = {
                    tier = 7,
                    column = 2,
                    mustHave = true,
                },
            },
            ["12-8c2b1f08-1"] = {   -- Soul Barrier (Veng) (Talent)
                spell = 227225,
                minLevel = 110,
                specs = {false, true},
                talent = {
                    tier = 7,
                    column = 3,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["12-89e46112-1"] = {   -- Bloodlet (Havok) (Talent)
                spell = 207690,
                minLevel = 102,
                auraType = "debuff",
                unit = "target",
                specs = {true, false},
                talent = {
                    tier = 3,
                    column = 3,
                    mustHave = true,
                },
            },
            ["12-aaddc099-1"] = {   -- Nemesis (Havok) (Talent)
                spell = 206491,
                minLevel = 106,
                auraType = "debuff",
                unit = "target",
                specs = {true, false},
                talent = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
            },
            ["12-aeb77dff-1"] = {   -- Fiery Brand (Veng)
                spell = 207744,
                minLevel = 98,
                auraType = "debuff",
                unit = "target",
                specs = {false, true},
            },
            ["12-83a223f0-1"] = {   -- Sigil of Flame (Veng)
                spell = 204598,
                minLevel = 98,
                auraType = "debuff",
                unit = "target",
                specs = {false, true},
            },
            ["12-ac02f3e2-1"] = {   -- Spirit Bomb (Veng) (Talent)
                spell = 224509, -- Frailty
                minLevel = 108,
                auraType = "debuff",
                unit = "target",
                specs = {false, true},
                talent = {
                    tier = 6,
                    column = 3,
                    mustHave = true,
                },
            },
    },

    ["DRUID"] = {
        -- Static Player Auras
            ["11-b0d10e92-1"] = {   -- Savage Roar (Feral)
                spell = 52610,
                minLevel = 75,
                specs = {false, true, false, false},
                order = 1,
                talent = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = SavageRoar
                }
            },
            ["11-a774b290-1"] = {   -- Ironfur (Guardian)
                spell = 192081,
                minLevel = 44,
                specs = {false, false, true, false},
                order = 1,
            },
            ["11-b409da56-1"] = {   -- Abundance (Resto)
                spell = 207640,
                minLevel = 15,
                specs = {false, false, false, true},
                order = 1,
                talent = {
                    tier = 1,
                    column = 3,
                    mustHave = true,
                },
            },
        -- Static Target Auras
            ["11-b1a3a3b5-1"] = {   -- Moonfire (Balance)
                spell = 164812,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false, false},
                order = 1,
            },
            ["11-bbefa72d-1"] = {   -- Sunfire (Balance)
                spell = 164815,
                minLevel = 18,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false, false},
                order = 2,
            },
            ["11-b5e260cc-1"] = {   -- Stellar Flare (Talent) (Balance)
                spell = 202347,
                minLevel = 75,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false, false},
                talent = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
                order = 3,
            },
            ["11-931a3a8f-1"] = {   -- Rake (Feral)
                spell = 155722,
                minLevel = 6,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false},
                order = 1,
            },
            ["11-98b179f7-1"] = {   -- Rip (Feral)
                spell = 1079,
                minLevel = 20,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false},
                order = 2,
            },
            ["11-ac72ea83-1"] = {   -- Lunar Inspiration (Talent) (Feral)
                spell = 155625, -- Moonfire (Cat)
                minLevel = 15,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false},
                talent = {
                    tier = 1,
                    column = 3,
                    mustHave = true,
                },
                order = 3,
                customName = _G.GetSpellInfo(155580),
            },
            ["11-9d6059d3-1"] = {   -- Thrash (Guardian)
                spell = 192090,
                minLevel = 14,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true, false},
                order = 1,
            },
        -- Free Player Auras
            ["11-a14ea115-1"] = {   -- Celestial Alignment (Balance)
                spell = 194223,
                minLevel = 64,
                specs = {true, false, false, false},
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = false,
                },
            },
            ["11-bb1a6cfe-1"] = {   -- Tiger's Fury (Feral)
                spell = 5217,
                minLevel = 12,
                specs = {false, true, false, false}
            },
            ["11-b0d536fe-1"] = {   -- Predatory Swiftness (Feral)
                spell = 69369,
                minLevel = 28,
                specs = {false, true, false, false}
            },
            ["11-b2007cb7-1"] = {   -- Berserk (Feral)
                spell = 106951,
                minLevel = 48,
                specs = {false, true, true, false}
            },
            ["11-942ab297-1"] = {   -- Survival Instincts (Feral, Guardian)
                spell = 61336,
                minLevel = 40,
                specs = {false, true, true, false}
            },
            ["11-b3c84eed-1"] = {   -- Barkskin (Guardian)
                spell = 22812,
                minLevel = 36,
                specs = {false, false, true, false}
            },
            ["11-9ee9dd75-1"] = {   -- Omen of Clarity (Feral, Resto)
                spell = {135700, 16870},   -- Clearcasting (Feral, Resto)
                minLevel = 38,
                specs = {false, true, false, true},
                customName = _G.GetSpellInfo(113043),
            },
            ["11-a9a4c453-1"] = {   -- Incarnation: Chosen of Elune (Talent) (Balance)
                spell = 102560,
                minLevel = 75,
                specs = {true, false, false, false},
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
            },
            ["11-87d1164a-1"] = {   -- Incarnation: King of the Jungle (Talent) (Feral)
                spell = 102543,
                minLevel = 75,
                specs = {false, true, false, false},
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
            },
            ["11-827cfea6-1"] = {   -- Bloodtalons (Talent) (Feral)
                spell = 145152,
                minLevel = 100,
                specs = {false, true, false, false},
                talent = {
                    tier = 7,
                    column = 2,
                    mustHave = true,
                },
            },
            ["11-aa9fcbad-1"] = {   -- Incarnation: Son of Ursoc (Talent) (Guardian)
                spell = 102558,
                minLevel = 75,
                specs = {false, false, true, false},
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
            },
            ["11-bb237125-1"] = {   -- Pulverize (Talent) (Guardian)
                spell = 158792,
                minLevel = 100,
                specs = {false, false, true, false},
                talent = {
                    tier = 7,
                    column = 3,
                    mustHave = true,
                },
            },
            ["11-bb4c75ca-1"] = {   -- Soul of the Forest (Talent) (Resto)
                spell = 114108,
                minLevel = 75,
                specs = {false, false, false, true},
                talent = {
                    tier = 5,
                    column = 1,
                    mustHave = true,
                },
            },
            ["11-a121bb73-1"] = {   -- Incarnation: Tree of Life (Talent) (Resto)
                spell = 117679,
                minLevel = 75,
                specs = {false, false, false, true},
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(33891),
            },
            ["11-9a94211a-1"] = {spell = 1850},   -- Dash
        -- Free Target Auras
            ["11-a6d635ba-1"] = {   -- Thrash (Feral)
                spell = 106830,
                minLevel = 14,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false}
            },
    },

    ["HUNTER"] = {
        -- Static Player Auras
            ["3-a08d9a86-1"] = {   -- Dire Beast (BM)
                spell = 120694,
                minLevel = 10,
                specs = {true, false, false},
                talent = {
                    tier = 2,
                    column = 2,
                    mustHave = false,
                },
                order = 1,
            },
            ["3-9baa529a-1"] = {   -- Dire Frenzy (BM)
                spell = 217200,
                minLevel = 30,
                unit = "pet",
                specs = {true, false, false},
                talent = {
                    tier = 2,
                    column = 2,
                    mustHave = true,
                },
                order = 1,
            },
            ["3-81e273d4-1"] = {   -- Marking Targets (MM)
                spell = 223138,
                minLevel = 18,
                specs = {false, true, false},
                order = 1,
            },
            ["3-ad43391a-1"] = {   -- Steady Focus (MM) (Talent)
                spell = 193534,
                minLevel = 15,
                specs = {false, true, false},
                talent = {
                    tier = 1,
                    column = 2,
                    mustHave = true,
                },
                order = 2,
            },
            ["3-a5b3eaa4-1"] = {   -- Mongoose Fury (SV)
                spell = 190931,
                minLevel = 18,
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
            ["3-9298993d-1"] = {   -- True Aim (MM) (Talent)
                spell = 199803,
                minLevel = 30,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                talent = {
                    tier = 2,
                    column = 3,
                    mustHave = true,
                },
                order = 1,
            },
            ["3-a18c4f9e-1"] = {   -- Lacerate (SV)
                spell = 185855,
                minLevel = 36,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
            ["3-bb365636-1"] = {   -- Serpent Sting (SV) (Talent)
                spell = 118253,
                minLevel = 90,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                talent = {
                    tier = 6,
                    column = 3,
                    mustHave = true,
                },
                order = 2,
            },
        -- Free Player Auras
            ["3-afe5d9ac-1"] = {   -- Wild Call (BM)
                spell = 185791,
                minLevel = 22,
                specs = {true, false, false}
            },
            ["3-a280664b-1"] = {   -- Beast Cleave (BM)
                spell = 118455,
                minLevel = 29,
                unit = "pet",
                specs = {true, false, false}
            },
            ["3-9a8eacb4-1"] = {   -- Bestial Wrath (BM)
                spell = 19574,
                minLevel = 40,
                specs = {true, false, false}
            },
            ["3-9bd8be3e-1"] = {   -- Aspect of the Wild (BM)
                spell = 193530,
                minLevel = 18,
                specs = {true, false, false}
            },
            ["3-91db07fb-1"] = {   -- Trueshot (MM)
                spell = 193526,
                minLevel = 40,
                specs = {false, true, false}
            },
            ["3-9924d77d-1"] = {   -- Bombardment (MM)
                spell = 82921,
                minLevel = 62,
                specs = {false, true, false}
            },
            ["3-9e5da04c-1"] = {   -- Lock and Load (MM) (Talent)
                spell = 194594,
                minLevel = 30,
                specs = {false, true, false},
                talent = {
                    tier = 2,
                    column = 1,
                    mustHave = true,
                },
            },
            ["3-94516e94-1"] = {   -- Trick Shot (MM) (Talent)
                spell = 227272,
                minLevel = 100,
                specs = {false, true, false},
                talent = {
                    tier = 7,
                    column = 3,
                    mustHave = true,
                },
            },
            ["3-86ed5897-1"] = {   -- Aspect of the Eagle (SV)
                spell = 186289,
                minLevel = 44,
                specs = {false, false, true}
            },
            ["3-9bca201a-1"] = {spell = 186265},   -- Aspect of the Turtle
        -- Free Target Auras
            ["3-8998954e-1"] = {   -- Vulnerable (MM)
                spell = 187131,
                minLevel = 18,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false}
            },
            ["3-bc4972cd-1"] = {   -- Explosive Trap (SV)
                spell = 13812,
                minLevel = 48,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true}
            },
            ["3-a0d6a726-1"] = {   -- A Murder of Crows (BM, MM) (Talent)
                spell = 131894,
                minLevel = 90,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
            },
            ["3-ae78fcd9-1"] = {   -- Black Arrow (MM) (Talent)
                spell = 194599,
                minLevel = 30,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                talent = {
                    tier = 2,
                    column = 2,
                    mustHave = true,
                },
            },
    },

    ["MAGE"] = {
        -- Static Player Auras
            ["8-860b9d97-1"] = {   -- Arcane Missiles! (Arcane)
                spell = 79683,
                minLevel = 24,
                specs = {true, false, false},
                order = 1,
            },
            ["8-9f01a933-1"] = {   -- Fingers of Frost (Frost)
                spell = 44544,
                minLevel = 24,
                specs = {false, false, true},
                order = 1,
            },
            ["8-8ab5ea50-1"] = {   -- Rune of Power (Talent)
                spell = 116014,
                minLevel = 45,
                talent = {
                    tier = 3,
                    column = 2,
                    mustHave = true,
                },
                order = 2,
            },
        -- Static Target Auras
            ["8-89b90044-1"] = {   -- Nether Tempest (Arcane) (Talent)
                spell = 114923,
                minLevel = 90,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
                order = 1,
            },
            ["8-bc5837f7-1"] = {   -- Mastery: Ignite (Fire)
                spell = 12654,
                minLevel = 12,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 1,
            },
            ["8-8864aa74-1"] = {   -- Living Bomb (Fire) (Talent)
                spell = 217694,
                minLevel = 75,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
                order = 2,
            },
        -- Free Player Auras
            ["8-95ae39d1-1"] = {   -- Presence of Mind (Arcane)
                spell = 205025,
                minLevel = 15,
                specs = {true, false, false},
                talent = {
                    tier = 1,
                    column = 2,
                    mustHave = true,
                },
            },
            ["8-bf568893-1"] = {   -- Arcane Power (Arcane)
                spell = 12042,
                minLevel = 44,
                specs = {true, false, false},
            },
            ["8-a3050e9c-1"] = {   -- Heating Up (Fire)
                spell = 48107,
                minLevel = 12,
                specs = {false, true, false},
            },
            ["8-a0b8d817-1"] = {   -- Pyroblast! (Fire)
                spell = 48108,
                minLevel = 12,
                specs = {false, true, false},
                customIcon = [[Interface\Icons\Spell_Fire_Fireball02]]
            },
            ["8-84e5eb74-1"] = {   -- Brain Freeze (Frost)
                spell = 190446,
                minLevel = 28,
                specs = {false, false, true},
            },
            ["8-be277caf-1"] = {   -- Icy Veins (Frost)
                spell = 12472,
                minLevel = 40,
                specs = {false, false, true},
            },
            ["8-ba699a82-1"] = {   -- Ice Block
                spell = 45438,
                minLevel = 15,
            },
            ["8-93a9a908-1"] = {   -- Invisibility
                spell = {32612, 113862},
                minLevel = 50,
            },
            ["8-b1d9be24-1"] = {   -- Mirror Image (Talent)
                spell = 55342,
                minLevel = 45,
                talent = {
                    tier = 3,
                    column = 1,
                    mustHave = true,
                },
                eventUpdate = {
                    event = "COMBAT_LOG_EVENT_UNFILTERED",
                    func = MirrorImage
                },
            },
            ["8-bcbae5c4-1"] = {   -- Incanter's Flow (Talent)
                spell = {156150, 116267},
                minLevel = 45,
                talent = {
                    tier = 3,
                    column = 3,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(116267),
                eventUpdate = {
                    event = "UNIT_AURA",
                    func = IncantersFlow
                },
            },
            ["8-817ae191-1"] = {   -- Ice Floes (Talent)
                spell = 108839,
                minLevel = 75,
                talent = {
                    tier = 5,
                    column = 1,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["8-a0ef0e74-1"] = {   -- Frost Bomb (Frost)
                spell = 112948,
                minLevel = 90,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
            },
    },

    ["MONK"] = {
        -- Static Player Auras
            ["10-a53c4a0d-1"] = {   -- Ironskin Brew (Brewmaster)
                spell = {115308, 215479},
                minLevel = 28,
                specs = {true, false, false},
                order = 1,
            },
            --[=[ ["10-b95a8d44-1"] = {   -- Gift of the Ox (Brewmaster)
                spell = 124502,
                minLevel = 40,
                specs = {true, false, false},
                order = 2,
                eventUpdate = {
                    event = "COMBAT_LOG_EVENT_UNFILTERED",
                    func = GiftoftheOx
                },
                customIcon = [[Interface\Icons\Ability_Monk_HealthSphere]],
                debug = "GiftoftheOx"
            },]=]
            ["10-8082e169-1"] = {   -- Power Strikes (Windwalker) (Talent)
                spell = 129914,
                minLevel = 45,
                specs = {false, false, true},
                talent = {
                    tier = 3,
                    column = 3,
                    mustHave = true,
                },
                order = 1,
                eventUpdate = {
                    event = "UNIT_AURA",
                    func = PowerStrikes
                },
            },
            ["10-a297de89-1"] = {   -- Hit Combo (Windwalker) (Talent)
                spell = 196741,
                minLevel = 90,
                specs = {false, false, true},
                talent = {
                    tier = 6,
                    column = 3,
                    mustHave = true,
                },
                order = 2,
            },
        -- Static Target Auras
            ["10-83b91fd2-1"] = {   -- Mark of the Crane (Windwalker)
                spell = 228287,
                minLevel = 40,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
        -- Free Player Auras
            ["10-9cc09bbe-1"] = {   -- Guard (Brewmaster)
                spell = 202162,
                minLevel = 110,
                specs = {true, false, false},
                talentPVP = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
            },
            ["10-8cf143c1-1"] = {   -- Touch of Karma (Windwalker)
                spell = 125174,
                minLevel = 22,
                specs = {false, false, true},
            },

            ["10-ab86d9e3-1"] = {   -- Serenity (Windwalker) (Talent)
                spell = 152173,
                minLevel = 100,
                specs = {false, false, true},
                talent = {
                    tier = 7,
                    column = 3,
                    mustHave = true,
                },
            },
            ["10-9372460a-1"] = {   -- Diffuse Magic (Talent)
                spell = 122783,
                minLevel = 75,
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
            },
            ["10-871ccaed-1"] = {   -- Dampen Harm (Talent)
                spell = 122278,
                minLevel = 75,
                talent = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
            },
            ["10-a84fc108-1"] = {spell = 120954},   -- Fortifying Brew
        -- Free Target Auras
    },

    ["PALADIN"] = {
        -- Static Player Auras
            ["2-b2420e4c-1"] = {   -- Shield of the Righteous (Prot)
                spell = 132403,
                minLevel = 38,
                specs = {false, true, false},
                order = 1,
            },
        -- Static Target Auras
            ["2-919f1d2c-1"] = {   -- Blade of Wrath (Ret) (Talent)
                spell = 202270,
                minLevel = 60,
                auraType = "debuff",
                unit = "target",
                talent = {
                    tier = 4,
                    column = 2,
                    mustHave = true,
                },
                order = 1,
            },
        -- Free Player Auras
            ["2-bc41e225-1"] = {   -- Infusion of Light (Holy)
                spell = 54149,
                minLevel = 50,
                specs = {true, false, false},
            },
            ["2-a0c9223c-1"] = {   -- Avenging Wrath (Holy)
                spell = 31842,
                minLevel = 72,
                specs = {true, false, false},
            },
            ["2-ab20fc1d-1"] = {   -- Divine Purpose (Holy) (Talent)
                spell = {216411, 216413}, --Holy Shock, Light of Dawn
                minLevel = 75,
                specs = {true, false, false},
                talent = {
                    tier = 5,
                    column = 1,
                    mustHave = true,
                },
            },
            ["2-9434af38-1"] = {   -- Holy Avenger (Holy) (Talent)
                spell = 105809,
                minLevel = 75,
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
            },
            ["2-a73a3586-1"] = {   -- Ardent Defender (Prot)
                spell = 31850,
                minLevel = 65,
                specs = {false, true, false},
            },
            ["2-be248ad3-1"] = {   -- Guardian of Ancient Kings (Prot)
                spell = 86659,
                minLevel = 72,
                specs = {false, true, false},
            },
            ["2-bb656491-1"] = {   -- Seraphim (Prot) (Talent)
                spell = 152262,
                minLevel = 100,
                specs = {false, true, false},
                talent = {
                    tier = 7,
                    column = 2,
                    mustHave = true,
                },
            },
            ["2-bdba8989-1"] = {   -- Avenging Wrath (Prot, Ret)
                spell = 31884,
                minLevel = 72,
                specs = {false, true, true},
            },
            ["2-8942b773-1"] = {   -- Divine Purpose (Ret) (Talent)
                spell = 223819,
                minLevel = 100,
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = true,
                },
            },
        ["2-bb2a51e1-1"] = {spell = 498},   -- Divine Protection
        -- Free Target Auras
    },

    ["PRIEST"] = {
        -- Static Player Auras
        -- Static Target Auras
            ["5-b255a230-1"] = {   -- Shadow Word:Pain (Disc)
                spell = 589,
                minLevel = 3,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = false,
                },
                order = 1,
            },
            ["5-8636c202-1"] = {   -- Purge the Wicked (Disc) (Talent)
                spell = 204213,
                minLevel = 100,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = true,
                },
                order = 1,
            },
            ["5-9ee1ee3e-1"] = {   -- Shadow Word:Pain (Shadow)
                spell = 589,
                minLevel = 3,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
            ["5-a3ca1f76-1"] = {   -- Vampiric Touch (Shadow)
                spell = 34914,
                minLevel = 24,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 2,
            },
        -- Free Player Auras
            ["5-a4b0b5d4-1"] = {   -- Rapture (Disc)
                spell = 47536,
                minLevel = 50,
                specs = {true, false, false},
            },
            ["5-90be0e2a-1"] = {   -- Power Infusion (Disc) (Talent)
                spell = 10060,
                minLevel = 75,
                specs = {true, false, false},
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
            },
            ["5-86b717fe-1"] = {   -- Twist of Fate (Disc) (Talent)
                spell = 123254,
                minLevel = 75,
                specs = {true, false, false},
                talent = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
            },
            ["5-b1df8034-1"] = {   -- Spirit of Redemption (Holy)
                spell = 27827,
                minLevel = 29,
                specs = {false, true, false},
            },
            ["5-ab8e3ab7-1"] = {   -- Surge of Light (Holy) (Talent)
                spell = 114255,
                minLevel = 75,
                specs = {false, true, false},
                talent = {
                    tier = 5,
                    column = 1,
                    mustHave = true,
                },
            },
            ["5-b917679d-1"] = {   -- Divinity (Holy) (Talent)
                spell = 197030,
                minLevel = 90,
                specs = {false, true, false},
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
            },
            ["5-80ee0623-1"] = {   -- Apotheosis (Holy) (Talent)
                spell = 200183,
                minLevel = 100,
                specs = {false, true, false},
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = true,
                },
            },
            ["5-9678bff1-1"] = {   -- Voidform (Shadow)
                spell = 194249,
                minLevel = 10,
                specs = {false, false, true},
            },
            ["5-b6ea7743-1"] = {   -- Lingering Insanity (Shadow)
                spell = 197937,
                minLevel = 10,
                specs = {false, false, true},
            },
            ["5-aaf9a60f-1"] = {   -- Dispersion (Shadow)
                spell = 47585,
                minLevel = 58,
                specs = {false, false, true},
            },
            ["5-9e14c42b-1"] = {   -- Vampiric Embrace (Shadow)
                spell = 15286,
                minLevel = 65,
                specs = {false, false, true},
            },
            ["5-817d87de-1"] = {   -- Shadowy Insight (Talent) (Shadow)
                spell = 124430,
                minLevel = 75,
                specs = {false, false, true},
                talent = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
            },
            ["5-8ead482d-1"] = {   -- Power Infusion (Shadow) (Talent)
                spell = 10060,
                minLevel = 90,
                specs = {false, false, true},
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
            },
            ["5-9f2335ea-1"] = {   -- Dominant Mind (Disc, Shadow) (Talent)
                spell = 205364, -- Mind Control
                minLevel = 45,
                auraType = "debuff",
                unit = "pet",
                specs = {true, false, false},
                talent = {
                    tier = 3,
                    column = 3,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["5-a88338ed-1"] = {   -- Holy Fire (Holy)
                spell = 14914,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
            },
    },

    ["ROGUE"] = {
        -- Static Player Auras
            ["4-b590c8e6-1"] = {   -- Envenom (Sass)
                spell = 32645,
                minLevel = 3,
                specs = {true, false, false},
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = Envenom
                }
            },
            --[[["4-a758d1b3-1"] = {   -- Roll the Bones (Outlaw)
                spell = {
                    193356, -- Broadsides
                    193357, -- Shark Infested Waters
                    193358, -- Grand Melee
                    193359, -- True Bearing
                    199600, -- Buried Treasure
                    199603, -- Jolly Roger
                },
                minLevel = 36,
                specs = {false, true, false},
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = false,
                },
                order = 1,
                customName = _G.GetSpellInfo(193316),
                eventUpdate = {
                    event = "UNIT_AURA",
                    func = RollTheBones
                }
            },]]
            ["4-a4347749-1"] = {   -- Slice and Dice (Outlaw) (Talent)
                spell = 5171,
                minLevel = 100,
                specs = {false, true, true},
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = true,
                },
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = SliceAndDice
                }
            },
            ["4-a5abd891-1"] = {   -- Shadow Dance (Sub)
                spell = 185422,
                minLevel = 36,
                specs = {false, false, true},
                order = 1,
            },
            ["4-93d2a558-1"] = {   -- Enveloping Shadows (Sub) (Talent)
                spell = 206237,
                minLevel = 90,
                specs = {false, false, true},
                talent = {
                    tier = 6,
                    column = 3,
                    mustHave = true,
                },
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = EnvelopingShadows
                }
            },
        -- Static Target Auras
            ["4-b2b390d7-1"] = {   -- Rupture (Sass)
                spell = 1943,
                minLevel = 22,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = Rupture
                }
            },
            ["4-b7bc86f8-1"] = {   -- Ghostly Strike (Outlaw) (Talent)
                spell = 196937,
                minLevel = 15,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                talent = {
                    tier = 1,
                    column = 1,
                    mustHave = true,
                },
                order = 1,
            },
            ["4-ac22ce84-1"] = {   -- Nightblade (Sub)
                spell = 195452,
                minLevel = 46,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = Nightblade
                }
            },
        -- Free Player Auras
            ["4-bcbb4a21-1"] = {   -- Riposte (Outlaw)
                spell = 199754,
                minLevel = 10,
                specs = {false, true, false},
            },
            ["4-9040a7b9-1"] = {   -- Blade Flurry (Outlaw)
                spell = 13877,
                minLevel = 48,
                specs = {false, true, false},
            },
            ["4-bf8be102-1"] = {   -- Adrenaline Rush (Outlaw)
                spell = {13750},
                minLevel = 72,
                specs = {false, true, false},
            },
            ["4-8301b93a-1"] = {   -- Symbols of Death (Sub)
                spell = 212283,
                minLevel = 34,
                specs = {false, false, true},
            },
            ["4-b8faafc6-1"] = {   -- Shadow Blades (Sub)
                spell = 121471,
                minLevel = 72,
                specs = {false, false, true},
            },
            ["4-9f580e91-1"] = {   -- Master of Subtlety (Sub)
                spell = 31665,
                minLevel = 15,
                specs = {false, false, true},
                talent = {
                    tier = 1,
                    column = 1,
                    mustHave = true,
                },
            },
            ["4-9f332190-1"] = {   -- Evasion (Sass, Sub)
                spell = 5277,
                minLevel = 8,
                specs = {true, false, true},
            },
            ["4-82cf4c29-1"] = {   -- Subterfuge (Sass, Sub) (Talent)
                spell = 115192,
                minLevel = 15,
                specs = {true, false, true},
                talent = {
                    tier = 2,
                    column = 2,
                    mustHave = true,
                },
            },
            ["4-80b0f420-1"] = {   -- Vanish
                spell = {11327,115193},
                minLevel = 32,
            },
            ["4-a0c86712-1"] = {   -- Feint
                spell = 1966,
                minLevel = 44,
            },
            ["4-851514ee-1"] = {   -- Cloak of Shadows
                spell = 31224,
                minLevel = 58,
            },
            ["4-a758c6b8-1"] = {   -- Cheat Death (Talent)
                spell = 45182,
                minLevel = 60,
                talent = {
                    tier = 4,
                    column = 3,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(31230),
            },
            ["4-b697e402-1"] = {   -- Alacrity (Talent)
                spell = 193538,
                minLevel = 90,
                talent = {
                    tier = 6,
                    column = 2,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["4-8856069f-1"] = {   -- Garrote (Sass)
                spell = 703,
                minLevel = 48,
                auraType = "debuff",
                unit = "target",
            },
            ["4-8c6900cc-1"] = {   -- Vendetta (Sass)
                spell = 79140,
                minLevel = 72,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
            },
            ["4-9b960b7a-1"] = {   -- Hemorrhage (Sass)
                spell = 16511,
                minLevel = 15,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 1,
                    column = 3,
                    mustHave = true,
                },
            },
    },

    ["SHAMAN"] = {
        -- Static Player Auras
            ["7-bd97988f-1"] = {   -- Boulderfist (Enh) (Talent)
                spell = 218825,
                minLevel = 15,
                specs = {false, true, false},
                talent = {
                    tier = 1,
                    column = 3,
                    mustHave = true,
                },
                order = 1,
            },
            ["7-98774f14-1"] = {   -- Landslide (Enh) (Talent)
                spell = 202004,
                minLevel = 100,
                specs = {false, true, false},
                order = 2,
                talent = {
                    tier = 7,
                    column = 2,
                    mustHave = true,
                },
            },
            ["7-8065f89b-1"] = {   -- Frostbrand (Enh)
                spell = 196834,
                minLevel = 60,
                specs = {false, true, false},
                talent = { -- Hailstorm
                    tier = 4,
                    column = 3,
                    mustHave = true,
                },
                order = 3,
            },
            ["7-9f7d9c17-1"] = {   -- Flametongue (Enh)
                spell = 194084,
                minLevel = 12,
                specs = {false, true, false},
                order = 4,
            },
            ["7-a7dc8a98-1"] = {   -- Tidal Waves (Resto)
                spell = 53390,
                minLevel = 50,
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
            ["7-8ef35823-1"] = {   -- Flame Shock (Ele)
                spell = 188389,
                minLevel = 5,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 1,
            },
        -- Free Player Auras
            ["7-80da6a44-1"] = {   -- Ancestral Guidance (Ele) (Talent)
                spell = 108281,
                minLevel = 30,
                specs = {true, false, false},
                talent = {
                    tier = 2,
                    column = 2,
                    mustHave = true,
                },
            },
            ["7-be08b458-1"] = {   -- Lava Surge (Ele) (Talent)
                spell = 77762,
                minLevel = 38,
                specs = {true, false, false},
            },
            ["7-93c0c50d-1"] = {   -- Elemental Focus (Ele) (Talent)
                spell = 16246,
                minLevel = 38,
                specs = {true, false, false},
            },
            ["7-b9209d3d-1"] = {   -- Elemental Blast (Ele) (Talent)
                spell = {118522, 173183, 173184}, -- Crit, Haste, Mast
                minLevel = 60,
                talent = {
                    tier = 4,
                    column = 1,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(117014),
            },
            ["7-b5ebf41b-1"] = {   -- Elemental Mastery (Ele) (Talent)
                spell = 16166,
                minLevel = 90,
                specs = {true, false, false},
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
            },
            ["7-80768995-1"] = {   -- Crash Lightning (Enh)
                spell = 187878,
                minLevel = 28,
                specs = {false, true, false},
            },
            ["7-8ffd47c0-1"] = {   -- Stormbringer (Enh)
                spell = 201846,
                minLevel = 40,
                specs = {false, true, false},
            },
            ["7-901cef84-1"] = {   -- Unleash Life (Resto) (Talent)
                spell = 73685,
                minLevel = 15,
                specs = {false, false, true},
                talent = {
                    tier = 1,
                    column = 2,
                    mustHave = true,
                },
            },
            ["7-b7881104-1"] = {   -- Ancestral Guidance (Resto) (Talent)
                spell = 108281,
                minLevel = 60,
                specs = {false, false, true},
                talent = {
                    tier = 4,
                    column = 2,
                    mustHave = true,
                },
            },
            ["7-9725fc0f-1"] = {   -- Spiritwalker's Grace (Resto)
                spell = 79206,
                minLevel = 72,
                specs = {false, false, true},
            },
            ["7-b44b958f-1"] = {   -- Astral Shift
                spell = 108271,
                minLevel = 44,
            },
            ["7-b2a0a61d-1"] = {   -- Ascendance (Talent)
                spell = {114050, 114051, 114052}, -- Ele, Enh, Resto
                minLevel = 100,
                talent = {
                    tier = 7,
                    column = 1,
                    mustHave = true,
                },
            },
        -- Free Target Auras
    },

    ["WARLOCK"] = {
        -- Static Player Auras
            ["9-bd74da2c-1"] = {   -- Mana Tap (Aff, Destro) (Talent)
                spell = 196104,
                minLevel = 30,
                specs = {true, false, true},
                talent = {
                    tier = 2,
                    column = 3,
                    mustHave = true,
                },
                order = 1,
            },
            ["9-8ef292f7-1"] = {   -- Demonic Empowerment (Demo) (Talent)
                spell = 193396,
                minLevel = 12,
                unit = "pet",
                specs = {false, true, false},
                -- TODO: track number of demons summoned, and w/ buff
                order = 1,
            },
        -- Static Target Auras
            ["9-be413012-1"] = {   -- Corruption (Aff)
                spell = 146739,
                minLevel = 3,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 1,
            },
            ["9-9d46aea7-1"] = {   -- Agony (Aff)
                spell = 980,
                minLevel = 6,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 2,
            },
            ["9-bcf57e20-1"] = {   -- Unstable Affliction (Aff)
                spell = 30108,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 3,
            },
            ["9-b2aa6f2d-1"] = {   -- Doom (Demo)
                spell = 603,
                minLevel = 26,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 1,
            },
            ["9-bfee421b-1"] = {   -- Shadowflame (Demo) (Talent)
                spell = 205181,
                minLevel = 15,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                talent = {
                    tier = 1,
                    column = 2,
                    mustHave = true,
                },
                order = 2,
            },
            ["9-be90eb3d-1"] = {   -- Immolate (Dest)
                spell = 157736,
                minLevel = 12,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
        -- Free Player Auras
            ["9-82ad155e-1"] = {   -- Shadowy Inspiration (Demo) (Talent)
                spell = 196606,
                minLevel = 15,
                specs = {false, true, false},
                talent = {
                    tier = 1,
                    column = 1,
                    mustHave = true,
                },
            },
            ["9-9f916aed-1"] = {   -- Demonic Calling (Demo) (Talent)
                spell = 205146,
                minLevel = 15,
                specs = {false, true, false},
                talent = {
                    tier = 1,
                    column = 3,
                    mustHave = true,
                },
            },
            ["9-a8874fa3-1"] = {   -- Grimoire of Synergy (Demo) (Talent)
                spell = 171982, -- Demonic Synergy
                minLevel = 90,
                specs = {false, true, false},
                talent = {
                    tier = 6,
                    column = 3,
                    mustHave = true,
                },
            },
            ["9-bc1debbb-1"] = {   -- Backdraft (Destro) (Talent)
                spell = 117828,
                minLevel = 15,
                specs = {false, false, true},
                talent = {
                    tier = 1,
                    column = 1,
                    mustHave = true,
                },
            },
            ["9-911df4e4-1"] = {   -- Soul Harvest (Talent)
                spell = 196098,
                minLevel = 60,
                talent = {
                    tier = 4,
                    column = 3,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["9-8072e1ae-1"] = {   -- Haunt (Aff) (Talent)
                spell = 48181,
                minLevel = 15,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 1,
                    column = 1,
                    mustHave = true,
                },
            },
            ["9-869d9949-1"] = {   -- Seed of Corruption (Aff)
                spell = 27243,
                minLevel = 21,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
            },
            ["9-87bd1ea8-1"] = {   -- Phantom Singularity (Aff) (Talent)
                spell = 205179,
                minLevel = 100,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 7,
                    column = 2,
                    mustHave = true,
                },
            },
            ["9-858bed5f-1"] = {   -- Eradication (Destro) (Talent)
                spell = 196414,
                minLevel = 60,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                talent = {
                    tier = 4,
                    column = 1,
                    mustHave = true,
                },
            },
    },

    ["WARRIOR"] = {
        -- Static Player Auras
            ["1-be149d0a-1"] = {   -- Enrage (Fury)
                spell = 184362,
                minLevel = 14,
                specs = {false, true, false},
                order = 1,
            },
            ["1-bb0caec6-1"] = {   -- Ignore Pain (Prot)
                spell = 190456,
                minLevel = 34,
                specs = {false, false, true},
                order = 1,
            },
            ["1-8d6897d2-1"] = {   -- Shield Block (Prot)
                spell = 132404,
                minLevel = 18,
                specs = {false, false, true},
                order = 2,
            },
        -- Static Target Auras
            ["1-9256f2b1-1"] = {   -- Rend (Arms)
                spell = 772,
                minLevel = 45,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 3,
                    column = 2,
                    mustHave = true,
                },
                order = 1,
            },
        -- Free Player Auras
            ["1-9ca47424-1"] = {   -- Die by the Sword (Arms)
                spell = 118038,
                minLevel = 50,
                specs = {true, false, false},
            },
            ["1-b9d2c83a-1"] = {   -- Focused Rage (Arms) (Talent)
                spell = 207982,
                minLevel = 75,
                specs = {true, false, false},
                talent = {
                    tier = 5,
                    column = 3,
                    mustHave = true,
                },
            },
            ["1-88616b14-1"] = {   -- Furious Slash (Fury)
                spell = 206333, -- Taste for Blood
                minLevel = 10,
                specs = {false, true, false},
            },
            ["1-849c1974-1"] = {   -- Enraged Regeneration (Fury)
                spell = 184364,
                minLevel = 12,
                specs = {false, true, false},
            },
            ["1-8c2242a0-1"] = {   -- War Machine (Fury) (Talent)
                spell = 215562,
                minLevel = 15,
                talent = {
                    tier = 1,
                    column = 1,
                    mustHave = true,
                },
            },
            ["1-80e6917a-1"] = {   -- Frothing Berserker (Fury) (Talent)
                spell = 215572,
                minLevel = 75,
                talent = {
                    tier = 5,
                    column = 2,
                    mustHave = true,
                },
            },
            ["1-9b003d2d-1"] = {   -- Frenzy (Fury) (Talent)
                spell = 202539,
                minLevel = 90,
                talent = {
                    tier = 6,
                    column = 2,
                    mustHave = true,
                },
            },
            ["1-a216ed2a-1"] = {   -- Dragon Roar (Fury) (Talent)
                spell = 118000,
                minLevel = 100,
                talent = {
                    tier = 7,
                    column = 3,
                    mustHave = true,
                },
            },
            ["1-ae88cb34-1"] = {   -- Last Stand (Prot)
                spell = 12975,
                minLevel = 36,
                specs = {false, false, true},
            },
            ["1-8ede1252-1"] = {   -- Ultimatum (Prot)
                spell = 122510,
                minLevel = 45,
                specs = {false, false, true},
                talent = {
                    tier = 3,
                    column = 2,
                    mustHave = true,
                },
            },
            ["1-bc105857-1"] = {   -- Shield Wall (Prot)
                spell = 871,
                minLevel = 48,
                specs = {false, false, true},
            },
            ["1-b8a217f8-1"] = {   -- Focused Rage (Prot)
                spell = 204488,
                minLevel = 52,
                specs = {false, false, true},
            },
            ["1-af01758e-1"] = {   -- Spell Reflection (Prot)
                spell = 23920,
                minLevel = 65,
                specs = {false, false, true},
            },
            ["1-a17f11f4-1"] = {   -- Victory Rush (Arms, Prot)
                spell = 32216, -- Victorious
                minLevel = 10,
                specs = {true, false, true},
            },
            ["1-bc751f32-1"] = {   -- Avatar (Talent)
                spell = 107574,
                minLevel = 45,
                talent = {
                    tier = 3,
                    column = 3,
                    mustHave = true,
                },
            },
            ["1-bb6869cd-1"] = {   -- Berserker Rage
                spell = 18499,
                minLevel = 40,
            },
            ["1-803da340-1"] = {   -- Battle Cry
                spell = 1719,
                minLevel = 60,
            },
        -- Free Target Auras
            ["1-bbd999f7-1"] = {   -- Colossus Smash (Arms)
                spell = 208086,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
            },
            ["1-a26f3820-1"] = {   -- Bloodbath (Fury) (Talent)
                spell = 113344,
                minLevel = 90,
                auraType = "debuff",
                unit = "target",
                talent = {
                    tier = 6,
                    column = 1,
                    mustHave = true,
                },
            },
            ["1-96c7609f-1"] = {   -- Demoralizing Shout (Prot)
                spell = 1160,
                minLevel = 50,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
    },
}
