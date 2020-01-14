local _, private = ...

-- Lua Globals --
-- luacheck: globals wipe next tinsert sort tonumber

-- RealUI --
local RealUI = _G.RealUI
local Currency = RealUI:GetModule("Currency")
local characterInfo = RealUI.charInfo

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

local function SetUpHooks()
    private.AddHook("SetCurrencyByID", function(self, currencyID, quantity)
        AddTooltipInfo(self, currencyID, not _G.MerchantMoneyInset:IsMouseOver())
    end)
    private.AddHook("SetCurrencyToken", function(self, index)
        local name = _G.GetCurrencyListInfo(index)
        AddTooltipInfo(self, Currency:GetCurrencyID(name), not _G.TokenFrame:IsMouseOver())
    end)
    private.AddHook("SetCurrencyTokenByID", function(self, currencyID)
        AddTooltipInfo(self, currencyID, not _G.TokenFrame:IsMouseOver())
    end)

    private.AddHook("SetLFGDungeonReward", function(self, dungeonID, rewardIndex)
        local name = _G.GetLFGDungeonRewardInfo(dungeonID, rewardIndex)
        AddTooltipInfo(self, Currency:GetCurrencyID(name), true)
    end)
    private.AddHook("SetLFGDungeonShortageReward", function(self, dungeonID, shortageIndex, rewardIndex)
        local name = _G.GetLFGDungeonShortageRewardInfo(dungeonID, shortageIndex, rewardIndex)
        AddTooltipInfo(self, Currency:GetCurrencyID(name), true)
    end)

    private.AddHook("SetMerchantCostItem", function(self, slotIndex, itemIndex)
        local _, _, _, name = _G.GetMerchantItemCostItem(slotIndex, itemIndex)
        AddTooltipInfo(self, Currency:GetCurrencyID(name), true)
    end)

    private.AddHook("SetHyperlink", function(self, link)
        local id = link:match("currency:(%d+)")
        if id then
            AddTooltipInfo(self, tonumber(id), true)
        end
    end)
end


function private.SetupCurrency()
    currencyDB = RealUI.db.global.currency

    SetUpHooks()
end
