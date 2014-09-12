-- Credit to Sylvanaar's ACP for much of this code.
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local dbc, dbg

local MODNAME = "AddonListAdv"
local AddonListAdv = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Addon List Adv.",
        desc = "Enhances the Addon List.",
        childGroups = "tab",
        arg = MODNAME,
        args = {
            header = {
                type = "header",
                name = "Addon List Adv.",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Enhances the Addon List.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Addon List Adv. module.",
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value)
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                    AddonListAdv:RefreshMod()
                end,
                order = 30,
            },
        },
    }
    end
    return options
end

local function OnSaveAs(self)
    local popup;
    if self:GetParent():GetName() == "UIParent" then
        popup = self
    else
        popup = self:GetParent()
    end
    local text = _G[popup:GetName() .. "EditBox"]:GetText()
    if text == "" then
        text = nil
    end
    AddonListAdv:SaveSet(AddonListAdv.savingSet, text)
    popup:Hide()
end

StaticPopupDialogs["ALA_SaveAs"] = {
    text = "Enter the name for this set.",
    button1 = YES,
    button2 = CANCEL,
    OnAccept = OnSaveAs,
    EditBoxOnEnterPressed = OnSaveAs,
    EditBoxOnEscapePressed = function(self)
        self:GetParent():Hide()
    end,
    timeout = 0,
    hideOnEscape = 1,
    exclusive = 1,
    whileDead = 1,
    hasEditBox = 1,
    preferredIndex = 3,
}

--------------
---- Sets ----
--------------
function AddonListAdv:SaveSet(set, newName)
    --print("SaveSet", set, newName)
    if not set then set, newName = newName, set end
    if newName and dbc[set] then dbc[set] = nil; set = newName end
    --print("SaveSet2", set, newName)
    
    local list
    if set == nibRealUI.class then
        list = dbg[nibRealUI.class]
    else

        list = dbc[set] or {}
    end

    for k, v in next, list do
        --print("SaveSet3", k, v)
        table.remove(list, k)
    end

    local name, enabled, _
    for i = 1, GetNumAddOns() do
        name, _, _, enabled = GetAddOnInfo(i)
        --print("SaveSet4", name, enabled)
        if enabled then
            table.insert(list, name)
        end
    end

    if (set ~= nibRealUI.class) and (not dbc[set]) then
        --print("SaveSet5", list)
        dbc[set] = list
    end
    --print("SaveSet6", dbc[set])
    print(string.format("Addons [%s] Saved.", self:GetSetName(set))) 
end

function AddonListAdv:GetSetName(set)
    --print("GetSetName", set)
    if set == "RealUISet" then
        set = "RealUI"
        return "Set " .. set
    elseif set == nibRealUI.class then
        set = UnitClass("player")
        return "Set " .. set
    elseif dbc[set] then
        return "Set " .. set
    else
        print("Nope!!")
    end
end

function AddonListAdv:UnloadSet(set)
    local list

    if set == "RealUISet" or set == nibRealUI.class then
        list = dbg[set]
    else
        list = dbc[set]
    end

    for i = 1, #list do
        --print("UnloadSet: name", list[i])
        if GetAddOnInfo(list[i]) then
            DisableAddOn(list[i])
        end
    end

    print(string.format("Addons [%s] Unloaded.", self:GetSetName(set)))
    AddonList_Update()
end

function AddonListAdv:ClearSelectionAndLoadSet(set)
    --print("ClearSelectionAndLoadSet", set)
    DisableAllAddOns()
    self:LoadSet(set)
end

function AddonListAdv:LoadSet(set)
    --print("LoadSet", set)
    local list

    if set == "RealUISet" or set == nibRealUI.class then
        list = dbg[set]
    else
        list = dbc[set]
    end

    for i = 1, #list do
        --print("LoadSet: name", list[i])
        if GetAddOnInfo(list[i]) then
            EnableAddOn(list[i])
        end
    end

    print(string.format("Addons [%s] Loaded.", self:GetSetName(set)))
    AddonList_Update()
end
function AddonListAdv:RenameSet(set, name)

    local oldName = self:GetSetName(set)
    if not dbc[set] then dbc[set] = {} end
    dbc[set].name = name

    print(string.format("Addons [%s] renamed to [%s].", oldName, name))

end

function AddonListAdv:SetsOnClick(btn)
    --print("SetsOnClick", self, self.GetName and self:GetName())
    if not AddonList.setsDD then
        --print("Create setsDD")
        AddonList.setsDD = CreateFrame("Frame", "ALAdvSetsDD", nil, "UIDropDownMenuTemplate")
        UIDropDownMenu_Initialize(AddonList.setsDD, AddonListAdv.SetDropDown_Populate, "MENU")--
        --UIDropDownMenu_SetAnchor(AddonList.setsDD, "TOPLEFT", "BOTTOMLEFT")
    end
    ToggleDropDownMenu(1, nil, AddonList.setsDD, AddonList.sets, 0, 0)
end
function AddonListAdv:Skin()
    if not AddonList.sets then 
        AddonList.sets = nibRealUI:CreateTextButton("Sets", AddonList, 100, 22)
        AddonList.sets:SetPoint("LEFT", AddonCharacterDropDownButton, "RIGHT", 10, 0)
        AddonList.sets:SetScript("OnClick", self.SetsOnClick)
    end
    if Aurora then
        local F = Aurora[1]
        F.ReskinScroll(AddonListScrollFrameScrollBar)
    end
end

function AddonListAdv:SetDropDown_Populate(level)
    --print("SetDropDown_Populate", level)
    self = AddonListAdv
    local info

    if level == 1 then
        info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true
        info.hasArrow = true

        -- RealUI set.
        info.text = string.format("%s (%d)", "RealUI", #dbg.RealUISet)
        info.value = "RealUISet"
        UIDropDownMenu_AddButton(info)

        -- Class set.
        info.text = string.format("%s (%d)", UnitClass("player"), #dbg[nibRealUI.class])
        info.value = nibRealUI.class
        UIDropDownMenu_AddButton(info)

        local count
        for set = 1, dbc do
            --print("SetDropDown_Populate", set, dbc[set])
            if dbc and dbc[set] then
                count = #dbc[set]
            else
                count = 0
            end

            info.text = string.format("%s (%d)", set, count)
            info.value = set
            UIDropDownMenu_AddButton(info)
        end

        -- New set.
        info.text = "Create a new set"
        info.hasArrow = false
        info.func = function()
            StaticPopup_Show("ALA_SaveAs", setName)
        end
        UIDropDownMenu_AddButton(info)
    elseif level == 2 then
        info = UIDropDownMenu_CreateInfo()
        local setName = UIDROPDOWNMENU_MENU_VALUE
        info.text = setName
        info.isTitle = true
        info.notCheckable = true
        UIDropDownMenu_AddButton(info, level)

        info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true

        if UIDROPDOWNMENU_MENU_VALUE ~= "RealUISet" then
            info.text = "Save"
            info.func = function() self:SaveSet(setName) end
            UIDropDownMenu_AddButton(info, level)
        end

        info.text = "Load"
        info.func = function() self:ClearSelectionAndLoadSet(UIDROPDOWNMENU_MENU_VALUE) end
        UIDropDownMenu_AddButton(info, level)


        info.text = "Add to current selection"
        info.func = function() self:LoadSet(UIDROPDOWNMENU_MENU_VALUE) end
        UIDropDownMenu_AddButton(info, level)


        info.text = "Remove from current selection"
        info.func = function() self:UnloadSet(UIDROPDOWNMENU_MENU_VALUE) end
        UIDropDownMenu_AddButton(info, level)

        if UIDROPDOWNMENU_MENU_VALUE ~= "RealUISet" and UIDROPDOWNMENU_MENU_VALUE ~= nibRealUI.class then
            info.text = "Rename"
            info.func = function()
                self.savingSet = UIDROPDOWNMENU_MENU_VALUE
                StaticPopup_Show("ALA_SaveAs", setName)
                CloseDropDownMenus(1)
            end
            UIDropDownMenu_AddButton(info, level)
        end
    end
end


-----------------------
function AddonListAdv:RefreshMod()
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end

    --self:UpdatePosition()
end

function AddonListAdv:PLAYER_ENTERING_WORLD()
    --self:ScheduleTimer("UpdatePlayerLocation", 1)
end

function AddonListAdv:PLAYER_LOGIN()
    LoggedIn = true
    self:RefreshMod()
    self:Skin()
end

function AddonListAdv:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        char = {
        },
        global = {
            [nibRealUI.class] = {
                --
            },
            RealUISet = {
                "!Aurora",
                "!BugGrabber",
                "Aurora",
                "BadBoy",
                "BadBoy_CCleaner",
                "BadBoy_Guilded",
                "Bartender4",
                "BugSack",
                "ButtonFacade",
                "cargBags_Nivaya",
                "Chatter",
                "EasyMail",
                "FreebTip",
                "Grid2",
                "Grid2Options",
                "Grid2RaidDebuffs",
                "Grid2RaidDebuffsOptions",
                "Kui_Nameplates",
                "Kui_Nameplates_Auras",
                "Masque",
                "MikScrollingBattleText",
                "MSBTOptions",
                "nibRealUI",
                "Raven",
                "Raven_Options",
                "SharedMedia",
                "Skada",
            },
        },
    })
    dbc = self.db.char
    dbg = self.db.global

    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)

    self:RegisterEvent("PLAYER_LOGIN")
end

function AddonListAdv:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    if LoggedIn then self:RefreshMod() end
end

function AddonListAdv:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
