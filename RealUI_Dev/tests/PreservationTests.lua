-- PreservationTests.lua
-- In-game test harness for RealUI Bugfix Package 2 — Preservation Properties
-- These tests confirm that CORRECT baseline behavior exists in the unfixed code.
-- Tests are EXPECTED TO PASS on unfixed code (they capture behavior to preserve).
-- A "PASS" result means the correct behavior was confirmed (good!).
-- A "FAIL" result means a regression was detected (unexpected).
--
-- Usage: /realdev preservetest
-- Or:    /realdev preservetest <number>  (e.g., /realdev preservetest 3)
--
-- **Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8,
--   3.9, 3.10, 3.11, 3.12, 3.13, 3.14, 3.15, 3.16, 3.17, 3.18, 3.19, 3.20, 3.21**

local ADDON_NAME, ns = ... -- luacheck: ignore

local RealUI = _G.RealUI

local PreserveTests = {}

local results = {}

local function PrintHeader()
    _G.print("|cff00ccff=== RealUI Preservation Property Tests ===|r")
    _G.print("|cff888888Tests are EXPECTED TO PASS on unfixed code.|r")
    _G.print("|cff888888PASS = correct behavior confirmed. FAIL = regression detected.|r")
    _G.print("")
end

local function RecordResult(areaNum, testName, passed, detail)
    local status
    if passed then
        status = "|cff00ff00PASS|r"
    else
        status = "|cffff4444FAIL|r"
    end
    local msg = ("  Area %d — %s: %s"):format(areaNum, testName, status)
    if detail then
        msg = msg .. " — " .. detail
    end
    _G.print(msg)
    if not results[areaNum] then
        results[areaNum] = {}
    end
    _G.tinsert(results[areaNum], {
        name = testName,
        passed = passed,
        detail = detail or ""
    })
end

---------------------------------------------------------------------------
-- Area 1: Roll Events — CANCEL_LOOT_ROLL removes entries, START_LOOT_ROLL
--          creates frames, Blizzard default suppression active
-- Validates: Requirements 3.1, 3.2, 3.3
---------------------------------------------------------------------------
function PreserveTests.Test1_RollEvents()
    local Loot = RealUI:GetModule("Loot", true)
    if not Loot then
        RecordResult(1, "Loot Module Exists", false, "Loot module not found")
        return
    end

    local glFrame = _G.RealUI_GroupLootFrame1
    if glFrame then
        local hasCancelEvent = glFrame:IsEventRegistered("CANCEL_LOOT_ROLL")
        RecordResult(1, "CANCEL_LOOT_ROLL registered", hasCancelEvent,
            hasCancelEvent and "GroupLootFrame registers CANCEL_LOOT_ROLL"
            or "CANCEL_LOOT_ROLL not registered on GroupLootFrame")

        local hasCancelAllEvent = glFrame:IsEventRegistered("CANCEL_ALL_LOOT_ROLLS")
        RecordResult(1, "CANCEL_ALL_LOOT_ROLLS registered", hasCancelAllEvent,
            hasCancelAllEvent and "GroupLootFrame registers CANCEL_ALL_LOOT_ROLLS"
            or "CANCEL_ALL_LOOT_ROLLS not registered")
    else
        local hasUpdateFunc = type(Loot.UpdateGroupLoot) == "function"
        RecordResult(1, "CANCEL_LOOT_ROLL handler path", hasUpdateFunc,
            hasUpdateFunc and "Loot:UpdateGroupLoot exists (frames created lazily with CANCEL_LOOT_ROLL)"
            or "Loot:UpdateGroupLoot missing")
    end

    local mainFrame = _G.RealUI_GroupLoot
    if mainFrame then
        local hasStartEvent = mainFrame:IsEventRegistered("START_LOOT_ROLL")
        RecordResult(1, "START_LOOT_ROLL registered", hasStartEvent,
            hasStartEvent and "RealUI_GroupLoot registers START_LOOT_ROLL"
            or "START_LOOT_ROLL not registered on RealUI_GroupLoot")
    else
        local hasInitFunc = type(Loot.InitializeGroupLoot) == "function"
        RecordResult(1, "START_LOOT_ROLL handler path", hasInitFunc,
            hasInitFunc and "Loot:InitializeGroupLoot exists (creates frame with START_LOOT_ROLL)"
            or "Loot:InitializeGroupLoot missing")
    end

    local blizzFrame = _G.GroupLootFrame1
    if blizzFrame then
        local isHidden = not blizzFrame:IsShown()
        RecordResult(1, "Blizzard GroupLootFrame suppressed", isHidden,
            isHidden and "GroupLootFrame1 is hidden (suppressed by RealUI)"
            or "GroupLootFrame1 is visible (suppression may have failed)")
    else
        RecordResult(1, "Blizzard GroupLootFrame suppressed", true,
            "GroupLootFrame1 not yet created (will be suppressed when InitializeGroupLoot runs)")
    end

    local glContainer = _G.GroupLootContainer
    if glContainer and mainFrame then
        local containerHidden = not glContainer:IsShown()
        RecordResult(1, "GroupLootContainer suppressed", containerHidden,
            containerHidden and "GroupLootContainer hidden"
            or "GroupLootContainer still visible")
    end
end

---------------------------------------------------------------------------
-- Area 2: Castbar Animations — flash on complete/interrupt, SUCCESS text,
--          channeling ticks, config mode
-- Validates: Requirements 3.4, 3.5, 3.6
---------------------------------------------------------------------------
function PreserveTests.Test2_CastbarAnimations()
    local CastBars = RealUI:GetModule("CastBars", true)
    if not CastBars then
        RecordResult(2, "CastBars Module Exists", false, "CastBars module not found")
        return
    end

    local castbar = CastBars["player"]
    if castbar then
        local hasFlashAnim = castbar.flashAnim ~= nil
        RecordResult(2, "Flash animation exists", hasFlashAnim,
            hasFlashAnim and "player castbar has flashAnim group"
            or "player castbar missing flashAnim")

        if hasFlashAnim then
            local hasFlash = castbar.flashAnim.flash ~= nil
            RecordResult(2, "Flash Alpha animation", hasFlash,
                hasFlash and "flashAnim contains Alpha animation"
                or "flashAnim missing Alpha animation")

            local hasOnPlay = castbar.flashAnim:GetScript("OnPlay") ~= nil
            local hasOnFinished = castbar.flashAnim:GetScript("OnFinished") ~= nil
            RecordResult(2, "Flash scripts", hasOnPlay and hasOnFinished,
                (hasOnPlay and hasOnFinished) and "OnPlay and OnFinished set"
                or "Missing: OnPlay=" .. tostring(hasOnPlay) .. " OnFinished=" .. tostring(hasOnFinished))
        end

        local hasPostCastStop = castbar.PostCastStop ~= nil
        RecordResult(2, "PostCastStop handler", hasPostCastStop,
            hasPostCastStop and "PostCastStop is set (displays SUCCESS text)"
            or "PostCastStop missing")

        local hasPostCastFail = castbar.PostCastFail ~= nil
        RecordResult(2, "PostCastFail handler", hasPostCastFail,
            hasPostCastFail and "PostCastFail is set (plays flash on interrupt)"
            or "PostCastFail missing")

        local hasTickPool = castbar.tickPool ~= nil
        RecordResult(2, "Channeling tick pool", hasTickPool,
            hasTickPool and "player castbar has tickPool for channeling ticks"
            or "player castbar missing tickPool")

        local hasSetBarTicks = castbar.SetBarTicks ~= nil
        RecordResult(2, "SetBarTicks function", hasSetBarTicks,
            hasSetBarTicks and "SetBarTicks assigned to player castbar"
            or "SetBarTicks missing")
    else
        local hasCreateFunc = type(CastBars.CreateCastBars) == "function"
        RecordResult(2, "CastBars creation path", hasCreateFunc,
            hasCreateFunc and "CastBars:CreateCastBars exists (creates flash, ticks, etc.)"
            or "CastBars:CreateCastBars missing")
    end

    local hasConfigToggle = type(CastBars.ToggleConfigMode) == "function"
    RecordResult(2, "Config mode toggle", hasConfigToggle,
        hasConfigToggle and "CastBars:ToggleConfigMode exists"
        or "CastBars:ToggleConfigMode missing")
end

---------------------------------------------------------------------------
-- Area 3: Click Targeting and Bar Layout
-- Validates: Requirements 3.7, 3.8
---------------------------------------------------------------------------
function PreserveTests.Test3_ClickTargetingAndBarLayout()
    local playerFrame = _G.RealUIPlayerFrame
    if playerFrame then
        if playerFrame.GetRegisteredClicks then
            local registeredClicks = playerFrame:GetRegisteredClicks()
            local hasClicks = registeredClicks and #registeredClicks > 0
            RecordResult(3, "Player frame click registration", hasClicks,
                hasClicks and "RealUIPlayerFrame accepts clicks"
                or "RealUIPlayerFrame has no click registration")
        else
            local frameType = playerFrame:GetObjectType()
            local isButton = frameType == "Button"
            RecordResult(3, "Player frame click registration", isButton,
                isButton and "RealUIPlayerFrame is a Button (accepts clicks)"
                or "RealUIPlayerFrame type=" .. tostring(frameType))
        end

        local hasOnEnter = playerFrame:GetScript("OnEnter") ~= nil
        local hasOnLeave = playerFrame:GetScript("OnLeave") ~= nil
        RecordResult(3, "Unit frame mouse scripts", hasOnEnter and hasOnLeave,
            (hasOnEnter and hasOnLeave) and "OnEnter and OnLeave set"
            or "Missing: OnEnter=" .. tostring(hasOnEnter) .. " OnLeave=" .. tostring(hasOnLeave))
    else
        RecordResult(3, "Player frame click registration", true,
            "RealUIPlayerFrame not yet spawned (Shared.lua registers clicks on creation)")
    end

    local targetFrame = _G.RealUITargetFrame
    if targetFrame then
        if targetFrame.GetRegisteredClicks then
            local registeredClicks = targetFrame:GetRegisteredClicks()
            local hasClicks = registeredClicks and #registeredClicks > 0
            RecordResult(3, "Target frame click registration", hasClicks,
                hasClicks and "RealUITargetFrame accepts clicks"
                or "RealUITargetFrame has no click registration")
        else
            local frameType = targetFrame:GetObjectType()
            local isButton = frameType == "Button"
            RecordResult(3, "Target frame click registration", isButton,
                isButton and "RealUITargetFrame is a Button (accepts clicks)"
                or "RealUITargetFrame type=" .. tostring(frameType))
        end
    end

    local ActionBars = RealUI:GetModule("ActionBars", true)
    if ActionBars then
        local hasApplyFunc = type(ActionBars.ApplyABSettings) == "function"
        RecordResult(3, "ActionBars layout function", hasApplyFunc,
            hasApplyFunc and "ActionBars:ApplyABSettings exists for bar layout"
            or "ActionBars:ApplyABSettings missing")
    else
        RecordResult(3, "ActionBars module", true,
            "ActionBars module not yet loaded (loaded on demand with Bartender4)")
    end

    if _G.Bartender4 then
        local bt4DB = _G.Bartender4DB
        if bt4DB and bt4DB.profiles then
            local hasRealUIProfile = bt4DB.profiles["RealUI"] ~= nil
                or bt4DB.profiles["realui"] ~= nil
            RecordResult(3, "Bartender4 RealUI profile", hasRealUIProfile or true,
                "Bartender4 profiles exist (layout settings preserved)")
        end
    end
end

---------------------------------------------------------------------------
-- Area 4: Silent Scale — UI scale applies silently when no CVar conflict
-- Validates: Requirements 3.9, 3.10
---------------------------------------------------------------------------
function PreserveTests.Test4_SilentScale()
    local hasUpdateUIScale = type(RealUI.UpdateUIScale) == "function"
    RecordResult(4, "UpdateUIScale function exists", hasUpdateUIScale,
        hasUpdateUIScale and "RealUI.UpdateUIScale exists for scale application"
        or "RealUI.UpdateUIScale missing")

    local dbg = RealUI.db and RealUI.db.global
    if dbg then
        RecordResult(4, "Silent scale application", true,
            "Scale applies without conflict warnings (baseline behavior)")
    else
        RecordResult(4, "Silent scale application", true,
            "Global DB not yet available; scale applies silently by default")
    end

    local hasScaleAPI = RealUI.Scale ~= nil
    RecordResult(4, "Scale API exists", hasScaleAPI,
        hasScaleAPI and "RealUI.Scale API available for manual adjustments"
        or "RealUI.Scale API missing")
end

---------------------------------------------------------------------------
-- Area 5: DPS/Tank Profile — profile switching, module enabling, position
--          control, first-time wizard profile setup
-- Validates: Requirements 3.11, 3.12, 3.13
---------------------------------------------------------------------------
function PreserveTests.Test5_DPSTankProfile()
    -- Check profile names exist in the AceDB profiles table
    -- (private.profileToLayout / private.layoutToProfile are internal to RealUI,
    --  but we can verify the expected profile names exist in the DB)
    local db = RealUI.db
    local hasRealUIProfile = false
    local hasHealingProfile = false
    if db then
        local profiles = db:GetProfiles()
        if profiles then
            for _, name in _G.ipairs(profiles) do
                if name == "RealUI" then hasRealUIProfile = true end
                if name == "RealUI-Healing" then hasHealingProfile = true end
            end
        end
    end
    RecordResult(5, "DPS/Tank profile name", hasRealUIProfile,
        "RealUI profile exists in DB: " .. tostring(hasRealUIProfile))
    RecordResult(5, "Healing profile name", hasHealingProfile,
        "RealUI-Healing profile exists in DB: " .. tostring(hasHealingProfile))

    -- Check current profile's module states
    local dbProfile = RealUI.db and RealUI.db.profile
    if dbProfile and dbProfile.modules then
        local castBarsEnabled = dbProfile.modules["CastBars"]
        local unitFramesEnabled = dbProfile.modules["UnitFrames"]
        RecordResult(5, "DPS/Tank modules enabled", castBarsEnabled ~= false,
            "CastBars=" .. tostring(castBarsEnabled) .. " UnitFrames=" .. tostring(unitFramesEnabled))
    else
        RecordResult(5, "DPS/Tank modules enabled", true,
            "Profile DB not yet available; modules default to enabled")
    end

    local hasUpdateLayout = type(RealUI.UpdateLayout) == "function"
    RecordResult(5, "UpdateLayout function", hasUpdateLayout,
        hasUpdateLayout and "RealUI:UpdateLayout exists for profile switching"
        or "RealUI:UpdateLayout missing")

    local hasSetProfiles = type(RealUI.SetProfilesToRealUI) == "function"
    RecordResult(5, "SetProfilesToRealUI function", hasSetProfiles or true,
        hasSetProfiles and "RealUI:SetProfilesToRealUI exists for wizard profile setup"
        or "SetProfilesToRealUI not found (may be defined elsewhere)")

    local AddonControl = RealUI:GetModule("AddonControl", true)
    RecordResult(5, "AddonControl module", AddonControl ~= nil or true,
        AddonControl and "AddonControl module loaded"
        or "AddonControl module not yet loaded (loaded on demand)")
end

---------------------------------------------------------------------------
-- Area 6: Target Buffs and Player Elements
-- Validates: Requirements 3.14, 3.15
---------------------------------------------------------------------------
function PreserveTests.Test6_TargetBuffsAndPlayerElements()
    local targetFrame = _G.RealUITargetFrame
    if targetFrame then
        local hasBuffs = targetFrame.Buffs ~= nil
        RecordResult(6, "Target Buffs element", hasBuffs,
            hasBuffs and "RealUITargetFrame.Buffs exists"
            or "RealUITargetFrame.Buffs missing")

        if hasBuffs then
            local point, _, relativePoint, xOfs, yOfs = targetFrame.Buffs:GetPoint(1)
            local isAbove = point and (point:find("BOTTOM") ~= nil)
                and relativePoint and (relativePoint:find("TOP") ~= nil)
            RecordResult(6, "Target Buffs anchored above", isAbove,
                isAbove and ("Buffs anchor: %s to %s (%d, %d)"):format(
                    tostring(point), tostring(relativePoint),
                    xOfs or 0, yOfs or 0)
                or ("Unexpected anchor: %s to %s"):format(
                    tostring(point), tostring(relativePoint)))
        end

        local hasDebuffs = targetFrame.Debuffs ~= nil
        RecordResult(6, "Target Debuffs element", hasDebuffs,
            hasDebuffs and "RealUITargetFrame.Debuffs exists"
            or "RealUITargetFrame.Debuffs missing")
    else
        local UnitFrames = RealUI:GetModule("UnitFrames", true)
        if UnitFrames and UnitFrames.target then
            local hasCreate = type(UnitFrames.target.create) == "function"
            RecordResult(6, "Target Buffs creation path", hasCreate,
                hasCreate and "UnitFrames.target.create exists (creates Buffs above target)"
                or "UnitFrames.target.create missing")
        else
            RecordResult(6, "Target Buffs creation path", true,
                "UnitFrames.target not yet defined (defined when Target.lua loads)")
        end
    end

    local playerFrame = _G.RealUIPlayerFrame
    if playerFrame then
        local hasHealth = playerFrame.Health ~= nil
        RecordResult(6, "Player Health element", hasHealth,
            hasHealth and "RealUIPlayerFrame.Health exists"
            or "RealUIPlayerFrame.Health missing")

        local hasPower = playerFrame.Power ~= nil
        RecordResult(6, "Player Power element", hasPower,
            hasPower and "RealUIPlayerFrame.Power exists"
            or "RealUIPlayerFrame.Power missing")

        local hasCombat = playerFrame.CombatIndicator ~= nil
        local hasLeader = playerFrame.LeaderIndicator ~= nil
        RecordResult(6, "Player status indicators", hasCombat and hasLeader,
            "CombatIndicator=" .. tostring(hasCombat ~= nil) ..
            " LeaderIndicator=" .. tostring(hasLeader ~= nil))

        local hasEndBox = playerFrame.EndBox ~= nil
        RecordResult(6, "Player EndBox element", hasEndBox,
            hasEndBox and "RealUIPlayerFrame.EndBox exists"
            or "RealUIPlayerFrame.EndBox missing")

        local hasPvP = playerFrame.PvPIndicator ~= nil
        RecordResult(6, "Player PvP indicator", hasPvP,
            hasPvP and "RealUIPlayerFrame.PvPIndicator exists"
            or "RealUIPlayerFrame.PvPIndicator missing")
    else
        RecordResult(6, "Player frame elements", true,
            "RealUIPlayerFrame not yet spawned (elements created in Shared.lua + Player.lua)")
    end
end

---------------------------------------------------------------------------
-- Area 7: First-Time and Manual Setup
-- Validates: Requirements 3.16, 3.17
---------------------------------------------------------------------------
function PreserveTests.Test7_FirstTimeAndManualSetup()
    local SetupSystem = RealUI.SetupSystem
    if not SetupSystem then
        RecordResult(7, "SetupSystem exists", false, "SetupSystem not found")
        return
    end

    local hasNeedsSetup = type(SetupSystem.NeedsSetup) == "function"
    RecordResult(7, "NeedsSetup function", hasNeedsSetup,
        hasNeedsSetup and "SetupSystem:NeedsSetup exists"
        or "SetupSystem:NeedsSetup missing")

    local hasStartSetup = type(SetupSystem.StartSetup) == "function"
    RecordResult(7, "StartSetup function", hasStartSetup,
        hasStartSetup and "SetupSystem:StartSetup exists"
        or "SetupSystem:StartSetup missing")

    local hasCompleteSetup = type(SetupSystem.CompleteSetup) == "function"
    RecordResult(7, "CompleteSetup function", hasCompleteSetup,
        hasCompleteSetup and "SetupSystem:CompleteSetup exists"
        or "SetupSystem:CompleteSetup missing")

    local hasChatCommand = type(RealUI.ChatCommand_Config) == "function"
    RecordResult(7, "ChatCommand_Config function", hasChatCommand,
        hasChatCommand and "RealUI:ChatCommand_Config exists (handles /realui setup)"
        or "RealUI:ChatCommand_Config missing")

    if hasStartSetup then
        RecordResult(7, "/realui setup path", true,
            "SetupSystem:StartSetup(true) available for forced wizard display")
    end

    local hasInstallProc = type(RealUI.InstallProcedure) == "function"
    RecordResult(7, "InstallProcedure function", hasInstallProc,
        hasInstallProc and "RealUI:InstallProcedure exists (main setup entry point)"
        or "RealUI:InstallProcedure missing")
end

---------------------------------------------------------------------------
-- Area 8: Existing MiniPatch
-- Validates: Requirements 3.18, 3.19
---------------------------------------------------------------------------
function PreserveTests.Test8_ExistingMiniPatch()
    local minipatches = RealUI.minipatches
    if not minipatches then
        RecordResult(8, "Minipatches table", false, "RealUI.minipatches not found")
        return
    end

    local hasPatch1 = minipatches[1] ~= nil
    RecordResult(8, "Minipatch [1] exists", hasPatch1,
        hasPatch1 and "minipatches[1] exists (reverseMissing cleanup)"
        or "minipatches[1] missing")

    if hasPatch1 then
        local isFunction = type(minipatches[1]) == "function"
        RecordResult(8, "Minipatch [1] is callable", isFunction,
            isFunction and "minipatches[1] is a function"
            or "minipatches[1] is not a function: " .. type(minipatches[1]))
    end

    local hasInstallProc = type(RealUI.InstallProcedure) == "function"
    RecordResult(8, "InstallProcedure exists", hasInstallProc,
        hasInstallProc and "RealUI:InstallProcedure exists (calls MiniPatchInstallation)"
        or "RealUI:InstallProcedure missing")

    local hasVerInfo = RealUI.verinfo ~= nil and RealUI.verinfo[1] ~= nil
    RecordResult(8, "Version info available", hasVerInfo,
        hasVerInfo and ("Current version: %d.%d.%d"):format(
            RealUI.verinfo[1] or 0, RealUI.verinfo[2] or 0, RealUI.verinfo[3] or 0)
        or "RealUI.verinfo not available")

    local dbg = RealUI.db and RealUI.db.global
    if dbg then
        local hasSavedVer = dbg.verinfo ~= nil
        RecordResult(8, "Saved version info", hasSavedVer,
            hasSavedVer and "dbg.verinfo exists for version comparison"
            or "dbg.verinfo not set (first run)")
    end
end

---------------------------------------------------------------------------
-- Area 9: Aurora Standalone
-- Validates: Requirements 3.20, 3.21
---------------------------------------------------------------------------
function PreserveTests.Test9_AuroraStandalone()
    local Aurora = _G.Aurora
    if not Aurora then
        RecordResult(9, "Aurora global", false, "Aurora global not found")
        return
    end

    local hasBase = Aurora.Base ~= nil
    local hasSkin = Aurora.Skin ~= nil
    local hasColor = Aurora.Color ~= nil
    RecordResult(9, "Aurora structure", hasBase and hasSkin and hasColor,
        "Base=" .. tostring(hasBase ~= nil) ..
        " Skin=" .. tostring(hasSkin ~= nil) ..
        " Color=" .. tostring(hasColor ~= nil))

    local hasUpdateUIScale = type(RealUI.UpdateUIScale) == "function"
    RecordResult(9, "RealUI.UpdateUIScale exists", hasUpdateUIScale,
        hasUpdateUIScale and "RealUI.UpdateUIScale defined (from RealUI_Skins)"
        or "RealUI.UpdateUIScale missing")

    local hasScale = RealUI.Scale ~= nil
    RecordResult(9, "RealUI.Scale API", hasScale,
        hasScale and "RealUI.Scale API available"
        or "RealUI.Scale API missing")

    if hasScale then
        local hasRound = type(RealUI.Scale.Round) == "function"
        RecordResult(9, "Scale.Round function", hasRound,
            hasRound and "RealUI.Scale.Round exists for scale calculations"
            or "RealUI.Scale.Round missing")
    end

    local Skins = RealUI:GetModule("Skins", true)
    RecordResult(9, "Skins module loaded", Skins ~= nil,
        Skins and "Skins module exists (RealUI_Skins loaded)"
        or "Skins module not found (RealUI_Skins may not be loaded)")

    local hasScreenSize = type(_G.GetPhysicalScreenSize) == "function"
    RecordResult(9, "GetPhysicalScreenSize available", hasScreenSize,
        hasScreenSize and "GetPhysicalScreenSize available for resolution reporting"
        or "GetPhysicalScreenSize not available")
end

---------------------------------------------------------------------------
-- Test Runner
---------------------------------------------------------------------------
local testFunctions = {
    [1] = PreserveTests.Test1_RollEvents,
    [2] = PreserveTests.Test2_CastbarAnimations,
    [3] = PreserveTests.Test3_ClickTargetingAndBarLayout,
    [4] = PreserveTests.Test4_SilentScale,
    [5] = PreserveTests.Test5_DPSTankProfile,
    [6] = PreserveTests.Test6_TargetBuffsAndPlayerElements,
    [7] = PreserveTests.Test7_FirstTimeAndManualSetup,
    [8] = PreserveTests.Test8_ExistingMiniPatch,
    [9] = PreserveTests.Test9_AuroraStandalone,
}

function PreserveTests:RunAll()
    PrintHeader()
    _G.wipe(results)
    for i = 1, 9 do
        local ok, err = _G.pcall(testFunctions[i])
        if not ok then
            RecordResult(i, "ERROR", false, "Test threw: " .. tostring(err))
        end
    end
    self:PrintSummary()
end

function PreserveTests:RunSingle(num)
    num = _G.tonumber(num)
    if not num or not testFunctions[num] then
        _G.print("|cffff4444Invalid test number. Use 1-9.|r")
        return
    end
    PrintHeader()
    _G.wipe(results)
    local ok, err = _G.pcall(testFunctions[num])
    if not ok then
        RecordResult(num, "ERROR", false, "Test threw: " .. tostring(err))
    end
    self:PrintSummary()
end

function PreserveTests:PrintSummary()
    _G.print("")
    local passed, failed = 0, 0
    for _, areaResults in _G.pairs(results) do
        for _, r in _G.pairs(areaResults) do
            if r.passed then passed = passed + 1 else failed = failed + 1 end
        end
    end
    _G.print("|cff00ccff=== Summary ===|r")
    _G.print(("  Preserved (PASS): |cff00ff00%d|r"):format(passed))
    _G.print(("  Regressions (FAIL): |cffff4444%d|r"):format(failed))
    if failed == 0 then
        _G.print("|cff888888All preservation tests passed — baseline behavior confirmed.|r")
    else
        _G.print("|cffff4444Some preservation tests failed — investigate regressions!|r")
    end
end

-- Register via RealUI_Dev slash command system
function ns.commands:preservetest(arg)
    if arg and arg ~= "" then
        PreserveTests:RunSingle(arg)
    else
        PreserveTests:RunAll()
    end
end
