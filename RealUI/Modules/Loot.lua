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
local next = _G.next

-- Libs --
local Aurora = _G.Aurora
local Base = Aurora.Base
local Skin = Aurora.Skin
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local db
--if RealUI.isDragonflight then return end
-- TODO: move this to Skins

local MODNAME = "Loot"
local Loot = RealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Runtime toggle: /run RealUI_LootRollDebug = true (or false)
local DEBUG_GROUP_LOOT = false

local function IsGroupLootDebugEnabled()
    return DEBUG_GROUP_LOOT or _G.RealUI_LootRollDebug == true
end

local function GroupLootDebug(...)
    if not IsGroupLootDebugEnabled() then
        return
    end

    local parts = {}
    for i = 1, _G.select("#", ...) do
        parts[i] = _G.tostring(_G.select(i, ...))
    end

    _G.print("|cff33ff99RealUI Loot Debug:|r ".._G.table.concat(parts, " "))
end

--------------------
---- GROUP LOOT ----
--------------------
local GroupLootIconSize = 32
local grouplootlist, grouplootframes = {}, {}
local RealUIGroupLootFrame

local function GroupLootOnEvent(self, event, ...)
    if event == "START_LOOT_ROLL" then
        local rollId, rollTime = ...
        local _, name, _, _, _, canNeed, canGreed, canDisenchant, _, _, _, _, canTransmog = _G.GetLootRollItemInfo(rollId)
        local rollLink = _G.GetLootRollItemLink(rollId)
        GroupLootDebug(
            "START_LOOT_ROLL",
            "rollId="..rollId,
            "name="..(name or "nil"),
            "need=".._G.tostring(canNeed),
            "greed=".._G.tostring(canGreed),
            "de=".._G.tostring(canDisenchant),
            "transmog=".._G.tostring(canTransmog),
            "linkType=".._G.tostring(type(rollLink) == "string" and rollLink:match("|H([^:|]+):") or nil)
        )
        _G.tinsert(grouplootlist, {rollId = rollId, rollTime = rollTime})
        Loot:UpdateGroupLoot()
    elseif event == "CONFIRM_LOOT_ROLL" then
        -- Server requires confirmation before the roll registers (e.g. housing decors,
        -- BoP-need items). The user already expressed intent by clicking a button, so
        -- auto-confirm here. Without this the roll silently fails: our frame is already
        -- hidden before the server's async CONFIRM_LOOT_ROLL event arrives, Blizzard's
        -- popup appears orphaned, the user dismisses it, and the server stays
        -- "Waiting on" this player.
        local confirmRollId, confirmRollType = ...
        GroupLootDebug("CONFIRM_LOOT_ROLL", "rollId=".._G.tostring(confirmRollId), "type=".._G.tostring(confirmRollType))
        _G.StaticPopup_Hide("CONFIRM_LOOT_ROLL", confirmRollId)
        _G.ConfirmLootRoll(confirmRollId, confirmRollType)
    elseif event == "CONFIRM_DISENCHANT_ROLL" then
        local confirmRollId, confirmRollType = ...
        GroupLootDebug("CONFIRM_DISENCHANT_ROLL", "rollId=".._G.tostring(confirmRollId), "type=".._G.tostring(confirmRollType))
        _G.StaticPopup_Hide("CONFIRM_LOOT_ROLL", confirmRollId)
        _G.ConfirmLootRoll(confirmRollId, confirmRollType)
    elseif event == "LOOT_ROLLS_COMPLETE" then
        GroupLootDebug("LOOT_ROLLS_COMPLETE", "active=".._G.tostring(#grouplootlist))
        -- Safety net: remove any stale entries whose rollId no longer returns valid data
        for i = #grouplootlist, 1, -1 do
            local texture = _G.GetLootRollItemInfo(grouplootlist[i].rollId)
            if not texture then
                _G.tremove(grouplootlist, i)
            end
        end
        Loot:UpdateGroupLoot()
    end
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
    elseif event == "CANCEL_ALL_LOOT_ROLLS" then
        _G.wipe(grouplootlist)
        Loot:UpdateGroupLoot()
    elseif event == "MODIFIER_STATE_CHANGED" then
        local key, state = ...
        if (key == "LSHIFT" or key == "RSHIFT") then
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
    local frame = self:GetParent()
    local rollId = frame.rollId
    GroupLootDebug("RollOnLoot", "rollId=".._G.tostring(rollId), "type=".._G.tostring(self.type), "roll=".._G.tostring(self.roll))
    _G.RollOnLoot(rollId, self.type)

    -- Remove the roll entry from grouplootlist (mirrors CANCEL_LOOT_ROLL cleanup)
    for index, value in next, grouplootlist do
        if rollId == value.rollId then
            _G.tremove(grouplootlist, index)
            break
        end
    end

    _G.StaticPopup_Hide("CONFIRM_LOOT_ROLL", rollId)
    frame.rollId = nil
    Loot:UpdateGroupLoot()
end

-- B215: the roll timer, as Blizzard's GroupLootFrame drives its own Timer bar.
local function GroupLootTimerOnUpdate(bar)
    local rollId = bar:GetParent().rollId
    if rollId then
        bar:SetValue(_G.GetLootRollTimeLeft(rollId) or 0)
    end
end

local function GroupLootSortFunc(a, b)
    return a.rollId < b.rollId
end

local function UpdateSecondaryRollButtons(frame, rollId, canGreed, canTransmog)
    local greedEnabled = canGreed or canTransmog
    frame.greed.type = 2

    -- WoW 12 can expose a transmog roll alongside greed-style behavior.
    -- Keep greed clickable when transmog is available so both options are usable.
    if greedEnabled then
        frame.greed:Enable()
    else
        frame.greed:Disable()
    end

    if canTransmog then
        frame.transmog:Show()
        frame.transmog:Enable()
        frame.greed:ClearAllPoints()
        frame.greed:SetPoint("RIGHT", frame.transmog, "LEFT", -1, -4)
    else
        frame.transmog:Hide()
        frame.greed:ClearAllPoints()
        frame.greed:SetPoint("RIGHT", frame.pass, "LEFT", -1, -4)
    end

    frame.greed:GetNormalTexture():SetDesaturated(not frame.greed:IsEnabled())
    GroupLootDebug(
        "SecondaryButtons",
        "rollId=".._G.tostring(rollId),
        "canGreed=".._G.tostring(canGreed),
        "canTransmog=".._G.tostring(canTransmog),
        "greedEnabledByRules=".._G.tostring(greedEnabled),
        "greedShown=".._G.tostring(frame.greed:IsShown()),
        "greedEnabled=".._G.tostring(frame.greed:IsEnabled()),
        "transmogShown=".._G.tostring(frame.transmog:IsShown())
    )
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
            frame:RegisterEvent("CANCEL_ALL_LOOT_ROLLS")
            frame:RegisterEvent("MODIFIER_STATE_CHANGED")
            frame:SetScript("OnEvent", GroupLootFrameOnEvent)
            frame:SetScript("OnMouseUp", GroupLootFrameOnClick)
            frame:SetScript("OnLeave", GroupLootFrameOnLeave)
            frame:SetScript("OnEnter", GroupLootFrameOnEnter)

            Base.SetBackdrop(frame, Color.frame)

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

            frame.transmog = _G.CreateFrame("Button", nil, frame)
            frame.transmog.type = 4
            frame.transmog.roll = "transmog"
            frame.transmog:SetWidth(28)
            frame.transmog:SetHeight(28)
            frame.transmog:SetNormalAtlas("lootroll-toast-icon-transmog-up")
            frame.transmog:SetPushedAtlas("lootroll-toast-icon-transmog-down")
            frame.transmog:SetHighlightAtlas("lootroll-toast-icon-transmog-highlight")
            frame.transmog:SetPoint("RIGHT", frame.pass, "LEFT", -1, -4)
            frame.transmog:SetScript("OnClick", GroupLootButtonOnClick)
            frame.transmog:Hide()

            frame.need = _G.CreateFrame("Button", nil, frame)
            frame.need.type = 1
            frame.need.roll = "need"
            frame.need:SetWidth(28)
            frame.need:SetHeight(28)
            frame.need:SetNormalTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Up")
            frame.need:SetPushedTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Down")
            frame.need:SetHighlightTexture("Interface\\Buttons\\UI-GroupLoot-Dice-Highlight")
            frame.need:SetPoint("RIGHT", frame.greed, "LEFT", -1, 0)
            frame.need:SetScript("OnClick", GroupLootButtonOnClick)

            frame.text = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
            frame.text:SetJustifyH("LEFT")
            -- B254: one line, truncated; a long name wrapped to a second line
            -- that ran out of the 24px frame
            frame.text:SetWordWrap(false)
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
            Base.CropIcon(icon, iconFrame)
            frame.icon = icon

            -- B215: time left on the roll, a thin bar. B254: under the frame,
            -- not along its bottom edge, where it ran through the item name;
            -- roll frames stack 35px apart for a 24px frame, so it fits.
            local timer = _G.CreateFrame("StatusBar", nil, frame)
            timer:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", 0, -1)
            timer:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 0, -1)
            timer:SetHeight(3)
            timer:SetStatusBarTexture(RealUI.textures.plain)
            timer:SetStatusBarColor(Color.highlight:GetRGB())
            timer:SetScript("OnUpdate", GroupLootTimerOnUpdate)
            frame.timer = timer

            _G.tinsert(grouplootframes, frame)
        end

        local texture, name, _, quality, _, Needable, Greedable, _, _, _, _, _, canTransmog = _G.GetLootRollItemInfo(value.rollId)
        local rollLink = _G.GetLootRollItemLink(value.rollId)

        if not name then
            _G.tremove(grouplootlist, index)
            break
        end

        frame.rollId = value.rollId
        frame.rollLink = rollLink

        -- A roll already running at login has no START_LOOT_ROLL time; the
        -- time left is the best maximum we have.
        local timeLeft = _G.GetLootRollTimeLeft(value.rollId) or 0
        value.rollTime = value.rollTime or timeLeft
        frame.timer:SetMinMaxValues(0, _G.math.max(value.rollTime, 1))
        frame.timer:SetValue(timeLeft)

        if Needable then frame.need:Enable() else frame.need:Disable() end

        UpdateSecondaryRollButtons(frame, value.rollId, Greedable, canTransmog)

        frame.need:GetNormalTexture():SetDesaturated(not Needable);

        frame.text:SetText(_G.ITEM_QUALITY_COLORS[quality].hex..name)

        frame.icon:SetTexture(texture)

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
    RealUIGroupLootFrame:RegisterEvent("LOOT_ROLLS_COMPLETE")
    RealUIGroupLootFrame:RegisterEvent("CONFIRM_LOOT_ROLL")
    RealUIGroupLootFrame:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
    RealUIGroupLootFrame:SetScript("OnEvent", GroupLootOnEvent)
    RealUIGroupLootFrame:SetFrameStrata("HIGH")
    RealUIGroupLootFrame:SetWidth(db.grouplootwidth)
    RealUIGroupLootFrame:SetHeight(24)
    self:GroupLootPosition()

    -- Keep Blizzard's roll frames from opening by cutting the event route
    -- into them, not by replacing GroupLootContainer_AddRoll or SetScript on
    -- GroupLootFrame1-4 (taint doctrine R8): every caller of a replaced
    -- global, and every show of a SetScript frame, ran RealUI code inside
    -- Blizzard's execution. START_LOOT_ROLL reaches the container only
    -- through GameEvent's router (HandleStartLootRoll → AddRoll);
    -- UnregisterInternalEvent is that router's own off switch, and the key it
    -- clears is never read again. The roll frames themselves stay Blizzard's.
    -- If Blizzard still opens one (its PLAYER_ENTERING_WORLD handler re-adds
    -- rolls carried over a loading screen), its own OnShow registers
    -- CANCEL_LOOT_ROLL and it removes itself when the roll ends.
    if _G.GameEvent and _G.GameEvent.UnregisterInternalEvent then
        _G.GameEvent.UnregisterInternalEvent("START_LOOT_ROLL")
    end
    _G.GroupLootContainer:UnregisterAllEvents()
    _G.GroupLootContainer:Hide()

    -- After a /reload, re-populate from any still-active rolls that the
    -- server remembers (Blizzard's PLAYER_ENTERING_WORLD does the same for
    -- its own frames via GetActiveLootRollIDs → GroupLootContainer_AddRoll).
    local pendingIDs = _G.GetActiveLootRollIDs and _G.GetActiveLootRollIDs()
    if pendingIDs then
        for i = 1, #pendingIDs do
            _G.tinsert(grouplootlist, {rollId = pendingIDs[i]})
        end
        if #pendingIDs > 0 then
            self:UpdateGroupLoot()
        end
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
Skin.UIPanelCloseButton(RealUILootFrame.close)
RealUILootFrame.close:SetPoint("TOPRIGHT", RealUILootFrame, "TOPRIGHT", 8, 20)
RealUILootFrame.slots = {}

-- Slot types by enum, as Blizzard's own LootFrame checks them. The legacy
-- LOOT_SLOT_ITEM / LOOT_SLOT_CURRENCY globals are client-provided and WoW
-- Forever's client does not expose them, so a comparison against them was
-- nil == number and the tooltip never showed there (found 2026-09-22).
local SLOT_ITEM = _G.Enum.LootSlotType and _G.Enum.LootSlotType.Item or _G.LOOT_SLOT_ITEM
local SLOT_CURRENCY = _G.Enum.LootSlotType and _G.Enum.LootSlotType.Currency or _G.LOOT_SLOT_CURRENCY

local function LootOnEnter(self)
    local slot = self:GetID()
    local slotType = _G.GetLootSlotType(slot)
    if slotType == SLOT_ITEM then
        _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        _G.GameTooltip:SetLootItem(slot)
        _G.CursorUpdate(self)
    end
    if slotType == SLOT_CURRENCY then
        _G.GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        _G.GameTooltip:SetLootCurrency(slot);
        _G.CursorUpdate(self);
    end
end

local function LootOnLeave(self)
    _G.GameTooltip:Hide()
    _G.ResetCursor()
end

-- Master loot (B147) ---------------------------------------------------------
-- WoW Forever has master loot. Looting a master-loot slot as the looter fires
-- OPEN_MASTER_LOOT_LIST instead of looting it. Blizzard's own handler builds
-- its menu from `selected*` fields its LootFrame writes on click; RealUI's
-- frame never sets them, and writing them onto LootFrame would be a plant
-- (taint doctrine R1). So RealUI builds its own menu from the master-loot
-- APIs. All state lives in these locals, none on a Blizzard frame or table.
-- Retail has no master loot: the event never fires there.
local MAX_CANDIDATES = _G.MAX_RAID_MEMBERS or 40
local masterLootSlot            -- slot of the last plain click on a loot slot
local masterLootMenu            -- the open assign menu (a pooled menu proxy)
local masterLootOwner           -- the RealUI slot button that menu belongs to
local masterLootConfirm         -- data table of the open confirmation popup
local masterLootConfirmSlot     -- the loot slot that popup is for

local function HasMasterLoot()
    return _G.GiveMasterLoot and _G.GetMasterLootCandidate
        and _G.MenuUtil and _G.MenuUtil.CreateContextMenu
        and _G.StaticPopup_ShowCustomGenericConfirmation
        and true or false
end

local function IsMasterLootMenuOpen()
    -- Menu frames are pooled, so the proxy is ours only while it is shown
    -- for the slot button we opened it on.
    return masterLootMenu and masterLootMenu:IsShown()
        and masterLootMenu:GetOwnerRegion() == masterLootOwner
end

local function CloseMasterLootMenu()
    if IsMasterLootMenuOpen() then
        masterLootMenu:Close()
    end
    masterLootMenu, masterLootOwner = nil, nil
end

local function HideMasterLootConfirm()
    if masterLootConfirm then
        _G.StaticPopup_Hide("GENERIC_CONFIRMATION", masterLootConfirm)
    end
    masterLootConfirm, masterLootConfirmSlot = nil, nil
end

local function ClassColored(className, text)
    local color = className and _G.RAID_CLASS_COLORS[className]
    if color and color.WrapTextInColorCode then
        return color:WrapTextInColorCode(text)
    end
    return text
end

local function CandidateSort(a, b)
    if a.class == b.class then
        return a.name < b.name
    end
    return a.class < b.class
end

local function GetMasterLootCandidates(slot)
    local candidates = {}
    for i = 1, MAX_CANDIDATES do
        local name, class, className = _G.GetMasterLootCandidate(slot, i)
        if name then
            candidates[#candidates + 1] = {name = name, class = class or "", className = className}
        end
    end
    _G.sort(candidates, CandidateSort)
    return candidates
end

-- Candidate indices shift when the group changes, so the index is looked up
-- by name at the moment of giving, not taken from when the menu was built.
local function GiveToCandidate(slot, name)
    for i = 1, MAX_CANDIDATES do
        if _G.GetMasterLootCandidate(slot, i) == name then
            _G.GiveMasterLoot(slot, i)
            return
        end
    end
end

local function SelectRecipient(slot, candidate)
    HideMasterLootConfirm()

    local _, itemName, _, _, quality = _G.GetLootSlotInfo(slot)
    if not itemName then return end

    local lootConsts = _G.Constants and _G.Constants.LootConsts
    local threshold = lootConsts and lootConsts.MasterLootQualityThreshold or 4
    if quality and quality >= threshold then
        -- Blizzard's CONFIRM_LOOT_DISTRIBUTION accept handler only gives from
        -- its own MasterLooterFrame fields, so confirm through the generic
        -- dialog with our own callback instead.
        local color = _G.ITEM_QUALITY_COLORS[quality]
        local data
        data = {
            text = _G.CONFIRM_LOOT_DISTRIBUTION,
            text_arg1 = color and (color.hex .. itemName .. "|r") or itemName,
            text_arg2 = ClassColored(candidate.className, candidate.name),
            callback = function()
                if masterLootConfirm == data then
                    masterLootConfirm, masterLootConfirmSlot = nil, nil
                end
                GiveToCandidate(slot, candidate.name)
            end,
            cancelCallback = function()
                if masterLootConfirm == data then
                    masterLootConfirm, masterLootConfirmSlot = nil, nil
                end
            end,
        }
        masterLootConfirm, masterLootConfirmSlot = data, slot
        _G.StaticPopup_ShowCustomGenericConfirmation(data)
    else
        GiveToCandidate(slot, candidate.name)
    end
end

local function NoOp() end

local function OpenMasterLootMenu(slot)
    local owner = RealUILootFrame.slots[slot]
    if not (owner and owner:IsShown()) then return end

    local candidates = GetMasterLootCandidates(slot)
    CloseMasterLootMenu()

    -- A context menu owned by the clicked slot button: it opens at the cursor
    -- (which is on that slot) and closes when the slot hides.
    masterLootMenu = _G.MenuUtil.CreateContextMenu(owner, function(_, rootDescription)
        rootDescription:CreateTitle(_G.MASTER_LOOTER)

        -- party: Assign Loot > name; raid: Assign Loot > class > name
        local assign = rootDescription:CreateButton(_G.ASSIGN_LOOT)
        local isRaid = _G.IsInRaid()
        local classButton, currentClass
        for _, candidate in _G.ipairs(candidates) do
            local parent = assign
            if isRaid then
                if candidate.class ~= currentClass then
                    currentClass = candidate.class
                    classButton = assign:CreateButton(ClassColored(candidate.className, candidate.class), NoOp)
                end
                parent = classButton
            end
            parent:CreateButton(ClassColored(candidate.className, candidate.name), function()
                SelectRecipient(slot, candidate)
            end)
        end

        if _G.DoMasterLootRoll then
            rootDescription:CreateButton(_G.REQUEST_ROLL, function()
                _G.DoMasterLootRoll(slot)
            end)
        end
    end)
    masterLootOwner = owner
end

local function LootOnClick(self)
    if _G.IsModifiedClick() then
        _G.HandleModifiedItemClick(_G.GetLootSlotLink(self:GetID()))
    else
        _G.StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
        HideMasterLootConfirm()
        -- No `selected*` fields on Blizzard's LootFrame (taint doctrine R1):
        -- the master-loot menu reads this local instead (B147).
        masterLootSlot = self:GetID()
        _G.LootSlot(self:GetID())
    end
end

local function LootOnUpdate(self)
    if _G.GameTooltip:IsOwned(self) then
        LootOnEnter(self)
    end
    _G.CursorOnUpdate(self)
end

local function createSlot(id)
    local frame = _G.CreateFrame("Button", "ButsuSlot"..id, RealUILootFrame)
    frame:SetPoint("TOP", RealUILootFrame, 0, -((id-1)*(LootIconSize+1)))
    frame:SetPoint("RIGHT")
    frame:SetPoint("LEFT")
    frame:SetHeight(24)
    --frame:SetFrameStrata("HIGH")
    --frame:SetFrameLevel(20)
    frame:SetID(id)
    RealUILootFrame.slots[id] = frame

    frame:SetScript("OnClick", LootOnClick)
    frame:SetScript("OnEnter", LootOnEnter)
    frame:SetScript("OnLeave", LootOnLeave)
    frame:SetScript("OnUpdate", LootOnUpdate)

    Base.SetBackdrop(frame, Color.button)
    Base.SetHighlight(frame)

    local iconFrame = _G.CreateFrame("Frame", nil, frame)
    iconFrame:SetHeight(LootIconSize)
    iconFrame:SetWidth(LootIconSize)
    iconFrame:SetFrameStrata("HIGH")
    iconFrame:SetFrameLevel(20)
    iconFrame:ClearAllPoints()
    iconFrame:SetPoint("RIGHT", frame, "LEFT", -2, 0)

    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetPoint("TOPLEFT", 1, -1)
    icon:SetPoint("BOTTOMRIGHT", -1, 1)
    Base.CropIcon(icon, iconFrame)
    frame.icon = icon

    local count = iconFrame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    count:SetJustifyH("CENTER")
    count:SetPoint("TOP", iconFrame, 1, -2)
    count:SetText(1)
    frame.count = count

    local name = frame:CreateFontString(nil, "OVERLAY", "SystemFont_Shadow_Med1")
    name:SetJustifyH("LEFT")
    name:SetPoint("RIGHT", frame)
    name:SetPoint("LEFT", icon, "RIGHT", 8, 0)
    name:SetNonSpaceWrap(true)
    frame.name = name

    return frame
end

local function anchorSlots(self)
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

RealUILootFrame:SetScript("OnEvent", function(dialog, event, ...)
    dialog[event](dialog, event, ...)
end)

RealUILootFrame:SetScript("OnHide", function(dialog)
    _G.StaticPopup_Hide("CONFIRM_LOOT_DISTRIBUTION")
    _G.CloseLoot()
end)

-- Instant loot ---------------------------------------------------------------
-- Can slot `i` actually be looted right now? Returning false leaves the slot
-- for the loot window rather than issuing a call the server will refuse — the
-- historic auto-loot disconnect pattern is re-issuing refused loot calls.
local function SlotIsLootable(i)
    local slotType = _G.GetLootSlotType(i)
    if slotType == _G.Enum.LootSlotType.Money
    or slotType == _G.Enum.LootSlotType.Currency then
        return true
    end

    local link = _G.GetLootSlotLink(i)
    if not link then return false end -- locked or unreadable

    local itemFamily = _G.C_Item.GetItemFamily(link) or 0
    for bag = 0, _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS do
        local free, bagFamily = _G.C_Container.GetContainerNumFreeSlots(bag)
        if free and free > 0 then
            if not bagFamily or bagFamily == 0 or itemFamily == 0
            or _G.bit.band(itemFamily, bagFamily) > 0 then
                return true
            end
        end
    end

    -- No free slot, but a partial stack may still have room. Approximate:
    -- count % maxStack ~= 0 means at least one non-full stack exists. Errs
    -- toward looting; the window + sound path is the safety net if the merge
    -- turns out to be narrower than the loot quantity.
    local itemID = _G.C_Item.GetItemInfoInstant(link)
    local maxStack = itemID and _G.C_Item.GetItemMaxStackSizeByID(itemID)
    if maxStack and maxStack > 1 then
        local count = _G.C_Item.GetItemCount(itemID)
        if count > 0 and (count % maxStack) ~= 0 then
            return true
        end
    end

    return false
end

-- LOOT_READY can fire more than once for a single loot session; this makes the
-- pass and its sound cue single-shot. Cleared in LOOT_CLOSED.
local lootPassDone

function Loot:LOOT_READY(event, autoLoot)
    if self.db.global.instantLoot and autoLoot and not lootPassDone then
        lootPassDone = true

        local blocked = false
        -- Top-down: slot indices collapse as slots clear.
        for i = _G.GetNumLootItems(), 1, -1 do
            local ok, lootable = _G.pcall(SlotIsLootable, i)
            if ok and lootable then
                _G.LootSlot(i) -- one call per slot, never retried
            else
                blocked = true
            end
        end

        if not blocked then
            -- Everything dispatched; the server closes the session and the
            -- window never appears.
            return
        end

        -- Something could not be looted (full bags or a locked slot): cue the
        -- user and fall through to the window so they can see what is left.
        _G.PlaySound(_G.SOUNDKIT.IG_BACKPACK_OPEN)
    end

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
            local icon, name, quantity, currencyID, quality = _G.GetLootSlotInfo(i)
            if currencyID then
                name, icon, quantity, quality = _G.CurrencyContainerUtil.GetCurrencyContainerInfo(currencyID, quantity, name, icon, quality);
            end
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
    if masterLootConfirmSlot == slot then
        HideMasterLootConfirm()
    end
    RealUILootFrame.slots[slot]:Hide()
    anchorSlots(RealUILootFrame)
end

function Loot:LOOT_CLOSED(...)
    --print("Loot:", ...)
    lootPassDone = nil
    masterLootSlot = nil
    CloseMasterLootMenu()
    HideMasterLootConfirm()
    _G.StaticPopup_Hide"LOOT_BIND"
    RealUILootFrame:Hide()

    for _, v in next, RealUILootFrame.slots do
        v:Hide()
    end
end

-- B147: fired by LootSlot() on a master-loot slot when we are the looter.
function Loot:OPEN_MASTER_LOOT_LIST()
    if masterLootSlot and RealUILootFrame:IsShown() then
        OpenMasterLootMenu(masterLootSlot)
    end
end

-- The candidate list changed (someone joined, left or went out of range):
-- rebuild an open menu so it never offers a stale list.
function Loot:UPDATE_MASTER_LOOT_LIST()
    if IsMasterLootMenuOpen() then
        OpenMasterLootMenu(masterLootOwner:GetID())
    end
end

function Loot:InitializeLoot()
    _G.LootFrame:UnregisterAllEvents()
    _G.tinsert(_G.UISpecialFrames, "RealUI_Loot")

    self:RegisterEvent("LOOT_READY")
    self:RegisterEvent("LOOT_SLOT_CLEARED")
    self:RegisterEvent("LOOT_CLOSED")

    if HasMasterLoot() then
        -- Blizzard opens its own master-loot menu from GroupLootFrame_OnLoad,
        -- through EventRegistry rather than on LootFrame, so the
        -- UnregisterAllEvents above leaves it live. Against RealUI's frame it
        -- anchors to a nil LootFrame.selectedLootFrame and reads a nil
        -- selectedSlot, and it would race ours for the one open menu. Remove
        -- those callbacks through the registry's own API (it writes only
        -- when the owner is present); no Blizzard frame or function is touched.
        for i = 1, 4 do
            local glf = _G["GroupLootFrame"..i]
            if glf then
                _G.EventRegistry:UnregisterCallback("OPEN_MASTER_LOOT_LIST", glf)
            end
        end
        self:RegisterEvent("OPEN_MASTER_LOOT_LIST")
        self:RegisterEvent("UPDATE_MASTER_LOOT_LIST")
    end
end

function Loot:PLAYER_LOGIN()
    self:RefreshMod()
end

-----------------------
function Loot:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    db = self.db.profile

    if db.loot.enabled then
        self:InitializeLoot()
    end
    if db.roll.enabled then
        self:InitializeGroupLoot()
    end
end

function Loot:OnInitialize()
    -- Register with ModuleFramework
    if RealUI.ModuleFramework then
        RealUI:RegisterRealUIModule(MODNAME, "enhancement", {}, {
            description = "Loot frame enhancements and positioning",
            version = "1.0.0"
        })
    end

    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        global = {
            -- Account-wide: the install wizard already opts users into auto
            -- loot, so fast auto-loot is the expected experience. New key, so
            -- existing profiles are unaffected.
            instantLoot = true,
        },
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
end
