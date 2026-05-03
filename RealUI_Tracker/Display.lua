local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

---------------------------------------------------------
-- Template assignment (Task 10)
---------------------------------------------------------

-- Each Blizzard tracker module uses its own specialized block/line templates
-- with required mixins (e.g. QuestObjectiveTracker uses
-- ObjectiveTrackerQuestPOIBlockTemplate which provides SetPOIInfo).
-- Overriding these with a generic base template breaks the mixin chain and
-- causes nil-call errors. Instead, visual tweaks are applied via post-hooks
-- on the existing templates. The custom XML templates (Templates.xml) are
-- defined but not assigned — they serve as a future extension point if
-- Aurora provides compatible template overrides.

local function AssignTemplates()
    -- Intentional no-op: template assignment is deferred until Aurora
    -- provides RealUI-compatible tracker templates that inherit from
    -- the correct per-module base templates (ObjectiveTrackerQuestPOIBlockTemplate,
    -- ObjectiveTrackerAnimLineTemplate, QuestObjectiveLineTemplate, etc.).
end

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
-- Quest difficulty coloring (Task 12)
---------------------------------------------------------

-- Hook LayoutBlock on quest modules to color headers by difficulty.
-- LayoutBlock is called after the block is fully populated (SetHeader,
-- AddObjective, SetPOIInfo have all run), so the HeaderText is set.
-- Because hooksecurefunc chains later hooks after earlier ones, and
-- RealUI_Tracker loads after Aurora (OptionalDep), our hook runs AFTER
-- Aurora's hooks. Our difficulty color overrides Aurora's header color,
-- which is the correct behavior per requirement 7.4.
local QUEST_MODULES = {
    _G.QuestObjectiveTracker,
    _G.CampaignQuestObjectiveTracker,
}

local function HookDifficultyColoring()
    for _, module in ipairs(QUEST_MODULES) do
        hooksecurefunc(module, "LayoutBlock", function(self, block)
            if not RealUI_Tracker.db.profile.display.difficultyColor then return end
            local questID = block.id
            if not questID then return end
            local level = C_QuestLog.GetQuestDifficultyLevel(questID)
            if not level or level == 0 then return end
            local color = GetQuestDifficultyColor(level)
            if block.HeaderText and color then
                block.HeaderText:SetTextColor(color.r, color.g, color.b)
            end
        end)
    end
end

---------------------------------------------------------
-- Setup / Cleanup (called from RealUI_Tracker.lua)
---------------------------------------------------------

function RealUI_Tracker:SetupDisplay()
    -- Template assignment is a no-op for now (see comment above)
    AssignTemplates()

    -- Hook each module's Update method to inject quest counts into headers.
    -- These hooks fire whenever the tracker refreshes (quest add/remove/complete),
    -- so counts update live without additional event registration.
    for _, module in ipairs(HEADER_MODULES) do
        hooksecurefunc(module, "Update", function(self)
            UpdateModuleHeader(self)
        end)
    end

    -- Hook LayoutBlock on quest modules for difficulty coloring
    HookDifficultyColoring()

    private.displaySetUp = true
end

function RealUI_Tracker:CleanupDisplay()
    -- Hooks installed via hooksecurefunc cannot be removed.
    -- They are gated on db settings, so they become inert when disabled.
    private.displaySetUp = false
end
