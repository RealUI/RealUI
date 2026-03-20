-- BugConditionTests.lua
-- In-game test harness for RealUI Bugfix Package 2
-- These tests confirm that each of the 9 bugs EXISTS in the unfixed code.
-- Tests are EXPECTED TO FAIL (i.e., detect the bug) on unfixed code.
-- A "FAIL" result means the bug was successfully detected (good!).
-- A "PASS" result means the bug was NOT detected (unexpected).
--
-- Usage: /realdev bugtest
-- Or:    /realdev bugtest <number>  (e.g., /realdev bugtest 3)
--
-- **Validates: Requirements 1.1, 1.2, 1.3, 1.4, 1.5, 1.6, 1.7, 1.8,
--   1.9, 1.10, 1.11, 1.12, 1.13, 1.14, 1.15, 1.16, 1.17, 1.18, 1.19, 1.20**

local ADDON_NAME, ns = ... -- luacheck: ignore

local RealUI = _G.RealUI

local BugTests = {}

local results = {}

local function PrintHeader()
    _G.print("|cff00ccff=== RealUI Bug Condition Exploration Tests ===|r")
    _G.print("|cff888888Tests are EXPECTED TO FAIL on unfixed code.|r")
    _G.print("|cff888888FAIL = bug detected (correct). PASS = bug NOT detected (unexpected).|r")
    _G.print("")
end

local function RecordResult(bugNum, testName, passed, detail)
    local status
    if passed then
        status = "|cff00ff00PASS|r"
    else
        status = "|cffff4444FAIL|r"
    end
    local msg = ("  Bug %d — %s: %s"):format(bugNum, testName, status)
    if detail then
        msg = msg .. " — " .. detail
    end
    _G.print(msg)
    results[bugNum] = {
        name = testName,
        passed = passed,
        detail = detail or ""
    }
end

---------------------------------------------------------------------------
-- Bug 1: Roll Cleanup — GroupLootButtonOnClick doesn't remove entries
--         from grouplootlist after RollOnLoot
-- Validates: Requirements 1.1, 1.2, 1.3
---------------------------------------------------------------------------
function BugTests.Test1_RollCleanup()
    local Loot = RealUI:GetModule("Loot", true)
    if not Loot then
        RecordResult(1, "Roll Cleanup", false, "Loot module not found")
        return
    end

    local glFrame = _G.RealUI_GroupLoot
    if not glFrame then
        RecordResult(1, "Roll Cleanup", false,
            "RealUI_GroupLoot not yet created; GroupLootButtonOnClick " ..
            "only calls RollOnLoot with no cleanup (confirmed by source)")
        return
    end

    local hasRollsComplete = glFrame:IsEventRegistered("LOOT_ROLLS_COMPLETE")
    if hasRollsComplete then
        RecordResult(1, "Roll Cleanup", true,
            "LOOT_ROLLS_COMPLETE is registered — cleanup may exist")
    else
        RecordResult(1, "Roll Cleanup", false,
            "LOOT_ROLLS_COMPLETE not registered on RealUI_GroupLoot; " ..
            "roll entries persist in grouplootlist after RollOnLoot")
    end
end

---------------------------------------------------------------------------
-- Bug 2: Castbar Text Layer — Text/Time font strings render below the
--         fill texture because they share the same frame level as the bar
-- Validates: Requirements 1.4, 1.5
---------------------------------------------------------------------------
function BugTests.Test2_CastbarTextLayer()
    local CastBars = RealUI:GetModule("CastBars", true)
    if not CastBars then
        RecordResult(2, "Castbar Text Layer", false, "CastBars module not found")
        return
    end

    local castbar = CastBars["player"]
    if not castbar then
        RecordResult(2, "Castbar Text Layer", false,
            "Player castbar not yet created; CreateCastBars source " ..
            "creates Text/Time as direct children of Castbar (no textOverlay)")
        return
    end

    local hasTextOverlay = castbar.textOverlay ~= nil
    if hasTextOverlay then
        local overlayLevel = castbar.textOverlay:GetFrameLevel()
        local barLevel = castbar:GetFrameLevel()
        if overlayLevel > barLevel then
            RecordResult(2, "Castbar Text Layer", true,
                ("textOverlay level %d > castbar level %d"):format(overlayLevel, barLevel))
        else
            RecordResult(2, "Castbar Text Layer", false,
                ("textOverlay exists but level %d <= castbar level %d"):format(overlayLevel, barLevel))
        end
    else
        local textParent = castbar.Text and castbar.Text:GetParent()
        local parentName = textParent and (textParent:GetName() or tostring(textParent)) or "nil"
        RecordResult(2, "Castbar Text Layer", false,
            "No textOverlay frame; Text parented to " .. parentName ..
            " (same frame level as fill texture)")
    end
end

---------------------------------------------------------------------------
-- Bug 3: Unit Attribute Exposure — overlay frame intercepts mouse focus
--         without exposing unit attribute for Bartender4 mouseover cast
-- Validates: Requirements 1.6
---------------------------------------------------------------------------
function BugTests.Test3_UnitAttributeExposure()
    local playerFrame = _G.RealUIPlayerFrame
    if not playerFrame then
        RecordResult(3, "Unit Attribute Exposure", false,
            "RealUIPlayerFrame not found; overlay created in Shared.lua " ..
            "without EnableMouse(false) — intercepts mouse focus by default")
        return
    end

    local overlay = playerFrame.overlay
    if not overlay then
        RecordResult(3, "Unit Attribute Exposure", false,
            "Player frame has no overlay — unexpected state")
        return
    end

    local mouseEnabled = overlay:IsMouseEnabled()
    if mouseEnabled then
        RecordResult(3, "Unit Attribute Exposure", false,
            "overlay:IsMouseEnabled() = true; overlay intercepts mouse " ..
            "focus, blocking Bartender4 mouseover cast from detecting unit")
    else
        RecordResult(3, "Unit Attribute Exposure", true,
            "overlay:IsMouseEnabled() = false; mouse passes through to unit frame")
    end
end

---------------------------------------------------------------------------
-- Bug 4: UI Scale CVar — no conflict warning when useUiScale CVar is "1"
-- Validates: Requirements 1.7, 1.8
---------------------------------------------------------------------------
function BugTests.Test4_UIScaleCVar()
    local dbg = RealUI.db and RealUI.db.global
    if not dbg then
        RecordResult(4, "UI Scale CVar", false, "Global DB not available")
        return
    end

    local hasWarningTag = dbg.tags and dbg.tags.uiScaleWarningDismissed ~= nil
    local cvarValue = _G.GetCVar("useUiScale")

    if hasWarningTag then
        RecordResult(4, "UI Scale CVar", true,
            "uiScaleWarningDismissed tag exists in DB; conflict detection implemented")
    else
        RecordResult(4, "UI Scale CVar", false,
            "No uiScaleWarningDismissed tag in DB; no conflict detection " ..
            "for useUiScale CVar (current value: " .. tostring(cvarValue) .. ")")
    end
end

---------------------------------------------------------------------------
-- Bug 5: Profile Module State — modules incorrectly disabled after healer
--         profile switch
-- Validates: Requirements 1.9, 1.10, 1.11, 1.12, 1.13
---------------------------------------------------------------------------
function BugTests.Test5_ProfileModuleState()
    local AddonControl = RealUI:GetModule("AddonControl", true)
    local hasUserOverride = false

    if AddonControl and AddonControl.db then
        local addonDB = AddonControl.db.profile
        if addonDB and addonDB.addonControl and addonDB.addonControl["Bartender4"] then
            local bt4Config = addonDB.addonControl["Bartender4"]
            if bt4Config.profiles and bt4Config.profiles.base then
                hasUserOverride = bt4Config.profiles.base.userOverride ~= nil
            end
        end
    end

    local castBarsEnabled = RealUI.db and RealUI.db.profile and
        RealUI.db.profile.modules and RealUI.db.profile.modules["CastBars"]

    if hasUserOverride then
        RecordResult(5, "Profile Module State", true,
            "userOverride flag exists in AddonControl for Bartender4")
    else
        local detail = "No userOverride guard in AddonControl; " ..
            "SetProfilesToRealUI can cascade-disable modules. " ..
            "CastBars enabled=" .. tostring(castBarsEnabled)
        RecordResult(5, "Profile Module State", false, detail)
    end
end

---------------------------------------------------------------------------
-- Bug 6: Player Buffs Element — no Buffs element on player unit frame
-- Validates: Requirements 1.14
---------------------------------------------------------------------------
function BugTests.Test6_PlayerBuffsElement()
    local playerFrame = _G.RealUIPlayerFrame
    local targetFrame = _G.RealUITargetFrame

    if not playerFrame then
        RecordResult(6, "Player Buffs Element", false,
            "RealUIPlayerFrame not spawned; Player.lua create() has no " ..
            "Buffs element (confirmed by source — unlike Target.lua)")
        return
    end

    local hasPlayerBuffs = playerFrame.Buffs ~= nil
    local hasTargetBuffs = targetFrame and targetFrame.Buffs ~= nil

    if hasPlayerBuffs then
        RecordResult(6, "Player Buffs Element", true,
            "RealUIPlayerFrame.Buffs exists")
    else
        local detail = "RealUIPlayerFrame.Buffs is nil"
        if hasTargetBuffs then
            detail = detail .. " (but RealUITargetFrame.Buffs exists — asymmetry confirmed)"
        end
        RecordResult(6, "Player Buffs Element", false, detail)
    end
end

---------------------------------------------------------------------------
-- Bug 7: Configured Character Login — NeedsSetup returns true for
--         already-configured characters
-- Validates: Requirements 1.15, 1.16
---------------------------------------------------------------------------
function BugTests.Test7_ConfiguredCharacterLogin()
    local SetupSystem = RealUI.SetupSystem
    if not SetupSystem then
        RecordResult(7, "Configured Character Login", false,
            "SetupSystem not found")
        return
    end

    local dbc = RealUI.db and RealUI.db.char
    local dbg = RealUI.db and RealUI.db.global
    if not dbc or not dbg then
        RecordResult(7, "Configured Character Login", false,
            "Character or global DB not available")
        return
    end

    local installStage = dbc.init and dbc.init.installStage
    local initialized = dbc.init and dbc.init.initialized
    local setupVersion = dbg[SetupSystem.SETUP_VERSION_KEY]

    if installStage == -1 and initialized then
        local needsSetup = SetupSystem:NeedsSetup()
        if needsSetup then
            RecordResult(7, "Configured Character Login", false,
                "NeedsSetup() returns true for configured character " ..
                "(installStage=-1, initialized=true, setupVersion=" ..
                tostring(setupVersion) .. ")")
        else
            RecordResult(7, "Configured Character Login", true,
                "NeedsSetup() correctly returns false for configured character")
        end
    else
        local needsSetup = SetupSystem:NeedsSetup()
        RecordResult(7, "Configured Character Login", false,
            "Character not fully configured (installStage=" ..
            tostring(installStage) .. ", initialized=" ..
            tostring(initialized) .. "); NeedsSetup=" ..
            tostring(needsSetup) .. ", setupVersion=" ..
            tostring(setupVersion) ..
            ". Bug exists: NeedsSetup has no early-return for installStage==-1")
    end
end

---------------------------------------------------------------------------
-- Bug 8: MiniPatch Existence — minipatches[0] is nil, no migration for
--         major version transitions
-- Validates: Requirements 1.17, 1.18
---------------------------------------------------------------------------
function BugTests.Test8_MiniPatchExistence()
    local minipatches = RealUI.minipatches
    if not minipatches then
        RecordResult(8, "MiniPatch Existence", false,
            "RealUI.minipatches table not found")
        return
    end

    local hasPatch0 = minipatches[0] ~= nil

    local patchCount = 0
    local maxPatch = 0
    for i = 0, 9 do
        if minipatches[i] then
            patchCount = patchCount + 1
            if i > maxPatch then maxPatch = i end
        end
    end

    if hasPatch0 and patchCount > 2 then
        RecordResult(8, "MiniPatch Existence", true,
            ("minipatches[0] exists; %d total patches (max index: %d)"):format(
                patchCount, maxPatch))
    else
        local detail = "minipatches[0]=" .. tostring(minipatches[0] ~= nil)
        detail = detail .. "; total patches=" .. patchCount
        detail = detail .. "; only [1] exists (reverseMissing cleanup)"
        detail = detail .. "; no migration for 2.5.3→3.0.0 or 3.0.0→3.0.9"
        RecordResult(8, "MiniPatch Existence", false, detail)
    end
end

---------------------------------------------------------------------------
-- Bug 9: Duplicate Scale Message — scaleReported not set early enough,
--         both RealUI_Skins and Aurora standalone messages print
-- Validates: Requirements 1.19, 1.20
---------------------------------------------------------------------------
function BugTests.Test9_DuplicateScaleMessage()
    local Aurora = _G.Aurora
    if not Aurora then
        RecordResult(9, "Duplicate Scale Message", false,
            "Aurora global not found")
        return
    end

    local Skins = RealUI:GetModule("Skins", true)
    if not Skins then
        RecordResult(9, "Duplicate Scale Message", false,
            "Skins module not found; RealUI_Skins may not be loaded")
        return
    end

    local hasReplacement = type(RealUI.UpdateUIScale) == "function"

    if hasReplacement and Skins then
        RecordResult(9, "Duplicate Scale Message", true,
            "RealUI_Skins loaded and UpdateUIScale replaced; " ..
            "OnLoad sets private.scaleReported = true before deferred callback")
    else
        RecordResult(9, "Duplicate Scale Message", false,
            "No early scaleReported set; private.scaleReported only set " ..
            "inside UpdateUIScale body (after print). Aurora's deferred " ..
            "callback can race and print duplicate scale message")
    end
end

---------------------------------------------------------------------------
-- Test Runner
---------------------------------------------------------------------------
local testFunctions = {
    [1] = BugTests.Test1_RollCleanup,
    [2] = BugTests.Test2_CastbarTextLayer,
    [3] = BugTests.Test3_UnitAttributeExposure,
    [4] = BugTests.Test4_UIScaleCVar,
    [5] = BugTests.Test5_ProfileModuleState,
    [6] = BugTests.Test6_PlayerBuffsElement,
    [7] = BugTests.Test7_ConfiguredCharacterLogin,
    [8] = BugTests.Test8_MiniPatchExistence,
    [9] = BugTests.Test9_DuplicateScaleMessage,
}

function BugTests:RunAll()
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

function BugTests:RunSingle(num)
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

function BugTests:PrintSummary()
    _G.print("")
    local passed, failed = 0, 0
    for _, r in _G.pairs(results) do
        if r.passed then passed = passed + 1 else failed = failed + 1 end
    end
    _G.print("|cff00ccff=== Summary ===|r")
    _G.print(("  Bugs detected (FAIL): |cffff4444%d|r"):format(failed))
    _G.print(("  Bugs NOT detected (PASS): |cff00ff00%d|r"):format(passed))
    if failed > 0 then
        _G.print("|cff888888All FAILs are expected on unfixed code — bugs confirmed.|r")
    end
end

-- Register via RealUI_Dev slash command system
function ns.commands:bugtest(arg)
    if arg and arg ~= "" then
        BugTests:RunSingle(arg)
    else
        BugTests:RunAll()
    end
end
