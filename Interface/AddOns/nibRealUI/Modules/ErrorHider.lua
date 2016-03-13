local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "ErrorHider"
local ErrorHider = RealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Blacklist filter.
local FilterList = {
    _G.INTERRUPTED,
    _G.ERR_ABILITY_COOLDOWN,
    _G.ERR_ATTACK_CHANNEL,
    _G.ERR_ATTACK_CHARMED,
    _G.ERR_ATTACK_CONFUSED,
    _G.ERR_ATTACK_DEAD,
    _G.ERR_ATTACK_FLEEING,
    _G.ERR_ATTACK_MOUNTED,
    _G.ERR_ATTACK_PACIFIED,
    _G.ERR_ATTACK_STUNNED,
    _G.ERR_AUTOFOLLOW_TOO_FAR,
    _G.ERR_BADATTACKFACING,
    _G.ERR_BADATTACKPOS,
    _G.ERR_CLIENT_LOCKED_OUT,
    _G.ERR_GENERIC_NO_TARGET,
    _G.ERR_GENERIC_NO_VALID_TARGETS,
    _G.ERR_GENERIC_STUNNED,
    _G.ERR_INVALID_ATTACK_TARGET,
    _G.ERR_ITEM_COOLDOWN,
    _G.ERR_NOEMOTEWHILERUNNING,
    _G.ERR_NOT_IN_COMBAT,
    _G.ERR_NOT_WHILE_DISARMED,
    _G.ERR_NOT_WHILE_FALLING,
    _G.ERR_NOT_WHILE_MOUNTED,
    _G.ERR_NO_ATTACK_TARGET,
    _G.ERR_OUT_OF_ENERGY,
    _G.ERR_OUT_OF_FOCUS,
    _G.ERR_OUT_OF_MANA,
    _G.ERR_OUT_OF_RAGE,
    _G.ERR_OUT_OF_RANGE,
    _G.ERR_OUT_OF_RUNES,
    _G.ERR_OUT_OF_RUNIC_POWER,
    _G.ERR_OUT_OF_HOLY_POWER,
    _G.SPELL_FAILED_CUSTOM_ERROR_153,
    _G.ERR_SPELL_COOLDOWN,
    _G.ERR_SPELL_OUT_OF_RANGE,
    _G.ERR_TOO_FAR_TO_INTERACT,
    _G.ERR_USE_BAD_ANGLE,
    _G.ERR_USE_CANT_IMMUNE,
    _G.ERR_USE_TOO_FAR,
    _G.SPELL_FAILED_BAD_IMPLICIT_TARGETS,
    _G.SPELL_FAILED_BAD_TARGETS,
    _G.SPELL_FAILED_CASTER_AURASTATE,
    _G.SPELL_FAILED_NO_COMBO_POINTS,
    _G.SPELL_FAILED_SPELL_IN_PROGRESS,
    _G.SPELL_FAILED_TARGET_AURASTATE,
    _G.SPELL_FAILED_MOVING,
    _G.SPELL_FAILED_UNIT_NOT_INFRONT,
}

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Error Hider",
        desc = "Hide specific error messages.",
        arg = MODNAME,
        -- order = 518,
        args = {
            header = {
                type = "header",
                name = "Error Hider",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Hide specific error messages.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Error Hider module.",
                get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value) 
                    RealUI:SetModuleEnabled(MODNAME, value)
                end,
                order = 30,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 31,
            },
        },
    }
    end
    
    -- Create Filter List options table
    local filteropts = {
        name = "Filter List",
        type = "group",
        inline = true,
        disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
        order = 40,
        args = {
            note = {
                type = "description",
                name = "Ticked = Hidden",
                fontSize = "medium",
                order = 10,
            },
            hideall = {
                type = "toggle",
                name = "Hide All",
                desc = "Hide all error messages.",
                get = function() return db.hideall end,
                set = function(info, value) 
                    db.hideall = value
                end,
                order = 20,
            },
            sep = {
                type = "description",
                name = " ",
                fontSize = "medium",
                order = 30,
            },
        },
    }
    local filterordercnt = 40   
    for k_f,v_f in next, FilterList do
        -- Create base options for Addons
        filteropts.args[v_f] = {
            type = "toggle",
            name = v_f,
            width = "full",
            get = function(info) return db.filterlist[v_f] end,
            set = function(info, value)
                db.filterlist[v_f] = value
            end,
            order = filterordercnt,
            disabled = function() return db.hideall or (not RealUI:GetModuleEnabled(MODNAME)) end,
        }
        filterordercnt = filterordercnt + 10
    end
    
    options.args.filterlist = filteropts
    return options
end

function ErrorHider:UI_ERROR_MESSAGE(event, err)
    if err == "" then return end
    if not db.filterlist[err] and not db.hideall then
        _G.UIErrorsFrame:AddMessage(err, 1, 0, 0)
    end
end

----
function ErrorHider:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            hideall = false,
            filterlist = {
                [_G.INTERRUPTED] = false,
                [_G.ERR_ABILITY_COOLDOWN] = true,
                [_G.ERR_ATTACK_CHANNEL] = false,
                [_G.ERR_ATTACK_CHARMED] = false,
                [_G.ERR_ATTACK_CONFUSED] = false,
                [_G.ERR_ATTACK_DEAD] = false,
                [_G.ERR_ATTACK_FLEEING] = false,
                [_G.ERR_ATTACK_MOUNTED] = true,
                [_G.ERR_ATTACK_PACIFIED] = false,
                [_G.ERR_ATTACK_STUNNED] = false,
                [_G.ERR_AUTOFOLLOW_TOO_FAR] = false,
                [_G.ERR_BADATTACKFACING] = false,
                [_G.ERR_BADATTACKPOS] = true,
                [_G.ERR_CLIENT_LOCKED_OUT] = false,
                [_G.ERR_GENERIC_NO_TARGET] = true,
                [_G.ERR_GENERIC_NO_VALID_TARGETS] = true,
                [_G.ERR_GENERIC_STUNNED] = false,
                [_G.ERR_INVALID_ATTACK_TARGET] = true,
                [_G.ERR_ITEM_COOLDOWN] = true,
                [_G.ERR_NOEMOTEWHILERUNNING] = false,
                [_G.ERR_NOT_IN_COMBAT] = false,
                [_G.ERR_NOT_WHILE_DISARMED] = false,
                [_G.ERR_NOT_WHILE_FALLING] = false,
                [_G.ERR_NOT_WHILE_MOUNTED] = false,
                [_G.ERR_NO_ATTACK_TARGET] = true,
                [_G.ERR_OUT_OF_ENERGY] = true,
                [_G.ERR_OUT_OF_FOCUS] = true,
                [_G.ERR_OUT_OF_MANA] = true,
                [_G.ERR_OUT_OF_RAGE] = true,
                [_G.ERR_OUT_OF_RANGE] = true,
                [_G.ERR_OUT_OF_RUNES] = true,
                [_G.ERR_OUT_OF_RUNIC_POWER] = true,
                [_G.ERR_OUT_OF_HOLY_POWER] = true,
                [_G.SPELL_FAILED_CUSTOM_ERROR_153] = true,
                [_G.ERR_SPELL_COOLDOWN] = true,
                [_G.ERR_SPELL_OUT_OF_RANGE] = false,
                [_G.ERR_TOO_FAR_TO_INTERACT] = false,
                [_G.ERR_USE_BAD_ANGLE] = false,
                [_G.ERR_USE_CANT_IMMUNE] = false,
                [_G.ERR_USE_TOO_FAR] = false,
                [_G.SPELL_FAILED_BAD_IMPLICIT_TARGETS] = true,
                [_G.SPELL_FAILED_BAD_TARGETS] = true,
                [_G.SPELL_FAILED_CASTER_AURASTATE] = false,
                [_G.SPELL_FAILED_NO_COMBO_POINTS] = true,
                [_G.SPELL_FAILED_SPELL_IN_PROGRESS] = true,
                [_G.SPELL_FAILED_TARGET_AURASTATE] = true,
                [_G.SPELL_FAILED_MOVING] = false,
                [_G.SPELL_FAILED_UNIT_NOT_INFRONT] = false,
            },
        },
    })
    db = self.db.profile
    
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    RealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function ErrorHider:OnEnable()
    self:RegisterEvent("UI_ERROR_MESSAGE")
    _G.UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
end

function ErrorHider:OnDisable()
    self:UnregisterEvent("UI_ERROR_MESSAGE")
    _G.UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
end
