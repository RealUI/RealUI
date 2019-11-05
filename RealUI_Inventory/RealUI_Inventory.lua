local _, private = ...

-- Lua Globals --
-- luacheck: globals next tinsert ceil

-- RealUI --
local RealUI = _G.RealUI

local Inventory = RealUI:NewModule("Inventory")
private.Inventory = Inventory

local defaults = {
    global = {
        filters = {
        },
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

    if show then
        main:RegisterEvent("BAG_UPDATE")
        main:RegisterEvent("UNIT_INVENTORY_CHANGED")
        main:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        main:RegisterEvent("ITEM_LOCK_CHANGED")
        main:RegisterEvent("BAG_UPDATE_COOLDOWN")
        main:RegisterEvent("DISPLAY_SIZE_CHANGED")
        main:RegisterEvent("INVENTORY_SEARCH_UPDATE")
        main:RegisterEvent("BAG_NEW_ITEMS_UPDATED")
        main:RegisterEvent("BAG_SLOT_FLAGS_UPDATED")

        private.Update()
    else
        main:UnregisterEvent("BAG_UPDATE")
        main:UnregisterEvent("UNIT_INVENTORY_CHANGED")
        main:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
        main:UnregisterEvent("ITEM_LOCK_CHANGED")
        main:UnregisterEvent("BAG_UPDATE_COOLDOWN")
        main:UnregisterEvent("DISPLAY_SIZE_CHANGED")
        main:UnregisterEvent("INVENTORY_SEARCH_UPDATE")
        main:UnregisterEvent("BAG_NEW_ITEMS_UPDATED")
        main:UnregisterEvent("BAG_SLOT_FLAGS_UPDATED")
    end

    main:SetShown(show)
end

function Inventory:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_TemplateDB", defaults, true)

    private.CreateBags()
end
