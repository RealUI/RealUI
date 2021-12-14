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

--local oldOpenAllBagsMatchingContext = _G.OpenAllBagsMatchingContext
function _G.OpenAllBagsMatchingContext()
    private.Toggle(true)
    return 4
end

--local oldToggleBackpack = _G.ToggleBackpack
_G.ToggleBackpack = _G.ToggleAllBags

--local oldToggleBag = _G.ToggleBag
_G.ToggleBag = _G.nop

_G.BankFrame:UnregisterAllEvents()
