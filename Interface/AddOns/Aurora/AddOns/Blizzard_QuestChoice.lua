local F, C = unpack(select(2, ...))

C.themes["Blizzard_QuestChoice"] = function()
	local QuestChoiceFrame = QuestChoiceFrame

	for i = 1, 15 do
		select(i, QuestChoiceFrame:GetRegions()):Hide()
	end

	for i = 17, 19 do
		select(i, QuestChoiceFrame:GetRegions()):Hide()
	end

	for i = 1, 2 do
		local option = QuestChoiceFrame["Option"..i]
		local rewards = option.Rewards
		local icon = rewards.Item.Icon
		local currencies = rewards.Currencies

		option.OptionText:SetTextColor(.9, .9, .9)
		rewards.Item.Name:SetTextColor(1, 1, 1)

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetDrawLayer("BACKGROUND", 1)
		F.CreateBG(icon)

		for j = 1, 3 do
			local cu = currencies["Currency"..j]

			cu.Icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(cu.Icon)
		end
	end

	F.CreateBD(QuestChoiceFrame)
	F.Reskin(QuestChoiceFrame.Option1.OptionButton)
	F.Reskin(QuestChoiceFrame.Option2.OptionButton)
	F.ReskinClose(QuestChoiceFrame.CloseButton)
end