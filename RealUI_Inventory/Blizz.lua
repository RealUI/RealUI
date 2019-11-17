local _, private = ...

-- RealUI --
local Inventory = private.Inventory

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

function private.CreateDummyBags(bagType)
    local bagStart, bagEnd
    if bagType == "main" then
        bagStart, bagEnd = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS
    end

    for bagID = bagStart, bagEnd do
        local bag = _G.CreateFrame("Frame", "RealUIInventory_Bag"..bagID, Inventory[bagType])
        bag:SetID(bagID)
        blizz[bagID] = bag
    end
end
