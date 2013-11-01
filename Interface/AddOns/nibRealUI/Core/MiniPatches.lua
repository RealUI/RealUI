local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

function nibRealUI:MiniPatch(ver)
	if ver == "80r1" then
		if IsAddOnLoaded("Skada") then
			if SkadaDB["profiles"]["RealUI"]["windows"][1] then
				SkadaDB["profiles"]["RealUI"]["windows"][1]["classicons"] = false
				SkadaDB["profiles"]["RealUI"]["windows"][1]["classcolorbars"] = true
				SkadaDB["profiles"]["RealUI"]["windows"][1]["classcolortext"] = false
				SkadaDB["profiles"]["RealUI"]["windows"][1]["bartexture"] = "Plain80"
				if nibRealUI.db.profile.settings.fontStyle == 3 then
					SkadaDB["profiles"]["RealUI"]["windows"][1]["y"] = 23.5
				else
					SkadaDB["profiles"]["RealUI"]["windows"][1]["y"] = 22.5
				end
				if SkadaDB["profiles"]["RealUI"]["windows"][1]["title"] then
					SkadaDB["profiles"]["RealUI"]["windows"][1]["title"]["height"] = 17
				end
				if SkadaDB["profiles"]["RealUI"]["windows"][1]["background"] then
					SkadaDB["profiles"]["RealUI"]["windows"][1]["background"]["height"] = 150
				end
			end
		end

	elseif ver == "80r2" then
		if IsAddOnLoaded("Grid2") and Grid2DB then
			local oldProfileKeys = Grid2DB["profileKeys"]
			nibRealUI:LoadSpecificAddOnData("Grid2", true)
			Grid2DB["profileKeys"] = oldProfileKeys
		end

	elseif ver == "80r6" then
		if IsAddOnLoaded("DXE_Loader") and not IsAddOnLoaded("DXE") then
			SlashCmdList.DXE()
		end
		nibRealUI:LoadSpecificAddOnData("DXE", true)
		nibRealUI.db.char.addonProfiles.needSet.DXE = true

	elseif ver == "80r8" then
		DXEIconDB = {
			["hide"] = true,
		}

		if IsAddOnLoaded("Grid2") and Grid2DB then
			if Grid2DB["profiles"]["RealUI"]["statusMap"] then
				Grid2DB["profiles"]["RealUI"]["statusMap"]["border"] = {["afk"] = 51, ["threat"] = 50, }
				Grid2DB["profiles"]["RealUI"]["statusMap"]["corner-bottom-left"] = {["ready-check"] = 50, }
			end
			if Grid2DB["profiles"]["RealUI"]["indicators"] then
				Grid2DB["profiles"]["RealUI"]["indicators"]["corner-bottom-left"] = {["type"] = "icon", ["color1"] = {["a"] = 1, ["b"] = 0, ["g"] = 0, ["r"] = 0, }, ["fontSize"] = 8, ["borderSize"] = 1, ["size"] = 10, ["width"] = 6, ["location"] = {["y"] = 1, ["relPoint"] = "BOTTOMLEFT", ["point"] = "BOTTOMLEFT", ["x"] = 1, }, ["level"] = 5, ["height"] = 6, ["texture"] = "Plain", }
			end

			if Grid2DB["profiles"]["RealUI-Healing"]["statusMap"] then
				Grid2DB["profiles"]["RealUI-Healing"]["statusMap"]["border"] = {["afk"] = 51, ["threat"] = 50, }
				Grid2DB["profiles"]["RealUI-Healing"]["statusMap"]["corner-bottom-left"] = {["ready-check"] = 50, }
			end
			if Grid2DB["profiles"]["RealUI-Healing"]["indicators"] then
				Grid2DB["profiles"]["RealUI-Healing"]["indicators"]["corner-bottom-left"] = {["type"] = "icon", ["color1"] = {["a"] = 1, ["b"] = 0, ["g"] = 0, ["r"] = 0, }, ["fontSize"] = 8, ["borderSize"] = 1, ["size"] = 10, ["width"] = 6, ["location"] = {["y"] = 1, ["relPoint"] = "BOTTOMLEFT", ["point"] = "BOTTOMLEFT", ["x"] = 1, }, ["level"] = 5, ["height"] = 6, ["texture"] = "Plain", }
			end
		end

	elseif ver == "80r9" then
		if IsAddOnLoaded("Chatter") and ChatterDB then
			if ChatterDB["profiles"]["RealUI"]["modules"] then
				ChatterDB["profiles"]["RealUI"]["modules"]["Chat Font"] = false
			end
		end

	elseif ver == "80r12" then
		if IsAddOnLoaded("FreebTip") then
			FreebTipDB = {
				["y"] = 192,
				["x"] = -31,
				["point"] = "BOTTOMRIGHT",
			}
		end

	elseif ver == "80r16" then
		AuroraConfig = nil

	elseif ver == "80r21" then
		if IsAddOnLoaded("Bartender4") and Bartender4DB then
			if Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI"]["actionbars"] then
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI"]["actionbars"][1]["visibility"]["customdata"] = "[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI"]["actionbars"][2]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI"]["actionbars"][3]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI"]["actionbars"][4]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI"]["actionbars"][5]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade"
			end
			if Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI-Healing"]["actionbars"] then
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI-Healing"]["actionbars"][1]["visibility"]["customdata"] = "[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI-Healing"]["actionbars"][2]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI-Healing"]["actionbars"][3]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI-Healing"]["actionbars"][4]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI-Healing"]["actionbars"][5]["visibility"]["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade"
				Bartender4DB["namespaces"]["ActionBars"]["profiles"]["RealUI-Healing"]["actionbars"][6]["visibility"]["customdata"] = "[mod:ctrl][cursor]show;fade"
			end
		end

	end
end