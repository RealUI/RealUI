--[[
Name: Tablet-2.0
Revision: $Rev: 216 $
Author(s): ckknight (ckknight@gmail.com)
Website: http://ckknight.wowinterface.com/
Documentation: http://www.wowace.com/index.php/Tablet-2.0
SVN: http://svn.wowace.com/wowace/trunk/TabletLib/Tablet-2.0
Description: A library to provide an efficient, featureful tooltip-style display.
Dependencies: AceLibrary, (optional) Dewdrop-2.0
License: LGPL v2.1
]]

local MAJOR_VERSION = "Tablet-2.0"
local MINOR_VERSION = 90000 + tonumber(("$Revision: 216 $"):match("(%d+)"))

if not AceLibrary then error(MAJOR_VERSION .. " requires AceLibrary") end
if not AceLibrary:IsNewVersion(MAJOR_VERSION, MINOR_VERSION) then return end

local DEBUG = false

local SCROLL_UP = "Scroll up"
local SCROLL_DOWN = "Scroll down"
local HINT = "Hint"
local DETACH = "Detach"
local DETACH_DESC = "Detach the tablet from its source."
local SIZE = "Size"
local SIZE_DESC = "Scale the tablet."
local CLOSE_MENU = "Close menu"
local CLOSE_MENU_DESC = "Close the menu."
local COLOR = "Background color"
local COLOR_DESC = "Set the background color."
local LOCK = "Lock"
local LOCK_DESC = "Lock the tablet in its current position. Alt+Right-click for menu or Alt+drag to drag it when locked."

if GetLocale() == "deDE" then
	SCROLL_UP = "Hochscrollen"
	SCROLL_DOWN = "Runterscrollen"
	HINT = "Hinweis"
	DETACH = "L\195\182sen"
	DETACH_DESC = "L\195\182st den Tooltip aus seiner Verankerung."
	SIZE = "Gr\195\182\195\159e"
	SIZE_DESC = "Gr\195\182\195\159e des Tooltips \195\164ndern."
	CLOSE_MENU = "Menu schlie\195\159en"
	CLOSE_MENU_DESC = "Schlie\195\159t das Menu."
	COLOR = "Hintergrundfarbe"
	COLOR_DESC = "Hintergrundfarbe setzen."
	LOCK = "Sperren"
	LOCK_DESC = "Sperrt die aktuelle Position vom Tooltip. Alt+Rechts-klick f\195\188rs Men\195\188 oder Alt+Verschieben f\195\188rs verschieben wenn es gesperrt ist."
elseif GetLocale() == "koKR" then
	SCROLL_UP = "위로 스크롤"
	SCROLL_DOWN = "아래로 스크롤"
	HINT = "힌트"
	DETACH = "분리"
	DETACH_DESC = "테이블을 분리합니다."
	SIZE = "크기"
	SIZE_DESC = "테이블의 크기입니다."
	CLOSE_MENU = "메뉴 닫기"
	CLOSE_MENU_DESC = "메뉴를 닫습니다."
	COLOR = "배경 색상"
	COLOR_DESC = "배경 색상을 설정합니다."
	LOCK = "고정"
	LOCK_DESC = "현재 위치에 테이블을 고정합니다. 알트+우클릭 : 메뉴열기, 알트+드래그 : 고정된것을 드래그합니다."
elseif GetLocale() == "zhCN" then
	SCROLL_UP = "向上翻转"
	SCROLL_DOWN = "向上翻转"
	HINT = "提示"
	DETACH = "分离"
	DETACH_DESC = "分离菜单为独立提示."
	SIZE = "尺寸"
	SIZE_DESC = "缩放菜单显示尺寸."
	CLOSE_MENU = "关闭菜单"
	CLOSE_MENU_DESC = "关闭菜单"
	COLOR = "背景颜色"
	COLOR_DESC = "设置菜单背景颜色."
	LOCK = "锁定"
	LOCK_DESC = "锁定菜单当前位置. alt+右键 将显示选项, alt+拖动 可以移动已锁定的菜单."
elseif GetLocale() == "zhTW" then
	SCROLL_UP = "向上翻捲"
	SCROLL_DOWN = "向上翻捲"
	HINT = "提示"
	DETACH = "分離"
	DETACH_DESC = "分離選單為獨立提示。"
	SIZE = "尺寸"
	SIZE_DESC = "縮放選單顯示尺寸。"
	CLOSE_MENU = "關閉選單"
	CLOSE_MENU_DESC = "關閉選單。"
	COLOR = "背景顏色"
	COLOR_DESC = "設定選單背景顏色。"
	LOCK = "鎖定"
	LOCK_DESC = "鎖定選單目前位置設定。Alt-右鍵將顯示選項，Alt-拖動可以移動已鎖定的選單。"
elseif GetLocale() == "frFR" then
	SCROLL_UP = "Parcourir vers le haut"
	SCROLL_DOWN = "Parcourir vers le bas"
	HINT = "Astuce"
	DETACH = "D\195\169tacher"
	DETACH_DESC = "Permet de d\195\169tacher le tableau de sa source."
	SIZE = "Taille"
	SIZE_DESC = "Permet de changer l'\195\169chelle du tableau."
	CLOSE_MENU = "Fermer le menu"
	CLOSE_MENU_DESC = "Ferme ce menu."
	COLOR = "Couleur du fond"
	COLOR_DESC = "Permet de d\195\169finir la couleur du fond."
	LOCK = "Bloquer"
	LOCK_DESC = "Bloque le tableau \195\160 sa position actuelle. Alt+clic-droit pour le menu ou Alt+glisser pour le d\195\169placer quand il est bloqu\195\169."
elseif GetLocale() == "esES" then
	SCROLL_UP = "Desplazar hacia arriba"
	SCROLL_DOWN = "Desplazar hacia abajo"
	HINT = "Consejo"
	DETACH = "Separar"
	DETACH_DESC = "Separa el tooltip de su fuente."
	SIZE = "Tama\195\177o"
	SIZE_DESC = "Escala el tooltip"
	CLOSE_MENU = "Cerrar men\195\186"
	CLOSE_MENU_DESC = "Cierra el men\195\186"
	COLOR = "Color de fondo"
	COLOR_DESC = "Establece el color de fondo"
	LOCK = "Bloquear"
	LOCK_DESC = "Bloquea el tooltip  en su posici\195\179n actual. Clic+Alt para el men\195\186 y arrastra+Alt para arrastrarlo cuando est\195\161 bloqueado"
elseif GetLocale() == "ruRU" then
	SCROLL_UP = "Прокрутка вверх"
	SCROLL_DOWN = "Прокрутка вниз"
	HINT = "Совет"
	DETACH = "Отделить"
	DETACH_DESC = "Отделить планшет от его источника."
	SIZE = "Размер"
	SIZE_DESC = "Масштаб планшета."
	CLOSE_MENU = "Закрыть меню"
	CLOSE_MENU_DESC = "Закрыть меню."
	COLOR = "Цвет фона"
	COLOR_DESC = "Установить цвет фона."
	LOCK = "Зафиксировать"
	LOCK_DESC = "Зафиксировать планшет в его текущем позиции. Alt+ПКМ для меню или Alt+перетаскивание для перетаскивания когда планшет зафиксирован."
end

local start = GetTime()
local wrap
local GetProfileInfo
if DEBUG then
	local tree = {}
	local treeMemories = {}
	local treeTimes = {}
	local memories = {}
	local times = {}
	function wrap(value, name)
		if type(value) == "function" then
			local oldFunction = value
			memories[name] = 0
			times[name] = 0
			return function(self, ...)
				local pos = #tree
				tree[#tree+1] = name
				treeMemories[#treeMemories+1] = 0
				treeTimes[#treeTimes+1] = 0
				local t, mem = GetTime(), gcinfo()
				local r1, r2, r3, r4, r5, r6, r7, r8 = oldFunction(self, ...)
				mem, t = gcinfo() - mem, GetTime() - t
				if pos > 0 then
					treeMemories[pos] = treeMemories[pos] + mem
					treeTimes[pos] = treeTimes[pos] + t
				end
				local otherMem = table.remove(treeMemories)
				if mem - otherMem > 0 then
					memories[name] = memories[name] + mem - otherMem
				end
				times[name] = times[name] + t - table.remove(treeTimes)
				table.remove(tree)
				return r1, r2, r3, r4, r5, r6, r7, r8
			end
		end
	end

	function GetProfileInfo()
		return GetTime() - start, times, memories
	end
else
	function wrap(value)
		return value
	end
end

local function SetBorder(parent)
	local sd = CreateFrame("Frame", nil, parent)
	sd:SetBackdrop({
		edgeFile = "Interface\\Buttons\\WHITE8X8",
		edgeSize = 1,
	})
	sd:SetPoint("TOPLEFT", parent, 2, -2)
	sd:SetPoint("BOTTOMRIGHT", parent, -2, 2)
	sd:SetBackdropBorderColor(0, 0, 0)
	sd:SetAlpha(1)
	
	-- local sd2 = CreateFrame("Frame", nil, parent)
	-- sd2:SetBackdrop({
	-- 	edgeFile = "Interface\\Buttons\\WHITE8X8",
	-- 	edgeSize = 1,
	-- })
	-- sd2:SetPoint("TOPLEFT", parent, 3, -3)
	-- sd2:SetPoint("BOTTOMRIGHT", parent, -3, 3)
	-- sd2:SetBackdropBorderColor(0.1, 0.1, 0.1)
	-- sd2:SetAlpha(1)
end

local function GetMainFrame()
	if UIParent:IsShown() then
		return UIParent
	end
	local f = GetUIPanel("fullscreen")
	if f and f:IsShown() then
		return f
	end
	return nil
end
GetMainFrame = wrap(GetMainFrame, "GetMainFrame")

local MIN_TOOLTIP_SIZE = 200
local TESTSTRING_EXTRA_WIDTH = 8
local Tablet = {}
local CleanCategoryPool
local pool = {}

local function del(t)
	setmetatable(t, nil)
	for k in pairs(t) do
		t[k] = nil
	end
	t[''] = true
	t[''] = nil
	pool[t] = true
	return nil
end

local function copy(parent)
	local t = next(pool)
	if not t then
		t = {}
	else
		pool[t] = nil
	end
	if parent then
		for k,v in pairs(parent) do
			t[k] = v
		end
		setmetatable(t, getmetatable(parent))
	end
	return t
end

local function new(...)
	local t = next(pool)
	if not t then
		t = {}
	else
		pool[t] = nil
	end
	
	for i = 1, select('#', ...), 2 do
		local k = select(i, ...)
		if k then
			t[k] = select(i+1, ...)
		else
			break
		end
	end
	return t
end

local tmp
tmp = setmetatable({}, {__index = function(self, key)
	local t = {}
	tmp[key] = function(...)
		for k in pairs(t) do
			t[k] = nil
		end
		for i = 1, select('#', ...), 2 do
			local k = select(i, ...)
			if k then
				t[k] = select(i+1, ...)
			else
				break
			end
		end
		return t
	end
	return tmp[key]
end})

local headerSize, normalSize
if GameTooltipHeaderText then
	headerSize = select(2,GameTooltipHeaderText:GetFont())
else
	headerSize = 14
end
if GameTooltipText then
	normalSize = select(2,GameTooltipText:GetFont())
else
	normalSize = 12
end
local tooltip
local testString
local TabletData = {}
local Category = {}
local Line = {}
local function getTestWidth(font, size, text)
	if not testString then
		return MIN_TOOLTIP_SIZE + 40
	end
	testString:SetWidth(0)
	testString:SetFontObject(font)
	local a,_,b = font:GetFont()
	testString:SetFont(a, size, b)
	testString:SetText(text)
	return testString:GetStringWidth()-- + TESTSTRING_EXTRA_WIDTH
end
getTestWidth = wrap(getTestWidth, "getTestWidth")
do
	local TabletData_mt = { __index = TabletData }
	function TabletData:new(tablet)
		local self = new()
		self.categories = new()
		self.id = 0
		self.width = 0 -- (MIN_TOOLTIP_SIZE - 20)*tablet.fontSizePercent
		self.tablet = tablet
		self.title = nil
		self.titleR, self.titleG, self.titleB = nil, nil, nil
		self.num_lines = 0
		setmetatable(self, TabletData_mt)
		return self
	end
	TabletData.new = wrap(TabletData.new, "TabletData:new")
	
	function TabletData:checkMinWidth()
		local min = self.minWidth or MIN_TOOLTIP_SIZE
		local width = (min - 20)*self.tablet.fontSizePercent
		if self.width < width then
			self.width = width
		end
	end
	TabletData.checkMinWidth = wrap(TabletData.checkMinWidth, "TabletData:checkMinWidth")

	function TabletData:del()
		for k, v in ipairs(self.categories) do
			v:del()
		end
		del(self.categories)
		del(self)
	end
	TabletData.del = wrap(TabletData.del, "TabletData:del")

	function TabletData:Display()
		if self.title and (self.tablet == tooltip or self.tablet.registration.showTitleWhenDetached) then
			local info = new(
				'hideBlankLine', true,
				'text', self.title,
				'justify', "CENTER",
				'font', GameTooltipHeaderText,
				'isTitle', true
			)
			if self.titleR then
				info.textR = self.titleR
				info.textG = self.titleG
				info.textB = self.titleB
			end
			self:AddCategory(info, 1)
			del(info)
		end
		if self.tablet == tooltip or self.tablet.registration.showHintWhenDetached then
			if self.hint then
				local hintCat = self:AddCategory(nil)
				hintCat:AddLine('blank', true, 'fakeChild', true, 'noInherit', true)
				hintCat:AddLine(
					'text', self.hint,	--HINT .. ": " .. self.hint,
					'textR', 0,
					'textG', 1,
					'textB', 0,
					'wrap', true
				)
			end
		end

		local tabletData = self.tabletData
		for k, v in ipairs(self.categories) do
			local width
			if v.columns <= 2 then
				width = v.x1
			else
				width = (v.columns - 1)*20
				for i = 1, v.columns do
					width = width + v['x' .. i]
				end
			end
			if self.width < width then
				self.width = width
			end
		end
		
		local good = false
		local lastTitle = true
		for k, v in ipairs(self.categories) do
			if lastTitle then
				v.hideBlankLine = true
				lastTitle = false
			end
			if v:Display(self.tablet) and (not v.isTitle or not self.tablet.registration.hideWhenEmpty or next(self.categories, k)) then
				good = true
			end
			if v.isTitle then
				lastTitle = true
			end
		end
		if not good then
			if self.tablet == tooltip or not self.tablet.registration.hideWhenEmpty then
				local width
				local info = new(
					'hideBlankLine', true,
					'text', self.title,
					'justify', "CENTER",
					'font', GameTooltipHeaderText,
					'isTitle', true
				)
				local cat = self:AddCategory(info)
				del(info)
				self.width = self.categories[#self.categories].x1
				cat:Display(self.tablet)
			else
				self.tablet:__Hide()
				self.tablet.tmpHidden = true
			end
		else
			self.tablet:__Show()
			self.tablet.tmpHidden = nil
		end
	end
	TabletData.Display = wrap(TabletData.Display, "TabletData:Display")

	function TabletData:AddCategory(info, index)
		local made = false
		if not info then
			made = true
			info = new()
		end
		local cat = Category:new(self, info)
		if index then
			table.insert(self.categories, index, cat)
		else
			self.categories[#self.categories+1] = cat
		end
		if made then
			del(info)
		end
		return cat
	end
	TabletData.AddCategory = wrap(TabletData.AddCategory, "TabletData:AddCategory")
	
	function TabletData:SetHint(hint)
		self.hint = hint
	end
	TabletData.SetHint = wrap(TabletData.SetHint, "TabletData:SetHint")
	
	function TabletData:SetTitle(title)
		self.title = title or "Title"
	end
	TabletData.SetTitle = wrap(TabletData.SetTitle, "TabletData:SetTitle")
	
	function TabletData:SetTitleColor(r, g, b)
		self.titleR = r
		self.titleG = g
		self.titleB = b
	end
	TabletData.SetTitleColor = wrap(TabletData.SetTitleColor, "TabletData:SetTitleColor")
end
do
	local Category_mt = { __index = Category }
	function Category:new(tabletData, info, superCategory)
		local self = copy(info)
		if superCategory and not self.noInherit then
			self.superCategory = superCategory.superCategory
			for k, v in pairs(superCategory) do
				if k:find("^child_") then
					local k = strsub(k, 7)
					if self[k] == nil then
						self[k] = v
					end
				end
			end
			self.columns = superCategory.columns
		else
			self.superCategory = self
		end
		self.tabletData = tabletData
		self.lines = new()
		if not self.columns then
			self.columns = 1
		end
		for i = 1, self.columns do
			self['x' .. i] = 0
		end
		setmetatable(self, Category_mt)
		self.lastWasTitle = nil
		local good = self.text
		if not good then
			for i = 2, self.columns do
				if self['text' .. i] then
					good = true
					break
				end
			end
		end
		if good then
			local x = new(
				'category', category,
				'text', self.text,
				'fakeChild', true,
				'func', self.func,
				'onEnterFunc', self.onEnterFunc,
				'onLeaveFunc', self.onLeaveFunc,
				'hasCheck', self.hasCheck,
				'checked', self.checked,
				'checkIcon', self.checkIcon,
				'isRadio', self.isRadio,
				'font', self.font,
				'size', self.size,
				'wrap', self.wrap,
				'catStart', true,
				'indentation', self.indentation,
				'noInherit', true,
				'justify', self.justify,
				'isLine', self.isLine,
				'isTitle', self.isTitle
			)
			local i = 1
			while true do
				local k = 'arg' .. i
				local v = self[k]
				if v == nil then
					break
				end
				x[k] = v
				i = i + 1
			end
			i = 1
			while true do
				local k = 'onEnterArg' .. i
				local v = self[k]
				if v == nil then
					break
				end
				x[k] = v
				i = i + 1
			end
			i = 1
			while true do
				local k = 'onLeaveArg' .. i
				local v = self[k]
				if v == nil then
					break
				end
				x[k] = v
				i = i + 1
			end
			if self.isTitle then
				x.textR = self.textR or 1
				x.textG = self.textG or 0.823529
				x.textB = self.textB or 0
			else
				x.textR = self.textR or 1
				x.textG = self.textG or 1
				x.textB = self.textB or 1
			end
			for i = 2, self.columns do
				x['text' .. i] = self['text' .. i]
				x['text' .. i .. 'R'] = self['text' .. i .. 'R'] or self['textR' .. i] or 1
				x['text' .. i .. 'G'] = self['text' .. i .. 'G'] or self['textG' .. i] or 1
				x['text' .. i .. 'B'] = self['text' .. i .. 'B'] or self['textB' .. i] or 1
				x['font' .. i] = self['font' .. i]
				x['size' .. i] = self['size' .. i]
				x['justify' .. i] = self['justify' .. i]
			end
			if self.checkIcon and self.checkIcon:find("^Interface\\Icons\\") then
				x.checkCoordLeft = self.checkCoordLeft or 0.05
				x.checkCoordRight = self.checkCoordRight or 0.95
				x.checkCoordTop = self.checkCoordTop or 0.05
				x.checkCoordBottom = self.checkCoordBottom or 0.95
			else
				x.checkCoordLeft = self.checkCoordLeft or 0
				x.checkCoordRight = self.checkCoordRight or 1
				x.checkCoordTop = self.checkCoordTop or 0
				x.checkCoordBottom = self.checkCoordBottom or 1
			end
			x.checkColorR = self.checkColorR or 1
			x.checkColorG = self.checkColorG or 1
			x.checkColorB = self.checkColorB or 1
			self:AddLine(x)
			del(x)
			self.lastWasTitle = true
		end
		return self
	end
	Category.new = wrap(Category.new, "Category:new")

	function Category:del()
		local prev = garbageLine
		for k, v in pairs(self.lines) do
			v:del()
		end
		del(self.lines)
		del(self)
	end
	Category.del = wrap(Category.del, "Category:del")

	function Category:AddLine(...)
		self.lastWasTitle = nil
		local line
		local k1 = ...
		if type(k1) == "table" then
			local k2 = select(2, ...)
			Line:new(self, k1, k2)
		else
			local info = new(...)
			Line:new(self, info)
			info = del(info)
		end
	end
	Category.AddLine = wrap(Category.AddLine, "Category:AddLine")

	function Category:AddCategory(...)
		local lastWasTitle = self.lastWasTitle
		self.lastWasTitle = nil
		local info
		local k1 = ...
		if type(k1) == "table" then
			info = k1
		else
			info = new(...)
		end
		if lastWasTitle or #self.lines == 0 then
			info.hideBlankLine = true
		end
		local cat = Category:new(self.tabletData, info, self)
		self.lines[#self.lines+1] = cat
		if info ~= k1 then
			info = del(info)
		end
		return cat
	end
	Category.AddCategory = wrap(Category.AddCategory, "Category:AddCategory")

	function Category:HasChildren()
		local hasChildren = false
		for k, v in ipairs(self.lines) do
			if v.HasChildren then
				if v:HasChildren() then
					return true
				end
			end
			if not v.fakeChild then
				return true
			end
		end
		return false
	end
	Category.HasChildren = wrap(Category.HasChildren, "Category:HasChildren")

	local lastWasTitle = false
	function Category:Display(tablet)
		if not self.isTitle and not self.showWithoutChildren and not self:HasChildren() then
			return false
		end
		if not self.hideBlankLine and not lastWasTitle then
			-- local info = new(
				-- 'blank', true,
				-- 'fakeChild', true,
				-- 'noInherit', true
			-- )
			-- self:AddLine(info, 1)
			-- del(info)
		end
		local good = false
		if #self.lines > 0 then
			self.tabletData.id = self.tabletData.id + 1
			self.id = self.tabletData.id
			for k, v in ipairs(self.lines) do
				if v:Display(tablet) then
					good = true
				end
			end
		end
		lastWasTitle = self.isTitle
		return good
	end
	Category.Display = wrap(Category.Display, "Category:Display")
end
do
	local Line_mt = { __index = Line }
	function Line:new(category, info, position)
		local self = copy(info)
		if not info.noInherit then
			for k, v in pairs(category) do
				if k:find("^child_") then
					local k = strsub(k, 7)
					if self[k] == nil then
						self[k] = v
					end
				end
			end
		end
		self.category = category
		if position then
			table.insert(category.lines, position, self)
		else
			category.lines[#category.lines+1] = self
		end
		setmetatable(self, Line_mt)
		local n = category.tabletData.num_lines + 1
		category.tabletData.num_lines = n
		if n == 10 then
			category.tabletData:checkMinWidth()
		end
		local columns = category.columns
		if columns == 1 then
			if not self.justify then
				self.justify = "LEFT"
			end
		elseif columns == 2 then
			if not self.justify then
				self.justify = "LEFT"
			end
			if not self['justify2'] then
				self['justify2'] = "LEFT"
			end
			if self.wrap then
				self.wrap2 = false
			end
		else
			for i = 2, columns-1 do
				if not self['justify' .. i] then
					self['justify' .. i] = "CENTER"
				end
			end
			if not self.justify then
				self.justify = "LEFT"
			end
			if not self['justify' .. columns] then
				self['justify' .. columns] = "RIGHT"
			end
			if self.wrap then
				for i = 2, columns do
					self['wrap' .. i] = false
				end
			else
				for i = 2, columns do
					if self['wrap' .. i] then
						for j = i+1, columns do
							self['wrap' .. i] = false
						end
						break
					end
				end
			end
		end
		if not self.indentation or self.indentation < 0 then
			self.indentation = 0
		end
		if not self.font then
			self.font = GameTooltipText
		end
		for i = 2, columns do
			if not self['font' .. i] then
				self['font' .. i] = self.font
			end
		end
		if not self.size then
			self.size = select(2,self.font:GetFont())
		end
		for i = 2, columns do
			if not self['size' .. i] then
				self['size' .. i] = select(2,self['font' .. i]:GetFont())
			end
		end
		if self.checkIcon and self.checkIcon:find("^Interface\\Icons\\") then
			if not self.checkCoordLeft then
				self.checkCoordLeft = 0.05
			end
			if not self.checkCoordRight then
				self.checkCoordRight = 0.95
			end
			if not self.checkCoordTop then
				self.checkCoordTop = 0.05
			end
			if not self.checkCoordBottom then
				self.checkCoordBottom = 0.95
			end
		else
			if not self.checkCoordLeft then
				self.checkCoordLeft = 0
			end
			if not self.checkCoordRight then
				self.checkCoordRight = 1
			end
			if not self.checkCoordTop then
				self.checkCoordTop = 0
			end
			if not self.checkCoordBottom then
				self.checkCoordBottom = 1
			end
		end
		if not self.checkColorR then
			self.checkColorR = 1
		end
		if not self.checkColorG then
			self.checkColorG = 1
		end
		if not self.checkColorB then
			self.checkColorB = 1
		end

		local fontSizePercent = category.tabletData.tablet.fontSizePercent
		local w = 0
		self.checkWidth = 0
		testString = category.tabletData.tablet.buttons[1].col1
		if self.text then
			if not self.wrap then
				local testWidth = getTestWidth(self.font, self.size * fontSizePercent, self.text)
				if self.customwidth then 
					if testWidth < self.customwidth then
						testWidth = self.customwidth
					end
				end
				local checkWidth = self.hasCheck and self.size * fontSizePercent or 0
				self.checkWidth = checkWidth
				w = testWidth + self.indentation * fontSizePercent + checkWidth
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			else
				if columns == 1 then
					local testWidth = getTestWidth(self.font, self.size * fontSizePercent, self.text)
					if self.customwidth then 
						testWidth = self.customwidth
					end
					local checkWidth = self.hasCheck and self.size * fontSizePercent or 0
					self.checkWidth = checkWidth
					w = testWidth + self.indentation * fontSizePercent + checkWidth
					if w > (MIN_TOOLTIP_SIZE - 20) * fontSizePercent then
						w = (MIN_TOOLTIP_SIZE - 20) * fontSizePercent
					end
				else
					if self.customwidth then 
						w = self.customwidth
					else
						w = MIN_TOOLTIP_SIZE * fontSizePercent / 2
					end
				end
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			end
		end
		if columns == 2 and self.text2 then
			if not self.wrap2 then
				local testWidth = getTestWidth(self.font2, self.size2 * fontSizePercent, self.text2)
				if self.customwidth2 then 
					w = w + 20 + self.customwidth2
				else
					w = w + 40 * fontSizePercent + testWidth
				end
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			else
				w = w + 40 * fontSizePercent + MIN_TOOLTIP_SIZE * fontSizePercent / 2
				if category.superCategory.x1 < w then
					category.superCategory.x1 = w
				end
			end
		elseif columns >= 3 then
			if self.text2 then
				if not self.wrap2 then
					local testWidth = getTestWidth(self.font2, self.size2 * fontSizePercent, self.text2)
					if self.customwidth2 then 
						if testWidth < self.customwidth2 then
							testWidth = self.customwidth2
						end
					end
					local w = testWidth
					if category.superCategory.x2 < w then
						category.superCategory.x2 = w
					end
				else
					local w = MIN_TOOLTIP_SIZE / 2
					if category.superCategory.x2 < w then
						category.superCategory.x2 = w
					end
				end
			end
			
			for i = 3, columns do
				local text = self['text' .. i]
				if text then
					local x_i = 'x' .. i
					if not self['wrap' .. i] then
						local testWidth = getTestWidth(self['font' .. i], self['size' .. i] * fontSizePercent, text)
						if self['customwidth'..i] then 
							if testWidth < self['customwidth'..i] then
								testWidth = self['customwidth'..i]
							end
						end
						local w = testWidth
						if category.superCategory[x_i] < w then
							category.superCategory[x_i] = w
						end
					else
						local w = MIN_TOOLTIP_SIZE / 2
						if category.superCategory[x_i] < w then
							category.superCategory[x_i] = w
						end
					end
				end
			end
		end
		return self
	end
	Line.new = wrap(Line.new, "Line:new")

	function Line:del()
		del(self)
	end
	Line.del = wrap(Line.del, "Line:del")

	function Line:Display(tablet)
		tablet:AddLine(self)
		return true
	end
	Line.Display = wrap(Line.Display, "Line:Display")
end

local fake_ipairs
do
	local function iter(tmp, i)
		i = i + 1
		local x = tmp[i]
		tmp[i] = nil
		if x then
			return i, x
		end
	end
	
	local tmp = {}
	function fake_ipairs(...)
		for i = 1, select('#', ...) do
			tmp[i] = select(i, ...)
		end
		return iter, tmp, 0
	end
	fake_ipairs = wrap(fake_ipairs, "fake_ipairs")
end

local function argunpack(t, key, i)
	if not i then
		i = 1
	end
	local k = key .. i
	local v = t[k]
	if v then
		return v, argunpack(t, key, i+1)
	end
end	
argunpack = wrap(argunpack, "argunpack")


local delstring, newstring
do
	local cache = {}
	function delstring(t)
		cache[#cache+1] = t
		t:SetText(nil)
		t:ClearAllPoints()
		t:Hide()
		t:SetParent(UIParent)
		return nil
	end
	delstring = wrap(delstring, "delstring")
	function newstring(parent)
		if #cache ~= 0 then
			local t = cache[#cache]
			cache[#cache] = nil
			t:Show()
			t:SetParent(parent)
			return t
		end
		local t = parent:CreateFontString(nil, "ARTWORK")
		return t
	end
	newstring = wrap(newstring, "newstring")
end

local function button_OnEnter(this, ...)
	if type(this.self:GetScript("OnEnter")) == "function" then
		this.self:GetScript("OnEnter")(this.self, ...)
	end
	this.highlight:Show()
	if this.onEnterFunc then
		local success, ret = pcall(this.onEnterFunc, argunpack(this, 'onEnterArg'))
		if not success then
			geterrorhandler()(ret)
		end
	end
end	
button_OnEnter = wrap(button_OnEnter, "button_OnEnter")

local function button_OnLeave(this, ...)
	if type(this.self:GetScript("OnLeave")) == "function" then
		this.self:GetScript("OnLeave")(this.self, ...)
	end
	this.highlight:Hide()
	if this.onLeaveFunc then
		local success, ret = pcall(this.onLeaveFunc, argunpack(this, 'onLeaveArg'))
		if not success then
			geterrorhandler()(ret)
		end
	end
end
button_OnLeave = wrap(button_OnLeave, "button_OnLeave")
local lastMouseDown
local function button_OnClick(this, arg1, ...)
	if this.self:HasScript("OnClick") and type(this.self:GetScript("OnClick")) == "function" then
		this.self:GetScript("OnClick")(this.self, arg1, ...)
	end
	if arg1 == "RightButton" then
		if this.self:HasScript("OnClick") and type(this.self:GetScript("OnClick")) == "function" then
			this.self:GetScript("OnClick")(this.self, arg1, ...)
		end
	elseif arg1 == "LeftButton" then
		if this.self.preventClick == nil or GetTime() > this.self.preventClick and GetTime() < lastMouseDown + 0.5 then
			this.self.preventClick = nil
			this.self.updating = true
			this.self.preventRefresh = true
			local success, ret = pcall(this.func, argunpack(this, 'arg'))
			if not success then
				geterrorhandler()(ret)
			end
			if this.self and this.self.registration then
				this.self.preventRefresh = false
				this.self:children()
				this.self.updating = false
			end
		end
	end
end
button_OnClick = wrap(button_OnClick, "button_OnClick")
local function button_OnMouseUp(this, arg1, ...)
	if this.self:HasScript("OnMouseUp") and type(this.self:GetScript("OnMouseUp")) == "function" then
		this.self:GetScript("OnMouseUp")(this.self, arg1, ...)
	end
	if arg1 ~= "RightButton" then
		if this.clicked then
			local a,b,c,d,e = this.check:GetPoint(1)
			this.check:SetPoint(a,b,c,d-1,e+1)
			this.clicked = false
		end
	end
end
button_OnMouseUp = wrap(button_OnMouseUp, "button_OnMouseUp")
local function button_OnMouseDown(this, arg1, ...)
	if this.self:HasScript("OnMouseDown") and type(this.self:GetScript("OnMouseDown")) == "function" then
		this.self:GetScript("OnMouseDown")(this.self, arg1, ...)
	end
	lastMouseDown = GetTime()
	if arg1 ~= "RightButton" then
		local a,b,c,d,e = this.check:GetPoint(1)
		this.check:SetPoint(a,b,c,d+1,e-1)
		this.clicked = true
	end
end
button_OnMouseDown = wrap(button_OnMouseDown, "button_OnMouseDown")
local function button_OnDragStart(this, ...)
	local parent = this:GetParent() and this:GetParent().tablet
	if parent:GetScript("OnDragStart") then
		return parent:GetScript("OnDragStart")(parent, ...)
	end
end
button_OnDragStart = wrap(button_OnDragStart, "button_OnDragStart")
local function button_OnDragStop(this, ...)
	local parent = this:GetParent() and this:GetParent().tablet
	if parent:GetScript("OnDragStop") then
		return parent:GetScript("OnDragStop")(parent, ...)
	end
end
button_OnDragStop = wrap(button_OnDragStop, "button_OnDragStop")

local num_buttons = 0
local function NewLine(self)
	if self.maxLines <= self.numLines then
		self.maxLines = self.maxLines + 1
		num_buttons = num_buttons + 1

		local button = CreateFrame("Button", "Tablet20Button" .. num_buttons, self.scrollChild)
		button.self = self
		self.buttons[#self.buttons+1] = button
			button:SetFrameLevel(12)
			button.indentation = 0
			button:SetPoint("RIGHT", self.scrollFrame, "RIGHT", -7, 0)
		
		local check = button:CreateTexture(nil, "ARTWORK")
		button.check = check
			check.shown = false
			check:SetPoint("TOPLEFT", button, "TOPLEFT")
			local size = select(2, GameTooltipText:GetFont())
			check:SetHeight(size * 1.5)
			check:SetWidth(size * 1.5)
			check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
			check:SetAlpha(0)
			check:Show()

		local col1 = newstring(button)
		button.col1 = col1
		testString = col1
			col1:SetWidth(0)
			col1:SetPoint("TOPLEFT", check, "TOPLEFT")
			col1:Hide()
		
		local highlight = button:CreateTexture(nil, "BACKGROUND")
		button.highlight = highlight
			highlight:SetTexture("Interface\\AddOns\\nibRealUI\\Libs\\Libs\\TabletLib\\Highlight")
			highlight:SetVertexColor(unpack(RealUI.classColor))
			highlight:SetBlendMode("ADD")
			highlight:SetAllPoints(button)
			highlight:Hide()
			
		if self.maxLines == 1 then
			col1:SetFontObject(GameTooltipHeaderText)
			col1:SetJustifyH("CENTER")
			button:SetPoint("TOPLEFT", self.scrollFrame, "TOPLEFT", 3, -5)
		else
			col1:SetFontObject(GameTooltipText)
			button:SetPoint("TOPLEFT", self.buttons[self.maxLines - 1], "BOTTOMLEFT", 0, -2)
		end
		
		button:SetScript("OnEnter", button_OnEnter)
		button:SetScript("OnLeave", button_OnLeave)
		if not button.clicked then
			button:SetScript("OnMouseWheel", self:GetScript("OnMouseWheel"))
			button:EnableMouseWheel(true)
			button:Hide()
		end
	end
end
NewLine = wrap(NewLine, "NewLine")

local function RecalculateTabletHeight(detached)
	detached.height_ = nil
	if detached.registration and detached.registration.positionFunc then
		local height = detached:GetHeight()
		if height > 0 then
			detached.height_ = height
		else
			local top, bottom
			for i = 1, detached:GetNumPoints() do
				local a,b,c,d,e = detached:GetPoint(i)
		
				if a:find("^TOP") then
					if c:find("^TOP") then
						top = b:GetTop()
					elseif c:find("^BOTTOM") then
						top = b:GetBottom()
					else
						top = select(2,b:GetCenter())
					end
					if top then
						top = top + e
					end
				elseif a:find("^BOTTOM") then
					if c:find("^TOP") then
						bottom = b:GetTop()
					elseif c:find("^BOTTOM") then
						bottom = b:GetBottom()
					else
						bottom = select(2,b:GetCenter())
					end
					if bottom then
						bottom = bottom + e
					end
				end
			end
			if top and bottom then
				detached.height_ = top - bottom
			end
		end
	end
end
RecalculateTabletHeight = wrap(RecalculateTabletHeight, "RecalculateTabletHeight")

local function GetTooltipHeight(self)
	RecalculateTabletHeight(self)
	if self.height_ then
		local height = self:GetTop() and self:GetBottom() and self:GetTop() - self:GetBottom() or self:GetHeight()
		if height == 0 then
			height = self.height_
		end
		return height
	end
	if self.registration.maxHeight then
		return self.registration.maxHeight
	end
	if self == tooltip then
		return GetScreenHeight()*3/4
	else
		return GetScreenHeight()*2/3
	end
end
GetTooltipHeight = wrap(GetTooltipHeight, "GetTooltipHeight")

local overFrame = nil
local detachedTooltips = {}
local AcquireDetachedFrame, ReleaseDetachedFrame
local function AcquireFrame(self, registration, data, detachedData)
	if not detachedData then
		detachedData = data
	end
	if tooltip then
		tooltip.data = data
		tooltip.detachedData = detachedData
		
		local fontSizePercent = tooltip.data and tooltip.data.fontSizePercent or 1
		local transparency = tooltip.data and tooltip.data.transparency or 0.8
		local r = tooltip.data and tooltip.data.r or 0
		local g = tooltip.data and tooltip.data.g or 0
		local b = tooltip.data and tooltip.data.b or 0

		tooltip:SetFontSizePercent(fontSizePercent)
		tooltip:SetTransparency(transparency)
		tooltip:SetColor(r, g, b)
		tooltip:SetParent(GetMainFrame())
		tooltip:SetFrameStrata(registration.strata or "TOOLTIP")
		tooltip:SetFrameLevel(10)
		for _,frame in fake_ipairs(tooltip:GetChildren()) do
			frame:SetFrameLevel(12)
		end
	else
		tooltip = CreateFrame("Frame", "Tablet20Frame", UIParent)
		self.tooltip = tooltip
		
		tooltip:SetParent(GetMainFrame())
		tooltip:SetFrameStrata(registration.strata or "TOOLTIP")
		tooltip:SetFrameLevel(10)
		
		tooltip:EnableMouse(true)
		tooltip:EnableMouseWheel(true)
		local backdrop = new(
			'bgFile', "Interface\\Buttons\\WHITE8X8",
			'edgeFile', "",
			'tile', true,
			'tileSize', 16,
			'edgeSize', 0,
			'insets', new(
				'left', 2,
				'right', 2,
				'top', 2,
				'bottom', 2
			)
		)
		tooltip:SetBackdrop(backdrop)
		SetBorder(tooltip)
		del(backdrop.insets)
		del(backdrop)
		tooltip:SetBackdropColor(0, 0, 0, 1)
		
		tooltip.data = data
		tooltip.detachedData = detachedData

		RealUI:AddStripeTex(tooltip)

		tooltip.numLines = 0
		tooltip.owner = nil
		tooltip.fontSizePercent = tooltip.data and tooltip.data.fontSizePercent or 1
		tooltip.maxLines = 0
		tooltip.buttons = {}
		tooltip.transparency = tooltip.data and tooltip.data.transparency or 0.8
		tooltip:SetBackdropColor(0, 0, 0, tooltip.transparency)
		tooltip:SetBackdropBorderColor(0, 0, 0, 1)

		tooltip:SetScript("OnUpdate", function(this, elapsed)
			if not tooltip.updating and (not tooltip.enteredFrame or (overFrame and not MouseIsOver(overFrame))) then
				tooltip.scrollFrame:SetVerticalScroll(0)
				tooltip.slider:SetValue(0)
				tooltip:Hide()
				tooltip.registration.tooltip = nil
				tooltip.registration = nil
				overFrame = nil
			end
		end)

		tooltip:SetScript("OnEnter", function(this)
			if tooltip.clickable then
				tooltip.enteredFrame = true
				overFrame = nil
			end
		end)

		tooltip:SetScript("OnLeave", function(this)
			if not tooltip.updating then
				tooltip.enteredFrame = false
			end
		end)

		tooltip:SetScript("OnMouseWheel", function(this, arg1)
			tooltip.updating = true
			tooltip:Scroll(arg1 < 0)
			tooltip.updating = false
		end)
		
		local scrollFrame = CreateFrame("ScrollFrame", "Tablet20FrameScrollFrame", tooltip)
		scrollFrame:SetFrameLevel(11)
		local scrollChild = CreateFrame("Frame", "Tablet20FrameScrollChild", scrollFrame)
		scrollChild.tablet = tooltip
		scrollFrame:SetScrollChild(scrollChild)
		tooltip.scrollFrame = scrollFrame
		tooltip.scrollChild = scrollChild
		scrollFrame:SetPoint("TOPLEFT", 5, -5)
		scrollFrame:SetPoint("TOPRIGHT", -5, -5)
		scrollFrame:SetPoint("BOTTOMLEFT", 5, 5)
		scrollFrame:SetPoint("BOTTOMRIGHT", -5, 5)
		scrollChild:SetWidth(1)
		scrollChild:SetHeight(1)
		local slider = CreateFrame("Slider", "Tablet20FrameSlider", scrollFrame)
		tooltip.slider = slider
		slider:SetOrientation("VERTICAL")
		slider:SetMinMaxValues(0, 1)
		slider:SetValueStep(0.001)
		slider:SetValue(0)
		slider:SetWidth(16)
		slider:SetPoint("TOPRIGHT", 0, 0)
		slider:SetPoint("BOTTOMRIGHT", 0, 0)
		slider:SetBackdrop(new(
			'bgFile', "",
			'edgeFile', "",
			'tile', true,
			'edgeSize', 1,
			'tileSize', 8,
			'insets', new(
				'left', 1,
				'right', 1,
				'top', 1,
				'bottom', 1
			)
		))
		slider:SetThumbTexture("Interface\\AddOns\\nibRealUI\\Libs\\Libs\\TabletLib\\SliderButton")
		slider:SetScript("OnEnter", tooltip:GetScript("OnEnter"))
		slider:SetScript("OnLeave", tooltip:GetScript("OnLeave"))
		slider.tablet = tooltip
		slider:SetScript("OnValueChanged", function(this)
			local max = this.tablet.scrollChild:GetHeight() - this.tablet:GetHeight()
			
			local val = this:GetValue() * max
			
			if math.abs(this.tablet.scrollFrame:GetVerticalScroll() - val) < 1 then
				return
			end
			
			this.tablet.scrollFrame:SetVerticalScroll(val)
		end)
		local sliderArrowTop = CreateFrame("Frame", nil, tooltip)
		sliderArrowTop:SetPoint("TOPRIGHT", tooltip, "TOPRIGHT", -5, -5)
		sliderArrowTop:SetWidth(16)
		sliderArrowTop:SetHeight(16)
		sliderArrowTop.bg = sliderArrowTop:CreateTexture()
		sliderArrowTop.bg:SetAllPoints()
		sliderArrowTop.bg:SetTexture("Interface\\AddOns\\nibRealUI\\Libs\\Libs\\TabletLib\\SliderArrow")
		tooltip.sliderArrowTop = sliderArrowTop
		local sliderArrowBottom = CreateFrame("Frame", nil, tooltip)
		sliderArrowBottom:SetPoint("BOTTOMRIGHT", tooltip, "BOTTOMRIGHT", -5, 5)
		sliderArrowBottom:SetWidth(16)
		sliderArrowBottom:SetHeight(16)
		sliderArrowBottom.bg = sliderArrowBottom:CreateTexture()
		sliderArrowBottom.bg:SetAllPoints()
		sliderArrowBottom.bg:SetTexture("Interface\\AddOns\\nibRealUI\\Libs\\Libs\\TabletLib\\SliderArrow")
		sliderArrowBottom.bg:SetTexCoord(0, 1, 1, 0)
		tooltip.sliderArrowBottom = sliderArrowBottom
		
		NewLine(tooltip)

		function tooltip:SetOwner(o)
			self:Hide(o)
			self.owner = o
		end
		tooltip.SetOwner = wrap(tooltip.SetOwner, "tooltip:SetOwner")

		function tooltip:IsOwned(o)
			return self.owner == o
		end
		tooltip.IsOwned = wrap(tooltip.IsOwned, "tooltip:IsOwned")

		function tooltip:ClearLines(hide)
			CleanCategoryPool(self)
			for i = 1, self.numLines do
				local button = self.buttons[i]
				local check = button.check
				if not button.clicked or hide then
					button:Hide()
				end
				check.shown = false
				check:SetAlpha(0)
			end
			self.numLines = 0
		end
		tooltip.ClearLines = wrap(tooltip.ClearLines, "tooltip:ClearLines")

		function tooltip:NumLines()
			return self.numLines
		end

		local lastWidth
		local old_tooltip_Hide = tooltip.Hide
		tooltip.__Hide = old_tooltip_Hide
		function tooltip:Hide(newOwner)
			if self == tooltip or newOwner == nil then
				old_tooltip_Hide(self)
			end
			self:ClearLines(true)
			self.owner = nil
			self.lastWidth = nil
			self.tmpHidden = nil
		end
		tooltip.Hide = wrap(tooltip.Hide, "tooltip:Hide")

		local old_tooltip_Show = tooltip.Show
		tooltip.__Show = old_tooltip_Show
		function tooltip:Show(tabletData)
			if not((not InCombatLockdown()) or RealUI.InfoLineICTips) then return end
			if self.owner == nil or self.notInUse then
				return
			end
			if not self.tmpHidden then
				old_tooltip_Show(self)
			end
			
			testString = self.buttons[1].col1
			
			local maxWidth = tabletData and tabletData.width or self:GetWidth() - 22
			local hasWrap = false
			local numColumns
			
			local height = 22
			self:SetWidth(maxWidth + 22)
			
			for i = 1, self.numLines do
				local button = self.buttons[i]
				local col1 = button.col1
				local col2 = button.col2
				local check = button.check
				button:SetWidth(maxWidth)
				button:SetHeight(col2 and math.max(col1:GetHeight(), col2:GetHeight()) or col1:GetHeight())
				height = height + button:GetHeight() + 2
				if i == 1 then
					button:SetPoint("TOPLEFT", self.scrollChild, "TOPLEFT", 5, -5)
				else
					button:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, -2)
				end
				if button.clicked then
					check:SetPoint("TOPLEFT", button, "TOPLEFT", button.indentation * self.fontSizePercent + (check.width - check:GetWidth()) / 2 + 1, -1)
				else
					check:SetPoint("TOPLEFT", button, "TOPLEFT", button.indentation * self.fontSizePercent + (check.width - check:GetWidth()) / 2, 0)
				end
				button:Show()
			end
			self.scrollFrame:SetFrameLevel(11)
			self.scrollChild:SetWidth(maxWidth)
			self.scrollChild:SetHeight(height)
			local maxHeight = GetTooltipHeight(self)
			if height > maxHeight then
				height = maxHeight
				self:SetWidth(maxWidth + 42)
				self.slider:Show()
				self.sliderArrowTop:Show()
				self.sliderArrowBottom:Show()
			else
				if self.slider then self.slider:Hide() end
				if self.sliderArrowTop then self.sliderArrowTop:Hide() end
				if self.sliderArrowBottom then self.sliderArrowBottom:Hide() end
			end
			self:SetHeight(height)
			self.scrollFrame:SetScrollChild(self.scrollChild)
			local val = self.scrollFrame:GetVerticalScroll()
			local max = self.scrollChild:GetHeight() - self:GetHeight()
			if val > max then
				val = max
			end
			if val < 0 then
				val = 0
			end
			self.scrollFrame:SetVerticalScroll(val)
			if val == 0 or max == 0 then
				self.slider:SetValue(0)
			else
				self.slider:SetValue(val/max)
			end
		end
		tooltip.Show = wrap(tooltip.Show, "tooltip:Show")
		
		function tooltip:AddLine(info)
			local category = info.category.superCategory
			local maxWidth = category.tabletData.width
			local text = info.blank and "\n" or info.text
			local id = info.id
			local func = info.func
			local checked = info.checked
			local isRadio = info.isRadio
			local checkTexture = info.checkTexture
			local isLine = info.isLine
			local fontSizePercent = self.fontSizePercent
			if not info.font then
				info.font = GameTooltipText
			end
			if not info.size then
				info.size = select(2,info.font:GetFont())
			end
			local catStart = false
			local columns = category and category.columns or 1
			local x_total = 0
			local x1, x2
			if category then
				for i = 1, category.columns do
					x_total = x_total + category['x' .. i]
				end
				x1, x2 = category.x1, category.x2
			else
				x1, x2 = 0, 0
			end

			self.numLines = self.numLines + 1
			NewLine(self)
			local num = self.numLines

			local button = self.buttons[num]
			button:Show()
			button.col1:Show()
			button.indentation = info.indentation
			local col1 = button.col1
			local check = button.check
			do -- if columns >= 1 then
				col1:SetWidth(0)
				col1:SetFontObject(info.font)
				local font,_,flags = info.font:GetFont()
				col1:SetFont(font, info.size * fontSizePercent, flags)
				col1:SetText(text)
				col1:SetJustifyH(info.justify)
				col1:Show()
				
				if info.textR and info.textG and info.textB then
					col1:SetTextColor(info.textR, info.textG, info.textB)
				else
					col1:SetTextColor(1, 0.823529, 0)
				end
				if columns < 2 then
					local i = 2
					while true do
						local col = button['col' .. i]
						if col then
							button['col' .. i] = delstring(col)
						else
							break
						end
						i = i + 1
					end
				else
					local i = 2
					while true do
						local col = button['col' .. i]
						if not col then
							button['col' .. i] = newstring(button)
							col = button['col' .. i]
						end
						col:SetFontObject(info['font' .. i])
						col:SetText(info['text' .. i])
						col:Show()
						local r,g,b = info['text' .. i .. 'R']
						if r then
							g = info['text' .. i .. 'G']
							if g then
								b = info['text' .. i .. 'B']
							end
						end
						if b then
							col:SetTextColor(r, g, b)
						else
							col:SetTextColor(1, 0.823529, 0)
						end
						local a,_,b = info.font2:GetFont()
						col:SetFont(a, info['size' .. i] * fontSizePercent, b)
						col:SetJustifyH(info['justify' .. i])
						if columns == i then
							if i == 2 then
								col:SetPoint("TOPLEFT", col1, "TOPRIGHT", 40 * fontSizePercent, 0)
								col:SetPoint("TOPRIGHT", button, "TOPRIGHT", -5, 0)
							else
								local col2 = button.col2
								col2:ClearAllPoints()
								col2:SetPoint("TOPLEFT", col1, "TOPRIGHT", (20 - info.indentation) * fontSizePercent, 0)
							end
							i = i + 1
							while true do
								local col = button['col' .. i]
								if col then
									button['col' .. i] = delstring(col)
								else
									break
								end
								i = i + 1
							end
							break
						end
						i = i + 1
					end
				end
			end
			
			check:SetWidth(info.size * fontSizePercent)
			check:SetHeight(info.size * fontSizePercent)
			check.width = info.size * fontSizePercent
			if info.hasCheck then
				check.shown = true
				check:Show()
				if isRadio then
					check:SetTexture(info.checkIcon or "Interface\\Buttons\\UI-RadioButton")
					if info.checked then
						check:SetAlpha(1)
						check:SetTexCoord(0.25, 0.5, 0, 1)
					else
						check:SetAlpha(self.transparency)
						check:SetTexCoord(0, 0.25, 0, 1)
					end	
					check:SetVertexColor(1, 1, 1)
				else
					if info.checkIcon then
						check:SetTexture(info.checkIcon)
						check:SetTexCoord(info.checkCoordLeft, info.checkCoordRight, info.checkCoordTop, info.checkCoordBottom)
						check:SetVertexColor(info.checkColorR, info.checkColorG, info.checkColorB)
					else
						check:SetTexture("Interface\\Buttons\\UI-CheckBox-Check")
						check:SetWidth(info.size * fontSizePercent * 1)
						check:SetHeight(info.size * fontSizePercent * 1)
						check.width = info.size * fontSizePercent * 1
						check:SetTexCoord(0, 1, 0, 1)
						check:SetVertexColor(1, 1, 1)
					end
					check:SetAlpha(info.checked and 1 or 0)
				end
				col1:SetPoint("TOPLEFT", check, "TOPLEFT", check.width, 0)
			else
				col1:SetPoint("TOPLEFT", check, "TOPLEFT")
			end
			local col2 = button.col2
			if columns == 1 then
				col1:SetWidth(maxWidth)
			elseif columns == 2 then
				if info.wrap then
					col1:SetWidth(maxWidth - col2:GetWidth() - 40 * fontSizePercent)
					col2:SetWidth(0)
				elseif info.wrap2 then
					col1:SetWidth(0)
					col2:SetWidth(maxWidth - col1:GetWidth() - 40 * fontSizePercent)
				else
					col1:SetWidth(0)
					col2:SetWidth(0)
				end
				col2:ClearAllPoints()
				col2:SetPoint("TOPRIGHT", button, "TOPRIGHT", 0, 0)
				if not info.text2 then
					col1:SetJustifyH(info.justify or "LEFT")
				end
			else
				col1:SetWidth(x1 - info.checkWidth)
				col2:SetWidth(x2)
				local num = (category.tabletData.width - x_total) / (columns - 1)
				col2:SetPoint("TOPLEFT", col1, "TOPRIGHT", num - info.indentation * fontSizePercent, 0)
				local last = col2
				for i = 3, category.columns do
					local col = button['col' .. i]
					col:SetWidth(category['x' .. i])
					col:SetPoint("TOPLEFT", last, "TOPRIGHT", num, 0)
					last = col
				end
			end
			button.func = nil
			button.onEnterFunc = nil
			button.onLeaveFunc = nil
			button:SetFrameLevel(12)  -- hack suggested on forum. Added 06/17/2007. (hC)
			if not self.locked or IsAltKeyDown() then
				local func = info.func
				if func then
					if type(func) == "string" then
						if type(info.arg1) ~= "table" then
							Tablet:error("Cannot call method " .. info.func .. " on a non-table")
						end
						func = info.arg1[func]
						if type(func) ~= "function" then
							Tablet:error("Method " .. info.func .. " nonexistant")
						end
					else
						if type(func) ~= "function" then
							Tablet:error("func must be a function or method")
						end
					end
					button.func = func
					local i = 1
					while true do
						local k = 'arg' .. i
						if button[k] ~= nil then
							button[k] = nil
						else
							break
						end
						i = i + 1
					end
					i = 1
					while true do
						local k = 'arg' .. i
						local v = info[k]
						if v == nil then
							break
						end
						button[k] = v
						i = i + 1
					end
					local onEnterFunc = info.onEnterFunc
					if onEnterFunc then
						if type(onEnterFunc) == "string" then
							if type(info.onEnterArg1) ~= "table" then
								Tablet:error("Cannot call method " .. info.onEnterFunc .. " on a non-table")
							end
							onEventFunc = info.onEnterArg1[onEnterFunc]
							if type(onEnterFunc) ~= "function" then
								Tablet:error("Method " .. info.onEnterFunc .. " nonexistant")
							end
						else
							if type(onEnterFunc) ~= "function" then
								Tablet:error("func must be a function or method")
							end
						end
						button.onEnterFunc = onEnterFunc
						local i = 1
						while true do
							local k = 'onEnterArg' .. i
							if button[k] ~= nil then
								button[k] = nil
							else
								break
							end
							i = i + 1
						end
						i = 1
						while true do
							local k = 'onEnterArg' .. i
							local v = info[k]
							if v == nil then
								break
							end
							button[k] = v
							i = i + 1
						end
					end
					local onLeaveFunc = info.onLeaveFunc
					if onLeaveFunc then
						if type(onLeaveFunc) == "string" then
							if type(info.onLeaveArg1) ~= "table" then
								Tablet:error("Cannot call method " .. info.onLeaveFunc .. " on a non-table")
							end
							onLeaveFunc = info.onLeaveArg1[onLeaveFunc]
							if type(onLeaveFunc) ~= "function" then
								Tablet:error("Method " .. info.onLeaveFunc .. " nonexistant")
							end
						else
							if type(onLeaveFunc) ~= "function" then
								Tablet:error("func must be a function or method")
							end
						end
						button.onLeaveFunc = onLeaveFunc
						local i = 1
						while true do
							local k = 'onLeaveArg' .. i
							if button[k] ~= nil then
								button[k] = nil
							else
								break
							end
							i = i + 1
						end
						i = 1
						while true do
							local k = 'onLeaveArg' .. i
							local v = info[k]
							if v == nil then
								break
							end
							button[k] = v
							i = i + 1
						end
					end
					button.self = self
					button:SetScript("OnMouseUp", button_OnMouseUp)
					button:SetScript("OnMouseDown", button_OnMouseDown)
					button:RegisterForDrag("LeftButton")
					button:SetScript("OnDragStart", button_OnDragStart)
					button:SetScript("OnDragStop", button_OnDragStop)
					button:SetScript("OnClick", button_OnClick)
					if button.clicked then
						button:SetButtonState("PUSHED")
					end
					button:EnableMouse(true)
				else
					button:SetScript("OnMouseDown", nil)
					button:SetScript("OnMouseUp", nil)
					button:RegisterForDrag()
					button:SetScript("OnDragStart", nil)
					button:SetScript("OnDragStop", nil)
					button:SetScript("OnClick", nil)
					button:EnableMouse(false)
				end
			else
				button:SetScript("OnMouseDown", nil)
				button:SetScript("OnMouseUp", nil)
				button:RegisterForDrag()
				button:SetScript("OnDragStart", nil)
				button:SetScript("OnDragStop", nil)
				button:SetScript("OnClick", nil)
				button:EnableMouse(false)
			end
		end
		tooltip.AddLine = wrap(tooltip.AddLine, "tooltip:AddLine")

		function tooltip:SetFontSizePercent(percent)
			local data, detachedData = self.data, self.detachedData
			if detachedData and detachedData.detached then
				data = detachedData
			end
			local lastSize = self.fontSizePercent
			percent = tonumber(percent) or 1
			if percent < 0.25 then
				percent = 0.25
			elseif percent > 4 then
				percent = 4
			end
			self.fontSizePercent = percent
			if data then
				data.fontSizePercent = percent
			end
			local ratio = self.fontSizePercent / lastSize
			for i = 1, self.numLines do
				local button = self.buttons[i]
				local j = 1
				while true do
					local col = button['col' .. j]
					if not col then
						break
					end
					local font, size, flags = col:GetFont()
					col:SetFont(font, size * ratio, flags)
					j = j + 1
				end
				local check = button.check
				check.width = check.width * ratio
				check:SetWidth(check:GetWidth() * ratio)
				check:SetHeight(check:GetHeight() * ratio)
			end
			self:SetWidth((self:GetWidth() - 51) * ratio + 51)
			self:SetHeight((self:GetHeight() - 51) * ratio + 51)
			if self:IsShown() and self.children then
				self:children()
				self:Show()
			end
		end
		tooltip.SetFontSizePercent = wrap(tooltip.SetFontSizePercent, "tooltip:SetFontSizePercent")

		function tooltip:GetFontSizePercent()
			return self.fontSizePercent
		end

		function tooltip:SetTransparency(alpha)
			local data, detachedData = self.data, self.detachedData
			if detachedData and detachedData.detached then
				data = detachedData
			end
			self.transparency = alpha
			if data then
				data.transparency = alpha ~= 0.75 and alpha or nil
			end
			self:SetBackdropColor(self.r or 0, self.g or 0, self.b or 0, alpha)
			self:SetBackdropBorderColor(0, 0, 0, alpha)
			self.slider:SetBackdropColor(self.r or 0, self.g or 0, self.b or 0, alpha)
			self.slider:SetBackdropBorderColor(0, 0, 0, alpha)
		end
		tooltip.SetTransparency = wrap(tooltip.SetTransparency, "tooltip:SetTransparency")

		function tooltip:GetTransparency()
			return self.transparency
		end

		function tooltip:SetColor(r, g, b)
			local data, detachedData = self.data, self.detachedData
			if detachedData and detachedData.detached then
				data = detachedData
			end
			self.r = r
			self.g = g
			self.b = b
			if data then
				data.r = r ~= 0 and r or nil
				data.g = g ~= 0 and g or nil
				data.b = b ~= 0 and b or nil
			end
			self:SetBackdropColor(r or 0, g or 0, b or 0, self.transparency)
			self:SetBackdropBorderColor(0, 0, 0, self.transparency)
		end
		tooltip.SetColor = wrap(tooltip.SetColor, "tooltip:SetColor")

		function tooltip:GetColor()
			return self.r, self.g, self.b
		end

		function tooltip:Scroll(down)
			local val
			local max = self.scrollChild:GetHeight() - self:GetHeight()
			if down then
				if IsShiftKeyDown() then
					val = max
				else
					val = self.scrollFrame:GetVerticalScroll() + 36
					if val > max then
						val = max
					end
				end
			else
				if IsShiftKeyDown() then
					val = 0
				else
					val = self.scrollFrame:GetVerticalScroll() - 36
					if val < 0 then
						val = 0
					end
				end
			end
			self.scrollFrame:SetVerticalScroll(val)
			if max > 0 then
				self.slider:SetValue(val/max)
			end
		end
		tooltip.Scroll = wrap(tooltip.Scroll, "tooltip:Scroll")

		function tooltip.Detach(tooltip)
			local owner = tooltip.owner
			tooltip:Hide()
			if not tooltip.detachedData then
				self:error("You cannot detach if detachedData is not present")
			end
			tooltip.detachedData.detached = true
			local detached = AcquireDetachedFrame(self, tooltip.registration, tooltip.data, tooltip.detachedData)

			detached.menu, tooltip.menu = tooltip.menu, nil
			detached.runChildren = tooltip.runChildren
			detached.children = tooltip.children
			detached.minWidth = tooltip.minWidth
			tooltip.runChildren = nil
			tooltip.children = nil
			tooltip.minWidth = nil
			detached:SetOwner(owner)
			detached:children()
			detached:Show()
		end
		tooltip.Detach = wrap(tooltip.Detach, "tooltip:Detach")

	end

	tooltip.registration = registration
	registration.tooltip = tooltip
	return tooltip
end
AcquireFrame = wrap(AcquireFrame, "AcquireFrame")

function ReleaseDetachedFrame(self, data, detachedData)
	if not detachedData then
		detachedData = data
	end
	for _, detached in ipairs(detachedTooltips) do
		if detached.detachedData == detachedData then
			detached.notInUse = true
			detached:Hide()
			detached.registration.tooltip = nil
			detached.registration = nil
			detached.detachedData = nil
		end
	end
end
ReleaseDetachedFrame = wrap(ReleaseDetachedFrame, "ReleaseDetachedFrame")

local StartCheckingAlt, StopCheckingAlt
do
	local frame
	function StartCheckingAlt(func)
		if not frame then
			frame = CreateFrame("Frame")
			frame:SetScript("OnEvent", function(this, _, modifier)
				if modifier == "LALT" or modifier == "RALT" then
					this.func()
				end
			end)
		end
		frame:RegisterEvent("MODIFIER_STATE_CHANGED")
		frame.func = func
	end
	StartCheckingAlt = wrap(StartCheckingAlt, "StartCheckingAlt")
	function StopCheckingAlt()
		if frame then
			frame:UnregisterEvent("MODIFIER_STATE_CHANGED")
		end
	end
	StopCheckingAlt = wrap(StopCheckingAlt, "StopCheckingAlt")
end

function AcquireDetachedFrame(self, registration, data, detachedData)
	if not detachedData then
		detachedData = data
	end
	for _, detached in ipairs(detachedTooltips) do
		if detached.notInUse then
			detached.data = data
			detached.detachedData = detachedData
			detached.notInUse = nil
			local fontSizePercent = detachedData.fontSizePercent or 1
			local transparency = detachedData.transparency or 0.8
			local r = detachedData.r or 0
			local g = detachedData.g or 0
			local b = detachedData.b or 0
			detached:SetFontSizePercent(fontSizePercent)
			detached:SetTransparency(transparency)
			detached:SetColor(r, g, b)
			detached:ClearAllPoints()
			detached:SetWidth(0)
			detached:SetHeight(0)
			if not registration.strata then
				detached:SetFrameStrata("BACKGROUND")
			end
			if not registration.frameLevel then
				detached:SetFrameLevel(10)
				for _,frame in fake_ipairs(detached:GetChildren()) do
					frame:SetFrameLevel(12)
				end
			end
			detached:SetParent(registration.parent or GetMainFrame())
			if registration.strata then
				detached:SetFrameStrata(registration.strata)
			end
			if registration.frameLevel then
				detached:SetFrameLevel(registration.frameLevel)
				for _,frame in fake_ipairs(detached:GetChildren()) do
					frame:SetFrameLevel(registration.frameLevel+2)
				end
			end
			detached.height_ = nil
			if registration.positionFunc then
				registration.positionFunc(detached)
				RecalculateTabletHeight(detached)
			else
				detached:SetPoint(detachedData.anchor or "CENTER", GetMainFrame(), detachedData.anchor or "CENTER", detachedData.offsetx or 0, detachedData.offsety or 0)
			end
			detached.registration = registration
			registration.tooltip = detached
			if registration.movable == false then
				detached:RegisterForDrag()
			else
				detached:RegisterForDrag("LeftButton")
			end
			return detached
		end
	end

	StartCheckingAlt(function()
		for _, detached in ipairs(detachedTooltips) do
			if detached:IsShown() and detached.locked then
				detached:EnableMouse(IsAltKeyDown())
				detached:children()
				if detached.moving then
					local a1 = arg1
					arg1 = "LeftButton"
					if type(detached:GetScript("OnMouseUp")) == "function" then
						detached:GetScript("OnMouseUp")(detached, arg1)
					end
					arg1 = a1
				end
			end
		end
	end)
	if not tooltip then
		AcquireFrame(self, {})
	end
	local detached = CreateFrame("Frame", "Tablet20DetachedFrame" .. (#detachedTooltips + 1), GetMainFrame())
	detachedTooltips[#detachedTooltips+1] = detached
	detached.notInUse = true
	detached:EnableMouse(not data.locked)
	detached:EnableMouseWheel(true)
	detached:SetMovable(true)
	detached:SetPoint(data.anchor or "CENTER", GetMainFrame(), data.anchor or "CENTER", data.offsetx or 0, data.offsety or 0)

	detached.numLines = 0
	detached.owner = nil
	detached.fontSizePercent = 1
	detached.maxLines = 0
	detached.buttons = {}
	detached.transparency = 0.8
	detached.r = 0
	detached.g = 0
	detached.b = 0
	detached:SetFrameStrata(registration and registration.strata or "BACKGROUND")
	detached:SetBackdrop(tmp.a(
		'bgFile', "Interface\\Buttons\\WHITE8X8",
		'edgeFile', "Interface\\Tooltips\\UI-Tooltip-Border",
		'tile', true,
		'tileSize', 16,
		'edgeSize', 16,
		'insets', tmp.b(
			'left', 5,
			'right', 5,
			'top', 5,
			'bottom', 5
		)
	))
	detached.locked = detachedData.locked
	detached:EnableMouse(not detached.locked)

	local width = GetScreenWidth()
	local height = GetScreenHeight()
	if registration and registration.movable == false then
		detached:RegisterForDrag()
	else
		detached:RegisterForDrag("LeftButton")
	end
	detached:SetScript("OnDragStart", function(this)
		detached:StartMoving()
		detached.moving = true
	end)

	detached:SetScript("OnDragStop", function(this)
		detached:StopMovingOrSizing()
		detached.moving = nil
		detached:SetClampedToScreen(1)
		detached:SetClampedToScreen(nil)
		local anchor
		local offsetx
		local offsety
		if detached:GetTop() + detached:GetBottom() < height then
			anchor = "BOTTOM"
			offsety = detached:GetBottom()
			if offsety < 0 then
				offsety = 0
			end
			if offsety < MainMenuBar:GetTop() and MainMenuBar:IsVisible() then
				offsety = MainMenuBar:GetTop()
			end
			local top = 0
			if FuBar then
				for i = 1, FuBar:GetNumPanels() do
					local panel = FuBar:GetPanel(i)
					if panel:GetAttachPoint() == "BOTTOM" then
						if panel.frame:GetTop() > top then
							top = panel.frame:GetTop()
							break
						end
					end
				end
			end
			if offsety < top then
				offsety = top
			end
		else
			anchor = "TOP"
			offsety = detached:GetTop() - height
			if offsety > 0 then
				offsety = 0
			end
			local bottom = GetScreenHeight()
			if FuBar then
				for i = 1, FuBar:GetNumPanels() do
					local panel = FuBar:GetPanel(i)
					if panel:GetAttachPoint() == "TOP" then
						if panel.frame:GetBottom() < bottom then
							bottom = panel.frame:GetBottom()
							break
						end
					end
				end
			end
			bottom = bottom - GetScreenHeight()
			if offsety > bottom then
				offsety = bottom
			end
		end
		if detached:GetLeft() + detached:GetRight() < width * 2 / 3 then
			anchor = anchor .. "LEFT"
			offsetx = detached:GetLeft()
			if offsetx < 0 then
				offsetx = 0
			end
		elseif detached:GetLeft() + detached:GetRight() < width * 4 / 3 then
			if anchor == "" then
				anchor = "CENTER"
			end
			offsetx = (detached:GetLeft() + detached:GetRight() - GetScreenWidth()) / 2
		else
			anchor = anchor .. "RIGHT"
			offsetx = detached:GetRight() - width
			if offsetx > 0 then
				offsetx = 0
			end
		end
		detached:ClearAllPoints()
		detached:SetPoint(anchor, GetMainFrame(), anchor, offsetx, offsety)
		local t = detached.detachedData
		if t.anchor ~= anchor or math.abs(t.offsetx - offsetx) > 8 or math.abs(t.offsety - offsety) > 8 then
			detached.preventClick = GetTime() + 0.05
		end
		t.anchor = anchor
		t.offsetx = offsetx
		t.offsety = offsety
		detached:Show()
	end)

	local scrollFrame = CreateFrame("ScrollFrame", detached:GetName() .. "ScrollFrame", detached)
	local scrollChild = CreateFrame("Frame", detached:GetName() .. "ScrollChild", scrollFrame)
	scrollFrame:SetFrameLevel(11)
	scrollFrame:SetScrollChild(scrollChild)
	scrollChild.tablet = detached
	detached.scrollFrame = scrollFrame
	detached.scrollChild = scrollChild
	scrollFrame:SetPoint("TOPLEFT", 5, -5)
	scrollFrame:SetPoint("BOTTOMRIGHT", -5, 5)
	scrollChild:SetWidth(1)
	scrollChild:SetHeight(1)
	local slider = CreateFrame("Slider", detached:GetName() .. "Slider", scrollFrame)
	detached.slider = slider
	slider:SetOrientation("VERTICAL")
	slider:SetMinMaxValues(0, 1)
	slider:SetValueStep(0.001)
	slider:SetValue(0)
	slider:SetWidth(8)
	slider:SetPoint("TOPRIGHT", 0, 0)
	slider:SetPoint("BOTTOMRIGHT", 0, 0)
	slider:SetBackdrop(new(
		'bgFile', "Interface\\Buttons\\UI-SliderBar-Background",
		'edgeFile', "Interface\\Buttons\\UI-SliderBar-Border",
		'tile', true,
		'edgeSize', 8,
		'tileSize', 8,
		'insets', new(
			'left', 3,
			'right', 3,
			'top', 3,
			'bottom', 3
		)
	))
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Vertical")
	slider:SetScript("OnEnter", detached:GetScript("OnEnter"))
	slider:SetScript("OnLeave", detached:GetScript("OnLeave"))
	slider.tablet = detached
	slider:SetScript("OnValueChanged", Tablet20FrameSlider:GetScript("OnValueChanged"))

	NewLine(detached)

	detached:SetScript("OnMouseWheel", function(this, arg1)
		detached:Scroll(arg1 < 0)
	end)

	detached.SetTransparency = tooltip.SetTransparency
	detached.GetTransparency = tooltip.GetTransparency
	detached.SetColor = tooltip.SetColor
	detached.GetColor = tooltip.GetColor
	detached.SetFontSizePercent = tooltip.SetFontSizePercent
	detached.GetFontSizePercent = tooltip.GetFontSizePercent
	detached.SetOwner = tooltip.SetOwner
	detached.IsOwned = tooltip.IsOwned
	detached.ClearLines = tooltip.ClearLines
	detached.NumLines = tooltip.NumLines
	detached.__Hide = detached.Hide
	detached.__Show = detached.Show
	detached.Hide = tooltip.Hide
	detached.Show = tooltip.Show
	local old_IsShown = detached.IsShown
	function detached:IsShown()
		if self.tmpHidden then
			return true
		else
			return old_IsShown(self)
		end
	end
	detached.AddLine = tooltip.AddLine
	detached.Scroll = tooltip.Scroll
	function detached:IsLocked()
		return self.locked
	end
	function detached:Lock()
		self:EnableMouse(self.locked)
		self.locked = not self.locked
		if self.detachedData then
			self.detachedData.locked = self.locked or nil
		end
		self:children()
	end

	function detached.Attach(detached)
		if not detached then
			self:error("Detached tooltip not given.")
		end
		if not detached.AddLine then
			self:error("detached argument not a Tooltip.")
		end
		if not detached.owner then
			self:error("Detached tooltip has no owner.")
		end
		if detached.notInUse then
			self:error("Detached tooltip not in use.")
		end
		detached.menu = nil
		detached.detachedData.detached = nil
		detached:SetOwner(nil)
		detached.notInUse = true
	end

	return AcquireDetachedFrame(self, registration, data, detachedData)
end
AcquireDetachedFrame = wrap(AcquireDetachedFrame, "AcquireDetachedFrame")

function Tablet:Close(parent)
	if not parent then
		if tooltip and tooltip:IsShown() then
			tooltip:Hide()
			tooltip.registration.tooltip = nil
			tooltip.registration = nil
			tooltip.enteredFrame = false
		end
		return
	else
		self:argCheck(parent, 2, "table", "string")
	end
	local info = self.registry[parent]
	if not info then
		self:error("You cannot close a tablet with an unregistered parent frame.")
	end
	local data = info.data
	local detachedData = info.detachedData
	if detachedData and detachedData.detached then
		ReleaseDetachedFrame(self, data, detachedData)
	elseif tooltip and tooltip.data == data then
		tooltip:Hide()
		if tooltip.registration then
			tooltip.registration.tooltip = nil
			tooltip.registration = nil
		end
	end
	if tooltip then tooltip.enteredFrame = false end
end
Tablet.Close = wrap(Tablet.Close, "Tablet:Close")

local function frame_children(self)
	if not self.preventRefresh and self:GetParent() and self:GetParent():IsShown() then
		Tablet.currentFrame = self
		Tablet.currentTabletData = TabletData:new(self)
		Tablet.currentTabletData.minWidth = self.minWidth
		self:ClearLines()
		if self.runChildren then
			self.runChildren()
		end
		Tablet.currentTabletData:Display(Tablet.currentFrame)
		self:Show(Tablet.currentTabletData)
		Tablet.currentTabletData:del()
		Tablet.currentTabletData = nil
		Tablet.currentFrame = nil
	end
end
frame_children = wrap(frame_children, "frame_children")

function Tablet:Open(fakeParent, parent)
	if not((not InCombatLockdown()) or RealUI.InfoLineICTips) then return end
	self:argCheck(fakeParent, 2, "table", "string")
	self:argCheck(parent, 3, "nil", "table", "string")
	if not parent then
		parent = fakeParent
	end
	
	local info = self.registry[parent]
	if not info then
		self:error("You cannot open a tablet with an unregistered parent frame.")
	end
	local detachedData = info.detachedData
	if detachedData then
		for _, detached in ipairs(detachedTooltips) do
			if not detached.notInUse and detached.detachedData == detachedData then
				return
			end
		end
	end
	local data = info.data
	local children = info.children
	if not children then
		return
	end
	local frame = AcquireFrame(self, info, data, detachedData)
	frame.clickable = info.clickable
	frame.menu = info.menu
	frame.runChildren = info.children
	frame.minWidth = info.minWidth
	if not frame.children or not frame.childrenVer or frame.childrenVer < MINOR_VERSION then
		frame.childrenVer = MINOR_VERSION
		frame.children = frame_children
	end
	frame:SetOwner(fakeParent)
	frame:children()
	local point = info.point
	local relativePoint = info.relativePoint
	if type(point) == "function" then
		local b
		point, b = point(fakeParent)
		if b then
			relativePoint = b
		end
	end
	if type(relativePoint) == "function" then
		relativePoint = relativePoint(fakeParent)
	end
	if not point then
		point = "CENTER"
	end
	if not relativePoint then
		relativePoint = point
	end
	frame:ClearAllPoints()
	if type(parent) ~= "string" then
		frame:SetPoint(point, fakeParent, relativePoint)
	end
	local offsetx = 0
	local offsety = 0
	frame:SetClampedToScreen(1)
	frame:SetClampedToScreen(nil)
	if frame:GetBottom() and frame:GetLeft() then
		if frame:GetRight() > GetScreenWidth() then
			offsetx = frame:GetRight() - GetScreenWidth()
		elseif frame:GetLeft() < 0 then
			offsetx = -frame:GetLeft()
		end
		local ratio = GetScreenWidth() / GetScreenHeight()
		if ratio >= 2.4 and frame:GetRight() > GetScreenWidth() / 2 and frame:GetLeft() < GetScreenWidth() / 2 then
			if frame:GetCenter() < GetScreenWidth() / 2 then
				offsetx = frame:GetRight() - GetScreenWidth() / 2
			else
				offsetx = frame:GetLeft() - GetScreenWidth() / 2
			end
		end
		if frame:GetBottom() < 0 then
			offsety = frame:GetBottom()
		elseif frame:GetTop() and frame:GetTop() > GetScreenHeight() then
			offsety = frame:GetTop() - GetScreenHeight()
		end
		if MainMenuBar:IsVisible() and frame:GetBottom() < MainMenuBar:GetTop() and offsety < frame:GetBottom() - MainMenuBar:GetTop() then
			offsety = frame:GetBottom() - MainMenuBar:GetTop()
		end

		if FuBar then
			local top = 0
			if FuBar then
				for i = 1, FuBar:GetNumPanels() do
					local panel = FuBar:GetPanel(i)
					if panel:GetAttachPoint() == "BOTTOM" then
						if panel.frame:GetTop() and panel.frame:GetTop() > top then
							top = panel.frame:GetTop()
							break
						end
					end
				end
			end
			if frame:GetBottom() < top and offsety < frame:GetBottom() - top then
				offsety = frame:GetBottom() - top
			end
			local bottom = GetScreenHeight()
			if FuBar then
				for i = 1, FuBar:GetNumPanels() do
					local panel = FuBar:GetPanel(i)
					if panel:GetAttachPoint() == "TOP" then
						if panel.frame:GetBottom() and panel.frame:GetBottom() < bottom then
							bottom = panel.frame:GetBottom()
							break
						end
					end
				end
			end
			if frame:GetTop() > bottom and offsety < frame:GetTop() - bottom then
				offsety = frame:GetTop() - bottom
			end
		end
	end
	if type(fakeParent) ~= "string" then
		frame:SetPoint(point, fakeParent, relativePoint, -offsetx, -offsety - 1)
	end

	if detachedData and (info.cantAttach or detachedData.detached) and frame == tooltip then
		detachedData.detached = false
		frame:Detach()
	end
	if (not detachedData or not detachedData.detached) and GetMouseFocus() == fakeParent then
		self.tooltip.enteredFrame = true
	end
	overFrame = type(fakeParent) == "table" and MouseIsOver(fakeParent) and fakeParent
end
Tablet.Open = wrap(Tablet.Open, "Tablet:Open")

function Tablet:Register(parent, ...)
	self:argCheck(parent, 2, "table", "string")
	if self.registry[parent] then
		self:Unregister(parent)
	end
	local info
	local k1 = ...
	if type(k1) == "table" and k1[0] then
		if type(self.registry[k1]) ~= "table" then
			self:error("Other parent not registered")
		end
		info = copy(self.registry[k1])
		local v1 = select(2, ...)
		if type(v1) == "function" then
			info.point = v1
			info.relativePoint = nil
		end
	else
		info = new(...)
	end
	self.registry[parent] = info
	info.data = info.data or info.detachedData or new()
	info.detachedData = info.detachedData or info.data
	local data = info.data
	local detachedData = info.detachedData
	if not self.onceRegistered[parent] and type(parent) == "table" and type(parent.SetScript) == "function" and not info.dontHook then
		local script = parent:GetScript("OnEnter")
		parent:SetScript("OnEnter", function(...)
			if script then
				script(...)
			end
			if self.registry[parent] then
				if (not data or not detachedData.detached) then
					self:Open(parent)
				end
			end
		end)
		if parent:HasScript("OnMouseDown") then
			local script = parent:GetScript("OnMouseDown")
			parent:SetScript("OnMouseDown", function(...)
				if script then
					script(...)
				end
				if self.registry[parent] and self.registry[parent].tooltip and self.registry[parent].tooltip == self.tooltip then
					self.tooltip:Hide()
				end
			end)
		end
		if parent:HasScript("OnMouseWheel") then
			local script = parent:GetScript("OnMouseWheel")
			parent:SetScript("OnMouseWheel", function(...)
				if script then
					script(...)
				end
				if self.registry[parent] and self.registry[parent].tooltip then
					if tonumber(arg1) ~= nil then
						self.registry[parent].tooltip:Scroll(arg1 < 0)
					end
				end
			end)
		end
	end
	self.onceRegistered[parent] = true
	if GetMouseFocus() == parent then
		self:Open(parent)
	end
end
Tablet.Register = wrap(Tablet.Register, "Tablet:Register")

function Tablet:Unregister(parent)
	self:argCheck(parent, 2, "table", "string")
	if not self.registry[parent] then
		self:error("You cannot unregister a parent frame if it has not been registered already.")
	end
	self.registry[parent] = nil
end
Tablet.Unregister = wrap(Tablet.Unregister, "Tablet:Unregister")

function Tablet:IsRegistered(parent)
	self:argCheck(parent, 2, "table", "string")
	return self.registry[parent] and true
end
Tablet.IsRegistered = wrap(Tablet.IsRegistered, "Tablet:IsRegistered")

local _id = 0
local addedCategory
local depth = 0
local categoryPool = {}
function CleanCategoryPool(self)
	for k,v in pairs(categoryPool) do
		del(v)
		categoryPool[k] = nil
	end
	_id = 0
end
CleanCategoryPool = wrap(CleanCategoryPool, "CleanCategoryPool")

function Tablet:AddCategory(...)
	if not self.currentFrame then
		self:error("You must add categories in within a registration.")
	end
	local info = new(...)
	local cat = self.currentTabletData:AddCategory(info)
	info = del(info)
	return cat
end
Tablet.AddCategory = wrap(Tablet.AddCategory, "Tablet:AddCategory")

function Tablet:SetHint(text)
	if not self.currentFrame then
		self:error("You must set hint within a registration.")
	end
	self.currentTabletData:SetHint(text)
end
Tablet.SetHint = wrap(Tablet.SetHint, "Tablet:SetHint")

function Tablet:SetTitle(text)
	if not self.currentFrame then
		self:error("You must set title within a registration.")
	end
	self.currentTabletData:SetTitle(text)
end
Tablet.SetTitle = wrap(Tablet.SetTitle, "Tablet:SetTitle")

function Tablet:SetTitleColor(r, g, b)
	if not self.currentFrame then
		self:error("You must set title color within a registration.")
	end
	self:argCheck(r, 2, "number")
	self:argCheck(g, 3, "number")
	self:argCheck(b, 4, "number")
	self.currentTabletData:SetTitleColor(r, g, b)
end
Tablet.SetTitleColor = wrap(Tablet.SetTitleColor, "Tablet:SetTitleColor")

function Tablet:GetNormalFontSize()
	return normalSize
end
Tablet.GetNormalFontSize = wrap(Tablet.GetNormalFontSize, "Tablet:GetNormalFontSize")

function Tablet:GetHeaderFontSize()
	return headerSize
end
Tablet.GetHeaderFontSize = wrap(Tablet.GetHeaderFontSize, "Tablet:GetHeaderFontSize")

function Tablet:GetNormalFontObject()
	return GameTooltipText
end
Tablet.GetNormalFontObject = wrap(Tablet.GetNormalFontObject, "Tablet:GetNormalFontObject")

function Tablet:GetHeaderFontObject()
	return GameTooltipHeaderText
end
Tablet.GetHeaderFontObject = wrap(Tablet.GetHeaderFontObject, "Tablet:GetHeaderFontObject")

function Tablet:SetFontSizePercent(parent, percent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		if info.tooltip then
			info.tooltip:SetFontSizePercent(percent)
		else
			local data = info.data
			local detachedData = info.detachedData
			if detachedData.detached then
				detachedData.fontSizePercent = percent
			else
				data.fontSizePercent = percent
			end
		end
	elseif type(parent) == "table" then
		parent.fontSizePercent = percent
	else
		self:error("You cannot change font size with an unregistered parent frame.")
	end
end
Tablet.SetFontSizePercent = wrap(Tablet.SetFontSizePercent, "Tablet:SetFontSizePercent")

function Tablet:GetFontSizePercent(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		local data = info.data
		local detachedData = info.detachedData
		if detachedData.detached then
			return detachedData.fontSizePercent or 1
		else
			return data.fontSizePercent or 1
		end
	elseif type(parent) == "table" then
		return parent.fontSizePercent or 1
	else
		self:error("You cannot check font size with an unregistered parent frame.")
	end
end
Tablet.GetFontSizePercent = wrap(Tablet.GetFontSizePercent, "Tablet:GetFontSizePercent")

function Tablet:SetTransparency(parent, percent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		if info.tooltip then
			info.tooltip:SetTransparency(percent)
		else
			local data = info.data
			local detachedData = info.detachedData
			if detachedData.detached then
				detachedData.transparency = percent
			elseif data then
				data.transparency = percent
			end
		end
	elseif type(parent) == "table" then
		parent.transparency = percent
	else
		self:error("You cannot change transparency with an unregistered parent frame.")
	end
end
Tablet.SetTransparency = wrap(Tablet.SetTransparency, "Tablet:SetTransparency")

function Tablet:GetTransparency(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		local data = info.data
		local detachedData = info.detachedData
		if detachedData.detached then
			return detachedData.transparency or 0.8
		else
			return data.transparency or 0.8
		end
	elseif type(parent) == "table" then
		return parent.transparency or 0.8
	else
		self:error("You cannot get transparency with an unregistered parent frame.")
	end
end
Tablet.GetTransparency = wrap(Tablet.GetTransparency, "Tablet:GetTransparency")

function Tablet:SetColor(parent, r, g, b)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		if info.tooltip then
			info.tooltip:SetColor(r, g, b)
		else
			local data = info.data
			local detachedData = info.detachedData
			if detachedData.detached then
				detachedData.r = r
				detachedData.g = g
				detachedData.b = b
			else
				data.r = r
				data.g = g
				data.b = b
			end
		end
	elseif type(parent) == "table" then
		parent.r = r
		parent.g = g
		parent.b = b
	else
		self:error("You cannot change color with an unregistered parent frame.")
	end
end
Tablet.SetColor = wrap(Tablet.SetColor, "Tablet:SetColor")

function Tablet:GetColor(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if info then
		local data = info.data
		local detachedData = info.detachedData
		if detachedData.detached then
			return detachedData.r or 0, detachedData.g or 0, detachedData.b or 0
		else
			return data.r or 0, data.g or 0, data.b or 0
		end
	elseif type(parent) == "table" then
		return parent.r or 0, parent.g or 0, parent.b or 0
	else
		self:error("You must provide a registered parent frame to check color")
	end
end
Tablet.GetColor = wrap(Tablet.GetColor, "Tablet:GetColor")

function Tablet:Detach(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if not info then
		self:error("You cannot detach tablet with an unregistered parent frame.")
	end
	if not info.detachedData then
		self:error("You cannot detach tablet without a data field.")
	end
	if info.tooltip and info.tooltip == tooltip and tooltip.registration then
		tooltip:Detach()
	else
		info.detachedData.detached = true
		local detached = AcquireDetachedFrame(self, info, info.data, info.detachedData)
		
		detached.menu = info.menu
		detached.runChildren = info.children
		detached.minWidth = info.minWidth
		if not detached.children or not detached.childrenVer or detached.childrenVer < MINOR_VERSION then
			detached.childrenVer = MINOR_VERSION
			detached.children = frame_children
		end
		detached:SetOwner(parent)
		detached:children()
	end
end
Tablet.Detach = wrap(Tablet.Detach, "Tablet:Detach")

function Tablet:Attach(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if not info then
		self:error("You cannot detach tablet with an unregistered parent frame.")
	end
	if not info.detachedData then
		self:error("You cannot attach tablet without a data field.")
	end
	if info.tooltip and info.tooltip ~= tooltip then
		info.tooltip:Attach()
	else
		info.detachedData.detached = false
	end
end
Tablet.Attach = wrap(Tablet.Attach, "Tablet:Attach")

function Tablet:IsAttached(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if not info then
		self:error("You cannot check tablet with an unregistered parent frame.")
	end
	return not info.detachedData or not info.detachedData.detached
end
Tablet.IsAttached = wrap(Tablet.IsAttached, "Tablet:IsAttached")

function Tablet:Refresh(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if not info then
		self:error("You cannot refresh tablet with an unregistered parent frame.")
	end
	local tt = info.tooltip
	if tt and not tt.preventRefresh and tt:IsShown() then
		tt.updating = true
		tt:children()
		tt.updating = false
	end
end
Tablet.Refresh = wrap(Tablet.Refresh, "Tablet:Refresh")

function Tablet:IsLocked(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if not info then
		self:error("You cannot check tablet with an unregistered parent frame.")
	end
	return info.detachedData and info.detachedData.locked
end
Tablet.IsLocked = wrap(Tablet.IsLocked, "Tablet:IsLocked")

function Tablet:ToggleLocked(parent)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if not info then
		self:error("You cannot lock tablet with an unregistered parent frame.")
	end
	if info.tooltip and info.tooltip ~= tooltip then
		info.tooltip:Lock()
	elseif info.detachedData then
		info.detachedData.locked = info.detachedData.locked
	end
end
Tablet.ToggleLocked = wrap(Tablet.ToggleLocked, "Tablet:ToggleLocked")

function Tablet:UpdateDetachedData(parent, detachedData)
	self:argCheck(parent, 2, "table", "string")
	local info = self.registry[parent]
	if not info then
		self:error("You cannot update tablet with an unregistered parent frame.")
	end
	self:argCheck(detachedData, 3, "table")
	if info.data == info.detachedData then
		info.data = detachedData
	end
	info.detachedData = detachedData
	if info.detachedData.detached then
		self:Detach(parent)
	elseif info.tooltip and info.tooltip.owner then
		self:Attach(parent)
	end
end
Tablet.UpdateDetachedData = wrap(Tablet.UpdateDetachedData, "Tablet:UpdateDetachedData")

if DEBUG then
	function Tablet:ListProfileInfo()
		local duration, times, memories = GetProfileInfo()
		if not duration or not time or not memories then
			self:error("Problems")
		end
		local t = new()
		for method in pairs(memories) do
			t[#t+1] = method
		end
		table.sort(t, function(alpha, bravo)
			if memories[alpha] ~= memories[bravo] then
				return memories[alpha] < memories[bravo]
			elseif times[alpha] ~= times[bravo] then
				return times[alpha] < times[bravo]
			else
				return alpha < bravo
			end
		end)
		local memory = 0
		local time = 0
		for _,method in ipairs(t) do
			DEFAULT_CHAT_FRAME:AddMessage(format("%s || %.3f s || %.3f%% || %d KiB", method, times[method], times[method] / duration * 100, memories[method]))
			memory = memory + memories[method]
			time = time + times[method]
		end
		DEFAULT_CHAT_FRAME:AddMessage(format("%s || %.3f s || %.3f%% || %d KiB", "Total", time, time / duration * 100, memory))
		del(t)
	end
	SLASH_TABLET1 = "/tablet"
	SLASH_TABLET2 = "/tabletlib"
	SlashCmdList["TABLET"] = function(msg)
		AceLibrary(MAJOR_VERSION):ListProfileInfo()
	end
end

local function activate(self, oldLib, oldDeactivate)
	Tablet = self
	if oldLib then
		self.registry = oldLib.registry
		self.onceRegistered = oldLib.onceRegistered
		self.tooltip = oldLib.tooltip
		self.currentFrame = oldLib.currentFrame
		self.currentTabletData = oldLib.currentTabletData
	else
		self.registry = {}
		self.onceRegistered = {}
	end
	
	tooltip = self.tooltip
	
	if oldDeactivate then
		oldDeactivate(oldLib)
	end
end

local function deactivate(self)
	StopCheckingAlt()
end

AceLibrary:Register(Tablet, MAJOR_VERSION, MINOR_VERSION, activate, deactivate)
