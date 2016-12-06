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
    -- original code by Gnarfoz
    --C_ArtifactUI.GetTotalPurchasedRanks() shenanigans
    local oldOnShow
    local newOnShow

    local function newOnShow(self)
        if C_ArtifactUI.GetTotalPurchasedRanks() then 
            oldOnShow(self)
        else
            HideUIPanel(ArtifactFrame)
        end
    end

    local function artifactHook()
        if not oldOnShow then
            oldOnShow = ArtifactFrame:GetScript("OnShow")
            ArtifactFrame:SetScript("OnShow", newOnShow)
        end
    end
    hooksecurefunc("ArtifactFrame_LoadUI", artifactHook)
end
