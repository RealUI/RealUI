local ADDON_NAME, private = ... -- luacheck: ignore

-- Lua Globals --
-- luacheck: globals print next

-- Frame Movement System Test
-- Tests the FrameMover module (Modules/FrameMover.lua) which repositions
-- miscellaneous UI frames not managed by EditMode.

local RealUI = private.RealUI

local FrameMovementTest = {}

function FrameMovementTest:RunTests()
    print("=== Running Frame Movement System Tests ===")

    local FrameMover = RealUI:GetModule("FrameMover", true)
    if not FrameMover then
        print("ERROR: FrameMover module not available")
        return false
    end

    local success = true

    -- Test 1: Module initialization
    success = self:TestModuleInitialization(FrameMover) and success

    -- Test 2: FrameList structure
    success = self:TestFrameListStructure(FrameMover) and success

    -- Test 3: MoveFrameGroup utility
    success = self:TestMoveFrameGroupExport(FrameMover) and success

    print("=== Frame Movement System Tests", success and "PASSED" or "FAILED", "===")
    return success
end

function FrameMovementTest:TestModuleInitialization(FrameMover)
    print("Testing FrameMover module initialization...")

    -- Verify the module has a db
    if not FrameMover.db then
        print("ERROR: FrameMover module has no database")
        return false
    end

    -- Verify the module has a profile
    if not FrameMover.db.profile then
        print("ERROR: FrameMover module has no profile")
        return false
    end

    print("✓ Module initialization test passed")
    return true
end

function FrameMovementTest:TestFrameListStructure(FrameMover)
    print("Testing FrameList structure...")

    local FrameList = FrameMover.FrameList
    if not FrameList then
        print("ERROR: FrameList not exported from FrameMover module")
        return false
    end

    -- Verify uiframes table exists
    if not FrameList.uiframes then
        print("ERROR: FrameList.uiframes missing")
        return false
    end

    -- Verify the 6 expected UI frame entries exist
    local expectedFrames = {
        "zonetext", "raidmessages", "ticketstatus",
        "worldstate", "errorframe", "playerpowerbaralt",
    }

    for _, slug in ipairs(expectedFrames) do
        if not FrameList.uiframes[slug] then
            print("ERROR: Missing expected UI frame entry:", slug)
            return false
        end
        if not FrameList.uiframes[slug].name then
            print("ERROR: UI frame entry missing name:", slug)
            return false
        end
        if not FrameList.uiframes[slug].frames then
            print("ERROR: UI frame entry missing frames table:", slug)
            return false
        end
    end

    -- Verify removed entries are gone
    local removedEntries = { "vsi", "raven", "durabilityframe" }
    for _, slug in ipairs(removedEntries) do
        if FrameList.uiframes[slug] then
            print("ERROR: Removed entry still present in uiframes:", slug)
            return false
        end
    end

    -- Verify addons and hide tables are gone
    if FrameList.addons then
        print("ERROR: FrameList.addons should have been removed")
        return false
    end
    if FrameList.hide then
        print("ERROR: FrameList.hide should have been removed")
        return false
    end

    print("✓ FrameList structure test passed")
    return true
end

function FrameMovementTest:TestMoveFrameGroupExport(FrameMover)
    print("Testing MoveFrameGroup export...")

    if not FrameMover.MoveFrameGroup then
        print("ERROR: MoveFrameGroup not exported from FrameMover module")
        return false
    end

    if type(FrameMover.MoveFrameGroup) ~= "function" then
        print("ERROR: MoveFrameGroup should be a function")
        return false
    end

    print("✓ MoveFrameGroup export test passed")
    return true
end

-- Register test command
if RealUI and RealUI.RegisterChatCommand then
    RealUI:RegisterChatCommand("framemovementtest", function()
        FrameMovementTest:RunTests()
    end)
end

-- Auto-run tests in development mode
if RealUI and RealUI.isDev then
    RealUI:ScheduleTimer(function()
        FrameMovementTest:RunTests()
    end, 3)
end
