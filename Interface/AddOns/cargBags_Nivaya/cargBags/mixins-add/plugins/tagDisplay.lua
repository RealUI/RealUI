--[[
LICENSE
    cargBags: An inventory framework addon for World of Warcraft

    Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

    cargBags is free software; you can redistribute it and/or
    modify it under the terms of the GNU General Public License
    as published by the Free Software Foundation; either version 2
    of the License, or (at your option) any later version.

    cargBags is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with cargBags; if not, write to the Free Software
    Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION
    An infotext-module which can display several things based on tags.

    Supported tags:
        space - specify a formatstring as arg #1, using "free" / "max" / "used"
        item - count of the item in arg #1 (itemID, itemLink, itemName)
            shards - "sub-tag" of item, displays soul shard info
        ammo - count of ammo slot
        currency - displays the currency with id arg #1
            currencies - displays all tracked currencies
        money - formatted money display

    The space-tag still needs .bags defined in the plugin!
    e.g. tagDisplay.bags = cargBags:ParseBags("backpack+bags")

DEPENDENCIES
    mixins/api-common.lua

CALLBACKS
    :OnTagUpdate(event) - When the tag is updated
]]
local _, ns = ...
local cargBags = ns.cargBags

-- Lua Globals --
local _G = _G
local next = _G.next

local tagPool, tagEvents, object = {}, {}
local function tagger(tag, ...) return object.tags[tag] and object.tags[tag](object, ...) or "" end

-- Update the space display
local function updater(self, event)
    object = self
    self:SetText(self.tagString:gsub("%[([^%]:]+):?(.-)%]", tagger))
    
    if(self.OnTagUpdate) then self:OnTagUpdate(event) end
end

local function setTagString(self, tagString)
    self.tagString = tagString
    for tag in tagString:gmatch("%[([^%]:]+):?.-]") do
        if self.tagEvents[tag] then
            for k, event in next, self.tagEvents[tag] do
                self.implementation:RegisterEvent(event, self, updater)
            end
        end
    end
end

cargBags:RegisterPlugin("TagDisplay", function(self, tagString, parent)
    parent = parent or self
    tagString = tagString or ""

    local plugin = parent:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    plugin.implementation = self.implementation
    plugin.SetTagString = setTagString
    plugin.tags = tagPool
    plugin.tagEvents = tagEvents
    plugin.iconValues = "16:16:0:0"
    plugin.forceEvent = function(event) updater(plugin, event) end

    setTagString(plugin, tagString)

    self.implementation:RegisterEvent("BAG_UPDATE", plugin, updater)
    return plugin
end)

local function createIcon(icon, iconValues)
    if _G.type(iconValues) == "table" then
        iconValues = _G.table.concat(iconValues, ":")
    end
    return ("|T%s:%s|t"):format(icon, iconValues)
end


-- Tags

tagPool["space"] = function(self, str)
    local free,max = 0, 0
    if self.bags then
        for _,id in next, self.bags do
            free = free + _G.GetContainerNumFreeSlots(id)
            max = max + _G.GetContainerNumSlots(id)
        end
    end
    str = str or "free/max"
    return str:gsub("free", free):gsub("max", max):gsub("used", max-free)
end

tagPool["item"] = function(self, item)
    local bags = _G.GetItemCount(item, nil)
    local total = _G.GetItemCount(item, true)
    local bank = total - bags

    if total > 0 then
        return bags .. (bank and " ("..bank..")") .. createIcon(_G.GetItemIcon(item), self.iconValues)
    end
end

tagPool["currency"] = function(self, id)
    local _, count, icon = _G.GetBackpackCurrencyInfo(id)

    if count then
        return count .. createIcon(icon, self.iconValues)
    end
end
tagEvents["currency"] = { "CURRENCY_DISPLAY_UPDATE" }

tagPool["currencies"] = function(self)
    local str
    for i = 1, _G.GetNumWatchedTokens() do
        local curr = self.tags["currency"](self, i)
        if curr then
            str = (str and str.." " or "")..curr
        end
    end
    return str
end
tagEvents["currencies"] = tagEvents["currency"]

tagPool["money"] = function(self)
    return _G.GetMoneyString(_G.GetMoney(), true)
end
tagEvents["money"] = { "PLAYER_MONEY" }
