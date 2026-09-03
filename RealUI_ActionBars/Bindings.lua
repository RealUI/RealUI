local _, private = ...
local AB = private.AB

--[[ Keybinds (spec req 7; LibKeyBound failed its license gate — no license
     grant in the upstream header — so this is the minimal own capture mode
     from req 7.3).

     Bar 1 mirrors the user's ACTIONBUTTON1-12 bindings via override bindings,
     so existing muscle memory works untouched (and LAB displays those hotkeys
     through keyBoundTarget). Other bars get custom click bindings captured by
     /rab bind: hover a button, press a key; ESC clears. ]]--

local bindingOwner = _G.CreateFrame("Frame", "RealUI_AB_BindingOwner", _G.UIParent)

function private.ApplyBindings()
    _G.ClearOverrideBindings(bindingOwner)

    -- Blizzard binding mirrors: keys bound through the standard Blizzard
    -- commands press our equivalent buttons. Bar 1 = ACTIONBUTTON; bars 3-6
    -- occupy the same action pages as Blizzard's multibars, so their
    -- MULTIACTIONBAR bindings map straight across (bar 2 = page 2 has no
    -- Blizzard binding set; it pages via bar 1).
    local BLIZZARD_MIRRORS = {
        [1] = "ACTIONBUTTON%d",
        [3] = "MULTIACTIONBAR3BUTTON%d",  -- page 3 / MultiBarRight
        [4] = "MULTIACTIONBAR4BUTTON%d",  -- page 4 / MultiBarLeft
        [5] = "MULTIACTIONBAR2BUTTON%d",  -- page 5 / MultiBarBottomRight
        [6] = "MULTIACTIONBAR1BUTTON%d",  -- page 6 / MultiBarBottomLeft
    }
    for barID, commandFormat in _G.next, BLIZZARD_MIRRORS do
        for i = 1, 12 do
            local buttonName = ("RealUI_AB_Bar%dB%d"):format(barID, i)
            local keys = { _G.GetBindingKey(commandFormat:format(i)) }
            for k = 1, #keys do
                _G.SetOverrideBindingClick(bindingOwner, false, keys[k], buttonName, "LeftButton")
            end
        end
    end

    -- Custom captures for any bar.
    for buttonName, key in _G.next, AB.db.profile.bindings do
        _G.SetOverrideBindingClick(bindingOwner, false, key, buttonName, "LeftButton")
        local button = _G[buttonName]
        if button and button.HotKey then
            button.HotKey:SetText(_G.GetBindingText(key, 1))
            button.HotKey:Show()
        end
    end
end

--[[ Capture mode ]]--

local catcher
local IGNORED_KEYS = {
    LSHIFT = true, RSHIFT = true, LCTRL = true, RCTRL = true,
    LALT = true, RALT = true, UNKNOWN = true,
}

local function GetHoveredButton()
    local foci = _G.GetMouseFoci()
    for i = 1, #foci do
        local name = foci[i] and foci[i].GetName and foci[i]:GetName()
        if name and name:find("^RealUI_AB_Bar%d+B%d+$") then
            return name
        end
    end
end

-- Blizzard's canonical chord order is ALT-CTRL-SHIFT-key
-- (BindingUtil.lua CreateKeyChordStringUsingMetaKeyState). The previous
-- prepend loop produced SHIFT-CTRL-ALT-key, which the game's own binding set
-- would not have matched.
local function ComposeKey(key)
    local chord = ""
    if _G.IsAltKeyDown()     then chord = chord .. "ALT-"   end
    if _G.IsControlKeyDown() then chord = chord .. "CTRL-"  end
    if _G.IsShiftKeyDown()   then chord = chord .. "SHIFT-" end
    return chord .. key
end

local function Say(fmt, ...)
    _G.print(("|cff30d0ffRealUI ActionBars|r: " .. fmt):format(...))
end

--[[ Two kinds of button, two binding stores.

     Bars 1 and 3-6 mirror a Blizzard command (`keyBoundTarget`, set in
     Bar.lua): the key the button DISPLAYS is whatever the game's own binding
     set holds for that command, and Bar 1 presses via that command too. Our
     profile table never held those keys, so ESC on such a button printed
     "cleared" while removing nothing, and the hotkey stayed on the button
     (post-4.0.1 report). Bind and clear on these go through SetBinding on the
     command — the same thing LibActionButton's SetKey/ClearBindings do —
     followed by SaveBindings so the change survives a reload.

     Bar 2 has no Blizzard command; its captures live in the profile and are
     applied as override bindings by ApplyBindings. ]]--
local function HandleBind(key)
    local buttonName = GetHoveredButton()
    if not buttonName then return false end

    local button = _G[buttonName]
    local target = button and button.config and button.config.keyBoundTarget
    local bindings = AB.db.profile.bindings

    -- SetBinding is refused in combat; bind mode refuses to START in combat,
    -- but combat can begin while it is on.
    if target and _G.InCombatLockdown() then
        Say("cannot change bindings in combat.")
        return true
    end

    if key == "ESCAPE" then
        local cleared = {}
        if bindings[buttonName] then
            cleared[#cleared + 1] = _G.GetBindingText(bindings[buttonName], 1)
            bindings[buttonName] = nil
        end
        if target then
            local keys = { _G.GetBindingKey(target) }
            for k = 1, #keys do
                _G.SetBinding(keys[k], nil)
                cleared[#cleared + 1] = _G.GetBindingText(keys[k], 1)
            end
            if #keys > 0 then
                _G.SaveBindings(_G.GetCurrentBindingSet())
            end
        end
        if button and button.HotKey then
            button.HotKey:SetText("")
        end
        if #cleared > 0 then
            Say("cleared %s on %s.", _G.table.concat(cleared, ", "), buttonName)
        else
            Say("nothing was bound on %s.", buttonName)
        end
    else
        if IGNORED_KEYS[key] then return false end
        local composed = ComposeKey(key)
        -- One binding per key: drop it from any other custom capture first,
        -- and blank that button's hotkey — ApplyBindings only writes text for
        -- captures that still exist, so the old label would otherwise stay.
        for otherName, otherKey in _G.next, bindings do
            if otherKey == composed then
                bindings[otherName] = nil
                local other = _G[otherName]
                if other and other.HotKey then other.HotKey:SetText("") end
            end
        end
        if target then
            -- SetBinding already unbinds the key from whatever Blizzard
            -- command held it, so no sweep is needed on that side.
            _G.SetBinding(composed, target)
            _G.SaveBindings(_G.GetCurrentBindingSet())
        else
            bindings[buttonName] = composed
        end
        Say("%s bound to %s.", _G.GetBindingText(composed, 1), buttonName)
    end

    private.QueueSecure(private.ApplyBindings)
    return true
end

function private.ToggleBindMode()
    if _G.InCombatLockdown() then
        _G.print("|cff30d0ffRealUI ActionBars|r: cannot bind in combat.")
        return
    end

    if catcher and catcher:IsShown() then
        catcher:Hide()
        _G.print("|cff30d0ffRealUI ActionBars|r: keybind mode OFF.")
        return
    end

    if not catcher then
        catcher = _G.CreateFrame("Frame", nil, _G.UIParent)
        catcher:SetFrameStrata("FULLSCREEN_DIALOG")
        catcher:EnableKeyboard(true)
        catcher:SetScript("OnKeyDown", function(self, key)
            -- Swallow the key only when it landed on one of our buttons.
            self:SetPropagateKeyboardInput(not HandleBind(key))
        end)
        catcher:SetScript("OnMouseDown", function(self, mouseButton)
            local n = mouseButton:match("^Button(%d+)$")
            if n then HandleBind("BUTTON" .. n) end
        end)
    end
    catcher:Show()
    _G.print("|cff30d0ffRealUI ActionBars|r: keybind mode ON — hover a button and press a key (ESC clears). /rab bind to exit.")
end
