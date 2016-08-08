-- Code based on: sGroupLoot by Shantalya, modified by Alza.
--                Butsu by Haste, heavily modified by Alza
--[[-------------------------------------------------------------------------
  Copyright (c) 2007-2008, Trond A Ekseth
  All rights reserved.

  Redistribution and use in source and binary forms, with or without
  modification, are permitted provided that the following conditions are
  met:

      * Redistributions of source code must retain the above copyright
        notice, this list of conditions and the following disclaimer.
      * Redistributions in binary form must reproduce the above
        copyright notice, this list of conditions and the following
        disclaimer in the documentation and/or other materials provided
        with the distribution.
      * Neither the name of Butsu nor the names of its contributors may
        be used to endorse or promote products derived from this
        software without specific prior written permission.

  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
  "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
  LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
  A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
  OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
  SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
  LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
  DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
  THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
  (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
  OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
---------------------------------------------------------------------------]]
local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "Loot"
local Loot = RealUI:NewModule(MODNAME, "AceEvent-3.0")

--------------------
---- GROUP LOOT ----
--------------------
local GroupLootIconSize = 32
local grouplootlist, grouplootframes = {}, {}
local RealUIGroupLootFrame

local function GroupLootOnEvent(self, event, rollId)
    _G.tinsert(grouplootlist, {rollId = rollId})
    Loot:UpdateGroupLoot()
end

local function GroupLootFrameOnEvent(self, event, ...)
    if event == "CANCEL_LOOT_ROLL" then
        local rollId = ...
        if (self.rollId and rollId==self.rollId) then
            for index, value in next, grouplootlist do
                if(self.rollId==value.rollId) then
                    _G.tremove(grouplootlist, index)
                    break
                end
            end
            _G.StaticPopup_Hide("CONFIRM_LOOT_ROLL", self.rollId)
            self.rollId = nil
            Loot:UpdateGroupLoot()
        end
    elseif event == "MODIFIER_STATE_CHANGED" then
        local key, state = ...
        if (key == "LSHIFT" or key == "RSHIFT") and not _G.GameTooltip:IsEquippedItem() then
            if state == 1 then
                _G.GameTooltip_ShowCompareItem()
            else
                _G.ShoppingTooltip1:Hide()
                _G.ShoppingTooltip2:Hide()
            end
        end
    end
end

local function GroupLootFrameOnClick(self)
    _G.HandleModifiedItemClick(self.rollLink)
end

local function GroupLootFrameOnEnter(self)
    if(not self.rollId) then return end
    _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
    _G.GameTooltip:SetLootRollItem(self.rollId)
    if _G.IsShiftKeyDown() then _G.GameTooltip_ShowCompareItem() end
    _G.CursorUpdate(self)
end

local function GroupLootFrameOnLeave(self)
    _G.GameTooltip:Hide()
    _G.ResetCursor()
end

local function GroupLootButtonOnClick(self, button)
    _G.RollOnLoot(self:GetParent().rollId, self.type)
end

local function GroupLootSortFunc(a, b)
    return a.rollId < b.rollId
end

function Loot:UpdateGroupLoot()
    _G.sort(grouplootlist, GroupLootSortFunc)
    for index, value in next, grouplootframes do value:Hide() end

    local frame
    for index, value in next, grouplootlist do
        frame = grouplootframes[index]
        if(not frame) then
            frame = _G.CreateFrame("Frame", "RealUI_GroupLootFrame"..index, _G.UIParent)
            frame:EnableMouse(true)
            frame:SetWidth(240)
            frame:SetHeight(24)
            frame:SetPoint("BOTTOM", RealUIGroupLootFrame, 0, ((index-1)*(GroupLootIconSize+3)))
            frame:RegisterEvent("CANCEL_LOOT_ROLL")
            frame:RegisterEvent("MODIFIER_STATE_CHANGED")
            frame:SetScript("OnEvent", GroupLootFrameOnEvent)
            frame:SetScript("OnMouseUp", GroupLootFrameOnClick)
            frame:SetScript("OnLeave", GroupLootFrameOnLeave)
            frame:SetScript("OnEnter", GroupLootFrameOnEnter)

            RealUI:CreateBD(frame)

            frame.pass = _G.CreateFrame("Button", nil, frame)
            frame.pass.type = 0
            frame.pass.roll = "pass"
            frame.pass:SetWidth(28)
            frame.pass:SetHeight(28)
            frame.pass:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Up")
            frame.pass:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Pass-Down")
            frame.pass:SetPoint("RIGHT", 0, 1)
            frame.pass:SetScript("OnClick", GroupLootButtonOnClick)
            
            frame.greed = _G.CreateFrame("Button", nil, frame)
            frame.greed.type = 2
            frame.greed.roll = "greed"
            frame.greed:SetWidth(28)
            frame.greed:SetHeight(28)
            frame.greed:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Up")
            frame.greed:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Down")
            frame.greed:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Coin-Highlight")
            frame.greed:SetPoint("RIGHT", frame.pass, "LEFT", -1, -4)
            frame.greed:SetScript("OnClick", GroupLootButtonOnClick)
            
            frame.disenchant = _G.CreateFrame("Button", nil, frame)
            frame.disenchant.type = 3
            frame.disenchant.roll = "disenchant"
            frame.disenchant:SetWidth(28)
            frame.disenchant:SetHeight(28)
            frame.disenchant:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-DE-Up")
            frame.disenchant:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-DE-Down")
            frame.disenchant:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-DE-Highlight")
            frame.disenchant:SetPoint("RIGHT", frame.greed, "LEFT", -1, 2)
            frame.disenchant:SetScript("OnClick", GroupLootButtonOnClick)

            frame.need = _G.CreateFrame("Button", nil, frame)
            frame.need.type = 1
            frame.need.roll = "need"
            frame.need:SetWidth(28)
            frame.need:SetHeight(28)
            frame.need:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
            frame.need:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Down")
            frame.need:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")
            frame.need:SetPoint("RIGHT", frame.disenchant, "LEFT", -1, 0)
            frame.need:SetScript("OnClick", GroupLootButtonOnClick)
            
            frame.text = RealUI:CreateFS(frame, "LEFT")
            frame.text:SetPoint("LEFT", 2, 0)
            frame.text:SetPoint("RIGHT", frame.need, "LEFT")

            local iconFrame = _G.CreateFrame("Frame", nil, frame)
            iconFrame:SetHeight(GroupLootIconSize)
            iconFrame:SetWidth(GroupLootIconSize)
            iconFrame:ClearAllPoints()
            iconFrame:SetPoint("RIGHT", frame, "LEFT", -2, 0)

            local icon = iconFrame:CreateTexture(nil, "OVERLAY")
            icon:SetPoint("TOPLEFT")
            icon:SetPoint("BOTTOMRIGHT")
            icon:SetTexCoord(.08, .92, .08, .92)
            frame.icon = icon

            RealUI:CreateBG(icon)

            _G.tinsert(grouplootframes, frame)
        end

        local texture, name, _, quality, _, Needable, Greedable, Disenchantable = _G.GetLootRollItemInfo(value.rollId)

        if Disenchantable then frame.disenchant:Enable() else frame.disenchant:Disable() end
        if Needable then frame.need:Enable() else frame.need:Disable() end
        if Greedable then frame.greed:Enable() else frame.greed:Disable() end

        frame.disenchant:GetNormalTexture():SetDesaturated(not Disenchantable);
        frame.need:GetNormalTexture():SetDesaturated(not Needable);
        frame.greed:GetNormalTexture():SetDesaturated(not Greedable);

        frame.text:SetText(_G.ITEM_QUALITY_COLORS[quality].hex..name)

        frame.icon:SetTexture(texture) 

        frame.rollId = value.rollId
        frame.rollLink = _G.GetLootRollItemLink(value.rollId)

        frame:Show()
    end
end

function Loot:GroupLootPosition()
    RealUIGroupLootFrame:ClearAllPoints()
    RealUIGroupLootFrame:SetPoint("LEFT", db.roll.horizontal + 41, db.roll.vertical)
end

function Loot:InitializeGroupLoot()
    RealUIGroupLootFrame = _G.CreateFrame("Frame", "RealUI_GroupLoot", _G.UIParent)
    RealUIGroupLootFrame:RegisterEvent("START_LOOT_ROLL")
    RealUIGroupLootFrame:SetScript("OnEvent", GroupLootOnEvent)
    RealUIGroupLootFrame:SetFrameStrata("HIGH")
    RealUIGroupLootFrame:SetWidth(db.grouplootwidth)
    RealUIGroupLootFrame:SetHeight(24)
    self:GroupLootPosition()
    
    for i = 1,4 do
        local glf = _G["GroupLootFrame"..i]
        glf:UnregisterAllEvents()
        glf:Hide()
        glf:SetScript("OnShow", function(frame) frame:Hide() end)
    end
end

--------------
---- LOOT ----
--------------
local LootIconSize = 32

local RealUILootFrame = _G.CreateFrame("Button", "RealUI_Loot", _G.UIParent)
RealUILootFrame:SetFrameStrata("HIGH")
RealUILootFrame:SetToplevel(true)
RealUILootFrame:SetHeight(64)

RealUILootFrame.close = _G.CreateFrame("Button", "RealUI_Loot_Close", RealUILootFrame, "UIPanelCloseButton")
--RealUILootFrame.close:SetPoint("TOPRIGHT", RealUILootFrame, "TOPRIGHT", 8, 20)
RealUILootFrame.slots = {}

local function LootOnEnter(self)
    --print("LootOnEnter: ")
    local slot = self:GetID()
    --print("GetLootSlotType Enter: "..tostring(GetLootSlotType(slot)))
    --print("GetLootSlotType(slot) == 1 is "..tostring((GetLootSlotType(slot) == 1)))
    if(_G.GetLootSlotType(slot) == 1) then
        _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        _G.GameTooltip:SetLootItem(slot)
        _G.CursorUpdate(self)
    end
    self.bg:SetBackdropColor(0.15, 0.15, 0.15, RealUI.media.background[4])
end

local LootOnLeave = function(self)
    --print("LootOnLeave: ")
    _G.GameTooltip:Hide()
    _G.ResetCursor()
    self.bg:SetBackdropColor(0, 0, 0, RealUI.media.background[4])
end

local LootOnClick = function(self)
    --print("LootOnClick: ")
    --print("IsModifiedClick: "..tostring(IsModifiedClick()))
    if(_G.IsModifiedClick()) then
        _G.HandleModifiedItemClick(_G.GetLootSlotLink(self:GetID()))
    else
        _G.StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
        _G.LootFrame.selectedLootButton = self
        _G.LootFrame.selectedSlot = self:GetID()
        _G.LootFrame.selectedQuality = self.quality
        _G.LootFrame.selectedItemName = self.name:GetText()
        _G.LootFrame.selectedTexture = self.icon:GetTexture()
        
        _G.LootSlot(self:GetID())
    end
end

local LootOnUpdate = function(self)
    --print("LootOnUpdate: ")
    if(_G.GameTooltip:IsOwned(self)) then
        _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        _G.GameTooltip:SetLootItem(self:GetID())
        _G.CursorOnUpdate(self)
    end
end

local createSlot = function(id)
    local frame = _G.CreateFrame("Button", "ButsuSlot"..id, RealUILootFrame)
    frame:SetPoint("TOP", RealUILootFrame, 0, -((id-1)*(LootIconSize+1)))
    frame:SetPoint("RIGHT")
    frame:SetPoint("LEFT")
    frame:SetHeight(24)
    --frame:SetFrameStrata("HIGH")
    --frame:SetFrameLevel(20)
    frame:SetID(id)
    RealUILootFrame.slots[id] = frame

    local bg = _G.CreateFrame("Frame", nil, frame)
    bg:SetPoint("TOPLEFT", frame, -1, 1)
    bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
    bg:SetFrameLevel(frame:GetFrameLevel()-1)
    RealUI:CreateBD(bg)
    
    frame.bg = bg

    frame:SetScript("OnClick", LootOnClick)
    frame:SetScript("OnEnter", LootOnEnter)
    frame:SetScript("OnLeave", LootOnLeave)
    frame:SetScript("OnUpdate", LootOnUpdate)

    local iconFrame = _G.CreateFrame("Frame", nil, frame)
    iconFrame:SetHeight(LootIconSize)
    iconFrame:SetWidth(LootIconSize)
    iconFrame:SetFrameStrata("HIGH")
    iconFrame:SetFrameLevel(20)
    iconFrame:ClearAllPoints()
    iconFrame:SetPoint("RIGHT", frame, "LEFT", -2, 0)

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetTexCoord(.08, .92, .08, .92)
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    frame.icon = icon

    RealUI:CreateBG(icon)

    local count = RealUI:CreateFS(iconFrame, "CENTER")
    count:SetPoint("TOP", iconFrame, 1, -2)
    count:SetText(1)
    frame.count = count

    local name = RealUI:CreateFS(frame, "LEFT")
    name:SetPoint("RIGHT", frame)
    name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    name:SetNonSpaceWrap(true)
    frame.name = name

    return frame
end

local anchorSlots = function(self)
    local shownSlots = 0
    for i=1, #self.slots do
        local frame = self.slots[i]
        if(frame:IsShown()) then
            shownSlots = shownSlots + 1

            -- We don't have to worry about the previous slots as they're already hidden.
            frame:SetPoint("TOP", RealUILootFrame, 4, (-8 + LootIconSize) - (shownSlots * (LootIconSize+1)))
        end
    end

    self:SetHeight(_G.max(shownSlots * LootIconSize + 16, 20))
end

function Loot:UpdateLootPosition()
    local x, y = _G.GetCursorPosition()
    x = x / RealUILootFrame:GetEffectiveScale()
    y = y / RealUILootFrame:GetEffectiveScale()
    
    RealUILootFrame:ClearAllPoints()
    if db.loot.cursor then
        RealUILootFrame:SetPoint("TOPLEFT", nil, "BOTTOMLEFT", x-40, y+20)
    else
        RealUILootFrame:SetPoint(db.loot.static.anchor, _G.UIParent, db.loot.static.anchor, db.loot.static.x, db.loot.static.y)
    end
end

RealUILootFrame:SetScript("OnEvent", function(self, event, ...)
    self[event](self, event, ...)
end)

RealUILootFrame:SetScript("OnHide", function(self)
    _G.StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
    _G.CloseLoot()
end)

function Loot:LOOT_READY(event, autoLoot)
    --print("Loot:", event, autoLoot)
    RealUILootFrame:Show()
    RealUILootFrame:SetWidth(db.lootwidth)
    
    --print("Loot:", not RealUILootFrame:IsShown(), autoLoot == 0)
    if (not RealUILootFrame:IsShown()) then
        --print("Loot:", "Close?")
        _G.CloseLoot(autoLoot == 0)
    end

    local items = _G.GetNumLootItems()

    Loot:UpdateLootPosition()
    RealUILootFrame:Raise()

    if(items > 0) then
        for i = 1, items do
            local slot = RealUILootFrame.slots[i] or createSlot(i)
            local icon, name, quantity, quality = _G.GetLootSlotInfo(i)
            if icon then
                local color = _G.ITEM_QUALITY_COLORS[quality]

                --print("GetLootSlotType OPENED: "..tostring(GetLootSlotType(i)))
                --print("GetLootSlotType(i) == 2 is "..tostring((GetLootSlotType(i) == 2)))
                if (_G.GetLootSlotType(i) == 2) then
                    name = name:gsub("\n", ", ")
                end

                if(quantity > 1) then
                    slot.count:SetText(quantity)
                    slot.count:Show()
                else
                    slot.count:Hide()
                end

                slot.quality = quality
                slot.name:SetText(name)
                slot.name:SetTextColor(color.r, color.g, color.b)
                slot.icon:SetTexture(icon)
                slot.icon:SetDesaturated(false)

                slot:Enable()
                slot:Show()
            end
        end
    else
        local slot = RealUILootFrame.slots[1] or createSlot(1)

        slot.name:SetText(_G.EMPTY)
        slot.icon:SetTexture[[Interface\Icons\Inv_box_01]]
        slot.icon:SetDesaturated(true)

        slot.count:Hide()
        slot:Disable()
        slot:Show()
    end

    anchorSlots(RealUILootFrame)
end

function Loot:LOOT_SLOT_CLEARED(event, slot)
    --print("LOOT_SLOT_CLEARED: ")
    if(not RealUILootFrame:IsShown()) then return end
    RealUILootFrame.slots[slot]:Hide()
    anchorSlots(RealUILootFrame)
end

function Loot:LOOT_CLOSED(...)
    --print("Loot:", ...)
    _G.StaticPopup_Hide"LOOT_BIND"
    RealUILootFrame:Hide()

    for _, v in next, RealUILootFrame.slots do
        v:Hide()
    end
end

function Loot:OPEN_MASTER_LOOT_LIST()
    --print("OPEN_MASTER_LOOT_LIST: ")--..tostring(GetLootSlotType(slot)))
    _G.ToggleDropDownMenu(1, nil, _G.GroupLootDropDown, RealUILootFrame.slots[_G.LootFrame.selectedSlot], 0, 0)
end

function Loot:UPDATE_MASTER_LOOT_LIST()
    --print("UPDATE_MASTER_LOOT_LIST: ")
    _G.UIDropDownMenu_Refresh(_G.GroupLootDropDown)
end

function Loot:InitializeLoot()
    _G.LootFrame:UnregisterAllEvents()
    _G.tinsert(_G.UISpecialFrames, "RealUI_Loot")

    function Loot:GiveMasterLoot()
        _G.GiveMasterLoot(_G.MasterLooterFrame.slot, _G.MasterLooterFrame.candidateId)
        _G.MasterLooterFrame:Hide();
    end
    
    self:RegisterEvent("LOOT_READY")
    self:RegisterEvent("LOOT_SLOT_CLEARED")
    self:RegisterEvent("LOOT_CLOSED")
    self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
    self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
end

-----------------------
function Loot:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    
    if db.loot.enabled then
        self:InitializeLoot()
    end
    if db.roll.enabled then
        self:InitializeGroupLoot()
    end
end

function Loot:PLAYER_LOGIN()
    self:RefreshMod()
    if _G.Aurora and _G.Aurora[1].ReskinClose then
        _G.Aurora[1].ReskinClose(RealUILootFrame.close, "BOTTOMRIGHT", RealUILootFrame, "TOPRIGHT", 1, -3)
    end
end

function Loot:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            ["**"] = {
                enabled = true,
            },
            loot = {
                cursor = true,
                static = {
                    x = 0,
                    y = 0,
                    anchor = "CENTER",
                },
            },
            roll = {
                vertical = -210,
                horizontal = 0,
            },
            lootwidth = 190,
            grouplootwidth = 260,
        },
    })
    db = self.db.profile
    
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function Loot:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")

    do -- This is to keep the alert frames sane since loot rolls will no longer show up there.
        local adjustingSize = false
        _G.GroupLootContainer:SetScript("OnSizeChanged", function(groupLoot, width, height)
            Loot:debug("GroupLootContainer:SetHeight", height, groupLoot.reservedSize, adjustingSize)
            if adjustingSize then return end
            if height > groupLoot.reservedSize then
                adjustingSize = true
                groupLoot:SetHeight(groupLoot.reservedSize)
                adjustingSize = false
            end
        end)
    end
end
