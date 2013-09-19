local addon, ns = ...
local cargBags = ns.cargBags

cargBags_Nivaya = CreateFrame('Frame', 'cargBags_Nivaya', UIParent)
cargBags_Nivaya:SetScript('OnEvent', function(self, event, ...) self[event](self, event, ...) end)
cargBags_Nivaya:RegisterEvent("ADDON_LOADED")

local cbNivaya = cargBags:GetImplementation("Nivaya")
--cbNivCatDropDown = CreateFrame("Frame", "cbNivCatDropDown", UIParent, "UIDropDownMenuTemplate")

do	--Replacement for UIDropDownMenu

	local font = RealUI.font.pixel1
	local frameHeight = 14
	local defaultWidth = 120
	local frameInset = 16

	local f = cbNivCatDropDown or CreateFrame("Frame", "cbNivCatDropDown", UIParent)
	f.ActiveButtons = 0
	f.Buttons = {}
	
	f:SetFrameStrata("FULLSCREEN_DIALOG")
	f:SetSize(defaultWidth+frameInset,32)
	f:SetClampedToScreen(true)

	local inset = 1
	f:SetBackdrop({bgFile = "Interface\\Buttons\\WHITE8x8", 
		edgeFile = "Interface\\Buttons\\WHITE8x8", 
		tile = true, tileSize = 16, edgeSize = 1, 
		insets = { left = inset, right = inset, top = inset, bottom = inset }})
	f:SetBackdropColor(unpack(RealUI.media.window))
	f:SetBackdropBorderColor(0, 0, 0)

	function f:CreateButton()
		
		local button = CreateFrame("Button", nil, self)
		button:SetWidth(defaultWidth)
		button:SetHeight(frameHeight)
		
		local fstr = button:CreateFontString()
		fstr:SetJustifyH("LEFT")
		fstr:SetJustifyV("MIDDLE")
		fstr:SetFont(unpack(font))
		fstr:SetPoint("LEFT", button, "LEFT", 0, 0)
		button.Text = fstr
		
		function button:SetText(str)
			button.Text:SetText(str)
		end
		
		button:SetText("test")
		
		local ntex = button:CreateTexture()
		ntex:SetTexture(1,1,1,0)
		ntex:SetAllPoints()	
		button:SetNormalTexture(ntex)
		
		local htex = button:CreateTexture()
		htex:SetTexture(1,1,1,0.2)
		htex:SetAllPoints()
		button:SetHighlightTexture(htex)
		
		local ptex = button:CreateTexture()
		ptex:SetTexture(1,1,1,0.4)
		ptex:SetAllPoints()
		button:SetPushedTexture(ptex)
		
		return button
		
	end

	function f:AddButton(text, value, func)
		
		local bID = self.ActiveButtons+1
		
		local btn = self.Buttons[bID] or self:CreateButton()
		
		btn:SetText(text or "")
		btn.value = value
		btn.func = func or function() end
		
		btn:SetScript("OnClick", function(self, ...) self:func(...) self:GetParent():Hide() end)
		
		btn:ClearAllPoints()
		if bID == 1 then
			btn:SetPoint("TOP", self, "TOP", 0, -(frameInset/2))
		else
			btn:SetPoint("TOP", self.Buttons[bID-1], "BOTTOM", 0, 0)
		end
		
		self.Buttons[bID] = btn
		self.ActiveButtons = bID
		
		self:UpdateSize()

	end

	function f:UpdatePosition(frame, point, relativepoint, ofsX, ofsY)
		
		point, relativepoint, ofsX, ofsY = point or "TOPLEFT", relativepoint or "BOTTOMLEFT", ofsX or 0, ofsY or 0
		
		self:ClearAllPoints()
		self:SetPoint(point, frame, relativepoint, ofsX, ofsY)
		
	end

	function f:UpdateSize()

		local maxButtons = self.ActiveButtons
		local maxwidth = defaultWidth
		
		for i=1,maxButtons do
		
			local width = self.Buttons[i].Text:GetWidth()
			if width > maxwidth then maxwidth = width end
		
		end
		
		for i=1,maxButtons do
			self.Buttons[i]:SetWidth(maxwidth)
		end
		
		local height = maxButtons * frameHeight
		
		self:SetSize(maxwidth+frameInset, height+frameInset)
		
	end

	function f:Toggle(frame, point, relativepoint, ofsX, ofsY)
		cbNivaya:CatDropDownInit()
		self:UpdatePosition(frame, point, relativepoint, ofsX, ofsY)
		self:Show()
	end
	
	tinsert(UISpecialFrames,f:GetName())

end

---------------------------------------------
---------------------------------------------
local L = cBnivL
cB_Bags = {}
cB_BagHidden = {}
cB_CustomBags = {}

-- Those are default values only, change them ingame via "/cbniv":
local optDefaults = {
					NewItems = true,
					Restack = true,
					TradeGoods = true,
					Armor = true,
					CoolStuff = false,
					Junk = true,
					ItemSets = true,
					Consumables = true,
					Quest = true,
					BankBlack = true,
					scale = 1,
					FilterBank = true,
					CompressEmpty = true,
					Unlocked = true,
					SortBags = true,
					SortBank = true,
					BankCustomBags = true,
					SellJunk = true,
					}

-- Those are internal settings, don't touch them at all:
local defaults =	{ 
					}

local ItemSetCaption = (IsAddOnLoaded('ItemRack') and "ItemRack ") or (IsAddOnLoaded('Outfitter') and "Outfitter ") or "Item "
local bankOpenState = false

function cbNivaya:ShowBags(...) for i = 1, select("#", ...) do local bag = select(i, ...); if not cB_BagHidden[bag.name] then bag:Show() end end end
function cbNivaya:HideBags(...) for i = 1, select("#", ...) do select(i, ...):Hide() end end

local LoadDefaults = function()
	cBniv = cBniv or {}
	for k,v in pairs(defaults) do
		if(type(cBniv[k]) == 'nil') then cBniv[k] = v end
	end
	cBnivCfg = cBnivCfg or {}
	for k,v in pairs(optDefaults) do
		if(type(cBnivCfg[k]) == 'nil') then cBnivCfg[k] = v end
	end
end

function cargBags_Nivaya:ADDON_LOADED(event, addon)

	if (addon ~= 'cargBags_Nivaya') then return end
	self:UnregisterEvent(event)
	
	LoadDefaults()
	--UIDropDownMenu_Initialize(cbNivCatDropDown, cbNivaya.CatDropDownInit, "MENU")
	
	cB_filterEnabled["Armor"] = cBnivCfg.Armor
	cB_filterEnabled["TradeGoods"] = cBnivCfg.TradeGoods
	cB_filterEnabled["Junk"] = cBnivCfg.Junk
	cB_filterEnabled["ItemSets"] = cBnivCfg.ItemSets
	cB_filterEnabled["Consumables"] = cBnivCfg.Consumables
	cB_filterEnabled["Quest"] = cBnivCfg.Quest
	cBniv.BankCustomBags = cBnivCfg.BankCustomBags
	cBniv.BagPos = true

	-----------------
	-- Frame Spawns
	-----------------
	local C = cbNivaya:GetContainerClass()

	-- bank bags
	cB_Bags.bankSets		= C:New("cBniv_BankSets")
	
	if cBniv.BankCustomBags then
		for _,v in ipairs(cB_CustomBags) do 
			cB_Bags['Bank'..v.name] = C:New('Bank'..v.name) 
			cB_existsBankBag[v.name] = true
		end
	end
	
	cB_Bags.bankArmor		= C:New("cBniv_BankArmor")
	cB_Bags.bankConsumables	= C:New("cBniv_BankCons")
	cB_Bags.bankBattlePet	= C:New("cBniv_BankPet")
	cB_Bags.bankQuest		= C:New("cBniv_BankQuest")
	cB_Bags.bankTrade		= C:New("cBniv_BankTrade")
	cB_Bags.bank			= C:New("cBniv_Bank")

	cB_Bags.bankSets		:SetMultipleFilters(true, cB_Filters.fBank, cB_Filters.fBankFilter, cB_Filters.fItemSets)
	cB_Bags.bankArmor		:SetExtendedFilter(cB_Filters.fItemClass, "BankArmor")
	cB_Bags.bankConsumables :SetExtendedFilter(cB_Filters.fItemClass, "BankConsumables")
	cB_Bags.bankBattlePet	:SetExtendedFilter(cB_Filters.fItemClass, "BankBattlePet")
	cB_Bags.bankQuest		:SetExtendedFilter(cB_Filters.fItemClass, "BankQuest")
	cB_Bags.bankTrade		:SetExtendedFilter(cB_Filters.fItemClass, "BankTradeGoods")
	cB_Bags.bank			:SetMultipleFilters(true, cB_Filters.fBank, cB_Filters.fHideEmpty)
	if cBniv.BankCustomBags then
		for _,v in ipairs(cB_CustomBags) do cB_Bags['Bank'..v.name]:SetExtendedFilter(cB_Filters.fItemClass, 'Bank'..v.name) end
	end

	-- inventory bags
	cB_Bags.key			= C:New("cBniv_Keyring")
	cB_Bags.bagItemSets	= C:New("cBniv_ItemSets")
	cB_Bags.bagStuff	= C:New("cBniv_Stuff")
	
	for _,v in ipairs(cB_CustomBags) do 
		if (v.prio > 0) then 
			cB_Bags[v.name] = C:New(v.name, { isCustomBag = true } )
			v.active = true
			cB_filterEnabled[v.name] = true
		end 
	end
	
	cB_Bags.bagJunk		= C:New("cBniv_Junk")
	cB_Bags.bagNew		= C:New("cBniv_NewItems")

	for _,v in ipairs(cB_CustomBags) do 
		if (v.prio <= 0) then 
			cB_Bags[v.name] = C:New(v.name, { isCustomBag = true } )
			v.active = true
			cB_filterEnabled[v.name] = true
		end
	end
	cB_Bags.armor		= C:New("cBniv_Armor")
	cB_Bags.quest		= C:New("cBniv_Quest")
	cB_Bags.consumables	= C:New("cBniv_Consumables")
	cB_Bags.battlepet	= C:New("cBniv_BattlePet")
	cB_Bags.tradegoods	= C:New("cBniv_TradeGoods")
	cB_Bags.main		= C:New("cBniv_Bag")

	cB_Bags.key			:SetExtendedFilter(cB_Filters.fItemClass, "Keyring")
	cB_Bags.bagItemSets	:SetFilter(cB_Filters.fItemSets, true)
	cB_Bags.bagStuff	:SetExtendedFilter(cB_Filters.fItemClass, "Stuff")
	cB_Bags.bagJunk		:SetExtendedFilter(cB_Filters.fItemClass, "Junk")
	cB_Bags.bagNew		:SetFilter(cB_Filters.fNewItems, true)
	cB_Bags.armor		:SetExtendedFilter(cB_Filters.fItemClass, "Armor")
	cB_Bags.quest		:SetExtendedFilter(cB_Filters.fItemClass, "Quest")
	cB_Bags.consumables	:SetExtendedFilter(cB_Filters.fItemClass, "Consumables")
	cB_Bags.battlepet	:SetExtendedFilter(cB_Filters.fItemClass, "BattlePet")
	cB_Bags.tradegoods	:SetExtendedFilter(cB_Filters.fItemClass, "TradeGoods")
	cB_Bags.main		:SetMultipleFilters(true, cB_Filters.fBags, cB_Filters.fHideEmpty)
	for _,v in pairs(cB_CustomBags) do cB_Bags[v.name]:SetExtendedFilter(cB_Filters.fItemClass, v.name) end

	cB_Bags.main:SetPoint("BOTTOMRIGHT", -99, 26)
	cB_Bags.bank:SetPoint("TOPLEFT", 20, -20)
	
	cbNivaya:CreateAnchors()
	cbNivaya:Init()
	cbNivaya:ToggleBagPosButtons()
end

function cbNivaya:CreateAnchors()
	-----------------------------------------------
	-- Store the anchoring order:
	-- read: "tar" is anchored to "src" in the direction denoted by "dir".
	-----------------------------------------------
	local function CreateAnchorInfo(src, tar, dir)
		tar.AnchorTo = src
		tar.AnchorDir = dir
		if src then
			if not src.AnchorTargets then src.AnchorTargets = {} end
			src.AnchorTargets[tar] = true
		end
	end
	
	-- neccessary if this function is used to update the anchors:
	for k,_ in pairs(cB_Bags) do
		if not ((k == 'main') or (k == 'bank')) then cB_Bags[k]:ClearAllPoints() end
		cB_Bags[k].AnchorTo = nil
		cB_Bags[k].AnchorDir = nil
		cB_Bags[k].AnchorTargets = nil
	end

	-- Main Anchors:
	CreateAnchorInfo(nil, cB_Bags.main, "Bottom")
	CreateAnchorInfo(nil, cB_Bags.bank, "Bottom")

	-- Bank Anchors:
	CreateAnchorInfo(cB_Bags.bank, cB_Bags.bankArmor, "Right")
	CreateAnchorInfo(cB_Bags.bankArmor, cB_Bags.bankSets, "Bottom")
	CreateAnchorInfo(cB_Bags.bankSets, cB_Bags.bankTrade, "Bottom")
	
	CreateAnchorInfo(cB_Bags.bank, cB_Bags.bankConsumables, "Bottom")
	CreateAnchorInfo(cB_Bags.bankConsumables, cB_Bags.bankQuest, "Bottom")
	CreateAnchorInfo(cB_Bags.bankQuest, cB_Bags.bankBattlePet, "Bottom")
	
	-- Bank Custom Container Anchors:
	if cBniv.BankCustomBags then
		local ref = { [0] = 0, [1] = 0 }
		for _,v in ipairs(cB_CustomBags) do
			if v.active then
				local c = v.col
				if ref[c] == 0 then ref[c] = (c == 0) and cB_Bags.bankQuest or cB_Bags.bankTrade end
				CreateAnchorInfo(ref[c], cB_Bags['Bank'..v.name], "Bottom")
				ref[c] = cB_Bags['Bank'..v.name]
			end
		end
	end
	
	-- Bag Anchors:
	CreateAnchorInfo(cB_Bags.main, 			cB_Bags.key, 			"Bottom")

	CreateAnchorInfo(cB_Bags.main, 			cB_Bags.bagItemSets, 	"Left")
	CreateAnchorInfo(cB_Bags.bagItemSets, 	cB_Bags.armor, 			"Top")
	CreateAnchorInfo(cB_Bags.armor, 		cB_Bags.battlepet, 		"Top")
	CreateAnchorInfo(cB_Bags.battlepet, 	cB_Bags.bagStuff, 		"Top")

	CreateAnchorInfo(cB_Bags.main, 			cB_Bags.tradegoods, 	"Top")
	CreateAnchorInfo(cB_Bags.tradegoods, 	cB_Bags.consumables, 	"Top")
	CreateAnchorInfo(cB_Bags.consumables, 	cB_Bags.quest, 			"Top")
	CreateAnchorInfo(cB_Bags.quest, 		cB_Bags.bagJunk, 		"Top")
	CreateAnchorInfo(cB_Bags.bagJunk, 		cB_Bags.bagNew, 		"Top")
	
	-- Custom Container Anchors:
	local ref = { [0] = 0, [1] = 0 }
	for _,v in ipairs(cB_CustomBags) do
		if v.active then
			local c = v.col
			if ref[c] == 0 then ref[c] = (c == 0) and cB_Bags.bagStuff or cB_Bags.bagNew end
			CreateAnchorInfo(ref[c], cB_Bags[v.name], "Top")
			ref[c] = cB_Bags[v.name]
		end
	end
	
	-- Finally update all anchors:
	for _,v in pairs(cB_Bags) do cbNivaya:UpdateAnchors(v) end
end

function cbNivaya:UpdateAnchors(self)
	if not self.AnchorTargets then return end
	for v,_ in pairs(self.AnchorTargets) do
		local t, u = v.AnchorTo, v.AnchorDir
		if t then
			local h = cB_BagHidden[t.name]
			v:ClearAllPoints()
			if	not h		and u == "Top"		then v:SetPoint("BOTTOM", t, "TOP", 0, 9)
			elseif	h		and u == "Top"		then v:SetPoint("BOTTOM", t, "BOTTOM")
			elseif	not h	and u == "Bottom"	then v:SetPoint("TOP", t, "BOTTOM", 0, -9)
			elseif	h		and u == "Bottom"	then v:SetPoint("TOP", t, "TOP")
			elseif	u == "Left"					then v:SetPoint("BOTTOMRIGHT", t, "BOTTOMLEFT", -9, 0)
			elseif	u == "Right"				then v:SetPoint("TOPLEFT", t, "TOPRIGHT", 9, 0) end
		end
	end
end

function cbNivaya:OnOpen()
	cB_Bags.main:Show()
	cbNivaya:ShowBags(cB_Bags.armor, cB_Bags.bagNew, cB_Bags.bagItemSets, cB_Bags.quest, cB_Bags.consumables, cB_Bags.battlepet, 
					  cB_Bags.tradegoods, cB_Bags.bagStuff, cB_Bags.bagJunk)
	for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:ShowBags(cB_Bags[v.name]) end end
end

function cbNivaya:OnClose()
	cbNivaya:HideBags(cB_Bags.main, cB_Bags.armor, cB_Bags.bagNew, cB_Bags.bagItemSets, cB_Bags.quest, cB_Bags.consumables, cB_Bags.battlepet, 
					  cB_Bags.tradegoods, cB_Bags.bagStuff, cB_Bags.bagJunk, cB_Bags.key)
	for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:HideBags(cB_Bags[v.name]) end end
end

function cbNivaya:OnBankOpened() 
	cB_Bags.bank:Show(); 
	cbNivaya:ShowBags(cB_Bags.bankSets, cB_Bags.bankArmor, cB_Bags.bankQuest, cB_Bags.bankTrade, cB_Bags.bankConsumables, cB_Bags.bankBattlePet) 
	if cBniv.BankCustomBags then
		for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:ShowBags(cB_Bags['Bank'..v.name]) end end
	end
end

function cbNivaya:OnBankClosed()
	cbNivaya:HideBags(cB_Bags.bank, cB_Bags.bankSets, cB_Bags.bankArmor, cB_Bags.bankQuest, cB_Bags.bankTrade, cB_Bags.bankConsumables, cB_Bags.bankBattlePet)
	if cBniv.BankCustomBags then
		for _,v in ipairs(cB_CustomBags) do if v.active then cbNivaya:HideBags(cB_Bags['Bank'..v.name]) end end
	end
end

function cbNivaya:ToggleBagPosButtons()
	for _,v in ipairs(cB_CustomBags) do 
		if v.active then 
			local b = cB_Bags[v.name]
			
			if cBniv.BagPos then
				b.rightBtn:Hide()
				b.leftBtn:Hide()
				b.downBtn:Hide()
				b.upBtn:Hide()
			else
				b.rightBtn:Show()
				b.leftBtn:Show()
				b.downBtn:Show()
				b.upBtn:Show()
			end
		end
	end
	cBniv.BagPos = not cBniv.BagPos
end

local SetFrameMovable = function(f, v)
	f:SetMovable(true)
	f:SetUserPlaced(true)
	f:RegisterForClicks("LeftButton", "RightButton")
	if v then 
		f:SetScript("OnMouseDown", function() 
			f:ClearAllPoints() 
			f:StartMoving() 
		end)
		f:SetScript("OnMouseUp",  f.StopMovingOrSizing)
	else
		f:SetScript("OnMouseDown", nil)
		f:SetScript("OnMouseUp", nil)
	end
end

local DropDownInitialized
function cbNivaya:CatDropDownInit()
	if DropDownInitialized then return end
	DropDownInitialized = true
	level = 1
	local info = {}--UIDropDownMenu_CreateInfo()
  
	local function AddInfoItem(type)
		local caption = "cBniv_"..type
		local t = L.bagCaptions[caption] or L[type]
		info.text = t and t or type
		info.value = type
		
		if (type == "-------------") or (type == CANCEL) then
			info.func = nil
		else
			info.func = function(self) cbNivaya:CatDropDownOnClick(self, type) end
		end
		
	--	info.owner = self:GetParent()
	--	UIDropDownMenu_AddButton(info, level)
		
		cbNivCatDropDown:AddButton(info.text, type, info.func)
	end

	AddInfoItem("MarkAsNew")
	AddInfoItem("MarkAsKnown")
	AddInfoItem("-------------")
	AddInfoItem("Armor")
	AddInfoItem("Consumables")
	AddInfoItem("Quest")
	AddInfoItem("TradeGoods")
	AddInfoItem("Stuff")
	AddInfoItem("Junk")
	AddInfoItem("Bag")
	for _,v in ipairs(cB_CustomBags) do
		if v.active then AddInfoItem(v.name) end
	end
	AddInfoItem("-------------")
	AddInfoItem(CANCEL)
	
	hooksecurefunc(NivayacBniv_Bag, "Hide", function() cbNivCatDropDown:Hide() end)
end

function cbNivaya:CatDropDownOnClick(self, type)
	local value = self.value
	local itemName = cbNivCatDropDown.itemName
	local itemID = cbNivCatDropDown.itemID

	if (type == "MarkAsNew") then
		cB_KnownItems[itemName] = nil
	elseif (type == "MarkAsKnown") then
		cB_KnownItems[itemName] = cbNivaya:getItemCount(itemName)
	else
		cBniv_CatInfo[itemID] = value
		if (itemID ~= nil) then cB_ItemClass[itemID] = nil end
	end
	cbNivaya:UpdateBags()
end

local function StatusMsg(str1, str2, data, name, short)
	local R,G,t = '|cFFFF0000', '|cFF00FF00', ''
	if (data ~= nil) then t = data and G..(short and 'on|r' or 'enabled|r') or R..(short and 'off|r' or 'disabled|r') end
	t = (name and '|cFFFFFF00cargBags_Nivaya:|r ' or '')..str1..t..str2
	ChatFrame1:AddMessage(t)
end

local function StatusMsgVal(str1, str2, data, name)
	local G,t = '|cFF00FF00', ''
	if (data ~= nil) then t = G..data..'|r' end
	t = (name and '|cFFFFFF00cargBags_Nivaya:|r ' or '')..str1..t..str2
	ChatFrame1:AddMessage(t)
end

local function HandleSlash(str)
	local str, str2 = strsplit(" ", str, 2)
	
	if ((str == 'addbag') or (str == 'delbag') or (str == 'movebag') or (str == 'bagprio') or (str == 'orderup') or (str == 'orderdn')) and (not str2) then
		StatusMsg('You have to specify a name, e.g. /cbniv '..str..' TestBag.', '', nil, true, false)
		return false
	end
	
	local numBags, idx = 0, -1
	for i,v in ipairs(cB_CustomBags) do
		numBags = numBags + 1
		if v.name == str2 then idx = i end
	end

	if ((str == 'delbag') or (str == 'movebag') or (str == 'bagprio') or (str == 'orderup') or (str == 'orderdn')) and (idx == -1) then
		StatusMsg('There is no custom container named |cFF00FF00'..str2, '|r.', nil, true, false)
		return false
	end
	
	if str == 'new' then
		cBnivCfg.NewItems = not cBnivCfg.NewItems
		StatusMsg('The "New Items" filter is now ', '.', cBnivCfg.NewItems, true, false)
	elseif str == 'trade' then
		cBnivCfg.TradeGoods = not cBnivCfg.TradeGoods
		cB_filterEnabled["TradeGoods"] = cBnivCfg.TradeGoods
		StatusMsg('The "Trade Goods" filter is now ', '.', cBnivCfg.TradeGoods, true, false)
	elseif str == 'armor' then
		cBnivCfg.Armor = not cBnivCfg.Armor
		cB_filterEnabled["Armor"] = cBnivCfg.Armor
		StatusMsg('The "Armor and Weapons" filter is now ', '.', cBnivCfg.Armor, true, false)
	elseif str == 'junk' then
		cBnivCfg.Junk = not cBnivCfg.Junk
		cB_filterEnabled["Junk"] = cBnivCfg.Junk
		StatusMsg('The "Junk" filter is now ', '.', cBnivCfg.Junk, true, false)
	elseif str == 'sets' then
		cBnivCfg.ItemSets = not cBnivCfg.ItemSets
		cB_filterEnabled["ItemSets"] = cBnivCfg.ItemSets
		StatusMsg('The "ItemSets" filters are now ', '.', cBnivCfg.ItemSets, true, false)
	elseif str == 'consumables' then
		cBnivCfg.Consumables = not cBnivCfg.Consumables
		cB_filterEnabled["Consumables"] = cBnivCfg.Consumables
		StatusMsg('The "Consumables" filters are now ', '.', cBnivCfg.Consumables, true, false)
	elseif str == 'quest' then
		cBnivCfg.Quest = not cBnivCfg.Quest
		cB_filterEnabled["Quest"] = cBnivCfg.Quest
		StatusMsg('The "Quest" filters are now ', '.', cBnivCfg.Quest, true, false)
	elseif str == 'bankbg' then
		cBnivCfg.BankBlack = not cBnivCfg.BankBlack
		StatusMsg('Black background color for the bank is now ', '. Reload your UI for this change to take effect!', cBnivCfg.BankBlack, true, false)
	elseif str == 'bankfilter' then
		cBnivCfg.FilterBank = not cBnivCfg.FilterBank
		StatusMsg('Bank filtering is now ', '. Reload your UI for this change to take effect!', cBnivCfg.FilterBank, true, false)
	elseif str == 'empty' then
		cBnivCfg.CompressEmpty = not cBnivCfg.CompressEmpty
		if cBnivCfg.CompressEmpty then 
			cB_Bags.bank.DropTarget:Show()
			cB_Bags.main.DropTarget:Show()
			cB_Bags.main.EmptySlotCounter:Show()
			cB_Bags.bank.EmptySlotCounter:Show()
		else
			cB_Bags.bank.DropTarget:Hide()
			cB_Bags.main.DropTarget:Hide()
			cB_Bags.main.EmptySlotCounter:Hide()
			cB_Bags.bank.EmptySlotCounter:Hide()
		end
		StatusMsg('Empty bagspace compression is now ', '.', cBnivCfg.CompressEmpty, true, false)
	elseif str == 'unlock' then
		cBnivCfg.Unlocked = not cBnivCfg.Unlocked
		SetFrameMovable(cB_Bags.main, cBnivCfg.Unlocked)
		SetFrameMovable(cB_Bags.bank, cBnivCfg.Unlocked)
		StatusMsg('Movable bags are now ', '.', cBnivCfg.Unlocked, true, false)
	elseif str == 'sortbags' then
		cBnivCfg.SortBags = not cBnivCfg.SortBags
		StatusMsg('Auto sorting bags is now ', '. Reload your UI for this change to take effect!', cBnivCfg.SortBags, true, false)
	elseif str == 'sortbank' then
		cBnivCfg.SortBank = not cBnivCfg.SortBank
		StatusMsg('Auto sorting bank is now ', '. Reload your UI for this change to take effect!', cBnivCfg.SortBank, true, false)

	elseif str == 'scale' then
		local t = tonumber(str2)
		if t then
			cBnivCfg.scale = t
			for _,v in pairs(cB_Bags) do v:SetScale(cBnivCfg.scale) end
			StatusMsgVal('Overall scale has been set to ', '.', cBnivCfg.scale, true)
		else
			StatusMsg('You have to specify a value, e.g. /cbniv scale 0.8.', '', nil, true, false)
		end

	elseif str == 'addbag' then
		if not bagExists then
			local i = numBags + 1
			cB_CustomBags[i] = { name = str2, col = 0, prio = 1, active = false }
			StatusMsg('The new custom container has been created. Reload your UI for this change to take effect!', '', nil, true, false)
		else
			StatusMsg('A custom container with this name already exists.', '', nil, true, false)
		end

	elseif str == 'delbag' then
		table.remove(cB_CustomBags, idx)
		StatusMsg('The specified custom container has been removed. Reload your UI for this change to take effect!', '', nil, true, false)
		
	elseif str == 'listbags' then
		if numBags == 0 then
			StatusMsgVal('There are ', ' custom containers.', 0, true, false)
		else
			StatusMsgVal('There are ', ' custom containers:', numBags, true, false)
			for i,v in ipairs(cB_CustomBags) do 
				StatusMsg(i..'. '..v.name..' (|cFF00FF00'..((v.col == 0) and 'right' or 'left')..'|r column, |cFF00FF00'..((v.prio == 1) and 'high' or 'low')..'|r priority)', '', nil, true, false)
			end
		end

	elseif str == 'bagpos' then
		cbNivaya:ToggleBagPosButtons()
		StatusMsg('Custom container movers are now ', '.', cBniv.BagPos, true, false)

	elseif str == 'bagprio' then
		local tprio = (cB_CustomBags[idx].prio + 1) % 2
		cB_CustomBags[idx].prio = tprio 
		StatusMsg('The priority of the specified custom container has been set to |cFF00FF00'..((tprio == 1) and 'high' or 'low')..'|r. Reload your UI for this change to take effect!', '', nil, true, false)

	elseif str == 'bankbags' then
		cBnivCfg.BankCustomBags = not cBnivCfg.BankCustomBags
		StatusMsg('Display of custom containers in the bank is now ', '. Reload your UI for this change to take effect!', cBnivCfg.BankCustomBags, true, false)

	else
		ChatFrame1:AddMessage('|cFFFFFF00cargBags_Nivaya:|r')
		StatusMsg('(', ') |cFFFFFF00unlock|r - Toggle unlocked status.', cBnivCfg.Unlocked, false, true)
		StatusMsg('(', ') |cFFFFFF00new|r - Toggle the "New Items" filter.', cBnivCfg.NewItems, false, true)
		StatusMsg('(', ') |cFFFFFF00trade|r - Toggle the "Trade Goods" filter .', cBnivCfg.TradeGoods, false, true)
		StatusMsg('(', ') |cFFFFFF00armor|r - Toggle the "Armor and Weapons" filter .', cBnivCfg.Armor, false, true)
		StatusMsg('(', ') |cFFFFFF00junk|r - Toggle the "Junk" filter.', cBnivCfg.Junk, false, true)
		StatusMsg('(', ') |cFFFFFF00sets|r - Toggle the "ItemSets" filters.', cBnivCfg.ItemSets, false, true)
		StatusMsg('(', ') |cFFFFFF00consumables|r - Toggle the "Consumables" filters.', cBnivCfg.Consumables, false, true)
		StatusMsg('(', ') |cFFFFFF00quest|r - Toggle the "Quest" filters.', cBnivCfg.Quest, false, true)
		StatusMsg('(', ') |cFFFFFF00bankbg|r - Toggle black bank background color.', cBnivCfg.BankBlack, false, true)
		StatusMsg('(', ') |cFFFFFF00bankfilter|r - Toggle bank filtering.', cBnivCfg.FilterBank, false, true)
		StatusMsg('(', ') |cFFFFFF00empty|r - Toggle empty bagspace compression.', cBnivCfg.CompressEmpty, false, true)
		StatusMsg('(', ') |cFFFFFF00sortbags|r - Toggle auto sorting the bags.', cBnivCfg.SortBags, false, true)
		StatusMsg('(', ') |cFFFFFF00sortbank|r - Toggle auto sorting the bank.', cBnivCfg.SortBank, false, true)
		StatusMsgVal('(', ') |cFFFFFF00scale|r [number] - Set the overall scale.', cBnivCfg.scale, false)
		StatusMsg('', ' |cFFFFFF00addbag|r [name] - Add a custom container.')
		StatusMsg('', ' |cFFFFFF00delbag|r [name] - Remove a custom container.')
		StatusMsg('', ' |cFFFFFF00listbags|r - List all custom containers.')
		StatusMsg('', ' |cFFFFFF00bagpos|r - Toggle buttons to move custom containers (up, down, left, right).')
		StatusMsg('', " |cFFFFFF00bagprio|r [name] - Changes the filter priority of a custom container. High priority prevents items from being classified as junk or new, low priority doesn't.")
		StatusMsg('(', ') |cFFFFFF00bankbags|r - Show custom containers in the bank too.', cBnivCfg.BankCustomBags, false, true)
	end
	cbNivaya:UpdateBags()
end

SLASH_CBNIV1 = '/cbniv'
SlashCmdList.CBNIV = HandleSlash

local buttonCollector = {}
local Event =  CreateFrame('Frame', nil)
Event:RegisterEvent("PLAYER_ENTERING_WORLD")
Event:SetScript('OnEvent', function(self, event, ...)
	if event == "PLAYER_ENTERING_WORLD" then
		for bagID = -2, 11 do
			local slots = GetContainerNumSlots(bagID)
			for slotID=1,slots do
				local button = cbNivaya.buttonClass:New(bagID, slotID)
				buttonCollector[#buttonCollector+1] = button
				cbNivaya:SetButton(bagID, slotID, nil)
			end
		end
		for i,button in pairs(buttonCollector) do
			if button.container then
				button.container:RemoveButton(button)
			end
			button:Free()
		end
		cbNivaya:UpdateBags()
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end)