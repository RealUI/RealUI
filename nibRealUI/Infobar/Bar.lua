local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs error assert min type
-- luacheck: globals tinsert tremove wipe sort unpack

-- Libs --
local LDB = _G.LibStub("LibDataBroker-1.1")
local qTip = _G.LibStub("LibQTip-1.0")
local Aurora = _G.Aurora
local Base = Aurora.Base

-- RealUI --
local RealUI = private.RealUI
local Scale = RealUI.Scale
local db, ndb

local MODNAME = "Infobar"
local Infobar = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")
local MenuFrame = RealUI:GetModule("MenuFrame")

Infobar.LDB = LDB
Infobar.locked = true

local MOVING_BLOCK
local blocksByData = {}
local orderedBlocks = {}
local BAR_HEIGHT = 16
local blockFont

local function IsCombatBlocked()
    return _G.InCombatLockdown() and not db.combatTips
end

local infobarTooltip = _G.CreateFrame("GameTooltip", "RealUI_InfobarTooltip", _G.UIParent, "GameTooltipTemplate")
Aurora.Skin.GameTooltipTemplate(infobarTooltip)

----------------------
-- Block Management --
----------------------
local function PrepareTooltip(tooltip, block)
    Infobar:debug("PrepareTooltip", tooltip, block and block.name)
    if tooltip and block then
        --RealUI.RegisterModdedFrame(tooltip)
        tooltip:ClearAllPoints()
        if tooltip.SetOwner then
            tooltip:SetOwner(block, ("ANCHOR_NONE"))
        end
        local anchor = block.side:upper()
        Infobar:debug("SetPoint", anchor)
        Scale.Point(tooltip, ("BOTTOM"..anchor), block, ("TOP"..anchor))
    end
end

local BlockMixin = {}
function BlockMixin:OnEnter()
    --Infobar:debug("OnEnter", self.name)
    --self.highlight:Show()

    if IsCombatBlocked() then return end
    local dataObj  = self.dataObj

    MenuFrame:CloseAll()
    if dataObj.tooltip then
        PrepareTooltip(dataObj.tooltip, self)
        if dataObj.tooltiptext then
            dataObj.tooltip:SetText(dataObj.tooltiptext)
        end
        dataObj.tooltip:Show()

    elseif dataObj.OnEnter then
        dataObj.OnEnter(self)

    elseif dataObj.OnTooltipShow then
        PrepareTooltip(infobarTooltip, self)
        dataObj.OnTooltipShow(infobarTooltip)
        infobarTooltip:Show()

    elseif dataObj.tooltiptext then
        PrepareTooltip(infobarTooltip, self)
        infobarTooltip:SetText(dataObj.tooltiptext)
        infobarTooltip:Show()
    end
end

function BlockMixin:OnLeave()
    Infobar:debug("OnLeave", self.name)
    --self.highlight:Hide()

    if IsCombatBlocked() then return end
    local dataObj  = self.dataObj

    if dataObj.OnTooltipShow then
        infobarTooltip:Hide()
    end

    if dataObj.OnLeave then
        dataObj.OnLeave(self)
    elseif dataObj.tooltip then
        dataObj.tooltip:Hide()
    else
        infobarTooltip:Hide()
    end
end

function BlockMixin:OnClick(...)
    Infobar:debug("OnClick", self.name, ...)
    if IsCombatBlocked() then return end
    if self.dataObj.OnClick then
        Infobar:debug("Send OnClick")
        self.dataObj.OnClick(self, ...)
    end
end

function BlockMixin:OnDragStart(button)
    Infobar:debug("OnDragStart", self.name, button)
    local dock = self:GetNearestDock()
    dock:DetatchBlock(self)

    local x, y = self:GetCenter()
    x = x - (self:GetWidth()/Scale.Value(2))
    y = y - (self:GetHeight()/Scale.Value(2))
    self:ClearAllPoints()
    Scale.RawSetPoint(self, "TOPLEFT", "UIParent", "BOTTOMLEFT", x, y)
    self:SetMovable(true)
    self:StartMoving()
    MOVING_BLOCK = self
end

function BlockMixin:OnDragStop(button)
    Infobar:debug("OnDragStop", self.name, button)
    self:StopMovingOrSizing()

    local dock = self:GetNearestDock()
    dock:AtatchBlock(self)
    self:SavePosition()

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
        local dock = self:GetNearestDock()
        if dock:IsMouseOver(BAR_HEIGHT * 4, 0, 0, 0) then
            local insert = dock:GetInsertIndex()
            if self.index ~= insert then
                dock:MoveBlock(self, insert)
            end
        end

        if not _G.IsMouseButtonDown(self.dragButton) then
            self:OnDragStop(self.dragButton)
            self.dragButton = nil
            MOVING_BLOCK = nil
        end
    end
end

function BlockMixin:GetNearestDock()
    local xOfs =  self:GetCenter()
    local uiCenter = Infobar.frame:GetWidth() / 2

    local oldSide, newSide = self.side, "left"
    if xOfs > uiCenter then
        newSide = "right"
    end

    if oldSide ~= newSide then
        Infobar.frame[oldSide]:RemoveBlock(self)
        Infobar.frame[newSide]:AddBlock(self)
    end

    return Infobar.frame[newSide]
end

function BlockMixin:SavePosition()
    if not self.dataObj then return end
    local blockInfo = Infobar:GetBlockInfo(self.name, self.dataObj)

    blockInfo.side = self.side
    blockInfo.index = self.index
end

function BlockMixin:RestorePosition()
    local blockInfo = Infobar:GetBlockInfo(self.name, self.dataObj)

    local dock = self:GetNearestDock()
    dock:AddBlock(self, blockInfo.index)
end

function BlockMixin:AdjustElements(blockInfo)
    local font, size, outline = blockFont.font, Scale.Value(blockFont.size), blockFont.outline
    local space = 2
    local width = space

    Scale.Point(self.text, "RIGHT", -space, 0)
    self.text:SetFont(font, size, outline)
    width = Scale.Value(width + space) + self.text:GetStringWidth()

    if self.icon then
        if blockInfo.showIcon then
            Scale.Point(self.icon, "LEFT", space, 0)
            self.icon:Show()
            local iconWidth
            if self.icon.isFont then
                local iconFont = self.dataObj.iconFont
                self.icon:SetFont(iconFont.font, size, outline)
                iconWidth = self.icon:GetStringWidth() -- Scale.Value(space)
            else
                self.icon:SetSize(size, size)
                iconWidth = size
            end

            self.checkWidth = iconWidth < 1
            width = width + Scale.Value(space) + iconWidth
            Infobar:debug("icon", width)
        else
            self.icon:Hide()
        end
    end

    if blockInfo.showLabel then
        if self.icon and blockInfo.showIcon then
            self.label:SetPoint("LEFT", self.icon, "RIGHT", 0, 0)
        else
            Scale.Point(self.label, "LEFT", space, 0)
        end

        self.label:SetFont(font, size, outline)
        self.label:Show()
        width = width + Scale.Value(space) + self.label:GetStringWidth()
        Infobar:debug("label", self.dataObj.label, width)
    else
        self.label:Hide()
    end

    self:SetWidth(width)
    Scale.Height(self, BAR_HEIGHT)
end

local function SortBlocks(block1, block2)
    local name1 = block1.dataObj.name or block1.name
    local name2 = block2.dataObj.name or block2.name
    return name1 < name2
end
local function CreateNewBlock(name, dataObj, blockInfo)
    Infobar:debug("CreateNewBlock", name, dataObj)
    local block = _G.Mixin(_G.CreateFrame("Button", nil, Infobar.frame), BlockMixin)
    blocksByData[dataObj] = block
    block.dataObj = dataObj
    block.name = name
    tinsert(orderedBlocks, block)
    sort(orderedBlocks, SortBlocks)

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
            icon:SetFont(dataObj.iconFont.font, size, dataObj.iconFont.outline)
            icon:SetText(dataObj.icon)
            if dataObj.iconR then
                icon:SetTextColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
            end
            icon.isFont = true
        else
            icon = block:CreateTexture(nil, "ARTWORK")
            icon:SetTexture(dataObj.icon)
            Scale.Size(icon, size, size)
            if dataObj.iconR then
                icon:SetVertexColor(dataObj.iconR, dataObj.iconG, dataObj.iconB)
            end
            if dataObj.iconCoords then
                icon:SetTexCoord(unpack(dataObj.iconCoords))
            end
        end
        block.icon = icon
    end

    local label = block:CreateFontString(nil, "ARTWORK")
    label:SetFont(font, size, outline)
    label:SetTextColor(1, 1, 1)
    label:SetText(dataObj.label or dataObj.name)
    block.label = label

    local highlight = block:CreateTexture(nil, "ARTWORK")
    highlight:SetColorTexture(RealUI.charInfo.class.color:GetRGB())
    Scale.Height(highlight, 1)
    Scale.Point(highlight, "BOTTOMLEFT")
    Scale.Point(highlight, "BOTTOMRIGHT")
    highlight:Hide()
    block:SetHighlightTexture(highlight)
    block.highlight = highlight

    do -- pulseAnim
        local pulse = block:CreateTexture(nil, "ARTWORK")
        pulse:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Tab-Highlight-yellow]])
        pulse:SetBlendMode("ADD")
        pulse:SetAlpha(0)
        Scale.Point(pulse, "TOPLEFT")
        Scale.Point(pulse, "BOTTOMRIGHT")

        local pulseAnim = block:CreateAnimationGroup()
        pulseAnim:SetToFinalAlpha(true)
        pulseAnim:SetLooping("REPEAT")
        block.pulseAnim = pulseAnim

        local fadeIn = pulseAnim:CreateAnimation("Alpha")
        fadeIn:SetTarget(pulse)
        fadeIn:SetFromAlpha(0)
        fadeIn:SetToAlpha(1)
        fadeIn:SetDuration(1)
        fadeIn:SetOrder(1)

        local fadeOut = pulseAnim:CreateAnimation("Alpha")
        fadeOut:SetTarget(pulse)
        fadeOut:SetFromAlpha(1)
        fadeOut:SetToAlpha(0)
        fadeOut:SetDuration(1)
        fadeOut:SetOrder(2)
    end

    block:SetScript("OnEnter", block.OnEnter)
    block:SetScript("OnLeave", block.OnLeave)

    block:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    block:SetScript("OnClick", block.OnClick)
    block:SetScript("OnDragStart", block.OnDragStart)

    block:SetScript("OnUpdate", block.OnUpdate)
    block:AdjustElements(blockInfo)
    block:SetClampedToScreen(true)
    block:SetFrameLevel(Infobar.frame:GetFrameLevel() + 2)
    return block
end

function Infobar:AddBlock(name, dataObj, blockInfo)
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

function Infobar:ShowBlock(name, dataObj, blockInfo)
    self:debug("Infobar:HideBlock", name, blockInfo.side, blockInfo.index)
    local block, dock = blocksByData[dataObj], Infobar.frame[blockInfo.side]
    for i = 1, #dock.ADJUSTED_BLOCKS do
        if block == dock.ADJUSTED_BLOCKS[i].block then
            dock.ADJUSTED_BLOCKS[i].isHidden = false
            break
        end
    end

    self:AddBlock(name, dataObj, blockInfo)
end
function Infobar:HideBlock(name, dataObj, blockInfo)
    local block, position = blocksByData[dataObj], blockInfo.index
    local dock, found = Infobar.frame[blockInfo.side]
    for i = 1, #dock.ADJUSTED_BLOCKS do
        if block == dock.ADJUSTED_BLOCKS[i].block then
            dock.ADJUSTED_BLOCKS[i].isHidden = true
            found = true
            break
        end
    end

    if not found then
        local i = 1
        while i <= #dock.ADJUSTED_BLOCKS do
            if position < dock.ADJUSTED_BLOCKS[i].position then
                break
            end
            i = i + 1
        end
        tinsert(dock.ADJUSTED_BLOCKS, i, {
            position = position, -- where the block should be
            index = #dock.DOCKED_BLOCKS, -- where the block is
            isHidden = true,
            block = block
        })
    end
    self:RemoveBlock(name, dataObj, blockInfo)
end

function Infobar:LibDataBroker_DataObjectCreated(event, name, dataObj, noupdate)
    if dataObj.type == "data source" or dataObj.type == "RealUI" then
        local blockInfo = self:GetBlockInfo(name, dataObj)
        if blockInfo and blockInfo.enabled then
            self:AddBlock(name, dataObj, blockInfo)
        else
            local block = {
                dataObj = dataObj,
                name = name,
                isFake = true
            }
            blocksByData[dataObj] = block
            tinsert(orderedBlocks, block)
            sort(orderedBlocks, SortBlocks)
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
                    block.icon:SetTexCoord(unpack(dataObj.iconCoords))
                end
            end
        end
        block:AdjustElements(blockInfo)
    end
end

function Infobar:IterateBlocks()
    return next, orderedBlocks
end

---------------------
-- Dock Management --
---------------------
local DockMixin = {}
function DockMixin:OnLoad()
    Scale.Height(self, BAR_HEIGHT)
    self.anchor = "BOTTOM" .. self.side:upper()
    self.anchorAlt = "BOTTOM" .. self.alt:upper()
    Scale.Point(self, self.anchor)
    Scale.Point(self, self.anchorAlt, Infobar.frame, "BOTTOM")

    self.insertHighlight = self:CreateTexture(nil, "ARTWORK")
    Scale.Size(self.insertHighlight, 1, BAR_HEIGHT)
    self.insertHighlight:SetColorTexture(1, 1, 1)

    local spacerBlock = _G.Mixin(_G.CreateFrame("Button", nil, self), BlockMixin)
    spacerBlock.name = "spacer"
    Scale.Height(spacerBlock, BAR_HEIGHT)
    self.spacerBlock = spacerBlock

    local bg = spacerBlock:CreateTexture(nil, "BACKGROUND")
    bg:SetColorTexture(1, 1, 0, 0.5)
    bg:SetAllPoints()
    spacerBlock.bg = bg

    self.DOCKED_BLOCKS = {}
    self.ADJUSTED_BLOCKS = {} -- blocks that are not in thier saved position
    self.isDirty = true    --You dirty, dirty frame
end

function DockMixin:SetPrimary(block)
    self.primary = block
    self:AddBlock(block, 1)
end

function DockMixin:AddBlock(block, position)
    if ( not self.primary ) then
        error("Need a primary block before another can be added.")
    end

    if ( self:HasDockedBlock(block) ) then
        return --We're already docked...
    end

    self.isDirty = true
    block.isDocked = true
    block.side = self.side

    position = position or (#self.DOCKED_BLOCKS + 1)
    local adjustedPosition = position
    for i = 1, #self.ADJUSTED_BLOCKS do
        if adjustedPosition < self.ADJUSTED_BLOCKS[i].position then
            adjustedPosition = self.ADJUSTED_BLOCKS[i].index
            break
        end
    end

    if ( adjustedPosition and adjustedPosition <= #self.DOCKED_BLOCKS + 1 ) then
        assert(adjustedPosition ~= 1 or block == self.primary, adjustedPosition)
        tinsert(self.DOCKED_BLOCKS, adjustedPosition, block)
    else
        tinsert(self.DOCKED_BLOCKS, block)
    end

    if position > #self.DOCKED_BLOCKS or adjustedPosition ~= position then
        -- the block is not where is should be, save both for future reference
        local i = 1
        while i <= #self.ADJUSTED_BLOCKS do
            if position < self.ADJUSTED_BLOCKS[i].position then
                break
            end
            i = i + 1
        end
        tinsert(self.ADJUSTED_BLOCKS, i, {
            position = position, -- where the block should be
            index = #self.DOCKED_BLOCKS, -- where the block is
            block = block
        })
    end

    if ( self.primary ~= block ) then
        block:ClearAllPoints()
        block:SetMovable(false)
        block:SetResizable(false)
    end

    if block == MOVING_BLOCK then
        self.spacerBlock:Show()
    end

    self:UpdateBlocks()
end

function DockMixin:RemoveBlock(block)
    if block == self.primary or #self.DOCKED_BLOCKS == 1 then return end

    self.isDirty = true
    _G.tDeleteItem(self.DOCKED_BLOCKS, block)
    block.isDocked = false

    if block == MOVING_BLOCK then
        self.spacerBlock:Hide()
    end

    block:Show()
    self:UpdateBlocks()
end

function DockMixin:HasDockedBlock(block)
    return _G.tContains(self.DOCKED_BLOCKS, block)
end

function DockMixin:GetBlockAtIndex(index)
    local block = self.DOCKED_BLOCKS[index]
    if block.isDetatched then
        return self.spacerBlock, true
    else
        return block
    end
end

function DockMixin:DetatchBlock(block)
    block.isDetatched = true
    self.spacerBlock:Show()
    self:UpdateBlocks(true)
end

function DockMixin:AtatchBlock(block)
    block.isDetatched = nil
    self.spacerBlock:Hide()
    self:UpdateBlocks(true)
end

function DockMixin:MoveBlock(block, newIndex)
    self:RemoveBlock(block)
    self:AddBlock(block, newIndex)
end

local toBeRemoved = {}
function DockMixin:UpdateBlocks(forceUpdate)
    if ( not self.isDirty and not forceUpdate ) then
        --No changes have been made since the last update.
        return
    end

    local lastBlock
    for index, block in ipairs(self.DOCKED_BLOCKS) do
        if forceUpdate then
            block:AdjustElements(Infobar:GetBlockInfo(block.name, block.dataObj))
        end

        wipe(toBeRemoved)
        local indexAdjust = 0
        for i = 1, #self.ADJUSTED_BLOCKS do
            if self.ADJUSTED_BLOCKS[i].isHidden and index >= self.ADJUSTED_BLOCKS[i].position then
                indexAdjust = indexAdjust + 1
            end

            if block == self.ADJUSTED_BLOCKS[i].block then
                if index == self.ADJUSTED_BLOCKS[i].position then
                    -- the block is now where is should be, remove it
                    tinsert(toBeRemoved, i)
                else
                    -- the block is *still* not where is should be, update it's index
                    self.ADJUSTED_BLOCKS[i].index = index
                end
            end
        end
        for i = 1, #toBeRemoved do
            tremove(self.ADJUSTED_BLOCKS, toBeRemoved[i])
        end
        block.index = index + indexAdjust
        block:SavePosition()
        block:Show()

        if block.isDetatched then
            self.spacerBlock:SetWidth(block:GetWidth())
            block = self.spacerBlock
        end

        block:ClearAllPoints()
        if lastBlock then
            local xOfs = self.side == "left" and db.blockGap or -db.blockGap
            Scale.Point(block, self.anchor, lastBlock, self.anchorAlt, xOfs, 0)
        else
            Scale.Point(block, self.anchor)
        end
        lastBlock = block
    end

    self.isDirty = false

    return true
end

function DockMixin:GetInsertIndex()
    local moveX = MOVING_BLOCK:GetCenter()
    local insertIndex, detachedIndex
    for index = 2, #self.DOCKED_BLOCKS do
        local block, isDetatched = self:GetBlockAtIndex(index)
        local center = block:GetCenter()
        if isDetatched then
            detachedIndex = index
        end

        local width = min(block:GetWidth(), MOVING_BLOCK:GetWidth()) / 2
        local left, right = center - width, center + width
        if moveX > left and moveX < right then
            insertIndex = index
        end
    end
    insertIndex = (insertIndex or detachedIndex) or #self.DOCKED_BLOCKS

    --We aren't to the left of anything, so we're going into the far-right position.
    return insertIndex, insertIndex == self.DOCKED_BLOCKS
end

--------------------
-- Bar Management --
--------------------
function Infobar:CreateBar()
    local frame = _G.CreateFrame("Frame", "RealUI_Infobar", _G.UIParent)
    frame:SetPoint("BOTTOMLEFT", _G.UIParent)
    frame:SetPoint("BOTTOMRIGHT", _G.UIParent)
    Scale.Size(frame, RealUI.GetInterfaceSize(), BAR_HEIGHT)
    frame:SetFrameStrata("LOW")
    frame:SetFrameLevel(0)
    RealUI.RegisterModdedFrame(frame, function(this)
        Scale.Size(this, RealUI.GetInterfaceSize(), BAR_HEIGHT)
        for index, block in Infobar:IterateBlocks() do
            local blockInfo = Infobar:GetBlockInfo(block.name)
            if block.AdjustElements then block:AdjustElements(blockInfo) end
        end

        ndb.positions[1]["ActionBarsBotY"] = Scale.Value(BAR_HEIGHT)
        ndb.positions[2]["ActionBarsBotY"] = Scale.Value(BAR_HEIGHT)
    end)

    -- Stripes
    Base.SetBackdrop(frame, Aurora.Color.frame, db.bgAlpha)
    frame:SetBackdropBorderColor(Aurora.Color.frame, db.bgAlpha)
    local tex = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
    tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true, true)
    tex:SetAlpha(db.bgAlpha * 0.6)
    tex:SetAllPoints()
    tex:SetHorizTile(true)
    tex:SetVertTile(true)
    tex:SetBlendMode("ADD")
    frame.tex = tex

    -- Watch bars
    local watch = {}
    watch.main = _G.CreateFrame("StatusBar", nil, frame)
    watch.main:SetStatusBarTexture(RealUI.textures.plain)
    watch.main:SetAllPoints()
    watch.main:Hide()

    local mainBar = watch.main:GetStatusBarTexture()
    watch.main.rested = watch.main:CreateTexture(nil, "ARTWORK")
    Scale.Point(watch.main.rested, "TOPLEFT", mainBar, "TOPRIGHT")
    watch.main.rested:Hide()
    for i = 1, 2 do
        local bar = _G.CreateFrame("StatusBar", nil, frame)
        bar:SetStatusBarTexture(RealUI.textures.plain)
        Scale.Height(bar, 1)
        bar:SetFrameLevel(watch.main:GetFrameLevel() + 1)
        bar:Hide()

        local bg = bar:CreateTexture(nil, "BACKGROUND")
        bg:SetColorTexture(0, 0, 0)
        Scale.Point(bg, "TOPLEFT", bar, -1, 1)
        Scale.Point(bg, "BOTTOMRIGHT", bar, 1, -1)
        bar.bg = bg

        watch[i] = bar
    end
    Scale.Point(watch[1], "BOTTOMLEFT", watch.main, "TOPLEFT", 0, -1)
    Scale.Point(watch[1], "BOTTOMRIGHT", watch.main, "TOPRIGHT", 0, -1)

    Scale.Point(watch[2], "BOTTOMLEFT", watch.main, "TOPLEFT", 0, 1)
    Scale.Point(watch[2], "BOTTOMRIGHT", watch.main, "TOPRIGHT", 0, 1)

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

function Infobar:SettingsUpdate(setting, block)
    if setting == "statusBar" then
        local watch = self.frame.watch
        watch.main:SetShown(db.showBars)
        for i = 1, 2 do
            watch[i]:SetShown(db.showBars)
        end
        block:OnEvent("SettingsUpdate")
    elseif setting == "bgAlpha" then
        self.frame:SetBackdropColor(Aurora.Color.frame, db.bgAlpha)
        self.frame:SetBackdropBorderColor(Aurora.Color.frame, db.bgAlpha)
        self.frame.tex:SetAlpha(db.bgAlpha * 0.6)
        self.frame.watch:UpdateColors()

        local outline = self:GetFontOutline()
        if blockFont.outline ~= outline then
            blockFont.outline = outline
            self.frame.left:UpdateBlocks(true)
            self.frame.right:UpdateBlocks(true)
        end
    else
        self.frame.left:UpdateBlocks(true)
        self.frame.right:UpdateBlocks(true)
    end
end

function Infobar:GetBlockInfo(dataobjectname)
    local objType = type(dataobjectname)
    assert(objType == "string" or objType == "table", "\"dataobjectname\" must be a string or a table, got "..objType)

    local name, dataObj
    if objType == "table" then
        dataObj = dataobjectname
        name = LDB:GetNameByDataObject(dataObj)
        assert(dataObj.type and name, "table must be an LDB data object.")
    elseif objType == "string" then
        name = dataobjectname
        dataObj = LDB:GetDataObjectByName(name)
        assert(dataObj and dataObj.type, "string must be the name of an LDB data object.")
    end

    if dataObj.type == "RealUI" then
        self:debug("RealUI object", name)
        return db.blocks.realui[name]
    elseif dataObj.type == "data source" then
        self:debug("Other object", name)
        for k, v in LDB:pairs(dataObj) do
            self:debug(k, v)
        end
        return db.blocks.others[name]
    end
end
--------------------
-- Initialization --
--------------------
function Infobar:RefreshMod()
    db = self.db.profile
    self:SettingsUpdate()
end

function Infobar:OnInitialize()
    local specgear = {}
    for specIndex = 1, #RealUI.charInfo.specs do
        specgear[specIndex] = -1
    end
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        char = {
            progressState = "xp",
            currencyState = "money",
            specgear = specgear,
        },
        profile = {
            bgAlpha = 0.5,
            showBars = true,
            combatTips = false,
            blockGap = 3,
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

    function self:GetFontOutline(alpha)
        alpha = alpha or db.bgAlpha
        if alpha > 0.2 then
            return ""
        else
            return "OUTLINE"
        end
    end

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function Infobar:OnEnable()
    LDB.RegisterCallback(self, "LibDataBroker_DataObjectCreated")
    LDB.RegisterCallback(self, "LibDataBroker_AttributeChanged")

    blockFont = {
        font = RealUI.GetOptions("Skins").profile.fonts.chat.path,
        size = RealUI.Round(BAR_HEIGHT * 0.6),
        outline = self:GetFontOutline()
    }

    self:CreateBar()
    self:CreateBlocks()

    for name, dataObj in LDB:DataObjectIterator() do
        if dataObj.type == "data source" then
            self:LibDataBroker_DataObjectCreated("OnEnable", name, dataObj, true)
        end
    end

    -- Adjust ActionBar positions
    ndb = RealUI.db.profile
    ndb.positions[1]["ActionBarsBotY"] = Scale.Value(BAR_HEIGHT)
    ndb.positions[2]["ActionBarsBotY"] = Scale.Value(BAR_HEIGHT)
end
