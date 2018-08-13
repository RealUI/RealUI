local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local DB, realmDB, charDB

local MODNAME = "CurrencyTip"
local CurrencyTip = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local playerList = {}
local nameToID = {} -- maps localized currency names to IDs

------------------------------------------------------------------------

local collapsed, scanning = {}
local function UpdateCurrency()
    if scanning then return end
    scanning = true
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
            local id = _G.tonumber(link:match("currency:(%d+)"))
            nameToID[name] = id
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
    _G.wipe(collapsed)
    scanning = nil
end

local function UpdateMoney()
    charDB.money = _G.GetMoney() or 0
end

------------------------------------------------------------------------

local function AddTooltipInfo(tooltip, currency, includePlayer)
    local spaced
    for i = (includePlayer and 1 or 2), #playerList do
        local name = playerList[i]
        local n = realmDB[name][currency]
        if n then
            if not spaced then
                tooltip:AddLine(" ")
                spaced = true
            end
            local r, g, b
            if realmDB[name].class then
                r, g, b = _G.CUSTOM_CLASS_COLORS[realmDB[name].class]:GetRGB()
            else
                r, g, b = 0.5, 0.5, 0.5
            end
            tooltip:AddDoubleLine(name, n, r, g, b, r, g, b)
        end
    end
    if spaced then
        tooltip:Show()
    end
end

------------------------------------------------------------------------

function CurrencyTip:SetUpHooks()
    _G.hooksecurefunc(_G.GameTooltip, "SetCurrencyByID", function(tooltip, id)
        self:debug("SetCurrencyByID", id)
        AddTooltipInfo(tooltip, id, not _G.MerchantMoneyInset:IsMouseOver())
    end)
    _G.hooksecurefunc(_G.GameTooltip, "SetCurrencyToken", function(tooltip, i)
        local name = _G.GetCurrencyListInfo(i)
        self:debug("SetCurrencyToken", i, nameToID[name])
        AddTooltipInfo(_G.GameTooltip, nameToID[name], not _G.TokenFrame:IsMouseOver())
    end)
    _G.hooksecurefunc(_G.GameTooltip, "SetCurrencyTokenByID", function(tooltip, id)
        self:debug("SetCurrencyTokenByID", id)
        AddTooltipInfo(_G.GameTooltip, id, not _G.TokenFrame:IsMouseOver())
    end)

    _G.hooksecurefunc(_G.GameTooltip, "SetLFGDungeonReward", function(tooltip, dungeonID, lootIndex)
        local name = _G.GetLFGDungeonRewardInfo(dungeonID, lootIndex)
        self:debug("SetLFGDungeonReward", dungeonID, lootIndex, nameToID[name])
        AddTooltipInfo(_G.GameTooltip, nameToID[name], true)
    end)
    _G.hooksecurefunc(_G.GameTooltip, "SetLFGDungeonShortageReward", function(tooltip, dungeonID, shortageSeverity, lootIndex)
        local name = _G.GetLFGDungeonShortageRewardInfo(dungeonID, shortageSeverity, lootIndex)
        self:debug("SetLFGDungeonShortageReward", dungeonID, shortageSeverity, lootIndex, nameToID[name])
        AddTooltipInfo(_G.GameTooltip, nameToID[name], true)
    end)

    _G.hooksecurefunc(_G.GameTooltip, "SetHyperlink", function(tooltip, link)
        local id = link:match("currency:(%d+)")
        self:debug("SetHyperlink", link, id)
        if id then
            AddTooltipInfo(tooltip, _G.tonumber(id), true)
        end
    end)
    _G.hooksecurefunc(_G.ItemRefTooltip, "SetHyperlink", function(tooltip, link)
        local id = link:match("currency:(%d+)")
        self:debug("SetHyperlink", link, id)
        if id then
            AddTooltipInfo(tooltip, _G.tonumber(id), true)
        end
    end)

    _G.hooksecurefunc(_G.GameTooltip, "SetMerchantCostItem", function(tooltip, item, currency)
        local _, _, _, name = _G.GetMerchantItemCostItem(item, currency)
        self:debug("SetMerchantCostItem", item, currency, nameToID[name])
        AddTooltipInfo(tooltip, nameToID[name], true)
    end)
end

function CurrencyTip:NEUTRAL_FACTION_SELECT_RESULT(...)
    self:debug("CURRENCY_DISPLAY_UPDATE", ...)
    local charInfo  = RealUI.charInfo
    charInfo.faction = _G.UnitFactionGroup("player")
    DB[charInfo.realmNormalized][charInfo.faction][charInfo.name] = DB[charInfo.realmNormalized]["Neutral"][charInfo.name]
    DB[charInfo.realmNormalized]["Neutral"][charInfo.name] = nil
    UpdateCurrency()
end
function CurrencyTip:CURRENCY_DISPLAY_UPDATE(...)
    self:debug("CURRENCY_DISPLAY_UPDATE", ...)
    UpdateCurrency()
end
function CurrencyTip:PLAYER_MONEY(...)
    self:debug("PLAYER_MONEY", ...)
    UpdateMoney()
end

--------------------
-- Initialization --
--------------------
function CurrencyTip:OnInitialize()
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function CurrencyTip:OnEnable()
    self:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    self:RegisterEvent("PLAYER_MONEY")
    if RealUI.charInfo.faction == "Neutral" then
        self:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
    end

    RealUI:InitCurrencyDB()

    local player  = RealUI.charInfo.name

    DB = RealUI.db.global.currency
    realmDB = DB[RealUI.charInfo.realmNormalized][RealUI.charInfo.faction]
    charDB = realmDB[player]

    for name, data in next, realmDB do
        if name ~= player then
            _G.tinsert(playerList, name)
        end
    end

    _G.sort(playerList)
    _G.tinsert(playerList, 1, player)
    self:SetUpHooks()

    UpdateCurrency()
    UpdateMoney()
end
