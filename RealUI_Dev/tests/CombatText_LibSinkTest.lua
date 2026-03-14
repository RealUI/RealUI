local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: LibSink construction
-- Feature: combattext-wow12-update, Property 7: LibSink construction
-- Validates: Requirements 10.1, 10.2

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32) with unique seed 887
local rngState = 887
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- Generate a random float in [0, 1] with 2-decimal precision
local function nextFloat()
    return nextRandom(101) / 100  -- 0.00 to 1.00
end

-- Scroll area choices the sink can receive
local SCROLL_AREAS = {"incoming", "outgoing", "notification"}

-- Text prefixes for generating random text strings
local TEXT_PREFIXES = {"Damage", "Heal", "Crit", "Miss", "Absorb", "Recount", "Details", "Omen", "Threat", "DPS"}

local function RunTest()
    local CombatText = _G.RealUI:GetModule("CombatText")
    if not CombatText then
        _G.print("|cffff0000[ERROR]|r CombatText module not available")
        return false
    end

    local private = CombatText._testPrivate
    if not private then
        _G.print("|cffff0000[ERROR]|r CombatText._testPrivate not exposed")
        return false
    end

    -- Get LibSink and find the registered CombatText sink handler
    local LibSink = _G.LibStub and _G.LibStub("LibSink-2.0", true)
    if not LibSink then
        _G.print("|cffff9900[SKIP]|r LibSink-2.0 not available via LibStub")
        return nil -- nil = skip (not a failure)
    end

    -- LibSink-2.0 stores registered sinks in lib.registeredSinks[name].handler
    local sinkHandler
    if LibSink.registeredSinks and LibSink.registeredSinks["CombatText"] then
        sinkHandler = LibSink.registeredSinks["CombatText"].handler
    end

    if not sinkHandler then
        _G.print("|cffff0000[ERROR]|r Could not find registered CombatText sink handler in LibSink.registeredSinks")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Property 7: LibSink construction — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Save original AddEvent and replace with capture mock
    local originalAddEvent = private.AddEvent
    local capturedEventInfo -- luacheck: ignore 311
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    for i = 1, NUM_ITERATIONS do
        -- Generate random inputs
        local textIdx = nextRandom(#TEXT_PREFIXES)
        local text = TEXT_PREFIXES[textIdx] .. _G.tostring(nextRandom(99999))
        local r = nextFloat()
        local g = nextFloat()
        local b = nextFloat()
        local sticky = (nextRandom(2) == 1)
        local locationIdx = nextRandom(#SCROLL_AREAS + 1) -- +1 to allow nil case
        local location = (locationIdx <= #SCROLL_AREAS) and SCROLL_AREAS[locationIdx] or nil
        local hasIcon = (nextRandom(2) == 1)
        local icon = hasIcon and ("Interface\\Icons\\Spell_" .. nextRandom(9999)) or nil

        capturedEventInfo = nil
        -- Call sink: sink(addon, text, r, g, b, font, size, outline, sticky, location, icon)
        sinkHandler(nil, text, r, g, b, nil, nil, nil, sticky, location, icon)

        if not capturedEventInfo then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": sink produced no eventInfo")
        else
            -- Verify scrollType: should be location or "notification" if location is nil
            local expectedScrollType = location or "notification"
            if capturedEventInfo.scrollType ~= expectedScrollType then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": scrollType = '"
                    .. _G.tostring(capturedEventInfo.scrollType)
                    .. "', expected '" .. expectedScrollType .. "'")
            end

            -- Verify isSticky matches input
            if capturedEventInfo.isSticky ~= sticky then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": isSticky = "
                    .. _G.tostring(capturedEventInfo.isSticky)
                    .. ", expected " .. _G.tostring(sticky))
            end

            -- Verify icon matches input
            if capturedEventInfo.icon ~= icon then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": icon = '"
                    .. _G.tostring(capturedEventInfo.icon)
                    .. "', expected '" .. _G.tostring(icon) .. "'")
            end

            -- Verify string contains the text and color escape codes
            local str = capturedEventInfo.string
            if not str then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": eventInfo.string is nil")
            else
                -- String format is "|c" .. colorHex .. text .. "|r"
                -- colorHex is "ff%02x%02x%02x" from RealUI.GetColorString(r, g, b)
                local expectedColorHex = _G.string.format("ff%02x%02x%02x", r * 255, g * 255, b * 255)
                local expectedString = "|c" .. expectedColorHex .. text .. "|r"
                if str ~= expectedString then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": string = '"
                        .. str .. "', expected '" .. expectedString .. "'")
                end
            end
        end
    end

    -- Restore original AddEvent
    private.AddEvent = originalAddEvent

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 7: LibSink construction — passed")
    else
        _G.print("|cffff0000[FAIL]|r Property 7: LibSink construction — " .. failures .. " failures")
    end

    return failures == 0
end

function ns.commands:ctlibsink()
    return RunTest()
end
