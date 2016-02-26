InspectFix = CreateFrame("Button", "InspectFixHiddenFrame", UIParent)
local addonName = "InspectFix"
local revision = tonumber(("$Revision: 57 $"):match("%d+"))

local BlizzardNotifyInspect = _G.NotifyInspect
local InspectPaperDollFrame_SetLevel = nil
local InspectPaperDollFrame_OnShow = nil
local InspectGuildFrame_Update = nil
local loaded = false
local debugging = false
local allowDetarget = false   	-- allow window to remain open when target is not inspectable (experimental)
local serverTimeout = 1		-- timeout for INSPECT_READY response to assume server dropped it 

local function debug(msg)
  if debugging then
     DEFAULT_CHAT_FRAME:AddMessage("\124cFFFF0000"..addonName.."\124r: "..msg)
  end
end

local lastUINIGUID, lastUINITime, lastUIIRTime

local function inspectable(unit)
  return unit and UnitExists(unit) and UnitIsConnected(unit) and CanInspect(unit)
end

local function inspectfilter(self, event, ...) 
  --myprint(event,...)
  if loaded then
    local unit = InspectFrame.unit
    local inspectable = inspectable(unit)
    if not allowDetarget and not inspectable then -- disallow target dissappearance
       return true
    elseif event == nil and not inspectable then
       return false
    elseif event == "PLAYER_TARGET_CHANGED" then -- suppress close on change 
       if inspectable and InspectFix.UserInspecting() then
          InspectFrame_UnitChanged(InspectFrame);
       end
       return false
    end
    if inspectable and lastUINITime and not lastUIIRTime and 
       InspectFix.UserInspecting() and 
       (lastUINITime + serverTimeout) < GetTime() then
       debug("Re-issuing dropped notify")
       InspectFrame_UnitChanged(InspectFrame);
    end
  end
  return true
end
local function inspectonevent(self, event, ...)
  if inspectfilter(self, event, ...) then
    InspectFrame_OnEvent(self, event, ...)
    InspectFix:Update()
  end
end
local function inspectonupdate(self)
  if inspectfilter(self, nil) then
    InspectFrame_OnUpdate(self)
    InspectFix:Update()
  end
end
local function talentonevent(self, event, ...)
  if inspectfilter(self, event, ...) then
    InspectTalentFrame_OnEvent(self, event, ...)
    InspectFix:Update()
  end
end

-- cache the inspect contents in case we lose our target (so GameTooltip:SetInventoryItem() no longer works)
local scantt = CreateFrame("GameTooltip", "InspectFix_Tooltip", UIParent, "GameTooltipTemplate")
scantt:SetOwner(UIParent, "ANCHOR_NONE");
local inspect_item = {}
local inspect_unit = nil
local inspect_guid = nil
local buttonhooked = {}
local function pdfclick(self)  
   -- fix modified click on item buttons
   local id = self and self:GetID()
   local unit = InspectFrame.unit
   if not id or not unit or UnitGUID(unit) ~= inspect_guid then return end
   local link = GetInventoryItemLink(unit, id)
   if not link and inspect_item[id] then
     debug("Fixing modified click")
     HandleModifiedItemClick(inspect_item[id])
   end
end
local function pdfupdate(self)
  if loaded then
    local id = self:GetID()
    if self ~= InspectFix and not buttonhooked[id] then
      buttonhooked[id] = true
      self:HookScript("OnClick", pdfclick)
    end
    local unit = InspectFrame and InspectFrame.unit
    if unit and id then
      local link = GetInventoryItemLink(unit, id)
      local guid = UnitGUID(unit)
      if guid and guid ~= inspect_guid then
        inspect_guid = guid
        wipe(inspect_item)
      end
      inspect_unit = unit
      local oldlink = inspect_item[id]
      if link then
        inspect_item[id] = link
      end

      scantt:SetOwner(UIParent, "ANCHOR_NONE");
      scantt:SetInventoryItem(unit, id)
      local _, scanlink = scantt:GetItem()
      if scanlink then
        inspect_item[id] = scanlink
      end
      if oldlink and inspect_item[id] ~= oldlink then
        debug("Updating "..(inspect_item[id] or "nil").." to "..scanlink)
      end
      --if debugging then printlink(id.." "..(link or "nil")) end
    end
  end
end
local function pdfonenter(self)
  if loaded then
    local id = self:GetID()
    if id and inspect_item[id] and inspect_unit == InspectFrame.unit and
       GameTooltip:IsVisible() then
      if GameTooltip:NumLines() == 1 then -- fill in a bogus inspect result
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT");
        GameTooltip:SetHyperlink(inspect_item[id])
      else
        local name,link = GameTooltip:GetItem()
	if link and link ~= inspect_item[id] then
	  debug("Updating "..(inspect_item[id] or "nil").." to "..link)
          inspect_item[id] = link
	end
      end
      --if debugging then printlink(id.." "..inspect_item[id]) end
    end
  end
end

function InspectFix:GetID() return self.val end
InspectFix.val = INVSLOT_FIRST_EQUIPPED
function InspectFix:Update() 
 for slot = INVSLOT_FIRST_EQUIPPED, INVSLOT_LAST_EQUIPPED do
   InspectFix.val = slot
   pdfupdate(InspectFix)
 end
end


local blockmsg = {}

local function UserInspecting()
  if InspectFrame and InspectFrame:IsVisible() then
     return "Blizzard_InspectUI"
  elseif Examiner and Examiner:IsVisible() then
     return "Examiner"
  else
     return nil
  end
end
InspectFix.UserInspecting = UserInspecting

-- prevent NotifyInspect interference from other addons
local function NIhook(unit)
  InspectFix:tryhook()
  if loaded and not inspectable(unit) then
    debug("Blocked a bogus NotifyInspect("..(unit or "nil")..")")
    return
  end
  local ui = UserInspecting()
  if loaded and ui then
    local now = GetTime()
    local str = debugstack(2)
    --print(str)
    local addon = string.match(str,'[%s%c]+([^:%s%c]*)\\[^\\:%s%c]+:')
    addon = string.gsub(addon or "unknown",'I?n?t?e?r?f?a?c?e\\AddOns\\',"")
    if not string.find(str,ui) then
      blockmsg[addon] = blockmsg[addon] or {}
      local count = (blockmsg[addon].count or 0) + 1
      blockmsg[addon].count = count
      if not blockmsg[addon].lastwarn or (now - blockmsg[addon].lastwarn > 30) then -- throttle warnings
        print("InspectFix blocked a conflicting inspect request from "..addon.." ("..count.." occurences)")
	debug(str)
        blockmsg[addon].lastwarn = now
      end
      return
    end
    lastUINIGUID = UnitGUID(unit)
    lastUINITime = now
    lastUIIRTime = nil
  end
  debug("NotifyInspect("..tostring(unit)..") "..(ui or ""))
  BlizzardNotifyInspect(unit)
end

-- prevent a lua error bug in pdf
local function pdffilter(context)
  if not loaded then
    return true
  elseif InspectFrame and inspectable(InspectFrame.unit) then
    return true
  else
    debug(context.."_hook blocked a potential lua error")
    return false
  end
end
local function setlevel_hook()
  if pdffilter("setlevel") then
    return InspectPaperDollFrame_SetLevel()
  end
end

local function pdfshow_hook()
  if pdffilter("pdfshow") then
    return InspectPaperDollFrame_OnShow()
  end
end

local function guildframe_hook()
  if pdffilter("guildframe") then
    return InspectGuildFrame_Update()
  end
end

local function inspectunit(unit)
  if not inspectable(unit) then return end
  -- NotifyInspect blocking in this addon and others is controlled by visibility of InspectFrame
  -- When the user requests an inspect we need to immediately show that frame to start that blocking
  -- and ensure the Notify issued by InspectFrame isn't squashed by a subsequent stealth inspect, 
  -- which would effectively cancel the user's manual inspect, causing the frame to never be shown
  ShowUIPanel(InspectFrame)
  -- issue a (duplicate) NotifyInspect with the frame open, to engage our retry and be extra-sure
  InspectFrame_UnitChanged(InspectFrame)
end


local hookcnt = 0
local hooked = {}
function InspectFix:tryhook()

  if _G.NotifyInspect and _G.NotifyInspect ~= NIhook then
    if not hooked["notifyinspect"] then
      BlizzardNotifyInspect = _G.NotifyInspect
      _G.NotifyInspect = NIhook
      hookcnt = hookcnt + 1
      hooked["notifyinspect"] = true
      debug("Hooked notifyinspect")
    elseif not hooked["notifywarn"] then
      hooked["notifywarn"] = true
      debug("NotifyInspect hooked by another addon")
    end
  end

  if _G.InspectFrame_OnEvent and InspectFrame:GetScript("OnEvent") ~= inspectonevent then
    InspectFrame:SetScript("OnEvent", inspectonevent)
    if not hooked[inspectonevent] then
      hookcnt = hookcnt + 1
      hooked[inspectonevent] = true
      debug("Hooked inspectonevent")
    else
      debug("Re-Hooked inspectonevent")
    end
  end

  if _G.InspectFrame_OnUpdate and InspectFrame:GetScript("OnUpdate") ~= inspectonupdate then
    InspectFrame:SetScript("OnUpdate", inspectonupdate)
    if not hooked[inspectonupdate] then
      hookcnt = hookcnt + 1
      hooked[inspectonupdate] = true
      debug("Hooked inspectonupdate")
    else
      debug("Re-Hooked inspectonupdate")
    end
  end

  if _G.InspectTalentFrame_OnEvent and InspectTalentFrame:GetScript("OnEvent") ~= talentonevent then
    InspectTalentFrame:SetScript("OnEvent", talentonevent)
    if not hooked[talentonevent] then
      hookcnt = hookcnt + 1
      hooked[inspectonevent] = true
      debug("Hooked talentonevent")
    else
      debug("Re-Hooked talentonevent")
    end
  end

  if _G.InspectPaperDollFrame_SetLevel and _G.InspectPaperDollFrame_SetLevel ~= setlevel_hook then
    if not hooked[setlevel_hook] then
      InspectPaperDollFrame_SetLevel = _G.InspectPaperDollFrame_SetLevel
      _G.InspectPaperDollFrame_SetLevel = setlevel_hook
      hooked[setlevel_hook] = true
      hookcnt = hookcnt + 1
      debug("Hooked setlevel_hook")
    else
      debug("InspectPaperDollFrame_SetLevel hooked by another addon")
    end
  end

  if _G.InspectGuildFrame_Update and _G.InspectGuildFrame_Update ~= guildframe_hook then
    if not hooked[guildframe_hook] then
      InspectGuildFrame_Update = _G.InspectGuildFrame_Update
      _G.InspectGuildFrame_Update = guildframe_hook
      hooked[guildframe_hook] = true
      hookcnt = hookcnt + 1
      debug("Hooked guildframe_hook")
    else
      debug("InspectGuildFrame_Update hooked by another addon")
    end
  end

  if _G.InspectPaperDollFrame_OnShow and _G.InspectPaperDollFrame_OnShow ~= pdfshow_hook then
    InspectPaperDollFrame:SetScript("OnShow", pdfshow_hook)
    if not hooked[pdfshow_hook] then
      InspectPaperDollFrame_OnShow = _G.InspectPaperDollFrame_OnShow
      _G.InspectPaperDollFrame_OnShow = pdfshow_hook
      hooked[pdfshow_hook] = true
      hookcnt = hookcnt + 1
      debug("Hooked pdfshow_hook")
    else
      debug("Re-Hooked pdfshow_hook")
    end
  end

  if not hooked[pdfupdate] and InspectPaperDollItemSlotButton_Update and InspectPaperDollItemSlotButton_OnEnter then
    hooksecurefunc("InspectPaperDollItemSlotButton_Update", pdfupdate)
    hooksecurefunc("InspectPaperDollItemSlotButton_OnEnter", pdfonenter)
    hookcnt = hookcnt + 1
    hooked[pdfupdate] = true
    debug("Hooked pdfupdate")
  end

  if not hooked[inspectunit] and InspectUnit then
    hooksecurefunc("InspectUnit", inspectunit)
    hookcnt = hookcnt + 1
    hooked[inspectunit] = true
    debug("Hooked inspectunit")
  end

  if hookcnt == 9 then
    hookcnt = hookcnt + 1
    print("InspectFix hook activated.")
  end
end
local function InspectFix_OnEvent(self, event, ...)
  if event == "ADDON_LOADED" then
    InspectFix:tryhook()
  elseif event == "INSPECT_READY" and loaded and UserInspecting() then
    local guid = select(1,...)
    local unit = InspectFrame and InspectFrame.unit
    local iguid = unit and UnitGUID(unit)
    debug("INSPECT_READY: "..guid)
    if guid and iguid and guid ~= iguid then
       print("InspectFix blocked a conflicting inspect reply")
       BlizzardNotifyInspect(unit)
    end
    if guid == lastUINIGUID then
      lastUIIRTime = GetTime()
    end
    InspectFix:Update()
  end
end
InspectFix:SetScript("OnEvent", InspectFix_OnEvent)
InspectFix:RegisterEvent("ADDON_LOADED")
InspectFix:RegisterEvent("INSPECT_READY")

function InspectFix:Load()
  InspectFix:tryhook()
  loaded = true
  local revstr 
  revstr = GetAddOnMetadata("InspectFix", "X-Curse-Packaged-Version")
  if not revstr then
  revstr = GetAddOnMetadata("InspectFix", "Version")
  end
  if not revstr or string.find(revstr, "@") then
    revstr = "r"..tostring(revision)
  end
  print("InspectFix "..revstr.." loaded.")
end

function InspectFix:Unload()
  loaded = false
  print("InspectFix unloaded.")
end

InspectFix:Load()

SLASH_INSPECTFIX1 = "/inspectfix"
SLASH_INSPECTFIX2 = "/if"
SlashCmdList["INSPECTFIX"] = function(msg)
        local cmd = msg:lower()
        if cmd == "load" or cmd == "on" or cmd == "ver" then
          InspectFix:Load()
        elseif cmd == "unload" or cmd == "off" then
          InspectFix:Unload()
        elseif cmd == "debug" then
          debugging = not debugging
	  print("InspectFix debugging "..(debugging and "enabled" or "disabled"))
        else
          print("/inspectfix [ on | off | debug ]")
        end
end
