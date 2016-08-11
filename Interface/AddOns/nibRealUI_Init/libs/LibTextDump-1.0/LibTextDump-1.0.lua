-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _G = _G

-- Functions
local error = _G.error
local type = _G.type
local date = _G.date

-- Libraries
local table = _G.table


-----------------------------------------------------------------------
-- Library namespace.
-----------------------------------------------------------------------
local LibStub = _G.LibStub
local MAJOR = "RealUI_LibTextDump-1.0"

_G.assert(LibStub, MAJOR .. " requires LibStub")

local MINOR = 2 -- Should be manually increased
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR) -- luacheck: ignore

if not lib then
	return
end -- No upgrade needed


-----------------------------------------------------------------------
-- Migrations.
-----------------------------------------------------------------------
lib.prototype = lib.prototype or {}
lib.metatable = lib.metatable or { __index = lib.prototype }

lib.buffers = lib.buffers or {}
lib.frames = lib.frames or {}

lib.num_frames = lib.num_frames or 0


-----------------------------------------------------------------------
-- Constants and upvalues.
-----------------------------------------------------------------------
local prototype = lib.prototype
local metatable = lib.metatable

local buffers = lib.buffers
local frames = lib.frames

local METHOD_USAGE_FORMAT = MAJOR .. ":%s() - %s."

local DEFAULT_FRAME_WIDTH = 750
local DEFAULT_FRAME_HEIGHT = 600

-----------------------------------------------------------------------
-- Helper functions.
-----------------------------------------------------------------------
local debug = false
local function debugPrint(frame, ...)
	if debug and frame:IsShown() then
		_G.print(...)
	end
end
local function round(number, places)
	local mult = 10 ^ (places or 0)
	return _G.floor(number * mult + 0.5) / mult
end

local function NewInstance(width, height)
	lib.num_frames = lib.num_frames + 1

	local frameName = ("%s_CopyFrame%d"):format(MAJOR, lib.num_frames)
	local copyFrame = _G.CreateFrame("Frame", frameName, _G.UIParent, "ButtonFrameTemplate")
	_G.ButtonFrameTemplate_HidePortrait(copyFrame)
	_G.ButtonFrameTemplate_HideAttic(copyFrame)
	_G.ButtonFrameTemplate_HideButtonBar(copyFrame)
	copyFrame:SetSize(width, height)
	copyFrame:SetPoint("CENTER", _G.UIParent, "CENTER")
	copyFrame:SetFrameStrata("DIALOG")
	copyFrame:EnableMouse(true)
	copyFrame:SetMovable(true)
	copyFrame:SetToplevel(true)

	copyFrame:Hide()


	local titleBackground = _G[frameName.."TitleBg"]
	local dragFrame = _G.CreateFrame("Frame", nil, copyFrame)
	dragFrame:SetPoint("TOPLEFT", titleBackground, 16, 0)
	dragFrame:SetPoint("BOTTOMRIGHT", titleBackground)
	dragFrame:EnableMouse(true)

	dragFrame:SetScript("OnMouseDown", function(self, button)
		copyFrame:StartMoving()
	end)

	dragFrame:SetScript("OnMouseUp", function(self, button)
		copyFrame:StopMovingOrSizing()
	end)


	local scrollArea = _G.CreateFrame("ScrollFrame", ("%sScroll"):format(frameName), copyFrame, "FauxScrollFrameTemplate")
	scrollArea:SetPoint("TOPLEFT", copyFrame.Inset, 5, -5)
	scrollArea:SetPoint("BOTTOMRIGHT", copyFrame.Inset, -27, 6)

	function scrollArea:Update(start, wrappedLines, maxDisplayLines, allWrappedLines, lineHeight)
		--print("Scroll:Update", start, lineHeight, maxDisplayLines)
		local i, linesToDisplay = start - 1, 0
		repeat
			i = i + 1
			linesToDisplay = linesToDisplay + (wrappedLines[i] or 0)
			--print("Line:", i, linesToDisplay, wrappedLines[i])
		until linesToDisplay > maxDisplayLines or not wrappedLines[i]
		local stop = i - 1
		--print("repeat", start, stop, lineHeight, maxDisplayLines)

		self:Show()
		local name = self:GetName()
		local scrollBar = _G[name .. "ScrollBar"]
		scrollBar:SetStepsPerPage(linesToDisplay - 1)

		if allWrappedLines and lineHeight then
			--[[ This block should only be run when the buffer is changed because posible variations in 
			linesToDisplay from scroll to scroll will affect the height of the scroll frame. This will then 
			result in inconsistent scrolling behaviour. ]]
			local scrollChildFrame = _G[name .. "ScrollChildFrame"]

			local scrollFrameHeight = (allWrappedLines - linesToDisplay) * lineHeight
			local scrollChildHeight = allWrappedLines * lineHeight
			if ( scrollFrameHeight < 0 ) then
				scrollFrameHeight = 0
			end
			self.height = scrollFrameHeight
			scrollChildFrame:Show()
			scrollChildFrame:SetHeight(scrollChildHeight)

			scrollBar:SetMinMaxValues(0, scrollFrameHeight) 
			scrollBar:SetValueStep(lineHeight)
		end
		
		-- Arrow button handling
		local scrollUpButton = _G[name .. "ScrollBarScrollUpButton"]
		local scrollDownButton = _G[name .. "ScrollBarScrollDownButton"]

		if ( scrollBar:GetValue() == 0 ) then
			scrollUpButton:Disable()
		else
			scrollUpButton:Enable()
		end
		if ((scrollBar:GetValue() - self.height) == 0) then
			scrollDownButton:Disable()
		else
			scrollDownButton:Enable()
		end
		return start, stop
	end

	copyFrame.scrollArea = scrollArea


	local editBox = _G.CreateFrame("EditBox", ("%sScrollChildFrame"):format(frameName), copyFrame)
	editBox:SetMultiLine(true)
	editBox:SetMaxLetters(0)
	editBox:EnableMouse(true)
	editBox:SetAutoFocus(false)
	editBox:SetFontObject("SystemFont_Small")
	editBox:SetAllPoints(scrollArea)

	editBox:SetScript("OnEscapePressed", function()
		_G.HideUIPanel(copyFrame)
	end)

	copyFrame.edit_box = editBox

	local lineDummy = copyFrame:CreateFontString()
	lineDummy:SetJustifyH("LEFT")
	lineDummy:SetNonSpaceWrap(true)
	lineDummy:SetFontObject("SystemFont_Small")
	lineDummy:SetPoint("TOPLEFT", 5, 100)
	lineDummy:SetPoint("BOTTOMRIGHT", copyFrame, "TOPRIGHT", -28, 0)
	lineDummy:Hide()
	copyFrame.lineDummy = lineDummy


	local highlightButton = _G.CreateFrame("Button", nil, copyFrame)
	highlightButton:SetSize(16, 16)
	highlightButton:SetPoint("TOPLEFT", titleBackground)

	highlightButton:SetScript("OnMouseUp", function(self, button)
		self.texture:ClearAllPoints()
		self.texture:SetAllPoints(self)

		editBox:HighlightText(0)
		editBox:SetFocus()

		copyFrame:RegisterEvent("PLAYER_LOGOUT")
	end)

	highlightButton:SetScript("OnMouseDown", function(self, button)
		self.texture:ClearAllPoints()
		self.texture:SetPoint("RIGHT", self, "RIGHT", 1, -1)
	end)

	highlightButton:SetScript("OnEnter", function(self)
		self.texture:SetVertexColor(0.75, 0.75, 0.75)
	end)

	highlightButton:SetScript("OnLeave", function(self)
		self.texture:SetVertexColor(1, 1, 1)
	end)


	local highlightIcon = highlightButton:CreateTexture()
	highlightIcon:SetAllPoints()
	highlightIcon:SetTexture([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]])
	highlightButton.texture = highlightIcon


	local instance = _G.setmetatable({}, metatable)
	frames[instance] = copyFrame
	buffers[instance] = {
		wrappedLines = {}
	}

	return instance
end


-----------------------------------------------------------------------
-- Library methods.
-----------------------------------------------------------------------
--- Create a new dump frame.
-- @param frameTitle The title text of the frame.
-- @param width (optional) The width of the frame.
-- @param height (optional) The height of the frame.
-- @param save (optional) A function that will be called when the copy button is clicked.
-- @return A handle for the dump frame.
function lib:New(frameTitle, width, height, save)
	local titleType = type(frameTitle)

	if titleType ~= "nil" and titleType ~= "string" then
		error(METHOD_USAGE_FORMAT:format("New", "frame title must be nil or a string."), 2)
	end
	local widthType = type(width)

	if widthType ~= "nil" and widthType ~= "number" then
		error(METHOD_USAGE_FORMAT:format("New", "frame width must be nil or a number."))
	end
	local heightType = type(height)

	if heightType ~= "nil" and heightType ~= "number" then
		error(METHOD_USAGE_FORMAT:format("New", "frame height must be nil or a number."))
	end
	local saveType = type(save)

	if saveType ~= "nil" and saveType ~= "function" then
		error(METHOD_USAGE_FORMAT:format("New", "save must be nil or a function."))
	end

	local instance = NewInstance(width or DEFAULT_FRAME_WIDTH, height or DEFAULT_FRAME_HEIGHT)
	local frame = frames[instance]
	frame.TitleText:SetText(frameTitle)

	if save then
		frame:SetScript("OnEvent", function(event, ...)
			buffers[instance].wrappedLines = nil
			save(buffers[instance])
		end)
	end

	return instance
end


-----------------------------------------------------------------------
-- Instance methods.
-----------------------------------------------------------------------
function prototype:AddLine(text, dateFormat)
	self:InsertLine(#buffers[self] + 1, text, dateFormat)

	if frames[self]:IsVisible() then
		frames[self]:UpdateText()
	end
end


function prototype:Clear()
	local wrappedLines = buffers[self].wrappedLines
	table.wipe(buffers[self])
	buffers[self].wrappedLines = wrappedLines
end


function prototype:Display(separator)
	local display_text = self:String(separator)

	if display_text == "" then
		error(METHOD_USAGE_FORMAT:format("Display", "buffer must be non-empty"), 2)
	end
	local frame = frames[self]
	frame.edit_box:SetText(display_text)
	frame.edit_box:SetCursorPosition(0)
	frame:Show()
end


function prototype:InsertLine(position, text, dateFormat)
	if type(position) ~= "number" then
		error(METHOD_USAGE_FORMAT:format("InsertLine", "position must be a number."))
	end

	if type(text) ~= "string" or text == "" then
		error(METHOD_USAGE_FORMAT:format("InsertLine", "text must be a non-empty string."), 2)
	end

	if dateFormat and dateFormat ~= "" then
		table.insert(buffers[self], position, ("[%s] %s"):format(date(dateFormat), text))
	else
		table.insert(buffers[self], position, text)
	end
end


function prototype:Lines()
	return #buffers[self]
end


function prototype:String(separator)
	local sep_type = type(separator)

	if sep_type ~= "nil" and sep_type ~= "string" then
		error(METHOD_USAGE_FORMAT:format("String", "separator must be nil or a string."), 2)
	end

	separator = separator or "\n"
	local buffer, frame = buffers[self], frames[self]
	local lineDummy = frame.lineDummy
	local function UpdateWrappedLines()
		local allWrappedLines = 0
		table.wipe(buffer.wrappedLines)
		for i = 1, #buffer do
			lineDummy:SetText(buffer[i])
			buffer.wrappedLines[i] = lineDummy:GetNumLines()
			allWrappedLines = allWrappedLines + buffer.wrappedLines[i]
		end
		return allWrappedLines
	end

	local _, lineHeight = lineDummy:GetFont()
	local maxDisplayLines = round(frame.edit_box:GetHeight() / lineHeight)
	--print("Line stats", lineDummy:GetStringHeight(), lineHeight, maxDisplayLines)

	local allWrappedLines, offset = UpdateWrappedLines(), 1
	local start, stop = frame.scrollArea:Update(offset, buffer.wrappedLines, maxDisplayLines, allWrappedLines, lineHeight)
	function frame:UpdateText()
		local newWrappedLines = UpdateWrappedLines()
		debugPrint(frame, "UpdateText", newWrappedLines > allWrappedLines)
		if newWrappedLines > allWrappedLines then
			allWrappedLines = newWrappedLines
			start, stop = frame.scrollArea:Update(offset, buffer.wrappedLines, maxDisplayLines, allWrappedLines, lineHeight)
		else
			start, stop = frame.scrollArea:Update(offset, buffer.wrappedLines, maxDisplayLines)
		end

		debugPrint(frame, "Start/Stop", start, stop)
		local text = table.concat(buffer, separator, start, stop)
		frame.edit_box:SetText(text)
	end
	frame.scrollArea:SetScript("OnVerticalScroll", function(scrollArea, value)
		--print("OnVerticalScroll", value)
		local scrollbar = scrollArea.ScrollBar
		local _, scrollMax = scrollbar:GetMinMaxValues()
		--print("Min/Max", scroll_min, scrollMax)
		local scrollPer = round(value / scrollMax, 2)
		offset = round((1 - scrollPer) * 1 + scrollPer * #buffer)

		--print("Current position", value, offset, scrollPer)
		--print("Concat", start, stop)
		frame:UpdateText(UpdateWrappedLines())
	end)

	return table.concat(buffer, separator, start, stop)
end
