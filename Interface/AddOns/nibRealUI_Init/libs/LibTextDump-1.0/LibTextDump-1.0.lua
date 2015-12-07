-----------------------------------------------------------------------
-- Upvalued Lua API.
-----------------------------------------------------------------------
local _G = getfenv(0)

-- Functions
local error = _G.error
local pairs = _G.pairs
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
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)

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
local function round(number)
	return _G.floor(number + 0.5)
end

local function NewInstance(width, height)
	lib.num_frames = lib.num_frames + 1

	local frame_name = ("%s_CopyFrame%d"):format(MAJOR, lib.num_frames)
	local copy_frame = _G.CreateFrame("Frame", frame_name, _G.UIParent, "BaseBasicFrameTemplate")
	copy_frame:SetSize(width, height)
	copy_frame:SetPoint("CENTER", _G.UIParent, "CENTER")
	copy_frame:SetFrameStrata("DIALOG")
	copy_frame:EnableMouse(true)
	copy_frame:SetMovable(true)
	copy_frame:SetToplevel(true)

	table.insert(_G.UISpecialFrames, frame_name)
	_G.HideUIPanel(copy_frame)


	local title_bg = copy_frame:CreateTexture(nil, "BACKGROUND", "_UI-Frame-TitleTileBg")
	title_bg:SetPoint("TOPLEFT", 2, -3)
	title_bg:SetPoint("BOTTOMRIGHT", copy_frame.TopRightCorner, "BOTTOMLEFT", 7, 13)


	local dialog_bg = copy_frame:CreateTexture(nil, "BACKGROUND")
	dialog_bg:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
	dialog_bg:SetVertexColor(0, 0, 0, 0.75)
	dialog_bg:SetPoint("TOPLEFT", 2, -21)
	dialog_bg:SetPoint("BOTTOMRIGHT", -2, 21)


	-- assign template title region to old var
	local title = copy_frame.TitleText
	copy_frame.title = title


	local drag_frame = _G.CreateFrame("Frame", nil, copy_frame)
	drag_frame:SetPoint("TOPLEFT", title_bg)
	drag_frame:SetPoint("BOTTOMRIGHT", title_bg)
	drag_frame:EnableMouse(true)

	drag_frame:SetScript("OnMouseDown", function(self, button)
		copy_frame:StartMoving()
	end)

	drag_frame:SetScript("OnMouseUp", function(self, button)
		copy_frame:StopMovingOrSizing()
	end)


	local footer_frame = _G.CreateFrame("Frame", nil, copy_frame, "InsetFrameTemplate")
	footer_frame:SetHeight(24)
	footer_frame:SetPoint("BOTTOMLEFT", copy_frame, "BOTTOMLEFT", 2, 4)
	footer_frame:SetPoint("BOTTOMRIGHT", copy_frame, "BOTTOMRIGHT", -4, 4)


	local footer = footer_frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	footer:SetPoint("CENTER", footer_frame, "CENTER", 0, 0)


	local scroll_area = _G.CreateFrame("ScrollFrame", ("%sScroll"):format(frame_name), copy_frame, "FauxScrollFrameTemplate")
	scroll_area:SetPoint("TOPLEFT", 5, -24)
	scroll_area:SetPoint("BOTTOMRIGHT", -28, 29)

	copy_frame.scroll_area = scroll_area


	local edit_box = _G.CreateFrame("EditBox", ("%sScrollChildFrame"):format(frame_name), copy_frame)
	edit_box:SetMultiLine(true)
	edit_box:SetMaxLetters(0)
	edit_box:EnableMouse(true)
	edit_box:SetAutoFocus(false)
	edit_box:SetFontObject("ChatFontNormal")
	edit_box:SetPoint("TOPLEFT", 5, -24)
	edit_box:SetPoint("BOTTOMRIGHT", -28, 29)

	edit_box:SetScript("OnEscapePressed", function()
		_G.HideUIPanel(copy_frame)
	end)

	copy_frame.edit_box = edit_box

	local line_dummy = copy_frame:CreateFontString()
	line_dummy:SetJustifyH("LEFT")
	line_dummy:SetNonSpaceWrap(true)
	line_dummy:SetFontObject("ChatFontNormal")
	line_dummy:SetPoint("TOPLEFT", 5, 100)
	line_dummy:SetPoint("BOTTOMRIGHT", copy_frame, "TOPRIGHT", -28, 0)
	line_dummy:Hide()
	copy_frame.line_dummy = line_dummy


	local highlight_button = _G.CreateFrame("Button", nil, copy_frame)
	highlight_button:SetSize(16, 16)
	highlight_button:SetPoint("BOTTOMRIGHT", -8, 8)

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

local function GetDisplayLines(start, wrapped_lines, max_display_lines)
	--print("GetDisplayLines", start, line_height, max_display_lines)
	local i, lines = start - 1, 0
	repeat
	    i = i + 1
		lines = lines + (wrapped_lines[i] or 0)
		--print("Line:", i, lines, wrapped_lines[i])
	until lines > max_display_lines or not wrapped_lines[i]
	local stop = i - 1
	--print("repeat", start, stop, line_height, max_display_lines)
	return start, stop, lines
end


-----------------------------------------------------------------------
-- Library methods.
-----------------------------------------------------------------------
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
	frame.title:SetText(frame_title)

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
	wrapped_lines = nil
end


function prototype:Display(separator)
	local display_text = self:String(separator)

	if display_text == "" then
		error(METHOD_USAGE_FORMAT:format("Display", "buffer must be non-empty"), 2)
	end
	local buffer, frame = buffers[self], frames[self]
	frame.edit_box:SetText(display_text)
	frame.edit_box:SetCursorPosition(0)
	_G.ShowUIPanel(frame)
end


function prototype:InsertLine(position, text)
	if type(position) ~= "number" then
		error(METHOD_USAGE_FORMAT:format("InsertLine", "position must be a number."))
	end

	if type(text) ~= "string" or text == "" then
		error(METHOD_USAGE_FORMAT:format("InsertLine", "text must be a non-empty string."), 2)
	end
	table.insert(buffers[self], position, text)
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
	local buffer, frame, output = buffers[self], frames[self]
	local line_dummy, wrapped_lines = frame.line_dummy, buffer.wrapped_lines

	local _, line_height = line_dummy:GetFont()
	local max_display_lines, all_wrapped_lines = round(frame.edit_box:GetHeight() / line_height), 0
	--print("Line stats", line_dummy:GetStringHeight(), line_height, max_display_lines)
	table.wipe(wrapped_lines)
	for i = 1, #buffer do
		line_dummy:SetText(buffer[i])
		wrapped_lines[i] = line_dummy:GetNumLines()
		all_wrapped_lines = all_wrapped_lines + wrapped_lines[i]
	end

	local start, stop, lines = GetDisplayLines(1, wrapped_lines, max_display_lines)
	_G.FauxScrollFrame_Update(frame.scroll_area, all_wrapped_lines, lines, line_height, nil, nil, nil, nil, nil, nil, true )

	if all_wrapped_lines <= max_display_lines then
		--print("Simple", start, stop)
		output = table.concat(buffer, separator)
	else
		--print("Overflow", start, stop)
		frame.scroll_area:SetScript("OnVerticalScroll", function(scroll_area, value)
			--print("OnVerticalScroll", value)
			local scrollbar = scroll_area.ScrollBar
			local scroll_min, scroll_max = scrollbar:GetMinMaxValues()
            local offset = round((((value - scroll_min) * (#buffer - 1)) / (scroll_max - scroll_min)) + 1)
			--print("Current position", value, offset)

			local start, stop, lines = GetDisplayLines(offset, wrapped_lines, max_display_lines)
			_G.FauxScrollFrame_Update(frame.scroll_area, all_wrapped_lines, lines, line_height, nil, nil, nil, nil, nil, nil, true )

			--print("Concat", start, stop)
			local text = table.concat(buffer, separator, start, stop)
			frame.edit_box:SetText(text)
			frame.prev_stop = stop
		end)

		output = table.concat(buffer, separator, start, stop)
	end
	return output
end
