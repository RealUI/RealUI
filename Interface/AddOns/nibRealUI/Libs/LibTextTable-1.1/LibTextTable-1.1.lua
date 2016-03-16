-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _G = getfenv(0)


-----------------------------------------------------------------------
-- Library namespace.
-----------------------------------------------------------------------
local LibStub = _G.LibStub
local MAJOR = "LibTextTable-1.1"

_G.assert(LibStub, MAJOR .. " requires LibStub")

local MINOR = 4 -- Should be manually increased
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

if not lib then
	return
end -- No upgrade needed


-----------------------------------------------------------------------
-- Migrations.
-----------------------------------------------------------------------
lib.RowMeta = lib.RowMeta or { __index = {} }
lib.TableMeta = lib.TableMeta or { __index = {} }


-----------------------------------------------------------------------
-- Constants and upvalues.
-----------------------------------------------------------------------
local RowMethods = lib.RowMeta.__index
local TableMethods = lib.TableMeta.__index

local ROW_HEIGHT = 14
local COLUMN_PADDING = 6
local MIN_SIZE = 1e-3 -- Smallest frame size that the layout engine can render


-----------------------------------------------------------------------
-- Row methods.
-----------------------------------------------------------------------
function RowMethods:GetNumElements()
	return self:GetNumRegions() - 1 -- Skip highlight region
end


function RowMethods:GetElements()
	return select(2, self:GetRegions()) -- Skip highlight region
end


-- Returns the row's key and all original element data.
function RowMethods:GetData()
	return self.Key, unpack(self, 1, self:GetParent().Table.NumColumns)
end


-----------------------------------------------------------------------
-- Table methods.
-----------------------------------------------------------------------
do
	-- Clears visible element contents.
	-- @param Count Number of visible elements to clear.
	-- @param ... Row elements.
	local function ClearElements(Count, ...)
		for index = 1, Count do
			local Element = select(index, ...)
			Element:Hide()
			Element:SetText()
		end
	end


	function TableMethods:Clear()
		local rows = self.Rows

		if #rows > 0 then
			if self.View.YScroll then -- Force correct view resize
				self.View.YScroll:SetValue(0)
			end
			self:SetSelection()
			wipe(self.Keys)

			for index = #rows, 1, -1 do -- Remove in reverse so rows don't move mid-loop
				local row = rows[index]
				rows[index] = nil
				self.UnusedRows[row] = true
				row:Hide()
				row.Key = nil
				ClearElements(self.NumColumns, row:GetElements())

				for column = 1, self.NumColumns do -- Remove values
					row[column] = nil
				end
			end
			self:Resize()
			return true
		end
	end
end


do
	local function Column_OnClick(Column)
		PlaySound("igMainMenuOptionCheckBoxOn")
		Column:GetParent().Table:SetSortColumn(Column)
	end


	local function CreateColumn(Header)
		local index = #Header + 1
		local column = CreateFrame("Button", nil, Header)
		column:SetScript("OnClick", Column_OnClick)
		column:SetID(index)
		column:SetFontString(column:CreateFontString(nil, "ARTWORK", Header.Table.HeaderFont))
		column:SetPoint("TOP")
		column:SetPoint("BOTTOM")

		if index == 1 then
			column:SetPoint("LEFT")
		else
			column:SetPoint("LEFT", Header[index - 1], "RIGHT")
		end

		-- Artwork
		local arrow = column:CreateTexture(nil, "OVERLAY")
		column.Arrow = arrow
		arrow:Hide()
		arrow:SetSize(ROW_HEIGHT * 0.5, ROW_HEIGHT * 0.8)
		arrow:SetTexture([[Interface\Buttons\UI-SortArrow]])

		local left = column:CreateTexture(nil, "BACKGROUND")
		left:SetPoint("TOPLEFT")
		left:SetPoint("BOTTOM")
		left:SetWidth(COLUMN_PADDING)
		left:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]])
		left:SetTexCoord(0, 0.078125, 0, 0.75)

		local right = column:CreateTexture(nil, "BACKGROUND")
		right:SetPoint("TOPRIGHT")
		right:SetPoint("BOTTOM")
		right:SetWidth(COLUMN_PADDING)
		right:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]])
		right:SetTexCoord(0.90625, 0.96875, 0, 0.75)

		local middle = column:CreateTexture(nil, "BACKGROUND")
		middle:SetPoint("TOPLEFT", left, "TOPRIGHT")
		middle:SetPoint("BOTTOMRIGHT", right, "BOTTOMLEFT")
		middle:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]])
		middle:SetTexCoord(0.078125, 0.90625, 0, 0.75)

		column:SetHighlightTexture([[Interface\Buttons\UI-Panel-Button-Highlight]], "ADD")
		column:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875)

		local backdrop = column:CreateTexture(nil, "OVERLAY")
		backdrop:Hide()
		backdrop:SetPoint("TOPLEFT", column, "BOTTOMLEFT")
		backdrop:SetPoint("RIGHT")
		backdrop:SetPoint("BOTTOM", Header.Table.Body) -- Expand to bottom of view
		backdrop:SetTexture(0.15, 0.15, 0.15, 0.25)
		backdrop:SetBlendMode("ADD")
		column.Backdrop = backdrop

		Header[index] = column
		return column
	end


	-- Sets this table's header to a list of column labels.
	-- @param ...  Column labels.  Nil clears the column header.
	function TableMethods:SetHeader(...)
		local header = self.Header
		local num_columns = select("#", ...)

		if self.View.XScroll then -- Force correct view resize
			self.View.XScroll:SetValue(0)
		end

		-- Create necessary column buttons
		if #header < num_columns then
			for index = #header + 1, num_columns do
				CreateColumn(header)
			end
		end

		-- Fill out buttons
		for index = 1, num_columns do
			local column = header[index]
			local value = select(index, ...)
			column:SetText(value ~= nil and tostring(value) or nil)
			column:Show()
			column.Width, column.WidthChanged = column:GetTextWidth(), true
		end

		for index = num_columns + 1, #header do -- Hide unused
			local column = header[index]
			column:Hide()
			column:SetText()
			column.Sort = nil
		end

		if not self:Clear() then
			self:Resize() -- Fit to only headers
		end
		self.NumColumns = num_columns
		self:SetSortHandlers() -- None
	end
end


-- Allows or disallows sorting of table columns.
-- Sort handlers can be nil or false to disable sorting, true for simple sorting
-- using the less-than operator, or function values for custom sort order.
-- @param ...  Sort handlers for each column.
-- @see SortSimple for custom sort function behavior.
function TableMethods:SetSortHandlers(...)
	local header = self.Header

	for index = 1, self.NumColumns do
		local column = header[index]
		local handler = select(index, ...)
		column.Sort = handler

		if handler then
			column:Enable()
		else
			column:Disable()
		end
	end
	self:SetSortColumn() -- None
end


-- Selects or clears the column to sort by.
-- @param Column  Column button or column ID to sort by, or nil to stop sorting.
-- @param Inverted  False for normal order, or true for inverted order.  Inversion toggles intelligently if omitted.
function TableMethods:SetSortColumn(column, inverted)
	local header = self.Header

	if tonumber(column) then
		column = header[tonumber(column)]
	end

	if column then
		assert(type(column) == "table", "Invalid colum.")
		assert(column.Sort, "Column must have a sort handler assigned.")
	end

	if header.SortColumn ~= column then
		if header.SortColumn then
			header.SortColumn.Arrow:Hide()
			header.SortColumn.Backdrop:Hide()
		end
		header.SortColumn, header.SortInverted = column, inverted or false

		if column then
			column.Arrow:Show()
			column.Backdrop:Show()
			self:Sort()
		end
	elseif column then -- Selected same sort column
		if inverted == nil then -- Unspecified Flip inverted status
			inverted = not header.SortInverted
		end

		if header.SortInverted ~= inverted then
			header.SortInverted = inverted
			self:Sort()
		end
	end

	if column then
		if header.SortInverted then
			column.Arrow:SetPoint("LEFT", 0, 2)
			column.Arrow:SetTexCoord(0.0625, 0.5, 1, 0)
		else
			column.Arrow:SetPoint("LEFT", 0, -2)
			column.Arrow:SetTexCoord(0.0625, 0.5, 0, 1)
		end
	end
end


do
	-- Default sort handler for columns.
	-- Uses Lua's less-than operator.  Nil values are sorted as empty strings.
	-- @param Val1  Element value for row 1.
	-- @param Val2  Element value for row 2.
	-- @param Row1..Row2  Row tables being compared.
	-- @return True/false if Val1 is less/greater than Val2, or nil if they are equal.
	local function SortSimple(Val1, Val2 --[[, Row1, Row2]])
		if Val1 ~= Val2 then
			return Val1 < Val2
		end
	end


	local Handler, Column, Inverted
	-- Compare function for table.sort that supports inversion and custom sort handlers.
	local function Compare(Row1, Row2)
		local Result

		if Inverted then -- Flip the handler's args
			Result = Handler(Row2[Column], Row1[Column], Row2, Row1)
		else
			Result = Handler(Row1[Column], Row2[Column], Row1, Row2)
		end

		if Result ~= nil then -- Not equal
			return Result
		else -- Equal
			return Row1:GetID() < Row2:GetID() -- Fall back on previous row order
		end
	end


	-- Throttles re-sorts to once per frame.
	local function OnUpdate(Header)
		Header:SetScript("OnUpdate", nil)
		local Rows, View = Header.Table.Rows, Header.Table.View

		if Header.SortColumn and #Rows > 0 then
			Column = Header.SortColumn:GetID()
			Handler, Inverted = Header.SortColumn.Sort, Header.SortInverted

			if Handler == true then
				Handler = SortSimple -- Less-than operator
			end

			for Index = View.Top, min(#Rows, View.Bottom) do
				Rows[Index]:Hide()
			end
			sort(Rows, Compare)

			for Index = View.Top, min(#Rows, View.Bottom) do
				Rows[Index]:Show()
			end

			for Index, Row in ipairs(Rows) do
				Row:SetID(Index)
				Row:SetPoint("TOPLEFT", 0, (1 - Index) * ROW_HEIGHT)
			end
			local Selection = Header.Table:GetSelection()

			if Selection then
				Header.Table:ScrollToRow(Selection)
			end
		end
	end


	-- Schedules rows to be resorted on the next frame.
	function TableMethods:Sort()
		self.Header:SetScript("OnUpdate", OnUpdate)
	end
end


do
	-- Selects a row when it gets clicked.
	local function RowOnClick(Row)
		Row:GetParent().Table:SetSelection(Row)
	end


	-- @return A new row without any elements.
	function TableMethods:CreateRow()
		local Row = CreateFrame("Button", nil, self.Rows)
		Row:SetScript("OnClick", RowOnClick)
		Row:RegisterForClicks("AnyUp")
		Row:SetHeight(ROW_HEIGHT)
		Row:SetPoint("RIGHT", self.Body) -- Expand to right side of view
		Row:SetHighlightTexture([[Interface\FriendsFrame\UI-FriendsFrame-HighlightBar]], "ADD")

		-- Apply row methods
		if not getmetatable(RowMethods) then
			setmetatable(RowMethods, getmetatable(Row))
		end
		setmetatable(Row, lib.RowMeta)
		return Row
	end
end


do
	-- Adds and anchors missing element strings.
	local function RowAddElements(Table, Row)
		local Columns = Table.Header

		for Index = Row:GetNumElements() + 1, Table.NumColumns do
			local Element = Row:CreateFontString(nil, "ARTWORK", Table.ElementFont)
			Element:SetPoint("TOP")
			Element:SetPoint("BOTTOM")
			Element:SetPoint("LEFT", Columns[Index], COLUMN_PADDING, 0)
			Element:SetPoint("RIGHT", Columns[Index], -COLUMN_PADDING, 0)
		end
	end


	local select = select
	-- Sets a row's elements to a set of values.
	-- @param ...  Row element fontstrings.
	local function UpdateElements(Table, Row, ...)
		for Index = 1, Table.NumColumns do
			local Value = Row[Index]
			local Element = select(Index, ...)
			Element:SetText(Value)
			Element:Show()
			Element:SetJustifyH(type(Value) == "number" and "RIGHT" or "LEFT")

			local Column = Table.Header[Index]
			local Width = Element:GetStringWidth()

			if Column.Width < Width then
				Column.Width, Column.WidthChanged = Width, true
			end
		end

		for Index = Table.NumColumns + 1, select("#", ...) do
			select(Index, ...):Hide()
		end
	end


	-- Adds a populated row to this table.
	-- Numeric values become right-aligned in their columns.
	-- @param Key  Optional unique key to identify this row while sorting or selecting.
	-- @param ...  String or number values to set row elements to.
	-- @return Row object that was added.
	function TableMethods:AddRow(Key, ...)
		assert(Key == nil or self.Keys[Key] == nil, "Index key must be unique.")
		local Row, Index = next(self.UnusedRows), #self.Rows + 1

		if Row then
			self.UnusedRows[Row] = nil
			Row:Show()
		else
			Row = self:CreateRow()
		end
		self.Rows[Index] = Row

		if Key ~= nil then
			self.Keys[Key] = Row
			Row.Key = Key
		end

		for Index = 1, self.NumColumns do
			Row[Index] = select(Index, ...)
		end

		Row:SetID(Index)
		Row:SetPoint("TOPLEFT", 0, (1 - Index) * ROW_HEIGHT)
		RowAddElements(self, Row)
		-- Note: Row must be shown for GetStringWidth to return correct results.
		UpdateElements(self, Row, Row:GetElements())

		if Index < self.View.Top or self.View.Bottom < Index then
			Row:Hide()
		end

		self:Resize()
		self:Sort()
		return Row
	end
end


do
	-- Resizes all columns to fit table headers and element values.
	local function OnUpdate(Rows)
		Rows:SetScript("OnUpdate", nil)
		local Header, TotalWidth = Rows.Table.Header, 0

		for Index = 1, Rows.Table.NumColumns do
			local Column = Header[Index]
			local Width = Column.Width + COLUMN_PADDING * 2

			if Column.WidthChanged then
				Column.WidthChanged = nil
				Column:SetWidth(Width)
			end
			TotalWidth = TotalWidth + Width
		end
		local Height = #Rows * ROW_HEIGHT
		Rows:SetSize(TotalWidth > MIN_SIZE and TotalWidth or MIN_SIZE, Height > MIN_SIZE and Height or MIN_SIZE)
	end


	-- Requests that the table be resized on the next frame.
	function TableMethods:Resize()
		self.Rows:SetScript("OnUpdate", OnUpdate)
	end
end


-- Updates which rows are visible in the table.
function TableMethods:UpdateView()
	local View, Rows = self.View, self.Rows
	local Offset = View:GetVerticalScroll()
	local TopOld, BottomOld = View.Top, View.Bottom
	-- Note: Header takes up one row of space at the top.
	View.Top = floor(Offset / ROW_HEIGHT) + 1
	View.Bottom = ceil((Offset + View:GetHeight()) / ROW_HEIGHT) - 1
	for Index = TopOld, min(#Rows, BottomOld, View.Top - 1) do
		Rows[Index]:Hide()
	end

	for Index = View.Top, min(#Rows, View.Bottom) do
		Rows[Index]:Show()
		-- Note: Fixes issue where buttons sometimes appear as if anchored to bottom of scrollframe.
		Rows[Index]:SetHeight(ROW_HEIGHT)
	end

	for Index = max(TopOld, View.Bottom + 1), min(#Rows, BottomOld) do
		Rows[Index]:Hide()
	end
end


-- @return The selected table row.  Use Row:GetData to get its key and element values.
-- @see RowMethods:GetData
function TableMethods:GetSelection()
	return self.Selection
end


-- Sets the selection to a given row.
-- @param Row  A table row, or nil to clear the selection.
-- @return True if selection changed.
function TableMethods:SetSelection(Row)
	assert(Row == nil or Row:GetParent() == self.Rows, "Row must be an existing table row.")

	if Row ~= self.Selection then
		if self.Selection then -- Remove old selection
			self.Selection:UnlockHighlight()
		end
		self.Selection = Row

		if Row then
			Row:LockHighlight()
			self:ScrollToRow(Row)
		end

		if self.OnSelect then
			if Row then
				self:OnSelect(Row:GetData())
			else
				self:OnSelect()
			end
		end
		return true
	end
end


-- Sets the selection to the given row index.
-- @param Index  Row number to select.  Out of range indices do nothing.
function TableMethods:SetSelectionByIndex(Index)
	local Row = self.Rows[Index]
	if Row and Index >= 1 then
		return self:SetSelection(Row)
	end
end


-- Sets the selection to a row indexed by the given key.
-- @param Key  Unique key used to add the row with AddRow.  Unknown keys will clear the selection.
function TableMethods:SetSelectionByKey(Key)
	return self:SetSelection(self.Keys[Key])
end


-- Vertically scrolls the table to include Row if it isn't already visible.
-- @param Row  The table row to scroll to.
function TableMethods:ScrollToRow(Row)
	assert(Row:GetParent() == self.Rows, "Row must be an existing table row.")
	local Scroll = self.View:GetVerticalScroll()
	local Top = (Row:GetID() - 1) * ROW_HEIGHT
	local Bottom = Top + ROW_HEIGHT * 2 - self.View:GetHeight()

	if Bottom > Scroll then
		self.View.YScroll:SetValue(Bottom)
	end

	if Top < Scroll then
		self.View.YScroll:SetValue(Top)
	end
end


do
	local ViewOnSizeChanged, RowsOnSizeChanged
	do
		local PADDING = 2 -- Keeps the Body frame from causing scrolling

		-- Adjusts row widths and table height to fill the scrollframe without changing the scrollable area.
		local function Resize(Table, RowsX, RowsY, ViewX, ViewY)
			RowsY = RowsY + ROW_HEIGHT -- Allow room for header
			local Width, Height = (RowsX > ViewX and RowsX or ViewX) - PADDING, (RowsY > ViewY and RowsY or ViewY) - PADDING
			Table.Body:SetSize(Width > MIN_SIZE and Width or MIN_SIZE, Height > MIN_SIZE and Height or MIN_SIZE)
		end


		-- Resize when viewing area changes.
		function ViewOnSizeChanged(View, ViewX, ViewY)
			local RowsX, RowsY = View.Table.Rows:GetSize()
			Resize(View.Table, RowsX, RowsY, ViewX, ViewY)
			View.Table:UpdateView()
		end


		-- Resize when table data size changes.
		function RowsOnSizeChanged(Rows, RowsX, RowsY)
			Resize(Rows.Table, RowsX, RowsY, Rows.Table.View:GetSize())
		end
	end


	-- Handler for scrollwheel and scroll button increment/decrement.
	local function ScrollHandler(Scroll, Delta)
		Scroll:SetValue(Scroll:GetValue() + Delta * Scroll:GetLength() / 2)
	end


	-- Scrolls the view vertically, or horizontally if shift is held.
	local function OnMouseWheel(Table, Delta)
		local View = Table.View
		local IsHorizontal = View:GetHorizontalScrollRange() > 0
			and (View:GetVerticalScrollRange() == 0 or IsShiftKeyDown())
		ScrollHandler(View[IsHorizontal and "XScroll" or "YScroll"], -Delta)
	end


	-- Updates visible rows when the table scrolls vertically.
	local function ViewOnVerticalScroll(View)
		View.Table:UpdateView()
	end

	local ViewOnScrollRangeChanged
	do
		-- Syncs view and scroll buttons when scrollbars move.
		local function ScrollOnValueChanged(Scroll, Position)
			Scroll.SetScroll(Scroll:GetParent(), Position) -- ScrollFrame:SetHorizontalScroll/SetVerticalScroll
			local Min, Max = Scroll:GetMinMaxValues()
			Scroll.Dec[Position == Min and "Disable" or "Enable"](Scroll.Dec)
			Scroll.Inc[Position == Max and "Disable" or "Enable"](Scroll.Inc)
		end


		-- Scrolls a bar when its button is clicked.
		local function ScrollButtonOnClick(Button)
			PlaySound("UChatScrollButton")
			ScrollHandler(Button:GetParent(), Button.Delta)
		end


		-- @return New scrollbar with scroll buttons.
		local function CreateScrollBar(View, IsHorizontal)
			local Scroll = CreateFrame("Slider", nil, View)
			Scroll:Hide()
			Scroll:SetThumbTexture([[Interface\Buttons\UI-ScrollBar-Knob]])
			Scroll.GetLength = Scroll[IsHorizontal and "GetWidth" or "GetHeight"]
			Scroll.SetScroll = View[IsHorizontal and "SetHorizontalScroll" or "SetVerticalScroll"]
			Scroll:SetScript("OnValueChanged", ScrollOnValueChanged)

			Scroll.Dec = CreateFrame("Button", nil, Scroll, "UIPanelScrollUpButtonTemplate")
			Scroll.Dec:SetScript("OnClick", ScrollButtonOnClick)
			Scroll.Dec.Delta = -1
			Scroll.Inc = CreateFrame("Button", nil, Scroll, "UIPanelScrollDownButtonTemplate")
			Scroll.Inc:SetScript("OnClick", ScrollButtonOnClick)
			Scroll.Inc.Delta = 1

			local Thumb = Scroll:GetThumbTexture()
			Thumb:SetSize(Scroll.Dec:GetSize())
			Thumb:SetTexCoord(0.25, 0.75, 0.25, 0.75) -- Remove transparent border

			local Background = Scroll:CreateTexture(nil, "BACKGROUND")
			Background:SetTexture(0, 0, 0, 0.5)
			Background:SetAllPoints()

			return Scroll
		end


		-- Rotates all regions 90 degrees CCW.
		-- @param ...  Texture regions to rotate.
		local function RotateTextures(...)
			for Index = 1, select("#", ...) do
				select(Index, ...):SetTexCoord(0.75, 0.25, 0.25, 0.25, 0.75, 0.75, 0.25, 0.75)
			end
		end


		-- Adds and adjusts scrollbars when necessary.
		function ViewOnScrollRangeChanged(View, XRange, YRange)
			local XScroll, YScroll = View.XScroll, View.YScroll
			View.Table:EnableMouseWheel(XRange > 0 or YRange > 0) -- Enable only if scrollable

			-- Horizontal scrolling
			if XRange > 0 then
				if not XScroll then -- Create scrollbar
					XScroll = CreateScrollBar(View, true)
					View.XScroll = XScroll
					XScroll.Dec:SetPoint("BOTTOMLEFT", View.Table)
					XScroll:SetPoint("BOTTOMLEFT", XScroll.Dec, "BOTTOMRIGHT")
					XScroll:SetPoint("TOPRIGHT", XScroll.Inc, "TOPLEFT")
					XScroll:SetOrientation("HORIZONTAL")
					RotateTextures(XScroll.Dec:GetRegions())
					RotateTextures(XScroll.Inc:GetRegions())
				end

				if not XScroll:IsShown() then -- Show and position scrollbar
					XScroll:Show()
					View:SetPoint("BOTTOM", XScroll, "TOP")
				end
				-- Setup scrollbar's range
				XScroll.Inc:SetPoint("BOTTOMRIGHT", View.Table, YRange > 0 and -XScroll.Inc:GetWidth() or 0, 0)
				XScroll:SetMinMaxValues(0, XRange)
				XScroll:SetValue(min(XScroll:GetValue(), XRange))
			elseif XScroll and XScroll:IsShown() then -- Hide scrollbar
				XScroll:SetValue(0) -- Return to origin
				XScroll:Hide()
				View:SetPoint("BOTTOM", View.Table)
			end

			-- Vertical scrolling
			if YRange > 0 then
				if not YScroll then -- Create scrollbar
					YScroll = CreateScrollBar(View, false)
					View.YScroll = YScroll
					YScroll.Dec:SetPoint("TOPRIGHT", View.Table)
					YScroll:SetPoint("TOPRIGHT", YScroll.Dec, "BOTTOMRIGHT")
					YScroll:SetPoint("BOTTOMLEFT", YScroll.Inc, "TOPLEFT")
				end

				if not YScroll:IsShown() then -- Show and position scrollbar
					YScroll:Show()
					View:SetPoint("RIGHT", YScroll, "LEFT")
				end
				-- Setup scrollbar's range
				YScroll.Inc:SetPoint("BOTTOMRIGHT", View.Table, 0, XRange > 0 and YScroll.Inc:GetHeight() or 0)
				YScroll:SetMinMaxValues(0, YRange)
				YScroll:SetValue(min(YScroll:GetValue(), YRange))
			elseif YScroll and YScroll:IsShown() then -- Hide scrollbar
				YScroll:SetValue(0) -- Return to origin
				YScroll:Hide()
				View:SetPoint("RIGHT", View.Table)
			end
			View.Table:UpdateView()
		end
	end

	-----------------------------------------------------------------------
	-- Library methods.
	-----------------------------------------------------------------------
	-- Creates a new text table.
	-- @param Name Name of table frame.
	-- @param Parent Parent of table frame.
	-- @param HeaderFont Optional name of Font object to use for column labels.
	-- @param ElementFont Optional name of Font object to use for element text.
	-- @return New text table frame.
	function lib.New(Name, Parent, HeaderFont, ElementFont)
		local Table = CreateFrame("Frame", Name, Parent)
		if not getmetatable(TableMethods) then
			setmetatable(TableMethods, getmetatable(Table))
		end
		setmetatable(Table, lib.TableMeta)

		local View = CreateFrame("ScrollFrame", nil, Table)
		Table.View = View
		View.Table = Table
		View.Top, View.Bottom = 1, 0
		View:SetPoint("TOPLEFT")
		View:SetPoint("BOTTOM") -- Bottom and right anchors moved independently by scrollbars
		View:SetPoint("RIGHT")
		View:SetScript("OnSizeChanged", ViewOnSizeChanged)
		View:SetScript("OnScrollRangeChanged", ViewOnScrollRangeChanged)
		View:SetScript("OnVerticalScroll", ViewOnVerticalScroll)

		-- Body frame expands to fill the scrollframe
		local Body = CreateFrame("Frame")
		Table.Body = Body
		View:SetScrollChild(Body)

		-- Rows frame expands to the size of table data
		local Rows = CreateFrame("Frame", nil, Body)
		Table.Rows = Rows
		Rows.Table = Table
		Rows:SetPoint("TOPLEFT", 0, -ROW_HEIGHT) -- Leave room for header
		Rows:SetScript("OnSizeChanged", RowsOnSizeChanged)

		local Header = CreateFrame("Frame", nil, Body)
		Table.Header = Header
		Header.Table = Table
		Header:SetPoint("TOP", Table, 0, 1) -- Make sure rows don't show in the crack above the header
		Header:SetPoint("LEFT", Rows)
		Header:SetPoint("RIGHT", Rows)
		Header:SetHeight(ROW_HEIGHT)

		local Background = Header:CreateTexture(nil, "OVERLAY")
		Background:SetTexture(0, 0, 0)
		Background:SetPoint("TOPLEFT")
		Background:SetPoint("BOTTOM")
		Background:SetPoint("RIGHT", Body) -- Expand with view

		Table.Keys = {}
		Table.UnusedRows = {}
		Table.HeaderFont = HeaderFont or "GameFontHighlightSmall"
		Table.ElementFont = ElementFont or "GameFontNormalSmall"

		Table:SetScript("OnMouseWheel", OnMouseWheel)
		Table:EnableMouseWheel(false)
		Table:SetHeader() -- Clear all and resize
		return Table
	end
end
