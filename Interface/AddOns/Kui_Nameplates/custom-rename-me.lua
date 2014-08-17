--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved

   Rename this file to custom.lua to attach custom code to the addon. Once
   renamed, you'll need to completely restart WoW so that it detects the file.

   Some examples can be found at the following URL:
   https://github.com/rbtwrrr/Kui_Nameplates-Customs
]]
local kn = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local mod = kn:NewModule('CustomInjector', 'AceEvent-3.0')

---------------------------------------------------------------------- Create --
function mod:PostCreate(msg, frame)
	-- Place code to be performed after a frame is created here.
end

------------------------------------------------------------------------ Show --
function mod:PostShow(msg, frame)
	-- Place code to be performed after a frame is shown here.
end

------------------------------------------------------------------------ Hide --
function mod:PostHide(msg, frame)
	-- Place code to be performed after a frame is hidden here.
end

---------------------------------------------------------------------- Target --
function mod:PostTarget(msg, frame)
	-- Place code to be performed when a frame becomes the player's target here.
end

-------------------------------------------------------------------- Register --
mod:RegisterMessage('KuiNameplates_PostCreate', 'PostCreate')
mod:RegisterMessage('KuiNameplates_PostShow', 'PostShow')
mod:RegisterMessage('KuiNameplates_PostHide', 'PostHide')
mod:RegisterMessage('KuiNameplates_PostTarget', 'PostTarget')
