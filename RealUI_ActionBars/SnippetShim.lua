local _, private = ...
local AB = private.AB

--[[ WoW Forever secure-snippet shim.

     Forever 1.60.1 (69913) ships a Blizzard load-order bug: the
     Blizzard_EnvironmentCleanup TOC tags its dependency on
     Blizzard_RestrictedAddOnEnvironment `[AllowLoadGameType classic, standard]`
     without camelot, so on Forever the LoadFirst cleanup nils the client's
     `loadstring_untainted` before RestrictedExecution.lua captures it, and no
     secure handler snippet compiles ("attempt to call a nil value" at
     RestrictedExecution.lua:79). LibActionButton sets each button's `type`
     and `action` attributes from its `UpdateState` snippet, and bar 1's page
     reaches the buttons through the header's `_onstate-page` snippet, so on
     this build the buttons draw but cast nothing.

     What still works: the state driver is C-side and keeps writing
     `state-page` on the header, and setting attributes on a secure button from
     addon code OUT OF COMBAT is the supported pattern SecureActionButtonTemplate
     is built on. So this mirrors, in plain Lua and only out of combat, what
     LAB's `UpdateState` snippet does for the current state. Paging cannot
     change during combat and flyouts stay dead; keys and clicks cast.

     Gated on a list of builds known to ship the bug — there is no quiet way
     to probe snippet compilation from addon code (both attempts, the attribute
     route and CallRestrictedClosure, are recorded in the realui-forever tasks
     file). A new build drops out by itself; if LibActionButton still logs
     RestrictedExecution.lua:79 there, add it. Remove the whole file once
     Blizzard adds `camelot` to that Dep line. ]]--

local BROKEN_SECURE_SNIPPET_BUILDS = {
    ["69913"] = true, -- 1.60.1, 2026-09-22
    ["69977"] = true, -- 1.60.1, 2026-09-23
}

function private.SecureSnippetsBroken()
    -- RealUI core keeps the list of record (RealUI.BROKEN_SECURE_SNIPPET_BUILDS,
    -- Init.lua) so the action bars and the group frames agree; the local list
    -- only serves a standalone install without RealUI.
    local RealUI = _G.RealUI
    if RealUI and RealUI.SecureSnippetsBroken then
        return RealUI.SecureSnippetsBroken()
    end
    local _, build, _, interface = _G.GetBuildInfo()
    local isForever = interface >= 16000 and interface < 20000
    return isForever and BROKEN_SECURE_SNIPPET_BUILDS[build] == true
end

-- LAB wraps every button's OnClick, OnDragStart and OnReceiveDrag with secure
-- pre-snippets. Here each wrapper fails to compile on use and aborts the
-- event before anything else runs — measured 2026-09-22: the attributes were
-- right and a bare SecureActionButtonTemplate cast, but `/click` on a LAB
-- button did nothing, and shift-drag moved nothing. UnwrapScript compiles
-- nothing; taking the wrappers off restores the template's own click. The
-- drag scripts have nothing underneath (LAB nils them and drives drag purely
-- from snippets), so plain Lua handlers go in that mirror the snippets' rules
-- for action-type buttons, which is all RealUI's bars are: pickup honours the
-- bar lock plus the PICKUPACTION modifier, drop is PlaceAction, both out of
-- combat only. Left dead: dropping by click (LAB's PostClick runs that through
-- the header) and flyouts. LAB only re-wraps in NewHeader, which RealUI never
-- calls after creation, so once per button is enough.
local function Unwrap(header, button, script)
    for _ = 1, 4 do
        local ok, wrapper = _G.pcall(header.UnwrapScript, header, button, script)
        if not ok or not wrapper then break end
    end
end

local function OnDragStart(button)
    if _G.InCombatLockdown() then return end
    if button:GetAttribute("buttonlock") and not _G.IsModifiedClick("PICKUPACTION") then return end
    if button:GetAttribute("LABdisableDragNDrop") then return end
    if button:GetAttribute("type") ~= "action" then return end
    local action = button:GetAttribute("action")
    if action then
        _G.PickupAction(action)
    end
end

local function OnReceiveDrag(button)
    if _G.InCombatLockdown() then return end
    if button:GetAttribute("LABdisableDragNDrop") then return end
    if button:GetAttribute("type") ~= "action" then return end
    if not _G.GetCursorInfo() then return end
    local action = button:GetAttribute("action")
    if action then
        _G.PlaceAction(action)
    end
end

local unwrapped = _G.setmetatable({}, { __mode = "k" })
local function UnwrapButton(button)
    if unwrapped[button] then return end
    local header = button.header
    if not (header and header.UnwrapScript) then return end
    Unwrap(header, button, "OnClick")
    Unwrap(header, button, "OnDragStart")
    Unwrap(header, button, "OnReceiveDrag")
    button:SetScript("OnDragStart", OnDragStart)
    button:SetScript("OnReceiveDrag", OnReceiveDrag)
    unwrapped[button] = true
end

-- Mirror of LAB's `UpdateState` snippet for one button and state.
local function ApplyButtonState(button, state)
    UnwrapButton(button)
    state = _G.tostring(state)
    button:SetAttribute("state", state)
    local kind = button:GetAttribute("labtype-" .. state) or "empty"
    local action = button:GetAttribute("labaction-" .. state)

    button:SetAttribute("type", kind)
    if kind ~= "empty" and kind ~= "custom" then
        local field = (kind == "pet") and "action" or kind
        button:SetAttribute(field, action)
        button:SetAttribute("action_field", field)
    end
    -- Press-and-hold needs GetActionInfo inside the snippet; plain release
    -- semantics are enough for a stand-in.
    button:SetAttribute("typerelease", kind == "action" and "actionrelease" or nil)
    button:SetAttribute("pressAndHoldAction", false)

    -- LAB's Lua side re-reads the `state` attribute for what to draw.
    if button.UpdateAction then
        button:UpdateAction()
    end
end

local function BarState(bar)
    if bar.id == 1 then
        -- Written by the C-side state driver even though its snippet is dead.
        return bar:GetAttribute("state-page") or "0"
    end
    return "0"
end

-- Mirror of Visibility.lua's `_onstate-vis` snippet: the driver still writes
-- `state-vis` (C-side); only the show/hide it should trigger is dead. This is
-- what keeps the Naga bar (and any bar with a visibility conditional) hidden.
local function ApplyBarVisibility(bar)
    local vis = bar:GetAttribute("state-vis")
    if vis ~= nil then
        bar:SetShown(vis ~= "hide")
    end
end

local function ApplyBar(bar)
    local state = BarState(bar)
    for i = 1, #bar.buttons do
        ApplyButtonState(bar.buttons[i], state)
    end
    ApplyBarVisibility(bar)
end

local function ApplyAll()
    for id = 1, 6 do
        if AB.bars[id] then
            ApplyBar(AB.bars[id])
        end
    end
end

-- The drivers keep writing `state-page` / `state-vis`, but a HookScript on
-- OnAttributeChanged never sees it here: the template's own handler runs
-- first, tries the dead `_onstate-*` snippet, errors, and a post-hook does not
-- run after the original errors (measured 2026-09-22: bar 6 hidden with
-- `state-vis` = "show"). So the driver outputs are polled instead. Cheap: two
-- attribute reads per bar, four times a second, only on the affected builds.
local lastPage, lastVis = {}, {}
local ticker
local function Poll()
    for id = 1, 6 do
        local bar = AB.bars[id]
        if bar then
            local page = (id == 1) and bar:GetAttribute("state-page") or nil
            local vis = bar:GetAttribute("state-vis")
            if page ~= lastPage[bar] then
                lastPage[bar] = page
                private.QueueSecure(function() ApplyBar(bar) end)
            end
            if vis ~= lastVis[bar] then
                lastVis[bar] = vis
                private.QueueSecure(function() ApplyBarVisibility(bar) end)
            end
        end
    end
end

function private.SetupSnippetShim()
    if not private.SecureSnippetsBroken() then return end

    private.QueueSecure(ApplyAll)

    if not ticker then
        _G.print("|cff30d0ffRealUI ActionBars|r: this Forever build cannot run secure handler snippets (a Blizzard load-order bug), so bar paging and visibility are applied from plain Lua out of combat. Flyouts do not work until Blizzard fixes it.")
        ticker = _G.C_Timer.NewTicker(0.25, Poll)
    end
end

-- Called from the addon's PLAYER_ENTERING_WORLD handler (zone changes rebuild
-- Blizzard state the driver re-evaluates).
function private.ReapplySnippetShim()
    if private.SecureSnippetsBroken() then
        private.QueueSecure(ApplyAll)
    end
end
