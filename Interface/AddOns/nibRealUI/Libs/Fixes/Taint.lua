do --[[ World Map ]]--
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


    local old_WorldMapFrame_OnHide = _G.WorldMapFrame:GetScript("OnHide")
    _G.WorldMapFrame:SetScript("OnHide", function(self)
        if _G.InCombatLockdown() then return end
        old_WorldMapFrame_OnHide(self)
    end)
end
