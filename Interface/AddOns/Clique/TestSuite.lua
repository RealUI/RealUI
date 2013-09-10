local addonName, addon = ...

local tests = {}

--[[-------------------------------------------------------------------
--  Bootstrap code to set up the buttons
-------------------------------------------------------------------]]--

local groupheader = CreateFrame("Button", addonName .. "TestHeader", UIParent, "SecureGroupHeaderTemplate")
SecureHandler_OnLoad(groupheader)

local button_m = CreateFrame("Button", addonName .. "TestButton_m", UIParent, "SecureActionButtonTemplate")
local button_h = CreateFrame("Button", addonName .. "TestButton_h", UIParent, "ClickCastUnitTemplate,SecureActionButtonTemplate")

--[[-------------------------------------------------------------------
--  Create the event handler
-------------------------------------------------------------------]]--

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:SetScript("OnEvent", function(self, event, ...)
    print("====== " .. addonName .. "Test Suite ======")

    print("  - Registering frames for click-casting")

    ClickCastFrames[button_m] = true
    groupheader:SetFrameRef("clickcast_header", addon.header)
    groupheader:SetFrameRef("thebutton", button_h)
    groupheader:Execute[[
        local header = self:GetFrameRef("clickcast_header")
        header:SetAttribute("clickcast_button", self:GetFrameRef("thebutton"))
        header:RunAttribute("clickcast_register")
    ]]

    local currentProfile = addon.db:GetCurrentProfile()

    for name, testFunc in pairs(tests) do
        print("  - Running " .. name)
        testFunc()
    end

    addon.db:SetProfile(currentProfile)
end)


--[[-------------------------------------------------------------------
--  Utility functions
-------------------------------------------------------------------]]--

local function makeprofile(bindings)

    addon:ClearAttributes()

    local tempName = "Temp" .. GetTime()
    local suiteName = addonName .. "TestSuite"
    addon.db:SetProfile(tempName)
    addon.db:DeleteProfile(suiteName, true)
    addon.db:SetProfile(suiteName)
    addon.db:DeleteProfile(tempName)

    table.wipe(addon.bindings)
    for k,v in pairs(bindings) do
        table.insert(addon.bindings, v)
    end

    addon:FireMessage("BINDINGS_CHANGED")
end

local function makebind(key)
    local entry = {}
    entry.key = key
    entry.type = "menu"
    entry.menu = function()
        CLIQUE_TEST_TRIGGERED = key
    end
    entry.sets = {default = true}
    return entry
end

local function getbutton(bind)
    local prefix, suffix = addon:GetBindingPrefixSuffix(bind)
    if suffix == "1" then
        suffix = "LeftButton"
    elseif suffix == "2" then
        suffix = "RightButton"
    elseif suffix == "3" then
        suffix = "MiddleButton"
    elseif tonumber(suffix) then
        suffix = "Button" .. suffix
    end

    return suffix
end

local passed = 0
local function pass(name)
    passed = passed + 1
    --print("    - |cff00ff00PASS|r - " .. name)
end

local failed = 0
local function fail(name)
    failed = failed + 1
    print("    - |cffff0000FAIL|r - " .. name)
end

local modbits = {
    "IsAltKeyDown",
    "IsLeftAltKeyDown",
    "IsRightAltKeyDown",
    "IsControlKeyDown",
    "IsLeftControlKeyDown",
    "IsRightControlKeyDown",
    "IsShiftKeyDown",
    "IsLeftShiftKeyDown",
    "IsRightShiftKeyDown",
}

local origs = {}
for k,v in pairs(modbits) do
    origs[v] = _G[v]
end

local function setmodifiers(bind)
    local binary = addon:GetBinaryBindingKey()
    for i = 1, #binary, 1 do
        local enabled = binary:sub(i,i) == "1"
        if enabled then
            _G[modbits[i]] = function() return 1 end
        end
    end
end

local function clrmodifiers()
    for idx, name in ipairs(modbits) do
        _G[name] = origs[name]
    end
end

local function randommodifiers()
    local prefix = ""
    if math.random(0, 1) then
        -- Alt key down
        local which = math.random(0, 10)
        if which >= 2 then
            prefix = prefix .. "ALT-"
        elseif which == 0 then
            prefix = prefix .. "LALT-"
        elseif which == 1 then
            prefix = prefix .. "RALT-"
        end
    end

    if math.random(0, 1) then
        -- Ctrl key down
        local which = math.random(0, 10)
        if which >= 2 then
            prefix = prefix .. "CTRL-"
        elseif which == 0 then
            prefix = prefix .. "LCTRL-"
        elseif which == 1 then
            prefix = prefix .. "RCTRL-"
        end
    end

   if math.random(0, 1) then
        -- Shift key down
        local which = math.random(0, 10)
        if which >= 2 then
            prefix = prefix .. "SHIFT-"
        elseif which == 0 then
            prefix = prefix .. "LSHIFT-"
        elseif which == 1 then
            prefix = prefix .. "RSHIFT-"
        end
    end

    return prefix
end

--[[-------------------------------------------------------------------
--  Test code 
-------------------------------------------------------------------]]--

local all_binding_types = {
    lower = makebind("f"),
    upper = makebind("F"),
    num = makebind("1"),
    foreign = makebind("ö"),
    fkey = makebind("F1"),
    qkey = makebind("DOUBLEQUOTE"),
    dash = makebind("DASH"),
    bspace = makebind("BACKSPACE"),
    leftbutton = makebind("BUTTON1"),
    rightbutton = makebind("BUTTON2"),
    middlebutton = makebind("BUTTON3"),
    button4 = makebind("BUTTON4"),
    button5 = makebind("BUTTON5"),
}

-- First test to ensure each type of binding works properly
function tests.SimpleTriggers()
    makeprofile(all_binding_types)

    for name, bind in pairs(all_binding_types) do
        -- Test to see if the binding works on the manually registered button
        local button = getbutton(bind)
        button_m.menu = bind.menu
        button_m:Click(button)

        if CLIQUE_TEST_TRIGGERED then
            pass(name .. " manual")
        else
            fail(name .. " manual")
        end

        button_h.menu = bind.menu
        button_h:Click(button)

        if CLIQUE_TEST_TRIGGERED then
            pass(name .. " header")
        else
            fail(name .. " header")
        end
    end

    print("  - " .. passed .. " passed, " .. failed .. " failed")
end

function tests.Modifiers()
    -- Copy bindings table
    local bindings = {}
    for k,v in pairs(all_binding_types) do
        bindings[k] = {}
        for ka,va in pairs(v) do
            bindings[k][ka] = va
        end
    end

    -- Run this test five times
    for i = 1, 10, 1 do
        for name, bind in pairs(bindings) do
            local obind = bind.key
            bind.key = randommodifiers() .. bind.key

            -- Register the bindings
            makeprofile(bindings)

            -- Manually registered button
            local button = getbutton(bind)
            button_m.menu = function()
                CLIQUE_TEST_TRIGGERED = bind.key
            end
            button_m:Click(button)

            if CLIQUE_TEST_TRIGGERED then
                pass(name .. " manual")
            else
                fail(name .. " manual")
            end

            button_h.menu = function()
                CLIQUE_TEST_TRIGGERED = bind.key
            end
            button_h:Click(button)

            if CLIQUE_TEST_TRIGGERED then
                pass(name .. "(" .. bind.key .. ") " ..  "header")
            else
                fail(name .. " header")
            end
            bind.key = obind
        end
    end

    print("  - " .. passed .. " passed, " .. failed .. " failed")
end
