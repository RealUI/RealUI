local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Alt Linking", "AceHook-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
local LA
mod.modName = L["Alt Linking"]

local NAMES
local GUILDNOTES
local pairs = _G.pairs
local select = _G.select
local setmetatable = _G.setmetatable
local tinsert = _G.tinsert
local tremove = _G.tremove
local type = _G.type
local unpack = _G.unpack
local strlower= _G.string.lower
local gmatch = _G.string.gmatch

local leftBracket, rightBracket

local defaults = { 
	realm = {}, 
	profile = {
		leftBracket = "[",
		rightBracket = "]",
		colorMode = "COLOR_MOD", 
		color = {0.6, 0.6, 0.6},
		guildNotes=true,
		guildprefix = "",
		guildsuffix = "",
		guildranks = {}
	} 
}
local colorModes = {
	COLOR_MOD = L["Use PlayerNames coloring"],
	CUSTOM = L["Use custom color"],
	CHANNEL = L["Use channel color"]
}

local customColorNames = setmetatable({}, {
	__index = function(t, v)
		local r, g, b = unpack(mod.db.profile.color)
		t[v] = ("|cff%02x%02x%02x%s|r"):format(r * 255, g  * 255, b * 255, v)
		return t[v]
	end
})


local options
function mod:GetOptions()
	options = options or {
		outputheader = {
			type = "header",
			name = L["Output"],
			order = 100,
		},
		leftbracket = {
			order = 101, 
			type = "input",
			name = L["Left Bracket"],
			desc = L["Character to use for the left bracket"],
			get = function() return mod.db.profile.leftBracket end,
			set = function(i, v)
				mod.db.profile.leftBracket = v
				leftBracket = v
			end
		},
		rightbracket = {
			order = 102,
			type = "input",
			name = L["Right Bracket"],
			desc = L["Character to use for the right bracket"],
			get = function() return mod.db.profile.rightBracket end,
			set = function(i, v)
				mod.db.profile.rightBracket = v
				rightBracket = v
			end,
		},
		colorMode = {
			order=110,
			type = "select",
			name = L["Name color"],
			desc = L["Set the coloring mode for alt names"],
			values = colorModes,
			get = function()
				return mod.db.profile.colorMode
			end,
			set = function(info, v)
				mod.db.profile.colorMode = v
			end
		},
		color = {
			order=111,
			type = "color",
			name = L["Custom color"],
			desc = L["Select the custom color to use for alt names"],
			get = function()
				return unpack(mod.db.profile.color)
			end,
			set = function(info, r, g, b)
				mod.db.profile.color[1] = r
				mod.db.profile.color[2] = g
				mod.db.profile.color[3] = b
				for k, v in pairs(customColorNames) do
					customColorNames[k] = nil
				end
			end,
			disabled = function() return mod.db.profile.colorMode ~= "CUSTOM" end
		},
		guildHeader = {
			order = 200,
			type = "header",
			name = L["Guild Notes"],
		},
		guildNotes = {
			order = 201,
			type = "toggle",
			name = L["Use guildnotes"],
			desc = L["Look in guildnotes for character names, unless a note is set manually"],
			get = function()
				return mod.db.profile.guildNotes
			end,
			set = function(info, v)
				mod.db.profile.guildNotes = v
				mod:EnableGuildNotes(v)
			end,
		},
		guildprefix = {
			order = 202,
			type = "input",
			name = L["Guild note prefix"],
			desc = L["Enter the starting character for guild note delimiters, or leave blank for none."],
			disabled = function() return not mod.db.profile.guildNotes end,
			get = function() return mod.db.profile.guildprefix end,
			set = function(info,v) 
				mod.db.profile.guildprefix = v 
				mod:ScanGuildNotes()
			end,
		},	
		guildsuffix = {
			order = 202,
			type = "input",
			name = L["Guild note suffix"],
			desc = L["Enter the ending character for guild note delimiters, or leave blank for none."],
			disabled = function() return not mod.db.profile.guildNotes end,
			get = function() return mod.db.profile.guildsuffix end,
			set = function(info,v) 
				mod.db.profile.guildsuffix = v 
				mod:ScanGuildNotes()
			end,
		},	
		rankHeader = {
			order = 204,
			type = "header",
			name = L["Alt Ranks"],
		},
	}
	return options
end

local function escape(s)
	return (s:gsub('%%', '%%%%')
	     	:gsub('%^', '%%%^')
		:gsub('%$', '%%%$')
		:gsub('%(', '%%%(')
		:gsub('%)', '%%%)')
		:gsub('%.', '%%%.')
		:gsub('%[', '%%%[')
		:gsub('%]', '%%%]')
		:gsub('%*', '%%%*')
		:gsub('%+', '%%%+')
		:gsub('%-', '%%%-')
		:gsub('%?', '%%%?'))
end


local accept = function(frame, char, editBox)
	if editBox then
		local main = editBox:GetText()
		mod:AddAlt(char, main, frame.data)
	end
	frame:Hide()
end

StaticPopupDialogs['MENUITEM_SET_MAIN'] = {
	preferredindex = STATICPOPUP_NUMDIALOGS,
	text		= L["Who is %s's main?"],
	button1		= TEXT(ACCEPT),
	button2		= TEXT(CANCEL),
	hasEditBox	= 1,
	maxLetters	= 128,
	exclusive	= 0,
	OnShow = function(frame)
		_G[frame:GetName().."EditBox"]:SetFocus()
	end,
	OnHide = function(frame)
		if ( _G[frame:GetName().."EditBox"]:IsShown() ) then
			_G[frame:GetName().."EditBox"]:SetFocus();
		end
		_G[frame:GetName().."EditBox"]:SetText("");
	end,
	OnAccept = function(popup,char)
		accept(popup,char,_G[popup:GetName().."EditBox"])
	end,
	EditBoxOnEnterPressed = function(popup,char)
		accept(popup,char,_G[popup:GetName().."EditBox"])
	end,
	EditBoxOnEscapePressed = function(frame) frame:GetParent():Hide() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = 1
}	

UnitPopupButtons["SET_MAIN"] = {
	text = L["Set Main"],
	dist = 0,
	func = mod.GetMainName
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("AltLinks", defaults)
end

function mod:Decorate(frame)
	self:RawHook(frame, "AddMessage", true)
end

function mod:LA_SetAlt(event,main,alt,source)
	if not source then
		NAMES[alt] = main
	end
end

function mod:LA_RemoveAlt(event,main,alt,source)
	if not source then
		NAMES[alt] = nil
	else
		GUILDNOTES[alt] = nil
	end
end

function mod:OnEnable()
	LA = LibStub("LibAlts-1.0")
	LA.RegisterCallback( self, "LibAlts_SetAlt","LA_SetAlt")
	LA.RegisterCallback( self, "LibAlts_RemoveAlt","LA_RemoveAlt")
	NAMES = self.db.realm
	for k,v in pairs(NAMES) do
		LA:SetAlt(v,k,nil)
	end
	UnitPopupButtons["SET_MAIN"].func = self.GetMainName
	tinsert(UnitPopupMenus["SELF"], 	#UnitPopupMenus["SELF"] - 1,	"SET_MAIN")
	tinsert(UnitPopupMenus["PLAYER"], 	#UnitPopupMenus["PLAYER"] - 1,	"SET_MAIN")
	tinsert(UnitPopupMenus["FRIEND"],	#UnitPopupMenus["FRIEND"] - 1,	"SET_MAIN")
	tinsert(UnitPopupMenus["PARTY"], 	#UnitPopupMenus["PARTY"] - 1,	"SET_MAIN")
	self:SecureHook("UnitPopup_ShowMenu")

	leftBracket, rightBracket = self.db.profile.leftBracket, self.db.profile.rightBracket
	
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		if cf ~= COMBATLOG then
			self:RawHook(cf, "AddMessage", true)
		end
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			cf.altHooked = true
			self:RawHook(cf, "AddMessage", true)
		end
	end
	self.colorMod = Chatter:GetModule("Player Class Colors")
	mod:EnableGuildNotes(mod.db.profile.guildNotes)
end

local types = {"SELF", "PLAYER", "FRIEND", "PARTY"}
function mod:OnDisable()
	for j = 1, #types do
		local t = types[j]
		for i = 1, #UnitPopupMenus[t] do
			if UnitPopupMenus[t][i] == "SET_MAIN" then
				tremove(UnitPopupMenus[t], i)
				break
			end
		end
	end
	mod:EnableGuildNotes(false)
end


function mod.GetMainName()
	local alt = UIDROPDOWNMENU_INIT_MENU.name
	local popup = StaticPopup_Show("MENUITEM_SET_MAIN", alt)
	if popup then 
		popup.data = alt 
		local editbox = _G[popup:GetName().."EditBox"]
		editbox:SetText(NAMES[alt] or GUILDNOTES[alt] or "")
		editbox:HighlightText()
	end
end

function mod:UnitPopup_ShowMenu(dropdownMenu, which, unit, name, userData, ...)
	for i=1, UIDROPDOWNMENU_MAXBUTTONS do
		local button = _G["DropDownList"..UIDROPDOWNMENU_MENU_LEVEL.."Button"..i];
		if button.value == "SET_MAIN" then
		    button.func = UnitPopupButtons["SET_MAIN"].func
		end
	end
end

function mod:AddAlt(alt, main)
	if #main == 0 then 
		if GUILDNOTES[alt] then
			-- let the user store an empty note, meaning "dont show me this main"
		else
			NAMES[alt] = nil
			LA:DeleteAlt(NAMES[alt],alt,nil)
			main = nil 
		end
	end
	if main then
		LA:SetAlt(main,alt,nil)
	end
end

local function pName(msg, name)
	if name and #name > 0 then
		local alt = NAMES[name] or GUILDNOTES[name]
		if alt and alt ~= "" then		-- empty notes can be stored to override guildnote data
			local mode = mod.db.profile.colorMode
			if mode == "CUSTOM" then				
				alt = customColorNames[alt]
			elseif mode == "COLOR_MOD" and mod.colorMod and mod.colorMod:IsEnabled() then
				alt = mod.colorMod:ColorName(alt)
			end
			return ("%s%s%s%s"):format( msg, leftBracket, alt, rightBracket )
		end
	end
	return msg
end

function mod:AddMessage(frame, text, ...)
	if text and type(text) == "string" then 
		--text = text:gsub("(|Hplayer:([^:]+)[:%d+]*|h.-|h)", pName)
		text = text:gsub("(|Hplayer:([^:]+).-|h.-|h)", pName)
	end
	return self.hooks[frame].AddMessage(frame, text, ...)
end

function mod:Info()
	return L["Enables you to right-click a person's name in chat and set a note on them to be displayed in chat, such as their main character's name. Can also scan guild notes for character names to display, if no note has been manually set."]
end

function mod:EnableGuildNotes(enable)
	GUILDNOTES={}
	if enable then
		if IsInGuild() then
			GuildRoster()
			local ranks = {}
			for i = 1, (GetNumGuildMembers()) do
				local _, rank, index = GetGuildRosterInfo(i)
				ranks[index] = rank
			end
			for k,v in pairs(ranks) do
				self.db.profile.guildranks[k] = self.db.profile.guildranks[k] or false
				options["rank"..k] = {
					type = "toggle",
					name = v,
					desc = L["Use notes as main character names for this rank."],
					order = 205+k,
					get = function() return self.db.profile.guildranks[k] end,
					set = function(info,value) self.db.profile.guildranks[k] = value end,
					disabled = function() return not mod.db.profile.guildNotes end,
				}
			end

		end
		mod:ScanGuildNotes()	-- Unfortunately we can't count on GuildRoster() triggering the event if someone else triggered it recently. So we try once at first straight off the bat.
		mod:RegisterEvent("GUILD_ROSTER_UPDATE")
	else
		mod:UnregisterEvent("GUILD_ROSTER_UPDATE")
	end
end

local doscan=true	-- always the first time we start up
local guild_available=false
function mod:GUILD_ROSTER_UPDATE(event,arg1)
	if not guild_available then
		local check = GetGuildRosterInfo(1)
		if not check then
			self:ScheduleTimer("GUILD_ROSTER_UPDATE", 0.1, true)
			return
		else
			self:CancelTimer("GUILD_ROSTER_UPDATE", true)
			guild_available=true
		end
	end
	
	-- arg1 gets set for SOME changes to the guild, but notably not for player notes.. doh  (unless you're the one editing them yourself)
	-- we force a scan when the guild frame is actually visible (i.e. when we know the player is actually interested in seeing changes)
	-- i'd like to be able to not have the guildframe check there, but there's plenty of stupid-ass addons that spam GuildRoster() every 10/15/20 seconds, so ... no.
	if arg1 or (GuildFrame and GuildFrame:IsVisible()) or doscan then
		doscan=false
		mod:ScanGuildNotes()
	end
	
	if arg1 then
		-- but it appears that when arg1 is set, the player note change isn't available yet; that happens on the next arg1=nil update (about 0.1s later), so catch that one too. ghod this is messy.
		doscan=true	
	end
end

function mod:ScanGuildNotes()
	if not IsInGuild() then
		return
	end
	local gName,_,_ = GetGuildInfo("player")
	-- edge case sometimes this comes back as nil dont know why
	if not gName then
		return
	end
	--DBG print("Scanning guildnotes!")
	--DBG local n,nFallback=0,0
	local names = {}  -- ["playername"]="Playername"   (note lowercase = uppercase) (yes, this works for 'foreign' letters too in WoW, even though it does not in standard Lua)
	GUILDNOTES = {} -- Yes, we do want to zap it, otherwise we end up storing notes for people being promoted/demoted through alt ranks and stuff
	
	-- #1: find all names
	for i=1,GetNumGuildMembers(true) do
		local name = (GetGuildRosterInfo(i))
		names[strlower(name or "?")] = name
	end
	
	-- #2: scan all words in all guild notes, see if a name is mentioned
	for i=1,GetNumGuildMembers(true) do
		local name, rank, rankIndex, level, class, zone, note, officernote, online, status = GetGuildRosterInfo(i);
		local success
		if self.db.profile.guildranks[rankIndex] then
			for word in gmatch(strlower(note), self.db.profile.guildprefix.."[%a\128-\255]+"..self.db.profile.guildsuffix) do
				word = gsub(word, "^"..(escape(self.db.profile.guildprefix)), "")
				word = gsub(word, (escape(self.db.profile.guildsuffix)).."$", "")
				if names[word] then
					GUILDNOTES[name] = names[word]
					LA:SetAlt(name,names[word],LA.GUILD_PREFIX..gName)
					success = true
					--DBG n=n+1
					break
				end
			end
		end
	end
	--DBG print("Mapped",n,"names and",nFallback,"fallbacks!")
end
