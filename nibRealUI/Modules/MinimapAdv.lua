local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs unpack tinsert

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local db

-- Libs --
local HBD = _G.LibStub("HereBeDragons-2.0", true)
local HBDP = _G.LibStub("HereBeDragons-Pins-2.0", true)

local MODNAME = "MinimapAdv"
local MinimapAdv = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")
local MenuFrame = RealUI:GetModule("MenuFrame")

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
local isInFarmMode = false
local UpdateProcessing = false

----------
-- Zoom Out
local function ZoomMinimapOut()
    _G.Minimap:SetZoom(0)
    _G.MinimapZoomIn:Enable()
    _G.MinimapZoomOut:Disable()
end

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
    if isInFarmMode and db.expand.extras.clickthrough then
        _G.Minimap:EnableMouse(false)
    else
        _G.Minimap:EnableMouse(true)
    end
end

-- Farm Mode - Hide POI option
function MinimapAdv:UpdateFarmModePOI()
    self:POIUpdate("UpdateFarmModePOI", isInFarmMode)
end

-- Get size and position data
local function GetPositionData()
    -- Get Normal or Expanded data
    local mapPoints

    if isInFarmMode then
        mapPoints = {
            xofs = db.expand.position.x,
            yofs = db.expand.position.y,
            anchor = db.expand.position.anchorto,
            scale = db.expand.appearance.scale,
            opacity = db.expand.appearance.opacity,
            isTop = db.position.anchorto:find("TOP"),
            isLeft = db.position.anchorto:find("LEFT"),
        }
    else
        mapPoints = {
            xofs = db.position.x,
            yofs = db.position.y,
            anchor = db.position.anchorto,
            scale = db.position.scale,
            opacity = 1,
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
    if _G.Minimap:IsVisible() and not isInFarmMode then
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
                    _G.SetRaidProfileOption(_G.GetActiveRaidProfile(), "shown", false) _G.CompactRaidFrameManager_SetSetting("IsShown", false) -- Hide CRF
                    _G.SetRaidProfileOption(_G.GetActiveRaidProfile(), "locked", true) _G.CompactRaidFrameManager_SetSetting("Locked", true) -- Lock CRF
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

                        _G.FlowContainer_ResumeUpdates(container)

                        local _, usedY = _G.FlowContainer_GetUsedBounds(container)
                        CRFM:SetHeight(usedY + 40)
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
    if _G.Minimap:IsVisible() and not isInFarmMode then
        MMFrames.tracking:Show()
        _G.tinsert(frameOrder, "tracking")
        bfWidth = bfWidth + 15
    else
        MMFrames.tracking:Hide()
        MMFrames.tracking.mouseover = false
    end

    -- Farm mode
    if _G.Minimap:IsVisible() and not _G.IsInInstance() then
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

    if not RealUI.isPatch then
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
    end

    _G.ButtonCollectFrame:ClearAllPoints()
    if isTop then
        _G.ButtonCollectFrame:SetPoint("TOPLEFT", _G.Minimap, "BOTTOMLEFT", -1, -5)
        _G.ButtonCollectFrame:SetPoint("TOPRIGHT", _G.Minimap, "BOTTOMRIGHT", 1, -5)
    else
        _G.ButtonCollectFrame:SetPoint("BOTTOMLEFT", _G.Minimap, "TOPLEFT", -1, 5)
        _G.ButtonCollectFrame:SetPoint("BOTTOMRIGHT", _G.Minimap, "TOPRIGHT", 1, 5)
    end

    -- Update the rest of the Minimap
    self:UpdateButtonsPosition()
    self:UpdateInfoPosition()
    self:UpdateClickthrough()
end

---------------------
-- MINIMAP BUTTONS --
---------------------
do -- ButtonCollectFrame
    local BlackList = {
        QueueStatusMinimapButton = true,
        GarrisonLandingPageMinimapButton = true,
        MiniMapTracking = true,
        MiniMapMailFrame = true,
        HelpOpenTicketButton = true,
        GameTimeFrame = true,
        TimeManagerClockButton = true,
    }
    local OddList = {
        BagSync_MinimapButton = true,
        OutfitterMinimapButton = true,
    }

    local buttonFrame = _G.CreateFrame("Frame", "ButtonCollectFrame", _G.UIParent)
    Aurora.Base.SetBackdrop(buttonFrame, Color.frame:GetRGBA())
    buttonFrame:SetPoint("BOTTOMLEFT", _G.Minimap, "BOTTOMLEFT", -1, -5)
    buttonFrame:SetPoint("TOPRIGHT", _G.Minimap, "BOTTOMRIGHT", 1, -5)
    buttonFrame:SetHeight(32)
    buttonFrame:SetFrameStrata("LOW")
    buttonFrame:SetFrameLevel(10)
    buttonFrame:EnableMouse(true)
    buttonFrame:SetAlpha(0)
    buttonFrame:Show()
    buttonFrame:HookScript("OnEnter", fadeIn)
    buttonFrame:HookScript("OnLeave", fadeOut)

    local function setupButton(button)
        if not button then return end
        if button._isSkinned then return end

        button:SetParent(buttonFrame)
        button.ClearAllPoints = function() return end
        button.SetPoint = function() return end
        button:HookScript("OnEnter", function() fadeIn(buttonFrame) end)
        button:HookScript("OnLeave", function() fadeOut(buttonFrame) end)
        _G.tinsert(buttonFrame, button)
        button._isSkinned = true
    end

    local ClearAllPoints, SetPoint = buttonFrame.ClearAllPoints, buttonFrame.SetPoint
    local function positionButtons()
        local line, row = _G.floor(buttonFrame:GetWidth() / 32), 0
        for i = 1, #buttonFrame do
            local button = buttonFrame[i]
            ClearAllPoints(button)
            --print("Eval", i, i + line - 1, _G.floor(row+1) * line, row)
            if i + line - 1 == _G.floor(row + 1) * line then
                --print("Row start", i)
                SetPoint(button, "TOPLEFT", buttonFrame, "TOPLEFT", 0, -(row * 32))
            else
                --print("Row cont.", i)
                SetPoint(button, "TOPLEFT", buttonFrame[i - 1], "TOPRIGHT", 2, 0)
            end
            row = i / line
        end
        buttonFrame:SetHeight(_G.ceil(row) * 32)
    end

    function MinimapAdv:UpdateButtonCollection()
        if not db.information.minimapbuttons then return end
        for i, child in next, {_G.Minimap:GetChildren()} do
            if not(BlackList[child:GetName()]) and not child.questID then
                if (child:GetObjectType() == "Button") and child:GetNumRegions() >= 3 then
                    setupButton(child)
                end
            end
        end
        for f, _ in next, OddList do
            setupButton(_G[f])
        end

        if #buttonFrame == 0 then
            buttonFrame:Hide()
        else
            positionButtons()
            buttonFrame:Show()
        end
    end
end

-------------------------
-- INFORMATION UPDATES --
-------------------------
---- POI ----
local poiTable

local MinimapPOIMixin = {}
function MinimapPOIMixin:OnEnter()
    -- Set Tooltip's parent
    if _G.UIParent:IsVisible() then
        _G.GameTooltip:SetParent(_G.UIParent)
    else
        _G.GameTooltip:SetParent(self)
    end

    -- Set Tooltip position
    local mapPoints = GetPositionData()
    local mm_anchor = mapPoints.anchor
    if mm_anchor == "TOPLEFT" then
        _G.GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 10, -10)
    elseif mm_anchor == "BOTTOMLEFT" then
        _G.GameTooltip:SetOwner(self, "ANCHOR_TOPRIGHT", 5, 5)
    end

    -- Add Hyperlink
    local link = _G.GetQuestLink(self.questID)
    if link then
        _G.GameTooltip:SetHyperlink(link)
    end
end
function MinimapPOIMixin:OnLeave()
    _G.GameTooltip:Hide()
end
function MinimapPOIMixin:OnClick()
    _G.QuestPOIButton_OnClick(self)
    _G.QuestMapFrame_OpenToQuestDetails(self.questID)
end

function MinimapPOIMixin:UpdateAlpha()
    local isOnEdge = HBDP:IsMinimapIconOnEdge(self)
    if isOnEdge == nil then
        _G.C_Timer.After(0, function()
            self:UpdateAlpha()
        end)
        return
    end

    self:Show()
    if isOnEdge then
        self:SetAlpha(db.poi.icons.opacity * (db.poi.fadeEdge and 0.6 or 1))
    else
        self:SetAlpha(db.poi.icons.opacity)

        local isComplete
        if RealUI.isPatch then
            isComplete = _G.C_QuestLog.IsComplete(self.questID)
        else
            isComplete = _G.IsQuestComplete(self.questID)
        end
        if isComplete then
            self:Hide()
        end
    end
end
function MinimapPOIMixin:UpdateScale()
    local scale = db.poi.icons.scale
    local size50 = 50 * scale
    local size32 = 32 * scale

    if self.Number then
        self.Glow:SetSize(size50, size50)
        self.Number:SetSize(size32, size32)
        self.NormalTexture:SetSize(size32, size32)
        self.HighlightTexture:SetSize(size32, size32)
        self.PushedTexture:SetSize(size32, size32)
    else
        self.Glow:SetSize(size50, size50)
        local icon = RealUI.isPatch and self.Display.Icon or self.Icon

        if self.style == "waypoint" then
            icon:SetSize(13 * scale, 17 * scale)
        else
            icon:SetSize(24 * scale, 24 * scale)
        end
        if not RealUI.isPatch then
            self.FullHighlightTexture:SetSize(size32, size32)
            self.IconHighlightTexture:SetSize(size32, size32)
        end
        self.NormalTexture:SetSize(size32, size32)
        self.PushedTexture:SetSize(size32, size32)
    end
end

function MinimapPOIMixin:Add(xCoord, yCoord, instanceID)
    HBDP:AddMinimapIconWorld(MinimapAdv, self, instanceID, xCoord, yCoord, true)
end
function MinimapPOIMixin:Remove()
    HBDP:RemoveMinimapIcon(MinimapAdv, self)
    self.used = nil
end


local function AddPOIsForZone(zoneInfo, numNumericQuests)
    local quests = _G.C_QuestLog.GetQuestsOnMap(zoneInfo.mapID)
    if not quests then return numNumericQuests end

    for _, questInfo in next, quests do
        local questID = questInfo.questID
        local questLogIndex, hasLocalPOI, isHidden, isSuperTracked, _
        if RealUI.isPatch then
            questLogIndex = _G.C_QuestLog.GetLogIndexForQuestID(questID)
            local questLogInfo = _G.C_QuestLog.GetInfo(questLogIndex)
            hasLocalPOI = questLogInfo.hasLocalPOI
            isHidden = questLogInfo.isHidden
            isSuperTracked = _G.C_SuperTrack.GetSuperTrackedQuestID() == questID
        else
            questLogIndex = _G.GetQuestLogIndexByID(questID)
            _, _, _, _, _, _, _, _, _, _, _, hasLocalPOI, _, _, _, isHidden = _G.GetQuestLogTitle(questLogIndex)
            isSuperTracked = _G.GetSuperTrackedQuestID() == questID
        end

        if (not isHidden and hasLocalPOI) or isSuperTracked then
            MinimapAdv:debug("Add POI", questID, questInfo.x, questInfo.y, zoneInfo.mapID)
            local xCoord, yCoord, instanceID = HBD:GetWorldCoordinatesFromZone(questInfo.x, questInfo.y, zoneInfo.mapID)
            if xCoord and yCoord and instanceID then
                -- Check if there's already a POI for this quest.
                local poiButton = _G.QuestPOI_FindButton(_G.Minimap, questID)
                if not poiButton then
                    local isComplete
                    if RealUI.isPatch then
                        isComplete = _G.C_QuestLog.IsComplete(questID)
                    else
                        isComplete = _G.IsQuestComplete(questID)
                    end

                    if isComplete then
                        poiButton = _G.QuestPOI_GetButton(_G.Minimap, questID, "normal")
                    else
                        numNumericQuests = numNumericQuests + 1
                        poiButton = _G.QuestPOI_GetButton(_G.Minimap, questID, "numeric", numNumericQuests)
                    end
                end

                local isWatched
                if RealUI.isPatch then
                    isWatched = _G.QuestUtils_IsQuestWatched(questID)
                else
                    isWatched = _G.IsQuestWatched(questLogIndex)
                end
                if isWatched or not db.poi.watchedOnly then
                    poiButton:Add(xCoord, yCoord, instanceID)
                    if isSuperTracked then
                        _G.QuestPOI_SelectButton(poiButton)
                    end
                end
            elseif RealUI.isDev then
                _G.print("Could not place POI", questID, xCoord, yCoord, instanceID)
            end
        end
    end
    return numNumericQuests
end

function MinimapAdv:POIUpdate(event, ...)
    self:debug("POIUpdate", event, ...)
    if not db.poi.enabled then return end
    if isInFarmMode and db.expand.extras.hidepoi then
        return self:RemoveAllPOIs()
    end

    local currentMapID, continentMapID = _G.C_Map.GetBestMapForUnit("player")
    if currentMapID then
        local mapInfo = _G.C_Map.GetMapInfo(currentMapID)
        local exit = false
        while mapInfo and not exit do
            if mapInfo.mapType < _G.Enum.UIMapType.Continent then
                exit = true
            else
                continentMapID = mapInfo.mapID
                mapInfo = _G.C_Map.GetMapInfo(mapInfo.parentMapID)
            end
        end
    end

    if continentMapID then
        self:RemoveAllPOIs()

        -- Add current map first, which may be lower than the zone maps added later.
        local numNumericQuests = AddPOIsForZone(_G.C_Map.GetMapInfo(currentMapID), 0)

        local childrenZones = _G.C_Map.GetMapChildrenInfo(continentMapID, _G.Enum.UIMapType.Zone)
        for _, zoneInfo in next, childrenZones do
            numNumericQuests = AddPOIsForZone(zoneInfo, numNumericQuests)
        end
    end
end

function MinimapAdv:UpdatePOIVisibility(event, ...)
    self:debug("UpdatePOIVisibility", event, ...)
    for _, poiType in next, poiTable do
        for _, poiButton in next, poiType do
            if poiButton.used then
                poiButton:UpdateScale()
                poiButton:UpdateAlpha()
            end
        end
    end
end

function MinimapAdv:RemoveAllPOIs()
    if not poiTable then return end

    for _, poiType in next, poiTable do
        for _, poiButton in next, poiType do
            poiButton:Remove()
        end
    end
    _G.QuestPOI_ClearSelection(_G.Minimap)
end

function MinimapAdv:InitializePOI()
    _G.QuestPOI_Initialize(_G.Minimap, function(poiButton)
        _G.Mixin(poiButton, MinimapPOIMixin)
        poiButton:SetScript("OnEnter", poiButton.OnEnter)
        poiButton:SetScript("OnLeave", poiButton.OnLeave)
        poiButton:SetScript("OnClick", poiButton.OnClick)

        poiButton:UpdateScale()
        poiButton:UpdateAlpha()
    end)
    poiTable = _G.Minimap.poiTable
end

function MinimapAdv:UpdatePOIEnabled()
    if db.poi.enabled then
        if not poiTable then
            self:InitializePOI()
        end

        self:RegisterEvent("QUEST_POI_UPDATE", "POIUpdate")
        self:RegisterEvent("QUEST_LOG_UPDATE", "POIUpdate")
        self:RegisterEvent("QUEST_WATCH_LIST_CHANGED", "POIUpdate")
        if RealUI.isPatch then
            self:RegisterEvent("SUPER_TRACKING_CHANGED", "POIUpdate")
        else
            self:RegisterEvent("SUPER_TRACKED_QUEST_CHANGED", "POIUpdate")
        end
    else
        self:RemoveAllPOIs()
        self:UnregisterEvent("QUEST_POI_UPDATE")
        self:UnregisterEvent("QUEST_LOG_UPDATE")
        self:UnregisterEvent("QUEST_WATCH_LIST_CHANGED")
        if RealUI.isPatch then
            self:UnregisterEvent("SUPER_TRACKING_CHANGED")
        else
            self:UnregisterEvent("SUPER_TRACKED_QUEST_CHANGED")
        end
    end
end


---- LFG ----
function MinimapAdv:GetLFGList(event, arg)
    self:debug("GetLFGList", event, arg)
    local active, _, _, _, _, _, _, old_autoAccept, autoAccept = _G.C_LFGList.GetActiveEntryInfo()
    if active then
        local status
        if autoAccept or (_G.type(old_autoAccept) == "boolean" and old_autoAccept) then
            status = _G.LFG_LIST_AUTO_ACCEPT
        else
            local _, numActiveApplicants = _G.C_LFGList.GetNumApplicants()
            status = _G.LFG_LIST_PENDING_APPLICANTS:format(numActiveApplicants)
        end
        MMFrames.info.LFG.text:SetFormattedText("|c%sLFG:|r %s", Color.orange.colorStr, status)
        MMFrames.info.LFG:SetHeight(MMFrames.info.LFG.text:GetStringHeight())
        infoTexts.LFG.shown = true
    else
        infoTexts.LFG.shown = false
    end
    if not UpdateProcessing then
        self:UpdateInfoPosition()
    end
end

local queueFrames = {
    [1] = "Queue",
    [3] = "RFQueue",
    [4] = "SQueue"
}
function MinimapAdv:GetLFGQueue(event, ...)
    self:debug("GetLFGQueue", event, ...)
    for category = 1, _G.NUM_LE_LFG_CATEGORYS do
        local infoText = infoTexts[queueFrames[category]]
        local queueFrame = MMFrames.info[queueFrames[category]]
        if not (infoText and queueFrame) then return end

        local mode = _G.GetLFGMode(category)
        self:debug("LFGQueue", category, mode)
        if mode and mode == "queued" then
            local hasData, _, _, _, _, _, _, _, _, _, _, _, _, _, _, myWait, queuedTime = _G.GetLFGQueueStats(category)

            local queueStr
            if not hasData then
                queueStr = _G.LESS_THAN_ONE_MINUTE
            else
                local timeInQueue = _G.SecondsToClock(_G.GetTime() - queuedTime)
                if myWait > 0 then
                    local avgWait = _G.SecondsToTime(myWait, false, false, 1)
                    queueStr = ("%s |cffc0c0c0(%s)|r"):format(timeInQueue, avgWait)
                else
                    queueStr = ("%s"):format(timeInQueue)
                end
            end

            queueFrame.text:SetFormattedText(infoText.format, Color.orange.colorStr, queueStr)
            queueFrame:SetHeight(queueFrame.text:GetStringHeight())
            queueFrame.myWait = myWait
            queueFrame.queuedTime = queuedTime
            infoText.shown = true
        else
            infoText.shown = false
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
        self:debug("IsInInstance", Color.blue.colorStr, RealUI.GetCurrentLootSpecName())
        MMFrames.info.LootSpec.text:SetFormattedText("|c%s%s:|r %s", Color.blue.colorStr, _G.LOOT, RealUI.GetCurrentLootSpecName())
        MMFrames.info.LootSpec:SetHeight(MMFrames.info.LootSpec.text:GetStringHeight())
        infoTexts.LootSpec.shown = true
    else
        MMFrames.info.LootSpec.text:SetText("")
        infoTexts.LootSpec.shown = false
    end
end


---------------------
-- MINIMAP UPDATES --
---------------------
function MinimapAdv:Update()
    UpdateProcessing = true     -- Stops individual update functions from calling UpdateInfoPosition
    self:ZoneChange()
    self:DungeonDifficultyUpdate()
    self:UpdateButtonsPosition()
    self:UpdateButtonCollection()
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
        if isInFarmMode then
            isInFarmMode = false
            self:ToggleGatherer()
            self:UpdateMinimapPosition()
        end
        infoTexts.Coords.shown = false
    else
        infoTexts.Coords.shown = true
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
        if _G.Minimap.mouseover or MenuFrame:IsMenuOpen(MMFrames.tracking) or MMFrames.toggle.mouseover or MMFrames.config.mouseover or MMFrames.tracking.mouseover or MMFrames.farm.mouseover then
            local numButtons = 2

            if not isInFarmMode then
                MMFrames.tracking:Show()
                numButtons = numButtons + 1
            end
            if not _G.IsInInstance() then
                MMFrames.farm:Show()
                numButtons = numButtons + 1
            end

            if MMFrames.buttonframe.tooltip:IsShown() and not isInFarmMode then
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
        _G.PlaySound(_G.SOUNDKIT.IG_MINIMAP_CLOSE)
        MinimapAdv:Toggle(false)
    else
        _G.PlaySound(_G.SOUNDKIT.IG_MINIMAP_OPEN)
        MinimapAdv:Toggle(true)
    end
end

function MinimapAdv:ToggleBind()
    Toggle_OnMouseDown()
end

local function Toggle_OnEnter()
    MMFrames.toggle.mouseover = true

    MMFrames.toggle.icon:SetVertexColor(RealUI.charInfo.class.color:GetRGB())
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
    RealUI.Debug("Config", "Minimap")
    RealUI.LoadConfig("RealUI", "uiTweaks", "minimap")
end

local function Config_OnEnter()
    MMFrames.config.mouseover = true

    MMFrames.config.icon:SetVertexColor(RealUI.charInfo.class.color:GetRGB())
    MMFrames.config:SetFrameLevel(6)

    if not isInFarmMode then
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
    MenuFrame:Open(MMFrames.tracking, "BOTTOMLEFT", MMFrames.tracking.menuList)
end

local function Tracking_OnEnter()
    MMFrames.tracking.mouseover = true

    MMFrames.tracking.icon:SetVertexColor(RealUI.charInfo.class.color:GetRGB())
    MMFrames.tracking:SetFrameLevel(6)

    if not isInFarmMode then
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

    if isInFarmMode then
        _G.Gatherer.Config.SetSetting("minimap.enable", true)
    else
        _G.Gatherer.Config.SetSetting("minimap.enable", false)
    end
end

local function Farm_OnMouseDown()
    if isInFarmMode then
        isInFarmMode = false
        MMFrames.farm.icon:SetTexture(Textures.Expand)
        _G.PlaySound(_G.SOUNDKIT.IG_MINIMAP_CLOSE)
    else
        isInFarmMode = true
        MMFrames.farm.icon:SetTexture(Textures.Collapse)
        _G.PlaySound(_G.SOUNDKIT.IG_MINIMAP_OPEN)
    end

    MinimapAdv:ToggleGatherer()
    MinimapAdv:UpdateMinimapPosition()
    MinimapAdv:UpdateFarmModePOI()
    MinimapAdv:UpdateButtonCollection()
end

function MinimapAdv:FarmBind()
    if _G.IsInInstance() then return end
    Farm_OnMouseDown()
end

local function Farm_OnEnter()
    MMFrames.farm.mouseover = true

    MMFrames.farm.icon:SetVertexColor(RealUI.charInfo.class.color:GetRGB())
    MMFrames.farm:SetFrameLevel(6)

    if not isInFarmMode then
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

--[[ Garrison ]]--
-- GarrisonLandingPageMinimapButton.MinimapLoopPulseAnim:Play()
-- ShowGarrisonPulse(GarrisonLandingPageMinimapButton)
local function HideCommandBar(...)
    MinimapAdv:debug("HideCommandBar", ...)
    _G.OrderHallCommandBar:Hide()
end

local function ShowGarrisonPulse(self)
    local isPlaying = self.MinimapLoopPulseAnim:IsPlaying()
    MinimapAdv:debug("ShowGarrisonPulse", isPlaying)
    self.MinimapLoopPulseAnim:Stop()
    self.shouldShow = true
    fadeIn(self)
    if isPlaying then
        _G.C_Timer.After(0.2, function()
            self.MinimapLoopPulseAnim:Play()
        end)
    end
end

local isPulseEvent = {
    GARRISON_BUILDING_ACTIVATABLE = true,
    GARRISON_MISSION_FINISHED = true,
    GARRISON_INVASION_AVAILABLE = true,
    SHIPMENT_UPDATE = true,
}

local WoDGarrison = RealUI.isPatch and _G.Enum.GarrisonType.Type_7_0 or _G.LE_GARRISON_TYPE_7_0
local WoDFollower = RealUI.isPatch and _G.Enum.GarrisonFollowerType.FollowerType_7_0 or _G.LE_FOLLOWER_TYPE_GARRISON_7_0
local currencyId = _G.C_Garrison.GetCurrencyTypes(WoDGarrison)
local categoryInfo = {}
do -- by nebula
    local frame = _G.CreateFrame("Frame")
    frame:SetScript("OnEvent", function(self, event)
        if _G.C_Garrison.GetLandingPageGarrisonType() ~= WoDGarrison then return end

        if event == "GARRISON_FOLLOWER_CATEGORIES_UPDATED" then
            categoryInfo = _G.C_Garrison.GetClassSpecCategoryInfo(WoDFollower)
        else
            _G.C_Garrison.RequestClassSpecCategoryInfo(WoDFollower)
        end
    end)
    frame:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED")
    frame:RegisterEvent("GARRISON_FOLLOWER_ADDED")
    frame:RegisterEvent("GARRISON_FOLLOWER_REMOVED")
    frame:RegisterEvent("GARRISON_TALENT_COMPLETE")
    frame:RegisterEvent("GARRISON_TALENT_UPDATE")
    frame:RegisterEvent("GARRISON_SHOW_LANDING_PAGE")
end

local function Garrison_OnEvent(self, event, ...)
    MinimapAdv:debug("Garrison_OnEvent", event, ...)
    MinimapAdv:debug("button has pulse", self.MinimapLoopPulseAnim:IsPlaying())
    if event == "GARRISON_SHOW_LANDING_PAGE" then
        local alpha = self:GetAlpha()
        -- This fires quite often, so only react when the frame is actually shown.
        if _G.GarrisonLandingPage and _G.GarrisonLandingPage:IsShown() and alpha <= 1 then
            MinimapAdv:debug("inLandingPage fadein")
            fadeIn(self)
        elseif not self.shouldShow and alpha > 0 then
            MinimapAdv:debug("outLandingPage fadeout")
            fadeOut(self)
        else
            MinimapAdv:debug("notLandingPage")
            self.shouldShow = self.MinimapLoopPulseAnim:IsPlaying()
        end
    elseif isPulseEvent[event] then
        ShowGarrisonPulse(self)
    end
end
local function Garrison_OnLeave(self)
    MinimapAdv:debug("Garrison_OnLeave")
    if not (self.MinimapLoopPulseAnim:IsPlaying() and (_G.GarrisonLandingPage and _G.GarrisonLandingPage:IsShown())) then
        self.shouldShow = false
        fadeOut(self)
    end
end
local function Garrison_OnEnter(self)
    MinimapAdv:debug("Garrison_OnEnter")
    if not self.title then return end
    local isLeft = db.position.anchorto:find("LEFT")
    _G.GameTooltip:SetOwner(self, "ANCHOR_" .. (isLeft and "RIGHT" or "LEFT"))
    _G.GameTooltip:SetText(self.title, 1, 1, 1)
    _G.GameTooltip:AddLine(self.description, nil, nil, nil, true)
    if _G.C_Garrison.GetLandingPageGarrisonType() == WoDGarrison then
        _G.GameTooltip:AddLine(" ")

        local currency, amount = _G.GetCurrencyInfo(currencyId)
        _G.GameTooltip:AddDoubleLine(currency, RealUI.ReadableNumber(amount), 1, 1, 1, 1, 1, 1)

        if #categoryInfo > 0 then
            _G.GameTooltip:AddLine(" ")
            for index, category in ipairs(categoryInfo) do
                _G.GameTooltip:AddDoubleLine(category.name, _G.ORDER_HALL_COMMANDBAR_CATEGORY_COUNT:format(category.count, category.limit), 1, 1, 1, 1, 1, 1)
            end
        end
    end
    _G.GameTooltip:Show()
    self.shouldShow = true
    fadeIn(self)
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
end

function MinimapAdv:ZONE_CHANGED_NEW_AREA(event, ...)
    self:debug(event, ...)
    self:ZoneChange(event, ...)
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

    _G.TimeManagerClockButton:Hide()
    _G.TimeManagerClockButton.Show = function() end

    -- Update Minimap position and visible state
    self:UpdateShownState() -- Will also call MinimapAdv:Update
    self:UpdateMinimapPosition()
    self:UpdateButtonCollection()
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
    elseif addon == "Blizzard_OrderHallUI" then
        _G.C_Timer.After(0.1, HideCommandBar)
        _G.OrderHallCommandBar.SetShown = HideCommandBar
        _G.hooksecurefunc("OrderHall_CheckCommandBar", HideCommandBar)
    end

    self:UpdateButtonCollection()
end

function MinimapAdv:PLAYER_LOGIN(event, ...)
    self:debug(event, ...)
    MMFrames.buttonframe.edge:SetColorTexture(RealUI.charInfo.class.color:GetRGB())
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
    }, 0.2, "ZoneChange")

    -- Dungeon Difficulty
    self:RegisterEvent("GUILD_PARTY_STATE_UPDATED", "UpdateGuildPartyState")
    self:RegisterEvent("PLAYER_GUILD_UPDATE", "UpdateGuildPartyState")
    self:RegisterBucketEvent({
        "PLAYER_DIFFICULTY_CHANGED",
        "UPDATE_INSTANCE_INFO",
        "PARTY_MEMBER_ENABLE",
        "PARTY_MEMBER_DISABLE",
    }, 1, "InstanceDifficultyOnEvent")

    -- Queue
    self:RegisterEvent("LFG_UPDATE", "GetLFGQueue")
    self:RegisterEvent("LFG_PROPOSAL_SHOW", "GetLFGQueue")
    self:RegisterEvent("LFG_QUEUE_STATUS_UPDATE", "GetLFGQueue")
    self:RegisterEvent("LFG_LIST_APPLICANT_UPDATED", "GetLFGList")
    self:RegisterEvent("LFG_LIST_ACTIVE_ENTRY_UPDATE", "GetLFGList")
    self:GetLFGList("OnEnable", true)
end

--------------------------
-- FRAME INITIALIZATION --
--------------------------

-- Frame Template
local function NewInfoFrame(name, parent, format)
    local NewFrame = _G.CreateFrame("Frame", "MinimapAdv_"..name, parent)
    NewFrame:SetSize(_G.Minimap:GetWidth(), 12)
    NewFrame:SetFrameStrata("LOW")
    NewFrame:SetFrameLevel(5)

    local text = NewFrame:CreateFontString(nil, "ARTWORK")
    text:SetNonSpaceWrap(true)
    text:SetAllPoints()
    text:SetFontObject("SystemFont_Shadow_Med1_Outline")
    NewFrame.text = text

    if format then
        NewFrame:SetScript("OnUpdate", function(self, elapsed)
            if not self.queuedTime then return end
            --Don't update every tick (can't do 1 second beause it might be 1.01 seconds and we'll miss a tick.
            --Also can't do slightly less than 1 second (0.9) because we'll end up with some lingering numbers
            self.updateThrottle = (self.updateThrottle or 0.1) - elapsed
            if ( self.updateThrottle <= 0 ) then
                local queueStr
                local timeInQueue = _G.SecondsToClock(_G.GetTime() - self.queuedTime)
                if self.myWait > 0 then
                    local avgWait = _G.SecondsToTime(self.myWait, false, false, 1)
                    queueStr = ("%s |cffc0c0c0(%s)|r"):format(timeInQueue, avgWait)
                else
                    queueStr = ("%s"):format(timeInQueue)
                end

                self.text:SetFormattedText(format, Color.orange.colorStr, queueStr)
                self:SetHeight(self.text:GetStringHeight())
                self.updateThrottle = 0.1
            end
        end)
    end
    infoTexts[name] = {type = name, shown = false, format = format}
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
    Aurora.Base.SetBackdrop(MMFrames.buttonframe)

    MMFrames.buttonframe.edge = MMFrames.buttonframe:CreateTexture(nil, "ARTWORK")
    MMFrames.buttonframe.edge:SetColorTexture(1, 1, 1, 1)
    MMFrames.buttonframe.edge:SetPoint("LEFT", MMFrames.buttonframe, "LEFT", 1, 0)
    MMFrames.buttonframe.edge:SetSize(4, 15)

    MMFrames.buttonframe.tooltip = MMFrames.buttonframe:CreateFontString()
    MMFrames.buttonframe.tooltip:SetPoint("BOTTOMLEFT", MMFrames.buttonframe, "BOTTOMLEFT", 78.5, 4.5)
    MMFrames.buttonframe.tooltip:SetFontObject("SystemFont_Shadow_Med1")
    MMFrames.buttonframe.tooltip:SetTextColor(0.8, 0.8, 0.8)
    MMFrames.buttonframe.tooltip:Hide()

    MMFrames.buttonframe.tooltipIcon = MMFrames.buttonframe:CreateTexture(nil, "ARTWORK")
    MMFrames.buttonframe.tooltipIcon:SetPoint("BOTTOMRIGHT", MMFrames.buttonframe.tooltip, "BOTTOMLEFT", -1.5, -0.5)
    MMFrames.buttonframe.tooltipIcon:SetWidth(16)
    MMFrames.buttonframe.tooltipIcon:SetHeight(16)
    MMFrames.buttonframe.tooltipIcon:SetTexture(Textures.TooltipIcon)
    MMFrames.buttonframe.tooltipIcon:SetVertexColor(RealUI.charInfo.class.color:GetRGB())
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

    local menuList = {
        {text = _G.MINIMAP_TRACKING_NONE,
            checked = _G.MiniMapTrackingDropDown_IsNoTrackingActive,
            func = _G.ClearAllTracking
        },
    }
    do
        local name, texture, category, nested, numTracking
        local count = _G.GetNumTrackingTypes()
        local classToken = RealUI.charInfo.class.token

        local hunterTracking
        if classToken == "HUNTER" then --only show hunter dropdown for hunters
            numTracking = 0
            -- make sure there are at least two options in dropdown
            for id = 1, count do
                _, _, _, category, nested = _G.GetTrackingInfo(id)
                if (nested == _G.HUNTER_TRACKING and category == "spell") then
                    numTracking = numTracking + 1
                end
            end
            if numTracking > 1 then
                hunterTracking = {
                    text = _G.HUNTER_TRACKING_TEXT,
                    menuList = {}
                }
                tinsert(menuList, hunterTracking)
            end
        end

        local townsfolk = {
            text = _G.TOWNSFOLK_TRACKING_TEXT,
            menuList = {}
        }
        tinsert(menuList, townsfolk)

        for id = 1, count do
            name, texture, _, category, nested  = _G.GetTrackingInfo(id)
            local info = {
                text = name,
                icon = texture,
                checked = function(self)
                    local _, _, active = _G.GetTrackingInfo(id)
                    return active
                end,
                func = function(self, arg1, arg2, isChecked)
                    _G.SetTracking(id, isChecked)
                end,
                keepShown = true
            }

            if category == "spell" then
                info.iconTexCoords = {0.0625, 0.9, 0.0625, 0.9}
            else
                info.iconTexCoords = {0, 1, 0, 1}
            end

            if (nested < 0 or -- this tracking shouldn't be nested
                    (nested == _G.HUNTER_TRACKING and classToken ~= "HUNTER") or
                    (numTracking == 1 and category == "spell")) then -- this is a hunter tracking ability, but you only have one
                tinsert(menuList, info)
            elseif nested == _G.TOWNSFOLK then
                tinsert(townsfolk.menuList, info)
            elseif nested == _G.HUNTER_TRACKING and classToken == "HUNTER" then
                tinsert(hunterTracking.menuList, info)
            end
        end
    end
    MMFrames.tracking.menuList = menuList

    -- Farm Button
    MMFrames.farm = CreateButton("MinimapAdv_Farm", Textures.Expand, 4)
    MMFrames.farm:SetScript("OnEnter", Farm_OnEnter)
    MMFrames.farm:SetScript("OnLeave", Farm_OnLeave)
    MMFrames.farm:SetScript("OnMouseDown", Farm_OnMouseDown)

    -- Info
    MMFrames.info.Location = NewInfoFrame("Location", _G.Minimap)
    MMFrames.info.LootSpec = NewInfoFrame("LootSpec", _G.Minimap)
    MMFrames.info.DungeonDifficulty = NewInfoFrame("DungeonDifficulty", _G.Minimap)
    MMFrames.info.LFG = NewInfoFrame("LFG", _G.Minimap)
    MMFrames.info.Queue = NewInfoFrame("Queue", _G.Minimap, "|c%sDF:|r %s")
    MMFrames.info.RFQueue = NewInfoFrame("RFQueue", _G.Minimap, "|c%sRF:|r %s")
    MMFrames.info.SQueue = NewInfoFrame("SQueue", _G.Minimap, "|c%sS:|r %s")

    -- Coordinates
    local lastUpdate, threshold = 0, 0.5
    MMFrames.info.Coords = NewInfoFrame("Coords", _G.Minimap)
    MMFrames.info.Coords:SetAlpha(0.75)
    MMFrames.info.Coords:SetScript("OnUpdate", function(coordsFrame, elapsed)
        lastUpdate = lastUpdate + elapsed
        if lastUpdate > threshold then
            local x, y = HBD:GetPlayerZonePosition()
            if x and y then
                coordsFrame.text:SetText(("%.1f  %.1f"):format(x * 100, y * 100))
                coordsFrame:SetHeight(coordsFrame.text:GetStringHeight())
            else
                coordsFrame.text:SetText("")
            end
            lastUpdate = 0
        end
    end)

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

    if not RealUI.isPatch then
        _G.GarrisonLandingPageTutorialBox:SetParent(_G.Minimap)
    end
    local GLPButton = _G.GarrisonLandingPageMinimapButton
    GLPButton:SetParent(_G.Minimap)
    GLPButton:SetAlpha(0)
    GLPButton:ClearAllPoints()
    GLPButton:SetPoint("TOPRIGHT", 2, 2)
    GLPButton:SetSize(32, 32)
    GLPButton:HookScript("OnEvent", Garrison_OnEvent)
    GLPButton:HookScript("OnLeave", Garrison_OnLeave)
    GLPButton:SetScript("OnEnter", Garrison_OnEnter)
    GLPButton.shouldShow = false

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
    local bg = _G.Minimap:CreateTexture(nil, "BACKGROUND")
    bg:SetPoint("TOPLEFT", -1, 1)
    bg:SetPoint("BOTTOMRIGHT", 1, -1)
    bg:SetColorTexture(0, 0, 0)

    -- Disable MinimapCluster area
    _G.MinimapCluster:EnableMouse(false)
end

----------
function MinimapAdv:RefreshMod()
    db = self.db.profile
    self:Update()
    self:UpdatePOIEnabled()
end

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
                    opacity = .85,
                },
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function MinimapAdv:OnEnable()
    if not HBD then
        _G.LoadAddOn("HereBeDragons")
        HBD = _G.LibStub("HereBeDragons-2.0")
        HBDP = _G.LibStub("HereBeDragons-Pins-2.0")
    end

    -- Create frames, register events, begin the Minimap
    SetUpMinimapFrame()
    CreateFrames()
    self:RegEvents()
    --self:POIUpdate("MinimapAdv:OnEnable")
    self:UpdatePOIEnabled()

    -- Community defined API
    function _G.GetMinimapShape()
        return "SQUARE"
    end
end
