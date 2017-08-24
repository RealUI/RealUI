local ADDON_NAME, ns = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local debug = _G.RealUI.GetDebug("Dev")

ns.debug = debug
ns.commands = {}

--_G.GAME_LOCALE ="deDE"
local BlizzAddons = {
    -- Not LoD, in order of load
    "Blizzard_CompactRaidFrames",
    "Blizzard_ClientSavedVariables",
    "Blizzard_CUFProfiles",
    "Blizzard_PetBattleUI",
    "Blizzard_TokenUI",
    "Blizzard_StoreUI", -- can be loaded in GlueXML
    "Blizzard_AuthChallengeUI", -- can be loaded in GlueXML
    "Blizzard_ObjectiveTracker",
    "Blizzard_WowTokenUI",
    "Blizzard_NamePlates",
    "Blizzard_SecureTransferUI",
    "Blizzard_Deprecated",
    "Blizzard_Console",

    -- LoD
    "Blizzard_AchievementUI",
    "Blizzard_AdventureMap",
    "Blizzard_APIDocumentation",
    "Blizzard_ArchaeologyUI",
    "Blizzard_ArenaUI",
    "Blizzard_ArtifactUI",
    "Blizzard_AuctionUI",
    "Blizzard_BarbershopUI",
    "Blizzard_BattlefieldMinimap",
    "Blizzard_BindingUI",
    "Blizzard_BlackMarketUI",
    "Blizzard_BoostTutorial",
    "Blizzard_Calendar",
    "Blizzard_ChallengesUI",
    "Blizzard_ClassTrial",
    "Blizzard_Collections",
    "Blizzard_CombatLog",
    "Blizzard_CombatText",
    "Blizzard_Commentator",
    "Blizzard_Contribution",
    "Blizzard_DeathRecap",
    "Blizzard_DebugTools",
    "Blizzard_EncounterJournal",
    "Blizzard_FlightMap",
    "Blizzard_GarrisonTemplates",
    "Blizzard_GarrisonUI",
    "Blizzard_GMChatUI",
    "Blizzard_GMSurveyUI",
    "Blizzard_GuildBankUI",
    "Blizzard_GuildControlUI",
    "Blizzard_GuildUI",
    "Blizzard_InspectUI",
    "Blizzard_ItemSocketingUI",
    "Blizzard_ItemUpgradeUI",
    "Blizzard_LookingForGuildUI",
    "Blizzard_MacroUI",
    "Blizzard_MapCanvas",
    "Blizzard_MovePad",
    "Blizzard_ObliterumUI",
    "Blizzard_OrderHallUI",
    "Blizzard_PVPUI",
    "Blizzard_QuestChoice",
    "Blizzard_RaidUI",
    "Blizzard_SharedMapDataProviders",
    "Blizzard_SocialUI",
    "Blizzard_TalentUI",
    "Blizzard_TalkingHeadUI",
    "Blizzard_TimeManager",
    "Blizzard_TradeSkillUI",
    "Blizzard_TrainerUI",
    "Blizzard_Tutorial",
    "Blizzard_TutorialTemplates",
    "Blizzard_VoidStorageUI",
}

for i = 1, #BlizzAddons do
    local loaded = _G.IsAddOnLoaded(BlizzAddons[i])
    if loaded then
        debug("Pre-loaded:", BlizzAddons[i])
    end
end

local function profileTest(skip)
    if skip then return end
    local start, _ = _G.debugprofilestop()
    for i = 1, 1000000 do
        _ = "text" .. "concat" .. i
    end
    _G.print("concat", _, _G.debugprofilestop() - start)

    start = _G.debugprofilestop()
    for i = 1, 1000000 do
        _ = ("%s%s%d"):format("text", "concat", i)
    end
    _G.print("format", _, _G.debugprofilestop() - start)
end

local seenEvent, lastEvent = {}
local taintCheck = {
    WorldMap_UpdateQuestBonusObjectives = false,
    NUM_WORLDMAP_DEBUG_ZONEMAP = false,
    WorldMapFrame = false,
}
local eventWhitelist = {
    ADDONS_UNLOADING = true,
    ARENA_PREP_OPPONENT_SPECIALIZATIONS = true,
}
_G.C_Timer.NewTicker(1, function()
    for varName, isTainted in next, taintCheck do
        if not isTainted then
            local isSecure, taint = _G.issecurevariable(varName)
            if not isSecure then
                _G.print(varName, "is tainted by", taint, lastEvent)
                debug(varName, "is tainted by", taint, lastEvent)
                debug(_G.debugstack())
                taintCheck[varName] = true
            end
        end
    end
end)

function ns.commands:testFrame()
    local template = ""
    local parentFrame = _G.CreateFrame("Frame", "RealUI_TestFrameParent", _G.UIParent)
    parentFrame:SetPoint("TOPLEFT", 300, -300)
    parentFrame:SetPoint("BOTTOMRIGHT", -300, 300)

    for i = 1, 2 do
        local testFrame = _G.CreateFrame("Frame", "RealUI_TestFrame"..i, parentFrame, template)
        testFrame:SetParent(parentFrame)
        testFrame:Show()
        local texture = testFrame:CreateTexture(nil, "BACKGROUND")
        _G.Aurora.Base.SetTexture(texture, "roleDAMAGER", true)
        --texture:SetColorTexture(0, 0, 0, 0.2)
        texture:SetPoint("TOPLEFT")
        --texture:SetPoint("BOTTOMRIGHT")

        if i == 1 then
            testFrame:SetPoint("TOPLEFT")
            testFrame:SetPoint("BOTTOMRIGHT", -700, 0)
        else
            testFrame:SetPoint("TOPLEFT", 700, 0)
            testFrame:SetPoint("BOTTOMRIGHT")
            --_G.Aurora.Skin[template](testFrame)
        end
    end
end

local tempColor = {}
local function GetColorTexture(string)
    _G.wipe(tempColor)
    string = string:gsub("Color%-", "")

    local prevChar, val
    string:gsub("(%x)", function(char)
        if prevChar then
            val = _G.tonumber(prevChar..char, 16) / 255 -- convert hex to perc decimal
            _G.tinsert(tempColor, val - (val % 0.01)) -- round val to two decimal places
            prevChar = nil
        elseif char == "0" then
            _G.tinsert(tempColor, 0)
        else
            prevChar = char
        end
    end)

    return tempColor[1], tempColor[2], tempColor[3], tempColor[4]
end
local colors = {
    {0, 0, 0, 1},
    {0, 0, 0, 0},
    {0, 0, 0, 0.5},
    {0.2, 0.2, 0.2, 0.5},
    {1, 0, 0, 1},
    {0.67, 0.83, 0.45, 1},
}
function ns.commands:test()
    local frame = _G.CreateFrame("Frame")

    local texture = frame:CreateTexture()
    local color, colorStr
    for i = 1, #colors do
        color = colors[i]
        texture:SetColorTexture(color[1], color[2], color[3], color[4])
        colorStr = texture:GetTexture()
        _G.print(color[1]..", "..color[2]..", "..color[3]..", "..color[4], colorStr)
        _G.print(GetColorTexture(colorStr))
    end
end
local autorunScripts = {
    alert = false,
    testFrame = false,
}
local frame = _G.CreateFrame("Frame")
frame:RegisterAllEvents()
frame:SetScript("OnEvent", function(self, event, ...)
    lastEvent = event
    if event == "PLAYER_ENTERING_WORLD" then
        for command, run in next, autorunScripts do
            if run then
                ns.commands[command](ns.commands)
            end
        end
    end

    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == ADDON_NAME then
            profileTest(true)
        end

        if addonName:match("Blizzard") or addonName:match("RealUI") then
            debug("Loaded:", addonName)
        end
    elseif not seenEvent[event] then
        debug(event)
        if ... then
            debug("", ...)
        end

        if eventWhitelist[event] then
            _G.print("Dev", event, ...)
        else
            seenEvent[event] = true
        end
    end
end)

-- Slash Commands
_G.SLASH_DEV1 = "/dev"
function _G.SlashCmdList.DEV(msg, editBox)
    local command, arg = _G.strsplit(" ", msg)
    ns.debug("msg:", command, arg, editBox)
    if ns.commands[command] then
        ns.commands[command](ns.commands, arg)
    else
        _G.print("Usage: /dev |cff22dd22command|r")
        for cmd, value in next, ns.commands do
            _G.print(cmd)
        end
    end
end
