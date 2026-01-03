local _, private = ...

-- Lua Globals --
-- luacheck: globals next ipairs tinsert ceil tremove

-- RealUI --
local RealUI = _G.RealUI

local Inventory = RealUI:NewModule("Inventory", "AceEvent-3.0", "AceHook-3.0")
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

function private.GetBagTypeForBagID(bagID)
    if bagID >= _G.Enum.BagIndex.Backpack and bagID <= _G.NUM_TOTAL_EQUIPPED_BAG_SLOTS then
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

            _G.C_Container.UseContainerItem(slot:GetBagAndSlot()) --- FIXME
        end
    end

    if bag.profit > 0 then
        -- FIXMELATER
        -- -function GetMoneyString(money, separateThousands, checkGoldThreshold)
        -- +function GetMoneyString(money, separateThousands, checkGoldThreshold, showZeroAsGold)
        local money = _G.GetMoneyString(bag.profit, true)
        _G.print(_G.AMOUNT_RECEIVED_COLON, money)
    end
end
function private.CalculateJunkProfit(isAtMerchant)
    local bag = Inventory.main.bags.junk

    local profit = 0
    for _, slot in ipairs(bag.slots) do
        local _, _, _, _, _, _, _, _, _, _, sellPrice = _G.C_Item.GetItemInfo(slot.item:GetItemLink())
        if sellPrice > 0 then
            local stackCount = _G.C_Container.GetContainerItemInfo(slot:GetBagAndSlot()).stackCount
            profit = profit + (sellPrice * stackCount)

            slot.JunkIcon:SetShown(isAtMerchant)
            slot.sellPrice = sellPrice
        end
    end
    bag.profit = profit
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

    private.CreateBags()
    private.CreateFilters()

    -- Preload slots out of combat to prevent taint
    private.Update()

    self.Update = private.Update

    _G.C_Timer.After(1, function()
        -- Disable tutorials
        _G.SetCVarBitfield("closedInfoFramesAccountWide", _G.LE_FRAME_TUTORIAL_EQUIP_REAGENT_BAG, true)
        _G.SetCVarBitfield("closedInfoFramesAccountWide", _G.Enum.FrameTutorialAccount.TransmogSetsTab, true)
        _G.SetCVarBitfield("closedInfoFramesAccountWide", _G.Enum.FrameTutorialAccount.AssistedCombatRotationDragSpell, true)
        _G.SetCVarBitfield("closedInfoFramesAccountWide", _G.Enum.FrameTutorialAccount.AssistedCombatRotationActionButton, true)
        _G.SetCVarBitfield("closedInfoFramesAccountWide", _G.Enum.FrameTutorialAccount.HeirloomJournalLevel, true)

    end)
end
