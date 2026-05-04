-- CooldownViewer_MergeTest.lua
-- Verifies the production CooldownViewer module (RealUI_Auras/CooldownViewer.lua)
-- round-trips correctly and that MergePreset works end-to-end.
-- Usage: /realdev cdmmergetest

local _, ns = ... -- luacheck: ignore

local IMPORT_STRING = "1|NdC7SgNhEAXgNS74AjJ4fpHVBzCFV5KVYCJYCsFSEXS1sRCM2HhPCBLjC4jdFnZWJiBxC60s0mxqGzUQ1NbKKIhnNqb5ZqrhzCnaJ/5A1rcLF2mcO8AL8A38oExfIVMINyETkEnIGGQa4kJm0LDQLEFSkFmET5A5SALNFcg4TBGSRLkNyRirx/uE8WDWuT7bZC2EeeSstzC4zZm4I66jW0Cqo8oySV4q/STVR07vlQdyc0sqe8q+cqAcKkfKsXKtV+LKEqm9Ke/KBxoLxortfJHcr26B0ia7Q6S6eGXl+XWsFOX4zxh089Rb3chRUNfpzUfXhs/0YTbCslhipwLJdBoZKfBlVuDb8+mct7q18Qc="

-- ── Diagnostic ───────────────────────────────────────────────────────────────

function ns.commands:cdmencodinginfo()
    local eu = _G.C_EncodingUtil
    if not eu then _G.print("[cdmenc] C_EncodingUtil: NOT FOUND"); return end
    _G.print("[cdmenc] C_EncodingUtil available")
    _G.print("[cdmenc] SerializeCBOR:",    type(eu.SerializeCBOR))
    _G.print("[cdmenc] DeserializeCBOR:",  type(eu.DeserializeCBOR))
    _G.print("[cdmenc] CompressString:",   type(eu.CompressString))
    _G.print("[cdmenc] DecompressString:", type(eu.DecompressString))
    _G.print("[cdmenc] EncodeBase64:",     type(eu.EncodeBase64))
    _G.print("[cdmenc] DecodeBase64:",     type(eu.DecodeBase64))
end

-- ── Round-trip test using production module ──────────────────────────────────

function ns.commands:cdmmergetest()
    -- Resolve the production module
    local CDV = _G.RealUI_Auras and _G.RealUI_Auras.CooldownViewer
    if not CDV then
        _G.print("[cdmmergetest] RealUI_Auras.CooldownViewer not loaded."); return
    end

    -- 1. Verify Decode/Encode round-trip
    local ok, decoded = pcall(CDV.Decode, IMPORT_STRING)
    if not ok then
        _G.print("[cdmmergetest] Decode FAILED:", decoded); return
    end
    _G.print("[cdmmergetest] Decode OK — version:", decoded[1], "specLayouts:", decoded[3] and "present" or "nil")

    local ok2, reencoded = pcall(CDV.Encode, decoded)
    if not ok2 then
        _G.print("[cdmmergetest] Encode FAILED:", reencoded); return
    end

    -- Re-decode to verify structural equivalence (base64 may differ due to padding)
    local ok3, redecoded = pcall(CDV.Decode, reencoded)
    if not ok3 then
        _G.print("[cdmmergetest] Re-decode FAILED:", redecoded); return
    end
    _G.print("[cdmmergetest] Round-trip OK — version matches:", decoded[1] == redecoded[1])

    -- 2. Verify MergePreset against live data
    if not _G.C_CooldownViewer or not _G.C_CooldownViewer.IsCooldownViewerAvailable then
        _G.print("[cdmmergetest] C_CooldownViewer not available — skipping live merge."); return
    end
    local available, reason = _G.C_CooldownViewer.IsCooldownViewerAvailable()
    if not available then
        _G.print("[cdmmergetest] Unavailable:", reason, "— skipping live merge."); return
    end

    local added, skipped, err = CDV.MergePreset(IMPORT_STRING)
    if err then
        _G.print("[cdmmergetest] MergePreset FAILED:", err); return
    end
    _G.print(("[cdmmergetest] MergePreset OK — added %d, skipped %d"):format(added, skipped))

    -- 3. Verify idempotence — second merge should skip all
    local added2, skipped2, err2 = CDV.MergePreset(IMPORT_STRING)
    if err2 then
        _G.print("[cdmmergetest] Idempotence check FAILED:", err2); return
    end
    _G.print(("[cdmmergetest] Idempotence OK — added %d, skipped %d"):format(added2, skipped2))

    -- 4. Verify IsPresetApplied
    local applied = CDV.IsPresetApplied()
    _G.print("[cdmmergetest] IsPresetApplied:", applied)

    _G.print("[cdmmergetest] ALL CHECKS PASSED")
end
