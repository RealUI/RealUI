local _, private = ...

-- Lua Globals --
-- luacheck: globals next select tonumber wipe max

-- Libs --
local LOP = _G.LibStub("LibObjectiveProgress-1.0")

local progressFormat = "%s |cFFFFFFFF(+%s%%)|r"
local challengeData = {}

function private.AddObjectiveProgress(tooltip, lineData)
    local npcID = select(6, ("-"):split(_G.UnitGUID(tooltip._unitToken) or ""))
    npcID = tonumber(npcID)

    local weight

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

            local faction = _G.UnitFactionGroup(tooltip._unitToken)
            local _, _, _, _, _, _, _, instanceMapID = _G.GetInstanceInfo()
            local isAlternate = challengeMapID == 234 -- Upper Karazhan
            if instanceMapID == 1822 then -- Siege of Boralus
                isAlternate = faction == "Horde"
            end

            weight = LOP:GetNPCWeightByMap(instanceMapID, npcID, isTeeming, isAlternate)
        end
    else
        local questID = tooltip._questID
        weight = LOP:GetNPCWeightByQuest(questID, npcID)
        if not weight then
            local questCache = private.questCache
            if not questCache[questID] then
                questCache[questID] = {}
            end

            local questProgress = _G.GetQuestProgressBarPercent(questID) or 0
            local taskProgress = _G.C_TaskQuest.GetQuestProgressBarInfo(questID) or 0

            local progress = max(questProgress, taskProgress)
            if questCache[questID][npcID] then
                weight = questCache[questID][npcID]
            else
                weight = progress - (questCache[questID].progress or progress)
                if not questCache[questID][npcID] and weight > 0 then
                    questCache[questID][npcID] = weight
                end
            end

            questCache[questID].progress = progress
        end
    end

    if weight and weight > 0 then
        lineData.leftText = progressFormat:format(lineData.leftText, weight)
    end
end
