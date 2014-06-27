local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "PaperDoll"
local PaperDoll = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceHook-3.0")

local BordersSet = false
local DURABILITY_ITEMS, NON_DURABILITY_ITEMS, ILVL_ITEMS

-- Upgrade Level retrieval
local S_UPGRADE_LEVEL = "^" .. gsub(ITEM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)")	-- Search pattern
local scantip = CreateFrame("GameTooltip", "RealUIItemUpgradeScanTooltip", nil, "GameTooltipTemplate")
scantip:SetOwner(UIParent, "ANCHOR_NONE")

local function GetItemUpgradeLevel(itemLink)
	scantip:SetHyperlink(itemLink)
	for i = 2, scantip:NumLines() do -- Line 1 = name so skip
		local text = _G["RealUIItemUpgradeScanTooltipTextLeft"..i]:GetText()
		if text and text ~= "" then
			local currentUpgradeLevel, maxUpgradeLevel = strmatch(text, S_UPGRADE_LEVEL)
			if currentUpgradeLevel then
				return currentUpgradeLevel, maxUpgradeLevel
			end
		end
	end
end

-- String creation
function PaperDoll:CreateUpgradeString(slottype, slot)
	local gslot = _G[slottype..slot.."Slot"]
	if gslot then
		local str = gslot:CreateFontString(slot .. "UpgradeString", "OVERLAY")
		str:SetFont(unpack(nibRealUI.font.pixel1))
		str:SetTextColor(0, 1, 1)
		str:SetPoint("BOTTOMRIGHT", gslot, "BOTTOMRIGHT", 2, 12.5)
	end
end

function PaperDoll:CreateILVLString(slottype, slot)
	local gslot = _G[slottype..slot.."Slot"]
	if gslot then
		local str = gslot:CreateFontString(slot .. "ItemLevelString", "OVERLAY")
		str:SetFont(unpack(nibRealUI.font.pixel1))
		str:SetPoint("BOTTOMRIGHT", gslot, "BOTTOMRIGHT", 2, 1.5)
	end
end

-- Border creation
--local rightItems = {Waist = true, Legs = true, Feet = true, Hands = true, MainHand = true}
function PaperDoll:CreateBorder(slottype, slot, hasDurability)
	local gslot = _G[slottype..slot.."Slot"]
	local height = 37
	local width = 37
	
	if gslot then
		local border = CreateFrame("Frame", slot .. "QualityBorder", gslot)
		border:SetParent(gslot)
		border:SetHeight(height)
		border:SetWidth(width)
		border:SetPoint("CENTER", gslot, "CENTER", 0, 0)
		border:SetAlpha(0.8)
		border:SetBackdrop({
			bgFile = nibRealUI.media.textures.plain, 
			edgeFile = nibRealUI.media.textures.plain, 
			tile = false, tileSize = 0, edgeSize = 1, 
			insets = { left = 0, right = 0, top = 0, bottom = 0}
		})
		border:SetBackdropColor(0,0,0,0)
		border:SetBackdropBorderColor(0,0,0,0)
		border:Hide()

		if hasDurability and Aurora then
			local durStatus = CreateFrame("StatusBar", slot.."DurabilityStatus", gslot)
			
			if slot == "SecondaryHand" then
				durStatus:SetPoint("TOPLEFT", gslot, "TOPRIGHT", 2, 0)
				durStatus:SetPoint("BOTTOMRIGHT", gslot, "BOTTOMRIGHT", 3, 0)
			else
				durStatus:SetPoint("TOPRIGHT", gslot, "TOPLEFT", -2, 0)
				durStatus:SetPoint("BOTTOMLEFT", gslot, "BOTTOMLEFT", -3, 0)
			end
			
			durStatus:SetStatusBarTexture(nibRealUI.media.textures.plain)
			durStatus:SetOrientation("VERTICAL")
			durStatus:SetMinMaxValues(0, 1)
			durStatus:SetValue(0)
			
			nibRealUI:CreateBDFrame(durStatus)
			durStatus:SetFrameLevel(gslot:GetFrameLevel() + 4)
		end
	end
end

-- Tables
function PaperDoll:MakeTypeTable()
	ILVL_ITEMS = {"Neck", "Back", "Finger0", "Finger1", "Trinket0", "Trinket1", "Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand"}
	DURABILITY_ITEMS = {"Head", "Shoulder", "Chest", "Waist", "Legs", "Feet", "Wrist", "Hands", "MainHand", "SecondaryHand"}
	NON_DURABILITY_ITEMS = {"Neck", "Back", "Finger0", "Finger1", "Trinket0", "Trinket1", "Tabard", "Shirt"}
	for _, item in ipairs(DURABILITY_ITEMS) do
		self:CreateBorder("Character", item, true)
	end
	for _, nditem in ipairs(NON_DURABILITY_ITEMS) do
		self:CreateBorder("Character", nditem, false)
	end
	for _, item in ipairs(ILVL_ITEMS) do
		self:CreateILVLString("Character", item)
		self:CreateUpgradeString("Character", item)
	end
end

-- Update Item display
function PaperDoll:UpdateItems()
	if not CharacterFrame:IsVisible() then return end
	
	-- Item Durability
	for _, item in ipairs(DURABILITY_ITEMS) do
		local id, _ = GetInventorySlotInfo(item .. "Slot")

		local statusBar = _G[item.."DurabilityStatus"]
		local v1, v2 = GetInventoryItemDurability(id)
		v1, v2 = tonumber(v1) or 0, tonumber(v2) or 0
		local percent
		if v1 == 0 or v2 == 0 then
			percent = 0
		else
			percent = v1 / v2
		end
		
		if Aurora then
			if (v2 ~= 0) then
				statusBar:SetValue(percent)
				statusBar:SetStatusBarColor(nibRealUI:GetDurabilityColor(v1/v2))
				statusBar:Show()
			else
				statusBar:Hide()
			end
		end
		
		-- Quality Border
		--self:ColorBorders(id, item)
	end
	--self:ColorBordersND()

	-- Item Upgrades/Levels
	for _, item in ipairs(ILVL_ITEMS) do
		local id = GetInventorySlotInfo(item .. "Slot")
		local itemLink = GetInventoryItemLink("player", id)

		local upgradeStr = _G[item.."UpgradeString"]
		local ilvlStr = _G[item.."ItemLevelString"]

		if itemLink then
			local _,_,itemRarity, itemLevel = GetItemInfo(itemLink)
			local currentUpgradeLevel, maxUpgradeLevel = GetItemUpgradeLevel(itemLink)

			-- Item Upgrades
			if maxUpgradeLevel and currentUpgradeLevel and (tonumber(currentUpgradeLevel) > 0) then
				upgradeStr:SetText("+"..currentUpgradeLevel)
			else
				upgradeStr:SetText("")
			end

			if itemLevel and itemLevel > 0 then
				if maxUpgradeLevel and currentUpgradeLevel and (tonumber(currentUpgradeLevel) > 0) then
					if itemRarity <= 3 then
						itemLevel = itemLevel + (tonumber(currentUpgradeLevel) * 8)
					else
						itemLevel = itemLevel + (tonumber(currentUpgradeLevel) * 4)
					end
				end
				ilvlStr:SetTextColor(unpack(nibRealUI:GetILVLColor(itemLevel)))
				ilvlStr:SetText(itemLevel)
			else
				ilvlStr:SetText("")
			end
		else
			upgradeStr:SetText("")
			ilvlStr:SetText("")
		end
	end
	
	if not self.ilvl then
		self.ilvl = PaperDollFrame:CreateFontString("ARTWORK")
		self.ilvl:SetFontObject(SystemFont_Small)
		self.ilvl:SetPoint("TOP", PaperDollFrame, "TOP", 0, -20)
	end
	local avgItemLevel, avgItemLevelEquipped = GetAverageItemLevel()
	local aILColor = nibRealUI:GetILVLColor(avgItemLevel)[4]
	local aILEColor = nibRealUI:GetILVLColor(avgItemLevelEquipped)[4]
    avgItemLevel = floor(avgItemLevel)
    avgItemLevelEquipped = floor(avgItemLevelEquipped)
    self.ilvl:SetText("|c"..aILEColor..avgItemLevelEquipped.."|r |cffffffff/|r |c"..aILColor..avgItemLevel)
end

function PaperDoll:CharacterFrame_OnShow()
	self:RegisterBucketEvent({"UNIT_INVENTORY_CHANGED", "UPDATE_INVENTORY_DURABILITY"}, 0.25, "UpdateItems")
	self:UpdateItems()
end

function PaperDoll:CharacterFrame_OnHide()
	self:UnregisterAllBuckets()
end

function PaperDoll:ColorBorders(SlotID, RawSlot)
	local quality = GetInventoryItemQuality("player", SlotID)
	if quality then
		local r, g, b, _ = GetItemQualityColor(quality)
		_G[RawSlot.."QualityBorder"]:SetBackdropBorderColor(r, g, b)
		_G[RawSlot.."QualityBorder"]:Show()
	else
		_G[RawSlot.."QualityBorder"]:Hide()
	end
end

function PaperDoll:ColorBordersND()
	for _, nditem in ipairs(NON_DURABILITY_ITEMS) do
		if _G["Character"..nditem.."Slot"] then
			local SlotID, _ = GetInventorySlotInfo(nditem .. "Slot")
			local quality = GetInventoryItemQuality("player", SlotID)
			if quality then
				local r, g, b, _ = GetItemQualityColor(quality)
				_G[nditem.."QualityBorder"]:SetBackdropBorderColor(r, g, b)
				_G[nditem.."QualityBorder"]:Show()
			else
				_G[nditem.."QualityBorder"]:Hide()
			end
		end
	end
end

function PaperDoll:BorderToggle()
	self:UpdateItems()
end

--------------------
-- Initialization --
--------------------
function PaperDoll:OnInitialize()
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterSkin(MODNAME, "Character Window")
end

function PaperDoll:OnEnable()
	self:SecureHookScript(CharacterFrame, "OnShow", "CharacterFrame_OnShow")
	self:SecureHookScript(CharacterFrame, "OnHide", "CharacterFrame_OnHide")
	if not BordersSet then
		self:MakeTypeTable()
	end
end
