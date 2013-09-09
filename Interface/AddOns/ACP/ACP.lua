--==============
-- Global Variables
--==============
ACP = {}

ACP_LINEHEIGHT = 16

ACP.CheckEvents = 0


ACP.TAGS = {
    PART_OF = "X-Part-Of",
    INTERFACE_MIN = "X-Min-Interface",
    INTERFACE_MIN_ORG = "X-Since-Interface",
    INTERFACE_MAX = "X-Max-Interface",
    INTERFACE_MAX_ORG = "X-Compatible-With",
	CHILD_OF = "X-Child-Of",
}

-- Handle various annoying special case names
function ACP:SpecialCaseName(name)
    local partof = GetAddOnMetadata(name, ACP.TAGS.PART_OF)
    if partof == nil then
        partof = GetAddOnMetadata(name, ACP.TAGS.CHILD_OF)
    end

    if partof ~= nil then
        return partof .. "_" .. name
    end

    if name == "DBM-Core" then
        return "DBM"
    elseif name:match("DBM%-") then
        return name:gsub("DBM%-", "DBM_")
    elseif name:match("CT_") then
        return name:gsub("CT_", "CT-")
    elseif name:sub(1, 1) == "+" or name:sub(1, 1) == "!" or name:sub(1, 1) == "_" then
        return name:sub(2, -1)
    elseif name == "ShadowedUF_Options" then
        return "ShadowedUnitFrames_Options"
    --	elseif name == "Auc-Advanced" then
    --		return "Auc"
    --	elseif name:match("Auc%-") then
    --		return name:gsub("Auc%-", "Auc_")
    --	elseif
    end

    return name
end

--==============
-- Localization
--==============
local DEFAULT = "Default"
local TITLES = "Titles"
local ACE2 = "Ace2"
local AUTHOR = "Author"
local SEPARATE_LOD_LIST = "Separate LOD List"
local GROUP_BY_NAME = "Group By Name"

if (GetLocale() == "zhCN") then
    DEFAULT = "默认"
    TITLES = "名称"
    ACE2 = "Ace2"
    AUTHOR = "作者"
    SEPARATE_LOD_LIST = "按需求加载"
    GROUP_BY_NAME = "按名称分组"
elseif (GetLocale() == "zhTW") then
    DEFAULT = "預設"
    TITLES = "名稱"
    ACE2 = "Ace2"
    AUTHOR = "作者"
    SEPARATE_LOD_LIST = "隨需求載入"
    GROUP_BY_NAME = "以名稱分組"
elseif (GetLocale() == "koKR") then
    DEFAULT = "기본"
    TITLES = "제목"
    ACE2 = "Ace2"
    AUTHOR = "제작자"
    SEPARATE_LOD_LIST = "LOD 목록 분리"
    GROUP_BY_NAME = "이름별 분류"
elseif (GetLocale() == "frFR") then
    DEFAULT = "Défaut"
    TITLES = "Titres"
    ACE2 = "Ace2"
    AUTHOR = "Auteur"
    SEPARATE_LOD_LIST = "Liste LOD séparée"
    GROUP_BY_NAME = "Groupement par nom"
elseif (GetLocale() == "esES") then
    DEFAULT = "Por Defecto"
    TITLES = "T?tulos"
    ACE2 = "Ace2"
    AUTHOR = "Autor"
    SEPARATE_LOD_LIST = "Lista CaD por separado"
    GROUP_BY_NAME = "Agrupar por nombre"
elseif (GetLocale() == "ruRU") then
    DEFAULT = "По умолчанию"
    TITLES = "Заголовкам"
    ACE2 = "Ace2"
    AUTHOR = "Автор"
    SEPARATE_LOD_LIST = "Отдел. список ЗПТ"
    GROUP_BY_NAME = "Группир. по имени"
end

--==============
-- Locale
--==============
local L = setmetatable({}, {
    __index = function(t, k)
        error("Locale key " .. tostring(k) .. " is not provided.")
    end
})

--==============
-- Special Tables
--==============

--[[
	masterAddonList : master list of sorted addons.
	It should be in the following structures:
		masterAddonList = {
			addon1Index,
			addon2Index,
			{
				addon3Index,
				addon4Index,
				...
				['category'] = "Category1Name"
			},
			addon5Index,
			{
				addon6Index,
				addon7Index,
				['category'] = "Category2Name"
			},
		}

	This list is used to build sortedAddonList, which is the list used in the FauxScrollFrame.

	NEW: addonIndex can now be number or string, where string is the addon name,
			so you can directly insert the Blizzard addon names to the list.

--]]
local masterAddonList = {}
ACP.masterAddonList = masterAddonList


--[[
	sortedAddonList : list of addonIndexes, which is used by the FauxScrollFrame.
	It should be in the following structure:
		sortedAddonList = {
			addon1Index,
			addon2Index,
			"Category1Name",
			addon3Index,
			addon4Index,
			...,
			addon5Index,
			"Category2Name",
			addon6Index,
			addon7Index,
			...,
		}

	- If type(addonIndex) == 'string', it will be shown in the panel as a category header.
	- The collapse state will be retrieved from the saved variables: collapsedAddons.
	- If addonIndex > GetNumAddOns(), it''s a Blizzard addon, the index references to ACP_BLIZZARD_ADDONS[addonIndex - GetNumAddOns()].
	- otherwise, addonIndex is the index used in GetAddOnInfo().

	This list will be rebuilt whenever use expanded/collapsed a category, or when user changed the sorting criteria.

--]]
local sortedAddonList = {}
ACP.sortedAddonList = sortedAddonList

--[[
	addonListBuilders : a table of functions used to build masterAddonList

	To define your own sorting criteria, check the default builder functions as examples.
	Note if you create the build function in an external scope, you cannot access to the ACP local variables,
	  i.e. masterAddonList and ACP_BLIZZARD_ADDONS, but they can be accessed through ACP. e.g.:

		function MyExternalBuilder()
			local masterAddonList = ACP.masterAddonList
			local bzAddons = ACP.ACP_BLIZZARD_ADDONS
			(Now build the masterAddonList)
		end

	When you have defined your own builder function, simple add them to the table by:

		ACP.addonListBuilders["MyExternalBuilder"] = MyExternalBuilder

	After everything is done, the custom defined function can be accessed from the ACP sorter drop down menu.

]]
local addonListBuilders = {}
ACP.addonListBuilders = addonListBuilders



--
-- Decorator Pattern Text Colorization Functions
-- Same as crayonlib
--
local CLR = {}
CLR.COLOR_NONE = nil
function CLR:Colorize(hexColor, text)
    if text == nil then text = "" end

    if hexColor == CLR.COLOR_NONE then
        return text
    end

    return "|cff" .. tostring(hexColor or 'ffffff') .. tostring(text) .. "|r"
end

function CLR:GetHexColor(color)
    return string.format("%02x%02x%02x", color.r * 255, color.g * 255, color.b * 255)
end

--
-- Colors used
--
function CLR:Label(txt) return CLR:Colorize('ffff7f', txt) end

function CLR:ActiveEmbed(txt) return CLR:Colorize('80ff80', txt) end

function CLR:Addon(txt) return CLR:Colorize('7f7fff', txt) end

function CLR:On(txt) return CLR:Colorize('00ff00', txt) end

function CLR:Off(txt) return CLR:Colorize('ff0000', txt) end

function CLR:Bool(b, txt) if b then return CLR:On(txt) else return CLR:Off(txt) end end

function CLR:AddonStatus(addon, txt)
    local color = ACP:GetAddonStatus(addon)
    return CLR:Colorize(color, txt)
end

local function formattitle(title)
    return title:gsub("Lib: ", "|cff66ccffLib|r: "):gsub(" |cff7fff7f %-Ace2%-|r", ""):gsub("%-Ace2%-", ""):trim()

end

-- From modmenutufu
local reasons = {}

local function getreason(r)
    if not reasons[r] then reasons[r] = _G["ADDON_" .. r] end
    return reasons[r]
end

function ACP:IsAddonCompatibleWithCurrentIntefaceVersion(addon)
    local build = select(4, GetBuildInfo())

    local addonnum = tonumber(addon)
    if not addonnum or (addonnum and (addonnum == 0 or addonnum > GetNumAddOns())) then
        return true -- Get to the choppa!
    end

    local max_supported = GetAddOnMetadata(addonnum, ACP.TAGS.INTERFACE_MAX) or
        GetAddOnMetadata(addonnum, ACP.TAGS.INTERFACE_MAX_ORG)

    local min_supported = GetAddOnMetadata(addonnum, ACP.TAGS.INTERFACE_MIN) or
        GetAddOnMetadata(addonnum, ACP.TAGS.INTERFACE_MIN_ORG)

    --print("Min: "..tostring(min_supported).."  Max: "..tostring(max_supported))

    if max_supported then
        max_supported = tonumber(max_supported) and (tonumber(max_supported) >= build) or false
    end

    if min_supported then
        min_supported = tonumber(min_supported) and (tonumber(min_supported) <= build) or false
    end

    return max_supported, min_supported

end

function ACP:GetAddonCompatibilitySummary(addon)
    local high, low = self:IsAddonCompatibleWithCurrentIntefaceVersion(addon)

    if low == false then
        return false
    elseif high == false then
        return false
    elseif high or low then
        return true
    end

    return nil -- Compatibility not specified
end

function ACP:GetAddonStatus(addon)
    local addon = addon

    -- Hi, i'm Mr Kludge! Whats your name?
    local addonnum = tonumber(addon)
    if addonnum and (addonnum == 0 or addonnum > GetNumAddOns()) then
        return -- Get to the choppa!
    end

    local high, low = self:IsAddonCompatibleWithCurrentIntefaceVersion(addon)
    if (low == false) then
        return "FF0000", getreason("INCOMPATIBLE")
    end
    if (high == false) then
        return "FF0000", getreason("INTERFACE_VERSION")
    end


    local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addon)

    if reason == "MISSING" and type(addon) == "string" then
        addon = self:ResolveLibraryName(addon) or addon
    end


    local loaded = IsAddOnLoaded(addon)
    local isondemand = IsAddOnLoadOnDemand(addon)
    local color, note

    if reason == "DISABLED" then color, note = "9d9d9d", getreason(reason) -- Grey
    elseif reason == "NOT_DEMAND_LOADED" then color, note = "0070dd", getreason(reason) -- Blue
    elseif reason then color, note = "ff8000", getreason(reason) -- Orange
    elseif loadable and isondemand and not loaded and enabled then color, note = "1eff00", L["Loadable OnDemand"] -- Green
    elseif loaded and not enabled then color, note = "a335ee", L["Disabled on reloadUI"] -- Purple
    elseif reason == "MISSING" then color, note = "ff0000", getreason(reason)
    else
        color = CLR.COLOR_NONE
        note = ""
    end

    return color, note
end


--==============
-- Reference to tables in saved variables
--==============
local savedVar
local collapsedAddons


--==============
-- Local Variables
--==============
local cache = setmetatable({}, {
    __mode = 'k'
})
local function acquire()
    local t = next(cache) or {}
    cache[t] = nil
    return t
end

local function reclaim(t)
    for k in pairs(t) do
        t[k] = nil
    end
    cache[t] = true
end

local ACP_ADDON_NAME = "ACP"
local ACP_FRAME_NAME = "ACP_AddonList"
local playerClass = nil
local ACP_SET_SIZE = 25
local ACP_MAXADDONS = 20
local ACP_DefaultSet = {}
local ACP_DEFAULT_SET = 0
local ACP_BLIZZARD_ADDONS = {
    "Blizzard_AchievementUI",
    "Blizzard_ArenaUI",
    "Blizzard_AuctionUI",
    "Blizzard_BarbershopUI",
    "Blizzard_BattlefieldMinimap",
    "Blizzard_BindingUI",
    "Blizzard_Calendar",
    "Blizzard_CombatLog",
    "Blizzard_CombatText",
    "Blizzard_DebugTools",
    "Blizzard_GlyphUI",
    "Blizzard_GMChatUI",
    "Blizzard_GMSurveyUI",
    "Blizzard_GuildBankUI",
    "Blizzard_InspectUI",
    "Blizzard_ItemSocketingUI",
    "Blizzard_MacroUI",
    "Blizzard_RaidUI",
    "Blizzard_TalentUI",
    "Blizzard_TimeManager",
    "Blizzard_TokenUI",
    "Blizzard_TradeSkillUI",
    "Blizzard_TrainerUI",
}
local NUM_BLIZZARD_ADDONS = #ACP_BLIZZARD_ADDONS
ACP.ACP_BLIZZARD_ADDONS = ACP_BLIZZARD_ADDONS
local enabledList -- Used to prevent recursive loop in EnableAddon.

local function ParseVersion(version)
    if type(version) == "string" then
        version = version:gsub("@project%-version@", CLR:Colorize("ffa0a0", "DEBUG")):trim()
    end
    return version
end

local function toggle(flag)
    if flag then
        return nil
    else
        return true
    end
end




local function GetAddonIndex(addon, noerr)
    if type(addon) == 'number' then
        return addon
    elseif type(addon) == 'string' then
        local addonIndex = ACP_BLIZZARD_ADDONS[addon]
        if addonIndex then
            return addonIndex + GetNumAddOns()
        else
            if addon == "" then return nil end
            for i=1,GetNumAddOns() do
                local name = ACP:SpecialCaseName(GetAddOnInfo(i))
                if name:lower() == ACP:SpecialCaseName(addon):lower() then
                    return i
                end
            end

            if not noerr then
                error("Cannot find addon " .. tostring(addon))
            end
        end
    else
        if not noerr then
            error("GetAddonIndex(): addon must be of type number of string.")
        end
    end
end

function ACP:ToggleRecursion(val)
    if val == nil then
        savedVar.NoRecurse = not savedVar.NoRecurse
    else
        savedVar.NoRecurse = not val
    end

    local frame = _G[ACP_FRAME_NAME .. "_NoRecurse"]


    frame:SetChecked(not savedVar.NoRecurse)

--    ACP:Print(L["Recursive Enable is now %s"]:format(CLR:Bool(not savedVar.NoRecurse, tostring(not savedVar.NoRecurse))))
end

function ACP:OnLoad(this)

    self.L = L
    self.frame = _G[ACP_FRAME_NAME]

    self.frame:SetMovable()

    -- Make sure we are properly scaled.
    self.frame:SetScale(UIParent:GetEffectiveScale());

    GameMenuButtonAddOns:SetText(L["AddOns"])

    for i=1,ACP_MAXADDONS do
        local button = _G[ACP_FRAME_NAME .. "Entry" .. i .. "LoadNow"]
        button:SetText(L["Load"])
    end

    _G[ACP_FRAME_NAME .. "DisableAll"]:SetText(L["Disable All"])
    _G[ACP_FRAME_NAME .. "EnableAll"]:SetText(L["Enable All"])
    _G[ACP_FRAME_NAME .. "SetButton"]:SetText(L["Sets"])
    _G[ACP_FRAME_NAME .. "_ReloadUI"]:SetText(L["ReloadUI"])
    _G[ACP_FRAME_NAME .. "BottomClose"]:SetText(L["Close"])


    UIPanelWindows[ACP_FRAME_NAME] = {
        area = "center",
        pushable = 0,
        whileDead = 1
    }
    StaticPopupDialogs["ACP_RELOADUI"] = {
        text = L["Reload your User Interface?"],
        button1 = TEXT(ACCEPT),
        button2 = TEXT(CANCEL),
        OnAccept = function()
            ReloadUI()
        end,
        OnCancel = function(data, reason)
            if (reason == "timeout") then
                ReloadUI()
            else
                StaticPopupDialogs["ACP_RELOADUI"].reloadAccepted = false
            end
        end,
        OnHide = function()
            if (StaticPopupDialogs["ACP_RELOADUI"].reloadAccepted) then
                ReloadUI();
            end
        end,
        OnShow = function()
            StaticPopupDialogs["ACP_RELOADUI"].reloadAccepted = true;
        end,
        timeout = 5,
        hideOnEscape = 1,
        exclusive = 1,
        whileDead = 1,
        preferredIndex = 3,
    }

    StaticPopupDialogs["ACP_RELOADUI_START"] = {
        text = L["ACP: Some protected addons aren't loaded. Reload now?"],
        button1 = TEXT(ACCEPT),
        button2 = TEXT(CANCEL),
        OnAccept = function()
            ReloadUI()
        end,
        OnCancel = function(data, reason)
            if (reason == "timeout") then
                ReloadUI()
            end
        end,
        timeout = 5,
        hideOnEscape = 1,
        exclusive = 1,
        whileDead = 1,
        preferredIndex = 3,
    }

    StaticPopupDialogs["ACP_SAVESET"] = {
        text = L["Save the current addon list to [%s]?"],
        button1 = TEXT(YES),
        button2 = TEXT(CANCEL),
        OnAccept = function()
            self:SaveSet(self.savingSet)
            CloseDropDownMenus(1)
        end,
        timeout = 0,
        hideOnEscape = 1,
        whileDead = 1,
        exclusive = 1,
        preferredIndex = 3,
    }

    local function OnRenameSet(this)
        local popup;
        if this:GetParent():GetName() == "UIParent" then
            popup = this
        else
            popup = this:GetParent()
        end
        local text = _G[popup:GetName() .. "EditBox"]:GetText()
        if text == "" then
            text = nil
        end
        self:RenameSet(self.renamingSet, text)
        popup:Hide()
    end

    StaticPopupDialogs["ACP_RENAMESET"] = {
        text = L["Enter the new name for [%s]:"],
        button1 = TEXT(YES),
        button2 = TEXT(CANCEL),
        OnAccept = OnRenameSet,
        EditBoxOnEnterPressed = OnRenameSet,
        EditBoxOnEscapePressed = function(this)
            this:GetParent():Hide()
        end,
        timeout = 0,
        hideOnEscape = 1,
        exclusive = 1,
        whileDead = 1,
        hasEditBox = 1,
        preferredIndex = 3,
    }

    for i,v in ipairs(ACP_BLIZZARD_ADDONS) do
        ACP_BLIZZARD_ADDONS[v] = i
    end
    --	ACP_BLIZZARD_ADDONS = setmetatable(ACP_BLIZZARD_ADDONS, {
    --		__index = function(t,k)
    --			for i=1, #t do
    --				if t[i] == k then
    --
    --					return i
    --				end
    --			end
    --		end
    --	} )

    local title = "Addon Control Panel"
    local version = GetAddOnMetadata(ACP_ADDON_NAME, "Version")
    if version then
        version = ParseVersion(version)
        title = title .. " (" .. version .. ")"
    end
    ACP_AddonListHeaderTitle:SetText(title)
    this:RegisterEvent("VARIABLES_LOADED")
    this:RegisterEvent("ADDON_LOADED")

    this:RegisterForDrag("LeftButton");

    local _
    playerClass, _ = UnitClass("player")

    SlashCmdList["ACP"] = self.SlashHandler

    SLASH_ACP1 = "/acp"
end






local eventLibrary, bugeventreged

function ACP:OnEvent(this, event, arg1, arg2, arg3)
    if event == "VARIABLES_LOADED" then
        if not ACP_Data then ACP_Data = {} end

        savedVar = ACP_Data

        savedVar.ProtectedAddons = savedVar.ProtectedAddons or {
            ["ACP"] = true
        }

        if not savedVar.collapsed then
            savedVar.collapsed = {}
        end
        collapsedAddons = savedVar.collapsed

        if not savedVar.sorter then
            ACP:SetMasterAddonBuilder(GROUP_BY_NAME)
        else
            ACP:ReloadAddonList()
        end

        if savedVar.NoChildren == nil then
            savedVar.NoChildren = true
        end

        for i=1,GetNumAddOns() do
            if IsAddOnLoaded(i) then
                local name = GetAddOnInfo(i)
                if name ~= ACP_ADDON_NAME then
                    table.insert(ACP_DefaultSet, name)
                end
            end
        end

        self:ToggleRecursion(not savedVar.NoRecurse)
        _G[ACP_FRAME_NAME .. "_NoRecurseText"]:SetText(L["Recursive"])


        this:RegisterEvent("PLAYER_ENTERING_WORLD")
        this:UnregisterEvent("VARIABLES_LOADED")
    elseif event == "PLAYER_ALIVE" then

        for k,v in pairs(savedVar.ProtectedAddons) do
            if type(k) == "number" then savedVar.ProtectedAddons[k] = nil end
            if not v then savedVar.ProtectedAddons[k] = nil end
        end

        local reloadRequired = false
        for k,v in pairs(savedVar.ProtectedAddons) do
            local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(k)

            if reason == 'MISSING' then
                savedVar.ProtectedAddons[k] = nil
            elseif (not enabled) or enabled == 0 then
                EnableAddOn(k)
                reloadRequired = true
            end

        end

        if reloadRequired then
            if savedVar.reloadRequired then
                savedVar.reloadRequired = nil
            else
                savedVar.reloadRequired = true
            end
        else
            savedVar.reloadRequired = nil
        end
        if savedVar.reloadRequired then
            StaticPopup_Show("ACP_RELOADUI_START");
        end
    elseif event == "PLAYER_ENTERING_WORLD" then
        this:UnregisterEvent("PLAYER_ENTERING_WORLD")
        this:RegisterEvent("PLAYER_ALIVE")


    --        ACP:ProcessBugSack("session")
    elseif event == "ADDON_LOADED" then
        ACP:ADDON_LOADED(arg1)
    end

end


function ACP:ResolveLibraryName(id)
    local a, name
    for a=1,GetNumAddOns() do
        local n = GetAddOnInfo(a)
        if n == id then
            name = n
        elseif GetAddOnMetadata(a, "X-AceLibrary-" .. id) then
            name = name or n
        end
    end

    return name
end


--function ACP:ProcessBugSack(which)
--    if BugSack then
--        local errs = BugSack:GetErrors(which)
--    	for i=1, #errs do
--    	    local str = errs[i].message
--    	    if type(str) == "table" then
--    	        str = table.concat(str)
--    	    end
--
--    	    local _,_,id = strfind(str, "Cannot find a library instance of ([_A-Za-z0-9-]+%.?%d?)")
--
--    	    if not id then
--    	        _,_,id = strfind(str, "Library \"([_A-Za-z0-9-]+%.?%d?)\" does not exist")
--    	    end
--
--    	    if not id then
--    	        _,_,id = strfind(str, ".-requires ([_A-Za-z0-9-]+%.?%d?)")
--    	    end
--
--    	    if id then
--                local name = self:ResolveLibraryName(id)
--
--        	    if name then
--        	        local _, _, _, enabled = GetAddOnInfo(name)
--                    if not enabled then
--                        local reload = Prat and Prat:GetReloadUILink("ACP") or L["Reload"]
--                	    ACP:Print(L["*** Enabling <%s> %s your UI ***"]:format(CLR:Addon(name), reload), 1.0, 1.0, 0.0)
--                	    ACP:EnableAddon(name)
--                    end
--            	else
--               	    ACP:Print(L["*** Unknown Addon <%s> Required ***"]:format(CLR:Addon(name)), 1.0, 0.0, 0.0)
--            	end
--            end
--    	end
--    end
--end

--ACP_Data.NoRecurse
--ACP_Data.NoChildren
--ACP_Data.NoRecurse
--ACP_Data.NoChildren
local ACP_NOCHILDREN = "nochildren"
local ACP_NORECURSE = "norecurse"

local ACP_ADD_SET_D = "addset"
local ACP_REM_SET_D = "removeset"
local ACP_DISABLEALL = "disableall"

local ACP_RESTOREDEFAULT = "default"

local ACP_COMMANDS = { ACP_NOCHILDREN, ACP_NORECURSE, ACP_ADD_SET_D, ACP_REM_SET_D, ACP_DISABLEALL, ACP_RESTOREDEFAULT }

function ACP.SlashHandler(msg)
    if type(msg) == "string" and msg:len() > 0 then
        if msg == ACP_NOCHILDREN then
            savedVar.NoChildren = not savedVar.NoChildren
            ACP:Print(L["LoD Child Enable is now %s"]:format(CLR:Bool(not savedVar.NoChildren, tostring(not savedVar.NoChildren))))
            return
        end

        if msg == ACP_NORECURSE then
            ACP:ToggleRecursion()
            ACP:Print(L["Recursive Enable is now %s"]:format(CLR:Bool(not savedVar.NoRecurse, tostring(not savedVar.NoRecurse))))
            return
        end

        if msg == ACP_DISABLEALL then
            ACP:DisableAllAddons()
            return
        end

        if msg:find("^"..ACP_ADD_SET_D) then
            local set = msg:sub(ACP_ADD_SET_D:len(), -1):match("%d+")
            set = tonumber(set)

            if type(set) == "number" then
                ACP:LoadSet(set)
                return
            end
        end

        if msg:find("^"..ACP_REM_SET_D) then
            local set = msg:sub(ACP_REM_SET_D:len(), -1):match("%d+")
            set = tonumber(set)

            if type(set) == "number" then
                ACP:UnloadSet(set)
                return
            end
        end

        if msg == ACP_RESTOREDEFAULT then
            ACP:DisableAll_OnClick()
            ACP:LoadSet(0)
            return
        end

        ACP:ShowSlashCommands()
    end

    ACP:ToggleUI()
end

function ACP:ShowSlashCommands()
    ACP:Print("Valid commands: " .. table.concat(ACP_COMMANDS, ", "))
end


addonListBuilders[DEFAULT] = function()
    for k in pairs(masterAddonList) do
        masterAddonList[k] = nil
    end
    local numAddons = GetNumAddOns()
    for i=1,numAddons do
        table.insert(masterAddonList, i)
    end
    for i=1,NUM_BLIZZARD_ADDONS do
        table.insert(masterAddonList, numAddons + i)
    end
end

addonListBuilders[TITLES] = function()
    for k in pairs(masterAddonList) do
        masterAddonList[k] = nil
    end

    local numAddons = GetNumAddOns()
    for i=1,numAddons do
        table.insert(masterAddonList, i)
    end

    -- Sort the addon list by Ace2 Categories.
    table.sort(masterAddonList, function(a, b)
        local _, nameA = GetAddOnInfo(a)
        local _, nameB = GetAddOnInfo(b)
        return formattitle(nameA) < formattitle(nameB)
    end)

    for i=1,NUM_BLIZZARD_ADDONS do
        table.insert(masterAddonList, numAddons + i)
    end
end

addonListBuilders[ACE2] = function()

    local t = {}

    local numAddons = GetNumAddOns()
    for i=1,numAddons do
        table.insert(t, i)
    end

    -- Sort the addon list by Ace2 Categories.
    table.sort(t, function(a, b)
        local catA = GetAddOnMetadata(a, "X-Category")
        local catB = GetAddOnMetadata(b, "X-Category")
        if catA == catB then
            local nameA = GetAddOnInfo(a)
            local nameB = GetAddOnInfo(b)
            return nameA < nameB
        else
            return tostring(catA) < tostring(catB)
        end
    end)

    -- Insert the category titles into the list.
    local prevCategory = ""
    for i,addonIndex in ipairs(t) do
        local category = GetAddOnMetadata(addonIndex, "X-Category")
        if not category then
            category = "Undefined"
        end
        if category ~= prevCategory then
            table.insert(t, i, category)
        end
        prevCategory = category
    end

    table.insert(t, "Blizzard")

    for i=1,NUM_BLIZZARD_ADDONS do
        table.insert(t, numAddons + i)
    end

    -- Now build the masterAddonList.
    for k in pairs(masterAddonList) do
        masterAddonList[k] = nil
    end
    local list = masterAddonList
    local currPos = list
    for i,addon in ipairs(t) do
        if type(addon) == 'string' then
            local t = {}
            t.category = addon
            table.insert(list, t)
            currPos = t
        else
            table.insert(currPos, addon)
        end
    end


end


addonListBuilders[AUTHOR] = function()
    local t = {}

    local numAddons = GetNumAddOns()
    for i=1,numAddons do
        table.insert(t, i)
    end

    -- Sort the addon list by Ace2 Categories.
    table.sort(t, function(a, b)
        local catA = GetAddOnMetadata(a, "Author")
        local catB = GetAddOnMetadata(b, "Author")
        if catA == catB then
            local nameA = GetAddOnInfo(a)
            local nameB = GetAddOnInfo(b)
            return nameA < nameB
        else
            return tostring(catA) < tostring(catB)
        end
    end)

    -- Insert the category titles into the list.
    local prevCategory = ""
    for i,addonIndex in ipairs(t) do
        local category = GetAddOnMetadata(addonIndex, "Author")
        if not category then
            category = "Unknown"
        end
        if category ~= prevCategory then
            table.insert(t, i, category)
        end
        prevCategory = category
    end

    table.insert(t, "Blizzard")

    for i=1,NUM_BLIZZARD_ADDONS do
        table.insert(t, numAddons + i)
    end

    -- Now build the masterAddonList.
    for k in pairs(masterAddonList) do
        masterAddonList[k] = nil
    end
    local list = masterAddonList
    local currPos = list
    for i,addon in ipairs(t) do
        if type(addon) == 'string' then
            local t = {}
            t.category = addon
            table.insert(list, t)
            currPos = t
        else
            table.insert(currPos, addon)
        end
    end

end


--[[
addonListBuilders["Ace2 Libs And Packages"] = function()
	for k in pairs(masterAddonList) do
		masterAddonList[k] = nil
	end

	-- Sort the addon list by Ace2 Categories.
	table.sort(t, function(a, b)
		local catA = GetAddOnMetadata(a, "Author")
		local catB = GetAddOnMetadata(b, "Author")
		if catA == catB then
			local nameA = GetAddOnInfo(a)
			local nameB = GetAddOnInfo(b)
			return nameA < nameB
		else
			return tostring(catA) < tostring(catB)
		end
	end )


	local numAddons = GetNumAddOns()
	for i=1, numAddons do
		table.insert(masterAddonList, i)
	end
	for i=1, NUM_BLIZZARD_ADDONS do
		table.insert(masterAddonList, numAddons+i)
	end
end
--]]

addonListBuilders[SEPARATE_LOD_LIST] = function()
    for k in pairs(masterAddonList) do
        masterAddonList[k] = nil
    end
    local numAddons = GetNumAddOns()
    local name

    local lods = {}
    lods.category = "Load On Demand Addons"
    local nonlods = {}
    nonlods.category = "Standard Addons"
    local blizz = {}
    blizz.category = "Blizzard Addons"

    local pos = 1
    for i=1,numAddons do
        name = GetAddOnInfo(i)
        if not IsAddOnLoadOnDemand(name) then
            table.insert(nonlods, i)
        else
            table.insert(lods, i)
        end
    end

    for i=1,NUM_BLIZZARD_ADDONS do
        table.insert(blizz, numAddons + i)
    end

    table.insert(masterAddonList, nonlods)
    table.insert(masterAddonList, lods)
    table.insert(masterAddonList, blizz)
end



addonListBuilders[GROUP_BY_NAME] = function()
    local t = {}

    local numAddons = GetNumAddOns()
    for i=1,numAddons do
        table.insert(t, i)
    end

    local libs = {}
    libs.category = "Libraries"

    -- Sort the addon list by Ace2 Categories.
    table.sort(t, function(a, b)
        local nameA = GetAddOnInfo(a)
        local nameB = GetAddOnInfo(b)

        local catA, catB

        nameA, nameB = ACP:SpecialCaseName(nameA), ACP:SpecialCaseName(nameB)

        if nameA:find("_") then
            catA, nameA = strsplit("_", nameA)
        else
            catA, nameA = nameA
        end

        if nameB:find("_") then
            catB, nameB = strsplit("_", nameB)
        else
            catB, nameB = nameB
        end

        if catA:lower() == catB:lower() then
            return (nameA or ""):lower() < (nameB or ""):lower()
        else
            return tostring(catA):lower() < tostring(catB):lower()
        end
    end)



    -- Insert the category titles into the list.
    local prevCategory = ""
    local name = nil
    local t2 = t
    t = {}
    for i,addonIndex in ipairs(t2) do
        name = ACP:SpecialCaseName(GetAddOnInfo(addonIndex))

        local acecategory = GetAddOnMetadata(addonIndex, "X-Category")

        if (acecategory and acecategory:find("Library")) and not ACP:IsAddOnProtected(name) then
            table.insert(libs, addonIndex)
        else
            local category, content = strsplit("_", name)
            if not content then
                content = category
                category = ""
            end
            if category:lower() ~= prevCategory:lower() then
                table.insert(t, category)
            end

            table.insert(t, addonIndex)
            prevCategory = category
        end
    end



    local blizz = {}
    blizz.category = "Blizzard Addons"

    for i=1,NUM_BLIZZARD_ADDONS do
        table.insert(blizz, numAddons + i)
    end

    -- Now build the masterAddonList.
    for k in pairs(masterAddonList) do
        masterAddonList[k] = nil
    end
    local list = masterAddonList
    local currPos = list
    for i,addon in ipairs(t) do
        if type(addon) == 'string' then
            if addon == "" then
                currPos = list
            else
                local t = {}
                t.category = addon
                --    			table.remove(currPos, #currPos)
                local addonpos = currPos[#currPos]
                if addonpos then
                    local addonname = ACP:SpecialCaseName(GetAddOnInfo(addonpos))
                    if (addonname == addon) then table.remove(currPos, #currPos) end
                    table.insert(list, t)
                    currPos = t
                end
            end
        else
            table.insert(currPos, addon)
        end
    end



    table.insert(masterAddonList, libs)
    table.insert(masterAddonList, blizz)
end


function ACP:ToggleUI()
--[[ added Mon Jul 30 12:14:24 CEST 2007 - fin

wanted an easy way to toggle the UI on / off for CustomMenuFu

NOTE: maybe change the slash handler to use this instead?
]]
    if ACP_AddonList:IsShown() then
        HideUIPanel(ACP_AddonList)
    else
        ShowUIPanel(ACP_AddonList)
    end
end



function ACP:ReloadAddonList()

    local builder = savedVar.sorter
    if not builder then
        builder = DEFAULT
    end

    local func = addonListBuilders[builder]
    if not func then
        func = addonListBuilders[DEFAULT]
    end

    func()

    self:RebuildSortedAddonList()
    ACP:AddonList_OnShow()


    ACP_AddonListSortDropDownText:SetText(builder)
    local button = _G[ACP_FRAME_NAME .. "SortDropDown"]
    UIDropDownMenu_SetSelectedValue(button, builder)

end

--function ACP:OnKeyDown(this, key)
--   -- print(this, key)
--	if ( key == "ESCAPE" ) then
--		HideUIPanel(ACP_AddonList);
--	elseif ( key == "PRINTSCREEN" ) then
--		Screenshot();
--	elseif ( key == "PAGEUP" ) then
--		ScrollFrameTemplate_OnMouseWheel(ACP_AddonList_ScrollFrame, 1)
--	elseif ( key == "PAGEDOWN" ) then
--		ScrollFrameTemplate_OnMouseWheel(ACP_AddonList_ScrollFrame, -1)
--	end
--end



--
-- Shift will invert the use of recursion
-- Ctrl will invert the use of LoD children
--
function ACP:EnableAddon(addon, shift, ctrl)
    local norecurse = ACP_Data.NoRecurse
    if shift then norecurse = not norecurse end

    local nochildren = ACP_Data.NoChildren
    if ctrl then nochildren = not nochildren end

    if norecurse then
        EnableAddOn(addon)
    else
        local name = GetAddOnInfo(addon)
        ACP_EnableRecurse(name, nochildren)
    end
end

function ACP:ReadDependencies(t, ...)
    for k in pairs(t) do
        t[k] = nil
    end
    for i=1,select('#', ...) do
        local name = select(i, ...)
        if name then
            t[name] = true
        end
    end
    return t
end

function ACP:EnableDependencies(addon)
    local deps = self:ReadDependencies(acquire(), GetAddOnDependencies(addon))

    if next(deps) then
        for k in pairs(deps) do
            self:EnableAddon(k)
        end
    end

    reclaim(deps)

end

function ACP:FindAddon(list, name)
    for i,v in ipairs(list) do
        if v == name then
            return true
        end
    end
    return nil
end

function ACP:FindAddonKey(list, name)
    for k,v in pairs(list) do
        if k == name then
            return true
        end
    end
    return nil
end


function ACP:Print(msg, r, g, b)
    DEFAULT_CHAT_FRAME:AddMessage("ACP: " .. msg, r, g, b)
end

function ACP:CollapseAll(collapse)
    local categories = {}

    for i,addon in ipairs(masterAddonList) do
        if type(addon) == 'table' and addon.category then
            table.insert(categories, addon.category)
        end
    end


    for i,category in ipairs(categories) do
        collapsedAddons[category] = collapse
    end

    self:RebuildSortedAddonList()
end

function ACP:SaveSet(set)
    if not savedVar.AddonSet then
        savedVar.AddonSet = {}
    end

    if not savedVar.AddonSet[set] then
        savedVar.AddonSet[set] = {}
    end

    local addonSet = savedVar.AddonSet[set]

    local setName = addonSet.name
    for k in pairs(addonSet) do
        addonSet[k] = nil
    end

    addonSet.name = setName

    local name, enabled, _
    for i=1,GetNumAddOns() do
        name, _, _, enabled = GetAddOnInfo(i)
        if enabled and name ~= ACP_ADDON_NAME and not ACP:IsAddOnProtected(name) then
            table.insert(addonSet, name)
        end
    end

    self:Print(L["Addons [%s] Saved."]:format(self:GetSetName(set)))

end

function ACP:GetSetName(set)
    if set == ACP_DEFAULT_SET then
        return L["Default"]
    elseif set == playerClass then
        return playerClass
    elseif savedVar and savedVar.AddonSet and savedVar.AddonSet[set] and savedVar.AddonSet[set].name then
        return savedVar.AddonSet[set].name
    else
        return L["Set "] .. set
    end
end

function ACP:UnloadSet(set)

    local list

    if set == ACP_DEFAULT_SET then
        list = ACP_DefaultSet
    else
        if not savedVar or not savedVar.AddonSet or not savedVar.AddonSet[set] then return end
        list = savedVar.AddonSet[set]
    end

    local name
    for i=1,GetNumAddOns() do
        name = GetAddOnInfo(i)
        if name ~= ACP_ADDON_NAME and ACP:FindAddon(list, name) and not ACP:IsAddOnProtected(name) then
            DisableAddOn(name)
        end
    end

    self:Print(L["Addons [%s] Unloaded."]:format(self:GetSetName(set)))
    ACP:AddonList_OnShow()
end

function ACP:ClearSelectionAndLoadSet(set)
    self:DisableAll_OnClick()

    self:LoadSet(set)
end

function ACP:LoadSet(set)
    local list

    if set == ACP_DEFAULT_SET then
        list = ACP_DefaultSet
    else
        if not savedVar or not savedVar.AddonSet or not savedVar.AddonSet[set] then return end
        list = savedVar.AddonSet[set]
    end

    enabledList = acquire()
    local name
    for i=1,GetNumAddOns() do
        name = GetAddOnInfo(i)
        if ACP:FindAddon(list, name) and not ACP:IsAddOnProtected(name) then
            self:EnableAddon(name)
        end
    end

    reclaim(enabledList)
    enabledList = nil

    self:Print(L["Addons [%s] Loaded."]:format(self:GetSetName(set)))
    ACP:AddonList_OnShow()

end

function ACP:IsAddOnProtected(addon)
    local addon = GetAddOnInfo(addon)
    if addon and savedVar.ProtectedAddons then
        return savedVar.ProtectedAddons[addon]
    end
end

function ACP:Security_OnClick(addon)
    local addon = GetAddOnInfo(addon)
    if addon then
        savedVar.ProtectedAddons = savedVar.ProtectedAddons or {
            ["ACP"] = true
        }
        local prot = savedVar.ProtectedAddons[addon]
        if prot then
            savedVar.ProtectedAddons[addon] = nil
        else
            savedVar.ProtectedAddons[addon] = true
        end

        EnableAddOn(addon)
    end
    self:AddonList_OnShow()
end

function ACP:ShowSecurityTooltip(this)
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT")

    GameTooltip:AddLine(L["Click to enable protect mode. Protected addons will not be disabled"])
    GameTooltip:AddLine(L["when performing a reloadui."])

    GameTooltip:Show()
end


function ACP:RenameSet(set, name)

    local oldName = self:GetSetName(set)
    if not savedVar then savedVar = {} end
    if not savedVar.AddonSet then savedVar.AddonSet = {} end
    if not savedVar.AddonSet[set] then savedVar.AddonSet[set] = {} end
    savedVar.AddonSet[set].name = name

    self:Print(L["Addons [%s] renamed to [%s]."]:format(oldName, name))

end

-- Rebuild sortedAddonList from masterAddonList

function ACP:RebuildSortedAddonList()
    for k in pairs(sortedAddonList) do
        sortedAddonList[k] = nil
    end

    for i,addon in ipairs(masterAddonList) do
        if type(addon) == 'table' then
            local category = addon.category
            if category then
                table.insert(sortedAddonList, category)
            end
            if not category or not collapsedAddons[category] then
                for j,subAddon in ipairs(addon) do
                    table.insert(sortedAddonList, subAddon)
                end
            end
        else
        --addon = GetAddonIndex(addon)
            table.insert(sortedAddonList, addon)
        end
    end

--	ACP.masterAddonList = masterAddonList
--	ACP.sortedAddonList = sortedAddonList
end

function ACP:SetMasterAddonBuilder(sorter)
    if not addonListBuilders[sorter] or not savedVar then return end
    for k in pairs(collapsedAddons) do
        collapsedAddons[k] = nil
    end
    savedVar.sorter = sorter
    self:ReloadAddonList()
end

function ACP:UpdateLocale(loc)
    for k,v in pairs(loc) do
        if v == true then
            L[k] = k
        else
            L[k] = v
        end
    end
end


-- UI Controllers.
function ACP:SortDropDown_OnShow(this)
    if not self.initSortDropDown then
        UIDropDownMenu_Initialize(this, function() self:SortDropDown_Populate() end)
        self.initSortDropDown = true
    end
end

function ACP:SortDropDown_Populate()
    local info
    for name,func in pairs(addonListBuilders) do
        info = UIDropDownMenu_CreateInfo()
        info.text = name
        info.func = function() self:SetMasterAddonBuilder(name) end
        UIDropDownMenu_AddButton(info)
    end
end

function ACP:SortDropDown_OnClick(sorter)

end

function ACP:DisableAllAddons()
    DisableAllAddOns()
    EnableAddOn(ACP_ADDON_NAME)

    for k in pairs(savedVar.ProtectedAddons) do
        EnableAddOn(k)
    end
    ACP:Print("Disabled all addons (except ACP & protected)")
    
    if _G[ACP_FRAME_NAME]:IsShown() then
        self:AddonList_OnShow()
    end
end

function ACP:DisableAll_OnClick()
    self:DisableAllAddons()

end

function ACP:Collapse_OnClick(obj)

    local category = obj.category
    if not category then return end

    collapsedAddons[category] = toggle(collapsedAddons[category])

    self:RebuildSortedAddonList()
    self:AddonList_OnShow()

end

function ACP:CollapseAll_OnClick()
    local obj = _G[ACP_FRAME_NAME .. "CollapseAll"]
    local icon = _G[ACP_FRAME_NAME .. "CollapseAllIcon"]
    obj.collapsed = toggle(obj.collapsed)
    if obj.collapsed then
        icon:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomInButton-Up")
    else
        icon:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomOutButton-Up")
    end
    self:CollapseAll(obj.collapsed)
    self:AddonList_OnShow()
end

function ACP:GetAddonCategory(addon)
    for i,a in ipairs(masterAddonList) do
        if type(a) == 'table' then
            if self:FindAddon(a, addon) then
                return a.category
            end
        else
            if a == addon then
                return ""
            end
        end
    end
end

function ACP:GetAddonCategoryTable(addon)
    for i,a in ipairs(masterAddonList) do
        if type(a) == 'table' then
            if a.category == addon then
                return a
            end
        else
            if a == addon then
                return nil
            end
        end
    end
end


function ACP:AddonList_Enable(addonIndex, enabled, shift, ctrl, category)
    if (type(addonIndex) == "number") then
        if (enabled) then
            enabledList = acquire()
            self:EnableAddon(addonIndex, shift, ctrl)
            reclaim(enabledList)
            enabledList = nil
        else
            DisableAddOn(addonIndex)
        end

        if category and collapsedAddons[category] then
            self:Print(CLR:Addon(category) .. " is collapsed. Setting all its addons " .. CLR:Bool(enabled, (enabled and "ENABLED" or "DISABLED")))
            local t = self:GetAddonCategoryTable(category)
            for k,v in pairs(t) do
                if enabled then
                    self:EnableAddon(v, shift, ctrl)
                else
                    DisableAddOn(v)
                end
            end
        end
    end
    self:AddonList_OnShow()
end

function ACP:AddonList_LoadNow(index)
    UIParentLoadAddOn(index)
    ACP:AddonList_OnShow()
end

function ACP:AddonList_OnShow_Fast(this)
    local function setSecurity(obj, idx)
        local width, height, iconWidth = 64, 16, 16
        local increment = iconWidth / width
        local left = (idx - 1) * increment
        local right = idx * increment
        obj:SetTexCoord(left, right, 0, 1)
    end

    local obj
    local origNumAddons = GetNumAddOns()
    local numAddons = #sortedAddonList
    FauxScrollFrame_Update(ACP_AddonList_ScrollFrame, numAddons, ACP_MAXADDONS, ACP_LINEHEIGHT, nil, nil, nil)
    local i
    local offset = FauxScrollFrame_GetOffset(ACP_AddonList_ScrollFrame)
    local curr_category = ""
    for i=1,ACP_MAXADDONS,1 do
        obj = _G["ACP_AddonListEntry" .. i]
        local addonIdx = sortedAddonList[offset + i]

        --     if not curr_category then
        curr_category = self:GetAddonCategory(addonIdx) or ""
        --   end
        if offset + i > #sortedAddonList then
            obj:Hide()
            obj.addon = nil
        else
            local headerText = _G["ACP_AddonListEntry" .. i .. "Header"]
            local titleText = _G["ACP_AddonListEntry" .. i .. "Title"]
            local status = _G["ACP_AddonListEntry" .. i .. "Status"]
            local checkbox = _G["ACP_AddonListEntry" .. i .. "Enabled"]
            local securityButton = _G["ACP_AddonListEntry" .. i .. "Security"]
            local securityIcon = _G["ACP_AddonListEntry" .. i .. "SecurityIcon"]
            local loadnow = _G["ACP_AddonListEntry" .. i .. "LoadNow"]
            local collapse = _G["ACP_AddonListEntry" .. i .. "Collapse"]
            local collapseIcon = _G["ACP_AddonListEntry" .. i .. "CollapseIcon"]


            if type(addonIdx) == 'string' and not GetAddonIndex(addonIdx, true) then
            --				curr_category  = addonIdx
                obj.addon = nil
                obj.category = addonIdx
                obj:Show()
                headerText:SetText(addonIdx)
                headerText:Show()
                titleText:Hide()
                status:Hide()
                checkbox:Hide()
                securityButton:Hide()
                loadnow:Hide()
                if collapsedAddons[addonIdx] then
                    collapseIcon:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomInButton-Up")
                else
                    collapseIcon:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomOutButton-Up")
                end
                collapse:Show()
            else
                if type(addonIdx) == 'string' then
                    obj.category = addonIdx
                    --    				curr_category  = addonIdx
                    if collapsedAddons[addonIdx] then
                        collapseIcon:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomInButton-Up")
                    else
                        collapseIcon:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomOutButton-Up")
                    end
                    collapse:Show()
                    securityButton:Hide()
                    addonIdx = GetAddonIndex(addonIdx, true)
                else
                    obj.category = nil
                    collapse:Hide()

                    if curr_category == "" then
                        securityButton:Show()
                    else
                        securityButton:Hide()
                    end
                end
                obj:Show()
                headerText:Hide()
                titleText:Show()
                status:Show()

                local subCount = nil
                if collapsedAddons[obj.category] then
                    local t = self:GetAddonCategoryTable(obj.category)
                    subCount = t and #t
                end

                local name, title, notes, enabled, loadable, reason, security
                if (addonIdx > origNumAddons) then
                    name = ACP_BLIZZARD_ADDONS[(addonIdx - origNumAddons)]
                    name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(name)
                    --					obj.addon = name
                    --					title = L[name]
                    --					notes = ""
                    --					enabled = 1
                    --					loadable = 1
                    --					if (IsAddOnLoaded(name)) then
                    --						reason = "LOADED"
                    --						loadable = 1
                    --					end
                    --					security = "SECURE"
                    obj.addon = name
                else
                    name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addonIdx)
                    obj.addon = addonIdx
                end
                local loaded = IsAddOnLoaded(name)
                local ondemand = IsAddOnLoadOnDemand(name)
                if (loadable) then
                    titleText:SetTextColor(1, 0.78, 0)
                elseif (enabled and reason ~= "DEP_DISABLED") then
                    titleText:SetTextColor(1, 0.1, 0.1)
                else
                    titleText:SetTextColor(0.5, 0.5, 0.5)
                end

                if (title) then

                    if subCount and subCount > 0 then
                        title = title .. "  |cffffffff(|r" .. tostring(subCount) .. "|cffffffff)|r"
                    end

                    title = title:gsub(" |cff7fff7f %-Ace2%-|r", ""):gsub("%-Ace2%-", ""):trim()

                    if not (loaded or loadable) then
                        titleText:SetText(title:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", ""))
                    else
                        titleText:SetText(formattitle(title))
                    end
                else
                    titleText:SetText(name)
                end

                --			    checkbox:ClearAllPoints()
                if curr_category == "" then
                    checkbox:SetPoint("LEFT", 5, 0)
                    if collapse:IsShown() then
                        checkbox:SetWidth(32)
                        checkbox:SetHeight(32)
                    else
                        checkbox:SetWidth(32)
                        checkbox:SetHeight(32)
                    end
                else
                    checkbox:SetPoint("LEFT", 21, 0)
                    checkbox:SetWidth(16)
                    checkbox:SetHeight(16)
                end

                if (name == ACP_ADDON_NAME or addonIdx > origNumAddons) then
                    checkbox:Hide()
                else
                    checkbox:Show()
                    checkbox:SetChecked(enabled)
                end

                if addonIdx < origNumAddons and
                    savedVar.ProtectedAddons[name] then
                    setSecurity(securityIcon, 4)
                    securityButton:Show()
                    checkbox:Hide()
                else
                --    				if (security == "SECURE") then
                --    					setSecurity(securityIcon,1)
                --    				elseif (security == "INSECURE") then
                --    					setSecurity(securityIcon,2)
                --    				elseif (security == "BANNED") then -- wtf?
                --    					setSecurity(securityIcon,3)
                --    				end

                    local compat = self:GetAddonCompatibilitySummary(addonIdx)

                    if compat ~= nil then
                        setSecurity(securityIcon, 1)
                    else
                        setSecurity(securityIcon, 2)
                    end

                end

                --[[
                                if (reason) then
                                    status:SetText(TEXT(_G["ADDON_"..reason)))
                                elseif (loaded) then
                                    status:SetText(L["Loaded"])
                                elseif (ondemand) then
                                    status:SetText(L["Loaded on demand."])
                                else
                                    status:SetText("")
                                end
                ]] if addonIdx <= origNumAddons then
                    status:SetText(CLR:Colorize(self:GetAddonStatus(addonIdx)))
                end

                if (not loaded and enabled and ondemand) then
                    loadnow:Show()
                else
                    loadnow:Hide()
                end
            end
        end

    end
end

function ACP:AddonList_OnShow(this)
    UpdateAddOnMemoryUsage()
    return self:AddonList_OnShow_Fast(this)
end

function ACP:SetButton_OnClick(this)
    if not self.dropDownFrame then
        local frame = CreateFrame("Frame", "ACP_SetDropDown", nil, "UIDropDownMenuTemplate")
        UIDropDownMenu_Initialize(frame, ACP.SetDropDown_Populate, "MENU") -- wotlk temp hack fixing the UIDropDown menu not displayed after pressing "Sets" button
        self.dropDownFrame = frame
    end
    ToggleDropDownMenu(1, nil, self.dropDownFrame, this, 0, 0)
end


function ACP:SetDropDown_Populate(level)
    self = ACP -- wotlk temp hack fixing the UIDropDown menu not displayed after pressing "Sets" button
    if not savedVar then return end

    if level == 1 then

        local info, count, name
        for i=1,ACP_SET_SIZE do
            local name = nil

            info = UIDropDownMenu_CreateInfo()
            if savedVar.AddonSet and savedVar.AddonSet[i] then
                count = table.getn(savedVar.AddonSet[i])
            else
                count = 0
            end

            name = self:GetSetName(i)

            info = UIDropDownMenu_CreateInfo()
            info.text = string.format("%s (%d)", name, count)
            info.value = i
            info.hasArrow = 1
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info)
        end

        -- Class set.
        if savedVar.AddonSet and savedVar.AddonSet[playerClass] then
            count = table.getn(savedVar.AddonSet[playerClass])
        else
            count = 0
        end
        info = UIDropDownMenu_CreateInfo()
        info.text = string.format("%s (%d)", playerClass, count)
        info.value = playerClass
        info.hasArrow = 1
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)

        -- Default set.
        info = UIDropDownMenu_CreateInfo()
        info.text = string.format("%s (%d)", L["Default"], table.getn(ACP_DefaultSet))
        info.value = ACP_DEFAULT_SET
        info.hasArrow = 1
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info)

    elseif level == 2 then
        local info
        local setName = self:GetSetName(UIDROPDOWNMENU_MENU_VALUE)
        info = UIDropDownMenu_CreateInfo()
        info.text = setName
        info.isTitle = 1
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)


        if UIDROPDOWNMENU_MENU_VALUE ~= ACP_DEFAULT_SET then
            info = UIDropDownMenu_CreateInfo()
            info.text = L["Save"]
            info.func = function()
                self.savingSet = UIDROPDOWNMENU_MENU_VALUE
                StaticPopup_Show("ACP_SAVESET", setName)
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
        end

        info = UIDropDownMenu_CreateInfo()
        info.text = L["Load"]
        info.func = function() self:ClearSelectionAndLoadSet(UIDROPDOWNMENU_MENU_VALUE) end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)


        info = UIDropDownMenu_CreateInfo()
        info.text = L["Add to current selection"]
        info.func = function() self:LoadSet(UIDROPDOWNMENU_MENU_VALUE) end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)


        info = UIDropDownMenu_CreateInfo()
        info.text = L["Remove from current selection"]
        info.func = function() self:UnloadSet(UIDROPDOWNMENU_MENU_VALUE) end
        info.notCheckable = 1
        UIDropDownMenu_AddButton(info, level)

        if UIDROPDOWNMENU_MENU_VALUE ~= ACP_DEFAULT_SET and UIDROPDOWNMENU_MENU_VALUE ~= playerClass then
            info = UIDropDownMenu_CreateInfo()
            info.text = L["Rename"]
            info.func = function()
                self.renamingSet = UIDROPDOWNMENU_MENU_VALUE
                StaticPopup_Show("ACP_RENAMESET", setName)
                CloseDropDownMenus(1)
            end
            info.notCheckable = 1
            UIDropDownMenu_AddButton(info, level)
        end

    end



end





do
-- /print ACP.embedded_libs
    ACP.embedded_libs = {}
    -- /print ACP.embedded_libs_owners
    ACP.embedded_libs_owners = {}


    function ACP:ADDON_LOADED(name)
        if not LibStub then return end
        self:LocateEmbeds()

        if name == "ACP" or name:sub(9) == "Blizzard_" then
            name = "???"
        end

        for k,v in pairs(ACP.embedded_libs_owners) do
            if type(v) == "boolean" then
                ACP.embedded_libs_owners[k] = name
            end
        end

    end

    -- /script ACP:LocateEmbeds()
    function ACP:LocateEmbeds()
        local embeds = LibStub.libs

        for k,v in pairs(embeds) do
            if self.embedded_libs[k] ~= v then
                self.embedded_libs[k] = v
                self.embedded_libs_owners[k] = true
            end
        end
    end
end

function ACP:ShowTooltip(this, index)
    if not index then return end

    if type(index) == "number" and (index > GetNumAddOns()) then
        index = ACP_BLIZZARD_ADDONS[(index - GetNumAddOns())]
    end

    local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(index)
    local author = GetAddOnMetadata(name, "Author")
    local version = ParseVersion(GetAddOnMetadata(name, "Version"))
    local deps = {
        GetAddOnDependencies(index)
    }

    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT")
    if title then
        GameTooltip:AddLine(formattitle(title), 1, 0.78, 0, 1)
    else
        GameTooltip:AddLine(name, 1, 0.78, 0, 1)
    end
    if author then
        GameTooltip:AddLine(string.format("%s: %s", CLR:Label(L["Author"]), author), 1, 1, 1, 1)
    end
    if version then
        GameTooltip:AddLine(string.format("%s: %s", CLR:Label(L["Version"]), version), 1, 1, 1, 1)
    end



    if notes then
        GameTooltip:AddLine(notes, 1, 1, 1, 1)
    else
        GameTooltip:AddLine(L["No information available."], 1, 1, 1)
    end

    if reason then
        GameTooltip:AddLine(CLR:Label(L["Status"]) .. ": " .. CLR:AddonStatus(self:GetAddonStatus(index)), 1, 1, 1, 1)
    end

    local depLine
    local dep = deps[1]
    if dep then
        depLine = CLR:Label(L["Dependencies"]) .. ": " .. CLR:AddonStatus(dep, dep)
        for i=2,#deps do
            dep = deps[i]
            if dep and dep:len() > 0 then
                depLine = depLine .. ", " .. CLR:AddonStatus(dep, dep)
            end
        end
        GameTooltip:AddLine(depLine, 1, 1, 1, 1)
    end

    if GetAddOnOptionalDependencies then
        local optionalDeps = { GetAddOnOptionalDependencies(name) }
        if #optionalDeps > 0 then
            local dep = optionalDeps[1]
            if dep then
                depLine = CLR:Label(L["Embeds"]) .. ": " .. CLR:AddonStatus(dep, dep)
                for i=2,#optionalDeps do
                    dep = optionalDeps[i]
                    if dep and dep:len() > 0 then
                        depLine = depLine .. ", " .. CLR:AddonStatus(dep, dep)
                    end
                end
                GameTooltip:AddLine(depLine, 1, 0.78, 0, 1)
            end
        end
    end

    local actives = nil
    for k,v in pairs(self.embedded_libs_owners) do
        if v == name then
            if actives == nil then
                actives = CLR:Label(L["Active Embeds"]) .. ": " .. CLR:ActiveEmbed(k)
            else
                actives = actives .. ", " .. CLR:ActiveEmbed(k)
            end
        end
    end
    if actives then
        GameTooltip:AddLine(actives, 1, 0.78, 0, 1)
    end

    --UpdateAddOnMemoryUsage()
    local mem = GetAddOnMemoryUsage(index)
    local text2
    if mem > 1024 then
        text2 = ("|cff8080ff%.2f|r MiB"):format(mem / 1024)
    else
        text2 = ("|cff8080ff%.0f|r KiB"):format(mem)
    end

    GameTooltip:AddLine(CLR:Label(L["Memory Usage"]) .. ": " .. text2, 1, 0.78, 0, 1)




    local high, low = self:IsAddonCompatibleWithCurrentIntefaceVersion(index)

    if low == false then
        GameTooltip:AddLine(CLR:Label("Compatible") .. ": " .. CLR:Bool(false, NO), 1, 0.78, 0, 1)
    elseif high == false then
        GameTooltip:AddLine(CLR:Label("Compatible") .. ": " .. CLR:Bool(false, NO), 1, 0.78, 0, 1)
    elseif high or low then
        GameTooltip:AddLine(CLR:Label("Compatible") .. ": " .. CLR:Bool(true, YES), 1, 0.78, 0, 1)
    end



    GameTooltip:Show()
end


function ACP:ShowHintTooltip(this, index)
    GameTooltip:SetOwner(this, "ANCHOR_BOTTOMLEFT")

    GameTooltip:AddLine(L["Use SHIFT to override the current enabling of dependancies behaviour."])

    GameTooltip:Show()
end

local function build_string(...)
    local s
    for i=1,select("#", ...) do
        local x = select(i, ...)
        if x and x:len() > 0 then
            s = s and (s .. ", " .. x) or x
        end
    end
    return s
end

local function find_iterate_over(name, ...)
    for i=1,select("#", ...) do
        local x = select(i, ...)
        if x and x:len() > 0 and x == name then
            return true
        end
    end
    return false
end

local function iterate_over(...)
    for i=1,select("#", ...) do
        local x = select(i, ...)
        if x and x:len() > 0 then
            EnableAddOn(x)
        end
    end
end

local function recursive_iterate_over(sink, ...)
    for i=1,select("#", ...) do
        local x = select(i, ...)
        if x and x:len() > 0 then
            sink(x)

        end
    end
end

local function enable_lod_dependants(addon)
    local addon_name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(addon)

    -- dont do this for FuBar, its annoying
    if addon_name == "FuBar" then
        return
    end

    for i=1,GetNumAddOns() do
        local name, title, notes, enabled, loadable, reason, security = GetAddOnInfo(i)
        local isdep = find_iterate_over(addon_name, GetAddOnDependencies(name))
        local ondemand = IsAddOnLoadOnDemand(name)

--        if not isdep then
--            local metaXEmbeds = GetAddOnMetadata(name, "X-Embeds")
--            if metaXEmbeds then
--                isdep = find_iterate_over(addon_name, strsplit(" ,", metaXEmbeds:trim()))
--            end
--        end

        if isdep and not enabled and ondemand then
            ACP_EnableRecurse(name, true)
        --EnableAddOn(name)
        end
    end
end

local function enableFunc(x) ACP_EnableRecurse(x, true) end

local function enableIfLodFunc(x) if IsAddOnLoadOnDemand(x) then ACP_EnableRecurse(x, true) end end

function ACP_EnableRecurse(name, skip_children)
    local _, _, _, enabled = GetAddOnInfo(name)
    if enabled then
        return

    end

    if (type(name) == "string" and strlen(name) > 0) or
        (type(name) == "number" and name > 0) then

        EnableAddOn(name)

        if not skip_children then
            enable_lod_dependants(name)
        end

        recursive_iterate_over(enableFunc, GetAddOnDependencies(name))
        if GetAddOnOptionalDependencies then
            recursive_iterate_over(enableIfLodFunc, GetAddOnOptionalDependencies(name))
        end
    else
    --    self:Print(L["Addon <%s> not valid"]:format(tostring(name)))
    end
end
