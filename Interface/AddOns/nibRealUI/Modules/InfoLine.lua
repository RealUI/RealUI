local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")

local MODNAME = "InfoLine"
local InfoLine = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
local db, dbc, dbg, ndb, ndbc, ndbg

local lsm = LibStub("LibSharedMedia-3.0")
local ldb = LibStub("LibDataBroker-1.1")
local qTip = LibStub("LibQTip-1.0")
local lif = LibStub("LibIconFonts-1.0")
lif:RegisterPath([[Interface\AddOns\nibRealUI\Libs]])
local octicons = lif:octicons()

local _
local min = math.min
local max = math.max
local floor = math.floor
local round = nibRealUI.Round
local abs = math.abs
local tonumber = tonumber
local tostring = tostring
local strform = string.format
local gsub = gsub
local strsub = strsub

local layoutSize
local textColor = {}

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

local CurrencyColors = {
    GOLD = {1, 0.95, 0.15},
    SILVER = {0.75, 0.75, 0.75},
    COPPER = {0.75, 0.45, 0.31}
}

local ClassLookup

local REMOTE_CHAT_ICON = "|TInterface\\ChatFrame\\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:74:176:74|t"
local PlayerStatusValToStr = {
    [1] = CHAT_FLAG_AFK,
    [2] = CHAT_FLAG_DND,
}

local blocks = {
    left = {},
    right = {},
}

local BPCurr1Name, BPCurr2Name, BPCurr3Name, GoldName

----------------
-- Micro Menu --
----------------
local function updateColors()
    textColor.normal = db.colors.normal
    if db.colors.classcolorhighlight then
        textColor.highlight = nibRealUI.classColor
    else
        textColor.highlight = db.colors.highlight
    end
    textColor.disabled = db.colors.disabled
    textColor.white = {1, 1, 1}
    textColor.header = db.colors.ttheader
    textColor.orange = nibRealUI.media.colors.orange
    textColor.blue = nibRealUI.media.colors.blue
end

-------------
-- Options --
-------------
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Info Line",
        desc = "Information / Button display.",
        arg = MODNAME,
        childGroups = "tab",
        args = {
            header = {
                type = "header",
                name = "Info Line",
                order = 10,
            },
            desc = {
                name = "Information / Button display.",
                type = "description",
                order = 20,
                fontSize = "medium",
            },
            enabled = {
                name = "Enabled",
                type = "toggle",
                desc = "Enable/Disable the Info Line module.",
                order = 30,
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value) 
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                    nibRealUI:ReloadUIDialog()
                end,
            },
            blocks = {
                name = "Blocks",
                type = "group",
                order = 50,
                disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
                args = {
                    general = {
                        name = "General",
                        type = "group",
                        order = 10,
                        disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
                        args = {
                            position = {
                                name = "Text",
                                type = "group",
                                inline = true,
                                order = 10,
                                disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
                                args = {
                                    gap = {
                                        type = "input",
                                        name = "Block Gap",
                                        desc = "The ammount of space between each block.",
                                        width = "half",
                                        get = function(info) return tostring(db.text.gap) end,
                                        set = function(info, value)
                                            value = nibRealUI:ValidateOffset(value)
                                            db.text.gap = value
                                            InfoLine:UpdatePositions()
                                        end,
                                        order = 10,
                                    },
                                    padding = {
                                        type = "input",
                                        name = "Padding",
                                        desc = "Additional space between the icon and the text",
                                        width = "half",
                                        get = function(info) return tostring(db.text.padding) end,
                                        set = function(info, value)
                                            value = nibRealUI:ValidateOffset(value)
                                            db.text.padding = value
                                            InfoLine:UpdatePositions()
                                        end,
                                        order = 10,
                                    },
                                    tablets = {
                                        name = "Font Sizes",
                                        type = "group",
                                        inline = true,
                                        order = 20,
                                        args = {
                                            header = {
                                                type = "input",
                                                name = "Header",
                                                width = "half",
                                                get = function(info) return tostring(db.text.headersize) end,
                                                set = function(info, value)
                                                    value = nibRealUI:ValidateOffset(value)
                                                    db.text.headersize = value
                                                end,
                                                order = 10,
                                            },
                                            column = {
                                                type = "input",
                                                name = "Column Titles",
                                                width = "half",
                                                get = function(info) return tostring(db.text.columnsize) end,
                                                set = function(info, value)
                                                    value = nibRealUI:ValidateOffset(value)
                                                    db.text.columnsize = value
                                                end,
                                                order = 20,
                                            },
                                            normal = {
                                                type = "input",
                                                name = "Normal",
                                                width = "half",
                                                get = function(info) return tostring(db.text.normalsize) end,
                                                set = function(info, value)
                                                    value = nibRealUI:ValidateOffset(value)
                                                    db.text.normalsize = value
                                                end,
                                                order = 30,
                                            },
                                            hint = {
                                                type = "input",
                                                name = "Hint",
                                                width = "half",
                                                get = function(info) return tostring(db.text.hintsize) end,
                                                set = function(info, value)
                                                    value = nibRealUI:ValidateOffset(value)
                                                    db.text.hintsize = value
                                                end,
                                                order = 40,
                                            },
                                        },
                                    },
                                },
                            },
                            tooltips = {
                                name = "Tooltips",
                                type = "group",
                                inline = true,
                                order = 20,
                                disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
                                args = {
                                    inCombat = {
                                        type = "toggle",
                                        name = "In Combat Tooltips",
                                        desc = "Show tooltips in combat.",
                                        get = function() return db.other.icTips end,
                                        set = function(info, value) 
                                            db.other.icTips = value
                                        end,
                                        order = 10,
                                    },
                                    maxHeight = {
                                        type = "input",
                                        name = "Max Height",
                                        desc = "Maximum height of the Info Displays.",
                                        width = "half",
                                        get = function(info) return tostring(db.other.maxheight) end,
                                        set = function(info, value)
                                            value = nibRealUI:ValidateOffset(value)
                                            db.other.maxheight = value
                                        end,
                                        order = 10,
                                    },
                                },
                            },
                            colors = {
                                name = "Colors",
                                type = "group",
                                inline = true,
                                order = 30,
                                disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
                                args = {
                                    normal = {
                                        name = "Normal text",
                                        type = "color",
                                        order = 10,
                                        hasAlpha = false,
                                        get = function(info, r, g, b)
                                            return db.colors.normal[1], db.colors.normal[2], db.colors.normal[3]
                                        end,
                                        set = function(info, r, g, b)
                                            db.colors.normal[1] = r
                                            db.colors.normal[2] = g
                                            db.colors.normal[3] = b
                                            updateColors()
                                        end,
                                    },
                                    disabled = {
                                        name = "Disabled text",
                                        type = "color",
                                        order = 20,
                                        hasAlpha = false,
                                        get = function(info, r, g, b)
                                            return db.colors.disabled[1], db.colors.disabled[2], db.colors.disabled[3]
                                        end,
                                        set = function(info, r, g, b)
                                            db.colors.disabled[1] = r
                                            db.colors.disabled[2] = g
                                            db.colors.disabled[3] = b
                                            updateColors()
                                        end,
                                    },
                                    classcolorhighlight = {
                                        name = "Class Color Highlight",
                                        desc = "Use your Class Color for the highlight.",
                                        type = "toggle",
                                        order = 30,
                                        get = function() return db.colors.classcolorhighlight end,
                                        set = function(info, value) 
                                            db.colors.classcolorhighlight = value
                                            updateColors()
                                        end,
                                    },
                                    highlight = {
                                        name = "Frame Highlight",
                                        type = "color",
                                        order = 40,
                                        disabled = function() return db.colors.classcolorhighlight end,
                                        hasAlpha = false,
                                        get = function(info, r, g, b)
                                            return db.colors.highlight[1], db.colors.highlight[2], db.colors.highlight[3]
                                        end,
                                        set = function(info, r, g, b)
                                            db.colors.highlight[1] = r
                                            db.colors.highlight[2] = g
                                            db.colors.highlight[3] = b
                                            updateColors()
                                        end,
                                    },
                                    ttheader = {
                                        name = "Tooltip Header 1",
                                        type = "color",
                                        order = 50,
                                        hasAlpha = false,
                                        get = function(info, r, g, b)
                                            return db.colors.ttheader[1], db.colors.ttheader[2], db.colors.ttheader[3]
                                        end,
                                        set = function(info, r, g, b)
                                            db.colors.ttheader[1] = r
                                            db.colors.ttheader[2] = g
                                            db.colors.ttheader[3] = b
                                            updateColors()
                                        end,
                                    },
                                    orange1 = {
                                        name = "Header 1",
                                        type = "color",
                                        order = 60,
                                        hasAlpha = false,
                                        get = function(info, r, g, b)
                                            return nibRealUI.media.colors.orange[1], nibRealUI.media.colors.orange[2], nibRealUI.media.colors.orange[3]
                                        end,
                                        set = function(info, r, g, b)
                                            nibRealUI.media.colors.orange[1] = r
                                            nibRealUI.media.colors.orange[2] = g
                                            nibRealUI.media.colors.orange[3] = b
                                            updateColors()
                                        end,
                                    },
                                    blue1 = {
                                        name = "Header 2",
                                        type = "color",
                                        order = 70,
                                        hasAlpha = false,
                                        get = function(info, r, g, b)
                                            return nibRealUI.media.colors.blue[1], nibRealUI.media.colors.blue[2], nibRealUI.media.colors.blue[3]
                                        end,
                                        set = function(info, r, g, b)
                                            nibRealUI.media.colors.blue[1] = r
                                            nibRealUI.media.colors.blue[2] = g
                                            nibRealUI.media.colors.blue[3] = b
                                            updateColors()
                                        end,
                                    },
                                },
                            },
                        },
                    },
                },
            },
        },
    }
    end
    
    local blocksOrder = 10
    local realui = {
        name = "RealUI",
        type = "group",
        order = 20,
        disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
        args = {},
    }
    for name, info in next, db.blocks.realui do
        -- Create base options for RealUI
        realui.args[name] = {
            type = "toggle",
            name = name,
            desc = "Enable the " .. name .. " block.",
            get = function() return info.enabled end,
            set = function(data, value) 
                info.enabled = value
                InfoLine:IterateObjects("toggle")
            end,
            order = blocksOrder,
        }
        blocksOrder = blocksOrder + 10
    end
    options.args.blocks.args.realui = realui

    blocksOrder = 10
    local others = {
        name = "Others",
        type = "group",
        order = 30,
        disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
        args = {},
    }
    for name, info in next, db.blocks.others do
        -- Create base options for others
        others.args[name] = {
            type = "toggle",
            name = name,
            desc = "Enable " .. name,
            get = function() return info.enabled end,
            set = function(data, value) 
                info.enabled = value
                InfoLine:IterateObjects("toggle")
            end,
            order = blocksOrder,
        }
        blocksOrder = blocksOrder + 10
    end
    options.args.blocks.args.others = others
    
    return options
end
----

-- Sort by Realm
local function RealmSort(a, b)
    if a.name == nibRealUI.realm then 
        return true
    elseif b.name == nibRealUI.realm then
        return false
    else
        return a.name < b.name
    end
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
    local gold, silver, copper = floor(money / 10000), floor(money / 100) % 100, money % 100
    if gold > 0 then
        return format("|cff%s%d|r", TextColorNormal, gold), "GOLD", gold, format("|cff%s%d|r", TextColorNormal, gold)
    elseif silver > 0 then
        return format("|cff%s%d|r", TextColorNormal, silver), "SILVER", silver, format("|cff%s%d|r|cffc7c7cfs|r", TextColorNormal, silver)
    else
        return format("|cff%s%d|r", TextColorNormal, copper), "COPPER", copper, format("|cff%s%d|r|cffeda55fc|r", TextColorNormal, copper)
    end
end

-- Get Realm time
local function RetrieveTime(isMilitary, isLocal)
    local timeFormat, hour, min, suffix
    if isLocal then
        hour, min = tonumber(date("%H")), tonumber(date("%M"))
    else
        hour, min = GetGameTime()
    end
    if isMilitary then
        timeFormat = TIMEMANAGER_TICKER_24HOUR
        suffix = ""
    else
        timeFormat = TIMEMANAGER_TICKER_12HOUR
        if hour >= 12 then 
            suffix = TIMEMANAGER_PM
            if hour > 12 then
                hour = hour - 12
            end
        else
            suffix = TIMEMANAGER_AM
            if hour == 0 then
                hour = 12
            end
        end
    end
    return timeFormat, hour, min, suffix
end

-- Seconds to Time
local function ConvertSecondstoTime(value)
    local hours, minutes, seconds
    hours = floor(value / 3600)
    minutes = floor((value - (hours * 3600)) / 60)
    seconds = floor(value - ((hours * 3600) + (minutes * 60)))

    if ( hours > 0 ) then
        return strform("%dh %dm", hours, minutes)
    elseif ( minutes > 0 ) then
        if minutes >= 10 then
            return strform("%dm", minutes)
        else
            return strform("%dm %ds", minutes, seconds)
        end
    else
        return strform("%ds", seconds)
    end
end

-- Element Width
local function UpdateElementWidth(frame, tag, ...)
    local extraWidth = 0
    if ... or frame.hidden then
        frame.curwidth = 0
        frame:SetWidth(frame.curwidth)
        --InfoLine:UpdatePositions()
    else

        local iconSize, labelSize, textSize = 4, 0, 0
        if frame.icon then
            iconSize = frame.icon:GetWidth() + db.text.padding
        end
        if frame.label then
            frame.label:SetText(frame.dataObj.label)
            labelSize = frame.label:GetStringWidth() + db.text.padding
            iconSize = 0
        end
        if frame.text then
            --print("Frame Text")
            --print(format("Value: %q Suffix: %q", tostring(frame.dataObj.value), tostring(frame.dataObj.suffix)))
            if frame.dataObj.value and (frame.dataObj.suffix and frame.dataObj.suffix ~= "") then
                --print("Has suffix")
                frame.text:SetText(frame.dataObj.value .. " " .. frame.dataObj.suffix)
            else
                --print("No suffix")
                frame.text:SetText(frame.dataObj.value or frame.dataObj.text)
            end
            textSize = frame.text:GetStringWidth()
        end
        local OldWidth = frame.curwidth or frame:GetWidth()
        --print("UpdateElementWidth", OldWidth, iconSize, textSize)
        frame.curwidth = round(iconSize + labelSize + textSize)

        if frame.curwidth ~= OldWidth then
            frame:SetWidth(frame.curwidth)
        end
    end
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
    Graphs[id] = CreateFrame("Frame", nil, UIParent)
    Graphs[id].parentFrame = parentFrame
    Graphs[id]:SetHeight(GraphHeight + 1)
    
    Graphs[id].gridBot = CreateFrame("Frame", nil, Graphs[id])
    Graphs[id].gridBot:SetHeight(1)
    Graphs[id].gridBot:SetPoint("BOTTOMLEFT", Graphs[id], 0, 0)
    Graphs[id].gridBot:SetPoint("BOTTOMRIGHT", Graphs[id], 0, 0)
    Graphs[id].gridBot.bg = Graphs[id].gridBot:CreateTexture()
    Graphs[id].gridBot.bg:SetAllPoints()
    Graphs[id].gridBot.bg:SetTexture(GraphColor2[1], GraphColor2[2], GraphColor2[3], GraphColor2[4])
    
    Graphs[id].topLines = {}
    Graphs[id].gapLines = {}
    for c = 1, numVals do
        Graphs[id].topLines[c] = CreateFrame("Frame", nil, Graphs[id])
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
    for k, v in pairs(Graphs) do
        if (Graphs[k].parentFrame ~= parentFrame) and Graphs[k].shown then
            HideGraph(k)
        end
    end
end

--------------------
-- Frame Creation --
--------------------
local barHeight
function InfoLine:CreateFrames()
    local frame = CreateFrame("Frame", "RealUI_InfoLine", UIParent)
    frame:SetPoint("BOTTOMLEFT", UIParent, "BOTTOMLEFT",  0, 0)
    frame:SetPoint("BOTTOMRIGHT", UIParent, "BOTTOMRIGHT",  0, 0)
    frame:SetHeight(barHeight)
    frame:SetFrameStrata("LOW")
    frame:SetFrameLevel(0)

    blocks.left[0] = frame
    blocks.right[0] = frame

    -- Background
    frame:SetBackdrop({
        bgFile = nibRealUI.media.textures.plain,
        edgeFile = nibRealUI.media.textures.plain,
        edgeSize = 1,
    })
    frame:SetBackdropBorderColor(0, 0, 0)
    frame:SetBackdropColor(unpack(nibRealUI.media.window))

    -- Stripes
    local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
    tex:SetAlpha(ndb.settings.stripeOpacity)
    tex:SetAllPoints()
    tex:SetHorizTile(true)
    tex:SetVertTile(true)
    tex:SetBlendMode("ADD")
    tinsert(REALUI_WINDOW_FRAMES, frame)
    tinsert(REALUI_STRIPE_TEXTURES, tex)

    --[[ template 
    local test = ldb:NewDataObject("test", {
        type = "RealUI",
        text = "TEST 1 test",
        value = 1,
        suffix = "test",
        label = "TEST"
        icon = Icons[layoutSize].guild
    })
    ]]

    --- Left
    -- Start
    local startMenu = CreateFrame("Frame", "RealUIStartDropDown", UIParent, "UIDropDownMenuTemplate")
    local menuList = {
        {text = "|cffffffffRealUI|r",
            isTitle = true,
            notCheckable = true,
        },
        {text = L["RealUI Config"],
            func = function() nibRealUI:ShowConfigBar() end,
            notCheckable = true,
        },
        {text = "Power Mode",
            notCheckable = true,
            hasArrow = true,
            menuList = {
                {
                    text = "Economy",
                    func = function() 
                        print(L["PowerModeEconomy"])
                        nibRealUI:SetPowerMode(2)
                        nibRealUI:ReloadUIDialog()
                    end,
                    checked = function() return nibRealUI.db.profile.settings.powerMode == 2 end,
                },
                {
                    text = "Normal",
                    func = function()
                        print(L["PowerModeNormal"])
                        nibRealUI:SetPowerMode(1)
                        nibRealUI:ReloadUIDialog()
                    end,
                    checked = function() return nibRealUI.db.profile.settings.powerMode == 1 end,
                },
                {
                    text = "Turbo",
                    func = function()
                        print(L["PowerModeTurbo"])
                        nibRealUI:SetPowerMode(3)
                        nibRealUI:ReloadUIDialog()
                    end,
                    checked = function() return nibRealUI.db.profile.settings.powerMode == 3 end,
                },
            },
        },
        {text = "",
            notCheckable = true,
            disabled = true,
        },
        {text = CHARACTER_BUTTON,
            func = function() ToggleCharacter("PaperDollFrame") end,
            notCheckable = true,
        },
        {text = SPELLBOOK_ABILITIES_BUTTON,
            func = function() ToggleFrame(SpellBookFrame) end,
            notCheckable = true,
        },
        {text = TALENTS_BUTTON,
            func = function() 
                if not PlayerTalentFrame then 
                    TalentFrame_LoadUI()
                end 

                ShowUIPanel(PlayerTalentFrame)
            end,
            notCheckable = true,
            disabled = UnitLevel("player") < SHOW_SPEC_LEVEL,
        },
        {text = ACHIEVEMENT_BUTTON,
            func = function() ToggleAchievementFrame() end,
            notCheckable = true,
        },
        {text = QUESTLOG_BUTTON,
            func = function() ToggleQuestLog() end,
            notCheckable = true,
        },
        {text = IsInGuild() and GUILD or LOOKINGFORGUILD,
            func = function() 
                if IsInGuild() then 
                    if not GuildFrame then GuildFrame_LoadUI() end 
                    GuildFrame_Toggle() 
                else 
                    if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end 
                    LookingForGuildFrame_Toggle() 
                end
            end,
            notCheckable = true,
            disabled = IsTrialAccount(),
        },
        {text = SOCIAL_BUTTON,
            func = function() ToggleFriendsFrame(1) end,
            notCheckable = true,
        },
        {text = DUNGEONS_BUTTON,
            func = function() PVEFrame_ToggleFrame() end,
            notCheckable = true,
            disabled = UnitLevel("player") < math.min(SHOW_LFD_LEVEL, SHOW_PVP_LEVEL),
        },
        {text = COLLECTIONS,
            func = function() TogglePetJournal() end,
            notCheckable = true,
        },
        {text = ENCOUNTER_JOURNAL,
            func = function() ToggleEncounterJournal() end,
            disabled = UnitLevel("player") < SHOW_LFD_LEVEL,
            notCheckable = true,
        },  
        {text = BLIZZARD_STORE,
            func = function() ToggleStoreUI() end,
            notCheckable = true,
        },
        {text = HELP_BUTTON,
            func = function() ToggleHelpFrame() end,
            notCheckable = true,
        },  
    }

    local start = ldb:NewDataObject("Start", {
        type = "RealUI",
        text = "Start",
        side = "left",
        index = 1,
        OnClick = function(self, ...)
            print("Start: OnClick", self.side, ...)
        end,
        OnEnter = function(self, ...)
            print("Start: OnEnter", self.side, ...)
            EasyMenu(menuList, RealUIStartDropDown, self, 0, 0, "MENU", 2)
        end,
        OnLeave = function(self, ...)
            print("Start: OnLeave", self.side, ...)
            --CloseDropDownMenus()
        end,
    })
    UIDropDownMenu_SetAnchor(RealUIStartDropDown, 0, 0, "BOTTOMLEFT", InfoLine_Start, "TOPLEFT")

    -- Mail

    -- Guild Roster
    local guild = ldb:NewDataObject(GUILD, {
        type = "RealUI",
        label = octicons["alignment-unalign"],
        labelFont = {octicons.font, barHeight * .6, "OUTLINE"},
        text = 1,
        value = 1,
        suffix = "",
        side = "left",
        index = 2,
        OnClick = function(self, ...)
            --print("Guild: OnClick", self.side, ...)
            if not InCombatLockdown() then
                ToggleGuildFrame()
            end
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            --print("Guild: OnEnter", self.side, ...)
            local canOffNote = CanViewOfficerNote()

            local tooltip = qTip:Acquire(self, canOffNote and 6 or 5, "LEFT", "CENTER", "LEFT", "LEFT", "LEFT", canOffNote and "LEFT" or nil)
            self.tooltip = tooltip
            local lineNum, colNum

            lineNum, colNum = tooltip:AddHeader()
            local gname = GetGuildInfo("player")
            tooltip:SetCell(lineNum, colNum, gname, nil, nil, canOffNote and 6 or 5, nil, nil, nil, 100)

            local gmotd = GetGuildRosterMOTD()
            if gmotd ~= "" then
                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, gmotd, nil, nil, canOffNote and 6 or 5, nil, nil, nil, 500)
            end
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            tooltip:AddLine(" ")

            if canOffNote then
                lineNum, colNum = tooltip:AddHeader(NAME, LEVEL_ABBR, ZONE, RANK, LABEL_NOTE, OFFICER_NOTE_COLON)
            else
                lineNum, colNum = tooltip:AddHeader(NAME, LEVEL_ABBR, ZONE, RANK, LABEL_NOTE)
            end
            local color = nibRealUI.media.colors.orange
            tooltip:SetLineTextColor(lineNum, color[1], color[2], color[3])

            for i = 1, GetNumGuildMembers() do
                local name, rank, _, lvl, _class, zone, note, offnote, isOnline, status, class, _, _, isMobile = GetGuildRosterInfo(i)
                if isOnline or isMobile then
                    -- Remove server from name
                    name = Ambiguate(name, "guild")

                    -- Status tag
                    if status > 0 then
                        local curStatus = PlayerStatusValToStr[status] or ""
                        name = curStatus .. name
                    end

                    -- Mobile tag
                    if isMobile and (not isOnline) then
                        name = REMOTE_CHAT_ICON .. name
                        zone = REMOTE_CHAT
                    end

                    if canOffNote then
                        lineNum, colNum = tooltip:AddLine(name, lvl, zone, rank, note, offnote)
                    else
                        lineNum = tooltip:AddLine(name, lvl, zone, rank, note)
                    end

                    -- Class color names
                    color = nibRealUI:GetClassColor(class)
                    tooltip:SetCellTextColor(lineNum, 1, color[1], color[2], color[3])

                    -- Difficulty color levels
                    color = GetQuestDifficultyColor(lvl)
                    tooltip:SetCellTextColor(lineNum, 2, color.r, color.g, color.b)

                    -- Mouse functions
                    tooltip:SetLineScript(lineNum, "OnMouseDown", function(...)
                        print(...)
                        if not name then return end
                        if IsAltKeyDown() then
                            InviteUnit(name)
                        else
                            SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
                        end
                    end)
                end
            end

            tooltip:AddLine(" ")

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, colNum, L["<Click> to whisper, <Alt+Click> to invite."], nil, nil, canOffNote and 6 or 5, nil, nil, nil, 500)
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
        end,
        OnEvent = function(self, event, ...)
            --print("Guild: OnEvent", event, ...)
            local _, online, onlineAndMobile = GetNumGuildMembers()
            self.dataObj.value = online
            if online == onlineAndMobile then
                self.dataObj.suffix = ""
            else
                self.dataObj.suffix = "(".. onlineAndMobile - online ..")"
            end
            UpdateElementWidth(self)
        end,
        events = {
            "GUILD_ROSTER_UPDATE",
            "GUILD_MOTD",
        },
    })

    -- Friends

    -- Durability
    local itemSlots = {
        {slot = "Head", hasDura = true},
        {slot = "Neck", hasDura = false},
        {slot = "Shoulder", hasDura = true},
        {}, -- shirt
        {slot = "Chest", hasDura = true},
        {slot = "Waist", hasDura = true},
        {slot = "Legs", hasDura = true},
        {slot = "Feet", hasDura = true},
        {slot = "Wrist", hasDura = true},
        {slot = "Hands", hasDura = true},
        {slot = "Finger0", hasDura = false},
        {slot = "Finger1", hasDura = false},
        {slot = "Trinket0", hasDura = false},
        {slot = "Trinket1", hasDura = false},
        {slot = "Back", hasDura = false},
        {slot = "MainHand", hasDura = true},
        {slot = "SecondaryHand", hasDura = true},
    }
    local dura = ldb:NewDataObject(DURABILITY, {
        type = "RealUI",
        text = 1,
        side = "left",
        index = 3,
        OnClick = function(self, ...)
            print("Durability: OnClick", self.side, ...)
            if not InCombatLockdown() then
                ToggleCharacter("PaperDollFrame")
            end
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            print("Durability: OnEnter", self.side, ...)

            local tooltip = qTip:Acquire(self, 2, "LEFT", "RIGHT")
            self.tooltip = tooltip
            local lineNum, colNum

            lineNum, colNum = tooltip:AddHeader()
            tooltip:SetCell(lineNum, colNum, DURABILITY, nil, 2)

            for slotID = 1, #itemSlots do
                local item = itemSlots[slotID]
                if item.hasDura then
                    tooltip:AddLine(item.slot, round(item.dura * 100) .. "%")
                end
            end

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
        end,
        OnEvent = function(self, event, ...)
            print("Durability: OnEvent", event, self.timer, ...)
            if event == "UPDATE_INVENTORY_DURABILITY" and not self.timer then
                self.timer = InfoLine:ScheduleTimer(self.dataObj.OnEvent, 1, self, "timerUpdate")
                return
            end
            local lowest = 1
            for slotID = 1, #itemSlots do
                local item = itemSlots[slotID]
                if item.hasDura then
                    local min, max = GetInventoryItemDurability(slotID)
                    local per = nibRealUI:GetSafeVals(min, max)
                    item.dura = per
                    lowest = per < lowest and per or lowest
                    print(slotID, item.slot, round(per, 3), round(lowest, 3))
                end
            end
            self.dataObj.text = round(lowest * 100) .. "%"
            self.timer = false
            UpdateElementWidth(self)
        end,
        events = {
            "UPDATE_INVENTORY_DURABILITY",
            "PLAYER_ENTERING_WORLD",
        },
    })

    -- Bag space

    -- Currency

    -- XP / Rep
    local xprep = ldb:NewDataObject(XP.."/"..REPUTATION_ABBR, {
        type = "RealUI",
        label = XP,
        text = 1,
        value = 1,
        suffix = "",
        side = "left",
        index = 4,
        OnClick = function(self, ...)
            print("XP / Rep: OnClick", self.side, ...)
            dbc.xrstate = (dbc.xrstate == "x") and "r" or "x"
            if UnitLevel("player") == MAX_PLAYER_LEVEL and not InCombatLockdown() then
                ToggleCharacter("ReputationFrame")
            end
            self.dataObj.OnEvent(self, "OnClick", ...)
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            print("XP / Rep: OnEnter", self.side, ...)

            local tooltip = qTip:Acquire(self, 2, "LEFT", "RIGHT")
            self.tooltip = tooltip
            local lineNum, colNum

            -- XP
            if UnitLevel("player") < MAX_PLAYER_LEVEL then
                local xpCurr, xpMax = UnitXP("player"), UnitXPMax("player")
                local xpRest = GetXPExhaustion() or 0

                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetCell(lineNum, colNum, EXPERIENCE_COLON, nil, 2)

                lineNum, colNum = tooltip:AddLine(L["Current"], nibRealUI:ReadableNumber(xpCurr))
                if IsXPUserDisabled() then
                    tooltip:SetCellTextColor(lineNum, 2, 0.5, 0.5, 0.5)
                end

                lineNum, colNum = tooltip:AddLine(L["Remaining"], nibRealUI:ReadableNumber(xpMax - xpCurr))
                if IsXPUserDisabled() then
                    tooltip:SetCellTextColor(lineNum, 2, 0.5, 0.5, 0.5)
                end

                lineNum, colNum = tooltip:AddLine(TUTORIAL_TITLE26, nibRealUI:ReadableNumber(xpRest))
                tooltip:AddLine(" ")
            end

            -- Rep
            local name, standing, repMin, repMax, value, factionID = GetWatchedFactionInfo()

            lineNum, colNum = tooltip:AddHeader()
            tooltip:SetCell(lineNum, colNum, REPUTATION..":", nil, 2)

            tooltip:AddLine(FACTION, name or "None Selected")
            if name then
                lineNum, colNum = tooltip:AddLine(STATUS, _G["FACTION_STANDING_LABEL"..standing])
                tooltip:SetCellTextColor(lineNum, 2, FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b)
                tooltip:AddLine(L["Current"], nibRealUI:ReadableNumber(value - repMin))
                tooltip:AddLine(L["Remaining"], nibRealUI:ReadableNumber(repMax - (value - repMin)))
            end

            tooltip:AddLine(" ")

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, 1, L["<Click> to switch between"], nil, 2)
            tooltip:SetCellTextColor(lineNum, 1, 0, 1, 0)

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, 1, "       "..L["XP and Rep display."], nil, 2)
            tooltip:SetCellTextColor(lineNum, 1, 0, 1, 0)

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
        end,
        OnEvent = function(self, event, ...)
            print("XP / Rep: OnEvent", event, ...)
            local isMaxLvl = (UnitLevel("player") == MAX_PLAYER_LEVEL)
            if ( (dbc.xrstate == "x") and not isMaxLvl and not (IsXPUserDisabled()) ) then
                local xpPer, _, xpMax = nibRealUI:GetSafeVals(UnitXP("player"), UnitXPMax("player"))
                local xpRest = nibRealUI:GetSafeVals(GetXPExhaustion() or 0, xpMax)

                self.dataObj.label = XP
                self.dataObj.value = round(xpPer * 100) .. "%"
                if xpRest > 0 then
                    self.dataObj.suffix = "(".. round(xpRest * 100) .. "%)"
                else
                    self.dataObj.suffix = ""
                end
            else
                dbc.xrstate = "r"
                local name, standing, repMin, repMax, value, factionID = GetWatchedFactionInfo()
                local repPer = nibRealUI:GetSafeVals((value - repMin), repMax)

                self.dataObj.label = "Rep"
                if name then
                    self.dataObj.value = round(repPer * 100) .. "%"
                else
                    self.dataObj.value = "---"
                end
                self.dataObj.suffix = ""
            end
            UpdateElementWidth(self)
        end,
        events = {
            "PLAYER_XP_UPDATE",
            "DISABLE_XP_GAIN",
            "ENABLE_XP_GAIN",
            "UPDATE_FACTION",
            "PLAYER_ENTERING_WORLD",
        },
    })

    --- Right
    -- Clock
    local function setTimeOptions(self)
        self.isMilitary = GetCVar("timeMgrUseMilitaryTime") == "1"
        self.isLocal = GetCVar("timeMgrUseLocalTime") == "1"
    end
    local clock = ldb:NewDataObject(TIMEMANAGER_TITLE, {
        type = "RealUI",
        text = 1,
        value = 1,
        suffix = "",
        side = "right",
        index = 1,
        OnClick = function(self, ...)
            --print("Clock: OnClick", self.side, ...)
            if IsShiftKeyDown() then
                ToggleTimeManager()
            else
                if IsAddOnLoaded("GroupCalendar5") then
                    if GroupCalendar.UI.Window:IsShown() then
                        HideUIPanel(GroupCalendar.UI.Window)
                    else
                        ShowUIPanel(GroupCalendar.UI.Window)
                    end
                else
                    ToggleCalendar()
                end
            end
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            --print("Clock: OnEnter", self.side, ...)

            local tooltip = qTip:Acquire(self, 2, "LEFT", "RIGHT")
            self.tooltip = tooltip
            local lineNum, colNum

            lineNum, colNum = tooltip:AddHeader()
            tooltip:SetCell(lineNum, colNum, TIMEMANAGER_TOOLTIP_TITLE, nil, 2)

            -- Realm time
            local timeFormat, hour, min, suffix = RetrieveTime(self.isMilitary, false)
            tooltip:AddLine(TIMEMANAGER_TOOLTIP_REALMTIME, strform(timeFormat, hour, min) .. " " .. suffix)

            -- Local time
            timeFormat, hour, min, suffix = RetrieveTime(self.isMilitary, true)
            tooltip:AddLine(TIMEMANAGER_TOOLTIP_LOCALTIME, strform(timeFormat, hour, min) .. " " .. suffix)

            tooltip:AddLine(" ")

            for i = 1, 3 do
                local _, zone, isActive, canQueue, startTime, canEnter = GetWorldPVPAreaInfo(i)
                if startTime then
                    tooltip:AddLine(strform(L["PVP Time Left"], zone), ConvertSecondstoTime(startTime))
                else
                    lineNum, colNum = tooltip:AddLine()
                    tooltip:SetCell(lineNum, colNum, strform(L["No PVP Time Available"], zone), nil, 2)
                end
            end

            tooltip:AddLine(" ")

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, colNum, L["<Click> to show calendar."], nil, 2)
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, colNum, L["<Shift+Click> to show timer."], nil, 2)
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
        end,
        OnEvent = function(self, event, ...)
            --print("Clock: OnEvent", event, ...)
            if event == "PLAYER_ENTERING_WORLD" then
                InfoLine:ScheduleRepeatingTimer(self.dataObj.OnEvent, 1, self, "Update")
                hooksecurefunc("TimeManager_ToggleTimeFormat", setTimeOptions)
                hooksecurefunc("TimeManager_ToggleLocalTime", setTimeOptions)
                setTimeOptions(self)
            end
            local timeFormat, hour, min, suffix = RetrieveTime(self.isMilitary, self.isLocal)
            self.dataObj.value = strform(timeFormat, hour, min)
            self.dataObj.suffix = suffix
            UpdateElementWidth(self)
        end,
        events = {
            "PLAYER_ENTERING_WORLD",
        },
    })

    -- Meters

    -- Layout

    -- Specialization

    -- FPS/Ping
end


-------------------
-- LDB Functions --
-------------------
local function OnEnter(self)
    --self.highlight:Show()

    if (not db.other.icTips and UnitAffectingCombat("player")) then return end
    local dataObj  = self.dataObj
    local name = self.name
    
    if dataObj.tooltip then
        PrepareTooltip(obj.tooltip, self)
        if dataObj.tooltiptext then
            dataObj.tooltip:SetText(obj.tooltiptext)
        end
        dataObj.tooltip:Show()
    
    elseif dataObj.OnTooltipShow then
        PrepareTooltip(GameTooltip, self)
        dataObj.OnTooltipShow(GameTooltip)
        GameTooltip:Show()
    
    elseif dataObj.tooltiptext then
        PrepareTooltip(GameTooltip, self)
        GameTooltip:SetText(obj.tooltiptext)
        GameTooltip:Show()      
    
    elseif dataObj.OnEnter then
        dataObj.OnEnter(self)
    end
end

local function OnLeave(self)
    --self.highlight:Hide()

    if (not db.other.icTips and UnitAffectingCombat("player")) then return end
    local dataObj  = self.dataObj
    
    if dataObj.OnTooltipShow then
        GameTooltip:Hide()
    end
    
    if dataObj.OnLeave then
        dataObj.OnLeave(self)
    elseif dataObj.tooltip then
        dataObj.tooltip:Hide()
    else
        GameTooltip:Hide()
    end
end

local function OnClick(self, ...)
    if (UnitAffectingCombat("player")) then return end
    if self.dataObj.OnClick then
        self.dataObj.OnClick(self, ...)
    end
end

local function OnEvent(self, event, ...)
    --print(self, event, ...)
    self.dataObj.OnEvent(self, event, ...)

    -- Update the tooltip
    if qTip:IsAcquired(self) then
        qTip:Release(self.tooltip)
        OnEnter(self)
    end
end

local function OnUpdate(self, ...)
    self.dataObj.OnUpdate(self, ...)

    -- Update the tooltip
    if qTip:IsAcquired(self) then
        qTip:Release(self.tooltip)
        OnEnter(self)
    end
end

local function CreateNewBlock(name, dataObj)
    local block = CreateFrame("Button", "InfoLine_" .. name, RealUI_InfoLine)
    tinsert(blocks[dataObj.side], dataObj.index, block)
    block.dataObj = dataObj
    block:SetSize(barHeight, barHeight)
    
    --[[ Test BG ]]
    local test = block:CreateTexture(nil, "ARTWORK")
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(block)

    local yOfs = round(barHeight * 0.3)
    local font, size, flags = nibRealUI.font.pixel1[1], nibRealUI.font.pixel1[2], nibRealUI.font.pixel1[3]
    local text = block:CreateFontString(nil, "ARTWORK")
    text:SetFont(font, size, flags)
    text:SetTextColor(textColor.normal[1], textColor.normal[2], textColor.normal[3])
    text:SetPoint("RIGHT", 0, 0)
    text:SetText(dataObj.text)
    if dataObj.value and (dataObj.suffix ~= "" or dataObj.suffix ~= nil) then
        text:SetText(dataObj.value .. " " .. dataObj.suffix)
    else
        text:SetText(dataObj.value or dataObj.text)
    end
    block.text = text


    if dataObj.label then
        local label = block:CreateFontString(nil, "ARTWORK")
        if dataObj.labelFont then
            font, size, flags = dataObj.labelFont[1], dataObj.labelFont[2], dataObj.labelFont[3]
        end
        label:SetFont(font, size, flags)
        label:SetTextColor(textColor.normal[1], textColor.normal[2], textColor.normal[3])
        label:SetPoint("LEFT", 4, 0)
        label:SetText(dataObj.label)
        block.label = label
    end

    if dataObj.icon then
        local icon = block:CreateTexture(nil, "ARTWORK")
        icon:SetTexture(dataObj.icon[1])
        icon:SetSize(16, 16)
        icon:SetPoint("LEFT", 4, 0)
        block.icon = icon
    end

    local r, g, b = nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3]
    local highlight = block:CreateTexture(nil, "ARTWORK")
    highlight:SetTexture(r, g, b)
    highlight:SetHeight(1)
    highlight:SetPoint("BOTTOMLEFT")
    highlight:SetPoint("BOTTOMRIGHT")
    highlight:Hide()
    block:SetHighlightTexture(highlight)
    block.highlight = highlight
    
    block:SetScript("OnEnter", OnEnter)
    block:SetScript("OnLeave", OnLeave)

    block:SetScript("OnClick", OnClick)
    if dataObj.events then
        block:SetScript("OnEvent", OnEvent)
        for i = 1, #dataObj.events do
            block:RegisterEvent(dataObj.events[i])
        end
    end
    if dataObj.OnUpdate then
        block:SetScript("OnUpdate", OnUpdate)
    end
    
    return block
end

local function updatePositions()
    print("numLeft", #blocks["left"], "numRight", #blocks["right"])
    for i = 1, #blocks["left"] do
        local block = blocks["left"][i]
        print("Left", i, block and block:GetName())
        UpdateElementWidth(block)
        block:SetPoint("BOTTOMLEFT", blocks["left"][block.dataObj.index - 1], block.dataObj.index > 1 and "BOTTOMRIGHT" or "BOTTOMLEFT", db.text.gap, 0)
    end
    for i = 1, #blocks["right"] do
        local block = blocks["right"][i]
        print("Right", i, block and block:GetName())
        UpdateElementWidth(block)
        block:SetPoint("BOTTOMRIGHT", blocks["right"][block.dataObj.index - 1], block.dataObj.index > 1 and "BOTTOMLEFT" or "BOTTOMRIGHT", -db.text.gap, 0)
    end
end

function InfoLine:IterateObjects(event)
    for name, dataObj in ldb:DataObjectIterator() do
        self:LibDataBroker_DataObjectCreated(event, name, dataObj, true)
    end
end

function InfoLine:LibDataBroker_DataObjectCreated(event, name, dataObj, noupdate)
    --print("DataObjectCreated:", event, name, dataObj, noupdate)
    if dataObj.type == "RealUI" then
        print("RealUI object", name)
        if db.blocks.realui[name].enabled then
            CreateNewBlock(name, dataObj)
        end
    elseif dataObj.type == "data source" then
        --print(name, dataObj.type)
        for k, v in ldb:pairs(dataObj) do
            --print(k, v)
        end
        if db.blocks.others[name].enabled then
            dataObj.index = db.blocks.others[name].index
            dataObj.side = db.blocks.others[name].side
            CreateNewBlock(name, dataObj)
        end
    end
end

--------------------
-- Initialization --
--------------------
function InfoLine:OnInitialize()
    local otherFaction = nibRealUI:OtherFaction(nibRealUI.faction)
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        char = {
            xrstate = "x",
            currencystate = 1,
            specgear = {
                primary = -1,
                secondary = -1,
            },
        },
        global = {
            currency = {
                [nibRealUI.realm] = {
                    [nibRealUI.faction] = {
                        [nibRealUI.name] = {
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
            text = {
                gap = 1,
                padding = 5,
                headersize = 13,
                columnsize = 10,
                normalsize = 11,
                hintsize = 11,
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
                wgalert = false,
                tbalert = true,
                maxheight = 500,
            },
            blocks = {
                others = {
                    ['*'] = {
                        side = "left",
                        enabled = false,
                        showText = true,
                        showIcon = true,
                        index = 500,
                        width = 0,
                    },
                },
                realui = {
                    ['*'] = {
                        side = "left",
                        enabled = true,
                        index = 1,
                    },
                },
            },
        },
    })
    db = self.db.profile
    dbc = self.db.char
    dbg = self.db.global
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
    ndbg = nibRealUI.db.global

    layoutSize = ndb.settings.hudSize

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function InfoLine:OnEnable()
    barHeight = floor(GetScreenHeight() * 0.02)
    updateColors()

    self:CreateFrames()
    self:IterateObjects("OnEnable")
    updatePositions()
    ldb.RegisterCallback(self, "LibDataBroker_DataObjectCreated")
end

function InfoLine:OnDisable()
    for name, dataObj in ldb:DataObjectIterator() do
        if blocks[name] then blocks[name]:Hide() end
    end
    for k, v in pairs(blocks) do
        v:Hide()
    end
    ldb.UnregisterCallback(self, "LibDataBroker_DataObjectCreated")
end
