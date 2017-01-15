local _, private = ...

-- Lua Globals --
local next = _G.next

-- Libs --
local LDB = _G.LibStub("LibDataBroker-1.1")
local qTip = _G.LibStub("LibQTip-1.0")
local qTipAquire = qTip.Acquire
function qTip:Acquire(...)
    local tooltip = qTipAquire(self, ...)
    if _G.Aurora and not tooltip._skinned then
        _G.Aurora[1].CreateBD(tooltip)
        tooltip._skinned = true
    end
    return tooltip
end

local artData = _G.LibStub("LibArtifactData-1.0", true)
local fa = _G.LibStub("LibIconFonts-1.0"):GetIconFont("FontAwesome")
fa.path = [[Interface\AddOns\nibRealUI\Fonts\FontAwesome\fontawesome-webfont.ttf]]

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local L = RealUI.L

local MODNAME = "InfoLine"
local InfoLine = RealUI:GetModule(MODNAME)
local testCell = _G.UIParent:CreateFontString()
testCell:SetPoint("CENTER")
testCell:SetSize(500, 20)
testCell:Hide()

local headerFont, textFont, iconFont
do
    local size = RealUI.ModValue(12)
    local font, _, outline = _G.RealUIFont_Normal:GetFont()
    local header = _G.CreateFont("RealUI_TooltipHeader")
    header:SetFont(font, size, outline)
    headerFont = {
        font = font,
        size = size,
        outline = outline,
        object = header
    }

    size = RealUI.ModValue(8)
    font, _, outline = _G.RealUIFont_Chat:GetFont()
    local text = _G.CreateFont("RealUI_TooltipText")
    text:SetFont(font, size, outline)
    textFont = {
        font = font,
        size = size,
        outline = outline,
        object = text
    }

    size = RealUI.ModValue(10)
    iconFont = {
        font = fa.path,
        size = size,
        outline = "OUTLINE"
    }
end

local TextTableCellProvider, TextTableCellPrototype = qTip:CreateCellProvider()
do
    local MAX_ROWS = 10
    local ROW_HEIGHT = textFont.size
    local numTables = 0
    local extData = {}

    local GTT_FrameLevel
    local function Cell_OnEnter(self)
        self.row:GetScript("OnEnter")(self.row)
        local text = self:GetTooltipText()
        if text then
            GTT_FrameLevel = _G.GameTooltip:GetFrameLevel()
            _G.GameTooltip:SetFrameLevel(1000)
            _G.GameTooltip:SetOwner(self, "ANCHOR_TOP")
            _G.GameTooltip:SetText(text)
            _G.GameTooltip:Show()
        end
    end
    local function Cell_OnLeave(self)
        self.row:GetScript("OnLeave")(self.row)
        if GTT_FrameLevel and _G.GameTooltip:IsShown() then
            _G.GameTooltip:SetFrameLevel(GTT_FrameLevel)
            _G.GameTooltip:Hide()
        end
    end

    local function UpdateScroll(self)
        InfoLine:debug("UpdateScroll", self:GetDebugName(), self:GetName())
        local offset = _G.FauxScrollFrame_GetOffset(self) or 0
        local data = self.textTable.data
        local header = self.textTable.header
        InfoLine:debug("offset", offset)
        for i = 1, MAX_ROWS do
            local index = offset + i
            local row = self.textTable.rows[i]
            InfoLine:debug("row", i, index)
            if i > #data then
                row:Hide()
            else
                for col = 1, #header do
                    local cell = row[col]
                    if not cell then
                        cell = _G.CreateFrame("Button", "$parentCell"..col, row)
                        cell:SetID(col)
                        cell:SetPoint("TOP")
                        cell:SetPoint("BOTTOM")
                        cell:SetPoint("LEFT", header[col])
                        cell:SetPoint("RIGHT", header[col])
                        cell.row = row
                        row[col] = cell

                        local text = cell:CreateFontString(nil, "ARTWORK")
                        text:SetFont(textFont.font, textFont.size, textFont.outline)
                        text:SetJustifyH(data.header.justify[col])
                        text:SetAllPoints()
                        cell:SetFontString(text)
                        cell:SetPushedTextOffset(0, 0)

                        cell:SetScript("OnClick", function(c)
                            c.row:GetScript("OnClick")(c.row)
                        end)
                    end
                    local rowData = data[index]
                    if rowData then
                        rowData.id = i
                        row.meta = rowData.meta
                        cell.GetTooltipText = data.cellGetTooltipText
                        cell:SetText(rowData.info[col])
                        cell:SetScript("OnEnter", Cell_OnEnter)
                        cell:SetScript("OnLeave", Cell_OnLeave)
                    else
                        cell:SetText("")
                        cell:SetScript("OnEnter", nil)
                        cell:SetScript("OnLeave", nil)
                    end
                end
                row:Show()
            end
        end

        self:Show()
        local numToDisplay = _G.min(MAX_ROWS, #data)
        local scrollFrameHeight = (#data - numToDisplay) * ROW_HEIGHT
        if ( scrollFrameHeight < 0 ) then
            scrollFrameHeight = 0
        end

        local scrollBar = self.ScrollBar
        scrollBar:SetMinMaxValues(0, scrollFrameHeight)
        scrollBar:SetValueStep(ROW_HEIGHT)
        scrollBar:SetStepsPerPage(numToDisplay - 1)

        -- Arrow button handling
        local scrollUpButton = scrollBar.ScrollUpButton
        local scrollDownButton = scrollBar.ScrollDownButton

        if ( scrollBar:GetValue() == 0 ) then
            scrollUpButton:Disable()
        else
            scrollUpButton:Enable()
        end
        if ((scrollBar:GetValue() - scrollFrameHeight) == 0) then
            scrollDownButton:Disable()
        else
            scrollDownButton:Enable()
        end

        return (numToDisplay + 1) * ROW_HEIGHT
    end

    do --[[ Sort ]]--
        -- Default sort handler for columns.
        -- Uses Lua's less-than operator.  Nil values are sorted as empty strings.
        -- @param val1  Element value for row 1.
        -- @param val2  Element value for row 2.
        -- @param row1..row2  Row tables being compared.
        -- @return True/false if val1 is less/greater than val2, or nil if they are equal.
        local function SortSimple(val1, val2 --[[, row1, row2]])
            if val1 ~= val2 then
                return val1 < val2
            end
        end


        local sortHandler, sortColumn, sortInverted
        -- Compare function for table.sort that supports inversion and custom sort handlers.
        local function Compare(row1, row2)
            InfoLine:debug("Compare1", row1.info[sortColumn])
            InfoLine:debug("Compare2", row2.info[sortColumn])
            local result

            InfoLine:debug("sortInverted", sortInverted)
            if sortInverted then -- Flip the sorthandler's args
                result = sortHandler(row2.info[sortColumn], row1.info[sortColumn], row2, row1)
            else
                result = sortHandler(row1.info[sortColumn], row2.info[sortColumn], row1, row2)
            end

            if result ~= nil then -- Not equal
                return result
            else -- Equal
                return row1.id < row2.id -- Fall back on previous row order
            end
        end

        local function OnUpdate(self, ...)
            InfoLine:debug("textTable:OnUpdate", ...)
            self:SetScript("OnUpdate", nil)
            local data = self.data

            if extData[data].sortColumn and #data > 0 then
                sortColumn = extData[data].sortColumn:GetID()
                InfoLine:debug("Header_OnClick", sortColumn, ...)


                sortInverted = extData[data].sortInverted
                if data.header.sort then
                    sortHandler = data.header.sort[sortColumn]
                    if sortHandler == true then
                        sortHandler = SortSimple -- Less-than operator
                    end
                else
                    sortHandler = SortSimple
                end

                _G.sort(data, Compare)
                UpdateScroll(self.scrollArea)
            end
        end

        function TextTableCellPrototype:SetSort(header, inverted)
            InfoLine:debug("CellProto:SetSort", header:GetID(), inverted)
            local textTable = self.textTable
            local data = textTable.data
            if extData[data].sortColumn ~= header then
                extData[data].sortColumn, extData[data].sortInverted = header, inverted or false

                if header then
                    textTable:SetScript("OnUpdate", OnUpdate)
                end
            elseif header then -- Selected same sort column
                if inverted == nil then -- Unspecified, flip inverted status
                    inverted = not extData[data].sortInverted
                end

                extData[data].sortInverted = inverted
                textTable:SetScript("OnUpdate", OnUpdate)
            end
        end
    end

    function TextTableCellPrototype:SetRowOnClick(func)
        for index = 1, MAX_ROWS do
            local row = self.textTable.rows[index]
            row:SetScript("OnClick", func)
        end
    end

    function TextTableCellPrototype:InitializeCell()
        InfoLine:debug("CellProto:InitializeCell")

        if not self.textTable then
            numTables = numTables + 1
            local textTable = _G.CreateFrame("Frame", "IL_TextTable"..numTables, self)
            textTable:SetPoint("TOPLEFT")
            textTable:SetPoint("BOTTOMRIGHT")
            textTable:EnableMouse(true)

            --[[ Test BG
            local test = textTable:CreateTexture(nil, "BACKGROUND")
            test:SetColorTexture(1, 1, 1, 0.5)
            test:SetAllPoints(textTable)]]

            textTable.header = _G.CreateFrame("Frame", "$parentHeader", textTable) -- textTable:CreateFontString(nil, "ARTWORK", "RealUIFont_Header")
            textTable.header:SetPoint("TOPLEFT")
            textTable.header:SetPoint("RIGHT")
            textTable.header:SetHeight(ROW_HEIGHT)

            local line = textTable:CreateTexture(nil, "BACKGROUND")
            line:SetColorTexture(1, 1, 1)
            line:SetPoint("TOPLEFT", textTable.header, "BOTTOMLEFT", 0, -5)
            line:SetPoint("RIGHT")
            line:SetHeight(1)

            textTable.scrollArea = _G.CreateFrame("ScrollFrame", "$parentScroll", textTable, "FauxScrollFrameTemplate")
            textTable.scrollArea:SetPoint("TOPLEFT", line, 0, -5)
            textTable.scrollArea:SetPoint("BOTTOMRIGHT")
            textTable.scrollArea:SetScript("OnVerticalScroll", function(scroll, offset)
                _G.FauxScrollFrame_OnVerticalScroll(scroll, offset, ROW_HEIGHT, UpdateScroll)
            end)
            textTable.scrollArea.textTable = textTable

            local prev = textTable.scrollArea
            textTable.rows = {}
            for index = 1, MAX_ROWS do
                local row = _G.CreateFrame("Button", "$parentRow"..index, textTable)
                if index == 1 then -- textTable:CreateFontString(nil, "ARTWORK", "RealUIFont_Normal")
                    row:SetPoint("TOPLEFT", prev)
                else
                    row:SetPoint("TOPLEFT", prev, "BOTTOMLEFT")
                end
                row:SetPoint("RIGHT")
                row:SetHeight(ROW_HEIGHT)
                row:SetScript("OnEnter", function(r)
                    r.highlight:Show()
                end)
                row:SetScript("OnLeave", function(r)
                    r.highlight:Hide()
                end)

                local highlight = row:CreateTexture(nil, "BACKGROUND")
                local r, g, b = _G.unpack(RealUI.classColor)
                highlight:SetColorTexture(r, g, b, 0.25)
                highlight:SetAllPoints()
                highlight:Hide()
                row.highlight = highlight

                textTable.rows[index] = row
                prev = row
            end

            self.textTable = textTable
        end
    end

    function TextTableCellPrototype:SetupCell(tooltip, data, justification, font, r, g, b)
        InfoLine:debug("CellProto:SetupCell")
        local textTable = self.textTable
        local width = data.width or 500
        extData[data] = extData[data] or {}
        textTable.data = data

        local flex, filler = {}
        local remainingWidth = width
        local headerRow, headerData = textTable.header, data.header
        for col = 1, #headerData.info do
            local header = headerRow[col]
            if not header then
                header = _G.CreateFrame("Button", nil, headerRow)
                header:SetID(col)
                header:SetPoint("TOP", 0, -4)
                header:SetPoint("BOTTOM")
                if col == 1 then
                    header:SetPoint("LEFT")
                else
                    header:SetPoint("LEFT", headerRow[col-1], "RIGHT", 2, 0)
                end

                header.text = header:CreateFontString(nil, "ARTWORK")
                header.text:SetFont(textFont.font, textFont.size, textFont.outline)
                header.text:SetTextColor(_G.unpack(RealUI.media.colors.orange))
                header.text:SetAllPoints()

                local hR, hG, hB = _G.unpack(RealUI.classColor)
                local highlight = header:CreateTexture(nil, "ARTWORK")
                highlight:SetColorTexture(hR, hG, hB)
                highlight:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -5)
                highlight:SetPoint("RIGHT")
                highlight:SetHeight(3)
                header:SetHighlightTexture(highlight)
                header.hl = highlight

                header.textTable = textTable
                headerRow[col] = header
            end
            if headerData.sort then
                header.hl:Show()
                header:SetScript("OnClick", function(btn)
                    _G.PlaySound("igMainMenuOptionCheckBoxOn")
                    self:SetSort(btn)
                end)
            else
                header.hl:Hide()
            end
            header.text:SetText(headerData.info[col])
            header.text:SetJustifyH(headerData.justify[col])

            local size = headerData.size[col]
            if size == "FIT" then
                local cellWidth = header.text:GetStringWidth()
                testCell:SetFont(textFont.font, textFont.size, textFont.outline)
                for i = 1, #data do
                    testCell:SetText(data[i].info[col])
                    local newWidth = testCell:GetStringWidth()
                    if newWidth > cellWidth then cellWidth = newWidth end
                end
                header:SetWidth(cellWidth)
                remainingWidth = remainingWidth - cellWidth
            elseif size == "FILL" then
                filler = header
            else
                flex[header] = size
            end
            InfoLine:debug("Width", col, remainingWidth)
        end
        for header, size in next, flex do
            local headerWidth = _G.max(width * size, header.text:GetStringWidth())
            remainingWidth = remainingWidth - headerWidth
            header:SetWidth(headerWidth)
            InfoLine:debug("Width", headerWidth, remainingWidth)
        end
        filler:SetWidth(_G.max(remainingWidth, filler.text:GetStringWidth()))

        InfoLine:debug("Sort", extData[data].sortColumn, extData[data].sortInverted)
        if extData[data].sortColumn then
            self:SetSort(extData[data].sortColumn, extData[data].sortInverted)
        elseif data.defaultSort then
            self:SetSort(headerRow[data.defaultSort])
        end

        if data.rowOnClick then
            self:SetRowOnClick(data.rowOnClick)
        end

        local cellHeight = UpdateScroll(textTable.scrollArea)
        textTable:Show()

        return width, cellHeight + 11
    end

    function TextTableCellPrototype:ReleaseCell()
        InfoLine:debug("CellProto:ReleaseCell")
        if self.textTable then
            local headerRow = self.textTable.header
            for col = 1, #headerRow do
                headerRow[col]:SetScript("OnClick", nil)
            end

            for index = 1, MAX_ROWS do
                local row = self.textTable.rows[index]
                row:SetScript("OnClick", nil)
                for col = 1, #headerRow do
                    local cell = row[col]
                    if cell then
                        cell:SetScript("OnEnter", nil)
                        cell:SetScript("OnLeave", nil)
                    end
                end
            end
            self.textTable:Hide()
        end
    end

    function TextTableCellPrototype:getContentHeight()
        InfoLine:debug("CellProto:getContentHeight")
        return self.textTable:GetHeight()
    end
end

local function SetupTooltip(tooltip, block)
    tooltip:SetHeaderFont(headerFont.object)
    tooltip:SetFont(textFont.object)
    tooltip:SmartAnchorTo(block)
    tooltip:SetAutoHideDelay(0.10, block)
    block.tooltip = tooltip
end

--[[
do -- template
    LDB:NewDataObject("test", {
        name = "Test",
        type = "RealUI",
        icon = fa["group"],
        iconFont = iconFont,
        text = "TEST 1 test",
        value = 1,
        suffix = "test",
        OnEnter = function(block, ...)
            if qTip:IsAcquired(block) then return end
            --InfoLine:debug("Test: OnEnter", block.side, ...)

            local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
            SetupTooltip(tooltip, block)
            local lineNum, colNum

            tooltip:AddHeader("Header")
            tooltip:AddLine("Left", "Right")

            tooltip:Show()
        end,
    })
end
--]]

local nameMatch = [=[|cff%x%x%x%x%x%x(.*)|r]=]
function InfoLine:CreateBlocks()
    local dbc = InfoLine.db.char

    --[[ Static Blocks ]]--
    do  -- Start
        local startMenu = _G.CreateFrame("Frame", "RealUIStartDropDown", _G.UIParent, "Lib_UIDropDownMenuTemplate")
        local menuList = {
            {text = L["Start_Config"],
                func = function() RealUI:LoadConfig("HuD") end,
                notCheckable = true,
            },
            {text = L["General_Lock"],
                func = function()
                    if InfoLine.locked then
                        InfoLine:Unlock()
                    else
                        InfoLine:Lock()
                    end
                end,
                checked = function() return InfoLine.locked end,
            },
            {text = "",
                notCheckable = true,
                disabled = true,
            },
            {text = _G.CHARACTER_BUTTON,
                func = function() _G.ToggleCharacter("PaperDollFrame") end,
                notCheckable = true,
            },
            {text = _G.SPELLBOOK_ABILITIES_BUTTON,
                func = function() _G.ToggleSpellBook(_G.BOOKTYPE_SPELL) end,
                notCheckable = true,
            },
            {text = _G.TALENTS_BUTTON,
                func = function()
                    if not _G.PlayerTalentFrame then
                        _G.TalentFrame_LoadUI()
                    end

                    _G.ShowUIPanel(_G.PlayerTalentFrame)
                end,
                notCheckable = true,
                disabled = _G.UnitLevel("player") < _G.SHOW_SPEC_LEVEL,
            },
            {text = _G.ACHIEVEMENT_BUTTON,
                func = function() _G.ToggleAchievementFrame() end,
                notCheckable = true,
            },
            {text = _G.QUESTLOG_BUTTON,
                func = function() _G.ToggleQuestLog() end,
                notCheckable = true,
            },
            {text = _G.IsInGuild() and _G.GUILD or _G.LOOKINGFORGUILD,
                func = function()
                    if _G.IsInGuild() then
                        if not _G.GuildFrame then _G.GuildFrame_LoadUI() end
                        _G.GuildFrame_Toggle()
                    else
                        if not _G.LookingForGuildFrame then _G.LookingForGuildFrame_LoadUI() end
                        _G.LookingForGuildFrame_Toggle()
                    end
                end,
                notCheckable = true,
                disabled = _G.IsTrialAccount() or (_G.IsVeteranTrialAccount() and not _G.IsInGuild()),
            },
            {text = _G.SOCIAL_BUTTON,
                func = function() _G.ToggleFriendsFrame(1) end,
                notCheckable = true,
            },
            {text = _G.DUNGEONS_BUTTON,
                func = function() _G.PVEFrame_ToggleFrame() end,
                notCheckable = true,
                disabled = _G.UnitLevel("player") < _G.min(_G.SHOW_LFD_LEVEL, _G.SHOW_PVP_LEVEL),
            },
            {text = _G.COLLECTIONS,
                func = function() _G.ToggleCollectionsJournal() end,
                notCheckable = true,
            },
            {text = _G.ADVENTURE_JOURNAL,
                func = function() _G.ToggleEncounterJournal() end,
                notCheckable = true,
            },
            {text = _G.BLIZZARD_STORE,
                func = function() _G.ToggleStoreUI() end,
                notCheckable = true,
            },
            {text = _G.HELP_BUTTON,
                func = function() _G.ToggleHelpFrame() end,
                notCheckable = true,
            },
            {text = "",
                notCheckable = true,
                disabled = true,
            },
            {text = _G.CANCEL,
                func = function() _G.CloseDropDownMenus() end,
                notCheckable = true,
            },
        }

        LDB:NewDataObject("start", {
            name = L["Start"],
            type = "RealUI",
            icon = fa["bars"],
            iconFont = iconFont,
            OnEnter = function(block, ...)
                InfoLine:debug("Start: OnEnter", block.side, ...)
                _G.Lib_EasyMenu(menuList, startMenu, block, 0, 0, "MENU", 1)
            end,
        })
        _G.Lib_UIDropDownMenu_SetAnchor(startMenu, 0, 0, "BOTTOMLEFT", InfoLine.frame, "TOPLEFT")
    end

    do  -- Clock
        local function RetrieveTime(isMilitary, isLocal)
            local timeFormat, hour, min, suffix
            if isLocal then
                hour, min = _G.tonumber(_G.date("%H")), _G.tonumber(_G.date("%M"))
            else
                hour, min = _G.GetGameTime()
            end
            if isMilitary then
                timeFormat = _G.TIMEMANAGER_TICKER_24HOUR
                suffix = ""
            else
                timeFormat = _G.TIMEMANAGER_TICKER_12HOUR
                if hour >= 12 then
                    suffix = _G.TIMEMANAGER_PM
                    if hour > 12 then
                        hour = hour - 12
                    end
                else
                    suffix = _G.TIMEMANAGER_AM
                    if hour == 0 then
                        hour = 12
                    end
                end
            end
            return timeFormat, hour, min, suffix
        end

        LDB:NewDataObject("clock", {
            name = _G.TIMEMANAGER_TITLE,
            type = "RealUI",
            text = 1,
            value = 1,
            suffix = "",
            OnEnable = function(block)
                InfoLine:debug("clock: OnEnable", block.side)
                local function setTimeOptions()
                    block.isMilitary = _G.GetCVar("timeMgrUseMilitaryTime") == "1"
                    block.isLocal = _G.GetCVar("timeMgrUseLocalTime") == "1"
                end
                _G.hooksecurefunc("TimeManager_ToggleTimeFormat", setTimeOptions)
                _G.hooksecurefunc("TimeManager_ToggleLocalTime", setTimeOptions)
                setTimeOptions(block)

                local alert = _G.CreateFrame("Frame", nil, block, "MicroButtonAlertTemplate")
                alert:SetSize(177, alert.Text:GetHeight() + 42)
                alert:SetPoint("BOTTOMRIGHT", block, "TOPRIGHT", 0, 18)
                alert.Arrow:SetPoint("TOPRIGHT", alert, "BOTTOMRIGHT", -30, 4)
                alert.CloseButton:SetScript("OnClick", function(btn)
                    alert:Hide()
                    alert.isHidden = true
                end)
                alert.Text:SetText(_G.GAMETIME_TOOLTIP_CALENDAR_INVITES)
                alert.Text:SetWidth(145)
                block.alert = alert

                InfoLine:ScheduleRepeatingTimer(function()
                    local timeFormat, hour, min, suffix = RetrieveTime(block.isMilitary, block.isLocal)
                    block.dataObj.value = timeFormat:format(hour, min)
                    block.dataObj.suffix = suffix
                end, 1)
            end,
            OnClick = function(block, ...)
                InfoLine:debug("Clock: OnClick", block.side, ...)
                if _G.IsAltKeyDown() then
                    _G.ToggleTimeManager()
                else
                    if _G.IsAddOnLoaded("GroupCalendar5") then
                        if _G.GroupCalendar.UI.Window:IsShown() then
                            _G.HideUIPanel(_G.GroupCalendar.UI.Window)
                        else
                            _G.ShowUIPanel(_G.GroupCalendar.UI.Window)
                        end
                    else
                        _G.ToggleCalendar()
                    end
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --InfoLine:debug("Clock: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 3, "LEFT", "CENTER", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                tooltip:AddHeader(_G.TIMEMANAGER_TOOLTIP_TITLE)
                --tooltip:SetCell(lineNum, colNum, , nil, 2)

                -- Realm time
                local timeFormat, hour, min, suffix = RetrieveTime(block.isMilitary, false)
                tooltip:AddLine(_G.TIMEMANAGER_TOOLTIP_REALMTIME, " ", timeFormat:format(hour, min) .. " " .. suffix)

                -- Local time
                timeFormat, hour, min, suffix = RetrieveTime(block.isMilitary, true)
                tooltip:AddLine(_G.TIMEMANAGER_TOOLTIP_LOCALTIME, " ", timeFormat:format(hour, min) .. " " .. suffix)

                -- Date
                lineNum = tooltip:AddLine() --L["Clock_Date"], date("%b %d (%a)"))
                tooltip:SetCell(lineNum, 1, L["Clock_Date"])
                tooltip:SetCell(lineNum, 2, _G.date("%b %d (%a)"), "RIGHT", 2)

                -- Invites
                if block.invites and block.invites > 0 then
                    tooltip:AddLine(" ")
                    lineNum, colNum = tooltip:AddLine()
                    tooltip:SetCell(lineNum, colNum, L["Clock_CalenderInvites"], block.invites, 2)
                end

                -- World Bosses
                local numSavedBosses = _G.GetNumSavedWorldBosses()
                if (_G.UnitLevel("player") >= 90) and (numSavedBosses > 0) then
                    tooltip:AddLine(" ")
                    lineNum, colNum = tooltip:AddHeader()
                    tooltip:SetCell(lineNum, colNum, _G.LFG_LIST_BOSSES_DEFEATED, nil, 2)
                    for i = 1, numSavedBosses do
                        local bossName, _, bossReset = _G.GetSavedWorldBossInfo(i)
                        tooltip:AddLine(bossName, _G.format(_G.SecondsToTimeAbbrev(bossReset)))
                    end
                end

                tooltip:AddLine(" ")

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, L["Clock_ShowCalendar"], nil, 2)
                tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, L["Clock_ShowTimer"], nil, 2)
                tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                --InfoLine:debug("Clock: OnEvent", event, ...)
                local alert = block.alert
                block.invites = _G.CalendarGetNumPendingInvites()
                if block.invites > 0 and not alert.isHidden then
                    alert:Show()
                    alert.isHidden = false
                else
                    alert:Hide()
                end
            end,
            events = {
                "CALENDAR_UPDATE_EVENT_LIST",
                "PLAYER_ENTERING_WORLD",
            },
        })
    end

    --[[ Left ]]--
    do  -- Guild Roster
        local inlineTexture = [[|T%s:14:14:0:0:16:16:0:16:0:16|t]]
        local RemoteChatStatus = {
            [0] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:74:176:74|t]],
            [1] = inlineTexture:format([[Interface\ChatFrame\UI-ChatIcon-ArmoryChat-AwayMobile]]),
            [2] = inlineTexture:format([[Interface\ChatFrame\UI-ChatIcon-ArmoryChat-BusyMobile]]),
        }
        local PlayerStatus = {
            [1] = inlineTexture:format(_G.FRIENDS_TEXTURE_AFK),
            [2] = inlineTexture:format(_G.FRIENDS_TEXTURE_DND),
        }

        local NameSort do
            function NameSort(val1, val2, row1, row2)
                InfoLine:debug("NameSort", _G.strsplit("|", val1))
                val1 = val1:match(nameMatch)
                val2 = val2:match(nameMatch)
                InfoLine:debug("Player1", val1)
                InfoLine:debug("Player2", val2)

                local isMobile1 = row1.meta[1]
                local isMobile2 = row2.meta[1]
                if isMobile1 ~= isMobile2 then
                    if isMobile1 and not isMobile2 then
                        return false
                    elseif not isMobile1 and isMobile2 then
                        return true
                    end
                elseif val1 ~= val2 then
                    return val1 < val2
                end
            end
        end
        local RankSort do
            local rankTable = {}
            for i = 1, _G.GuildControlGetNumRanks() do
                rankTable[_G.GuildControlGetRankName(i)] = i
            end

            function RankSort(val1, val2)
                if val1 ~= val2 then
                    return rankTable[val1] < rankTable[val2]
                end
            end
        end
        local NoteSort do
            function NoteSort(val1, val2)
                if val1 and val2 then
                    if val1 ~= val2 then
                        return val1 < val2
                    end
                else
                    if val1 and not val2 then
                        return true
                    elseif not val1 and val2 then
                        return false
                    end
                end
            end
        end

        local function Guild_OnClick(row, ...)
            local name = row[1]:GetText():match(nameMatch)
            if not name then return end

            if _G.IsAltKeyDown() then
                _G.InviteUnit(name)
            else
                _G.SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
            end
        end
        local function Guild_GetTooltipText(cell)
            InfoLine:debug("Guild_GetTooltipText")
            if cell:GetTextWidth() > cell:GetWidth() then
                InfoLine:debug("Guild_GetTooltipText true")
                return cell:GetText()
            end
        end

        local time, tableWidth = _G.GetTime(), 500
        local guildData = {}
        local headerData = {
            sort = {
                NameSort, true, true, RankSort, NoteSort, NoteSort
            },
            info = {
                _G.NAME, _G.LEVEL_ABBR, _G.ZONE, _G.RANK, _G.LABEL_NOTE, _G.OFFICER_NOTE_COLON
            },
            justify = {
                "LEFT", "RIGHT", "LEFT", "LEFT", "LEFT", "LEFT"
            },
            size = {
                "FILL", "FIT", 0.2, "FIT", 0.2, 0.2
            }
        }

        LDB:NewDataObject("guild", {
            name = _G.GUILD,
            type = "RealUI",
            icon = fa["group"],
            iconFont = iconFont,
            text = 1,
            value = 1,
            suffix = "",
            OnEnable = function(block, ...)
                InfoLine:debug("Guild: OnEnable", block.side, ...)
                if not _G.IsInGuild() then
                    local info = InfoLine:GetBlockInfo(block.name, block.dataObj)
                    InfoLine:RemoveBlock(block.name, block.dataObj, info)
                end
            end,
            OnClick = function(block, ...)
                InfoLine:debug("Guild: OnClick", block.side, ...)
                if not _G.InCombatLockdown() then
                    _G.ToggleGuildFrame()
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --InfoLine:debug("Guild: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 1, "LEFT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                local gname = _G.GetGuildInfo("player")
                tooltip:AddHeader(gname)

                local motd = _G.GetGuildRosterMOTD()
                if motd ~= "" then
                    lineNum, colNum = tooltip:AddLine()
                    tooltip:SetCell(lineNum, colNum, motd, nil, "LEFT", nil, nil, nil, nil, tableWidth)
                end

                _G.table.wipe(guildData)
                guildData.width = tableWidth
                guildData.header = headerData
                guildData.defaultSort = 4
                guildData.rowOnClick = Guild_OnClick
                guildData.cellGetTooltipText = Guild_GetTooltipText
                for i = 1, _G.GetNumGuildMembers() do
                    local name, rank, _, lvl, _, zone, note, offnote, isOnline, status, class, _, _, isMobile = _G.GetGuildRosterInfo(i)
                    if isOnline or isMobile then
                        -- Remove server from name
                        name = _G.Ambiguate(name, "guild")

                        -- Class color names
                        local color = RealUI:GetClassColor(class, "hex")
                        name = _G.PLAYER_CLASS_NO_SPEC:format(color, name)

                        -- Tags
                        if isMobile then
                            zone = _G.REMOTE_CHAT
                            name = RemoteChatStatus[status] .. name
                        elseif status > 0 then
                            name = PlayerStatus[status] .. name
                        end

                        -- Difficulty color levels
                        color = _G.ConvertRGBtoColorString(_G.GetQuestDifficultyColor(lvl))
                        lvl = ("%s%d|r"):format(color, lvl)

                        if note == "" then note = nil end
                        if offnote == "" then offnote = nil end

                        _G.tinsert(guildData, {
                            id = i,
                            info = {
                                name, lvl, zone, rank, note, offnote
                            },
                            meta = {
                                isMobile
                            }
                        })
                    end
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, guildData, TextTableCellProvider)

                lineNum = tooltip:AddLine(L["GuildFriend_WhisperInvite"]:format(_G[_G.GetDisplayedInviteType()]))
                tooltip:SetLineTextColor(lineNum, 0, 1, 0)

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                InfoLine:debug("Guild: OnEvent", event, ...)
                local isVisible, isInGuild = block:IsVisible(), _G.IsInGuild()
                if isVisible and not isInGuild then
                    local info = InfoLine:GetBlockInfo(block.name, block.dataObj)
                    InfoLine:RemoveBlock(block.name, block.dataObj, info)
                elseif not isVisible and isInGuild then
                    local info = InfoLine:GetBlockInfo(block.name, block.dataObj)
                    InfoLine:AddBlock(block.name, block.dataObj, info)
                end

                local now = _G.GetTime()
                InfoLine:debug("Guild: time", now - time)
                if now - time > 10 then
                    _G.GuildRoster()
                    time = now
                else
                    local _, online, onlineAndMobile = _G.GetNumGuildMembers()
                    block.dataObj.value = online
                    if online == onlineAndMobile then
                        block.dataObj.suffix = ""
                    else
                        block.dataObj.suffix = "(".. onlineAndMobile - online ..")"
                    end
                end
            end,
            events = {
                "PLAYER_GUILD_UPDATE",
                "GUILD_ROSTER_UPDATE",
                "GUILD_MOTD",
            },
        })
    end

    -- Friends

    do  -- Durability
        local itemSlots = {
            {slot = "Head", hasDura = true},
            {slot = "Neck", hasDura = false},
            {slot = "Shoulder", hasDura = true},
            {}, -- shirt
            {slot = "Chest", hasDura = true},
            {slot = "Waist", hasDura = true},
            {slot = "Legs", hasDura = true},
            {slot = "Feet", hasDura = true},
            {slot = "Wrist", hasDura = true},
            {slot = "Hands", hasDura = true},
            {slot = "Finger0", hasDura = false},
            {slot = "Finger1", hasDura = false},
            {slot = "Trinket0", hasDura = false},
            {slot = "Trinket1", hasDura = false},
            {slot = "Back", hasDura = false},
            {slot = "MainHand", hasDura = true},
            {slot = "SecondaryHand", hasDura = true},
        }

        LDB:NewDataObject("durability", {
            name = _G.DURABILITY,
            type = "RealUI",
            icon = fa["heartbeat"],
            iconFont = iconFont,
            text = 1,
            OnClick = function(block, ...)
                InfoLine:debug("Durability: OnClick", block.side, ...)
                if not _G.InCombatLockdown() then
                    _G.ToggleCharacter("PaperDollFrame")
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --InfoLine:debug("Durability: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetHeaderFont(headerFont.object)
                tooltip:SetFont(textFont.object)
                tooltip:SetCell(lineNum, colNum, _G.DURABILITY, nil, 2)

                for slotID = 1, #itemSlots do
                    local item = itemSlots[slotID]
                    if item.hasDura and item.dura then
                        lineNum = tooltip:AddLine(item.slot, round(item.dura * 100, 1) .. "%")
                        if slotID == itemSlots.lowSlot then
                            tooltip:SetLineTextColor(lineNum, RealUI.GetDurabilityColor(item.min, item.max))
                        else
                            tooltip:SetCellTextColor(lineNum, 2, RealUI.GetDurabilityColor(item.min, item.max))
                        end
                    end
                end

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                InfoLine:debug("Durability1: OnEvent", event, ...)
                local lowDur, lowMin, lowMax, lowSlot = 1, 1, 1
                for slotID = 1, #itemSlots do
                    local item = itemSlots[slotID]
                    if item.hasDura then
                        local min, max = _G.GetInventoryItemDurability(slotID)
                        if max then
                            item.dura = RealUI:GetSafeVals(min, max)
                            item.min, item.max = min, max
                            if lowDur > item.dura then
                                lowDur, lowSlot = item.dura, slotID
                                lowMin, lowMax = min, max
                            end
                            InfoLine:debug(slotID, item.slot, round(item.dura, 3), min, lowMin)
                        end
                    end
                end
                itemSlots.lowSlot = lowSlot
                if not block.alert then
                    block.alert = _G.CreateFrame("Frame", nil, block, "MicroButtonAlertTemplate")
                end
                local alert = block.alert
                if lowDur < 0.1 and not alert.isHidden then
                    alert:SetSize(177, alert.Text:GetHeight() + 42)
                    alert.Arrow:SetPoint("TOP", alert, "BOTTOM", -30, 4)
                    alert:SetPoint("BOTTOM", block, "TOP", 30, 18)
                    alert.CloseButton:SetScript("OnClick", function(btn)
                        alert:Hide()
                        alert.isHidden = true
                    end)
                    alert.Text:SetFormattedText("%s %d%%", _G.DURABILITY, round(lowDur * 100))
                    alert.Text:SetWidth(145)
                    alert:Show()
                    alert.isHidden = false
                else
                    alert:Hide()
                end
                block.dataObj.text = round(lowDur * 100) .. "%"
                block.dataObj.iconR, block.dataObj.iconG, block.dataObj.iconB = RealUI.GetDurabilityColor(lowMin, lowMax)
                block.timer = false
            end,
            events = {
                "UPDATE_INVENTORY_DURABILITY",
                "PLAYER_EQUIPMENT_CHANGED",
                "PLAYER_ENTERING_WORLD",
            },
        })
    end

    do -- Progress Watch
        local watchStates, artifactInit = {}
        watchStates["xp"] = {
            GetNext = function(XP)
                if watchStates["rep"]:IsValid() then
                    return "rep"
                elseif watchStates["artifact"]:IsValid() then
                    return "artifact"
                elseif watchStates["honor"]:IsValid() then
                    return "honor"
                elseif watchStates["xp"]:IsValid() then
                    return "xp"
                else
                    return nil
                end
            end,
            GetStats = function(XP)
                return _G.UnitXP("player"), _G.UnitXPMax("player"), _G.GetXPExhaustion()
            end,
            GetColor = function(XP, isRested)
                if isRested then
                    return 0.0, 0.39, 0.88
                else
                    return 0.58, 0.0, 0.5
                end
            end,
            IsValid = function(XP)
                return _G.UnitLevel("player") < _G.MAX_PLAYER_LEVEL_TABLE[_G.GetExpansionLevel()]
            end,
            SetTooltip = function(XP, tooltip)
                local curXP, maxXP, restXP = XP:GetStats()
                local xpStatus = ("%s/%s (%d%%)"):format(RealUI:ReadableNumber(curXP), RealUI:ReadableNumber(maxXP), (curXP/maxXP)*100)
                local lineNum = tooltip:AddLine(_G.EXPERIENCE_COLON, xpStatus)
                tooltip:SetCellTextColor(lineNum, 1, _G.unpack(RealUI.media.colors.orange))
                tooltip:SetCellTextColor(lineNum, 2, 0.9, 0.9, 0.9)
                if _G.IsXPUserDisabled() then
                    lineNum = tooltip:AddLine(_G.EXPERIENCE_COLON, _G.VIDEO_OPTIONS_DISABLED)
                    tooltip:SetCellTextColor(lineNum, 1, _G.unpack(RealUI.media.colors.orange))
                    tooltip:SetCellTextColor(lineNum, 2, 0.3, 0.3, 0.3)
                elseif restXP then
                    lineNum = tooltip:AddLine(_G.TUTORIAL_TITLE26, RealUI:ReadableNumber(restXP))
                    tooltip:SetLineTextColor(lineNum, 0.9, 0.9, 0.9)
                end

                tooltip:AddLine(" ")
            end,
            OnClick = function(XP)
            end
        }
        watchStates["rep"] = {
            hint = L["Progress_OpenRep"],
            GetNext = function(Rep)
                if watchStates["artifact"]:IsValid() then
                    return "artifact"
                elseif watchStates["honor"]:IsValid() then
                    return "honor"
                elseif watchStates["xp"]:IsValid() then
                    return "xp"
                elseif watchStates["rep"]:IsValid() then
                    return "rep"
                else
                    return nil
                end
            end,
            GetStats = function(Rep)
                local name, _, minRep, maxRep, curRep = _G.GetWatchedFactionInfo()
                return curRep - minRep, maxRep - minRep, name
            end,
            GetColor = function(Rep)
                local _, reaction = _G.GetWatchedFactionInfo()
                local color = _G.FACTION_BAR_COLORS[reaction]
                return color.r, color.g, color.b, reaction
            end,
            IsValid = function(Rep)
                return not not _G.GetWatchedFactionInfo()
            end,
            SetTooltip = function(Rep, tooltip)
                local minRep, maxRep, name = Rep:GetStats()
                local r, g, b, reaction = Rep:GetColor()

                local lineNum = tooltip:AddLine(_G.REPUTATION.._G.HEADER_COLON, name)
                tooltip:SetCellTextColor(lineNum, 1, _G.unpack(RealUI.media.colors.orange))
                tooltip:SetCellTextColor(lineNum, 2, r, g, b)

                local repStatus = ("%s/%s (%d%%)"):format(RealUI:ReadableNumber(minRep), RealUI:ReadableNumber(maxRep), (minRep/maxRep)*100)
                lineNum = tooltip:AddLine(_G["FACTION_STANDING_LABEL"..reaction], repStatus)
                tooltip:SetCellTextColor(lineNum, 1, r, g, b)
                tooltip:SetCellTextColor(lineNum, 2, 0.9, 0.9, 0.9)

                tooltip:AddLine(" ")
            end,
            OnClick = function(Rep)
                _G.ToggleCharacter("ReputationFrame")
            end
        }
        watchStates["artifact"] = {
            hint = L["Progress_OpenArt"],
            GetNext = function(Art)
                if watchStates["honor"]:IsValid() then
                    return "honor"
                else
                    return "xp"
                end
            end,
            GetStats = function(Art)
                local hasArtifact, _, power, maxPower = artData:GetArtifactPower()
                if hasArtifact then
                    return power, maxPower
                else
                    return 0, 100
                end
            end,
            GetColor = function(Art)
                return .901, .8, .601
            end,
            IsValid = function(Rep)
                local activeArtifact = _G.C_ArtifactUI.GetEquippedArtifactInfo()
                InfoLine:debug("artifact:IsValid", activeArtifact, artifactInit)
                if activeArtifact or artifactInit then
                    -- After a spec switch, the active artifact could be invalid
                    if artData:GetNumObtainedArtifacts() ~= _G.C_ArtifactUI.GetNumObtainedArtifacts() and not activeArtifact then
                        -- async timer to prevent stack overflow
                        _G.C_Timer.After(2, artData.ForceUpdate)
                    end
                    return not not activeArtifact
                else
                    -- Artifact info is not available until the first ARTIFACT_UPDATE, just fake it until then
                    return true
                end
            end,
            SetTooltip = function(Art, tooltip)
                local hasArtifact, artifact = artData:GetArtifactInfo()

                if hasArtifact then
                    testCell:SetFontObject("GameTooltipText")
                    testCell:SetText(artifact.name)
                    local maxWidth = _G.max(testCell:GetStringWidth(), 200)

                    local lineNum, colNum = tooltip:AddLine()
                    tooltip:SetCell(lineNum, colNum, artifact.name, nil, nil, 2, nil, nil, nil, maxWidth)
                    tooltip:SetCellTextColor(lineNum, colNum, _G.unpack(RealUI.media.colors.orange))

                    local minAP, maxAP = artifact.power, artifact.maxPower
                    local artStatus = ("%s/%s (%d%%)"):format(_G.FormatLargeNumber(minAP), _G.FormatLargeNumber(maxAP), (minAP/maxAP)*100)
                    lineNum = tooltip:AddLine(_G.FormatLargeNumber(artifact.unspentPower), artStatus)
                    tooltip:SetLineTextColor(lineNum, 0.9, 0.9, 0.9)

                    if artifact.numRanksPurchasable > 0 then
                        artStatus = _G.ARTIFACT_POWER_TOOLTIP_BODY:format(artifact.numRanksPurchasable)
                        lineNum, colNum = tooltip:AddLine()
                        tooltip:SetCell(lineNum, colNum, artStatus, nil, nil, 2, nil, nil, nil, maxWidth)
                        tooltip:SetCellTextColor(lineNum, colNum, 0.7, 0.7, 0.7)
                    end
                else
                    tooltip:AddLine(_G.SPELL_FAILED_NO_ARTIFACT_EQUIPPED)
                end
                tooltip:AddLine(" ")
            end,
            OnClick = function(Art)
                _G.SocketInventoryItem(16)
            end
        }
        watchStates["honor"] = {
            hint = L["Progress_OpenHonor"],
            GetNext = function(Honor)
                if watchStates["rep"]:IsValid() then
                    return "rep"
                elseif watchStates["artifact"]:IsValid() then
                    return "artifact"
                elseif watchStates["honor"]:IsValid() then
                    return "honor"
                else
                    return nil
                end
            end,
            GetStats = function(Honor)
                return _G.UnitHonor("player"), _G.UnitHonorMax("player"), _G.GetHonorExhaustion()
            end,
            GetColor = function(Honor, isRested)
                if isRested then
                    return 1.0, 0.71, 0
                else
                    return 1.0, 0.24, 0
                end
            end,
            IsValid = function(Rep)
                return _G.UnitLevel("player") >= _G.MAX_PLAYER_LEVEL_TABLE[_G.LE_EXPANSION_LEVEL_CURRENT]
            end,
            SetTooltip = function(Honor, tooltip)
                local minHonor, maxHonor = Honor:GetStats()

                local honorStatus
                if _G.CanPrestige() then
                    honorStatus = _G.PVP_HONOR_PRESTIGE_AVAILABLE
                else
                    honorStatus = ("%s/%s (%d%%)"):format(RealUI:ReadableNumber(minHonor), RealUI:ReadableNumber(maxHonor), (minHonor/maxHonor)*100)
                end

                local lineNum = tooltip:AddLine(_G.HONOR.._G.HEADER_COLON, honorStatus)
                tooltip:SetCellTextColor(lineNum, 1, _G.unpack(RealUI.media.colors.orange))
                tooltip:SetCellTextColor(lineNum, 2, 0.9, 0.9, 0.9)

                tooltip:AddLine(" ")
            end,
            OnClick = function(Honor)
                _G.ToggleTalentFrame(_G.PVP_TALENTS_TAB)
            end
        }

        local function UpdateProgress(block)
            local curValue, maxValue, otherValue = watchStates[dbc.progressState]:GetStats()
            local value = curValue / maxValue
            block.dataObj.icon = fa["thermometer-"..round(value * 4)]
            block.dataObj.text = round(value, 3) * 100 .. "%"

            local watch = InfoLine.frame.watch
            InfoLine:debug("progress:main", dbc.progressState, curValue, maxValue)

            local main = watch.main
            local r, g, b = watchStates[dbc.progressState]:GetColor()
            main:SetStatusBarColor(r, g, b, 0.5)
            main:SetMinMaxValues(0, maxValue)
            main:SetValue(curValue)
            main:Show()

            if _G.type(otherValue) == "number" then
                local restedOfs = _G.max(((curValue + otherValue) / maxValue) * main:GetWidth(), 0)
                r, g, b = watchStates[dbc.progressState]:GetColor(true)
                main.rested:SetColorTexture(r, g, b, 0.5)
                main.rested:SetPoint("BOTTOMRIGHT", main, "BOTTOMLEFT", restedOfs, 0)
                main.rested:Show()
            end

            local nextState = watchStates[dbc.progressState]:GetNext()
            for i = 1, 2 do
                local bar = watch[i]
                if nextState ~= dbc.progressState then
                    curValue, maxValue = watchStates[nextState]:GetStats()
                    InfoLine:debug("progress:"..i, nextState, curValue, maxValue)

                    bar:SetStatusBarColor(watchStates[nextState]:GetColor())
                    bar:SetMinMaxValues(0, maxValue)
                    bar:SetValue(curValue)
                    bar:Show()
                else
                    bar:Hide()
                end
                nextState = watchStates[nextState]:GetNext()
            end
        end

        local function UpdateState(block)
            local state = watchStates[dbc.progressState]:GetNext()
            if state then
                InfoLine:debug("check state", dbc.progressState, state)
                dbc.progressState = state
                InfoLine.frame.watch.main.rested:Hide()
                UpdateProgress(block)
            else
                InfoLine:RemoveBlock(block.name, block.dataObj, block)
            end
        end

        LDB:NewDataObject("progress", {
            name = L["Progress"],
            type = "RealUI",
            icon = fa["thermometer"],
            iconFont = iconFont,
            text = "XP",
            OnEnable = function(block)
                InfoLine:debug("progress: OnEnable", block.side)
                if not watchStates[dbc.progressState] then
                    dbc.progressState = "xp"
                end

                if _G.UnitLevel("player") > 100 then
                    block:RegisterEvent("ARTIFACT_UPDATE")
                else
                    artifactInit = true
                end

                if not watchStates[dbc.progressState]:IsValid() then
                    UpdateState(block)
                end

                artData:RegisterCallback("ARTIFACT_POWER_CHANGED", block.OnEvent, block)
                artData:RegisterCallback("ARTIFACT_ACTIVE_CHANGED", block.OnEvent, block)
                artData:RegisterCallback("ARTIFACT_EQUIPPED_CHANGED", block.OnEvent, block)
            end,
            OnDisable = function(block)
                InfoLine:debug("progress: OnDisable", block.side)
                local watch = InfoLine.frame.watch
                watch.main:Hide()
                watch[1]:Hide()
                watch[2]:Hide()

                block:UnregisterAllEvents()
                artData:UnregisterCallback("ARTIFACT_POWER_CHANGED")
                artData:UnregisterCallback("ARTIFACT_ACTIVE_CHANGED")
                artData:UnregisterCallback("ARTIFACT_EQUIPPED_CHANGED")
            end,
            OnClick = function(block, ...)
                InfoLine:debug("progress: OnClick", block.side, ...)
                if _G.IsAltKeyDown() then
                    UpdateState(block)
                else
                    watchStates[dbc.progressState]:OnClick()
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --InfoLine:debug("progress: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetHeaderFont(headerFont.object)
                tooltip:SetFont(textFont.object)
                tooltip:SetCell(lineNum, colNum, L["Progress"], nil, nil, 2)

                watchStates[dbc.progressState]:SetTooltip(tooltip)

                local nextState = watchStates[dbc.progressState]:GetNext()
                for i = 1, 2 do
                    if nextState ~= dbc.progressState then
                        watchStates[nextState]:SetTooltip(tooltip)
                    end
                    nextState = watchStates[nextState]:GetNext()
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, watchStates[dbc.progressState].hint, nil, nil, 2)
                tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)
                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, L["Progress_Cycle"], nil, nil, 2)
                tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                InfoLine:debug("progress: OnEvent", block.side, event, ...)
                if event == "ARTIFACT_UPDATE" then
                    artifactInit = true
                    if not watchStates["artifact"]:IsValid() then
                        UpdateState(block)
                    end
                    block:UnregisterEvent(event)
                end

                UpdateProgress(block)
            end,
            events = {
                "PLAYER_ENTERING_WORLD",
                "PLAYER_LEVEL_UP",
                "UPDATE_EXHAUSTION",

                "PLAYER_XP_UPDATE",
                "PLAYER_UPDATE_RESTING",
                "DISABLE_XP_GAIN",
                "ENABLE_XP_GAIN",

                "UPDATE_FACTION",

                "HONOR_XP_UPDATE",
                "HONOR_LEVEL_UPDATE",
            },
        })
    end


    --[[ Right ]]--
    do -- Mail
        LDB:NewDataObject("mail", {
            name = _G.MAIL_LABEL,
            type = "RealUI",
            icon = fa["envelope"],
            iconFont = iconFont,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --InfoLine:debug("Mail: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 1, "LEFT")
                SetupTooltip(tooltip, block)

                tooltip:SetHeaderFont(headerFont.object)
                tooltip:SetFont(textFont.object)
                local send1, send2, send3 = _G.GetLatestThreeSenders()
                if (send1 or send2 or send3) then
                    tooltip:AddHeader(_G.HAVE_MAIL_FROM)
                else
                    tooltip:AddHeader(_G.HAVE_MAIL)
                end

                if send1 then tooltip:AddLine(send1) end
                if send2 then tooltip:AddLine(send2) end
                if send3 then tooltip:AddLine(send3) end

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                InfoLine:debug("Mail1: OnEvent", event, ...)
                local isVisible, hasNewMail = block:IsVisible(), _G.HasNewMail()
                if not isVisible and hasNewMail then
                    local info = InfoLine:GetBlockInfo(block.name, block.dataObj)
                    InfoLine:AddBlock(block.name, block.dataObj, info)
                elseif isVisible and not hasNewMail then
                    local info = InfoLine:GetBlockInfo(block.name, block.dataObj)
                    InfoLine:RemoveBlock(block.name, block.dataObj, info)
                end
            end,
            events = {
                "PLAYER_ENTERING_WORLD",
                "UPDATE_PENDING_MAIL",
                "MAIL_INBOX_UPDATE",
            },
        })
    end

    -- Bag space

    -- Specialization

    do -- Currency
        local GOLD_AMOUNT_STRING = "%s|cfffff226%s|r"
        local SILVER_AMOUNT_STRING = "%d|cffbfbfbf%s|r"
        local COPPER_AMOUNT_STRING = "%d|cffbf734f%s|r"
        local TOKEN_STRING = [[|T%s:12:12:0:0:64:64:5:59:5:59|t %d]]
        local charName = "|c%s%s|r"

        local currencyDB, charDB
        local ignore = _G.LOCALE_koKR or _G.LOCALE_zhCN or _G.LOCALE_zhTW
        local function ShortenCurrencyName(name)
            if ignore then
                return name
            else
                return name ~= nil and name:gsub("%l*%s*%p*", "") or "-"
            end
        end
        local function SplitMoney(money)
            if not money then return 0,0,0 end
            local gold = _G.floor(money / (_G.COPPER_PER_SILVER * _G.SILVER_PER_GOLD))
            local silver = _G.floor((money - (gold * _G.COPPER_PER_SILVER * _G.SILVER_PER_GOLD)) / _G.COPPER_PER_SILVER)
            local copper = money % _G.COPPER_PER_SILVER
            return gold, silver, copper
        end
        local function GetMoneyString(money, useFirst)
            local goldString, silverString, copperString
            local gold, silver, copper = SplitMoney(money)

            goldString = GOLD_AMOUNT_STRING:format(_G.FormatLargeNumber(gold), _G.GOLD_AMOUNT_SYMBOL)
            silverString = SILVER_AMOUNT_STRING:format(silver, _G.SILVER_AMOUNT_SYMBOL)
            copperString = COPPER_AMOUNT_STRING:format(copper, _G.COPPER_AMOUNT_SYMBOL)

            local moneyString = ""
            local separator = ""
            if gold > 0 then
                moneyString = goldString
                if useFirst then
                    return moneyString
                else
                    separator = " "
                end
            end
            if silver > 0 then
                moneyString = moneyString..separator..silverString
                if useFirst then
                    return moneyString
                else
                    separator = " "
                end
            end
            if copper > 0 or moneyString == "" then
                moneyString = moneyString..separator..copperString
            end

            return moneyString
        end

        local currencyStates = {}
        currencyStates["money"] = {
            GetNext = function(Money)
                if currencyStates["token1"]:IsValid() then
                    return "token1"
                elseif currencyStates["token2"]:IsValid() then
                    return "token2"
                elseif currencyStates["token3"]:IsValid() then
                    return "token3"
                elseif currencyStates["money"]:IsValid() then
                    return "money"
                else
                    return nil
                end
            end,
            GetText = function(Money)
                return GetMoneyString(charDB.money)
            end,
            GetIcon = function(Money)
                local gold, silver = SplitMoney(charDB.money)
                if gold > 0 then
                    return [[Interface\Icons\INV_Misc_Coin_02]], _G.GOLD_AMOUNT_SYMBOL
                elseif silver > 0 then
                    return [[Interface\Icons\INV_Misc_Coin_03]], _G.SILVER_AMOUNT_SYMBOL
                else
                    return [[Interface\Icons\INV_Misc_Coin_19]], _G.COPPER_AMOUNT_SYMBOL
                end
            end,
            IsValid = function(Money)
                return true
            end,
            OnClick = function(Money)
            end
        }
        for i = 1, _G.MAX_WATCHED_TOKENS do
            currencyStates["token"..i] = {
                index = i,
                GetNext = function(token)
                    if i == 3 then
                        return "money"
                    else
                        if currencyStates["token"..i+1]:IsValid() then
                            return "token"..i+1
                        else
                            return "money"
                        end
                    end
                end,
                GetText = function(token)
                    if token.id then
                        return charDB[token.id] or 0
                    else
                        return false
                    end
                end,
                GetIcon = function(token)
                    return token.icon, ShortenCurrencyName(token.name)
                end,
                IsValid = function(token)
                    return not not token.id
                end,
                OnClick = function(token)
                end
            }
        end

        local function UpdateTrackedCurrency(block)
            local changeIndex
            for i = 1, _G.MAX_WATCHED_TOKENS do
                local token = currencyStates["token"..i]
                local name, _, icon, currencyID = _G.GetBackpackCurrencyInfo(token.index)
                if token.id ~= currencyID and not changeIndex then
                    changeIndex = i
                end

                token.name = name
                token.icon = icon
                token.id = currencyID
                charDB["token"..i] = currencyID
            end
            return changeIndex
        end

        local function UpdateBlock(block)
            local icon, label = currencyStates[dbc.currencyState]:GetIcon()
            block.dataObj.icon = icon
            block.dataObj.label = label

            block.dataObj.text = currencyStates[dbc.currencyState]:GetText()
        end

        local function UpdateState(block)
            UpdateTrackedCurrency(block)
            local state = currencyStates[dbc.currencyState]:GetNext()
            InfoLine:debug("check state", dbc.currencyState, state)
            dbc.currencyState = state

            UpdateBlock(block)
        end

        local function Currency_OnClick(row, ...)
            local name = row[1]:GetText():match(nameMatch)
            if not name then return end
            local realm, faction = _G.strsplit("-", row.meta[1])

            if _G.IsAltKeyDown() then
                currencyDB[realm][faction][name] = nil
            end
        end
        local function Currency_GetTooltipText(cell)
            InfoLine:debug("Currency_GetTooltipText")
            local name = cell.row.meta[cell:GetID()]
            if name then
                InfoLine:debug("Currency_GetTooltipText", name)
                return name
            end
        end

        local hintLine
        local function Currency_TooltipOnUpdate(tooltip)
            if tooltip:IsMouseOver() then
                tooltip:SetCell(hintLine, 1, L["Currency_EraseData"])
            else
                tooltip:SetCell(hintLine, 1, L["Currency_Cycle"])
            end
        end

        local tokens, tableWidth = {}, 400
        local currencyData = {}
        local headerData = {
            info = {
                _G.NAME, _G.MONEY, _G.CURRENCY.." 1", _G.CURRENCY.." 2", _G.CURRENCY.." 3", L["Currency_UpdatedAbbr"]
            },
            justify = {
                "LEFT", "RIGHT", "LEFT", "LEFT", "LEFT", "LEFT"
            },
            size = {
                "FILL", "FIT", "FIT", "FIT", "FIT", 0.15
            }
        }

        LDB:NewDataObject("currency", {
            name = "Currency",
            type = "RealUI",
            icon = [[Interface\MoneyFrame\UI-GoldIcon]],
            iconCoords = {.08, .92, .08, .92},
            text = "Currency",
            OnEnable = function(block)
                InfoLine:debug("currency: OnEnable", block.side)
                currencyDB = RealUI.db.global.currency
                charDB = currencyDB[RealUI.realm][RealUI.faction][RealUI.charName]
                if not currencyStates[dbc.currencyState] then
                    dbc.currencyState = "money"
                end

                _G.hooksecurefunc("SetCurrencyBackpack", function(index, flag)
                    local trackedIndex, trackedName = currencyStates[dbc.currencyState].index, currencyStates[dbc.currencyState].name
                    local changeIndex = UpdateTrackedCurrency(block)
                    if changeIndex and trackedIndex then
                        if changeIndex < trackedIndex then
                            if flag == 0 and trackedName == currencyStates["token"..trackedIndex-1].name then
                                dbc.currencyState = "token"..trackedIndex-1
                            end
                        elseif changeIndex == trackedIndex then
                            if flag == 1 and trackedName == currencyStates["token"..trackedIndex+1].name then
                                dbc.currencyState = "token"..trackedIndex+1
                            end
                        end

                        if currencyStates[dbc.currencyState].index >= changeIndex then
                            UpdateBlock(block)

                            if not currencyStates[dbc.currencyState]:IsValid() then
                                UpdateState(block)
                            end
                        end
                    end
                end)

                UpdateTrackedCurrency(block)
                if not currencyStates[dbc.currencyState]:IsValid() then
                    UpdateState(block)
                end
            end,
            OnClick = function(block, ...)
                InfoLine:debug("currency: OnClick", block.side, ...)
                if _G.IsAltKeyDown() then
                    UpdateState(block)
                else
                    if not _G.InCombatLockdown() then
                        _G.ToggleCharacter("TokenFrame")
                    end
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --InfoLine:debug("currency: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
                SetupTooltip(tooltip, block)
                tooltip:SetScript("OnUpdate", Currency_TooltipOnUpdate)
                local lineNum, colNum

                tooltip:AddHeader(_G.CURRENCY)

                _G.table.wipe(currencyData)
                currencyData.width = tableWidth
                currencyData.header = headerData
                currencyData.defaultSort = 1
                currencyData.rowOnClick = Currency_OnClick
                currencyData.cellGetTooltipText = Currency_GetTooltipText

                local realm, faction = RealUI.realm, RealUI.faction
                local realm_faction = realm.."-"..faction
                local factionDB = currencyDB[realm][faction]
                for name, data in next, factionDB do
                    local classColor = RealUI:GetClassColor(data.class, "hex")
                    name = charName:format(classColor, name)
                    local money = GetMoneyString(data.money, true)

                    _G.table.wipe(tokens)
                    for i = 1, _G.MAX_WATCHED_TOKENS do
                        if data["token"..i] then
                            local tokenName, _, texture = _G.GetCurrencyInfo(data["token"..i])
                            local amount = data[data["token"..i]] or 0
                            tokens[i] = TOKEN_STRING:format(texture, amount)
                            tokens[i+3] = tokenName
                        else
                            tokens[i] = "---"
                        end
                    end

                    _G.tinsert(currencyData, {
                        id = #currencyData + 1,
                        info = {
                            name, money, tokens[1], tokens[2], tokens[3], _G.date("%b %d", data.lastSeen)
                        },
                        meta = {
                            realm_faction, GetMoneyString(data.money), tokens[4], tokens[5], tokens[6], ""
                        }
                    })
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, currencyData, TextTableCellProvider)

                tooltip:AddLine(" ")

                hintLine = tooltip:AddLine(L["Currency_Cycle"])
                tooltip:SetLineTextColor(hintLine, 0, 1, 0)

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                InfoLine:debug("currency: OnEvent", block.side, event, ...)
                UpdateBlock(block)
            end,
            events = {
                "PLAYER_ENTERING_WORLD",

                "CURRENCY_DISPLAY_UPDATE",
                "PLAYER_MONEY",
            },
        })
    end

    do -- FPS/Ping
        -- Global Upvalues
        local GetFramerate, GetNetStats = _G.GetFramerate, _G.GetNetStats
        local tinsert, tremove = _G.tinsert, _G.tremove

        local blockText = "%d |cff%s|||r %d"
        local lagFormat = "    %s |cff808080(%s)|r"
        local indent = "    "

        local period = 5
        local fpsElapsed, fpsCount = 0, 0
        local fps = {cur = 0, avg = 0, set = {}}

        local lagElapsed, lagCount = 0, 0
        local home = {cur = 0, avg = 0, set = {}}
        local world = {cur = 0, avg = 0, set = {}}

        local function UpdateStat(stat)
            local set = stat.set
            tinsert(set, stat.cur)
            if #set > period then
                tremove(set, 1)
            end

            local sum = 0
            for i = 1, #set do
                local part = set[i]
                sum = sum + part
            end
            stat.avg = sum / #set
        end
        LDB:NewDataObject("netstats", {
            name = L["Sys_SysInfo"],
            type = "RealUI",
            text = "FPS",
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --InfoLine:debug("progress: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 3, "LEFT", "RIGHT", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum--, colNum

                tooltip:SetHeaderFont(headerFont.object)
                tooltip:SetFont(textFont.object)
                tooltip:AddHeader(_G.NETWORK_LABEL)

                local color = RealUI.media.colors.orange
                lineNum = tooltip:AddLine(indent..L["Sys_Stat"], L["Sys_CurrentAbbr"], L["Sys_AverageAbbr"])
                tooltip:SetLineTextColor(lineNum, color[1], color[2], color[3])
                tooltip:AddLine(lagFormat:format(_G.HOME, _G.MILLISECONDS_ABBR), round(home.cur), round(home.avg))
                tooltip:AddLine(lagFormat:format(_G.WORLD, _G.MILLISECONDS_ABBR), round(world.cur), round(world.avg))

                tooltip:AddLine(" ")

                tooltip:AddHeader(_G.SYSTEMOPTIONS_MENU)
                lineNum = tooltip:AddLine(indent..L["Sys_Stat"], L["Sys_CurrentAbbr"], L["Sys_AverageAbbr"])
                tooltip:SetLineTextColor(lineNum, color[1], color[2], color[3])
                tooltip:AddLine(indent.._G.FRAMERATE_LABEL, round(fps.cur), round(fps.avg))

                tooltip:Show()
            end,
            OnUpdate = function(block, elapsed)
                fpsElapsed = fpsElapsed + elapsed
                if fpsElapsed > .2 then
                    fps.cur = GetFramerate()
                    fpsCount = fpsCount + 1
                    fpsElapsed = 0
                end

                if fpsCount == period then
                    UpdateStat(fps)
                    fpsCount = 0
                end

                lagElapsed = lagElapsed + elapsed
                if lagElapsed > 6 then
                    local _, _, latencyHome, latencyWorld = GetNetStats()
                    home.cur = latencyHome
                    world.cur = latencyWorld
                    lagCount = lagCount + 1
                    lagElapsed = 0
                end

                if lagCount == period then
                    UpdateStat(home)
                    UpdateStat(world)
                    lagCount = 0
                end

                local latency = home.cur > world.cur and home.cur or world.cur
                local color
                if latency > _G.PERFORMANCEBAR_MEDIUM_LATENCY then
                    color = "FF0000"
                elseif latency > _G.PERFORMANCEBAR_LOW_LATENCY then
                    color = "FFFF00"
                else
                    color = "00FF00"
                end

                block.dataObj.text = blockText:format(fps.cur, color, latency)
            end,
        })
    end
end
