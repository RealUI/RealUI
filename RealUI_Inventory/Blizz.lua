local _, private = ...

-- RealUI --
local Inventory = private.Inventory

local blizz = {}
private.blizz = blizz
for bagID = 0, _G.NUM_BAG_SLOTS do
    local bag = _G.CreateFrame("Frame", "RealUIInventory_Bag"..bagID, _G.UIParent)
    bag:SetID(bagID)
    blizz[bagID] = bag
end

local function Toggle(show)
    if show == nil then
        show = Inventory.main:IsShown()
    end

    for bagID = 0, _G.NUM_BAG_SLOTS do
        blizz[bagID]:SetShown(show)
    end
end

--local oldOpenAllBags = _G.OpenAllBags
function _G.OpenAllBags()
    private.Toggle(true)
    Toggle(true)
end

--local oldCloseAllBags = _G.CloseAllBags
function _G.CloseAllBags()
    private.Toggle(false)
    Toggle(false)
end

--local oldToggleAllBags = _G.ToggleAllBags
function _G.ToggleAllBags()
    private.Toggle()
    Toggle()
end

--local oldToggleBackpack = _G.ToggleBackpack
_G.ToggleBackpack = _G.ToggleAllBags

--local oldToggleBag = _G.ToggleBag
_G.ToggleBag = _G.nop

