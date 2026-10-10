local ADDON_NAME = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

--[[ Wowhead link in the quest right-click menus (2026-10-10).

     Adds "Wowhead link" to the tracker's quest and bonus objective menus and
     the quest log's quest menu, through Menu.ModifyMenu, Blizzard's supported
     way to add to a menu. Blizzard runs modify callbacks through
     securecallfunction (Blizzard_Menu/Menu.lua, PopulateDescription), so the
     click that opened the menu continues secure after ours returns.

     The tracker menus carry no quest ID (owner is the module), so it is read
     from the block under the mouse: the right-click lands on the block's
     HeaderButton, whose parent is the block. Only reads; nothing is written
     onto Blizzard frames. The URL opens in a RealUI-owned copy box, not a
     StaticPopup, so Blizzard's shared popup frames are not involved. ]]

local URL_FORMAT = "https://www.wowhead.com/quest=%d"

---------------------------------------------------------
-- Copy box
---------------------------------------------------------

local dialog

local function CreateDialog()
    -- Aurora's SetBackdrop brings its own backdrop; Blizzard's template only
    -- without it.
    local Aurora = _G.Aurora
    local hasAurora = Aurora and Aurora.Base
    dialog = _G.CreateFrame("Frame", nil, _G.UIParent, not hasAurora and "BackdropTemplate" or nil)
    dialog:SetSize(380, 86)
    dialog:SetPoint("CENTER", 0, 200)
    dialog:SetFrameStrata("DIALOG")
    dialog:EnableMouse(true)
    dialog:Hide()

    if hasAurora then
        Aurora.Base.SetBackdrop(dialog)
    else
        dialog:SetBackdrop(_G.BACKDROP_TOOLTIP_16_16_5555)
    end

    local title = dialog:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetPoint("TOPLEFT", 12, -10)
    title:SetPoint("TOPRIGHT", -30, -10)
    title:SetJustifyH("LEFT")
    title:SetWordWrap(false)
    dialog.title = title

    local close = _G.CreateFrame("Button", nil, dialog, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 0, 0)
    if Aurora and Aurora.Skin and Aurora.Skin.UIPanelCloseButton then
        Aurora.Skin.UIPanelCloseButton(close)
    end

    local editBox = _G.CreateFrame("EditBox", nil, dialog, "InputBoxTemplate")
    editBox:SetPoint("TOPLEFT", 16, -32)
    editBox:SetPoint("TOPRIGHT", -12, -32)
    editBox:SetHeight(20)
    editBox:SetAutoFocus(false)
    if Aurora and Aurora.Skin and Aurora.Skin.InputBoxTemplate then
        Aurora.Skin.InputBoxTemplate(editBox)
    end
    -- Read-only: any typing puts the URL back.
    editBox:SetScript("OnTextChanged", function(self, userInput)
        if userInput then
            self:SetText(dialog.url or "")
            self:HighlightText()
        end
    end)
    editBox:SetScript("OnEscapePressed", function() dialog:Hide() end)
    editBox:SetScript("OnEnterPressed", function() dialog:Hide() end)
    dialog.editBox = editBox

    local hint = dialog:CreateFontString(nil, "ARTWORK", "GameFontDisableSmall")
    hint:SetPoint("TOPLEFT", editBox, "BOTTOMLEFT", -4, -6)
    hint:SetText("Ctrl+C to copy, Esc to close")
end

local function ShowURL(questID)
    if not dialog then CreateDialog() end
    dialog.url = URL_FORMAT:format(questID)
    dialog.title:SetText(_G.C_QuestLog.GetTitleForQuestID(questID) or ("Quest " .. questID))
    dialog:Show()
    dialog.editBox:SetText(dialog.url)
    dialog.editBox:SetFocus()
    dialog.editBox:HighlightText()
end

---------------------------------------------------------
-- Menus
---------------------------------------------------------

-- A quest ID the client knows, or nil.
local function ValidQuestID(id)
    id = tonumber(id)
    if id and id > 0 and _G.C_QuestLog.GetTitleForQuestID(id) then
        return id
    end
end

-- The tracker block under the mouse: the focus itself or up to two parents
-- (HeaderButton -> block).
local function QuestIDUnderMouse()
    local foci = _G.GetMouseFoci and _G.GetMouseFoci()
    local frame = foci and foci[1]
    for _ = 1, 3 do
        if not frame then return end
        if frame.parentModule then
            return ValidQuestID(frame.id)
        end
        frame = frame:GetParent()
    end
end

local function AddEntry(rootDescription, questID)
    if not (questID and RealUI_Tracker.db.profile.display.wowheadLink) then return end
    rootDescription:CreateDivider()
    rootDescription:CreateButton("Wowhead link", function()
        ShowURL(questID)
    end)
end

function RealUI_Tracker:SetupWowhead()
    local Menu = _G.Menu
    if not (Menu and Menu.ModifyMenu) then return end

    local function FromTracker(_, rootDescription)
        AddEntry(rootDescription, QuestIDUnderMouse())
    end
    Menu.ModifyMenu("MENU_QUEST_OBJECTIVE_TRACKER", FromTracker)
    Menu.ModifyMenu("MENU_BONUS_OBJECTIVE_TRACKER", FromTracker)

    -- The quest log's title button carries its own questID.
    Menu.ModifyMenu("MENU_QUEST_MAP_LOG_TITLE", function(owner, rootDescription)
        AddEntry(rootDescription, ValidQuestID(owner and owner.questID))
    end)
end
