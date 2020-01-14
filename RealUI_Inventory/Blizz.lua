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

--_G.BankFrame:UnregisterAllEvents()

local function CreateBag(bagID, parent)
    local bag = _G.CreateFrame("Frame", "$parent_Bag"..bagID, parent)
    bag:SetID(bagID)
    blizz[bagID] = bag
end

function private.CreateDummyBags(bagType)
    local bagStart, bagEnd
    if bagType == "main" then
        bagStart, bagEnd = _G.BACKPACK_CONTAINER, _G.NUM_BAG_SLOTS
    elseif bagType == "bank" then
        CreateBag(_G.BANK_CONTAINER, Inventory[bagType])
        bagStart, bagEnd = _G.NUM_BAG_SLOTS + 1, _G.NUM_BAG_SLOTS + _G.NUM_BANKBAGSLOTS
    end

    for bagID = bagStart, bagEnd do
        CreateBag(bagID, Inventory[bagType])
    end
end
