local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0")

--[[ B116, 2026-08-24: the shipped tracker position is stated ONCE, in
     RealUI/Core/EditModeTemplates.lua, and read here.

     It used to be stated twice — `-25, -210` as the EditMode anchor and
     `-50, -200` as the AceDB default below — and nothing kept them in step.
     Since 2.5b EditMode owns the live position and this table is only a
     one-time seed, so the EditMode value is what every install past first run
     actually gets: the tracker shipped at -25, under the right-hand action
     bar column (which ends at -30). Changing only one of the two numbers
     would have fixed only one of first-run and everyone-else.

     RealUI is a RequiredDep, so the fallback below is for load-order
     paranoia, not a supported configuration. Keep it equal to the template's
     derived value if it is ever touched. ]]
local DEFAULT_POSITION = (_G.RealUI and _G.RealUI.EditModeTemplates
    and _G.RealUI.EditModeTemplates.trackerDefaultPosition)
    or { anchorFrom = "TOPRIGHT", anchorTo = "TOPRIGHT", x = -36, y = -210 }

function RealUI_Tracker:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RealUI_TrackerDB", {
        profile = {
            position = {
                enabled       = true,
                anchorTo      = DEFAULT_POSITION.anchorTo,
                anchorFrom    = DEFAULT_POSITION.anchorFrom,
                x             = DEFAULT_POSITION.x,
                y             = DEFAULT_POSITION.y,
            },
            context = {
                enabled = true,
                -- D1 (tracker-widget-taint-rewrite): the hide is an alpha fade
                -- (Context.lua); there is no real-hide mode.
                hide = {
                    arena    = true,
                    raid     = true,
                    pvp      = false,
                    party    = false,
                    scenario = false,
                },
                -- D2: the per-instance module collapse (collapse /
                -- collapseModules) is dropped; DropRemovedSettings cleans it
                -- out of saved profiles.
            },
            combatFade = {
                enabled  = true,
                opacity  = {
                    incombat    = 0.25,
                    hurt        = 0.75,
                    target      = 0.75,
                    harmtarget  = 0.85,
                    outofcombat = 1.0,
                },
            },
            display = {
                questCount = true,
            },
        },
        global = {
            migratedFromObjectivesAdv = false,
        },
    })

    -- Task 8.4: Run ObjectivesAdv migration after AceDB:New() has populated defaults
    self:MigrateFromObjectivesAdv()

    -- Remove settings whose features are gone (collapse D2, display trim)
    self:DropRemovedSettings()
end

function RealUI_Tracker:OnEnable()
    -- 3.3: Register PLAYER_LOGIN — conflict check and container setup happen there
    self:RegisterEvent("PLAYER_LOGIN")
end

function RealUI_Tracker:PLAYER_LOGIN()
    self:UnregisterEvent("PLAYER_LOGIN")

    -- 3.3: Check for competing addons first; abort if conflict found
    if self:CheckForConflicts() then
        return
    end

    -- Task 2's container wrapper is gone (tracker-widget-taint-rewrite 5.1):
    -- Edit Mode owns the tracker's position. See Container.lua.

    -- 5.4: Set up context hide — registers PLAYER_ENTERING_WORLD
    self:SetupContext()

    -- 11.3: Set up the quest count hooks
    self:SetupDisplay()

    -- 6.1–6.3: Set up CombatFader integration
    self:SetupCombatFader()

    -- 14.2: Set up config panel (inject into RealUI options tree)
    self:SetupConfig()
end

---------------------------------------------------------
-- CombatFader integration (Task 6)
---------------------------------------------------------

-- 6.1–6.3: SetupCombatFader — inject proxy and register with CombatFader
function RealUI_Tracker:SetupCombatFader()
    local RealUI_Core = _G.RealUI  -- the RealUI AceAddon, not our addon
    if not RealUI_Core then return end
    local CombatFader = RealUI_Core:GetModule("CombatFader", true)
    if not CombatFader then return end

    -- 6.2: Inject proxy so RealUI.GetOptions("RealUI_Tracker", path) resolves our DB
    RealUI_Core.modules["RealUI_Tracker"] = { db = self.db }

    -- 6.3: Register with CombatFader — path "profile", "combatFade" means
    -- it will traverse self.db.profile.combatFade to find opacity/enabled keys
    CombatFader:RegisterModForFade("RealUI_Tracker", "profile", "combatFade")
    CombatFader:RegisterFrameForFade("RealUI_Tracker", _G.ObjectiveTrackerFrame)
    private.combatFaderSetUp = true
end

-- 6.4: CleanupCombatFader — remove proxy from RealUI's module registry
function RealUI_Tracker:CleanupCombatFader()
    if not private.combatFaderSetUp then return end
    local RealUI_Core = _G.RealUI
    if RealUI_Core and RealUI_Core.modules then
        RealUI_Core.modules["RealUI_Tracker"] = nil
    end
    private.combatFaderSetUp = false
end

---------------------------------------------------------
-- OnDisable
---------------------------------------------------------

function RealUI_Tracker:OnDisable()
    -- Clean up in reverse order of setup
    self:CleanupCombatFader()
    self:CleanupDisplay()
    self:CleanupContext()
end
