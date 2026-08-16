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

local function ComposeKey(key)
    local prefix = ""
    if _G.IsAltKeyDown() then prefix = "ALT-" .. prefix end
    if _G.IsControlKeyDown() then prefix = "CTRL-" .. prefix end
    if _G.IsShiftKeyDown() then prefix = "SHIFT-" .. prefix end
    return prefix .. key
end

local function HandleBind(key)
    local buttonName = GetHoveredButton()
    if not buttonName then return false end

    if key == "ESCAPE" then
        AB.db.profile.bindings[buttonName] = nil
        local button = _G[buttonName]
        if button and button.HotKey and not (button.config and button.config.keyBoundTarget) then
            button.HotKey:SetText("")
        end
        _G.print(("|cff30d0ffRealUI ActionBars|r: cleared binding on %s."):format(buttonName))
    else
        if IGNORED_KEYS[key] then return false end
        local composed = ComposeKey(key)
        -- One binding per key: drop it from any other button first.
        for otherName, otherKey in _G.next, AB.db.profile.bindings do
            if otherKey == composed then
                AB.db.profile.bindings[otherName] = nil
            end
        end
        AB.db.profile.bindings[buttonName] = composed
        _G.print(("|cff30d0ffRealUI ActionBars|r: %s bound to %s."):format(
            _G.GetBindingText(composed, 1), buttonName))
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
