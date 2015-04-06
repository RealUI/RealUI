local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local _
local MODNAME = "AchievementScreenshots"
local AchievementScreenshots = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Achievement Screenshots",
		desc = "Takes a screenshot whenever an achievement is earned.",
		arg = MODNAME,
		-- order = 1916,
		args = {
			header = {
				type = "header",
				name = "Achievement Screenshots",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Takes a screenshot whenever an achievement is earned.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Achievement Screenshots module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 30,
			},
		},
	}
	end
	return options
end

----------------------------------------------------------------------------------------
--	Take screenshots of Achievements(Based on Achievement Screenshotter by Blamdarot)
----------------------------------------------------------------------------------------
local function TakeScreen(delay, func, ...)
	local waitTable = {}
	local waitFrame = CreateFrame("Frame", "WaitFrame", UIParent)
	waitFrame:SetScript("onUpdate", function (self, elapse)
		local count = #waitTable
		local i = 1
		while (i <= count) do
			local waitRecord = tremove(waitTable, i)
			local d = tremove(waitRecord, 1)
			local f = tremove(waitRecord, 1)
			local p = tremove(waitRecord, 1)
			if d > elapse then
				tinsert(waitTable, i, {d-elapse, f, p})
				i = i + 1
			else
				count = count - 1
				f(unpack(p))
			end
		end
	end)
	tinsert(waitTable, {delay, func, {...} })
end

local function TakeScreenshot()
	TakeScreen(1, TakeScreenshot)
end

function AchievementScreenshots:ACHIEVEMENT_EARNED()
	TakeScreenshot()
end

function AchievementScreenshots:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function AchievementScreenshots:OnEnable()
	self:RegisterEvent("ACHIEVEMENT_EARNED")
end

function AchievementScreenshots:OnDisable()
	self:UnregisterAllEvents()
end
