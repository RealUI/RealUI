local ADDON_NAME = ...

-- Lua Globals --
-- luacheck: globals select tostring next

local LTD, debugger = _G.LibStub("LibTextDump-1.0"), {}
local function GetDebugFrame(mod)
    if not debugger[mod] then
        local function save(buffer)
            _G.RealUI_Debug[mod] = buffer
        end
        debugger[mod] = LTD:New(("%s Debug Output"):format(mod), 640, 473, save)
        debugger[mod].numDuped = 0
        debugger[mod].prevLine = ""
    end
    return debugger[mod]
end

local RealUI = {}
function RealUI.Debug(mod, ...)
    local modDebug = GetDebugFrame(mod)

    local text = ""
    for i = 1, select("#", ...) do
        local arg = select(i, ...)
        text = text .. tostring(arg) .. "     "
    end
    if modDebug.prevLine == text then
        modDebug.numDuped = modDebug.numDuped + 1
    else
        if modDebug.numDuped > 0 then
            modDebug:AddLine(("^^ Repeated %d times ^^"):format(modDebug.numDuped))
            modDebug.numDuped = 0
        end
        modDebug:AddLine(text, "%H:%M:%S")
        modDebug.prevLine = text
    end
end
function RealUI.GetDebug(mod)
    return function (...)
        return RealUI.Debug(mod, ...)
    end
end
_G.RealUI = RealUI

--local debug = RealUI.GetDebug("Bugs")
local errorFrame do
    errorFrame = _G.CreateFrame("Frame", "RealUI_ErrorFrame", _G.UIParent, "UIPanelDialogTemplate")
    errorFrame:SetClampedToScreen(true)
    errorFrame:SetMovable(true)
    errorFrame:SetSize(500, 350)
    errorFrame:SetPoint("CENTER")
    errorFrame:SetToplevel(true)
    errorFrame:Hide()

    errorFrame.Close = _G.RealUI_ErrorFrameClose
    errorFrame.Title:SetText(_G.LUA_ERROR)

    local dragArea = _G.CreateFrame("Frame", nil, errorFrame, "TitleDragAreaTemplate")
    dragArea:SetPoint("TOPLEFT")
    dragArea:SetPoint("BOTTOMRIGHT", errorFrame.Title)
    errorFrame.DragArea = dragArea

    local scrollFrame = _G.CreateFrame("ScrollFrame", nil, errorFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", dragArea, "BOTTOMLEFT", 10, -10)
    scrollFrame:SetPoint("BOTTOMRIGHT", -28, 44)
    _G.ScrollFrame_OnLoad(scrollFrame)
    errorFrame.ScrollFrame = scrollFrame

    local text = _G.CreateFrame("EditBox", nil, scrollFrame)
    text:SetSize(scrollFrame:GetSize())
    text:SetAutoFocus(false)
    text:SetMultiLine(true)
    text:SetMaxLetters(0)
    text:SetFontObject("GameFontHighlightSmall")
    text:SetScript("OnEscapePressed", _G.EditBox_ClearFocus)
    text:SetScript("OnEditFocusGained", function(self)
        self:HighlightText()
    end)
    scrollFrame:SetScrollChild(text)
    scrollFrame.Text = text

    local reload = _G.CreateFrame("Button", nil, errorFrame, "UIPanelButtonTemplate")
    reload:SetSize(96, 24)
    reload:SetText(_G.RELOADUI)
    reload:SetPoint("BOTTOMLEFT", 10, 10)
    reload:SetScript("OnClick", _G.ReloadUI)
    errorFrame.Reload = reload

    local index = errorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalCenter")
    index:SetSize(70, 16)
    index:SetPoint("BOTTOM", 0, 16)
    errorFrame.IndexLabel = index

    local prevError = _G.CreateFrame("Button", nil, errorFrame)
    prevError:SetSize(32, 32)
    prevError:SetNormalTexture([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]])
    prevError:SetPushedTexture([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Down]])
    prevError:SetDisabledTexture([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Disabled]])
    prevError:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
    prevError:SetPoint("RIGHT", index, "LEFT")
    prevError:SetScript("OnClick", function() errorFrame:ShowPrevious() end)
    errorFrame.PreviousError = prevError

    local nextError = _G.CreateFrame("Button", nil, errorFrame)
    nextError:SetSize(32, 32)
    nextError:SetNormalTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
    nextError:SetPushedTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]])
    nextError:SetDisabledTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Disabled]])
    nextError:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
    nextError:SetPoint("LEFT", index, "RIGHT")
    nextError:SetScript("OnClick", function() errorFrame:ShowNext() end)
    errorFrame.NextError = nextError
end


local CHAT_ERROR_FORMAT = [=[|cFFFF2020|Herror:%s|h[%s: %s]|h|r]=]
local REALUI_ERROR_FORMAT = [[x%d |cFFFFFFFF %s|r
|cFFFFD200Stack:|r|cFFFFFFFF %s|r
|cFFFFD200Time:|r|cFFFFFFFF %s|r |cFFFFD200Index:|r|cFFFFFFFF %d/%d|r
|cFFFFD200RealUI Version:|r %s
|cFFFFD200Locals:|r
|cFFFFFFFF%s|r]]
local ERROR_FORMAT = [[x%d |cFFFFFFFF %s|r
|cFFFFD200Stack:|r|cFFFFFFFF %s|r
|cFFFFD200Time:|r|cFFFFFFFF %s|r |cFFFFD200Index:|r|cFFFFFFFF %d/%d|r
|cFFFFD200Locals:|r
|cFFFFFFFF%s|r]]

local FormatError do
    local c = {
        ORANGE = "|c".._G.RAID_CLASS_COLORS.DRUID.colorStr,
        GREEN  = "|c".._G.RAID_CLASS_COLORS.HUNTER.colorStr,
        MINT   = "|c".._G.RAID_CLASS_COLORS.MONK.colorStr,
        BLUE   = "|c".._G.RAID_CLASS_COLORS.MAGE.colorStr,
        PINK   = "|c".._G.RAID_CLASS_COLORS.PALADIN.colorStr,
        PURPLE = "|c".._G.RAID_CLASS_COLORS.DEMONHUNTER.colorStr,
        TAN    = "|c".._G.RAID_CLASS_COLORS.WARRIOR.colorStr,
        GRAY   = _G.GRAY_FONT_COLOR_CODE,
    }

    local GRAY = c.GRAY .. "%1|r"
    local IN_C = c.TAN .. "[C]|r" .. c.GRAY .. "|r"
    local TYPE_BOOLEAN = " = " .. c.PURPLE .. "%1|r"
    local TYPE_NUMBER  = " = " .. c.ORANGE .. "%1|r"
    local TYPE_STRING  = " = " .. c.BLUE .. "\"%1\"|r"
    local TYPE_TABLE   = " = "
    local TYPE_FUNCTION   = " = " .. c.PINK .. "%1|r"
    local FILE_TEMPLATE   = GRAY .. c.MINT .. "%2|r\\%3:" .. c.GREEN .. "%4|r" .. c.GRAY .. "%5|r%6"
    local STRING_TEMPLATE = c.GRAY .. "%1[string |r" .. c.BLUE .. "\"%2\"|r" .. c.GRAY .. "]|r:" .. c.GREEN .. "%3|r" .. c.GRAY .. "%4|r%5"
    local NAME_TEMPLATE   = c.PINK .. "'%1'|r"

    function FormatError(msg)
        msg = msg and _G.tostring(msg)
        if not msg then return "None" end

        msg = msg:gsub("%.%.%.[IA]?[nd]?[td]?[eO]?[rn]?[fs]?a?c?e?\\", "")
        msg = msg:gsub("Interface\\", "")
        msg = msg:gsub("AddOns\\(.-%.[lx][um][al])", "%1")
        msg = msg:gsub("{\n%s*}", "{}")
        msg = msg:gsub("\n%s", "\n    ")
        msg = msg:gsub("%(%*temporary%)", GRAY)
        msg = msg:gsub("%[C%]:%-?%d?", IN_C)
        msg = msg:gsub(" = ([ftn][ari][lu]s?e?)", TYPE_BOOLEAN)
        msg = msg:gsub(" = ([0-9%.%-]+)", TYPE_NUMBER)
        msg = msg:gsub(" = \"([^\"]+)\"", TYPE_STRING)
        msg = msg:gsub(" = <(function)> defined", TYPE_FUNCTION)
        msg = msg:gsub(" = <(table)>", TYPE_TABLE)
        msg = msg:gsub("(<[a-z]+>)", GRAY)
        msg = msg:gsub("(<?)([%a!_]+)\\(.-%.[lx][um][al]):(%d+)(>?)(:?)", FILE_TEMPLATE)
        msg = msg:gsub("(<?)%[string \"(.-)\"]:(%d+)(>?)(:?)", STRING_TEMPLATE)
        msg = msg:gsub("[`]([^`]+)'", NAME_TEMPLATE)

        return msg
    end
end

function errorFrame:ChangeDisplayedIndex(delta)
    local errors = _G.BugGrabber:GetDB()
    self.index = _G.Clamp(self.index + delta, 0, #errors)

    self:Update()
end

function errorFrame:ShowPrevious()
    self:ChangeDisplayedIndex(-1);
end

function errorFrame:ShowNext()
    self:ChangeDisplayedIndex(1);
end

function errorFrame:ShowError(err)
    local errors = _G.BugGrabber:GetDB()
    if not err then
        if not self.index then
            self.index = #errors
        end
    elseif _G.type(err) == "string" then
        local errorObject = _G.BugGrabber:GetErrorByID(err)

        if errorObject ~= errors[self.index] then
            for i = 1, #errors do
                if errorObject == errors[i] then
                    self.index = i
                    break
                end
            end
        end
    end

    if not self:IsShown() then
        self:Show()
    else
        self:Update()
    end
end

local function GetNavigationButtonEnabledStates(count, index)
    -- Returns indicate whether navigation for "previous" and "next" should be enabled, respectively.
    if count > 1 then
        return index > 1, index < count;
    end

    return false, false;
end

local _, _, _, _, reason = _G.GetAddOnInfo("nibRealUI")
local hasRealUI, RealUI_Version = reason ~= "MISSING", _G.GetAddOnMetadata(ADDON_NAME, "Version")
function errorFrame:Update()
    local errors = _G.BugGrabber:GetDB()
    local numErrors = #errors
    if not self.index then
        self.index = numErrors
    end

    local previousEnabled, nextEnabled = GetNavigationButtonEnabledStates(numErrors, self.index)
    self.PreviousError:SetEnabled(previousEnabled)
    self.NextError:SetEnabled(nextEnabled)

    self.IndexLabel:SetText(("%d / %d"):format(self.index, numErrors))


    if numErrors > 0 then
        local err = errors[self.index]
        local editbox = self.ScrollFrame.Text
        local msg, stack, locals = FormatError(err.message), FormatError(err.stack), FormatError(err.locals)

        if hasRealUI then
            editbox:SetText(REALUI_ERROR_FORMAT:format(err.counter, msg, stack, err.time, self.index, numErrors, RealUI_Version, locals))
        else
            editbox:SetText(ERROR_FORMAT:format(err.counter, msg, stack, err.time, self.index, numErrors, locals))
        end
        editbox:HighlightText(0, 0)
        editbox:SetCursorPosition(0)
    end
end

local lastSeen, threshold = {}, 2
function errorFrame:BugGrabber_BugGrabbed(callback, errorObject)
    --[[errorObject = {
        message = sanitizedMessage,
        stack = table.concat(tmp, "\n"),
        locals = inCombat and "" or debuglocals(3),
        session = addon:GetSessionId(),
        time = date("%Y/%m/%d %H:%M:%S"),
        counter = 1,
    }]]
    --print(errorObject.message)
    local errorID, now = _G.BugGrabber:GetErrorID(errorObject), _G.time()

    if not lastSeen[errorID] or (now - lastSeen[errorID]) > threshold then
        lastSeen[errorID] = now
        _G.print(CHAT_ERROR_FORMAT:format(errorID, _G.LUA_ERROR, errorID))

        if self:IsShown() then
            self:Update()
        end
    end
end
function errorFrame:BugGrabber_CapturePaused()
    --print("Too many errors")
end


function errorFrame.ADDON_LOADED(addon)
    if not _G.RealUI_Storage then
        _G.RealUI_Storage = {}
    end
    if not _G.RealUI_Debug then
        _G.RealUI_Debug = {}
    end

    if addon == "nibRealUI" then
        _G.RealUI_Storage.nibRealUI = {}
        _G.RealUI_Storage.nibRealUI.nibRealUIDB = _G.nibRealUIDB
    end
end

_G.BugGrabber.setupCallbacks()
_G.BugGrabber.RegisterCallback(errorFrame, "BugGrabber_BugGrabbed")
_G.BugGrabber.RegisterCallback(errorFrame, "BugGrabber_CapturePaused")
errorFrame:RegisterEvent("ADDON_LOADED")
errorFrame:RegisterEvent("LUA_WARNING")
errorFrame:SetScript("OnEvent", function(self, event, ...)
    if self[event] then
        self[event](...)
    end
end)

errorFrame:SetScript("OnShow", function(self)
    self:Update()
end)

local oldOnHyperlinkShow = _G.ChatFrame_OnHyperlinkShow
function _G.ChatFrame_OnHyperlinkShow(frame, link, ...)
    local linkType, errorID =  _G.strsplit(":", link)
    if linkType == "error" then
        return errorFrame:ShowError(errorID)
    end
    return oldOnHyperlinkShow(frame, link, ...)
end

_G.SLASH_ERROR1 = '/error'
function _G.SlashCmdList.ERROR(str)
    errorFrame:ShowError()
end

_G.SLASH_DEBUG1 = "/debug"
function _G.SlashCmdList.DEBUG(mod, editBox)
    _G.print("/debug", mod, editBox)
    if mod == "" then
        -- TODO: Make this show a frame w/ buttons to specific debugs
        for k, v in next, debugger do
            _G.print(k, debugger[k]:Lines())
        end
    else
        local modDebug = GetDebugFrame(mod)

        if mod == "test" then
            _G.print("Generating test...")
            for i = 1, 100 do
                modDebug:AddLine("Test line "..i.." WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW")
                --modDebug:AddLine("Test line "..i)
            end
        end
        if modDebug:Lines() == 0 then
            modDebug:AddLine("Nothing to report.")
            modDebug:Display()
            modDebug:Clear()
            return
        end
        modDebug:Display()
    end
end
