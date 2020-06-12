local _, private = ...

-- Lua Globals --
-- luacheck: globals min max tonumber floor
-- luacheck: globals sort tinsert unpack wipe
-- luacheck: globals next date strsplit type

-- Libs --
local LDB = _G.LibStub("LibDataBroker-1.1")
local qTip = _G.LibStub("LibQTip-1.0")

local fa = _G.LibStub("LibIconFonts-1.0"):GetIconFont("FontAwesome-4.7")
fa.path = _G.LibStub("LibSharedMedia-3.0"):Fetch("font", "Font Awesome")

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local Scale = RealUI.Scale
local round = RealUI.Round
local L = RealUI.L

local MODNAME = "Infobar"
local Infobar = RealUI:GetModule(MODNAME)
local MenuFrame = RealUI:GetModule("MenuFrame")

local testCell = _G.UIParent:CreateFontString()
Scale.Point(testCell, "CENTER")
Scale.Size(testCell, 500, 20)
testCell:Hide()

local iconFont
local TextTableCellProvider, TextTableCellPrototype
local function SetupTextTable()
    TextTableCellProvider, TextTableCellPrototype = qTip:CreateCellProvider()

    local MAX_ROWS = 15
    local ROW_HEIGHT = Scale.Value(9)
    local TABLE_WIDTH = 320
    local numTables = 0
    local extData = {}

    local GTT_FrameLevel
    local function Cell_OnEnter(self)
        self.row:GetScript("OnEnter")(self.row)
        local text = self:GetTooltipText()
        if text then
            GTT_FrameLevel = _G.RealUI_InfobarTooltip:GetFrameLevel()
            _G.RealUI_InfobarTooltip:SetFrameLevel(1000)
            _G.RealUI_InfobarTooltip:SetOwner(self, "ANCHOR_TOP")
            _G.RealUI_InfobarTooltip:SetText(text)
            _G.RealUI_InfobarTooltip:Show()
        end
    end
    local function Cell_OnLeave(self)
        self.row:GetScript("OnLeave")(self.row)
        if GTT_FrameLevel and _G.RealUI_InfobarTooltip:IsShown() then
            _G.RealUI_InfobarTooltip:SetFrameLevel(GTT_FrameLevel)
            _G.RealUI_InfobarTooltip:Hide()
        end
    end

    local function UpdateScroll(self)
        Infobar:debug("UpdateScroll", self:GetDebugName(), self:GetName())
        local offset = _G.FauxScrollFrame_GetOffset(self) or 0
        local data = self.textTable.data
        local header = self.textTable.header
        Infobar:debug("offset", offset)
        for i = 1, MAX_ROWS do
            local index = offset + i
            local row = self.textTable.rows[i]
            Infobar:debug("row", i, index)
            if i > #data then
                row:Hide()
            else
                for col = 1, #data.header.justify do
                    local cell = row[col]
                    if not cell then
                        cell = _G.CreateFrame("Button", "$parentCell"..col, row)
                        cell:SetID(col)
                        Scale.Point(cell, "TOP")
                        Scale.Point(cell, "BOTTOM")
                        Scale.Point(cell, "LEFT", header[col])
                        Scale.Point(cell, "RIGHT", header[col])
                        cell.row = row
                        row[col] = cell

                        local text = cell:CreateFontString(nil, "ARTWORK")
                        text:SetFontObject("SystemFont_Shadow_Med1")
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
        local numToDisplay = min(MAX_ROWS, #data)
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
            Infobar:debug("Compare1", row1.info[sortColumn])
            Infobar:debug("Compare2", row2.info[sortColumn])
            local result

            Infobar:debug("sortInverted", sortInverted)
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
            Infobar:debug("textTable:OnUpdate", ...)
            self:SetScript("OnUpdate", nil)
            local data = self.data

            if extData[data].sortColumn and #data > 0 then
                sortColumn = extData[data].sortColumn:GetID()
                Infobar:debug("Header_OnClick", sortColumn, ...)


                sortInverted = extData[data].sortInverted
                if data.header.sort then
                    sortHandler = data.header.sort[sortColumn]
                    if sortHandler == true then
                        sortHandler = SortSimple -- Less-than operator
                    end
                else
                    sortHandler = SortSimple
                end

                sort(data, Compare)
                UpdateScroll(self.scrollArea)
            end
        end

        function TextTableCellPrototype:SetSort(header, inverted)
            Infobar:debug("CellProto:SetSort", header:GetID(), inverted)
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
        Infobar:debug("CellProto:InitializeCell")

        if not self.textTable then
            numTables = numTables + 1
            local textTable = _G.CreateFrame("Frame", "IL_TextTable"..numTables, self)
            Scale.Point(textTable, "TOPLEFT")
            Scale.Point(textTable, "BOTTOMRIGHT")
            textTable:EnableMouse(true)

            --[[ Test BG
            local test = textTable:CreateTexture(nil, "BACKGROUND")
            test:SetColorTexture(1, 1, 1, 0.5)
            test:SetAllPoints(textTable)]]

            textTable.header = _G.CreateFrame("Frame", "$parentHeader", textTable)
            Scale.Point(textTable.header, "TOPLEFT")
            Scale.Point(textTable.header, "RIGHT")
            textTable.header:SetHeight(ROW_HEIGHT)

            local line = textTable:CreateTexture(nil, "BACKGROUND")
            line:SetColorTexture(1, 1, 1)
            Scale.Point(line, "TOPLEFT", textTable.header, "BOTTOMLEFT", 0, -5)
            Scale.Point(line, "RIGHT")
            line:SetHeight(1)

            textTable.scrollArea = _G.CreateFrame("ScrollFrame", "$parentScroll", textTable, "FauxScrollFrameTemplate")
            Scale.Point(textTable.scrollArea, "TOPLEFT", line, 0, -5)
            Scale.Point(textTable.scrollArea, "BOTTOMRIGHT")
            textTable.scrollArea:SetScript("OnVerticalScroll", function(scroll, offset)
                _G.FauxScrollFrame_OnVerticalScroll(scroll, offset, ROW_HEIGHT, UpdateScroll)
            end)
            textTable.scrollArea.textTable = textTable

            local prev = textTable.scrollArea
            textTable.rows = {}
            for index = 1, MAX_ROWS do
                local row = _G.CreateFrame("Button", "$parentRow"..index, textTable)
                if index == 1 then
                    Scale.Point(row, "TOPLEFT", prev)
                else
                    Scale.Point(row, "TOPLEFT", prev, "BOTTOMLEFT")
                end
                Scale.Point(row, "RIGHT")
                row:SetHeight(ROW_HEIGHT)
                row:SetScript("OnEnter", function(r)
                    r.highlight:Show()
                end)
                row:SetScript("OnLeave", function(r)
                    r.highlight:Hide()
                end)

                local highlight = row:CreateTexture(nil, "BACKGROUND")
                local r, g, b = RealUI.charInfo.class.color:GetRGB()
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
        Infobar:debug("CellProto:SetupCell")
        local textTable = self.textTable
        local width = Scale.Value(data.width or TABLE_WIDTH)
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
                Scale.Point(header, "TOP", 0, -4)
                Scale.Point(header, "BOTTOM")
                if col == 1 then
                    Scale.Point(header, "LEFT")
                else
                    Scale.Point(header, "LEFT", headerRow[col-1], "RIGHT", 2, 0)
                end

                header.text = header:CreateFontString(nil, "ARTWORK")
                header.text:SetFontObject("SystemFont_Shadow_Med1")
                header.text:SetTextColor(Color.orange:GetRGB())
                header.text:SetAllPoints()

                local hR, hG, hB = RealUI.charInfo.class.color:GetRGB()
                local highlight = header:CreateTexture(nil, "ARTWORK")
                highlight:SetColorTexture(hR, hG, hB)
                Scale.Point(highlight, "TOPLEFT", header, "BOTTOMLEFT", 0, -5)
                Scale.Point(highlight, "RIGHT")
                highlight:SetHeight(3)
                header:SetHighlightTexture(highlight)
                header.hl = highlight

                header.textTable = textTable
                headerRow[col] = header
            end
            if headerData.sort then
                header.hl:Show()
                header:SetScript("OnClick", function(btn)
                    _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
                    self:SetSort(btn)
                end)
            else
                header.hl:Hide()
            end
            header.text:SetText(headerData.info[col])
            header.text:SetJustifyH(headerData.justify[col])

            local size = headerData.size[col]
            if size == "FILL" then
                filler = header
                size = "FIT"
            end

            if size == "FIT" then
                local cellWidth = header.text:GetStringWidth()
                testCell:SetFontObject("SystemFont_Shadow_Med1")
                for i = 1, #data do
                    testCell:SetText(data[i].info[col])
                    local newWidth = testCell:GetStringWidth()
                    if newWidth > cellWidth then cellWidth = newWidth end
                end
                header:SetWidth(cellWidth)
                if filler ~= header then
                    remainingWidth = remainingWidth - cellWidth
                end
            else
                flex[header] = size
            end
            Infobar:debug("Width", col, remainingWidth)
        end
        for header, size in next, flex do
            local headerWidth = max(width * size, header.text:GetStringWidth())
            remainingWidth = remainingWidth - headerWidth
            header:SetWidth(headerWidth)
            Infobar:debug("Width", headerWidth, remainingWidth)
        end
        filler:SetWidth(max(remainingWidth, filler:GetWidth()))

        Infobar:debug("Sort", extData[data].sortColumn, extData[data].sortInverted)
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

        return width, cellHeight + (MAX_ROWS + 1)
    end

    function TextTableCellPrototype:ReleaseCell()
        Infobar:debug("CellProto:ReleaseCell")
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
        Infobar:debug("CellProto:getContentHeight")
        return self.textTable:GetHeight()
    end
end

local function SetupTooltip(tooltip, block)
    tooltip:SetHeaderFont("Fancy16Font")
    tooltip:SetFont("SystemFont_Shadow_Med1")
    tooltip:SmartAnchorTo(block)
    tooltip:SetAutoHideDelay(0.10, block)
    --RealUI.RegisterModdedFrame(tooltip)
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
            --Infobar:debug("Test: OnEnter", block.side, ...)

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
local CreateTextureMarkup do
    local textureEscape = "|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d|t"
    local textureEscapeColor = "|T%s:%d:%d:0:0:%d:%d:%d:%d:%d:%d:%d:%d:%d|t"
    function CreateTextureMarkup(file, fileWidth, fileHeight, width, height, left, right, top, bottom, r, g, b)
        if r and g and b then
            return textureEscapeColor:format(
                file,
                height,
                width,
                fileWidth,
                fileHeight,
                left * fileWidth,
                right * fileWidth,
                top * fileHeight,
                bottom * fileHeight,
                r, g, b
            )
        else
            return textureEscape:format(
                file,
                height,
                width,
                fileWidth,
                fileHeight,
                left * fileWidth,
                right * fileWidth,
                top * fileHeight,
                bottom * fileHeight
            )
        end
    end
end


function Infobar:CreateBlocks()
    local dbc = Infobar.db.char

    if not TextTableCellPrototype then
        iconFont = {
            font = fa.path,
            outline = Infobar:GetFontOutline()
        }

        SetupTextTable()
    end

    -- TODO: when Blizz fixes the issues with textures not showing, use these.
    --local leftClick = CreateTextureMarkup([[Interface\TutorialFrame\UI-TUTORIAL-FRAME]], 512, 512, 14, 16, 0.0019531, 0.1484375, 0.4257813, 0.6210938)
    --local rightClick = CreateTextureMarkup([[Interface\TutorialFrame\UI-TUTORIAL-FRAME]], 512, 512, 14, 16, 0.0019531, 0.1484375, 0.6269531, 0.8222656)

    --[[ Static Blocks ]]--
    do  -- Start
        local guildText
        if _G.CommunitiesFrame_IsEnabled() then
            guildText = _G.GUILD_AND_COMMUNITIES
        elseif _G.IsInGuild() then
            guildText = _G.GUILD
        else
            guildText = _G.LOOKINGFORGUILD
        end

        local function ToggleUI(this, arg1, arg2, isChecked)
            if _G.InCombatLockdown() then return end

            _G[arg1](arg2)
        end

        local menuList = {
            {text = L["Start_Config"],
                func = function() RealUI.LoadConfig("HuD") end,
            },
            {text = L["General_Lock"],
                func = function()
                    if Infobar.locked then
                        Infobar:Unlock()
                    else
                        Infobar:Lock()
                    end
                end,
                checked = function() return Infobar.locked end,
            },
            {isSpacer = true},
            {text = _G.MicroButtonTooltipText(_G.CHARACTER_BUTTON, "TOGGLECHARACTER0"),
                func = ToggleUI,
                arg1 = "ToggleCharacter",
                arg2 = "PaperDollFrame",
            },
            {text = _G.MicroButtonTooltipText(_G.SPELLBOOK_ABILITIES_BUTTON, "TOGGLESPELLBOOK"),
                func = ToggleUI,
                    -- ToggleSpellBook causes taint
                arg1 = "ToggleFrame",
                arg2 = _G.SpellBookFrame,
            },
            {text = _G.MicroButtonTooltipText(_G.TALENTS_BUTTON, "TOGGLETALENTS"),
                func = function()
                    if _G.InCombatLockdown() then return end

                    if not _G.PlayerTalentFrame then
                        _G.TalentFrame_LoadUI()
                    end

                    if _G.PlayerTalentFrame:IsShown() then
                        _G.HideUIPanel(_G.PlayerTalentFrame)
                    else
                        _G.ShowUIPanel(_G.PlayerTalentFrame)
                    end

                end,
                disabled = function( ... )
                    if RealUI.isPatch then
                        return not _G.C_SpecializationInfo.CanPlayerUseTalentSpecUI()
                    else
                        return _G.UnitLevel("player") < _G.SHOW_SPEC_LEVEL
                    end
                end,
            },
            {text = _G.MicroButtonTooltipText(_G.ACHIEVEMENT_BUTTON, "TOGGLEACHIEVEMENT"),
                func = ToggleUI,
                arg1 = "ToggleAchievementFrame",
            },
            {text = _G.MicroButtonTooltipText(_G.QUESTLOG_BUTTON, "TOGGLEQUESTLOG"),
                func = ToggleUI,
                arg1 = "ToggleQuestLog",
            },
            {text = _G.MicroButtonTooltipText(guildText, "TOGGLEGUILDTAB"),
                func = ToggleUI,
                arg1 = "ToggleGuildFrame",
                disabled = _G.IsCommunitiesUIDisabledByTrialAccount,
            },
            {text = _G.MicroButtonTooltipText(_G.SOCIAL_BUTTON, "TOGGLESOCIAL"),
                func = ToggleUI,
                arg1 = "ToggleFriendsFrame",
                arg2 = 1,
            },
            {text = _G.MicroButtonTooltipText(_G.DUNGEONS_BUTTON, "TOGGLEGROUPFINDER"),
                func = ToggleUI,
                arg1 = "PVEFrame_ToggleFrame",
                disabled = function( ... )
                    if RealUI.isPatch then
                        return not ((_G.C_LFGInfo.CanPlayerUseLFD() or _G.C_LFGInfo.CanPlayerUsePVP()) and RealUI.charInfo.faction ~= "Neutral")
                    else
                        return _G.UnitLevel("player") < min(_G.SHOW_LFD_LEVEL, _G.SHOW_PVP_LEVEL)
                    end
                end,
            },
            {text = _G.MicroButtonTooltipText(_G.COLLECTIONS, "TOGGLECOLLECTIONS"),
                func = ToggleUI,
                arg1 = "ToggleCollectionsJournal",
            },
            {text = _G.MicroButtonTooltipText(_G.ADVENTURE_JOURNAL, "TOGGLEENCOUNTERJOURNAL"),
                func = ToggleUI,
                arg1 = "ToggleEncounterJournal",
            },
            {text = _G.BLIZZARD_STORE,
                func = ToggleUI,
                arg1 = "ToggleStoreUI",
                disabled = function( ... )
                    return not _G.C_StorePublic.IsEnabled()
                end,
            },
            {text = _G.HELP_BUTTON,
                func = ToggleUI,
                arg1 = "ToggleHelpFrame",
            },
            {isSpacer = true},
            {text = _G.CANCEL,
                func = function() MenuFrame:CloseAll() end,
            },
        }

        local errors
        local function ShowBugIcon(block, callback, errorObject)
            --[[errorObject = {
                message = sanitizedMessage,
                stack = table.concat(tmp, "\n"),
                locals = inCombat and "" or debuglocals(3),
                session = addon:GetSessionId(),
                time = date("%Y/%m/%d %H:%M:%S"),
                counter = 1,
            }]]

            if not block.dataObj.value then
                Infobar:debug("insert error line", #menuList)
                tinsert(menuList, 3, {
                    text = _G.SHOW_LUA_ERRORS,
                    func = function() _G.RealUI_ErrorFrame:ShowError() end,
                })

                Infobar:debug("add lines", #menuList)
                block.dataObj.icon = fa["bug"]
                block.dataObj.iconR, block.dataObj.iconG, block.dataObj.iconB = Color.red:GetRGB()
            end

            block.dataObj.value = #errors
        end

        LDB:NewDataObject("start", {
            name = L["Start"],
            type = "RealUI",
            icon = fa["bars"],
            iconFont = iconFont,
            OnEnable = function(block)
                errors = _G.BugGrabber:GetDB()
                if #errors > 0 then
                    ShowBugIcon(block, "OnEnable", errors[#errors])
                end

                _G.BugGrabber.RegisterCallback(block, "BugGrabber_BugGrabbed", ShowBugIcon, block)
            end,
            OnEnter = function(block, ...)
                MenuFrame:Open(block, "TOPLEFT", menuList)
            end,
            OnLeave = function(block, ...)
                MenuFrame:CloseAll()
            end,
        })
    end

    do  -- Clock
        local function RetrieveTime(isMilitary, isLocal)
            local timeFormat, hour, min, suffix
            if isLocal then
                hour, min = tonumber(date("%H")), tonumber(date("%M"))
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
            value = 1,
            suffix = "",
            OnEnable = function(block)
                Infobar:debug("clock: OnEnable", block.side)
                local function setTimeOptions()
                    block.isMilitary = _G.GetCVar("timeMgrUseMilitaryTime") == "1"
                    block.isLocal = _G.GetCVar("timeMgrUseLocalTime") == "1"
                end
                _G.hooksecurefunc("TimeManager_ToggleTimeFormat", setTimeOptions)
                _G.hooksecurefunc("TimeManager_ToggleLocalTime", setTimeOptions)
                setTimeOptions(block)

                block.helpTipInfo = {
                    text = _G.GAMETIME_TOOLTIP_CALENDAR_INVITES,
                    buttonStyle = _G.HelpTip.ButtonStyle.Close,
                    targetPoint = _G.HelpTip.Point.TopEdgeCenter,
                    alignment = _G.HelpTip.Alignment.Right,
                    autoHorizontalSlide = true,
                    onHideCallback = function( ... )
                        block.alertHidden = true
                    end
                }

                Infobar:ScheduleRepeatingTimer(function()
                    local timeFormat, hour, min, suffix = RetrieveTime(block.isMilitary, block.isLocal)
                    block.dataObj.value = timeFormat:format(hour, min)
                    block.dataObj.suffix = suffix
                end, 1)
            end,
            OnClick = function(block, ...)
                Infobar:debug("Clock: OnClick", block.side, ...)
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
                --Infobar:debug("Clock: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 3, "LEFT", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                tooltip:AddHeader(_G.TIMEMANAGER_TOOLTIP_TITLE)

                -- Realm time
                local timeFormat, hour, min, suffix = RetrieveTime(block.isMilitary, false)
                tooltip:AddLine(_G.TIMEMANAGER_TOOLTIP_REALMTIME, timeFormat:format(hour, min) .. " " .. suffix)

                -- Local time
                timeFormat, hour, min, suffix = RetrieveTime(block.isMilitary, true)
                tooltip:AddLine(_G.TIMEMANAGER_TOOLTIP_LOCALTIME, timeFormat:format(hour, min) .. " " .. suffix)

                -- Date
                tooltip:AddLine(L["Clock_Date"], date("%b %d (%a)"))

                -- Invites
                if block.invites and block.invites > 0 then
                    tooltip:AddLine(" ")
                    tooltip:AddLine(L["Clock_CalenderInvites"], block.invites)
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
                tooltip:SetCellTextColor(lineNum, colNum, Color.green:GetRGB())

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, L["Clock_ShowTimer"], nil, 2)
                tooltip:SetCellTextColor(lineNum, colNum, Color.green:GetRGB())

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                --Infobar:debug("Clock: OnEvent", event, ...)
                block.invites = _G.C_Calendar.GetNumPendingInvites()
                if block.invites > 0 and not block.alertHidden then
                    block.alertHidden = not _G.HelpTip:Show(block, block.helpTipInfo)
                else
                    _G.HelpTip:Hide(block, block.helpTipInfo.text)
                end
            end,
            events = {
                "CALENDAR_UPDATE_EVENT_LIST",
            },
        })
    end

    --[[ Left ]]--
    local PlayerStatus = {
        [1] = CreateTextureMarkup(_G.FRIENDS_TEXTURE_AFK, 16, 16, 15, 15, 0, 0.9375, 0, 0.9375),
        [2] = CreateTextureMarkup(_G.FRIENDS_TEXTURE_DND, 16, 16, 15, 15, 0, 0.9375, 0, 0.9375),
    }

    do  -- Guild Roster
        local RemoteChatStatus = {
            [0] = CreateTextureMarkup([[Interface\ChatFrame\UI-ChatIcon-ArmoryChat]], 16, 16, 15, 15, 0, 1, 0, 1, 73, 177, 73),
            [1] = CreateTextureMarkup([[Interface\ChatFrame\UI-ChatIcon-ArmoryChat-AwayMobile]], 16, 16, 15, 15, 0, 1, 0, 1),
            [2] = CreateTextureMarkup([[Interface\ChatFrame\UI-ChatIcon-ArmoryChat-BusyMobile]], 16, 16, 15, 15, 0, 1, 0, 1),
        }

        local NameSort do
            function NameSort(val1, val2, row1, row2)
                Infobar:debug("NameSort", strsplit("|", val1))
                val1 = val1:match(nameMatch)
                val2 = val2:match(nameMatch)
                Infobar:debug("Player1", val1)
                Infobar:debug("Player2", val2)

                local isMobile1 = row1.meta[2]
                local isMobile2 = row2.meta[2]
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
        local RankSort, UpdateRanks do
            local rankTable = {}
            function UpdateRanks()
                for i = 1, _G.GuildControlGetNumRanks() do
                    rankTable[_G.GuildControlGetRankName(i)] = i
                end
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
            local name = row.meta[1]
            if not name then return end

            if _G.IsAltKeyDown() then
                _G.InviteToGroup(name)
            else
                _G.SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
            end
        end
        local function Guild_GetTooltipText(cell)
            Infobar:debug("Guild_GetTooltipText")
            if cell:GetTextWidth() > cell:GetWidth() then
                Infobar:debug("Guild_GetTooltipText true")
                return cell:GetText()
            end
        end

        local tableWidth = 320
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
                Infobar:debug("Guild: OnEnable", block.side, ...)
                if _G.IsInGuild() then
                    UpdateRanks()

                    if _G.GetNumGuildMembers() == 0 then
                        _G.C_GuildInfo.GuildRoster()
                    end
                else
                    local info = Infobar:GetBlockInfo(block.name, block.dataObj)
                    Infobar:HideBlock(block.name, block.dataObj, info)
                end
            end,
            OnClick = function(block, ...)
                Infobar:debug("Guild: OnClick", block.side, ...)
                if not _G.InCombatLockdown() then
                    _G.ToggleGuildFrame()
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --Infobar:debug("Guild: OnEnter", block.side, ...)

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

                wipe(guildData)
                guildData.width = tableWidth
                guildData.header = headerData
                guildData.defaultSort = 4
                guildData.rowOnClick = Guild_OnClick
                guildData.cellGetTooltipText = Guild_GetTooltipText
                for i = 1, _G.GetNumGuildMembers() do
                    local fullName, rank, _, lvl, _, zone, note, offnote, isOnline, status, class, _, _, isMobile = _G.GetGuildRosterInfo(i)
                    if isOnline or isMobile then
                        -- Remove server from name
                        local name = _G.Ambiguate(fullName, "guild")

                        -- Class color names
                        name = _G.PLAYER_CLASS_NO_SPEC:format(_G.CUSTOM_CLASS_COLORS[class].colorStr, name)

                        -- Tags
                        if isMobile then
                            zone = _G.REMOTE_CHAT
                            name = RemoteChatStatus[status] .. name
                        elseif status > 0 then
                            name = PlayerStatus[status] .. name
                        end

                        -- Difficulty color levels
                        lvl = ("|c%s%d|r"):format(RealUI.GetColorString(_G.GetQuestDifficultyColor(lvl)), lvl)

                        if note == "" then note = nil end
                        if offnote == "" then offnote = nil end

                        tinsert(guildData, {
                            id = i,
                            info = {
                                name, lvl, zone, rank, note, offnote
                            },
                            meta = {
                                fullName, isMobile
                            }
                        })
                    end
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, guildData, TextTableCellProvider)

                lineNum = tooltip:AddLine(L["GuildFriend_WhisperInvite"]:format(_G[_G.GetDisplayedInviteType()]))
                tooltip:SetLineTextColor(lineNum, Color.green:GetRGB())

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                Infobar:debug("Guild: OnEvent", event, ...)
                if event == "GUILD_RANKS_UPDATE" then
                    UpdateRanks()
                else
                    if event == "GUILD_ROSTER_UPDATE" then
                        local canRequestRosterUpdate = ...
                        if canRequestRosterUpdate then
                            _G.C_GuildInfo.GuildRoster()
                        end
                    end

                    local isVisible, isInGuild = block:IsVisible(), _G.IsInGuild()
                    if isVisible and not isInGuild then
                        local info = Infobar:GetBlockInfo(block.name, block.dataObj)
                        Infobar:HideBlock(block.name, block.dataObj, info)
                    elseif not isVisible and isInGuild then
                        local info = Infobar:GetBlockInfo(block.name, block.dataObj)
                        Infobar:ShowBlock(block.name, block.dataObj, info)
                    end

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
                "GUILD_RANKS_UPDATE",
                "GUILD_MOTD",
            },
        })
    end

    do  -- Friends
        local nameFormat = "|cff%s%s|r |c%s(%s)|r"
        local bnetFriendColor = ("%.2x%.2x%.2x"):format(_G.FRIENDS_BNET_NAME_COLOR.r * 255, _G.FRIENDS_BNET_NAME_COLOR.g * 255, _G.FRIENDS_BNET_NAME_COLOR.b * 255)
        local NameSort do
            function NameSort(val1, val2, row1, row2)
                local index1 = row1.meta[1]
                local index2 = row2.meta[1]
                if index1 ~= index2 then
                    return index1 < index2
                end
            end
        end
        local LevelSort do
            function LevelSort(val1, val2, row1, row2)
                local lvl1 = row1.meta[2]
                local lvl2 = row2.meta[2]
                if lvl1 and lvl2 then
                    return lvl1 < lvl2
                else
                    if lvl1 and not lvl2 then
                        return true
                    elseif not lvl1 and lvl2 then
                        return false
                    end
                end
            end
        end
        local NoteSort do
            function NoteSort(val1, val2)
                if val1 and val2 then
                    return val1 < val2
                else
                    if val1 and not val2 then
                        return true
                    elseif not val1 and val2 then
                        return false
                    end
                end
            end
        end

        local function Friends_OnClick(row, ...)
            local name = row.meta[3]
            if not name[1] then return end

            if _G.IsAltKeyDown() then
                _G.InviteToGroup(name[1])
            elseif name[3] then
                _G.SetItemRef("BNplayer:"..name[2]..":"..name[3], "|HBNplayer:"..name[2].."|h["..name[2].."|h", "LeftButton")
            else
                _G.SetItemRef("player:"..name[1], "|Hplayer:"..name[1].."|h["..name[1].."]|h", "LeftButton")
            end
        end
        local function Friends_GetTooltipText(cell)
            Infobar:debug("Friends_GetTooltipText")
            if cell:GetTextWidth() > cell:GetWidth() then
                Infobar:debug("Friends_GetTooltipText true")
                return cell:GetText()
            end
        end

        local ClassLookup, tableWidth = {}, 300
        local friendsData = {}
        local headerData = {
            sort = {
                NameSort, LevelSort, true, NoteSort
            },
            info = {
                _G.NAME, _G.LEVEL_ABBR, _G.STATUS, _G.LABEL_NOTE
            },
            justify = {
                "LEFT", "RIGHT", "LEFT", "LEFT"
            },
            size = {
                "FILL", "FIT", 0.2, 0.2
            }
        }

        LDB:NewDataObject("friends", {
            name = _G.FRIENDS,
            type = "RealUI",
            icon = fa["address-book"],
            iconFont = iconFont,
            value = 1,
            OnEnable = function(block)
                -- Class Name lookup table
                for k, v in next, _G.LOCALIZED_CLASS_NAMES_MALE do
                    ClassLookup[v] = k
                end
                for k, v in next, _G.LOCALIZED_CLASS_NAMES_FEMALE do
                    ClassLookup[v] = k
                end
            end,
            OnClick = function(block, ...)
                Infobar:debug("Friends: OnClick", block.side, ...)
                if not _G.InCombatLockdown() then
                    _G.ToggleFriendsFrame()
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --Infobar:debug("Friends: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 1, "LEFT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                tooltip:AddHeader(_G.FRIENDS)

                wipe(friendsData)
                friendsData.width = tableWidth
                friendsData.header = headerData
                friendsData.defaultSort = 1
                friendsData.rowOnClick = Friends_OnClick
                friendsData.cellGetTooltipText = Friends_GetTooltipText

                -- Battle.net Friends
                for i = 1, _G.BNGetNumFriends() do
                    local accountInfo = _G.C_BattleNet.GetFriendAccountInfo(i)
                    if accountInfo and accountInfo.gameAccountInfo.isOnline then
                        local gameAccountInfo = accountInfo.gameAccountInfo
                        local client = gameAccountInfo.clientProgram ~= "" and gameAccountInfo.clientProgram or nil
                        local noteText = accountInfo.note
                        local characterName = gameAccountInfo.characterName
                        local class = gameAccountInfo.className or ""
                        local zoneName = gameAccountInfo.areaName or ""
                        local level = gameAccountInfo.characterLevel or ""
                        local gameText = gameAccountInfo.richPresence or ""

                        local name
                        if accountInfo.accountName then
                            name = accountInfo.accountName
                            characterName = _G.BNet_GetValidatedCharacterName(characterName, accountInfo.battleTag, client)
                        else
                            name = _G.UNKNOWN
                        end

                        if characterName then
                            if client == _G.BNET_CLIENT_WOW and _G.CanCooperateWithGameAccount(accountInfo) then
                                name = nameFormat:format(bnetFriendColor, name, _G.CUSTOM_CLASS_COLORS[ClassLookup[class]].colorStr, characterName)
                            else
                                if ( _G.ENABLE_COLORBLIND_MODE == "1" ) then
                                    name = nameFormat:format(bnetFriendColor, name, "ff7b8489", characterName.._G.CANNOT_COOPERATE_LABEL)
                                else
                                    name = nameFormat:format(bnetFriendColor, name, "ff7b8489", characterName)
                                end
                            end
                        end

                        if accountInfo.isAFK or gameAccountInfo.isGameAFK then
                            name = PlayerStatus[1] .. name
                        elseif accountInfo.isDND or gameAccountInfo.isGameBusy then
                            name = PlayerStatus[2] .. name
                        end
                        name = _G.BNet_GetClientEmbeddedTexture(client, 14, 14, 0, 0) .. name

                        -- Difficulty color levels
                        local lvl = tonumber(level)
                        if lvl then
                            local color = RealUI.GetColorString(_G.GetQuestDifficultyColor(level))
                            level = ("|c%s%d|r"):format(color, level)
                        end

                        local status
                        if client == _G.BNET_CLIENT_WOW then
                            if zoneName and zoneName ~= "" then
                                status = zoneName
                            else
                                status = _G.UNKNOWN
                            end
                        else
                            status = gameText
                        end

                        if noteText == "" then noteText = nil end


                        tinsert(friendsData, {
                            id = i,
                            info = {
                                name, level, status, noteText
                            },
                            meta = {
                                i, lvl, {characterName, accountInfo.accountName, accountInfo.bnetAccountID}
                            }
                        })
                    end
                end

                -- WoW Friends
                for i = 1, _G.C_FriendList.GetNumOnlineFriends() do
                    local info = _G.C_FriendList.GetFriendInfoByIndex(i)

                    -- Class color names
                    local name = _G.PLAYER_CLASS_NO_SPEC:format(_G.CUSTOM_CLASS_COLORS[ClassLookup[info.className]].colorStr, info.name)

                    if info.afk then
                        name = PlayerStatus[1] .. name
                    elseif info.dnd then
                        name = PlayerStatus[2] .. name
                    end

                    -- Difficulty color levels
                    local level = ("|c%s%d|r"):format(RealUI.GetColorString(_G.GetQuestDifficultyColor(info.level)), info.level)

                    -- Add Friend to list
                    tinsert(friendsData, {
                        id = #friendsData + i,
                        info = {
                            name, level, info.area, info.notes
                        },
                        meta = {
                            #friendsData + i, info.level, {info.name}
                        }
                    })
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, friendsData, TextTableCellProvider)

                lineNum = tooltip:AddLine(L["GuildFriend_WhisperInvite"]:format(_G[_G.GetDisplayedInviteType()]))
                tooltip:SetLineTextColor(lineNum, Color.green:GetRGB())

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                Infobar:debug("Friend: OnEvent", event, ...)

                local _, numBNetOnline = _G.BNGetNumFriends()
                local numWoWOnline = _G.C_FriendList.GetNumOnlineFriends()

                block.dataObj.value = numBNetOnline + numWoWOnline
            end,
            events = {
                "FRIENDLIST_UPDATE",
                "BN_FRIEND_INVITE_ADDED",
                "BN_FRIEND_INVITE_LIST_INITIALIZED",
                "BN_FRIEND_INVITE_REMOVED",
                "BN_FRIEND_ACCOUNT_ONLINE",
                "BN_FRIEND_ACCOUNT_OFFLINE",
            },
        })
    end

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
            OnEnable = function(block)
                block.helpTipInfo = {
                    text = _G.TUTORIAL36:match("(.-%p)"),
                    buttonStyle = _G.HelpTip.ButtonStyle.Close,
                    targetPoint = _G.HelpTip.Point.TopEdgeCenter,
                    alignment = _G.HelpTip.Alignment.Left,
                    autoHorizontalSlide = true,
                    onHideCallback = function( ... )
                        block.alertHidden = true
                    end
                }
            end,
            OnClick = function(block, ...)
                Infobar:debug("Durability: OnClick", block.side, ...)
                if not _G.InCombatLockdown() then
                    _G.ToggleCharacter("PaperDollFrame")
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --Infobar:debug("Durability: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetCell(lineNum, colNum, _G.DURABILITY, nil, 2)

                for slotID = 1, #itemSlots do
                    local item = itemSlots[slotID]
                    if item.hasDura and item.dura then
                        lineNum = tooltip:AddLine(item.slot, round(item.dura * 100, 1) .. "%")
                        if slotID == itemSlots.lowSlot then
                            tooltip:SetLineTextColor(lineNum, RealUI.GetDurabilityColor(item.min, item.max):GetRGB())
                        else
                            tooltip:SetCellTextColor(lineNum, 2, RealUI.GetDurabilityColor(item.min, item.max):GetRGB())
                        end
                    end
                end

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                Infobar:debug("Durability1: OnEvent", event, ...)
                local lowDur, lowMin, lowMax, lowSlot = 1, 1, 1
                for slotID = 1, #itemSlots do
                    local item = itemSlots[slotID]
                    if item.hasDura then
                        local min, max = _G.GetInventoryItemDurability(slotID)
                        if max then
                            item.dura = RealUI.GetSafeVals(min, max)
                            item.min, item.max = min, max
                            if lowDur > item.dura then
                                lowDur, lowSlot = item.dura, slotID
                                lowMin, lowMax = min, max
                            end
                            Infobar:debug(slotID, item.slot, round(item.dura, 3), min, lowMin)
                        end
                    end
                end
                itemSlots.lowSlot = lowSlot

                if lowDur < 0.1 and not block.alertHidden then
                    block.alertHidden = not _G.HelpTip:Show(block, block.helpTipInfo)
                else
                    _G.HelpTip:Hide(block, block.helpTipInfo.text)
                end
                block.dataObj.text = round(lowDur * 100) .. "%"
                block.dataObj.iconR, block.dataObj.iconG, block.dataObj.iconB = RealUI.GetDurabilityColor(lowMin, lowMax):GetRGB()
                block.timer = false
            end,
            events = {
                "UPDATE_INVENTORY_DURABILITY",
                "PLAYER_EQUIPMENT_CHANGED",
            },
        })
    end

    do -- Progress Watch
        local C_AzeriteItem = _G.C_AzeriteItem
        local azeriteItem, azeriteItemLocation
        local watchStates = {}
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
                return not _G.IsPlayerAtEffectiveMaxLevel()
            end,
            SetTooltip = function(XP, tooltip)
                local curXP, maxXP, restXP = XP:GetStats()
                local xpStatus = ("%s/%s (%.1f%%)"):format(RealUI.ReadableNumber(curXP), RealUI.ReadableNumber(maxXP), (curXP/maxXP)*100)
                local lineNum = tooltip:AddLine(_G.EXPERIENCE_COLON, xpStatus)
                tooltip:SetCellTextColor(lineNum, 1, Color.orange:GetRGB())
                tooltip:SetCellTextColor(lineNum, 2, Color.grayLight:GetRGB())
                if _G.IsXPUserDisabled() then
                    lineNum = tooltip:AddLine(_G.EXPERIENCE_COLON, _G.VIDEO_OPTIONS_DISABLED)
                    tooltip:SetCellTextColor(lineNum, 1, Color.orange:GetRGB())
                    tooltip:SetCellTextColor(lineNum, 2, Color.gray:GetRGB())
                elseif restXP then
                    lineNum = tooltip:AddLine(_G.TUTORIAL_TITLE26, RealUI.ReadableNumber(restXP))
                    tooltip:SetLineTextColor(lineNum, Color.grayLight:GetRGB())
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
                local name, reaction, minRep, maxRep, curRep, factionID = _G.GetWatchedFactionInfo()
                Rep.factionStandingtext = _G["FACTION_STANDING_LABEL"..reaction]
                Rep.colorIndex = reaction

                local friendshipID = _G.GetFriendshipReputation(factionID)
                if friendshipID then
                    local _, friendRep, _, _, _, _, friendTextLevel, friendThreshold, nextFriendThreshold = _G.GetFriendshipReputation(factionID)
                    if nextFriendThreshold then
                        minRep, maxRep, curRep = friendThreshold, nextFriendThreshold, friendRep
                    else
                        -- max rank, make it look like a full bar
                        minRep, maxRep, curRep = 0, 1, 1
                    end
                    Rep.colorIndex = 5     -- always color friendships green
                    Rep.factionStandingtext = friendTextLevel
                elseif _G.C_Reputation.IsFactionParagon(factionID) then
                    local currentValue, threshold, _, hasRewardPending = _G.C_Reputation.GetFactionParagonInfo(factionID)
                    maxRep = threshold
                    curRep = currentValue % threshold
                    if hasRewardPending then
                        curRep = curRep + threshold
                    end
                    return curRep, maxRep, name, hasRewardPending
                else
                    if reaction == _G.MAX_REPUTATION_REACTION then
                        -- We're exalted
                        minRep = 0
                    end
                end

                -- Normalize values
                maxRep = maxRep - minRep
                curRep = curRep - minRep
                return curRep, maxRep, name
            end,
            GetColor = function(Rep)
                local color = _G.FACTION_BAR_COLORS[Rep.colorIndex]
                return color.r, color.g, color.b
            end,
            IsValid = function(Rep)
                return not not _G.GetWatchedFactionInfo()
            end,
            SetTooltip = function(Rep, tooltip)
                local curRep, maxRep, name, hasRewardPending = Rep:GetStats()
                local r, g, b = Rep:GetColor()

                local lineNum = tooltip:AddLine(_G.REPUTATION.._G.HEADER_COLON, name)
                tooltip:SetCellTextColor(lineNum, 1, Color.orange:GetRGB())
                tooltip:SetCellTextColor(lineNum, 2, r, g, b)

                local repStatus = ("%s/%s (%.1f%%)"):format(RealUI.ReadableNumber(curRep), RealUI.ReadableNumber(maxRep), (curRep/maxRep)*100)
                lineNum = tooltip:AddLine(Rep.factionStandingtext, repStatus)
                tooltip:SetCellTextColor(lineNum, 1, r, g, b)
                tooltip:SetCellTextColor(lineNum, 2, Color.grayLight:GetRGB())

                if hasRewardPending then
                    lineNum = tooltip:AddLine(_G.BOUNTY_TUTORIAL_BOUNTY_FINISHED)
                    tooltip:SetLineTextColor(lineNum, Color.gray:GetRGB())
                end

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
                elseif watchStates["xp"]:IsValid() then
                    return "xp"
                elseif watchStates["rep"]:IsValid() then
                    return "rep"
                elseif watchStates["artifact"]:IsValid() then
                    return "artifact"
                else
                    return nil
                end
            end,
            GetStats = function(Art)
                -- /dump C_AzeriteItem.GetAzeriteItemXPInfo(C_AzeriteItem.FindActiveAzeriteItem())
                azeriteItemLocation = C_AzeriteItem.FindActiveAzeriteItem()

                if azeriteItemLocation then
                    if not azeriteItem then
                        azeriteItem = _G.Item:CreateFromItemLocation(azeriteItemLocation)
                    end

                    local xp, totalLevelXP, currentLevel
                    if _G.AzeriteUtil.IsAzeriteItemLocationBankBag(azeriteItemLocation) then
                        xp, totalLevelXP = 0, 1
                        currentLevel = -1
                    else
                        xp, totalLevelXP = C_AzeriteItem.GetAzeriteItemXPInfo(azeriteItemLocation)
                        currentLevel = C_AzeriteItem.GetPowerLevel(azeriteItemLocation)
                    end

                    return xp, totalLevelXP, azeriteItem:GetItemName() or "", currentLevel
                end
            end,
            GetColor = function(Art)
                return _G.ARTIFACT_BAR_COLOR:GetRGB()
            end,
            IsValid = function(Art)
                return C_AzeriteItem.HasActiveAzeriteItem() and not C_AzeriteItem.IsAzeriteItemAtMaxLevel()
            end,
            SetTooltip = function(Art, tooltip)
                local xp, totalLevelXP, name, currentLevel = Art:GetStats()
                local xpToNextLevel = totalLevelXP - xp

                local title
                if currentLevel == -1 then
                    title = _G.HEART_OF_AZEROTH_MISSING_ERROR
                else
                    title = _G.AZERITE_POWER_TOOLTIP_TITLE:format(currentLevel, xpToNextLevel)
                end

                local lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, title, nil, nil, 2)
                tooltip:SetCellTextColor(lineNum, colNum, Color.orange:GetRGB())

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, _G.AZERITE_POWER_TOOLTIP_BODY:format(name), nil, nil, 2)
                tooltip:SetCellTextColor(lineNum, colNum, Color.grayLight:GetRGB())

                tooltip:AddLine(" ")
            end,
            OnClick = function(Art)
                _G.ToggleCharacter("PaperDollFrame")
            end
        }
        watchStates["honor"] = {
            hint = L["Progress_OpenHonor"],
            GetNext = function(Honor)
                if watchStates["xp"]:IsValid() then
                    return "xp"
                elseif watchStates["rep"]:IsValid() then
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
                return _G.UnitHonor("player"), _G.UnitHonorMax("player")
            end,
            GetColor = function(Honor, isRested)
                if isRested then
                    return 1.0, 0.71, 0
                else
                    return 1.0, 0.24, 0
                end
            end,
            IsValid = function(Honor)
                return true
            end,
            SetTooltip = function(Honor, tooltip)
                local minHonor, maxHonor = Honor:GetStats()
                local honorStatus = ("%s/%s (%.1f%%)"):format(RealUI.ReadableNumber(minHonor), RealUI.ReadableNumber(maxHonor), (minHonor/maxHonor)*100)

                local level = _G.UnitHonorLevel("player")
                local lineNum = tooltip:AddLine(_G.HONOR_LEVEL_LABEL:format(level).._G.HEADER_COLON, honorStatus)
                tooltip:SetCellTextColor(lineNum, 1, Color.orange:GetRGB())
                tooltip:SetCellTextColor(lineNum, 2, Color.grayLight:GetRGB())

                tooltip:AddLine(" ")
            end,
            OnClick = function(Honor)
                _G.ToggleTalentFrame(_G.PVP_TALENTS_TAB)
            end
        }

        function Infobar.frame.watch:UpdateColors()
            local alpha = _G.Lerp(0.4, 0.5, (Infobar.db.profile.bgAlpha / 1))

            local main = self.main
            local r, g, b = watchStates[dbc.progressState]:GetColor()
            main:SetStatusBarColor(r, g, b, alpha)

            r, g, b = watchStates[dbc.progressState]:GetColor(true)
            main.rested:SetColorTexture(r, g, b, alpha)

            local nextState = watchStates[dbc.progressState]:GetNext()
            for i = 1, 2 do
                local bar = self[i]
                if nextState ~= dbc.progressState then
                    r, g, b = watchStates[nextState]:GetColor()
                    bar:SetStatusBarColor(r, g, b, alpha * 1.5)

                    local bgColor = Color.frame
                    bar.bg:SetColorTexture(bgColor.r, bgColor.g, bgColor.b, alpha)
                end
                nextState = watchStates[nextState]:GetNext()
            end
        end

        local function UpdateProgress(block)
            local curValue, maxValue, otherValue = watchStates[dbc.progressState]:GetStats()
            local value = curValue / maxValue
            block.dataObj.icon = fa["thermometer-"..round(value * 4)]
            block.dataObj.text = round(value, 3) * 100 .. "%"

            if Infobar.db.profile.showBars then
                local watch = Infobar.frame.watch
                Infobar:debug("progress:main", dbc.progressState, curValue, maxValue)

                local main = watch.main
                main:SetMinMaxValues(0, maxValue)
                main:SetValue(curValue)
                main:Show()

                if type(otherValue) == "number" then
                    local restedOfs = max(((curValue + otherValue) / maxValue) * main:GetWidth(), 0)
                    Scale.Point(main.rested, "BOTTOMRIGHT", main, "BOTTOMLEFT", restedOfs, 0)
                    main.rested:Show()
                end

                local nextState = watchStates[dbc.progressState]:GetNext()
                for i = 1, 2 do
                    local bar = watch[i]
                    if nextState ~= dbc.progressState then
                        curValue, maxValue = watchStates[nextState]:GetStats()
                        Infobar:debug("progress:"..i, nextState, curValue, maxValue)

                        bar:SetMinMaxValues(0, maxValue)
                        bar:SetValue(curValue)
                        bar:Show()
                    else
                        bar:Hide()
                    end
                    nextState = watchStates[nextState]:GetNext()
                end

                watch:UpdateColors()
            end
        end

        local function UpdateState(block)
            local state = watchStates[dbc.progressState]:GetNext()
            if state then
                Infobar:debug("check state", dbc.progressState, state)
                dbc.progressState = state
                Infobar.frame.watch.main.rested:Hide()
                UpdateProgress(block)
            else
                Infobar:HideBlock(block.name, block.dataObj, block)
            end
        end

        LDB:NewDataObject("progress", {
            name = L["Progress"],
            type = "RealUI",
            icon = fa["thermometer"],
            iconFont = iconFont,
            text = "XP",
            OnEnable = function(block)
                Infobar:debug("progress: OnEnable", block.side)
                if not watchStates[dbc.progressState] then
                    dbc.progressState = "xp"
                end

                if not watchStates[dbc.progressState]:IsValid() then
                    UpdateState(block)
                end
                UpdateProgress(block)
            end,
            OnDisable = function(block)
                Infobar:debug("progress: OnDisable", block.side)
                local watch = Infobar.frame.watch
                watch.main:Hide()
                watch[1]:Hide()
                watch[2]:Hide()

                block:UnregisterAllEvents()
            end,
            OnClick = function(block, ...)
                Infobar:debug("progress: OnClick", block.side, ...)
                if _G.IsAltKeyDown() then
                    UpdateState(block)
                else
                    watchStates[dbc.progressState]:OnClick()
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --Infobar:debug("progress: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum, colNum

                lineNum, colNum = tooltip:AddHeader()
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
                tooltip:SetCellTextColor(lineNum, colNum, Color.green:GetRGB())

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                Infobar:debug("progress: OnEvent", block.side, event, ...)
                if event == "AZERITE_ITEM_POWER_LEVEL_CHANGED" or event == "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED" then
                    if _G.AzeriteUtil.DoEquippedItemsHaveUnselectedPowers() then
                        block.pulseAnim:Play()
                    else
                        block.pulseAnim:Finish()
                    end
                elseif event == "UPDATE_EXPANSION_LEVEL" then
                    if not watchStates.xp:IsValid() then
                        dbc.progressState = "xp"
                    end
                elseif event == "UPDATE_FACTION" then
                    if not watchStates[dbc.progressState]:IsValid() then
                        UpdateState(block)
                    end
                end

                UpdateProgress(block)
            end,
            events = {
                "UPDATE_EXPANSION_LEVEL",
                "PLAYER_LEVEL_UP",
                "UPDATE_EXHAUSTION",

                "PLAYER_XP_UPDATE",
                "PLAYER_UPDATE_RESTING",
                "DISABLE_XP_GAIN",
                "ENABLE_XP_GAIN",

                "UPDATE_FACTION",

                "AZERITE_ITEM_EXPERIENCE_CHANGED",
                "AZERITE_ITEM_POWER_LEVEL_CHANGED",
                "AZERITE_EMPOWERED_ITEM_SELECTION_UPDATED",

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
                --Infobar:debug("Mail: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 1, "LEFT")
                SetupTooltip(tooltip, block)

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
                Infobar:debug("Mail1: OnEvent", event, ...)
                local info = Infobar:GetBlockInfo(block.name, block.dataObj)
                local isVisible, hasNewMail = block:IsVisible(), _G.HasNewMail()
                if not isVisible and hasNewMail then
                    Infobar:ShowBlock(block.name, block.dataObj, info)
                elseif isVisible and not hasNewMail then
                    Infobar:HideBlock(block.name, block.dataObj, info)
                end
            end,
            events = {
                "UPDATE_PENDING_MAIL",
                "MAIL_INBOX_UPDATE",
            },
        })
    end

    do -- Bag space
        LDB:NewDataObject("bags", {
            name = _G.BAGSLOTTEXT,
            type = "RealUI",
            icon = fa["shopping-bag"],
            iconFont = iconFont,
            value = 1,
            tooltiptext = "",
            OnClick = function(block, ...)
                Infobar:debug("Friends: OnClick", block.side, ...)
                _G.ToggleAllBags()
            end,
            OnEvent = function(block, event, ...)
                Infobar:debug("currency: OnEvent", block.side, event, ...)
                local freeSlots, totalSlots = 0, 0

                -- Cycle through bags
                for bagID = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS do
                    local slots, slotsTotal = _G.GetContainerNumFreeSlots(bagID), _G.GetContainerNumSlots(bagID)
                    if ( bagID >= 1 ) then  -- Extra bag
                        local bagLink = _G.GetInventoryItemLink("player", _G.ContainerIDToInventoryID(bagID))
                        if bagLink then
                            freeSlots = freeSlots + slots
                            totalSlots = totalSlots + slotsTotal
                        end
                    else -- Backpack, we count slots
                        freeSlots = freeSlots + slots
                        totalSlots = totalSlots + slotsTotal
                    end
                end

                block.dataObj.value = freeSlots
                block.dataObj.tooltiptext = _G.NUM_FREE_SLOTS:format(freeSlots)
            end,
            events = {
                "UNIT_INVENTORY_CHANGED",
                "BAG_UPDATE_DELAYED",
            },
        })
    end

    do -- Specialization
        local C_EquipmentSet = _G.C_EquipmentSet
        local specInfo, specLines = RealUI.charInfo.specs, {}
        local equipmentSetIDs, equipmentSetInfos = {}, {}
        local equipmentNeedsUpdate = false

        local function Line_OnMouseUp(line, specIndex, button)
            local tooltip = line:GetParent():GetParent():GetParent()
            if button == "LeftButton" then
                if _G.IsAltKeyDown() then
                    _G.SetLootSpecialization(specInfo[specIndex].id)
                else
                    if not _G.InCombatLockdown() then
                        if specIndex == specInfo.current.index then
                            if dbc.specgear[specIndex] >= 0 then
                                _G.EquipmentManager_EquipSet(dbc.specgear[specIndex])
                            end
                        else
                            _G.SetSpecialization(specIndex)
                            if dbc.specgear[specIndex] >= 0 then
                                equipmentNeedsUpdate = dbc.specgear[specIndex]
                            end
                        end
                    end
                end
            elseif button == "RightButton" and #equipmentSetIDs > 0 then
                if _G.IsAltKeyDown() then
                    dbc.specgear[specIndex] = -1
                    tooltip:SetCell(specLines[specIndex], 2, "---")
                else
                    local equipIndex
                    if dbc.specgear[specIndex] < 0 then
                        equipIndex = 1
                    else
                        equipIndex = _G.Wrap(equipmentSetInfos[dbc.specgear[specIndex]].index + 1, #equipmentSetIDs)
                    end
                    dbc.specgear[specIndex] = equipmentSetIDs[equipIndex]
                    tooltip:SetCell(specLines[specIndex], 2, equipmentSetInfos[dbc.specgear[specIndex]].name)
                end
            end
        end

        local function UpdateGearSets()
            equipmentSetIDs = C_EquipmentSet.GetEquipmentSetIDs()
            wipe(equipmentSetInfos)
            for index = 1, #equipmentSetIDs do
                local equipName = C_EquipmentSet.GetEquipmentSetInfo(equipmentSetIDs[index])
                equipmentSetInfos[equipmentSetIDs[index]] = {
                    name = equipName,
                    index = index
                }
            end

            for specIndex = 1, #specInfo do
                if not equipmentSetInfos[dbc.specgear[specIndex]] then
                    dbc.specgear[specIndex] = -1
                end
            end
        end
        local function UpdateBlock(block)
            block.dataObj.icon = specInfo[specInfo.current.index].icon
            block.dataObj.text = specInfo[specInfo.current.index].name
        end

        local lootSpec, hintSpec, hintGear
        local function Spec_TooltipOnUpdate(tooltip)
            local numColumns = tooltip:GetColumnCount()
            tooltip:SetCell(lootSpec, 1, ("%s: %s"):format(_G.SELECT_LOOT_SPECIALIZATION, RealUI.GetCurrentLootSpecName()), nil, numColumns)
            tooltip:SetCell(hintGear, 1, nil, nil, numColumns)

            if tooltip:IsMouseOver() then
                tooltip:SetCell(hintSpec, 1, L["Spec_ChangeSpec"], nil, numColumns)
                if #equipmentSetIDs > 0 then
                    tooltip:SetCell(hintGear, 1, L["Spec_ChangeGear"], nil, numColumns)
                    tooltip:SetCellTextColor(hintGear, 1, Color.green:GetRGB())
                end
            else
                tooltip:SetCell(hintSpec, 1, L["Spec_Open"], nil, numColumns)
            end
        end

        LDB:NewDataObject("spec", {
            name = _G.SPECIALIZATION,
            type = "RealUI",
            icon = specInfo[1].icon,
            iconCoords = {.08, .92, .08, .92},
            text = "",
            OnEnable = function(block)
                Infobar:debug("spec: OnEnable", block.side)
                UpdateGearSets()
                UpdateBlock(block)
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --Infobar:debug("spec: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "LEFT")
                SetupTooltip(tooltip, block)
                tooltip:SetScript("OnUpdate", Spec_TooltipOnUpdate)
                local lineNum, colNum

                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetCell(lineNum, colNum, _G.SPECIALIZATION, nil, 2)
                for specIndex = 1, #RealUI.charInfo.specs do
                    if #equipmentSetIDs > 0 then
                        tooltip:AddColumn("LEFT")
                        local equipSet = dbc.specgear[specIndex] >= 0 and equipmentSetInfos[dbc.specgear[specIndex]]
                        lineNum = tooltip:AddLine(specInfo[specIndex].name, equipSet and equipSet.name or "---", RealUI.db:GetDualSpecProfile(specIndex))
                    else
                        lineNum = tooltip:AddLine(specInfo[specIndex].name, RealUI.db:GetDualSpecProfile(specIndex))
                    end

                    tooltip:SetLineScript(lineNum, "OnMouseUp", Line_OnMouseUp, specIndex)
                    specLines[specIndex] = lineNum
                    if specIndex == specInfo.current.index then
                        tooltip:SetLineTextColor(lineNum, Color.orange:GetRGB())
                    end
                end

                tooltip:AddLine(" ")
                lootSpec = tooltip:AddLine()
                hintSpec = tooltip:AddLine()
                hintGear = tooltip:AddLine()
                tooltip:SetCell(hintSpec, 1, L["Spec_Open"], nil, tooltip:GetColumnCount())
                tooltip:SetCellTextColor(hintSpec, 1, Color.green:GetRGB())

                tooltip:Show()
            end,
            OnClick = function(block, ...)
                Infobar:debug("spec: OnClick", block.side, ...)
                _G.ToggleTalentFrame(_G.TalentMicroButton.suggestedTab)
            end,
            OnEvent = function(block, event, ...)
                Infobar:debug("spec: OnEvent", block.side, event, ...)
                if event == "EQUIPMENT_SETS_CHANGED" then
                    UpdateGearSets()
                elseif event == "PLAYER_SPECIALIZATION_CHANGED" then
                    UpdateBlock(block)

                    if equipmentNeedsUpdate then
                        _G.EquipmentManager_EquipSet(equipmentNeedsUpdate)
                        equipmentNeedsUpdate = false
                    end
                end
            end,
            events = {
                "PLAYER_SPECIALIZATION_CHANGED",
                "EQUIPMENT_SETS_CHANGED",
                "EQUIPMENT_SWAP_FINISHED",
                "PLAYER_EQUIPMENT_CHANGED",
            },
        })
    end

    do -- Currency
        local GOLD_AMOUNT_STRING = "%s|cfffff226%s|r"
        local SILVER_AMOUNT_STRING = "%d|cffbfbfbf%s|r"
        local COPPER_AMOUNT_STRING = "%d|cffbf734f%s|r"
        local TOKEN_STRING = [[|T%s:12:12:0:0:64:64:5:59:5:59|t %d]]
        local charName = "%s |c%s%s|r"

        local currencyDB
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
            local gold = floor(money / (_G.COPPER_PER_SILVER * _G.SILVER_PER_GOLD))
            local silver = floor((money - (gold * _G.COPPER_PER_SILVER * _G.SILVER_PER_GOLD)) / _G.COPPER_PER_SILVER)
            local copper = money % _G.COPPER_PER_SILVER
            return gold, silver, copper
        end
        local neutralTCoords = {0.140625, 0.28125, 0.5625, 0.84375}
        local function GetInlineFactionIcon(faction)
            local coords = _G.QUEST_TAG_TCOORDS[faction:upper()] or neutralTCoords
            return _G.CreateTextureMarkup(_G.QUEST_ICONS_FILE, _G.QUEST_ICONS_FILE_WIDTH, _G.QUEST_ICONS_FILE_HEIGHT, 16, 16
            , coords[1]
            , coords[2]
            , coords[3]
            , coords[4], 0, 2)
        end
        local function GetMoneyString(money, useFirst)
            local goldString, silverString, copperString
            local gold, silver, copper = SplitMoney(money)

            goldString = GOLD_AMOUNT_STRING:format(RealUI.ReadableNumber(gold), _G.GOLD_AMOUNT_SYMBOL)
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
                if RealUI.realmInfo.realmNormalized then
                    return GetMoneyString(currencyDB[RealUI.realmInfo.realmNormalized][RealUI.charInfo.faction][RealUI.charInfo.name].money)
                else
                    return _G.SEARCH_LOADING_TEXT
                end
            end,
            GetIcon = function(Money)
                if RealUI.realmInfo.realmNormalized then
                    local gold, silver = SplitMoney(currencyDB[RealUI.realmInfo.realmNormalized][RealUI.charInfo.faction][RealUI.charInfo.name].money)
                    if gold > 0 then
                        return [[Interface\Icons\INV_Misc_Coin_02]], _G.GOLD_AMOUNT_SYMBOL
                    elseif silver > 0 then
                        return [[Interface\Icons\INV_Misc_Coin_03]], _G.SILVER_AMOUNT_SYMBOL
                    else
                        return [[Interface\Icons\INV_Misc_Coin_19]], _G.COPPER_AMOUNT_SYMBOL
                    end
                else
                    return [[Interface\Icons\INV_Misc_Coin_02]], _G.GOLD_AMOUNT_SYMBOL
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
                    if token.id and RealUI.realmInfo.realmNormalized then
                        return currencyDB[RealUI.realmInfo.realmNormalized][RealUI.charInfo.faction][RealUI.charInfo.name][token.id] or 0
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
            if not RealUI.realmInfo.realmNormalized then return end
            local changeIndex

            if RealUI.isPatch then
                for i = 1, _G.MAX_WATCHED_TOKENS do
                    local token = currencyStates["token"..i]
                    local currencyInfo = _G.C_CurrencyInfo.GetBackpackCurrencyInfo(token.index)
                    if currencyInfo then
                        if token.id ~= currencyInfo.currencyTypesID and not changeIndex then
                            changeIndex = i
                        end

                        token.name = currencyInfo.name
                        token.icon = currencyInfo.iconFileID
                        token.id = currencyInfo.currencyTypesID
                        currencyDB[RealUI.realmInfo.realmNormalized][RealUI.charInfo.faction][RealUI.charInfo.name]["token"..i] = currencyInfo.currencyTypesID
                    end
                end
            else
                for i = 1, _G.MAX_WATCHED_TOKENS do
                    local token = currencyStates["token"..i]
                    local name, _, icon, currencyID = _G.GetBackpackCurrencyInfo(token.index)
                    if token.id ~= currencyID and not changeIndex then
                        changeIndex = i
                    end

                    token.name = name
                    token.icon = icon
                    token.id = currencyID
                    currencyDB[RealUI.realmInfo.realmNormalized][RealUI.charInfo.faction][RealUI.charInfo.name]["token"..i] = currencyID
                end
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
            Infobar:debug("check state", dbc.currencyState, state)
            dbc.currencyState = state

            UpdateBlock(block)
        end

        local function Currency_OnClick(row, ...)
            local name = row[1]:GetText():match(nameMatch)
            if not name then return end
            local realm, faction = strsplit("-", row.meta[1])

            if _G.IsAltKeyDown() then
                currencyDB[realm][faction][name] = nil
            end
        end
        local function Currency_GetTooltipText(cell)
            Infobar:debug("Currency_GetTooltipText")
            local name = cell.row.meta[cell:GetID()]
            if name then
                Infobar:debug("Currency_GetTooltipText", name)
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

        local tokens, tableWidth = {}, 250
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
            name = _G.CURRENCY,
            type = "RealUI",
            icon = [[Interface\MoneyFrame\UI-GoldIcon]],
            iconCoords = {.08, .92, .08, .92},
            text = "Currency",
            OnEnable = function(block)
                Infobar:debug("currency: OnEnable", block.side)
                if RealUI.realmInfo.realmNormalized then
                    currencyDB = RealUI.db.global.currency
                    local function UpdateTracked(index, backpack)
                        local trackedIndex, trackedName = currencyStates[dbc.currencyState].index, currencyStates[dbc.currencyState].name
                        local changeIndex = UpdateTrackedCurrency(block)
                        if changeIndex and trackedIndex then
                            if changeIndex < trackedIndex then
                                if backpack == 0 and trackedName == currencyStates["token"..trackedIndex-1].name then
                                    dbc.currencyState = "token"..trackedIndex-1
                                end
                            elseif changeIndex == trackedIndex then
                                if backpack == 1 and trackedName == currencyStates["token"..trackedIndex+1].name then
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
                    end

                    if RealUI.isPatch then
                        _G.hooksecurefunc(_G.C_CurrencyInfo, "SetCurrencyBackpack", UpdateTracked)
                    else
                        _G.hooksecurefunc("SetCurrencyBackpack", UpdateTracked)
                    end

                    if not currencyStates[dbc.currencyState]:IsValid() then
                        UpdateState(block)
                    else
                        UpdateTrackedCurrency(block)
                        UpdateBlock(block)
                    end
                else
                    self:RegisterMessage("NormalizedRealmReceived", block.dataObj.OnEnable, block)
                end
            end,
            OnClick = function(block, ...)
                Infobar:debug("currency: OnClick", block.side, ...)
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
                --Infobar:debug("currency: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
                SetupTooltip(tooltip, block)
                tooltip:SetScript("OnUpdate", Currency_TooltipOnUpdate)
                local lineNum, colNum

                tooltip:AddHeader(_G.CURRENCY)

                wipe(currencyData)
                currencyData.width = tableWidth
                currencyData.header = headerData
                currencyData.defaultSort = 1
                currencyData.rowOnClick = Currency_OnClick
                currencyData.cellGetTooltipText = Currency_GetTooltipText

                local realmMoneyTotal = 0
                for index, realm in next, RealUI.realmInfo.connectedRealms do
                    local realmDB = currencyDB[realm]
                    if realmDB then
                        for faction, factionDB in next, realmDB do
                            local realm_faction = realm.."-"..faction
                            local factionIcon = GetInlineFactionIcon(faction)
                            for name, data in next, factionDB do
                                name = charName:format(factionIcon, _G.CUSTOM_CLASS_COLORS[data.class].colorStr, name)
                                local money = GetMoneyString(data.money, true)
                                realmMoneyTotal = realmMoneyTotal + data.money

                                wipe(tokens)
                                for i = 1, _G.MAX_WATCHED_TOKENS do
                                    if data["token"..i] then
                                        local tokenName, _, texture
                                        if RealUI.isPatch then
                                            local currencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo(data["token"..i])
                                            tokenName = currencyInfo.name
                                            texture = currencyInfo.iconFileID
                                        else
                                            tokenName, _, texture = _G.GetCurrencyInfo(data["token"..i])
                                        end
                                        local amount = data[data["token"..i]] or 0
                                        tokens[i] = TOKEN_STRING:format(texture, amount)
                                        tokens[i+3] = tokenName
                                    else
                                        tokens[i] = "---"
                                    end
                                end

                                tinsert(currencyData, {
                                    id = #currencyData + 1,
                                    info = {
                                        name, money, tokens[1], tokens[2], tokens[3], date("%b %d", data.lastSeen)
                                    },
                                    meta = {
                                        realm_faction, GetMoneyString(data.money), tokens[4], tokens[5], tokens[6], ""
                                    }
                                })
                            end
                        end
                    end
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, currencyData, TextTableCellProvider)

                tooltip:AddLine(L["Currency_TotalMoney"]..GetMoneyString(realmMoneyTotal))
                tooltip:AddLine(" ")

                hintLine = tooltip:AddLine(L["Currency_Cycle"])
                tooltip:SetLineTextColor(hintLine, Color.green:GetRGB())

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                Infobar:debug("currency: OnEvent", block.side, event, ...)
                UpdateBlock(block)
            end,
            events = {
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
        local lagFormat = "%s |cff808080(%s)|r"

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
            icon = fa["microchip"],
            iconFont = iconFont,
            label = "FPS/Ping",
            text = "FPS/Ping",
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                --Infobar:debug("progress: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 3, "LEFT", "RIGHT", "RIGHT")
                SetupTooltip(tooltip, block)
                local lineNum--, colNum

                tooltip:AddHeader(_G.NETWORK_LABEL)

                lineNum = tooltip:AddLine(L["Sys_Stat"], L["Sys_CurrentAbbr"], L["Sys_AverageAbbr"])
                tooltip:SetLineTextColor(lineNum, Color.orange:GetRGB())
                tooltip:AddLine(lagFormat:format(_G.HOME, _G.MILLISECONDS_ABBR), round(home.cur), round(home.avg))
                tooltip:AddLine(lagFormat:format(_G.WORLD, _G.MILLISECONDS_ABBR), round(world.cur), round(world.avg))

                tooltip:AddLine(" ")

                tooltip:AddHeader(_G.SYSTEMOPTIONS_MENU)
                lineNum = tooltip:AddLine(L["Sys_Stat"], L["Sys_CurrentAbbr"], L["Sys_AverageAbbr"])
                tooltip:SetLineTextColor(lineNum, Color.orange:GetRGB())
                tooltip:AddLine(_G.FRAMERATE_LABEL, round(fps.cur), round(fps.avg))

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
