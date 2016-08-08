 --[[
LICENSE
	cargBags: An inventory framework addon for World of Warcraft

	Copyright (C) 2010  Constantin "Cargor" Schomburg <xconstruct@gmail.com>

	cargBags is free software; you can redistribute it and/or
	modify it under the terms of the GNU General Public License
	as published by the Free Software Foundation; either version 2
	of the License, or (at your option) any later version.

	cargBags is distributed in the hope that it will be useful,
	but WITHOUT ANY WARRANTY; without even the implied warranty of
	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
	GNU General Public License for more details.

	You should have received a copy of the GNU General Public License
	along with cargBags; if not, write to the Free Software
	Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

DESCRIPTION
	Provides translation-tables for the auction house categories

USAGE:
	local L = cargBags:GetLocalizedNames()
	OR local L = Implementation:GetLocalizedNames()

	L[englishName] returns localized name
]]
local _, ns = ...
local cargBags = ns.cargBags

local L
do
end

--[[!
	Fetches/creates a table of localized type names
	@return locale <table>
]]
function cargBags:GetLocalizedTypes()
	if(L) then return L end

	L = {}

	-- Credit: Torhal http://www.wowinterface.com/forums/showpost.php?p=317527&postcount=6
	local classIndex = 0
	local className = _G.GetItemClassInfo(classIndex)

	while className and className ~= "" do
		L[classIndex] = {
			name = className,
			subClasses = {},
		}

		local subClassIndex = 0
		local subClassName = _G.GetItemSubClassInfo(classIndex, subClassIndex)

		while subClassName and subClassName ~= "" do
			L[classIndex].subClasses[subClassIndex] = subClassName

			subClassIndex = subClassIndex + 1
			subClassName = _G.GetItemSubClassInfo(classIndex, subClassIndex)
		end

		classIndex = classIndex + 1
		className = _G.GetItemClassInfo(classIndex)
	end

	return L
end

cargBags.classes.Implementation.GetLocalizedNames = cargBags.GetLocalizedNames
