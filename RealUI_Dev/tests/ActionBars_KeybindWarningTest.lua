-- ActionBars_KeybindWarningTest.lua
-- B202: the keybind mode warning box (RealUI_ActionBars/Bindings.lua).
-- Usage: /realdev abkeybindwarning (out of combat, UI visible)
--
-- Drives the mode through every exit path a script can reach and checks the
-- box follows it: shown while on, gone after /rab bind, the box's own button,
-- combat start and a plain Hide of the catcher; still up after the config
-- window closes. The mode is left off. Expect keybind mode lines in chat.
--
-- Not reachable from a script, check by hand:
--   1. Combat: turn the mode on, enter combat. Box gone, chat says so, no
--      blocked action error, keys work in combat. A PASS here only proves the
--      handler, because the event is called by hand.
--   2. /reload with the mode on: mode off, no box.
--   3. Alt-Z with the mode on: the box goes with the UI and comes back with it.
--   4. Look: Aurora backdrop and buttons, yellow border, box above the config
--      window and the game menu.
--   5. Hover a bar button with the mode on (needs a real cursor):
--      - W: you walk, the box asks, /dump GetBindingAction("W") stays
--        MOVEFORWARD. Replace binds it. Rebind W to Move Forward afterwards.
--      - An unbound key: binds at once, no question.
--      - ESC on a button with keys: no menu, the box asks, the key stays.
--        Clear removes it; a second ESC instead drops the question and opens
--        the game menu with the key still there.
--      - A question up, then enter combat or /rab bind: it goes with the box.

local _, ns = ... -- luacheck: ignore

local STRINGS = {
    "ActionBars_KeybindMode",
    "ActionBars_KeybindModeClear",
    "ActionBars_KeybindModeClearDesc",
    "ActionBars_KeybindModeCombat",
    "ActionBars_KeybindModeDesc",
    "ActionBars_KeybindModeExit",
    "ActionBars_KeybindModeReplace",
    "ActionBars_KeybindModeReplaceDesc",
}

function ns.commands:abkeybindwarning()
    local AceAddon = _G.LibStub("AceAddon-3.0", true)
    local AB = AceAddon and AceAddon:GetAddon("RealUIActionBars", true)
    if not AB then
        _G.print("|cffff0000[FAIL]|r abkeybindwarning: RealUI_ActionBars not loaded.")
        return false
    end
    if _G.InCombatLockdown() then
        _G.print("|cffff0000[FAIL]|r abkeybindwarning: run it out of combat.")
        return false
    end

    local failures = 0
    local function fail(fmt, ...)
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r " .. fmt:format(...))
    end

    local toggle = function() _G.SlashCmdList.REALUIACTIONBARS("bind") end

    -- The frames only exist after the first start, and the mode may be on
    -- already.
    local catcher = _G.RealUI_AB_KeybindCatcher
    if catcher then catcher:Hide() end
    toggle()
    catcher = _G.RealUI_AB_KeybindCatcher
    local box = _G.RealUI_AB_KeybindWarning
    if not (catcher and box and box.exit) then
        fail("frames missing after /rab bind")
        return false
    end

    local function check(context, on)
        if catcher:IsShown() ~= on then
            fail("%s: mode %s, expected %s", context, _G.tostring(catcher:IsShown()), _G.tostring(on))
        end
        if box:IsVisible() ~= on then
            fail("%s: box visible %s, expected %s", context, _G.tostring(box:IsVisible()), _G.tostring(on))
        end
    end

    check("started", true)

    -- Strings resolve (a missing key would show as its own name), and the
    -- measured height holds the button.
    local RealUI = _G.RealUI
    for _, key in _G.ipairs(STRINGS) do
        if not (RealUI and RealUI.L and _G.rawget(RealUI.L, key)) then
            fail("no locale entry for %s", key)
        end
    end
    if box:GetFrameStrata() ~= "TOOLTIP" then
        fail("box strata %s, expected TOOLTIP", box:GetFrameStrata())
    end
    if box.exit:GetBottom() < box:GetBottom() then
        fail("exit button hangs below the box")
    end
    if box.confirm:IsShown() then
        fail("a question is up with no key pressed")
    end

    -- Exit paths.
    box.exit:Click()
    check("box button", false)

    toggle()
    check("restart", true)
    toggle()
    check("/rab bind", false)

    toggle()
    catcher:GetScript("OnEvent")(catcher, "PLAYER_REGEN_DISABLED")
    check("combat start handler", false)

    -- The handler must do nothing when the mode is off.
    catcher:GetScript("OnEvent")(catcher, "PLAYER_REGEN_DISABLED")
    check("combat start while off", false)

    -- Closing the config window is not an exit.
    toggle()
    local dialog = _G.LibStub("AceConfigDialog-3.0", true)
    if dialog then
        AB:OpenConfig()
        if not dialog.OpenFrames.RealUI_ActionBars then
            fail("config window did not open")
        end
        dialog:Close("RealUI_ActionBars")
        check("config window closed", true)
    else
        _G.print("|cffffff00[SKIP]|r config window close: AceConfigDialog not loaded.")
    end

    -- The box has no exit logic of its own: any hide of the catcher takes it.
    catcher:Hide()
    check("catcher hidden directly", false)

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r B202 keybind warning: box follows every scripted exit path (combat, /reload, Alt-Z and the look are manual, see the file header)")
    else
        _G.print(("|cffff0000[FAIL]|r B202 keybind warning: %d failures"):format(failures))
    end
    return failures == 0
end
