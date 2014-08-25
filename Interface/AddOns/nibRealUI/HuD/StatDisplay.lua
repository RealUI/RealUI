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

local Stats = {  --Warlords
    --Attributes
    [1]  = "Strength",
    [2]  = "Agility",
    [3]  = "Stamina",
    [4]  = "Intellect",

    --Enhancments
    [5]  = "Haste",
    [6]  = "Crit",
    [7]  = "Mastery",
    [8]  = "Multistrike",
    [9]  = "Versitility",
    [10] = "Bonus_Armor", --Tanks
    [11] = "Spirit", --Healers

    --Attack
    [12] = "Attack_Power",
    [13] = "Attack_Speed",
    [14] = "Res_Regen", --Energy, Focus, and Runes regen

    --Spell
    [15] = "Spell_Power",
    [16] = "Combat_Regen",
    [17] = "Mana_Regen",

    --Defense
    [18] = "Dodge",
    [19] = "Parry",
    [20] = "Block",
    [21] = "Total_Armor",
}

local convertStat = { --Test prep for Warlords
    ["Melee_Haste"] = "Haste",
    ["Range_Haste"] = "Haste",
    ["Spell_Haste"] = "Haste",
    ["Melee_Crit"] = "Crit",
    ["Range_Crit"] = "Crit",
    ["Spell_Crit"] = "Crit",
    ["Defense_Mastery"] = "Mastery",
    ["Melee_Mastery"] = "Mastery",
    ["Range_Mastery"] = "Mastery",
    ["Spell_Mastery"] = "Mastery",
    ["Melee_AP"] = "Attack_Power",
    ["Range_AP"] = "Attack_Power",
    ["Weapon_Speed"] = "Attack_Speed",
    ["Range_Speed"] = "Attack_Speed",
    ["MP5"] = "Combat_Regen",
    ["Armor_Defense"] = "Total_Armor",
}

local StatIcons = {
    [1]  = "PersonPlus",
    [2]  = "PersonPlus",
    [3]  = "Heart",
    [4]  = "PersonPlus",

    [5]  = "Lightning",
    [6]  = "DoubleArrow2",
    [7]  = "Sword",
    [8]  = "DoubleArrow2",
    [9]  = "Heart",
    [10] = "Shield",
    [11]  = "Flame",
             
    [12] = "Sword",
    [13] = "Lightning",
    [14] = "DoubleArrow2",
          
    [15] = "Flame",
    [16] = "Lightning",
    [17] = "Lightning",
         
    [18] = "Lightning",
    [19] = "Lightning",
    [20] = "Shield",
    [21] = "Shield",
}
local StatTexts = {
    [1]  = SPELL_STAT1_NAME,
    [2]  = SPELL_STAT2_NAME,
    [3]  = SPELL_STAT3_NAME,
    [4]  = SPELL_STAT4_NAME,

    [5]  = STAT_HASTE,
    [6]  = STAT_CRITICAL_STRIKE,
    [7]  = STAT_MASTERY,
    [8]  = STAT_MULTISTRIKE,
    [9]  = STAT_VERSATILITY,
    [10] = BONUS_ARMOR,
    [11] = SPELL_STAT5_NAME,
          
    [12] = STAT_ATTACK_SPEED,
    [13] = STAT_ATTACK_SPEED,
    [14] = {STAT_ENERGY_REGEN, STAT_FOCUS_REGEN, STAT_RUNE_REGEN},
          
    [15] = STAT_SPELLPOWER,
    [16] = MANA_REGEN_COMBAT,
    [17] = MANA_REGEN,
          
    [18] = STAT_DODGE,
    [19] = STAT_PARRY,
    [20] = STAT_BLOCK,
    [21] = ARMOR,
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

--------------------
---- Attributes ----
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

---------------------
---- Enhancments ----
---------------------
StatFunc.Haste = function()
    local Haste = GetHaste()
    return strform(PercentFormatString, Haste)
end

StatFunc.Crit = function()
    local Crit
    local spellCrit = GetSpellCritChance("2")
    local rangedCrit = GetRangedCritChance();
    local meleeCrit = GetCritChance();

    if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
        Crit = spellCrit;
    elseif (rangedCrit >= meleeCrit) then
        Crit = rangedCrit;
    else
        Crit = meleeCrit;
    end
    return strform(PercentFormatString, Crit)
end

StatFunc.Mastery = function()
    local Mastery = GetMasteryEffect();
    return strform(PercentFormatString, Mastery)
end

StatFunc.Multistrike = function()
    local Multistrike = GetMultistrike();
    return strform(PercentFormatString, Multistrike)
end

StatFunc.Versitility = function()
    local Versitility = GetVersatility();
    return strform(PercentFormatString, Versitility)
end

StatFunc.Bonus_Armor = function()
    local _, _, _, posBuff, negBuff = UnitArmor("player")
    local Bonus_Armor = posBuff + negBuff
    return nibRealUI:ReadableNumber(Bonus_Armor)
end

StatFunc.Spirit = function()
    local _, Spirit = UnitStat("player", 5)
    return nibRealUI:ReadableNumber(Spirit)
end

----------------
---- Attack ----
----------------
StatFunc.Attack_Power = function()
    local rangedWeapon = IsRangedWeapon()
    local base, posBuff, negBuff

    if ( rangedWeapon ) then
        base, posBuff, negBuff = UnitRangedAttackPower("player")
    else 
        base, posBuff, negBuff = UnitAttackPower("player")
    end

    local Attack_Power = max(0, base + posBuff + negBuff) 
    return nibRealUI:ReadableNumber(Attack_Power)
end

StatFunc.Attack_Speed = function()
    local rangedWeapon = IsRangedWeapon()
    local speed, offhandSpeed
    if ( rangedWeapon ) then
        speed = UnitRangedDamage(unit)
    else 
        speed, offhandSpeed = UnitAttackSpeed(unit)
    end
    if ( offhandSpeed ) then
        return strform(RoundFormatString, speed).." / ".. strform(RoundFormatString, offhandSpeed)
    else
        return strform(RoundFormatString, speed)
    end
end

StatFunc.Res_Regen = function()
    local _, class = UnitClass(unit);
    local Res_Regen
    if (class == "DEATHKNIGHT") then
        _, Res_Regen = GetRuneCooldown(1);
    else
        Res_Regen = GetPowerRegen();
    end
    return strform(RoundFormatString, Res_Regen)
end

---------------
---- Spell ----
---------------
StatFunc.Spell_Power = function()
    local Spell_Power = GetSpellBonusDamage("2")
    return nibRealUI:ReadableNumber(Spell_Power)
end

StatFunc.Combat_Regen = function()
    local base, casting = GetManaRegen()
    local Combat_Regen = floor(casting * 5)
    return strform("%.0f", Combat_Regen)
end

StatFunc.Mana_Regen = function()
    local base, casting = GetManaRegen()
    local Mana_Regen = floor(base * 5)
    return strform("%.0f", Mana_Regen)
end


-----------------
---- Defense ----
-----------------
StatFunc.Dodge = function()
    local Dodge = GetDodgeChance()
    return strform(PercentFormatString, Dodge)
end

StatFunc.Parry = function()
    local Parry = GetParryChance()
    return strform(PercentFormatString, Parry)
end

StatFunc.Block = function()
    local Block = GetBlockChance()
    return strform(PercentFormatString, Block)
end

StatFunc.Total_Armor = function()
    local _, Total_Armor = UnitArmor("player")
    return nibRealUI:ReadableNumber(Total_Armor)
end



------------
local GetStatText
local DefaultStatTypes = {
    Melee = {"Attack_Power", "Crit"},
    Ranged = {"Attack_Power", "Crit"},
    Spell = {"Spell_Power", "Crit"},
}
local DefaultStats = {
    ["DEATHKNIGHT"] = {
        [1] = {"Multistrike", "Mastery"},   -- Blood
        [2] = {"Haste", "Attack_Power"},   -- Frost
        [3] = {"Multistrike", "Attack_Power"},   -- Unholy
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["DRUID"] = {
        [1] = {"Mastery", "Spell_Power"},   -- Bal
        [2] = {"Crit", "Attack_Power"},   -- Feral
        [3] = {"Mastery", "Crit"},    -- Guardian
        [4] = {"Haste", "Combat_Regen"},    -- Resto
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["HUNTER"] = {
        [1] = {"Mastery", "Attack_Power"},  -- BM
        [2] = {"Crit", "Attack_Power"},  -- MM
        [3] = {"Multistrike", "Attack_Power"},  -- SV
        ["NA"] = DefaultStatTypes.Ranged,
    },
    ["MAGE"] = {
        [1] = {"Mastery", "Spell_Power"},   -- Arc
        [2] = {"Crit", "Spell_Power"},   -- Fire
        [3] = {"Multistrike", "Spell_Power"},   -- Frost
        ["NA"] = DefaultStatTypes.Spell,
    },
    ["MONK"] = {
        [1] = {"Crit", "Mastery"},    -- BrM
        [2] = {"Multistrike", "Combat_Regen"},    -- MW
        [3] = {"Multistrike", "Attack_Power"},   -- WW
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["PALADIN"] = {
        [1] = {"Crit", "Combat_Regen"},    -- Holy
        [2] = {"Haste", "Block"},    -- Prot
        [3] = {"Mastery", "Attack_Power"},   -- Ret
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["PRIEST"] = {
        [1] = {"Crit", "Combat_Regen"},    -- Disc
        [2] = {"Multistrike", "Combat_Regen"},    -- Holy
        [3] = {"Haste", "Spell_Power"},   -- Shadow
        ["NA"] = DefaultStatTypes.Spell,
    },
    ["ROGUE"] = {
        [1] = {"Mastery", "Attack_Power"},   -- Assass
        [2] = {"Haste", "Attack_Power"},   -- Combat
        [3] = {"Multistrike", "Attack_Power"},   -- Sub
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["SHAMAN"] = {
        [1] = {"Multistrike", "Spell_Power"},   -- Ele
        [2] = {"Haste", "Attack_Power"},   -- Enh
        [3] = {"Mastery", "Combat_Regen"},    -- Resto
        ["NA"] = DefaultStatTypes.Melee,
    },
    ["WARLOCK"] = {
        [1] = {"Haste", "Spell_Power"},   -- Afflic
        [2] = {"Mastery", "Spell_Power"},   -- Demo
        [3] = {"Crit", "Spell_Power"},   -- Destro
        ["NA"] = DefaultStatTypes.Spell,
    },
    ["WARRIOR"] = {
        [1] = {"Mastery", "Attack_Power"},   -- Arms
        [2] = {"Crit", "Attack_Power"},   -- Fury
        [3] = {"Mastery", "Block"},    -- Prot
        ["NA"] = DefaultStatTypes.Melee,
    },
}


local function RefreshStats()
    if GetStatText == nil then
        GetStatText = {
            Strength     = function() return StatFunc.Strength() end,
            Agility      = function() return StatFunc.Agility() end,
            Stamina      = function() return StatFunc.Stamina() end,
            Intellect    = function() return StatFunc.Intellect() end,

            Haste        = function() return StatFunc.Haste() end,
            Crit         = function() return StatFunc.Crit() end,
            Mastery      = function() return StatFunc.Mastery() end,
            Multistrike  = function() return StatFunc.Multistrike() end,
            Versitility  = function() return StatFunc.Versitility() end,
            Bonus_Armor  = function() return StatFunc.Bonus_Armor() end,
            Spirit       = function() return StatFunc.Spirit() end,

            Attack_Power = function() return StatFunc.Attack_Power() end,
            Attack_Speed = function() return StatFunc.Attack_Speed() end,
            Res_Regen    = function() return StatFunc.Res_Regen() end,

            Spell_Power  = function() return StatFunc.Spell_Power() end,
            Combat_Regen = function() return StatFunc.Combat_Regen() end,
            Mana_Regen   = function() return StatFunc.Mana_Regen() end,

            Dodge        = function() return StatFunc.Dodge() end,
            Parry        = function() return StatFunc.Parry() end,
            Block        = function() return StatFunc.Block() end,
            Total_Armor  = function() return StatFunc.Total_Armor() end,
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
