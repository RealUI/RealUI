local _, private = ...

-- Lua Globals --
-- luacheck: globals next tinsert ceil

-- RealUI --
local RealUI = _G.RealUI

local Inventory = RealUI:NewModule("Inventory")
private.Inventory = Inventory

local defaults = {
    global = {
        maxHeight = 600,
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
        private.Update()
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

function Inventory:OnInitialize()
    defaults.global.filters = private.filterList
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_InventoryDB", defaults, true)

    private.CreateBags()
end
