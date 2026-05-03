local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

---------------------------------------------------------
-- Competing addon detection (Task 3)
---------------------------------------------------------
local COMPETING_ADDONS = {
    { name = "!KalielsTracker",       display = "Kaliel's Tracker" },
    { name = "AscensionQuestTracker", display = "Ascension Quest Tracker" },
    { name = "EskaQuestTracker",      display = "Eska Quest Tracker" },
}

function RealUI_Tracker:CheckForConflicts()
    for _, entry in ipairs(COMPETING_ADDONS) do
        if C_AddOns.IsAddOnLoaded(entry.name) then
            print("|cffff6600RealUI Tracker:|r disabled — conflicts with "
                .. entry.display .. ". Uninstall it to use RealUI Tracker.")
            self:SetEnabledState(false)
            return true
        end
    end
    return false
end

---------------------------------------------------------
-- Container wrapper (Task 2)
---------------------------------------------------------
local container
local OTF

function RealUI_Tracker:SetupContainer()
    -- 2.1: Create container frame
    container = CreateFrame("Frame", "RealUI_TrackerFrame", UIParent)
    container:SetFrameStrata("MEDIUM")

    OTF = _G.ObjectiveTrackerFrame

    -- 2.2: Reparent ObjectiveTrackerFrame into the container
    OTF:SetParent(container)
    OTF:ClearAllPoints()
    OTF:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)

    -- 2.3: Overwrite SetParent with a no-op (store original for cleanup)
    private.origSetParent = OTF.SetParent
    OTF.SetParent = function() end

    -- 2.4: Hook SetPoint with re-entrancy guard
    local movingTracker = false
    hooksecurefunc(OTF, "SetPoint", function()
        if movingTracker then return end
        movingTracker = true
        OTF:ClearAllPoints()
        OTF:SetPoint("TOPLEFT", container, "TOPLEFT", 0, 0)
        movingTracker = false
    end)

    -- 2.5 / 2.6: Apply initial position and register scale/display events
    self:UpdatePosition()
    self:RegisterEvent("UI_SCALE_CHANGED", "UpdatePosition")
    self:RegisterEvent("DISPLAY_SIZE_CHANGED", "UpdatePosition")

    private.containerSetUp = true
end

-- 2.5: UpdatePosition — reads db.position, sets container anchor and height
function RealUI_Tracker:UpdatePosition()
    if not container then return end

    local db = self.db.profile.position
    if not db.enabled then
        container:ClearAllPoints()
        container:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -14, -200)
        container:SetHeight(UIParent:GetHeight() - 300)
        return
    end

    container:ClearAllPoints()
    container:SetPoint(db.anchorFrom, UIParent, db.anchorTo, db.x, db.y)
    local height = math.max(100, UIParent:GetHeight() - db.maxHeightOffset)
    container:SetHeight(height)
    container:SetWidth(OTF:GetWidth())
end

-- 2.7: Cleanup on disable
function RealUI_Tracker:CleanupContainer()
    if not private.containerSetUp then return end

    -- Unregister scale/display events
    self:UnregisterEvent("UI_SCALE_CHANGED")
    self:UnregisterEvent("DISPLAY_SIZE_CHANGED")

    -- Restore SetParent and reparent back to UIParent
    if private.origSetParent then
        OTF.SetParent = private.origSetParent
        private.origSetParent = nil
    else
        OTF.SetParent = nil
    end

    OTF:SetParent(UIParent)
    OTF:ClearAllPoints()
    OTF:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -14, -200)

    private.containerSetUp = false
end
