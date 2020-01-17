local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs tinsert ceil

-- RealUI --
local RealUI = _G.RealUI

local Inventory = RealUI:NewModule("Inventory", "AceEvent-3.0")
private.Inventory = Inventory

local defaults = {
    global = {
        maxHeight = 600,
        sellJunk = true
    }
}

function private.Update()
    private.UpdateBags()
end
function private.Toggle(show)
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
    else
        return "bank"
    end
end

function private.SellJunk()
    local bag, profit = Inventory.main.bags.junk, 0

    for _, slot in ipairs(bag.slots) do
        local bagID, slotIndex = slot:GetBagAndSlot()
        local _, itemCount = _G.GetContainerItemInfo(bagID, slotIndex)
        local _, _, _, _, _, _, _, _, _, _, sellPrice = _G.GetItemInfo(slot.item:GetItemID())
        profit = profit + (sellPrice * itemCount)
        _G.UseContainerItem(bagID, slotIndex)
    end

    local money = _G.GetMoneyString(profit, true)
    _G.print(_G.AMOUNT_RECEIVED_COLON, money)
end
function Inventory:MERCHANT_SHOW(event, ...)
    local bag = Inventory.main.bags.junk

    if Inventory.db.global.sellJunk then
        if #bag.slots == 0 then
            -- items aren't updated yet, wait a frame.
            return _G.C_Timer.After(0, private.SellJunk)
        end
        private.SellJunk()
    else
        bag.sellJunk:Show()
        for _, slot in ipairs(bag.slots) do
            slot.JunkIcon:Show()
        end
    end
end
function Inventory:MERCHANT_CLOSED(event, ...)
    local bag = Inventory.main.bags.junk

    bag.sellJunk:Hide()
    for _, slot in ipairs(bag.slots) do
        slot.JunkIcon:Hide()
    end
end

function Inventory:OnInitialize()
    defaults.global.filters = private.filterList
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_InventoryDB", defaults, true)

    Inventory:RegisterEvent("MERCHANT_SHOW")
    Inventory:RegisterEvent("MERCHANT_CLOSED")

    private.CreateBags()
end
