local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G
local min, max, abs, floor = _G.math.min, _G.math.max, _G.math.abs, _G.math.floor
local tonumber, tostring = _G.tonumber, _G.tostring
local next, type = _G.next, _G.type

-- WoW Globals --
local CreateFrame = _G.CreateFrame

-- Libs --
local LDB = LibStub("LibDataBroker-1.1")
local qTip = LibStub("LibQTip-1.0")

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L
local db, dbc, dbg, ndb, ndbc, ndbg

local MODNAME = "InfoLine"
local InfoLine = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local round = nibRealUI.Round
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
        return ("|cff%s%d|r"):format(TextColorNormal, gold), "GOLD", gold, ("|cff%s%d|r"):format(TextColorNormal, gold)
    elseif silver > 0 then
        return ("|cff%s%d|r"):format(TextColorNormal, silver), "SILVER", silver, ("|cff%s%d|r|cffc7c7cfs|r"):format(TextColorNormal, silver)
    else
        return ("|cff%s%d|r"):format(TextColorNormal, copper), "COPPER", copper, ("|cff%s%d|r|cffeda55fc|r"):format(TextColorNormal, copper)
    end
end

-- Element Width
function InfoLine:UpdateElementWidth(frame, tag, ...)
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
            self:debug("Frame Text")
            self:debug(("Value: %q Suffix: %q"):format(tostring(frame.dataObj.value), tostring(frame.dataObj.suffix)))
            if frame.dataObj.value and (frame.dataObj.suffix and frame.dataObj.suffix ~= "") then
                self:debug("Has suffix")
                frame.text:SetText(frame.dataObj.value .. " " .. frame.dataObj.suffix)
            else
                self:debug("No suffix")
                frame.text:SetText(frame.dataObj.value or frame.dataObj.text)
            end
            textSize = frame.text:GetStringWidth()
        end
        local OldWidth = frame.curwidth or frame:GetWidth()
        self:debug("UpdateElementWidth", OldWidth, iconSize, textSize)
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
function InfoLine:CreateBar()
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
    tex:SetAlpha(RealUI_InitDB.stripeOpacity)
    tex:SetAllPoints()
    tex:SetHorizTile(true)
    tex:SetVertTile(true)
    tex:SetBlendMode("ADD")
    tinsert(REALUI_WINDOW_FRAMES, frame)
    tinsert(REALUI_STRIPE_TEXTURES, tex)
end


-------------------
-- LDB Functions --
-------------------
local function PrepareTooltip(tooltip, block)
    InfoLine:debug("PrepareTooltip", tooltip, block and block.name)
    if tooltip and block then
        tooltip:ClearAllPoints()
        if tooltip.SetOwner then
            tooltip:SetOwner(block, ("ANCHOR_NONE"))
        end 
        local anchor = block.side == "left" and "LEFT" or "RIGHT"
        InfoLine:debug("SetPoint", anchor)
        tooltip:SetPoint(("BOTTOM"..anchor), block, ("TOP"..anchor))
    end
end

local function OnEnter(self)
    InfoLine:debug("OnEnter", self.name)
    --self.highlight:Show()

    if (not db.other.icTips and UnitAffectingCombat("player")) then return end
    local dataObj  = self.dataObj
    
    if dataObj.tooltip then
        PrepareTooltip(dataObj.tooltip, self)
        if dataObj.tooltiptext then
            dataObj.tooltip:SetText(dataObj.tooltiptext)
        end
        dataObj.tooltip:Show()
    
    elseif dataObj.OnEnter then
        dataObj.OnEnter(self)

    elseif dataObj.OnTooltipShow then
        PrepareTooltip(GameTooltip, self)
        dataObj.OnTooltipShow(GameTooltip)
        GameTooltip:Show()
    
    elseif dataObj.tooltiptext then
        PrepareTooltip(GameTooltip, self)
        GameTooltip:SetText(dataObj.tooltiptext)
        GameTooltip:Show()      
    end
end

local function OnLeave(self)
    InfoLine:debug("OnLeave", self.name)
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
    InfoLine:debug("OnClick", self.name, ...)
    if (UnitAffectingCombat("player")) then return end
    if self.dataObj.OnClick then
        InfoLine:debug("Send OnClick")
        self.dataObj.OnClick(self, ...)
    end
end

local function OnEvent(self, event, ...)
    InfoLine:debug("OnEvent", self.name, event, ...)
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
    InfoLine:debug("CreateNewBlock", name, dataObj)
    local block = CreateFrame("Button", "InfoLine_" .. name, RealUI_InfoLine)
    tinsert(blocks[dataObj.side], dataObj.index, block)
    block.dataObj = dataObj
    block.name = name
    block:SetSize(barHeight, barHeight)
    
    --[[ Test BG ]]
    local test = block:CreateTexture(nil, "ARTWORK")
    test:SetTexture(1, 1, 1, 0.5)
    test:SetAllPoints(block)

    local yOfs = round(barHeight * 0.3)
    local text = block:CreateFontString(nil, "ARTWORK")
    text:SetFontObject(RealUIFont_Pixel)
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
            label:SetFont(dataObj.labelFont[1], dataObj.labelFont[2], dataObj.labelFont[3])
        else
            label:SetFontObject(RealUIFont_Pixel)
        end
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

    block:RegisterForClicks("LeftButtonUp", "RightButtonUp")
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
    InfoLine:debug("numLeft", #blocks["left"], "numRight", #blocks["right"])
    for i = 1, #blocks["left"] do
        local block = blocks["left"][i]
        InfoLine:debug("Left", i, block and block:GetName())
        InfoLine:UpdateElementWidth(block)
        block:SetPoint("BOTTOMLEFT", blocks["left"][block.dataObj.index - 1], block.dataObj.index > 1 and "BOTTOMRIGHT" or "BOTTOMLEFT", db.text.gap, 0)
    end
    for i = 1, #blocks["right"] do
        local block = blocks["right"][i]
        InfoLine:debug("Right", i, block and block:GetName())
        InfoLine:UpdateElementWidth(block)
        block:SetPoint("BOTTOMRIGHT", blocks["right"][block.dataObj.index - 1], block.dataObj.index > 1 and "BOTTOMLEFT" or "BOTTOMRIGHT", -db.text.gap, 0)
    end
end

function InfoLine:IterateObjects(event)
    self:debug("IterateObjects:", event)
    for name, dataObj in LDB:DataObjectIterator() do
        self:LibDataBroker_DataObjectCreated(event, name, dataObj, true)
    end
    updatePositions()
end

function InfoLine:LibDataBroker_DataObjectCreated(event, name, dataObj, noupdate)
    self:debug("DataObjectCreated:", event, name, dataObj.type, noupdate)
    local blockInfo
    if dataObj.type == "RealUI" then
        blockInfo = db.blocks.realui[name]
        self:debug("RealUI object", blockInfo.enabled)
        if blockInfo.enabled then
            CreateNewBlock(name, dataObj)
        end
    elseif dataObj.type == "data source" then
        blockInfo = db.blocks.others[name]
        self:debug("Other object", blockInfo.enabled)
        for k, v in LDB:pairs(dataObj) do
            self:debug(k, v)
        end
        if blockInfo.enabled then
            if blockInfo.index == 500 then
                blockInfo.side = #blocks["left"] <= #blocks["right"] and "left" or "right"
                blockInfo.index = #blocks[blockInfo.side] + 1
            end
            dataObj.side = blockInfo.side
            dataObj.index = blockInfo.index
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
    self.barHeight = barHeight
    updateColors()

    self:CreateBar()
    self:CreateBlocks(dbc, ndb)
    self:IterateObjects("OnEnable")
    LDB.RegisterCallback(self, "LibDataBroker_DataObjectCreated")
end

function InfoLine:OnDisable()
    for name, dataObj in LDB:DataObjectIterator() do
        if blocks[name] then blocks[name]:Hide() end
    end
    for k, v in pairs(blocks) do
        v:Hide()
    end
    LDB.UnregisterCallback(self, "LibDataBroker_DataObjectCreated")
end
