local _, private = ...

-- Lua Globals --
-- luacheck: globals next select tonumber wipe

-- Libs --
local LOP = _G.LibStub("LibObjectiveProgress-1.0")

local progressFormat = "%s |cFFFFFFFF(+%s%%)|r"
local progressInfo, challengeData = {}, {}

function private.AddObjectiveProgress(tooltip, unit, previousLine)
    local npcID = select(6, ("-"):split(_G.UnitGUID(unit)))
    npcID = tonumber(npcID)
    wipe(progressInfo)

    local challengeMapID = _G.C_ChallengeMode.GetActiveChallengeMapID()
    if challengeMapID then
        if not challengeData[challengeMapID] then
            challengeData[challengeMapID] = {}
        end

        if not challengeData[challengeMapID][npcID] then
            local isTeeming = false
            local _, activeAffixIDs = _G.C_ChallengeMode.GetActiveKeystoneInfo()
            for i = 1, #activeAffixIDs do
                if activeAffixIDs[i] == 5 then
                    isTeeming = true
                    break
                end
            end

            local faction = _G.UnitFactionGroup(unit)
            local _, _, _, _, _, _, _, instanceMapID = _G.GetInstanceInfo()
            local isAlternate = challengeMapID == 234 -- Upper Karazhan
            if instanceMapID == 1822 then -- Siege of Boralus
                isAlternate = faction == "Horde"
            end

            local weight = LOP:GetNPCWeightByMap(instanceMapID, npcID, isTeeming, isAlternate)
            if weight then
                challengeData[challengeMapID][npcID] = {
                    weight = weight,
                    text = _G.ENEMY
                }
            end
        end

        progressInfo[challengeMapID] = challengeData[challengeMapID][npcID]
    else
        local taskPOIs = _G.C_TaskQuest.GetQuestsForPlayerByMapID(_G.MapUtil.GetDisplayableMapForPlayer())
        for i, poiData in next, taskPOIs do
            local weight = LOP:GetNPCWeightByQuest(poiData.questId, npcID)
            if poiData.inProgress and weight then
                progressInfo[poiData.questId] = {
                    weight = weight,
                    text = _G.C_TaskQuest.GetQuestInfoByQuestID(poiData.questId)
                }
            end
        end

        for id, info in next, progressInfo do
            for i = previousLine + 1, tooltip:NumLines() do
                local line = _G["GameTooltipTextLeft" .. i]
                if line and line:GetText() == info.text then
                    info.line = line
                    break
                end
            end
        end
    end

    for id, info in next, progressInfo do
        if info.line then
            info.line:SetFormattedText(progressFormat, info.line:GetText(), info.weight)
        else
            _G.GameTooltip:AddLine(progressFormat:format(info.text, info.weight))
        end
    end
end
