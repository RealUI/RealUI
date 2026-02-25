local _, private = ...

-- Lua Globals --
-- luacheck: globals ipairs

local Inventory = private.Inventory

function Inventory:OpenBags(frame)
    if frame ~= nil then return end
    self.main:Show()
end
function Inventory:CloseBags(frame)
    if frame ~= nil then return end
    self.main:Hide()
end
function Inventory:ToggleBags(frame)
    if frame ~= nil then return end
    if self.main:IsShown() then
        self.main:Hide()
    else
        self.main:Show()
    end
end

Inventory:RawHook("OpenBackpack", "OpenBags", true)
Inventory:SecureHook("CloseBackpack", "CloseBags")

Inventory:RawHook("ToggleBag", "ToggleBags", true)
Inventory:RawHook("ToggleBackpack", "ToggleBags", true)
Inventory:RawHook("ToggleAllBags", "ToggleBags", true)
Inventory:RawHook("OpenAllBags", "OpenBags", true)
Inventory:RawHook("OpenBag", "OpenBags", true)

function Inventory:OpenBank()
    if not self.bank then return end
    if not _G.C_Bank.CanViewBank(_G.Enum.BankType.Character) and not _G.C_Bank.CanViewBank(_G.Enum.BankType.Account) then
        return
    end
    self.bank:Show()
    if not self.main:IsShown() then
        self.openedBagsForBank = true
        self:OpenBags()
    end
end
function Inventory:CloseBank()
    if not self.bank then return end
    self.bank:Hide()
    if self.openedBagsForBank then
        self.openedBagsForBank = false
        self:CloseBags()
    end
end

_G.BankFrame:UnregisterAllEvents()
_G.BankFrame:SetScript("OnShow", nil)
_G.BankFrame:SetParent(_G.RealUI.UIHider)

local function MERCHANT_SHOW(event, ...)
    local bag = Inventory.main.bags.junk
    if not bag:IsShown() then return end
    if #bag.slots == 0 then
        -- items aren't updated yet, wait a frame.
        return _G.C_Timer.After(0, MERCHANT_SHOW)
    end

    private.CalculateJunkProfit(true)
    if Inventory.db.global.sellJunk then
        private.SellJunk()
    else
        bag.sellJunk:Show()
    end
end
local function MERCHANT_CLOSED(event, ...)
    local bag = Inventory.main.bags.junk

    bag.sellJunk:Hide()
    for _, slot in ipairs(bag.slots) do
        slot.JunkIcon:Hide()
    end
end


local bagEvents = {
    [_G.Enum.PlayerInteractionType.MailInfo] = -1,
    [_G.Enum.PlayerInteractionType.TradePartner] = 0,
    [_G.Enum.PlayerInteractionType.Auctioneer] = 0,
    [_G.Enum.PlayerInteractionType.GuildBanker] = 0,
    [_G.Enum.PlayerInteractionType.Merchant] = 0,
}

local bankInteractionType = {
    [_G.Enum.PlayerInteractionType.AccountBanker] = true,
    [_G.Enum.PlayerInteractionType.Banker] = true,
    [_G.Enum.PlayerInteractionType.CharacterBanker] = true,
}

function Inventory:PLAYER_INTERACTION_MANAGER_FRAME_SHOW(event, id)
    if bagEvents[id] and bagEvents[id] >= 0 then
        self:OpenBags()
    end

    if bankInteractionType[id] then
        self.atBank = true
        self:OpenBank()
    elseif id == _G.Enum.PlayerInteractionType.Merchant then
        MERCHANT_SHOW()
    end
end

function Inventory:PLAYER_INTERACTION_MANAGER_FRAME_HIDE(event, id)
    if bagEvents[id] and bagEvents[id] <= 0 then
        self:CloseBags()
    end

    if bankInteractionType[id] then
        self:CloseBank()
        self.atBank = false
    elseif id == _G.Enum.PlayerInteractionType.Merchant then
        MERCHANT_CLOSED()
    end
end

Inventory:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_SHOW")
Inventory:RegisterEvent("PLAYER_INTERACTION_MANAGER_FRAME_HIDE")
