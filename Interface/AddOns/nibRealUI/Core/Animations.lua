local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb, ndbc

local MODNAME = "Animations"
local Animations = nibRealUI:NewModule(MODNAME)

local function smooth(mode,x,y,z)
	return mode == true and 1 or max((10 + abs(x - y)) / (88.88888 * z), .2) * 1.1
end

function Animations:SimpleMove(frame, t)
	frame.pos = frame.pos + t * frame.speed * smooth(frame.smode,frame.limit,frame.pos,.5)
	frame:SetPoint(frame.point_1,frame.parent,frame.point_2,frame.hor and frame.pos or frame.alt or 0,not(frame.hor) and frame.pos or frame.alt or 0)
	if frame.pos * frame.mod >= frame.limit * frame.mod then
		frame:SetPoint(frame.point_1,frame.parent,frame.point_2,frame.hor and frame.limit or frame.alt or  0,not(frame.hor) and frame.limit or frame.alt or 0)
		frame.pos = frame.limit
		frame:SetScript("OnUpdate",nil)
		if frame.finish_hide then
			frame:Hide()
		end
		if frame.finish_function then
			frame:finish_function()
		end
	end
end

function Animations:Slide(frame, direction, length, speed)
	local p1, rel, p2, x, y = frame:GetPoint()
	frame.mod = ( direction == "LEFT" or direction == "DOWN" ) and -1 or 1
	frame.limit = y + frame.mod * length
	frame.speed = frame.mod * speed
	frame.point_1 = p1
	frame.point_2 = p2
	frame.hor = ( direction == "LEFT" or direction == "RIGHT" ) and true or false
	if frame.hor then
		frame.pos = x
		frame.alt = y
	else
		frame.pos = y
		frame.alt = x
	end
	frame:SetScript("OnUpdate", function(self, elapsed) Animations:SimpleMove(self, elapsed) end)
end

-------------
function Animations:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
end