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
    -- commands press our equivalent buttons. Keyed by the PAGE a bar shows
    -- (B151, Bar.lua PAGE_BINDINGS): bar 1 = ACTIONBUTTON, and a bar on a
    -- Blizzard multibar's page takes that multibar's MULTIACTIONBAR command.
    -- Bartender mode: bars 3-6 mirror, bar 2 (page 2, no Blizzard binding
    -- set) is capture-only. Blizzard mode: bars 2-6 mirror Blizzard bars 2-6.
    for barID = 1, 6 do
        local commandFormat = private.GetBindingFormat(barID)
        if commandFormat then
            for i = 1, 12 do
                local buttonName = ("RealUI_AB_Bar%dB%d"):format(barID, i)
                local keys = { _G.GetBindingKey(commandFormat:format(i)) }
                for k = 1, #keys do
                    _G.SetOverrideBindingClick(bindingOwner, false, keys[k], buttonName, "LeftButton")
                end
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

-- RealUI is an optional dependency; without it a string reads as its key.
local L = _G.RealUI and _G.RealUI.L or _G.setmetatable({}, { __index = function(_, key) return key end })

local catcher, warningBox, pendingAction
local BOX_WIDTH, BOX_PADDING, EXIT_HEIGHT = 380, 14, 22
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

     Bars 1 and 3-6 (2-6 with Blizzard page numbering, B151) mirror a
     Blizzard command (`keyBoundTarget`, set in Bar.lua): the key the button DISPLAYS is whatever the game's own binding
     set holds for that command, and Bar 1 presses via that command too. Our
     profile table never held those keys, so ESC on such a button printed
     "cleared" while removing nothing, and the hotkey stayed on the button
     (post-4.0.1 report). Bind and clear on these go through SetBinding on the
     command — the same thing LibActionButton's SetKey/ClearBindings do —
     followed by SaveBindings so the change survives a reload.

     Bar 2 in Bartender mode has no Blizzard command; its captures live in
     the profile and are applied as override bindings by ApplyBindings.

     B202: a key left to this code used to rewrite the game's bindings on the
     spot, so W with the cursor resting on a bar took W off Move Forward and
     saved it. A key that already does something else now asks in the warning
     box and still acts as normal; only the box's button writes. Refusing such
     keys outright would stop a player taking Q off strafe on purpose. ]]--
local function ShowPrompt(text, confirmLabel, action)
    pendingAction = action
    local box = warningBox
    box.body:SetText(text or L["ActionBars_KeybindModeDesc"])
    box.exit:ClearAllPoints()
    if action then
        box.confirm:SetText(confirmLabel)
        box.confirm:Show()
        box.exit:SetPoint("TOPLEFT", box.body, "BOTTOM", 5, -10)
    else
        box.confirm:Hide()
        box.exit:SetPoint("TOP", box.body, "BOTTOM", 0, -10)
    end
    box:SetHeight(BOX_PADDING * 2 + box.title:GetStringHeight() + 8 + box.body:GetStringHeight() + 10 + EXIT_HEIGHT)
end

-- What already answers to this key, other than this button. Bar 2's captures
-- are override bindings, which hide the game's binding rather than replace it,
-- so the game's set is checked for them too.
local function GetKeyHolder(key, buttonName, target)
    for otherName, otherKey in _G.next, AB.db.profile.bindings do
        if otherKey == key and otherName ~= buttonName then
            return otherName
        end
    end
    local action = _G.GetBindingAction(key)
    if action and action ~= "" and action ~= target then
        return _G.GetBindingName(action)
    end
end

local function GetButtonKeys(buttonName, target)
    local names = {}
    local custom = AB.db.profile.bindings[buttonName]
    if custom then
        names[1] = _G.GetBindingText(custom, 1)
    end
    if target then
        local keys = { _G.GetBindingKey(target) }
        for k = 1, #keys do
            names[#names + 1] = _G.GetBindingText(keys[k], 1)
        end
    end
    return names
end

local function ClearKeys(buttonName, target)
    local cleared = GetButtonKeys(buttonName, target)
    AB.db.profile.bindings[buttonName] = nil
    if target then
        local keys = { _G.GetBindingKey(target) }
        for k = 1, #keys do
            _G.SetBinding(keys[k], nil)
        end
        if #keys > 0 then
            _G.SaveBindings(_G.GetCurrentBindingSet())
        end
    end
    local button = _G[buttonName]
    if button and button.HotKey then
        button.HotKey:SetText("")
    end
    Say("cleared %s on %s.", _G.table.concat(cleared, ", "), buttonName)
    private.QueueSecure(private.ApplyBindings)
end

local function BindKey(buttonName, target, composed)
    local bindings = AB.db.profile.bindings
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
    private.QueueSecure(private.ApplyBindings)
end

local function HandleBind(key)
    -- ESC with a question up drops it and goes on to the game menu.
    if key == "ESCAPE" and pendingAction then
        ShowPrompt()
        return false
    end

    local buttonName = GetHoveredButton()
    if not buttonName then return false end

    local button = _G[buttonName]
    local target = button and button.config and button.config.keyBoundTarget

    -- SetBinding is refused in combat. Bind mode refuses to START in combat
    -- and combat ends it (ToggleBindMode), so this only covers a key that
    -- lands before PLAYER_REGEN_DISABLED has been delivered.
    if target and _G.InCombatLockdown() then
        Say("cannot change bindings in combat.")
        return true
    end

    if key == "ESCAPE" then
        local names = GetButtonKeys(buttonName, target)
        if #names > 0 then
            ShowPrompt(L["ActionBars_KeybindModeClearDesc"]:format(_G.table.concat(names, ", ")),
                L["ActionBars_KeybindModeClear"],
                function() ClearKeys(buttonName, target) end)
        else
            Say("nothing was bound on %s.", buttonName)
        end
        return true
    end

    if IGNORED_KEYS[key] then return false end
    local composed = ComposeKey(key)
    local holder = GetKeyHolder(composed, buttonName, target)
    if holder then
        ShowPrompt(L["ActionBars_KeybindModeReplaceDesc"]:format(_G.GetBindingText(composed, 1), holder),
            L["ActionBars_KeybindModeReplace"],
            function() BindKey(buttonName, target, composed) end)
        return false
    end

    ShowPrompt()
    BindKey(buttonName, target, composed)
    return true
end

--[[ B202: the mode outlives the config window that started it, and a key
     pressed over a button rewrites the game's binding set, so it has to say so
     for as long as it is on.

     The box is a child of the catcher: every way the catcher hides takes the
     box with it, so no exit path can leave it behind. It is deliberately not
     in UISpecialFrames, where ESC would hide the warning and leave the mode on.
     TOOLTIP strata because AceGUI windows share the catcher's strata and would
     cover the box. ]]--
local function CreateWarningBox(parent)
    local box = _G.CreateFrame("Frame", "RealUI_AB_KeybindWarning", parent)
    warningBox = box
    box:SetFrameStrata("TOOLTIP")
    box:SetSize(BOX_WIDTH, 100) -- height set once the text is measured
    box:SetPoint("TOP", _G.UIParent, "TOP", 0, -64) -- under the HuD config bar
    box:EnableMouse(true)

    local Aurora = _G.Aurora
    if Aurora then
        Aurora.Base.SetBackdrop(box, Aurora.Color.frame, 0.95)
        local warning = Aurora.Color.yellow
        box:SetBackdropBorderColor(warning.r, warning.g, warning.b, 1)
    else
        local bg = box:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints()
        bg:SetColorTexture(0, 0, 0, 0.9)
    end

    local title = box:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Large")
    title:SetPoint("TOP", 0, -BOX_PADDING)
    title:SetTextColor(1, 0.82, 0)
    title:SetText(L["ActionBars_KeybindMode"])
    box.title = title

    local body = box:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    body:SetPoint("TOP", title, "BOTTOM", 0, -8)
    body:SetWidth(BOX_WIDTH - BOX_PADDING * 2)
    box.body = body

    local exit = _G.CreateFrame("Button", nil, box, "UIPanelButtonTemplate")
    exit:SetSize(170, EXIT_HEIGHT)
    exit:SetText(L["ActionBars_KeybindModeExit"])
    exit:SetScript("OnClick", function() private.ToggleBindMode() end)
    box.exit = exit

    local confirm = _G.CreateFrame("Button", nil, box, "UIPanelButtonTemplate")
    confirm:SetSize(170, EXIT_HEIGHT)
    confirm:SetPoint("TOPRIGHT", body, "BOTTOM", -5, -10)
    confirm:SetScript("OnClick", function()
        local action = pendingAction
        ShowPrompt()
        if action then action() end
    end)
    box.confirm = confirm

    local Skin = Aurora and Aurora.Skin
    if Skin and Skin.UIPanelButtonTemplate then
        Skin.UIPanelButtonTemplate(exit)
        Skin.UIPanelButtonTemplate(confirm)
    end

    ShowPrompt()
end

function private.ToggleBindMode()
    -- Leaving comes first and is allowed in combat: hiding our own frame is
    -- not restricted, and an exit that can be refused is no exit.
    if catcher and catcher:IsShown() then
        catcher:Hide()
        _G.print("|cff30d0ffRealUI ActionBars|r: keybind mode OFF.")
        return
    end

    if _G.InCombatLockdown() then
        _G.print("|cff30d0ffRealUI ActionBars|r: cannot bind in combat.")
        return
    end

    if not catcher then
        catcher = _G.CreateFrame("Frame", "RealUI_AB_KeybindCatcher", _G.UIParent)
        catcher:SetFrameStrata("FULLSCREEN_DIALOG")
        catcher:EnableKeyboard(true)
        catcher:SetScript("OnKeyDown", function(self, key)
            -- Swallow only a key that bound or asked over ESC: anything else,
            -- a key that is asking included, still reaches the game.
            self:SetPropagateKeyboardInput(not HandleBind(key))
        end)
        catcher:SetScript("OnMouseDown", function(self, mouseButton)
            local n = mouseButton:match("^Button(%d+)$")
            if n then HandleBind("BUTTON" .. n) end
        end)
        -- Combat ends the mode. SetPropagateKeyboardInput is refused to
        -- insecure code in combat (10.1.5), so OnKeyDown would raise a blocked
        -- action on every key and leave propagation as the last key set it:
        -- after a swallowed key, the whole keyboard stays swallowed.
        catcher:RegisterEvent("PLAYER_REGEN_DISABLED")
        catcher:SetScript("OnEvent", function(self)
            if self:IsShown() then
                self:Hide()
                Say(L["ActionBars_KeybindModeCombat"])
            end
        end)
        CreateWarningBox(catcher)
        catcher:SetScript("OnHide", function() ShowPrompt() end)
    end
    catcher:Show()
    _G.print("|cff30d0ffRealUI ActionBars|r: keybind mode ON — hover a button and press a key (ESC clears). /rab bind to exit.")
end
