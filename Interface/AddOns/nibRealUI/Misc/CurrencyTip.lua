local _, private = ...

-- Lua Globals --
local _G = _G
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
local function UpdateData()
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

------------------------------------------------------------------------

local classColor
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
            local class = realmDB[name].class
            if class then
                classColor = RealUI:GetClassColor(class)
                r, g, b = classColor[1], classColor[2], classColor[3]
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
    _G.hooksecurefunc("BackpackTokenFrame_Update", UpdateData)
    _G.hooksecurefunc("TokenFrame_Update", UpdateData)

    _G.hooksecurefunc(_G.GameTooltip, "SetCurrencyByID", function(tooltip, id)
        --print("SetCurrencyByID", id)
        AddTooltipInfo(tooltip, id, not _G.MerchantMoneyInset:IsMouseOver())
    end)

    _G.hooksecurefunc(_G.GameTooltip, "SetCurrencyToken", function(tooltip, i)
        --print("SetCurrencyToken", i)
        local name = _G.GetCurrencyListInfo(i)
        AddTooltipInfo(_G.GameTooltip, nameToID[name], not _G.TokenFrame:IsMouseOver())
    end)

    _G.hooksecurefunc(_G.GameTooltip, "SetHyperlink", function(tooltip, link)
        --print("SetHyperlink", link)
        local id = link:match("currency:(%d+)")
        if id then
            AddTooltipInfo(tooltip, _G.tonumber(id), true)
        end
    end)

    _G.hooksecurefunc(_G.ItemRefTooltip, "SetHyperlink", function(tooltip, link)
        --print("SetHyperlink", link)
        local id = link:match("currency:(%d+)")
        if id then
            AddTooltipInfo(tooltip, _G.tonumber(id), true)
        end
    end)

    _G.hooksecurefunc(_G.GameTooltip, "SetMerchantCostItem", function(tooltip, item, currency)
        --print("SetMerchantCostItem", item, currency)
        local _, _, _, name = _G.GetMerchantItemCostItem(item, currency)
        AddTooltipInfo(tooltip, nameToID[name], true)
    end)
end

function CurrencyTip:SetUpChar()
    local realm   = RealUI.realm
    local faction = RealUI.faction
    local player  = RealUI.name

    for k,v in next, DB[realm] do
        if k ~= "Alliance" and k ~= "Horde" then
            DB[realm][k] = nil
        end
    end

    realmDB = DB[realm][faction]
    if not realmDB then return end -- probably low level Pandaren

    charDB = realmDB[player]

    local now = _G.time()
    charDB.class = RealUI.class
    charDB.lastSeen = now

    local cutoff = now - (60 * 60 * 24 * 30)
    for name, data in next, realmDB do
        if data.lastSeen and data.lastSeen < cutoff then
            realmDB[name] = nil
        elseif name ~= player then
            _G.tinsert(playerList, name)
        end
    end
    _G.sort(playerList)
    _G.tinsert(playerList, 1, player)
    
    self:SetUpHooks()
    
    UpdateData()
end

--------------------
-- Initialization --
--------------------
function CurrencyTip:OnInitialize()
    local otherFaction = RealUI:OtherFaction(RealUI.faction)
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        global = {
            currency = {
                [RealUI.realm] = {
                    [RealUI.faction] = {
                        [RealUI.name] = {
                            class = "",
                            lastSeen = nil,
                        },
                    },
                    [otherFaction] = {},
                },
            },
        },
    })
    DB = self.db.global.currency
    charDB = self.db.global.currency[RealUI.realm][RealUI.faction][RealUI.name]
    realmDB = self.db.global.currency[RealUI.realm]
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function CurrencyTip:OnEnable()
    self:SetUpChar()
    --self:RegisterEvent("PLAYER_LOGIN")
end
