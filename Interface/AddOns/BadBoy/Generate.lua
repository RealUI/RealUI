
local _, t = ...

t.gen = function(entry)
	local tbl = {}
	local pos = 0
	local str = ""
	for i = 1, select("#", strsplit("^", entry)) do
		local db = select(i, strsplit("^", entry))
		for j = 1, select("#", strsplit(",", db)) do
			local text = select(j, strsplit(",", db))
			local n = tonumber(text)
			if j == 1 then
				if pos > 0 then
					tbl[pos] = str
					str = ""
				end
				pos = pos + 1
			end
			str = str .. string.char(n)
		end
	end
	tbl[pos] = str
	return tbl
end
