-- Lua Globals --
local _G = _G
local next, type = _G.next, _G.type

-- WoW Globals --
local UnitPower = _G.UnitPower

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L

local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")

local SavageRoar, WildMushrooms
local BanditsGuile, Rupture, SliceAndDice
local BurningEmbers
if nibRealUI.class == "DRUID" then
    do -- SavageRoar
        -- Shows predicted buff duration based on current CPs.
        function SavageRoar(self, spellData)
        end
    end
    do -- WildMushrooms
        -- Shows predicted debuff duration based on current CPs.
        function WildMushrooms(self, spellData)
        end
    end
elseif nibRealUI.class == "ROGUE" then
    local function predictDuration(tracker, gap, base, max)
        local comboPoints = UnitPower("player", _G.SPELL_POWER_COMBO_POINTS)

        if (comboPoints > 0) then
            local potential = base + ((comboPoints - 1) * gap)
            tracker.count:SetText(potential)
            if potential == max then
                tracker.count:SetTextColor(0, 1, 0)
            else
                tracker.count:SetTextColor(1, 1, 1)
            end
        else
            tracker.count:SetText("")
        end
    end

    do -- BanditsGuile
        -- Shows how many Sinister Strikes hit since the last BG upgrade or reset.
        local SinisterStrikeID = 1752
        local swingCount = 0
        local bgSpellIDs = {
            [84745] = true, -- Shallow Insight
            [84746] = true, -- Moderate Insight
            [84747] = true  -- Deep Insight
        }

        function BanditsGuile(self, ...)
            local _, subEvent, _, srcGUID, _,_,_,_,_,_,_, spellID = ...
            if (srcGUID ~= AuraTracking.playerGUID) then return end

            if (subEvent == "SPELL_DAMAGE") and (spellID == SinisterStrikeID) then
                swingCount = swingCount + 1
                self.count:SetText(swingCount)

            elseif ((subEvent == "SPELL_AURA_REMOVED") or (subEvent == "SPELL_AURA_APPLIED")) and (bgSpellIDs[spellID]) then
                swingCount = 0
                self.count:SetText("")
            end
        end
    end
    do -- Rupture
        -- Shows predicted debuff duration based on current CPs.
        function Rupture(self, spellData)
            predictDuration(self, 4, 8, 24)
        end
    end
    do -- SliceAndDice
        -- Shows predicted buff duration based on current CPs.
        function SliceAndDice(self, spellData)
            predictDuration(self, 6, 12, 36)
        end
    end
elseif nibRealUI.class == "WARLOCK" then
    do -- BurningEmbers
        -- Shows predicted buff duration based on current CPs.
        function BurningEmbers(self, spellData)
        end
    end
end

local defaultTracker = {
    spell = L["AuraTrack_SpellNameID"],
    minLevel = 1,
    auraType = "buff", -- buff|debuff
    unit = "player", -- player|target|pet
    specs = {true, true, true, GetSpecializationInfo(4) and true}, -- {spec1, spec2, spec3[, spec4]}
    talent = {},
    order = 0, -- Tracker will be static if greater than 0
    hideOOC = false, -- hide out-of-combat even if active
    hideTime = false, -- hide timer text
    hideStacks = false, -- hide stack count (useful for auras with a passive 1 stack)
    ignoreRaven = false, -- don't add this aura to Raven's filter lists
    shouldLoad = true,
    debug = false
}

AuraTracking.Defaults = {
    ["DEATHKNIGHT"] = {
        ["**"] = defaultTracker,
        -- Static Player Auras
            ["6-b6cce35c-1"] = {   -- Scent of Blood (Blood)
                spell = 50421,
                minLevel = 62,
                specs = {true, false, false},
                order = 1,
            },
            ["6-987a58fe-1"] = {   -- Blood Shield (Blood)
                spell = 77535,
                minLevel = 80,
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
                auraType = "debuff",
                unit = "target",
                talent = {[7] = {21207}},
                order = 1,
            },
            ["6-a4a87f4c-1"] = {   -- Blood Plague
                spell = 55078,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                talent = {[7] = {21208, 21209}},
                order = 1,
            },
            ["6-ac6e45ce-1"] = {   -- Frost Fever
                spell = 55095,
                minLevel = 55,
                auraType = "debuff",
                unit = "target",
                talent = {[7] = {21208, 21209}},
                order = 2,
            },
        -- Free Player Auras
            ["6-8f813ae5-1"] = {   -- Crimson Scourge (Blood)
                spell = 81141,
                specs = {true, false, false},
            },
            ["6-80713fed-1"] = {   -- Vampiric Blood (Blood)
                spell = 55233,
                specs = {true, false, false},
            },
            ["6-986c8a80-1"] = {   -- Dancing Rune Weapon (Blood)
                spell = 81256,
                specs = {true, false, false},
            },
            ["6-9eeb4ba5-1"] = {   -- Bone Shield (Blood)
                spell = 49222,
                specs = {true, false, false},
            },
            ["6-a27ed53e-1"] = {   -- Killing Machine (Frost)
                spell = 51124,
                specs = {false, true, false},
            },
            ["6-9af9ad7e-1"] = {   -- Pillar of Frost (Frost)
                spell = 51271,
                specs = {false, true, false},
            },
            ["6-9dae73fe-1"] = {   -- Freezing Fog (Frost, from Rime)
                spell = 59052,
                specs = {false, true, false},
            },
            ["6-8ea694c4-1"] = {   -- Sudden Doom (Unholy)
                spell = 81340,
                specs = {false, false, true},
            },
            ["6-9334862e-1"] = {spell = 48792},    -- Icebound Fortitude
            ["6-827cfea6-1"] = {spell = 22744},    -- Chains of Ice
            ["6-a543932b-1"] = {spell = 48707},    -- Anti-Magic Shell
            ["6-8c2b1f08-1"] = {spell = 49039},    -- Lichborne (Talent)
            ["6-83cbafac-1"] = {spell = 50461},    -- Anti-Magic Zone (Talent)
            ["6-8281137d-1"] = {spell = 96268},    -- Death's Advance (Talent)
            ["6-ac02f3e2-1"] = {spell = 114851},   -- Blood Charge (used for Blood Tap, Talent)
        -- Free Target Auras
    },

    ["DRUID"] = {
        ["**"] = defaultTracker,
        -- Static Player Auras
            ["11-b0d10e92-1"] = {   -- Savage Roar (Feral)
                type = "SavageRoar",
                order = 1,
            },
            ["11-86ed5897-1"] = {   -- Savage Defense (Guardian)
                spell = 62606,
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
            ["11-aa0bdedd-1"] = {   -- Wild Mushrooms (Resto)
                type = "WildMushrooms",
                order = 2,
            },
        -- Static Target Auras
            ["11-bbefa72d-1"] = {   -- Sunfire (Balance)
                spell = 164815,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false, false},
                order = 1,
            },
            ["11-b1a3a3b5-1"] = {   -- Moonfire (Balance)
                spell = 164812,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false, false},
                order = 2,
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
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false},
                order = 2,
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
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true, false},
                order = 2,
            },
        -- Free Player Auras
            ["11-9baa529a-1"] = {   -- Lunar/Solar Empowerment (Balance)
                spell = {164547,164545},
                specs = {true, false, false, false}
            },
            ["11-a5b3eaa4-1"] = {   -- Lunar/Solar Peak (Balance)
                spell = {171743,171744},
                specs = {true, false, false, false}
            },
            ["11-a14ea115-1"] = {   -- Celestial Alignment (Balance)
                spell = 112071,
                specs = {true, false, false, false}
            },
            ["11-a9a4c453-1"] = {   -- Incarnation: Chosen of Elune (Talent, Balance)
                spell = 102560,
                specs = {true, false, false, false}
            },
            ["11-b0d536fe-1"] = {   -- Predatory Swiftness (Feral)
                spell = 69369,
                specs = {false, true, false, false}
            },
            ["11-bb1a6cfe-1"] = {   -- Tiger's Fury (Feral)
                spell = 5217,
                specs = {false, true, false, false}
            },
            ["11-b3c84eed-1"] = {   -- Barkskin (Guardian)
                spell = 22812,
                specs = {false, false, true, false}
            },
            ["11-9924d77d-1"] = {   -- Tooth and Claw (Guardian)
                spell = 135286,
                specs = {false, false, true, false}
            },
            ["11-942ab297-1"] = {   -- Survival Instincts (Guardian)
                spell = 50322,
                specs = {false, false, true, false}
            },
            ["11-bb237125-1"] = {   -- Pulverize (Talent, Guardian)
                spell = 158792,
                specs = {false, false, true, false}
            },
            ["11-9ee9dd75-1"] = {   -- Clearcasting (Resto)
                spell = 16870,
                specs = {false, false, false, true}
            },
            ["11-9a94211a-1"] = {spell = 5211},     -- Dash
            ["11-94516e94-1"] = {spell = 33831},    -- Force of Nature (Talent)
        -- Free Target Auras
            ["11-ac72ea83-1"] = {   -- Lacerate (Feral)
                spell = 33745,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false}
            },
            ["11-a6d635ba-1"] = {   -- Thrash (Feral)
                spell = 106830,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false}
            },
            ["11-b5e260cc-1"] = {   -- Maim (Feral)
                spell = 22570,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false, false}
            },
            ["11-91db07fb-1"] = {   -- Faerie Fire (Feral, Guardian)
                spell = 770,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, true, false}
            },
            ["11-87d1164a-1"] = {   -- Infected Wounds (Feral, Guardian)
                spell = 58180,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, true, false}
            },
            ["11-b2007cb7-1"] = {   -- Berserk (Feral, Guardian)
                spell = 50334,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, true, false}
            },
    },

    ["HUNTER"] = {
        ["**"] = defaultTracker,
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
                order = 1,
            },
            ["3-81e273d4-1"] = {   -- Sniper Training (MM)
                spell = 168811,
                minLevel = 80,
                specs = {false, true, false},
                order = 1,
                hideOOC = true,
            },
            ["3-9e5da04c-1"] = {   -- Lock and Load (SV)
                spell = 168980,
                minLevel = 43,
                specs = {false, false, true},
                order = 1,
            },
            ["3-ad43391a-1"] = {   -- Steady Focus (Talent)
                spell = 177668,
                order = 2,
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
                unit = "pet",
                specs = {true, false, false}
            },
            ["3-9a8eacb4-1"] = {   -- Bestial Wrath (BM)
                spell = 19574,
                specs = {true, false, false}
            },
            ["3-a08d9a86-1"] = {   -- Rapid Fire (MM)
                spell = 3045,
                specs = {false, true, false}
            },
            ["3-9bca201a-1"] = {spell = 19263},   -- Deterrence
            ["3-89b90044-1"] = {spell = 51755},   -- Camouflage
            ["3-ad25aea5-1"] = {spell = 54216},   -- Master's Call
            ["3-b228dae3-1"] = {spell = 53480},   -- Roar of Sacrifice (Cunning)
            ["3-9bd8be3e-1"] = {spell = 34720},   -- Thrill of the Hunt (Talent)
        -- Free Target Auras
            ["3-ae78fcd9-1"] = {   -- Black Arrow (SV)
                spell = 3674,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true}
            },
            ["3-afe5d9ac-1"] = {   -- Explosive Shot (SV)
                spell = 53301,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true}
            },
            ["3-bc4972cd-1"] = {   -- Explosive Trap
                spell = 13812,
                auraType = "debuff",
                unit = "target",
            },
            ["3-ba699a82-1"] = {   -- Freezing Trap
                spell = 3355,
                auraType = "debuff",
                unit = "target",
            },
            ["3-a0b8d817-1"] = {   -- Ice Trap
                spell = 13810,
                auraType = "debuff",
                unit = "target",
            },
            ["3-a0d6a726-1"] = {   -- A Murder of Crows (Talent)
                spell = 131894,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["MAGE"] = {
        ["**"] = defaultTracker,
        -- Static Player Auras
            ["8-860b9d97-1"] = {   -- Arcane Missiles! (Arcane)
                spell = 79683,
                minLevel = 24,
                specs = {true, false, false},
                order = 1,
            },
            ["8-aeb77dff-1"] = {   -- Arcane Charge (Arcane)
                spell = 36032,
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
        -- Static Target Auras
            ["8-bc5837f7-1"] = {   -- Ignite (Fire)
                spell = 12654,
                minLevel = 12,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 1,
            },
            ["8-bf27cce4-1"] = {   -- Pyroblast (Fire)
                spell = 11366,
                auraType = "debuff",
                unit = "target",
                specs = {false, true, false},
                order = 2,
            },
        -- Free Player Auras
            ["8-bf568893-1"] = {   -- Arcane Power (Arcane)
                spell = 12042,
                specs = {true, false, false},
            },
            ["8-95ae39d1-1"] = {   -- Presence of Mind (Arcane)
                spell = 12043,
                specs = {true, false, false},
            },
            ["8-93a9a908-1"] = {   -- Evocation (Arcane)
                spell = 12051,
                specs = {true, false, false},
            },
            ["8-a3050e9c-1"] = {   -- Pyroblast!, Heating Up (Fire)
                spell = {48108,48107},
                specs = {false, true, false},
            },
            ["8-be277caf-1"] = {   -- Icy Veins (Frost)
                spell = 12472,
                specs = {false, false, true},
            },
            ["8-84e5eb74-1"] = {   -- Brain Freeze (Frost)
                spell = 57761,
                specs = {false, false, true},
            },
            ["8-b1d9be24-1"] = {spell = 55342},    -- Mirror Image
            ["8-83a223f0-1"] = {spell = 108843},   -- Blazing Speed (Talent)
            ["8-817ae191-1"] = {spell = 108839},   -- Ice Floes (Talent)
            ["8-97643e93-1"] = {spell = 110909},   -- Alter Time (Talent)
            ["8-86dc5f08-1"] = {spell = 111264},   -- Ice Ward (Talent)
            ["8-8ab5ea50-1"] = {spell = 116014},   -- Rune of Power (Talent)
            ["8-bcbae5c4-1"] = {spell = 116267},   -- Incanter's Flow (Talent)
            ["8-b3901232-1"] = {spell = {32612,113862}},   -- Invisibility, Greater Invisibility (Talent)
        -- Free Target Auras
            ["8-a0ef0e74-1"] = {   -- Slow
                spell = 31589,
                auraType = "debuff",
                unit = "target",
            },
            ["8-a297de89-1"] = {   -- Frostbolt
                spell = 116,
                auraType = "debuff",
                unit = "target",
            },
            ["8-a34a80e5-1"] = {   -- Frostfire Bolt
                spell = 44614,
                auraType = "debuff",
                unit = "target",
            },
            ["8-8864aa74-1"] = {   -- Living Bomb
                spell = 44457,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["MONK"] = {
        ["**"] = defaultTracker,
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
                specs = {true, false, false},
            },
            ["10-8cf143c1-1"] = {   -- Touch of Karma (Windwalker)
                spell = 125174,
                specs = {false, false, true},
            },
            ["10-a42fc1fd-1"] = {   -- Energizing Brew (Windwalker)
                spell = 115288,
                specs = {false, false, true},
            },
            ["10-9b76a592-1"] = {   -- Mana Tea (Mistweaver)
                spell = 115294,
                specs = {false, true, false},
            },
            ["10-862a1e93-1"] = {spell = 125359},   -- Tiger Power
            ["10-a84fc108-1"] = {spell = 120954},   -- Fortifying Brew
            ["10-9372460a-1"] = {spell = 122783},   -- Diffuse Magic (Talent)
            ["10-871ccaed-1"] = {spell = 122278},   -- Dampen Harm (Talent)
            ["10-8082e169-1"] = {spell = 116841},   -- Tiger's Lust (Talent)
            ["10-ab86d9e3-1"] = {spell = 152173},   -- Serenity (Talent)
        -- Free Target Auras
            ["10-b561c6be-1"] = { -- Mortal Wounds
                spell = 115804,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["PALADIN"] = {
        ["**"] = defaultTracker,
        -- Static Player Auras
            ["2-bdba8989-1"] = {   -- Avenging Wrath (Ret)
                spell = 31884,
                specs = {false, false, true},
                order = 1,
            },
        -- Static Target Auras
        -- Free Player Auras
            ["2-a0c9223c-1"] = {   -- Avenging Wrath (Holy, Prot)
                spell = 31884,
                specs = {true, true, false},
            },
            ["2-bb2a51e1-1"] = {spell = 498},      -- Divine Protection
            ["2-9434af38-1"] = {spell = 105809},   -- Holy Avenger
            ["2-be248ad3-1"] = {spell = 86659},    -- Guardian
            ["2-aaddc099-1"] = {spell = 1044},     -- Hand of Freedom
            ["2-bc41e225-1"] = {spell = 1022},     -- Hand of Protection
            ["2-96a15d91-1"] = {spell = 6940},     -- Hand of Sacrifice
            ["2-bb656491-1"] = {spell = 1038},     -- Hand of Salvation
            ["2-b6ea7743-1"] = {spell = 642},      -- Divine Shield
            ["2-8942b773-1"] = {spell = 20925},    -- Holy Shield
            ["2-b2420e4c-1"] = {spell = 31842},    -- Divine Favor
            ["2-ab20fc1d-1"] = {spell = 114039},   -- Hand of Purity
            ["2-8f8a7deb-1"] = {spell = 31821},    -- Devotion Aura
            ["2-93d2a558-1"] = {spell = 53563},    -- Beacon of Light
            ["2-9ab78043-1"] = {spell = 85499},    -- Speed of Light
            ["2-a73a3586-1"] = {spell = 31850},    -- Ardent Defender
        -- Free Target Auras
            ["2-901cef84-1"] = {   -- Avenger's Shield
                spell = 31935,
                auraType = "debuff",
                unit = "target",
            },
            ["2-857dac62-1"] = {   -- Concecration
                spell = 26573,
                auraType = "debuff",
                unit = "target",
            },
            ["2-919f1d2c-1"] = {   -- Censure
                spell = 31803,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["PRIEST"] = {
        ["**"] = defaultTracker,
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
            ["5-a3ca1f76-1"] = {   -- Vampiric Touch (Shadow)
                spell = 34914,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
                order = 1,
            },
            ["5-9ee1ee3e-1"] = {   -- SW:P (Shadow)
                spell = 589,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
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
        -- Free Player Auras
            ["5-a4b0b5d4-1"] = {spell = 109964},   -- Spirit Shell
            ["5-aaf9a60f-1"] = {spell = 47585},    -- Dispersion
            ["5-9e14c42b-1"] = {spell = 15286},    -- Vampiric Embrace
            ["5-90be0e2a-1"] = {spell = 33206},    -- Pain Suppression
            ["5-8ead482d-1"] = {spell = 10060},    -- Power Infusion
            ["5-817d87de-1"] = {spell = 47788},    -- Guardian Spirit
            ["5-9f2335ea-1"] = {spell = 62618},    -- Power Word: Barrier
            ["5-99868b0a-1"] = {spell = 6346},     -- Fear Ward
            ["5-ab8e3ab7-1"] = {spell = 114239},   -- Phantasm
            ["5-b255a230-1"] = {spell = 119032},   -- Spectral Guise
            ["5-8636c202-1"] = {spell = 27827},    -- Spirit of Redemption
        -- Free Target Auras
            ["5-a88338ed-1"] = {   -- Holy Fire
                spell = 14914,
                auraType = "debuff",
                unit = "target",
                },
            ["5-86b717fe-1"] = {   -- Psychic Horror
                spell = 64044,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["ROGUE"] = {
        ["**"] = defaultTracker,
        -- Static Player Auras
            ["4-a4347749-1"] = {   -- Slice and Dice (Combat, Sub)
                spell = 5171,
                minLevel = 14,
                specs = {true, false, true}, -- Passive for Assas via Dreanor Perk
                order = 1,
                postUnitAura = SliceAndDice
            },
            ["4-b590c8e6-1"] = {   -- Envenom (Ass)
                spell = 32645,
                specs = {true, false, false},
                order = 1,
            },
            ["4-b8faafc6-1"] = {   -- Bandit's Guile (Combat)
                spell = {84745, 84746, 84747}, -- Shallow, Moderate, Deep Insight
                minLevel = 60,
                specs = {false, true, false},
                order = 2,
                customName = _G.GetSpellInfo(84654),
                combatUpdate = BanditsGuile
            },
            ["4-a5abd891-1"] = {   -- Shadow Dance (Sub)
                spell = 51713,
                specs = {false, false, true},
                order = 2,
            },
        -- Static Target Auras
            ["4-b2b390d7-1"] = {   -- Rupture (Combat)
                spell = 1943,
                minLevel = 46,
                specs = {true, false, false}, -- Passive for Assas via Dreanor Perk
                order = 1,
                postUnitAura = Rupture
            },
            ["4-ac22ce84-1"] = {   -- Revealing Strike (Comb)
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
                order = 2,
            },
        -- Free Player Auras
            ["4-bcbb4a21-1"] = {spell = 73651},    -- Recuperate
            ["4-bd56d2d6-1"] = {spell = 108212},   -- Burst of Speed
            ["4-bf8be102-1"] = {spell = 13750},    -- Adrenaline Rush
            ["4-9040a7b9-1"] = {spell = 13877},    -- Blade Flurry
            ["4-965917ad-1"] = {spell = 2983},     -- Sprint
            ["4-9f332190-1"] = {spell = 5277},     -- Evasion
            ["4-82cf4c29-1"] = {spell = 108208},   -- Subterfuge
            ["4-b697e402-1"] = {spell = 121153},   -- Blindside
            ["4-a5bdd6b2-1"] = {spell = 57933},    -- TotT
            ["4-9f580e91-1"] = {spell = 31223},    -- Master of Subtlety
            ["4-851514ee-1"] = {spell = 31224},    -- Cloak of Shadows
            ["4-a758c6b8-1"] = {spell = 45182},    -- Cheating Death
            ["4-a758d1b3-1"] = {spell = 114018},   -- Shroud of Concealment
            ["4-80b0f420-1"] = {spell = 11327},    -- Vanish
            ["4-a45b83a3-1"] = {spell = 137619},   -- Marked for Death
            ["4-a0c86712-1"] = {spell = 1966},     -- Feint
            ["4-b7bc86f8-1"] = {spell = 74002},    -- Combat Insight
        -- Free Target Auras
            ["4-9b960b7a-1"] = {   -- Hemorrhage
                spell = 16511,
                auraType = "debuff",
                unit = "target",
            },
            ["4-8c6900cc-1"] = {   -- Vendetta
                spell = 79140,
                auraType = "debuff",
                unit = "target",
            },
            ["4-8856069f-1"] = {   -- Garrote
                spell = 703,
                auraType = "debuff",
                unit = "target",
            },
            ["4-b4b6abe1-1"] = {   -- Nerve Strike
                spell = 108210,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["SHAMAN"] = {
        ["**"] = defaultTracker,
        -- Static Player Auras
            ["7-98774f14-1"] = {   -- Maelstrom Weapon (Enh)
                spell = 65986,
                minLevel = 83,
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
            ["7-8ef35823-1"] = {   -- Flame Shock (Enh, Ele)
                spell = 8050,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
                order = 1,
            },
            ["7-bd97988f-1"] = {   -- Frost Shock (Enh, Ele)
                spell = 8056,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
                order = 2,
            },
        -- Free Player Auras
            ["7-8065f89b-1"] = {   -- Lightning Shield (Ele) (Fulmination)
                spell = 324,
                minLevel = 20,
                specs = {true, false, false},
                hideOOC = true,
            },
            ["7-b7881104-1"] = {spell = 30823},    -- Shamanistic Rage
            ["7-80768995-1"] = {spell = 73683},    -- Unleash Flame
            ["7-93c0c50d-1"] = {spell = 73681},    -- Unleash Wind
            ["7-9725fc0f-1"] = {spell = 79206},    -- Spiritwalker's Grace
            ["7-8975b89c-1"] = {spell = 61295},    -- Riptide
            ["7-a121bb73-1"] = {spell = 98007},    -- Spirit Link Totem
            ["7-b44b958f-1"] = {spell = 108271},   -- Astral Shift
            ["7-bb4c75ca-1"] = {spell = 16188},    -- Ancestral Swiftness
            ["7-b409da56-1"] = {spell = 2825},     -- Bloodlust
            ["7-a8874fa3-1"] = {spell = 8178},     -- Grounding Totem Effect
            ["7-8ffd47c0-1"] = {spell = 58875},    -- Spirit Walk
            ["7-80da6a44-1"] = {spell = 108281},   -- Ancestral Guidance
            ["7-b5ebf41b-1"] = {spell = 16166},    -- Elemental Mastery (talent)
            ["7-b9209d3d-1"] = {spell = 114896},   -- Windwalk Totem
            ["7-b2a0a61d-1"] = {spell = 114049},   -- Ascendance
        -- Free Target Auras
            ["7-9f7d9c17-1"] = {   -- Flame Shock (Resto)
                spell = 8050,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["7-803045b0-1"] = {   -- Frost Shock (Resto)
                spell = 8056,
                auraType = "debuff",
                unit = "target",
                specs = {false, false, true},
            },
            ["7-be08b458-1"] = {   -- Stormstrike
                spell = 17364,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["WARLOCK"] = {
        ["**"] = defaultTracker,
        -- Static Player Auras
            ["9-9f916aed-1"] = {   -- Molten Core (Demo)
                spell = {140074, 122355}, -- Green Fire, Normal
                minLevel = 69,
                specs = {false, true, false},
                order = 1,
            },
            ["9-a6a32ca3-1"] = {   -- Burning Embers (Dest)
                type = "BurningEmbers",
                order = 1,
            },
        -- Static Target Auras
            ["9-be413012-1"] = {   -- Corruption (Aff, Demo)
                spell = 146739,
                minLevel = 3,
                auraType = "debuff",
                unit = "target",
                specs = {true, true, false},
                order = 1,
            },
            ["9-bcf57e20-1"] = {   -- Unstable Affliction (Aff)
                spell = 30108,
                minLevel = 10,
                auraType = "debuff",
                unit = "target",
                specs = {true, false, false},
                order = 2,
            },
            ["9-9d46aea7-1"] = {   -- Agony, Doom (Aff)
                spell = {980,603},
                minLevel = 36,
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
            ["9-bd74da2c-1"] = {spell = 110913},   -- Dark Bargain
            ["9-911df4e4-1"] = {spell = 108359},   -- Dark Regeneration
            ["9-82ad155e-1"] = {spell = 113860},   -- Dark Soul: Misery
            ["9-8ef292f7-1"] = {spell = 113861},   -- Dark Soul: Knowledge
            ["9-87bd1ea8-1"] = {spell = 113858},   -- Dark Soul: Instability
            ["9-bb5f0433-1"] = {spell = 88448},    -- Demonic Rebirth
            ["9-9e083577-1"] = {spell = 104773},   -- Unending Resolve
        -- Free Target Auras
            ["9-869d9949-1"] = {   -- Seed of Corruption
                spell = 27243,
                auraType = "debuff",
                unit = "target",
            },
            ["9-8072e1ae-1"] = {   -- Haunt
                spell = 48181,
                auraType = "debuff",
                unit = "target",
            },
            ["9-bfee421b-1"] = {   -- Shadowflame
                spell = 80270,
                auraType = "debuff",
                unit = "target",
            },
            ["9-81347abb-1"] = {   -- Conflagrate
                spell = 17962,
                auraType = "debuff",
                unit = "target",
            },
            ["9-858bed5f-1"] = {   -- Havoc
                spell = 80240,
                auraType = "debuff",
                unit = "target",
            },
            ["9-bc1debbb-1"] = {   -- Shadowburn
                spell = 17877,
                auraType = "debuff",
                unit = "target",
            },
            ["9-aa9fcbad-1"] = {   -- Archimonde's Vengeance
                spell = 108505,
                auraType = "debuff",
                unit = "target",
            },
    },

    ["WARRIOR"] = {
        ["**"] = defaultTracker,
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
            ["1-9d8e1b35-1"] = {   -- Bloodsurge (Fury)
                spell = 46916,
                specs = {false, true, false},
            },
            ["1-bf917422-1"] = {   -- Enrage (Prot)
                spell = 12880,
                specs = {false, false, true},
            },
            ["1-8ede1252-1"] = {   -- Ultimatum (Prot)
                spell = 122510,
                specs = {false, false, true},
            },
            ["1-bb0caec6-1"] = {   -- Sword and Board (Prot)
                spell = 50227,
                specs = {false, false, true},
            },
            ["1-9ca47424-1"] = {spell = 118038},   -- Die by the Sword
            ["1-ae88cb34-1"] = {spell = 12975},    -- Last Stand
            ["1-bc105857-1"] = {spell = 871},      -- Shield Wall
            ["1-bb6869cd-1"] = {spell = 18499},    -- Berserker Rage
            ["1-95b80fdf-1"] = {spell = 1719},     -- Recklessness
            ["1-af01758e-1"] = {spell = 23920},    -- Spell Reflection
            ["1-8c2242a0-1"] = {spell = 85739},    -- Meat Cleaver
            
            ["1-849c1974-1"] = {spell = 55694},    -- Enraged Regeneration (Talent)
            ["1-9b003d2d-1"] = {spell = 52437},    -- Sudden Death (Talent)
            ["1-a216ed2a-1"] = {spell = 169686},   -- Unyielding Strikes (Talent)
            ["1-89e46112-1"] = {spell = 114028},   -- Mass Spell Reflection (Talent)
            ["1-bc751f32-1"] = {spell = 107574},   -- Avatar (Talent)
            ["1-a26f3820-1"] = {spell = 12292},    -- Bloodbath (Talent)
            ["1-b8a217f8-1"] = {spell = 46924},    -- Bladestorm (Talent)
        -- Free Target Auras
            ["1-bbd999f7-1"] = {   -- Colossus Smash
                spell = 86346,
                auraType = "debuff",
                unit = "target",
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
