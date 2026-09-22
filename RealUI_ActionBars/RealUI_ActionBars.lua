local _, private = ...

--[[ RealUI_ActionBars (spec: realui-actionbars, de-bundling 3/3)

     Clean-room action bars. Button behavior (cooldowns, range, charges,
     flyouts, glow, drag&drop) comes from LibActionButton-1.0 (BSD-3, verified
     2026-08-15). Bar layout, paging map, visibility grammar, fade, bindings,
     and profiles are ours. No Bartender4 code was referenced. ]]--

-- NOT "RealUI_ActionBars": AceAddon registers RealUI core's "ActionBars"
-- MODULE under that exact name (<parent>_<module>), so the obvious name
-- collides at NewAddon.
local AB = _G.LibStub("AceAddon-3.0"):NewAddon("RealUIActionBars", "AceEvent-3.0")
private.AB = AB
AB.bars = {}

--[[ Combat lockdown queue: every secure write funnels through here ]]--

local pending = {}
function private.QueueSecure(fn)
    if not _G.InCombatLockdown() then return fn() end
    pending[#pending + 1] = fn
end

function AB:PLAYER_REGEN_ENABLED()
    local queue = pending
    pending = {}
    for i = 1, #queue do queue[i]() end
end

--[[ Lifecycle ]]--

function AB:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_ActionBarsDB", private.defaults, true)

    -- Coordinator-compatible namespace shape (spec req 8.1): RealUI's profile
    -- machinery pattern-matches <DB>.namespaces.<Module>.profiles[<name>].
    self.dbActionBars = self.db:RegisterNamespace("ActionBars", private.nsDefaults.ActionBars)
    self.dbPetBar = self.db:RegisterNamespace("PetBar", private.nsDefaults.PetBar)
    self.dbStanceBar = self.db:RegisterNamespace("StanceBar", private.nsDefaults.StanceBar)
    self.dbVehicle = self.db:RegisterNamespace("Vehicle", private.nsDefaults.Vehicle)

    local LibDualSpec = _G.LibStub("LibDualSpec-1.0", true)
    if LibDualSpec then
        LibDualSpec:EnhanceDatabase(self.db, "RealUI_ActionBars")
    end

    self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileCopied", "OnProfileUpdate")
    self.db.RegisterCallback(self, "OnProfileReset", "OnProfileUpdate")

    -- One-shot Bartender4 conversion. MUST be here rather than in OnEnable:
    -- Bartender4DB is only in memory while BT4 is installed, and OnEnable
    -- stands this addon down whenever it is — so init is the single moment an
    -- upgrading user's layout and keybinds can be captured. No-op after the
    -- first run (db.global.importedBT4) and when no BT4 data exists.
    if private.MaybeImportFromBartender4 then
        _G.pcall(private.MaybeImportFromBartender4)
    end
end

-- WoW Forever 1.60.1 (69913) ships a Blizzard load-order bug: the
-- Blizzard_EnvironmentCleanup TOC tags its dependency on
-- Blizzard_RestrictedAddOnEnvironment `[AllowLoadGameType classic, standard]`,
-- without camelot, so on Forever the LoadFirst cleanup can nil the client's
-- `loadstring_untainted` before RestrictedExecution.lua captures it. Every
-- secure snippet then dies with "attempt to call a nil value"
-- (RestrictedExecution.lua:79). LibActionButton logs that once per button at
-- login; its flyouts are dead there and, without help, so are its buttons —
-- the `type`/`action` attributes come from a snippet too. SnippetShim.lua
-- mirrors that snippet in plain Lua out of combat on the affected builds.
-- The one-line fix is Blizzard's (add `camelot` to that Dep line).

function AB:OnEnable()
    -- Bartender4 coexistence stand-down (same pattern as RealUI_Nameplates vs
    -- Platynator): RealUI 4.0 removed BT4 support entirely, but a user-installed
    -- BT4 would otherwise double up the bars — so we yield rather than fight.
    -- RealUI no longer drives BT4 in any way; disable BT4 to get RealUI bars.
    if _G.C_AddOns.IsAddOnLoaded("Bartender4") then
        -- /rab import remains available for users who want their custom BT4
        -- tweaks (keybinds, visibility strings, Naga toggle) carried over.
        _G.print("|cff30d0ffRealUI ActionBars|r: disabled — Bartender4 is loaded. RealUI no longer integrates with Bartender4; disable it to use RealUI's bars. (/rab import copies your old BT4 keybinds and tweaks.)")
        self:Disable()
        return
    end

    self:RegisterEvent("PLAYER_REGEN_ENABLED")

    private.QueueSecure(private.HideBlizzardBars)
    -- EditMode re-applies its layout after login/zoning and can resurrect the
    -- Blizzard bars; re-suppress each time.
    self:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        private.QueueSecure(private.HideBlizzardBars)
        -- The zone-ability frames get recreated/re-laid-out on zone changes.
        private.QueueSecure(private.ApplyExtraButtons)
        private.QueueSecure(private.ApplyVehicleButton)
        if private.ReapplySnippetShim then private.ReapplySnippetShim() end
        -- B65: the Infobar can be built after our OnEnable, so the watcher
        -- may not have had a frame to attach to yet. Idempotent.
        if private.WatchInfobarHeight then private.WatchInfobarHeight() end
    end)
    self:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", function()
        private.QueueSecure(private.HideBlizzardBars)
        -- Task 4.2: EditMode owns the vehicle-exit button's anchor; re-assert
        -- ours after every layout apply (B68/B29 stomp pattern).
        private.QueueSecure(private.ApplyVehicleButton)
    end)
    private.BuildBars()
    -- Forever 69913: LAB's state snippets cannot compile; mirror them in Lua.
    if private.SetupSnippetShim then private.SetupSnippetShim() end
    -- Skins before ApplyAllBars: the button-inset pass needs the skin's
    -- visual-cell frames to exist.
    if private.SetupSkins then private.SetupSkins() end
    -- RealUI drives the layout when present (computed from HuD settings — no
    -- Bartender involved, ever); static defaults otherwise. Errors here must
    -- not take the bindings/stance/pet setup below down with them.
    local ok, applied, reason = _G.pcall(private.ApplyRealUILayout)
    if not ok then
        _G.print("|cff30d0ffRealUI ActionBars|r: layout error — " .. _G.tostring(applied))
        _G.pcall(private.ApplyAllBars)
    elseif not applied then
        if reason then
            _G.print("|cff30d0ffRealUI ActionBars|r: using standalone layout (" .. reason .. ")")
        end
        private.ApplyAllBars()
    end
    _G.pcall(private.SetupRealUIIntegration)

    -- RealUI core's ActionBars module also claims /naga (its handler drives
    -- Bartender4 — a silent no-op without it). Its AceConsole registration
    -- lands after our file-scope one, so reclaim the hash mapping here.
    _G.hash_SlashCmdList["/NAGA"] = "REALUIABNAGA"
    private.QueueSecure(private.BuildStancePetBars)
    private.QueueSecure(private.ApplyExtraButtons)
    private.QueueSecure(private.ApplyVehicleButton)
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", function()
        private.QueueSecure(private.BuildStanceBar)
    end)
    private.ApplyBindings()
    self:RegisterEvent("UPDATE_BINDINGS", function()
        private.QueueSecure(private.ApplyBindings)
    end)

    -- Button lock follows the game's "Lock Action Bars" checkbox; re-apply
    -- when it changes and refresh the readout in our config panel.
    self:RegisterEvent("CVAR_UPDATE", function(_, cvar)
        if cvar == "lockActionBars" then
            private.QueueSecure(private.ApplyButtonLock)
            local registry = _G.LibStub("AceConfigRegistry-3.0", true)
            if registry then
                registry:NotifyChange("RealUI_ActionBars")
            end
        end
    end)
end

function AB:OnProfileUpdate()
    private.QueueSecure(function()
        private.ApplyAllBars()
        private.ApplyBindings()
    end)
end

--[[ Blizzard action bar suppression: with Bartender4 out of the picture,
     nothing else parks Blizzard's bars. Reparent the action-button containers
     to a hidden frame (pcall-guarded, reversible on disable); the stance and
     pet bars stay Blizzard's — StancePetBar.lua adopts their buttons.

     B51/B55 — PARKING A BAR IS NOT THE SAME AS SILENCING IT.

     `Suppress` only ever reparented. Every parked bar kept its event
     registrations, every parked BUTTON kept its own, and nothing was ever
     Hide()n — they are invisible purely because the hider frame is. So
     Blizzard's handlers went on running normally, on frames whose parent
     chain is now addon-owned, and both captured combat errors are exactly
     those handlers reaching a protected call:

       ActionButton:OnEvent -> OnActionBarSlotChanged -> UpdateAction ->
         ActionBar:UpdateShownButtons -> MultiBarBottomLeftButton1:SetShown()
       ActionButton:OnEvent -> ActionButton_UpdateCooldown ->
         ActionButton_ApplyCooldown -> ...Button4Cooldown:SetCooldown()

     Both are new behaviour dating from the BT4 removal (2026-08-22).

     The other two hypotheses are disproved, not merely unlikely:
       A. Aurora skinning the parked buttons — its MultiActionBar path is gated
          `not private.disabled.mainmenubar and private.isClassic`, and
          RealUI_Skins sets that flag (`RealUI_Skins.lua:666`).
       C. RealUI_Skins frame stripes — `AddFrameStripes` runs only from the
          `Skin.FrameTypeFrame` / `PanelTabButtonTemplate` hooks, which never
          fire for a frame Aurora never skins.
     RealUI_Skins is named in the blame string as a bystander: taint spreads
     through the execution, and it is the addon with the widest hook surface. ]]--

--- Make a key on a frame secure again after an insecure write.
--
-- Taint is tracked per key, and the bookkeeping only re-evaluates when the
-- table is written to again — so a key stays marked until something disturbs
-- it. Poking throwaway numeric keys is the community-standard way to force
-- that re-evaluation. Bounded, unlike the usual `repeat until` form: a key
-- that never comes back clean must not hang the client.
local function ScrubKey(frame, key)
    frame[key] = nil
    if _G.issecurevariable(frame, key) then return true end

    for i = 42, 442 do
        if frame[i] == nil then
            frame[i] = nil
        end
        if _G.issecurevariable(frame, key) then return true end
    end
    return false
end

--- Stop a parked bar from running Blizzard's update code at all.
local function SilenceFrame(frame, clearEvents)
    if clearEvents then
        _G.pcall(frame.UnregisterAllEvents, frame)
    end

    -- EditMode REPLACES Hide() on the systems it manages, and calling that
    -- override from insecure code taints the system; HideBase is the original.
    if frame.HideBase then
        _G.pcall(frame.HideBase, frame)
    else
        _G.pcall(frame.Hide, frame)
    end

    -- EditMode's "something outside me is showing this" flag. Left set on a
    -- frame we just parked, it invites the system to show it straight back.
    if frame.system and frame.isShownExternal ~= nil then
        ScrubKey(frame, "isShownExternal")
    end
end

--- Silence one replaced action button.
local function SilenceButton(button)
    if not button then return end
    _G.pcall(button.UnregisterAllEvents, button)
    _G.pcall(button.Hide, button)
    -- Consulted by the secure state drivers before a button is shown again.
    -- Legal out of combat only, which is what QueueSecure guarantees.
    _G.pcall(button.SetAttribute, button, "statehidden", true)
    -- Sever the button -> bar backlink so the bar's own update loops skip it.
    button.bar = nil
end

local blizzHider
local suppressedBars = {}
-- Known container names, plus the bags bar and micro menu (BT4's HideBlizzard
-- used to park those for RealUI).
local BLIZZARD_BARS = {
    "MainMenuBar", "MainActionBar", "MultiBarBottomLeft", "MultiBarBottomRight",
    "MultiBarRight", "MultiBarLeft", "MultiBar5", "MultiBar6", "MultiBar7",
    "BagsBar", "MicroMenuContainer",
    -- XP/rep tracking bars (the RealUI infobar shows these; BT4's art module
    -- used to park them)
    "StatusTrackingBarManager", "MainStatusTrackingBarContainer", "SecondaryStatusTrackingBarContainer",
    -- Containers only: the stance/pet BUTTONS get adopted into our own bars
    -- (StancePetBar.lua) before these empty shells are parked.
    "StanceBar", "PetActionBar", "PossessActionBar",
}
-- Frame names churn across EditMode reworks; the action BUTTONS are stable,
-- so also discover each bar container by walking up from button 1.
local ANCHOR_BUTTONS = {
    "ActionButton1", "MultiBarBottomLeftButton1", "MultiBarBottomRightButton1",
    "MultiBarRightButton1", "MultiBarLeftButton1",
    "MultiBar5Button1", "MultiBar6Button1", "MultiBar7Button1",
}

-- Bars RealUI REPLACES outright: silence the container and its 12 buttons
-- (B51/B55). Deliberately not here:
--   StanceBar / PetActionBar — StancePetBar.lua adopts their buttons and
--     depends on Blizzard's own update logic to drive icons and cooldowns.
--     Unregistering those events would leave the adopted buttons blank.
--   PossessActionBar, BagsBar, MicroMenuContainer, the status tracking bars —
--     no button-update path and no reported errors; parking is enough.
local REPLACED_BARS = {
    { frame = "MainMenuBar",         buttons = nil,                          clearEvents = false },
    { frame = "MainActionBar",       buttons = "ActionButton",               clearEvents = false },
    { frame = "MultiBarBottomLeft",  buttons = "MultiBarBottomLeftButton",   clearEvents = true },
    { frame = "MultiBarBottomRight", buttons = "MultiBarBottomRightButton",  clearEvents = true },
    { frame = "MultiBarRight",       buttons = "MultiBarRightButton",        clearEvents = true },
    { frame = "MultiBarLeft",        buttons = "MultiBarLeftButton",         clearEvents = true },
    { frame = "MultiBar5",           buttons = "MultiBar5Button",            clearEvents = true },
    { frame = "MultiBar6",           buttons = "MultiBar6Button",            clearEvents = true },
    { frame = "MultiBar7",           buttons = "MultiBar7Button",            clearEvents = true },
}
-- MainMenuBar (<= 11.2.5) and MainActionBar (>= 11.2.7) are the same bar under
-- two names across client versions; whichever exists owns ActionButton1..12.

local function Suppress(frame, key)
    if not frame then return end
    local ok, parent = _G.pcall(frame.GetParent, frame)
    if not ok or parent == blizzHider or frame == blizzHider then return end
    -- EditMode can reparent bars back when it applies layouts; remember the
    -- ORIGINAL parent once, re-suppress every time.
    if _G.pcall(frame.SetParent, frame, blizzHider) and not suppressedBars[key] then
        suppressedBars[key] = { frame = frame, parent = parent or _G.UIParent }
    end
end

-- Silencing is one-way (events cannot be handed back) so it runs ONCE per
-- frame, unlike Suppress, which re-runs on every EditMode layout apply.
local silenced = {}
local function SilenceReplacedBars()
    for _, bar in _G.ipairs(REPLACED_BARS) do
        local frame = _G[bar.frame]
        if frame and not silenced[bar.frame] then
            silenced[bar.frame] = true
            SilenceFrame(frame, bar.clearEvents)
            if bar.buttons then
                for i = 1, 12 do
                    SilenceButton(_G[bar.buttons .. i])
                end
            end
        end
    end
end

function private.HideBlizzardBars()
    blizzHider = blizzHider or _G.CreateFrame("Frame", "RealUI_AB_BlizzHider", _G.UIParent)
    blizzHider:Hide()

    -- Before the reparent: a silenced bar has nothing left to run, so the
    -- parent swap cannot strand a handler mid-flight.
    SilenceReplacedBars()

    for _, name in _G.ipairs(BLIZZARD_BARS) do
        Suppress(_G[name], name)
    end
    for _, buttonName in _G.ipairs(ANCHOR_BUTTONS) do
        local button = _G[buttonName]
        if button then
            local ok, parent = _G.pcall(button.GetParent, button)
            if ok and parent and parent ~= _G.UIParent then
                Suppress(parent, "parentOf_" .. buttonName)
            end
        end
    end
end

function AB:OnDisable()
    for key, info in _G.next, suppressedBars do
        _G.pcall(info.frame.SetParent, info.frame, info.parent)
        suppressedBars[key] = nil
    end
    -- Parenting is reversible; silencing is not — UnregisterAllEvents discards
    -- the registration list, and Blizzard rebuilds it only at load. A session
    -- that has silenced the bars needs a reload to get them back.
    if _G.next(silenced) then
        _G.print("|cff30d0ffRealUI ActionBars|r: reload to restore Blizzard's action bars.")
    end
end

--[[ Slash ]]--

_G.SLASH_REALUIACTIONBARS1 = "/rab"
_G.SlashCmdList.REALUIACTIONBARS = function(input)
    input = (input or ""):lower():trim()
    if input == "bind" then
        if private.ToggleBindMode then private.ToggleBindMode() end
    elseif input == "dump" then
        for id = 1, 6 do
            local bar = AB.bars[id]
            local db = AB.dbActionBars.profile.actionbars[id]
            if bar and db then
                local point, rel, _, x, y = bar:GetPoint(1)
                local relName = rel and rel.GetName and (rel:GetName() or "?anon?") or "?nil?"
                -- Sizes print with %.4g, not %d: GetWidth/GetHeight return the
                -- on-screen rect, which carries float error at fractional
                -- anchors and non-integer UI scale (e.g. 26.9999996). %d
                -- truncates that to "26" and invents a 1px discrepancy that
                -- isn't there; %.4g rounds, and still shows genuinely
                -- fractional sizes instead of hiding them.
                _G.print(("bar%d: db=%s %s,%s r%d s%.2f | live=%s->%s %.1f,%.1f %s | frame %.4gx%.4g"):format(
                    id, db.position.point, db.position.x, db.position.y,
                    db.rows or 1, db.scale or 1,
                    point or "?", relName, x or 0, y or 0,
                    db.enabled and (bar:IsShown() and "shown" or "HIDDEN") or "disabled",
                    bar:GetWidth(), bar:GetHeight()))
                -- Button-level truth: size + the b1->b2 offset reveals the real
                -- grow orientation regardless of what the db claims.
                local b1, b2 = bar.buttons[1], bar.buttons[2]
                if b1 and b2 then
                    local b1x, b1y = b1:GetLeft(), b1:GetTop()
                    local b2x, b2y = b2:GetLeft(), b2:GetTop()
                    if b1x and b2x then
                        _G.print(("   b1 %.4gx%.4g shown=%s | b2 delta %.1f,%.1f"):format(
                            b1:GetWidth(), b1:GetHeight(), _G.tostring(b1:IsShown()),
                            b2x - b1x, b2y - b1y))
                    else
                        _G.print("   b1/b2 have no rect (never laid out?)")
                    end
                end
            end
        end
    elseif input == "layout" then
        local ok, applied, reason = _G.pcall(private.ApplyRealUILayout)
        if not ok then
            _G.print("|cff30d0ffRealUI ActionBars|r: layout ERROR — " .. _G.tostring(applied))
        elseif applied then
            _G.print("|cff30d0ffRealUI ActionBars|r: RealUI HuD layout applied.")
        else
            _G.print("|cff30d0ffRealUI ActionBars|r: not applied — " .. _G.tostring(reason))
        end
    elseif input == "blizz" then
        -- Suppression report: is anything Blizzard-owned still visible?
        for key, info in _G.next, suppressedBars do
            local shown = info.frame:IsVisible() and "VISIBLE" or "hidden"
            local parent = info.frame:GetParent()
            local parentName = parent and parent:GetName() or "?"
            _G.print(("%s: %s, parent=%s"):format(key, shown, parentName))
        end
        for _, name in _G.ipairs({ "ActionButton1", "MultiBarBottomLeftButton1", "MultiBarBottomRightButton1", "PetActionButton1", "StanceButton1" }) do
            local button = _G[name]
            if button and button:IsVisible() then
                local parent = button:GetParent()
                _G.print(("%s VISIBLE, parent=%s"):format(name, parent and parent:GetName() or "?"))
            end
        end
    elseif input == "import" then
        if private.ImportFromBartender4 then private.ImportFromBartender4(true) end
    elseif private.OpenConfig then
        private.OpenConfig()
    else
        _G.print("|cff30d0ffRealUI ActionBars|r: /rab bind — keybind mode; config requires AceConfig.")
    end
end
