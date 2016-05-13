local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local db

if RealUI.isBeta then return end

local MODNAME = "ErrorHider"
local ErrorHider = RealUI:NewModule(MODNAME, "AceEvent-3.0")

function ErrorHider:UI_ERROR_MESSAGE(event, messageType, message)
    self:debug(event, messageType, message)
    if message == "" then return end
    self:debug("Hide", db.hideall, db.filterlist[message])
    if not db.filterlist[message] and not db.hideall then
        _G.UIErrorsFrame:AddMessage(message, 1, 0, 0)
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
end

function ErrorHider:OnEnable()
    self:RegisterEvent("UI_ERROR_MESSAGE")
    _G.UIErrorsFrame:UnregisterEvent("UI_ERROR_MESSAGE")
end

function ErrorHider:OnDisable()
    self:UnregisterEvent("UI_ERROR_MESSAGE")
    _G.UIErrorsFrame:RegisterEvent("UI_ERROR_MESSAGE")
end
