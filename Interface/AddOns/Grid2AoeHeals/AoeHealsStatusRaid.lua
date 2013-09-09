-- Status: CircleofHealing and WildGrowth

local AOEM = Grid2:GetModule("Grid2AoeHeals")
if AOEM.playerClass ~= "PRIEST" and AOEM.playerClass ~= "DRUID" then return end

local band   = bit.band
local next   = next
local tsort  = table.sort
local GetSpellCooldown = GetSpellCooldown

local radius2
local minPlayers
local maxPlayers
local maxSolutions  
local healthDeficit    
local healthThreshold 
local keepPrevHeals

local solutions = {}

local prev_solutions
local function SortBySolutionCount(p1,p2)
	local p1s= prev_solutions[p1.unit]~=nil
	local p2s= prev_solutions[p2.unit]~=nil
	if p1s==p2s then
		return p1.count>p2.count
	else 
		return p1s
	end	
end

local function IsSpellReady(Spell)
	local start, duration = GetSpellCooldown(Spell)
	return start == 0 or duration <= 1.5
end

local function CheckCooldown(self)
	if (not self.dbx.hideOnCooldown) or IsSpellReady(self.spellId) then
		return true
	elseif next(self.states) then
		self:ClearIndicators()
	end
end

local function ResetSolutions(self,players)
	wipe(solutions)
	local m = #players
	for i=1,m do
		local p = players[i]
		if p.deficit>0 or healthThreshold==0 then
			p.count    = 1
			p.curHeal  = min( healthDeficit, p.deficit )
			p.totHeal  = p.curHeal
			p.totMaskR = p.curMask
		else
			p.count    = 0
			p.curHeal  = 0
			p.totHeal  = 0
			p.totMaskR = 0
		end
	end
	tsort(players, AOEM.SortByDeficit)
end

local function AddSolutions(self, solutions, maxSolutions)
	if keepPrevHeals then
		prev_solutions = self.statesu
		tsort(solutions, SortBySolutionCount)
	end	
	usedNodesMask = 0
	local m = #solutions
	for i=1,m do
		local p= solutions[i]
		if band(usedNodesMask,p.totMaskR)==0  then
			self:AddUnit(p)
			usedNodesMask = usedNodesMask + p.totMaskR
			maxSolutions  = maxSolutions - 1 
			if maxSolutions==0 then return end
		end
	end
end

local function CalcSolutions(self, players)
	ResetSolutions(self,players)
	local m = #players
	for i=1,m do
		local pi     = players[i]
		local piHurt = pi.deficit>0 or healthThreshold==0
		local xi,yi  = pi.x, pi.y
		for j=i+1,m do
			local pj     = players[j]
			local pjHurt = pj.deficit>0 or healthThreshold==0
			if not (piHurt or pjHurt) then break end
			if radius2 >= (xi-pj.x)^2 + (yi-pj.y)^2 then
				if pjHurt and pi.count<maxPlayers then         
					pi.count    = pi.count + 1
					pi.totMaskR = pi.totMaskR + pj.curMask
					pi.totHeal  = pi.totHeal + pj.curHeal
				end	
				if piHurt and pj.count<maxPlayers then
					pj.count    = pj.count + 1
					pj.totMaskR = pj.totMaskR + pi.curMask
					pj.totHeal  = pj.totHeal + pi.curHeal
				end  
			end
		end
		if pi.totHeal>=healthThreshold and pi.count>=minPlayers then
			solutions[#solutions+1]= pi
		end
	end 
	AddSolutions(self, solutions, maxSolutions)
end

local function Update(self)
	if CheckCooldown(self) then
		self:SwapUnits()
		CalcSolutions( self, self:GetFilteredRoster() )
		self:UpdateUnits()
	end	
end

local function Enabled(self)
	self:RegisterEvent( "PLAYER_TALENT_UPDATE", "UpdateTalents" )
	self:UpdateDB()
	self:UpdateTalents()
end

local function Disabled(self)
	self:UnregisterEvent( "PLAYER_TALENT_UPDATE", "UpdateTalents" )
end

local function UpdateDB(self)
	radius2         = (self.dbx.radius2 or 30) ^ 2
	minPlayers      = self.dbx.minPlayers
	maxSolutions    = self.dbx.maxSolutions  or 1
	healthDeficit   = self.dbx.healthDeficit or 0
	keepPrevHeals   = self.dbx.keepPrevHeals
	healthThreshold = healthDeficit * minPlayers
end

if AOEM.playerClass == "PRIEST" then
	AOEM.setupFunc["aoe-CircleOfHealing"]= function(self,dbx)
		self.Update        = Update
		self.spellId       = 34861 
		self.texture       = select( 3, GetSpellInfo(self.spellId) )
		self.HighlightField= "totMaskR"
		self.UpdateDB      = UpdateDB
		self.StatusEnabled = Enabled
		self.StatusDisabled= Disabled
		self.UpdateTalents = function(self) 
			maxPlayers = AOEM:PlayerHasGlyph(55675) and 6 or 5 
		end
	end
	Grid2:DbSetStatusDefaultValue( "aoe-CircleOfHealing", { type = "aoe-CircleOfHealing", 
		hideOnCooldown = true, healthDeficit = 10000, minPlayers = 5, maxSolutions = 1, radius = 30, keepPrevHeals = true,
		color1 = {r=0, g=1, b=0, a=1}, 
	} )
elseif AOEM.playerClass == "DRUID" then
	AOEM.setupFunc["aoe-WildGrowth"] = function(self,dbx)
		self.Update        = Update
		self.spellId       = 48438
		self.texture       = select( 3, GetSpellInfo(self.spellId) )
		self.HighlightField= "totMaskR"
		self.UpdateDB      = UpdateDB
		self.StatusEnabled = Enabled
		self.StatusDisabled= Disabled
		self.UpdateTalents = function(self) 
			maxPlayers = AOEM:PlayerHasGlyph(45602) and 6 or 5 
		end
	end	
	Grid2:DbSetStatusDefaultValue( "aoe-WildGrowth", { type = "aoe-WildGrowth",
		hideOnCooldown = true, healthDeficit = 10000, minPlayers = 5,	maxSolutions = 1, radius = 30, keepPrevHeals = true,
		color1 = {r=0, g=1, b=0, a=1}, 
	})
end
