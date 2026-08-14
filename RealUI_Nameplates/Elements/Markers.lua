local _, private = ...
local NP = private.NP
local Safe = private.Safe

--[[ Quest objective, raid target icon, rare/elite marker. Quest detection scans
     C_TooltipInfo unit data (no direct unit-quest API); fully guarded and throttled
     to the slow tick. ]]--

local Markers = {}

function Markers.Create(plate)
    local raidIcon = plate:CreateTexture(nil, "OVERLAY")
    raidIcon:SetSize(18, 18)
    raidIcon:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
    raidIcon:SetPoint("LEFT", plate, "RIGHT", 30, 0)
    raidIcon:Hide()

    local rare = plate:CreateTexture(nil, "OVERLAY")
    rare:SetSize(14, 14)
    rare:SetPoint("RIGHT", plate, "LEFT", -2, 8)
    rare:Hide()

    local quest = plate:CreateTexture(nil, "OVERLAY")
    quest:SetSize(12, 12)
    quest:SetPoint("RIGHT", rare, "LEFT", -2, 0)
    if not private.Try(quest.SetAtlas, quest, "SmallQuestBang", false) then
        quest:SetTexture([[Interface\GossipFrame\AvailableQuestIcon]])
    end
    quest:Hide()

    plate.Markers = { raidIcon = raidIcon, rare = rare, quest = quest, questDirty = false }
end

local function UpdateRaidIcon(plate)
    local markers = plate.Markers
    if not NP.db.profile.enemy.markers.raidIcon then
        markers.raidIcon:Hide()
        return
    end
    local index = _G.GetRaidTargetIndex(plate.unit)
    if index then
        _G.SetRaidTargetIconTexture(markers.raidIcon, index)
        markers.raidIcon:Show()
    else
        markers.raidIcon:Hide()
    end
end

local function UpdateRare(plate)
    local markers = plate.Markers
    if plate.design ~= "enemy" or not NP.db.profile.enemy.markers.rare then
        markers.rare:Hide()
        return
    end
    local classification = _G.UnitClassification(plate.unit)
    if classification == "rare" then
        Safe(markers.rare.SetAtlas, markers.rare, "nameplates-icon-elite-silver", false)
        markers.rare:Show()
    elseif classification == "elite" or classification == "rareelite" or classification == "worldboss" then
        Safe(markers.rare.SetAtlas, markers.rare, "nameplates-icon-elite-gold", false)
        markers.rare:Show()
    else
        markers.rare:Hide()
    end
end

local function UpdateQuest(plate)
    local markers = plate.Markers
    markers.questDirty = false
    if plate.design ~= "enemy" or not NP.db.profile.enemy.markers.quest then
        markers.quest:Hide()
        return
    end
    local isQuestUnit = Safe(function()
        local data = _G.C_TooltipInfo.GetUnit(plate.unit)
        if not data or not data.lines then return false end
        local questObjective = _G.Enum.TooltipDataLineType.QuestObjective
        local questTitle = _G.Enum.TooltipDataLineType.QuestTitle
        for i = 1, #data.lines do
            local lineType = data.lines[i].type
            if lineType == questObjective or lineType == questTitle then
                return true
            end
        end
        return false
    end)
    markers.quest:SetShown(isQuestUnit or false)
end

function Markers.Attach(plate, unit)
    UpdateRaidIcon(plate)
    UpdateRare(plate)
    UpdateQuest(plate)
end

function Markers.Detach(plate)
    plate.Markers.raidIcon:Hide()
    plate.Markers.rare:Hide()
    plate.Markers.quest:Hide()
end

function Markers.OnRaidTargetUpdate(plate)
    UpdateRaidIcon(plate)
end

function Markers.OnTick(plate, doSlow)
    if doSlow and plate.Markers.questDirty then
        UpdateQuest(plate)
    end
end

function Markers.OnEnable()
    NP:RegisterEvent("QUEST_LOG_UPDATE", function()
        for _, plate in _G.next, private.activeByUnit do
            plate.Markers.questDirty = true
        end
    end)
end

private.AddElement("Markers", Markers)
