local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb

local _
local MODNAME = "HuDConfig_ActionBars"
local HuDConfig_ActionBars = nibRealUI:NewModule(MODNAME)

local Bar4
local buttonSizes = {
	bars = 26,
	petBar = 22,
	stanceBar = 22,
}

local function IsOdd(val)
	return val % 2 == 1 and true or false
end

function HuDConfig_ActionBars:ApplySettings(tag)
	if not IsAddOnLoaded("Bartender4") then return end
	if not nibRealUICharacter then return end
	if nibRealUICharacter.installStage ~= -1 then return end

	-- Font
	local font = nibRealUI.font.pixel1
	for i = 1, 120 do
		local button = _G["BT4Button"..i];
		if button then
			local name = button:GetName();
			local count = _G[name.."Count"];
			local hotkey = _G[name.."HotKey"];
			
			if count then
				count:SetFont(unpack(font))
			end
			hotkey:SetFont(unpack(font))
		end
	end
	if ExtraActionButton1 then
		ExtraActionButton1HotKey:SetFont(unpack(nibRealUI:Font(false, "small")))
		ExtraActionButton1HotKey:SetPoint("TOPLEFT", ExtraActionButton1, "TOPLEFT", 1.5, -1.5)
		ExtraActionButton1Count:SetFont(unpack(nibRealUI.font.pixelCooldown))
		ExtraActionButton1Count:SetPoint("BOTTOMRIGHT", ExtraActionButton1, "BOTTOMRIGHT", -2.5, 1.5)
	end


	-- Bar Settings
	if not(nibRealUI:DoesAddonMove("Bartender4")) then return end
	if InCombatLockdown() then return end
	
	
	local prof = nibRealUI.cLayout == 1 and "RealUI" or "RealUI-Healing"
	if not(Bar4 and Bartender4DB and Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]) then return end

	local barSettings = ndb.actionBarSettings[nibRealUI.cLayout]

	local topBars, numTopBars, bottomBars, sidePositions
	if not tag then
		-- Convert settings to tables
		if barSettings.centerPositions == 1 then
			topBars = {false, false, false}
			bottomBars = {true, true, true}
			numTopBars = 0
		elseif barSettings.centerPositions == 2 then
			topBars = {true, false, false}
			bottomBars = {false, true, true}
			numTopBars = 1
		elseif barSettings.centerPositions == 3 then
			topBars = {true, true, false}
			bottomBars = {false, false, true}
			numTopBars = 2
		else
			topBars = {true, true, true}
			bottomBars = {false, false, false}
			numTopBars = 3
		end
		if barSettings.sidePositions == 1 then
			sidePositions = {[4] = "RIGHT", [5] = "RIGHT"}
		elseif barSettings.sidePositions == 2 then
			sidePositions = {[4] = "RIGHT", [5] = "LEFT"}
		else
			sidePositions = {[4] = "LEFT", [5] = "LEFT"}
		end
		
		local HuDY = ndb.positions[nibRealUI.cLayout]["HuDY"]
		local ABY = ndb.positions[nibRealUI.cLayout]["ActionBarsY"] + (nibRealUI.hudSizeOffsets[ndb.settings.hudSize]["ActionBarsY"] or 0)

		----
		-- Calculate Width/Height of bars and their corresponding Left/Top points
		----
		local BarSizes = {}
		local CenterBarVertPadding = {}
		local BarPadding = {top = {}, bottom = {}, sides = {}}
		for i = 1, 5 do
			local isVertBar = i > 3
			local isRightBar = isVertBar and sidePositions[i] == "RIGHT"
			local isTopBar = not(isVertBar) and topBars[i] == true
			local isBottomBar = not(isVertBar) and not(isTopBar)
			local numButtons = barSettings.bars[i].buttons
			local padding = barSettings.bars[i].padding

			BarSizes[i] = (buttonSizes.bars * numButtons) + (padding * (numButtons - 1))

			-- Create Padding table
			if isTopBar then
				BarPadding.top[i] = padding
			elseif isBottomBar then
				BarPadding.bottom[i] = padding
			else
				BarPadding.sides[i] = padding
			end

			-- Calculate vertical padding of Center bars
			if isTopBar or isBottomBar then
				CenterBarVertPadding[i] = padding / 2
			end
		end

		----
		-- Calculate bars X and Y positions
		----
		local BarPoints = {}
		local BarPositions = {}
		for i = 1, 5 do
			local isVertBar = i > 3
			local isRightBar = isVertBar and sidePositions[i] == "RIGHT"
			local isLeftBar = isVertBar and not(isRightBar)
			local isTopBar = not(isVertBar) and topBars[i] == true
			local isBottomBar = not(isVertBar) and not(isTopBar)

			local x, y

			-- Side Bars
			if isVertBar then
				x = isRightBar and -36 or -8

				if sidePositions[4] == sidePositions[5] then
					-- Link Side Bar settings
					if i == 4 then
						y = BarSizes[4] + BarPadding.sides[4] + 10.5
					else
						y = 10.5
					end
				else
					y = (BarSizes[i] / 2) + 10
					if not(IsOdd(BarPadding.sides[i])) or IsOdd(barSettings.bars[i].buttons) then y = y + 0.5 end
				end

				BarPositions[i] = sidePositions[i]

			-- Top/Bottom Bars
			else
				x = -((BarSizes[i] / 2) + 10)
				-- if IsOdd(barSettings.bars[i].buttons) then x = x + 0.5 end

				-- Extra on X for pixel perfection
				if isTopBar then
					if not(IsOdd(BarPadding.top[i])) or IsOdd(barSettings.bars[i].buttons) then x = x + 0.5 end
				else
					if not(IsOdd(BarPadding.bottom[i])) or IsOdd(barSettings.bars[i].buttons) then x = x + 0.5 end
				end

				-- Bar Place
				local barPlace
				if i == 1 then 
					if numTopBars > 0 then
						barPlace = 1
					else
						barPlace = 3 - numTopBars	-- Want Bottom Bars stacking Top->Down
					end

				elseif i == 2 then
					barPlace = 2

				elseif i == 3 then
					if isTopBar then
						barPlace = 3
					else
						barPlace = 1
					end
				end

				-- y Offset
				if barPlace == 1 then
					if isTopBar then
						y = HuDY + ABY
					else
						y = 37
					end
				elseif barPlace == 2 then
					if isTopBar then
						local padding = ceil(CenterBarVertPadding[1] + CenterBarVertPadding[2])
						y = -(buttonSizes.bars + padding) + HuDY + ABY
					else
						local padding = ceil(CenterBarVertPadding[2] + CenterBarVertPadding[3])
						y = buttonSizes.bars + padding + 37
					end
				else
					local padding = ceil(CenterBarVertPadding[1] + (CenterBarVertPadding[2] * 2) + CenterBarVertPadding[3])
					if isTopBar then
						y = -((buttonSizes.bars * 2) + padding) + HuDY + ABY
					else
						y = (buttonSizes.bars * 2) + padding + 37
					end
				end

				BarPositions[i] = isTopBar and "TOP" or "BOTTOM"
			end

			BarPoints[i] = {
				x = x,
				y = y
			}
		end

		-- Profile Data
		if Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]["actionbars"] then
			for i = 1, 5 do
				local point
				if i <= 3 then
					point = BarPositions[i] == "TOP" and "CENTER" or "BOTTOM"
				else
					point = BarPositions[i]
				end

				Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]["actionbars"][i]["position"] = {
					["x"] = BarPoints[i].x,
					["y"] = BarPoints[i].y,
					["point"] = point,
					["scale"] = 1,
					["growHorizontal"] = "RIGHT",
					["growVertical"] = "DOWN",
				}
				Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]["actionbars"][i]["buttons"] = barSettings.bars[i].buttons
				Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]["actionbars"][i]["padding"] = barSettings.bars[i].padding - 10

				if i < 4 then
					Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]["actionbars"][i]["flyoutDirection"] = sidePositions[i] == "UP"
				else
					Bartender4DB["namespaces"]["ActionBars"]["profiles"][prof]["actionbars"][i]["flyoutDirection"] = sidePositions[i] == "LEFT" and "RIGHT" or "LEFT"
				end
			end
		end
		local B4Bars = Bar4:GetModule("ActionBars", true)
		if B4Bars then B4Bars:ApplyConfig() end
		for i = 1, 5 do
			if B4Bars.actionbars[i] then
				B4Bars.actionbars[i].SetButtons(B4Bars.actionbars[i])
			end
		end

		----
		-- Vehicle Bar
		----
		local vbX, vbY
		vbX = -36
		vbY = -59.5

		-- Set Position
		if Bartender4DB["namespaces"]["Vehicle"]["profiles"][prof] then
			Bartender4DB["namespaces"]["Vehicle"]["profiles"][prof]["position"] = {
				["x"] = vbX,
				["y"] = vbY,
				["point"] = "TOPRIGHT",
				["scale"] = 0.84,
				["growHorizontal"] = "RIGHT",
				["growVertical"] = "DOWN",
			}
		end
		local B4Vehicle = Bar4:GetModule("Vehicle", true)
		if B4Vehicle then B4Vehicle:ApplyConfig() end

		----
		-- Pet Bar
		----
		if barSettings.moveBars.pet then
			if nibRealUI.cLayout == 1 then
				local numPetBarButtons = 10
				local pbX, pbY, pbPoint
				local pbP = barSettings.petBar.padding
				local pbH = (numPetBarButtons * buttonSizes.petBar) + ((numPetBarButtons - 1) * pbP)

				-- Calculate X
				if (sidePositions[4] == "LEFT") and (sidePositions[5] == "LEFT") then
					pbX = buttonSizes.bars + ceil((BarPadding.sides[4] * 2) + (pbP / 2)) - 9
				elseif (sidePositions[5] == "LEFT") then
					pbX = buttonSizes.bars + ceil((BarPadding.sides[5] * 2) + (pbP / 2)) - 9
				else
					pbX = ceil(pbP / 2) - 9
				end

				-- Calculate Y
				pbY = (pbH / 2) + 10

				-- Set Position
				if Bartender4DB["namespaces"]["PetBar"]["profiles"][prof] then
					Bartender4DB["namespaces"]["PetBar"]["profiles"][prof]["position"] = {
						["x"] = pbX,
						["y"] = pbY,
						["point"] = "LEFT",
						["scale"] = 1,
						["growHorizontal"] = "RIGHT",
						["growVertical"] = "DOWN",
					}
					Bartender4DB["namespaces"]["PetBar"]["profiles"][prof]["padding"] = pbP - 8
				end
				local B4PetBar = Bar4:GetModule("PetBar", true)
				if B4PetBar then B4PetBar:ApplyConfig() end
			end
		end

		----
		-- Extra Action Bar
		----
		if barSettings.moveBars.eab then
			local eabX, eabY

			-- Calculate Y
			eabY = 61

			-- Calculate X
			if numTopBars == 3 then
				eabX = -32
			elseif numTopBars == 2 then
				eabX = BarSizes[3] / 2 - 4
			else
				eabX = max(BarSizes[2], BarSizes[3]) / 2 - 4
			end

			if Bartender4DB["namespaces"]["ExtraActionBar"]["profiles"][prof] then
				Bartender4DB["namespaces"]["ExtraActionBar"]["profiles"][prof]["position"] = {
					["y"] = eabY,
					["x"] = eabX,
					["point"] = "BOTTOM",
					["scale"] = 0.985,
					["growHorizontal"] = "RIGHT",
					["growVertical"] = "DOWN",
				}
			end
			local B4EAB = Bar4:GetModule("ExtraActionBar", true)
			if B4EAB then B4EAB:ApplyConfig() end
		end
	end
	
	----
	-- Stance Bar
	----
	-- local NumStances = GetNumShapeshiftForms()
	-- if NumStances >= 1 then
	-- 	local sbX, sbY, sbPoint
	-- 	local sbP = barSettings.stanceBar.padding
	-- 	local sbW = (NumStances * buttonSizes.stanceBar) + ((NumStances - 1) * sbP)

	-- 	-- Calculate X
	-- 	sbX = -floor((sbW / 2)) - 9.5

	-- 	-- Calculate Y
	-- 	if barSettings.stanceBar.position == "TOP" then
	-- 		if numTopBars > 0 then
	-- 			sbY = HuDY + ABY + buttonSizes.bars + ceil(CenterBarVertPadding[1] + (sbP / 2))
	-- 		else
	-- 			sbY = HuDY + ABY + buttonSizes.bars + ceil(sbP / 2)
	-- 		end
	-- 	else
	-- 		if numTopBars == 3 then
	-- 			sbY = 37
	-- 		elseif numTopBars == 2 then
	-- 			local padding = ceil(CenterBarVertPadding[3] + (sbP / 2))
	-- 			sbY = buttonSizes.bars + padding + 37
	-- 		elseif numTopBars == 1 then
	-- 			local padding = ceil(CenterBarVertPadding[3] + (CenterBarVertPadding[2] * 2) + (sbP / 2))
	-- 			sbY = (buttonSizes.bars * 2) + padding + 37
	-- 		elseif numTopBars == 0 then
	-- 			local padding = ceil(CenterBarVertPadding[3] + (CenterBarVertPadding[2] * 2) + (CenterBarVertPadding[1] * 2) + (sbP / 2))
	-- 			sbY = (buttonSizes.bars * 3) + padding + 37
	-- 		end
	-- 	end
	-- 	sbY = sbY - 5

	-- 	-- Set Position
	-- 	if Bartender4DB["namespaces"]["StanceBar"]["profiles"][prof] then
	-- 		Bartender4DB["namespaces"]["StanceBar"]["profiles"][prof]["position"] = {
	-- 			["x"] = sbX,
	-- 			["y"] = sbY,
	-- 			["point"] = (barSettings.stanceBar.position == "TOP") and "CENTER" or "BOTTOM",
	-- 			["scale"] = 1,
	-- 			["growHorizontal"] = "RIGHT",
	-- 			["growVertical"] = "DOWN",
	-- 		}
	-- 		Bartender4DB["namespaces"]["StanceBar"]["profiles"][prof]["padding"] = sbP - 8
	-- 	end
	-- 	local B4Stance = Bar4:GetModule("StanceBar", true)
	-- 	if B4Stance then B4Stance:ApplyConfig() end
	-- end
	if barSettings.moveBars.stance then
		local B4Stance = Bar4:GetModule("StanceBar", true)
		local NumStances = GetNumShapeshiftForms()
		if NumStances > 0 then
			if B4Stance and not(B4Stance:IsEnabled()) then B4Stance:Enable() end

			local sbX, sbY

			if ndb.settings.fontStyle == 3 then
				sbX = -286
				sbY = 28
			else
				sbX = -264
				sbY = 27
			end

			-- Set Position
			if Bartender4DB["namespaces"]["StanceBar"]["profiles"][prof] then
				Bartender4DB["namespaces"]["StanceBar"]["profiles"][prof]["position"] = {
					["x"] = sbX,
					["y"] = sbY,
					["scale"] = 1,
					["growHorizontal"] = "LEFT",
					["growVertical"] = "DOWN",
					["point"] = "BOTTOMRIGHT"
				}
			end
			if B4Stance then B4Stance:ApplyConfig() end
		end
	end

	-- ActionBar Doodads
	if nibRealUI:GetModuleEnabled("ActionBarDoodads") then
		local ABD = nibRealUI:GetModule("ActionBarDoodads", true)
		if ABD then ABD:RefreshMod() end
	end
end

----------
function HuDConfig_ActionBars:OnInitialize()
	ndb = nibRealUI.db.profile

	Bar4 = LibStub("AceAddon-3.0"):GetAddon("Bartender4", true)
end