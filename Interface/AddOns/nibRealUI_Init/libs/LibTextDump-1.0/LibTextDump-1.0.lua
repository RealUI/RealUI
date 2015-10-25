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

local _, LINE_HEIGHT = ChatFontNormal:GetFont()

-----------------------------------------------------------------------
-- Helper functions.
-----------------------------------------------------------------------
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
		max_display_lines = _G.floor(edit_box:GetHeight() / LINE_HEIGHT)
	}

	return instance
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
	table.wipe(buffers[self])
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
	_G.FauxScrollFrame_Update(frame.scroll_area, #buffer, _G.min(#buffer, buffer.max_display_lines), LINE_HEIGHT, nil, nil, nil, nil, nil, nil, true )
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
	local buffer, output = buffers[self]
	local max_display_lines = buffer.max_display_lines

	if max_display_lines > #buffer then
		output = table.concat(buffer, separator)
	else
		local frame = frames[self]
		frame.scroll_area:SetScript("OnVerticalScroll", function(scroll_area, value)
			local scrollbar = _G[scroll_area:GetName().."ScrollBar"];
			scrollbar:SetValue(value);
			local offset = _G.floor((value / LINE_HEIGHT) + 0.5);

			local text = table.concat(buffer, separator, offset + 1, offset + max_display_lines)
			frame.edit_box:SetText(text)
		end)

		output = table.concat(buffer, separator, 1, max_display_lines)
	end
	return output
end
