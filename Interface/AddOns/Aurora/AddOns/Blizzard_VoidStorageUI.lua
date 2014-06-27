local F, C = unpack(select(2, ...))

C.modules["Blizzard_VoidStorageUI"] = function()
	F.SetBD(VoidStorageFrame, 20, 0, 0, 20)
	F.CreateBD(VoidStoragePurchaseFrame)

	VoidStorageBorderFrame:DisableDrawLayer("BORDER")
	VoidStorageBorderFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageBorderFrame:DisableDrawLayer("OVERLAY")
	VoidStorageDepositFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageDepositFrame:DisableDrawLayer("BORDER")
	VoidStorageWithdrawFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageWithdrawFrame:DisableDrawLayer("BORDER")
	VoidStorageCostFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageCostFrame:DisableDrawLayer("BORDER")
	VoidStorageStorageFrame:DisableDrawLayer("BACKGROUND")
	VoidStorageStorageFrame:DisableDrawLayer("BORDER")
	VoidStorageFrameMarbleBg:Hide()
	select(2, VoidStorageFrame:GetRegions()):Hide()
	VoidStorageFrameLines:Hide()
	VoidStorageStorageFrameLine1:Hide()
	VoidStorageStorageFrameLine2:Hide()
	VoidStorageStorageFrameLine3:Hide()
	VoidStorageStorageFrameLine4:Hide()
	select(12, VoidStorageDepositFrame:GetRegions()):Hide()
	select(12, VoidStorageWithdrawFrame:GetRegions()):Hide()
	for i = 1, 10 do
		select(i, VoidStoragePurchaseFrame:GetRegions()):Hide()
	end

	for i = 1, 9 do
		local bu1 = _G["VoidStorageDepositButton"..i]
		local bu2 = _G["VoidStorageWithdrawButton"..i]

		bu1:SetPushedTexture("")
		bu2:SetPushedTexture("")

		_G["VoidStorageDepositButton"..i.."Bg"]:Hide()
		_G["VoidStorageWithdrawButton"..i.."Bg"]:Hide()

		_G["VoidStorageDepositButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
		_G["VoidStorageWithdrawButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)

		local bg1 = CreateFrame("Frame", nil, bu1)
		bg1:SetPoint("TOPLEFT", -1, 1)
		bg1:SetPoint("BOTTOMRIGHT", 1, -1)
		bg1:SetFrameLevel(bu1:GetFrameLevel()-1)
		F.CreateBD(bg1, .25)

		local bg2 = CreateFrame("Frame", nil, bu2)
		bg2:SetPoint("TOPLEFT", -1, 1)
		bg2:SetPoint("BOTTOMRIGHT", 1, -1)
		bg2:SetFrameLevel(bu2:GetFrameLevel()-1)
		F.CreateBD(bg2, .25)
	end

	for i = 1, 80 do
		local bu = _G["VoidStorageStorageButton"..i]

		bu:SetPushedTexture("")

		_G["VoidStorageStorageButton"..i.."Bg"]:Hide()
		_G["VoidStorageStorageButton"..i.."IconTexture"]:SetTexCoord(.08, .92, .08, .92)
	end

	F.Reskin(VoidStoragePurchaseButton)
	F.Reskin(VoidStorageHelpBoxButton)
	F.Reskin(VoidStorageTransferButton)
	F.ReskinClose(VoidStorageBorderFrame:GetChildren(), nil)
	F.ReskinInput(VoidItemSearchBox)
end

local voidHandler = CreateFrame("Frame")
voidHandler:RegisterEvent("ADDON_LOADED")
voidHandler:RegisterEvent("VOID_STORAGE_CONTENTS_UPDATE")
voidHandler:RegisterEvent("VOID_STORAGE_DEPOSIT_UPDATE")
voidHandler:RegisterEvent("VOID_TRANSFER_DONE")
voidHandler:RegisterEvent("VOID_STORAGE_OPEN")

local updateContents = function()
	if not IsAddOnLoaded("Blizzard_VoidStorageUI") then return end

	for slot = 1, VOID_WITHDRAW_MAX or 80 do
		F.ColourQuality(_G["VoidStorageStorageButton"..slot], GetVoidItemInfo(slot))
	end

	for slot = 1, VOID_WITHDRAW_MAX or 9 do
		F.ColourQuality(_G["VoidStorageWithdrawButton"..slot], GetVoidTransferWithdrawalInfo(slot))
	end
end

local updateDeposit = function(slot)
	if not IsAddOnLoaded("Blizzard_VoidStorageUI") then return end

	F.ColourQuality(_G["VoidStorageDepositButton"..slot], GetVoidTransferDepositInfo(slot))
end

local update = function()
	if not IsAddOnLoaded("Blizzard_VoidStorageUI") then return end

	for slot = 1, VOID_DEPOSIT_MAX or 9 do
		updateDeposit(slot)
	end

	return updateContents()
end

voidHandler:SetScript("OnEvent", function(self, event, ...)
	if event == "ADDON_LOADED" then
		if ... == "Blizzard_VoidStorageUI" then
			self:UnregisterEvent("ADDON_LOADED")
			local last = 0
			self:SetScript("OnUpdate", function(self, elapsed)
				last = last + elapsed
				if last > 1 then
					self:SetScript("OnUpdate", nil)
					update()
				end
			end)
		end
	elseif event == "VOID_STORAGE_CONTENTS_UPDATE" then
		updateContents()
	elseif event == "VOID_STORAGE_DEPOSIT_UPDATE" then
		updateDeposit(...)
	elseif event == "VOID_TRANSFER_DONE" or event == "VOID_STORAGE_OPEN" then
		update()
	end
end)