local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G

do --[[ World Map ]]--
    -- original code by ls- (lightspark)
    local old_ResetZoom = _G.WorldMapScrollFrame_ResetZoom
    _G.WorldMapScrollFrame_ResetZoom = function()
        if _G.InCombatLockdown() then
            _G.WorldMapFrame_Update()
            _G.WorldMapScrollFrame_ReanchorQuestPOIs()
            _G.WorldMapFrame_ResetPOIHitTranslations()
            _G.WorldMapBlobFrame_DelayedUpdateBlobs()
        else
            old_ResetZoom()
        end
    end

    local old_QuestMapFrame_OpenToQuestDetails = _G.QuestMapFrame_OpenToQuestDetails
    _G.QuestMapFrame_OpenToQuestDetails = function(questID)
        if _G.InCombatLockdown() then
            _G.ShowUIPanel(_G.WorldMapFrame);
            _G.QuestMapFrame_ShowQuestDetails(questID)
            _G.QuestMapFrame.DetailsFrame.mapID = nil
        else
            old_QuestMapFrame_OpenToQuestDetails(questID)
        end
    end

    _G.WorldMapFrame.questLogMode = true
    _G.QuestMapFrame_Open(true)
end


do --[[ Artifact Frame ]]--
    -- by Gnarfoz
    --C_ArtifactUI.GetTotalPurchasedRanks() shenanigans
    local orig_show
    local new_show
    local counter = 0

    local function new_show(self)
        if C_ArtifactUI.GetTotalPurchasedRanks() then 
            orig_show(self)
        else
            ArtifactFrame:Hide()
            counter = counter + 1
            print("GTPR is nil, count: " ..counter)
        end
    end

    local function hook_artifact_show()
        if not orig_show then
            orig_show = ArtifactFrame:GetScript("OnShow")
            ArtifactFrame:SetScript("OnShow", new_show)
        end
    end
    hooksecurefunc("ArtifactFrame_LoadUI", hook_artifact_show)
end
