local Alpha = Grid2.indicatorPrototype:new("alpha")

Alpha.Create = Grid2.Dummy
Alpha.Layout = Grid2.Dummy

function Alpha:OnUpdate(parent, unit, status)
	parent:SetAlpha(status and status:GetPercent(unit) or Alpha.dbx.color1.a)
end

local function Create(indicatorKey, dbx)
	Alpha.dbx = dbx
	Grid2:RegisterIndicator(Alpha, { "percent" })
	return Alpha
end

Grid2.setupFunc["alpha"] = Create
