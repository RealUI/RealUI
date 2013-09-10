local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "CurrencyTip"
local CurrencyTip = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local DB, realmDB, charDB

local playerList = {}
local classColor = {}

local nameToID = {} -- maps localized currency names to IDs

------------------------------------------------------------------------

local collapsed, scanning = {}
local function UpdateData()
	if scanning then return end
	scanning = true
	local i, limit = 1, GetCurrencyListSize()
	while i <= limit do
		local name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(i)
		if isHeader then
			if not isExpanded then
				collapsed[name] = true
				ExpandCurrencyList(i, 1)
				limit = GetCurrencyListSize()
			end
		else
			local link = GetCurrencyListLink(i)
			local id = tonumber(strmatch(link, "currency:(%d+)"))
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
		local name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(i)
		if isHeader and isExpanded and collapsed[name] then
			ExpandCurrencyList(i, 0)
		end
		i = i - 1
	end
	wipe(collapsed)
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
				classColor = nibRealUI:GetClassColor(class)
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
	hooksecurefunc("BackpackTokenFrame_Update", UpdateData)
	hooksecurefunc("TokenFrame_Update", UpdateData)

	hooksecurefunc(GameTooltip, "SetCurrencyByID", function(tooltip, id)
		--print("SetCurrencyByID", id)
		AddTooltipInfo(tooltip, id, not MerchantMoneyInset:IsMouseOver())
	end)

	hooksecurefunc(GameTooltip, "SetCurrencyToken", function(tooltip, i)
		--print("SetCurrencyToken", i)
		local name, isHeader, isExpanded, isUnused, isWatched, count, icon = GetCurrencyListInfo(i)
		AddTooltipInfo(GameTooltip, nameToID[name], not TokenFrame:IsMouseOver())
	end)

	hooksecurefunc(GameTooltip, "SetHyperlink", function(tooltip, link)
		--print("SetHyperlink", link)
		local id = strmatch(link, "currency:(%d+)")
		if id then
			AddTooltipInfo(tooltip, tonumber(id), true)
		end
	end)

	hooksecurefunc(ItemRefTooltip, "SetHyperlink", function(tooltip, link)
		--print("SetHyperlink", link)
		local id = strmatch(link, "currency:(%d+)")
		if id then
			AddTooltipInfo(tooltip, tonumber(id), true)
		end
	end)

	hooksecurefunc(GameTooltip, "SetMerchantCostItem", function(tooltip, item, currency)
		--print("SetMerchantCostItem", item, currency)
		local icon, _, _, name = GetMerchantItemCostItem(item, currency)
		AddTooltipInfo(tooltip, nameToID[name], true)
	end)
end

function CurrencyTip:SetUpChar()
	local realm   = nibRealUI.realm
	local faction = nibRealUI.faction
	local player  = nibRealUI.name

	for k,v in pairs(DB[realm]) do
		if k ~= "Alliance" and k ~= "Horde" then
			DB[realm][k] = nil
		end
	end

	realmDB = DB[realm][faction]
	if not realmDB then return end -- probably low level Pandaren

	charDB = realmDB[player]

	local now = time()
	charDB.class = nibRealUI.class
	charDB.lastSeen = now

	local cutoff = now - (60 * 60 * 24 * 30)
	for name, data in pairs(realmDB) do
		if data.lastSeen and data.lastSeen < cutoff then
			realmDB[name] = nil
		elseif name ~= player then
			tinsert(playerList, name)
		end
	end
	sort(playerList)
	tinsert(playerList, 1, player)
	
	self:SetUpHooks()
	
	UpdateData()
end

--------------------
-- Initialization --
--------------------
function CurrencyTip:OnInitialize()
	local otherFaction = nibRealUI:OtherFaction(nibRealUI.faction)
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		global = {
			currency = {
				[nibRealUI.realm] = {
					[nibRealUI.faction] = {
						[nibRealUI.name] = {
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
	charDB = self.db.global.currency[nibRealUI.realm][nibRealUI.faction][nibRealUI.name]
	realmDB = self.db.global.currency[nibRealUI.realm]
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
end

function CurrencyTip:OnEnable()
	self:SetUpChar()
	--self:RegisterEvent("PLAYER_LOGIN")
end