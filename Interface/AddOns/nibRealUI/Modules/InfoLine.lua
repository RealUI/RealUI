local _, private = ...

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs
local tostring, select = _G.tostring, _G.select
local min, max, floor = _G.math.min, _G.math.max, _G.math.floor
local tinsert = _G.table.insert

-- Libs --
local Tablet20 = _G.LibStub("Tablet-2.0")
local artData = _G.LibStub("LibArtifactData-1.0", true)

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, dbc, dbg, ndb, ndbc

local MODNAME = "InfoLine"
local InfoLine = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local LoggedIn
local NeedSpecUpdate = false

local ILFrames
local HighlightBar
local TextureFrames = {}
local FramesCreated = false

local layoutSize = 1

local Icons = {
    [1] = {
        start1 =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\Start1]],          15},
        start2 =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\Start2]],          15},
        mail =          {[[Interface\AddOns\nibRealUI\Media\InfoLine\Mail]],            14},
        guild =         {[[Interface\AddOns\nibRealUI\Media\InfoLine\Guild]],           9},
        friends =       {[[Interface\AddOns\nibRealUI\Media\InfoLine\Friends]],         8},
        durability =    {[[Interface\AddOns\nibRealUI\Media\InfoLine\Durability]],      8},
        bag =           {[[Interface\AddOns\nibRealUI\Media\InfoLine\Bags]],            10},
        xp =            {[[Interface\AddOns\nibRealUI\Media\InfoLine\XP]],              11},
        rep =           {[[Interface\AddOns\nibRealUI\Media\InfoLine\Rep]],             11},
        artifact =      {[[Interface\AddOns\nibRealUI\Media\InfoLine\ArtXP]],           11},
        honor =         {[[Interface\AddOns\nibRealUI\Media\InfoLine\Rep]],             11},
        meters =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\Meters]],          10},
        layout_dt =     {[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_DT]],       21},
        layout_h =      {[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_H]],        11},
        system =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\System]],          9},
        currency =      {[[Interface\AddOns\nibRealUI\Media\InfoLine\Currency]],        5},
    },
    [2] = {
        start1 =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\Start1]],          15},
        start2 =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\Start2]],          15},
        mail =          {[[Interface\AddOns\nibRealUI\Media\InfoLine\Mail_HR]],         15},
        guild =         {[[Interface\AddOns\nibRealUI\Media\InfoLine\Guild_HR]],        9},
        friends =       {[[Interface\AddOns\nibRealUI\Media\InfoLine\Friends_HR]],      9},
        durability =    {[[Interface\AddOns\nibRealUI\Media\InfoLine\Durability_HR]],   8},
        bag =           {[[Interface\AddOns\nibRealUI\Media\InfoLine\Bags_HR]],         11},
        xp =            {[[Interface\AddOns\nibRealUI\Media\InfoLine\XP_HR]],           12},
        rep =           {[[Interface\AddOns\nibRealUI\Media\InfoLine\Rep_HR]],          12},
        artifact =      {[[Interface\AddOns\nibRealUI\Media\InfoLine\ArtXP_HR]],        12},
        honor =         {[[Interface\AddOns\nibRealUI\Media\InfoLine\Rep_HR]],          12},
        meters =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\Meters_HR]],       11},
        layout_dt =     {[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_DT_HR]],    22},
        layout_h =      {[[Interface\AddOns\nibRealUI\Media\InfoLine\Layout_H_HR]],     12},
        system =        {[[Interface\AddOns\nibRealUI\Media\InfoLine\System_HR]],       10},
        currency =      {[[Interface\AddOns\nibRealUI\Media\InfoLine\Currency]],        5},
    },
}

local ElementHeight = {
    [1] = 9,
    [2] = 10,
}

local TextPadding = 1

local HighlightColorVals

local TextColorNormal
local TextColorNormalVals
local TextColorWhite
local TextColorTTHeader
local TextColorBlue1

local CurrencyColors = {
    GOLD = {1, 0.95, 0.15},
    SILVER = {0.75, 0.75, 0.75},
    COPPER = {0.75, 0.45, 0.31}
}

local ClassLookup

local PlayerStatusValToStr = {
    [1] = _G.CHAT_FLAG_AFK,
    [2] = _G.CHAT_FLAG_DND,
}

local Tablets = {
    guild = Tablet20,
    friends = Tablet20,
    currency = Tablet20,
    pc = Tablet20,
    spec = Tablet20,
    durability = Tablet20,
}

local CurrencyStartSet, GoldName

local LootSpecIDs = {}


----------------
-- Micro Menu --
----------------
local ddMenuFrame = _G.CreateFrame("Frame", "RealUIStartDropDown", _G.UIParent, "UIDropDownMenuTemplate")
local MicroMenu = {
    {text = "|cffffffffRealUI|r",
        isTitle = true,
        notCheckable = true
    },
    {text = L["Start_Config"],
        func = function()
            RealUI.Debug("Config", "InfoLine")
            RealUI:LoadConfig("HuD")
        end,
        notCheckable = true
    },
    {text = L["Power_PowerMode"],
        notCheckable = true,
        hasArrow = true,
        menuList = {
            {
                text = L["Power_Eco"],
                func = function()
                    _G.print(L["Power_EcoDesc"])
                    RealUI:SetPowerMode(2)
                    RealUI:ReloadUIDialog()
                end,
                checked = function() return RealUI.db.profile.settings.powerMode == 2 end,
            },
            {
                text = L["Power_Normal"],
                func = function()
                    _G.print(L["Power_NormalDesc"])
                    RealUI:SetPowerMode(1)
                    RealUI:ReloadUIDialog()
                end,
                checked = function() return RealUI.db.profile.settings.powerMode == 1 end,
            },
            {
                text = L["Power_Turbo"],
                func = function()
                    _G.print(L["Power_TurboDesc"])
                    RealUI:SetPowerMode(3)
                    RealUI:ReloadUIDialog()
                end,
                checked = function() return RealUI.db.profile.settings.powerMode == 3 end,
            },
        },
    },
    {text = "",
        notCheckable = true,
        disabled = true
    },
    {text = _G.CHARACTER_BUTTON,
        func = function() _G.ToggleCharacter("PaperDollFrame") end,
        notCheckable = true
    },
    {text = _G.SPELLBOOK_ABILITIES_BUTTON,
        func = function() _G.ToggleSpellBook(_G.BOOKTYPE_SPELL) end,
        notCheckable = true
    },
    {text = _G.TALENTS_BUTTON,
        func = function()
            if not _G.PlayerTalentFrame then
                _G.TalentFrame_LoadUI()
            end

            _G.ShowUIPanel(_G.PlayerTalentFrame)
        end,
        notCheckable = true
    },
    {text = _G.ACHIEVEMENT_BUTTON,
        func = function() _G.ToggleAchievementFrame() end,
        notCheckable = true
    },
    {text = _G.QUESTLOG_BUTTON,
        func = function() _G.ToggleQuestLog() end,
        notCheckable = true
    },
    {text = _G.COLLECTIONS,
        func = function() _G.ToggleCollectionsJournal() end,
        notCheckable = true
    },
    {text = _G.SOCIAL_BUTTON,
        func = function() _G.ToggleFriendsFrame(1) end,
        notCheckable = true
    },
    {text = _G.COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE,
        func = function() _G.PVEFrame_ToggleFrame("GroupFinderFrame") end,
        notCheckable = true
    },
    {text = _G.COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP,
        func = function() _G.PVEFrame_ToggleFrame("PVPUIFrame") end,
        notCheckable = true
    },
    {text = _G.ACHIEVEMENTS_GUILD_TAB,
        func = function()
            if _G.IsInGuild() then
                if not _G.GuildFrame then _G.GuildFrame_LoadUI() end
                _G.GuildFrame_Toggle()
            else
                if not _G.LookingForGuildFrame then _G.LookingForGuildFrame_LoadUI() end
                _G.LookingForGuildFrame_Toggle()
            end
        end,
        notCheckable = true
    },
    {text = _G.RAID,
        func = function() _G.ToggleFriendsFrame(4) end,
        notCheckable = true
    },
    {text = _G.HELP_BUTTON,
        func = function() _G.ToggleHelpFrame() end,
        notCheckable = true
    },
    {text = _G.ENCOUNTER_JOURNAL,
        func = function() _G.ToggleEncounterJournal() end,
        notCheckable = true
    },
    {text = _G.LOOKING_FOR_RAID,
        func = function() _G.ToggleRaidBrowser() end,
        notCheckable = true
    },
    {text = _G.BLIZZARD_STORE,
        func = function() _G.ToggleStoreUI() end,
        notCheckable = true,
        -- disabled = IsTrialAccount() or C_StorePublic.IsDisabledByParentalControls()
    }
}

--------------------
-- Misc Functions --
--------------------
-- Convert numbers into currency format (ie. 123456 = 123,456)
local function NumberToCurrencyFormat(val)
    local left, num, right = tostring(val):match('^([^%d]*%d)(%d*)(.-)$')
    return left..(num:reverse():gsub('(%d%d%d)','%1,'):reverse())..right
end

-- Create Copy Frame
local CopyFrame

local function CreateCopyFrame()
    local frame = _G.CreateFrame("Frame", "RealUICopyFrame", _G.UIParent)
    tinsert(_G.UISpecialFrames, "RealUICopyFrame")

    frame:SetBackdrop({
        bgFile = [[Interface\DialogFrame\UI-DialogBox-Background]],
        edgeFile = [[Interface\DialogFrame\UI-DialogBox-Border]],
        tile = true, tileSize = 16, edgeSize = 16,
        insets = { left = 3, right = 3, top = 5, bottom = 3 }
    })
    frame:SetBackdropColor(0,0,0,1)
    frame:SetWidth(400)
    frame:SetHeight(200)
    frame:SetPoint("CENTER", _G.UIParent, "CENTER")
    frame:Hide()
    frame:SetFrameStrata("DIALOG")
    CopyFrame = frame

    local scrollArea = _G.CreateFrame("ScrollFrame", "RealUICopyScroll", frame, "UIPanelScrollFrameTemplate")
    scrollArea:SetPoint("TOPLEFT", frame, "TOPLEFT", 8, -30)
    scrollArea:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 8)

    local editBox = _G.CreateFrame("EditBox", nil, frame)
    editBox:SetMultiLine(true)
    editBox:SetMaxLetters(99999)
    editBox:EnableMouse(true)
    editBox:SetAutoFocus(false)
    editBox:SetFontObject(_G.ChatFontNormal)
    editBox:SetWidth(350)
    editBox:SetHeight(170)
    editBox:SetScript("OnEscapePressed", function() frame:Hide() end)
    CopyFrame.editBox = editBox

    scrollArea:SetScrollChild(editBox)

    local close = _G.CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", frame, "TOPRIGHT")
end

-- Sort by Character
local function CharSort(a, b)
    if a[2] == b[2] then
        return a[8] < b[8]
    end
    return a[2] < b[2]
end

-- Gold string
local function convertMoney(money)
    money = money or 0
    local gold, silver, copper = _G.abs(money / 10000), _G.abs((money / 100) % 100), _G.abs(money % 100)
    if floor(gold) > 0 then
        return ("|cff%s%d|r"):format(TextColorNormal, gold), "GOLD", gold, ("|cff%s%d|r"):format(TextColorNormal, gold)
    elseif floor(silver) > 0 then
        return ("|cff%s%d|r"):format(TextColorNormal, silver), "SILVER", silver, ("|cff%s%d|r|cffc7c7cfs|r"):format(TextColorNormal, silver)
    else
        return ("|cff%s%d|r"):format(TextColorNormal, copper), "COPPER", copper, ("|cff%s%d|r|cffeda55fc|r"):format(TextColorNormal, copper)
    end
end

-- Get Realm time
local function RetrieveGameTime(...)
    local serTime, serAMPM
    local hour, minutes = _G.GetGameTime()

    if ( minutes < 10 ) then minutes = ("%s%s"):format("0", minutes) end

    if ... then
        -- 12 hour clock
        if hour >= 12 then
            serAMPM = "PM"
            if hour > 12 then
                hour = hour - 12
            end
        else
            serAMPM = "AM"
            if hour == 0 then hour = 12 end
        end
        serTime = ("%d:%s %s"):format(hour, minutes, serAMPM)
    else
        serAMPM = ""
        serTime = ("%d:%s"):format(hour, minutes)
    end

    return serTime, serAMPM
end

-- Seconds to Time
local function ConvertSecondstoTime(value)
    local hours, minutes, seconds
    hours = floor(value / 3600)
    minutes = floor((value - (hours * 3600)) / 60)
    seconds = floor(value - ((hours * 3600) + (minutes * 60)))

    if ( hours > 0 ) then
        return ("%dh %dm"):format(hours, minutes)
    elseif ( minutes > 0 ) then
        if minutes >= 10 then
            return ("%dm"):format(minutes)
        else
            return ("%dm %ds"):format(minutes, seconds)
        end
    else
        return ("%ds"):format(seconds)
    end
end

-- Text width
local TestStr = _G.CreateFrame("Frame", nil, _G.UIParent)
TestStr.text = TestStr:CreateFontString()
local function GetTextWidth(str, size)
    TestStr.text:SetFont(_G.RealUIFont_Normal:GetFont(), size)
    TestStr.text:SetText(str)
    return TestStr.text:GetWidth() + 4
end

-- Add blank line to Tablet
local function AddBlankTabLine(cat, ...)
    local blank = {"blank", true, "fakeChild", true, "noInherit", true}
    local cnt = ... or 1
    for i = 1, cnt do
        cat:AddLine(blank)
    end
end

-- Construct standard Header for tablets
local function MakeTabletHeader(col, size, indentation, justifyTable)
    local header = {}
    local colors = RealUI.media.colors.orange

    for i = 1, #col do
        if ( i == 1 ) then
            header["text"] = col[i]
            header["justify"] = justifyTable[i]
            header["size"] = size
            header["textR"] = colors[1]
            header["textG"] = colors[2]
            header["textB"] = colors[3]
            header["indentation"] = indentation
        else
            header["text"..i] = col[i]
            header["justify"..i] = justifyTable[i]
            header["size"..i] = size
            header["text"..i.."R"] = colors[1]
            header["text"..i.."G"] = colors[2]
            header["text"..i.."B"] = colors[3]
            header["indentation"] = indentation
        end
    end
    return header
end

-- Element Width
local function UpdateElementWidth(e, ...)
    local extraWidth = 0
    if ... or e.hidden then
        e.curwidth = 0
        e:SetWidth(e.curwidth)
        InfoLine:UpdatePositions()
    else
        local OldWidth = e.curwidth
        if e.type == 1 then
            e.curwidth = db.position.xgap + e.iconwidth + db.position.xgap
        elseif e.type == 2 then
            e.curwidth = db.position.xgap + (_G.ceil(e.text:GetWidth() / TextPadding) * TextPadding) + db.position.xgap
        elseif e.type == 3 then
            e.curwidth = db.position.xgap + e.iconwidth + extraWidth + (_G.ceil(e.text:GetWidth() / TextPadding) * TextPadding) + db.position.xgap
        elseif e.type == 4 then
            extraWidth = 4
            e.curwidth = db.position.xgap + e.text1:GetWidth()+ extraWidth  + e.iconwidth + extraWidth + e.text2:GetWidth() + db.position.xgap
            e.text1:ClearAllPoints()
            e.text1:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", db.position.xgap, db.position.yoff + db.text.yoffset + 0.5)
            e.icon:ClearAllPoints()
            e.icon:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", db.position.xgap + e.text1:GetWidth() + 2, db.position.yoff)
            e.text2:ClearAllPoints()
            e.text2:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", db.position.xgap + e.text1:GetWidth() + 2 + e.iconwidth + 6, db.position.yoff + db.text.yoffset + 0.5)
        end
        -- if e.side == "LEFT" then e.curwidth = e.curwidth - 5 else e.curwidth = e.curwidth - 2 end
        if e.type == 3 then e.curwidth = e.curwidth - 5 else e.curwidth = e.curwidth - 2 end
        if e.type == 2 then e.curwidth = e.curwidth - 1 end
        if e.tag == "currency" then e.curwidth = e.curwidth + 5 end
        if e.curwidth ~= OldWidth then
            e:SetWidth(e.curwidth)
            InfoLine:UpdatePositions()
        end
    end
end

-- Highlight Bar
local function SetHighlightPosition(e)
    HighlightBar:ClearAllPoints()
    HighlightBar:SetPoint("BOTTOMLEFT", e, "BOTTOMLEFT", 0, -1)
    HighlightBar:SetWidth(e.curwidth)
end

------------
-- GRAPHS --
------------

local Graphs = {}
local GraphHeight = 20  -- multipe of 2
local GraphLineWidth = 3
local GraphColor2 = {0.3, 0.3, 0.3, 0.2}
local GraphColor3 = {0.5, 0.5, 0.5, 0.75}

-- Create Graph
local function CreateGraph(id, maxVal, numVals, parentFrame)
    if Graphs[id] then return end

    -- Create Graph frame
    Graphs[id] = _G.CreateFrame("Frame", nil, _G.UIParent)
    Graphs[id].parentFrame = parentFrame
    Graphs[id]:SetHeight(GraphHeight + 1)

    Graphs[id].gridBot = _G.CreateFrame("Frame", nil, Graphs[id])
    Graphs[id].gridBot:SetHeight(1)
    Graphs[id].gridBot:SetPoint("BOTTOMLEFT", Graphs[id], 0, 0)
    Graphs[id].gridBot:SetPoint("BOTTOMRIGHT", Graphs[id], 0, 0)
    Graphs[id].gridBot.bg = Graphs[id].gridBot:CreateTexture()
    Graphs[id].gridBot.bg:SetAllPoints()
    Graphs[id].gridBot.bg:SetTexture(GraphColor2[1], GraphColor2[2], GraphColor2[3], GraphColor2[4])

    Graphs[id].topLines = {}
    Graphs[id].gapLines = {}
    for c = 1, numVals do
        Graphs[id].topLines[c] = _G.CreateFrame("Frame", nil, Graphs[id])
        Graphs[id].topLines[c]:SetPoint("BOTTOMLEFT", Graphs[id], "BOTTOMLEFT", (c - 1) * GraphLineWidth, 0)
        Graphs[id].topLines[c]:SetHeight(GraphHeight - 1)
        Graphs[id].topLines[c]:SetWidth(GraphLineWidth - 1)

        Graphs[id].topLines[c].point = Graphs[id].topLines[c]:CreateTexture()
        Graphs[id].topLines[c].point:SetPoint("BOTTOM", Graphs[id].topLines[c], "BOTTOM", 0, 0)
        Graphs[id].topLines[c].point:SetHeight(1)
        Graphs[id].topLines[c].point:SetWidth(GraphLineWidth - 1)
        Graphs[id].topLines[c].point:SetTexture(1, 0.15, 0.15)

        Graphs[id].gapLines[c] = {}
        for r = 1, (GraphHeight / 2) + 1 do
            Graphs[id].gapLines[c][r] = Graphs[id].topLines[c]:CreateTexture()
            Graphs[id].gapLines[c][r]:SetPoint("BOTTOM", Graphs[id].topLines[c], "BOTTOM", 0, (r - 1) * 2)
            Graphs[id].gapLines[c][r]:SetHeight(1)
            Graphs[id].gapLines[c][r]:SetWidth(GraphLineWidth - 1)
            Graphs[id].gapLines[c][r]:SetTexture(0, 0, 0, 0)
        end
    end

    -- Fill out Graph info
    Graphs[id].max = maxVal
    Graphs[id].numVals = numVals
    Graphs[id].vals = {}
    for i = 1, numVals do
        Graphs[id].vals[i] = 0
    end
end

-- Update Graph
local function UpdateGraph(id, vals, ...)
    if not Graphs[id] then return end
    if not Graphs[id].enabled then return end

    local numVals = Graphs[id].numVals

    -- Set new Min/Max
    local newMax = ...
    if newMax then
        Graphs[id].max = newMax
    end

    -- Update Vals
    if Graphs[id].shown then
        for c = 1, numVals do
            Graphs[id].vals[c] = min(vals[c] or 0, Graphs[id].max)
            Graphs[id].vals[c] = max(Graphs[id].vals[c], 0)

            local topPoint = max(floor(Graphs[id].vals[c] * ((GraphHeight - 1) / Graphs[id].max) - 1), 0) + 2
            Graphs[id].topLines[c].point:SetPoint("BOTTOM", Graphs[id].topLines[c], "BOTTOM", 0, topPoint)

            for g = 1, (GraphHeight / 2) do
                Graphs[id].gapLines[c][g]:SetTexture(0, 0, 0, 0)
            end
            if topPoint > 1 then
                for r = 1, floor((topPoint / 2)) do
                    if Graphs[id].gapLines[c][r] then
                        Graphs[id].gapLines[c][r]:SetTexture(GraphColor3[1], GraphColor3[2], GraphColor3[3], GraphColor3[4])
                    end
                end
            end
        end
    end
end

-- Show Graph
local function ShowGraph(id, parent, relPoint, point, x, y, parentFrame)
    Graphs[id]:SetParent(parent)
    Graphs[id]:SetFrameStrata("TOOLTIP")
    Graphs[id]:SetFrameLevel(20)
    Graphs[id]:SetPoint(relPoint, parent, point, x, y)
    Graphs[id]:SetWidth(Graphs[id].numVals * 3)

    Graphs[id]:Show()
    Graphs[id].shown = true
end

-- Hide Graph
local function HideGraph(id)
    Graphs[id]:Hide()
    Graphs[id].shown = false
end

-- Hide non-parented Graphs
local function HideOtherGraphs(parentFrame)
    for k, v in next, Graphs do
        if (Graphs[k].parentFrame ~= parentFrame) and Graphs[k].shown then
            HideGraph(k)
        end
    end
end

----------
-- Text --
----------
---- XP/Rep
local InfoLine_XR_OnEnter, InfoLine_XR_Update, InfoLine_XR_OnMouseDown
do
    local showXP, showRep, showArtifact, showHonor
    local watchStates = {
        { -- xp
            GetNext = function()
                return 2, showRep, "rep"
            end,
            GetActive = function()
                return 1, showXP, "xp"
            end,
            OnClick = function()
            end
        },
        { -- rep
            hint = L["Progress_OpenRep"],
            GetNext = function()
                return 3, showArtifact, "artifact"
            end,
            GetActive = function()
                return 2, showRep, "rep"
            end,
            OnClick = function()
                _G.ToggleCharacter("ReputationFrame")
            end
        },
        { -- artifact
            hint = L["Progress_OpenArt"],
            GetNext = function()
                return 4, showHonor, "honor"
            end,
            GetActive = function()
                return 3, showArtifact, "artifact"
            end,
            OnClick = function()
                _G.SocketInventoryItem(16)
            end
        },
        { -- honor
            hint = L["Progress_OpenHonor"],
            GetNext = function()
                return 1, showXP, "xp"
            end,
            GetActive = function()
                return 4, showHonor, "honor"
            end,
            OnClick = function()
                _G.ToggleTalentFrame(_G.PVP_TALENTS_TAB)
            end
        },
    }

    local lvl
    local xp, xpMax, xpPer, restxp
    local rep, replvlmax, repPer, repStandingID, repstatus, watchedFaction
    local artifactID, artifacts, artPer
    local honor, honorMax, honorPer
    function InfoLine_XR_OnEnter(self)
        self:SetAlpha(1)
        local GameTooltip = _G.GameTooltip

        GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, L["Progress"]))
        GameTooltip:AddLine(" ")

        local numActive = 0
        local statusFormat = "%s/%s (%d%%)"
        local color, color2 = RealUI.media.colors.orange
        if _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL then
            local xpStatus
            if _G.IsXPUserDisabled() then
                color2 = {0.3, 0.3, 0.3}
                GameTooltip:AddDoubleLine(_G.EXPERIENCE_COLON, _G.VIDEO_OPTIONS_DISABLED, color[1], color[2], color[3], color2[1], color2[2], color2[3])
            else
                xpStatus = statusFormat:format(RealUI:ReadableNumber(xp), RealUI:ReadableNumber(xpMax), xpPer)
                color2 = {0.9, 0.9, 0.9}
                GameTooltip:AddDoubleLine(_G.EXPERIENCE_COLON, xpStatus, color[1], color[2], color[3], color2[1], color2[2], color2[3])
                if not restxp then
                    GameTooltip:AddDoubleLine(_G.TUTORIAL_TITLE26, "0", 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
                else
                    GameTooltip:AddDoubleLine(_G.TUTORIAL_TITLE26, RealUI:ReadableNumber(restxp), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
                end
            end
            GameTooltip:AddLine(" ")
            numActive = numActive + 1
        end

        if showRep then
            color2 = _G.FACTION_BAR_COLORS[repStandingID]
            local repStatus = statusFormat:format(RealUI:ReadableNumber(rep), RealUI:ReadableNumber(replvlmax), repPer)
            GameTooltip:AddDoubleLine(_G.REPUTATION.._G.HEADER_COLON, watchedFaction, color[1], color[2], color[3], color2[1], color2[2], color2[3])
            GameTooltip:AddDoubleLine(repstatus, repStatus, color2.r, color2.g, color2.b, 0.9, 0.9, 0.9)
            GameTooltip:AddLine(" ")
            numActive = numActive + 1
        end

        if showArtifact then
            local artifact = artifacts[artifactID]
            GameTooltip:AddLine(artifact.name, color[1], color[2], color[3])

            local artStatus = _G.ARTIFACT_POWER_TOOLTIP_TITLE:format(artifact.unspentPower, artifact.power, artifact.maxPower)
            GameTooltip:AddLine(artStatus, 0.9, 0.9, 0.9)

            if artifact.numRanksPurchasable > 0 then
                local artStatus2 = _G.ARTIFACT_POWER_TOOLTIP_BODY:format(artifact.numRanksPurchasable)
                GameTooltip:AddLine(artStatus2, 0.7, 0.7, 0.7, true)
            end
            GameTooltip:AddLine(" ")
            numActive = numActive + 1
        end

        if showHonor then
            color2 = {0.9, 0.9, 0.9}
            local honorStatus
            if _G.CanPrestige() then
                honorStatus = _G.PVP_HONOR_PRESTIGE_AVAILABLE
            else
                honorStatus = statusFormat:format(RealUI:ReadableNumber(honor), RealUI:ReadableNumber(honorMax), honorPer)
            end
            GameTooltip:AddDoubleLine(_G.HONOR.._G.HEADER_COLON, honorStatus, color[1], color[2], color[3], color2[1], color2[2], color2[3])
            GameTooltip:AddLine(" ")
            numActive = numActive + 1
        end

        -- Hint
        color = {0, 1, 0} 
        if watchStates[dbc.xrstate].hint then
            GameTooltip:AddLine(watchStates[dbc.xrstate].hint, color[1], color[2], color[3])
        end
        if numActive > 1 then
            GameTooltip:AddLine(L["Progress_Cycle"], color[1], color[2], color[3])
        end

        GameTooltip:Show()
    end

    function InfoLine_XR_Update(self, event, ...)
        InfoLine:debug("InfoLine_XR_Update", dbc.xrstate, event, ...)
        local repName, replvl, repmin, repmax, repvalue = _G.GetWatchedFactionInfo()
        lvl = _G.UnitLevel("player")

        showXP = lvl < _G.MAX_PLAYER_LEVEL and not _G.IsXPUserDisabled()
        showRep = repName
        InfoLine:debug("Active artifact", artifactID, ...)
        if event == "ARTIFACT_ADDED" or event == "ARTIFACT_POWER_CHANGED" or event == "ARTIFACT_ACTIVE_CHANGED" then
            artifactID = ...
            artifacts = artData:GetAllArtifactsInfo(artifactID)
        end
        InfoLine:debug("GetArtifactInfo", artifactID, artifacts and next(artifacts[artifactID]))
        showArtifact = artifactID and _G.HasArtifactEquipped()
        showHonor = lvl >= _G.MAX_PLAYER_LEVEL_TABLE[_G.LE_EXPANSION_LEVEL_CURRENT] and (_G.IsWatchingHonorAsXP() or _G.InActiveBattlefield())

        -- XP Data
        if showXP then
            xp = _G.UnitXP("player")
            xpMax = _G.UnitXPMax("player")
            restxp = _G.GetXPExhaustion() or 0
            if (xp <= 0) or (xpMax <= 0) then
                xpPer = 0
            else
                xpPer = (xp/xpMax)*100
            end
        end

        -- Currency
        dbg.currency[RealUI.realm][RealUI.faction][RealUI.name].level = lvl

        -- Rep Data
        if showRep then
            watchedFaction = repName
            rep = repvalue - repmin
            replvlmax = repmax - repmin
            repstatus = _G["FACTION_STANDING_LABEL"..replvl]
            repStandingID = replvl

            if (replvlmax <= 0) then
                repPer = 0
            else
                repPer = (rep/replvlmax)*100
            end
        end

        local artifact
        if showArtifact then
            artifact = artifacts[artifactID]
            if (artifact.maxPower <= 0) then
                artPer = 0
            else
                artPer = (artifact.power/artifact.maxPower)*100
            end
        end

        if showHonor then
            honor = _G.UnitHonor("player")
            honorMax = _G.UnitHonorMax("player")
            if (honorMax <= 0) then
                honorPer = 0
            else
                honorPer = (honor/honorMax)*100
            end
        end

        -- Set Info Text
        local _, _, watchState = watchStates[dbc.xrstate]:GetActive()
        local watchText, watchText2, watchFormat2 = 0
        if watchState == "xp" then
            InfoLine:debug("Set XP", showXP)
            if showXP then
                watchText = xpPer
                if restxp > 0 then
                    watchFormat2 = "|cff%s[%.1f÷]|r"
                    watchText2 = (restxp / xpMax) * 100
                end
            end
        elseif watchState == "rep" then
            InfoLine:debug("Set Rep", showRep)
            if showRep then
                watchText = repPer
            end
        elseif watchState == "artifact" then
            InfoLine:debug("Set Artifact", showArtifact)
            if showArtifact then
                watchText = artPer
                if artifact.numRanksPurchasable > 0 then
                    watchFormat2 = "|cff%s[+%d]|r"
                    watchText2 = artifact.numRanksPurchasable
                end
            end
        elseif watchState == "honor" then
            InfoLine:debug("Set Honor", showHonor)
            if showHonor then
                watchText = honorPer
            end
        end

        local showWatch = showXP or showRep or showArtifact or showHonor
        self.hidden = not showWatch
        if showWatch then
            InfoLine:debug("Watch text", watchText, watchText2)
            local watchFormat = "|cff%s %.1f÷|r"
            if watchText2 then
                watchFormat = watchFormat .. watchFormat2
            end
            self.text:SetFormattedText(watchFormat, TextColorNormal, watchText, TextColorBlue1, watchText2)
            self.icon:SetTexture(Icons[layoutSize][watchState][1])
            UpdateElementWidth(self)
        else
            self.text:SetText("")
            UpdateElementWidth(self)
        end
    end

    function InfoLine_XR_OnMouseDown(self, ...)
        InfoLine:debug("InfoLine_XR_OnMouseDown", dbc.xrstate, ...)
        if _G.IsAltKeyDown() then
            repeat
                local state, isActive = watchStates[dbc.xrstate]:GetNext()
                InfoLine:debug("check state", dbc.xrstate, state)
                dbc.xrstate = state
            until isActive
            InfoLine_XR_Update(self)
        else
            watchStates[dbc.xrstate]:OnClick()
        end
    end
end

---- Currency
local CurrencyTabletData = {}
local CurrencyTabletDataRK = {}
local CurrencyTabletDataStart = {}
local CurrencyTabletDataCurrent = {}

local NumCurrencies = 4

local function ShortenDynamicCurrencyName(name)
    local IgnoreLocales = {
        koKR = true,
        zhCN = true,
        zhTW = true,
    }
    if IgnoreLocales[RealUI.locale] then
        return name
    else
        return name ~= nil and name:gsub("%l*%s*%p*", "") or "-"
    end
end

local function Currency_GetDifference(startVal, endVal, isGold)
    startVal = startVal or 0
    endVal = endVal or 0
    local newVal = endVal - startVal
    local newPrefix, newSuffix

    if newVal > 0 then
        newPrefix = "|cff00c000+"
    elseif newVal < 0 then
        newPrefix = "|cffe00000-"
    else
        newPrefix = "|cff4D4D4D"
    end

    if isGold and newVal ~= 0 then
        local gold, silver, copper = _G.abs(newVal / 10000), _G.abs((newVal / 100) % 100), _G.abs(newVal % 100)
        if floor(gold) > 0 then
            newVal = floor(gold)
            newSuffix = "|cffffd700g|r"
        elseif floor(silver) > 0 then
            newVal = floor(silver)
            newSuffix = "|cffc7c7cfs|r"
        else
            newVal = floor(copper)
            newSuffix = "|cffeda55fc|r"
        end
    else
        newSuffix = "|r"
    end

    return (newPrefix.."%s"..newSuffix):format(newVal ~= 0 and _G.abs(newVal) or "~")
end

local function Currency_TabletClickFunc(realm, faction, name)
    if not name then return end
    if realm == RealUI.realm and faction == RealUI.faction and name == RealUI.name then return end
    if _G.IsAltKeyDown() then
        dbg.currency[realm][faction][name] = nil
        ILFrames.currency.needrefreshed = true
        ILFrames.currency.elapsed = 1
    end
end

local RealmSection, MaxWidth = {}, {}
local function Currency_UpdateTablet()
    if not CurrencyTabletData then return end

    local FactionList = {RealUI.faction, RealUI:OtherFaction(RealUI.faction)}
    local HasMaxLvl, OnlyMe = false, true

    -- Get max col widths
    MaxWidth = {[1] = 0, [2] = 0, [3] = 0, [4] = 0, [5] = 0, [6] = 0, [7] = 0, [8] = 0, [9] = 0, [10] = 0, [11] = 0, [12] = 0}
    for kr, vr in next, CurrencyTabletData do
        local realm = kr
        if (CurrencyTabletData[realm]["Alliance"] and (#CurrencyTabletData[realm]["Alliance"] > 0)) or
            (CurrencyTabletData[realm]["Horde"] and (#CurrencyTabletData[realm]["Horde"] > 0)) then

            local TotalGold = 0
            for kf, vf in ipairs(FactionList) do
                if CurrencyTabletData[realm][vf] and #CurrencyTabletData[realm][vf] > 0 then
                    for kn, vn in next, CurrencyTabletData[realm][vf] do
                        if vn[2] == _G.MAX_PLAYER_LEVEL then HasMaxLvl = true end
                        TotalGold = TotalGold + vn[3]
                        MaxWidth[3] = max(MaxWidth[3], GetTextWidth(convertMoney(vn[3]), db.text.tablets.normalsize + ndb.media.font.sizeAdjust))
                        for i = 4, (NumCurrencies + 4) do
                            MaxWidth[i] = max(MaxWidth[i], GetTextWidth(vn[i], db.text.tablets.normalsize + ndb.media.font.sizeAdjust))
                        end
                    end
                end
            end
            MaxWidth[3] = max(MaxWidth[3], GetTextWidth(convertMoney(TotalGold), db.text.tablets.normalsize + ndb.media.font.sizeAdjust))
        end
    end
    MaxWidth[2] = 20    -- Level

    _G.wipe(RealmSection)
    local line = {}
    for kr, vr in ipairs(CurrencyTabletDataRK) do
        local realm = CurrencyTabletDataRK[kr].name
        if  (CurrencyTabletData[realm]["Alliance"] and (#CurrencyTabletData[realm]["Alliance"] > 0)) or
            (CurrencyTabletData[realm]["Horde"] and (#CurrencyTabletData[realm]["Horde"] > 0)) then

            -- Realm Category
            RealmSection[realm] = {}
            RealmSection[realm].cat = Tablets.currency:AddCategory()
            if kr > 1 then
                AddBlankTabLine(RealmSection[realm].cat, 4)
            end
            RealmSection[realm].cat:AddLine("text", realm, "size", db.text.tablets.headersize + ndb.media.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
            AddBlankTabLine(RealmSection[realm].cat, 2)

            -- Characters
            local charCols = {
                _G.NAME,
                _G.LEVEL_ABBR,
                GoldName,
                _G.CURRENCY .. 1,
                _G.CURRENCY .. 2,
                _G.CURRENCY .. 3,
                L["Currency_UpdatedAbbr"]
            }
            RealmSection[realm].charCat = Tablets.currency:AddCategory("columns", #charCols)
            local charHeader = MakeTabletHeader(charCols, db.text.tablets.columnsize + ndb.media.font.sizeAdjust, 12, {"LEFT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"})
            RealmSection[realm].charCat:AddLine(charHeader)
            AddBlankTabLine(RealmSection[realm].charCat, 1)

            local TotalGold, TotalRealmChars = 0, 0
            for kf, vf in ipairs(FactionList) do
                if CurrencyTabletData[realm][vf] and #CurrencyTabletData[realm][vf] > 0 then
                    _G.sort(CurrencyTabletData[realm][vf], CharSort)
                    for kn, vn in next, CurrencyTabletData[realm][vf] do
                        TotalRealmChars = TotalRealmChars + 1
                        local currentName = vn[NumCurrencies + 4]
                        local isPlayer = ((realm == RealUI.realm) and (vf == RealUI.faction) and (currentName == RealUI.name))
                        if not isPlayer then OnlyMe = false end
                        local NormColor = isPlayer and 1 or 0.7
                        local ZeroShade = isPlayer and 0.1 or 0.4

                        _G.wipe(line)
                        for i = 1, #charCols do
                            if (i == 1) then
                                line["indentation"] = 12.5
                                if isPlayer then
                                    line["hasCheck"] = true
                                    line["checked"] = true
                                    line["isRadio"] = true
                                    line["indentation"] = 0
                                end
                                line["text"] = vn[i]
                                line["justify"] = "LEFT"
                                line["func"] = function() Currency_TabletClickFunc(realm, vf, currentName) end
                                line["size"] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                                line["customwidth"] = MaxWidth[NumCurrencies + 4]
                            elseif (i == 2) or (i == (NumCurrencies + 3)) then
                                line["text"..i] = vn[i]
                                line["justify"..i] = "RIGHT"
                                line["text"..i.."R"] = NormColor
                                line["text"..i.."G"] = NormColor
                                line["text"..i.."B"] = NormColor
                                line["customwidth"..i] = MaxWidth[i]
                                line["indentation"..i] = 12.5
                            elseif (i == 3) then
                                TotalGold = TotalGold + vn[i]
                                line["text"..i] = select(4, convertMoney(vn[i]))
                                line["justify"..i] = "RIGHT"
                                line["customwidth"..i] = MaxWidth[i]
                                line["indentation"..i] = 12.5

                            else
                                --if not vn[i] then return end
                                local text
                                if not vn[i] or vn[i] < 0 then
                                    text = dbg.currency[realm][vf][currentName].bpCurrencies[i - 3].name
                                else
                                    text = (vn[i] or "0").." "..ShortenDynamicCurrencyName(dbg.currency[realm][vf][currentName].bpCurrencies[i - 3].name)
                                end
                                line["text"..i] = text
                                line["justify"..i] = "RIGHT"
                                line["customwidth"..i] = MaxWidth[i]
                                line["indentation"..i] = 12.5
                                if vn[i] == 0 then
                                    line["text"..i.."R"] = NormColor - ZeroShade
                                    line["text"..i.."G"] = NormColor - ZeroShade
                                    line["text"..i.."B"] = NormColor - ZeroShade
                                else
                                    line["text"..i.."R"] = NormColor
                                    line["text"..i.."G"] = NormColor
                                    line["text"..i.."B"] = NormColor
                                end

                            end
                        end
                        RealmSection[realm].charCat:AddLine(line)

                        -- Start values
                        if isPlayer then
                            _G.wipe(line)
                            for i = 1, #charCols do
                                if i == 1 then
                                    line["indentation"] = 12
                                    line["text"] = ""
                                    line["justify"] = "LEFT"
                                    line["size"] = db.text.tablets.columnsize + ndb.media.font.sizeAdjust
                                    line["customwidth"] = MaxWidth[(NumCurrencies + 4)]
                                elseif i == 2 or i == (NumCurrencies + 3) then
                                    line["text"..i] = ""
                                    line["justify"..i] = "RIGHT"
                                    line["size"..i] = db.text.tablets.columnsize + ndb.media.font.sizeAdjust
                                    line["customwidth"..i] = MaxWidth[i]
                                    line["indentation"..i] = 12
                                else
                                    line["text"..i] = Currency_GetDifference(CurrencyTabletDataStart[i], CurrencyTabletDataCurrent[i], i == 3)
                                    line["justify"..i] = "RIGHT"
                                    line["size"..i] = db.text.tablets.columnsize + ndb.media.font.sizeAdjust
                                    line["customwidth"..i] = MaxWidth[i]
                                    line["indentation"..i] = 12
                                end
                            end
                            RealmSection[realm].charCat:AddLine(line)
                            AddBlankTabLine(RealmSection[realm].charCat, 4)
                        end
                    end
                    AddBlankTabLine(RealmSection[realm].charCat, 4)
                end
            end

            -- Realm Total
            if TotalRealmChars > 1 then
                RealmSection[realm].charCat:AddLine(
                    "text3", convertMoney(TotalGold),
                    "justify3", "RIGHT",
                    "customwidth3", MaxWidth[3],
                    "size3", db.text.tablets.columnsize + ndb.media.font.sizeAdjust,
                    "indentation3", 12
                )
                AddBlankTabLine(RealmSection[realm].charCat, 4)
            end
        end
    end

    -- Hint
    local hint
    if OnlyMe then
        hint = L["Currency_Cycle"]
    else
        if HasMaxLvl then
            hint = L["Currency_Cycle"].."\n"..L["Currency_EraseData"].."\n"..L["Currency_ResetCaps"]
        else
            hint = L["Currency_Cycle"].."\n"..L["Currency_EraseData"]
        end
    end
    local hintCat = Tablets.currency:AddCategory()
    AddBlankTabLine(hintCat, 10)
    hintCat:AddLine(
        "text", hint,
        "textR", 0,
        "textG", 1,
        "textB", 0,
        "wrap", true
    )
    if not OnlyMe and HasMaxLvl then
        AddBlankTabLine(hintCat, 2)
        hintCat:AddLine(
            "text", L["Currency_NoteWeeklyReset"],
            "size", db.text.tablets.hintsize + ndb.media.font.sizeAdjust,
            "textR", 0.7,
            "textG", 0.7,
            "textB", 0.7,
            "wrap", true
        )
    end
    AddBlankTabLine(hintCat, 1)
    hintCat:AddLine(
        "text", L["Currency_TrackMore"],
        "textR", 0,
        "textG", 1,
        "textB", 0,
        "wrap", true
    )
end

local function Currency_ResetWeeklyValues()
    for kr, vr in next, dbg.currency do
        if vr then
            for kf, vf in next, dbg.currency[kr] do
                if vf then
                    for kn, vn in next, dbg.currency[kr][kf] do
                        if vn then
                            dbg.currency[kr][kf][kn].vpw = 0
                            dbg.currency[kr][kf][kn].cpw = 0
                        end
                    end
                end
            end
        end
    end
end

local function Currency_GetVals()
    local curr = {}
    local idx = 1
    for i = 1, _G.GetCurrencyListSize() do
        local name, _, _, _, isWatched, count = _G.GetCurrencyListInfo(i)
        if isWatched then
            curr[idx] = {
                name = name,
                amnt = count or 0
            }
            --print(curr[idx].name, curr[idx].amnt)
            idx = idx + 1
        end
    end

    return curr
end

local function Currency_Update(self)
    local currDB = dbg.currency[RealUI.realm][RealUI.faction][RealUI.name]
    currDB.class = RealUI.class

    local money = _G.GetMoney()
    local currVals = Currency_GetVals()

    local curDate = _G.date("%b %d") -- e.g. Sep 25
    if curDate:sub(1, 1) == "0" then
        curDate = curDate:sub(2)
    end

    currDB.gold = money or 0
    for i = 1, _G.MAX_WATCHED_TOKENS do
        currDB.bpCurrencies[i] = currVals[i] or {amnt = -1, name = "---"}
        --print(currDB.bpCurrencies[i].name, currDB.bpCurrencies[i].amnt)
    end

    currDB.updated = curDate

    if self.hasshown or self.initialized then
        -- Quick Current reference list
        CurrencyTabletDataCurrent = {
            "",
            "",
            currDB.gold,
            currDB.bpCurrencies[1].amnt,
            currDB.bpCurrencies[2].amnt,
            currDB.bpCurrencies[3].amnt,
            "",
            -- Start session values
            nil,
            currDB.bpCurrencies[1].amnt,
            currDB.bpCurrencies[2].amnt,
            currDB.bpCurrencies[3].amnt,
        }

        -- Start Session
        if not CurrencyStartSet then
            CurrencyTabletDataStart = CurrencyTabletDataCurrent
            CurrencyStartSet = true
        end
    end

    -- Fill out columns
    _G.wipe(CurrencyTabletData)
    _G.wipe(CurrencyTabletDataRK)
    local rCnt = 0
    for kr, vr in next, dbg.currency do
        rCnt = rCnt + 1
        CurrencyTabletData[kr] = {}
        CurrencyTabletDataRK[rCnt] = {name = kr}

        if vr then
            for kf, vf in next, dbg.currency[kr] do
                CurrencyTabletData[kr][kf] = {}

                if vf then
                    for kn, vn in next, dbg.currency[kr][kf] do
                        if vn then
                            local classColor = RealUI:GetClassColor(dbg.currency[kr][kf][kn].class)
                            local nameStr = ("|cff%02x%02x%02x%s|r"):format(classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, kn)

                            if not dbg.currency[kr][kf][kn].bpCurrencies then
                                dbg.currency[kr][kf][kn].bpCurrencies = {
                                    [1] = {amnt = 0, name = nil},
                                    [2] = {amnt = 0, name = nil},
                                    [3] = {amnt = 0, name = nil},
                                }
                            end

                            tinsert(CurrencyTabletData[kr][kf], {
                                nameStr,
                                dbg.currency[kr][kf][kn].level or 0,
                                dbg.currency[kr][kf][kn].gold,
                                dbg.currency[kr][kf][kn].bpCurrencies[1].amnt,
                                dbg.currency[kr][kf][kn].bpCurrencies[2].amnt,
                                dbg.currency[kr][kf][kn].bpCurrencies[3].amnt,
                                dbg.currency[kr][kf][kn].updated,
                                kn,
                            })
                        end

                    end
                end
            end
        end
    end

    -- Refresh tablet
    if Tablets.currency:IsRegistered(self) then
        if _G.Tablet20Frame:IsShown() then
            Tablets.currency:Refresh(self)
        end
    end

    -- Info Text
    local function CurrencyDisplayText(val, abrv)
        return tostring(val or 0) .. " " .. abrv
    end

    local CurText
    -- print("currencystate:", dbc.currencystate)
    if dbc.currencystate == 1 then
        local _, curCurrency, rawValue = convertMoney(money)
        CurText = NumberToCurrencyFormat(RealUI.Round(rawValue))

        -- show C/S/G colored square
        self.icon:Show()
        self.icon:ClearAllPoints()
        self.icon:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", self.text:GetWidth() + 6, 6)
        self.icon:SetVertexColor(CurrencyColors[curCurrency][1], CurrencyColors[curCurrency][2], CurrencyColors[curCurrency][3])
    else
        -- print("currDB:", currDB, " - bpCurrencies:", currDB and currDB.bpCurrencies)
        CurText = CurrencyDisplayText(currDB.bpCurrencies[dbc.currencystate - 1].amnt, ShortenDynamicCurrencyName(currDB.bpCurrencies[dbc.currencystate - 1].name))
        self.icon:Hide()
    end
    self.text:SetFormattedText("%s", CurText)

    UpdateElementWidth(self)
end

local function Currency_OnEnter(self)
    -- Register Tablets.currency
    if not Tablets.currency:IsRegistered(self) then
        Tablets.currency:Register(self,
            "children", function()
                Currency_UpdateTablet()
            end,
            "point", function()
                return "BOTTOMLEFT"
            end,
            "relativePoint", function()
                return "TOPLEFT"
            end,
            "maxHeight", db.other.tablets.maxheight,
            "clickable", true,
            "hideWhenEmpty", true
        )
    end

    if Tablets.currency:IsRegistered(self) then
        -- Tablets.currency appearance
        Tablets.currency:SetColor(self, RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3])
        Tablets.currency:SetTransparency(self, RealUI.media.window[4])
        Tablets.currency:SetFontSizePercent(self, 1)

        -- Open
        Tablets.currency:Open(self)

        HideOtherGraphs(self)
    end

    self.hasshown = true
    Currency_Update(self)
end

local function Currency_OnMouseDown(self)
    if _G.IsShiftKeyDown() then
        Currency_ResetWeeklyValues()
        Currency_Update(self)
        _G.print("|cff0099ffRealUI: |r|cffffffffWeekly caps have been reset.")
    elseif _G.IsAltKeyDown() then
        _G.print("|cff0099ffRealUI: |r|cffffffffTo erase character data, mouse-over their entry in the Currency display and then Alt+Click.")
    else
        local currDB = dbg.currency[RealUI.realm][RealUI.faction][RealUI.name]
        dbc.currencystate = (dbc.currencystate < NumCurrencies) and (dbc.currencystate + 1) or 1
        for i = 1, _G.MAX_WATCHED_TOKENS do
            if (dbc.currencystate == i + 1) and (currDB.bpCurrencies[i].amnt < 0) then
                dbc.currencystate = (dbc.currencystate < NumCurrencies) and (dbc.currencystate + 1) or 1
            end
        end
        if not _G.InCombatLockdown() then
            _G.ToggleCharacter("CurrencyFrame")
        end
        Currency_Update(self)
    end
end

---- Bag
local function InfoLine_Bag_Update(self)
    local freeSlots, totalSlots = 0, 0

    -- Cycle through bags
    for i = 0, 4 do
        local slots, slotsTotal = _G.GetContainerNumFreeSlots(i), _G.GetContainerNumSlots(i)
        if ( i >= 1 ) then  -- Extra bag
            local bagLink = _G.GetInventoryItemLink("player", _G.ContainerIDToInventoryID(i))
            if bagLink then
                freeSlots =  freeSlots + slots
                totalSlots = totalSlots + slotsTotal
            end
        else -- Backpack, we count slots
            freeSlots =  freeSlots + slots
            totalSlots = totalSlots + slotsTotal
        end
    end

    -- Info Text
    self.text:SetFormattedText("|cff%s %d|r", TextColorNormal, freeSlots)
    UpdateElementWidth(self)
end

local function InfoLine_Bag_OnMouseDown(self)
    if _G.ContainerFrame1:IsShown() then
        _G.ToggleBackpack()
    else
        _G.ToggleBackpack()
        for i = 1, _G.NUM_BAG_SLOTS do
            _G.ToggleBag(i)
        end
    end
end

---- Durability
local SlotNameTable = {
    [1] = { slot = "HeadSlot", name = "Head" },
    [2] = { slot = "ShoulderSlot", name = "Shoulder" },
    [3] = { slot = "ChestSlot", name = "Chest" },
    [4] = { slot = "WaistSlot", name = "Waist" },
    [5] = { slot = "WristSlot", name = "Wrist" },
    [6] = { slot = "HandsSlot", name = "Hands" },
    [7] = { slot = "LegsSlot", name = "Legs" },
    [8] = { slot = "FeetSlot", name = "Feet" },
    [9] = { slot = "MainHandSlot", name = "Main Hand" },
    [10] = { slot = "SecondaryHandSlot", name = "Off Hand" },
}
local DuraSlotInfo = { }

local DurabilityAlert
local function Durability_Low(self, dura)
    if not DurabilityAlert then
        DurabilityAlert = _G.CreateFrame("Frame", nil, self, "MicroButtonAlertTemplate")
    end
    if not dura then
        DurabilityAlert:Hide()
    elseif (not DurabilityAlert.isHidden) then
        DurabilityAlert:SetSize(125, DurabilityAlert.Text:GetHeight()+42)
        DurabilityAlert.Arrow:SetPoint("TOP", DurabilityAlert, "BOTTOM", 0, 4)
        DurabilityAlert:SetPoint("BOTTOM", self, "TOP", 0, 18)
        DurabilityAlert.CloseButton:SetScript("OnClick", function(btn)
            DurabilityAlert:Hide()
            DurabilityAlert.isHidden = true
        end)
        DurabilityAlert.Text:SetFormattedText("%s %d%%", _G.DURABILITY, dura)
        DurabilityAlert.Text:SetWidth(100)
        DurabilityAlert:Show()
        DurabilityAlert.isHidden = false
    end
end

local function InfoLine_Durability_OnEnter(self)
    _G.GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
    _G.GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, _G.DURABILITY))
    _G.GameTooltip:AddLine(" ")
    for i = 1, 10 do
        local durastring
        if ( DuraSlotInfo[i].equip and DuraSlotInfo[i].max ~= nil ) then
            local dColor = RealUI:ColorTableToStr({RealUI:GetDurabilityColor(DuraSlotInfo[i].perc / 100)})
            durastring = ("|cff%s%d%%|r"):format(dColor, DuraSlotInfo[i].perc)
            _G.GameTooltip:AddDoubleLine(SlotNameTable[i].name, durastring, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
        end
    end
    _G.GameTooltip:Show()
end

local function InfoLine_Durability_Update(self)
    local minVal = 100

    for i = 1, 10 do
        if not DuraSlotInfo[i] then DuraSlotInfo[i] = {} end
        local slotID = _G.GetInventorySlotInfo(SlotNameTable[i].slot)
        local itemLink = _G.GetInventoryItemLink("player", slotID)
        local value, maximum = 0, 0
        if itemLink ~= nil then
            DuraSlotInfo[i].equip = true
            value, maximum = _G.GetInventoryItemDurability(slotID)
        else
            DuraSlotInfo[i].equip = false
        end
        if ( DuraSlotInfo[i].equip and maximum ~= nil ) then
            DuraSlotInfo[i].value = value
            DuraSlotInfo[i].max = maximum
            DuraSlotInfo[i].perc = floor((DuraSlotInfo[i].value/DuraSlotInfo[i].max)*100)
        end
    end
    for i = 1, 10 do
        if ( DuraSlotInfo[i].equip and DuraSlotInfo[i].max ~= nil ) then
            if DuraSlotInfo[i].perc < minVal then minVal = DuraSlotInfo[i].perc end
        end
    end

    -- Info Text
    if minVal <= 95 then
        self.hidden = false
        self.text:SetFormattedText("|cff%s %d÷|r", TextColorNormal, minVal)
    else
        self.hidden = true
        self.text:SetText("")
    end
    return minVal, UpdateElementWidth(self)
end

local function InfoLine_Durability_OnMouseDown(self)
    if not _G.InCombatLockdown() then
        _G.ToggleCharacter("PaperDollFrame")
    end
end

---- Friends
local FriendsTabletData
local FriendsTabletDataNames
local FriendsOnline = 0

local function Friends_TabletClickFunc(name, iname, bnetIDAccount)
    --print("Name: "..name.." iName: "..iname.." bnetIDAccount: "..bnetIDAccount)
    if not name then return end
    if _G.IsAltKeyDown() then
        if iname == "" then
            _G.InviteUnit(name)
        else
            _G.InviteUnit(iname)
        end
    elseif bnetIDAccount then
        _G.SetItemRef("BNplayer:"..name..":"..bnetIDAccount, "|HBNplayer:"..name.."|h["..name.."|h", "LeftButton")
    else
        _G.SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."]|h", "LeftButton")
    end
end

local FriendsCat
local function Friends_UpdateTablet()
    if ( FriendsOnline > 0 and FriendsTabletData ) then
        -- Title
        local Cols, lineHeader = {
            _G.NAME,
            _G.LEVEL_ABBR,
            _G.ZONE,
            _G.FACTION,
            _G.GAME
        }
        FriendsCat = Tablets.friends:AddCategory("columns", #Cols)
        lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + ndb.media.font.sizeAdjust, 0, {"LEFT", "RIGHT", "LEFT", "LEFT", "LEFT"})
        FriendsCat:AddLine(lineHeader)
        AddBlankTabLine(FriendsCat)

        -- Friends
        for _, val in ipairs(FriendsTabletData) do
            local line = {}
            for i = 1, #Cols do
                if i == 1 then  -- Name
                    line["text"] = val[i]
                    line["justify"] = "LEFT"
                    line["func"] = function() Friends_TabletClickFunc(val[6],val[8],val[9]) end
                    line["size"] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                elseif i == 2 then  -- Level
                    line["text"..i] = val[2]
                    line["justify"..i] = "RIGHT"
                    local uLevelColor = _G.GetQuestDifficultyColor(_G.tonumber(val[2]) or 1)
                    line["text"..i.."R"] = uLevelColor.r
                    line["text"..i.."G"] = uLevelColor.g
                    line["text"..i.."B"] = uLevelColor.b
                    line["size"..i] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                else    -- The rest
                    line["text"..i] = val[i]
                    line["justify"..i] = "LEFT"
                    line["text"..i.."R"] = 0.8
                    line["text"..i.."G"] = 0.8
                    line["text"..i.."B"] = 0.8
                    line["size"..i] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                end
            end
            FriendsCat:AddLine(line)
        end

        -- Hint
        Tablets.friends:SetHint(L["Friend_WhisperInvite"], db.text.tablets.hintsize + ndb.media.font.sizeAdjust)
    end
end

local function Friends_OnEnter(self)
    -- Register Tablets.friends
    if not Tablets.friends:IsRegistered(self) then
        Tablets.friends:Register(self,
            "children", function()
                Friends_UpdateTablet()
            end,
            "point", function()
                return "BOTTOMLEFT"
            end,
            "relativePoint", function()
                return "TOPLEFT"
            end,
            "maxHeight", db.other.tablets.maxheight,
            "clickable", true,
            "hideWhenEmpty", true
        )
    end

    if Tablets.friends:IsRegistered(self) then
        -- Tablets.friends appearance
        Tablets.friends:SetColor(self, RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3])
        Tablets.friends:SetTransparency(self, RealUI.media.window[4])
        Tablets.friends:SetFontSizePercent(self, 1)

        -- Open
        if ( FriendsOnline > 0 ) then
            _G.ShowFriends()
        end
        Tablets.friends:Open(self)

        HideOtherGraphs(self)
    end
end

local BNetRequestAlert
local function Friends_BNetRequest(self, event, ...)
    if not BNetRequestAlert then
        BNetRequestAlert = _G.CreateFrame("Frame", nil, self, "MicroButtonAlertTemplate")
    end
    if (event == "BN_FRIEND_INVITE_REMOVED") then
        BNetRequestAlert:Hide()
    elseif (event == "BN_FRIEND_INVITE_ADDED") or (not BNetRequestAlert.isHidden) then
        BNetRequestAlert:SetSize(177, BNetRequestAlert.Text:GetHeight()+42)
        BNetRequestAlert.Arrow:SetPoint("TOP", BNetRequestAlert, "BOTTOM", -30, 4)
        BNetRequestAlert:SetPoint("BOTTOM", self, "TOP", 30, 18)
        BNetRequestAlert.CloseButton:SetScript("OnClick", function(btn)
            BNetRequestAlert:Hide()
            BNetRequestAlert.isHidden = true
        end)
        BNetRequestAlert.Text:SetText(_G.BN_TOAST_NEW_INVITE)
        BNetRequestAlert.Text:SetWidth(145)
        BNetRequestAlert:Show()
        BNetRequestAlert.isHidden = false
    end
end

local clientString = {
    [_G.BNET_CLIENT_SC2] = "SC2",
    [_G.BNET_CLIENT_WTCG] = "HS",
    [_G.BNET_CLIENT_HEROES] = "HotS",
    [_G.BNET_CLIENT_OVERWATCH] = "OW",
}

local function Friends_Update(self)
    FriendsTabletData = nil
    FriendsTabletDataNames = nil
    local curFriendsOnline = 0

    -- Standard Friends
    for i = 1, _G.GetNumFriends() do
        local name, lvl, class, area, isOnline, status, noteText = _G.GetFriendInfo(i)
        if isOnline then
            if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
            if ( not FriendsTabletDataNames or FriendsTabletDataNames == nil ) then FriendsTabletDataNames = {} end

            curFriendsOnline = curFriendsOnline + 1

            -- Class
            local classColor = RealUI:GetClassColor(ClassLookup[class])

            -- Name
            local cname
            if ( status == "" and name ) then
                cname = ("|cff%02x%02x%02x%s|r"):format(classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
            elseif ( name ) then
                cname = ("%s |cff%02x%02x%02x%s|r"):format(status, classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
            end

            -- Add Friend to list
            tinsert(FriendsTabletData, { cname, lvl, area, RealUI.faction, "WoW", name, noteText, "" })
            if name then
                FriendsTabletDataNames[name] = true
            end
        end
    end

    -- Battle.net Friends
    for t = 1, _G.BNGetNumFriends() do
        local bnetIDAccount, accountName, battleTag, _, _, bnetIDGameAccount, client, isOnline, _, isAFK, isDND, _, noteText = _G.BNGetFriendInfo(t)
        -- WoW friends
        if ( isOnline and client == _G.BNET_CLIENT_WOW ) then
            if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end
            if ( not FriendsTabletDataNames or FriendsTabletDataNames == nil ) then FriendsTabletDataNames = {} end

            local _, characterName, _, realmName, _, faction, _, class, _, zoneName, level = _G.BNGetGameAccountInfo(bnetIDGameAccount)
            curFriendsOnline = curFriendsOnline + 1

            if (realmName == RealUI.realm) then
                FriendsTabletDataNames[characterName] = true
            end

            -- Class
            local classColor = RealUI:GetClassColor(ClassLookup[class])

            -- Name
            local cname
            if ( realmName == _G.GetRealmName() ) then
                -- On My Realm
                cname = ("|cff%02x%02x%02x%s|r |cffcccccc(|r|cff%02x%02x%02x%s|r|cffcccccc)|r"):format(
                    _G.FRIENDS_BNET_NAME_COLOR.r * 255, _G.FRIENDS_BNET_NAME_COLOR.g * 255, _G.FRIENDS_BNET_NAME_COLOR.b * 255,
                    accountName,
                    classColor[1] * 255, classColor[2] * 255, classColor[3] * 255,
                    characterName
                )
            else
                -- On Another Realm
                cname = ("|cff%02x%02x%02x%s|r |cffcccccc(|r|cff%02x%02x%02x%s|r|cffcccccc-%s)|r"):format(
                    _G.FRIENDS_BNET_NAME_COLOR.r * 255, _G.FRIENDS_BNET_NAME_COLOR.g * 255, _G.FRIENDS_BNET_NAME_COLOR.b * 255,
                    accountName,
                    classColor[1] * 255, classColor[2] * 255, classColor[3] * 255,
                    characterName,
                    realmName
                )
            end
            if (isAFK and characterName ) then
                cname = ("%s %s"):format(_G.CHAT_FLAG_AFK, cname)
            elseif(isDND and characterName) then
                cname = ("%s %s"):format(_G.CHAT_FLAG_DND, cname)
            end

            -- Add Friend to list
            tinsert(FriendsTabletData, { cname, level, zoneName, faction, client, accountName, noteText, characterName, bnetIDAccount })
        -- Friends in other games
        elseif (isOnline) then
            if ( not FriendsTabletData or FriendsTabletData == nil ) then FriendsTabletData = {} end

            local _, characterName, _, realmName, realmID, faction, race, class, guild, zoneName, level, gameText = _G.BNGetGameAccountInfo(bnetIDGameAccount)
            InfoLine:debug("BNet: not in WoW", characterName, _, realmName, realmID, faction, race, class, guild, zoneName, level, gameText)
            characterName = _G.BNet_GetValidatedCharacterName(characterName, battleTag, client)
            client = clientString[client] or client
            curFriendsOnline = curFriendsOnline + 1

            -- Name
            local cname
            cname = ("|cff%02x%02x%02x%s|r |cffcccccc(%s)|r"):format(
                _G.FRIENDS_BNET_NAME_COLOR.r * 255, _G.FRIENDS_BNET_NAME_COLOR.g * 255, _G.FRIENDS_BNET_NAME_COLOR.b * 255,
                accountName,
                characterName
            )
            if ( isAFK and characterName ) then
                cname = ("%s %s"):format(_G.CHAT_FLAG_AFK, cname)
            elseif ( isDND and characterName ) then
                cname = ("%s %s"):format(_G.CHAT_FLAG_DND, cname)
            end

            -- Add Friend to list
            tinsert(FriendsTabletData, {cname, level, gameText, class, client, accountName, noteText, "", bnetIDAccount})
        end
    end

    -- OnEnter
    FriendsOnline = curFriendsOnline
    if FriendsOnline > 0 then
        self.hasfriends = true
    else
        self.hasfriends = false
    end

    -- Refresh tablet
    if Tablets.friends:IsRegistered(self) then
        if _G.Tablet20Frame:IsShown() then
            Tablets.friends:Refresh(self)
        end
    end

    -- Info Text
    self.text:SetFormattedText("|cff%s %d|r", TextColorNormal, FriendsOnline)
    UpdateElementWidth(self)
end

local function Friends_OnMouseDown(self)
    if not _G.InCombatLockdown() then
        _G.ToggleFriendsFrame()
    end
end

---- Guild
local GuildTabletData
local GuildOnline = 0

local function Guild_GMOTDClickFunc(gmotd)
    CopyFrame:Show()
    CopyFrame.editBox:SetText(gmotd)
    CopyFrame.editBox:HighlightText(0)
end

local function Guild_TabletClickFunc(name)
    if not name then return end
    if _G.IsAltKeyDown() then
        _G.InviteUnit(name)
    else
        _G.SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
    end
end

local GuildSection = {}
local function Guild_UpdateTablet()
    if ( _G.IsInGuild() and GuildOnline > 0 ) then
        _G.wipe(GuildSection)

        -- Guild Name
        local gname, _, _ = _G.GetGuildInfo("player")
        GuildSection.headerCat = Tablets.guild:AddCategory()
        GuildSection.headerCat:AddLine("text", gname, "size", db.text.tablets.headersize + ndb.media.font.sizeAdjust, "textR", db.colors.ttheader[1], "textG", db.colors.ttheader[2], "textB", db.colors.ttheader[3])
        GuildSection.headerCat:AddLine("isLine", true, "text", "")

        -- Reputation
        GuildSection.headerCat:AddLine("text", _G.GetText("FACTION_STANDING_LABEL".._G.GetGuildFactionInfo(), _G.UnitSex("player")), "size", db.text.tablets.normalsize + ndb.media.font.sizeAdjust, "textR", 0.7, "textG", 0.7, "textB", 0.7)
        AddBlankTabLine(GuildSection.headerCat, 5)

        -- GMOTD
        local gmotd = _G.GetGuildRosterMOTD()
        if gmotd ~= "" then
            GuildSection.headerCat:AddLine("text", gmotd, "wrap", true, "size", db.text.tablets.normalsize + ndb.media.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1, "func", function() Guild_GMOTDClickFunc(gmotd) end)
            AddBlankTabLine(GuildSection.headerCat, 5)
        end
        AddBlankTabLine(GuildSection.headerCat)

        -- Titles
        local Cols, lineHeader = {
            _G.NAME,
            _G.LEVEL_ABBR,
            _G.ZONE,
            _G.RANK,
            _G.LABEL_NOTE
        }
        if _G.CanViewOfficerNote() then
            tinsert(Cols, "Officer Note")
        end

        GuildSection.guildCat = Tablets.guild:AddCategory("columns", #Cols)
        lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + ndb.media.font.sizeAdjust, 0, {"LEFT", "RIGHT", "LEFT", "LEFT", "LEFT", "LEFT"})
        GuildSection.guildCat:AddLine(lineHeader)
        AddBlankTabLine(GuildSection.guildCat)

        -- Guild Members
        local isPlayer, isFriend, isGM, normColor
        local line = {}
        for _, val in ipairs(GuildTabletData) do
            isPlayer = val[7] == RealUI.name
            if FriendsTabletDataNames then
                isFriend = (not isPlayer) and FriendsTabletDataNames[val[7]] or false
            end
            isGM = val[4] == _G.GUILD_RANK0_DESC
            normColor =     isPlayer and {0.3, 1, 0.3} or
                            isFriend and {0, 0.8, 0.8} or
                            isGM and {1, 0.65, 0.2} or
                            {0.8, 0.8, 0.8}
            _G.wipe(line)
            for i = 1, #Cols do
                if i == 1 then  -- Name
                    line["text"] = val[i]
                    line["justify"] = "LEFT"
                    line["func"] = function() Guild_TabletClickFunc(val[7]) end
                    line["size"] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                elseif i == 2 then  -- Level
                    line["text"..i] = val[i]
                    line["justify"..i] = "RIGHT"
                    local uLevelColor = _G.GetQuestDifficultyColor(val[2])
                    line["text"..i.."R"] = uLevelColor.r
                    line["text"..i.."G"] = uLevelColor.g
                    line["text"..i.."B"] = uLevelColor.b
                    line["size"..i] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                else    -- The rest
                    line["text"..i] = val[i]
                    line["justify"..i] = "LEFT"
                    line["text"..i.."R"] = normColor[1]
                    line["text"..i.."G"] = normColor[2]
                    line["text"..i.."B"] = normColor[3]
                    line["size"..i] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                end
            end
            GuildSection.guildCat:AddLine(line)
        end

        -- Hint
        Tablets.guild:SetHint(L["Guild_WhisperInvite"], db.text.tablets.hintsize + ndb.media.font.sizeAdjust)
    end
end

local function Guild_OnEnter(self)
    -- Register Tablets.guild
    if not Tablets.guild:IsRegistered(self) then
        Tablets.guild:Register(self,
            "children", function()
                Guild_UpdateTablet()
            end,
            "point", function()
                return "BOTTOMLEFT"
            end,
            "relativePoint", function()
                return "TOPLEFT"
            end,
            "maxHeight", db.other.tablets.maxheight,
            "clickable", true,
            "hideWhenEmpty", true
        )
    end

    if Tablets.guild:IsRegistered(self) then
        -- Tablets.guild appearance
        Tablets.guild:SetColor(self, RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3])
        Tablets.guild:SetTransparency(self, RealUI.media.window[4])
        Tablets.guild:SetFontSizePercent(self, 1)

        -- Open
        if ( _G.IsInGuild() and GuildOnline > 0 ) then
            _G.GuildRoster()
        end
        Tablets.guild:Open(self)

        HideOtherGraphs(self)
    end
end

local function Guild_Update(self)
    -- If not in guild, set members to 0
    local guildonline = 0
    if not _G.IsInGuild() then
        self.hidden = true
        self.text:SetText("")
        UpdateElementWidth(self)
        return
    end

    GuildTabletData = nil
    -- Total Online Guildies
    for i = 1, _G.GetNumGuildMembers() do
        if ( not GuildTabletData or GuildTabletData == nil ) then GuildTabletData = {} end
        local gPrelist
        local name, rank, _, lvl, _, zone, note, offnote, isOnline, status, class, _, _, mobile = _G.GetGuildRosterInfo(i)

        if (isOnline or mobile) then
            -- Class Color
            local classColor = RealUI:GetClassColor(class)

            -- Player Name
            local cname
            if status == 0 then
                cname = ("|cff%02x%02x%02x%s|r"):format(classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
            else
                local curStatus = PlayerStatusValToStr[status] or ""
                cname = ("%s |cff%02x%02x%02x%s|r"):format(curStatus, classColor[1] * 255, classColor[2] * 255, classColor[3] * 255, name)
            end

            -- Mobile
            if mobile and (not isOnline) then
                cname = _G.ChatFrame_GetMobileEmbeddedTexture(73/255, 177/255, 73/255)..cname
                zone = _G.REMOTE_CHAT
            end

            -- Note
            if _G.CanViewOfficerNote() then
                gPrelist = { cname, lvl, zone, rank, note, offnote, name }
            else
                gPrelist = { cname, lvl, zone, rank, note, " ", name }
            end

            -- Add to list
            tinsert(GuildTabletData, gPrelist)
            guildonline = guildonline + 1
        end
    end

    -- OnEnter
    GuildOnline = guildonline
    if GuildOnline > 0 then
        self.hasguild = true
    else
        self.hasguild = false
    end

    -- Refresh tablet
    if Tablets.guild:IsRegistered(self) then
        Tablets.guild:Refresh(self)
    end

    -- Info Text
    self.hidden = false
    self.text:SetFormattedText("|cff%s %d|r", TextColorNormal, guildonline)
    UpdateElementWidth(self)
end

local function Guild_OnMouseDown(self)
    if not _G.InCombatLockdown() then
        _G.ToggleGuildFrame()
    end
end

-- Meters
local damageMeters
local function Meter_Toggle(self)
    if not self.initialized then return end
    local meter = damageMeters[self.meterLoaded]

    meter.toggle(meter.isVisible())
end

local function Meter_Update(self)
    if not self.initialized then
        damageMeters = {
            Skada = {
                isVisible = function()
                    -- we don't need the frame for skada
                end,
                toggle = function()
                    _G.Skada:ToggleWindow()
                end,
            },
            Recount = {
                isVisible = function()
                    return _G.Recount.MainWindow:IsVisible()
                end,
                toggle = function(isVisible)
                    local frame = _G.Recount.MainWindow
                    if isVisible then
                        frame:Hide()
                    else
                        frame:Show()
                        _G.Recount:RefreshMainWindow()
                    end
                end,
            },
            Details = {
                isVisible = function()
                    return _G._detalhes:GetOpenedWindowsAmount() > 0
                end,
                toggle = function(isVisible)
                    if isVisible then
                        _G._detalhes:ShutDownAllInstances()
                    else
                        _G._detalhes:ReabrirTodasInstancias()
                    end
                end,
            },
            alDamageMeter = {
                isVisible = function()
                    return _G.alDamageMeterFrame:IsVisible()
                end,
                toggle = function(isVisible)
                    if isVisible then
                        _G.alDamageMeterFrame:Hide()
                    else
                        _G.alDamageMeterFrame:Show()
                    end
                end,
            },
        }
        for name, addon in next, damageMeters do
            if _G.IsAddOnLoaded(name) and not self.meterLoaded then
                self.meterLoaded = name
            end
        end
        self.hidden = not self.meterLoaded
        self.initialized = true
    end

    if not self.hidden then
        self.windowopen = damageMeters[self.meterLoaded].isVisible()
    end

    if self.windowopen then
        self.icon:SetVertexColor(1, 1, 1)
    else
        self.icon:SetVertexColor(0.25, 0.25, 0.25)
    end

    InfoLine:UpdatePositions()
end

---- Layout Button
local function Layout_Update(self)
    local CurLayoutIcon

    if ndbc.layout.current == 1 then
        -- DPS/Tank
        CurLayoutIcon = Icons[layoutSize].layout_dt
    else
        -- Healing
        CurLayoutIcon = Icons[layoutSize].layout_h
    end
    self.icon:SetTexture(CurLayoutIcon[1])
    self.iconwidth = CurLayoutIcon[2]
    UpdateElementWidth(self)
end

---- Spec Button
local TalentInfo = {}
local equipSetsByIndex, equipSetsByID = {}, {}

local function SpecChangeClickFunc(self, specIndex)
    InfoLine:debug("SpecChangeClickFunc", specIndex)
    if specIndex then
        local numEquipSets = _G.GetNumEquipmentSets()
        if _G.IsModifierKeyDown() and numEquipSets > 0 then
            if _G.IsShiftKeyDown() then
                dbc.specgear[specIndex] = -1
            elseif _G.IsAltKeyDown() then
                if (dbc.specgear[specIndex] < 0) or (equipSetsByID[dbc.specgear[specIndex]].index == numEquipSets) then 
                    dbc.specgear[specIndex] = equipSetsByIndex[1].id
                else 
                    for equipIndex = equipSetsByID[dbc.specgear[specIndex]].index, numEquipSets do
                        if dbc.specgear[specIndex] ~= equipSetsByIndex[equipIndex].id then
                            dbc.specgear[specIndex] = equipSetsByIndex[equipIndex].id
                            break
                        end
                    end
                end
            end
        else
            if _G.GetSpecialization() == specIndex then
                if dbc.specgear[specIndex] >= 0 then
                    _G.EquipmentManager_EquipSet(equipSetsByID[dbc.specgear[specIndex]].name)
                end
            else
                _G.SetSpecialization(specIndex)
                NeedSpecUpdate = true
            end
        end
    else
        _G.ToggleTalentFrame(_G.SPECIALIZATION_TAB)
    end
end
local function SpecLootClickFunc(self, spec)
    _G.SetLootSpecialization(LootSpecIDs[spec])
end

local function SpecAddSpecLineToCat(self, cat, specIndex)
    InfoLine:debug("SpecAddSpecLineToCat", specIndex)
    local InactiveColor = db.colors.disabled
    local ActiveSpecColor =  RealUI.media.colors.orange
    local ActiveLayoutColor = db.colors.normal

    local activeSpec = _G.GetSpecialization()
    local line = {}

    local hasEquipSets = _G.GetNumEquipmentSets() > 0
    local numCols = hasEquipSets and 3 or 2
    InfoLine:debug("Stats", activeSpec, hasEquipSets, numCols)
    for i = 1, numCols do
        local color
        if i == 1 then
            InfoLine:debug("Spec", i)
            color = (activeSpec == specIndex) and ActiveSpecColor or InactiveColor
            line["text"] = TalentInfo[specIndex].name
            line["justify"] = "LEFT"
            line["size"] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
            line["textR"] = color[1]
            line["textG"] = color[2]
            line["textB"] = color[3]
            line["hasCheck"] = true
            line["checked"] = activeSpec == specIndex
            line["isRadio"] = true
            line["func"] = function(...)
                InfoLine:debug("SpecClick", _G.IsMouseButtonDown("RightButton"), ...)
                SpecChangeClickFunc(self, specIndex)
            end
            --line["customwidth"] = 110
        elseif i == 2 and hasEquipSets then
            local equipSet = dbc.specgear[specIndex] >= 0 and equipSetsByID[dbc.specgear[specIndex]].name or "---"
            local _, _, isEquipped = _G.GetEquipmentSetInfoByName(equipSet)
            color = isEquipped and ActiveLayoutColor or InactiveColor
            InfoLine:debug("Set", i, dbc.specgear[specIndex], equipSet, isEquipped)
            line["text"..i] = equipSet
            line["justify"..i] = "LEFT"
            line["size"..i] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
            line["text"..i.."R"] = color[1]
            line["text"..i.."G"] = color[2]
            line["text"..i.."B"] = color[3]
        else
            InfoLine:debug("Layout", i)
            color = (activeSpec == specIndex) and ActiveLayoutColor or InactiveColor
            line["text"..i] = ndbc.layout.spec[specIndex] == 1 and L["Layout_DPSTank"] or L["Layout_Healing"]
            line["justify"..i] = "LEFT"
            line["size"..i] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
            line["text"..i.."R"] = color[1]
            line["text"..i.."G"] = color[2]
            line["text"..i.."B"] = color[3]
        end
    end
    cat:AddLine(line)
end
local function SpecAddLootSpecToCat(self, cat)
    local specNames = {}
    for i = 1, RealUI.numSpecs do
        local _, name = _G.GetSpecializationInfo(i)
        specNames[i] = name
    end

    local curLootSpecName = RealUI:GetCurrentLootSpecName()

    -- Specs
    local line = {}
    for i = 1, RealUI.numSpecs do
        _G.wipe(line)

        line["text"] = specNames[i]
        line["size"] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
        line["justify"] = "LEFT"
        line["textR"] = (curLootSpecName == specNames[i]) and RealUI.media.colors.blue[1] or db.colors.disabled[1]
        line["textG"] = (curLootSpecName == specNames[i]) and RealUI.media.colors.blue[2] or db.colors.disabled[2]
        line["textB"] = (curLootSpecName == specNames[i]) and RealUI.media.colors.blue[3] or db.colors.disabled[3]
        line["hasCheck"] = true
        line["isRadio"] = true
        line["checked"] = (curLootSpecName == specNames[i])
        line["func"] = function() SpecLootClickFunc(self, i) end

        cat:AddLine(line)
    end
end

local SpecSection = {}
local function Spec_UpdateTablet(self)
    _G.wipe(SpecSection)

    ---- Spec Category
    SpecSection["specs"] = {}
    SpecSection["specs"].cat = Tablets.spec:AddCategory()
    SpecSection["specs"].cat:AddLine("text", _G.SPECIALIZATION, "size", db.text.tablets.headersize + ndb.media.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)

    SpecSection["specs"].talentCat = Tablets.spec:AddCategory("columns", 3)
    AddBlankTabLine(SpecSection["specs"].talentCat, 2)
    for specIndex = 1, RealUI.numSpecs do
        SpecAddSpecLineToCat(self, SpecSection["specs"].talentCat, specIndex)
    end

    ---- Loot Specialization
    if _G.GetSpecialization() then
        AddBlankTabLine(SpecSection["specs"].talentCat, 8)
        SpecSection["loot"] = {}
        SpecSection["loot"].cat = Tablets.spec:AddCategory()
        SpecSection["loot"].cat:AddLine("text", _G.SELECT_LOOT_SPECIALIZATION, "size", db.text.tablets.headersize + ndb.media.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
        AddBlankTabLine(SpecSection["loot"].cat, 2)
        SpecAddLootSpecToCat(self, SpecSection["loot"].cat)
    end

    -- Hint
    local hintStr = ""
    hintStr = hintStr .. L["Spec_ChangeSpec"]
    if _G.GetNumEquipmentSets() > 0 then
        if hintStr ~= "" then hintStr = hintStr .. "\n" end
        hintStr = hintStr .. L["Spec_EquipCycle"]..".\n"..L["Spec_EquipUnassign"]
    end
    Tablets.spec:SetHint(hintStr, db.text.tablets.hintsize + ndb.media.font.sizeAdjust)
end

local function Spec_OnEnter(self)
    -- Register Tablets.spec
    if not Tablets.spec:IsRegistered(self) then
        Tablets.spec:Register(self,
            "children", function()
                Spec_UpdateTablet(self)
            end,
            "point", function()
                return "BOTTOMRIGHT"
            end,
            "relativePoint", function()
                return "TOPRIGHT"
            end,
            "maxHeight", db.other.tablets.maxheight,
            "clickable", true,
            "hideWhenEmpty", true
        )
    end

    -- Tablets.spec appearance
    Tablets.spec:SetColor(self, RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3])
    Tablets.spec:SetTransparency(self, RealUI.media.window[4])
    Tablets.spec:SetFontSizePercent(self, 1)

    -- Open
    Tablets.spec:Open(self)

    HideOtherGraphs(self)

    self.mouseover = true
    self.text:SetTextColor(TextColorNormalVals[1], TextColorNormalVals[2], TextColorNormalVals[3])
end

local setEquipped = false
function InfoLine:SpecUpdateEquip()
    self:debug("SpecUpdateEquip start")
    -- Update Equipment Set
    for equipIndex = 1, _G.GetNumEquipmentSets() do
        if dbc.specgear[_G.GetSpecialization()] == equipSetsByIndex[equipIndex].id then
            _G.EquipmentManager_EquipSet(equipSetsByIndex[equipIndex].name)
        end
    end
    self:debug("SpecUpdateEquip end")
    setEquipped = true
end

local function Spec_Update(self)
    InfoLine:debug("Spec_Update", NeedSpecUpdate)
    -- Gear sets
    _G.wipe(equipSetsByIndex)
    _G.wipe(equipSetsByID)
    local numEquipSets = _G.GetNumEquipmentSets()
    if numEquipSets > 0 then
        for index = 1, numEquipSets do
            local equipName, _, equipID = _G.GetEquipmentSetInfo(index)
            equipSetsByIndex[index] = {
                name = equipName,
                id = equipID
            }
            equipSetsByID[equipID] = {
                name = equipName,
                index = index
            }
        end
    end

    -- Talent Info
    _G.wipe(TalentInfo)
    for specIndex = 1, RealUI.numSpecs do
        local _, name, _, specIcon = _G.GetSpecializationInfo(specIndex)
        TalentInfo[specIndex] = {
            name = name,
            icon = specIcon,
        }

        -- Reset equip set if the saved index doesn't exist
        if not equipSetsByID[dbc.specgear[specIndex]] then
            dbc.specgear[specIndex] = -1
        end
    end

    -- Info text
    local specIndex = _G.GetSpecialization()
    if not specIndex then return end
    self.text:SetText(TalentInfo[specIndex].name)
    UpdateElementWidth(self)

    -- Refresh Tablet
    if Tablets.spec:IsRegistered(self) then
        if _G.Tablet20Frame:IsShown() then
            Tablets.spec:Refresh(self)
        end
    end

    if NeedSpecUpdate then
        InfoLine:debug("NeedSpecUpdate")
        if _G.UnitCastingInfo("player") then
            -- cant swap sets while casting
            _G.C_Timer.After(.25, function()
                InfoLine:SpecUpdateEquip()
            end)
        else
            InfoLine:SpecUpdateEquip()
        end

        -- Update Layout
        ndbc.layout.current = ndbc.layout.spec[specIndex]
        Layout_Update(ILFrames.layout)
        RealUI:UpdateLayout()

        -- ActionBars
        if RealUI:GetModuleEnabled("ActionBars") then
            local ABD = RealUI:GetModule("ActionBars", true)
            if ABD then ABD:RefreshDoodads() end
        end

        -- No longer need Equip/Layout update on Spec change
        NeedSpecUpdate = false
    end
end

---- PC
local SysStats = {
    netTally = 0,
    bwIn =      {cur = 0, tally = {}, avg = 0, min = 0, max = 0},
    bwOut =     {cur = 0, tally = {}, avg = 0, min = 0, max = 0},
    lagHome =   {cur = 0, tally = {}, avg = 0, min = 0, max = 0},
    lagWorld =  {cur = 0, tally = {}, avg = 0, min = 0, max = 0},
    fpsTally = -5,
    fps =       {cur = 0, tally = {}, avg = 0, min = 0, max = 0},
}

local SysSection = {}
local function PC_UpdateTablet()
    local Cols, lineHeader
    _G.wipe(SysSection)

    -- Network Category
    SysSection["network"] = {}
    SysSection["network"].cat = Tablets.pc:AddCategory()
    SysSection["network"].cat:AddLine("text", _G.NETWORK_LABEL, "size", db.text.tablets.headersize + ndb.media.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
    AddBlankTabLine(SysSection["network"].cat, 2)

    -- Lines
    Cols = {
        L["Sys_Stat"],
        L["Sys_CurrentAbbr"],
        L["Sys_Max"],
        L["Sys_Min"],
        L["Sys_AverageAbbr"],
    }
    SysSection["network"].lineCat = Tablets.pc:AddCategory("columns", #Cols)
    lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + ndb.media.font.sizeAdjust, 12, {"LEFT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"})
    SysSection["network"].lineCat:AddLine(lineHeader)
    AddBlankTabLine(SysSection["network"].lineCat, 1)

    local NetworkLines = {
        [1] = {L["Sys_In"], L["Sys_kbps"], "%.2f", SysStats.bwIn},
        [2] = {L["Sys_Out"], L["Sys_kbps"], "%.2f", SysStats.bwOut},
        [3] = {_G.HOME , L["Sys_ms"], "%d", SysStats.lagHome},
        [4] = {_G.CHANNEL_CATEGORY_WORLD, L["Sys_ms"], "%d", SysStats.lagWorld},
    }
    local line = {}
    for l = 1, #NetworkLines do
        _G.wipe(line)
        for i = 1, #Cols do
            if i == 1 then
                line["text"] = ("|cffe5e5e5%s|r |cff808080(%s)|r"):format(NetworkLines[l][1], NetworkLines[l][2])
                line["justify"] = "LEFT"
                line["size"] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                line["indentation"] = 12.5
                line["customwidth"] = 90
            elseif i == 2 then
                line["text"..i] = NetworkLines[l][3]:format(NetworkLines[l][4].cur)
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.9
                line["text"..i.."G"] = 0.9
                line["text"..i.."B"] = 0.9
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            elseif i == 3 then
                line["text"..i] = NetworkLines[l][3]:format(NetworkLines[l][4].max)
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.7
                line["text"..i.."G"] = 0.7
                line["text"..i.."B"] = 0.7
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            elseif i == 4 then
                line["text"..i] = NetworkLines[l][3]:format(NetworkLines[l][4].min)
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.7
                line["text"..i.."G"] = 0.7
                line["text"..i.."B"] = 0.7
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            elseif i == 5 then
                line["text"..i] = NetworkLines[l][3]:format(NetworkLines[l][4].avg)
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.7
                line["text"..i.."G"] = 0.7
                line["text"..i.."B"] = 0.7
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            end
        end
        SysSection["network"].lineCat:AddLine(line)
    end
    AddBlankTabLine(SysSection["network"].lineCat, 4)

    -- Computer Category
    SysSection["computer"] = {}
    SysSection["computer"].cat = Tablets.pc:AddCategory()
    SysSection["computer"].cat:AddLine("text", _G.SYSTEMOPTIONS_MENU, "size", db.text.tablets.headersize + ndb.media.font.sizeAdjust, "textR", 1, "textG", 1, "textB", 1)
    AddBlankTabLine(SysSection["computer"].cat, 2)

    SysSection["computer"].lineCat = Tablets.pc:AddCategory("columns", #Cols)
    lineHeader = MakeTabletHeader(Cols, db.text.tablets.columnsize + ndb.media.font.sizeAdjust, 12, {"LEFT", "RIGHT", "RIGHT", "RIGHT", "RIGHT"})
    SysSection["computer"].lineCat:AddLine(lineHeader)
    AddBlankTabLine(SysSection["computer"].lineCat, 1)

    local ComputerLines = {
        [1] = {L["Sys_FPS"], SysStats.fps},
    }
    for l = 1, #ComputerLines do
        _G.wipe(line)
        for i = 1, #Cols do
            if i == 1 then
                line["text"] = ("|cffe5e5e5%s|r"):format(ComputerLines[l][1])
                line["justify"] = "LEFT"
                line["size"] = db.text.tablets.normalsize + ndb.media.font.sizeAdjust
                line["indentation"] = 12.5
                line["customwidth"] = 90
            elseif i == 2 then
                line["text"..i] = ComputerLines[l][2].cur
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.9
                line["text"..i.."G"] = 0.9
                line["text"..i.."B"] = 0.9
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            elseif i == 3 then
                line["text"..i] = ComputerLines[l][2].max
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.7
                line["text"..i.."G"] = 0.7
                line["text"..i.."B"] = 0.7
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            elseif i == 4 then
                line["text"..i] = ComputerLines[l][2].min
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.7
                line["text"..i.."G"] = 0.7
                line["text"..i.."B"] = 0.7
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            elseif i == 5 then
                line["text"..i] = ComputerLines[l][2].avg
                line["justify"..i] = "RIGHT"
                line["text"..i.."R"] = 0.7
                line["text"..i.."G"] = 0.7
                line["text"..i.."B"] = 0.7
                line["indentation"..i] = 12.5
                line["customwidth"..i] = 30
            end
        end
        SysSection["computer"].lineCat:AddLine(line)
    end
    AddBlankTabLine(SysSection["computer"].lineCat, 8)  -- Space for graph
end

local function PC_OnLeave(self)
    if Tablets.pc:IsRegistered(self) then
        Tablets.pc:Close(self)
        HideGraph("fps")
    end
end

local function PC_OnEnter(self)
    -- Register Tablets.pc
    if not Tablets.pc:IsRegistered(self) then
        Tablets.pc:Register(self,
            "children", function()
                PC_UpdateTablet()
            end,
            "point", function()
                return "BOTTOMRIGHT"
            end,
            "relativePoint", function()
                return "TOPRIGHT"
            end,
            "maxHeight", db.other.tablets.maxheight,
            "clickable", true,
            "hideWhenEmpty", true
        )
    end

    if Tablets.pc:IsRegistered(self) then
        -- Tablets.pc appearance
        Tablets.pc:SetColor(self, RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3])
        Tablets.pc:SetTransparency(self, RealUI.media.window[4])
        Tablets.pc:SetFontSizePercent(self, 1)

        Tablets.pc:Open(self)

        ShowGraph("fps", _G.Tablet20Frame, "BOTTOMRIGHT", "BOTTOMRIGHT", -10, 10, self)
        HideOtherGraphs(self)
    end
end

local function PC_Update(self, short)
    if short then
        -- FPS
        SysStats.fps.cur = floor((_G.GetFramerate() or 0) + 0.5)

        -- Get last 60 second data
        if ( (SysStats.fps.cur > 0) and (SysStats.fps.cur < 120) ) then
            if SysStats.fpsTally < 0 then
                -- Skip first 5 seconds upon login
                SysStats.fpsTally = SysStats.fpsTally + 1
            else
                local fpsCount = 60
                if SysStats.fpsTally < fpsCount then
                    -- fpsCount up to our 60-sec of total tallying
                    SysStats.fpsTally = SysStats.fpsTally + 1
                    SysStats.fps.tally[SysStats.fpsTally] = SysStats.fps.cur
                    fpsCount = SysStats.fpsTally
                else
                    -- Shift our tally table down by 1
                    for i = 1, fpsCount - 1 do
                        SysStats.fps.tally[i] = SysStats.fps.tally[i + 1]
                    end
                    SysStats.fps.tally[fpsCount] = SysStats.fps.cur
                end

                -- Get Average/Min/Max fps
                local minfps, maxfps, totalfps = nil, 0, 0
                for i = 1, fpsCount do
                    totalfps = totalfps + SysStats.fps.tally[i]
                    if not minfps then minfps = SysStats.fps.tally[i] else minfps = min(minfps, SysStats.fps.tally[i]) end
                    maxfps = max(maxfps, SysStats.fps.tally[i])
                end
                SysStats.fps.avg = floor((totalfps / fpsCount) + 0.5)
                SysStats.fps.min = minfps
                SysStats.fps.max = maxfps
            end
        end

        -- Graph
        if Graphs["fps"].shown then
            UpdateGraph("fps", SysStats.fps.tally)
        end
    else
        -- Net
        SysStats.bwIn.cur, SysStats.bwOut.cur, SysStats.lagHome.cur, SysStats.lagWorld.cur = _G.GetNetStats()
        SysStats.bwIn.cur = floor(SysStats.bwIn.cur * 100 + 0.5 ) / 100
        SysStats.bwOut.cur = floor(SysStats.bwOut.cur * 100 + 0.5 ) / 100

        -- Get last 60 net updates
        local netCount = 60
        if SysStats.netTally < netCount then
            -- Tally up to 60
            SysStats.netTally = SysStats.netTally + 1

            SysStats.bwIn.tally[SysStats.netTally] = SysStats.bwIn.cur
            SysStats.bwOut.tally[SysStats.netTally] = SysStats.bwOut.cur
            SysStats.lagHome.tally[SysStats.netTally] = SysStats.lagHome.cur
            SysStats.lagWorld.tally[SysStats.netTally] = SysStats.lagWorld.cur

            netCount = SysStats.netTally
        else
            -- Shift our tally table down by 1
            for i = 1, netCount - 1 do
                SysStats.bwIn.tally[i] = SysStats.bwIn.tally[i + 1]
                SysStats.bwOut.tally[i] = SysStats.bwOut.tally[i + 1]
                SysStats.lagHome.tally[i] = SysStats.lagHome.tally[i + 1]
                SysStats.lagWorld.tally[i] = SysStats.lagWorld.tally[i + 1]
            end
            -- Store new values
            SysStats.bwIn.tally[netCount] = SysStats.bwIn.cur
            SysStats.bwOut.tally[netCount] = SysStats.bwOut.cur
            SysStats.lagHome.tally[netCount] = SysStats.lagHome.cur
            SysStats.lagWorld.tally[netCount] = SysStats.lagWorld.cur
        end

        -- Get Average/Min/Max
        local minBwIn, maxBwIn, totalBwIn = nil, 0, 0
        local minBwOut, maxBwOut, totalBwOut = nil, 0, 0
        local minLagHome, maxLagHome, totalLagHome = nil, 0, 0
        local minLagWorld, maxLagWorld, totalLagWorld = nil, 0, 0

        for i = 1, netCount do
            totalBwIn = totalBwIn + SysStats.bwIn.tally[i]
            if not minBwIn then minBwIn = SysStats.bwIn.tally[i] else minBwIn = min(minBwIn, SysStats.bwIn.tally[i]) end
            maxBwIn = max(maxBwIn, SysStats.bwIn.tally[i])

            totalBwOut = totalBwOut + SysStats.bwOut.tally[i]
            if not minBwOut then minBwOut = SysStats.bwOut.tally[i] else minBwOut = min(minBwOut, SysStats.bwOut.tally[i]) end
            maxBwOut = max(maxBwOut, SysStats.bwOut.tally[i])

            totalLagHome = totalLagHome + SysStats.lagHome.tally[i]
            if not minLagHome then minLagHome = SysStats.lagHome.tally[i] else minLagHome = min(minLagHome, SysStats.lagHome.tally[i]) end
            maxLagHome = max(maxLagHome, SysStats.lagHome.tally[i])

            totalLagWorld = totalLagWorld + SysStats.lagWorld.tally[i]
            if not minLagWorld then minLagWorld = SysStats.lagWorld.tally[i] else minLagWorld = min(minLagWorld, SysStats.lagWorld.tally[i]) end
            maxLagWorld = max(maxLagWorld, SysStats.lagWorld.tally[i])
        end

        SysStats.bwIn.avg = floor((totalBwIn / netCount) * 100 + 0.5) / 100
        SysStats.bwIn.min = minBwIn
        SysStats.bwIn.max = maxBwIn

        SysStats.bwOut.avg = floor((totalBwOut / netCount) * 100 + 0.5) / 100
        SysStats.bwOut.min = minBwOut
        SysStats.bwOut.max = maxBwOut

        SysStats.lagHome.avg = floor((totalLagHome / netCount) + 0.5)
        SysStats.lagHome.min = minLagHome
        SysStats.lagHome.max = maxLagHome

        SysStats.lagWorld.avg = floor((totalLagWorld / netCount) + 0.5)
        SysStats.lagWorld.min = minLagWorld
        SysStats.lagWorld.max = maxLagWorld
    end

    -- Info Text
    self.text1:SetFormattedText("|cff%s%d|r", TextColorNormal, floor(SysStats.fps.cur + 0.5))
    self.text2:SetFormattedText("|cff%s%d|r", TextColorNormal, SysStats.lagWorld.cur)
    UpdateElementWidth(self)

    -- Tablet
    if Tablets.pc:IsRegistered(self) then
        if _G.Tablet20Frame:IsShown() then
            Tablets.pc:Refresh(self)
        end
    end
end

---- Mail
local function Mail_Update(self)
    if _G.HasNewMail() then
        self.hasMail = true
        self.hidden = false
        UpdateElementWidth(self)
    else
        self.hasMail = false
        self.hidden = true
        UpdateElementWidth(self, true)
    end
end

---- Clock
local function Clock_Update(self, ...)
    -- Time
    local newTime
    if db.other.clock.uselocal then
        newTime = db.other.clock.hr24 and _G.date("%H:%M") or _G.date("%I:%M %p")
        if newTime:sub(1, 1) == "0" then
            newTime = newTime:sub(2)
        end
    else
        newTime = db.other.clock.hr24 and RetrieveGameTime() or RetrieveGameTime(true)
    end

    -- Info Text
    self.text:SetFormattedText("|cff%s%s|r", TextColorNormal, newTime)
    UpdateElementWidth(self)
end

local function Clock_OnEnter(self)
    local locTime = db.other.clock.hr24 and _G.date("%H:%M") or ("%d%s"):format(_G.date("%I:%M %p"):sub(1, 2), _G.date("%I:%M %p"):sub(3))

    local serTime = RetrieveGameTime(not db.other.clock.hr24)
    local caltext = _G.date("%b %d (%a)")

    local GameTooltip = _G.GameTooltip
    GameTooltip:SetOwner(self, "ANCHOR_TOP"..self.side, 0, 1)
    GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, _G.TIMEMANAGER_TOOLTIP_TITLE))
    GameTooltip:AddLine(" ")
    GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(TextColorBlue1, _G.TIMEMANAGER_TOOLTIP_REALMTIME), ("%s"):format(serTime), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
    GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(TextColorBlue1, _G.TIMEMANAGER_TOOLTIP_LOCALTIME), ("%s"):format(locTime), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
    GameTooltip:AddDoubleLine(("|cff%s%s:|r"):format(TextColorBlue1, L["Clock_Date"]), caltext, 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)

    -- TB/WG
    GameTooltip:AddLine(" ")
    local _, _, _, _, WGTime = _G.GetWorldPVPAreaInfo(1)
    local _, _, _, _, TBTime = _G.GetWorldPVPAreaInfo(2)
    if ( WGTime ~= nil ) then
        GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(TextColorBlue1, L["Clock_WGTime"]), ("%s"):format(ConvertSecondstoTime(WGTime)), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
    else
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorBlue1, L["Clock_NoWGTime"]))
    end
    if ( TBTime ~= nil ) then
        GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(TextColorBlue1, L["Clock_TBTime"]), ("%s"):format(ConvertSecondstoTime(TBTime)), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
    else
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorBlue1, L["Clock_NoTBTime"]))
    end

    -- Invites
    GameTooltip:AddLine(" ")
    if self.pendingCalendarInvites and self.pendingCalendarInvites > 0 then
        GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(TextColorBlue1, L["Clock_CalenderInvites"]), ("%s"):format(self.pendingCalendarInvites), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
        GameTooltip:AddLine(" ")
    end

    -- World Bosses
    local numSavedBosses = _G.GetNumSavedWorldBosses()
    if (_G.UnitLevel("player") >= 90) and (numSavedBosses > 0) then
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, _G.WORLD .. _G.LFG_LIST_BOSSES_DEFEATED))
        for i = 1, numSavedBosses do
            local bossName, _, bossReset = _G.GetSavedWorldBossInfo(i)
            GameTooltip:AddDoubleLine(("|cff%s%s|r"):format(TextColorBlue1, bossName), ("%s"):format(ConvertSecondstoTime(bossReset)), 0.9, 0.9, 0.9, 0.9, 0.9, 0.9)
        end
        GameTooltip:AddLine(" ")
    end

    -- Hint
    GameTooltip:AddLine(("|cff00ff00%s|r"):format(L["Clock_ShowCalendar"]))
    GameTooltip:AddLine(("|cff00ff00%s|r"):format(L["Clock_ShowTimer"]))
    GameTooltip:Show()
end

local function Clock_OnMouseDown(self)
    if _G.IsShiftKeyDown() then
        _G.ToggleTimeManager()
    else
        if _G.IsAddOnLoaded("GroupCalendar5") and _G.SlashCmdList.CAL then
            _G.SlashCmdList.CAL("show")
        else
            _G.ToggleCalendar()
        end
    end
end

---------------------
-- Mouse functions --
---------------------
function InfoLine:OnMouseDown(element, ...)
    self:debug("InfoLine:OnMouseDown", element.tag, ...)
    if element.tag == "start" then
        _G.EasyMenu(MicroMenu, ddMenuFrame, element, 0, 0, "MENU", 2)

    elseif element.tag == "guild" then
        Guild_OnMouseDown(element)

    elseif element.tag == "friends" then
        Friends_OnMouseDown(element)

    elseif element.tag == "durability" then
        InfoLine_Durability_OnMouseDown(element)

    elseif element.tag == "bag" then
        InfoLine_Bag_OnMouseDown(element)

    elseif element.tag == "currency" then
        Currency_OnMouseDown(element)

    elseif element.tag == "xprep" then
        InfoLine_XR_OnMouseDown(element)

    elseif element.tag == "clock" then
        Clock_OnMouseDown(element)

    elseif element.tag == "meters" then
        Meter_Toggle(element)

    elseif element.tag == "spec" then
        SpecChangeClickFunc(element)

    elseif element.tag == "layout" then
        local NewLayout = ndbc.layout.current == 1 and 2 or 1
        ndbc.layout.current = NewLayout
        ndbc.layout.spec[_G.GetSpecialization()] = NewLayout
        Layout_Update(element)
        RealUI:UpdateLayout()
        _G.GameTooltip:Hide()
        InfoLine:OnEnter(element)
    end
end

function InfoLine:OnLeave(element)
    element.mouseover = false
    HighlightBar:Hide()
    if _G.GameTooltip:IsShown() then _G.GameTooltip:Hide() end
    if element.tag == "start" then
        local color = RealUI.media.colors.blue
        element.icon1:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
        color = RealUI.media.colors.orange
        element.icon2:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
    elseif element.tag == "pc" then
        PC_OnLeave(element)
    end
end

function InfoLine:OnEnter(element)
    -- Highlight
    element.mouseover = true
    if element.tag ~= "start" then
        HighlightBar:Show()
        SetHighlightPosition(element)
    end

    if _G.InCombatLockdown() and not db.other.icTips then return end
    local GameTooltip = _G.GameTooltip

    if element.tag == "start" then
        GameTooltip:SetOwner(element, "ANCHOR_TOP"..element.side, 0, 1)
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, _G.MAINMENU_BUTTON))
        GameTooltip:Show()

        local color = RealUI.media.colors.blue
        element.icon1:SetVertexColor(color[1], color[2], color[3])
        color = RealUI.media.colors.orange
        element.icon2:SetVertexColor(color[1], color[2], color[3])
    elseif element.tag == "mail" and element.hasMail then
        _G.MinimapMailFrameUpdate()

        local send1, send2, send3 = _G.GetLatestThreeSenders()

        GameTooltip:SetOwner(element, "ANCHOR_TOP"..element.side, 0, 1)
        if (send1 or send2 or send3) then
            GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, _G.HAVE_MAIL_FROM))
        else
            GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, _G.HAVE_MAIL))
        end

        if send1 then GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorWhite, send1)) end
        if send2 then GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorWhite, send2)) end
        if send3 then GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorWhite, send3)) end

        GameTooltip:Show()

    elseif element.tag == "guild" then
        if element.hasguild then
            Guild_OnEnter(element)
        end

    elseif element.tag == "friends" then
        if element.hasfriends then
            Friends_OnEnter(element)
        end

    elseif element.tag == "durability" then
        InfoLine_Durability_OnEnter(element)

    elseif element.tag == "bag" then
        GameTooltip:SetOwner(element, "ANCHOR_TOP"..element.side, 0, 1)
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, _G.EMPTY .. " " .. _G.BAGSLOTTEXT))
        GameTooltip:Show()

    elseif element.tag == "currency" then
        Currency_OnEnter(element)

    elseif element.tag == "xprep" then
        InfoLine_XR_OnEnter(element)

    elseif element.tag == "clock" then
        Clock_OnEnter(element)

    elseif element.tag == "meters" then
        GameTooltip:SetOwner(element, "ANCHOR_TOP"..element.side, 0, 1)
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, L["Meters_Header"]))
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorBlue1, L["Meters_Active"]))
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorWhite, element.meterLoaded))
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(("|cff00ff00%s|r"):format(L["Meters_Toggle"]))
        GameTooltip:Show()

    elseif element.tag == "pc" then
        PC_OnEnter(element)

    elseif element.tag == "spec" then
        Spec_OnEnter(element)

    elseif element.tag == "layout" then
        local CurLayoutText = ndbc.layout.current == 1 and L["Layout_DPSTank"] or L["Layout_Healing"]
        GameTooltip:SetOwner(element, "ANCHOR_TOP"..element.side, 0, 1)
        GameTooltip:AddLine(("|cff%s%s|r"):format(TextColorTTHeader, L["Layout_LayoutChanger"]))
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(("|cff%s%s |r|cff%s%s|r"):format(TextColorBlue1, L["Layout_Current"], TextColorWhite, CurLayoutText))
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine(("|cff00ff00%s|r"):format(L["Layout_Change"]))
        GameTooltip:Show()
    end
end

-------------------
-- Frame Updates --
-------------------
-- Background
function InfoLine:SetBackground()
    if ndb.settings.infoLineBackground then
        ILFrames.parent:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])
        tinsert(_G.REALUI_WINDOW_FRAMES, ILFrames.parent)
        ILFrames.parent.backgroundTop:SetTexture(0, 0, 0, 1)
        if db.position.y > 0 then
            ILFrames.parent.backgroundBottom:SetTexture(0, 0, 0, 1)
        else
            ILFrames.parent.backgroundBottom:SetTexture(0, 0, 0, 0)
        end
        ILFrames.parent.stripeTex:Show()
    else
        ILFrames.parent:SetBackdropColor(0, 0, 0, 0)
        ILFrames.parent.backgroundTop:SetTexture(0, 0, 0, 0)
        ILFrames.parent.backgroundBottom:SetTexture(0, 0, 0, 0)
        ILFrames.parent.stripeTex:Hide()
    end
end

-- Font
function InfoLine:UpdateFonts()
    layoutSize = (ndb.settings.fontStyle == 3) and 2 or 1

    -- Set Icons
    for i,v in next, TextureFrames do
        local element, texture, icon = v[1], v[2], v[3]
        if element.type and (element.type ~= 2) then
            texture:SetTexture(Icons[layoutSize][icon][1])
            element.iconwidth = Icons[layoutSize][icon][2]
        end
    end

    -- Update Element widths
    for i,v in next, ILFrames do
        if ILFrames[i].type and (ILFrames[i].type ~= 1) then
            UpdateElementWidth(ILFrames[i])
        end
    end

    Layout_Update(ILFrames.layout)
    Currency_Update(ILFrames.currency)
end

-- Positions
local function SetPosition(info, parent, anchor, x, width, height)
    info:ClearAllPoints()
    info:SetPoint(anchor, parent, anchor, x, 0)
    info:SetWidth(width)
    info:SetHeight(height)
end

local AlreadyUpdating
function InfoLine:UpdatePositions()
    if AlreadyUpdating then return end
    AlreadyUpdating = true

    local Frames = {
        left = {
            {ILFrames.start,        db.elements.start},
            {ILFrames.mail,         db.elements.mail},
            {ILFrames.guild,        db.elements.guild},
            {ILFrames.friends,      db.elements.friends},
            {ILFrames.durability,   db.elements.durability},
            {ILFrames.bag,          db.elements.bag},
            {ILFrames.currency,     db.elements.currency},
            {ILFrames.xprep,        db.elements.xprep},
        },
        right = {
            {ILFrames.clock,        db.elements.clock},
            {ILFrames.meters,       db.elements.metertoggle},
            {ILFrames.layout,       db.elements.layoutchanger},
            {ILFrames.spec,         db.elements.specchanger},
            {ILFrames.pc,           db.elements.pc},
        },
    }

    local EHeight = db.position.yoff + ElementHeight[layoutSize] + db.position.yoff

    -- Parent
    ILFrames.parent:ClearAllPoints()
    ILFrames.parent:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT",  db.position.xleft, db.position.y)
    ILFrames.parent:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT",  db.position.xright, db.position.y)
    ILFrames.parent:SetHeight(EHeight)

    ---- Left
    local XPos = 0
    for k,v in ipairs(Frames.left) do
        if v[2] and not v[1].hidden then
            v[1]:Show()
            SetPosition(v[1], ILFrames.parent, "BOTTOMLEFT", XPos, v[1].curwidth, EHeight)
            XPos = XPos + v[1].curwidth
            if v[1].mouseover then
                HighlightBar:SetWidth(v[1].curwidth)
            end
        else
            v[1]:Hide()
        end
    end

    -- Right
    XPos = 0
    for k,v in ipairs(Frames.right) do
        if v[2] and not v[1].hidden then
            v[1]:Show()
            SetPosition(v[1], ILFrames.parent, "BOTTOMRIGHT", XPos, v[1].curwidth, EHeight)
            XPos = XPos - v[1].curwidth
            if v[1].mouseover then
                HighlightBar:SetWidth(v[1].curwidth)
            end
        else
            v[1]:Hide()
        end
    end

    AlreadyUpdating = false
end

--------------------
-- Frame Creation --
--------------------
local function CreateNewElement(name, side, type, iconInfo, ...)
    local extra = ...
    -- Types - 1 = Icon, 2 = Text, 3 = Icon + Text
    local NewElement = _G.CreateFrame("Frame", name, _G.UIParent)
    NewElement.side = side
    NewElement.type = type

    NewElement:SetFrameStrata(ILFrames.parent:GetFrameStrata())
    NewElement:SetFrameLevel(ILFrames.parent:GetFrameLevel() + 1)

    if type ~= 4 then
        if (type == 1) or (type == 3) then
            if extra == "start" then
                NewElement.icon1 = NewElement:CreateTexture(nil, "ARTWORK")
                NewElement.icon1:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff / 2)
                NewElement.icon1:SetHeight(16)
                NewElement.icon1:SetWidth(16)
                NewElement.icon1:SetTexture(Icons[layoutSize].start1[1])
                local color = RealUI.media.colors.blue
                NewElement.icon1:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])

                NewElement.icon2 = NewElement:CreateTexture(nil, "ARTWORK")
                NewElement.icon2:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff / 2)
                NewElement.icon2:SetHeight(16)
                NewElement.icon2:SetWidth(16)
                NewElement.icon2:SetTexture(Icons[layoutSize].start2[1])
                color = RealUI.media.colors.orange
                NewElement.icon2:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
            else
                NewElement.icon = NewElement:CreateTexture(nil, "ARTWORK")
                NewElement.icon:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff)
                NewElement.icon:SetHeight(16)
                NewElement.icon:SetWidth(extra or 16)
                NewElement.icon:SetTexture(iconInfo[1])
            end
            if type == 1 then
                NewElement.curwidth = (db.position.xgap * 2) + iconInfo[2]
            end
            NewElement.iconwidth = iconInfo[2]
        end

        if (type == 2) or (type == 3) then
            NewElement.text = NewElement:CreateFontString(nil, "ARTWORK")
            NewElement.text:SetFontObject(_G.RealUIFont_Pixel)
            NewElement.text:SetJustifyH("LEFT")
            if type == 2 then
                NewElement.text:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap, db.position.yoff + db.text.yoffset + 0.5)
            else
                NewElement.text:SetPoint("BOTTOMLEFT", NewElement, "BOTTOMLEFT", db.position.xgap + iconInfo[2] - 1, db.position.yoff + db.text.yoffset + 0.5)
            end
            NewElement.curwidth = 50
        end
    else
        NewElement.text1 = NewElement:CreateFontString(nil, "ARTWORK")
        NewElement.text1:SetFontObject(_G.RealUIFont_Pixel)
        NewElement.text1:SetJustifyH("LEFT")

        NewElement.icon = NewElement:CreateTexture(nil, "ARTWORK")
        NewElement.icon:SetHeight(16)
        NewElement.icon:SetWidth(16)
        NewElement.icon:SetTexture(iconInfo[1])
        NewElement.iconwidth = iconInfo[2]

        NewElement.text2 = NewElement:CreateFontString(nil, "ARTWORK")
        NewElement.text2:SetFontObject(_G.RealUIFont_Pixel)
        NewElement.text2:SetTextColor(TextColorNormalVals[1], TextColorNormalVals[2], TextColorNormalVals[3])
        NewElement.text2:SetJustifyH("LEFT")

        NewElement.curwidth = 100
    end

    NewElement:EnableMouse(true)
    NewElement.mouseover = false
    NewElement:SetScript("OnEnter", function(self) InfoLine:OnEnter(self) end)
    NewElement:SetScript("OnLeave", function(self) InfoLine:OnLeave(self) end)
    NewElement:SetScript("OnMouseDown", function(self) InfoLine:OnMouseDown(self) end)

    return NewElement
end

function InfoLine:CreateFrames()
    if FramesCreated then return end

    ILFrames = {}

    -- Parent
    ILFrames.parent = _G.CreateFrame("Frame", "RealUI_InfoLine", _G.UIParent)
    ILFrames.parent:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT", 0, 0)
    ILFrames.parent:SetFrameStrata("LOW")
    ILFrames.parent:SetFrameLevel(0)

    -- Background
    ILFrames.parent:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
        edgeFile = nil,
    })
    ILFrames.parent.stripeTex = RealUI:AddStripeTex(ILFrames.parent)
    ILFrames.parent.backgroundTop = ILFrames.parent:CreateTexture(nil, "ARTWORK")
        ILFrames.parent.backgroundTop:SetPoint("TOPLEFT", ILFrames.parent, "TOPLEFT")
        ILFrames.parent.backgroundTop:SetPoint("BOTTOMRIGHT", ILFrames.parent, "TOPRIGHT", 0, -1)
    ILFrames.parent.backgroundBottom = ILFrames.parent:CreateTexture(nil, "ARTWORK")
        ILFrames.parent.backgroundBottom:SetPoint("BOTTOMLEFT", ILFrames.parent, "BOTTOMLEFT")
        ILFrames.parent.backgroundBottom:SetPoint("TOPRIGHT", ILFrames.parent, "BOTTOMRIGHT", 0, 1)
    self:SetBackground()

    -- Highlight Bar
    HighlightBar = _G.CreateFrame("Frame", nil, _G.UIParent)
    HighlightBar:Hide()
    HighlightBar:SetHeight(3)
    HighlightBar:SetFrameStrata("LOW")
    HighlightBar:SetFrameLevel(0)
    HighlightBar.bg = HighlightBar:CreateTexture(nil, "BORDER")
    HighlightBar.bg:SetAllPoints(HighlightBar)
    HighlightBar.bg:SetTexture(0, 0, 0, 1)
    HighlightBar.line = HighlightBar:CreateTexture(nil, "ARTWORK")
    HighlightBar.line:SetPoint("BOTTOMLEFT", HighlightBar, "BOTTOMLEFT", 1, 1)
    HighlightBar.line:SetPoint("TOPRIGHT", HighlightBar, "TOPRIGHT", -1, -1)
    HighlightBar.line:SetTexture(HighlightColorVals[1], HighlightColorVals[2], HighlightColorVals[3], HighlightColorVals[4])

    -------- LEFT
    -- -- Start Button
    ILFrames.start = CreateNewElement("RealUIInfoLineStart", "LEFT", 1, Icons[layoutSize].start1, "start")
    tinsert(TextureFrames, {ILFrames.start, ILFrames.start.icon1, "start1"})
    tinsert(TextureFrames, {ILFrames.start, ILFrames.start.icon2, "start2"})
    ILFrames.start.tag = "start"

    -- -- Mail
    ILFrames.mail = CreateNewElement(nil, "LEFT", 1, Icons[layoutSize].mail)
    tinsert(TextureFrames, {ILFrames.mail, ILFrames.mail.icon, "mail"})
    ILFrames.mail.tag = "mail"
    ILFrames.mail.hasMail = false
    ILFrames.mail:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.mail:RegisterEvent("UPDATE_PENDING_MAIL")
    ILFrames.mail:RegisterEvent("MAIL_CLOSED")
    ILFrames.mail:RegisterEvent("MAIL_SHOW")
    ILFrames.mail:RegisterEvent("MAIL_INBOX_UPDATE")
    ILFrames.mail:SetScript("OnEvent", function(element, event)
        if not db.elements.mail then return end
        if event == "PLAYER_ENTERING_WORLD" then
            element.needrefreshed = true
        end
        Mail_Update(element)
    end)
    ILFrames.mail.elapsed = 0
    ILFrames.mail:SetScript("OnUpdate", function(element, elapsed)
        if element.needrefreshed then
            element.elapsed = element.elapsed + elapsed
            if element.elapsed >= 5 then
                element.needrefreshed = false
                element.elapsed = 0
                Mail_Update(element)
            end
        end
    end)

    -- -- Guild
    ILFrames.guild = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].guild)
    tinsert(TextureFrames, {ILFrames.guild, ILFrames.guild.icon, "guild"})
    ILFrames.guild.tag = "guild"
    ILFrames.guild:RegisterEvent("GUILD_ROSTER_UPDATE")
    ILFrames.guild:RegisterEvent("GUILD_PERK_UPDATE")
    ILFrames.guild:RegisterEvent("GUILD_MOTD")
    ILFrames.guild:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.guild:SetScript("OnEvent", function(element, event)
        if not db.elements.guild then return end
        if event == "GUILD_MOTD" then
            if not element.hidden then return end
            element.needrefreshed = true
            element.elapsed = -2
        else
            element.needrefreshed = true
            element.elapsed = 0
        end
    end)
    ILFrames.guild.elapsed = 2
    ILFrames.guild:SetScript("OnUpdate", function(element, elapsed)
        element.elapsed = element.elapsed + elapsed
        if element.elapsed >= 2 then
            if element.needrefreshed then
                Guild_Update(element)
                element.needrefreshed = false
            end
            element.elapsed = 0
        end
    end)

    -- -- Friends
    ILFrames.friends = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].friends)
    tinsert(TextureFrames, {ILFrames.friends, ILFrames.friends.icon, "friends"})
    ILFrames.friends.tag = "friends"
    ILFrames.friends:RegisterEvent("FRIENDLIST_UPDATE")
    ILFrames.friends:RegisterEvent("BN_FRIEND_INVITE_ADDED")
    ILFrames.friends:RegisterEvent("BN_FRIEND_INVITE_LIST_INITIALIZED")
    ILFrames.friends:RegisterEvent("BN_FRIEND_INVITE_REMOVED")
    ILFrames.friends:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
    ILFrames.friends:RegisterEvent("BN_FRIEND_ACCOUNT_OFFLINE")
    ILFrames.friends:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.friends:SetScript("OnEvent", function(element, event, ...)
        if (_G.BNGetNumFriendInvites() > 0) or event == "BN_FRIEND_INVITE_REMOVED" then
            Friends_BNetRequest(element, event, ...)
        end
        if not db.elements.friends then return end
        element.needrefreshed = true
        element.elapsed = 0
    end)
    ILFrames.friends.elapsed = 2
    ILFrames.friends:SetScript("OnUpdate", function(element, elapsed)
        element.elapsed = element.elapsed + elapsed
        if element.elapsed >= 2 then
            if element.needrefreshed then
                Friends_Update(element)
                element.needrefreshed = false
            end
            element.elapsed = 0
        end
    end)

    -- -- Durability
    ILFrames.durability = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].durability)
    tinsert(TextureFrames, {ILFrames.durability, ILFrames.durability.icon, "durability"})
    ILFrames.durability.tag = "durability"
    ILFrames.durability:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
    ILFrames.durability:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.durability:SetScript("OnEvent", function(element)
        if not db.elements.durability then return end
        local dura = InfoLine_Durability_Update(element)
        if (dura < 15) then
            Durability_Low(element, dura)
        else
            Durability_Low(element, false)
        end
    end)

    -- -- Bag Space
    ILFrames.bag = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].bag)
    tinsert(TextureFrames, {ILFrames.bag, ILFrames.bag.icon, "bag"})
    ILFrames.bag.tag = "bag"
    ILFrames.bag:RegisterEvent("InfoLine_Bag_Update")
    ILFrames.bag:RegisterEvent("UNIT_INVENTORY_CHANGED")
    ILFrames.bag:RegisterEvent("BAG_UPDATE")
    ILFrames.bag:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.bag:SetScript("OnEvent", function(element)
        if not db.elements.bag then return end
        InfoLine_Bag_Update(element)
    end)

    -- -- Currency
    ILFrames.currency = CreateNewElement(nil, "LEFT", 2, nil)
    ILFrames.currency.icon = ILFrames.currency:CreateTexture(nil, "ARTWORK")
        ILFrames.currency.icon:SetSize(16, 16)
        ILFrames.currency.icon:SetTexture(Icons[layoutSize].currency[1])
    ILFrames.currency.tag = "currency"
    -- Currency events
    ILFrames.currency:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.currency:RegisterEvent("SEND_MAIL_MONEY_CHANGED")
    ILFrames.currency:RegisterEvent("SEND_MAIL_COD_CHANGED")
    ILFrames.currency:RegisterEvent("PLAYER_TRADE_MONEY")
    ILFrames.currency:RegisterEvent("TRADE_MONEY_CHANGED")
    ILFrames.currency:RegisterEvent("PLAYER_MONEY")
    ILFrames.currency:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    ILFrames.currency:RegisterEvent("UPDATE_PENDING_MAIL")
    -- To know when to start tracking Currency changes
    local MoneyPossibilityEvents = {
        ["AUCTION_HOUSE_SHOW"] = true,
        ["MAIL_SHOW"] = true,
        ["TRADE_SHOW"] = true,
        ["TRAINER_SHOW"] = true,
        ["MERCHANT_SHOW"] = true,
        ["GUILDBANKFRAME_OPENED"] = true,
        ["FORGE_MASTER_OPENED"] = true,
        ["VOID_STORAGE_OPEN"] = true,
        ["TRANSMOGRIFY_OPEN"] = true,
        ["TAXIMAP_OPENED"] = true,
        ["GOSSIP_SHOW"] = true,
        ["QUEST_COMPLETE"] = true,
    }
    for k, v in next, MoneyPossibilityEvents do
        if v then
            ILFrames.currency:RegisterEvent(k)
        end
    end
    -- Events to know when to update Currencies
    ILFrames.currency:SetScript("OnEvent", function(element, event)
        if not db.elements.currency then return end
        if event == "UPDATE_PENDING_MAIL" then
            element.ingame = true
            element:UnregisterEvent("UPDATE_PENDING_MAIL")
        elseif MoneyPossibilityEvents[event] then
            if element.ingame then
                element.initialized = true
            end
            if MoneyPossibilityEvents[event] then
                for k, v in next, MoneyPossibilityEvents do
                    if v then
                        ILFrames.currency:UnregisterEvent(k)
                    end
                end
            end
        end
        element.needrefreshed = true
        element.elapsed = 0
    end)
    -- Update on interval, avoids too many updates due to lots of events
    ILFrames.currency.elapsed = 1
    ILFrames.currency:SetScript("OnUpdate", function(element, elapsed)
        element.elapsed = element.elapsed + elapsed
        if element.elapsed >= 1 then
            if element.needrefreshed then
                Currency_Update(element)
                element.needrefreshed = false
            end
            element.elapsed = 0
        end
    end)

    -- -- XP/Rep
    ILFrames.xprep = CreateNewElement(nil, "LEFT", 3, Icons[layoutSize].xp)
    tinsert(TextureFrames, {ILFrames.xprep, ILFrames.xprep.icon, "xp"})
    ILFrames.xprep.tag = "xprep"
    ILFrames.xprep:RegisterEvent("PLAYER_XP_UPDATE")
    ILFrames.xprep:RegisterEvent("HONOR_XP_UPDATE")
    ILFrames.xprep:RegisterEvent("UPDATE_FACTION")
    ILFrames.xprep:RegisterEvent("DISABLE_XP_GAIN")
    ILFrames.xprep:RegisterEvent("ENABLE_XP_GAIN")
    ILFrames.xprep:RegisterEvent("PLAYER_ENTERING_WORLD")
    local function XR_OnEvent(element, ...)
        InfoLine:debug("XR_OnEvent", ...)
        if not db.elements.xprep then return end
        InfoLine_XR_Update(element, ...)
    end
    artData:RegisterCallback("ARTIFACT_ADDED", XR_OnEvent, ILFrames.xprep)
    artData:RegisterCallback("ARTIFACT_POWER_CHANGED", XR_OnEvent, ILFrames.xprep)
    artData:RegisterCallback("ARTIFACT_ACTIVE_CHANGED", XR_OnEvent, ILFrames.xprep)
    ILFrames.xprep:SetScript("OnEvent", XR_OnEvent)


    ------- RIGHT
    -- -- Clock
    ILFrames.clock = CreateNewElement(nil, "RIGHT", 2, nil)
    ILFrames.clock.tag = "clock"
    ILFrames.clock.text:SetJustifyH("RIGHT")
    ILFrames.clock:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.clock:SetScript("OnEvent", function(element)
        if not db.elements.clock then return end
        Clock_Update(element, true)
    end)
    ILFrames.clock.elapsed = 1
    ILFrames.clock:SetScript("OnUpdate", function(element, elapsed)
        if not db.elements.clock then return end
        element.elapsed = element.elapsed + elapsed
        if element.elapsed >= 1 then
            Clock_Update(element)
            element.elapsed = 0
        end
    end)

    -- -- Meters Button
    ILFrames.meters = CreateNewElement(nil, "RIGHT", 1, Icons[layoutSize].meters)
    tinsert(TextureFrames, {ILFrames.meters, ILFrames.meters.icon, "meters"})
    ILFrames.meters.tag = "meters"
    ILFrames.meters:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.meters:SetScript("OnEvent", function(element)
        if not db.elements.metertoggle then return end
        Meter_Update(element)
    end)
    ILFrames.meters.elapsed = 2
    ILFrames.meters:SetScript("OnUpdate", function(element, elapsed)
        if not db.elements.metertoggle then return end
        element.elapsed = element.elapsed + elapsed
        if element.elapsed >= 2 then
            Meter_Update(element)
            element.elapsed = 0
        end
    end)

    -- -- Spec Button
    ILFrames.spec = CreateNewElement("RealUIInfoLineSpecChanger", "RIGHT", 2, nil)
    ILFrames.spec.tag = "spec"
    ILFrames.spec:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.spec:RegisterEvent("UPDATE_PENDING_MAIL")
    ILFrames.spec:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    ILFrames.spec:RegisterEvent("EQUIPMENT_SETS_CHANGED")
    ILFrames.spec:RegisterEvent("EQUIPMENT_SWAP_FINISHED")
    ILFrames.spec:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    ILFrames.spec:SetScript("OnEvent", function(element, event)
        InfoLine:debug("Spec OnEvent:", event)
        if not db.elements.specchanger then return end
        if event == "UPDATE_PENDING_MAIL" then
            ILFrames.spec:UnregisterEvent("UPDATE_PENDING_MAIL")
        elseif event == "PLAYER_EQUIPMENT_CHANGED" then
            if not setEquipped then
                Spec_Update(element)
            end
        elseif event == "EQUIPMENT_SWAP_FINISHED" then
            InfoLine:debug("Spec EQUIPMENT_SWAPED", setEquipped)
            setEquipped = false
            Spec_Update(element)
        elseif event == "ACTIVE_TALENT_GROUP_CHANGED" then
            NeedSpecUpdate = true
            Spec_Update(element)
        else
            Spec_Update(element)
        end
    end)

    -- -- Layout Button
    ILFrames.layout = CreateNewElement(nil, "RIGHT", 1, Icons[layoutSize].layout_dt, 32)
    ILFrames.layout.tag = "layout"
    ILFrames.layout:RegisterEvent("PLAYER_ENTERING_WORLD")
    ILFrames.layout:SetScript("OnEvent", function(element)
        if not db.elements.layoutchanger then return end
        Layout_Update(element)
    end)

    -- -- PC
    ILFrames.pc = CreateNewElement(nil, "RIGHT", 4, Icons[layoutSize].system)
    tinsert(TextureFrames, {ILFrames.pc, ILFrames.pc.icon, "system"})
    ILFrames.pc.tag = "pc"
    CreateGraph("fps", 60, 60, ILFrames.pc)
    ILFrames.pc:RegisterEvent("UPDATE_PENDING_MAIL")
    ILFrames.pc:SetScript("OnEvent", function(element)
        if not db.elements.pc then return end
        ILFrames.pc.ready = true
        Graphs["fps"].enabled = true
        ILFrames.pc:UnregisterEvent("UPDATE_PENDING_MAIL")
    end)
    ILFrames.pc.elapsed1PowerModeTimes = {1, 2, 1}  -- Update FPS more or less frequently based on Power Mode setting {Normal, Economy, Turbo}
    ILFrames.pc.elapsed1 = 1
    ILFrames.pc.elapsed2 = 5
    ILFrames.pc:SetScript("OnUpdate", function(element, elapsed)
        if not db.elements.pc then return end
        if ILFrames.pc.ready then
            element.elapsed1 = element.elapsed1 + elapsed
            element.elapsed2 = element.elapsed2 + elapsed
            if element.elapsed1 >= element.elapsed1PowerModeTimes[ndb.settings.powerMode] then
                -- FPS update
                PC_Update(element, true)
                element.elapsed1 = 0
            end
            if element.elapsed2 >= 5 then
                PC_Update(element, false)
                element.elapsed2 = 0
            end
        end
    end)

    FramesCreated = true
end

------------------
-- Core Updates --
------------------
function InfoLine:UpdateAllInfo()
    Guild_Update(ILFrames.guild)
    Friends_Update(ILFrames.friends)
    InfoLine_Durability_Update(ILFrames.durability)
    InfoLine_Bag_Update(ILFrames.bag)
    Currency_Update(ILFrames.currency)
    InfoLine_XR_Update(ILFrames.xprep)
    Clock_Update(ILFrames.clock, true)
    PC_Update(ILFrames.pc, true)
    Spec_Update(ILFrames.spec)
    Layout_Update(ILFrames.layout)
    Meter_Update(ILFrames.meters)
end

function InfoLine:Refresh()
    -- Get Colors
    TextColorNormal = RealUI:ColorTableToStr(db.colors.normal)
    TextColorNormalVals = db.colors.normal
    if db.colors.classcolorhighlight then
        HighlightColorVals = {RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3]}
    else
        HighlightColorVals = db.colors.highlight
    end
    TextColorWhite = RealUI:ColorTableToStr({1, 1, 1})
    TextColorTTHeader = RealUI:ColorTableToStr(db.colors.ttheader)
    TextColorBlue1 = RealUI:ColorTableToStr(RealUI.media.colors.blue)

    -- Create Frames if it has been delayed
    if not FramesCreated then
        InfoLine:CreateFrames()
    end

    -- Update
    InfoLine:UpdateFonts()
    InfoLine:UpdatePositions()

    local color = RealUI.media.colors.blue
    ILFrames.start.icon1:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])
    color = RealUI.media.colors.orange
    ILFrames.start.icon2:SetVertexColor(color[1] * 0.8, color[2] * 0.8, color[3] * 0.8, color[4])

    -- InfoLine:UpdateAllInfo()
end

function InfoLine:UpdateGlobalColors()
    self:Refresh()
end

local function ClassColorsUpdate()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    InfoLine:Refresh()
end

function InfoLine:PLAYER_LOGIN()
    LoggedIn = true

    -- Class Name lookup table
    ClassLookup = {}
    for k, v in next, _G.LOCALIZED_CLASS_NAMES_MALE do
        ClassLookup[v] = k
    end
    for k, v in next, _G.LOCALIZED_CLASS_NAMES_FEMALE do
        ClassLookup[v] = k
    end

    -- Class Colors
    if _G.CUSTOM_CLASS_COLORS then
        _G.CUSTOM_CLASS_COLORS:RegisterCallback(ClassColorsUpdate)
    end

    -- Currency Names
    GoldName = _G.strtrim((RealUI.goldstr or _G.GOLD_AMOUNT):format(0):sub(2))

    -- Loot Spec
    LootSpecIDs = RealUI:GetLootSpecData(LootSpecIDs)

    -- Start title
    MicroMenu[1].text = RealUI:GetVerString(true)

    InfoLine:Refresh()
end

function InfoLine:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    db = self.db.profile
    ndbc = RealUI.db.char

    InfoLine:Refresh()
end

--------------------
-- Initialization --
--------------------
function InfoLine:OnInitialize()
    local specgear = {}
    for specIndex = 1, _G.GetNumSpecializationsForClassID(RealUI.classID) do
        specgear[specIndex] = -1
    end
    local otherFaction = RealUI:OtherFaction(RealUI.faction)
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        char = {
            xrstate = 1,
            currencystate = 1,
            specgear = specgear,
        },
        global = {
            currency = {
                [RealUI.realm] = {
                    [RealUI.faction] = {
                        [RealUI.name] = {
                            class = "",
                            level = 0,
                            gold = -1,
                            bpCurrencies = {
                                [1] = {amnt = -1, name = nil},
                                [2] = {amnt = -1, name = nil},
                                [3] = {amnt = -1, name = nil},
                            },
                            updated = "",
                        },
                    },
                    [otherFaction] = {},
                },
            },
        },
        profile = {
            position = {
                xleft = 0,
                xright = 0,
                y = 0,
                xgap = 8,
                yoff = 6,
            },
            text = {
                yoffset = 0,
                tablets = {
                    headersize = 13,
                    columnsize = 10,
                    normalsize = 11,
                    hintsize = 11,
                },
            },
            colors = {
                normal = {1, 1, 1},
                highlight = {1, 1, 1},
                classcolorhighlight = true,
                disabled = {0.5, 0.5, 0.5},
                ttheader = {1, 1, 1},
                hint = {0, 0.6, 1},
            },
            other = {
                icTips = false,
                clock = {
                    hr24 = false,
                    uselocal = true,
                    wgalert = false,
                    tbalert = true,
                },
                tablets = {
                    maxheight = 500,
                },
            },
            elements = {
                start = true,
                mail = true,
                guild = true,
                friends = true,
                durability = true,
                bag = true,
                currency = true,
                xprep = true,
                clock = true,
                pc = true,
                specchanger = true,
                layoutchanger = true,
                metertoggle = true,
            },
        },
    })
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char

    if _G.type(dbc.xrstate) ~= "number" then
        dbc.xrstate = nil
    end
    if dbc.specgear.primary then
        dbc.specgear = nil
    end

    RealUI.InfoLineICTips = db.other.icTips       -- Tablet-2.0 use

    local hasLDBDisplay = false
    do
        local ldbDisplays = {
            "Bazooka",
            "ChocolateBar",
            "DockingStation",
            "Titan",
        }
        for i, display in next, ldbDisplays do
            local _, _, _, loadable = _G.GetAddOnInfo(display)
            if loadable then
                hasLDBDisplay = true
                break
            end
        end
    end

    self:SetEnabledState(not hasLDBDisplay)
    if not RealUI:GetModuleEnabled(MODNAME) then
        RealUI:SetModuleEnabled(MODNAME, true)
    end
end

function InfoLine:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")

    CreateCopyFrame()

    if LoggedIn then
        InfoLine:Refresh()
    end
end
