local ADDON_NAME, ns = ... -- luacheck: ignore

-- Diagnostic: blank chat copy window (reported 2026-08-21, beta 6, in a delve).
-- RealUI's LibTextDump instance uses the standard (non-faux) scroll path, so
-- Display() would ERROR on an empty buffer — a blank-but-open window means the
-- EditBox holds text it is not rendering. Prime suspect: the edit box is sized
-- once at creation from scrollArea:GetSize() (anchored to the template's
-- DialogBG), which can be 0x0 before first layout.
--
--   /realdev copydiag — click the chat copy button first (blank window up),
--                       then run this. Reports buffer/editbox/scroll state.

local function Report(copyFrame)
    local editBox = copyFrame.edit_box
    local scrollArea = copyFrame.scrollArea

    local text = editBox and editBox:GetText()
    _G.print(("  frame: shown=%s size=%.0fx%.0f strata=%s"):format(
        tostring(copyFrame:IsShown()), copyFrame:GetWidth(), copyFrame:GetHeight(),
        tostring(copyFrame:GetFrameStrata())))
    if editBox then
        local font, size, flags = editBox:GetFont()
        local r, g, b, a = editBox:GetTextColor()
        _G.print(("  editBox: size=%.1fx%.1f textLen=%d shown=%s alpha=%.2f"):format(
            editBox:GetWidth(), editBox:GetHeight(),
            text and #text or -1, tostring(editBox:IsShown()), editBox:GetAlpha()))
        _G.print(("  editBox font: %s %s [%s] color %.2f,%.2f,%.2f,%.2f"):format(
            tostring(font), tostring(size), tostring(flags),
            r or -1, g or -1, b or -1, a or -1))
    else
        _G.print("  editBox: MISSING")
    end
    if scrollArea then
        _G.print(("  scrollArea: size=%.1fx%.1f shown=%s"):format(
            scrollArea:GetWidth(), scrollArea:GetHeight(), tostring(scrollArea:IsShown())))
        local child = scrollArea.GetScrollChild and scrollArea:GetScrollChild()
        _G.print(("  scrollChild: %s"):format(child and (child == editBox and "editBox" or child:GetDebugName()) or "nil"))
    else
        _G.print("  scrollArea: MISSING")
    end

    local bg = _G[(copyFrame:GetName() or "") .. "DialogBG"]
    if bg then
        _G.print(("  DialogBG: size=%.1fx%.1f shown=%s"):format(
            bg:GetWidth(), bg:GetHeight(), tostring(bg:IsShown())))
    else
        _G.print("  DialogBG: not found by name")
    end
end

function ns.commands:copydiag()
    local textDump = _G.LibStub and _G.LibStub("LibTextDump-1.0", true)
    if not textDump or not textDump.frames then
        _G.print("|cffff0000[CopyDiag]|r LibTextDump (or its frames table) not accessible.")
        return
    end

    -- Only the chat copy frame is interesting (every /debug module owns its
    -- own LibTextDump frame — reporting all of them drowned the signal on the
    -- first live run). Report frames that are shown OR titled "* Copy Frame".
    local found = 0
    for instance, copyFrame in _G.next, textDump.frames do
        local title = (copyFrame.title and copyFrame.title:GetText()) or "?"
        if copyFrame:IsShown() or title:find("Copy Frame", 1, true) then
            _G.print(("|cff00ccff[CopyDiag]|r LibTextDump frame \"%s\" (%d lines buffered, shown=%s):"):format(
                title, instance.Lines and instance:Lines() or -1, tostring(copyFrame:IsShown())))
            Report(copyFrame)
            found = found + 1
        end
    end

    if found == 0 then
        _G.print("|cff00ccff[CopyDiag]|r no copy frame found — click the chat copy button first (leave the blank window open), then re-run.")
    else
        _G.print("|cff00ccff[CopyDiag]|r textLen>0 with a 0-size editBox or invisible font color = rendering bug, not data loss.")
    end
end
