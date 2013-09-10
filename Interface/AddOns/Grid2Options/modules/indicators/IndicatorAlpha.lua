
Grid2Options:RegisterIndicatorOptions("alpha",  false, function(self, indicator)
	local options = {}
	self:MakeIndicatorStatusOptions(indicator, options)
	self:AddIndicatorOptions(indicator, options)
end)




