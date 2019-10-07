local _, private = ...

-- Lua Globals --
-- luacheck: globals wipe next tinsert sort tonumber

-- RealUI --
local RealUI = _G.RealUI
local characterInfo = RealUI.charInfo

local Tooltips = private.Tooltips
local currencyDB

local function UpdateMoney()
    if RealUI.realmInfo.realmNormalized then
        currencyDB[RealUI.realmInfo.realmNormalized][characterInfo.faction][characterInfo.name].money = _G.GetMoney() or 0
    end
end

local function SetUpHooks()
    local frame = _G.CreateFrame("Frame")
    frame:RegisterEvent("PLAYER_MONEY")
    frame:SetScript("OnEvent", function(self, event, ...)
        Tooltips:debug("Currency:OnEvent", event, ...)
        if event == "PLAYER_MONEY" then
            UpdateMoney()
        end
    end)
end


function private.SetupCurrency()
    currencyDB = RealUI.db.global.currency

    SetUpHooks()
    UpdateMoney()
end
