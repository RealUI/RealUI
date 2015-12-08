local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G
local min, max, abs, floor = _G.math.min, _G.math.max, _G.math.abs, _G.math.floor
local next, type = _G.next, _G.type

-- WoW Globals --
local CreateFrame = _G.CreateFrame

-- Libs --
local LDB = LibStub("LibDataBroker-1.1")
local qTip = LibStub("LibQTip-1.0")
local LIF = LibStub("LibIconFonts-1.0")
local octicons = LIF:GetIconFont("octicons", "v2.x")
octicons.path = [[Interface\AddOns\nibRealUI\Fonts\octicons-local.ttf]]

-- RealUI --
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = RealUI.L

local MODNAME = "InfoLine"
local InfoLine = nibRealUI:GetModule(MODNAME)

local round = nibRealUI.Round

--[[ template 
    local test = LDB:NewDataObject("test", {
        type = "RealUI",
        text = "TEST 1 test",
        value = 1,
        suffix = "test",
        label = "TEST"
        icon = Icons[layoutSize].guild
    })
]]

function InfoLine:CreateBlocks(dbc, ndb)
    --[[ Left ]]--
    -- Start
    local startMenu = CreateFrame("Frame", "RealUIStartDropDown", UIParent, "UIDropDownMenuTemplate")
    local menuList = {
        {text = L["Start_Config"],
            func = function() nibRealUI:LoadConfig("HuD") end,
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
                        nibRealUI:SetPowerMode(2)
                        nibRealUI:ReloadUIDialog()
                    end,
                    checked = function() return ndb.settings.powerMode == 2 end,
                },
                {
                    text = L["Power_Normal"],
                    tooltipTitle = L["Power_Normal"],
                    tooltipText = L["Power_NormalDesc"],
                    tooltipOnButton = 1,
                    func = function()
                        nibRealUI:SetPowerMode(1)
                        nibRealUI:ReloadUIDialog()
                    end,
                    checked = function() return ndb.settings.powerMode == 1 end,
                },
                {
                    text = L["Power_Turbo"],
                    tooltipTitle = L["Power_Turbo"],
                    tooltipText = L["Power_TurboDesc"],
                    tooltipOnButton = 1,
                    func = function()
                        nibRealUI:SetPowerMode(3)
                        nibRealUI:ReloadUIDialog()
                    end,
                    checked = function() return ndb.settings.powerMode == 3 end,
                },
            },
        },
        {text = "",
            notCheckable = true,
            disabled = true,
        },
        {text = CHARACTER_BUTTON,
            func = function() ToggleCharacter("PaperDollFrame") end,
            notCheckable = true,
        },
        {text = SPELLBOOK_ABILITIES_BUTTON,
            func = function() ToggleFrame(SpellBookFrame) end,
            notCheckable = true,
        },
        {text = TALENTS_BUTTON,
            func = function() 
                if not PlayerTalentFrame then 
                    TalentFrame_LoadUI()
                end 

                ShowUIPanel(PlayerTalentFrame)
            end,
            notCheckable = true,
            disabled = UnitLevel("player") < SHOW_SPEC_LEVEL,
        },
        {text = ACHIEVEMENT_BUTTON,
            func = function() ToggleAchievementFrame() end,
            notCheckable = true,
        },
        {text = QUESTLOG_BUTTON,
            func = function() ToggleQuestLog() end,
            notCheckable = true,
        },
        {text = IsInGuild() and GUILD or LOOKINGFORGUILD,
            func = function() 
                if IsInGuild() then 
                    if not GuildFrame then GuildFrame_LoadUI() end 
                    GuildFrame_Toggle() 
                else 
                    if not LookingForGuildFrame then LookingForGuildFrame_LoadUI() end 
                    LookingForGuildFrame_Toggle() 
                end
            end,
            notCheckable = true,
            disabled = IsTrialAccount(),
        },
        {text = SOCIAL_BUTTON,
            func = function() ToggleFriendsFrame(1) end,
            notCheckable = true,
        },
        {text = DUNGEONS_BUTTON,
            func = function() PVEFrame_ToggleFrame() end,
            notCheckable = true,
            disabled = UnitLevel("player") < math.min(SHOW_LFD_LEVEL, SHOW_PVP_LEVEL),
        },
        {text = COLLECTIONS,
            func = function() ToggleCollectionsJournal() end,
            notCheckable = true,
        },
        {text = ADVENTURE_JOURNAL,
            func = function() ToggleEncounterJournal() end,
            disabled = UnitLevel("player") < SHOW_EJ_LEVEL,
            notCheckable = true,
        },  
        {text = BLIZZARD_STORE,
            func = function() ToggleStoreUI() end,
            notCheckable = true,
        },
        {text = HELP_BUTTON,
            func = function() ToggleHelpFrame() end,
            notCheckable = true,
        },  
        {text = "",
            notCheckable = true,
            disabled = true,
        },
        {text = CANCEL,
            func = function() CloseDropDownMenus() end,
            notCheckable = true,
        },
    }

    local start = LDB:NewDataObject(L["Start"], {
        type = "RealUI",
        text = L["Start"],
        side = "left",
        index = 1,
        OnClick = function(self, ...)
            InfoLine:debug("Start: OnClick", self.side, ...)
        end,
        OnEnter = function(self, ...)
            InfoLine:debug("Start: OnEnter", self.side, ...)
            EasyMenu(menuList, RealUIStartDropDown, self, 0, 0, "MENU", 2)
        end,
        OnLeave = function(self, ...)
            InfoLine:debug("Start: OnLeave", self.side, ...)
            --CloseDropDownMenus()
        end,
    })
    UIDropDownMenu_SetAnchor(RealUIStartDropDown, 0, 0, "BOTTOMLEFT", InfoLine_Start, "TOPLEFT")

    -- Mail

    -- Guild Roster
    local guild = LDB:NewDataObject(GUILD, {
        type = "RealUI",
        label = octicons["alignment-unalign"],
        labelFont = {octicons.path, InfoLine.barHeight * .6, "OUTLINE"},
        text = 1,
        value = 1,
        suffix = "",
        side = "left",
        index = 2,
        OnClick = function(self, ...)
            --InfoLine:debug("Guild: OnClick", self.side, ...)
            if not InCombatLockdown() then
                ToggleGuildFrame()
            end
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            --InfoLine:debug("Guild: OnEnter", self.side, ...)
            local canOffNote = CanViewOfficerNote()

            local tooltip = qTip:Acquire(self, canOffNote and 6 or 5, "LEFT", "CENTER", "LEFT", "LEFT", "LEFT", canOffNote and "LEFT" or nil)
            local r, g, b = nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3]
            tooltip:SetHighlightTexture(r, g, b, 0.2)
            local lineNum, colNum

            lineNum, colNum = tooltip:AddHeader()
            local gname = GetGuildInfo("player")
            tooltip:SetCell(lineNum, colNum, gname, nil, nil, canOffNote and 6 or 5, nil, nil, nil, 100)

            local gmotd = GetGuildRosterMOTD()
            if gmotd ~= "" then
                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, gmotd, nil, nil, canOffNote and 6 or 5, nil, nil, nil, 500)
            end
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            tooltip:AddLine(" ")

            if canOffNote then
                lineNum, colNum = tooltip:AddHeader(NAME, LEVEL_ABBR, ZONE, RANK, LABEL_NOTE, OFFICER_NOTE_COLON)
            else
                lineNum, colNum = tooltip:AddHeader(NAME, LEVEL_ABBR, ZONE, RANK, LABEL_NOTE)
            end
            local color = nibRealUI.media.colors.orange
            tooltip:SetLineTextColor(lineNum, color[1], color[2], color[3])

            for i = 1, GetNumGuildMembers() do
                local name, rank, _, lvl, _class, zone, note, offnote, isOnline, status, class, _, _, isMobile = GetGuildRosterInfo(i)
                if isOnline or isMobile then
                    -- Remove server from name
                    local displayName = Ambiguate(name, "guild")

                    -- Status tag
                    local curStatus = ""
                    if status > 0 then
                        curStatus = PlayerStatusValToStr[status]
                        displayName = curStatus .. displayName
                    end

                    -- Mobile tag
                    if isMobile and (not isOnline) then
                        displayName = REMOTE_CHAT_ICON .. displayName
                        zone = REMOTE_CHAT
                    end

                    if canOffNote then
                        lineNum, colNum = tooltip:AddLine(displayName, lvl, zone, rank, note, offnote)
                    else
                        lineNum = tooltip:AddLine(displayName, lvl, zone, rank, note)
                    end

                    -- Class color names
                    color = nibRealUI:GetClassColor(class)
                    tooltip:SetCellTextColor(lineNum, 1, color[1], color[2], color[3])

                    -- Difficulty color levels
                    color = GetQuestDifficultyColor(lvl)
                    tooltip:SetCellTextColor(lineNum, 2, color.r, color.g, color.b)

                    -- Mouse functions
                    tooltip:SetLineScript(lineNum, "OnMouseDown", function(...)
                        InfoLine:debug("Guild: OnMouseDown", self.side, ...)
                        if not name then return end
                        if IsAltKeyDown() then
                            InviteUnit(name)
                        else
                            SetItemRef("player:"..name, "|Hplayer:"..name.."|h["..name.."|h", "LeftButton")
                        end
                    end)
                end
            end

            tooltip:AddLine(" ")

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, colNum, L["Guild_WhisperInvite"], nil, nil, canOffNote and 6 or 5, nil, nil, nil, 500)
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
            self.tooltip = tooltip
        end,
        OnEvent = function(self, event, ...)
            --InfoLine:debug("Guild: OnEvent", event, ...)
            local _, online, onlineAndMobile = GetNumGuildMembers()
            self.dataObj.value = online
            if online == onlineAndMobile then
                self.dataObj.suffix = ""
            else
                self.dataObj.suffix = "(".. onlineAndMobile - online ..")"
            end
            InfoLine:UpdateElementWidth(self)
        end,
        events = {
            "GUILD_ROSTER_UPDATE",
            "GUILD_MOTD",
        },
    })

    -- Friends

    -- Durability
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
    local dura = LDB:NewDataObject(DURABILITY, {
        type = "RealUI",
        text = 1,
        side = "left",
        index = 3,
        OnClick = function(self, ...)
            InfoLine:debug("Durability: OnClick", self.side, ...)
            if not InCombatLockdown() then
                ToggleCharacter("PaperDollFrame")
            end
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            InfoLine:debug("Durability: OnEnter", self.side, ...)

            local tooltip = qTip:Acquire(self, 2, "LEFT", "RIGHT")
            self.tooltip = tooltip
            local lineNum, colNum

            lineNum, colNum = tooltip:AddHeader()
            tooltip:SetCell(lineNum, colNum, DURABILITY, nil, 2)

            for slotID = 1, #itemSlots do
                local item = itemSlots[slotID]
                if item.hasDura and item.dura then
                    tooltip:AddLine(item.slot, round(item.dura * 100) .. "%")
                end
            end

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
        end,
        OnEvent = function(self, event, ...)
            InfoLine:debug("Durability1: OnEvent", event, self.timer, ...)
            if event == "UPDATE_INVENTORY_DURABILITY" then
                if self.timer then return end
                InfoLine:debug("Make timer")
                self.timer = InfoLine:ScheduleTimer(self.dataObj.OnEvent, 1, self)
                return
            end
            InfoLine:debug("Durability2: OnEvent", event, self.timer, ...)
            local lowest = 1
            for slotID = 1, #itemSlots do
                local item = itemSlots[slotID]
                if item.hasDura then
                    local min, max = GetInventoryItemDurability(slotID)
                    if max then
                        local per = nibRealUI:GetSafeVals(min, max)
                        item.dura = per
                        lowest = per < lowest and per or lowest
                        InfoLine:debug(slotID, item.slot, round(per, 3), round(lowest, 3))
                    end
                end
            end
            if not self.alert then
                self.alert = CreateFrame("Frame", nil, self, "MicroButtonAlertTemplate")
            end
            local alert = self.alert
            if lowest < 0.1 and not alert.isHidden then
                alert:SetSize(177, alert.Text:GetHeight() + 42);
                alert.Arrow:SetPoint("TOP", alert, "BOTTOM", -30, 4)
                alert:SetPoint("BOTTOM", self, "TOP", 30, 18)
                alert.CloseButton:SetScript("OnClick", function(self)
                    alert:Hide()
                    alert.isHidden = true
                end);
                alert.Text:SetFormattedText("%s %d%%", DURABILITY, lowest)
                alert.Text:SetWidth(145);
                alert:Show();
                alert.isHidden = false
            else
                alert:Hide()
            end
            self.dataObj.text = round(lowest * 100) .. "%"
            self.timer = false
            InfoLine:UpdateElementWidth(self)
        end,
        events = {
            "UPDATE_INVENTORY_DURABILITY",
            "PLAYER_ENTERING_WORLD",
        },
    })

    -- Bag space

    -- Currency

    -- Progress Watch
    local watch = LDB:NewDataObject(L["XPRep"], {
        type = "RealUI",
        label = XP,
        text = 1,
        value = 1,
        suffix = "",
        side = "left",
        index = 4,
        OnClick = function(self, ...)
            InfoLine:debug("XP / Rep: OnClick", self.side, ...)
            dbc.xrstate = (dbc.xrstate == "x") and "r" or "x"
            if UnitLevel("player") == MAX_PLAYER_LEVEL and not InCombatLockdown() then
                ToggleCharacter("ReputationFrame")
            end
            self.dataObj.OnEvent(self, "OnClick", ...)
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            InfoLine:debug("XP / Rep: OnEnter", self.side, ...)

            local tooltip = qTip:Acquire(self, 2, "LEFT", "RIGHT")
            self.tooltip = tooltip
            local lineNum, colNum

            -- XP
            if UnitLevel("player") < MAX_PLAYER_LEVEL then
                local xpCurr, xpMax = UnitXP("player"), UnitXPMax("player")
                local xpRest = GetXPExhaustion() or 0

                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetCell(lineNum, colNum, EXPERIENCE_COLON, nil, 2)

                lineNum, colNum = tooltip:AddLine(L["XPRep_Current"], nibRealUI:ReadableNumber(xpCurr))
                if IsXPUserDisabled() then
                    tooltip:SetCellTextColor(lineNum, 2, 0.5, 0.5, 0.5)
                end

                lineNum, colNum = tooltip:AddLine(L["XPRep_Remaining"], nibRealUI:ReadableNumber(xpMax - xpCurr))
                if IsXPUserDisabled() then
                    tooltip:SetCellTextColor(lineNum, 2, 0.5, 0.5, 0.5)
                end

                lineNum, colNum = tooltip:AddLine(TUTORIAL_TITLE26, nibRealUI:ReadableNumber(xpRest))
                tooltip:AddLine(" ")
            end

            -- Rep
            local name, standing, repMin, repMax, value, factionID = GetWatchedFactionInfo()

            lineNum, colNum = tooltip:AddHeader()
            tooltip:SetCell(lineNum, colNum, REPUTATION..":", nil, 2)

            tooltip:AddLine(FACTION, name or "None Selected")
            if name then
                lineNum, colNum = tooltip:AddLine(STATUS, _G["FACTION_STANDING_LABEL"..standing])
                tooltip:SetCellTextColor(lineNum, 2, FACTION_BAR_COLORS[standing].r, FACTION_BAR_COLORS[standing].g, FACTION_BAR_COLORS[standing].b)
                tooltip:AddLine(L["XPRep_Current"], nibRealUI:ReadableNumber(value - repMin))
                tooltip:AddLine(L["XPRep_Remaining"], nibRealUI:ReadableNumber(repMax - (value - repMin)))
            end

            tooltip:AddLine(" ")

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, 1, L["XPRep_Toggle"], nil, 2)
            tooltip:SetCellTextColor(lineNum, 1, 0, 1, 0)

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
        end,
        OnEvent = function(self, event, ...)
            InfoLine:debug("XP / Rep: OnEvent", event, ...)
            local isMaxLvl = (UnitLevel("player") == MAX_PLAYER_LEVEL)
            if ( (dbc.xrstate == "x") and not isMaxLvl and not (IsXPUserDisabled()) ) then
                local xpPer, _, xpMax = nibRealUI:GetSafeVals(UnitXP("player"), UnitXPMax("player"))
                local xpRest = nibRealUI:GetSafeVals(GetXPExhaustion() or 0, xpMax)

                self.dataObj.label = XP
                self.dataObj.value = round(xpPer * 100) .. "%"
                if xpRest > 0 then
                    self.dataObj.suffix = "(".. round(xpRest * 100) .. "%)"
                else
                    self.dataObj.suffix = ""
                end
            else
                dbc.xrstate = "r"
                local name, standing, repMin, repMax, value, factionID = GetWatchedFactionInfo()
                local repPer = nibRealUI:GetSafeVals((value - repMin), repMax)

                self.dataObj.label = "Rep"
                if name then
                    self.dataObj.value = round(repPer * 100) .. "%"
                else
                    self.dataObj.value = "---"
                end
                self.dataObj.suffix = ""
            end
            InfoLine:UpdateElementWidth(self)
        end,
        events = {
            "PLAYER_XP_UPDATE",
            "DISABLE_XP_GAIN",
            "ENABLE_XP_GAIN",
            "UPDATE_FACTION",
            "PLAYER_ENTERING_WORLD",
        },
    })

    --[[ Right ]]--
    -- Clock
    local function RetrieveTime(isMilitary, isLocal)
        local timeFormat, hour, min, suffix
        if isLocal then
            hour, min = tonumber(date("%H")), tonumber(date("%M"))
        else
            hour, min = GetGameTime()
        end
        if isMilitary then
            timeFormat = TIMEMANAGER_TICKER_24HOUR
            suffix = ""
        else
            timeFormat = TIMEMANAGER_TICKER_12HOUR
            if hour >= 12 then 
                suffix = TIMEMANAGER_PM
                if hour > 12 then
                    hour = hour - 12
                end
            else
                suffix = TIMEMANAGER_AM
                if hour == 0 then
                    hour = 12
                end
            end
        end
        return timeFormat, hour, min, suffix
    end
    local function setTimeOptions(self)
        self.isMilitary = GetCVar("timeMgrUseMilitaryTime") == "1"
        self.isLocal = GetCVar("timeMgrUseLocalTime") == "1"
    end
    local clock = LDB:NewDataObject(TIMEMANAGER_TITLE, {
        type = "RealUI",
        text = 1,
        value = 1,
        suffix = "",
        side = "right",
        index = 1,
        OnClick = function(self, ...)
            --InfoLine:debug("Clock: OnClick", self.side, ...)
            if IsShiftKeyDown() then
                ToggleTimeManager()
            else
                if IsAddOnLoaded("GroupCalendar5") then
                    if GroupCalendar.UI.Window:IsShown() then
                        HideUIPanel(GroupCalendar.UI.Window)
                    else
                        ShowUIPanel(GroupCalendar.UI.Window)
                    end
                else
                    ToggleCalendar()
                end
            end
        end,
        OnEnter = function(self, ...)
            if qTip:IsAcquired(self) then return end
            --InfoLine:debug("Clock: OnEnter", self.side, ...)

            local tooltip = qTip:Acquire(self, 3, "LEFT", "CENTER", "RIGHT")
            self.tooltip = tooltip
            local lineNum, colNum

            lineNum, colNum = tooltip:AddHeader(TIMEMANAGER_TOOLTIP_TITLE)
            --tooltip:SetCell(lineNum, colNum, , nil, 2)

            -- Realm time
            local timeFormat, hour, min, suffix = RetrieveTime(self.isMilitary, false)
            tooltip:AddLine(TIMEMANAGER_TOOLTIP_REALMTIME, " ", timeFormat:format(hour, min) .. " " .. suffix)

            -- Local time
            timeFormat, hour, min, suffix = RetrieveTime(self.isMilitary, true)
            tooltip:AddLine(TIMEMANAGER_TOOLTIP_LOCALTIME, " ", timeFormat:format(hour, min) .. " " .. suffix)

            -- Date
            lineNum, colNum = tooltip:AddLine() --L["Clock_Date"], date("%b %d (%a)"))
            tooltip:SetCell(lineNum, 1, L["Clock_Date"])
            tooltip:SetCell(lineNum, 2, date("%b %d (%a)"), "RIGHT", 2)

            -- PvP zones
            if UnitLevel("player") >= 90 then
                tooltip:AddLine(" ")
                for i = 1, 2 do -- 1 == Wintergrasp, 2 == Tol Barad, 3 == Ashran
                    local _, zone, _, _, startTime = GetWorldPVPAreaInfo(i)
                    if startTime then
                        lineNum, colNum = tooltip:AddLine()
                        tooltip:SetCell(lineNum, 1, L["Clock_PvPTime"]:format(zone))
                        tooltip:SetCell(lineNum, 2, format(SecondsToTimeAbbrev(startTime)), "RIGHT", 2)
                    else
                        lineNum, colNum = tooltip:AddLine()
                        tooltip:SetCell(lineNum, 1, L["Clock_NoPvPTime"]:format(zone), "LEFT", 2)
                    end
                end
            end

            -- Invites
            if self.invites and self.invites > 0 then
                tooltip:AddLine(" ")
                lineNum, colNum = tooltip:AddLine()
                tooltip:SetCell(lineNum, colNum, L["Clock_CalenderInvites"], self.invites, 2)
            end

            -- World Bosses
            local numSavedBosses = GetNumSavedWorldBosses()
            if (UnitLevel("player") >= 90) and (numSavedBosses > 0) then
                tooltip:AddLine(" ")
                lineNum, colNum = tooltip:AddHeader()
                tooltip:SetCell(lineNum, colNum, LFG_LIST_BOSSES_DEFEATED, nil, 2)
                for i = 1, numSavedBosses do
                    local bossName, bossID, bossReset = GetSavedWorldBossInfo(i)
                    tooltip:AddLine(bossName, format(SecondsToTimeAbbrev(bossReset)))
                end
            end

            tooltip:AddLine(" ")

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, colNum, L["Clock_ShowCalendar"], nil, 2)
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            lineNum, colNum = tooltip:AddLine()
            tooltip:SetCell(lineNum, colNum, L["Clock_ShowTimer"], nil, 2)
            tooltip:SetCellTextColor(lineNum, colNum, 0, 1, 0)

            tooltip:SmartAnchorTo(self)
            tooltip:SetAutoHideDelay(0.10, self)

            tooltip:Show()
        end,
        OnEvent = function(self, event, ...)
            --InfoLine:debug("Clock: OnEvent", event, ...)
            if event then
                if event == "PLAYER_ENTERING_WORLD" then
                    self.alert = CreateFrame("Frame", nil, self, "MicroButtonAlertTemplate")
                    InfoLine:ScheduleRepeatingTimer(self.dataObj.OnEvent, 1, self)
                    hooksecurefunc("TimeManager_ToggleTimeFormat", setTimeOptions)
                    hooksecurefunc("TimeManager_ToggleLocalTime", setTimeOptions)
                    setTimeOptions(self)
                end
                local alert = self.alert
                self.invites = CalendarGetNumPendingInvites()
                if self.invites > 0 and not alert.isHidden then
                    alert:SetSize(177, alert.Text:GetHeight() + 42);
                    alert:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 0, 18)
                    alert.Arrow:SetPoint("TOPRIGHT", alert, "BOTTOMRIGHT", -30, 4)
                    alert.CloseButton:SetScript("OnClick", function(self)
                        alert:Hide()
                        alert.isHidden = true
                    end)
                    alert.Text:SetText(GAMETIME_TOOLTIP_CALENDAR_INVITES)
                    alert.Text:SetWidth(145)
                    alert:Show()
                    alert.isHidden = false
                else
                    alert:Hide()
                end
            end
            local timeFormat, hour, min, suffix = RetrieveTime(self.isMilitary, self.isLocal)
            self.dataObj.value = timeFormat:format(hour, min)
            self.dataObj.suffix = suffix
            InfoLine:UpdateElementWidth(self)
        end,
        events = {
            "CALENDAR_UPDATE_EVENT_LIST",
            "PLAYER_ENTERING_WORLD",
        },
    })

    -- Meters

    -- Layout

    -- Specialization

    -- FPS/Ping
end
