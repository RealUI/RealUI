-- Credit to Sylvanaar's ACP for much of this code.
local _, private = ...

-- Lua Globals --
local _G = _G
local next, table = _G.next, _G.table

-- RealUI --
local RealUI = private.RealUI
local dbc, dbk, dbg

local MODNAME = "AddonListAdv"
local AddonListAdv = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

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

_G.StaticPopupDialogs["ALA_SaveAs"] = {
    text = "Enter the name for this set.",
    button1 = _G.YES,
    button2 = _G.CANCEL,
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
    --print("GetSet", name)
    local set, db
    if name == RealUI.classLocale then
        if not dbk[1] then
            dbk[1] = {["name"] = RealUI.classLocale}
        end
        set = dbk[1]
    else
        for k, v in next, {dbg, dbc} do
            local setIndex = 0
            repeat
                setIndex = setIndex + 1
                set = v[setIndex]
                --print("repeat", setIndex, v, dbg)
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
    --print("SaveSet", name, newName)
    if not name then
        name = newName
        table.insert(dbc, {["name"] = name,})
    end

    local set = GetSet(name)
    if name and newName then
        -- rename
        return AddonListAdv:RenameSet(set, newName)
    end

    --print("SaveSet2", set, set.name)
    
    for i = 1, #set do
        --print("SaveSet3", i, set[i])
        table.remove(set, i)
    end

    for i = 1, _G.GetNumAddOns() do
        local addonName, _, _, enabled = _G.GetAddOnInfo(i)
        --print("SaveSet4", addonName, enabled)
        if enabled then
            table.insert(set, addonName)
        end
    end

    _G.print(("Set [%s] Saved."):format(set.name))
end

function AddonListAdv:UnloadSet(set)
    --print("UnloadSet", set)
    if _G.type(set) ~= "table" then
        set = GetSet(set)
    end

    for i = 1, #set do
        --print("UnloadSet:", set[i])
        if _G.GetAddOnInfo(set[i]) then
            _G.DisableAddOn(set[i])
        end
    end

    _G.print(("Set [%s] Unloaded."):format(set.name))
    _G.AddonList_Update()
end

function AddonListAdv:DeleteSet(set)
    --print("DeleteSet", set)
    local db
    if _G.type(set) ~= "table" then
        set, db = GetSet(set)
    end

    local setName = set.name
    for i = 1, #db do
        if db[i] == set then
            table.remove(db, i)
        end
    end

    _G.print(("Set [%s] Deleted."):format(setName))
end

function AddonListAdv:ClearSelectionAndLoadSet(name)
    --print("ClearSelectionAndLoadSet", name)
    local set = GetSet(name)

    _G.DisableAllAddOns()
    self:LoadSet(set)
end

function AddonListAdv:LoadSet(set)
    --print("LoadSet", set)
    if _G.type(set) ~= "table" then
        set = GetSet(set)
    end

    for i = 1, #set do
        --print("LoadSet: name", set[i])
        if _G.GetAddOnInfo(set[i]) then
            _G.EnableAddOn(set[i])
        end
    end

    _G.print(("Set [%s] Loaded."):format(set.name))
    _G.AddonList_Update()
end
function AddonListAdv:RenameSet(set, name)
    local oldName = set.name
    set.name = name

    _G.print(("Set [%s] renamed to [%s]."):format(oldName, set.name))
end

function AddonListAdv:SetsOnClick(btn)
    --print("SetsOnClick", self, self.GetName and self:GetName())
    if not _G.AddonList.setsDD then
        --print("Create setsDD")
        _G.AddonList.setsDD = _G.CreateFrame("Frame", "ALAdvSetsDD", nil, "UIDropDownMenuTemplate")
        _G.UIDropDownMenu_Initialize(_G.AddonList.setsDD, AddonListAdv.SetDropDown_Populate, "MENU")--
        --UIDropDownMenu_SetAnchor(AddonList.setsDD, "TOPLEFT", "BOTTOMLEFT")
    end
    _G.ToggleDropDownMenu(1, nil, _G.AddonList.setsDD, _G.AddonList.sets, 0, 0)
end
function AddonListAdv:Skin()
    if not _G.AddonList.sets then 
        _G.AddonList.sets = RealUI:CreateTextButton("Sets", _G.AddonList, 100, 22)
        _G.AddonList.sets:SetPoint("LEFT", _G.AddonCharacterDropDownButton, "RIGHT", 10, 0)
        _G.AddonList.sets:SetScript("OnClick", self.SetsOnClick)
    end
end

function AddonListAdv.SetDropDown_Populate(menu, level)
    --print("SetDropDown_Populate", level)
    local self = AddonListAdv
    local info

    if level == 1 then
        info = _G.UIDropDownMenu_CreateInfo()
        info.notCheckable = true

        --[[ Account Sets ]]
        info.isTitle = true
        info.hasArrow = false
        info.text = "Account Sets"
        _G.UIDropDownMenu_AddButton(info)

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

            info.text = ("%s (%d)"):format(dbg[i].name, count)
            info.value = dbg[i].name
            _G.UIDropDownMenu_AddButton(info)

            if i == 1 then
                -- insert class set after RealUI
                if dbk and dbk[1] then
                    count = #dbk[1]
                else
                    count = 0
                end

                info.text = ("%s (%d)"):format(RealUI.classLocale, count)
                info.value = RealUI.classLocale
                _G.UIDropDownMenu_AddButton(info)
            end
        end

        --[[ Character Sets ]]
        info.isTitle = true
        info.hasArrow = false
        info.text = "Character Sets"
        _G.UIDropDownMenu_AddButton(info)

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

            info.text = ("%s (%d)"):format(dbc[i].name, count)
            info.value = dbc[i].name
            _G.UIDropDownMenu_AddButton(info)
        end

        -- New set.
        info.text = "Create a new set"
        info.hasArrow = false
        info.func = function()
            _G.StaticPopup_Show("ALA_SaveAs")
        end
        _G.UIDropDownMenu_AddButton(info)
    elseif level == 2 then
        info = _G.UIDropDownMenu_CreateInfo()
        local setName = _G.UIDROPDOWNMENU_MENU_VALUE
        info.text = setName
        info.isTitle = true
        info.notCheckable = true
        _G.UIDropDownMenu_AddButton(info, level)

        info = _G.UIDropDownMenu_CreateInfo()
        info.notCheckable = true

        if _G.UIDROPDOWNMENU_MENU_VALUE ~= "RealUI" then
            info.text = "Save"
            info.func = function() self:SaveSet(setName) end
            _G.UIDropDownMenu_AddButton(info, level)
        end

        info.text = "Load"
        info.func = function() self:ClearSelectionAndLoadSet(_G.UIDROPDOWNMENU_MENU_VALUE) end
        _G.UIDropDownMenu_AddButton(info, level)


        info.text = "Add to current selection"
        info.func = function() self:LoadSet(_G.UIDROPDOWNMENU_MENU_VALUE) end
        _G.UIDropDownMenu_AddButton(info, level)


        info.text = "Remove from current selection"
        info.func = function() self:UnloadSet(_G.UIDROPDOWNMENU_MENU_VALUE) end
        _G.UIDropDownMenu_AddButton(info, level)

        if _G.UIDROPDOWNMENU_MENU_VALUE ~= "RealUI" and _G.UIDROPDOWNMENU_MENU_VALUE ~= RealUI.classLocale then
            info.text = "Delete"
            info.func = function() self:DeleteSet(_G.UIDROPDOWNMENU_MENU_VALUE) end
            _G.UIDropDownMenu_AddButton(info, level)

            info.text = "Rename"
            info.func = function()
                self.savingSet = _G.UIDROPDOWNMENU_MENU_VALUE
                _G.StaticPopup_Show("ALA_SaveAs", setName)
                _G.CloseDropDownMenus(1)
            end
            _G.UIDropDownMenu_AddButton(info, level)
        end
    end
end


-----------------------
function AddonListAdv:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

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
    self.db = RealUI.db:RegisterNamespace(MODNAME)
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
                "cargBags_Nivaya",
                "EasyMail",
                "FreebTip",
                "FreebTipiLvl",
                "FreebTipSpec",
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

    self:SetEnabledState(true)
    self:RegisterEvent("PLAYER_LOGIN")
end

function AddonListAdv:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")

    if LoggedIn then self:RefreshMod() end
end

function AddonListAdv:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
