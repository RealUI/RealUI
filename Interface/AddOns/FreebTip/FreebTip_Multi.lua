local _, ns = ...

if ns.cfg.multiTip == false then return end

local tips = { [1] = _G["ItemRefTooltip"] }

local types = {
	item = true,
	spell = true,
	quest = true,
	talent = true,
	enchant = true,
	achievement = true,
}

function ns:CreateTip(link)
	-- Use existing tip
	for k, v in ipairs(tips) do
		-- Hide if tip is already shown
		for i, tip in ipairs(tips) do
			if(tip:IsShown() and tip.link == link) then
				tip.link = nil
				HideUIPanel(tip)
				return
			end
		end

		if(not v:IsShown()) then
			v.link = link
			return v
		end
	end

	-- Create new tip
	local num = #tips+1
	local tip = CreateFrame("GameTooltip", "ItemRefTooltip"..num, UIParent, "FreebTip_Multi_Template")
	tip:SetScript("OnShow", function(self) ns.style(self) end)

	table.insert(UISpecialFrames, tip:GetName())

	if(IDCard) then IDCard:RegisterTooltip(tip) end

	tip.link = link
	tips[num] = tip

	return tip
end

function ns:ShowTip(tip, link)
	ShowUIPanel(tip)
	if (not tip:IsShown() ) then
		tip:SetOwner(UIParent, "ANCHOR_PRESERVE")
	end

	tip:SetHyperlink(link)
end

local _SetItemRef = SetItemRef
function SetItemRef(...)
	local link, text, button = ...

	--print("link - "..link.. " - text "..text.." - button "..button)

	local handled = strsplit(":", link)
	if((not IsModifiedClick()) and handled and types[handled]) then
		local tip = ns:CreateTip(link)

		if(tip) then
			ns:ShowTip(tip, link)
		end
	else
		return _SetItemRef(...)
	end
end
