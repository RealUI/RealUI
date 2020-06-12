local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs tinsert ceil

-- RealUI --
local RealUI = _G.RealUI

local Inventory = RealUI:NewModule("Inventory", "AceEvent-3.0")
private.Inventory = Inventory

local defaults = {
    global = {
        maxHeight = 0.5,
        sellJunk = true,
        filters = {},
        assignedFilters = {},
        customFilters = {}
    }
}

function private.Update()
    Inventory:debug("private.Update")
    private.UpdateBags()
end
function private.Toggle(show)
    Inventory:debug("private.Toggle", show)
    local main = Inventory.main
    if show == nil then
        show = not main:IsShown()
    end

    main:SetShown(show)
    Inventory.bank:SetShown(show and Inventory.showBank)
end
function private.GetBagTypeForBagID(bagID)
    if bagID >= _G.BACKPACK_CONTAINER and bagID <= _G.NUM_BAG_SLOTS then
        return "main"
    elseif bagID == _G.REAGENTBANK_CONTAINER then
        return "reagent"
    else
        return "bank"
    end
end

function private.SellJunk()
    local bag, profit = Inventory.main.bags.junk, 0

    for _, slot in ipairs(bag.slots) do
        local bagID, slotIndex = slot:GetBagAndSlot()
        if slot.sellPrice then
            local _, itemCount = _G.GetContainerItemInfo(bagID, slotIndex)
            profit = profit + (slot.sellPrice * itemCount)

            slot.sellPrice = nil
            slot.JunkIcon:Hide()
            _G.UseContainerItem(bagID, slotIndex)
        end
    end

    local money = _G.GetMoneyString(profit, true)
    _G.print(_G.AMOUNT_RECEIVED_COLON, money)
end
local function MERCHANT_SHOW(event, ...)
    local bag = Inventory.main.bags.junk

    if Inventory.db.global.sellJunk then
        if #bag.slots == 0 then
            -- items aren't updated yet, wait a frame.
            return _G.C_Timer.After(0, private.SellJunk)
        end
        private.SellJunk()
    else
        bag.sellJunk:Show()
        bag.profit = 0
        for _, slot in ipairs(bag.slots) do
            local _, _, _, _, _, _, _, _, _, _, sellPrice = _G.GetItemInfo(slot.item:GetItemID())
            if sellPrice > 0 then
                slot.JunkIcon:Show()
                slot.sellPrice = sellPrice
            end
        end
    end
end
local function MERCHANT_CLOSED(event, ...)
    local bag = Inventory.main.bags.junk

    bag.sellJunk:Hide()
    for _, slot in ipairs(bag.slots) do
        slot.JunkIcon:Hide()
    end
end

function Inventory:OnInitialize()
    for i, info in ipairs(private.filterList) do
        defaults.global.filters[i] = info.tag
    end
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_InventoryDB", defaults, true)

    Inventory:RegisterEvent("MERCHANT_SHOW", MERCHANT_SHOW)
    Inventory:RegisterEvent("MERCHANT_CLOSED", MERCHANT_CLOSED)

    private.CreateBags()
    private.CreateFilters()

    self.Update = private.Update
end
