local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local QuestMapFrame = QuestMapFrame

	-- [[ Quest scroll frame ]]

	local QuestScrollFrame = QuestScrollFrame

	QuestMapFrame.VerticalSeparator:Hide()
	QuestScrollFrame.Background:Hide()

	F.Reskin(QuestScrollFrame.ViewAll)
	F.ReskinScroll(QuestScrollFrame.ScrollBar)

	-- [[ Quest details ]]

	local DetailsFrame = QuestMapFrame.DetailsFrame
	local RewardsFrame = DetailsFrame.RewardsFrame
	local CompleteQuestFrame = DetailsFrame.CompleteQuestFrame

	DetailsFrame:GetRegions():Hide()
	select(2, DetailsFrame:GetRegions()):Hide()
	select(3, DetailsFrame:GetRegions()):Hide()
	select(6, DetailsFrame.ShareButton:GetRegions()):Hide()
	select(7, DetailsFrame.ShareButton:GetRegions()):Hide()

	F.Reskin(DetailsFrame.BackButton)
	F.Reskin(DetailsFrame.AbandonButton)
	F.Reskin(DetailsFrame.ShareButton)
	F.Reskin(DetailsFrame.TrackButton)

	-- Rewards frame

	RewardsFrame.Background:Hide()
	select(2, RewardsFrame:GetRegions()):Hide()

	-- Scroll frame

	F.ReskinScroll(DetailsFrame.ScrollFrame.ScrollBar)

	-- Complete quest frame
	CompleteQuestFrame:GetRegions():Hide()
	select(2, CompleteQuestFrame:GetRegions()):Hide()
	select(6, CompleteQuestFrame.CompleteButton:GetRegions()):Hide()
	select(7, CompleteQuestFrame.CompleteButton:GetRegions()):Hide()

	F.Reskin(CompleteQuestFrame.CompleteButton)
end)