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
-- Quest log capacity in the container header (2026-10-10)
---------------------------------------------------------

-- Standard quests against the cap, as the quest log counts them: no headers,
-- hidden quests, world quests and bonus objectives (tasks) or emissaries.
local function GetQuestCapacity()
    local getMax = _G.C_QuestLog.GetMaxNumQuestsCanAccept
    local max = getMax and getMax()
    if not max or max <= 0 then return end

    local count = 0
    for i = 1, _G.C_QuestLog.GetNumQuestLogEntries() do
        local info = _G.C_QuestLog.GetInfo(i)
        if info and not info.isHeader and not info.isHidden and not info.isTask and not info.isBounty then
            count = count + 1
        end
    end
    return count, max
end

-- Grey, orange within three of the cap, red at the cap.
local function CapacityColor(count, max)
    if count >= max then
        return "ff3333"
    elseif max - count <= 3 then
        return "ff9933"
    end
    return "bfbfbf"
end

-- Same reasoning as UpdateModuleHeader: the container header's Text is a fixed
-- 208-wide, one-line AutoScalingFontString, so the text changes in place and
-- nothing Blizzard lays out is resized. Its one Lua write, `baseLineHeight`,
-- is made by Blizzard's own container Init; the `init` check keeps an early
-- QUEST_LOG_UPDATE from making it first.
local function UpdateContainerHeader()
    local tracker = _G.ObjectiveTrackerFrame
    if not (tracker and tracker.init and tracker.Header) then return end

    local title = tracker.headerText or ""
    local count, max
    if RealUI_Tracker.db.profile.display.questCapacity then
        count, max = GetQuestCapacity()
    end
    if count then
        tracker.Header.Text:SetText(string.format("%s  |cff%s%d/%d|r", title, CapacityColor(count, max), count, max))
    else
        tracker.Header.Text:SetText(title)
    end
end
RealUI_Tracker.UpdateContainerHeader = UpdateContainerHeader

---------------------------------------------------------
-- Turn-in colour (2026-10-10)
---------------------------------------------------------

-- Quests ready to turn in get a green title. In place on the block's existing
-- HeaderText (doctrine R3), from post-hooks on the module instances (spike 1.3:
-- the hooked keys stay secure).
--
-- Blizzard's SetStringText caches the colour it last set in
-- `HeaderText.colorStyle` and skips SetTextColor when it is unchanged, so a
-- block reused for another quest would keep our green. Every pass therefore
-- sets one or the other: green, or the colour Blizzard last chose (read, not
-- written).
local TURN_IN_COLOR = { r = 0.25, g = 1, b = 0.25 }

local QUEST_MODULES = {
    _G.QuestObjectiveTracker,
    _G.CampaignQuestObjectiveTracker,
}

local function ColorBlockHeader(block)
    local text = block.HeaderText
    if not text then return end
    local questID = tonumber(block.id)
    local ready = questID and RealUI_Tracker.db.profile.display.turnInColor
        and _G.C_QuestLog.IsComplete(questID)
    -- Hovered: Blizzard's highlight colour wins.
    local color = (ready and not block.isHighlighted) and TURN_IN_COLOR or text.colorStyle
    if color then
        text:SetTextColor(color.r, color.g, color.b)
    end
end

-- Recolour every live block now, after the setting changes.
function RealUI_Tracker:RefreshTurnInColor()
    for _, module in ipairs(QUEST_MODULES) do
        if module.usedBlocks then
            for _, blocks in pairs(module.usedBlocks) do
                for _, block in pairs(blocks) do
                    ColorBlockHeader(block)
                end
            end
        end
    end
end

---------------------------------------------------------
-- Setup / Cleanup (called from RealUI_Tracker.lua)
---------------------------------------------------------

-- 2026-10-10: the template assignment (a no-op, its XML templates never
-- used) and the difficulty colour (retail scales most quests to the
-- player's level; Forever colours titles natively) are gone; the capacity
-- and turn-in colour are new.
function RealUI_Tracker:SetupDisplay()
    -- Hook each module's Update method to inject quest counts into headers.
    -- These hooks fire whenever the tracker refreshes (quest add/remove/complete),
    -- so counts update live without additional event registration.
    for _, module in ipairs(HEADER_MODULES) do
        _G.hooksecurefunc(module, "Update", function(moduleSelf)
            UpdateModuleHeader(moduleSelf)
        end)
    end

    -- Capacity: after every container update, and on quest log changes that
    -- do not touch the tracker (accepting or abandoning an untracked quest).
    _G.hooksecurefunc(_G.ObjectiveTrackerFrame, "Update", UpdateContainerHeader)
    local events = _G.CreateFrame("Frame")
    events:RegisterEvent("QUEST_LOG_UPDATE")
    events:SetScript("OnEvent", UpdateContainerHeader)

    -- Turn-in colour: after each block is laid out (cached blocks included),
    -- and after the hover highlight ends.
    for _, module in ipairs(QUEST_MODULES) do
        _G.hooksecurefunc(module, "LayoutBlock", function(_, block)
            ColorBlockHeader(block)
        end)
        _G.hooksecurefunc(module, "OnBlockHeaderLeave", function(_, block)
            ColorBlockHeader(block)
        end)
    end

    private.displaySetUp = true
end

function RealUI_Tracker:CleanupDisplay()
    -- Hooks installed via hooksecurefunc cannot be removed.
    -- They are gated on db settings, so they become inert when disabled.
    private.displaySetUp = false
end
