-- Indicators test mode module

local Test, TestIcons, TestMode

local function InitTestData()
	-- generate test icons
	TestIcons = {}
	for _, category in pairs(Grid2Options.categories) do
		if category.icon then TestIcons[#TestIcons+1] = category.icon end
	end
	for _, params in pairs(Grid2Options.optionParams) do
		if params.titleIcon then TestIcons[#TestIcons+1] = params.titleIcon end
	end
	-- create test status
	Test = Grid2.statusPrototype:new("test",false)
	function Test:IsActive()    return true end
	function Test:GetText()     return "99" end
	function Test:GetColor()    return math.random(0,1),math.random(0,1),math.random(0,1),1 end
	function Test:GetPercent()	return math.random() end
	function Test:GetIcon()	    return TestIcons[ math.random(#TestIcons) ]	end
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
			if indicator.dbx.type ~= "bar" then
				indicator:RegisterStatus(Test,1)
			end	
		end
	else
		for _, indicator in Grid2:IterateIndicators() do
			indicator:UnregisterStatus(Test)
		end
	end
	Grid2Frame:UpdateIndicators()
end
