-- The "ListExample"-implementation provides list-based containers
-- All item buttons are rows in a scrollable list
-- Think of a very simple Baud Manifest

local ListExample = cargBags:NewImplementation("ListExample")
local ScrollContainer = ListExample:GetContainerClass()
local ListButton = ListExample:GetItemButtonClass()

ListExample:RegisterBlizzard()

function ListExample:OnInit()
	local onlyBags =		function(item) return item.bagID >= 0 and item.bagID <= 4 end
	local onlyBank =		function(item) return item.bagID == -1 or item.bagID >= 5 and item.bagID <= 11 end

	-- Don't forget to position only the mainFrame, not the container itself!
	local main = ScrollContainer:New("Main", {
			Bags = "backpack+bags",
		})
		main:SetFilter(onlyBags, true)
		main.mainFrame:SetPoint("RIGHT", -5, 0)

	local bank = ScrollContainer:New("Bank", {
			Bags = "bankframe+bank",
		})
		bank:SetFilter(onlyBank, true)
		bank.mainFrame:SetPoint("LEFT", 5, 0)
		bank.mainFrame:Hide()
end

function ListExample:OnBankOpened()
		self:GetContainer("Bank").mainFrame:Show()
end

function ListExample:OnBankClosed()
	self:GetContainer("Bank").mainFrame:Hide()
end



--[[#########################
	ScrollContainer
		Provides a scrollable frame for the item buttons
###########################]]

local function onMouseWheel(self, delta)
	local scroll = self.container.scroll

	local offset = scroll:GetVerticalScroll() - delta * 69 * 3
	offset = math.max(math.min(offset, scroll:GetVerticalScrollRange()), 0)
	scroll:SetVerticalScroll(offset)
end

function ScrollContainer:OnContentsChanged()
	self:SortButtons("bagSlot")
	local width, height = self:LayoutButtons("grid", 1, 5)
	self:SetSize(width, height)
end

function ScrollContainer:OnCreate(name, settings)
	self.Settings = settings

	-- The mainFrame takes the role of the container: plugins, layout and size
	-- 'scroll' is a scrollFrame and provides the inner dimensions for the real container with the items

	local mainFrame = CreateFrame("Button", nil, self.implementation)
	local scroll = CreateFrame("ScrollFrame", nil, mainFrame)
	self.mainFrame, self.scroll = mainFrame, scroll

	self:SetParent(parent)
	scroll:SetScrollChild(self)

	mainFrame:SetBackdrop{
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true, tileSize = 16, edgeSize = 16,
		insets = {left = 4, right = 4, top = 4, bottom = 4},
	}
	mainFrame:SetBackdropColor(0, 0, 0, 0.8)
	mainFrame:SetBackdropBorderColor(0, 0, 0, 0.5)
	mainFrame:SetFrameStrata("HIGH")
	mainFrame:SetScale(settings.Scale or 1)
	mainFrame:SetSize(settings.Width or 220, settings.Height or 500)

	mainFrame.container = self
	mainFrame:EnableMouseWheel(true)
	mainFrame:SetScript("OnMouseWheel", onMouseWheel)

	scroll:SetPoint("TOPLEFT", 10, -36)
	scroll:SetPoint("BOTTOMRIGHT", -10, 10)

	local infoFrame = CreateFrame("Button", nil, mainFrame)
	infoFrame:SetPoint("TOPLEFT", 10, -3)
	infoFrame:SetPoint("TOPRIGHT", -10, -3)
	infoFrame:SetHeight(32)

	local space = self:SpawnPlugin("TagDisplay", "[space:free/max]", infoFrame)
	space.bags = cargBags:ParseBags(settings.Bags)
	space:SetPoint("LEFT")

	self:SpawnPlugin("TagDisplay", "[money]", infoFrame):SetPoint("RIGHT", -10, 0)

	local search = self:SpawnPlugin("SearchBar", infoFrame)
	search:SetParent(mainFrame)
end

--[[#########################
	ListButton
		A wide button with a Name-text
###########################]]



function ListButton:OnCreate(tpl)
	self:SetWidth(200)
	self:SetHeight(24)

	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", onMouseWheel)

	self.Icon:ClearAllPoints()
	self.Icon:SetPoint("LEFT")
	self.Icon:SetSize(24, 24)

	self.Quest:ClearAllPoints()
	self.Quest:SetAllPoints(self.Icon)

	self.Border:ClearAllPoints()
	self.Border:SetPoint("CENTER", self.Icon, "CENTER", 0, -1)
	self.Border:SetSize(64/37*24, 64/37*24)

	self.Count:ClearAllPoints()
	self.Count:SetPoint("RIGHT")

	self.Name = self:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	self.Name:SetPoint("LEFT", self.Icon, "RIGHT", 5, 0)
	self.Name:SetPoint("RIGHT", self.Count, "LEFT", -5, 0)
	self.Name:SetJustifyH("LEFT")
end

function ListButton:OnUpdate(item)
	self.Name:SetText(item.name)
end
