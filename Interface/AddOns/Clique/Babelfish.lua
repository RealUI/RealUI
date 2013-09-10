#!/usr/local/bin/lua

local strings = {}

for i=1,#arg do
    if arg[i] ~= arg[0] then
        local file = io.open(arg[i], "r")

        assert(file, "Could not open " .. arg[i])
        local text = file:read("*all")

        for match in string.gmatch(text, "L%[\"(.-)\"%]") do
            strings[match] = true
        end	
    end
end

local work = {}

for k,v in pairs(strings) do table.insert(work, k) end
table.sort(work)

print("local addonName, addon = ...")
print("local baseLocale = {")
for idx,match in ipairs(work) do
	print(string.format("\t[\"%s\"] = \"%s\",", match, match))
end
print("}\n")
print("addon:RegisterLocale('enUS', baseLocale)")
