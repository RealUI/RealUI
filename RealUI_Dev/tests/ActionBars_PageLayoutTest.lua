-- ActionBars_PageLayoutTest.lua
-- B151: RealUI_ActionBars page numbering (Bartender4 vs Blizzard).
-- Usage: /realdev abpagelayout
--
-- Static part: the page table and the page->binding mapping for both
-- layouts, including that Bartender mode reproduces the pre-B151 per-bar
-- binding table exactly. Live part: every button on bars 1-6 holds the slot
-- and keyBoundTarget the profile's current layout says it should.

local _, ns = ... -- luacheck: ignore

local EXPECTED_PAGES = {
    bartender = { 1, 2, 3, 4, 5, 6 },
    blizzard  = { 1, 6, 5, 3, 4, 13 },
}

-- Bartender: the pre-B151 KEYBOUND_TARGETS / BLIZZARD_MIRRORS, verbatim.
-- Blizzard: bar N mirrors Blizzard's Action Bar N.
local EXPECTED_BINDINGS = {
    bartender = {
        [1] = "ACTIONBUTTON%d",
        [3] = "MULTIACTIONBAR3BUTTON%d",
        [4] = "MULTIACTIONBAR4BUTTON%d",
        [5] = "MULTIACTIONBAR2BUTTON%d",
        [6] = "MULTIACTIONBAR1BUTTON%d",
    },
    blizzard = {
        [1] = "ACTIONBUTTON%d",
        [2] = "MULTIACTIONBAR1BUTTON%d",
        [3] = "MULTIACTIONBAR2BUTTON%d",
        [4] = "MULTIACTIONBAR3BUTTON%d",
        [5] = "MULTIACTIONBAR4BUTTON%d",
        [6] = "MULTIACTIONBAR5BUTTON%d",
    },
}

function ns.commands:abpagelayout()
    local AceAddon = _G.LibStub("AceAddon-3.0", true)
    local AB = AceAddon and AceAddon:GetAddon("RealUIActionBars", true)
    if not (AB and AB.GetBarPage) then
        _G.print("|cffff0000[FAIL]|r abpagelayout: RealUI_ActionBars (with B151) not loaded.")
        return false
    end

    local failures = 0
    local function fail(fmt, ...)
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r " .. fmt:format(...))
    end

    -- Every binding command the client defines (Bindings_*.xml).
    local commands = {}
    for index = 1, _G.GetNumBindings() do
        local command = _G.GetBinding(index)
        if command then commands[command] = true end
    end

    -- Static mapping, both layouts.
    for layout, pages in _G.next, EXPECTED_PAGES do
        for id = 1, 6 do
            local page = AB:GetBarPage(id, layout)
            if page ~= pages[id] then
                fail("%s bar %d: page %s, expected %d", layout, id, _G.tostring(page), pages[id])
            end
            local got = AB:GetBindingFormat(id, layout)
            local want = EXPECTED_BINDINGS[layout][id]
            if got ~= want then
                fail("%s bar %d: binding %s, expected %s", layout, id, _G.tostring(got), _G.tostring(want))
            end
            -- The command must be one the client actually defines.
            if got and not commands[got:format(1)] then
                fail("%s bar %d: no client binding named %s", layout, id, got:format(1))
            end
        end
    end

    -- Unknown layout names fall back to Bartender.
    if AB:GetBarPage(2, "bogus") ~= 2 then
        fail("unknown layout did not fall back to bartender")
    end

    -- Live: buttons match the profile's current layout.
    local layout = AB:GetPageLayout()
    for id = 1, 6 do
        local bar = AB.bars and AB.bars[id]
        if not bar then
            fail("bar %d not built", id)
        else
            local base = (AB:GetBarPage(id) - 1) * 12
            local commandFormat = AB:GetBindingFormat(id)
            for i = 1, 12 do
                local button = bar.buttons[i]
                local kind, action = button:GetAction(0)
                -- Bar 1's state 0 is page 1 in both layouts.
                if kind ~= "action" or action ~= base + i then
                    fail("%s bar %d button %d: slot %s, expected %d", layout, id, i,
                        _G.tostring(action), base + i)
                end
                -- LAB stores "none" as false; compare as nil.
                local target = button.config and button.config.keyBoundTarget or nil
                local want = commandFormat and commandFormat:format(i) or nil
                if target ~= want then
                    fail("%s bar %d button %d: keyBoundTarget %s, expected %s", layout, id, i,
                        _G.tostring(target), _G.tostring(want))
                end
            end
        end
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r B151 page layout: both mappings + live bars (%s) correct"):format(layout))
    else
        _G.print(("|cffff0000[FAIL]|r B151 page layout: %d failures"):format(failures))
    end
    return failures == 0
end
