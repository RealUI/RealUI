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

-- Mirror of LAB's `UpdateState` snippet for one button and state.
local function ApplyButtonState(button, state)
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

local function ApplyBar(bar)
    local state = BarState(bar)
    for i = 1, #bar.buttons do
        ApplyButtonState(bar.buttons[i], state)
    end
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

        -- Re-apply whenever the driver flips bar 1's page (out of combat: in
        -- combat the value is queued and lands on PLAYER_REGEN_ENABLED).
        local bar1 = AB.bars[1]
        if bar1 then
            bar1:HookScript("OnAttributeChanged", function(_, name)
                if name == "state-page" then
                    private.QueueSecure(function() ApplyBar(bar1) end)
                end
            end)
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
