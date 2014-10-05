-- Credit to Sylvanaar's ACP for much of this code.
local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local dbc, dbk, dbg

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
local function GetSet(name)
    print("GetSet", name)
    local set, db
    if name == nibRealUI.classLocale then
        if not dbk[1] then
            dbk[1] = {["name"] = nibRealUI.classLocale}
        end
        set = dbk[1]
    else
        for k, v in next, {dbg, dbc} do
            local setIndex = 0
            repeat
                setIndex = setIndex + 1
                set = v[setIndex]
                print("repeat", setIndex, v, dbg)
            until not set or set.name == name
            if set then
                db = v
                break
            end
        end
    end
    return set, db
end

function AddonListAdv:SaveSet(name, newName)
    print("SaveSet", name, newName)
    if not name then
        name = newName
        table.insert(dbc, {["name"] = name,})
    end

    local set = GetSet(name)
    if name and newName then
        -- rename
        return AddonListAdv:RenameSet(set, newName)
    end

    print("SaveSet2", set, set.name)
    
    for i = 1, #set do
        print("SaveSet3", i, set[i])
        table.remove(set, i)
    end

    local name, enabled, _
    for i = 1, GetNumAddOns() do
        name, _, _, enabled = GetAddOnInfo(i)
        print("SaveSet4", name, enabled)
        if enabled then
            table.insert(set, name)
        end
    end

    print(("Set [%s] Saved."):format(set.name))
end

function AddonListAdv:UnloadSet(set)
    print("UnloadSet", set)
    if type(set) ~= "table" then
        set = GetSet(set)
    end

    for i = 1, #set do
        --print("UnloadSet:", set[i])
        if GetAddOnInfo(set[i]) then
            DisableAddOn(set[i])
        end
    end

    print(string.format("Set [%s] Unloaded.", set.name))
    AddonList_Update()
end

function AddonListAdv:DeleteSet(set)
    print("DeleteSet", set)
    local db
    if type(set) ~= "table" then
        set, db = GetSet(set)
    end

    local setName = set.name
    for i = 1, #db do
        if db[i] == set then
            table.remove(db, i)
        end
    end

    print(string.format("Set [%s] Deleted.", setName))
end

function AddonListAdv:ClearSelectionAndLoadSet(name)
    print("ClearSelectionAndLoadSet", name)
    local set = GetSet(name)

    DisableAllAddOns()
    self:LoadSet(set)
end

function AddonListAdv:LoadSet(set)
    print("LoadSet", set)
    if type(set) ~= "table" then
        set = GetSet(set)
    end

    for i = 1, #set do
        --print("LoadSet: name", set[i])
        if GetAddOnInfo(set[i]) then
            EnableAddOn(set[i])
        end
    end

    print(string.format("Set [%s] Loaded.", set.name))
    AddonList_Update()
end
function AddonListAdv:RenameSet(set, name)
    local oldName = set.name
    set.name = name

    print(string.format("Set [%s] renamed to [%s].", oldName, set.name))
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
end

function AddonListAdv:SetDropDown_Populate(level)
    --print("SetDropDown_Populate", level)
    self = AddonListAdv
    local info

    if level == 1 then
        info = UIDropDownMenu_CreateInfo()
        info.notCheckable = true

        --[[ Account Sets ]]
        info.isTitle = true
        info.hasArrow = false
        info.text = "Account Sets"
        UIDropDownMenu_AddButton(info)

        info.isTitle = false
        info.disabled = false
        info.hasArrow = true
        local count
        for i = 1, #dbg do
            --print("SetDropDown_Populate", i, dbg[i])

            if dbg and dbg[i] then
                count = #dbg[i]
            else
                count = 0
            end

            info.text = string.format("%s (%d)", dbg[i].name, count)
            info.value = dbg[i].name
            UIDropDownMenu_AddButton(info)

            if i == 1 then
                -- insert class set after RealUI
                if dbk and dbk[1] then
                    count = #dbk[1]
                else
                    count = 0
                end

                info.text = string.format("%s (%d)", nibRealUI.classLocale, count)
                info.value = nibRealUI.classLocale
                UIDropDownMenu_AddButton(info)
            end
        end

        --[[ Character Sets ]]
        info.isTitle = true
        info.hasArrow = false
        info.text = "Character Sets"
        UIDropDownMenu_AddButton(info)

        info.isTitle = false
        info.disabled = false
        info.hasArrow = true
        for i = 1, #dbc do
            --print("SetDropDown_Populate", i, dbc[i])
            if dbc and dbc[i] then
                count = #dbc[i]
            else
                count = 0
            end

            info.text = string.format("%s (%d)", dbc[i].name, count)
            info.value = dbc[i].name
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

        if UIDROPDOWNMENU_MENU_VALUE ~= "RealUI" then
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

        if UIDROPDOWNMENU_MENU_VALUE ~= "RealUI" and UIDROPDOWNMENU_MENU_VALUE ~= nibRealUI.classLocale then
            info.text = "Delete"
            info.func = function() self:DeleteSet(UIDROPDOWNMENU_MENU_VALUE) end
            UIDropDownMenu_AddButton(info, level)

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

    self:Skin()
end

function AddonListAdv:PLAYER_ENTERING_WORLD()
    --self:ScheduleTimer("UpdatePlayerLocation", 1)
end

function AddonListAdv:PLAYER_LOGIN()
    LoggedIn = true
    self:RefreshMod()
end

function AddonListAdv:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        char = {
        },
        class = {
        },
        global = {
            {
                name = "RealUI",
                "!Aurora_RealUI",
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
    dbk = self.db.class
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
