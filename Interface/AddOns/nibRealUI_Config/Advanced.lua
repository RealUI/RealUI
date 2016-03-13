--[[local _, private = ...
local options = private.options
local CloseHuDWindow = private.CloseHuDWindow
local debug = private.debug

-- Lua Globals --
local _G = _G
local tostring, next = _G.tostring, _G.next

-- Libs --
local ACD = LibStub("AceConfigDialog-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local ndb = RealUI.db.profile
local ndbc = RealUI.db.char
local hudSize = ndb.settings.hudSize
local round = RealUI.Round

local uiWidth, uiHeight = UIParent:GetSize()

options.RealUI = {
    type = "group",
    args = {
        enable = {
            name = "Enable",
            desc = "Enables / disables the addon",
            type = "toggle",
            set = function(info,val) end,
            get = function(info) end
        },
        moreoptions = {
            name = "More Options",
            type = "group",
            args = {
                -- more options go here
            }
        }
    }
}]]
