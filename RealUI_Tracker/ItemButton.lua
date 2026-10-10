local ADDON_NAME = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

--[[ Quest item button (2026-10-10).

     One RealUI-owned secure button for the usable item of the nearest quest
     (the super-tracked quest first, when it has one), with a key binding
     (Bindings.xml: Key Bindings > AddOns > RealUI Tracker). It never touches
     the objective tracker: the item comes from the quest log API, and the
     tracker's own item buttons stay as they are.

     It is a protected frame, so its item, Show/Hide and position change only
     out of combat. A change that arrives in combat waits for
     PLAYER_REGEN_ENABLED. It is anchored to UIParent, never to the tracker: a
     protected frame anchored to the tracker would restrict how the tracker
     itself may be moved in combat. Right-drag moves it. ]]

local BUTTON_NAME = "RealUI_TrackerItemButton"
local BINDING = "CLICK " .. BUTTON_NAME .. ":LeftButton"
_G.BINDING_HEADER_REALUI_TRACKER = "RealUI Tracker"
_G["BINDING_NAME_" .. BINDING] = "Use nearest quest item"

local BUTTON_SIZE = 36
local DEFAULT_POINT = { "TOPRIGHT", "TOPRIGHT", -310, -205 }
-- Distances change as the player moves; re-pick this often out of combat.
local UPDATE_INTERVAL = 2

local button
local currentLink
local pending = false

---------------------------------------------------------
-- Picking the item
---------------------------------------------------------

-- The quest's usable item, if it should be offered now.
local function GetQuestItem(questID)
    local logIndex = _G.C_QuestLog.GetLogIndexForQuestID(questID)
    if not logIndex then return end
    local link, _, _, showWhenComplete = _G.GetQuestLogSpecialItemInfo(logIndex)
    if not link then return end
    if _G.C_QuestLog.IsComplete(questID) and not showWhenComplete then return end
    return link
end

-- The super-tracked quest's item, else the item of the nearest quest on this
-- continent. The whole log is searched, so bonus objectives and world quests
-- the player is on count too.
local function FindItem()
    local superID = _G.C_SuperTrack.GetSuperTrackedQuestID()
    if superID and superID ~= 0 then
        local link = GetQuestItem(superID)
        if link then return link end
    end

    local bestLink, bestDist
    for i = 1, _G.C_QuestLog.GetNumQuestLogEntries() do
        local info = _G.C_QuestLog.GetInfo(i)
        if info and not info.isHeader and info.questID then
            local link = GetQuestItem(info.questID)
            if link then
                local distSq, onContinent = _G.C_QuestLog.GetDistanceSqToQuest(info.questID)
                if onContinent and distSq and (not bestDist or distSq < bestDist) then
                    bestLink, bestDist = link, distSq
                end
            end
        end
    end
    return bestLink
end

---------------------------------------------------------
-- Display (own regions only)
---------------------------------------------------------

local function IsReadable(...)
    if not _G.issecretvalue then return true end
    for i = 1, select("#", ...) do
        if _G.issecretvalue((select(i, ...))) then return false end
    end
    return true
end

local function UpdateCooldown()
    if not (button and button.itemID) then return end
    local start, duration, enable = _G.C_Container.GetItemCooldown(button.itemID)
    if IsReadable(start, duration, enable) then
        _G.CooldownFrame_Set(button.cooldown, start, duration, enable)
    end
end

local function UpdateCount()
    if not (button and button.itemID) then return end
    local count = _G.C_Item.GetItemCount(button.itemID)
    button.count:SetText((count and count > 1) and count or "")
end

local function UpdateHotkey()
    if not button then return end
    local key = _G.GetBindingKey(BINDING)
    button.hotkey:SetText(key and _G.GetBindingText(key, true) or "")
end

local function ApplyPosition()
    local saved = RealUI_Tracker.db.profile.itemButton.point
    local point = saved or DEFAULT_POINT
    button:ClearAllPoints()
    button:SetPoint(point[1], _G.UIParent, point[2], point[3], point[4])
end

local function SavePosition()
    local point, _, relativePoint, x, y = button:GetPoint()
    RealUI_Tracker.db.profile.itemButton.point = { point, relativePoint, x, y }
end

---------------------------------------------------------
-- Update
---------------------------------------------------------

local function Update()
    if not button then return end
    if _G.InCombatLockdown() then
        pending = true
        return
    end
    pending = false

    local link = RealUI_Tracker.db.profile.itemButton.enabled and FindItem() or nil
    if link == currentLink then return end
    currentLink = link

    if link then
        local itemID = _G.C_Item.GetItemInfoInstant(link)
        button.itemID = itemID
        button:SetAttribute("item", "item:" .. itemID)
        button.icon:SetTexture(_G.C_Item.GetItemIconByID(itemID))
        UpdateCooldown()
        UpdateCount()
        button:Show()
    else
        button.itemID = nil
        button:SetAttribute("item", nil)
        button:Hide()
    end
end

-- Coalesce bursts (QUEST_LOG_UPDATE fires in runs) into one update.
local queued = false
local function QueueUpdate()
    if queued then return end
    queued = true
    _G.C_Timer.After(0.2, function()
        queued = false
        Update()
    end)
end

-- For the config panel: re-pick, and re-place if the button was reset.
function RealUI_Tracker:RefreshItemButton()
    if not button then return end
    currentLink = false -- force a re-apply
    if not _G.InCombatLockdown() then
        ApplyPosition()
    end
    Update()
end

function RealUI_Tracker:ResetItemButtonPosition()
    self.db.profile.itemButton.point = nil
    self:RefreshItemButton()
end

---------------------------------------------------------
-- Button
---------------------------------------------------------

local function OnEnter(self)
    if not self.itemID then return end
    _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
    _G.GameTooltip:SetItemByID(self.itemID)
    _G.GameTooltip:AddLine("Right-drag to move", 0.6, 0.6, 0.6)
    _G.GameTooltip:Show()
end

local function OnLeave()
    _G.GameTooltip:Hide()
end

local function OnDragStart(self)
    if _G.InCombatLockdown() then return end
    self:StartMoving()
end

local function OnDragStop(self)
    self:StopMovingOrSizing()
    -- The position lives in the profile; keep it out of the layout cache.
    self:SetUserPlaced(false)
    SavePosition()
end

local function CreateButton()
    button = _G.CreateFrame("Button", BUTTON_NAME, _G.UIParent, "SecureActionButtonTemplate")
    button:SetSize(BUTTON_SIZE, BUTTON_SIZE)
    button:SetFrameStrata("MEDIUM")
    button:SetClampedToScreen(true)
    button:Hide()

    -- Both phases, as in WorldMarker.lua (B33): the template acts on the
    -- phase ActionButtonUseKeyDown selects, and only that one. Only the left
    -- button (and the binding, which clicks LeftButton) uses the item.
    button:RegisterForClicks("AnyUp", "AnyDown")
    button:SetAttribute("type1", "item")

    button:SetMovable(true)
    button:RegisterForDrag("RightButton")
    button:SetScript("OnDragStart", OnDragStart)
    button:SetScript("OnDragStop", OnDragStop)
    button:SetScript("OnEnter", OnEnter)
    button:SetScript("OnLeave", OnLeave)

    local icon = button:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    button.icon = icon

    local cooldown = _G.CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
    cooldown:SetAllPoints()
    button.cooldown = cooldown

    local count = button:CreateFontString(nil, "OVERLAY", "NumberFontNormal")
    count:SetPoint("BOTTOMRIGHT", -2, 2)
    button.count = count

    local hotkey = button:CreateFontString(nil, "OVERLAY", "NumberFontNormalSmallGray")
    hotkey:SetPoint("TOPRIGHT", -2, -3)
    button.hotkey = hotkey

    button:SetHighlightTexture([[Interface\Buttons\ButtonHilight-Square]], "ADD")
    button:SetPushedTexture([[Interface\Buttons\UI-Quickslot-Depress]])

    local Aurora = _G.Aurora
    if Aurora and Aurora.Base then
        Aurora.Base.CropIcon(icon, button)
    end

    ApplyPosition()
end

---------------------------------------------------------
-- Setup
---------------------------------------------------------

local EVENTS = {
    "QUEST_LOG_UPDATE",
    "QUEST_WATCH_LIST_CHANGED",
    "SUPER_TRACKING_CHANGED",
    "ZONE_CHANGED",
    "ZONE_CHANGED_NEW_AREA",
    "PLAYER_ENTERING_WORLD",
    "PLAYER_REGEN_ENABLED",
    "BAG_UPDATE_COOLDOWN",
    "BAG_UPDATE_DELAYED",
    "UPDATE_BINDINGS",
}

local function OnEvent(_, event)
    if event == "BAG_UPDATE_COOLDOWN" then
        UpdateCooldown()
    elseif event == "BAG_UPDATE_DELAYED" then
        UpdateCount()
    elseif event == "UPDATE_BINDINGS" then
        UpdateHotkey()
    elseif event == "PLAYER_REGEN_ENABLED" then
        if pending then Update() end
    else
        QueueUpdate()
    end
end

function RealUI_Tracker:SetupItemButton()
    CreateButton()
    UpdateHotkey()

    local events = _G.CreateFrame("Frame")
    for _, event in ipairs(EVENTS) do
        events:RegisterEvent(event)
    end
    events:SetScript("OnEvent", OnEvent)

    _G.C_Timer.NewTicker(UPDATE_INTERVAL, Update)
    Update()
end
