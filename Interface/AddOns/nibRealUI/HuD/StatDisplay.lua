local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, dbc, ndbc

local _
local MODNAME = "StatDisplay"
local StatDisplay = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local strform = string.format
local StatUpdateTimer
local StatFrame = {}

local PercentFormatString = "%.1f%%"
local RoundFormatString = "%.1f"

--[[local Stats = {  --Warlords
    --Primary stats
    [1]  = "Strength",
    [2]  = "Agility",
    [3]  = "Stamina",
    [4]  = "Intellect",

    --Secondary stats
    [5]  = "Haste",
    [6]  = "Crit",
    [7]  = "Mastery",
    [8]  = "Multistrike",
    [9]  = "Versitility",
    [10] = "Bonus_Armor", --Tanks
    [11] = "Spirit", --Healers
    
    --Pysical stats
    [12] = "Melee_AP",
    [13] = "Range_AP",
    [14] = "Dodge",
    [15] = "Parry",
    [16] = "Block",
    [17] = "Total_Armor",

    --Spell stats
    [18] = "Spell_Power",
    [19] = "Combat_Regen",

    --PvP stats
    [20] = "PvP_Resilience",
    [21] = "PvP_Power",
}]]

local convertStat = { --Test prep for Warlords
    ["Melee_Armor_Pen"] = "Melee_Crit",
    ["Range_Armor_Pen"] = "Range_Crit",
}

local Stats = {
    [1]  = "Dodge",
    [2]  = "Parry",
    [3]  = "Block",
    [4]  = "Armor_Defense",
    [5]  = "Defense_Mastery",
    
    [6]  = "Melee_Haste",
    [7]  = "Melee_Hit",
    [8]  = "Melee_AP",
    [9]  = "Melee_Crit",
    [10] = "Expertise",
    [11] = "Weapon_Speed",
    [12] = "Melee_Mastery",
    
    [13] = "Dmg_Reduction",
    [14] = "Total_Resilience",
    [15] = "Total_PvPPower",
    
    [16] = "Range_Haste",
    [17] = "Range_Hit",
    [18] = "Range_AP",
    [19] = "Range_Crit",
    [20] = "Range_Speed",
    [21] = "Range_Mastery",
    
    [22] = "Spell_Power",
    [23] = "Spell_Crit",
    [24] = "Spell_Haste",
    [25] = "Spell_Hit",
    [26] = "MP5",
    [27] = "Spell_Mastery",

    [28] = "Strength",
    [29] = "Agility",
    [30] = "Stamina",
    [31] = "Intellect",
    [32] = "Spirit",
}

local StatIcons = {
    [1] = "DoubleArrow2",
    [2] = "Shield",
    [3] = "Shield",
    [4] = "Shield",
    [5] = "Shield",
    
    [6] = "DoubleArrow2",
    [7] = "Sword",
    [8] = "Sword",
    [9] = "Lightning",
    [10] = "Sword",
    [11] = "DoubleArrow2",
    [12] = "Sword",
    
	[13] = "Shield",
    [14] = "Shield",
    [15] = "Lightning",
    
    [16] = "DoubleArrow2",
    [17] = "Lightning",
    [18] = "Lightning",
    [19] = "Lightning",
    [20] = "DoubleArrow2",
    [21] = "Lightning",
    
    [22] = "Flame",
    [23] = "Lightning",
    [24] = "DoubleArrow2",
    [25] = "Flame",
    [26] = "Flame",
    [27] = "Flame",

    [28] = "PersonPlus",
    [29] = "PersonPlus",
    [30] = "PersonPlus",
    [31] = "PersonPlus",
    [32] = "PersonPlus",
}
local StatTexts = {
    [1] = PLAYERSTAT_DEFENSES..": "..STAT_DODGE,
    [2] = PLAYERSTAT_DEFENSES..": "..STAT_PARRY,
    [3] = PLAYERSTAT_DEFENSES..": "..STAT_BLOCK,
    [4] = PLAYERSTAT_DEFENSES..": "..ARMOR,
    [5] = PLAYERSTAT_DEFENSES..": "..STAT_MASTERY,
    
    [6] = PLAYERSTAT_MELEE_COMBAT..": "..STAT_HASTE,
    [7] = PLAYERSTAT_MELEE_COMBAT..": "..STAT_HIT_CHANCE,
    [8] = PLAYERSTAT_MELEE_COMBAT..": "..STAT_ATTACK_POWER,
    [9] = PLAYERSTAT_MELEE_COMBAT..": "..MELEE_CRIT_CHANCE,
    [10] = PLAYERSTAT_MELEE_COMBAT..": "..STAT_EXPERTISE,
    [11] = PLAYERSTAT_MELEE_COMBAT..": "..WEAPON_SPEED,
    [12] = PLAYERSTAT_MELEE_COMBAT..": "..STAT_MASTERY,
    
    [13] = PVP.." "..COMBAT_TEXT_SHOW_RESISTANCES_TEXT,
    [14] = RESILIENCE,
    [15] = STAT_PVP_POWER,
    
    [16] = PLAYERSTAT_RANGED_COMBAT..": "..STAT_HASTE,
    [17] = PLAYERSTAT_RANGED_COMBAT..": "..STAT_HIT_CHANCE,
    [18] = PLAYERSTAT_RANGED_COMBAT..": "..STAT_ATTACK_POWER,
    [19] = PLAYERSTAT_RANGED_COMBAT..": "..RANGED_CRIT_CHANCE,
    [20] = PLAYERSTAT_RANGED_COMBAT..": "..WEAPON_SPEED,
    [21] = PLAYERSTAT_RANGED_COMBAT..": "..STAT_MASTERY,
    
    [22] = PLAYERSTAT_SPELL_COMBAT..": "..STAT_SPELLPOWER,
    [23] = PLAYERSTAT_SPELL_COMBAT..": "..SPELL_CRIT_CHANCE,
    [24] = PLAYERSTAT_SPELL_COMBAT..": "..STAT_HASTE,
    [25] = PLAYERSTAT_SPELL_COMBAT..": "..STAT_HIT_CHANCE,
    [26] = PLAYERSTAT_SPELL_COMBAT..": "..MANA_REGEN,
    [27] = PLAYERSTAT_SPELL_COMBAT..": "..STAT_MASTERY,

    [28] = SPELL_STAT1_NAME,
    [29] = SPELL_STAT2_NAME,
    [30] = SPELL_STAT3_NAME,
    [31] = SPELL_STAT4_NAME,
    [32] = SPELL_STAT5_NAME,
}

local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Stat Display",
        arg = MODNAME,
        childGroups = "tab",
        order = 1920,
        args = {
            header = {
                type = "header",
                name = "Stat Display",
                order = 10,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Stat Display module.",
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value) 
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                    nibRealUI:ReloadUIDialog()
                end,
                order = 30,
            },
            gap2 = {
                name = " ",
                type = "description",
                order = 51,
            },
            gap3 = {
                name = " ",
                type = "description",
                order = 52,
            },
            primary = {
                type = "group",
                inline = true,
                name = PRIMARY,
                disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
                order = 60,
                args = {
                    stat1 = {
                        type = "select",
                        name = "Stat 1",
                        set = function(info, value)
                            dbc.stats[1][1] = Stats[value]
                            StatDisplay:TalentUpdate()
                        end,
                        style = "dropdown",
                        width = nil,
                        values = StatTexts,
                        order = 10,
                    },
                    stat1name = {
                        name = function()
                            for k,v in pairs(Stats) do
                                if v == dbc.stats[1][1] then
                                    return StatTexts[k]
                                end
                            end
                        end,
                        type = "description",
                        order = 20,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 21,
                    },
                    stat2 = {
                        type = "select",
                        name = "Stat 2",
                        set = function(info, value)
                            dbc.stats[1][2] = Stats[value]
                            StatDisplay:TalentUpdate()
                        end,
                        style = "dropdown",
                        width = nil,
                        values = StatTexts,
                        order = 30,
                    },
                    stat2name = {
                        name = function()
                            for k,v in pairs(Stats) do
                                if v == dbc.stats[1][2] then
                                    return StatTexts[k]
                                end
                            end
                        end,
                        type = "description",
                        order = 40,
                    },
                },
            },
            gap2 = {
                name = " ",
                type = "description",
                order = 61,
            },
            secondary = {
                type = "group",
                inline = true,
                name = SECONDARY,
                disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
                order = 70,
                args = {
                    stat1 = {
                        type = "select",
                        name = "Stat 1",
                        set = function(info, value)
                            dbc.stats[2][1] = Stats[value]
                            StatDisplay:TalentUpdate()
                        end,
                        style = "dropdown",
                        width = nil,
                        values = StatTexts,
                        order = 10,
                    },
                    stat1name = {
                        name = function()
                            for k,v in pairs(Stats) do
                                if v == dbc.stats[2][1] then
                                    return StatTexts[k]
                                end
                            end
                        end,
                        type = "description",
                        order = 20,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 21,
                    },
                    stat2 = {
                        type = "select",
                        name = "Stat 2",
                        set = function(info, value)
                            dbc.stats[2][2] = Stats[value]
                            StatDisplay:TalentUpdate()
                        end,
                        style = "dropdown",
                        width = nil,
                        values = StatTexts,
                        order = 30,
                    },
                    stat2name = {
                        name = function()
                            for k,v in pairs(Stats) do
                                if v == dbc.stats[2][2] then
                                    return StatTexts[k]
                                end
                            end
                        end,
                        type = "description",
                        order = 40,
                    },
                },
            },
        },
    }
    end
    return options
end

local InCombat
local watchedStats = {}
local StatFunc = {}
-----------------
---- Defense ----
-----------------
StatFunc.Dodge = function()
    local Total_Dodge = GetDodgeChance()
    return strform(PercentFormatString, Total_Dodge)
end

StatFunc.Parry = function()
    local Total_Parry = GetParryChance()
    return strform(PercentFormatString, Total_Parry)
end

StatFunc.Block = function()
    local Total_Block = GetBlockChance()
    return strform(PercentFormatString, Total_Block)
end

StatFunc.Armor_Defense = function()
    local base, effectiveArmor, armor, posBuff, negBuff = UnitArmor("player")
    local Melee_Reduction = effectiveArmor
    return nibRealUI:ReadableNumber(Melee_Reduction)
end

StatFunc.Defense_Mastery = function()
    local Total_DM = GetMasteryEffect("player")
    return strform(PercentFormatString, Total_DM)
end

---------------
---- Melee ----
---------------
StatFunc.Melee_Haste = function()
    local Total_Melee_Haste = GetMeleeHaste("player")
    return strform(PercentFormatString, Total_Melee_Haste)
end

StatFunc.Melee_Hit = function()
    local Total_Hit = GetCombatRatingBonus("6")
    return strform(PercentFormatString, Total_Hit)
end

StatFunc.Melee_AP = function()
    local base, posBuff, negBuff = UnitAttackPower("player")
    local Melee_AP = base + posBuff + negBuff
    return nibRealUI:ReadableNumber(Melee_AP)
end

StatFunc.Melee_Crit = function()
    local Melee_Crit = GetCritChance("player")
    return strform(PercentFormatString, Melee_Crit)
end

StatFunc.Expertise = function()
    local Expertise = GetCombatRatingBonus("24")
    return strform(PercentFormatString, Expertise)
end

StatFunc.Melee_Armor_Pen = function()
    local Melee_Armor_Pen = GetCombatRatingBonus("25")
    return strform(PercentFormatString, Melee_Armor_Pen)
end

StatFunc.Weapon_Speed = function()
    local mainSpeed, offSpeed = UnitAttackSpeed("player");
    local MH = mainSpeed
    local OH = offSpeed
    return strform(RoundFormatString, MH)
end

StatFunc.Melee_Mastery = function()
    local Total_MM = GetMasteryEffect("player");
    return strform(PercentFormatString, Total_MM)
end

-------------
---- PvP ----
-------------
StatFunc.Dmg_Reduction = function()
    local PvPDmg = GetCombatRatingBonus("16") + 40
    return strform("-"..PercentFormatString, PvPDmg)
end

StatFunc.Total_Resilience = function()
    local Total_Resil = GetCombatRating("16")
    return nibRealUI:ReadableNumber(Total_Resil)
end

StatFunc.Total_PvPPower = function()
    local PvPPower = GetCombatRatingBonus("27")
    return strform(PercentFormatString, PvPPower)
end

---------------
---- Range ----
---------------
StatFunc.Range_Haste = function()
    local Total_Range_Haste = GetRangedHaste("player")
    return strform(PercentFormatString, Total_Range_Haste)
end

StatFunc.Range_Hit = function()
    local Total_Range_Hit = GetCombatRatingBonus("7")
    return strform(PercentFormatString, Total_Range_Hit)
end

StatFunc.Range_Armor_Pen = function()
    local Range_Armor_Pen = GetCombatRatingBonus("25")
    return strform(PercentFormatString, Range_Armor_Pen)
end

StatFunc.Range_AP = function()
    local base, posBuff, negBuff = UnitRangedAttackPower("player")
    local Range_AP = base + posBuff + negBuff
    return nibRealUI:ReadableNumber(Range_AP)
end

StatFunc.Range_Crit = function()
    local Range_Crit = GetRangedCritChance("25")
    return strform(PercentFormatString, Range_Crit)
end

StatFunc.Range_Speed = function()
    local speed = UnitRangedDamage("player")
    local Total_Range_Speed = speed
    return strform(RoundFormatString, Total_Range_Speed)
end

StatFunc.Range_Mastery = function()
    local Total_RM = GetMasteryEffect("player")
    return strform(PercentFormatString, Total_RM)
end

----------------
---- Spells ----
----------------
StatFunc.Spell_Power = function()
    local SP = GetSpellBonusDamage("2")
    return nibRealUI:ReadableNumber(SP)
end

StatFunc.Spell_Crit = function()
    local SC = GetSpellCritChance("2")
    return strform(PercentFormatString, SC)
end

StatFunc.Spell_Haste = function()
    local Total_Spell_Haste = UnitSpellHaste("player")
    return strform(PercentFormatString, Total_Spell_Haste)
end

StatFunc.Spell_Hit = function()
    local Total_Spell_Hit = GetCombatRatingBonus("8")
    return strform(PercentFormatString, Total_Spell_Hit)
end

StatFunc.MP5 = function()
    local base, casting = GetManaRegen()
    local MP5_1 = (casting * 5)
    return strform("%.0f", MP5_1)
end

StatFunc.Spell_Mastery = function()
    local Total_SM = GetMasteryEffect("player")
    return strform(PercentFormatString, Total_SM)
end

--------------------
---- Base Stats ----
--------------------
StatFunc.Strength = function()
    local _, effectiveStat = UnitStat("player", 1)
    return nibRealUI:ReadableNumber(effectiveStat)
end

StatFunc.Agility = function()
    local _, effectiveStat = UnitStat("player", 2)
    return nibRealUI:ReadableNumber(effectiveStat)
end

StatFunc.Stamina = function()
    local _, effectiveStat = UnitStat("player", 3)
    return nibRealUI:ReadableNumber(effectiveStat)
end

StatFunc.Intellect = function()
    local _, effectiveStat = UnitStat("player", 4)
    return nibRealUI:ReadableNumber(effectiveStat)
end

StatFunc.Spirit = function()
    local _, effectiveStat = UnitStat("player", 5)
    return nibRealUI:ReadableNumber(effectiveStat)
end


------------
local GetStatText
local DefaultStatTypes = {
    Tank = {"Armor_Defense", "Defense_Mastery"},
    Melee = {"Melee_AP", "Melee_Crit"},
    Ranged = {"Range_AP", "Range_Crit"},
    Spell = {"Spell_Power", "Spell_Crit"},
    Heal = {"MP5", "Spell_Mastery"},
}
local DefaultStats = {
    ["DEATHKNIGHT"] = {
        [1] = DefaultStatTypes.Tank,    -- B
        [2] = DefaultStatTypes.Melee,   -- F
        [3] = DefaultStatTypes.Melee,   -- U
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["DRUID"] = {
        [1] = DefaultStatTypes.Spell,   -- B
        [2] = DefaultStatTypes.Melee,   -- F
        [3] = DefaultStatTypes.Tank,    -- G
        [4] = DefaultStatTypes.Heal,    -- R
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["HUNTER"] = {
        [1] = DefaultStatTypes.Ranged,  -- BM
        [2] = DefaultStatTypes.Ranged,  -- MM
        [3] = DefaultStatTypes.Ranged,  -- S
        ["NA"] = DefaultStatTypes.Ranged,
    },
    ["MAGE"] = {
        [1] = DefaultStatTypes.Spell,   -- A
        [2] = DefaultStatTypes.Spell,   -- Fi
        [3] = DefaultStatTypes.Spell,   -- Fr
        ["NA"] = DefaultStatTypes.Spell,
    },
    ["MONK"] = {
        [1] = DefaultStatTypes.Tank,    -- BM
        [2] = DefaultStatTypes.Heal,    -- MW
        [3] = DefaultStatTypes.Melee,   -- WW
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["PALADIN"] = {
        [1] = DefaultStatTypes.Heal,    -- H
        [2] = DefaultStatTypes.Tank,    -- P
        [3] = DefaultStatTypes.Melee,   -- R
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["PRIEST"] = {
        [1] = DefaultStatTypes.Heal,    -- D
        [2] = DefaultStatTypes.Heal,    -- H
        [3] = DefaultStatTypes.Spell,   -- S
        ["NA"] = DefaultStatTypes.Spell,
    },
    ["ROGUE"] = {
        [1] = DefaultStatTypes.Melee,   -- A
        [2] = DefaultStatTypes.Melee,   -- C
        [3] = DefaultStatTypes.Melee,   -- S
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["SHAMAN"] = {
        [1] = DefaultStatTypes.Spell,   -- El
        [2] = DefaultStatTypes.Melee,   -- Enh
        [3] = DefaultStatTypes.Heal,    -- R
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["WARLOCK"] = {
        [1] = DefaultStatTypes.Spell,   -- A
        [2] = DefaultStatTypes.Spell,   -- Dem
        [3] = DefaultStatTypes.Spell,   -- Des
        ["NA"] = DefaultStatTypes.Spell,
    },
    ["WARRIOR"] = {
        [1] = DefaultStatTypes.Melee,   -- A
        [2] = DefaultStatTypes.Melee,   -- F
        [3] = DefaultStatTypes.Tank,    -- P
        ["NA"] = DefaultStatTypes.Melee,
    },
}


local function RefreshStats()
    if GetStatText == nil then
        GetStatText = {
            Dodge               = function() return StatFunc.Dodge() end,
            Parry               = function() return StatFunc.Parry() end,
            Block               = function() return StatFunc.Block() end,
            Armor_Defense       = function() return StatFunc.Armor_Defense() end,
            Defense_Mastery     = function() return StatFunc.Defense_Mastery() end,
            
            Melee_Haste         = function() return StatFunc.Melee_Haste() end,
            Melee_Hit           = function() return StatFunc.Melee_Hit() end,
            Melee_AP            = function() return StatFunc.Melee_AP() end,
            Melee_Crit          = function() return StatFunc.Melee_Crit() end,
            Expertise           = function() return StatFunc.Expertise() end,
            Melee_Armor_Pen     = function() return StatFunc.Melee_Armor_Pen() end,
            Weapon_Speed        = function() return StatFunc.Weapon_Speed() end,
            Melee_Mastery       = function() return StatFunc.Melee_Mastery() end,
            
            Dmg_Reduction       = function() return StatFunc.Dmg_Reduction() end,
            Total_Resilience    = function() return StatFunc.Total_Resilience() end,
            Total_PvPPower      = function() return StatFunc.Total_PvPPower() end,
            
            Range_Haste         = function() return StatFunc.Range_Haste() end,
            Range_Hit           = function() return StatFunc.Range_Hit() end,
            Range_Armor_Pen     = function() return StatFunc.Range_Armor_Pen() end,
            Range_AP            = function() return StatFunc.Range_AP() end,
            Range_Crit          = function() return StatFunc.Range_Crit() end,
            Range_Speed         = function() return StatFunc.Range_Speed() end,
            Range_Mastery       = function() return StatFunc.Range_Mastery() end,
            
            Spell_Power         = function() return StatFunc.Spell_Power() end,
            Spell_Crit          = function() return StatFunc.Spell_Crit() end,
            Spell_Haste         = function() return StatFunc.Spell_Haste() end,
            Spell_Hit           = function() return StatFunc.Spell_Hit() end,
            MP5                 = function() return StatFunc.MP5() end,
            Spell_Mastery       = function() return StatFunc.Spell_Mastery() end,

            Strength            = function() return StatFunc.Strength() end,
            Agility             = function() return StatFunc.Agility() end,
            Stamina             = function() return StatFunc.Stamina() end,
            Intellect           = function() return StatFunc.Intellect() end,
            Spirit              = function() return StatFunc.Spirit() end,
        }
    end
end

----------
-- Misc --
----------
function StatDisplay:GetCharStatTexts()
    local stats = {
        {},
        {},
    }
    for k,v in pairs(Stats) do
        if v == dbc.stats[1][1] then
            stats[1][1] = StatTexts[k]
        end
        if v == dbc.stats[1][2] then
            stats[1][2] = StatTexts[k]
        end
        if v == dbc.stats[2][1] then
            stats[2][1] = StatTexts[k]
        end
        if v == dbc.stats[2][2] then
            stats[2][2] = StatTexts[k]
        end
    end
    return stats
end

function StatDisplay:SetDefaultStats()
    if not dbc.statDefaultsSet[1] then
        local Spec1 = GetSpecialization(false, false, 1) or "NA"
        dbc.stats[1] = DefaultStats[nibRealUI.class][Spec1]
        dbc.statDefaultsSet[1] = true
    end
    if not dbc.statDefaultsSet[2] then
        local Spec2 = GetSpecialization(false, false, 2) or "NA"
        dbc.stats[2] = DefaultStats[nibRealUI.class][Spec2]
        dbc.statDefaultsSet[2] = true
    end
end

------------------
-- Stat Updates --
------------------
local function convert()
    for spec = 1, 2 do
        for stat = 1, 2 do
            if convertStat[dbc.stats[spec][stat]] then 
                dbc.stats[spec][stat] = convertStat[dbc.stats[spec][stat]] 
            end
        end
    end
end

local function SetValues(row, text)
    StatFrame[row].text:SetText(text)
end

local function ToggleRow(row, state)
    StatFrame[row]:SetShown(state)
end

local function GatherStats(stats)
    if GetStatText == nil then
        RefreshStats()
    end
    return {GetStatText[stats[1]](), GetStatText[stats[2]]()}
end

local statVals
function StatDisplay:StatUpdate()
    if not UnitAffectingCombat("player") then
        self:CombatUpdate()
        return
    end
    
    statVals = GatherStats(watchedStats)
    SetValues(1, statVals[1])
    SetValues(2, statVals[2])
end

function StatDisplay:TalentUpdate()
    self:SetDefaultStats()
    local specGroup = GetActiveSpecGroup()
    watchedStats = dbc.stats[specGroup]
    nibRealUI.watchedStats = watchedStats

    for k,v in pairs(Stats) do
        if v == dbc.stats[specGroup][1] then
            StatFrame[1].icon:SetTexture(nibRealUI.media.icons[StatIcons[k]])
        end
        if v == dbc.stats[specGroup][2] then
            StatFrame[2].icon:SetTexture(nibRealUI.media.icons[StatIcons[k]])
        end
    end

    if InCombat then
        self:StatUpdate()
    end
end

function StatDisplay:CombatUpdate()
    convert()
    InCombat = UnitAffectingCombat("player")
    if InCombat then
        self:TalentUpdate()
        self:StatUpdate()
        if not StatUpdateTimer then
            StatUpdateTimer = self:ScheduleRepeatingTimer("StatUpdate", 1)
        end
        ToggleRow(1, true)
        ToggleRow(2, true)
    else
        ToggleRow(1, false)
        ToggleRow(2, false)
        if StatUpdateTimer then
            self:CancelTimer(StatUpdateTimer)
            StatUpdateTimer = nil
        end
    end
end

function StatDisplay:PLAYER_LOGIN()
    if not (RealUIPlayerStat1 and RealUIPlayerStat2) then
        self:UnregisterAllEvents()
        return
    end
    StatFrame[1] = RealUIPlayerStat1
    StatFrame[2] = RealUIPlayerStat2
    self:CombatUpdate()
end

--------------------
-- Options Window --
--------------------
local function stat_initialize(dropdown, level)
    if not level or level == 1 then
        for idx, entry in ipairs(StatTexts) do
            local info = UIDropDownMenu_CreateInfo()
            info.text = entry
            info.value = entry
            info.func = function(frame, ...)
                UIDropDownMenu_SetSelectedValue(dropdown, entry)
                for k,v in pairs(StatTexts) do
                    if v == entry then
                        dbc.stats[dropdown.spec][dropdown.stat] = Stats[k]
                    end
                end
                StatDisplay:TalentUpdate()
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end

function StatDisplay:RefreshOptions()
    local sdO = self.options
    local stats = self:GetCharStatTexts()
    local statKeys = {{},{}}
    for k,v in pairs(Stats) do
        if v == dbc.stats[1][1] then
            statKeys[1][1] = k
        end
        if v == dbc.stats[1][2] then
            statKeys[1][2] = k
        end
        if v == dbc.stats[2][1] then
            statKeys[2][1] = k
        end
        if v == dbc.stats[2][2] then
            statKeys[2][2] = k
        end
    end
    UIDropDownMenu_Initialize(sdO.ddP1, stat_initialize)
    UIDropDownMenu_SetSelectedValue(sdO.ddP1, statKeys[1][1])
    UIDropDownMenu_SetText(sdO.ddP1, stats[1][1])
    UIDropDownMenu_Initialize(sdO.ddP2, stat_initialize)
    UIDropDownMenu_SetSelectedValue(sdO.ddP2, statKeys[1][2])
    UIDropDownMenu_SetText(sdO.ddP2, stats[1][2])
    UIDropDownMenu_Initialize(sdO.ddS1, stat_initialize)
    UIDropDownMenu_SetSelectedValue(sdO.ddS1, statKeys[2][1])
    UIDropDownMenu_SetText(sdO.ddS1, stats[2][1])
    UIDropDownMenu_Initialize(sdO.ddS2, stat_initialize)
    UIDropDownMenu_SetSelectedValue(sdO.ddS2, statKeys[2][2])
    UIDropDownMenu_SetText(sdO.ddS2, stats[2][2])
end

function StatDisplay:CreateOptionsFrame()
    if self.options then return end
    
    self.options = nibRealUI:CreateWindow("RealUIStatDisplayOptions", 456, 128, true)
    local sdO = self.options
        sdO:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
        sdO:Hide()
    
    sdO.okay = nibRealUI:CreateTextButton(OKAY, sdO, 100, 24)
        sdO.okay:SetPoint("BOTTOM", sdO, "BOTTOM", 0, 5)
        sdO.okay:SetScript("OnClick", function() RealUIStatDisplayOptions:Hide() end)
        nibRealUI:CreateBGSection(sdO, sdO.okay, sdO.okay)
    
    -- Header
    local header = nibRealUI:CreateFS(sdO, "CENTER", "small")
        header:SetText("Stat Display")
        header:SetPoint("TOP", sdO, "TOP", 0, -9)
    
    -- Header Primary
    local hP1 = nibRealUI:CreateFS(sdO, "CENTER", "small")
        hP1:SetPoint("TOPLEFT", sdO, "TOPLEFT", 3, -27)
        hP1:SetSize(235, 16)
        hP1:SetText(PRIMARY)
        hP1:SetTextColor(unpack(nibRealUI.classColor))
    
    -- Header Secondary
    local hS1 = nibRealUI:CreateFS(sdO, "CENTER", "small")
        hS1:SetPoint("TOPRIGHT", sdO, "TOPRIGHT", -1, -27)
        hS1:SetSize(235, 16)
        hS1:SetText(SECONDARY)
        hS1:SetTextColor(unpack(nibRealUI.classColor))
    
    -- P1
    sdO.ddP1 = CreateFrame("Frame", "RealUIStatDisplayOptionsPrimary1", sdO, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(sdO.ddP1, 184)
        sdO.ddP1:SetPoint("TOP", hP1, "BOTTOM", 0, 1)
        sdO.ddP1:SetFrameLevel(sdO:GetFrameLevel() + 2)
        sdO.ddP1:SetSize(235, 18)
        sdO.ddP1.spec = 1
        sdO.ddP1.stat = 1
    
    -- P2
    sdO.ddP2 = CreateFrame("Frame", "RealUIStatDisplayOptionsPrimary2", sdO, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(sdO.ddP2, 184)
        sdO.ddP2:SetPoint("TOP", sdO.ddP1, "BOTTOM", 0, 11)
        sdO.ddP2:SetFrameLevel(sdO:GetFrameLevel() + 2)
        sdO.ddP2:SetSize(235, 18)
        sdO.ddP2.spec = 1
        sdO.ddP2.stat = 2
    
    nibRealUI:CreateBGSection(sdO, sdO.ddP1, sdO.ddP2, 14, -2, -16, 6)
    
    -- S1
    sdO.ddS1 = CreateFrame("Frame", "RealUIStatDisplayOptionsSecondary1", sdO, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(sdO.ddS1, 184)
        sdO.ddS1:SetPoint("TOP", hS1, "BOTTOM", 0, 1)
        sdO.ddS1:SetFrameLevel(sdO:GetFrameLevel() + 2)
        sdO.ddS1:SetSize(235, 18)
        sdO.ddS1.spec = 2
        sdO.ddS1.stat = 1
    
    -- S2
    sdO.ddS2 = CreateFrame("Frame", "RealUIStatDisplayOptionsSecondary2", sdO, "UIDropDownMenuTemplate")
        UIDropDownMenu_SetWidth(sdO.ddS2, 184)
        sdO.ddS2:SetPoint("TOP", sdO.ddS1, "BOTTOM", 0, 11)
        sdO.ddS2:SetFrameLevel(sdO:GetFrameLevel() + 2)
        sdO.ddS2:SetSize(235, 18)
        sdO.ddS2.spec = 2
        sdO.ddS2.stat = 2
    
    nibRealUI:CreateBGSection(sdO, sdO.ddS1, sdO.ddS2, 14, -2, -16, 6)

    -- Skin
    if Aurora then
        local F = Aurora[1]
        F.Reskin(sdO.okay)
        F.ReskinDropDown(sdO.ddP1)
        F.ReskinDropDown(sdO.ddP2)
        F.ReskinDropDown(sdO.ddS1)
        F.ReskinDropDown(sdO.ddS2)
    end
    
    sdO:Show()
end

function StatDisplay:ShowOptionsWindow()
    if not StatDisplay.options then self:CreateOptionsFrame() end
    StatDisplay:RefreshOptions()
    StatDisplay.options:Show()
end

----------

function StatDisplay:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        char = {
            statDefaultsSet = {false, false},
            stats = {
                [1] = {},
                [2] = {},
            },
        },
    })
    db = self.db.profile
    dbc = self.db.char
    ndbc = nibRealUI.db.char
    
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterHuDOptions(MODNAME, GetOptions)
end

function StatDisplay:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "TalentUpdate")
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", "TalentUpdate")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "TalentUpdate")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "CombatUpdate")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "CombatUpdate")
end
