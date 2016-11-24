local _, private = ...

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs

-- Libs --
local LDB = _G.LibStub("LibDataBroker-1.1")
local qTip = _G.LibStub("LibQTip-1.0")

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "InfoLine"
local InfoLine = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
InfoLine.LDB = LDB
InfoLine.locked = true

local MOVING_BLOCK
local textColor = {}
local blocksByData = {}
local barHeight


----------------------
-- Block Management --
----------------------
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

local BlockMixin = {}
function BlockMixin:OnEnter()
    --InfoLine:debug("OnEnter", self.name)
    --self.highlight:Show()

    if (not db.other.icTips and _G.InCombatLockdown()) then return end
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

function BlockMixin:OnLeave()
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

function BlockMixin:OnClick(...)
    InfoLine:debug("OnClick", self.name, ...)
    if self.dataObj.OnClick and not _G.InCombatLockdown() then
        InfoLine:debug("Send OnClick")
        self.dataObj.OnClick(self, ...)
    end
end

function BlockMixin:OnDragStart(button)
    InfoLine:debug("OnDragStart", self.name, button)
    local dock = InfoLine.frame[self.side]
    dock:RemoveChatFrame(self)

    local x, y = self:GetCenter();
    x = x - (self:GetWidth()/2);
    y = y - (self:GetHeight()/2);
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x, y);
    self:StartMoving();
    MOVING_BLOCK = self;
end

function BlockMixin:OnDragStop(button)
    InfoLine:debug("OnDragStart", self.name, button)
    self:StopMovingOrSizing()

    local dock = InfoLine.frame[self.side]
    dock:HideInsertHighlight()

    if ( dock:IsMouseOver(barHeight, 0, 0, 0) ) then
        local scale, mouseX, mouseY = _G.UIParent:GetScale(), _G.GetCursorPosition();
        mouseX, mouseY = mouseX / scale, mouseY / scale;

        -- DockFrame
        dock:AddChatFrame(self, dock:GetInsertIndex(self, mouseX, mouseY))
        dock:UpdateTabs(true)
    else
        self:RestorePosition()
    end

    self:SavePosition();

    MOVING_BLOCK = nil
end

function BlockMixin:OnEvent(event, ...)
    InfoLine:debug("OnEvent", self.name, event, ...)
    self.dataObj.OnEvent(self, event, ...)

    -- Update the tooltip
    if qTip:IsAcquired(self) then
        qTip:Release(self.tooltip)
        self:OnEnter()
    end
end

function BlockMixin:OnUpdate(elapsed)
    --InfoLine:debug("OnUpdate", self.name, elapsed)
    if self.dataObj.OnUpdate then
        self.dataObj.OnUpdate(self, elapsed)
    end

    if self.checkWidth then
        local labelWidth = self.label:GetStringWidth()
        InfoLine:debug(self.name, "OnUpdate", labelWidth)
        if labelWidth > 1 then
            self:SetWidth(self:GetWidth() + labelWidth)
            self.checkWidth = nil
        end
    end

    if self == MOVING_BLOCK then
        local scale, cursorX, cursorY = _G.UIParent:GetScale(), _G.GetCursorPosition();
        cursorX, cursorY = cursorX / scale, cursorY / scale;
        local dock = InfoLine.frame[self.side]
        if dock:IsMouseOver(barHeight, 0, 0, 0) then
            dock:PlaceInsertHighlight(self, cursorX, cursorY);
        else
            dock:HideInsertHighlight();
        end
        self:UpdateButtonSide();

        if not _G.IsMouseButtonDown(self.dragButton) then
            self:OnDragStop(self.dragButton)
            self.dragButton = nil;
            MOVING_BLOCK = nil
        end
    elseif self:IsMouseOver() then
        -- Update the tooltip
        qTip:Release(self.tooltip)
        self:OnEnter()
    end
end

function BlockMixin:UpdateButtonSide()
    local xOfs =  self:GetCenter();
    local uiCenter = _G.UIParent:GetWidth() / 2
    local changed = nil;
    if xOfs < uiCenter then
        if self.side ~= "left" then
            self.side = "left"
            changed = 1;
        end
    else
        if self.side ~= "right" then
            self.side = "right"
            changed = 1;
        end
    end
    return changed;
end

function BlockMixin:SavePosition()
    local blockInfo = InfoLine:GetBlockInfo(self.name, self.dataObj)

    blockInfo.side = self.side
    blockInfo.index = self.index
end

function BlockMixin:RestorePosition()
    local blockInfo = InfoLine:GetBlockInfo(self.name, self.dataObj)

    local dock = InfoLine.frame[blockInfo.side]
    dock:AddChatFrame(self, blockInfo.index)
end

local function CreateNewBlock(name, dataObj)
    InfoLine:debug("CreateNewBlock", name, dataObj)
    local block = _G.Mixin(_G.CreateFrame("Button", nil, InfoLine.frame), BlockMixin)
    blocksByData[dataObj] = block
    block.dataObj = dataObj
    block.name = name
    local width, space = 0, 4

    local bg = block:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 1, 0.5)
    bg:SetAllPoints(block)
    bg:Hide()
    block.bg = bg

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
        block.checkWidth = labelWidth < 1
        InfoLine:debug(block.name, "labelWidth", labelWidth)

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

    block:SetScript("OnEnter", block.OnEnter)
    block:SetScript("OnLeave", block.OnLeave)

    block:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    block:SetScript("OnClick", block.OnClick)
    block:SetScript("OnDragStart", block.OnDragStart)

    block:SetScript("OnUpdate", block.OnUpdate)

    InfoLine:debug("SetSize", width, barHeight)
    block:SetSize(width, barHeight)
    block:SetClampedToScreen(true)
    return block
end

function InfoLine:AddBlock(name, dataObj, blockInfo)
    local block = blocksByData[dataObj]
    if not block then
        block = CreateNewBlock(name, dataObj)
    end

    if dataObj.events then
        block:SetScript("OnEvent", block.OnEvent)
        for i = 1, #dataObj.events do
            block:RegisterEvent(dataObj.events[i])
        end
    end

    if dataObj.OnEnable then
        dataObj.OnEnable(block)
    end

    if blockInfo.side then
        block.side = blockInfo.side
        local dock = self.frame[blockInfo.side]
        self:debug("AddChatFrame", blockInfo.side, blockInfo.index)
        if blockInfo.index == 1 then
            dock:SetPrimary(block)
        else
            dock:AddChatFrame(block, blockInfo.index)
        end
    end
end

function InfoLine:RemoveBlock(name, dataObj, blockInfo)
    local block = blocksByData[dataObj]
    if blockInfo.side then
        local dock = InfoLine.frame[self.side]
        dock:RemoveChatFrame(self)
    end

    if dataObj.OnDisable then
        dataObj.OnDisable(block)
    end
    block:Hide()
end

function InfoLine:LibDataBroker_DataObjectCreated(event, name, dataObj, noupdate)
    self:debug("DataObjectCreated:", event, name, dataObj.type, noupdate)
    local blockInfo = self:GetBlockInfo(name, dataObj)
    if blockInfo and blockInfo.enabled then
        self:AddBlock(name, dataObj, blockInfo)
    end
end
function InfoLine:LibDataBroker_AttributeChanged(event, name, attr, value, dataObj)
    self:debug("AttributeChanged:", event, name, attr, value, dataObj.type)
    local block = blocksByData[dataObj]
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


---------------------
-- Dock Management --
---------------------
local DockMixin = {}
function DockMixin:OnLoad()
    self:SetHeight(barHeight)
    self.anchor = "BOTTOM" .. self.side:upper()
    self.anchorAlt = "BOTTOM" .. self.alt:upper()
    self:SetPoint(self.anchor)
    self:SetPoint(self.anchorAlt, InfoLine.frame, "BOTTOM")

    self.insertHighlight = self:CreateTexture(nil, "ARTWORK")
    self.insertHighlight:SetSize(1, barHeight)
    self.insertHighlight:SetColorTexture(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])

    self.DOCKED_CHAT_FRAMES = {};
    self.isDirty = true;    --You dirty, dirty frame
end

function DockMixin:GetChatFrames()
    return self.DOCKED_CHAT_FRAMES;
end

function DockMixin:SetPrimary(chatFrame)
    self.primary = chatFrame;

    if ( not self:GetSelectedWindow() ) then
        self:SelectWindow(chatFrame);
    end

    self:AddChatFrame(chatFrame, 1);
end

function DockMixin:OnUpdate()
    --These may fail if we're resizing the WoW client
    if self:UpdateTabs() then
        self.leftTab = nil;
        self:SetScript("OnUpdate", nil);
    end
end

function DockMixin:AddChatFrame(chatFrame, position)
    if ( not self.primary ) then
        _G.error("Need a primary window before another can be added.");
    end

    if ( self:HasDockedChatFrame(chatFrame) ) then
        return; --We're already docked...
    end

    self.isDirty = true;
    chatFrame.isDocked = 1;

    if ( position and position <= #self.DOCKED_CHAT_FRAMES + 1 ) then
        _G.assert(position ~= 1 or chatFrame == self.primary, position);
        _G.tinsert(self.DOCKED_CHAT_FRAMES, position, chatFrame);
    else
        _G.tinsert(self.DOCKED_CHAT_FRAMES, chatFrame);
    end

    self:HideInsertHighlight();

    if ( self.primary ~= chatFrame ) then
        chatFrame:ClearAllPoints();
        chatFrame:SetMovable(false);
        chatFrame:SetResizable(false);
    end

    self:UpdateTabs();
end

function DockMixin:RemoveChatFrame(chatFrame)
    _G.assert(chatFrame ~= self.primary or #self.DOCKED_CHAT_FRAMES == 1);
    self.isDirty = true;
    _G.tDeleteItem(self.DOCKED_CHAT_FRAMES, chatFrame);
    chatFrame.isDocked = nil;
    chatFrame:SetMovable(true);
    if ( self:GetSelectedWindow() == chatFrame ) then
        self:SelectWindow(self.DOCKED_CHAT_FRAMES[1]);
    end

    chatFrame:Show();
    self:UpdateTabs();
end

function DockMixin:HasDockedChatFrame(chatFrame)
    return _G.tContains(self.DOCKED_CHAT_FRAMES, chatFrame);
end

function DockMixin:SelectWindow(chatFrame)
    _G.assert(chatFrame)
    self.isDirty = true;
    self.selected = chatFrame;
    self:UpdateTabs();
end

function DockMixin:GetSelectedWindow()
    return self.selected;
end

function DockMixin:UpdateTabs(forceUpdate)
    if ( not self.isDirty and not forceUpdate ) then
        --No changes have been made since the last update.
        return;
    end

    local lastBlock = nil;

    for index, chatFrame in ipairs(self.DOCKED_CHAT_FRAMES) do
        chatFrame:Show();

        if ( lastBlock ) then
            local xOfs = self.side == "left" and db.text.gap or -db.text.gap
            chatFrame:SetPoint(self.anchor, lastBlock, self.anchorAlt, xOfs, 0);
        else
            chatFrame:SetPoint(self.anchor);
        end
        lastBlock = chatFrame
    end

    self.isDirty = false;

    return true
end

function DockMixin:GetInsertIndex(chatFrame, mouseX, mouseY)
    local maxPosition = 0;
    for index, value in ipairs(self.DOCKED_CHAT_FRAMES) do
        if self.side == "left" then
            if mouseX < (value:GetLeft() + value:GetRight()) / 2 and  --Find the first tab we're on the left of. (Being on top of the tab, but left of the center counts)
                value ~= self.primary then   --We never count as being to the left of the primary tab.
                return index;
            end
        elseif self.side == "right" then
            if mouseX > (value:GetLeft() + value:GetRight()) / 2 and
                value ~= self.primary then
                return index;
            end
        end
        maxPosition = index;
    end
    --We aren't to the left of anything, so we're going into the far-right position.
    return maxPosition + 1;
end

function DockMixin:PlaceInsertHighlight(chatFrame, mouseX, mouseY)
    local insert = self:GetInsertIndex(chatFrame, mouseX, mouseY);

    local attachFrame = self.primary;

    for index, value in ipairs(self.DOCKED_CHAT_FRAMES) do
        if ( index < insert ) then
            attachFrame = value;
        end
    end

    self.insertHighlight:ClearAllPoints();
    self.insertHighlight:SetPoint(self.anchor, attachFrame, self.anchorAlt, 0, 0);
    self.insertHighlight:Show();
end

function DockMixin:HideInsertHighlight()
    self.insertHighlight:Hide();
end

--------------------
-- Bar Management --
--------------------
function InfoLine:CreateBar()
    local frame = _G.CreateFrame("Frame", "RealUI_InfoLine", _G.UIParent)
    frame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT",  0, 0)
    frame:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT",  0, 0)
    frame:SetHeight(barHeight)
    frame:SetFrameStrata("LOW")
    frame:SetFrameLevel(0)

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

    -- Watch bars
    local watch = {}
    watch.main = _G.CreateFrame("StatusBar", nil, frame)
    watch.main:SetStatusBarTexture(RealUI.media.textures.plain)
    watch.main:SetAllPoints()
    watch.main:Hide()
    for i = 1, 2 do
        local bar = _G.CreateFrame("StatusBar", nil, frame)
        bar:SetStatusBarTexture(RealUI.media.textures.plain)
        bar:SetHeight(1)
        bar:SetFrameLevel(watch.main:GetFrameLevel() + 1)
        bar:Hide()

        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(0, 0, 0)
        bg:SetPoint("TOPLEFT", bar, -1, 1)
        bg:SetPoint("BOTTOMRIGHT", bar, 1, -1)

        watch[i] = bar
    end
    watch[1]:SetPoint("BOTTOMLEFT", watch.main, "TOPLEFT", 0, -1)
    watch[1]:SetPoint("BOTTOMRIGHT", watch.main, "TOPRIGHT", 0, -1)

    watch[2]:SetPoint("BOTTOMLEFT", watch.main, "TOPLEFT", 0, 1)
    watch[2]:SetPoint("BOTTOMRIGHT", watch.main, "TOPRIGHT", 0, 1)

    frame.watch = watch

    -- Docks
    frame.left = _G.Mixin(_G.CreateFrame("Frame", nil, frame), DockMixin)
    frame.left.side = "left"
    frame.left.alt = "right"
    frame.left:OnLoad()

    frame.right = _G.Mixin(_G.CreateFrame("Frame", nil, frame), DockMixin)
    frame.right.side = "right"
    frame.right.alt = "left"
    frame.right:OnLoad()

    self.frame = frame
end

function InfoLine:Unlock()
    local left = self.frame.left
    for i, block in next, left.DOCKED_CHAT_FRAMES do
        if i > 1 then
            block:RegisterForDrag("LeftButton")
            block.bg:Show()
        end
    end

    local right = self.frame.right
    for i, block in next, right.DOCKED_CHAT_FRAMES do
        if i > 1 then
            block:RegisterForDrag("LeftButton")
            block.bg:Show()
        end
    end

    self.locked = false
end
function InfoLine:Lock()
    local left = self.frame.left
    for i, block in next, left.DOCKED_CHAT_FRAMES do
        block:RegisterForDrag()
        block.bg:Hide()
    end

    local right = self.frame.right
    for i, block in next, right.DOCKED_CHAT_FRAMES do
        block:RegisterForDrag()
        block.bg:Hide()
    end

    self.locked = true
end

function InfoLine:GetBlockInfo(name, dataObj)
    if not name and dataObj then
        name = LDB:GetNameByDataObject(dataObj)
    elseif name and not dataObj then
        dataObj = LDB:GetDataObjectByName(name)
    end
    _G.assert(_G.type(name) == "string" and _G.type(dataObj) == "table", "Usage: InfoLine:GetBlockInfo(\"dataobjectname\")")

    if dataObj.type == "RealUI" then
        self:debug("RealUI object")
        return db.blocks.realui[name]
    elseif dataObj.type == "data source" then
        self:debug("Other object")
        for k, v in LDB:pairs(dataObj) do
            self:debug(k, v)
        end
        return db.blocks.others[name]
    end
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
            progressState = 1,
            currencyState = 1,
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
            },
            blocks = {
                others = {
                    ['*'] = {
                        side = "left",
                        index = 10,
                        enabled = false,
                        showText = true,
                        showIcon = true,
                    },
                },
                realui = {
                    -- Left
                    start = {
                        side = "left",
                        index = 1,
                        enabled = -1
                    },
                    guild = {
                        side = "left",
                        index = 2,
                        enabled = true
                    },
                    durability = {
                        side = "left",
                        index = 3,
                        enabled = true
                    },
                    progress = {
                        side = "left",
                        index = 4,
                        enabled = true
                    },

                    -- Right
                    clock = {
                        side = "right",
                        index = 1,
                        enabled = -1
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

    LDB.RegisterCallback(self, "LibDataBroker_DataObjectCreated")
    LDB.RegisterCallback(self, "LibDataBroker_AttributeChanged")

    self:CreateBar()
    self:CreateBlocks()

    for name, dataObj in LDB:DataObjectIterator() do
        self:LibDataBroker_DataObjectCreated("OnEnable", name, dataObj, true)
    end
end
