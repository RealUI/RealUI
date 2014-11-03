-------------------------------
-- Code Taken from Tukui v16 --
-------------------------------
local Button = ExtraActionButton1
local Texture = Button.style
local RemoveTexture = function(self, texture)
	if texture and (string.sub(texture, 1, 9) == "Interface" or string.sub(texture, 1, 9) == "INTERFACE") then
		self:SetTexture("")
	end
end
hooksecurefunc(Texture, "SetTexture", RemoveTexture)