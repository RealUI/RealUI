local F, C = unpack(select(2, ...))

C.themes["Recount"] = function()
	if IsAddOnLoaded("CowTip") or IsAddOnLoaded("TipTac") or IsAddOnLoaded("FreebTip") or IsAddOnLoaded("lolTip") or IsAddOnLoaded("StarTip") or IsAddOnLoaded("TipTop") then return end

	hooksecurefunc(LibStub("LibDropdown-1.0"), "OpenAce3Menu", function()
		F.CreateBD(LibDropdownFrame0, AuroraConfig.alpha)
	end)
end