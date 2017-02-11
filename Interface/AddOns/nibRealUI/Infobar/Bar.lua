local _, private = ...

-- Lua Globals --
local next, ipairs = _G.next, _G.ipairs

-- Libs --
local LDB = _G.LibStub("LibDataBroker-1.1")
local qTip = _G.LibStub("LibQTip-1.0")

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "Infobar"
local Infobar = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
Infobar.LDB = LDB
Infobar.locked = true

local MOVING_BLOCK
local blocksByData = {}
local BAR_HEIGHT = RealUI.ModValue(16)

local blockFont do
    local font, _, outline = _G.RealUIFont_Normal:GetFont()
    blockFont = {
        font = font,
        size = RealUI.ModValue(10),
        outline = outline
    }
end

----------------------
-- Block Management --
----------------------
local function PrepareTooltip(tooltip, block)
    Infobar:debug("PrepareTooltip", tooltip, block and block.name)
    if tooltip and block then
        tooltip:ClearAllPoints()
        if tooltip.SetOwner then
            tooltip:SetOwner(block, ("ANCHOR_NONE"))
        end
        local anchor = block.side:upper()
        Infobar:debug("SetPoint", anchor)
        tooltip:SetPoint(("BOTTOM"..anchor), block, ("TOP"..anchor))
    end
end

local BlockMixin = {}
function BlockMixin:OnEnter()
    --Infobar:debug("OnEnter", self.name)
    --self.highlight:Show()

    if (not db.combatTips and _G.InCombatLockdown()) then return end
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
    Infobar:debug("OnLeave", self.name)
    --self.highlight:Hide()

    if (not db.combatTips and _G.UnitAffectingCombat("player")) then return end
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
    Infobar:debug("OnClick", self.name, ...)
    if self.dataObj.OnClick and not _G.InCombatLockdown() then
        Infobar:debug("Send OnClick")
        self.dataObj.OnClick(self, ...)
    end
end

function BlockMixin:OnDragStart(button)
    Infobar:debug("OnDragStart", self.name, button)
    local dock = Infobar.frame[self.side]
    dock:RemoveBlock(self)

    local x, y = self:GetCenter();
    x = x - (self:GetWidth()/2);
    y = y - (self:GetHeight()/2);
    self:ClearAllPoints();
    self:SetPoint("TOPLEFT", "UIParent", "BOTTOMLEFT", x, y);
    self:StartMoving();
    MOVING_BLOCK = self;
end

function BlockMixin:OnDragStop(button)
    Infobar:debug("OnDragStart", self.name, button)
    self:StopMovingOrSizing()

    local dock = Infobar.frame[self.side]
    dock:HideInsertHighlight()

    if ( dock:IsMouseOver(BAR_HEIGHT, 0, 0, 0) ) then
        local scale, mouseX, mouseY = _G.UIParent:GetScale(), _G.GetCursorPosition();
        mouseX, mouseY = mouseX / scale, mouseY / scale;

        -- DockFrame
        dock:AddBlock(self, dock:GetInsertIndex(mouseX, mouseY))
        dock:UpdateBlocks(true)
    else
        self:RestorePosition()
    end

    self:SavePosition();

    MOVING_BLOCK = nil
end

function BlockMixin:OnEvent(event, ...)
    Infobar:debug("OnEvent", self.name, event, ...)
    self.dataObj.OnEvent(self, event, ...)

    -- Update the tooltip
    if qTip:IsAcquired(self) then
        qTip:Release(self.tooltip)
        self:OnEnter()
    end
end

function BlockMixin:OnUpdate(elapsed)
    --Infobar:debug("OnUpdate", self.name, elapsed)
    if self.dataObj.OnUpdate then
        self.dataObj.OnUpdate(self, elapsed)
    end

    if self.checkWidth and self.icon.isFont then
        local width = self.icon:GetStringWidth()
        Infobar:debug(self.name, "OnUpdate", width)
        if width > 1 then
            self:SetWidth(self:GetWidth() + width)
            self.checkWidth = nil
        end
    end

    if self == MOVING_BLOCK then
        local scale, cursorX, cursorY = _G.UIParent:GetScale(), _G.GetCursorPosition();
        cursorX, cursorY = cursorX / scale, cursorY / scale;
        local dock = Infobar.frame[self.side]
        if dock:IsMouseOver(BAR_HEIGHT, 0, 0, 0) then
            dock:PlaceInsertHighlight(cursorX, cursorY);
        else
            dock:HideInsertHighlight();
        end
        self:UpdateButtonSide();

        if not _G.IsMouseButtonDown(self.dragButton) then
            self:OnDragStop(self.dragButton)
            self.dragButton = nil;
            MOVING_BLOCK = nil
        end
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
    local blockInfo = Infobar:GetBlockInfo(self.name, self.dataObj)

    blockInfo.side = self.side
    blockInfo.index = self.index
end

function BlockMixin:RestorePosition()
    local blockInfo = Infobar:GetBlockInfo(self.name, self.dataObj)

    local dock = Infobar.frame[blockInfo.side]
    dock:AddBlock(self, blockInfo.index)
end

function BlockMixin:AdjustElements(blockInfo)
    local space = RealUI.ModValue(2)
    local width = self.text:GetStringWidth() + space
    self.text:SetPoint("RIGHT", -space, 0)

    if self.icon then
        if blockInfo.showIcon then
            self.icon:SetPoint("LEFT", space, 0)
            self.icon:Show()
            local iconWidth = (self.icon.isFont and self.icon:GetStringWidth() or self.icon:GetWidth())

            self.checkWidth = iconWidth < 1
            width = width + space + iconWidth
            Infobar:debug("icon", width)
        else
            self.icon:Hide()
        end
    end

    if blockInfo.showLabel then
        if self.icon and blockInfo.showIcon then
            self.label:SetPoint("LEFT", self.icon, "RIGHT", 0, 0)
        else
            self.label:SetPoint("LEFT", space, 0)
        end

        self.label:Show()
        width = width + space + self.label:GetStringWidth()
        Infobar:debug("label", self.dataObj.label, width)
    else
        self.label:Hide()
    end

    self:SetWidth(width)
end

local function CreateNewBlock(name, dataObj, blockInfo)
    Infobar:debug("CreateNewBlock", name, dataObj)
    local block = _G.Mixin(_G.CreateFrame("Button", nil, Infobar.frame), BlockMixin)
    block:SetFrameLevel(Infobar.frame:GetFrameLevel() + 2)
    blocksByData[dataObj] = block
    block.dataObj = dataObj
    block.name = name

    local bg = block:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 1, 0.25)
    bg:SetAllPoints(block)
    bg:Hide()
    block.bg = bg

    local font, size, outline = blockFont.font, blockFont.size, blockFont.outline
    local text = block:CreateFontString(nil, "ARTWORK")
    text:SetFont(font, size, outline)
    text:SetTextColor(1, 1, 1)
    if dataObj.suffix and dataObj.suffix ~= "" then
        text:SetText(dataObj.value .. " " .. dataObj.suffix)
    else
        text:SetText(dataObj.value or dataObj.text)
    end
    block.text = text

    if dataObj.icon then
        local icon
        if dataObj.iconFont then
            icon = block:CreateFontString(nil, "ARTWORK")
            icon:SetFont(dataObj.iconFont.font, dataObj.iconFont.size, dataObj.iconFont.outline)
            icon:SetText(dataObj.icon)
            if dataObj.iconR then
                icon:SetTextColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
            end
            icon.isFont = true
        else
            icon = block:CreateTexture(nil, "ARTWORK")
            icon:SetTexture(dataObj.icon)
            icon:SetSize(size, size)
            if dataObj.iconR then
                icon:SetVertexColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
            end
            if dataObj.iconCoords then
                icon:SetTexCoord(_G.unpack(dataObj.iconCoords))
            end
        end
        block.icon = icon
    end

    local label = block:CreateFontString(nil, "ARTWORK")
    label:SetFont(font, size, outline)
    label:SetTextColor(1, 1, 1)
    label:SetText(dataObj.label or dataObj.name)
    block.label = label

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

    Infobar:debug("SetHeight", BAR_HEIGHT)
    block:SetHeight(BAR_HEIGHT)
    block:AdjustElements(blockInfo)
    block:SetClampedToScreen(true)
    return block
end

function Infobar:AddBlock(name, dataObj, blockInfo)
    self:debug("Infobar:AddBlock", name, blockInfo.side, blockInfo.index)
    local block = blocksByData[dataObj]
    if not block or block.isFake then
        block = CreateNewBlock(name, dataObj, blockInfo)
    end

    if dataObj.events then
        block:SetScript("OnEvent", block.OnEvent)
        block:RegisterEvent("PLAYER_ENTERING_WORLD")
        for i = 1, #dataObj.events do
            block:RegisterEvent(dataObj.events[i])
        end
    end

    if blockInfo.side then
        block.side = blockInfo.side
        local dock = self.frame[blockInfo.side]
        if blockInfo.index == 1 then
            dock:SetPrimary(block)
        else
            dock:AddBlock(block, blockInfo.index)
        end
    end

    if dataObj.OnEnable then
        dataObj.OnEnable(block)
    end

    return block
end

function Infobar:RemoveBlock(name, dataObj, blockInfo)
    self:debug("Infobar:RemoveBlock", name, blockInfo.side, blockInfo.index)
    local block = blocksByData[dataObj]
    if blockInfo.side then
        local dock = Infobar.frame[blockInfo.side]
        dock:RemoveBlock(block)
    end

    block:Hide()
    if dataObj.OnDisable then
        dataObj.OnDisable(block)
    end
end

function Infobar:LibDataBroker_DataObjectCreated(event, name, dataObj, noupdate)
    --self:debug("DataObjectCreated:", event, name, dataObj.type, noupdate)
    if dataObj.type == "data source" or dataObj.type == "RealUI" then
        local blockInfo = self:GetBlockInfo(name, dataObj)
        if blockInfo and blockInfo.enabled then
            self:AddBlock(name, dataObj, blockInfo)
        else
            blocksByData[dataObj] = {
                name = name,
                isFake = true
            }
        end
    end
end
function Infobar:LibDataBroker_AttributeChanged(event, name, attr, value, dataObj)
    --self:debug("AttributeChanged:", event, name, attr, value, dataObj.type)
    local block = blocksByData[dataObj]
    if block and not block.isFake then
        local blockInfo = self:GetBlockInfo(name, dataObj)
        if attr == "value" or attr == "suffix" or attr == "text" then
            if dataObj.suffix and dataObj.suffix ~= "" then
                block.text:SetText(dataObj.value .. " " .. dataObj.suffix)
            else
                block.text:SetText(dataObj.value or dataObj.text)
            end
        end
        if blockInfo.showLabel and attr:find("label") then
            block.label:SetText(dataObj.label)
            if dataObj.labelR then
                block.label:SetTextColor(dataObj.labelR, dataObj.labelG, dataObj.labelB)
            end
        end
        if blockInfo.showIcon and attr:find("icon") then
            local icon = block.icon
            if icon.isFont then
                icon:SetText(dataObj.icon)
                if dataObj.iconR then
                    icon:SetTextColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
                end
            else
                block.icon:SetTexture(dataObj.icon)
                if dataObj.iconR then
                    block.icon:SetVertexColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
                end
                if dataObj.iconCoords then
                    block.icon:SetTexCoord(_G.unpack(dataObj.iconCoords))
                end
            end
        end
        block:AdjustElements(blockInfo)
    end
end

function Infobar:IterateBlocks()
    return next, blocksByData
end

---------------------
-- Dock Management --
---------------------
local DockMixin = {}
function DockMixin:OnLoad()
    self:SetHeight(BAR_HEIGHT)
    self.anchor = "BOTTOM" .. self.side:upper()
    self.anchorAlt = "BOTTOM" .. self.alt:upper()
    self:SetPoint(self.anchor)
    self:SetPoint(self.anchorAlt, Infobar.frame, "BOTTOM")

    self.insertHighlight = self:CreateTexture(nil, "ARTWORK")
    self.insertHighlight:SetSize(1, BAR_HEIGHT)
    self.insertHighlight:SetColorTexture(1, 1, 1)

    self.DOCKED_BLOCKS = {};
    self.isDirty = true;    --You dirty, dirty frame
end

function DockMixin:SetPrimary(block)
    self.primary = block;
    self:AddBlock(block, 1);
end

function DockMixin:AddBlock(block, position)
    if ( not self.primary ) then
        _G.error("Need a primary block before another can be added.");
    end

    if ( self:HasDockedBlock(block) ) then
        return; --We're already docked...
    end

    self.isDirty = true;
    block.isDocked = 1;

    if ( position and position <= #self.DOCKED_BLOCKS + 1 ) then
        _G.assert(position ~= 1 or block == self.primary, position);
        _G.tinsert(self.DOCKED_BLOCKS, position, block);
    else
        _G.tinsert(self.DOCKED_BLOCKS, block);
    end

    self:HideInsertHighlight();

    if ( self.primary ~= block ) then
        block:ClearAllPoints();
        block:SetMovable(false);
        block:SetResizable(false);
    end

    self:UpdateBlocks();
end

function DockMixin:RemoveBlock(block)
    _G.assert(block ~= self.primary or #self.DOCKED_BLOCKS == 1);
    self.isDirty = true;
    _G.tDeleteItem(self.DOCKED_BLOCKS, block);
    block.isDocked = nil;
    block:SetMovable(true);

    block:Show();
    self:UpdateBlocks();
end

function DockMixin:HasDockedBlock(block)
    return _G.tContains(self.DOCKED_BLOCKS, block);
end

function DockMixin:UpdateBlocks(forceUpdate)
    if ( not self.isDirty and not forceUpdate ) then
        --No changes have been made since the last update.
        return;
    end

    local lastBlock = nil;

    for index, block in ipairs(self.DOCKED_BLOCKS) do
        if forceUpdate then
            block:AdjustElements(Infobar:GetBlockInfo(block.name, block.dataObj))
        end
        block:Show();

        if ( lastBlock ) then
            local xOfs = self.side == "left" and db.blockGap or -db.blockGap
            block:SetPoint(self.anchor, lastBlock, self.anchorAlt, xOfs, 0);
        else
            block:SetPoint(self.anchor);
        end
        lastBlock = block
    end

    self.isDirty = false;

    return true
end

function DockMixin:GetInsertIndex(mouseX, mouseY)
    local maxPosition = 0;
    for index, block in ipairs(self.DOCKED_BLOCKS) do
        if self.side == "left" then
            if mouseX < (block:GetLeft() + block:GetRight()) / 2 and  --Find the first block we're on the left of. (Being on top of the block, but left of the center counts)
                block ~= self.primary then   --We never count as being to the left of the primary block.
                return index;
            end
        elseif self.side == "right" then
            if mouseX > (block:GetLeft() + block:GetRight()) / 2 and
                block ~= self.primary then
                return index;
            end
        end
        maxPosition = index;
    end
    --We aren't to the left of anything, so we're going into the far-right position.
    return maxPosition + 1;
end

function DockMixin:PlaceInsertHighlight(mouseX, mouseY)
    local insert = self:GetInsertIndex(mouseX, mouseY);

    local attachFrame = self.primary;

    for index, block in ipairs(self.DOCKED_BLOCKS) do
        if ( index < insert ) then
            attachFrame = block;
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
function Infobar:CreateBar()
    local frame = _G.CreateFrame("Frame", "RealUI_Infobar", _G.UIParent)
    frame:SetPoint("BOTTOMLEFT", _G.UIParent, "BOTTOMLEFT",  0, 0)
    frame:SetPoint("BOTTOMRIGHT", _G.UIParent, "BOTTOMRIGHT",  0, 0)
    frame:SetHeight(BAR_HEIGHT)
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

    local mainBar = watch.main:GetStatusBarTexture()
    watch.main.rested = watch.main:CreateTexture(nil, "ARTWORK")
    watch.main.rested:SetPoint("TOPLEFT", mainBar, "TOPRIGHT")
    watch.main.rested:Hide()
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

function Infobar:Unlock()
    local left = self.frame.left
    for i, block in next, left.DOCKED_BLOCKS do
        if i > 1 then
            block:RegisterForDrag("LeftButton")
            block.bg:Show()
        end
    end

    local right = self.frame.right
    for i, block in next, right.DOCKED_BLOCKS do
        if i > 1 then
            block:RegisterForDrag("LeftButton")
            block.bg:Show()
        end
    end

    self.locked = false
end
function Infobar:Lock()
    local left = self.frame.left
    for i, block in next, left.DOCKED_BLOCKS do
        block:RegisterForDrag()
        block.bg:Hide()
    end

    local right = self.frame.right
    for i, block in next, right.DOCKED_BLOCKS do
        block:RegisterForDrag()
        block.bg:Hide()
    end

    self.locked = true
end
function Infobar:SettingsUpdate(setting, dataObj)
    if setting == "statusBar" then
        local watch = self.frame.watch
        watch.main:SetShown(db.showBars)
        for i = 1, 2 do
            watch[i]:SetShown(db.showBars)
        end
    else
        self.frame.left:UpdateBlocks(true)
        self.frame.right:UpdateBlocks(true)
    end
end

function Infobar:GetBlockInfo(name, dataObj)
    if not name and dataObj then
        name = LDB:GetNameByDataObject(dataObj)
    elseif name and not dataObj then
        dataObj = LDB:GetDataObjectByName(name)
    end
    _G.assert(_G.type(name) == "string" and _G.type(dataObj) == "table", "Usage: Infobar:GetBlockInfo(\"dataobjectname\")")

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
function Infobar:OnInitialize()
    local specgear = {}
    for specIndex = 1, RealUI.numSpecs do
        specgear[specIndex] = -1
    end
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        char = {
            progressState = "xp",
            currencyState = "gold",
            specgear = specgear,
        },
        profile = {
            showBars = true,
            combatTips = false,
            blockGap = 1,
            blocks = {
                others = {
                    ["*"] = {
                        enabled = false,
                        showLabel = false,
                        showIcon = true,
                        side = "left",
                        index = 10,
                    },
                },
                realui = {
                    ["**"] = {
                        enabled = true,
                        showLabel = false,
                        showIcon = true,
                        side = "left",
                        index = 10,
                    },
                    -- Left
                    start = {
                        side = "left",
                        index = 1,
                        enabled = -1
                    },
                    guild = {
                        side = "left",
                        index = 2,
                    },
                    friends = {
                        side = "left",
                        index = 3,
                    },
                    durability = {
                        side = "left",
                        index = 4,
                    },
                    progress = {
                        side = "left",
                        index = 5,
                    },

                    -- Right
                    clock = {
                        side = "right",
                        index = 1,
                        enabled = -1
                    },
                    mail = {
                        side = "right",
                        index = 2,
                    },
                    bags = {
                        side = "right",
                        index = 3,
                    },
                    spec = {
                        side = "right",
                        index = 4,
                    },
                    currency = {
                        side = "right",
                        index = 5,
                    },
                    netstats = {
                        showIcon = false,
                        side = "right",
                        index = 6,
                    },
                },
            },
        },
    })
    db = self.db.profile
    --[[
    dbc = self.db.char
    dbg = self.db.global
    ndbc = RealUI.db.char
    ndbg = RealUI.db.global
    ]]

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function Infobar:OnEnable()
    LDB.RegisterCallback(self, "LibDataBroker_DataObjectCreated")
    LDB.RegisterCallback(self, "LibDataBroker_AttributeChanged")

    self:CreateBar()
    self:CreateBlocks()

    for name, dataObj in LDB:DataObjectIterator() do
        self:LibDataBroker_DataObjectCreated("OnEnable", name, dataObj, true)
    end

    -- Adjust ActionBar positions
    local ndb = RealUI.db.profile
    ndb.positions[RealUI.cLayout]["ActionBarsBotY"] = BAR_HEIGHT -- self.frame:GetTop()
end
