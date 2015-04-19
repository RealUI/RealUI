-- Status: Chain Heals
--[[
local AOEM = Grid2:GetModule("Grid2AoeHeals")
if AOEM.playerClass ~= "SHAMAN" then return end

local next = next 
local min = math.min
local floor= math.floor
local tsort = table.sort
local tinsert = table.insert

local roster  = {}    -- Roster for chain heals calculated by CalcNeighbors (GetFilteredRoster() with invalid targets for chain heals removed)
local visited = {}	  -- Temporary table used by Chain Heals calcs

local radius2
local minJumps          
local showOverlapHeals  
local healthDeficit     
local healthThreshold   
local keepPrevHeals

local prev_solutions
local function SortBySolutionDeficit(p1,p2)
	local p1s= prev_solutions[p1.unit]~=nil
	local p2s= prev_solutions[p2.unit]~=nil
	if p1s==p2s then
		return p1.percent<p2.percent 
	else 
		return p1s
	end	
end

local function CalcNeighbors(self, input, output)
	local m = #input
	for i=1,m do
	    local p = input[i]
		p.totMaskC    = 0
		p.valid      = true
		wipe(p.neighbors)
	end
	tsort(input, AOEM.SortByDeficit)
	wipe(output)
	for i=1,m do
		local pi = input[i]
		local xi,yi = pi.x, pi.y
		for j=i+1,m do
			local pj = input[j]
			if radius2 >= (xi-pj.x)^2 + (yi-pj.y)^2 then
				tinsert( pi.neighbors, pj )
				tinsert( pj.neighbors, pi )
			end
		end
		if #pi.neighbors>0 then
			output[#output+1]= pi
		end	
	end
	if keepPrevHeals then
		prev_solutions = self.statesu
		tsort(output, SortBySolutionDeficit)
	end	
	return output
end

local function SearchNextChainNode(n)
	for k=1,#n do
		local pk= n[k]
		if not visited[pk] then
			return pk
		end
	end
end

-- Calculate best chainheals
local function CalcChainHeals(self, roster)
	local states, statesu   = self.states, self.statesu
	for i=1,#roster do
		local pi = roster[i]
		if pi.valid then
			wipe(visited)
			visited[pi] = true
			local p, j, totHeal = pi, 0, 0
			repeat
				local pn= SearchNextChainNode(p.neighbors)
				if not (pn and pn.valid) then break end
				p , j = pn, j + 1
				totHeal = totHeal + min( healthDeficit, p.deficit )
				visited[p] = true
			until j>=3
			if j>=minJumps then
				totHeal= totHeal + min( healthDeficit, pi.deficit ) 
				if totHeal>=healthThreshold then
					local unit    =  pi.unit
					local count   =  j + 1
					states[unit]  = count
					statesu[unit] = statesu[unit]~=count and count or nil
					for pr in next,visited do
						pr.valid   = showOverlapHeals
						pi.totMaskC = pi.totMaskC + pr.curMask
					end
				end
			end
		end	
	end
end

local function Update(self)
	self:SwapUnits()
	CalcChainHeals( self, CalcNeighbors( self, self:GetFilteredRoster(), roster ) )
	self:UpdateUnits()
end

local function UpdateDB(self,dbx)
	dbx               = dbx or self.dbx
	radius2           = (dbx.radius or 12.5) ^ 2
	minJumps          = dbx.minPlayers - 1
	keepPrevHeals     = dbx.keepPrevHeals
	showOverlapHeals  = dbx.showOverlapHeals
	healthDeficit     = dbx.healthDeficit or 8000
	healthThreshold   = healthDeficit * dbx.minPlayers
end

--}}

AOEM.setupFunc["aoe-ChainHeal"] = function(self,dbx)
	AOEM.chCreated      = true     -- uggly/hackish special case
	self.isChainHeal    = true
	self.spellId        = 1064
	self.texture        = select( 3, GetSpellInfo(self.spellId) )
	self.HighlightField = "totMaskC"
	self.Update         = Update
	self.UpdateDB       = UpdateDB
	UpdateDB(self,dbx)
end

Grid2:DbSetStatusDefaultValue( "aoe-ChainHeal", { type = "aoe-ChainHeal", 
	healthDeficit = 10000, minPlayers = 4, maxSolutions = 5, radius = 12.5, keepPrevHeals = true,
	color1 = {r=0, g=1, b=0, a=1}, 
})
--]]		