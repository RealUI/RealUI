local _, private = ...

-- Lua Globals --
-- luacheck: globals ipairs

local blizz = {}
private.blizz = blizz

--local oldOpenAllBags = _G.OpenAllBags
function _G.OpenAllBags()
    private.Toggle(true)
end

--local oldCloseAllBags = _G.CloseAllBags
function _G.CloseAllBags()
    private.Toggle(false)
end

--local oldToggleAllBags = _G.ToggleAllBags
function _G.ToggleAllBags()
    private.Toggle()
end

--local oldToggleBackpack = _G.ToggleBackpack
_G.ToggleBackpack = _G.ToggleAllBags

--local oldToggleBag = _G.ToggleBag
_G.ToggleBag = _G.nop

_G.BankFrame:UnregisterAllEvents()

local bagIDs = {
    main = {0, 1, 2, 3, 4}, -- BACKPACK_CONTAINER through NUM_BAG_SLOTS
    bank = {-1, 5, 6, 7, 8, 9, 10, 11}, -- BANK_CONTAINER, (NUM_BAG_SLOTS + 1) through (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
    reagent = {-3} -- REAGENTBANK_CONTAINER
}
function private.IterateBagIDs(bagType)
    return ipairs(bagIDs[bagType])
end
