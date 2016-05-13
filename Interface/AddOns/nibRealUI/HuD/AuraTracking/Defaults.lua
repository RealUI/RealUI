local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local Lerp = RealUI.Lerp

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
local SavageRoar
local MirrorImage, IncantersFlow
local PowerStrikes
local BanditsGuile, Envenom, Rupture, ShadowReflection, SliceAndDice
local function PredictDuration(gap, base, max)
    local potential, color = "", {}
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
            AuraTracking:RemoveTracker(self, self.isStatic)
        end
    end

    -- Shows predicted debuff duration based on current CPs.
    return function(self, spellData, unit, powerType)
        debug(spellData.debug, "UNIT_POWER_FREQUENT", unit, powerType)
        if unit == "player" and powerType == "COMBO_POINTS" then
            debug(spellData.debug, "Main", unit, powerType)
            local comboPoints = _G.UnitPower("player", _G.SPELL_POWER_COMBO_POINTS)

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
        end
    end
end

if class == "DRUID" then
    SavageRoar = PredictDuration(6, 18, 42)
elseif class == "MAGE" then
    do -- MirrorImage
        local hasAura = false
        local start, duration = 0, 40

        local function postUnitAura(self, spellData)
            debug(spellData.debug, "postUnitAura", hasAura)
            self.cd:SetCooldown(start, duration)

            if hasAura and not self.slotID then
                AuraTracking:AddTracker(self)
            elseif not hasAura and self.slotID then
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
            elseif self.slotID then
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

            local status = self:CreateTexture(nil, "BACKGROUND", nil, 0)
            status:SetTexture(0, 0, 0, 0.9)
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
            elseif numNotUsed > threshold and self.slotID then
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
elseif class == "ROGUE" then
    do -- BanditsGuile
        -- Shows how many Sinister Strikes hit since the last BG upgrade or reset.
        local SinisterStrikeID = 1752
        local swingCount = 0
        local bgSpellIDs, bgState = {
            [84745] = 1, -- Shallow Insight
            [84746] = 2, -- Moderate Insight
            [84747] = 3  -- Deep Insight
        }, 0

        local function postUnitAura(self, spellData, aura, hasAura)
            debug(spellData.debug, "postUnitAura", swingCount, bgState)
            if (swingCount > 0) and (bgState < 3) then
                self.count:SetText(swingCount)
            else
                self.count:SetText()
            end
            if hasAura then
                self.auraIndex = aura.index
                self.cd:Show()
                self.cd:SetCooldown(aura.endTime - aura.duration, aura.duration)
                self.icon:SetTexture(aura.texture)
                AuraTracking:AddTracker(self)
            elseif hasAura ~= nil and self.slotID then
                self.auraIndex = nil
                self.cd:SetCooldown(0, 0)
                self.cd:Hide()
                AuraTracking:RemoveTracker(self, self.isStatic)
            end
        end

        function BanditsGuile(self, spellData, _, subEvent, _, srcGUID, _,_,_,_,_,_,_, spellID, _,_, ...)
            debug(spellData.debug, "COMBAT_LOG_EVENT_UNFILTERED", subEvent, srcGUID, spellID)
            if (srcGUID ~= AuraTracking.playerGUID) then return end
            AuraTracking:debug("BanditsGuile", bgState)

            if (subEvent == "SPELL_DAMAGE") and (spellID == SinisterStrikeID) then
                local _,_,_,_,_,_,_,_,_,_, isMultistrike = ...
                if not isMultistrike and bgState < 3 then
                    swingCount = swingCount + 1
                    AuraTracking:debug("BanditsGuile:SPELL_DAMAGE", swingCount)
                end

            elseif ((subEvent == "SPELL_AURA_REMOVED") or (subEvent == "SPELL_AURA_APPLIED")) and (bgSpellIDs[spellID]) then
                AuraTracking:debug("BanditsGuile:"..subEvent, spellID)
                if bgState < 3 then
                    bgState = bgSpellIDs[spellID]
                else
                    bgState = 0
                end
                swingCount = 0
            end
            postUnitAura(self, spellData)

            if not self.postUnitAura then
                self.postUnitAura = postUnitAura
            end
        end
    end
    Envenom = PredictDuration(1, 2, 6)
    Rupture = PredictDuration(4, 8, 24)
    SliceAndDice = PredictDuration(6, 12, 36)
    do -- ShadowReflection
        -- Modifies the tracker icon to show when the reflection is or isn't attaking.
        local isWatching = false
        local start, duration = 0, 8.5

        local function postUnitAura(self, spellData, aura, hasAura)
            debug(spellData.debug, "postUnitAura", isWatching, hasAura)

            self.cd:SetCooldown(start, duration)
            self.cd:SetReverse(isWatching)
            self.icon:SetDesaturated(isWatching)

            if hasAura then
                self.auraIndex = aura.index
                self.cd:Show()
                self.icon:SetTexture(aura.texture)
                AuraTracking:AddTracker(self)
            elseif hasAura ~= nil and self.slotID then
                self.auraIndex = nil
                self.cd:SetCooldown(0, 0)
                self.cd:Hide()
                self.count:SetText("")
                AuraTracking:RemoveTracker(self, self.isStatic)
            end
        end

        function ShadowReflection(self, spellData, timestamp, subEvent, _, srcGUID, _,_,_,_,_,_,_, spellID, _,_)
            if srcGUID == AuraTracking.playerGUID and spellID == spellData.spell then
                debug(spellData.debug, "COMBAT_LOG_EVENT_UNFILTERED", subEvent, timestamp, _G.time(), _G.GetTime())

                if subEvent == "SPELL_AURA_APPLIED" then
                    AuraTracking:debug("ShadowReflection", isWatching)
                    isWatching = true
                    start = _G.GetTime()
                    _G.C_Timer.After(duration, function()
                        isWatching = false
                        start = _G.GetTime()
                        postUnitAura(self, spellData)
                    end)
                end
                postUnitAura(self, spellData)

                if not self.postUnitAura then
                    self.postUnitAura = postUnitAura 
                end
            end
        end
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

if not RealUI.isBeta then

--[[ Retired IDs
9ab78043
857dac62
99868b0a
bd56d2d6
965917ad
a5bdd6b2


-- Used
a6a32ca3

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
                spell = 49222,
                minLevel = 55,
                specs = {true, false, false},
                order = 2,
            },
            ["6-ab29032c-1"] = {   -- Shadow Infusion, Dark Transformation (Unholy)
                spell = {91342,63560},
                minLevel = 60,
                unit = "pet",
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
            ["6-8621f38d-1"] = {   -- Necrotic Plague (Talent)
                spell = 155159,
                minLevel = 100,
                auraType = "debuff",
                unit = "target",
                talent = {
                    tier = 7,
                    ID = 21207,
                    mustHave = true,
                },
                order = 1,
            },
            ["6-a4a87f4c-1"] = {   -- Blood Plague
                spell = 55078,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                talent = {
                    tier = 7,
                    ID = 21207,
                    mustHave = false,
                },
                order = 1,
            },
            ["6-ac6e45ce-1"] = {   -- Frost Fever
                spell = 55095,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                talent = {
                    tier = 7,
                    ID = 21207,
                    mustHave = false,
                },
                order = 2,
            },
        -- Free Player Auras
            ["6-8f813ae5-1"] = {   -- Crimson Scourge (Blood)
                spell = 81141,
                minLevel = 55,
                specs = {true, false, false},
            },
            ["6-b6cce35c-1"] = {   -- Scent of Blood (Blood)
                spell = 50421,
                minLevel = 62,
                specs = {true, false, false},
            },
            ["6-986c8a80-1"] = {   -- Dancing Rune Weapon (Blood)
                spell = 81256,
                minLevel = 74,
                specs = {true, false, false},
            },
            ["6-80713fed-1"] = {   -- Vampiric Blood (Blood)
                spell = 55233,
                minLevel = 76,
                specs = {true, false, false},
            },
            ["6-9dae73fe-1"] = {   -- Freezing Fog (Frost)
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
            ["6-8ea694c4-1"] = {   -- Sudden Doom (Unholy)
                spell = 81340,
                minLevel = 64,
                specs = {false, false, true},
            },
            ["6-8c2b1f08-1"] = {   -- Lichborne (Talent)
                spell = 49039,
                minLevel = 57,
                talent = {
                    tier = 2,
                    ID = 19218,
                    mustHave = true,
                },
            },
            ["6-8281137d-1"] = {   -- Death's Advance (Talent)
                spell = 96268,
                minLevel = 58,
                talent = {
                    tier = 3,
                    ID = 19221,
                    mustHave = true,
                },
            },
            ["6-ac02f3e2-1"] = {   -- Blood Tap (Talent)
                spell = 114851,  -- Blood Charge
                minLevel = 60,
                talent = {
                    tier = 4,
                    ID = 19224,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(45529),
            },
            ["6-9334862e-1"] = {spell = 48792},    -- Icebound Fortitude
            ["6-a543932b-1"] = {spell = 48707},    -- Anti-Magic Shell
        -- Free Target Auras
    },

    ["DRUID"] = {
        -- Static Player Auras
            ["11-b0d10e92-1"] = {   -- Savage Roar (Feral)
                spell = {52610, 174544}, -- Normal, Glyph
                minLevel = 18,
                specs = {false, true, false, false},
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = SavageRoar
                }
            },
            ["11-86ed5897-1"] = {   -- Savage Defense (Guardian)
                spell = 132402,
                minLevel = 10,
                specs = {false, false, true, false},
                order = 1,
            },
            ["11-a18c4f9e-1"] = {   -- Harmony (Resto Mastery) gained by casting direct heals
                spell = 100977,
                minLevel = 80,
                specs = {false, false, false, true},
                order = 1,
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
                spell = 152221,
                minLevel = 100,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false, false},
                talent = {
                    tier = 7,
                    ID = 21193,
                    mustHave = true,
                },
                order = 3,
            },
            ["11-931a3a8f-1"] = {   -- Rake (Feral)
                spell = 155722,
                minLevel = 10,
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
                minLevel = 100,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false},
                talent = {
                    tier = 7,
                    ID = 21646,
                    mustHave = true,
                },
                order = 3,
                customName = _G.GetSpellInfo(155580),
            },
            ["11-9d6059d3-1"] = {   -- Thrash (Guardian)
                spell = 77758,
                minLevel = 14,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true, false},
                order = 1,
            },
            ["11-a774b290-1"] = {   -- Lacerate (Guardian)
                spell = 33745,
                minLevel = 38,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true, false},
                order = 2,
            },
        -- Free Player Auras
            ["11-a5b3eaa4-1"] = {   -- Lunar/Solar Peak (Balance)
                spell = {171743,171744},
                minLevel = 10,
                specs = {true, false, false, false}
            },
            ["11-9baa529a-1"] = {   -- Lunar Empowerment (Balance)
                spell = 164547,
                minLevel = 12,
                specs = {true, false, false, false}
            },
            ["11-94516e94-1"] = {   -- Solar Empowerment (Balance)
                spell = 164545,
                minLevel = 12,
                specs = {true, false, false, false}
            },
            ["11-a14ea115-1"] = {   -- Celestial Alignment (Balance)
                spell = 112071,
                minLevel = 58,
                specs = {true, false, false, false}
            },
            ["11-bb1a6cfe-1"] = {   -- Tiger's Fury (Feral)
                spell = 5217,
                minLevel = 10,
                specs = {false, true, false, false}
            },
            ["11-b0d536fe-1"] = {   -- Predatory Swiftness (Feral)
                spell = 69369,
                minLevel = 26,
                specs = {false, true, false, false}
            },
            ["11-b2007cb7-1"] = {   -- Berserk (Feral, Guardian)
                spell = {106951, 50334},
                minLevel = 48,
                specs = {false, true, true, false}
            },
            ["11-942ab297-1"] = {   -- Survival Instincts (Feral, Guardian)
                spell = 61336,
                minLevel = 56,
                specs = {false, true, true, false}
            },
            ["11-b3c84eed-1"] = {   -- Barkskin (Guardian)
                spell = 22812,
                minLevel = 44,
                specs = {false, false, true, false}
            },
            ["11-9924d77d-1"] = {   -- Tooth and Claw (Guardian)
                spell = 135286,
                minLevel = 32,
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
                minLevel = 60,
                specs = {true, false, false, false},
                talent = {
                    tier = 4,
                    ID = 18579,
                    mustHave = true,
                },
            },
            ["11-87d1164a-1"] = {   -- Incarnation: King of the Jungle (Talent) (Feral)
                spell = 102543,
                minLevel = 60,
                specs = {false, true, false, false},
                talent = {
                    tier = 4,
                    ID = 21705,
                    mustHave = true,
                },
            },
            ["11-827cfea6-1"] = {   -- Bloodtalons (Talent) (Feral)
                spell = 145152,
                minLevel = 100,
                specs = {false, true, false, false},
                talent = {
                    tier = 7,
                    ID = 21649,
                    mustHave = true,
                },
            },
            ["11-aa9fcbad-1"] = {   -- Incarnation: Son of Ursoc (Talent) (Guardian)
                spell = 102558,
                minLevel = 60,
                specs = {false, false, true, false},
                talent = {
                    tier = 4,
                    ID = 21706,
                    mustHave = true,
                },
            },
            ["11-b409da56-1"] = {   -- Dream of Cenarius (Talent) (Guardian)
                spell = 145162,
                minLevel = 90,
                specs = {false, false, true, false},
                talent = {
                    tier = 6,
                    ID = 21712,
                    mustHave = true,
                },
                hideStacks = true,
            },
            ["11-bb237125-1"] = {   -- Pulverize (Talent) (Guardian)
                spell = 158792,
                minLevel = 14,
                specs = {false, false, true, false},
                talent = {
                    tier = 7,
                    ID = 21650,
                    mustHave = true,
                },
            },
            ["11-bb4c75ca-1"] = {   -- Soul of the Forest (Talent) (Resto)
                spell = 114108,
                minLevel = 60,
                specs = {false, false, false, true},
                talent = {
                    tier = 4,
                    ID = 21704,
                    mustHave = true,
                },
            },
            ["11-a121bb73-1"] = {   -- Incarnation: Tree of Life (Talent) (Resto)
                spell = 117679,
                minLevel = 60,
                specs = {false, false, false, true},
                talent = {
                    tier = 4,
                    ID = 21707,
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
            ["11-91db07fb-1"] = {   -- Faerie Fire (Feral, Guardian)
                spell = 770,
                minLevel = 28,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, true, false}
            },
    },

    ["HUNTER"] = {
        -- Static Player Auras
            ["3-8998954e-1"] = {   -- Frenzy (BM)
                spell = 19615,
                minLevel = 30,
                unit = "pet",
                specs = {true, false, false},
                order = 1,
            },
            ["3-9298993d-1"] = {   -- Focus Fire (BM)
                spell = 82692,
                minLevel = 30,
                specs = {true, false, false},
                order = 2,
            },
            ["3-81e273d4-1"] = {   -- Sniper Training (MM)
                spell = 168811,
                minLevel = 80,
                specs = {false, true, false},
                order = 1,
            },
            ["3-9e5da04c-1"] = {   -- Lock and Load (SV)
                spell = 168980,
                minLevel = 43,
                specs = {false, false, true},
                order = 1,
            },
            ["3-ad43391a-1"] = {   -- Steady Focus (Talent)
                spell = 177668,
                minLevel = 60,
                talent = {
                    tier = 4,
                    ID = 19352,
                    mustHave = true,
                },
                order = 3,
            },
        -- Static Target Auras
            ["3-bb365636-1"] = {   -- Serpent Sting (SV)
                spell = 118253,
                minLevel = 68,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
        -- Free Player Auras
            ["3-a280664b-1"] = {   -- Beast Cleave (BM)
                spell = 118455,
                minLevel = 24,
                unit = "pet",
                specs = {true, false, false}
            },
            ["3-9a8eacb4-1"] = {   -- Bestial Wrath (BM)
                spell = 19574,
                minLevel = 40,
                specs = {true, false, false}
            },
            ["3-a08d9a86-1"] = {   -- Rapid Fire (MM)
                spell = 3045,
                minLevel = 68,
                specs = {false, true, false}
            },
            ["3-9bd8be3e-1"] = {   -- Thrill of the Hunt (Talent)
                spell = 34720,
                minLevel = 60,
                talent = {
                    tier = 4,
                    ID = 19365,
                    mustHave = true,
                },
            },
            ["3-9bca201a-1"] = {spell = 19263},   -- Deterrence
            ["3-ad25aea5-1"] = {spell = 54216},   -- Master's Call
            ["3-b228dae3-1"] = {spell = 53480},   -- Roar of Sacrifice (Cunning)
        -- Free Target Auras
            ["3-ae78fcd9-1"] = {   -- Black Arrow (SV)
                spell = 3674,
                minLevel = 68,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true}
            },
            ["3-afe5d9ac-1"] = {   -- Explosive Shot (SV)
                spell = 53301,
                minLevel = 68,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true}
            },
            ["3-bc4972cd-1"] = {   -- Explosive Trap
                spell = 13812,
                minLevel = 38,
                auraType = "debuff",
                unit = "target",
            },
            ["3-a0d6a726-1"] = {   -- A Murder of Crows (Talent)
                spell = 131894,
                minLevel = 75,
                auraType = "debuff",
                unit = "target",
                talent = {
                    tier = 5,
                    ID = 19360,
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
            ["8-aeb77dff-1"] = {   -- Arcane Charge (Arcane)
                spell = {48108, 36032},
                minLevel = 10,
                auraType = "debuff",
                specs = {true, false, false},
                order = 2,
            },
            ["8-9f01a933-1"] = {   -- Fingers of Frost (Frost)
                spell = 44544,
                minLevel = 12,
                specs = {false, false, true},
                order = 1,
            },
            ["8-8ab5ea50-1"] = {   -- Rune of Power (Talent)
                spell = 116014,
                minLevel = 90,
                talent = {
                    tier = 6,
                    ID = 16032,
                    mustHave = true,
                },
                order = 3,
            },
        -- Static Target Auras
            ["8-89b90044-1"] = {   -- Nether Tempest (Talent) (Arcane)
                spell = 114923,
                minLevel = 75,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                talent = {
                    tier = 5,
                    ID = 19299,
                    mustHave = true,
                },
                order = 3,
            },
            ["8-bc5837f7-1"] = {   -- Mastery: Ignite (Fire)
                spell = 12654,
                minLevel = 12,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 1,
            },
            ["8-bf27cce4-1"] = {   -- Pyroblast (Fire)
                spell = 11366,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 2,
            },
            ["8-8864aa74-1"] = {   -- Living Bomb
                spell = 44457,
                minLevel = 75,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                talent = {
                    tier = 5,
                    ID = 21690,
                    mustHave = true,
                },
                order = 3,
            },
        -- Free Player Auras
            ["8-95ae39d1-1"] = {   -- Presence of Mind (Arcane)
                spell = 12043,
                minLevel = 22,
                specs = {true, false, false},
            },
            ["8-bf568893-1"] = {   -- Arcane Power (Arcane)
                spell = 12042,
                minLevel = 62,
                specs = {true, false, false},
            },
            ["8-a3050e9c-1"] = {   -- Heating Up (Fire)
                spell = 48107,
                minLevel = 10,
                specs = {false, true, false},
            },
            ["8-a0b8d817-1"] = {   -- Pyroblast! (Fire)
                spell = 48108,
                minLevel = 10,
                specs = {false, true, false},
                customIcon = [[Interface\Icons\Spell_Fire_Fireball02]]
            },
            ["8-be277caf-1"] = {   -- Icy Veins (Frost)
                spell = 12472,
                minLevel = 36,
                specs = {false, false, true},
            },
            ["8-84e5eb74-1"] = {   -- Brain Freeze (Frost)
                spell = 57761,
                minLevel = 77,
                specs = {false, false, true},
            },
            ["8-ba699a82-1"] = {   -- Ice Block
                spell = 45438,
                minLevel = 15,
            },
            ["8-93a9a908-1"] = {   -- Invisibility
                spell = 32612,
                minLevel = 56,
                talent = {
                    tier = 4,
                    ID = 16027,
                    mustHave = false,
                },
            },
            ["8-83a223f0-1"] = {   -- Blazing Speed (Talent)
                spell = 108843,
                minLevel = 15,
                talent = {
                    tier = 1,
                    ID = 16012,
                    mustHave = true,
                },
            },
            ["8-817ae191-1"] = {   -- Ice Floes (Talent)
                spell = 108839,
                minLevel = 15,
                talent = {
                    tier = 1,
                    ID = 16013,
                    mustHave = true,
                },
            },
            ["8-97643e93-1"] = {   -- Alter Time (Talent)
                spell = 110909,
                minLevel = 30,
                talent = {
                    tier = 2,
                    ID = 16023,
                    mustHave = true,
                },
            },
            ["8-86dc5f08-1"] = {   -- Ice Ward (Talent)
                spell = 111264,
                minLevel = 45,
                talent = {
                    tier = 3,
                    ID = 16020,
                    mustHave = true,
                },
            },
            ["8-b3901232-1"] = {   -- Greater Invisibility (Talent)
                spell = 113862,
                minLevel = 60,
                talent = {
                    tier = 4,
                    ID = 16027,
                    mustHave = true,
                },
            },
            ["8-b1d9be24-1"] = {   -- Mirror Image (Talent)
                spell = 55342,
                minLevel = 90,
                talent = {
                    tier = 6,
                    ID = 16031,
                    mustHave = true,
                },
                eventUpdate = {
                    event = "COMBAT_LOG_EVENT_UNFILTERED",
                    func = MirrorImage
                },
            },
            ["8-bcbae5c4-1"] = {   -- Incanter's Flow (Talent)
                spell = {156150, 116267},
                minLevel = 90,
                talent = {
                    tier = 6,
                    ID = 16033,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(116267),
                eventUpdate = {
                    event = "UNIT_AURA",
                    func = IncantersFlow
                },
            },
        -- Free Target Auras
            ["8-a297de89-1"] = {   -- Frostbolt (Frost)
                spell = 116,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["8-a34a80e5-1"] = {   -- Frostfire Bolt (Frost)
                spell = 44614,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["8-a0ef0e74-1"] = {   -- Frost Bomb (Frost)
                spell = 112948,
                minLevel = 75,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                talent = {
                    tier = 5,
                    ID = 21691,
                    mustHave = true,
                },
            },
    },

    ["MONK"] = {
        -- Static Player Auras
            ["10-a53c4a0d-1"] = {   -- Shuffle (Brewmaster)
                spell = 115307,
                minLevel = 10,
                specs = {true, false, false},
                order = 1,
            },
            ["10-b95a8d44-1"] = {   -- Elusive Brew (Brewmaster)
                spell = {115308,128939}, -- Effect buff, Stacking buff
                minLevel = 10,
                specs = {true, false, false},
                order = 2,
            },
            ["10-88e98dfb-1"] = {   -- Vital Mists (Mistweaver)
                spell = 118674,
                minLevel = 10,
                specs = {false, true, false},
                order = 1,
            },
            ["10-9500074b-1"] = {   -- Crane's Zeal (Mistweaver)
                spell = 127722,
                minLevel = 10,
                specs = {false, true, false},
                order = 2,
            },
            ["10-b87137e0-1"] = {   -- Tigereye Brew (Windwalker)
                spell = {116740,125195}, -- Effect buff, Stacking buff
                minLevel = 56,
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
            ["10-83b91fd2-1"] = {   -- Rising Sun Kick (Windwalker)
                spell = 130320,
                minLevel = 56,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, true},
                order = 1,
            },
        -- Free Player Auras
            ["10-9cc09bbe-1"] = {   -- Guard (Brewmaster)
                spell = 115295,
                minLevel = 26,
                specs = {true, false, false},
            },
            ["10-9b76a592-1"] = {   -- Mana Tea (Mistweaver)
                spell = 115867,
                minLevel = 56,
                specs = {false, true, false},
            },
            ["10-8cf143c1-1"] = {   -- Touch of Karma (Windwalker)
                spell = 125174,
                minLevel = 22,
                specs = {false, false, true},
            },
            ["10-a42fc1fd-1"] = {   -- Energizing Brew (Windwalker)
                spell = 115288,
                minLevel = 36,
                specs = {false, false, true},
            },
            ["10-862a1e93-1"] = {spell = 125359},   -- Tiger Power
            ["10-a84fc108-1"] = {spell = 120954},   -- Fortifying Brew

            ["10-8975b89c-1"] = {   -- Zen Sphere (Talent)
                spell = 124081,
                minLevel = 30,
                talent = {
                    tier = 2,
                    ID = 19820,
                    mustHave = true,
                },
            },
            ["10-8082e169-1"] = {   -- Power Strikes (Talent)
                spell = 129914,
                minLevel = 45,
                talent = {
                    tier = 3,
                    ID = 19992,
                    mustHave = true,
                },
                eventUpdate = {
                    event = "UNIT_AURA",
                    func = PowerStrikes
                },
            },
            ["10-871ccaed-1"] = {   -- Dampen Harm (Talent)
                spell = 122278,
                minLevel = 75,
                talent = {
                    tier = 5,
                    ID = 20175,
                    mustHave = true,
                },
            },
            ["10-9372460a-1"] = {   -- Diffuse Magic (Talent)
                spell = 122783,
                minLevel = 75,
                talent = {
                    tier = 5,
                    ID = 20173,
                    mustHave = true,
                },
            },
            ["10-ab86d9e3-1"] = {   -- Serenity (Talent)
                spell = 152173,
                minLevel = 100,
                talent = {
                    tier = 7,
                    ID = 21191,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["10-b561c6be-1"] = { -- Mortal Wounds
                spell = 115804,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["PALADIN"] = {
        -- Static Player Auras
            ["2-aaddc099-1"] = {   -- Daybreak (Holy)
                spell = 88819,
                specs = {true, false, false},
                order = 1,
            },
            ["2-bc41e225-1"] = {   -- Infusion of Light (Holy)
                spell = 54149,
                specs = {true, false, false},
                order = 2,
            },
            ["2-8f8a7deb-1"] = {   -- Enhanced Holy Shock (Holy)
                spell = 160002,
                specs = {true, false, false},
                order = 3,
            },
            ["2-96a15d91-1"] = {   -- Bastion of Glory (Prot)
                spell = 114637,
                specs = {false, true, false},
                order = 1,
            },
            ["2-b2420e4c-1"] = {   -- Shield of the Righteous (Prot)
                spell = 132403,
                specs = {false, true, false},
                order = 2,
            },
            ["2-bdba8989-1"] = {   -- Avenging Wrath (Ret)
                spell = 31884,
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
        -- Free Player Auras
            ["2-a0c9223c-1"] = {   -- Avenging Wrath (Holy)
                spell = 31842,
                specs = {true, false, false},
            },
            ["2-a73a3586-1"] = {   -- Ardent Defender (Prot)
                spell = 31850,
                specs = {false, true, false},
            },
            ["2-b6ea7743-1"] = {   -- Grand Crusader (Prot)
                spell = 85416,
                specs = {false, true, false},
            },
            ["2-be248ad3-1"] = {   -- Guardian of Ancient Kings (Prot)
                spell = 86659,
                specs = {false, true, false},
            },
            ["2-901cef84-1"] = {   -- Divine Crusader (Ret)
                spell = 144595,
                specs = {false, false, true},
            },
            ["2-93d2a558-1"] = {   -- Selfless Healer (Talent)
                spell = 114250,
                minLevel = 45,
                talent = {
                    tier = 3,
                    ID = 17581,
                    mustHave = true,
                },
            },
            ["2-8942b773-1"] = {   -- Sacred Shield (Talent)
                spell = {20925, 148039}, -- Holy, Prot/Ret
                minLevel = 45,
                talent = {
                    tier = 3,
                    ID = {21810,21811,21811}, -- Holy, Prot, Ret
                    mustHave = true,
                },
            },
            ["2-9434af38-1"] = {   -- Holy Avenger (Talent)
                spell = 105809,
                minLevel = 75,
                talent = {
                    tier = 5,
                    ID = 17597,
                    mustHave = true,
                },
            },
            ["2-ab20fc1d-1"] = {   -- Divine Purpose (Talent)
                spell = 90174,
                minLevel = 75,
                talent = {
                    tier = 5,
                    ID = 17601,
                    mustHave = true,
                },
            },
            ["2-bb656491-1"] = {   -- Seraphim (Talent) (Prot, Ret)
                spell = 152262,
                minLevel = 100,
                specs = {false, true, true},
                talent = {
                    tier = 7,
                    ID = 21202,
                    mustHave = true,
                },
            },
            ["2-919f1d2c-1"] = {   -- Final Verdict (Talent) (Ret)
                spell = 157048,
                minLevel = 100,
                specs = {false, false, true},
                talent = {
                    tier = 7,
                    ID = 21672,
                    mustHave = true,
                },
            },
            ["2-bb2a51e1-1"] = {spell = 498},   -- Divine Protection
        -- Free Target Auras
    },

    ["PRIEST"] = {
        -- Static Player Auras
            ["5-9678bff1-1"] = {   -- Evangelism (Disc)
                spell = 81661,
                minLevel = 44,
                specs = {true, false, false},
                order = 1,
            },
            ["5-80ee0623-1"] = {   -- Borrowed Time (Disc)
                spell = 59889,
                minLevel = 62,
                specs = {true, false, false},
                order = 2,
            },
            ["5-b917679d-1"] = {   -- Serendipity (Holy)
                spell = 63735,
                minLevel = 34,
                specs = {false, true, false},
                order = 1,
            },
        -- Static Target Auras
            ["5-9ee1ee3e-1"] = {   -- Shadow Word:Pain (Shadow)
                spell = 589,
                minLevel = 3,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                talent = {
                    tier = 7,
                    ID = 21637,
                    mustHave = false,
                },
                order = 1,
            },
            ["5-a3ca1f76-1"] = {   -- Vampiric Touch (Shadow)
                spell = 34914,
                minLevel = 28,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                talent = {
                    tier = 7,
                    ID = 21637,
                    mustHave = false,
                },
                order = 2,
            },
            ["5-b1df8034-1"] = {   -- Devouring Plague (Shadow)
                spell = 158831,
                minLevel = 21,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 3,
            },
            ["5-9f2335ea-1"] = {   -- Void Entropy (Shadow)
                spell = 155361,
                minLevel = 100,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                talent = {
                    tier = 7,
                    ID = 21644,
                    mustHave = true,
                },
                order = 4,
            },
        -- Free Player Auras
            ["5-8636c202-1"] = {   -- Archangel (Disc)
                spell = 81700,
                minLevel = 44,
                specs = {true, false, false},
            },
            ["5-aaf9a60f-1"] = {   -- Dispersion (Shadow)
                spell = 47585,
                minLevel = 60,
                specs = {false, false, true},
            },
            ["5-9e14c42b-1"] = {   -- Vampiric Embrace (Shadow)
                spell = 15286,
                minLevel = 78,
                specs = {false, false, true},
            },
            ["5-b255a230-1"] = {   -- Spectral Guise (Talent)
                spell = 119032,
                minLevel = 15,
                talent = {
                    tier = 1,
                    ID = 19753,
                    mustHave = true,
                },
            },
            ["5-ab8e3ab7-1"] = {   -- Surge of Light (Talent) (Disc, Holy)
                spell = 114255,
                minLevel = 45,
                specs = {true, true, false},
                talent = {
                    tier = 3,
                    ID = {19759, 21750},
                    mustHave = true,
                },
            },
            ["5-86b717fe-1"] = {   -- Surge of Darkness (Talent) (Shadow)
                spell = 87160,
                minLevel = 45,
                specs = {false, false, true},
                talent = {
                    tier = 3,
                    ID = 21751,
                    mustHave = true,
                },
            },
            ["5-90be0e2a-1"] = {   -- Insanity (Talent) (Shadow)
                spell = 114255,
                minLevel = 45,
                specs = {false, false, true},
                talent = {
                    tier = 3,
                    ID = {19759, 21750},
                    mustHave = true,
                },
            },
            ["5-8ead482d-1"] = {   -- Power Infusion (Talent)
                spell = 10060,
                minLevel = 75,
                talent = {
                    tier = 5,
                    ID = 19765,
                    mustHave = true,
                },
            },
            ["5-a4b0b5d4-1"] = {   -- Divine Insight (Talent) (Holy)
                spell = 123267,
                minLevel = 75,
                specs = {false, true, false},
                talent = {
                    tier = 5,
                    ID = 19766,
                    mustHave = true,
                },
            },
            ["5-817d87de-1"] = {   -- Shadowy Insight (Talent) (Shadow)
                spell = 124430,
                minLevel = 75,
                specs = {false, false, true},
                talent = {
                    tier = 5,
                    ID = 21755,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["5-a88338ed-1"] = {   -- Holy Fire (Disc, Holy)
                spell = 14914,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
            },
    },

    ["ROGUE"] = {
        -- Static Player Auras
            ["4-b590c8e6-1"] = {   -- Envenom (Assas)
                spell = 32645,
                minLevel = 20,
                specs = {true, false, false},
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = Envenom
                }
            },
            ["4-a4347749-1"] = {   -- Slice and Dice (Outlaw, Sub)
                spell = 5171,
                minLevel = 14,
                specs = {false, true, true}, -- Passive for Assas via Dreanor Perk
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = SliceAndDice
                }
            },
            ["4-b8faafc6-1"] = {   -- Bandit's Guile (Outlaw)
                spell = {84745, 84746, 84747}, -- Shallow, Moderate, Deep Insight
                minLevel = 60,
                specs = {false, true, false},
                order = 2,
                customName = _G.GetSpellInfo(84654),
                eventUpdate = {
                    event = "COMBAT_LOG_EVENT_UNFILTERED",
                    func = BanditsGuile
                }
            },
            ["4-a5abd891-1"] = {   -- Shadow Dance (Sub)
                spell = 51713,
                specs = {false, false, true},
                order = 2,
            },
        -- Static Target Auras
            ["4-b2b390d7-1"] = {   -- Rupture (Assas, Outlaw)
                spell = 1943,
                minLevel = 46,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
                order = 1,
                eventUpdate = {
                    event = "UNIT_POWER_FREQUENT",
                    func = Rupture
                }
            },
            ["4-ac22ce84-1"] = {   -- Revealing Strike (Outlaw)
                spell = 84617,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 2,
            },
            ["4-8301b93a-1"] = {   -- Find Weakness (Sub)
                spell = 91021,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
        -- Free Player Auras
            ["4-b697e402-1"] = {   -- Blindside (Assas)
                spell = 121153,
                specs = {true, false, false},
            },
            ["4-bf8be102-1"] = {   -- Adrenaline Rush (Outlaw)
                spell = {13750},
                specs = {false, true, false},
            },
            ["4-9040a7b9-1"] = {   -- Blade Flurry (Outlaw)
                spell = 13877,
                specs = {false, true, false},
            },
            ["4-9f580e91-1"] = {   -- Master of Subtlety (Sub)
                spell = {31665, 31666, 31223},
                specs = {false, false, true},
            },
            ["4-82cf4c29-1"] = {   -- Subterfuge (Talent)
                spell = 115192,
                minLevel = 15,
                talent = {
                    tier = 1,
                    ID = 19234,
                    mustHave = true,
                },
            },
            ["4-b7bc86f8-1"] = {   -- Combat Readiness (Talent)
                spell = 74002,
                minLevel = 30,
                talent = {
                    tier = 2,
                    ID = 19238,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(74001),
            },
            ["4-a758c6b8-1"] = {   -- Cheat Death (Talent)
                spell = 45182,
                minLevel = 45,
                talent = {
                    tier = 3,
                    ID = 19239,
                    mustHave = true,
                },
                customName = _G.GetSpellInfo(31230),
            },
            ["4-a758d1b3-1"] = {   -- Shadow Reflection (Talent)
                spell = 152151,
                minLevel = 100,
                talent = {
                    tier = 7,
                    ID = 21187,
                    mustHave = true,
                },
                eventUpdate = {
                    event = "COMBAT_LOG_EVENT_UNFILTERED",
                    func = ShadowReflection
                }
            },
            ["4-bcbb4a21-1"] = {spell = 73651},    -- Recuperate
            ["4-9f332190-1"] = {spell = 5277},     -- Evasion
            ["4-851514ee-1"] = {spell = 31224},    -- Cloak of Shadows
            ["4-80b0f420-1"] = {spell = {11327,115193}},    -- Vanish
            ["4-a0c86712-1"] = {spell = 1966},     -- Feint
        -- Free Target Auras
            ["4-8c6900cc-1"] = {   -- Vendetta (Assas)
                spell = 79140,
                minLevel = 80,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
            },
            ["4-9b960b7a-1"] = {   -- Hemorrhage (Sub)
                spell = 16511,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["4-8856069f-1"] = {   -- Garrote
                spell = 703,
                minLevel = 48,
                auraType = "debuff",
                unit = "target",
            },
            ["4-b4b6abe1-1"] = {   -- Nerve Strike
                spell = 108210,
                minLevel = 30,
                auraType = "debuff",
                unit = "target",
                talent = {
                    tier = 2,
                    ID = 19237,
                    mustHave = true,
                },
            },
    },

    ["SHAMAN"] = {
        -- Static Player Auras
            ["7-8065f89b-1"] = {   -- Lightning Shield (Ele)
                spell = 324,
                minLevel = 8,
                specs = {true, false, false},
                order = 1,
            },
            ["7-98774f14-1"] = {   -- Maelstrom Weapon (Enh)
                spell = 53817,
                minLevel = 50,
                specs = {false, true, false},
                order = 1,
            },
            ["7-a7dc8a98-1"] = {   -- Tidal Waves (Resto)
                spell = 53390,
                minLevel = 50,
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
            ["7-8ef35823-1"] = {   -- Flame Shock (Ele, Enh)
                spell = 8050,
                minLevel = 12,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
                order = 1,
            },
            ["7-bd97988f-1"] = {   -- Frost Shock (Enh)
                spell = 8056,
                minLevel = 22,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 2,
            },
        -- Free Player Auras
            ["7-8ffd47c0-1"] = {   -- Spirit Walk (Enh)
                spell = 58875,
                minLevel = 60,
                specs = {false, true, false},
            },
            ["7-80768995-1"] = {   -- Unleash Flame (Enh)
                spell = 73683,
                minLevel = 81,
                specs = {false, true, false},
            },
            ["7-93c0c50d-1"] = {   -- Unleash Wind (Enh)
                spell = 73681,
                minLevel = 81,
                specs = {false, true, false},
            },
            ["7-b7881104-1"] = {   -- Shamanistic Rage (Ele, Enh)
                spell = 30823,
                minLevel = 65,
                specs = {true, true, false},
            },
            ["7-9725fc0f-1"] = {   -- Spiritwalker's Grace (Ele, Resto)
                spell = 79206,
                minLevel = 85,
                specs = {true, false, true},
            },
            ["7-b2a0a61d-1"] = {   -- Ascendance
                spell = {114050, 114051, 114052},
                minLevel = 87,
            },
            ["7-b44b958f-1"] = {   -- Astral Shift (Talent)
                spell = 108271,
                minLevel = 15,
                talent = {
                    tier = 1,
                    ID = 19264,
                    mustHave = true,
                },
            },
            ["7-b5ebf41b-1"] = {   -- Elemental Mastery (Talent)
                spell = 16166,
                minLevel = 60,
                talent = {
                    tier = 4,
                    ID = 19271,
                    mustHave = true,
                },
            },
            ["7-80da6a44-1"] = {   -- Ancestral Guidance (Talent)
                spell = 108281,
                minLevel = 75,
                talent = {
                    tier = 5,
                    ID = 19269,
                    mustHave = true,
                },
            },
            ["7-b9209d3d-1"] = {   -- Elemental Blast (Talent)
                spell = {118522, 173183, 173184, 173185, 173186, 173187}, -- Crit, Haste, Mast, Mult, Agi, Spirit
                minLevel = 90,
                talent = {
                    tier = 6,
                    ID = 19267,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["7-9f7d9c17-1"] = {   -- Flame Shock (Resto)
                spell = 8050,
                minLevel = 12,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["7-be08b458-1"] = {   -- Stormstrike
                spell = 17364,
                minLevel = 26,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["WARLOCK"] = {
        -- Static Player Auras
            ["9-a8874fa3-1"] = {   -- Soulburn: Haunt (Aff)
                spell = 157698,
                minLevel = 100,
                specs = {true, false, false},
                talent = {
                    tier = 7,
                    ID = 21180,
                    mustHave = true,
                },
                order = 1,
                customName = _G.GetSpellInfo(152109),
            },
            ["9-9f916aed-1"] = {   -- Molten Core (Demo)
                spell = {140074, 122355}, -- Green Fire, Normal
                minLevel = 69,
                specs = {false, true, false},
                order = 1,
            },
        -- Static Target Auras
            ["9-9d46aea7-1"] = {   -- Agony (Aff)
                spell = 980,
                minLevel = 36,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 1,
            },
            ["9-be413012-1"] = {   -- Corruption (Aff, Demo)
                spell = 146739,
                minLevel = 3,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
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
                minLevel = 36,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 3,
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
            ["9-82ad155e-1"] = {   -- Dark Soul: Misery (Aff)
                spell = 113860,
                minLevel = 84,
                specs = {true, false, false},
            },
            ["9-8ef292f7-1"] = {   -- Dark Soul: Knowledge (Demo)
                spell = 113861,
                minLevel = 84,
                specs = {false, true, false},
            },
            ["9-87bd1ea8-1"] = {   -- Dark Soul: Instability (Destro)
                spell = 113858,
                minLevel = 84,
                specs = {false, false, true},
            },
            ["9-911df4e4-1"] = {   -- Dark Regeneration (Talent)
                spell = 108359,
                minLevel = 15,
                talent = {
                    tier = 1,
                    ID = 19279,
                    mustHave = true,
                },
            },
            ["9-bd74da2c-1"] = {   -- Dark Bargain (Talent)
                spell = 110913,
                minLevel = 45,
                talent = {
                    tier = 3,
                    ID = 19289,
                    mustHave = true,
                },
            },
            ["9-89e46112-1"] = {   -- Demonbolt (Talent) (Demo)
                spell = 157695,
                minLevel = 100,
                auraType = "debuff",
                specs = {false, true, false},
                talent = {
                    tier = 7,
                    ID = 21694,
                    mustHave = true,
                },
            },
            ["9-bb5f0433-1"] = {spell = 88448},    -- Demonic Rebirth
            ["9-9e083577-1"] = {spell = 104773},   -- Unending Resolve
        -- Free Target Auras
            ["9-8072e1ae-1"] = {   -- Haunt (Aff)
                spell = 48181,
                minLevel = 60,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
            },
            ["9-869d9949-1"] = {   -- Seed of Corruption (Aff)
                spell = 27243,
                minLevel = 21,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
            },
            ["9-bfee421b-1"] = {   -- Hand of Gul'dan (Demo)
                spell = 47960,
                minLevel = 19,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
            },
            ["9-81347abb-1"] = {   -- Conflagrate (Destro)
                spell = 17962,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["9-858bed5f-1"] = {   -- Havoc (Destro)
                spell = 80240,
                minLevel = 36,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["9-bc1debbb-1"] = {   -- Shadowburn (Destro)
                spell = 17877,
                minLevel = 47,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
    },

    ["WARRIOR"] = {
        -- Static Player Auras
            ["1-be149d0a-1"] = {   -- Enrage (Fury)
                spell = 12880,
                minLevel = 14,
                specs = {false, true, false},
                order = 1,
            },
            ["1-88616b14-1"] = {   -- Raging Blow! (Fury)
                spell = 131116,
                minLevel = 30,
                specs = {false, true, false},
                order = 2,
            },
            ["1-8d6897d2-1"] = {   -- Shield Block, Shield Charge (Prot)
                spell = {132404, 169667},
                minLevel = 18,
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
            ["1-9256f2b1-1"] = {   -- Rend (Arms)
                spell = 772,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 1,
            },
        -- Free Player Auras
            ["1-9ca47424-1"] = {   -- Die by the Sword (Arms, Fury)
                spell = 118038,
                minLevel = 56,
                specs = {true, true, false},
            },
            ["1-95b80fdf-1"] = {   -- Recklessness (Arms, Fury)
                spell = 1719,
                minLevel = 87,
                specs = {true, true, false},
            },
            ["1-9d8e1b35-1"] = {   -- Bloodsurge (Fury)
                spell = 46916,
                minLevel = 10,
                specs = {false, true, false},
            },
            ["1-8c2242a0-1"] = {   -- Meat Cleaver (Fury)
                spell = 85739,
                minLevel = 58,
                specs = {false, true, false},
            },
            ["1-bf917422-1"] = {   -- Enrage (Prot)
                spell = 12880,
                minLevel = 14,
                specs = {false, false, true},
            },
            ["1-8ede1252-1"] = {   -- Ultimatum (Prot)
                spell = 122510,
                minLevel = 10,
                specs = {false, false, true},
            },
            ["1-bb0caec6-1"] = {   -- Sword and Board (Prot)
                spell = 50227,
                minLevel = 10,
                specs = {false, false, true},
            },
            ["1-bc105857-1"] = {   -- Shield Wall (Prot)
                spell = 871,
                minLevel = 48,
                specs = {false, false, true},
            },
            ["1-ae88cb34-1"] = {   -- Last Stand (Prot)
                spell = 12975,
                minLevel = 38,
                specs = {false, false, true},
            },
            ["1-bb6869cd-1"] = {spell = 18499},    -- Berserker Rage
            ["1-af01758e-1"] = {spell = {23920, 114028}},    -- Spell Reflection
            
            ["1-849c1974-1"] = {   -- Enraged Regeneration (Talent)
                spell = 55694,
                minLevel = 30,
                talent = {
                    tier = 2,
                    ID = 16036,
                    mustHave = true,
                },
            },
            ["1-9b003d2d-1"] = {   -- Sudden Death (Talent)
                spell = 52437,
                minLevel = 45,
                talent = {
                    tier = 3,
                    ID = 15769,
                    mustHave = true,
                },
            },
            ["1-a216ed2a-1"] = {   -- Unyielding Strikes (Talent) (Prot)
                spell = 169686,
                minLevel = 45,
                specs = {false, false, true},
                talent = {
                    tier = 3,
                    ID = 21792,
                    mustHave = true,
                },
            },
            ["1-bc751f32-1"] = {   -- Avatar (Talent)
                spell = 107574,
                minLevel = 90,
                talent = {
                    tier = 6,
                    ID = 19138,
                    mustHave = true,
                },
            },
            ["1-a26f3820-1"] = {   -- Bloodbath (Talent)
                spell = 12292,
                minLevel = 90,
                talent = {
                    tier = 6,
                    ID = 19139,
                    mustHave = true,
                },
            },
            ["1-b8a217f8-1"] = {   -- Bladestorm (Talent)
                spell = 46924,
                minLevel = 90,
                talent = {
                    tier = 6,
                    ID = 19140,
                    mustHave = true,
                },
            },
        -- Free Target Auras
            ["1-bbd999f7-1"] = {   -- Colossus Smash (Arms)
                spell = 167105,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
            },
            ["1-96c7609f-1"] = {   -- Demoralizing Shout
                spell = 1160,
                auraType = "debuff",
                unit = "target",
            },
            ["1-80e6917a-1"] = {   -- Hamstring
                spell = 1715,
                auraType = "debuff",
                unit = "target",
            },
            ["1-b9d2c83a-1"] = {   -- Mortal Strike
                spell = 12294,
                auraType = "debuff",
                unit = "target",
            },
            ["1-803da340-1"] = {   -- Shattering Throw
                spell = 64382,
                auraType = "debuff",
                unit = "target",
            },
            ["1-a17f11f4-1"] = {   -- Pummel
                spell = 6552,
                auraType = "debuff",
                unit = "target",
            },
    },
}

else

--[[ Retired IDs
]]

classDefaults = {
    ["DEATHKNIGHT"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["DEMONHUNTER"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["DRUID"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["HUNTER"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["MAGE"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["MONK"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["PALADIN"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["PRIEST"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["ROGUE"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["SHAMAN"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["WARLOCK"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },

    ["WARRIOR"] = {
        -- Static Player Auras
        -- Static Target Auras
        -- Free Player Auras
        -- Free Target Auras
    },
}

end
