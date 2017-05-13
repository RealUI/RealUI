local hasBugDisplay
for i = 1, _G.GetNumAddOns() do
    local meta = _G.GetAddOnMetadata(i, "X-BugGrabber-Display")
    if meta then
        local _, _, _, enabled = _G.GetAddOnInfo(i)
        if enabled then
            hasBugDisplay = meta
            break
        end
    end
end

if hasBugDisplay then _G.print("Another display found, RealUI_Error is disabled."); return end
-- Lua Globals --
--local next = _G.next

local errorFrame do
    local function ScrollingEdit_OnLoad(self)
        self.cursorOffset = 0
        self.cursorHeight = 0
    end

    errorFrame = _G.CreateFrame("Frame", "RealUI_ErrorFrame", _G.UIParent, "UIPanelDialogTemplate")
    errorFrame:SetClampedToScreen(true)
    errorFrame:SetMovable(true)
    errorFrame:SetSize(500, 350)
    errorFrame:SetPoint("CENTER")
    errorFrame:SetToplevel(true)
    errorFrame:Hide()

    -- errorFrame.Title:SetText(_G.LUA_ERROR) -- is725
    errorFrame.title:SetText(_G.LUA_ERROR)

    --[[ -- is725
    local dragArea = _G.CreateFrame("Frame", nil, errorFrame, "TitleDragAreaTemplate")
    dragArea:SetPoint("TOPLEFT")
    dragArea:SetPoint("BOTTOMRIGHT", errorFrame, "TOPRIGHT", -26, -26)
    errorFrame.DragArea = dragArea
    ]]
    local dragArea = _G.CreateFrame("Frame", nil, errorFrame)
    dragArea:SetPoint("TOPLEFT")
    dragArea:SetPoint("BOTTOMRIGHT", errorFrame, "TOPRIGHT", -26, -26)
    dragArea:EnableMouse(true)
    dragArea:RegisterForDrag("LeftButton")
    dragArea:SetScript("OnDragStart", function(self)
        self:GetParent().moving = true
        self:GetParent():StartMoving()
    end)
    dragArea:SetScript("OnDragStop", function(self)
        self:GetParent().moving = false
        self:GetParent():StopMovingOrSizing()
    end)
    errorFrame.DragArea = dragArea

    local index = errorFrame:CreateFontString(nil, "ARTWORK", "GameFontNormalCenter")
    index:SetSize(70, 16)
    index:SetPoint("BOTTOM", 0, 16)
    errorFrame.IndexLabel = index

    local scrollFrame = _G.CreateFrame("ScrollFrame", nil, errorFrame, "UIPanelScrollFrameTemplate")
    scrollFrame:SetPoint("TOPLEFT", 12, -30)
    scrollFrame:SetPoint("BOTTOMRIGHT", -30, 40)
    _G.ScrollFrame_OnLoad(scrollFrame)
    errorFrame.ScrollFrame = scrollFrame

    local text = _G.CreateFrame("EditBox", nil, scrollFrame)
    text:SetSize(scrollFrame:GetSize())
    text:SetAutoFocus(false)
    text:SetMultiLine(true)
    text:SetMaxLetters(4000)
    text:SetFontObject("GameFontHighlightSmall")
    text:SetScript("OnCursorChanged", _G.ScrollingEdit_OnCursorChanged)
    text:SetScript("OnUpdate", function(self, elapsed)
        _G.ScrollingEdit_OnUpdate(self, elapsed, self:GetParent())
    end)
    text:SetScript("OnEditFocusGained", function(self)
        self:HighlightText(0)
    end)
    text:SetScript("OnEscapePressed", _G.EditBox_ClearFocus)
    scrollFrame:SetScrollChild(text)
    ScrollingEdit_OnLoad(text)
    scrollFrame.Text = text

    local prevError = _G.CreateFrame("Button", nil, errorFrame)
    prevError:SetSize(32, 32)
    prevError:SetPoint("RIGHT", index, "LEFT")
    prevError:SetNormalTexture([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Up]])
    prevError:SetPushedTexture([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Down]])
    prevError:SetDisabledTexture([[Interface\Buttons\UI-SpellbookIcon-PrevPage-Disabled]])
    prevError:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
    prevError:SetScript("OnClick", function() errorFrame:ShowPrevious() end)
    errorFrame.PreviousError = prevError

    local nextError = _G.CreateFrame("Button", nil, errorFrame)
    nextError:SetSize(32, 32)
    nextError:SetPoint("LEFT", index, "RIGHT")
    nextError:SetNormalTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Up]])
    nextError:SetPushedTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Down]])
    nextError:SetDisabledTexture([[Interface\Buttons\UI-SpellbookIcon-NextPage-Disabled]])
    nextError:SetHighlightTexture([[Interface\Buttons\UI-Common-MouseHilight]], "ADD")
    nextError:SetScript("OnClick", function() errorFrame:ShowNext() end)
    errorFrame.NextError = nextError
end

local CHAT_ERROR_FORMAT = [=[|cffff3333|Herror:%s|h[%s: %s]|h|r]=]
local REALUI_ERROR_FORMAT = [[|cffffd200Message:|r|cffffffff %s|r
|cffffd200Stack:|r|cffffffff %s|r
|cffffd200Time:|r|cffffffff %s|r |cffffd200Count:|r|cffffffff %s|r
|cffffd200Version:|r %s
|cffffd200Locals:|r
|cffffffff%s|r]]
local ERROR_FORMAT = [[|cffffd200Message:|r|cffffffff %s|r
|cffffd200Stack:|r|cffffffff %s|r
|cffffd200Time:|r|cffffffff %s|r |cffffd200Count:|r|cffffffff %s|r
|cffffd200Locals:|r
|cffffffff%s|r]]

--[[local FormatStack do
    local FILE_TEMPLATE   = c.GRAY .. "%1%2\\|r%3:" .. c.GREEN .. "%4|r" .. c.GRAY .. "%5|r%6"
    local STRING_TEMPLATE = c.GRAY .. "%1[string |r\"" .. c.BLUE .. "%2\"|r" .. c.GRAY .. "]|r:" .. c.GREEN .. "%3|r" .. c.GRAY .. "%4|r%5"
    local NAME_TEMPLATE   = c.BLUE .. "'%1'|r"
    local IN_C = c.GOLD .. "[C]|r" .. c.GRAY .. ":|r"

    function FormatStack(stack)
        stack = stack and tostring(stack)
        if not stack then return "" end
        stack = gsub(stack, "Interface\\", "")
        stack = gsub(stack, "AddOns\\", "")
        stack = gsub(stack, "%[C%]", IN_C)
        stack = gsub(stack, "(<?)([%a!_]+)\\(.-%.[lx][um][al]):(%d+)(>?)(:?)", FILE_TEMPLATE)
        stack = gsub(stack, "(<?)%[string \"(.-)\"]:(%d+)(>?)(:?)", STRING_TEMPLATE)
        stack = gsub(stack, "['`]([^`']+)'", NAME_TEMPLATE)
        return stack
    end
end

local FormatLocals do
    local FILE_TEMPLATE   = c.GRAY .. "%1\\|r%2:" .. c.GREEN .. "%3|r"
    local GRAY    = c.GRAY .. "%1|r"
    local EQUALS  = c.GRAY .. " = |r"
    local BOOLEAN = EQUALS .. c.PURPLE .. "%1|r"
    local NUMBER  = EQUALS .. c.ORANGE .. "%1|r"
    local STRING  = EQUALS .. c.BLUE .. "\"%1\"|r"
    local IN_C = c.GOLD .. " [C]|r" .. c.GRAY .. "|r"

    function FormatLocals(locals)
        locals = locals and _G.tostring(locals)
        if not locals then return "" end
        locals = gsub(locals, "> {\n%s*}", ">")
        locals = gsub(locals, "\n%s", "\n    ")
        locals = gsub(locals, "%(%*temporary%)", GRAY)
        locals = gsub(locals, "(<[a-z]+>)", GRAY)
        locals = gsub(locals, "%[C%]:%-%d", IN_C)
        locals = gsub(locals, " = ([ftn][ari][lu]s?e?)", BOOLEAN)
        locals = gsub(locals, " = ([0-9%.%-]+)", NUMBER)
        locals = gsub(locals, " = \"([^\"]+)\"", STRING)
        locals = gsub(locals, "Interface\\A?d?d?[Oo]?n?s?\\?([%a!_]+)\\(.-%.[lx][um][al]):([0-9]+)", FILE_TEMPLATE)
        return locals
    end
end]]

local FormatError do
    local c = {
        BLUE   = _G.BATTLENET_FONT_COLOR_CODE,
        GOLD   = _G.NORMAL_FONT_COLOR_CODE,
        GRAY   = "|cff9f9f9f",
        GREEN  = "|cff7fff7f",
        ORANGE = "|cffff9f7f",
        PURPLE = "|cff9f7fff",
    }

    local FILE_TEMPLATE   = c.GRAY .. "%1%2\\|r%3:" .. c.GREEN .. "%4|r" .. c.GRAY .. "%5|r%6"
    local GRAY    = c.GRAY .. "%1|r"
    local EQUALS  = c.GRAY .. " = |r"
    local BOOLEAN = EQUALS .. c.PURPLE .. "%1|r"
    local NUMBER  = EQUALS .. c.ORANGE .. "%1|r"
    local STRING  = EQUALS .. c.BLUE .. "\"%1\"|r"
    local IN_C = c.GOLD .. " [C]|r" .. c.GRAY .. "|r"

    function FormatError(msg, stack, locals)
        msg = msg and _G.tostring(msg)
        if not msg then return "" end
        msg = msg:gsub("Interface\\", "")
        msg = msg:gsub("AddOns\\", "")
        msg = msg:gsub("> {\n%s*}", ">")
        msg = msg:gsub("\n%s", "\n    ")
        msg = msg:gsub("%(%*temporary%)", GRAY)
        msg = msg:gsub("(<[a-z]+>)", GRAY)
        msg = msg:gsub("%[C%]:%-%d", IN_C)
        msg = msg:gsub(" = ([ftn][ari][lu]s?e?)", BOOLEAN)
        msg = msg:gsub(" = ([0-9%.%-]+)", NUMBER)
        msg = msg:gsub(" = \"([^\"]+)\"", STRING)
        msg = msg:gsub("(<?)([%a!_]+)\\(.-%.[lx][um][al]):(%d+)(>?)(:?)", FILE_TEMPLATE)
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
        if err.message:find("RealUI") then
            editbox:SetText(REALUI_ERROR_FORMAT:format(msg, stack, err.time, err.counter, _G.RealUI:GetVerString(true), locals))
        else
            editbox:SetText(ERROR_FORMAT:format(msg, stack, err.time, err.counter, locals))
        end
        editbox:HighlightText(0, 0)
        editbox:SetCursorPosition(0)

        if not self:IsShown() then
            self:Show()
        end
    end
end

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
    local errorID = _G.BugGrabber:GetErrorID(errorObject)
    _G.print(CHAT_ERROR_FORMAT:format(errorID, _G.LUA_ERROR, errorID))
end
function errorFrame:BugGrabber_CapturePaused()
    --print("Too many errors")
end

_G.BugGrabber.setupCallbacks()
_G.BugGrabber.RegisterCallback(errorFrame, "BugGrabber_BugGrabbed")
_G.BugGrabber.RegisterCallback(errorFrame, "BugGrabber_CapturePaused")
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
_G.SlashCmdList.ERROR = function(str)
    errorFrame:ShowError()
end
