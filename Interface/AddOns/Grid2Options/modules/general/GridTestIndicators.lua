-- Indicators test mode module

local TestMode -- Boolean
local Test     -- Test indicator
local Exclude = { bar = true, multibar = true, alpha = true }

local function InitTestData()
	-- generate test icons
	local TestIcons = {}
	local TestAuras = {	textures = {}, counts = {}, expirations = {}, durations = {}, colors = {} }
	for _, category in pairs(Grid2Options.categories) do
		if category.icon then TestIcons[#TestIcons+1] = category.icon end
	end
	for _, params in pairs(Grid2Options.optionParams) do
		if params.titleIcon then TestIcons[#TestIcons+1] = params.titleIcon end
	end
	local time, color = GetTime(), { r=1,g=1,b=1,a=0.6 }
	for i=1,#TestIcons do
		TestAuras.textures[i]    = TestIcons[i]
		TestAuras.counts[i]      = math.random(1,3)
		TestAuras.expirations[i] = time+math.random(10,60)
		TestAuras.durations[i]   = math.random(30) + 3
		TestAuras.colors[i]      = color
	end
	-- create test status
	Test = Grid2.statusPrototype:new("test",false)
	function Test:IsActive()    return true end
	function Test:GetText()     return "99" end
	function Test:GetColor()    return math.random(0,1),math.random(0,1),math.random(0,1),1 end
	function Test:GetPercent()	return math.random() end
	function Test:GetIcon()	    return TestIcons[ math.random(#TestIcons) ]	end
	function Test:GetIcons() 	return #TestIcons, TestAuras.textures, TestAuras.counts, TestAuras.expirations, TestAuras.durations, TestAuras.colors end
	Test.dbx = TestIcons -- Asigned to TestIcons to avoid creating a new table
	Grid2:RegisterStatus( Test, {"text","color", "percent", "icon"}, "test" )
	--
	InitTestData = Grid2.Dummy
end

function Grid2Options:IndicatorsTestMode()
	InitTestData()
	TestMode = not TestMode
	if TestMode then
		for _, indicator in Grid2:IterateIndicators() do
			if not Exclude[indicator.dbx.type] then
				indicator:RegisterStatus(Test,1)
			end	
		end
	else
		for _, indicator in Grid2:IterateIndicators() do
			if not Exclude[indicator.dbx.type] then
				indicator:UnregisterStatus(Test)
			end	
		end
	end
	Grid2Frame:UpdateIndicators()
end
