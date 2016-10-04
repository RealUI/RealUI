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
]]
local _, ns = ...
local cargBags = ns.cargBags

-- Lua Globals --
local _G = _G

--[[!
    @class ItemButton
        This class serves as the basis for all itemSlots in a container
]]
local ItemButton = cargBags:NewClass("ItemButton", nil, "Button")

--[[!
    Gets a template name for the bagID
    @param bagID <number> [optional]
    @return template <string> - The template to be used for the bag
    @return parent <frame> - The parent container frame
]]
function ItemButton:GetTemplate(bagID)
    bagID = bagID or self.bagID

    if bagID == -3 then
        return "ReagentBankItemButtonGenericTemplate", _G.ReagentBankFrame
    elseif bagID == -1 then
        return "BankItemButtonGenericTemplate", _G.BankFrame
    elseif bagID then
        return "ContainerFrameItemButtonTemplate", _G["ContainerFrame"..bagID + 1]
    else
        return "ItemButtonTemplate"
    end
end

local mt_gen_key = {__index = function(self,k)
    self[k] = {}
    return self[k]
end}

--[[!
    Fetches a new instance of the ItemButton, creating one if necessary
    @param bagID <number>
    @param slotID <number>
    @return button <ItemButton>
]]
function ItemButton:New(bagID, slotID)
    self.recycled = self.recycled or _G.setmetatable({}, mt_gen_key)

    local tpl, parent = self:GetTemplate(bagID)
    local button = _G.tremove(self.recycled[tpl]) or self:Create(tpl, parent)

    button.bagID = bagID
    button.slotID = slotID
    button:SetID(slotID)
    
    button:Show()
    
    return button
end

--[[!
    Creates a new ItemButton
    @param tpl <string> The template to use [optional]
    @return button <ItemButton>
    @callback button:OnCreate(tpl)
]]
local bFS
function ItemButton:Create(tpl, parent)
    local impl = self.implementation
    impl.numSlots = (impl.numSlots or 0) + 1
    local name = ("%sSlot%d"):format(impl.name, impl.numSlots)

    local button = _G.setmetatable(_G.CreateFrame("Button", name, parent, tpl), self.__index)

    if button.Scaffold then button:Scaffold(tpl) end
    if button.OnCreate then button:OnCreate(tpl) end
    local btnNT = _G[button:GetName().."NormalTexture"]
    local btnNIT = button.NewItemTexture
    local btnBIT = button.BattlepayItemTexture
    if btnNT then btnNT:SetTexture("") end
    if btnNIT then btnNIT:SetTexture("") end
    if btnBIT then btnBIT:SetTexture("") end
    
    button:SetSize(ns.options.itemSlotSize, ns.options.itemSlotSize)
    bFS = _G[button:GetName().."Count"]
    bFS:ClearAllPoints()
    bFS:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", 1.5, 1.5);
    bFS:SetFontObject(_G.RealUIFont_PixelSmall)

    return button
end

--[[!
    Frees an ItemButton, storing it for later use
]]
function ItemButton:Free()
    self:Hide()
    _G.tinsert(self.recycled[self:GetTemplate()], self)
end

--[[!
    Fetches the item-info of the button, just a small wrapper for comfort
    @return item <table>
]]
function ItemButton:GetItemInfo()
    --print("ItemButton:GetItemInfo", bagID)
    return self.implementation:GetItemInfo(self.bagID, self.slotID)
end

