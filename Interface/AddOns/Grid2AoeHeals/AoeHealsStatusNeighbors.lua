-- Status: Neighbors

local AOEM = Grid2:GetModule("Grid2AoeHeals")

local radius
local minPlayers
local healthDeficit
local IsActive

local function CalcNeighbors(self, players)
	local m = #players
	for i=1,m do
		local p = players[i]
		p.count    = 1
		p.totMaskN = p.curMask
	end
	for i=1,m do
		local pi = players[i]
		local xi,yi = pi.x, pi.y
		for j=i+1,m do
			local pj = players[j]
			if radius2 >= (xi-pj.x)^2 + (yi-pj.y)^2 then
				if pj.deficit >= healthDeficit then
					pi.count    = pi.count + 1 
					pi.totMaskN = pi.totMaskN + pj.curMask
				end
				if pi.deficit >= healthDeficit then
					pj.count    = pj.count + 1
					pj.totMaskN = pj.totMaskN + pi.curMask
				end	
			end
		end
		if pi.count>=minPlayers then
			self:AddUnit( pi )
		end
	end
end

local function Refresh(self)
	wipe(self.states)
	CalcNeighbors( self, self:GetFilteredRoster() )
end

local function Update(self)
	self:SwapUnits()
	CalcNeighbors( self, self:GetFilteredRoster() )
	self:UpdateUnits()
end

local function UpdateDB(self, dbx)
	dbx           = dbx or self.dbx
	radius2       = dbx.radius ^ 2
	minPlayers    = dbx.minPlayers
	healthDeficit = dbx.healthDeficit or 0
end

AOEM.setupFunc["aoe-neighbors"] = function(self,dbx)
	IsActive             = self.IsActive
	self.UpdateDB        = UpdateDB
	self.Update 		 = Update
	self.Refresh         = Refresh
	self.HighlightField  = "totMaskN"
	self.texture         = "Interface\\Icons\\Inv_misc_map04"
	UpdateDB(self,dbx)
end	

Grid2:DbSetStatusDefaultValue( "aoe-neighbors", {type = "aoe-neighbors", 
	radius = 12.5, minPlayers = 4, healthDeficit = 0, color1 = {r=0,g=0.5,b=1,a=1}, 
})
