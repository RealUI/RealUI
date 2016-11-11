local _, private = ...

-- Lua Globals --
local _G = _G
local ipairs = _G.ipairs

-- Libs --
local LDB = _G.LibStub("LibDataBroker-1.1")
local qTip = _G.LibStub("LibQTip-1.0")

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "InfoLine"
local InfoLine = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
InfoLine.LDB = LDB

local textColor = {}
local inactiveBlocks = {
    left = {},
    right = {},
}

--------------------
-- Frame Creation --
--------------------
local barHeight
function InfoLine:CreateBar()
    local frame = _G.CreateFrame("Frame", "RealUI_InfoLine", _G.UIParent)
    frame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT",  0, 0)
    frame:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT",  0, 0)
    frame:SetHeight(barHeight)
    frame:SetFrameStrata("LOW")
    frame:SetFrameLevel(0)

    frame.left = {}
    frame.right = {}

    -- Background
    frame:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
        edgeFile = RealUI.media.textures.plain,
        edgeSize = 1,
    })
    frame:SetBackdropBorderColor(0, 0, 0)
    frame:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])

    -- Stripes
    local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true, true)
    tex:SetAlpha(_G.RealUI_InitDB.stripeOpacity)
    tex:SetAllPoints()
    tex:SetHorizTile(true)
    tex:SetVertTile(true)
    tex:SetBlendMode("ADD")
    _G.tinsert(_G.REALUI_WINDOW_FRAMES, frame)
    _G.tinsert(_G.REALUI_STRIPE_TEXTURES, tex)

    self.frame = frame
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

    if (not db.other.icTips and _G.UnitAffectingCombat("player")) then return end
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
        PrepareTooltip(_G.GameTooltip, self)
        dataObj.OnTooltipShow(_G.GameTooltip)
        _G.GameTooltip:Show()
    
    elseif dataObj.tooltiptext then
        PrepareTooltip(_G.GameTooltip, self)
        _G.GameTooltip:SetText(dataObj.tooltiptext)
        _G.GameTooltip:Show()      
    end
end

local function OnLeave(self)
    InfoLine:debug("OnLeave", self.name)
    --self.highlight:Hide()

    if (not db.other.icTips and _G.UnitAffectingCombat("player")) then return end
    local dataObj  = self.dataObj
    
    if dataObj.OnTooltipShow then
        _G.GameTooltip:Hide()
    end
    
    if dataObj.OnLeave then
        dataObj.OnLeave(self)
    elseif dataObj.tooltip then
        dataObj.tooltip:Hide()
    else
        _G.GameTooltip:Hide()
    end
end

local function OnClick(self, ...)
    InfoLine:debug("OnClick", self.name, ...)
    if (_G.UnitAffectingCombat("player")) then return end
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
    local block = _G.CreateFrame("Button", "InfoLine_" .. name, InfoLine.frame)
    block.dataObj = dataObj
    dataObj.block = block
    block.name = name
    local width, space = 0, 4
    
    --[[ Test BG ]]
    local test = block:CreateTexture(nil, "BACKGROUND")
    test:SetColorTexture(1, 1, 1, 0.5)
    test:SetAllPoints(block)

    local text = block:CreateFontString(nil, "ARTWORK")
    text:SetFontObject(_G.RealUIFont_Chat)
    text:SetTextColor(textColor.normal[1], textColor.normal[2], textColor.normal[3])
    text:SetPoint("RIGHT", 0, 0)
    text:SetText(dataObj.text)
    if dataObj.suffix and dataObj.suffix ~= "" then
        text:SetText(dataObj.value .. " " .. dataObj.suffix)
    else
        text:SetText(dataObj.value or dataObj.text)
    end
    block.text = text
    width = width + text:GetStringWidth() + space
    InfoLine:debug("text", width)


    if dataObj.icon then
        local icon, size = block:CreateTexture(nil, "ARTWORK"), _G.floor(barHeight * 0.9)
        icon:SetTexture(dataObj.icon)
        icon:SetSize(size, size)
        icon:SetPoint("LEFT", space, 0)
        if dataObj.iconR then
            icon:SetVertexColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
        end
        if dataObj.iconCoords then
            icon:SetTexCoord(_G.unpack(dataObj.iconCoords))
        end
        block.icon = icon
        width = width + size + space
        InfoLine:debug("icon", width)
    end

    if dataObj.label then
        local label = block:CreateFontString(nil, "ARTWORK")
        if dataObj.labelFont then
            label:SetFont(dataObj.labelFont[1], dataObj.labelFont[2], dataObj.labelFont[3])
        else
            label:SetFontObject(_G.RealUIFont_Chat)
        end
        label:SetTextColor(textColor.normal[1], textColor.normal[2], textColor.normal[3])
        if dataObj.icon then
            label:SetPoint("LEFT", block.icon, "RIGHT", space, 0)
        else
            label:SetPoint("LEFT", space, 0)
        end
        label:SetText(dataObj.label)

        local labelWidth = label:GetStringWidth()
        label.checkWidth = labelWidth < 1

        block.label = label
        width = width + labelWidth + space
        InfoLine:debug("label", dataObj.label, width)
    end

    local r, g, b = RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3]
    local highlight = block:CreateTexture(nil, "ARTWORK")
    highlight:SetColorTexture(r, g, b)
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
    
    InfoLine:debug("SetSize", width, barHeight)
    block:SetSize(width, barHeight)
    return block
end

do
    --[[local function InsertBlock(newBlock, nextBlock)
        InfoLine:debug("InsertBlock", newBlock.name)
    end
    local function WithdrawBlock(block, blockInfo)
        InfoLine:debug("WithdrawBlock", block.name)
    end]]

    function InfoLine:AddBlock(name, dataObj, blockInfo)
        self:debug("AddBlock:", blockInfo.index, blockInfo.side)
        local inactive = inactiveBlocks[blockInfo.side]
        local newBlock = inactive[blockInfo.index]
        if not newBlock then
            newBlock = CreateNewBlock(name, dataObj)
        end

        local active, nextBlock = self.frame[blockInfo.side]
        self:debug("Find next:", #active)
        for index, block in ipairs(active) do
            if blockInfo.index and block.index > blockInfo.index then
                self:debug("Found next", index)
                nextBlock = block
                _G.tinsert(active, index, newBlock)
                break
            end
        end

        local point, relativeTo, relativePoint, xOfs, yOfs
        if nextBlock then
            point, relativeTo, relativePoint, xOfs, yOfs = nextBlock:GetPoint()
            nextBlock:ClearAllPoints()
            if point == relativePoint then
                local relPoint = relativePoint:find("LEFT") and "BOTTOMRIGHT" or "BOTTOMLEFT"
                nextBlock:SetPoint(point, newBlock, relPoint, xOfs, yOfs)
            else
                nextBlock:SetPoint(point, newBlock, relativePoint, xOfs, yOfs)
            end
        else
            _G.tinsert(active, newBlock)
            local isFirst = #active == 1
            point = "BOTTOM"..blockInfo.side:upper()
            relativeTo = isFirst and self.frame or active[#active - 1]
            relativePoint = isFirst and point or "BOTTOM"..(blockInfo.side == "left" and "RIGHT" or "LEFT")
            xOfs = db.text.gap
            yOfs = 0
        end
        if not blockInfo.index then
            blockInfo.index = #active
        end
        newBlock.index = blockInfo.index
        self:debug("Point:", point, relativeTo.name, relativePoint, xOfs, yOfs)
        newBlock:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        newBlock:Show()
    end

    function InfoLine:RemoveBlock(name, blockInfo)
        self:debug("RemoveBlock:", name, blockInfo.index, blockInfo.side)
        local active, nextBlock, oldBlock = self.frame[blockInfo.side]
        for index, block in ipairs(active) do
            if name == block.name then
                self:debug("Found block", index)
                oldBlock = _G.tremove(active, index)
                inactiveBlocks[blockInfo.side][blockInfo.index] = oldBlock
                nextBlock = active[index]
                break
            end
        end
        
        if nextBlock then
            local point, relativeTo, relativePoint, xOfs, yOfs = oldBlock:GetPoint()
            nextBlock:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
        end
        oldBlock:Hide()
    end
end

function InfoLine:LibDataBroker_DataObjectCreated(event, name, dataObj, noupdate)
    self:debug("DataObjectCreated:", event, name, dataObj.type, noupdate)
    local blockInfo
    if dataObj.type == "RealUI" then
        blockInfo = db.blocks.realui[name]
        self:debug("RealUI object", blockInfo.enabled)
        if blockInfo.enabled then
            InfoLine:AddBlock(name, dataObj, blockInfo)
        end
    elseif dataObj.type == "data source" then
        blockInfo = db.blocks.others[name]
        self:debug("Other object", blockInfo.enabled)
        for k, v in LDB:pairs(dataObj) do
            self:debug(k, v)
        end
        if blockInfo.enabled then
            InfoLine:AddBlock(name, dataObj, blockInfo)
        end
    end
end
function InfoLine:LibDataBroker_AttributeChanged(event, name, attr, value, dataObj)
    self:debug("AttributeChanged:", event, name, attr, value, dataObj.type)
    local block = dataObj.block
    if block then
        if attr == "value" or attr == "suffix" or attr == "text" then
            local blockWidth = block:GetWidth()
            local oldStringWidth = block.text:GetStringWidth()
            if dataObj.suffix and dataObj.suffix ~= "" then
                block.text:SetText(dataObj.value .. " " .. dataObj.suffix)
            else
                block.text:SetText(dataObj.value or dataObj.text)
            end
            local newStringWidth = block.text:GetStringWidth()

            if block.label and block.label.checkWidth then
                local labelWidth = block.label:GetStringWidth()
                block.label.checkWidth = labelWidth < 1

                newStringWidth = newStringWidth + labelWidth
            end

            block:SetWidth((blockWidth - oldStringWidth) + newStringWidth)
        end
        if attr:find("icon") then
            block.icon:SetTexture(dataObj.icon)
            if dataObj.iconR then
                block.icon:SetVertexColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
            end
            if dataObj.iconCoords then
                block.icon:SetTexCoord(_G.unpack(dataObj.iconCoords))
            end
        end
    end
end
--------------------
-- Initialization --
--------------------
function InfoLine:OnInitialize()
    local otherFaction = RealUI:OtherFaction(RealUI.faction)
    self.db = RealUI.db:RegisterNamespace(MODNAME)
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
                    },
                },
                realui = {
                    ['*'] = {
                        side = "left",
                        enabled = true,
                    },
                },
            },
        },
    })
    db = self.db.profile
    --[[
    dbc = self.db.char
    dbg = self.db.global
    ndb = RealUI.db.profile
    ndbc = RealUI.db.char
    ndbg = RealUI.db.global
    ]]

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function InfoLine:OnEnable()
    barHeight = _G.floor(_G.GetScreenHeight() * 0.02)
    self.barHeight = barHeight

    textColor.normal = db.colors.normal
    if db.colors.classcolorhighlight then
        textColor.highlight = RealUI.classColor
    else
        textColor.highlight = db.colors.highlight
    end
    textColor.disabled = db.colors.disabled
    textColor.white = {1, 1, 1}
    textColor.header = db.colors.ttheader
    textColor.orange = RealUI.media.colors.orange
    textColor.blue = RealUI.media.colors.blue

    self:CreateBar()
    for name, dataObj in LDB:DataObjectIterator() do
        self:LibDataBroker_DataObjectCreated("OnEnable", name, dataObj, true)
    end

    LDB.RegisterCallback(self, "LibDataBroker_DataObjectCreated")
    LDB.RegisterCallback(self, "LibDataBroker_AttributeChanged")
    self:CreateBlocks()
end
