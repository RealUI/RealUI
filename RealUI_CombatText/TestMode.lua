local _, private = ...

local CombatText = private.CombatText

local isSpamming
local random = _G.math.random

local function GetAmount(maxAmount)
    return random(1, maxAmount or 5000)
end

-- WoW 12 message types with their call signatures for HandleMessageType(messageType, data, arg3, arg4)
-- Each entry: { messageType, generator function returning data, arg3, arg4 }
local powerTypes = {"MANA", "RAGE", "ENERGY", "FOCUS", "RUNIC_POWER"}

local testEvents = {
    -- Damage types: data = amount
    { "DAMAGE",          function() return GetAmount(), nil, nil end },
    { "DAMAGE_CRIT",     function() return GetAmount(), nil, nil end },
    { "SPELL_DAMAGE",    function() return GetAmount(), nil, nil end },
    { "SPELL_DAMAGE_CRIT", function() return GetAmount(), nil, nil end },
    { "DAMAGE_SHIELD",   function() return GetAmount(), nil, nil end },
    { "SPLIT_DAMAGE",    function() return GetAmount(), nil, nil end },

    -- Heal types: data = healer name, arg3 = amount
    { "HEAL",               function() return "Healer", GetAmount(), nil end },
    { "HEAL_CRIT",          function() return "Healer", GetAmount(), nil end },
    { "PERIODIC_HEAL",      function() return "Healer", GetAmount(), nil end },
    { "PERIODIC_HEAL_CRIT", function() return "Healer", GetAmount(), nil end },
    { "HEAL_ABSORB",        function() return "Healer", GetAmount(), nil end },
    { "ABSORB_ADDED",       function() return "Healer", GetAmount(), nil end },

    -- Miss types: no amount
    { "MISS",    function() return nil, nil, nil end },
    { "DODGE",   function() return nil, nil, nil end },
    { "PARRY",   function() return nil, nil, nil end },
    { "EVADE",   function() return nil, nil, nil end },
    { "IMMUNE",  function() return nil, nil, nil end },
    { "DEFLECT", function() return nil, nil, nil end },
    { "BLOCK",   function() return nil, nil, nil end },
    { "ABSORB",  function() return nil, nil, nil end },
    { "RESIST",  function() return nil, nil, nil end },
    { "SPELL_MISS",    function() return nil, nil, nil end },
    { "SPELL_DODGE",   function() return nil, nil, nil end },
    { "SPELL_PARRY",   function() return nil, nil, nil end },
    { "SPELL_BLOCK",   function() return nil, nil, nil end },
    { "SPELL_ABSORB",  function() return nil, nil, nil end },
    { "SPELL_RESIST",  function() return nil, nil, nil end },

    -- Energize types: data = amount, arg3 = power type string
    { "ENERGIZE",          function() return GetAmount(200), powerTypes[random(1, #powerTypes)], nil end },
    { "PERIODIC_ENERGIZE", function() return GetAmount(200), powerTypes[random(1, #powerTypes)], nil end },
}

local numEvents = #testEvents

local testFrame = _G.CreateFrame("Frame")
testFrame:Hide()
private._testFrame = testFrame

local update = 0
testFrame:SetScript("OnUpdate", function(self, elapsed)
    update = update + elapsed
    if update > (isSpamming and 0.25 or 0.5) then
        -- Randomly trigger spam bursts
        if not isSpamming then
            if random(1, 20) == 20 then
                isSpamming = random(5, 10)
            end
        else
            isSpamming = isSpamming - 1
            if isSpamming == 0 then
                isSpamming = false
            end
        end

        local entry = testEvents[random(1, numEvents)]
        local messageType = entry[1]
        local data, arg3, arg4 = entry[2]()
        private.HandleMessageType(messageType, data, arg3, arg4)

        update = 0
    end
end)

function CombatText:ToggleTest()
    testFrame:SetShown(not testFrame:IsShown())
end
