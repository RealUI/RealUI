-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _G = _G

-- Functions
local error = _G.error
local type = _G.type

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

	local frame_name = ("%s_CopyFrame%d"):format(MAJOR, lib.num_frames)
	local copy_frame = _G.CreateFrame("Frame", frame_name, _G.UIParent, "ButtonFrameTemplate")
	_G.ButtonFrameTemplate_HidePortrait(copy_frame)
	_G.ButtonFrameTemplate_HideAttic(copy_frame)
	_G.ButtonFrameTemplate_HideButtonBar(copy_frame)
	copy_frame:SetSize(width, height)
	copy_frame:SetPoint("CENTER", _G.UIParent, "CENTER")
	copy_frame:SetFrameStrata("DIALOG")
	copy_frame:EnableMouse(true)
	copy_frame:SetMovable(true)
	copy_frame:SetToplevel(true)

	copy_frame:Hide()


	local title_bg = _G[frame_name.."TitleBg"]
	local drag_frame = _G.CreateFrame("Frame", nil, copy_frame)
	drag_frame:SetPoint("TOPLEFT", title_bg, 16, 0)
	drag_frame:SetPoint("BOTTOMRIGHT", title_bg)
	drag_frame:EnableMouse(true)

	drag_frame:SetScript("OnMouseDown", function(self, button)
		copy_frame:StartMoving()
	end)

	drag_frame:SetScript("OnMouseUp", function(self, button)
		copy_frame:StopMovingOrSizing()
	end)


	local scroll_area = _G.CreateFrame("ScrollFrame", ("%sScroll"):format(frame_name), copy_frame, "FauxScrollFrameTemplate")
	scroll_area:SetPoint("TOPLEFT", copy_frame.Inset, 5, -5)
	scroll_area:SetPoint("BOTTOMRIGHT", copy_frame.Inset, -27, 6)

	function scroll_area:Update(start, wrapped_lines, max_display_lines, all_wrapped_lines, line_height)
		--print("Scroll:Update", start, line_height, max_display_lines)
		local i, linesToDisplay = start - 1, 0
		repeat
			i = i + 1
			linesToDisplay = linesToDisplay + (wrapped_lines[i] or 0)
			--print("Line:", i, linesToDisplay, wrapped_lines[i])
		until linesToDisplay > max_display_lines or not wrapped_lines[i]
		local stop = i - 1
		--print("repeat", start, stop, line_height, max_display_lines)

		self:Show()
		local frameName = self:GetName()
		local scrollBar = _G[frameName .. "ScrollBar"]
		scrollBar:SetStepsPerPage(linesToDisplay - 1)

		if all_wrapped_lines and line_height then
			--[[ This block should only be run when the buffer is changed because posible variations in 
			linesToDisplay from scroll to scroll will affect the height of the scroll frame. This will then 
			result in inconsistent scrolling behaviour. ]]
			local scrollChildFrame = _G[frameName .. "ScrollChildFrame"]

			local scrollFrameHeight = (all_wrapped_lines - linesToDisplay) * line_height
			local scrollChildHeight = all_wrapped_lines * line_height
			if ( scrollFrameHeight < 0 ) then
				scrollFrameHeight = 0
			end
			self.height = scrollFrameHeight
			scrollChildFrame:Show()
			scrollChildFrame:SetHeight(scrollChildHeight)

			scrollBar:SetMinMaxValues(0, scrollFrameHeight) 
			scrollBar:SetValueStep(line_height)
		end
		
		-- Arrow button handling
		local scrollUpButton = _G[frameName .. "ScrollBarScrollUpButton"]
		local scrollDownButton = _G[frameName .. "ScrollBarScrollDownButton"]

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

	copy_frame.scroll_area = scroll_area


	local edit_box = _G.CreateFrame("EditBox", ("%sScrollChildFrame"):format(frame_name), copy_frame)
	edit_box:SetMultiLine(true)
	edit_box:SetMaxLetters(0)
	edit_box:EnableMouse(true)
	edit_box:SetAutoFocus(false)
	edit_box:SetFontObject("SystemFont_Small")
	edit_box:SetAllPoints(scroll_area)

	edit_box:SetScript("OnEscapePressed", function()
		_G.HideUIPanel(copy_frame)
	end)

	copy_frame.edit_box = edit_box

	local line_dummy = copy_frame:CreateFontString()
	line_dummy:SetJustifyH("LEFT")
	line_dummy:SetNonSpaceWrap(true)
	line_dummy:SetFontObject("SystemFont_Small")
	line_dummy:SetPoint("TOPLEFT", 5, 100)
	line_dummy:SetPoint("BOTTOMRIGHT", copy_frame, "TOPRIGHT", -28, 0)
	line_dummy:Hide()
	copy_frame.line_dummy = line_dummy


	local highlight_button = _G.CreateFrame("Button", nil, copy_frame)
	highlight_button:SetSize(16, 16)
	highlight_button:SetPoint("TOPLEFT", title_bg)

	highlight_button:SetScript("OnMouseUp", function(self, button)
		self.texture:ClearAllPoints()
		self.texture:SetAllPoints(self)

		edit_box:HighlightText(0)
		edit_box:SetFocus()

		copy_frame:RegisterEvent("PLAYER_LOGOUT")
	end)

	highlight_button:SetScript("OnMouseDown", function(self, button)
		self.texture:ClearAllPoints()
		self.texture:SetPoint("RIGHT", self, "RIGHT", 1, -1)
	end)

	highlight_button:SetScript("OnEnter", function(self)
		self.texture:SetVertexColor(0.75, 0.75, 0.75)
	end)

	highlight_button:SetScript("OnLeave", function(self)
		self.texture:SetVertexColor(1, 1, 1)
	end)


	local highlight_icon = highlight_button:CreateTexture()
	highlight_icon:SetAllPoints()
	highlight_icon:SetTexture([[Interface\BUTTONS\UI-GuildButton-PublicNote-Up]])
	highlight_button.texture = highlight_icon


	local instance = _G.setmetatable({}, metatable)
	frames[instance] = copy_frame
	buffers[instance] = {
		wrapped_lines = {}
	}

	return instance
end


-----------------------------------------------------------------------
-- Library methods.
-----------------------------------------------------------------------
--- Create a new dump frame.
-- @param frame_title The title text of the frame.
-- @param width (optional) The width of the frame.
-- @param height (optional) The height of the frame.
-- @param save (optional) A function that will called when the copy button is clicked.
-- @return A handle for the dump frame.
function lib:New(frame_title, width, height, save)
	local title_type = type(frame_title)

	if title_type ~= "nil" and title_type ~= "string" then
		error(METHOD_USAGE_FORMAT:format("New", "frame title must be nil or a string."), 2)
	end
	local width_type = type(width)

	if width_type ~= "nil" and width_type ~= "number" then
		error(METHOD_USAGE_FORMAT:format("New", "frame width must be nil or a number."))
	end
	local height_type = type(height)

	if height_type ~= "nil" and height_type ~= "number" then
		error(METHOD_USAGE_FORMAT:format("New", "frame height must be nil or a number."))
	end
	local save_type = type(save)

	if save_type ~= "nil" and save_type ~= "function" then
		error(METHOD_USAGE_FORMAT:format("New", "save must be nil or a function."))
	end
	local instance = NewInstance(width or DEFAULT_FRAME_WIDTH, height or DEFAULT_FRAME_HEIGHT)
	local frame = frames[instance]
	frame.TitleText:SetText(frame_title)

	if save then
		frame:SetScript("OnEvent", function(event, ...)
			save(buffers[instance])
		end)
	end

	return instance
end


-----------------------------------------------------------------------
-- Instance methods.
-----------------------------------------------------------------------
function prototype:AddLine(text)
	self:InsertLine(#buffers[self] + 1, text)
end


function prototype:Clear()
	local wrapped_lines = buffers[self].wrapped_lines
	table.wipe(buffers[self])
	buffers[self].wrapped_lines = wrapped_lines
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


function prototype:InsertLine(position, text)
	if type(position) ~= "number" then
		error(METHOD_USAGE_FORMAT:format("InsertLine", "position must be a number."))
	end

	if type(text) ~= "string" or text == "" then
		error(METHOD_USAGE_FORMAT:format("InsertLine", "text must be a non-empty string."), 2)
	end
	table.insert(buffers[self], position, text)
	debugPrint(frames[self], "InsertLine", position, text)
	if frames[self]:IsShown() then
		frames[self]:UpdateText(buffers[self]:UpdateWrappedLines())
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
	local line_dummy = frame.line_dummy
	function buffer:UpdateWrappedLines()
		local all_wrapped_lines = 0
		table.wipe(buffer.wrapped_lines)
		for i = 1, #buffer do
			line_dummy:SetText(buffer[i])
			buffer.wrapped_lines[i] = line_dummy:GetNumLines()
			all_wrapped_lines = all_wrapped_lines + buffer.wrapped_lines[i]
		end
		return all_wrapped_lines
	end

	local _, line_height = line_dummy:GetFont()
	local max_display_lines = round(frame.edit_box:GetHeight() / line_height)
	--print("Line stats", line_dummy:GetStringHeight(), line_height, max_display_lines)

	local all_wrapped_lines, offset = buffer:UpdateWrappedLines(), 1
	local start, stop = frame.scroll_area:Update(offset, buffer.wrapped_lines, max_display_lines, all_wrapped_lines, line_height)
	function frame:UpdateText(newWrappedLines)
		debugPrint(frame, "UpdateText", newWrappedLines > all_wrapped_lines)
		if newWrappedLines > all_wrapped_lines then
			all_wrapped_lines = newWrappedLines
			start, stop = frame.scroll_area:Update(offset, buffer.wrapped_lines, max_display_lines, all_wrapped_lines, line_height)
		else
			start, stop = frame.scroll_area:Update(offset, buffer.wrapped_lines, max_display_lines)
		end

		debugPrint(frame, "Start/Stop", start, stop)
		local text = table.concat(buffer, separator, start, stop)
		frame.edit_box:SetText(text)
	end
	frame.scroll_area:SetScript("OnVerticalScroll", function(scroll_area, value)
		--print("OnVerticalScroll", value)
		local scrollbar = scroll_area.ScrollBar
		local _, scroll_max = scrollbar:GetMinMaxValues()
		--print("Min/Max", scroll_min, scroll_max)
		local scroll_per = round(value / scroll_max, 2)
		offset = round((1 - scroll_per) * 1 + scroll_per * #buffer)

		--print("Current position", value, offset, scroll_per)
		--print("Concat", start, stop)
		frame:UpdateText(buffer:UpdateWrappedLines())
	end)

	return table.concat(buffer, separator, start, stop)
end
