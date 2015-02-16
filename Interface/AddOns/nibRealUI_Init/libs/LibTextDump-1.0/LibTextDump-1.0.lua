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
local MAJOR = "LibTextDump-1.0"

_G.assert(LibStub, MAJOR .. " requires LibStub")

local MINOR = 1 -- Should be manually increased
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
local function CreateBorder(parent, width, height, left, right, top, bottom)
	local border = parent:CreateTexture(nil, "BORDER")
	border:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-Border]])
	border:SetWidth(width)
	border:SetHeight(height)
	border:SetTexCoord(left, right, top, bottom)

	return border
end

local function NewInstance(width, height)
	lib.num_frames = lib.num_frames + 1

	local frame_name = ("%s_CopyFrame%d"):format(MAJOR, lib.num_frames)
	local copy_frame = _G.CreateFrame("Frame", frame_name, _G.UIParent)
	copy_frame:SetSize(width, height)
	copy_frame:SetPoint("CENTER", _G.UIParent, "CENTER")
	copy_frame:SetFrameStrata("DIALOG")
	copy_frame:EnableMouse(true)
	copy_frame:SetMovable(true)

	table.insert(_G.UISpecialFrames, frame_name)
	_G.HideUIPanel(copy_frame)


	local title_bg = copy_frame:CreateTexture(nil, "BACKGROUND")
	title_bg:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-Title-Background]])
	title_bg:SetPoint("TOPLEFT", 9, -6)
	title_bg:SetPoint("BOTTOMRIGHT", copy_frame, "TOPRIGHT", -28, -24)


	local dialog_bg = copy_frame:CreateTexture(nil, "BACKGROUND")
	dialog_bg:SetTexture([[Interface\Tooltips\UI-Tooltip-Background]])
	dialog_bg:SetVertexColor(0, 0, 0, 0.75)
	dialog_bg:SetPoint("TOPLEFT", 8, -24)
	dialog_bg:SetPoint("BOTTOMRIGHT", -6, 8)


	local top_left = CreateBorder(copy_frame, 64, 64, 0.501953125, 0.625, 0, 1)
	top_left:SetPoint("TOPLEFT")


	local top_right = CreateBorder(copy_frame, 64, 64, 0.625, 0.75, 0, 1)
	top_right:SetPoint("TOPRIGHT")


	local top = CreateBorder(copy_frame, 0, 64, 0.25, 0.369140625, 0, 1)
	top:SetPoint("TOPLEFT", top_left, "TOPRIGHT", 0, 0)
	top:SetPoint("TOPRIGHT", top_right, "TOPLEFT", 0, 0)


	local bottom_left = CreateBorder(copy_frame, 64, 64, 0.751953125, 0.875, 0, 1)
	bottom_left:SetPoint("BOTTOMLEFT")


	local bottom_right = CreateBorder(copy_frame, 64, 64, 0.875, 1, 0, 1)
	bottom_right:SetPoint("BOTTOMRIGHT")


	local bottom = CreateBorder(copy_frame, 0, 64, 0.37695312, 0.498046875, 0, 1)
	bottom:SetPoint("BOTTOMLEFT", bottom_left, "BOTTOMRIGHT", 0, 0)
	bottom:SetPoint("BOTTOMRIGHT", bottom_right, "BOTTOMLEFT", 0, 0)


	local left = CreateBorder(copy_frame, 64, 0, 0.001953125, 0.125, 0, 1)
	left:SetPoint("TOPLEFT", top_left, "BOTTOMLEFT", 0, 0)
	left:SetPoint("BOTTOMLEFT", bottom_left, "TOPLEFT", 0, 0)


	local right = CreateBorder(copy_frame, 64, 0, 0.1171875, 0.2421875, 0, 1)
	right:SetPoint("TOPRIGHT", top_right, "BOTTOMRIGHT", 0, 0)
	right:SetPoint("BOTTOMRIGHT", bottom_right, "TOPRIGHT", 0, 0)


	local title = copy_frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	title:SetPoint("TOPLEFT", 12, -8)
	title:SetPoint("TOPRIGHT", -32, -8)

	copy_frame.title = title


	local drag_frame = _G.CreateFrame("Frame", nil, copy_frame)
	drag_frame:SetPoint("TOPLEFT", title)
	drag_frame:SetPoint("BOTTOMRIGHT", title)
	drag_frame:EnableMouse(true)

	drag_frame:SetScript("OnMouseDown", function(self, button)
		copy_frame:StartMoving()
	end)

	drag_frame:SetScript("OnMouseUp", function(self, button)
		copy_frame:StopMovingOrSizing()
	end)


	local close_button = _G.CreateFrame("Button", nil, copy_frame, "UIPanelCloseButton")
	close_button:SetSize(32, 32)
	close_button:SetPoint("TOPRIGHT", 2, 1)


	local footer_frame = _G.CreateFrame("Frame", nil, copy_frame, "InsetFrameTemplate")
	footer_frame:SetHeight(23)
	footer_frame:SetPoint("BOTTOMLEFT", copy_frame, "BOTTOMLEFT", 8, 8)
	footer_frame:SetPoint("BOTTOMRIGHT", copy_frame, "BOTTOMRIGHT", -5, 8)


	local footer = footer_frame:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	footer:SetPoint("CENTER", footer_frame, "CENTER", 0, 0)


	local scroll_area = _G.CreateFrame("ScrollFrame", ("%sScroll"):format(frame_name), copy_frame, "UIPanelScrollFrameTemplate")
	scroll_area:SetPoint("TOPLEFT", copy_frame, "TOPLEFT", 10, -28)
	scroll_area:SetPoint("BOTTOMRIGHT", copy_frame, "BOTTOMRIGHT", -28, 31)

	scroll_area:SetScript("OnMouseWheel", function(self, delta)
		_G.ScrollFrameTemplate_OnMouseWheel(self, delta, self.ScrollBar)
	end)

	scroll_area.ScrollBar:SetScript("OnMouseWheel", function(self, delta)
		_G.ScrollFrameTemplate_OnMouseWheel(self, delta, self)
	end)


	local edit_box = _G.CreateFrame("EditBox", nil, copy_frame)
	edit_box:SetMultiLine(true)
	edit_box:SetMaxLetters(0)
	edit_box:EnableMouse(true)
	edit_box:SetAutoFocus(false)
	edit_box:SetFontObject("ChatFontNormal")
	edit_box:SetSize(650, 270)

	edit_box:SetScript("OnEscapePressed", function()
		_G.HideUIPanel(copy_frame)
	end)

	copy_frame.edit_box = edit_box
	scroll_area:SetScrollChild(edit_box)


	local highlight_button = _G.CreateFrame("Button", nil, copy_frame)
	highlight_button:SetSize(16, 16)
	highlight_button:SetPoint("BOTTOMRIGHT", -10, 10)

	highlight_button:SetScript("OnMouseUp", function(self, button)
		self.texture:ClearAllPoints()
		self.texture:SetAllPoints(self)

		edit_box:HighlightText(0)
		edit_box:SetFocus()
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
	buffers[instance] = {}

	return instance
end


-----------------------------------------------------------------------
-- Library methods.
-----------------------------------------------------------------------
function lib:New(frame_title, width, height)
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
	local instance = NewInstance(width or DEFAULT_FRAME_WIDTH, height or DEFAULT_FRAME_HEIGHT)
	frames[instance].title:SetText(frame_title)

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
	local frame = frames[self]
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
	return table.concat(buffers[self], separator or "\n")
end
