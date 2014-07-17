local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "Positioners"
local Positioners = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local PF = {}

local function GetHuDSizeOffset(key)
	return nibRealUI.hudSizeOffsets[ndb.settings.hudSize][key] or 0
end

local function GetPositionData(pT)
	local point, parent, rPoint, x, y, width, height, xKeyTable, yKeyTable, widthKeyTable, heightKeyTable =
			pT[1], pT[2], pT[3], pT[4], pT[5], pT[6], pT[7], pT[8], pT[9], pT[10], pT[11]
	
	local xAdj, yAdj, widthAdj, heightAdj = 0, 0, 0, 0

	if xKeyTable then
		for k,v in pairs(xKeyTable) do
			xAdj = xAdj + ndb.positions[ndbc.layout.current][v] + GetHuDSizeOffset(v)
		end
	end
	if yKeyTable then
		for k,v in pairs(yKeyTable) do
			yAdj = yAdj + ndb.positions[ndbc.layout.current][v] + GetHuDSizeOffset(v)
		end
	end
	if widthKeyTable then
		for k,v in pairs(widthKeyTable) do
			widthAdj = widthAdj + ndb.positions[ndbc.layout.current][v] + GetHuDSizeOffset(v)
		end
	end
	if heightKeyTable then
		for k,v in pairs(heightKeyTable) do
			heightAdj = heightAdj + ndb.positions[ndbc.layout.current][v] + GetHuDSizeOffset(v)
		end
	end
	x = floor(x + xAdj)
	y = floor(y + yAdj)
	width = floor(width + widthAdj)
	height = floor(height + heightAdj)

	return point, parent, rPoint, x, y, width, height
end

function nibRealUI:UpdatePositioners()
	local positioners = {}
	for k, v in pairs(db.positioners) do
		positioners[k] = v
	end
	for k, v in pairs(positioners) do
		local point, parent, rPoint, x, y, width, height = GetPositionData(v)
		PF[k]:ClearAllPoints()
		PF[k]:SetPoint(point, parent, rPoint, x, y)
		PF[k]:SetSize(width, height)
	end
end

local function CreatePositionerFrame(point, parent, rpoint, x, y, w, h, name)
	local frame = CreateFrame("Frame", name, _G[parent])
	frame:SetPoint(point, _G[parent], rpoint, x, y)
	frame:SetHeight(h)
	frame:SetWidth(w)
	
	-- frame.bg = frame:CreateTexture(nil, "OVERLAY")
	-- frame.bg:SetAllPoints(frame)
	-- frame.bg:SetTexture(1, 1, 0, 0.5)
	
	return frame
end

local function CreatePositioners()
	local positioners = {}
	for k, v in pairs(db.positioners) do
		positioners[k] = v
	end
	for k, v in pairs(positioners) do
		local point, parent, rPoint, x, y, width, height = GetPositionData(v)
		PF[k] = CreatePositionerFrame(
			point, parent, rPoint, x, y, width, height, "RealUIPositioners"..k
		)
	end
end

function Positioners:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			positioners = {
				-- 						{point, 	parent, 	rpoint, 	x, y, w, h, 	xKeyTable, 					yKeyTable, 					widthKeyTable,						heightKeyTable},
				["Center"] =			{"CENTER", 	"UIParent",	"CENTER",	0, 0, 2, 2, 	nil, 						{"HuDY"}},
				["Buffs"] =				{"TOPRIGHT","UIParent",	"TOPRIGHT", -1, -1, 2, 2},
				["HuD"] =				{"CENTER", 	"UIParent",	"CENTER", 	0, 0, 0, 2,		{"HuDX"},					{"HuDY"}},
				["SpellAlerts"] =		{"CENTER", 	"UIParent",	"CENTER", 	0, 0, 0, 140, 	{"HuDX"},					{"HuDY"}, 					{"SpellAlertWidth"}},
				["CTAurasLeft"] =	{"BOTTOMRIGHT",	"UIParent",	"CENTER", 	-4, -128, 2, 2,	{"HuDX", "CTAurasLeftX"},	{"HuDY", "CTAurasLeftY"}},
				["CTAurasRight"] =	{"BOTTOMLEFT",	"UIParent",	"CENTER", 	3, -128, 2, 2,	{"HuDX", "CTAurasRightX"},	{"HuDY", "CTAurasRightY"}},
				["CTPoints"] =			{"CENTER",	"UIParent",	"CENTER", 	0, 0, -216, 0,	{"HuDX"},					{"HuDY"},					{"CTPointsWidth", "UFHorizontal"},	{"CTPointsHeight"}},
				["CastBarPlayer"] =		{"TOP", 	"UIParent",	"CENTER", 	-2, -130, 2, 2,	{"HuDX", "CastBarPlayerX"},	{"HuDY", "CastBarPlayerY"}},
				["CastBarTarget"] =		{"TOP", 	"UIParent",	"CENTER", 	2, -130, 2, 2,	{"HuDX", "CastBarTargetX"},	{"HuDY", "CastBarTargetY"}},
				["UnitFrames"] =		{"CENTER", 	"UIParent",	"CENTER", 	0, 0, 80, 2, 	{"HuDX"}, 					{"HuDY"}, 					{"UFHorizontal"}},
				["BossFrames"] =		{"RIGHT", 	"UIParent",	"RIGHT",  	0, 0, 2, 2, 	{"BossX"},					{"HuDY", "BossY"}},
				["GridBottom"] =		{"BOTTOM", 	"UIParent",	"BOTTOM", 	0, 0, 2, 2, 	{"HuDX", "GridBottomX"},	{"GridBottomY"}},
				["GridTop"] = 			{"CENTER", 	"UIParent",	"CENTER", 	0, 0, 2, 2, 	{"HuDX", "GridTopX"},		{"HuDY", "GridTopY"}},
				["ClassResource"] = 	{"CENTER", 	"UIParent",	"CENTER", 	0, -93, 2, 2, 	{"HuDX", "ClassResourceX"},	{"HuDY", "ClassResourceY"}},
				["Runes"] = 			{"CENTER", 	"UIParent",	"CENTER", 	0, -88, 2, 2, 	{"HuDX", "RunesX"},			{"HuDY", "RunesY"}},
			},
		}
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(true)
	
	CreatePositioners()
end
