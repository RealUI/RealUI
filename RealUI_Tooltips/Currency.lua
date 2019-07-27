local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- RealUI --
local RealUI = _G.RealUI
local Tooltips = private.Tooltips
local currencyDB, realmDB, charDB

local characterList = {}
local currencyNameToID = {}

local function AddTooltipInfo(tooltip, currency, includePlayer)
    local spaced
    for i = (includePlayer and 1 or 2), #characterList do
        local charName = characterList[i]
        local currencyQuantity = realmDB[charName][currency]
        if currencyQuantity then
            if not spaced then
                tooltip:AddLine(" ")
                spaced = true
            end
            local r, g, b
            if realmDB[charName].class then
                r, g, b = _G.CUSTOM_CLASS_COLORS[realmDB[charName].class]:GetRGB()
            else
                r, g, b = 0.5, 0.5, 0.5
            end
            tooltip:AddDoubleLine(charName, currencyQuantity, r, g, b, r, g, b)
        end
    end
    if spaced then
        tooltip:Show()
    end
end

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
    _G.wipe(collapsed)
    scanning = nil
end

local function UpdateMoney()
    charDB.money = _G.GetMoney() or 0
end

local function SetUpHooks()
    private.AddHook("SetCurrencyByID", function(self, currencyID, quantity)
        AddTooltipInfo(self, currencyID, not _G.MerchantMoneyInset:IsMouseOver())
    end)
    private.AddHook("SetCurrencyToken", function(self, index)
        local name = _G.GetCurrencyListInfo(index)
        AddTooltipInfo(self, currencyNameToID[name], not _G.TokenFrame:IsMouseOver())
    end)
    private.AddHook("SetCurrencyTokenByID", function(self, currencyID)
        AddTooltipInfo(self, currencyID, not _G.TokenFrame:IsMouseOver())
    end)

    private.AddHook("SetLFGDungeonReward", function(self, dungeonID, rewardIndex)
        local name = _G.GetLFGDungeonRewardInfo(dungeonID, rewardIndex)
        AddTooltipInfo(self, currencyNameToID[name], true)
    end)
    private.AddHook("SetLFGDungeonShortageReward", function(self, dungeonID, shortageIndex, rewardIndex)
        local name = _G.GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex)
        AddTooltipInfo(self, currencyNameToID[name], true)
    end)

    private.AddHook("SetMerchantCostItem", function(self, slotIndex, itemIndex)
        local _, _, _, name = _G.GetMerchantItemCostItem(slotIndex, itemIndex)
        AddTooltipInfo(self, currencyNameToID[name], true)
    end)

    private.AddHook("SetHyperlink", function(self, link)
        local id = link:match("currency:(%d+)")
        if id then
            AddTooltipInfo(self, _G.tonumber(id), true)
        end
    end)
end

local frame = _G.CreateFrame("Frame")
frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
frame:RegisterEvent("PLAYER_MONEY")
frame:SetScript("OnEvent", function(self, event, ...)
    Tooltips:debug("Currency:OnEvent", event, ...)
    if event == "NEUTRAL_FACTION_SELECT_RESULT" then
        local charInfo  = RealUI.charInfo
        charInfo.faction = _G.UnitFactionGroup("player")
        currencyDB[charInfo.realmNormalized][charInfo.faction][charInfo.name] = currencyDB[charInfo.realmNormalized]["Neutral"][charInfo.name]
        currencyDB[charInfo.realmNormalized]["Neutral"][charInfo.name] = nil
        UpdateCurrency()
    elseif event == "CURRENCY_DISPLAY_UPDATE" then
        UpdateCurrency()
    elseif event == "PLAYER_MONEY" then
        UpdateMoney()
    end
end)

function private.SetupCurrency()
    RealUI:InitCurrencyDB()

    local charInfo = RealUI.charInfo
    if charInfo.faction == "Neutral" then
        frame:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
    end

    local player  = charInfo.name
    currencyDB = RealUI.db.global.currency
    realmDB = currencyDB[charInfo.realmNormalized][charInfo.faction]
    charDB = realmDB[player]

    for name, data in next, realmDB do
        if name ~= player then
            _G.tinsert(characterList, name)
        end
    end

    _G.sort(characterList)
    _G.tinsert(characterList, 1, player)

    SetUpHooks()
    UpdateCurrency()
    UpdateMoney()
end
