local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- Libs --
local HBD = _G.LibStub("HereBeDragons-1.0")
local HBDP = _G.LibStub("HereBeDragons-Pins-1.0")

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "MinimapAdv"
local MinimapAdv = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

_G.RealUIMinimap = MinimapAdv
_G.BINDING_HEADER_REALUIMINIMAP = "RealUI Minimap"
_G.BINDING_NAME_REALUIMINIMAPTOGGLE = "Toggle Minimap"
_G.BINDING_NAME_REALUIMINIMAPFARM = "Toggle Farm Mode"

local infoTexts = {}

local Textures = {
    SquareMask = [[Interface\AddOns\nibRealUI\Media\Minimap\SquareMinimapMask]],
    Minimize = [[Interface\Addons\nibRealUI\Media\Minimap\Minimize]],
    Maximize = [[Interface\Addons\nibRealUI\Media\Minimap\Maximize]],
    Config = [[Interface\Addons\nibRealUI\Media\Minimap\Config]],
    Tracking = [[Interface\Addons\nibRealUI\Media\Minimap\Tracking]],
    Expand = [[Interface\Addons\nibRealUI\Media\Minimap\Expand]],
    Collapse = [[Interface\Addons\nibRealUI\Media\Minimap\Collapse]],
    ZoneIndicator = [[Interface\Addons\nibRealUI\Media\Minimap\ZoneIndicator]],
    TooltipIcon = [[Interface\Addons\nibRealUI\Media\Minimap\TooltipIcon]],
}

local MMFrames = MinimapAdv.Frames

local pois = {}
MinimapAdv.pois = pois

local ExpandedState = 0
local UpdateProcessing = false

----------
-- Seconds to Time
local function ConvertSecondstoTime(value)
    local minutes, seconds
    minutes = _G.floor(value / 60)
    seconds = _G.floor(value - (minutes * 60))
    if ( minutes > 0 ) then
        if ( seconds < 10 ) then seconds = ("0%d"):format(seconds) end
        return ("%s:%s"):format(minutes, seconds)
    else
        return ("%ss"):format(seconds)
    end
end

-- Zoom Out
local function ZoomMinimapOut()
    _G.Minimap:SetZoom(0)
    _G.MinimapZoomIn:Enable()
    _G.MinimapZoomOut:Disable()
end

-- Timer
local RefreshMap, RefreshZoom
local RefreshTimer = _G.CreateFrame("FRAME")
RefreshTimer.elapsed = 5
RefreshTimer:Hide()
RefreshTimer:SetScript("OnUpdate", function(s, e)
    RefreshTimer.elapsed = RefreshTimer.elapsed - e
    if (RefreshTimer.elapsed <= 0) then
        -- Map
        if RefreshMap then
            local x, y = _G.GetPlayerMapPosition("Player")

            -- If Coords are at 0,0 then it's possible that they are stuck
            if x == 0 and y == 0 and not _G.WorldMapFrame:IsVisible() then
                _G.SetMapToCurrentZone()
            end
            RefreshMap = false
        end

        -- Zoom
        if RefreshZoom then
            ZoomMinimapOut()
            RefreshZoom = false
        end
        RefreshTimer.elapsed = 1
    end
end)

local function fadeIn(frame)
    --print("fadeIn")
    if _G.InCombatLockdown() then return end
    _G.UIFrameFadeIn(frame, 0.1, frame:GetAlpha(), 1)
end
local function fadeOut(frame)
    --print("fadeOut")
    _G.UIFrameFadeOut(frame, 0.5, frame:GetAlpha(), 0)
end

---------------------------
-- MINIMAP FRAME UPDATES --
---------------------------
-- Clickthrough
function MinimapAdv:UpdateClickthrough()
    if ( (ExpandedState == 0) or (not db.expand.extras.clickthrough) ) then
        _G.Minimap:EnableMouse(true)
    else
        _G.Minimap:EnableMouse(false)
    end
end

-- Farm Mode - Hide POI option
function MinimapAdv:UpdateFarmModePOI()
    if ExpandedState == 0 then
        self:POIUpdate()
    else
        if db.expand.extras.hidepoi then
            self:RemoveAllPOIs()
        else
            self:POIUpdate()
        end
    end
end

-- Get size and position data
local function GetPositionData()
    -- Get Normal or Expanded data
    local mapPoints

    if ExpandedState == 0 then
        mapPoints = {
            xofs = db.position.x,
            yofs = db.position.y,
            anchor = db.position.anchorto,
            scale = db.position.scale,
            opacity = 1,
            isTop = db.position.anchorto:find("TOP"),
            isLeft = db.position.anchorto:find("LEFT"),
        }
    else
        mapPoints = {
            xofs = db.expand.position.x,
            yofs = db.expand.position.y,
            anchor = db.expand.position.anchorto,
            scale = db.expand.appearance.scale,
            opacity = db.expand.appearance.opacity,
            isTop = db.position.anchorto:find("TOP"),
            isLeft = db.position.anchorto:find("LEFT"),
        }
    end

    return mapPoints
end

-- Set Info text/button positions
function MinimapAdv:UpdateInfoPosition()
    self:debug("UpdateInfoPosition")
    self.numText = 1
    if _G.Minimap:IsVisible() and (ExpandedState == 0) then
        local mapPoints = GetPositionData()
        local isTop = mapPoints.isTop
        local isLeft = mapPoints.isLeft
        local numText = self.numText

        -- Set Offsets, Positions, Gaps
        local yofs, justify
        local rpoint, point, Cpoint
        if isTop then
            yofs = -db.information.gap
            point = "TOP"
            rpoint = "BOTTOM"
            Cpoint = "BOTTOM"
        else
            yofs = db.information.gap
            point = "BOTTOM"
            rpoint = "TOP"
            Cpoint = "TOP"
        end
        if isLeft then
            justify = "LEFT"
            point = point .. "LEFT"
            rpoint = rpoint .. "LEFT"
            Cpoint = Cpoint .. "LEFT"
        else
            justify = "RIGHT"
            point = point .. "RIGHT"
            rpoint = rpoint .. "RIGHT"
            Cpoint = Cpoint .. "RIGHT"
        end

        -- Zone Indicator
        if MMFrames.info.zoneIndicator.isHostile then
            MMFrames.info.zoneIndicator:Show()
        else
            MMFrames.info.zoneIndicator:Hide()
        end

        ---- Info List
        local prevFrame = _G.Minimap
        for i = 1, #infoTexts do
            local info = infoTexts[i]
            local infoText = MMFrames.info[info.type]
            if info.shown then
                infoText:ClearAllPoints()
                if info.type == "Coords" then
                    infoText:SetPoint(Cpoint, _G.Minimap, Cpoint, 0, 0)
                else
                    infoText:SetPoint(point, prevFrame, rpoint, 0, yofs)
                    prevFrame = infoText
                    numText = numText + 1
                end
                infoText.text:SetJustifyH(justify)
                infoText:Show()
            else
                infoText:Hide()
            end
        end
        MMFrames.info.lastFrame = prevFrame

        if (_G.IsAddOnLoaded("Blizzard_CompactRaidFrames") and mapPoints.anchor == "TOPLEFT") then
            self:AdjustCRFManager(_G["CompactRaidFrameManager"], mapPoints)
            if not self.hookedCRFM then
                _G["CompactRaidFrameManager"]:SetFrameLevel(20)
                _G.hooksecurefunc("CompactRaidFrameManager_Toggle", function(CRFM)
                    self:AdjustCRFManager(CRFM, GetPositionData())
                end)
                if db.information.hideRaidFilters then
                    -- These buttons are only relevant if using the Blizzard frames
                    _G.SetRaidProfileOption(_G.GetActiveRaidProfile(), "shown", false); _G.CompactRaidFrameManager_SetSetting("IsShown", false) -- Hide CRF
                    _G.SetRaidProfileOption(_G.GetActiveRaidProfile(), "locked", true); _G.CompactRaidFrameManager_SetSetting("Locked", true) -- Lock CRF
                    _G.hooksecurefunc("CompactRaidFrameManager_UpdateOptionsFlowContainer", function(CRFM)
                        self:debug("AdjustCRFManager", _G.InCombatLockdown())
                        if _G.InCombatLockdown() then
                            return
                        end
                        local container = CRFM.displayFrame.optionsFlowContainer
                        _G.FlowContainer_PauseUpdates(container)

                        _G.FlowContainer_RemoveObject(container, CRFM.displayFrame.profileSelector)
                        CRFM.displayFrame.profileSelector:Hide()
                        _G.FlowContainer_RemoveObject(container, CRFM.displayFrame.filterOptions)
                        CRFM.displayFrame.filterOptions:Hide()
                        _G.FlowContainer_RemoveObject(container, CRFM.displayFrame.lockedModeToggle)
                        CRFM.displayFrame.lockedModeToggle:Hide()
                        _G.FlowContainer_RemoveObject(container, CRFM.displayFrame.hiddenModeToggle)
                        CRFM.displayFrame.hiddenModeToggle:Hide()

                        _G.FlowContainer_ResumeUpdates(container);
                        
                        local _, usedY = _G.FlowContainer_GetUsedBounds(container);
                        CRFM:SetHeight(usedY + 40);
                    end)
                end
                self.hookedCRFM = true
            end
        end
    else
        MMFrames.info.Location:Hide()
        MMFrames.info.Coords:Hide()
        MMFrames.info.DungeonDifficulty:Hide()
        MMFrames.info.LootSpec:Hide()
        MMFrames.info.LFG:Hide()
        MMFrames.info.Queue:Hide()
        MMFrames.info.RFQueue:Hide()
        MMFrames.info.SQueue:Hide()
        MMFrames.info.zoneIndicator:Hide()
    end
end

function MinimapAdv:AdjustCRFManager(CRFM, mapPoints)
    self:debug("AdjustCRFManager", (_G.InCombatLockdown() or mapPoints.anchor ~= "TOPLEFT"))
    if (_G.InCombatLockdown() or mapPoints.anchor ~= "TOPLEFT") then
        return
    end
    local screenH = _G.UIParent:GetHeight()
    local bottom = MMFrames.info.lastFrame:GetBottom()
    local show = _G.UnitIsGroupLeader("player") or _G.UnitIsGroupAssistant("player") or not db.information.hideRaidFilters
    self:debug("yOfs", bottom, mapPoints.scale, db.information.gap)
    local yofs = ((bottom and bottom * mapPoints.scale or screenH * 0.85) - screenH) - db.information.gap
    if CRFM.collapsed then
        CRFM:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", show and -182 or -200, yofs)
    else
        CRFM:SetPoint("TOPLEFT", _G.UIParent, "TOPLEFT", show and -7 or -200, yofs)
    end
end


-- Set Button positions
function MinimapAdv:UpdateButtonsPosition()
    self:debug("UpdateButtonsPosition")
    local mapPoints = GetPositionData()

    local anchor = mapPoints.anchor
    local scale = mapPoints.scale
    local isTop = mapPoints.isTop
    local isLeft = mapPoints.isLeft
    local frameOrder = {
        "toggle",
    }

    -- Set visibility for Normal or Farm Mode
    local bfWidth = 21

    -- Config
    if _G.Minimap:IsVisible() then
        MMFrames.config:Show()
        _G.tinsert(frameOrder, "config")
        bfWidth = bfWidth + 15
    else
        MMFrames.config:Hide()
        MMFrames.config.mouseover = false
    end

    -- Tracking
    if _G.Minimap:IsVisible() and ExpandedState == 0 then
        MMFrames.tracking:Show()
        _G.tinsert(frameOrder, "tracking")
        bfWidth = bfWidth + 15
    else
        MMFrames.tracking:Hide()
        MMFrames.tracking.mouseover = false
    end

    -- Farm mode
    if ( _G.Minimap:IsVisible() and (not _G.IsInInstance()) ) then
        MMFrames.farm:Show()
        _G.tinsert(frameOrder, "farm")
        bfWidth = bfWidth + 15
    else
        MMFrames.farm:Hide()
        MMFrames.farm.mouseover = false
    end

    -- Set button positions
    MMFrames.buttonframe:ClearAllPoints()
    MMFrames.buttonframe:SetPoint(anchor, "Minimap", isLeft and 1 or -1, isTop and -1 or 1)
    MMFrames.buttonframe:SetScale(1)
    MMFrames.buttonframe:Show()

    if isLeft then
        local prevFrame = MMFrames.buttonframe.edge
        prevFrame:ClearAllPoints()
        prevFrame:SetPoint("LEFT", MMFrames.buttonframe, 1, 0)
        for i = 1, #frameOrder do
            --print("Left", frameOrder[i])
            local frame = MMFrames[frameOrder[i]]
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT", 0, 0)
            prevFrame = frame
        end
        MMFrames.buttonframe.tooltip:ClearAllPoints()
        MMFrames.buttonframe.tooltip:SetPoint("TOPLEFT", prevFrame, "TOPRIGHT", 9, -3)
    else
        local prevFrame = MMFrames.buttonframe.edge
        prevFrame:ClearAllPoints()
        prevFrame:SetPoint("RIGHT", MMFrames.buttonframe, -1, 0)
        for i = 1, #frameOrder do
            --print("Right", frameOrder[i])
            local frame = MMFrames[frameOrder[i]]
            frame:ClearAllPoints()
            frame:SetPoint("TOPRIGHT", prevFrame, "TOPLEFT", 0, 0)
            prevFrame = frame
        end
        MMFrames.buttonframe.tooltip:ClearAllPoints()
        MMFrames.buttonframe.tooltip:SetPoint("TOPRIGHT", prevFrame, "TOPLEFT", 0, -3)
    end

    if MMFrames.buttonframe.tooltip:IsShown() then
        MMFrames.buttonframe:SetWidth(_G.Minimap:GetWidth() * scale + 2)
    else
        MMFrames.buttonframe:SetWidth(bfWidth)
    end

    self:FadeButtons()
end

-- Set Minimap position
function MinimapAdv:UpdateMinimapPosition()
    self:debug("UpdateMinimapPosition")
    local mapPoints = GetPositionData()

    local xofs = mapPoints.xofs
    local yofs = mapPoints.yofs
    local anchor = mapPoints.anchor
    local scale = mapPoints.scale
    local opacity = mapPoints.opacity
    local isTop = mapPoints.isTop
    local isLeft = mapPoints.isLeft

    -- Set new size and position
    _G.Minimap:SetFrameStrata("LOW")
    _G.Minimap:SetFrameLevel(1)

    _G.Minimap:SetSize(db.position.size, db.position.size)
    _G.Minimap:SetScale(scale)
    _G.Minimap:SetAlpha(opacity)

    _G.Minimap:SetMovable(true)
    _G.Minimap:ClearAllPoints()
    _G.Minimap:SetPoint(anchor, "UIParent", anchor, xofs, yofs)
    _G.Minimap:SetUserPlaced(true)

    -- Kinda dirty, but it works
    local LFDrpoint, LFDpoint, Qpoint, Gpoint
    if isTop then
        LFDpoint = "TOP"
        LFDrpoint = "TOP"
        Qpoint = "BOTTOM"
        Gpoint = "TOP"
    else
        LFDpoint = "BOTTOM"
        LFDrpoint = "BOTTOM"
        Qpoint = "TOP"
        Gpoint = "BOTTOM"
    end
    if isLeft then
        LFDpoint = LFDpoint .. "LEFT"
        LFDrpoint = LFDrpoint .. "RIGHT"
        Qpoint = Qpoint .. "RIGHT"
        Gpoint = Gpoint .. "RIGHT"
    else
        LFDpoint = LFDpoint .. "RIGHT"
        LFDrpoint = LFDrpoint .. "LEFT"
        Qpoint = Qpoint .. "LEFT"
        Gpoint = Gpoint .. "LEFT"
    end

    -- Queue Status
    _G.QueueStatusMinimapButton:ClearAllPoints()
    _G.QueueStatusMinimapButton:SetPoint(Qpoint, isLeft and 2 or -2, isTop and -2 or 2)

    -- LFD Button Tooltip
    _G.QueueStatusFrame:ClearAllPoints()
    _G.QueueStatusFrame:SetPoint(LFDpoint, "QueueStatusMinimapButton", LFDrpoint)
    _G.QueueStatusFrame:SetClampedToScreen(true)

    -- Garrisons
    _G.GarrisonLandingPageMinimapButton:ClearAllPoints()
    _G.GarrisonLandingPageMinimapButton:SetPoint(Gpoint, isLeft and 2 or -2, isTop and 2 or -2)

    _G.GarrisonLandingPageTutorialBox:ClearAllPoints()
    _G.GarrisonLandingPageTutorialBox.Arrow:ClearAllPoints()
    if isTop then
        _G.GarrisonLandingPageTutorialBox:SetPoint("TOP", _G.GarrisonLandingPageMinimapButton, "BOTTOM", 0, -20)
        _G.GarrisonLandingPageTutorialBox.Arrow:SetPoint("BOTTOM", _G.GarrisonLandingPageTutorialBox, "TOP", 0, -3)
        _G.SetClampedTextureRotation(_G.GarrisonLandingPageTutorialBox.Arrow, 180)
    else
        _G.GarrisonLandingPageTutorialBox:SetPoint("BOTTOM", _G.GarrisonLandingPageMinimapButton, "TOP", 0, 20)
        _G.GarrisonLandingPageTutorialBox.Arrow:SetPoint("TOP", _G.GarrisonLandingPageTutorialBox, "BOTTOM", 0, 3)
        _G.SetClampedTextureRotation(_G.GarrisonLandingPageTutorialBox.Arrow, 0)
    end

    _G.ButtonCollectFrame:ClearAllPoints()
    if isTop then
        _G.ButtonCollectFrame:SetPoint("TOPLEFT", _G.Minimap, "BOTTOMLEFT", -1, -5)
    else
        _G.ButtonCollectFrame:SetPoint("BOTTOMLEFT", _G.Minimap, "TOPLEFT", -1, 5)
    end

    -- Update the rest of the Minimap
    self:UpdateButtonsPosition()
    self:UpdateInfoPosition()
    self:UpdateClickthrough()
end

---------------------
-- MINIMAP BUTTONS --
---------------------
local BlackList = {
    ["QueueStatusMinimapButton"] = true,
    ["GarrisonLandingPageMinimapButton"] = true,
    ["MiniMapTracking"] = true,
    ["MiniMapMailFrame"] = true,
    ["HelpOpenTicketButton"] = true,
    ["GameTimeFrame"] = true,
}
local OddList = {
    ["BagSync_MinimapButton"] = true,
    ["OutfitterMinimapButton"] = true,
}

local buttons = {}
local button = _G.CreateFrame("Frame", "ButtonCollectFrame", _G.UIParent)
button:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1,
})
button:SetBackdropBorderColor(0, 0, 0)
button:SetBackdropColor(0, 0, 0, .5)
button:SetPoint("TOPLEFT", _G.Minimap, "BOTTOMLEFT", -1, -5)
button:SetSize(136, 32)
button:SetFrameStrata("LOW")
button:SetFrameLevel(10)
button:EnableMouse(true)
button:SetAlpha(0)
button:Show()
button:HookScript("OnEnter", fadeIn)
button:HookScript("OnLeave", fadeOut)
local line = _G.floor(button:GetWidth() / 32)

local function PositionAndStyle()
    local row = 0
    for i = 1, #buttons do
        if not buttons[i].styled then
            buttons[i]:SetParent(button)
            buttons[i]:ClearAllPoints()
            --print("Eval", i, i + line - 1, _G.floor(row+1) * line, row)
            if i + line - 1 == _G.floor(row + 1) * line then
                --print("Row start", i)
                buttons[i]:SetPoint("TOPLEFT", button, "TOPLEFT", 0, -(row * 32))
            else
                --print("Row cont.", i)
                buttons[i]:SetPoint("TOPLEFT", buttons[i - 1], "TOPRIGHT", 2, 0)
            end
            row = i / line
            buttons[i].ClearAllPoints = function() return end
            buttons[i].SetPoint = function() return end
            buttons[i]:HookScript("OnEnter", function() fadeIn(button) end)
            buttons[i]:HookScript("OnLeave", function() fadeOut(button) end)
            buttons[i].styled = true
        end
    end
    button:SetHeight(_G.ceil(row) * 32)
end

local function MoveMMButton(mmb)
    if not mmb then return end
    if mmb.mmStyled then return end

    mmb:SetParent(button)
    _G.tinsert(buttons, mmb)
    mmb.mmStyled = true
end

local function UpdateMMButtonsTable()
    for i, child in next, {_G.Minimap:GetChildren()} do
        if not(BlackList[child:GetName()]) then
            if (child:GetObjectType() == "Button") and child:GetNumRegions() >= 3 and child:IsShown() then
                MoveMMButton(child)
            end
        end
    end
    for f, _ in next, OddList do
        MoveMMButton(_G[f])
    end

    if #buttons == 0 then
        button:Hide()
    else
        button:Show()
    end
end

local collect = _G.CreateFrame("Frame")
collect:RegisterEvent("PLAYER_ENTERING_WORLD")
collect:SetScript("OnEvent", function(self, event)
    self:UnregisterEvent(event)
    if db.information.minimapbuttons then
        UpdateMMButtonsTable()
        PositionAndStyle()
    end
end)

-------------------------
-- INFORMATION UPDATES --
-------------------------
---- POI ----
-- POI Frame events
-- Show Tooltip
local POITooltip = _G.CreateFrame("GameTooltip", "QuestPointerTooltip", _G.UIParent, "GameTooltipTemplate")
local function POI_OnEnter(self)
    -- Set Tooltip's parent
    if _G.UIParent:IsVisible() then
        POITooltip:SetParent(_G.UIParent)
    else
        POITooltip:SetParent(self)
    end

    -- Set Tooltip position
    local mapPoints = GetPositionData()
    local mm_anchor = mapPoints.anchor
    if mm_anchor == "TOPLEFT" then
        POITooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, -10)
    elseif mm_anchor == "BOTTOMLEFT" then
        POITooltip:SetOwner(self, "ANCHOR_TOPMRIGHT", 5, 5)
    end

    -- Add Hyperlink
    local link = _G.GetQuestLink(self.questLogIndex)
    if link then
        POITooltip:SetHyperlink(link)
    end

    if _G.Aurora then
        _G.Aurora[1].SetBD(POITooltip)
    end
end

-- Hide Tooltip
local function POI_OnLeave(self)
    POITooltip:Hide()
end

-- Open World Map at appropriate quest
local function POI_OnMouseUp(self)
    _G.WorldMapFrame:Show()
    local frame = _G["WorldMapQuestFrame"..self.index]
    if not frame then
        return
    end
    _G.WorldMapFrame_SelectQuestFrame(frame)
    MinimapAdv:SelectSpecificPOI(self)
end

-- Find closest POI
function MinimapAdv:ClosestPOI(all)
    local _, closest, closest_distance, poi_distance
    for k, poi in next, self.pois do
        if poi.active then
            _, poi_distance = HBDP:GetVectorToIcon(poi)

            if closest then
                if ( poi_distance and closest_distance and (poi_distance < closest_distance) ) then
                    closest = poi
                    closest_distance = poi_distance
                end
            else
                closest = poi
                closest_distance = poi_distance
            end
        end
    end
    return closest
end

function MinimapAdv:SelectSpecificPOI(poi)
    _G.QuestPOI_SelectButton(poi.poiButton)
    _G.SetSuperTrackedQuestID(poi.questId)
    MinimapAdv:UpdatePOIGlow()
end

-- Select Closest POI
function MinimapAdv:SelectClosestPOI()
    if not db.poi.enabled then return end
    if _G.IsAddOnLoaded("Carbonite") or _G.IsAddOnLoaded("DugisGuideViewerZ") then return end

    local closest = self:ClosestPOI()
    if closest then
        self:SelectSpecificPOI(closest)
    end
end

-- Update POI at edge of Minimap
function MinimapAdv:UpdatePOIEdges()
    for id, poi in next, pois do
        if poi.active then
            if HBDP:IsMinimapIconOnEdge(poi) then
                poi.poiButton:Show()
                poi.poiButton:SetAlpha(db.poi.icons.opacity * (db.poi.fadeEdge and 0.6 or 1))
            else
                -- Hide completed POIs when close enough to see the ?
                if poi.complete then
                    poi.poiButton:Hide()
                else
                    poi.poiButton:Show()
                end
                poi.poiButton:SetAlpha(db.poi.icons.opacity)
            end
        end
    end
end

-- Update POI highlight
function MinimapAdv:UpdatePOIGlow()
    for i, poi in next, pois do
        if _G.GetSuperTrackedQuestID() == poi.questId then
            _G.QuestPOI_SelectButton(poi.poiButton)
            poi:SetFrameLevel(_G.Minimap:GetFrameLevel() + 3)
        else
            _G.QuestPOI_ClearSelection(_G.Minimap)
            poi:SetFrameLevel(_G.Minimap:GetFrameLevel() + 2)
        end
    end
end

function MinimapAdv:RemoveAllPOIs()
    for i, poi in next, pois do
        HBDP:RemoveMinimapIcon(poi)
        if poi.poiButton then
            poi.poiButton:Hide()
            poi.poiButton:SetParent(_G.Minimap)
            poi.poiButton = nil
        end
        poi.active = false
    end
end

-- Update all POIs
function MinimapAdv:POIUpdate(...)
    self:debug("POIUpdate", ...)
    if ( (not db.poi.enabled) or (ExpandedState == 1 and db.expand.extras.hidepoi) ) then return end
    if _G.IsAddOnLoaded("Carbonite") or _G.IsAddOnLoaded("DugisGuideViewerZ") then return end

    self:RemoveAllPOIs()

    local mapID, mapFloor = HBD:GetPlayerZone()

    -- Update was probably triggered by World Map browsing. Don't update any POIs.
    if not (mapID and mapFloor) then return end

    _G.QuestPOIUpdateIcons()

    local numNumericQuests = 0
    local numCompletedQuests = 0
    local numEntries = _G.QuestMapUpdateAllQuests()
    -- Iterate through all available quests, retrieving POI info
    for i = 1, numEntries do
        local questID, questLogIndex = _G.QuestPOIGetQuestIDByVisibleIndex(i)
        if questID then
            local _, posX, posY = _G.QuestPOIGetIconInfo(questID)
            if ( posX and posY and (_G.IsQuestWatched(questLogIndex) or not db.poi.watchedOnly) ) then
                local title, _, _, _, _, isComplete, _, _, _, _, _, _, _, isStory = _G.GetQuestLogTitle(questLogIndex)
                local numObjectives = _G.GetNumQuestLeaderBoards(questLogIndex)
                if isComplete and isComplete < 0 then
                    isComplete = false
                elseif numObjectives == 0 then
                    isComplete = true
                end

                -- Create POI arrow
                local poi = pois[i]
                if not poi then
                    poi = _G.CreateFrame("Frame", "QuestPointerPOI"..i, _G.Minimap)
                    poi:SetFrameLevel(_G.Minimap:GetFrameLevel() + 2)
                    poi:SetWidth(10)
                    poi:SetHeight(10)
                    poi:SetScript("OnEnter", POI_OnEnter)
                    poi:SetScript("OnLeave", POI_OnLeave)
                    poi:SetScript("OnMouseUp", POI_OnMouseUp)
                    poi:EnableMouse()
                end

                -- Create POI button
                local poiButton
                if isComplete then
                    -- Using QUEST_POI_COMPLETE_SWAP gets the ? without any circle
                    -- Using QUEST_POI_COMPLETE_IN gets the ? in a brownish circle
                    numCompletedQuests = numCompletedQuests + 1
                    poiButton = _G.QuestPOI_GetButton(_G.Minimap, questID)--, "completed", numCompletedQuests)
                else
                    numNumericQuests = numNumericQuests + 1
                    poiButton = _G.QuestPOI_GetButton(_G.Minimap, questID, "numeric", numNumericQuests, isStory)
                end
                poiButton:SetPoint("CENTER", poi)
                poiButton:SetScale(db.poi.icons.scale)
                poiButton:SetParent(poi)
                poiButton:EnableMouse(false)
                poi.poiButton = poiButton

                poi.index = i
                poi.questID = questID
                poi.questLogIndex = questLogIndex
                poi.mapID = mapID
                poi.mapFloor = mapFloor
                poi.x = posX
                poi.y = posY
                poi.title = title
                poi.active = true
                poi.complete = isComplete

                HBDP:AddMinimapIconMF(self, poi, mapID, mapFloor, posX, posY, true)

                pois[i] = poi
            end
        end
    end
    self:UpdatePOIEdges()
    self:UpdatePOIGlow()
end

function MinimapAdv:InitializePOI()
    -- Update POI timer
    local GlowTimer = _G.CreateFrame("Frame")
    GlowTimer.elapsed = 0
    GlowTimer:SetScript("OnUpdate", function(timer, elapsed)
        timer.elapsed = timer.elapsed + elapsed
        if ( (timer.elapsed > 2) and (not _G.WorldMapFrame:IsShown()) and db.poi.enabled ) then
            timer.elapsed = 0
            MinimapAdv:UpdatePOIGlow()
        end
    end)
end

function MinimapAdv:UpdatePOIEnabled()
    if db.poi.enabled and not(_G.IsAddOnLoaded("Carbonite") or _G.IsAddOnLoaded("DugisGuideViewerZ")) then
        _G.QuestPOI_Initialize(_G.Minimap, function() end)
        self:POIUpdate()
        self:InitializePOI()
    else
        self:RemoveAllPOIs()
    end
end

function MinimapAdv:GetLFGList(event, arg)
    self:debug("GetLFGList", event, arg)
    if not arg then
        infoTexts.LFG.shown = false
    else
        local _, _, _, _, _, _, _, autoAccept = _G.C_LFGList.GetActiveEntryInfo()
        local status
        if autoAccept then
            status = _G.LFG_LIST_AUTO_ACCEPT
        else
            local _, numActiveApplicants = _G.C_LFGList.GetNumApplicants()
            status = _G.LFG_LIST_PENDING_APPLICANTS:format(numActiveApplicants)
        end
        local colorOrange = RealUI:ColorTableToStr(RealUI.media.colors.orange)
        MMFrames.info.LFG.text:SetText("|cff"..colorOrange.."LFG:|r "..status)
        MMFrames.info.LFG:SetHeight(MMFrames.info.LFG.text:GetStringHeight())
        infoTexts.LFG.shown = true
    end
    if not UpdateProcessing then
        self:UpdateInfoPosition()
    end
end

function MinimapAdv:GetLFGQueue(event, ...)
    self:debug("GetLFGQueue", event, ...)
    -- Reset shown status
    infoTexts.Queue.shown = false
    infoTexts.RFQueue.shown = false
    infoTexts.SQueue.shown = false
    for category = 1, _G.NUM_LE_LFG_CATEGORYS do
        local mode = _G.GetLFGMode(category)
        self:debug("LFGQueue", category, mode)
        if mode and mode == "queued" then
            local queueStr
            local hasData, _, _, _, _, _, _, _, _, _, _, _, _, _, _, myWait, queuedTime = _G.GetLFGQueueStats(category)

            if not hasData then
                queueStr = _G.LESS_THAN_ONE_MINUTE
            else
                local elapsedTime = _G.GetTime() - queuedTime
                local tiqStr = ("%s"):format(ConvertSecondstoTime(elapsedTime))
                local awtStr = ("%s"):format(myWait == -1 and _G.TIME_UNKNOWN or _G.SecondsToTime(myWait, false, false, 1))
                queueStr = ("%s |cffc0c0c0(%s)|r"):format(tiqStr, awtStr)
            end

            local colorOrange = RealUI:ColorTableToStr(RealUI.media.colors.orange)
            if category == 1 then -- Dungeon Finder
                MMFrames.info.Queue.text:SetFormattedText("|cff%sDF:|r ", colorOrange, queueStr)
                MMFrames.info.Queue:SetHeight(MMFrames.info.Queue.text:GetStringHeight())
                infoTexts.Queue.shown = true
            elseif category == 3 then -- Raid Finder
                MMFrames.info.RFQueue.text:SetFormattedText("|cff%sRF:|r ", colorOrange, queueStr)
                MMFrames.info.RFQueue:SetHeight(MMFrames.info.RFQueue.text:GetStringHeight())
                infoTexts.RFQueue.shown = true
            elseif category == 4 then -- Scenarios
                MMFrames.info.SQueue.text:SetFormattedText("|cff%sS:|r ", colorOrange, queueStr)
                MMFrames.info.SQueue:SetHeight(MMFrames.info.SQueue.text:GetStringHeight())
                infoTexts.SQueue.shown = true
            end
        end
    end
    if not UpdateProcessing then
        self:UpdateInfoPosition()
    end
end

--[[ Dungeon Difficulty ----
    ID - "Name"
    1  - "Normal"
    2  - "Heroic"
    3  - "10 Player"
    4  - "25 Player"
    5  - "10 Player (Heroic)"
    6  - "25 Player (Heroic)"
    7  - "Looking For Raid"
    8  - "Challenge Mode"
    9  - "40 Player"
    10 - nil
    11 - "Heroic Scenario"
    12 - "Normal Scenario"
    13 - nil
    14 - "Normal"  10-30 Player
    15 - "Heroic"  10-30 Player
    16 - "Mythic"  20 Player
    17 - "Looking For Raid" 10-25 Player
]]--
function MinimapAdv:DungeonDifficultyUpdate()
    self:debug("DungeonDifficultyUpdate")
    -- If in a Party/Raid then show Dungeon Difficulty text
    MMFrames.info.DungeonDifficulty.text:SetText("")
    local instanceName, instanceType, difficulty, _, maxPlayers, _, _, _, currPlayers = _G.GetInstanceInfo()
    local _, _, isHeroic, isChallengeMode = _G.GetDifficultyInfo(difficulty)
    self:debug("instanceType", instanceType)
    if instanceType ~= "none" and not instanceName:find("Garrison") then
        if (instanceType == "party" or instanceType == "scenario") and (maxPlayers <= 5) then
            self.DifficultyText = "D: "..maxPlayers
            if isChallengeMode then self.DifficultyText = self.DifficultyText.."+" end
        elseif (instanceType == "raid") then
            self.DifficultyText = "R: "

            --Set raid size
            if (difficulty <= 9) or (difficulty == 16) then
                --Legacy raids and Mythic are fixed size
                self.DifficultyText = self.DifficultyText..maxPlayers
            else
                --Current Normal, Heroic, and LFR are flexible
                self.DifficultyText = self.DifficultyText..currPlayers
            end

            --Give Mythic double "+" because it's #Hardcore
            if (difficulty == 16) then
                --Mythic gets the isHeroic flag
                self.DifficultyText = self.DifficultyText.."+"
            elseif (difficulty == 15) then
                --Heroic does not
                self.DifficultyText = self.DifficultyText.."+"
            end
        else
            self.DifficultyText = "PvP: "
            if (instanceType == "arena") then
                self.DifficultyText = self.DifficultyText..currPlayers
            else
                self.DifficultyText = self.DifficultyText..maxPlayers
            end
        end

        if isHeroic then self.DifficultyText = self.DifficultyText.."+" end

        -- Update Frames
        MMFrames.info.DungeonDifficulty.text:SetText(self.DifficultyText.." ")
        MMFrames.info.DungeonDifficulty:EnableMouse(true)
        MMFrames.info.DungeonDifficulty:SetHeight(MMFrames.info.DungeonDifficulty.text:GetStringHeight())

        -- Set to show DungeonDifficulty
        infoTexts.DungeonDifficulty.shown = true
    else
        self.DifficultyText = ""
        -- Set to hide DungeonDifficulty
        infoTexts.DungeonDifficulty.shown = false
    end
    if self.IsGuildGroup then
        self.DifficultyText = self.DifficultyText.."(".._G.GUILD..")"
        MMFrames.info.DungeonDifficulty:SetScript("OnEnter", function(diffFrame)
            local guildName = _G.GetGuildInfo("player")
            local _, _, numGuildRequired = _G.InGuildParty()
            if instanceType == "arena" then
                maxPlayers = numGuildRequired
            end
            _G.GameTooltip:SetOwner(diffFrame, "ANCHOR_RIGHT", 18)
            _G.GameTooltip:SetText(_G.GUILD_GROUP, 1, 1, 1)
            _G.GameTooltip:AddLine(_G.GUILD_ACHIEVEMENTS_ELIGIBLE:format(numGuildRequired, maxPlayers, guildName), nil, nil, nil, 1)
            _G.GameTooltip:Show()
        end)
        MMFrames.info.DungeonDifficulty:SetScript("OnLeave", function()
            if _G.GameTooltip:IsShown() then _G.GameTooltip:Hide() end
        end)
    else
        MMFrames.info.DungeonDifficulty:SetScript("OnEnter", nil)
    end

    -- Loot Spec
    self:LootSpecUpdate()

    if not UpdateProcessing then
        self:UpdateInfoPosition()
    end
end

function MinimapAdv:UpdateGuildPartyState(event, ...)
    self:debug("UpdateGuildPartyState", event, ...)
    -- Update Guild info and then update Dungeon Difficulty
    if event == "GUILD_PARTY_STATE_UPDATED" then
        local isGuildGroup = ...
        if isGuildGroup ~= self.IsGuildGroup then
            self.IsGuildGroup = isGuildGroup
            self:DungeonDifficultyUpdate()
        end
    else
        if _G.IsInGuild() then
            _G.RequestGuildPartyState()
        else
            self.IsGuildGroup = nil
        end
    end
end

function MinimapAdv:InstanceDifficultyOnEvent(event, ...)
    self:debug("InstanceDifficultyOnEvent", event, ...)
    self:DungeonDifficultyUpdate()
end

---- Loot Specialization ----
function MinimapAdv:LootSpecUpdate()
    self:debug("LootSpecUpdate")
    -- If in a Dungeon, Raid or Garrison show Loot Spec
    local _, instanceType = _G.GetInstanceInfo()
    if (instanceType == "party" or instanceType == "raid") then
        MMFrames.info.LootSpec.text:SetText("|cff"..RealUI:ColorTableToStr(RealUI.media.colors.blue).._G.LOOT..":|r "..RealUI:GetCurrentLootSpecName())
        MMFrames.info.LootSpec:SetHeight(MMFrames.info.LootSpec.text:GetStringHeight())
        infoTexts.LootSpec.shown = true
    else
        MMFrames.info.LootSpec.text:SetText("")
        infoTexts.LootSpec.shown = false
    end
end


---- Coordinates ----
local coords_int = 0.5
function MinimapAdv:CoordsUpdate()
    self:debug("CoordsUpdate")
    if (_G.IsInInstance() or not(_G.Minimap:IsVisible()) or self.StationaryTime >= 10) then   -- Hide Coords
        MMFrames.info.Coords:SetScript("OnUpdate", nil)
        infoTexts.Coords.shown = false
    else    -- Show Coords
        MMFrames.info.Coords:SetScript("OnUpdate", function(coordsFrame, elapsed)
            coords_int = coords_int - elapsed
            if (coords_int <= 0) then
                local X, Y = _G.GetPlayerMapPosition("player")
                coordsFrame.text:SetText(("%.1f  %.1f"):format(X*100, Y*100))
                coordsFrame:SetHeight(coordsFrame.text:GetStringHeight())
                coords_int = 0.5
            end
        end)
        infoTexts.Coords.shown = true
    end
    if not UpdateProcessing then self:UpdateInfoPosition() end
end

---------------------
-- MINIMAP UPDATES --
---------------------
function MinimapAdv:MovementUpdate()
    self:debug("MovementUpdate")
    if not(db.information.coordDelayHide) or _G.IsInInstance() or not(_G.Minimap:IsVisible()) then return end

    local X, Y = _G.GetPlayerMapPosition("player")
    if X == self.LastX and Y == self.LastY then
        self.StationaryTime = self.StationaryTime + 0.5
    else
        self.StationaryTime = 0
    end
    self.LastX = X
    self.LastY = Y

    if ((self.StationaryTime >= 10) and (infoTexts.Coords.shown)) or ((self.StationaryTime < 10) and not(infoTexts.Coords.shown)) then
        self:CoordsUpdate()
    end
end

function MinimapAdv:Update()
    UpdateProcessing = true     -- Stops individual update functions from calling UpdateInfoPosition
    self:CoordsUpdate()
    self:DungeonDifficultyUpdate()
    self:UpdateButtonsPosition()
    UpdateProcessing = false
end

-- Set Minimap visibility
function MinimapAdv:Toggle(shown)
    if shown then
        _G.Minimap:Show()
        MMFrames.toggle.icon:SetTexture(Textures.Minimize)
    else
        _G.Minimap:Hide()
        MMFrames.toggle.icon:SetTexture(Textures.Maximize)
    end
    self:Update()
end

-- Determine what visibility state the Minimap should be in
function MinimapAdv:UpdateShownState()
    local Inst, InstType = _G.IsInInstance()
    local MinimapShown = true
    if Inst then
        if db.hidden.enabled then
            if (InstType == "pvp" and db.hidden.zones.pvp) then         -- Battlegrounds
                MinimapShown = false
            elseif (InstType == "arena" and db.hidden.zones.arena) then -- Arena
                MinimapShown = false
            elseif (InstType == "party" and db.hidden.zones.party) then -- 5 Man Dungeons
                MinimapShown = false
            elseif (InstType == "raid" and db.hidden.zones.raid) then   -- Raid Dungeons
                MinimapShown = false
            end
        end

        -- Disable Farm Mode while in dungeon
        if ExpandedState ~= 0 then
            ExpandedState = 0
            self:ToggleGatherer()
            self:UpdateMinimapPosition()
        end
    end
    self:Toggle(MinimapShown)
end


-------------
-- BUTTONS --
-------------
---- Fade
function MinimapAdv:FadeButtons()
    local mapPoints = GetPositionData()
    local scale = mapPoints.scale

    if _G.Minimap:IsVisible() then
        if _G.Minimap.mouseover or MMFrames.toggle.mouseover or MMFrames.config.mouseover or MMFrames.tracking.mouseover or MMFrames.farm.mouseover then
            local numButtons = 2

            if ExpandedState == 0 then
                MMFrames.tracking:Show()
                numButtons = numButtons + 1
            end
            if not _G.IsInInstance() then
                MMFrames.farm:Show()
                numButtons = numButtons + 1
            end

            if MMFrames.buttonframe.tooltip:IsShown() and (ExpandedState == 0) then
                MMFrames.buttonframe:SetWidth(_G.Minimap:GetWidth() * scale + 2)
            else
                MMFrames.buttonframe.tooltip:Hide()
                MMFrames.buttonframe.tooltipIcon:Hide()
                MMFrames.buttonframe:SetWidth(6 + numButtons * 15)
            end

            MMFrames.buttonframe:Show()
        else
            MMFrames.buttonframe:Hide()
            MMFrames.tracking:Hide()
            MMFrames.farm:Hide()
        end
    end
end

---- Toggle Button ----
local function Toggle_OnMouseDown()
    local MinimapShown = _G.Minimap:IsVisible()
    if MinimapShown then
        _G.PlaySound("igMiniMapClose")
        MinimapAdv:Toggle(false)
    else
        _G.PlaySound("igMiniMapOpen")
        MinimapAdv:Toggle(true)
    end
    if _G.DropDownList1 then _G.DropDownList1:Hide() end
    if _G.DropDownList2 then _G.DropDownList2:Hide() end
end

function MinimapAdv:ToggleBind()
    Toggle_OnMouseDown()
end

local function Toggle_OnEnter()
    MMFrames.toggle.mouseover = true

    MMFrames.toggle.icon:SetVertexColor(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
    MMFrames.toggle:SetFrameLevel(6)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()
end

local function Toggle_OnLeave()
    MMFrames.toggle.mouseover = false

    MMFrames.toggle.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.toggle:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()
end

---- Config Button ----
local function Config_OnMouseDown()
    RealUI:LoadConfig("RealUI", "modules", "MinimapAdv")

    if _G.DropDownList1 then _G.DropDownList1:Hide() end
    if _G.DropDownList2 then _G.DropDownList2:Hide() end
end

local function Config_OnEnter()
    MMFrames.config.mouseover = true

    MMFrames.config.icon:SetVertexColor(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
    MMFrames.config:SetFrameLevel(6)

    if ExpandedState == 0 then
        MMFrames.buttonframe.tooltip:SetText("Options")
        MMFrames.buttonframe.tooltip:Show()
        MMFrames.buttonframe.tooltipIcon:Show()
    end

    MinimapAdv:FadeButtons()
end

local function Config_OnLeave()
    MMFrames.config.mouseover = false

    MMFrames.config.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.config:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()

    if _G.GameTooltip:IsShown() then _G.GameTooltip:Hide() end
end

---- Tracking Button ----
local function Tracking_OnMouseDown()
    _G.ToggleDropDownMenu(1, nil, _G.MiniMapTrackingDropDown, "MinimapAdv_Tracking", 0, 0)
end

local function Tracking_OnEnter()
    MMFrames.tracking.mouseover = true

    MMFrames.tracking.icon:SetVertexColor(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
    MMFrames.tracking:SetFrameLevel(6)

    if ExpandedState == 0 then
        MMFrames.buttonframe.tooltip:SetText("Tracking")
        MMFrames.buttonframe.tooltip:Show()
        MMFrames.buttonframe.tooltipIcon:Show()
    end

    MinimapAdv:FadeButtons()
end

local function Tracking_OnLeave()
    MMFrames.tracking.mouseover = false

    MMFrames.tracking.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.tracking:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()

    if _G.GameTooltip:IsShown() then _G.GameTooltip:Hide() end
end

---- Farm Button ----
function MinimapAdv:ToggleGatherer()
    if ( (not db.expand.extras.gatherertoggle) or (not _G.Gatherer) ) then return end

    if ExpandedState == 1 then
        _G.Gatherer.Config.SetSetting("minimap.enable", true)
    else
        _G.Gatherer.Config.SetSetting("minimap.enable", false)
    end
end

local function Farm_OnMouseDown()
    if ExpandedState == 0 then
        ExpandedState = 1
        MMFrames.farm.icon:SetTexture(Textures.Collapse)
        _G.PlaySound("igMiniMapOpen")
        button:Hide()
    else
        ExpandedState = 0
        MMFrames.farm.icon:SetTexture(Textures.Expand)
        _G.PlaySound("igMiniMapClose")
        button:Show()
    end
    if _G.DropDownList1 then _G.DropDownList1:Hide() end
    if _G.DropDownList2 then _G.DropDownList2:Hide() end

    MinimapAdv:ToggleGatherer()
    MinimapAdv:UpdateMinimapPosition()
    MinimapAdv:UpdateFarmModePOI()
end

function MinimapAdv:FarmBind()
    if _G.IsInInstance() then return end
    Farm_OnMouseDown()
end

local function Farm_OnEnter()
    MMFrames.farm.mouseover = true

    MMFrames.farm.icon:SetVertexColor(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
    MMFrames.farm:SetFrameLevel(6)

    if ExpandedState == 0 then
        MMFrames.buttonframe.tooltip:SetText("Farm Mode")
        MMFrames.buttonframe.tooltip:Show()
        MMFrames.buttonframe.tooltipIcon:Show()
    end

    MinimapAdv:FadeButtons()
end

local function Farm_OnLeave()
    MMFrames.farm.mouseover = false

    MMFrames.farm.icon:SetVertexColor(0.8, 0.8, 0.8)
    MMFrames.farm:SetFrameLevel(5)

    MMFrames.buttonframe.tooltip:Hide()
    MMFrames.buttonframe.tooltipIcon:Hide()

    MinimapAdv:FadeButtons()
end

--[[ Garrison
--The pulse anim that these function call will reset the alpha of the whole button each time it repeats.
--This was the only reliable way I could find to get this button back to full opacity.
local oldGarrisonMinimapBuilding_ShowPulse = GarrisonMinimapBuilding_ShowPulse
GarrisonMinimapBuilding_ShowPulse = function(self)
    print("Pre-hook: Building")
    self:SetAlpha(1)
    return oldGarrisonMinimapBuilding_ShowPulse(self)
end
local oldGarrisonMinimapMission_ShowPulse = GarrisonMinimapMission_ShowPulse
GarrisonMinimapMission_ShowPulse = function(self)
    print("Pre-hook: Mission")
    self:SetAlpha(1)
    return oldGarrisonMinimapMission_ShowPulse(self)
end
local oldGarrisonMinimapInvasion_ShowPulse = GarrisonMinimapInvasion_ShowPulse
GarrisonMinimapInvasion_ShowPulse = function(self)
    print("Pre-hook: Invasion")
    self:SetAlpha(1)
    return oldGarrisonMinimapInvasion_ShowPulse(self)
end
local oldGarrisonMinimapShipmentCreated_ShowPulse = GarrisonMinimapShipmentCreated_ShowPulse
GarrisonMinimapShipmentCreated_ShowPulse = function(self)
    print("Pre-hook: Shipment")
    self:SetAlpha(1)
    return oldGarrisonMinimapShipmentCreated_ShowPulse(self)
end

--GarrisonLandingPageTutorialBox:Show()
--GarrisonMinimapMission_ShowPulse(GarrisonLandingPageMinimapButton)

local function hookfunc(self, lock, enabled)
    print("hookfunc", self, lock, enabled)
    if enabled then
        self:SetAlpha(1)
    else
        self:SetAlpha(0)
    end
end

local function Garrison_OnLeave(self)
    fadeOut(self)
end
]]--

local function Garrison_OnEnter(self)
    local isLeft = db.position.anchorto:find("LEFT")
    --print("Garrison_OnEnter")
    _G.GameTooltip:SetOwner(_G.GarrisonLandingPageMinimapButton, "ANCHOR_" .. (isLeft and "RIGHT" or "LEFT"));
    _G.GameTooltip:SetText(_G.GARRISON_LANDING_PAGE_TITLE, 1, 1, 1);
    _G.GameTooltip:AddLine(_G.MINIMAP_GARRISON_LANDING_PAGE_TOOLTIP, nil, nil, nil, true);
    _G.GameTooltip:Show();
    --fadeIn(self)
end

---- Minimap
local function Minimap_OnEnter()
    _G.Minimap.mouseover = true
    MinimapAdv:FadeButtons()
end

local function Minimap_OnLeave()
    _G.Minimap.mouseover = false
    MinimapAdv:FadeButtons()
end

------------
-- EVENTS --
------------
local hostilePvPTypes = {
    arena = true,
    hostile = true,
    contested = true,
    combat = true,
}
function MinimapAdv:ZoneChange(event, ...)
    self:debug("ZoneChange", event, ...)
    local r, g, b = 0.5, 0.5, 0.5
    local pvpType = _G.GetZonePVPInfo()
    if pvpType == "sanctuary" then
        r, g, b = 0.41, 0.8, 0.94
    elseif pvpType == "arena" then
        r, g, b = 1, 0.1, 0.1
    elseif pvpType == "friendly" then
        r, g, b = 0.2, 0.9, 0.2
    elseif pvpType == "hostile" then
        r, g, b = 1, 0.15, 0.15
    elseif pvpType == "contested" then
        r, g, b = 1, 0.7, 0
    elseif pvpType == "combat" then
        r, g, b = 1, 0, 0
    end

    MMFrames.info.zoneIndicator.bg:SetVertexColor(r, g, b)
    MMFrames.info.zoneIndicator.isHostile = hostilePvPTypes[pvpType]
    if MMFrames.info.zoneIndicator.isHostile then
        MMFrames.info.zoneIndicator:Show()
    else
        MMFrames.info.zoneIndicator:Hide()
    end

    local zName = _G.GetMinimapZoneText()

    local Location = MMFrames.info.Location
    Location.text:SetText(zName)
    Location.text:SetTextColor(r, g, b)
    Location:SetHeight(Location.text:GetStringHeight())
    infoTexts.Location.shown = db.information.location

    RefreshMap = true
end

function MinimapAdv:ZONE_CHANGED_NEW_AREA(event, ...)
    self:debug(event, ...)
    _G.SetMapToCurrentZone()
    self:ZoneChange()

    -- Update POIs
    self:POIUpdate()
end

function MinimapAdv:MINIMAP_UPDATE_ZOOM(event, ...)
    self:debug(event, ...)
    ZoomMinimapOut()
    self:UnregisterEvent("MINIMAP_UPDATE_ZOOM")
end

function MinimapAdv:PLAYER_ENTERING_WORLD(event, ...)
    self:debug(event, ...)
    -- Hide persistent Minimap elements
    _G.GameTimeFrame:Hide()
    _G.GameTimeFrame.Show = function() end

    -- Update Minimap position and visible state
    self:UpdateShownState() -- Will also call MinimapAdv:Update
    self:UpdateMinimapPosition()

    -- Update POIs
    self:UpdatePOIEnabled()

    -- Timer
    RefreshMap = true
    RefreshZoom = true
    RefreshTimer:Show()
end

-- Hide default Clock Button
function MinimapAdv:ADDON_LOADED(event, ...)
    self:debug(event, ...)
    local addon = ...
    if addon == "Blizzard_TimeManager" then
        _G.TimeManagerClockButton:HookScript("OnShow", function()
            _G.TimeManagerClockButton:Hide()
        end)
        _G.TimeManagerClockButton:Hide()
    end
end

function MinimapAdv:PLAYER_LOGIN(event, ...)
    self:debug(event, ...)
    MMFrames.buttonframe.edge:SetTexture(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
end

-- Register events
function MinimapAdv:RegEvents()
    -- Hook into Blizzard addons
    self:RegisterEvent("ADDON_LOADED")

    -- Basic settings
    self:RegisterEvent("PLAYER_LOGIN")

    -- Initialise settings on UI load
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    -- Set Minimap Zoom
    self:RegisterEvent("MINIMAP_UPDATE_ZOOM")

    -- Location
    self:RegisterEvent("ZONE_CHANGED_NEW_AREA")
    self:RegisterBucketEvent({
        "ZONE_CHANGED",
        "ZONE_CHANGED_INDOORS",
        "WORLD_MAP_UPDATE",
    }, 0.2, "ZoneChange")

    -- Dungeon Difficulty
    self:RegisterEvent("GUILD_PARTY_STATE_UPDATED", "UpdateGuildPartyState")
    self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuildPartyState")
    self:RegisterBucketEvent({
        "PLAYER_DIFFICULTY_CHANGED",
        "UPDATE_INSTANCE_INFO",
        "PARTY_MEMBERS_CHANGED",
        "PARTY_MEMBER_ENABLE",
        "PARTY_MEMBER_DISABLE",
    }, 1, "InstanceDifficultyOnEvent")

    -- Queue
    self:RegisterEvent("LFG_UPDATE", "GetLFGQueue")
    self:RegisterEvent("LFG_PROPOSAL_SHOW", "GetLFGQueue")
    self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", "GetLFGQueue")
    self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED", "GetLFGList")
    self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE", "GetLFGList")

    -- POI
    self:RegisterEvent("QUEST_POI_UPDATE", "POIUpdate")
    self:RegisterEvent("QUEST_LOG_UPDATE", "POIUpdate")

    local UpdatePOICall = function() self:POIUpdate() end
    _G.hooksecurefunc("AddQuestWatch", UpdatePOICall)
    _G.hooksecurefunc("RemoveQuestWatch", UpdatePOICall)

    -- Player Coords
    self.LastX = 0
    self.LastY = 0
    self.StationaryTime = 0
    -- self:RegisterEvent("PLAYER_STARTED_MOVING", function(...)
    local function MovementTimerUpdate()
        MinimapAdv:MovementUpdate()
    end
    self.CoordsTicker = _G.C_Timer.NewTicker(0.5, MovementTimerUpdate)
    -- end)
    -- self:RegisterEvent("PLAYER_STOPPED_MOVING", function(...)
        -- self.CoordsTicker:Cancel()
    -- end)
end

--------------------------
-- FRAME INITIALIZATION --
--------------------------
-- Frame Template
local function NewInfoFrame(name, parent, size2)
    local NewFrame = _G.CreateFrame("Frame", "MinimapAdv_"..name, parent)
    NewFrame:SetSize(_G.Minimap:GetWidth(), 12)
    NewFrame:SetFrameStrata("LOW")
    NewFrame:SetFrameLevel(5)

    local text = NewFrame:CreateFontString(nil, "ARTWORK")
    text:SetNonSpaceWrap(true)
    text:SetAllPoints()
    if size2 then
        text:SetFontObject("RealUIFont_Pixel")
    else
        text:SetFontObject("RealUIFont_PixelSmall")
    end
    NewFrame.text = text

    infoTexts[name] = {type = name, shown = false}
    _G.tinsert(infoTexts, infoTexts[name])
    return NewFrame
end

-- Create Information/Toggle frames
local function CreateButton(Name, Texture, index)
    local NewButton

    NewButton = _G.CreateFrame("Frame", Name, MMFrames.buttonframe)
    NewButton:SetPoint("BOTTOMLEFT", MMFrames.buttonframe, "BOTTOMLEFT", 5 + ((index -1) * 15), 1)
    NewButton:SetHeight(15)
    NewButton:SetWidth(15)
    NewButton:EnableMouse(true)
    NewButton:Show()

    NewButton.icon = NewButton:CreateTexture(nil, "ARTWORK")
    NewButton.icon:SetTexture(Texture)
    NewButton.icon:SetVertexColor(0.8, 0.8, 0.8)
    NewButton.icon:SetPoint("BOTTOMLEFT", NewButton, "BOTTOMLEFT", 0, 0)
    NewButton.icon:SetHeight(16)
    NewButton.icon:SetWidth(16)

    return NewButton
end

local function CreateFrames()
    -- Set up Frame table
    MinimapAdv.Frames = {
        toggle = nil,
        config = nil,
        tracking = nil,
        farm = nil,
        info = {},
    }
    MMFrames = MinimapAdv.Frames

    ---- Buttons
    MMFrames.buttonframe = _G.CreateFrame("Frame", nil, _G.UIParent)
    MMFrames.buttonframe:SetPoint("TOPLEFT", _G.Minimap, "TOPLEFT", 1, -1)
    MMFrames.buttonframe:SetSize(66, 17)
    MMFrames.buttonframe:SetFrameStrata("MEDIUM")
    MMFrames.buttonframe:SetFrameLevel(5)
    RealUI:CreateBD(MMFrames.buttonframe, nil, true, true)

    MMFrames.buttonframe.edge = MMFrames.buttonframe:CreateTexture(nil, "ARTWORK")
    MMFrames.buttonframe.edge:SetTexture(1, 1, 1, 1)
    MMFrames.buttonframe.edge:SetPoint("LEFT", MMFrames.buttonframe, "LEFT", 1, 0)
    MMFrames.buttonframe.edge:SetSize(4, 15)

    MMFrames.buttonframe.tooltip = MMFrames.buttonframe:CreateFontString()
    MMFrames.buttonframe.tooltip:SetPoint("BOTTOMLEFT", MMFrames.buttonframe, "BOTTOMLEFT", 78.5, 4.5)
    MMFrames.buttonframe.tooltip:SetFontObject("RealUIFont_PixelSmall")
    MMFrames.buttonframe.tooltip:SetTextColor(0.8, 0.8, 0.8)
    MMFrames.buttonframe.tooltip:Hide()

    MMFrames.buttonframe.tooltipIcon = MMFrames.buttonframe:CreateTexture(nil, "ARTWORK")
    MMFrames.buttonframe.tooltipIcon:SetPoint("BOTTOMRIGHT", MMFrames.buttonframe.tooltip, "BOTTOMLEFT", -1.5, -0.5)
    MMFrames.buttonframe.tooltipIcon:SetWidth(16)
    MMFrames.buttonframe.tooltipIcon:SetHeight(16)
    MMFrames.buttonframe.tooltipIcon:SetTexture(Textures.TooltipIcon)
    MMFrames.buttonframe.tooltipIcon:SetVertexColor(RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3])
    MMFrames.buttonframe.tooltipIcon:Hide()

    -- Toggle Button
    MMFrames.toggle = CreateButton("MinimapAdv_Toggle", Textures.Minimize, 1)
    MMFrames.toggle:SetScript("OnEnter", Toggle_OnEnter)
    MMFrames.toggle:SetScript("OnLeave", Toggle_OnLeave)
    MMFrames.toggle:SetScript("OnMouseDown", Toggle_OnMouseDown)

    -- Config Button
    MMFrames.config = CreateButton("MinimapAdv_Config", Textures.Config, 2)
    MMFrames.config:SetScript("OnEnter", Config_OnEnter)
    MMFrames.config:SetScript("OnLeave", Config_OnLeave)
    MMFrames.config:SetScript("OnMouseDown", Config_OnMouseDown)

    -- Tracking Button
    MMFrames.tracking = CreateButton("MinimapAdv_Tracking", Textures.Tracking, 3)
    MMFrames.tracking:SetScript("OnEnter", Tracking_OnEnter)
    MMFrames.tracking:SetScript("OnLeave", Tracking_OnLeave)
    MMFrames.tracking:SetScript("OnMouseDown", Tracking_OnMouseDown)

    -- Farm Button
    MMFrames.farm = CreateButton("MinimapAdv_Farm", Textures.Expand, 4)
    MMFrames.farm:SetScript("OnEnter", Farm_OnEnter)
    MMFrames.farm:SetScript("OnLeave", Farm_OnLeave)
    MMFrames.farm:SetScript("OnMouseDown", Farm_OnMouseDown)

    -- Info
    MMFrames.info.Coords = NewInfoFrame("Coords", _G.Minimap)
    MMFrames.info.Coords:SetAlpha(0.75)
    MMFrames.info.Location = NewInfoFrame("Location", _G.Minimap, true)
    MMFrames.info.LootSpec = NewInfoFrame("LootSpec", _G.Minimap, true)
    MMFrames.info.DungeonDifficulty = NewInfoFrame("DungeonDifficulty", _G.Minimap, true)
    MMFrames.info.LFG = NewInfoFrame("LFG", _G.Minimap, true)
    MMFrames.info.Queue = NewInfoFrame("Queue", _G.Minimap, true)
    MMFrames.info.RFQueue = NewInfoFrame("RFQueue", _G.Minimap, true)
    MMFrames.info.SQueue = NewInfoFrame("SQueue", _G.Minimap, true)

    -- Zone Indicator
    MMFrames.info.zoneIndicator = _G.CreateFrame("Frame", "MinimapAdv_Zone", _G.Minimap)
    MMFrames.info.zoneIndicator:SetHeight(16)
    MMFrames.info.zoneIndicator:SetWidth(16)
    MMFrames.info.zoneIndicator:SetFrameStrata("MEDIUM")
    MMFrames.info.zoneIndicator:SetFrameLevel(5)
    MMFrames.info.zoneIndicator:ClearAllPoints()
    MMFrames.info.zoneIndicator:SetPoint("BOTTOMRIGHT", "Minimap", "BOTTOMRIGHT", 1, -1)

    MMFrames.info.zoneIndicator.bg = MMFrames.info.zoneIndicator:CreateTexture(nil, "BACKGROUND")
    MMFrames.info.zoneIndicator.bg:SetTexture(Textures.ZoneIndicator)
    MMFrames.info.zoneIndicator.bg:SetVertexColor(0.5, 0.5, 0.5)
    MMFrames.info.zoneIndicator.bg:SetAllPoints(MMFrames.info.zoneIndicator)
end

-------------------
-- MINIMAP FRAME --
-------------------
local function SetUpMinimapFrame()
    -- Establish Scroll Wheel zoom
    _G.MinimapZoomIn:Hide()
    _G.MinimapZoomOut:Hide()
    _G.Minimap:EnableMouseWheel()
    _G.Minimap:SetScript("OnMouseWheel", function(self, direction)
        if direction > 0 then
            _G.MinimapZoomIn:Click()
        else
            _G.MinimapZoomOut:Click()
        end
    end)
    _G.Minimap:SetScript("OnEnter", Minimap_OnEnter)
    _G.Minimap:SetScript("OnLeave", Minimap_OnLeave)

    -- Hide/Move Minimap elements
    _G.MiniMapTracking:Hide()

    _G.MiniMapMailFrame:Hide()
    _G.MiniMapMailFrame.Show = function() end

    _G.MinimapZoneText:Hide()
    _G.MinimapZoneTextButton:Hide()

    _G.QueueStatusMinimapButton:ClearAllPoints()
    _G.QueueStatusMinimapButton:SetParent(_G.Minimap)
    _G.QueueStatusMinimapButton:SetPoint('BOTTOMRIGHT', 2, -2)
    _G.QueueStatusMinimapButtonBorder:Hide()

    _G.GarrisonLandingPageTutorialBox:SetParent(_G.Minimap)
    --GarrisonLandingPageMinimapButton:SetAlpha(0)
    _G.GarrisonLandingPageMinimapButton:SetParent(_G.Minimap)
    _G.GarrisonLandingPageMinimapButton:ClearAllPoints()
    _G.GarrisonLandingPageMinimapButton:SetPoint("TOPRIGHT", 2, 2)
    _G.GarrisonLandingPageMinimapButton:SetSize(32, 32)
    --GarrisonLandingPageMinimapButton:HookScript("OnEvent", Garrison_OnEvent)
    --GarrisonLandingPageMinimapButton:HookScript("OnLeave", Garrison_OnLeave)
    _G.GarrisonLandingPageMinimapButton:SetScript("OnEnter", Garrison_OnEnter)
    --hooksecurefunc("GarrisonMinimap_SetPulseLock", hookfunc)


    _G.MinimapNorthTag:SetAlpha(0)

    _G.MiniMapInstanceDifficulty:Hide()
    _G.MiniMapInstanceDifficulty.Show = function() end
    _G.GuildInstanceDifficulty:Hide()
    _G.GuildInstanceDifficulty.Show = function() end
    _G.MiniMapChallengeMode:Hide()
    _G.MiniMapChallengeMode.Show = function() end

    _G.MiniMapWorldMapButton:Hide()

    _G.GameTimeFrame:Hide()

    _G.MinimapBorderTop:Hide()

    -- Make it square
    _G.MinimapBorder:SetTexture(nil)
    _G.Minimap:SetMaskTexture(Textures.SquareMask)

    -- Create New Border
    RealUI:CreateBG(_G.Minimap)

    -- Disable MinimapCluster area
    _G.MinimapCluster:EnableMouse(false)
end

----------
function MinimapAdv:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            hidden = {
                enabled = true,
                zones = {
                    pvp = false,
                    arena = true,
                    party = false,
                    raid = false,
                },
            },
            position = {
                size = 134,
                scale = 1,
                anchorto = "TOPLEFT",
                x = 7,
                y = -7,
            },
            expand = {
                appearance = {
                    scale = 1.4,
                    opacity = 0.5,
                },
                position = {
                    anchorto = "TOPLEFT",
                    x = 7,
                    y = -7,
                },
                extras = {
                    gatherertoggle = false,
                    clickthrough = false,
                    hidepoi = true,
                },
            },
            information = {
                position = {x = -1, y = 0},
                location = false,
                minimapbuttons = true,
                coordDelayHide = true,
                gap = 4,
                hideRaidFilters = true,
            },
            poi = {
                enabled = true,
                watchedOnly = true,
                fadeEdge = true,
                icons = {
                    scale = 0.7,
                    opacity = 1,
                },
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function MinimapAdv:OnEnable()
    -- Create frames, register events, begin the Minimap
    SetUpMinimapFrame()
    CreateFrames()
    self:RegEvents()
end
