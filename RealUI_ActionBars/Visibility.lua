local _, private = ...

--[[ Visibility + fade engine.

     The config string is a WoW macro conditional whose terminal states are
     show / hide / fade, e.g.:
       "[petbattle][overridebar][vehicleui]hide;[mod:ctrl][cursor]show;fade"

     show/hide are handled SECURELY: the string goes straight into a state
     driver and the _onstate-vis snippet shows/hides the bar (combat-legal).
     fade is an alpha-only reaction (insecure is fine in combat): the bar's
     OnAttributeChanged fires when the driver flips state, and a light ticker
     restores alpha on mouseover. ]]--

local fadedBars = {}
local hoverTicker

local function UpdateHover()
    local anyFaded = false
    for bar, fadeAlpha in _G.next, fadedBars do
        anyFaded = true
        -- Widget method, not the removed MouseIsOver global (WoW 12).
        if bar:IsMouseOver() then
            bar:SetAlpha(bar._ruiAlpha or 1)
        else
            bar:SetAlpha(fadeAlpha)
        end
    end
    if not anyFaded and hoverTicker then
        hoverTicker:Cancel()
        hoverTicker = nil
    end
end

local function SetFadeState(bar, state)
    local config = bar._ruiConfig
    if state == "fade" and config then
        fadedBars[bar] = config.fadeoutalpha or 0
        bar:SetAlpha(config.fadeoutalpha or 0)
        if not hoverTicker then
            hoverTicker = _G.C_Timer.NewTicker(0.15, UpdateHover)
        end
    else
        fadedBars[bar] = nil
        bar:SetAlpha(bar._ruiAlpha or 1)
    end
end

local function OnAttributeChanged(bar, name, value)
    if name == "state-vis" then
        SetFadeState(bar, value)
    end
end

function private.SetupVisibility(bar)
    bar:SetAttribute("_onstate-vis", [[
        if newstate == "hide" then
            self:Hide()
        else
            self:Show()
        end
    ]])
    -- HookScript, NEVER SetScript: SecureHandlerStateTemplate's own
    -- OnAttributeChanged script IS the dispatcher that executes every
    -- _onstate-* snippet — replacing it silently kills paging and secure
    -- show/hide on the whole bar (fade kept working, which masked it).
    bar:HookScript("OnAttributeChanged", OnAttributeChanged)
end

function private.ApplyVisibility(bar, conditional)
    _G.UnregisterStateDriver(bar, "vis")
    fadedBars[bar] = nil
    bar:SetAlpha(bar._ruiAlpha or 1)
    if conditional and conditional ~= "" then
        -- Clear the cached state BEFORE re-registering. The secure state
        -- driver manager only writes `state-vis` when the evaluated value
        -- CHANGES, and the cached attribute survives UnregisterStateDriver —
        -- so a bar that was disabled (manually Hidden) and re-enabled
        -- evaluated to the same "show" as before, the write was skipped, the
        -- snippet never fired, and the bar stayed hidden forever (/naga
        -- re-enable, found live 2026-08-22). Out of combat this SetAttribute
        -- is legal; in combat ApplyConfig is already QueueSecure-deferred.
        bar:SetAttribute("state-vis", nil)
        _G.RegisterStateDriver(bar, "vis", conditional)
    else
        bar:Show()
    end
end

function private.ClearFade(bar)
    fadedBars[bar] = nil
end
