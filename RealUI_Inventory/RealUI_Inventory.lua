local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs tinsert ceil tremove

-- RealUI --
local RealUI = _G.RealUI

local Inventory = RealUI:NewModule("Inventory", "AceEvent-3.0")
private.Inventory = Inventory

local defaults = {
    global = {
        version = 1,
        maxHeight = 0.5,
        sellJunk = true,
        filters = {},
        assignedFilters = {},
        customFilters = {},
        disabledFilters = {}
    },
    char = {
        junk = {},
    }
}

function private.Update()
    Inventory:debug("private.Update")
    private.UpdateBags()
    private.CalculateJunkProfit(_G.MerchantFrame:IsShown())
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
    else
        return "bank"
    end
end

function private.SellJunk()
    local bag = Inventory.main.bags.junk

    for _, slot in ipairs(bag.slots) do
        if slot.sellPrice then
            slot.sellPrice = nil
            slot.JunkIcon:Hide()

            _G.UseContainerItem(slot:GetBagAndSlot())
        end
    end

    local money = _G.GetMoneyString(bag.profit, true)
    _G.print(_G.AMOUNT_RECEIVED_COLON, money)
end
function private.CalculateJunkProfit(isAtMerchant)
    local bag = Inventory.main.bags.junk

    local profit = 0
    for _, slot in ipairs(bag.slots) do
        local _, _, _, _, _, _, _, _, _, _, sellPrice = _G.GetItemInfo(slot.item:GetItemLink())
        if sellPrice > 0 then
            local _, itemCount = _G.GetContainerItemInfo(slot:GetBagAndSlot())
            profit = profit + (sellPrice * itemCount)

            slot.JunkIcon:SetShown(isAtMerchant)
            slot.sellPrice = sellPrice
        end
    end
    bag.profit = profit
end
local function MERCHANT_SHOW(event, ...)
    local bag = Inventory.main.bags.junk
    if not bag:IsShown() then return end
    if #bag.slots == 0 then
        -- items aren't updated yet, wait a frame.
        return _G.C_Timer.After(0, MERCHANT_SHOW)
    end

    private.CalculateJunkProfit(true)
    if Inventory.db.global.sellJunk then
        private.SellJunk()
    else
        bag.sellJunk:Show()
    end
end
local function MERCHANT_CLOSED(event, ...)
    local bag = Inventory.main.bags.junk

    bag.sellJunk:Hide()
    for _, slot in ipairs(bag.slots) do
        slot.JunkIcon:Hide()
    end
end

local settingsVersion = 4
function private.SanitizeSavedVars(oldVer)
    if oldVer < 4 then
        local indexedFilters = Inventory.db.global.filters
        Inventory.db.global.filters = {}
        for i, tag in ipairs(indexedFilters) do
            Inventory.db.global.filters[tag] = i
        end
    end

    if oldVer < 3 then
        Inventory:ClearAssignedItems("anima")
    end

    -- Remove custom filters with the same name as our default filters
    for i, info in ipairs(private.filterList) do
        if Inventory.db.global.customFilters[info.tag] then
            Inventory.db.global.customFilters[info.tag] = nil
        end
    end

    Inventory.db.global.version = settingsVersion
end

function Inventory:OnInitialize()
    for i, info in ipairs(private.filterList) do
        defaults.global.filters[info.tag] = i
    end
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_InventoryDB", defaults, true)

    if self.db.global.version < settingsVersion then
        private.SanitizeSavedVars(self.db.global.version)
    end

    self:RegisterEvent("MERCHANT_SHOW", MERCHANT_SHOW)
    self:RegisterEvent("MERCHANT_CLOSED", MERCHANT_CLOSED)

    private.CreateBags()
    private.CreateFilters()

    -- Preload slots out of combat to prevent taint
    private.Update()

    self.Update = private.Update
end
