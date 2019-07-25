-- Credit to Sylvanaar's ACP for much of this code.
local _, private = ...

-- Lua Globals --
-- luacheck: globals next unpack table wipe

-- Libs --
local LDD = _G.LibStub("LibDropDown")

-- RealUI --
local RealUI = private.RealUI
local dbc, dbk, dbg

local MODNAME = "AddonListAdv"
local AddonListAdv = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false
local classInfo

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

local RealUISet = {
    name = "RealUI",
    "BadBoy",
    "BadBoy_CCleaner",
    "BadBoy_Guilded",
    "Bartender4",
    "cargBags_Nivaya",
    "Grid2",
    "Grid2Options",
    "Grid2RaidDebuffs",
    "Grid2RaidDebuffsOptions",
    "Kui_Nameplates",
    "Kui_Nameplates_Core",
    "Masque",
    "MikScrollingBattleText",
    "MSBTOptions",
    "nibRealUI",
    "nibRealUI_Config",
    "Raven",
    "Raven_Options",
    "RealUI_Bugs",
    "RealUI_Skins",
    "RealUI_Tooltips",
    "Skada",
}

--------------
---- Sets ----
--------------
local function GetSet(name)
    --print("GetSet", name)
    if name == RealUISet.name then
        return RealUISet
    elseif name == classInfo.locale then
        if not dbk[1] then
            dbk[1] = {["name"] = classInfo.locale}
        end
        return dbk[1]
    else
        local set, db
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
        return set, db
    end
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

local setsButton = RealUI:CreateTextButton("Sets", _G.AddonList, 100, 22)
setsButton:SetPoint("LEFT", _G.AddonCharacterDropDownButton, "RIGHT", 10, 0)
setsButton:SetScript("OnClick", function(self)
    self.menu:ClearLines()
    self.menu:GetMenuList()
    self.menu:Toggle()
end)

local setsMenu = LDD:NewMenu(setsButton, "RealUIAddonListDropDown")
setsMenu:SetAnchor("TOPLEFT", setsButton, "BOTTOMLEFT", 5, -5)
setsButton.menu = setsMenu

local info = {}
local function GetSetOptions(setName)
    local menu = {
        {text = setName,
            isTitle = true
        },
        {text = "Load",
            func = function() AddonListAdv:ClearSelectionAndLoadSet(setName) end
        },
        {text = "Add to current selection",
            func = function() AddonListAdv:LoadSet(setName) end
        },
        {text = "Remove from current selection",
            func = function() AddonListAdv:UnloadSet(setName) end
        },
    }

    if setName ~= RealUISet.name then
        table.insert(menu, 2, {
            text = "Save",
            func = function() AddonListAdv:SaveSet(setName) end
        })
    end

    if setName ~= RealUISet.name and setName ~= classInfo.locale then
        table.insert(menu, {
            text = "Delete",
            func = function() AddonListAdv:DeleteSet(setName) end
        })

        table.insert(menu, {
            text = "Rename",
            func = function()
                AddonListAdv.savingSet = setName
                _G.StaticPopup_Show("ALA_SaveAs", setName)
                LDD:CloseAll()
            end
        })
    end
    return menu
end
function setsMenu:GetMenuList()
    --[[ Account Sets ]]--
    wipe(info)
    info.isTitle = true
    info.text = "Account Sets"
    setsMenu:AddLine(info)


    -- RealUI --
    wipe(info)
    local count = #RealUISet
    info.text = ("%s (%d)"):format(RealUISet.name, count)
    info.menu = GetSetOptions(RealUISet.name)
    setsMenu:AddLine(info)


    -- Class --
    wipe(info)
    if dbk and dbk[1] then
        count = #dbk[1]
    else
        count = 0
    end

    info.text = ("%s (%d)"):format(classInfo.locale, count)
    info.value = classInfo.locale
    info.menu = GetSetOptions(classInfo.locale)
    setsMenu:AddLine(info)

    -- Global --
    for i = 1, #dbg do
        --print("SetDropDown_Populate", i, dbg[i])

        if dbg and dbg[i] then
            count = #dbg[i]
        else
            count = 0
        end

        info.text = ("%s (%d)"):format(dbg[i].name, count)
        info.value = dbg[i].name
        setsMenu:AddLine(info)
    end


    --[[ Character Sets ]]--
    wipe(info)
    info.text = "Character Sets"
    info.isTitle = true
    setsMenu:AddLine(info)

    for i = 1, #dbc do
        wipe(info)
       --print("SetDropDown_Populate", i, dbc[i])
        if dbc and dbc[i] then
            count = #dbc[i]
        else
            count = 0
        end

        info.text = ("%s (%d)"):format(dbc[i].name, count)
        info.value = dbc[i].name
        info.menu = GetSetOptions(dbc[i].name)
        setsMenu:AddLine(info)
    end


    -- New Set --
    wipe(info)
    info.text = "Create a new set"
    info.func = function()
        _G.StaticPopup_Show("ALA_SaveAs")
    end
    setsMenu:AddLine(info)
end


-----------------------
function AddonListAdv:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
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
        },
    })
    dbc = self.db.char
    dbk = self.db.class
    dbg = self.db.global

    if dbg[1] and dbg[1].name == "RealUI" then
        dbg[1] = nil
    end

    classInfo = RealUI.charInfo.class

    if RealUI.isDev then
        local function AddOptDeps(optDeps)
            for i = 1, #optDeps do
                RealUISet[#RealUISet + 1] = optDeps[i]
            end
        end

        AddOptDeps({_G.GetAddOnOptionalDependencies("nibRealUI")})
        AddOptDeps({_G.GetAddOnOptionalDependencies("nibRealUI_Config")})
        AddOptDeps({_G.GetAddOnOptionalDependencies("RealUI_Bugs")})
        AddOptDeps({_G.GetAddOnOptionalDependencies("RealUI_Skins")})
        AddOptDeps({_G.GetAddOnOptionalDependencies("RealUI_Tooltips")})
    end

    self:SetEnabledState(true)
    self:RegisterEvent("PLAYER_LOGIN")
end

function AddonListAdv:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    _G.UIDropDownMenu_SetSelectedValue(_G.AddonCharacterDropDown, RealUI.charInfo.name)

    setsMenu:SetStyle("REALUI")
    if LoggedIn then self:RefreshMod() end
end

function AddonListAdv:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
end
