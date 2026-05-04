-- Tests whether C_CooldownViewer.SetLayoutData() works from a slash command context.
-- Usage: /realdev cdmsetlayouttest
--
-- Previously confirmed working from PLAYER_LOGIN and OnClick.
-- This test fires from a user-typed slash command (tainted) with no auto-run on login.

local _, ns = ... -- luacheck: ignore

local IMPORT_STRING = "1|NdC7SgNhEAXgNS74AjJ4fpHVBzCFV5KVYCJYCsFSEXS1sRCM2HhPCBLjC4jdFnZWJiBxC60s0mxqGzUQ1NbKKIhnNqb5ZqrhzCnaJ/5A1rcLF2mcO8AL8A38oExfIVMINyETkEnIGGQa4kJm0LDQLEFSkFmET5A5SALNFcg4TBGSRLkNyRirx/uE8WDWuT7bZC2EeeSstzC4zZm4I66jW0Cqo8oySV4q/STVR07vlQdyc0sqe8q+cqAcKkfKsXKtV+LKEqm9Ke/KBxoLxortfJHcr26B0ia7Q6S6eGXl+XWsFOX4zxh089Rb3chRUNfpzUfXhs/0YTbCslhipwLJdBoZKfBlVuDb8+mct7q18Qc="

function ns.commands:cdmsetlayouttest()
    if not _G.C_CooldownViewer or not _G.C_CooldownViewer.IsCooldownViewerAvailable then
        _G.print("[cdmsetlayouttest] C_CooldownViewer not available.")
        return
    end

    local available, reason = _G.C_CooldownViewer.IsCooldownViewerAvailable()
    if not available then
        _G.print("[cdmsetlayouttest] Unavailable:", reason)
        return
    end

    local before = _G.C_CooldownViewer.GetLayoutData()
    _G.print("[cdmsetlayouttest] Before:", before and before:sub(1, 30) .. "..." or "nil")

    local ok, err = pcall(_G.C_CooldownViewer.SetLayoutData, IMPORT_STRING)
    if ok then
        local after = _G.C_CooldownViewer.GetLayoutData()
        _G.print("[cdmsetlayouttest] SetLayoutData: SUCCESS — data changed:", before ~= after)
        local trigOk, trigErr = pcall(_G.EventRegistry.TriggerEvent, _G.EventRegistry, "CooldownViewerSettings.OnDataChanged")
        if trigOk then
            _G.print("[cdmsetlayouttest] TriggerEvent: SUCCESS — viewer should refresh live.")
        else
            _G.print("[cdmsetlayouttest] TriggerEvent: FAILED —", trigErr)
        end
    else
        _G.print("[cdmsetlayouttest] SetLayoutData: FAILED —", err)
    end
end
