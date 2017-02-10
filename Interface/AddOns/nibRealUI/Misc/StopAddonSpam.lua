-- Concepts taken from !StopTheSpam
local _, private = ...

-- Lua Globals --
local ipairs = _G.ipairs

-- RealUI --
local RealUI = private.RealUI

local StopAddonSpam = RealUI:NewModule("StopAddonSpam", "AceEvent-3.0", "AceHook-3.0")

local ALLOW = 1
local DENY  = 0

-- Filter
StopAddonSpam.ruleset = {
    order = {
        -- Allowed addons.
        "warmup",
        "buggrabber",
        -- Global deny.
        -- Denied addons.
        -- Late loading denied addons.
        "ace",
        "dkptable",
        -- Uncommon denies.
        "timeplayed",
        "skinner",
        -- Default fallthrough.
        "default"
    },
    -- The order of the rules here does not matter.
    rules = {
        ["warmup"] = {
            test = function (msg, id, frame) return _G.WarmupFrame and frame == _G.WarmupFrame end,
            invalidate = true,
            action = ALLOW
        },
        ["buggrabber"] = {
            test = function (msg, id, frame) return _G.BugGrabber and frame == _G.BugGrabber end,
            invalidate = true,
            action = ALLOW
        },
        ["ace"] = {
            test = function (msg, id, frame) return _G.AceEventFrame and frame == _G.AceEventFrame end,
            invalidate = true,
            action = DENY
        },
        ["dkptable"] = {
            test = function (msg, id, frame) return _G.DKPT_Main_Frame and frame == _G.DKPT_Main_Frame end,
            expire = 1,
            action = DENY
        },
        ["timeplayed"] = {
            test = function (msg, id, frame) return msg:lower():find(_G.TIME_PLAYED_MSG:lower()) end,
            action = DENY
        },
        ["skinner"] = {
            test = function (msg, id, frame) return msg:lower():find(("skinner:"):lower()) end,
            action = DENY
        },
        ["default"] = {
            action = ALLOW
        }
    }
}

function StopAddonSpam:Release()
    self:Unhook(_G.ChatFrame1, "AddMessage")
    self:Unhook(_G.ChatFrame2, "AddMessage")
    self.ruleset = nil
end

function StopAddonSpam:End(event)
    self:UnregisterEvent(event)
    self:Release()
end

-- Determine if message is spam
function StopAddonSpam:IsMessageSpam(msg, id, frame)
    local ruleset = self.ruleset

    if not msg then return end

    for i, name in ipairs(ruleset.order) do
        local rule = ruleset.rules[name]
        -- If the rule tests true then there is a match. The absence of a test implies a positive match.
        local match = not rule.test or rule.test(msg, id, frame)

        -- The rule matches but it may not actually be spam.
        if match then
            -- Update the expiration count and handle expired rules if necessary.
            if rule.expire then
                if rule.expire <= 1 then
                    _G.table.remove(ruleset.order, i)
                else
                    rule.expire = rule.expire - 1
                end
            end

            -- If this is a deny rule, then this message is spam.
            return rule.action == DENY
        -- If the rule returned nil, then it is invalid.
        elseif match == nil then -- Must explicitly test for nil!
            -- If the rule is set to invalidate then it should be removed from further tests.
            if rule.invalidate then
                _G.table.remove(ruleset.order, i)
            end
        end
    end
end

-- Filter out messages
function StopAddonSpam:AddMessage(obj, msg, r, g, b, id)
    if not self:IsMessageSpam(msg, id, obj) then
        -- Let the message pass through.
        self.hooks[obj].AddMessage(obj, msg, r, g, b, id)
    end
end

-- Basic Filter
local function ChatFilter(self, event, arg1)
    if arg1:find(_G.ERR_SPELL_UNLEARNED_S:sub(1, _G.ERR_SPELL_UNLEARNED_S:len() - 3)) or
      arg1:find(_G.ERR_LEARN_SPELL_S:sub(1, _G.ERR_LEARN_SPELL_S:len() - 3)) or
      arg1:find(_G.ERR_LEARN_ABILITY_S:sub(1, _G.ERR_LEARN_ABILITY_S:len() - 3)) or
      arg1:find(_G.ERR_PET_SPELL_UNLEARNED_S:sub(1, _G.ERR_PET_SPELL_UNLEARNED_S:len() - 3)) then
        return true
    end
end

-- Hook Chat and register End event
function StopAddonSpam:Start()
    -- Hook the default chat frame's AddMessage method.
    self:RawHook(_G.ChatFrame1, "AddMessage", true)

    -- Hook the combat log frame's AddMessage method to catch Gatherer.
    self:RawHook(_G.ChatFrame2, "AddMessage", true)

    -- Register for a late-firing event that happens on startup or reload.
    self:RegisterEvent("UPDATE_PENDING_MAIL", "End")

    -- Set up basic chat filter
    _G.ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", ChatFilter)
end

StopAddonSpam:Start()
