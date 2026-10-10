local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

---------------------------------------------------------
-- Quest count in module headers (Task 11)
---------------------------------------------------------

-- Modules whose headers can show a count
local HEADER_MODULES = {
    _G.QuestObjectiveTracker,
    _G.CampaignQuestObjectiveTracker,
    _G.AdventureObjectiveTracker,
    _G.ProfessionsRecipeTracker,
    _G.BonusObjectiveTracker,
    _G.WorldQuestObjectiveTracker,
}

-- GetModuleCount — counts visible blocks across all templates for a module.
-- usedBlocks is structured as usedBlocks[template][id], so we need a double
-- iteration. Does NOT use C_QuestLog.GetNumQuestWatches() — that returns
-- total watched quests across all modules, not what's visible in this
-- module's header.
local function GetModuleCount(module)
    local count = 0
    if module.usedBlocks then
        for template, blocks in pairs(module.usedBlocks) do
            for _ in pairs(blocks) do
                count = count + 1
            end
        end
    end
    return count
end

-- UpdateModuleHeader — appends (N) to header text when db.display.questCount is true
--
-- tracker-widget-taint-rewrite 5.4, 2026-10-05: reviewed against doctrine R3
-- and kept. It is a feature (the count), not a cosmetic rename, and the text
-- change stays in place: the module header is a fixed 260x26 frame and Text a
-- fixed-width (200), one-line FontString, so nothing Blizzard lays out is
-- resized, and no tracker code reads the header text back. The SetText is
-- AutoScalingFontStringMixin's (SecureUtil.lua:55-58), which calls
-- SetTextScale to fit; its one Lua write, `baseLineHeight`, is made once by
-- Blizzard's own SetHeader in the module's OnLoad, before this hook can run.
-- The hook only reads `usedBlocks` and `headerText`.
local function UpdateModuleHeader(module)
    if not RealUI_Tracker.db.profile.display.questCount then return end
    local header = module.Header
    if not header then return end
    local count = GetModuleCount(module)
    local title = module.headerText or ""
    if count > 0 then
        header.Text:SetText(string.format("%s (%d)", title, count))
    else
        header.Text:SetText(title)
    end
end

---------------------------------------------------------
-- Setup / Cleanup (called from RealUI_Tracker.lua)
---------------------------------------------------------

-- 2026-10-10: the template assignment (a no-op, its XML templates never
-- used) and the difficulty colour (retail scales most quests to the
-- player's level; Forever colours titles natively) are gone.
function RealUI_Tracker:SetupDisplay()
    -- Hook each module's Update method to inject quest counts into headers.
    -- These hooks fire whenever the tracker refreshes (quest add/remove/complete),
    -- so counts update live without additional event registration.
    for _, module in ipairs(HEADER_MODULES) do
        hooksecurefunc(module, "Update", function(moduleSelf)
            UpdateModuleHeader(moduleSelf)
        end)
    end

    private.displaySetUp = true
end

function RealUI_Tracker:CleanupDisplay()
    -- Hooks installed via hooksecurefunc cannot be removed.
    -- They are gated on db settings, so they become inert when disabled.
    private.displaySetUp = false
end
