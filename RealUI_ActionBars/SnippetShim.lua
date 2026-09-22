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
}

function private.SecureSnippetsBroken()
    local _, build, _, interface = _G.GetBuildInfo()
    local isForever = interface >= 16000 and interface < 20000
    return isForever and BROKEN_SECURE_SNIPPET_BUILDS[build] == true
end

-- LAB wraps every button's OnClick with a secure pre-snippet (flyout
-- handling). Here that wrapper fails to compile on every click and aborts it
-- before SecureActionButton_OnClick ever runs — measured 2026-09-22: the
-- attributes were right and a bare SecureActionButtonTemplate cast, but
-- `/click` on a LAB button did nothing. UnwrapScript compiles nothing; taking
-- the wrapper off restores the template's own click. The OnDragStart and
-- OnReceiveDrag wrappers are left in place, so dragging onto the bars stays
-- dead, like flyouts. LAB only re-wraps in NewHeader, which RealUI never
-- calls after creation, so once per button is enough.
local unwrapped = _G.setmetatable({}, { __mode = "k" })
local function UnwrapClick(button)
    if unwrapped[button] then return end
    local header = button.header
    if not (header and header.UnwrapScript) then return end
    for _ = 1, 4 do
        local ok, wrapper = _G.pcall(header.UnwrapScript, header, button, "OnClick")
        if not ok or not wrapper then break end
    end
    unwrapped[button] = true
end

-- Mirror of LAB's `UpdateState` snippet for one button and state.
local function ApplyButtonState(button, state)
    UnwrapClick(button)
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

local hooked = false
function private.SetupSnippetShim()
    if not private.SecureSnippetsBroken() then return end

    private.QueueSecure(ApplyAll)

    if not hooked then
        hooked = true
        _G.print("|cff30d0ffRealUI ActionBars|r: this Forever build cannot run secure handler snippets (a Blizzard load-order bug), so bar paging is applied from plain Lua out of combat. Flyouts do not work until Blizzard fixes it.")

        -- Re-apply whenever a driver flips a bar's page or visibility (out of
        -- combat: in combat the work is queued and lands on PLAYER_REGEN_ENABLED).
        for id = 1, 6 do
            local bar = AB.bars[id]
            if bar then
                bar:HookScript("OnAttributeChanged", function(_, name)
                    if name == "state-page" then
                        private.QueueSecure(function() ApplyBar(bar) end)
                    elseif name == "state-vis" then
                        private.QueueSecure(function() ApplyBarVisibility(bar) end)
                    end
                end)
            end
        end
    end
end

-- Called from the addon's PLAYER_ENTERING_WORLD handler (zone changes rebuild
-- Blizzard state the driver re-evaluates).
function private.ReapplySnippetShim()
    if private.SecureSnippetsBroken() then
        private.QueueSecure(ApplyAll)
    end
end
