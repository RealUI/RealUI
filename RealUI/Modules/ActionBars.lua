local _, private = ...

-- Lua Globals --
-- luacheck: globals math


-- RealUI --
local RealUI = private.RealUI
local db, ndb, ndbc

local MODNAME = "ActionBars"
local ActionBars = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

local EnteredWorld = false

local Textures = {
    petBar = {
        center = [[Interface\Addons\RealUI\Media\Doodads\PetBar_Center]],
        sides = [[Interface\Addons\RealUI\Media\Doodads\PetBar_Sides]],
    },
    stanceBar = {
        center = [[Interface\Addons\RealUI\Media\Doodads\StanceBar_Center]],
        sides = [[Interface\Addons\RealUI\Media\Doodads\StanceBar_Sides]],
    },
}

local Doodads = {}

-- NOTE: the button-size / padding constants, IsOdd and GetActionBarsBotY that
-- used to live here were only ever inputs to the Bartender4 layout math that
-- this module no longer performs (RealUI_ActionBars computes its own geometry
-- from the same HuD settings — see its Integration.lua). They were removed
-- with BT4 support on 2026-08-22; the equivalents in RealUI_ActionBars are
-- expressed in ITS units, not BT4's 36px/-9 overlap proportions.
-- (The long-standing FIXMELATER about refactoring hardcoded padding died with
-- that math — the data-driven layout it asked for is what RealUI_ActionBars
-- does now.)

--[[ The canonical action-bar layout signal.

     RealUI computes bar geometry from HuD settings whenever the layout, spec,
     HuD size or bar arrangement changes. Until 4.0.0 this function WROTE that
     geometry into Bartender4; BT4 support was removed 2026-08-22, so the
     write side is gone. RealUI_ActionBars derives its own layout by hooking
     this function (Integration.lua SetupRealUIIntegration -> hooksecurefunc),
     which means it must still be CALLED on every one of those triggers even
     though it no longer drives a backend itself. Do not "optimise" it away.

     It also records the shared /bardumptrace diagnostic, which is how the
     cLayout+profile combination behind a bad layout gets identified.
--]]
function ActionBars:ApplyABSettings(tag)
    if not ndbc then return end
    if ndbc.init.installStage ~= -1 then return end

    local prof = RealUI.cLayout == 1 and "RealUI" or "RealUI-Healing"

    -- Refresh db reference to ensure we have the latest settings
    db = self.db.profile
    ndb = RealUI.db.profile

    -- Trace: record every call so we can see which cLayout+prof combo drove
    -- the final layout. Keeps the last 10 calls; dump with /bardumptrace.
    ActionBars._applyTrace = ActionBars._applyTrace or {}
    do
        local sv = _G.RealUI_ActionBarsDB
        local barsProfile = (type(sv) == "table" and type(sv.profileKeys) == "table"
            and RealUI.key and _G.tostring(sv.profileKeys[RealUI.key])) or "(nil)"
        local posLayout = ndb and ndb.positions and ndb.positions[RealUI.cLayout]
        table.insert(ActionBars._applyTrace, {
            t      = _G.GetTime(),
            cL     = RealUI.cLayout,
            prof   = prof,
            btCur  = barsProfile,
            tag    = tag or "(none)",
            abY    = posLayout and posLayout["ActionBarsY"],
            abBotY = posLayout and posLayout["ActionBarsBotY"],
            hudY   = posLayout and posLayout["HuDY"],
            hudSz  = ndb and ndb.settings and ndb.settings.hudSize,
            cPos   = db and db[RealUI.cLayout] and db[RealUI.cLayout].centerPositions,
        })
        if #ActionBars._applyTrace > 10 then
            table.remove(ActionBars._applyTrace, 1)
        end
    end

    -- Doodads are RealUI's own decorations, not a bar-backend concern.
    if RealUI:GetModuleEnabled(MODNAME) then
        self:RefreshDoodads()
    end
end

----
-- Doodad functions
----
local function CreateDoodad(doodad, parent)
    ActionBars:debug("CreateDoodad", doodad)
    local bar = _G.CreateFrame("Frame", "RealUIActionBarDoodads"..doodad, _G.UIParent)
    Doodads[doodad] = bar

    bar:SetFrameStrata("LOW")
    bar:SetHeight(32)
    bar:SetWidth(32)

    bar.texture = bar:CreateTexture(nil, "ARTWORK")
    bar.texture:SetAllPoints(bar)
    bar.texture:SetTexture(Textures.stanceBar.center)

    bar.parent = parent

    bar:Hide()
end

function ActionBars:UpdateDoodadVisibility(doodadType)
    if not Doodads[doodadType] then return end
    ActionBars:debug("UpdateDoodadVisibility", doodadType)

    local doodad = Doodads[doodadType]
    if db.showDoodads and doodad:ShouldShow() then
        ActionBars:debug("Show doodad")
        doodad:Show()
    else
        ActionBars:debug("Hide doodad")
        doodad:Hide()
    end
end

--[[ Doodad placement against RealUI_ActionBars' stance/pet holders.

     The BT4 version reconstructed the bar's extent from its button grid
     (buttons x rows x a hardcoded button size + BT4's padding) because BT4's
     bar frame did not represent it. RealUI_ActionBars sizes its holders to
     the REAL rendered extent (StancePetBar.lua AdoptButtons), so the extent
     can just be read off the frame — and the grow direction comes from the
     holder's own live config rather than a BT4 SavedVariables lookup.

     NOT visually verified yet: the doodads have been absent since Bartender4
     stopped driving the bars, so this restores them rather than adjusting
     something on screen. Expect a nudge after the first look. ]]--
function ActionBars:UpdateDoodadPosition(doodadType)
    if not db.showDoodads then return end
    ActionBars:debug("UpdateDoodadPosition", doodadType)

    local doodad = Doodads[doodadType]
    local bar = doodad and doodad.parent
    if not bar then return end

    local barWidth, barHeight = bar:GetWidth(), bar:GetHeight()
    if not barWidth or barWidth <= 0 then return end

    local barX = RealUI.Round(barWidth / 2) - 0.5
    local barY = RealUI.Round(barHeight / 2) - 0.5

    -- Holders anchor by their grow corner: LEFT growth hangs off the top
    -- right, and both bars grow downward from that corner.
    local config = bar._ruiConfig
    if config and config.growHorizontal == "LEFT" then
        barX = -barX
    end
    barY = -barY

    doodad:ClearAllPoints()
    doodad:SetPoint("CENTER", bar, barX, barY)
end

----
-- Frame Creation
----
function ActionBars:RefreshDoodads(doodadType)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    ActionBars:debug("RefreshDoodads", doodadType)
    db = self.db.profile

    -- Parent to RealUI_ActionBars' holders. They are created lazily when the
    -- respective bar is built, so a missing holder simply means "no bar yet";
    -- the next refresh (UPDATE_SHAPESHIFT_FORMS, pet summon, layout change)
    -- picks it up.
    local petBar = _G.RealUI_AB_Pet
    if petBar and (doodadType == nil or doodadType == "Pet") then
        ActionBars:debug("RefreshPet")
        if not Doodads.Pet then
            CreateDoodad("Pet", petBar)
            function Doodads.Pet:ShouldShow()
                return _G.UnitExists("pet") and not _G.UnitInVehicle("player")
            end
        end
        self:UpdateDoodadPosition("Pet")
        self:UpdateDoodadVisibility("Pet")
    end

    local stanceBar = _G.RealUI_AB_Stance
    if stanceBar and (doodadType == nil or doodadType == "Stance") then
        ActionBars:debug("RefreshStance")
        if not Doodads.Stance then
            CreateDoodad("Stance", stanceBar)
            function Doodads.Stance:ShouldShow()
                return not _G.UnitInVehicle("player")
            end
        end
        self:UpdateDoodadPosition("Stance")
        self:UpdateDoodadVisibility("Stance")
    end
end

function ActionBars:PLAYER_ENTERING_WORLD()
    self:debug("PLAYER_ENTERING_WORLD")

    self:ApplyABSettings()

    -- The bars rebuild themselves (RealUI_ActionBars owns button layout); all
    -- that is needed here is a doodad pass once the holders exist. Staggered
    -- because the stance/pet holders are built lazily after login.
    for _, delay in ipairs({0.2, 0.5, 1.0}) do
        _G.C_Timer.After(delay, function()
            if _G.InCombatLockdown() then return end
            self:RefreshDoodads()
        end)
    end

    if EnteredWorld then return end

    self:RegisterEvent("PET_UI_UPDATE", function()
        self:RefreshDoodads("Pet")
    end)
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", function()
        self:RefreshDoodads("Stance")
    end)

    EnteredWorld = true
end

function ActionBars:BarChatCommand()
    if not _G.InCombatLockdown() then
        RealUI.Debug("Config", "/bt")
        RealUI.LoadConfig("HuD", "other", "actionbars")
    end
end

-- Diagnostic: show the last few ApplyABSettings invocations
-- Usage: /bardumptrace
function ActionBars:BarDumpTraceCommand()
    local trace = ActionBars._applyTrace or {}
    if #trace == 0 then
        _G.print("[bardumptrace] no calls recorded yet")
        return
    end
    _G.print(("[bardumptrace] last %d ApplyABSettings calls:"):format(#trace))
    for i, entry in ipairs(trace) do
        _G.print(("  %d: t=%.2f cL=%s prof=%s bt=%s tag=%s cPos=%s abY=%s abBotY=%s hudY=%s hudSz=%s"):format(
            i, entry.t,
            tostring(entry.cL), entry.prof, entry.btCur, entry.tag,
            tostring(entry.cPos),
            tostring(entry.abY), tostring(entry.abBotY),
            tostring(entry.hudY), tostring(entry.hudSz)))
    end
end

-- Diagnostic: dump current actionbar positions for both RealUI profiles.
-- Usage: /bardump
function ActionBars:BarDumpCommand()
    local dbTable = _G.RealUI_ActionBarsDB
    local dbLabel = "RealUI_ActionBarsDB"
    local currentProf = dbTable and _G.type(dbTable.profileKeys) == "table"
        and RealUI.key and dbTable.profileKeys[RealUI.key]
    if not dbTable or not dbTable.namespaces or not dbTable.namespaces.ActionBars then
        _G.print(("[bardump] %s.namespaces.ActionBars missing"):format(dbLabel)); return
    end

    _G.print(("[bardump] RealUI.cLayout=%s (%s)"):format(
        tostring(RealUI.cLayout),
        RealUI.cLayout == 1 and "DPS/Tank" or "Healing"))
    _G.print(("[bardump] %s current profile: %s"):format(dbLabel, tostring(currentProf)))

    local profiles = dbTable.namespaces.ActionBars.profiles
    for _, profName in ipairs({"RealUI", "RealUI-Healing"}) do
        local prof = profiles[profName]
        if not prof then
            _G.print(("[bardump] profile %s: MISSING"):format(profName))
        else
            _G.print(("[bardump] profile %s:"):format(profName))
            local bars = prof.actionbars or {}
            for id = 1, 6 do
                local bar = bars[id]
                if bar and bar.position then
                    _G.print(("  bar%d point=%s x=%.1f y=%.1f"):format(
                        id, tostring(bar.position.point),
                        bar.position.x or 0, bar.position.y or 0))
                else
                    _G.print(("  bar%d: (no position)"):format(id))
                end
            end
        end
    end
end

function ActionBars:RefreshMod()
    db = self.db.profile
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char

    self:RefreshDoodads()
    self:ApplyABSettings()
    -- Deliberately NO UpdateNagaBarState here. RealUI_ActionBars owns bar 6
    -- (its /naga writes barDB.enabled directly); re-asserting the module's
    -- enableNagaBar (default false) on every profile/spec swap switched a
    -- user-enabled Naga bar back off — caught live 2026-08-22 ("Razer Naga
    -- action bar disabled" firing mid spec change). The module's flag is the
    -- WIZARD's one-time choice, applied via ToggleNagaCommand/ToggleNagaBar.
end

--[[ Naga bar toggle. RealUI_ActionBars owns bar 6 (its own /naga reclaims the
     slash command), so this delegates rather than configuring a backend
     itself. It stays because the install wizard's Naga checkbox writes
     db.enableNagaBar here and applies it through this path — once, at setup,
     not per refresh. --]]
function ActionBars:ToggleNagaBar(enable)
    local AB = _G.LibStub("AceAddon-3.0"):GetAddon("RealUIActionBars", true)
    if not (AB and AB:IsEnabled() and AB.dbActionBars) then return end

    local barDB = AB.dbActionBars.profile.actionbars[6]
    if not barDB then return end
    if barDB.enabled == (enable and true or false) then return end

    barDB.enabled = enable and true or false
    if AB.RefreshBar then
        AB:RefreshBar(6)
    end
    RealUI:Print("Razer Naga action bar", enable and "enabled" or "disabled")
end

function ActionBars:UpdateNagaBarState()
    if not db then return end
    self:ToggleNagaBar(db.enableNagaBar)
end

function ActionBars:ToggleNagaCommand()
    if not db then return end
    db.enableNagaBar = not db.enableNagaBar
    self:ToggleNagaBar(db.enableNagaBar)
end

function ActionBars:OnProfileUpdate(...)
    -- Was gated on DoesAddonMove("Bartender4"): with BT4 support removed that
    -- entry is gone, and keeping the gate would disable this module entirely —
    -- taking the doodads AND the ApplyABSettings hook RealUI_ActionBars rides
    -- with it.
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    if self:IsEnabled() then
        self:RefreshMod()
    end
end

function ActionBars:OnInitialize()
    self:debug("OnInitialize")

    -- Register with ModuleFramework
    if RealUI.ModuleFramework then
        RealUI:RegisterRealUIModule(MODNAME, "core", {}, {
            description = "Action bar positioning and styling system",
            version = "1.0.0"
        })
    end

    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            showDoodads = true,
            enableNagaBar = false,  -- Razer Naga action bar (Bar 2)
            [1] = {     -- DPS/Tank
                centerPositions = 2,    -- 1 top, 2 bottom
                sidePositions = 1,      -- 2 Right, 0 Left
                moveBars = {
                    stance = true,
                    pet = true,
                    eab = true,
                },
            },
            [2] = {     -- Healing
                centerPositions = 2,    -- 1 top, 2 bottom
                sidePositions = 1,      -- 2 Right, 0 Left
                moveBars = {
                    stance = true,
                    pet = true,
                    eab = true,
                },
            },
        },
    })
    db = self.db.profile
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char

    -- Was gated on DoesAddonMove("Bartender4"): with BT4 support removed that
    -- entry is gone, and keeping the gate would disable this module entirely —
    -- taking the doodads AND the ApplyABSettings hook RealUI_ActionBars rides
    -- with it.
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function ActionBars:OnEnable()
    self:debug("OnEnable")

    -- /bardump reads RealUI_ActionBarsDB, /bardumptrace records every
    -- ApplyABSettings call (which RealUI_ActionBars rides via hooksecurefunc).
    if not self._diagCommandsRegistered then
        self:RegisterChatCommand("bardump", "BarDumpCommand")
        self:RegisterChatCommand("bardumptrace", "BarDumpTraceCommand")
        self._diagCommandsRegistered = true
    end

    if EnteredWorld then
        self:debug("Post EnteredWorld")
        self:RefreshDoodads()
    else
        self:debug("Pre EnteredWorld")
        -- Registered UNCONDITIONALLY now. This used to live inside an
        -- `elseif BT4` branch, so once Bartender4 stopped being installed the
        -- event never registered at all — which is why the doodads silently
        -- disappeared rather than merely being misplaced.
        self:RegisterEvent("PLAYER_ENTERING_WORLD")

        -- Legacy bar-config aliases kept: users type them out of habit, and
        -- they now open RealUI's own action bar config.
        self:RegisterChatCommand("bar", "BarChatCommand")
        self:RegisterChatCommand("bt", "BarChatCommand")
    end
end

function ActionBars:OnDisable()
    self:debug("OnDisable")

    -- Was `self:TogglePetBar()` — a method that exists nowhere in the code
    -- base, so disabling this module always threw (spec task 9.1 logged it as
    -- "the TogglePetBar nil-call"). The doodads are the only thing this module
    -- owns visually, so hiding them IS the disable behaviour.
    for _, doodad in next, Doodads do
        if doodad.Hide then doodad:Hide() end
    end

    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterChatCommand("bar")
    self:UnregisterChatCommand("bt")
end
