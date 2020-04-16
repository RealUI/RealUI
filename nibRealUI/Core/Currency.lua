local _, private = ...

-- Lua Globals --
-- luacheck: globals tonumber wipe next

-- RealUI --
local RealUI = private.RealUI
local characterInfo = RealUI.charInfo

local MODNAME = "Currency"
local Currency = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local currencyNameToID = {}
function Currency:GetCurrencyID(name)
    return currencyNameToID[name]
end

local collapsed, scanning = {}
local function UpdateCurrency()
    if scanning then return end
    if not RealUI.realmInfo.realmNormalized then return end

    scanning = true
    local currencyDB = RealUI.db.global.currency
    local charDB = currencyDB[RealUI.realmInfo.realmNormalized][characterInfo.faction][characterInfo.name]

    if RealUI.isPatch then
        local i, limit = 1, _G.C_CurrencyInfo.GetCurrencyListSize()
        while i <= limit do
            local currencyInfo = _G.C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyInfo.isHeader then
                if not currencyInfo.isHeaderExpanded then
                    collapsed[currencyInfo.name] = true
                    _G.C_CurrencyInfo.ExpandCurrencyList(i, true)
                    limit = _G.C_CurrencyInfo.GetCurrencyListSize()
                end
            else
                local link = _G.C_CurrencyInfo.GetCurrencyListLink(i)
                local id = tonumber(link:match("currency:(%d+)"))
                currencyNameToID[currencyInfo.name] = id
                if currencyInfo.quantity > 0 then
                    charDB[id] = currencyInfo.quantity
                else
                    charDB[id] = nil
                end
            end
            i = i + 1
        end

        while i > 0 do
            local currencyInfo = _G.C_CurrencyInfo.GetCurrencyListInfo(i)
            if currencyInfo and currencyInfo.isHeader and currencyInfo.isHeaderExpanded and collapsed[currencyInfo.name] then
                _G.C_CurrencyInfo.ExpandCurrencyList(i, false)
            end
            i = i - 1
        end
    else
        local i, limit = 1, _G.GetCurrencyListSize()
        while i <= limit do
            local name, isHeader, isExpanded, _, _, count = _G.GetCurrencyListInfo(i)
            if isHeader then
                if not isExpanded then
                    collapsed[name] = true
                    _G.ExpandCurrencyList(i, 1)
                    limit = _G.GetCurrencyListSize()
                end
            else
                local link = _G.GetCurrencyListLink(i)
                local id = tonumber(link:match("currency:(%d+)"))
                currencyNameToID[name] = id
                if count > 0 then
                    charDB[id] = count
                else
                    charDB[id] = nil
                end
            end
            i = i + 1
        end

        while i > 0 do
            local name, isHeader, isExpanded = _G.GetCurrencyListInfo(i)
            if isHeader and isExpanded and collapsed[name] then
                _G.ExpandCurrencyList(i, 0)
            end
            i = i - 1
        end
    end

    wipe(collapsed)
    scanning = nil
end

local function UpdateMoney()
    RealUI.db.global.currency[RealUI.realmInfo.realmNormalized][characterInfo.faction][characterInfo.name].money = _G.GetMoney() or 0
end

local THIRTY_DAYS = 60 * 60 * 24 * 30
local function SetupCurrency()
    local currencyDB = RealUI.db.global.currency
    local realmInfo = RealUI.realmInfo

    -- clear out old data
    local now = _G.time()
    for index, realm in next, realmInfo.connectedRealms do
        local realmDB = currencyDB[realm]
        if realmDB then
            for faction, factionDB in next, realmDB do
                for name, data in next, factionDB do
                    if (not data.lastSeen or not data.class) or not data.money then
                        currencyDB[realm][faction][name] = nil
                    elseif (now - data.lastSeen) >= THIRTY_DAYS then
                        currencyDB[realm][faction][name] = nil
                    end
                end
            end
        end
    end

    -- init current player
    local charInfo = RealUI.charInfo
    local realm   = realmInfo.realmNormalized
    local faction = charInfo.faction
    local player  = charInfo.name

    if not currencyDB[realm] then
        currencyDB[realm] = {}
    end
    if not currencyDB[realm][faction] then
        currencyDB[realm][faction] = {}
    end
    if not currencyDB[realm][faction][player] then
        currencyDB[realm][faction][player] = {
            class = charInfo.class.token
        }
    end

    currencyDB[realm][faction][player].lastSeen = now
end

function Currency:NormalizedRealmReceived()
    SetupCurrency()
    UpdateMoney()
end

function Currency:NEUTRAL_FACTION_SELECT_RESULT()
    characterInfo.faction = _G.UnitFactionGroup("player")

    local currencyDB = RealUI.db.global.currency
    currencyDB[RealUI.realmInfo.realmNormalized][characterInfo.faction][characterInfo.name] = currencyDB[RealUI.realmInfo.realmNormalized]["Neutral"][characterInfo.name]
    currencyDB[RealUI.realmInfo.realmNormalized]["Neutral"][characterInfo.name] = nil
    UpdateCurrency()
end

function Currency:OnInitialize()
    if RealUI.realmInfo.realmNormalized then
        self:NormalizedRealmReceived()
    else
        self:RegisterMessage("NormalizedRealmReceived")
    end

    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE", UpdateCurrency)
    self:RegisterEvent("PLAYER_MONEY", UpdateMoney)
    if characterInfo.faction == "Neutral" then
        self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
    end
end
