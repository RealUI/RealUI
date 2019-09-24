local _, private = ...

-- Lua Globals --
-- luacheck: globals wipe next tinsert sort tonumber

-- RealUI --
local RealUI = _G.RealUI
local characterInfo = RealUI.charInfo

local Tooltips = private.Tooltips
local currencyDB

local neutralTCoords = {0.140625, 0.28125, 0.5625, 0.84375}
local function GetInlineFactionIcon(faction)
    local coords = _G.QUEST_TAG_TCOORDS[faction:upper()] or neutralTCoords
    return _G.CreateTextureMarkup(_G.QUEST_ICONS_FILE, _G.QUEST_ICONS_FILE_WIDTH, _G.QUEST_ICONS_FILE_HEIGHT, 16, 16
    , coords[1]
    , coords[2]
    , coords[3]
    , coords[4], 0, 0)
end
local function CharSort(a, b)
    return a.name < b.name
end

local characterList, characterName = {}, "%s %s %s"
local function UpdateCharacterList(currencyID, includePlayer)
    wipe(characterList)
    local playerInfo
    for index, realm in next, RealUI.realmInfo.connectedRealms do
        local realmDB = currencyDB[realm]
        if realmDB then
            for faction, factionDB in next, realmDB do
                for name, data in next, factionDB do
                    if data[currencyID] then
                        if name ~= characterInfo.name then
                            tinsert(characterList, {
                                name = name,
                                class = data.class,
                                quantity = data[currencyID],
                                realm = characterInfo.realm == realm and "" or realm,
                                faction = GetInlineFactionIcon(faction)
                            })
                        elseif includePlayer then
                            playerInfo = {
                                name = name,
                                class = data.class,
                                quantity = data[currencyID],
                                realm = "",
                                faction = GetInlineFactionIcon(faction)
                            }
                        end
                    end
                end
            end
        end
    end

    sort(characterList, CharSort)
    if playerInfo then
        tinsert(characterList, 1, playerInfo)
    end

    return #characterList > 0
end
local function AddTooltipInfo(tooltip, currencyID, includePlayer)
    if currencyID and UpdateCharacterList(currencyID, includePlayer) then
        tooltip:AddLine(" ")
        for i = 1, #characterList do
            local charInfo = characterList[i]
            local r, g, b = _G.CUSTOM_CLASS_COLORS[charInfo.class]:GetRGB()
            local charName = characterName:format(charInfo.faction, charInfo.name, charInfo.realm)
            tooltip:AddDoubleLine(charName, charInfo.quantity, r, g, b, r, g, b)
        end
        tooltip:Show()
    end
end

local currencyNameToID = {}
local collapsed, scanning = {}
local function UpdateCurrency()
    if scanning then return end
    if not RealUI.realmInfo.realmNormalized then return end

    scanning = true
    local charDB = currencyDB[RealUI.realmInfo.realmNormalized][characterInfo.faction][characterInfo.name]

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

    wipe(collapsed)
    scanning = nil
end

local function UpdateMoney()
    if RealUI.realmInfo.realmNormalized then
        currencyDB[RealUI.realmInfo.realmNormalized][characterInfo.faction][characterInfo.name].money = _G.GetMoney() or 0
    end
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
            AddTooltipInfo(self, tonumber(id), true)
        end
    end)

    local frame = _G.CreateFrame("Frame")
    frame:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
    frame:RegisterEvent("PLAYER_MONEY")
    if characterInfo.faction == "Neutral" then
        frame:RegisterEvent("NEUTRAL_FACTION_SELECT_RESULT")
    end
    frame:SetScript("OnEvent", function(self, event, ...)
        Tooltips:debug("Currency:OnEvent", event, ...)
        if event == "NEUTRAL_FACTION_SELECT_RESULT" then
            local charInfo  = RealUI.charInfo
            charInfo.faction = _G.UnitFactionGroup("player")
            currencyDB[RealUI.realmInfo.realmNormalized][charInfo.faction][charInfo.name] = currencyDB[RealUI.realmInfo.realmNormalized]["Neutral"][charInfo.name]
            currencyDB[RealUI.realmInfo.realmNormalized]["Neutral"][charInfo.name] = nil
            UpdateCurrency()
        elseif event == "CURRENCY_DISPLAY_UPDATE" then
            UpdateCurrency()
        elseif event == "PLAYER_MONEY" then
            UpdateMoney()
        end
    end)
end


function private.SetupCurrency()
    currencyDB = RealUI.db.global.currency

    SetUpHooks()
    UpdateCurrency()
    UpdateMoney()
end
