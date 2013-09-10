--[[
Name: LibAlts-1.0
Revision: 46
Author: Sylvanaar (sylvanaar@mindspring.com)
Description: Shared handling of alt identity between addons.
Dependencies: LibStub
License: 
]]--

local MAJOR, MINOR = "LibAlts-1.0", "46"
local LibStub = LibStub
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end

local _G = getfenv(0)

lib.Alts = lib.Alts or {}
lib.AltsPerSource = lib.AltsPerSource or {}
lib.RealIds = lib.RealIds or {}

local Alts = lib.Alts
local AltsPerSource = lib.AltsPerSource

local Mains  -- reverse lookup table
local MainsPerSource = {} -- reverse lookup table

--local RealIds = lib.RealIds
--local RealIdMains = {} -- reverse lookup table

local tinsert = _G.tinsert
local unpack = _G.unpack
local pairs = _G.pairs
local tremove = _G.tremove
local tsort = _G.table.sort
local tContains = _G.tContains
local ipairs = _G.ipairs
local wipe = _G.wipe

lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
local callbacks = lib.callbacks

-- Regexp to match the first character for UTF8 strings
local MULTIBYTE_FIRST_CHAR = "^([\192-\255]?%a?[\128-\191]*)"

-- Constants for the source prefixes.  These should be prepended for guild or
-- addon source names so they remain consistent.  The guild name itself should
-- be the exact value from the Blizzard API.  Addons should use their exact name.
lib.GUILD_PREFIX = "guild:"
lib.ADDON_PREFIX = "addon:"

local function reverseTable(table)
	local reverse = {}
	
	if table then
    	for k,v in pairs(table) do
    		for i,a in ipairs(v) do
    			reverse[a] = k
    		end
    	end
	end

	return reverse
end

--- Register a Main-Alt relationship.
--  User-entered data should not have a source (i.e, source = nil).  For guild data, 
--  prepend "guild:" to the guild name returned from the API.  Addons 
--  wishing to add their own separate data should prepend "addon:".  Any data not 
--  directly entered by a user should be added as a source.
-- @name :SetAlt 
-- @param main Name of the main character.
-- @param alt Name of the alt character.
-- @param source Source of the main-alt relationship.  Nil if used-defined.
function lib:SetAlt(main, alt, source)
	if (not main) or (not alt) then return end

	main = self:TitleCase(main)
	alt = self:TitleCase(alt)
    
    if not source then
        -- Adding the relationship to the user-defined data.
	    Mains = nil

    	Alts[main] = Alts[main] or {}
    	for i,v in ipairs(Alts[main]) do
    	    if v == alt then
    	        return
    	    end
    	end
    	tinsert(Alts[main], alt)
    else
        -- Adding a relationship for a specific source.
        MainsPerSource[source] = nil

        AltsPerSource[source] = AltsPerSource[source] or {}
    	AltsPerSource[source][main] = AltsPerSource[source][main] or {}
    	for i,v in ipairs(AltsPerSource[source][main]) do
    	    if v == alt then
    	        return
    	    end
    	end
    	tinsert(AltsPerSource[source][main], alt)
    end

	callbacks:Fire("LibAlts_SetAlt", main, alt, source)
end

--- Get a list of alts for a given character.
-- @name :GetAlts
-- @param main Name of the main character.
-- @return  list list of alts.
function lib:GetAlts(main)
	if not main then return nil end

	main = self:TitleCase(main)
	
	local alts = {}

	if Alts[main] and #Alts[main] > 0 then
		for i, v in ipairs(Alts[main]) do
		    if not tContains(alts, v) then
		        tinsert(alts, v)
		    end
		end
	end

    for k, v in pairs(AltsPerSource) do
        if AltsPerSource[k][main] and #AltsPerSource[k][main] > 0 then
            for i, v in ipairs(AltsPerSource[k][main]) do
                if not tContains(alts, v) then
                    tinsert(alts, v)
                end
            end
        end
    end

    if #alts > 0 then
        return unpack(alts)
    end

	return nil
end

--- Get a list of alts for a given character for a given data source.
-- @name :GetAltsForSource
-- @param main Name of the main character.
-- @param source The data source to use.  Nil for user-defined.
-- @return  list list of alts.
function lib:GetAltsForSource(main, source)
	if not main then return end

	main = self:TitleCase(main)

	if not source then
    	if Alts[main] and #Alts[main] > 0 then
    	    return unpack(Alts[main])
    	end
    else
        if not AltsPerSource[source] then return nil end
        if AltsPerSource[source][main] and #AltsPerSource[source][main] > 0 then
            return unpack(AltsPerSource[source][main])
        end
    end
    
    return nil
end

--- Get the main for a given alt character.
-- @name :GetMain 
-- @param alt Name of the alt character.
-- @return string the main character.
function lib:GetMain(alt)
	if not alt then return end

	alt = self:TitleCase(alt)

	if not Mains then
		Mains = reverseTable(Alts)
	end

    -- Check the user-defined data first.
	local main = Mains[alt]
	if main then return main end
	
	-- Check the various data sources.
	for k, v in pairs(AltsPerSource) do
	    -- Check that the reverse table is built for the data source
	    if not MainsPerSource[k] then
	        MainsPerSource[k] = reverseTable(AltsPerSource[k])
        end

	    main = MainsPerSource[k][alt]
	    if main then return main end
    end
    
    return nil
end

--- Get the main for a given alt character for a given data source.
-- @name :GetMainForSource 
-- @param alt Name of the alt character.
-- @param source The data source to use.
-- @return string the main character.
function lib:GetMainForSource(alt, source)
	if not alt then return nil end

	alt = self:TitleCase(alt)

    if not source then
    	if not Mains then
    		Mains = reverseTable(Alts)
    	end

    	return Mains[alt]
	else
        if not AltsPerSource[source] then return nil end

	    if not MainsPerSource[source] then
	        MainsPerSource[source] = reverseTable(AltsPerSource[source])
        end

	    return MainsPerSource[source][alt]
    end
end

--- Return a table of all main characters.
-- @name :GetAllMains
-- @param mains The table to fill with the mains.
function lib:GetAllMains(mains)
    if not mains then return end

    for k, v in pairs(Alts) do
        if not tContains(mains, k) then
            tinsert(mains, k)
        end
    end

    for k, v in pairs(AltsPerSource) do
        for key, val in pairs(AltsPerSource[k]) do
            if not tContains(mains, key) then
                tinsert(mains, key)
            end
        end
    end

	return mains
end

--- Return a table of all main characters for a given data source.
-- @name :GetAllMainsForSource
-- @param mains The table to fill with the mains.
-- @param source The data source to limit the mains for.  Nil for user-defined.
function lib:GetAllMainsForSource(mains, source)
    if not mains then return end

    if not source then
        for k, v in pairs(Alts) do
            tinsert(mains, k)
        end
    else
        if not AltsPerSource[source] then return nil end
        
        for k, v in pairs(AltsPerSource[source]) do
            tinsert(mains, k)
        end
    end

	return mains
end

--- Test if a character is a main.
-- @name :IsMain
-- @param main Name of the character.
-- @return boolean is this a main character.
function lib:IsMain(main)
	if not main then return nil end
	
	main = self:TitleCase(main)
	
	if Alts[main] then return true end
	
	for k, v in pairs(AltsPerSource) do
	    if AltsPerSource[k][main] then return true end
    end

	return false
end

--- Test if a character is a main for a given data source.
-- @name :IsMainForSource
-- @param main Name of the character.
-- @param source The data source to use.  Nil for user-defined.
-- @return boolean is this a main character.
function lib:IsMainForSource(main, source)
	if not main then return nil end
	
	main = self:TitleCase(main)
	
	if not source then
	    return Alts[main] and true or false
    else
        if not AltsPerSource[source] then return false end
        return AltsPerSource[source][main] and true or false
    end
end

--- Test if a character is an alt.
-- @name :IsAlt
-- @param alt Name of the character.
-- @return boolean is this a alt character.
function lib:IsAlt(alt)
	if not alt then return nil end
	
	alt = self:TitleCase(alt)
	
    if not Mains then
		Mains = reverseTable(Alts)
	end

    if Mains[alt] then return true end

    for k, v in pairs(AltsPerSource) do
        if not MainsPerSource[k] then
            MainsPerSource[k] = reverseTable(AltsPerSource[k])
        end
        
        if MainsPerSource[k][alt] then return true end
    end

	return false
end

--- Test if a character is an alt for a given data source.
-- @name :IsAltForSource
-- @param alt Name of the character.
-- @param source The data source to use.  Nil for user-defined.
-- @return boolean is this a alt character.
function lib:IsAltForSource(alt, source)
	if not alt then return nil end
	
	alt = self:TitleCase(alt)

	if not source then
        if not Mains then
    		Mains = reverseTable(Alts)
    	end

        return Mains[alt] and true or false
    else
        if not AltsPerSource[source] then return false end

        if not MainsPerSource[source] then
            MainsPerSource[source] = reverseTable(AltsPerSource[source])
        end
    
        return MainsPerSource[source][alt] and true or false
    end
end

--- Remove a Main-Alt relationship and fire a callback for the disassociation.
-- @name :DeleteAlt
-- @param main Name of the Main character.
-- @param alt Name of the Alt being removed.
-- @param source Source of the main-alt relationship.  Nil if used-defined.
function lib:DeleteAlt(main, alt, source)
	main, alt = self:TitleCase(main), self:TitleCase(alt)

    if not source then
    	if not Alts[main] then return end
    	Mains = nil
    	for i = 1, #Alts[main] do
    		if Alts[main][i] == alt then
    			tremove(Alts[main], i)
    		end
    	end
    	if #Alts[main] == 0 then
    		Alts[main] = nil
    	end
    else
        if not AltsPerSource[source] or not AltsPerSource[source][main] then return end
        MainsPerSource[source] = nil
        for i = 1, #AltsPerSource[source][main] do
            if AltsPerSource[source][main][i] == alt then
                tremove(AltsPerSource[source][main], i)
            end
        end
        if #AltsPerSource[source][main] == 0 then
            AltsPerSource[source][main] = nil
        end
    end
	callbacks:Fire("LibAlts_RemoveAlt", main, alt, source)	--Alt is the one removed
end

--- Remove a data source, including all main-alt relationships, and fire a callback.
-- @name :RemoveSource
-- @param source Data source to be removed.
function lib:RemoveSource(source)
    if AltsPerSource[source] then
        wipe(AltsPerSource[source])
        AltsPerSource[source] = nil
    end
    if MainsPerSource[source] then
        wipe(MainsPerSource[source])
        MainsPerSource[source] = nil
    end
	callbacks:Fire("LibAlts_RemoveSource", source)
end

--- Returns a name formatted in title case (i.e., first character upper case, the rest lower).
-- @name :TitleCase
-- @param name The name to be converted.
-- @return string The converted name.
function lib:TitleCase(name)
    if not name then return "" end
    if #name == 0 then return "" end

    name = name:lower()
    return name:gsub(MULTIBYTE_FIRST_CHAR, string.upper, 1)
end
    
--[[
--- Get the main for a given Real Id name.
-- @name :GetMainForRealId 
-- @param realid The Real Id name.
-- @return string The main character name, if a mapping exists.
function lib:GetMainForRealId(realid)
    if not realid then return nil end
    realid = self:TitleCase(realid)
    return RealIds[realid]
end

--- Get the Real ID name for a given main character.
-- @name :GetRealIdForMain 
-- @param main Name of the main character.
-- @return string The Real Id name for the main, if a mapping exists.
function lib:GetRealIdForMain(main)
    if not main then return nil end
    main = self:TitleCase(main)
    return RealIdMains[main]
end

--- Register a Real Id-Main relationship.
-- @name :SetRealIdForMain 
-- @param realid The Real Id name.
-- @param main Name of the main character.
function lib:SetRealIdForMain(realid, main)
    if not realid or or #realid == 0 or not main or #main == 0 then return nil end
    main = self:TitleCase(main)
    realid = self:TitleCase(realid)

    -- Add the forward and reverse mappings
    RealIds[realid] = main
    RealIdMains[main] = realid

    callbacks:Fire("LibAlts_SetRealIdForMain", realid, main)	
end

--- Test if a Real Id-Main relationship exists for a given Real Id name.
-- @name :IsRealId
-- @param realid The Real Id name.
-- @return boolean Does the Real Id-Main relationship exist.
function lib:IsRealId(realid)
    if not realid then return nil end

    return RealIds[realid] and true or false
end
]]--
