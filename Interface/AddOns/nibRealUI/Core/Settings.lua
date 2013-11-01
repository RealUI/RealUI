local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, dbc, dbg

local nibRealUICharacter_defaults = {
	installStage = 0,
	initialized = false,
	needchatmoved = true,
}

-- Minipatch list. These get flagged on a PrimaryInstall as not being required.
local MiniPatchMajorVer = "80"
local MiniPatches = {1,2,6,8,9,12,16,21}

local Textures = {
	Logo = [[Interface\AddOns\nibRealUI\Media\Install\Logo.tga]],
}
local IWF = {}

-- CVars
local function SetDefaultCVars()
	-- Graphics
	if GetCVar("gxMultisample") ~= "1" then
		SetCVar("gxMultisample", 1)
		RestartGx()
	end
	-- Sound
	SetCVar("Sound_EnableErrorSpeech", 0)
	-- Nameplates
	SetCVar("bloatTest", 0)
	SetCVar("bloatnameplates", 0)
	SetCVar("bloatthreat", 0)
	-- Screenshots
	SetCVar("screenshotFormat", "jpg")				-- JPG format
	SetCVar("screenshotQuality", "10")				-- Highest quality
	-- Help
	SetCVar("showGameTips", 0)						-- Turn off Loading Screen Tips
	SetCVar("showTutorials", 0)						-- Turn off Tutorials
	SetCVar("UberTooltips", 1)						-- Turn on Enhanced Tooltips
	SetCVar("scriptErrors", 1)						-- Turn on Display Lua Errors
	-- Controls
	SetCVar("deselectOnClick", 1)					-- Turn off Sticky Targeting (inverted)
	-- Combat
	SetCVar("displaySpellActivationOverlays", 1)	-- Turn on Spell Alerts
	SetCVar("spellActivationOverlayOpacity", 0.75)	-- Spell Alert Opacity
	-- Display
	SetCVar("emphasizeMySpellEffects", 0)			-- Turn off Emphasize My Spell Effects
	SetCVar("SpellTooltip_DisplayAvgValues", 0)		-- Turn off Display Points As Average
	-- Social
	SetCVar("chatBubbles", 0)						-- Turn off Chat Bubbles
	SetCVar("chatBubblesParty", 0)					-- Turn off Party Chat Bubbles
	SetCVar("chatStyle", "classic")					-- Chat Style = "Classic"
	SetCVar("conversationMode", "inline")			-- Conversation Mode = "In-line"
	-- Quests
	SetCVar("autoQuestWatch", 1)					-- Auto Track Quests
	SetCVar("mapQuestDifficulty", 1)				-- Color Quests by Difficulty on World Map
	-- Names
	SetCVar("UnitNameNPC", 1)						-- Turn on NPC Names
	SetCVar("UnitNamePlayerPVPTitle", 0)			-- Turn off PvP Player Titles
	SetCVar("UnitNameEnemyGuardianName", 1)			-- Turn on Enemy Pet Names
	SetCVar("UnitNameEnemyTotemName", 1)			-- Turn on Enemy Totem Names
	SetCVar("nameplateMotion", 1)					-- Stacking Nameplates
	-- Camera
	SetCVar("cameraYawSmoothSpeed", 210)
	SetCVar("cameraView", 1)						-- Camera Stlye
	SetCVar("cameraDistanceMax", 50)				-- Camera Max Distance
	SetCVar("cameraDistanceMaxFactor", 2)			-- Camera Follow Speed
	-- Quality of Life
	SetCVar("guildShowOffline", 0)					-- Hide Offline Guild Members
	SetCVar("profanityFilter", 0)					-- Turn off Profanity Filter
	-- Combat Text
	if IsAddOnLoaded("MikScrollingBattleText") then
		SetCVar("enableCombatText", 0)				-- Turn off Combat Text
		SetCVar("CombatDamage", 0)					-- Turn off Combat Text - Damage
		SetCVar("CombatHealing", 0)					-- Turn off Combat Text - Healing
	end
end

-- Initial Settings
local function InitialSettings()
	---- Chat
	-- Lock chat frames
	for i = 1, 10 do
		local cf = _G["ChatFrame"..i]
		if cf then FCF_SetLocked(cf, 1) end
    end

	-- Set all chat channels to color player names by class
	for k, v in pairs(CHAT_CONFIG_CHAT_LEFT) do
		ToggleChatColorNamesByClassGroup(true, v.type)
	end
	for iCh = 1, 15 do
		ToggleChatColorNamesByClassGroup(true, "CHANNEL"..iCh)
	end

	-- Make Chat windows transparent
	SetChatWindowAlpha(1, 0)
	SetChatWindowAlpha(2, 0)
	
	-- Initial Settings done
	nibRealUICharacter.initialized = true
end

---- Primary Installation
---- Stage 1
function RealUI_RunStage1()
	nibRealUICharacter.installStage = -1
	
	if dbg.tags.firsttime then
		dbg.tags.firsttime = false
		dbg.tutorial.stage = 0
		
		---- Addon Data
		-- Initialize DXE
		if IsAddOnLoaded("DXE_Loader") and not IsAddOnLoaded("DXE") then
			SlashCmdList.DXE()
		end

		-- Initialize Grid2
		if Grid2 and Grid2.LoadConfig then
			Grid2:LoadConfig()
		end

		-- Addon settings
		nibRealUI:LoadAddonData()

		---- Extra addon tweaks
		-- Grid - Healing frame height
		local resWidth, resHeight = nibRealUI:GetResolutionVals()
		if resHeight < 900 then
			if Grid2DB and Grid2DB["namespaces"]["Grid2Frame"]["profiles"]["RealUI-Healing"] then
				Grid2DB["namespaces"]["Grid2Frame"]["profiles"]["RealUI-Healing"]["frameHeight"] = 25
			end
		end
	end
	
	-- Make Chat windows transparent (again)
	SetChatWindowAlpha(1, 0)
	SetChatWindowAlpha(2, 0)
	
	-- Addon Profiles
	nibRealUI:SetProfileKeys()
end

local function CreateIWTextureFrame(texture, width, height, position, color)
	local frame = CreateFrame("Frame", nil, IWF)
	frame:SetParent(IWF)
	frame:SetPoint(unpack(position))
	frame:SetFrameStrata("DIALOG")
	frame:SetFrameLevel(IWF:GetFrameLevel() + 1)
	frame:SetWidth(width)
	frame:SetHeight(height)
	
	frame.bg = frame:CreateTexture()
	frame.bg:SetAllPoints(frame)
	frame.bg:SetTexture(texture)
	frame.bg:SetVertexColor(unpack(color))
	
	return frame
end

local function CreateInstallWindow()
	-- To help with debugging
	local bdAlpha, ibSizeOffs = 0.9, 0
	if nibRealUI.key == "Real - Zul'jin" then
		bdAlpha = 0.5
		ibSizeOffs = 300
	end

	-- Background
	IWF = CreateFrame("Frame", nil, UIParent)
	IWF:Hide()
		IWF:SetParent(UIParent)
		IWF:SetAllPoints(UIParent)
		IWF:SetFrameStrata("DIALOG")
		IWF:SetFrameLevel(0)
	IWF:SetBackdrop({
		bgFile = nibRealUI.media.textures.plain,
	})
	IWF:SetBackdropColor(0, 0, 0, bdAlpha)
	nibRealUI:AddStripeTex(IWF)
	
	-- Logo
	IWF.logo = CreateIWTextureFrame(Textures.Logo, 256, 256, {"BOTTOM", IWF, "CENTER", 0, 0}, {1, 1, 1, 1})

	-- Line
	local numMovers, moverLength, minSpeed = 4, 2, 6
	local line = IWF:CreateTexture(nil, "ARTWORK")
	line:SetPoint("TOPLEFT", IWF, "LEFT", 0, 0)
	line:SetPoint("BOTTOMRIGHT", IWF, "RIGHT", 0, -1)
	line:SetTexture(1, 1, 1, 0.2)
	line.squareTravelLength = UIParent:GetWidth() + moverLength * 2

	-- Moving Line Squares
	local lineSquares = {}
	for i = 1, numMovers do
		lineSquares[i] = CreateFrame("Frame", nil, IWF)
		local lS = lineSquares[i]

		lS:SetSize(moverLength, 1)
		lS.bg = lS:CreateTexture()
			lS.bg:SetAllPoints()
			lS.bg:SetTexture(1, 1, 1, 0.3)

		lS.curX = random(0, line.squareTravelLength) - (line.squareTravelLength / 2)
		lS.direction = i > (numMovers / 2) and -1 or 1
		lS.speed = random(minSpeed, minSpeed + numMovers)
		if (i > 1) and (lS.speed == lineSquares[i - 1].speed) then
			lS.speed = lS.speed + 1
		end
		lS:SetScript("OnUpdate", function(s, e)
			s:ClearAllPoints()
			s.curX = s.curX + s.direction * s.speed
			if s.curX > (line.squareTravelLength / 2) then
				s.curX = -(line.squareTravelLength / 2)
			elseif s.curX < -(line.squareTravelLength / 2) then
				s.curX = (line.squareTravelLength / 2)
			end
			s:SetPoint("BOTTOM", line, "BOTTOM", s.curX, 0)
		end)
	end

	-- Version string
	IWF.verStr = IWF:CreateFontString(nil, "OVERLAY")
		IWF.verStr:SetFont(nibRealUI.font.standard, 18)
		IWF.verStr:SetText(L["Version"].." "..nibRealUI:GetVerString(true))
		IWF.verStr:SetPoint("TOP", IWF, "CENTER", 0, -12)
	
	-- Button
	IWF.install = CreateFrame("Button", "RealUI_Install", IWF, "SecureActionButtonTemplate")
		IWF.install:SetPoint("CENTER")
		IWF.install:SetSize(UIParent:GetWidth() - ibSizeOffs, UIParent:GetHeight() - ibSizeOffs)
	IWF.install:RegisterForClicks("LeftButtonUp")
	IWF.install:SetScript("OnClick", function()
		RealUI_RunStage1()
		ReloadUI()
	end)

	-- Click To Install frame + string
	IWF.installTextFrame = CreateFrame("Frame", nil, IWF)
		IWF.installTextFrame:SetPoint("BOTTOM", 0, UIParent:GetHeight() / 4)
		IWF.installTextFrame:SetSize(2,2)
	IWF.installTextFrame.aniGroup = IWF.installTextFrame:CreateAnimationGroup() 
		IWF.installTextFrame.aniGroup:SetLooping("BOUNCE")
		IWF.installTextFrame.fade = IWF.installTextFrame.aniGroup:CreateAnimation("Alpha")
		IWF.installTextFrame.fade:SetDuration(1)
		IWF.installTextFrame.fade:SetChange(-0.5)
		IWF.installTextFrame.fade:SetOrder(1)
		IWF.installTextFrame.fade:SetSmoothing("IN_OUT")
	IWF.installTextFrame.aniGroup:Play()

	IWF.installText = IWF.installTextFrame:CreateFontString(nil, "OVERLAY")
		IWF.installText:SetPoint("BOTTOM")
		IWF.installText:SetFont(nibRealUI.font.standard, 18)
		IWF.installText:SetText("[ "..L["INSTALL"].." ]")

	-- Combat Check
	IWF:RegisterEvent("PLAYER_ENTERING_WORLD")
	IWF:RegisterEvent("PLAYER_REGEN_ENABLED")
	IWF:RegisterEvent("PLAYER_REGEN_DISABLED")
	IWF:SetScript("OnEvent", function(self, event)
		if event == "PLAYER_ENTERING_WORLD" then
			if not(InCombatLockdown()) then
				IWF:Show()
			end
		elseif event == "PLAYER_REGEN_DISABLED" then
			IWF:Hide()
			print("|cffff0000RealUI Installation paused until you leave combat.|r")
		else
			IWF:Show()
		end
	end)
end

local function InstallationStage1()
	---- Create Installation Window
	CreateInstallWindow()
	
	---- First Time
	if dbg.tags.firsttime then
		-- CVars
		SetDefaultCVars()
	end
	
	---- Initial Character Settings
	if not nibRealUICharacter.initialized then
		InitialSettings()
	end
	
	---- Set MiniPatch flags
	dbg.minipatches = {}
	for k,v in ipairs(MiniPatches) do
		dbg.minipatches[k] = v
	end
	
	DEFAULT_CHATFRAME_ALPHA = 0
end

---- Process
local function PrimaryInstallation()
	if nibRealUICharacter.installStage > -1 then
		InstallationStage1()
	end
end

-- Mini Patch
local function ApplyMiniPatches(np, accepted)
	for k,v in ipairs(np) do
		if v then
			if accepted then
				nibRealUI:MiniPatch(MiniPatchMajorVer.."r"..tostring(MiniPatches[k]))
			end
			dbg.minipatches[k] = MiniPatches[k]
		end
	end
end

local function MiniPatchInstallation()
	local CurVer = nibRealUI.verinfo
	if CurVer[1] == 8 and CurVer[2] == 0 then
		-- Find out which Mini Patches are needed
		local NP = {}
		local needPatchCount = 0
		for k,v in ipairs(MiniPatches) do
			NP[k] = true
			needPatchCount = needPatchCount + 1
		end
		if dbg.minipatches ~= nil then
			for k,v in ipairs(dbg.minipatches) do
				NP[k] = false
				needPatchCount = needPatchCount - 1
			end
		end
		
		-- Run through MiniPatches
		local toPatch = {}
		local MiniPatchAccepted = false
		if dbg.minipatches == nil then dbg.minipatches = {} end

		if needPatchCount > 0 then
			StaticPopupDialogs["PUDRUIMP"] = {
				text = "|cff85e0ff"..L["RealUI Mini Patch"].."|r\n\n|cffffffff"..L["Do you wish to apply the latest RealUI settings?"],
				button1 = "Yes",
				button2 = "No",
				OnAccept = function()
					ApplyMiniPatches(NP, true)
					ReloadUI()
				end,
				OnCancel = function()
					ApplyMiniPatches(NP, false)
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = false,
				notClosableByLogout = false,
			}
			StaticPopup_Show("PUDRUIMP")
		end
	end
end

---- Install Procedure
function nibRealUI:InstallProcedure()
	db = self.db.profile
	dbc = self.db.char
	dbg = self.db.global
	
	---- Version checking
	local CurVer = nibRealUI.verinfo
	local OldVer = nibRealUI.verinfo
	local IsNewVer = nibRealUI:MajorVerChange(OldVer, CurVer)
	
	-- nibRealUIVersion = nibRealUI.verinfo
	
	-- Reset DB if new Major version
	if IsNewVer then
		nibRealUI.db:ResetDB("RealUI")
		if StaticPopup1 then
			StaticPopup1:Hide()
		end
	end

	-- Set Char defaults
	if not(db.registeredChars[self.key]) or not(nibRealUICharacter) or IsNewVer or not(nibRealUICharacter.installStage) then
		nibRealUICharacter = nibRealUICharacter_defaults
		db.registeredChars[self.key] = true
	end
	
	-- Primary Stages
	if nibRealUICharacter.installStage > -1 then
		PrimaryInstallation()
		
	-- Mini Patch
	else
		MiniPatchInstallation()
	end
end