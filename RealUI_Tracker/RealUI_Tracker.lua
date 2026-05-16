local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):NewAddon(ADDON_NAME, "AceEvent-3.0")

function RealUI_Tracker:OnInitialize()
    self.db = LibStub("AceDB-3.0"):New("RealUI_TrackerDB", {
        profile = {
            position = {
                enabled       = true,
                anchorTo      = "TOPRIGHT",
                anchorFrom    = "TOPRIGHT",
                x             = -50,
                y             = -200,
            },
            context = {
                enabled = true,
                hide = {
                    arena    = true,
                    raid     = true,
                    pvp      = false,
                    party    = false,
                    scenario = false,
                },
                collapse = {
                    pvp      = true,
                    party    = true,
                    arena    = false,
                    scenario = false,
                    raid     = false,
                },
                collapseModules = {
                    quest       = true,
                    campaign    = true,
                    adventure   = true,
                    professions = true,
                    bonus       = true,
                    world       = true,
                },
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
                questCount      = true,
                difficultyColor = true,
                wrapText        = false,
            },
        },
        global = {
            migratedFromObjectivesAdv = false,
        },
    })

    -- Task 8.4: Run ObjectivesAdv migration after AceDB:New() has populated defaults
    self:MigrateFromObjectivesAdv()
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

    -- Set up the container wrapper (Task 2)
    self:SetupContainer()

    -- 5.4: Set up context hide/collapse — registers PLAYER_ENTERING_WORLD
    self:SetupContext()

    -- 10.3 / 11.3 / 12.1: Set up display hooks (templates, quest count, difficulty color)
    self:SetupDisplay()

    -- 6.1–6.3: Set up CombatFader integration
    self:SetupCombatFader()

    -- 5.5: Disable the deprecated ObjectivesAdv module
    self:DisableObjectivesAdv()

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
-- ObjectivesAdv deprecation (Task 5.5)
---------------------------------------------------------

function RealUI_Tracker:DisableObjectivesAdv()
    local RealUI_Core = _G.RealUI
    if not RealUI_Core then return end
    local ObjectivesAdv = RealUI_Core:GetModule("Objectives Adv.", true)
    if ObjectivesAdv then
        ObjectivesAdv:SetEnabledState(false)
        ObjectivesAdv:OnDisable()
    end
end

---------------------------------------------------------
-- OnDisable
---------------------------------------------------------

function RealUI_Tracker:OnDisable()
    -- Clean up in reverse order of setup
    self:CleanupCombatFader()
    self:CleanupDisplay()
    self:CleanupContext()
    self:CleanupContainer()
end
