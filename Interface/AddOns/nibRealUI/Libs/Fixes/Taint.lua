local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- Libs --
local LCS = LibStub("LibCoolStuff")

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

do --[[ World Map ]]--
    -- original code by ls- (lightspark)
    local old_ResetZoom = _G.WorldMapScrollFrame_ResetZoom
    _G.WorldMapScrollFrame_ResetZoom = function()
        if _G.InCombatLockdown() then
            _G.WorldMapFrame_Update()
            _G.WorldMapScrollFrame_ReanchorQuestPOIs()
            _G.WorldMapFrame_ResetPOIHitTranslations()
            _G.WorldMapBlobFrame_DelayedUpdateBlobs()
        else
            old_ResetZoom()
        end
    end

    local old_QuestMapFrame_OpenToQuestDetails = _G.QuestMapFrame_OpenToQuestDetails
    _G.QuestMapFrame_OpenToQuestDetails = function(questID)
        if _G.InCombatLockdown() then
            _G.ShowUIPanel(_G.WorldMapFrame);
            _G.QuestMapFrame_ShowQuestDetails(questID)
            _G.QuestMapFrame.DetailsFrame.mapID = nil
        else
            old_QuestMapFrame_OpenToQuestDetails(questID)
        end
    end

    if _G.WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation == _G.WorldMapBountyBoardMixin.GetDisplayLocation then
        _G.WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation = function(frame)
            if _G.InCombatLockdown() then
                return
            end

            return _G.WorldMapBountyBoardMixin.GetDisplayLocation(frame)
        end
    end

    if _G.WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation == _G.WorldMapActionButtonMixin.GetDisplayLocation then
        _G.WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation = function(frame, useAlternateLocation)
            if _G.InCombatLockdown() then
                return
            end

            return _G.WorldMapActionButtonMixin.GetDisplayLocation(frame, useAlternateLocation)
        end
    end

    if _G.WorldMapFrame.UIElementsFrame.ActionButton.Refresh == _G.WorldMapActionButtonMixin.Refresh then
        _G.WorldMapFrame.UIElementsFrame.ActionButton.Refresh = function(frame)
            if _G.InCombatLockdown() then
                return
            end

            _G.WorldMapActionButtonMixin.Refresh(frame)
        end
    end

    _G.WorldMapFrame.questLogMode = true
    _G.QuestMapFrame_Open(true)
end
