-- Library of common/shared methods

local L = Grid2Options.L

-- Grid2Options:MakeStatusDeleteOptions()
do 
	local function DeleteStatus(info)
		local status   = info.arg.status
		local category = Grid2Options:GetStatusCategory(status)
		Grid2.db.profile.statuses[status.name] = nil
		Grid2:UnregisterStatus(status)
		Grid2Frame:UpdateIndicators()
		Grid2Options:DeleteStatusOptions(category, status)
	end
	function Grid2Options:MakeStatusDeleteOptions(status, options, optionParams)
		self:MakeHeaderOptions( options, "Delete")
		options.delete = {
			type = "execute",
			order = 255,
			width = "half",
			name = L["Delete"],
			desc = L["Delete this element"],
			func = DeleteStatus,
			confirm = function() return "Are you sure you want to delete this status ?" end,
			disabled = function() return next(status.indicators)~=nil end,
			arg = { status = status },
		}
	end
end

-- Grid2Options:MakeStatusColorOptions()
do
	local function GetStatusColor(info)
		local c = info.arg.status.dbx["color"..(info.arg.colorIndex)]
		return c.r, c.g, c.b, c.a
	end
	local function SetStatusColor(info, r, g, b, a)
		local status = info.arg.status
		local c = status.dbx["color"..(info.arg.colorIndex)]
		c.r, c.g, c.b, c.a = r, g, b, a
		status:UpdateDB()
		status:UpdateAllIndicators()
	end
	function Grid2Options:MakeStatusColorOptions(status, options, optionParams)
		local colorCount = status.dbx.colorCount or 1
		local name  = L["Color"]
		local desc  = L["Color for %s."]:format(status.name)
		local width = optionParams and optionParams.width or "half"
		for i = 1, colorCount do
			local colorKey = "color" .. i
			if optionParams and optionParams[colorKey] then
				name = optionParams[colorKey]
			elseif colorCount > 1 then
				name = L["Color %d"]:format(i)
			end
			local colorDescKey = "colorDesc" .. i
			if optionParams and optionParams[colorDescKey] then
				desc = optionParams[colorDescKey]
			elseif colorCount > 1 then
				desc = name
			end
			options[colorKey] = {
				type = "color",
				order = (10 + i),
				width = width,
				name = name,
				desc = desc,
				get = GetStatusColor,
				set = SetStatusColor,
				hasAlpha = true,
				arg = {status = status, colorIndex = i },
			}
		end
	end
end

-- Grid2Options:MakeStatusColorThresholdOptions()
function Grid2Options:MakeStatusColorThresholdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusThresholdOptions(status, options, optionParams)
end

-- Grid2Options:MakeStatusThresholdOptions()
function Grid2Options:MakeStatusThresholdOptions(status, options, optionParams, min, max, step)
	min = min or 0
	max = max or 1
	step = step or 0.01
	local name = optionParams and optionParams.threshold or L["Threshold"]
	local desc = optionParams and optionParams.thresholdDesc or L["Threshold at which to activate the status."]
	options.threshold = {
		type = "range",
		order = 20,
		name = name,
		desc = desc,
		min = min,
		max = max,
		step = step,
		get = function ()
			return status.dbx.threshold
		end,
		set = function (_, v)
			status.dbx.threshold = v
			status:UpdateAllIndicators()
		end,
	}
end

-- Grid2Options:MakeStatusMissingOptions()
function Grid2Options:MakeStatusMissingOptions(status, options, optionParams)
	options.threshold = {
		type = "toggle",
		name = L["Show if missing"],
		desc = L["Display status only if the buff is not active."],
		order = 110,
		tristate = false,
		get = function ()return status.dbx.missing end,
		set = function (_, v)
			status.dbx.missing = v or nil
			status:UpdateDB()
			status:UpdateAllIndicators()
		end,
	}
end

-- Grid2Options:MakeStatusToggleOptions()
function Grid2Options:MakeStatusToggleOptions(status, options, optionParams, toggleKey)
	local name = optionParams and optionParams[toggleKey] or L[toggleKey] or toggleKey
	options[toggleKey] = {
		type = "toggle",
		name = name,
		tristate = false,
		width = optionParams and optionParams.width or nil,
		get = function () return status.dbx[toggleKey] end,
		set = function (_, v)
			status.dbx[toggleKey] = v or nil
			status:UpdateDB()
			status:UpdateAllIndicators()
		end,
	}
end

-- Grid2Options:MakeStatusStandardOptions()
Grid2Options.MakeStatusStandardOptions = Grid2Options.MakeStatusColorOptions
