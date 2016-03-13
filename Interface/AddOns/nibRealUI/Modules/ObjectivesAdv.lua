local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local CombatFader = RealUI:GetModule("CombatFader")

local MODNAME = "Objectives Adv."
local ObjectivesAdv = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Objectives Adv.",
        desc = "Reposition the Objective Tracker.",
        childGroups = "tab",
        arg = MODNAME,
        args = {
            header = {
                type = "header",
                name = "Objectives Adv.",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Reposition the Objective Tracker.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Objectives Adv. module.",
                get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value)
                    RealUI:SetModuleEnabled(MODNAME, value)
                    ObjectivesAdv:RefreshMod()
                end,
                order = 30,
            },
            sizeposition = {
                name = "Size/Position",
                type = "group",
                disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                order = 40,
                args = {
                    header = {
                        type = "description",
                        name = "Adjust size and position.",
                        order = 10,
                    },
                    enabled = {
                        type = "toggle",
                        name = "Enabled",
                        get = function(info) return db.position.enabled end,
                        set = function(info, value)
                            db.position.enabled = value
                            ObjectivesAdv:UpdatePosition()
                            RealUI:ReloadUIDialog()
                        end,
                        order = 20,
                    },
                    note1 = {
                        type = "description",
                        name = "Note: Enabling/disabling the size/position adjustments will require a UI Reload to take full effect.",
                        order = 30,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 31,
                    },
                    offsets = {
                        type = "group",
                        name = "Offsets",
                        disabled = function() return not(db.position.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                        inline = true,
                        order = 40,
                        args = {
                            xoffset = {
                                type = "input",
                                name = "X Offset",
                                width = "half",
                                order = 10,
                                get = function(info) return _G.tostring(db.position.x) end,
                                set = function(info, value)
                                    value = RealUI:ValidateOffset(value)
                                    db.position.x = value
                                    ObjectivesAdv:UpdatePosition()
                                end,
                            },
                            yoffset = {
                                type = "input",
                                name = "Y Offset",
                                width = "half",
                                order = 20,
                                get = function(info) return _G.tostring(db.position.y) end,
                                set = function(info, value)
                                    value = RealUI:ValidateOffset(value)
                                    db.position.y = value
                                    ObjectivesAdv:UpdatePosition()
                                end,
                            },
                            negheightoffset = {
                                type = "input",
                                name = "Height Offset",
                                desc = "How much shorter than screen height to make the Quest Watch Frame.",
                                width = "half",
                                order = 30,
                                get = function(info) return _G.tostring(db.position.negheightofs) end,
                                set = function(info, value)
                                    value = RealUI:ValidateOffset(value)
                                    db.position.negheightofs = value
                                    ObjectivesAdv:UpdatePosition()
                                end,
                            },
                        },
                    },
                    gap2 = {
                        name = " ",
                        type = "description",
                        order = 41,
                    },
                    anchor = {
                        type = "group",
                        name = "Position",
                        inline = true,
                        disabled = function() return not(db.position.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                        order = 50,
                        args = {
                            anchorto = {
                                type = "select",
                                name = "Anchor To",
                                get = function(info)
                                    for k,v in next, RealUI.globals.anchorPoints do
                                        if v == db.position.anchorto then return k end
                                    end
                                end,
                                set = function(info, value)
                                    db.position.anchorto = RealUI.globals.anchorPoints[value]
                                    ObjectivesAdv:UpdatePosition()
                                end,
                                style = "dropdown",
                                width = nil,
                                values = RealUI.globals.anchorPoints,
                                order = 10,
                            },
                            anchorfrom = {
                                type = "select",
                                name = "Anchor From",
                                get = function(info)
                                    for k,v in next, RealUI.globals.anchorPoints do
                                        if v == db.position.anchorfrom then return k end
                                    end
                                end,
                                set = function(info, value)
                                    db.position.anchorfrom = RealUI.globals.anchorPoints[value]
                                    ObjectivesAdv:UpdatePosition()
                                end,
                                style = "dropdown",
                                width = nil,
                                values = RealUI.globals.anchorPoints,
                                order = 20,
                            },
                        },
                    },
                },
            },
            hidden = {
                name = "Automatic Collapse/Hide",
                type = "group",
                disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                order = 60,
                args = {
                    header = {
                        type = "description",
                        name = "Automatically collapse the Quest Watch Frame in certain zones.",
                        order = 10,
                    },
                    enabled = {
                        type = "toggle",
                        name = "Enabled",
                        get = function(info) return db.hidden.enabled end,
                        set = function(info, value)
                            db.hidden.enabled = value
                            ObjectivesAdv:UpdateCollapseState()
                        end,
                        order = 20,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 21,
                    },
                    collapse = {
                        type = "group",
                        name = "Collapse the Quest Watch Frame in..",
                        inline = true,
                        disabled = function() return not(RealUI:GetModuleEnabled(MODNAME) and db.hidden.enabled) end,
                        order = 30,
                        args = {
                            arena = {
                                type = "toggle",
                                name = "Arenas",
                                get = function(info) return db.hidden.collapse.arena end,
                                set = function(info, value)
                                    db.hidden.collapse.arena = value
                                    ObjectivesAdv:UpdateCollapseState()
                                end,
                                order = 10,
                            },
                            pvp = {
                                type = "toggle",
                                name = "Battlegrounds",
                                get = function(info) return db.hidden.collapse.pvp end,
                                set = function(info, value)
                                    db.hidden.collapse.pvp = value
                                    ObjectivesAdv:UpdateCollapseState()
                                end,
                                order = 20,
                            },
                            party = {
                                type = "toggle",
                                name = "5 Man Dungeons",
                                get = function(info) return db.hidden.collapse.party end,
                                set = function(info, value)
                                    db.hidden.collapse.party = value
                                    ObjectivesAdv:UpdateCollapseState()
                                end,
                                order = 30,
                            },
                            raid = {
                                type = "toggle",
                                name = "Raid Dungeons",
                                get = function(info) return db.hidden.collapse.raid end,
                                set = function(info, value)
                                    db.hidden.collapse.raid = value
                                    ObjectivesAdv:UpdateCollapseState()
                                end,
                                order = 40,
                            },
                        },
                    },
                    gap2 = {
                        name = " ",
                        type = "description",
                        order = 31,
                    },
                    hide = {
                        type = "group",
                        name = "Hide the Quest Watch Frame completely in..",
                        inline = true,
                        disabled = function() return not(db.hidden.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                        order = 40,
                        args = {
                            arena = {
                                type = "toggle",
                                name = "Arenas",
                                get = function(info) return db.hidden.hide.arena end,
                                set = function(info, value)
                                    db.hidden.hide.arena = value
                                    ObjectivesAdv:UpdateHideState()
                                end,
                                order = 10,
                            },
                            pvp = {
                                type = "toggle",
                                name = "Battlegrounds",
                                get = function(info) return db.hidden.hide.pvp end,
                                set = function(info, value)
                                    db.hidden.hide.pvp = value
                                    ObjectivesAdv:UpdateHideState()
                                end,
                                order = 20,
                            },
                            party = {
                                type = "toggle",
                                name = "5 Man Dungeons",
                                get = function(info) return db.hidden.hide.party end,
                                set = function(info, value)
                                    db.hidden.hide.party = value
                                    ObjectivesAdv:UpdateHideState()
                                end,
                                order = 30,
                            },
                            raid = {
                                type = "toggle",
                                name = "Raid Dungeons",
                                get = function(info) return db.hidden.hide.raid end,
                                set = function(info, value)
                                    db.hidden.hide.raid = value
                                    ObjectivesAdv:UpdateHideState()
                                end,
                                order = 40,
                            },
                        },
                    },
                    --[[fade = {
                        type = "group",
                        name = L["General_CombatFade"],
                        inline = true,
                        order = 40,
                        args = {
                            incombat = {
                                type = "range",
                                name = "In-combat",
                                min = 0, max = 1, step = 0.05,
                                isPercent = true,
                                get = function(info) return db.elements[ke].opacity.outofcombat end,
                                set = function(info, value)
                                    db.elements[ke].opacity.outofcombat = value
                                    CombatFader:OptionsRefresh()
                                end,
                                order = 10,
                            },
                            harmtarget = {
                                type = "range",
                                name = "Attackable Target",
                                min = 0, max = 1, step = 0.05,
                                isPercent = true,
                                get = function(info) return db.elements[ke].opacity.harmtarget end,
                                set = function(info, value)
                                    db.elements[ke].opacity.harmtarget = value
                                    CombatFader:OptionsRefresh()
                                end,
                                order = 20,
                            },
                            outofcombat = {
                                type = "range",
                                name = "Out-of-combat",
                                min = 0, max = 1, step = 0.05,
                                isPercent = true,
                                get = function(info) return db.elements[ke].opacity.incombat end,
                                set = function(info, value)
                                    --print("OutCombat", ke)
                                    db.elements[ke].opacity.incombat = value
                                    CombatFader:OptionsRefresh()
                                end,
                                order = 30,
                            },
                        },
                    },]]
                },
            },
        },
    }
    end
    return options
end

---------------------
-- Collapse / Hide --
---------------------
-- Hide Quest Tracker based on zone
function ObjectivesAdv:UpdateHideState()
    local Hide = false
    local _, instanceType = _G.GetInstanceInfo()

    if db.hidden.enabled and (instanceType ~= "none") and RealUI:GetModuleEnabled(MODNAME) then
        if (instanceType == "pvp" and db.hidden.hide.pvp) then          -- Battlegrounds
            Hide = true
        elseif (instanceType == "arena" and db.hidden.hide.arena) then  -- Arena
            Hide = true
        elseif (((instanceType == "party") or (instanceType == "scenario")) and db.hidden.hide.party) then  -- 5 Man Dungeons
            Hide = true
        elseif (instanceType == "raid" and db.hidden.hide.raid) then    -- Raid Dungeons
            Hide = true
        end
    end
    if Hide then
        self.hidden = true
        _G.ObjectiveTrackerFrame.realUIHidden = true
        _G.ObjectiveTrackerFrame:Hide()
    else
        local oldHidden = self.hidden
        self.hidden = false
        _G.ObjectiveTrackerFrame.realUIHidden = false
        _G.ObjectiveTrackerFrame:Show()

        -- Refresh fade, since fade won't update while hidden
        local CF = RealUI:GetModule("CombatFader", 1)
        if oldHidden and RealUI:GetModuleEnabled("CombatFader") and CF then
            CF:UpdateStatus(true)
        end
    end
end

-- Collapse Quest Tracker based on zone
function ObjectivesAdv:UpdateCollapseState()
    local Collapsed = false
    local instanceName, instanceType = _G.GetInstanceInfo()
    local isInGarrison = instanceName:find("Garrison")

    if db.hidden.enabled and (instanceType ~= "none") and RealUI:GetModuleEnabled(MODNAME) then
        if (instanceType == "pvp" and db.hidden.collapse.pvp) then          -- Battlegrounds
            Collapsed = true
        elseif (instanceType == "arena" and db.hidden.collapse.arena) then  -- Arena
            Collapsed = true
        elseif (((instanceType == "party" and not isInGarrison) or (instanceType == "scenario")) and db.hidden.collapse.party) then -- 5 Man Dungeons
            Collapsed = true
        elseif (instanceType == "raid" and db.hidden.collapse.raid) then    -- Raid Dungeons
            Collapsed = true
        end
    end

    if Collapsed then
        self.collapsed = true
        _G.ObjectiveTrackerFrame.userCollapsed = true
        _G.ObjectiveTracker_Collapse()
    else
        self.collapsed = false
        _G.ObjectiveTrackerFrame.userCollapsed = false
        _G.ObjectiveTracker_Expand()
    end
end

function ObjectivesAdv:UpdatePlayerLocation()
    self:UpdateCollapseState()
    self:UpdateHideState()
end

------------------
---- Position ----
------------------
-- Position
function ObjectivesAdv:UpdatePosition()
    if not (db.position.enabled and RealUI:GetModuleEnabled(MODNAME)) then return end

    if not self.origSet then
        self.origSet = _G.ObjectiveTrackerFrame.SetPoint
        self.origClear = _G.ObjectiveTrackerFrame.ClearAllPoints

        _G.ObjectiveTrackerFrame.SetPoint = function() end
        _G.ObjectiveTrackerFrame.ClearAllPoints = function() end
    end

    self.origClear(_G.ObjectiveTrackerFrame)
    self.origSet(_G.ObjectiveTrackerFrame, db.position.anchorfrom, "UIParent", db.position.anchorto, db.position.x, db.position.y)

    _G.ObjectiveTrackerFrame:SetHeight(_G.UIParent:GetHeight() - db.position.negheightofs)

    --ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "TOPRIGHT", -12, -1)
end


-----------------------
function ObjectivesAdv:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    self:UpdatePosition()
end

function ObjectivesAdv:UI_SCALE_CHANGED()
    self:UpdatePosition()
end

function ObjectivesAdv:PLAYER_ENTERING_WORLD()
    ObjectivesAdv:UpdatePlayerLocation()
end

function ObjectivesAdv:PLAYER_LOGIN()
    LoggedIn = true
    self:RefreshMod()
    --self:Skin()
end

function ObjectivesAdv:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            position = {
                enabled = true,
                anchorto = "TOPRIGHT",
                anchorfrom = "TOPRIGHT",
                x = -32,
                y = -200,
                negheightofs = 300,
            },
            hidden = {
                enabled = true,
                collapse = {
                    pvp = true,
                    arena = false,
                    party = true,
                    raid = false,
                },
                hide = {
                    pvp = false,
                    arena = true,
                    party = false,
                    raid = true,
                },
                combatfade = {
                    enabled = true,
                    opacity = {
                        incombat = 0.25,
                        hurt = .75,
                        target = .75,
                        harmtarget = 0.85,
                        outofcombat = 1,
                    },
                },
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    RealUI:RegisterModuleOptions(MODNAME, GetOptions)

    CombatFader:RegisterModForFade(MODNAME, db.hidden.combatfade)
    CombatFader:RegisterFrameForFade(MODNAME, _G.ObjectiveTrackerFrame)

    self:RegisterEvent("PLAYER_LOGIN")
end

function ObjectivesAdv:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UI_SCALE_CHANGED")

    if LoggedIn then self:RefreshMod() end
end

function ObjectivesAdv:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("UI_SCALE_CHANGED")
end
