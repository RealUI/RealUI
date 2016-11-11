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
local next = _G.next
local tonumber, strsplit = _G.tonumber, _G.strsplit


--[[!
    @class Implementation
        The Implementation-class serves as the basis for your cargBags-instance, handling
        item-data-fetching and dispatching events for containers and items.
]]
local Implementation = cargBags:NewClass("Implementation", nil, "Button")
Implementation.instances = {}
Implementation.itemKeys = {}

local toBagSlot = cargBags.ToBagSlot
local ItemInfo = {}
local L

--[[!
    Creates a new instance of the class
    @param name <string>
    @return impl <Implementation>
]]
function Implementation:New(name)
    if self.instances[name] then return _G.error(("cargBags: Implementation '%s' already exists!"):format(name)) end
    if _G[name] then return _G.error(("cargBags: Global '%s' for Implementation is already used!"):format(name)) end

    local impl = _G.setmetatable(_G.CreateFrame("Button", name, _G.UIParent), self.__index)
    impl.name = name

    impl:SetAllPoints()
    impl:EnableMouse(nil)
    impl:Hide()

    cargBags.SetScriptHandlers(impl, "OnEvent", "OnShow", "OnHide")

    impl.contByID = {} --! @property contByID <table> Holds all child-Containers by index
    impl.contByName = {} --!@ property contByName <table> Holds all child-Containers by name
    impl.buttons = {} -- @property buttons <table> Holds all ItemButtons by bagSlot
    impl.bagSizes = {} -- @property bagSizes <table> Holds the size of all bags
    impl.events = {} -- @property events <table> Holds all event callbacks
    impl.notInited = true -- @property notInited <bool>

    _G.tinsert(_G.UISpecialFrames, name) 

    self.instances[name] = impl

    return impl
end

--[[!
    Script handler, inits and updates the Implementation when shown
    @callback OnOpen
]]
function Implementation:OnShow()
    if self.notInited then
        if not _G.InCombatLockdown() then -- initialization of bags in combat taints the itembuttons within - Lars Norberg
            self:Init()
        else
            return
        end
    end

    if self.OnOpen then self:OnOpen() end
    self:UpdateAll()
end

--[[!
    Script handler, closes the Implementation when hidden
    @callback OnClose
]]
function Implementation:OnHide()
    if self.notInited then return end

    if self.OnClose then self:OnClose() end
    if self:AtBank() then _G.CloseBankFrame() end
end

--[[!
    Toggles the implementation
    @param forceopen <bool> Only open it
]]
function Implementation:Toggle(forceopen)
    if not forceopen and self:IsShown() then
        self:Hide()
    else
        self:Show()
    end
end

--[[!
    Fetches an implementation by name
    @param name <string>
    @return impl <Implementation>
]]
function Implementation:Get(name)
    return self.instances[name]
end

--[[!
    Fetches a child-Container by name
    @param name <string>
    @return container <Container>
]]
function Implementation:GetContainer(name)
    return self.contByName[name]
end

--[[!
    Fetches a implementation-owned class by relative name

    The relative class names are prefixed by the name of the implementation
    e.g. :GetClass("Button") -> ImplementationButton
    It is just to prevent people from overwriting each others classes

    @param name <string> The relative class name
    @param create <bool> Creates it, if it doesn't exist
    @param ... Arguments to pass to cargBags:NewClass(name, ...) when creating
    @return class <table> The class prototype
]]
function Implementation:GetClass(name, create, ...)
    if not name then return end

    name = self.name..name
    local class = cargBags.classes[name]
    if class or not create then return class end

    class = cargBags:NewClass(name, ...)
    class.implementation = self
    return class
end

--[[!
    Wrapper for :GetClass() using a Container
    @note Container-classes have the full name "ImplementationNameContainer"
    @param name <string> The relative container class name
    @return class <table> The class prototype
]]
function Implementation:GetContainerClass(name)
    return self:GetClass((name or "") .. "Container", true, "Container")
end

--[[!
    Wrapper for :GetClass() using an ItemButton
    @note ItemButton-Classes have the full name "ImplementationNameItemButton"
    @param name <string> The relative itembutton class name
    @return class <table> The class prototype
]]
function Implementation:GetItemButtonClass(name)
    return self:GetClass((name or "") .. "ItemButton", true, "ItemButton")
end

--[[!
    Sets the ItemButton class to use for spawning new buttons
    @param name <string> The relative itembutton class name
    @return class <table> The newly set class
]]
function Implementation:SetDefaultItemButtonClass(name)
    self.buttonClass = self:GetItemButtonClass(name)
    return self.buttonClass
end

--[[!
    Registers the implementation to overwrite Blizzards Bag-Toggle-Functions
    @note This function only works before PLAYER_LOGIN and can be overwritten by other Implementations
]]
function Implementation:RegisterBlizzard()
    cargBags:RegisterBlizzard(self)
end

local _registerEvent = _G.UIParent.RegisterEvent
local _isEventRegistered = _G.UIParent.IsEventRegistered

--[[!
    Registers an event callback - these are only called if the Implementation is currently shown
    The events do not have to be 'blizz events' - they can also be internal messages
    @param event <string> The event to register for
    @param key Something passed to the callback as arg #1, also serves as identification
    @param func <function> The function to call on the event
]]
function Implementation:RegisterEvent(event, key, func)
    local events = self.events
    
    if not events[event] then
        events[event] = {}
    end

    events[event][key] = func
    if event:upper() == event and not _isEventRegistered(self, event) then
        _registerEvent(self, event)
    end
end

--[[!
    Returns whether the Implementation has the specified event callback
    @param event <string> The event of the callback
    @param key The identification of the callback [optional]
]]
function Implementation:IsEventRegistered(event, key)
    return self.events[event] and (not key or self.events[event][key])
end

--[[!
    Script handler, dispatches the events
]]
function Implementation:OnEvent(event, ...)
    if not (self.events[event] and self:IsShown()) then return end

    for key, func in next, self.events[event] do
        func(key, event, ...)
    end
end

--[[!
    Inits the implementation by registering events
    @callback OnInit
]]
function Implementation:Init()
    if not self.notInited then return end
    
     -- initialization of bags in combat taints the itembuttons within - Lars Norberg
    if _G.InCombatLockdown() then
        return
    end
    
    self.notInited = nil

    if self.OnInit then self:OnInit() end

    if not self.buttonClass then
        self:SetDefaultItemButtonClass()
    end

    self:RegisterEvent("BAG_UPDATE", self, self.BAG_UPDATE)
    self:RegisterEvent("BAG_UPDATE_COOLDOWN", self, self.BAG_UPDATE_COOLDOWN)
    self:RegisterEvent("ITEM_LOCK_CHANGED", self, self.ITEM_LOCK_CHANGED)
    self:RegisterEvent("GET_ITEM_INFO_RECEIVED", self, self.GET_ITEM_INFO_RECEIVED)
    self:RegisterEvent("PLAYERBANKSLOTS_CHANGED", self, self.PLAYERBANKSLOTS_CHANGED)
    self:RegisterEvent("PLAYERREAGENTBANKSLOTS_CHANGED", self, self.PLAYERREAGENTBANKSLOTS_CHANGED)
    self:RegisterEvent("UNIT_QUEST_LOG_CHANGED", self, self.UNIT_QUEST_LOG_CHANGED)
    self:RegisterEvent("BAG_CLOSED", self, self.BAG_CLOSED)
end

--[[!
    Returns whether the user is currently at the bank
    @return atBank <bool>
]]
function Implementation:AtBank()
    return cargBags.atBank
end

--[[
    Fetches a button by bagID-slotID-pair
    @param bagID <number>
    @param slotID <number>
    @return button <ItemButton>
]]
function Implementation:GetButton(bagID, slotID)
    return self.buttons[toBagSlot(bagID, slotID)]
end

--[[!
    Stores a button by bagID-slotID-pair
    @param bagID <number>
    @param slotID <number>
    @param button <ItemButton> [optional]
]]
function Implementation:SetButton(bagID, slotID, button)
    self.buttons[toBagSlot(bagID, slotID)] = button
end

local defaultItem = cargBags:NewItemTable()

--[[!
    Fires a complete BAG_UPDATE on the next update
]]
do
    local scheduled = false
    local function scheduler()
        scheduled:OnEvent("BAG_UPDATE")
        scheduled = false
    end
    function Implementation:UpdateAll()
        if not scheduled then
            scheduled = self
            _G.C_Timer.After(0, scheduler)
        end
    end
end

--[[!
    Fetches the itemInfo of the item in bagID/slotID into the table
    @param bagID <number>
    @param slotID <number>
    @param i <table> [optional]
    @return i <table>
]]
local infoGather = {}
do
    local function GatherItemInfo(bagID, slotID, i)
        cargBags.debug("GatherItemInfo", bagID, slotID, i)
        i = i or defaultItem
        _G.wipe(i)

        i.bagID = bagID
        i.slotID = slotID

        local clink = _G.GetContainerItemLink(bagID, slotID)
        i.texture, i.count = _G.GetContainerItemInfo(bagID, slotID)
        if clink then
            local texture

            -- /dump GetContainerItemLink(0, 1):match("H(%w+):([%-?%d:]+)")
            local linkType, itemString = clink:match("H(%w+):([%-?%d:]+)")
            if linkType == "battlepet" then
                if not(L) then
                    L = cargBags:GetLocalizedTypes()
                end
                local itemType, petType = L[_G.LE_ITEM_CLASS_BATTLEPET]
                local speciesID, level, breedQuality, _, _, _, battlePetID = strsplit(":", itemString)
                i.name, texture, petType, i.creatureID, _, _, i.isWild, i.canBattle, i.isTradeable, i.isUnique, i.isObtainable, i.displayID = _G.C_PetJournal.GetPetInfoBySpeciesID(speciesID)
                i.link = clink
                i.rarity = tonumber(breedQuality) or 0
                i.minLevel = tonumber(level) or 0
                i.type = itemType.name
                i.subType = itemType[petType-1]
                i.texture = i.texture or texture
                i.typeID = _G.LE_ITEM_CLASS_BATTLEPET
                i.subTypeID = petType
                i.id = tonumber(battlePetID)

                i.speciesID = tonumber(speciesID) or 0
            else
                local itemID = strsplit(":", itemString)
                i.id = tonumber(itemID) or 0

                i.isQuestItem, i.questID, i.questActive = _G.GetContainerItemQuestInfo(bagID, slotID)
                i.isInSet, i.setName = _G.GetContainerItemEquipmentSetInfo(bagID, slotID)

                i.name, i.link, i.rarity, i.level, i.minLevel, i.type, i.subType, i.stackCount, i.equipLoc, texture, i.sellPrice, i.typeID, i.subTypeID = _G.GetItemInfo(clink)
                if not i.name then
                    i.id, i.type, i.subType, i.equipLoc, texture, i.typeID, i.subTypeID = _G.GetItemInfoInstant(clink)
                    if not infoGather[i.id] then infoGather[i.id] = {} end
                    if not infoGather[i.id][i.bagID] then infoGather[i.id][i.bagID] = {} end
                    if not infoGather[i.id][i.bagID][i.slotID] then
                        infoGather[i.id][i.bagID][i.slotID] = i
                    end
                end
                i.texture = i.texture or texture
            end
            cargBags.debug("ItemInfo", i.name, i.id, i.type, i.typeID)
        end

        ItemInfo[bagID][slotID] = i
        return i
    end

    function Implementation:GetItemInfo(bagID, slotID, reset)
        cargBags.debug("GetItemInfo", bagID, slotID, reset)
        if not ItemInfo[bagID] then
            cargBags.debug("ItemInfo bag", bagID)
            ItemInfo[bagID] = {}
        end

        if reset or (ItemInfo[bagID][slotID] and not ItemInfo[bagID][slotID].typeID) or (not ItemInfo[bagID][slotID]) then
            return GatherItemInfo(bagID, slotID, ItemInfo[bagID][slotID] or {})
        else
            cargBags.debug("ItemInfo cached", slotID, ItemInfo[bagID][slotID].name)
            return ItemInfo[bagID][slotID]
        end
    end
end

--[[!
    Updates the defined slot, creating/removing buttons as necessary
    @param bagID <number>
    @param slotID <number>
]]
function Implementation:UpdateSlot(bagID, slotID)
    cargBags.debug("Implementation:UpdateSlot", bagID, slotID)
    local item = self:GetItemInfo(bagID, slotID, true)
    local button = self:GetButton(bagID, slotID)
    local container = self:GetContainerForItem(item, button)

    cargBags.debug("button, container", button, container)
    if container then
        if button then
            if container ~= button.container then
                button.container:RemoveButton(button)
                container:AddButton(button)
            end
        else
            button = self.buttonClass:New(bagID, slotID)
            self:SetButton(bagID, slotID, button)
            container:AddButton(button)
        end

        button:Update(item)
    elseif button then
        button.container:RemoveButton(button)
        self:SetButton(bagID, slotID, nil)
        button:Free()
    end
end

local closed

--[[!
    Updates a bag and its containing slots
    @param bagID <number>
]]
function Implementation:UpdateBag(bagID)
    cargBags.debug("Implementation:UpdateBag", bagID)
    local numSlots
    if closed then
        numSlots, closed = 0, nil
    else
        numSlots = _G.GetContainerNumSlots(bagID)
    end
    local lastSlots = self.bagSizes[bagID] or 0
    self.bagSizes[bagID] = numSlots

    for slotID = 1, numSlots do
        self:UpdateSlot(bagID, slotID)
    end
    for slotID = numSlots + 1, lastSlots do
        local button = self:GetButton(bagID, slotID)
        if button then
            button.container:RemoveButton(button)
            self:SetButton(bagID, slotID, nil)
            button:Free()
        end
    end
end

--[[!
    Updates a set of items
    @param bagID <number> [optional]
    @param slotID <number> [optional]
    @callback Container:OnBagUpdate(bagID, slotID)
]]
function Implementation:BAG_UPDATE(event, bagID, slotID)
    cargBags.debug("Implementation:BAG_UPDATE", event, bagID, slotID)
    if bagID and slotID then
        self:UpdateSlot(bagID, slotID)
    elseif bagID then
        self:UpdateBag(bagID)
    else
        for id = -3, 11 do
            self:UpdateBag(id)
        end
    end
end

--[[!
    Updates a bag of the implementation (fired when it is removed)
    @param bagID <number>
]]
function Implementation:BAG_CLOSED(event, bagID)
    cargBags.debug("Implementation:BAG_CLOSED", event, bagID)
    closed = bagID
    self:BAG_UPDATE(event, bagID)
end

--[[!
    Fired when the item cooldowns need to be updated
    @param bagID <number> [optional]
]]
function Implementation:BAG_UPDATE_COOLDOWN(event, bagID)
    cargBags.debug("Implementation:BAG_UPDATE_COOLDOWN", event, bagID)
    if bagID then
        for slotID = 1, _G.GetContainerNumSlots(bagID) do
            local button = self:GetButton(bagID, slotID)
            if button then
                button:UpdateCooldown(self:GetItemInfo(bagID, slotID))
            end
        end
    else
        for id, container in next, self.contByID do
            for i, button in next, container.buttons do
                button:UpdateCooldown(self:GetItemInfo(button.bagID, button.slotID))
            end
        end
    end
end

--[[!
    Fired when the item is picked up or released
    @param bagID <number>
    @param slotID <number> [optional]
]]
function Implementation:ITEM_LOCK_CHANGED(event, bagID, slotID)
    cargBags.debug("Implementation:ITEM_LOCK_CHANGED", event, bagID, slotID)
    if not slotID then return end

    local button = self:GetButton(bagID, slotID)
    if button then
        local item = self:GetItemInfo(bagID, slotID)
        button:UpdateLock(item)
    end
end

--[[!
    Fired when item information is recived from the server after a GetItemInfo call
    @param itemID <number>
]]
function Implementation:GET_ITEM_INFO_RECEIVED(event, itemID)
    cargBags.debug("Implementation:GET_ITEM_INFO_RECEIVED", event, itemID)
    local itemInfo = infoGather[itemID]
    if itemInfo then
        for bagID, bag in next, itemInfo do
            for slotID, item in next, bag do
                cargBags.debug("Update item info", event, bagID, slotID)
                self:BAG_UPDATE(event, bagID, slotID)
            end
        end
        infoGather[itemID] = nil
    end
end

--[[!
    Fired when bank bags or slots need to be updated
    @param bagID <number>
    @param slotID <number> [optional]
]]
function Implementation:PLAYERBANKSLOTS_CHANGED(event, bagID, slotID)
    cargBags.debug("Implementation:PLAYERBANKSLOTS_CHANGED", event, bagID, slotID)
    if bagID <= _G.NUM_BANKGENERIC_SLOTS then
        slotID = bagID
        bagID = -1
    else
        bagID = bagID - _G.NUM_BANKGENERIC_SLOTS
    end

    self:BAG_UPDATE(event, bagID, slotID)
end

--[[!
    Fired when reagent bank slots need to be updated
    @param bagID <number>
    @param slotID <number> [optional]
]]
function Implementation:PLAYERREAGENTBANKSLOTS_CHANGED(event, slotID)
    cargBags.debug("Implementation:PLAYERREAGENTBANKSLOTS_CHANGED", event, slotID)
    local bagID = -3

    self:BAG_UPDATE(event, bagID, slotID)
end

--[[
    Fired when the quest log of a unit changes
]]
function Implementation:UNIT_QUEST_LOG_CHANGED(event)
    cargBags.debug("Implementation:UNIT_QUEST_LOG_CHANGED", event)
    for id, container in next, self.contByID do
        for i, button in next, container.buttons do
            local item = self:GetItemInfo(button.bagID, button.slotID)
            button:UpdateQuest(item)
        end
    end
end
