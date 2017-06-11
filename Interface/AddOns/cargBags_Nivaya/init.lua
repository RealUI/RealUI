local _, ns = ...

ns.filters = {}
ns.itemClass = {}

ns.bags = {}
ns.bagsHidden = {}
ns.bagsCustom = {}
ns.newItems = {}

ns.options = {
    itemSlotSize = 32,  -- Size of item slots
    sizes = {
        bags = {
            columnsSmall = 8,
            columnsLarge = 10,
            largeItemCount = 64,    -- Switch to columnsLarge when >= this number of items in your bags
        },
        bank = {
            columnsSmall = 12,
            columnsLarge = 14,
            largeItemCount = 96,    -- Switch to columnsLarge when >= this number of items in the bank
        },
    },
}

_G.RealUI.hasCargBags = true
