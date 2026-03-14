local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 4: Dynamic block registration produces complete toggle set
-- Validates: Requirements 3.2
--
-- For any block from Infobar:IterateBlocks() with blockInfo.enabled ~= -1,
-- the options table contains [name.."Toggle"], [name.."Label"], [name.."Icon"].

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- Collect all block names that should have toggles (enabled ~= -1).
local function CollectEligibleBlockNames()
    local Infobar = _G.RealUI:GetModule("Infobar")
    if not Infobar or not Infobar.IterateBlocks then
        return nil, "Infobar module not found or missing IterateBlocks"
    end

    local names = {}
    for index, block in Infobar:IterateBlocks() do
        local name = block.name
        local blockInfo = Infobar:GetBlockInfo(name, block.dataObj)
        if blockInfo and blockInfo.enabled ~= -1 then
            names[#names + 1] = name
        end
    end
    return names
end

---------------------------------------------------------------------------
-- Main test
---------------------------------------------------------------------------
local function RunBlockTogglesTest()
    -- Collect eligible block names from Infobar
    local blockNames, err = CollectEligibleBlockNames()
    if not blockNames then
        return 0, 1, err
    end

    if #blockNames == 0 then
        return 1, 0, nil -- vacuously true: no eligible blocks
    end

    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub("AceConfigRegistry-3.0")
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    -- Get the RealUI options table via AceConfigRegistry
    local rootOptions = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if not rootOptions or not rootOptions.args then
        return 0, 1, "Could not retrieve RealUI options table from AceConfigRegistry"
    end

    -- Navigate to the Infobar blocks args table
    local core = rootOptions.args.core
    if not core or not core.args then
        return 0, 1, "Core section not found in RealUI options table"
    end

    local infobar = core.args.infobar
    if not infobar or not infobar.args then
        return 0, 1, "Infobar section not found in Core options"
    end

    local blocks = infobar.args.blocks
    if not blocks or not blocks.args then
        return 0, 1, "Blocks group not found in Infobar options"
    end

    local blocksArgs = blocks.args

    local passed, failed = 0, 0
    local firstFailure = nil
    local SUFFIXES = { "Toggle", "Label", "Icon" }

    for _, name in ipairs(blockNames) do
        for _, suffix in ipairs(SUFFIXES) do
            local key = name .. suffix
            if blocksArgs[key] then
                passed = passed + 1
            else
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Block '%s' missing '%s' entry in options table"):format(name, key)
                end
            end
        end
    end

    return passed, failed, firstFailure
end

---------------------------------------------------------------------------
-- Slash command entry point: /realdev blocktoggles
---------------------------------------------------------------------------
function ns.commands:blocktoggles()
    _G.print("|cff00ccff[Block Toggles Complete]|r Running property test...")

    local ok, passed, failed, firstFailure = pcall(RunBlockTogglesTest)
    if not ok then
        _G.print("|cffff0000[ERROR]|r Test threw an error: " .. tostring(passed))
        return false
    end

    local total = passed + failed
    _G.print(("  Blocks checked: %d eligible, %d toggle entries checked"):format(
        total / 3, total))
    _G.print(("  Results: %d passed, %d failed"):format(passed, failed))

    if failed > 0 then
        _G.print("|cffff0000[FAIL]|r First failure: " .. (firstFailure or "unknown"))
        return false
    else
        _G.print("|cff00ff00[PASS]|r All eligible blocks have Toggle, Label, and Icon entries")
        return true
    end
end
