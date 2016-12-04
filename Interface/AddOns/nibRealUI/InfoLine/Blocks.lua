local _, private = ...

-- Lua Globals --
local _G = _G
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
local LIF = _G.LibStub("LibIconFonts-1.0")
local fa = LIF:GetIconFont("FontAwesome")
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

local TABLE_WIDTH = 500
local TextTableCellProvider, TextTableCellPrototype = qTip:CreateCellProvider()
do
    local MAX_ROWS = 10
    local ROW_HEIGHT = 10
    local numTables = 0


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
            for col = 1, #header do
                local text = row[col]
                if not text then
                    text = row:CreateFontString("$parentText", "ARTWORK", "RealUIFont_Normal")
                    text:SetPoint("TOP")
                    text:SetPoint("BOTTOM")
                    text:SetPoint("LEFT", header[col])
                    text:SetPoint("RIGHT", header[col])

                    row[col] = text
                end
                local rowData = data[index]
                if rowData then
                    rowData.id = i
                    text:SetText(rowData.info[col])
                    text:SetJustifyH(data.header.justify[col])
                else
                    text:SetText("")
                end
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
        -- @param Val1  Element value for row 1.
        -- @param Val2  Element value for row 2.
        -- @param Row1..Row2  Row tables being compared.
        -- @return True/false if Val1 is less/greater than Val2, or nil if they are equal.
        local function SortSimple(Val1, Val2 --[[, Row1, Row2]])
            if Val1 ~= Val2 then
                return Val1 < Val2
            end
        end


        local Handler, Column, Inverted
        -- Compare function for table.sort that supports inversion and custom sort handlers.
        local function Compare(Row1, Row2)
            InfoLine:debug("Compare1", Row1.info[Column])
            InfoLine:debug("Compare2", Row2.info[Column])
            local Result

            InfoLine:debug("Inverted", Inverted)
            if Inverted then -- Flip the handler's args
                Result = Handler(Row2.info[Column], Row1.info[Column], Row2, Row1)
            else
                Result = Handler(Row1.info[Column], Row2.info[Column], Row1, Row2)
            end

            if Result ~= nil then -- Not equal
                return Result
            else -- Equal
                return Row1.id < Row2.id -- Fall back on previous row order
            end
        end

        local function OnUpdate(self, ...)
            InfoLine:debug("textTable:OnUpdate", ...)
            self:SetScript("OnUpdate", nil)
            local data = self.data

            if self.sortColumn and #data > 0 then
                Column = self.sortColumn:GetID()
                InfoLine:debug("Header_OnClick", Column, ...)


                Inverted = self.sortInverted
                Handler = data.header.sort[Column]
                if Handler == true then
                    Handler = SortSimple -- Less-than operator
                end

                _G.sort(data, Compare)
                UpdateScroll(self.scrollArea)
            end
        end

        function TextTableCellPrototype:SetSort(header, inverted)
            InfoLine:debug("CellProto:SetSort", header:GetID(), inverted)
            local textTable = self.textTable
            if textTable.sortColumn ~= header then
                textTable.sortColumn, textTable.sortInverted = header, inverted or false

                if header then
                    textTable:SetScript("OnUpdate", OnUpdate)
                end
            elseif header then -- Selected same sort column
                if inverted == nil then -- Unspecified, flip inverted status
                    inverted = not textTable.sortInverted
                end

                textTable.sortInverted = inverted
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
                textTable.rows[index] = row
                prev = row
            end

            self.textTable = textTable
        end
    end

    function TextTableCellPrototype:SetupCell(tooltip, data, justification, font, r, g, b)
        InfoLine:debug("CellProto:SetupCell")
        local textTable = self.textTable
        local width = TABLE_WIDTH
        textTable.data = data

        local flex, filler = {}
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

                header.text = header:CreateFontString(nil, "ARTWORK", "RealUIFont_Header")
                header.text:SetAllPoints()

                header:SetScript("OnClick", function(btn)
                    _G.PlaySound("igMainMenuOptionCheckBoxOn")
                    self:SetSort(btn)
                end)

                header.textTable = textTable
                headerRow[col] = header
            end
            header.text:SetText(headerData.info[col])
            header.text:SetJustifyH(headerData.justify[col])

            local size = headerData.size[col]
            if size == "FIT" then
                local cellWidth = header.text:GetStringWidth()
                testCell:SetFontObject("RealUIFont_Normal")
                for i = 1, #data do
                    testCell:SetText(data[i].info[col])
                    local newWidth = testCell:GetStringWidth()
                    if newWidth > cellWidth then cellWidth = newWidth end
                end
                header:SetWidth(cellWidth)
                width = width - cellWidth
            elseif size == "FILL" then
                filler = header
            else
                flex[header] = size
            end
            InfoLine:debug("Width", col, width)
        end
        local remainingWidth = width
        for header, size in next, flex do
            local headerWidth = _G.max(width * size, header.text:GetStringWidth())
            remainingWidth = remainingWidth - headerWidth
            header:SetWidth(headerWidth)
            InfoLine:debug("Width", headerWidth, remainingWidth)
        end
        filler:SetWidth(_G.max(remainingWidth, filler.text:GetStringWidth()))

        InfoLine:debug("Sort", textTable.sortColumn, textTable.sortInverted)
        if textTable.sortColumn then
            self:SetSort(textTable.sortColumn, textTable.sortInverted)
        end

        if data.rowOnClick then
            self:SetRowOnClick(data.rowOnClick)
        end

        local cellHeight = UpdateScroll(textTable.scrollArea)
        textTable:Show()

        return TABLE_WIDTH, cellHeight + 11
    end

    function TextTableCellPrototype:ReleaseCell()
        InfoLine:debug("CellProto:ReleaseCell")
        if self.textTable then
            self.textTable:Hide()
        end
    end

    function TextTableCellPrototype:getContentHeight()
        InfoLine:debug("CellProto:getContentHeight")
        return self.textTable:GetHeight()
    end
end


--[[
do -- template
    LDB:NewDataObject("test", {
        name = "Test",
        type = "RealUI",
        label = fa["group"],
        labelFont = {fa.path, labelHeight, "OUTLINE"},
        text = "TEST 1 test",
        value = 1,
        suffix = "test",
    })
end
--]]

function InfoLine:CreateBlocks()
    local dbc = InfoLine.db.char
    local labelHeight = InfoLine.barHeight * .6

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
            label = fa["bars"],
            labelFont = {fa.path, labelHeight, "OUTLINE"},
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
        local function setTimeOptions(block)
            block.isMilitary = _G.GetCVar("timeMgrUseMilitaryTime") == "1"
            block.isLocal = _G.GetCVar("timeMgrUseLocalTime") == "1"
        end

        LDB:NewDataObject("clock", {
            name = _G.TIMEMANAGER_TITLE,
            type = "RealUI",
            text = 1,
            value = 1,
            suffix = "",
            OnClick = function(block, ...)
                InfoLine:debug("Clock: OnClick", block.side, ...)
                if _G.IsShiftKeyDown() then
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
                block.tooltip = tooltip
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

                tooltip:SmartAnchorTo(block)
                tooltip:SetAutoHideDelay(0.10, block)

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                --InfoLine:debug("Clock: OnEvent", event, ...)
                if event then
                    if event == "PLAYER_ENTERING_WORLD" then
                        block.alert = _G.CreateFrame("Frame", nil, block, "MicroButtonAlertTemplate")
                        InfoLine:ScheduleRepeatingTimer(block.dataObj.OnEvent, 1, block)
                        _G.hooksecurefunc("TimeManager_ToggleTimeFormat", setTimeOptions)
                        _G.hooksecurefunc("TimeManager_ToggleLocalTime", setTimeOptions)
                        setTimeOptions(block)
                    end
                    local alert = block.alert
                    block.invites = _G.CalendarGetNumPendingInvites()
                    if block.invites > 0 and not alert.isHidden then
                        alert:SetSize(177, alert.Text:GetHeight() + 42);
                        alert:SetPoint("BOTTOMRIGHT", block, "TOPRIGHT", 0, 18)
                        alert.Arrow:SetPoint("TOPRIGHT", alert, "BOTTOMRIGHT", -30, 4)
                        alert.CloseButton:SetScript("OnClick", function(btn)
                            alert:Hide()
                            alert.isHidden = true
                        end)
                        alert.Text:SetText(_G.GAMETIME_TOOLTIP_CALENDAR_INVITES)
                        alert.Text:SetWidth(145)
                        alert:Show()
                        alert.isHidden = false
                    else
                        alert:Hide()
                    end
                end
                local timeFormat, hour, min, suffix = RetrieveTime(block.isMilitary, block.isLocal)
                block.dataObj.value = timeFormat:format(hour, min)
                block.dataObj.suffix = suffix
            end,
            events = {
                "CALENDAR_UPDATE_EVENT_LIST",
                "PLAYER_ENTERING_WORLD",
            },
        })
    end

    --[[ Left ]]--

    do  -- Guild Roster
        local inlineTexture = [[|T%s:14:14:0:0:16:16:0:16:0:16|t]];
        local RemoteChatStatus = {
            [0] = [[|TInterface\ChatFrame\UI-ChatIcon-ArmoryChat:14:14:0:0:16:16:0:16:0:16:74:176:74|t]],
            [1] = inlineTexture:format([[Interface\ChatFrame\UI-ChatIcon-ArmoryChat-AwayMobile]]),
            [2] = inlineTexture:format([[Interface\ChatFrame\UI-ChatIcon-ArmoryChat-BusyMobile]]),
        }
        local PlayerStatus = {
            [1] = inlineTexture:format(_G.FRIENDS_TEXTURE_AFK),
            [2] = inlineTexture:format(_G.FRIENDS_TEXTURE_DND),
        }

        local nameMatch = [=[[|T]*(.*)[|t]*|cff%x%x%x%x%x%x(.*)|r]=]
        local NameSort do

            function NameSort(Val1, Val2)
                local icon1, icon2
                InfoLine:debug("NameSort", _G.strsplit("|", Val1))
                icon1, Val1 = Val1:match(nameMatch)
                icon2, Val2 = Val2:match(nameMatch)
                InfoLine:debug("Player1", icon1, Val1)
                InfoLine:debug("Player2", icon2, Val2)

                icon1 = (icon1:find("ArmoryChat") or icon1:find("StatusIcon"))
                icon2 = (icon2:find("ArmoryChat") or icon2:find("StatusIcon"))
                if icon1 ~= icon2 then
                    if icon1 and not icon2 then
                        return true
                    elseif not icon1 and icon2 then
                        return false
                    end
                elseif Val1 ~= Val2 then
                    return Val1 < Val2
                end
            end
        end
        local RankSort do
            local rankTable = {}
            for i = 1, _G.GuildControlGetNumRanks() do
                rankTable[_G.GuildControlGetRankName(i)] = i
            end

            function RankSort(Val1, Val2)
                if Val1 ~= Val2 then
                    return rankTable[Val1] < rankTable[Val2]
                end
            end
        end
        local NoteSort do
            function NoteSort(Val1, Val2)
                if Val1 and Val2 then
                    if Val1 ~= Val2 then
                        return Val1 < Val2
                    end
                else
                    if Val1 and not Val2 then
                        return true
                    elseif not Val1 and Val2 then
                        return false
                    end
                end
            end
        end

        local function Guild_OnClick(row, ...)
            local _, name = row[1]:GetText():match(nameMatch)
            if not name then return end

            if _G.IsAltKeyDown() then
                _G.InviteUnit(name)
            else
                _G.SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
            end
        end

        local time = _G.GetTime()
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
                "FILL", "FIT", 0.2, "FIT", 0.2, 0.3
            }
        }

        LDB:NewDataObject("guild", {
            name = _G.GUILD,
            type = "RealUI",
            label = fa["group"],
            labelFont = {fa.path, labelHeight, "OUTLINE"},
            text = 1,
            value = 1,
            suffix = "",
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
                local r, g, b = RealUI.classColor[1], RealUI.classColor[2], RealUI.classColor[3]
                tooltip:SetHighlightTexture(r, g, b, 0.2)
                local lineNum, colNum

                local gname = _G.GetGuildInfo("player")
                tooltip:AddHeader(gname)


                local motd = _G.GetGuildRosterMOTD()
                if motd ~= "" then
                    lineNum, colNum = tooltip:AddLine()
                    tooltip:SetCell(lineNum, colNum, motd, nil, "LEFT", nil, nil, nil, nil, TABLE_WIDTH)
                end

                _G.table.wipe(guildData)
                guildData.header = headerData
                guildData.rowOnClick = Guild_OnClick
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

                        --[[ Mouse functions
                        tooltip:SetLineScript(lineNum, "OnMouseDown", function(...)
                            InfoLine:debug("Guild: OnMouseDown", self.side, ...)
                            if not name then return end
                            if IsAltKeyDown() then
                                InviteUnit(name)
                            else
                                SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
                            end
                        end)]]
                        if note == "" then note = nil end
                        if offnote == "" then offnote = nil end

                        _G.tinsert(guildData, {
                            id = i,
                            info = {
                                name, lvl, zone, rank, note, offnote
                            }
                        })
                    end
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, guildData, TextTableCellProvider)

                lineNum = tooltip:AddLine(L["Guild_WhisperInvite"])
                tooltip:SetLineTextColor(lineNum, 0, 1, 0)

                tooltip:SmartAnchorTo(block)
                tooltip:SetAutoHideDelay(0.10, block)

                tooltip:Show()
                block.tooltip = tooltip
            end,
            OnEvent = function(block, event, ...)
                InfoLine:debug("Guild: OnEvent", event, ...)
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
            label = fa["heartbeat"],
            labelFont = {fa.path, labelHeight, "OUTLINE"},
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
                block.tooltip = tooltip
                local lineNum, colNum

                lineNum, colNum = tooltip:AddHeader()
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

                tooltip:SmartAnchorTo(block)
                tooltip:SetAutoHideDelay(0.10, block)

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
                    alert:SetSize(177, alert.Text:GetHeight() + 42);
                    alert.Arrow:SetPoint("TOP", alert, "BOTTOM", -30, 4)
                    alert:SetPoint("BOTTOM", block, "TOP", 30, 18)
                    alert.CloseButton:SetScript("OnClick", function(btn)
                        alert:Hide()
                        alert.isHidden = true
                    end);
                    alert.Text:SetFormattedText("%s %d%%", _G.DURABILITY, round(lowDur * 100))
                    alert.Text:SetWidth(145);
                    alert:Show();
                    alert.isHidden = false
                else
                    alert:Hide()
                end
                block.dataObj.text = round(lowDur * 100) .. "%"
                block.dataObj.labelR, block.dataObj.labelG, block.dataObj.labelB = RealUI.GetDurabilityColor(lowMin, lowMax)
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
        local watchStates = {}
        watchStates = {
            { -- xp
                GetNext = function(XP)
                    if watchStates[2]:IsValid() then
                        return 2, "rep"
                    elseif watchStates[3]:IsValid() then
                        return 3, "artifact"
                    elseif watchStates[4]:IsValid() then
                        return 4, "honor"
                    elseif watchStates[1]:IsValid() then
                        return 1, "xp"
                    else
                        return nil
                    end
                end,
                GetStats = function(XP)
                    return _G.UnitXP("player"), _G.UnitXPMax("player"), _G.GetXPExhaustion() or 0
                end,
                GetColor = function(XP)
                    if _G.GetRestState() == 1 then
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
            },
            { -- rep
                hint = L["Progress_OpenRep"],
                GetNext = function(Rep)
                    if watchStates[3]:IsValid() then
                        return 3, "artifact"
                    elseif watchStates[4]:IsValid() then
                        return 4, "honor"
                    elseif watchStates[1]:IsValid() then
                        return 1, "xp"
                    elseif watchStates[2]:IsValid() then
                        return 2, "rep"
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
                    local color = _G.FACTION_BAR_COLORS[reaction];
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
            },
            { -- artifact
                hint = L["Progress_OpenArt"],
                GetNext = function(Art)
                    if watchStates[4]:IsValid() then
                        return 4, "honor"
                    else
                        return 1, "xp"
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
                    local activeArtifact = artData:GetActiveArtifactID()
                    -- After a spec switch, the active artifact could be invalid
                    if artData:GetNumObtainedArtifacts() ~= _G.C_ArtifactUI.GetNumObtainedArtifacts() and not activeArtifact then
                        -- async timer to prevent stack overflow
                        _G.C_Timer.After(2, artData.ForceUpdate)
                    end
                    return not not activeArtifact
                end,
                SetTooltip = function(Art, tooltip)
                    local hasArtifact, artifact = artData:GetArtifactInfo()

                    if hasArtifact then
                        testCell:SetFontObject("GameTooltipText")
                        testCell:SetText(artifact.name)
                        local maxWidth = testCell:GetStringWidth()

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
            },
            { -- honor
                hint = L["Progress_OpenHonor"],
                GetNext = function(Honor)
                    if watchStates[2]:IsValid() then
                        return 2, "rep"
                    elseif watchStates[3]:IsValid() then
                        return 3, "artifact"
                    elseif watchStates[4]:IsValid() then
                        return 4, "honor"
                    else
                        return nil
                    end
                end,
                GetStats = function(Honor)
                    return _G.UnitHonor("player"), _G.UnitHonorMax("player")
                end,
                GetColor = function(Honor)
                    if _G.GetHonorRestState() == 1 then
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
            },
        }

        local function UpdateProgress(block)
            local curValue, maxValue = watchStates[dbc.progressState]:GetStats()
            block.dataObj.text = round(curValue / maxValue, 3) * 100 .. "%"

            local watch = InfoLine.frame.watch
            InfoLine:debug("progress:main", dbc.progressState, curValue, maxValue)
            local r, g, b = watchStates[dbc.progressState]:GetColor()
            watch.main:SetStatusBarColor(r, g, b, 0.5)
            watch.main:SetMinMaxValues(0, maxValue)
            watch.main:SetValue(curValue)
            watch.main:Show()

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
                UpdateProgress(block)
            else
                InfoLine:RemoveBlock(block.name, block.dataObj, block)
            end
        end

        LDB:NewDataObject("progress", {
            name = L["Progress"],
            type = "RealUI",
            text = "XP",
            OnEnable = function(block)
                InfoLine:debug("progress: OnEnable", block.side)
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
                block.tooltip = tooltip
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
                tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

                tooltip:SmartAnchorTo(block)
                tooltip:SetAutoHideDelay(0.10, block)

                tooltip:Show()
            end,
            OnEvent = function(block, ...)
                InfoLine:debug("progress: OnEvent", block.side, ...)
                UpdateProgress(block)
            end,
            events = {
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

    -- Currency


    --[[ Right ]]--
    -- Mail

    -- Bag space

    -- Layout

    -- Specialization

    -- FPS/Ping
end
