local _, private = ...

-- Lua Globals --
local _G = _G
local ipairs = _G.ipairs

-- Libs --
local LDB = _G.LibStub("LibDataBroker-1.1")
local qTip = _G.LibStub("LibQTip-1.0")
local LTT = _G.LibStub("LibTextTable-1.1")
local LIF = _G.LibStub("LibIconFonts-1.0")
local octicons = LIF:GetIconFont("octicons", "v2.x")
octicons.path = [[Interface\AddOns\nibRealUI\Fonts\Octicons\octicons-local.ttf]]

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local L = RealUI.L
local ndb

local MODNAME = "InfoLine"
local InfoLine = RealUI:GetModule(MODNAME)

local MAX_ROWS = 11
local TextTableCellProvider, TextTableCellPrototype = qTip:CreateCellProvider()
function TextTableCellPrototype:InitializeCell()
    InfoLine:debug("CellProto:InitializeCell")

    if not self.textTable then
        local textTable = LTT.New(nil, self, "RealUIFont_Crit", "RealUIFont_Normal")
        textTable:SetPoint("TOPLEFT", self, "TOPLEFT")
        textTable:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT")

        self.textTable = textTable
    end
end

function TextTableCellPrototype:SetupCell(tooltip, data, justification, font, r, g, b)
    InfoLine:debug("CellProto:SetupCell")
    local textTable = self.textTable
    for rowIndex, rowData in ipairs(data) do
        InfoLine:debug(rowIndex, rowData.type, _G.unpack(rowData.info))
        if rowData.type == "header" then
            textTable:SetHeader(_G.unpack(rowData.info))
            textTable:SetSortHandlers(_G.unpack(rowData.sort))
            textTable:SetSortColumn(1)
        else
            textTable:AddRow(nil, _G.unpack(rowData.info))
        end
    end
    textTable:Resize()
    textTable:Show()

    local heightMod = #data <= MAX_ROWS and #data or MAX_ROWS
    return 200, textTable.Header:GetHeight() * heightMod + 4
end

function TextTableCellPrototype:ReleaseCell()
    InfoLine:debug("CellProto:ReleaseCell")
    if self.textTable then
        self.textTable:Clear()
        self.textTable:Hide()
    end
end

function TextTableCellPrototype:getContentHeight()
    InfoLine:debug("CellProto:getContentHeight")
    return self.textTable:GetHeight()
end


--[[ 
do -- template 
    blocks["test"] = {
        type = "RealUI",
        text = "TEST 1 test",
        value = 1,
        suffix = "test",
        label = "TEST"
        icon = Icons[layoutSize].guild
    }
end
]]

--[=[]=]
function InfoLine:CreateBlocks()
    ndb = RealUI.db.profile

    --[[ Left ]]--
    do  -- Start
        local startMenu = _G.CreateFrame("Frame", "RealUIStartDropDown", _G.UIParent, "UIDropDownMenuTemplate")
        local menuList = {
            {text = L["Start_Config"],
                func = function() RealUI:LoadConfig("HuD") end,
                notCheckable = true,
            },
            {text = L["Power_PowerMode"],
                notCheckable = true,
                hasArrow = true,
                menuList = {
                    {
                        text = L["Power_Eco"],
                        tooltipTitle = L["Power_Eco"],
                        tooltipText = L["Power_EcoDesc"],
                        tooltipOnButton = 1,
                        func = function() 
                            RealUI:SetPowerMode(2)
                            RealUI:ReloadUIDialog()
                        end,
                        checked = function() return ndb.settings.powerMode == 2 end,
                    },
                    {
                        text = L["Power_Normal"],
                        tooltipTitle = L["Power_Normal"],
                        tooltipText = L["Power_NormalDesc"],
                        tooltipOnButton = 1,
                        func = function()
                            RealUI:SetPowerMode(1)
                            RealUI:ReloadUIDialog()
                        end,
                        checked = function() return ndb.settings.powerMode == 1 end,
                    },
                    {
                        text = L["Power_Turbo"],
                        tooltipTitle = L["Power_Turbo"],
                        tooltipText = L["Power_TurboDesc"],
                        tooltipOnButton = 1,
                        func = function()
                            RealUI:SetPowerMode(3)
                            RealUI:ReloadUIDialog()
                        end,
                        checked = function() return ndb.settings.powerMode == 3 end,
                    },
                },
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

        LDB:NewDataObject(L["Start"], {
            type = "RealUI",
            text = L["Start"],
            side = "left",
            index = 1,
            OnClick = function(block, ...)
                InfoLine:debug("Start: OnClick", block.side, ...)
            end,
            OnEnter = function(block, ...)
                InfoLine:debug("Start: OnEnter", block.side, ...)
                _G.EasyMenu(menuList, startMenu, block, 0, 0, "MENU", 2)
            end,
            OnLeave = function(block, ...)
                InfoLine:debug("Start: OnLeave", block.side, ...)
                --CloseDropDownMenus()
            end,
        })
        _G.UIDropDownMenu_SetAnchor(startMenu, 0, 0, "BOTTOMLEFT", InfoLine.frame, "TOPLEFT")
    end

    -- Mail

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

        local NameSort do
            local nameMatch = [[.*[|t]*|cff%x%x%x%x%x%x(.*)]]
            
            function NameSort(Val1, Val2)
                InfoLine:debug("NameSort", _G.strsplit("|", Val1))
                Val1 = Val1:match(nameMatch)
                Val2 = Val2:match(nameMatch)
                InfoLine:debug("match", Val1, Val2)
                if Val1 ~= Val2 then
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

        local time = _G.GetTime()
        LDB:NewDataObject(_G.GUILD, {
            type = "RealUI",
            label = octicons["organization"],
            labelFont = {octicons.path, InfoLine.barHeight * .6, "OUTLINE"},
            text = 1,
            value = 1,
            suffix = "",
            side = "left",
            index = 2,
            OnClick = function(block, ...)
                --InfoLine:debug("Guild: OnClick", block.side, ...)
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

                local gmotd = _G.GetGuildRosterMOTD()
                if gmotd ~= "" then
                    lineNum, colNum = tooltip:AddLine(gmotd)
                    tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)
                end

                local color = RealUI.media.colors.orange
                local guildData = {}
                guildData[1] = {type = "header",
                    r = color[1], g = color[2], b = color[3],
                    sort = {
                        NameSort, true, true, RankSort, true, true
                    },
                    info = {
                        _G.NAME, _G.LEVEL_ABBR, _G.ZONE, _G.RANK, _G.LABEL_NOTE, _G.OFFICER_NOTE_COLON
                    }
                }
                self:debug(guildData[1].info[1], guildData[1].info[2], guildData[1].info[3], guildData[1].info[4])
                
                for i = 1, _G.GetNumGuildMembers() do
                    local name, rank, _, lvl, _, zone, note, offnote, isOnline, status, class, _, _, isMobile = _G.GetGuildRosterInfo(i)
                    if isOnline or isMobile then
                        -- Remove server from name
                        name = _G.Ambiguate(name, "guild")

                        -- Class color names
                        color = RealUI:GetClassColor(class, "hex")
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

                        _G.tinsert(guildData, {type = "row",
                            r = color[1], g = color[2], b = color[3],
                            info = {
                                name, lvl, zone, rank, note, offnote
                            }
                        })
                    end
                end

                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, guildData, TextTableCellProvider)

                lineNum, colNum = tooltip:AddLine(L["Guild_WhisperInvite"])
                tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

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

        LDB:NewDataObject(_G.DURABILITY, {
            type = "RealUI",
            text = 1,
            side = "left",
            index = 3,
            OnClick = function(block, ...)
                InfoLine:debug("Durability: OnClick", block.side, ...)
                if not _G.InCombatLockdown() then
                    _G.ToggleCharacter("PaperDollFrame")
                end
            end,
            OnEnter = function(block, ...)
                if qTip:IsAcquired(block) then return end
                InfoLine:debug("Durability: OnEnter", block.side, ...)

                local tooltip = qTip:Acquire(block, 2, "LEFT", "RIGHT")
                block.tooltip = tooltip
                local lineNum, colNum

                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetCell(lineNum, colNum, _G.DURABILITY, nil, 2)

                for slotID = 1, #itemSlots do
                    local item = itemSlots[slotID]
                    if item.hasDura and item.dura then
                        tooltip:AddLine(item.slot, round(item.dura * 100) .. "%")
                    end
                end

                tooltip:SmartAnchorTo(block)
                tooltip:SetAutoHideDelay(0.10, block)

                tooltip:Show()
            end,
            OnEvent = function(block, event, ...)
                InfoLine:debug("Durability1: OnEvent", event, block.timer, ...)
                if event == "UPDATE_INVENTORY_DURABILITY" then
                    if block.timer then return end
                    InfoLine:debug("Make timer")
                    block.timer = InfoLine:ScheduleTimer(block.dataObj.OnEvent, 1, block)
                    return
                end
                InfoLine:debug("Durability2: OnEvent", event, block.timer, ...)
                local lowest = 1
                for slotID = 1, #itemSlots do
                    local item = itemSlots[slotID]
                    if item.hasDura then
                        local min, max = _G.GetInventoryItemDurability(slotID)
                        if max then
                            local per = RealUI:GetSafeVals(min, max)
                            item.dura = per
                            lowest = per < lowest and per or lowest
                            InfoLine:debug(slotID, item.slot, round(per, 3), round(lowest, 3))
                        end
                    end
                end
                if not block.alert then
                    block.alert = _G.CreateFrame("Frame", nil, block, "MicroButtonAlertTemplate")
                end
                local alert = block.alert
                if lowest < 0.1 and not alert.isHidden then
                    alert:SetSize(177, alert.Text:GetHeight() + 42);
                    alert.Arrow:SetPoint("TOP", alert, "BOTTOM", -30, 4)
                    alert:SetPoint("BOTTOM", block, "TOP", 30, 18)
                    alert.CloseButton:SetScript("OnClick", function(btn)
                        alert:Hide()
                        alert.isHidden = true
                    end);
                    alert.Text:SetFormattedText("%s %d%%", _G.DURABILITY, lowest)
                    alert.Text:SetWidth(145);
                    alert:Show();
                    alert.isHidden = false
                else
                    alert:Hide()
                end
                block.dataObj.text = round(lowest * 100) .. "%"
                block.timer = false
            end,
            events = {
                "UPDATE_INVENTORY_DURABILITY",
                "PLAYER_ENTERING_WORLD",
            },
        })
    end

    -- Bag space

    -- Currency


    --[[ Right ]]--
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

        LDB:NewDataObject(_G.TIMEMANAGER_TITLE, {
            type = "RealUI",
            text = 1,
            value = 1,
            suffix = "",
            side = "right",
            index = 1,
            OnClick = function(block, ...)
                --InfoLine:debug("Clock: OnClick", block.side, ...)
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

                -- PvP zones
                if _G.UnitLevel("player") >= 90 then
                    tooltip:AddLine(" ")
                    for i = 1, 2 do -- 1 == Wintergrasp, 2 == Tol Barad, 3 == Ashran
                        local _, zone, _, _, startTime = _G.GetWorldPVPAreaInfo(i)
                        if startTime then
                            lineNum = tooltip:AddLine()
                            tooltip:SetCell(lineNum, 1, L["Clock_PvPTime"]:format(zone))
                            tooltip:SetCell(lineNum, 2, _G.format(_G.SecondsToTimeAbbrev(startTime)), "RIGHT", 2)
                        else
                            lineNum = tooltip:AddLine()
                            tooltip:SetCell(lineNum, 1, L["Clock_NoPvPTime"]:format(zone), "LEFT", 2)
                        end
                    end
                end

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

    -- Meters

    -- Layout

    -- Specialization

    -- FPS/Ping
end
