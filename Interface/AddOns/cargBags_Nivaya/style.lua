local addon, ns = ...
local cargBags = ns.cargBags

local _
local L = cBnivL

local mediaPath = [[Interface\AddOns\cargBags_Nivaya\media\]]
local Textures = {
	Background =	mediaPath .. "texture",
	Search =		mediaPath .. "Search",
	BagToggle =		mediaPath .. "BagToggle",
	ResetNew =		mediaPath .. "ResetNew",
	Restack =		mediaPath .. "Restack",
	Config =		mediaPath .. "Config",
	SellJunk =		mediaPath .. "SellJunk",
	TooltipIcon =	mediaPath .. "TooltipIcon",
	Up =			mediaPath .. "Up",
	Down =			mediaPath .. "Down",
	Left =			mediaPath .. "Left",
	Right =			mediaPath .. "Right",
}

local itemSlotSize = ns.options.itemSlotSize
------------------------------------------
-- MyContainer specific
------------------------------------------
local cbNivaya = cargBags:GetImplementation("Nivaya")
local MyContainer = cbNivaya:GetContainerClass()

local function GetClassColor(class)
	if not RAID_CLASS_COLORS[class] then return {1, 1, 1} end
	local classColors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[class] or RAID_CLASS_COLORS[class]
	return {classColors.r, classColors.g, classColors.b}
end

local GetNumFreeSlots = function(bagType)
	local free, max = 0, 0
	if bagType == "bag" then
		for i = 0,4 do
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	else
		local containerIDs = {-1,5,6,7,8,9,10,11}
		for _,i in next, containerIDs do	
			free = free + GetContainerNumFreeSlots(i)
			max = max + GetContainerNumSlots(i)
		end
	end
	return free, max
end

local QuickSort;
do
	local func = function(v1, v2)
		if (v1 == nil) or (v2 == nil) then return (v1 and true or false) end
		if v1[1] == -1 or v2[1] == -1 then
			return v1[1] > v2[1] -- empty slots last
		elseif v1[2] ~= v2[2] then
			if v1[2] and v2[2] then
				return v1[2] > v2[2] -- higher quality first
			elseif (v1[2] == nil) or (v2[2] == nil) then
				return (v1[2] and true or false)
			else
				return false
			end
		elseif v1[1] ~= v2[1] then
			return v1[1] > v2[1] -- group identical item ids
		else
			return v1[4] > v2[4] -- full/larger stacks first
		end
	end;
	QuickSort = function(tbl) table.sort(tbl, func) end
end

function MyContainer:OnContentsChanged()

	local col, row = 0, 0
	local yPosOffs = self.Caption and 20 or 0
	local isEmpty = true

	local tName = self.name
	local tBankBags = string.find(tName, "cBniv_Bank%a+")
	local tBank = tBankBags or (tName == "cBniv_Bank")

	local buttonIDs = {}
  	for i, button in pairs(self.buttons) do
		local item = cbNivaya:GetItemInfo(button.bagID, button.slotID)
		if item.link then
			local _,_,tQ = GetItemInfo(item.link)
			local _,cnt = GetContainerItemInfo(button.bagID, button.slotID)
			buttonIDs[i] = { item.id, tQ, button, cnt }
		else
			buttonIDs[i] = { -1, -2, button, -1 }
		end
	end
	if (tBank and cBnivCfg.SortBank) or (not tBank and cBnivCfg.SortBags) then QuickSort(buttonIDs) end

	for _,v in ipairs(buttonIDs) do
		local button = v[3]
		button:ClearAllPoints()
	  
		local xPos = col * (itemSlotSize + 2) + 2
		local yPos = (-1 * row * (itemSlotSize + 2)) - yPosOffs

		button:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
		if(col >= self.Columns-1) then
			col = 0
			row = row + 1
		else
			col = col + 1
		end
		isEmpty = false
	end

	if cBnivCfg.CompressEmpty then
		local xPos = col * (itemSlotSize + 2) + 2
		local yPos = (-1 * row * (itemSlotSize + 2)) - yPosOffs

		local tDrop = self.DropTarget
		if tDrop then
			tDrop:ClearAllPoints()
			tDrop:SetPoint("TOPLEFT", self, "TOPLEFT", xPos, yPos)
			if(col >= self.Columns-1) then
				col = 0
				row = row + 1
			else
				col = col + 1
			end
		end
		
		cB_Bags.main.EmptySlotCounter:SetText(GetNumFreeSlots("bag"))
		cB_Bags.bank.EmptySlotCounter:SetText(GetNumFreeSlots("bank"))
	end
	
	-- This variable stores the size of the item button container
	self.ContainerHeight = (row + (col > 0 and 1 or 0)) * (itemSlotSize + 2)

	if (self.UpdateDimensions) then self:UpdateDimensions() end -- Update the bag's height
	local t = (tName == "cBniv_Bag") or (tName == "cBniv_Bank") 
	local tAS = (tName == "cBniv_Ammo") or (tName == "cBniv_Soulshards")
	if (not tBankBags and cB_Bags.main:IsShown() and not (t or tAS)) or (tBankBags and cB_Bags.bank:IsShown()) then 
		if isEmpty then self:Hide() else self:Show() end 
	end

	cB_BagHidden[tName] = (not t) and isEmpty or false
	cbNivaya:UpdateAnchors(self)
end

--[[function MyContainer:OnButtonAdd(button)
	if not button.Border then return end
 
	local _,bagType = GetContainerNumFreeSlots(button.bagID)
	if button.bagID == KEYRING_CONTAINER then
		button.Border:SetBackdropBorderColor(0, 0, 0)	  -- Key ring
	elseif bagType and bagType > 0 and bagType < 8 then
		button.Border:SetBackdropBorderColor(1, 1, 0)		-- Ammo bag
	elseif bagType and bagType > 4 then
		button.Border:SetBackdropBorderColor(1, 1, 1)		-- Profession bags
	else
		button.Border:SetBackdropBorderColor(0, 0, 0)		-- Normal bags
	end
end]]--

-- Sell Junk
local JS = CreateFrame("Frame")
JS:RegisterEvent("MERCHANT_SHOW")
local function SellJunk()
	if not(cBnivCfg.SellJunk) or (UnitLevel("player") < 5) then return end
	
	local Profit, SoldCount, Rarity, ItemPrice, ItemCount = 0, 0, 0, 0, 0
	local CurrentItemLink

	for BagID = 0, 4 do
		for BagSlot = 1, GetContainerNumSlots(BagID) do
			CurrentItemLink = GetContainerItemLink(BagID, BagSlot)
			if CurrentItemLink then
				_, _, Rarity, _, _, _, _, _, _, _, ItemPrice = GetItemInfo(CurrentItemLink)
				_, ItemCount = GetContainerItemInfo(BagID, BagSlot)
				if Rarity == 0 and ItemPrice ~= 0 then
					Profit = Profit + (ItemPrice * ItemCount)
					SoldCount = SoldCount + 1
					UseContainerItem(BagID, BagSlot)
				end
			end
		end
	end
	
	if Profit > 0 then
		local g, s, c = math.floor(Profit / 10000) or 0, math.floor((Profit%10000) / 100) or 0, Profit%100
		print("Vendor trash sold: |cff00a956+|r |cffffffff"..g.."\124TInterface\\MoneyFrame\\UI-GoldIcon:0:0:2:0\124t "..s.."\124TInterface\\MoneyFrame\\UI-SilverIcon:0:0:2:0\124t "..c.."\124TInterface\\MoneyFrame\\UI-CopperIcon:0:0:2:0\124t".."|r")
	end
end
JS:SetScript("OnEvent", function() SellJunk() end)

-- Restack Items
local ContainerID = { bags = { 0 }, bank = { -1 }, guild = { 42 } }
for i = 1, NUM_BAG_SLOTS do table.insert(ContainerID.bags, i) end
for i = NUM_BAG_SLOTS + 1, NUM_BAG_SLOTS + NUM_BANKBAGSLOTS do table.insert(ContainerID.bank, i) end

-- yielding function; items will get locked and we have to wait
local f = CreateFrame("Frame")
local function coYield(loc, bag, slot, count)
	local elapsed = 0
	f:SetScript("OnUpdate", function(_, update)
		elapsed = elapsed + update
		if type(restacker) == "thread" and coroutine.status(restacker) == "suspended" and elapsed > 0.1 then
			local locked = true
			locked = select(3, GetContainerItemInfo(bag, slot))
			if not locked then coroutine.resume(restacker) end
			elapsed = 0
		end
	end)
	coroutine.yield()
end

local restackItems = function(self)
	local tBag, tBank = (self.name == "cBniv_Bag"), (self.name == "cBniv_Bank")
	local loc = tBank and "bank" or "bags"
	
	if type(restacker) ~= "thread" or coroutine.status(restacker) == "dead" then
		restacker = coroutine.create(function()
			tabswap = 0
			local changed = true
			while changed do
				changed = false
				for _, bag in ipairs(ContainerID[loc]) do
					if changed then break end
					for slot = 1, (GetContainerNumSlots(bag)) do
						while true do
							local locked = select(3, GetContainerItemInfo(bag, slot))
							if locked then coYield(loc, bag, slot) else break end
						end
						local item = GetContainerItemLink(bag, slot)
						if item then
							local itemid = tonumber(item:match("item:(%d+)"))
							local stack = select(8, GetItemInfo(itemid))
							local count = select(2, GetContainerItemInfo(bag, slot))

							-- do "special" things with "special" items by moving them into "special" bags
							if select(9, GetItemInfo(itemid)) ~= "INVTYPE_BAG" then
								local bagType = (bag ~= 0 and bag ~= -1) and GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag))) or 0								
								for _, sbag in ipairs(ContainerID[loc]) do
									if sbag > 0 and GetContainerNumFreeSlots(sbag) > 0 then
										local sbagID = ContainerIDToInventoryID(sbag)
										local sbagType = GetItemFamily(GetInventoryItemLink("player", sbagID))
										local itemType = GetItemFamily(item)

										if sbagType > 0 and sbagType == itemType and bagType == 0 then
											PickupContainerItem(bag, slot)
											PutItemInBag(sbagID)
											coYield(loc, bag, slot)
											break
										end
									end
								end	
							end
							if count < stack then
								-- found a partial stack
								local locked, found, done, pbag, pslot
								while true do
									-- search through bags backwards for another partial stack with a matching itemid
									for i = #ContainerID[loc], 1, -1 do
										local _bag = ContainerID[loc][i]
										if found or done then break end
										local _slots = GetContainerNumSlots(_bag)
										for _slot = _slots, 1, -1 do
											if not (_bag == bag and _slot == slot) then
												local _item = GetContainerItemLink(_bag, _slot)
												if _item then
													local _itemid = tonumber(_item:match("item:(%d+):"))
													if _itemid == itemid then
														local _stack = select(8, GetItemInfo(_itemid))
														local _count = select(2, GetContainerItemInfo(_bag, _slot))
														if _count < _stack then found, pbag, pslot = true, _bag, _slot; break end
													end
												end
											else done = true; break end
										end
									end
									locked = found and select(3, GetContainerItemInfo(pbag, pslot)) or false
									if locked then coYield(loc, pbag, pslot) else break end
								end

								if found then
									ClearCursor()

									-- if second partial stack is inside a special bag, move the original stack into it
									local bagType = (bag ~= 0 and bag ~= -1) and GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(bag))) or 0
									local pbagType = (pbag ~= 0 and pbag ~= -1) and GetItemFamily(GetInventoryItemLink("player", ContainerIDToInventoryID(pbag))) or 0
									if pbagType > 0 and bagType == 0 then
										PickupContainerItem(bag, slot)
										PickupContainerItem(pbag, pslot)
									else
										PickupContainerItem(pbag, pslot)
										PickupContainerItem(bag, slot)
									end
									
									ClearCursor()
									
									changed = true
									break
								end
							end
						end
					end
				end
			end
			-- turn off yielding function
			f:SetScript("OnUpdate", nil)
		end)
		coroutine.resume(restacker)
	end	
end

-- Reset New
local resetNewItems = function(self)
	cB_KnownItems = {}
	for i = 0,4 do
		local tNumSlots = GetContainerNumSlots(i)
		if tNumSlots > 0 then
			for j = 1,tNumSlots do
				local tLink = GetContainerItemLink(i,j)
				if tLink then
					if (strsub(tLink, 13, 21) == "battlepet") then
						local _, tName = strmatch(tLink, "|H(.-)|h(.-)|h")
						local _,tStackCount = GetContainerItemInfo(i,j)
						if cB_KnownItems[tName] then
							cB_KnownItems[tName] = cB_KnownItems[tName] + tStackCount
						else
							cB_KnownItems[tName] = tStackCount
						end
					else	
						local tName = GetItemInfo(tLink)
						local _,tStackCount = GetContainerItemInfo(i,j)
						if cB_KnownItems[tName] then
							cB_KnownItems[tName] = cB_KnownItems[tName] + tStackCount
						else
							cB_KnownItems[tName] = tStackCount
						end
					end
				end
			end 
		end
	end
	cbNivaya:UpdateBags()
end
function cbNivResetNew()
	resetNewItems()
end

local UpdateDimensions = function(self)
	local height = 0			-- Normal margin space
	if self.BagBar and self.BagBar:IsShown() then
		height = height + 40	-- Bag button space
	end
	if self.Space then
		height = height + 16	-- additional info display space
	end
	if self.bagToggle then
		local tBag = (self.name == "cBniv_Bag")
		local extraHeight = (tBag and self.hintShown) and (RealUI.font.pixel1[2] + 4) or 0
		height = height + 24 + extraHeight
	end
	if self.Caption then		-- Space for captions
		height = height + RealUI.font.pixel1[2] + 12
	end
	self:SetHeight(self.ContainerHeight + height)
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

local classColor
local function IconButton_OnEnter(self)
	self.mouseover = true
	
	if not classColor then
		classColor = GetClassColor(select(2, UnitClass("player")))
	end
	self.icon:SetVertexColor(classColor[1], classColor[2], classColor[3])
	
	if self.tooltip then
		self.tooltip:Show()
		self.tooltipIcon:Show()
	end
end

local function IconButton_OnLeave(self)
	self.mouseover = false
	if self.tag == "SellJunk" then
		if cBnivCfg.SellJunk then
			self.icon:SetVertexColor(0.8, 0.8, 0.8)
		else
			self.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	else
		self.icon:SetVertexColor(0.8, 0.8, 0.8)
	end
	if self.tooltip then
		self.tooltip:Hide()
		self.tooltipIcon:Hide()
	end
end

local createMoverButton = function (parent, texture, tag)
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(17)
	button:SetHeight(17)
	
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetPoint("TOPRIGHT", button, "TOPRIGHT", -1, -1)
	button.icon:SetWidth(16)
	button.icon:SetHeight(16)
	button.icon:SetTexture(texture)
	button.icon:SetVertexColor(0.8, 0.8, 0.8)
	
	button.tag = tag
	button:SetScript("OnEnter", function() IconButton_OnEnter(button) end)
	button:SetScript("OnLeave", function() IconButton_OnLeave(button) end)
	button.mouseover = false
	
	return button
end

local createIconButton = function (name, parent, texture, point, hint, isBag)
	local font = RealUI.font.pixel1
	local button = CreateFrame("Button", nil, parent)
	button:SetWidth(17)
	button:SetHeight(17)
	
	button.icon = button:CreateTexture(nil, "ARTWORK")
	button.icon:SetPoint(point, button, point, point == "BOTTOMLEFT" and 2 or -2, 2)
	button.icon:SetWidth(16)
	button.icon:SetHeight(16)
	button.icon:SetTexture(texture)
	if name == "SellJunk" then
		if cBnivCfg.SellJunk then
			button.icon:SetVertexColor(0.8, 0.8, 0.8)
		else
			button.icon:SetVertexColor(0.4, 0.4, 0.4)
		end
	else
		button.icon:SetVertexColor(0.8, 0.8, 0.8)
	end
	
	button.tooltip = button:CreateFontString()
	-- button.tooltip:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", isBag and -76 or -59, 4.5)
	button.tooltip:SetFont(unpack(font))
	button.tooltip:SetJustifyH("RIGHT")
	button.tooltip:SetText(hint)
	button.tooltip:SetTextColor(0.8, 0.8, 0.8)
	button.tooltip:Hide()
	
	button.tooltipIcon = button:CreateTexture(nil, "ARTWORK")
	-- button.tooltipIcon:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", isBag and -71 or -54, 1)
	button.tooltipIcon:SetWidth(16)
	button.tooltipIcon:SetHeight(16)
	button.tooltipIcon:SetTexture(Textures.TooltipIcon)
	button.tooltipIcon:SetVertexColor(0.9, 0.2, 0.2)
	button.tooltipIcon:Hide()
	
	button.tag = name
	button:SetScript("OnEnter", function() IconButton_OnEnter(button) end)
	button:SetScript("OnLeave", function() IconButton_OnLeave(button) end)
	button.mouseover = false
	
	return button
end


local GetFirstFreeSlot = function(bagtype)
	if bagtype == "bag" then
		for i = 0,4 do
			local t = GetContainerNumFreeSlots(i)
			if t > 0 then
				local tNumSlots = GetContainerNumSlots(i)
				for j = 1,tNumSlots do
					local tLink = GetContainerItemLink(i,j)
					if not tLink then return i,j end
				end
			end
		end
	else
		local containerIDs = {-1,5,6,7,8,9,10,11}
		for _,i in next, containerIDs do
			local t = GetContainerNumFreeSlots(i)
			if t > 0 then
				local tNumSlots = GetContainerNumSlots(i)
				for j = 1,tNumSlots do
					local tLink = GetContainerItemLink(i,j)
					if not tLink then return i,j end
				end
			end
		end	
	end
	return false
end

function MyContainer:OnCreate(name, settings)
	local font = RealUI.font.pixel1
	
	settings = settings or {}
	self.Settings = settings
	self.name = name

	local tBag, tBank = (name == "cBniv_Bag"), (name == "cBniv_Bank")
	local tBankBags = string.find(name, "Bank")
	
	local numSlotsBag = {GetNumFreeSlots("bag")}
	local numSlotsBank = {GetNumFreeSlots("bank")}
	
	local usedSlotsBag = numSlotsBag[2] - numSlotsBag[1]
	local usedSlotsBank = numSlotsBank[2] - numSlotsBank[1]

	self:EnableMouse(true)
	
	self.UpdateDimensions = UpdateDimensions
	
	self:SetFrameStrata("HIGH")
	tinsert(UISpecialFrames, self:GetName()) -- Close on "Esc"

	if tBag or tBank then 
		SetFrameMovable(self, cBnivCfg.Unlocked) 
	end

	if tBank or tBankBags then
		self.Columns = (usedSlotsBank > ns.options.sizes.bank.largeItemCount) and ns.options.sizes.bank.columnsLarge or ns.options.sizes.bank.columnsSmall
	else
		self.Columns = (usedSlotsBag > ns.options.sizes.bags.largeItemCount) and ns.options.sizes.bags.columnsLarge or ns.options.sizes.bags.columnsSmall
	end
	self.ContainerHeight = 0
	self:UpdateDimensions()
	self:SetWidth((itemSlotSize + 2) * self.Columns + 2)

	-- The frame background
	local tBankCustom = (tBankBags and not cBnivCfg.BankBlack)
	local color_rb = RealUI.media.window[1]
	local color_gb = tBankCustom and .2 or RealUI.media.window[2]
	local color_bb = tBankCustom and .3 or RealUI.media.window[3]
	local alpha_fb = RealUI.media.window[4]

	-- The frame background
	local background = CreateFrame("Frame", nil, self)
	background:SetBackdrop{
		bgFile = RealUI.media.textures.plain,
		edgeFile = RealUI.media.textures.plain,
		tile = true, tileSize = 16, edgeSize = 1,
		insets = {left = 1, right = 1, top = 1, bottom = 1},
	}
	background:SetFrameStrata("HIGH")
	background:SetFrameLevel(1)
	background:SetBackdropColor(color_rb,color_gb,color_bb,alpha_fb)
	background:SetBackdropBorderColor(0, 0, 0, 1)

	background:SetPoint("TOPLEFT", -4, 4)
	background:SetPoint("BOTTOMRIGHT", 4, -4)

	-- Stripes
	background.tex = RealUI:AddStripeTex(background)

	-- Caption, close button
	local caption = background:CreateFontString(background, "OVERLAY", nil)
	caption:SetFont(unpack(font))
	if(caption) then
		local t = L.bagCaptions[self.name] or (tBankBags and strsub(self.name, 5))
		if not t then t = self.name end
		if self.Name == "cBniv_ItemSets" then t=ItemSetCaption..t end
		caption:SetText(t)
		caption:SetPoint("TOPLEFT", 7.5, -7.5)
		self.Caption = caption
		
		if tBag or tBank then
			local close = CreateFrame("Button", nil, self, "UIPanelCloseButton")
			if Aurora then
				local F = Aurora[1]
				F.ReskinClose(close, "TOPRIGHT", self, "TOPRIGHT", 1, 1)
			else
				close:SetPoint("TOPRIGHT", 8, 8)
			end
			close:SetScript("OnClick", function(self) if cbNivaya:AtBank() then CloseBankFrame() else CloseAllBags() end end)
		end
	end
	
	-- mover buttons
	if (settings.isCustomBag) then
		local moveLR = function(dir)
			local idx = -1
			for i,v in ipairs(cB_CustomBags) do if v.name == name then idx = i end end
			if (idx == -1) then return end

			local tcol = (cB_CustomBags[idx].col + ((dir == "left") and 1 or -1)) % 2
			cB_CustomBags[idx].col = tcol
			cbNivaya:CreateAnchors()
		end

		local moveUD = function(dir)
			local idx = -1
			for i,v in ipairs(cB_CustomBags) do if v.name == name then idx = i end end
			if (idx == -1) then return end

			local pos = idx
			local d = (dir == "up") and 1 or -1
			repeat 
				pos = pos + d
			until 
				(not cB_CustomBags[pos]) or (cB_CustomBags[pos].col == cB_CustomBags[idx].col)

			if (cB_CustomBags[pos] ~= nil) then
				local ele = cB_CustomBags[idx]
				cB_CustomBags[idx] = cB_CustomBags[pos]
				cB_CustomBags[pos] = ele
				cbNivaya:CreateAnchors()
			end
		end		
		
		local rightBtn = createMoverButton(self, Textures.Right, "Right")
		rightBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		rightBtn:SetScript("OnClick", function() moveLR("right") end)

		local leftBtn = createMoverButton(self, Textures.Left, "Left")
		leftBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -17, 0)
		leftBtn:SetScript("OnClick", function() moveLR("left") end)

		local downBtn = createMoverButton(self, Textures.Down, "Down")
		downBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -34, 0)
		downBtn:SetScript("OnClick", function() moveUD("down") end)

		local upBtn = createMoverButton(self, Textures.Up, "Up")
		upBtn:SetPoint("TOPRIGHT", self, "TOPRIGHT", -51, 0)
		upBtn:SetScript("OnClick", function() moveUD("up") end)

		self.rightBtn = rightBtn
		self.leftBtn = leftBtn
		self.downBtn = downBtn
		self.upBtn = upBtn
	end
		
	local tBtnOffs = 0
  	if tBag or tBank then
		 -- Bag bar for changing bags
		local bagType = tBag and "bags" or "bank"
		
		local tS = tBag and "backpack+bags" or "bank"
		local tI = tBag and 4 or 7
				
		local bagButtons = self:SpawnPlugin("BagBar", tS)
		bagButtons:SetSize(bagButtons:LayoutButtons("grid", tI))
		bagButtons.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
		bagButtons.isGlobal = true
		
		bagButtons:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", -2, 25)
		bagButtons:Hide()

		-- main window gets a fake bag button for toggling key ring
		self.BagBar = bagButtons
		
		-- We don't need the bag bar every time, so let's create a toggle button for them to show
		self.bagToggle = createIconButton("Bags", self, Textures.BagToggle, "BOTTOMRIGHT", "Toggle Bags", tBag)
		self.bagToggle:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
		self.bagToggle:SetScript("OnClick", function()
			if(self.BagBar:IsShown()) then 
				self.BagBar:Hide()
			--	if self.hint then self.hint:Show() end
			--	self.hintShown = true
			else
				self.BagBar:Show()
			--	if self.hint then self.hint:Hide() end
			--	self.hintShown = false
			end
			self:UpdateDimensions()
		end)

		-- Button to reset new items:
		if tBag and cBnivCfg.NewItems then
			self.resetBtn = createIconButton("ResetNew", self, Textures.ResetNew, "BOTTOMRIGHT", "Reset New", tBag)
			self.resetBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
			self.resetBtn:SetScript("OnClick", function() resetNewItems(self) end)
		end
		
		-- Button to restack items:
		if cBnivCfg.Restack then
			self.restackBtn = createIconButton("Restack", self, Textures.Restack, "BOTTOMRIGHT", "Restack", tBag)
			if self.resetBtn then
				self.restackBtn:SetPoint("BOTTOMRIGHT", self.resetBtn, "BOTTOMLEFT", 0, 0)
			else
				self.restackBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
			end
			self.restackBtn:SetScript("OnClick", function() restackItems(self) end)
		end
		
		-- Button to show /cbniv options:
		self.optionsBtn = createIconButton("Options", self, Textures.Config, "BOTTOMRIGHT", "Options", tBag)
		if self.restackBtn then
			self.optionsBtn:SetPoint("BOTTOMRIGHT", self.restackBtn, "BOTTOMLEFT", 0, 0)
		elseif self.resetBtn then
			self.optionsBtn:SetPoint("BOTTOMRIGHT", self.resetBtn, "BOTTOMLEFT", 0, 0)
		else
			self.optionsBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
		end
		self.optionsBtn:SetScript("OnClick", function() 
			SlashCmdList.CBNIV("")
			print("Usage: /cbniv |cffffff00command|r")
		end)
		
		-- Button to toggle Sell Junk:
		if tBag then
			local sjHint = cBnivCfg.SellJunk and "Sell Junk |cffd0d0d0(on)|r" or "Sell Junk |cffd0d0d0(off)|r"
			self.junkBtn = createIconButton("SellJunk", self, Textures.SellJunk, "BOTTOMRIGHT", sjHint, tBag)
			if self.optionsBtn then
				self.junkBtn:SetPoint("BOTTOMRIGHT", self.optionsBtn, "BOTTOMLEFT", 0, 0)
			elseif self.restackBtn then
				self.junkBtn:SetPoint("BOTTOMRIGHT", self.restackBtn, "BOTTOMLEFT", 0, 0)
			elseif self.resetBtn then
				self.junkBtn:SetPoint("BOTTOMRIGHT", self.resetBtn, "BOTTOMLEFT", 0, 0)
			else
				self.junkBtn:SetPoint("BOTTOMRIGHT", self.bagToggle, "BOTTOMLEFT", 0, 0)
			end
			self.junkBtn:SetScript("OnClick", function() 
				cBnivCfg.SellJunk = not(cBnivCfg.SellJunk)
				if cBnivCfg.SellJunk then
					self.junkBtn.tooltip:SetText("Sell Junk |cffd0d0d0(on)|r")
				else
					self.junkBtn.tooltip:SetText("Sell Junk |cffd0d0d0(off)|r")
				end
			end)
		end
		
		-- Tooltip positions
		local numButtons = 1
		local btnTable = {self.bagToggle}
		if self.optionsBtn then numButtons = numButtons + 1; tinsert(btnTable, self.optionsBtn) end
		if self.restackBtn then numButtons = numButtons + 1; tinsert(btnTable, self.restackBtn) end
		if tBag then
			if self.resetBtn then numButtons = numButtons + 1; tinsert(btnTable, self.resetBtn) end
			if self.junkBtn then numButtons = numButtons + 1; tinsert(btnTable, self.junkBtn) end
		end
		local ttPos = -(numButtons * 15 + 18)
		if tBank then ttPos = ttPos + 3 end
		for k,v in pairs(btnTable) do
			v.tooltip:ClearAllPoints()
			v.tooltip:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ttPos, 5.5)
			v.tooltipIcon:ClearAllPoints()
			v.tooltipIcon:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", ttPos + 5, 1.5)
		end
	end

	-- Item drop target
	if (tBag or tBank) then
		self.DropTarget = CreateFrame("Button", self.name.."DropTarget", self, "ItemButtonTemplate")
		local dtNT = _G[self.DropTarget:GetName().."NormalTexture"]
		if dtNT then dtNT:SetTexture(nil) end
		
		self.DropTarget.bg = CreateFrame("Frame", nil, self)
		self.DropTarget.bg:SetAllPoints(self.DropTarget)
		self.DropTarget.bg:SetBackdrop({
			bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
			edgeFile = "Interface\\Buttons\\WHITE8x8",
			tile = false, tileSize = 16, edgeSize = 1,
		})
		self.DropTarget.bg:SetBackdropColor(1, 1, 1, 0.1)
		self.DropTarget.bg:SetBackdropBorderColor(0, 0, 0, 1)
		self.DropTarget:SetWidth(itemSlotSize - 1)
		self.DropTarget:SetHeight(itemSlotSize - 1)
		
		local DropTargetProcessItem = function()
			-- if CursorHasItem() then	-- Commented out to fix Guild Bank -> Bags item dragging
				local bID, sID = GetFirstFreeSlot(tBag and "bag" or "bank")
				if bID then PickupContainerItem(bID, sID) end
			-- end
		end
		self.DropTarget:SetScript("OnMouseUp", DropTargetProcessItem)
		self.DropTarget:SetScript("OnReceiveDrag", DropTargetProcessItem)
		
		local fs = self:CreateFontString(nil, "OVERLAY")
		fs:SetFont(unpack(font))
		fs:SetJustifyH("LEFT")
		fs:SetPoint("BOTTOMRIGHT", self.DropTarget, "BOTTOMRIGHT", 1.5, 1.5)
		self.EmptySlotCounter = fs
		
		if cBnivCfg.CompressEmpty then 
			self.DropTarget:Show()
			self.EmptySlotCounter:Show()
		else
			self.DropTarget:Hide()
			self.EmptySlotCounter:Hide()
		end
	end
	
	if tBag then
		local infoFrame = CreateFrame("Button", nil, self)
		infoFrame:SetPoint("BOTTOMLEFT", 5, -6)
		infoFrame:SetPoint("BOTTOMRIGHT", -86, -6)
		infoFrame:SetHeight(32)

		-- Search bar
		local search = self:SpawnPlugin("SearchBar", infoFrame)
		search.isGlobal = true
		search.highlightFunction = function(button, match) button:SetAlpha(match and 1 or 0.1) end
		
		local searchIcon = background:CreateTexture(nil, "ARTWORK")
		searchIcon:SetTexture(Textures.Search)
		searchIcon:SetVertexColor(0.8, 0.8, 0.8)
		searchIcon:SetPoint("BOTTOMLEFT", infoFrame, "BOTTOMLEFT", -3, 8)
		searchIcon:SetWidth(16)
		searchIcon:SetHeight(16)
		
		-- Hint
		self.hint = background:CreateFontString(nil, "OVERLAY", nil)
		self.hint:SetPoint("BOTTOMLEFT", infoFrame, -0.5, 31.5)
		self.hint:SetFont(unpack(font))
		self.hint:SetTextColor(1, 1, 1, 0.4)
		self.hint:SetText("Ctrl + Alt + Right Click an item to assign category")
		self.hintShown = true
		
		-- The money display
		local money = self:SpawnPlugin("TagDisplay", "[money]", self)
		money:SetPoint("TOPRIGHT", self, -25.5, -2.5)
		money:SetFont(unpack(font))
		money:SetJustifyH("RIGHT")
		money:SetShadowColor(0, 0, 0, 0)
	end
	
	self:SetScale(cBnivCfg.scale)
	return self
end

------------------------------------------
-- MyButton specific
------------------------------------------
local MyButton = cbNivaya:GetItemButtonClass()
MyButton:Scaffold("Default")

function MyButton:OnAdd()
	self:SetScript('OnMouseUp', function(self, mouseButton)
		if (mouseButton == 'RightButton') and (IsAltKeyDown()) and (IsControlKeyDown()) then
			local tID = GetContainerItemID(self.bagID, self.slotID)
			if tID then 
				cbNivCatDropDown.itemName = GetItemInfo(tID)
				cbNivCatDropDown.itemID = tID
				--ToggleDropDownMenu(1, nil, cbNivCatDropDown, self, 0, 0)
				cbNivCatDropDown:Toggle(self, nil, nil, 0, 0)
			end
		end
	end)
end

------------------------------------------
-- BagButton specific
------------------------------------------
local BagButton = cbNivaya:GetClass("BagButton", true, "BagButton")

function BagButton:OnCreate() self:GetCheckedTexture():SetVertexColor(1, 0.8, 0, 0.8) end