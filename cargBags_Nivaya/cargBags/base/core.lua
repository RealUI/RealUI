--[[
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
    class-generation, helper-functions and the Blizzard-replacement.
]]
local ADDON_NAME, ns = ...

-- Lua Globals --
local next = _G.next

--- @class table
--  @name cargBags
--  This class provides the underlying fundamental functions, such as
--  class-generation, helper-functions and the Blizzard-replacement
local cargBags = _G.CreateFrame("Button")
ns.cargBags = cargBags

cargBags.debug = _G.RealUI.GetDebug("cargBags")

local global = _G.GetAddOnMetadata(ADDON_NAME, 'X-cargBags')
if global then
    _G[global] = cargBags
end

cargBags.classes = {} --- <table> Holds all classes by their name
cargBags.itemKeys = {} --- <table> Holds all ItemKeys by their name

local widgets = _G.setmetatable({}, {
    __index = function(self, widget)
        self[widget] = _G.getmetatable(_G.CreateFrame(widget))
        return self[widget]
    end
})

--- Creates a new class
--  @param name <string> The name of the class
--  @param parent <string> The class which should be inherited [optional]
--  @param widget <string> The widget type of the class
--  @return class <table> The prototype of the class
function cargBags:NewClass(name, parent, widget)
    if self.classes[name] then return end
    parent = parent and self.classes[parent]
    local class = _G.setmetatable({}, parent or (widget and widgets[widget]))
    class.__index = class
    class._parent = parent
    self.classes[name] = class
    return class
end

--- Creates a new instance of the class 'Implementation'
--  @param name <string> The name of the implementation
--  @return instance <Implementation> The new instance
function cargBags:NewImplementation(name)
    return self.classes.Implementation:New(name)
end

--- Fetches an existing Implementation
--  @param name <string> The name of the implementation
--  @return instance <Implementation> The instance (or 'nil' if not found)
function cargBags:GetImplementation(name)
    return self.classes.Implementation:Get(name)
end

local function toggleBag(forceopen) cargBags.blizzard:Toggle(forceopen) end
local function toggleNoForce()      cargBags.blizzard:Toggle()          end
local function openBag()            cargBags.blizzard:Show()            end -- luacheck: ignore
local function closeBag()           cargBags.blizzard:Hide()            end

--- Overwrites Blizzards Bag-Toggle-Functions with the implementation's ones
--  @param name <string> The name of the implementation [optional]
function cargBags:ReplaceBlizzard(name)
    local impl = name and cargBags:GetImplementation(name) or self.blizzard
    self.blizzard = impl

    -- Can we maybe live without hooking ToggleBag(id)?
    _G.ToggleAllBags = toggleNoForce
    _G.ToggleBag = toggleNoForce
    _G.ToggleBackpack = toggleNoForce

    _G.OpenAllBags = toggleBag -- Name is misleading, Blizz-function actually toggles bags
    _G.OpenBackpack = toggleBag -- Blizz does not provide toggling here
    _G.CloseAllBags = closeBag
    _G.CloseBackpack = closeBag

    _G.BankFrame:UnregisterAllEvents()
end

--- Flags the implementation to handle Blizzards Bag-Toggle-Functions
--  @param implementation <Implementation>
function cargBags:RegisterBlizzard(implementation)
    self.blizzard = implementation

    if _G.IsLoggedIn() then
        self:ReplaceBlizzard(self.blizzard)
    else
        self:RegisterEvent("PLAYER_LOGIN")
    end
end

--- Fires an event for all implementations
--  @param force <bool> even update hidden ones [optional]
--  @param event <string> the name of the event [default: "BAG_UPDATE"]
--  @param ... arguments of the event [optional]
function cargBags:FireEvent(force, event, ...)
    for name, impl in next, self.classes.Implementation.instances do
        if force or impl:IsShown() then
            impl:OnEvent(event or "BAG_UPDATE", ...)
        end
    end
end

cargBags:RegisterEvent("BANKFRAME_OPENED")
cargBags:RegisterEvent("BANKFRAME_CLOSED")

cargBags:SetScript("OnEvent", function(self, event)
    if not self.blizzard then return end

    local impl = self.blizzard

    if event == "PLAYER_LOGIN" then
        self:ReplaceBlizzard(impl)
    elseif event == "BANKFRAME_OPENED" then
        self.atBank = true

        if impl:IsShown() then
            impl:UpdateAll()
        else
            impl:Show()
        end

        if impl.OnBankOpened then
            impl:OnBankOpened()
        end
    elseif event == "BANKFRAME_CLOSED" then
        self.atBank = nil

        if impl:IsShown() then
            impl:Hide()
        end

        if impl.OnBankClosed then
            impl:OnBankClosed()
        end
    end
end)

local handlerFuncs = _G.setmetatable({}, {
    __index = function(self, handler)
        self[handler] = function(this, ...)
            if this[handler] then
                return this[handler](this, ...)
            end
        end
        return self[handler]
    end
})

--- Sets a number of script handlers by redirecting them to the members function, e.g. self:OnEvent(self, ...)
--  @param self <frame>
--  @param ... <string> A number of script handlers
function cargBags.SetScriptHandlers(self, ...)
    for i = 1, _G.select("#", ...) do
        local handler = _G.select(i, ...)
        self:SetScript(handler, handlerFuncs[handler])
    end
end

--- Gets the bagSlot-index of a bagID-slotID-pair
--  @param bagID <number>
--  @param slotID <number>
--  @return bagSlot <number>
function cargBags.ToBagSlot(bagID, slotID)
    return bagID * 100 + slotID
end


--- Gets the bagID-slotID-pair of a bagSlot-index
--  @param bagSlot <number>
--  @return bagID <number>
--  @return bagSlot <number>
function cargBags.FromBagSlot(bagSlot)
    return _G.floor(bagSlot / 100), bagSlot % 100
end

--- Creates a new item table which has access to ItemKeys
--  @return itemTable <table>
local m_item = {__index = function(i,k)
    return cargBags.itemKeys[k] and cargBags.itemKeys[k](i,k)
end}
function cargBags:NewItemTable()
    return _G.setmetatable({}, m_item)
end

