local _, private = ...

local CombatText = private.CombatText

local GetEvent, isSpamming
local function InitTest()
    local random = _G.random
    local player = private.player
    local other = private.other

    local function GetAmount(maxAmount)
        return random(1, maxAmount or 5000)
    end

    local function IsCrit()
        return random(1, 10) >= 8
    end

    local missTypes = {
        "ABSORB",
        "BLOCK",
        "DEFLECT",
        "DODGE",
        "EVADE",
        "IMMUNE",
        "MISS",
        "PARRY",
        "REFLECT",
        "RESIST",
    }
    local function GetMissType()
        return missTypes[random(1, #missTypes)]
    end

    local spellSchools = {
        _G.SCHOOL_MASK_HOLY,
        _G.SCHOOL_MASK_FIRE,
        _G.SCHOOL_MASK_NATURE,
        _G.SCHOOL_MASK_FROST,
        _G.SCHOOL_MASK_SHADOW,
        _G.SCHOOL_MASK_ARCANE,
    }
    local function GetSpellSchool()
        return spellSchools[random(1, #spellSchools)]
    end

    local envTypes = {
        "Drowning",
        "Falling",
        "Fatigue",
        "Fire",
        "Lava",
        "Slime",
    }
    local function GetEnvironmentType()
        return envTypes[random(1, #envTypes)]
    end

    local powerTypes = _G.Enum.PowerType
    local alternatePower = _G.Enum.PowerType.Alternate
    local function GetPowerType()
        local powerType = random(powerTypes.Mana, powerTypes.Chi)
        if powerType == alternatePower then
            return powerType, random(powerTypes.Mana, powerTypes.HolyPower)
        end
        return powerType
    end

    local function GetPartialEffects(amount, numEffects)
        local rand = random(1, numEffects + 1)
        local partial = GetAmount(amount * 0.7)

        if rand == 1 then
            return 0, 0, 0
        elseif rand == 2 then
            return partial, 0, 0
        elseif rand == 3 then
            return 0, partial, 0
        else
            return 0, 0, partial
        end
    end

    local events = {
        "SWING_DAMAGE",
        "SWING_MISSED",

        "SPELL_DAMAGE",
        "SPELL_MISSED",
        "SPELL_HEAL",
        "SPELL_ENERGIZE",
    }

    local specID = _G.RealUI.charInfo.specs.current.id
    local spells = _G.C_SpecializationInfo.GetSpellsDisplay(specID)

    local spell1ID = spells[1]
    local spell1Name = _G.GetSpellInfo(spell1ID)

    local spell2ID = spells[2]
    local spell2Name = _G.GetSpellInfo(spell2ID)

    local spell3ID = spells[3]
    local spell3Name = _G.GetSpellInfo(spell3ID)

    local spell4ID = spells[4]
    local spell4Name = _G.GetSpellInfo(spell4ID)

    local eventArgs = {
        SWING_DAMAGE = function()
            local amount = GetAmount()
            local resisted, blocked, absorbed = GetPartialEffects(amount, 3)
            --       amount, overkill, school,         resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            return amount, 0, _G.SCHOOL_MASK_PHYSICAL, resisted, blocked, absorbed, IsCrit(), false, false, false
        end,
        SWING_MISSED = function()
            --      missType, isOffHand, amountMissed, critical
            return GetMissType(), false, GetAmount(), false
        end,


        RANGE_DAMAGE = function()
            local amount = GetAmount()
            local resisted, blocked, absorbed = GetPartialEffects(amount, 3)

            --    spellID,    spellName,        spellSchool,      amount, overkill,     school,       resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            return spell1ID, spell1Name, _G.SCHOOL_MASK_PHYSICAL, amount, 0, _G.SCHOOL_MASK_PHYSICAL, resisted, blocked, absorbed, IsCrit(), false, false, false
        end,
        RANGE_MISSED = function()
            --    spellID,    spellName,     spellSchool,     missType, isOffHand, amountMissed, critical
            return spell1ID, spell1Name, GetSpellSchool(), GetMissType(), false, GetAmount(), false
        end,

        SPELL_DAMAGE = function()
            local amount = GetAmount()
            local resisted, blocked, absorbed = GetPartialEffects(amount, 3)
            local spellSchool = GetSpellSchool()

            --    spellID,          spellName,           spellSchool,      amount, overkill,     school,       resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            return spell1ID, spell1Name, spellSchool, amount, 0, spellSchool, resisted, blocked, absorbed, IsCrit(), false, false, false
        end,
        SPELL_MISSED = function()
            --    spellID,          spellName,               spellSchool,     missType, isOffHand, amountMissed, critical
            return spell1ID, spell1Name, GetSpellSchool(), GetMissType(), false, GetAmount(), false
        end,
        SPELL_HEAL = function()
            local amount = GetAmount()
            local overhealing, absorbed = GetPartialEffects(amount, 2)

            --    spellID,          spellName,              spellSchool,     amount, overhealing, absorbed, critical
            return spell2ID, spell2Name, GetSpellSchool(), amount, overhealing, absorbed, IsCrit()
        end,
        SPELL_ENERGIZE = function()
            local amount = GetAmount()
            local overEnergize = GetPartialEffects(amount, 1)
            local powerType, alternatePowerType = GetPowerType()

            --    spellID,          spellName,              spellSchool,     amount, overEnergize, powerType, alternatePowerType
            return spell3ID, spell3Name, GetSpellSchool(), amount, overEnergize, powerType, alternatePowerType
        end,

        SPELL_PERIODIC_DAMAGE = function()
            local amount = GetAmount()
            local resisted, blocked, absorbed = GetPartialEffects(amount, 3)
            local spellSchool = GetSpellSchool()

            --    spellID,          spellName,           spellSchool,      amount, overkill,     school,       resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            return spell4ID, spell4Name, spellSchool, amount, 0, spellSchool, resisted, blocked, absorbed, IsCrit(), false, false, false
        end,
        SPELL_PERIODIC_MISSED = function()
            --    spellID,          spellName,               spellSchool,     missType, isOffHand, amountMissed, critical
            return spell4ID, spell4Name, GetSpellSchool(), GetMissType(), false, GetAmount(), false
        end,

        ENVIRONMENTAL_DAMAGE = function()
            local amount = GetAmount()
            local resisted, blocked, absorbed = GetPartialEffects(amount, 3)

            --    environmentalType,      amount, overkill,     school,       resisted, blocked, absorbed, critical, glancing, crushing, isOffHand
            return GetEnvironmentType(), amount, 0, GetSpellSchool(), resisted, blocked, absorbed, IsCrit(), false, false, false
        end,
    }

    local sourceGUID, sourceName, sourceFlags, sourceRaidFlags
    local destGUID, destName, destFlags, destRaidFlags
    local timestamp, event, args
    local hideCaster = false

    function GetEvent()
        if not isSpamming then
            if random(1, 20) == 20 then
                isSpamming = random(5, 10)
            end

            if random(1, 2) == 1 then
                sourceGUID, sourceName, sourceFlags, sourceRaidFlags = player.guid, player.name, player.flags, player.raidFlags
                destGUID, destName, destFlags, destRaidFlags = other.guid, other.name, other.flags, other.raidFlags
            else
                sourceGUID, sourceName, sourceFlags, sourceRaidFlags = other.guid, other.name, other.flags, other.raidFlags
                destGUID, destName, destFlags, destRaidFlags = player.guid, player.name, player.flags, player.raidFlags
            end

            timestamp = _G.GetTime()
            event = events[random(1, #events)]
            args = eventArgs[event]
        else
            isSpamming = isSpamming - 1
            if isSpamming == 0 then
                isSpamming = false
            end
        end

        return timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, args()
    end
end

local testFrame = _G.CreateFrame("Frame")
testFrame:Hide()

local update = 0
testFrame:SetScript("OnUpdate", function(self, elapsed)
    update = update + elapsed
    if update > (isSpamming and 0.25 or 0.5) then
        private.FilterEvent(GetEvent())
        update = 0
    end
end)

function CombatText:ToggleTest()
    if not GetEvent then
        InitTest()
    end

    testFrame:SetShown(not testFrame:IsShown())
end
