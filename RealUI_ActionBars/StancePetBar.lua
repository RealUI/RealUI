local _, private = ...
local AB = private.AB

--[[ Stance + pet bars: rather than reimplementing the (fiddly, secure) stance
     and pet button behavior, adopt Blizzard's own StanceButton1..N and
     PetActionButton1..10 into RealUI-owned secure holder frames — their click
     handling stays Blizzard-secure, we own position, layout, and visibility.
     Fixes the stray vertical Blizzard stance bar (EditMode layout) by making
     it horizontal at the RealUI position. ]]--

local stanceBar, petBar

local function AdoptButtons(holder, buttonPrefix, kind, count, size, padding, growH, growV)
    local dirH = (growH == "LEFT") and -1 or 1
    local vertical = (growV ~= nil)
    -- Same box model as Bar.lua (B28): the skin draws a 1px border OUTSIDE the
    -- button frame, so db.padding is the visible gap between borders and both
    -- neighbours' borders sit between the frames.
    local gap = padding + private.BUTTON_BORDER * 2
    local shown = 0
    for i = 1, count do
        local button = _G[buttonPrefix .. i]
        if button then
            shown = shown + 1
            _G.pcall(button.SetParent, button, holder)
            button:ClearAllPoints()
            button:SetSize(size, size)
            if vertical then
                button:SetPoint("TOP", holder, "TOP", 0, -((i - 1) * (size + gap)))
            else
                button:SetPoint(dirH == 1 and "LEFT" or "RIGHT", holder,
                    dirH == 1 and "LEFT" or "RIGHT",
                    (i - 1) * (size + gap) * dirH, 0)
            end
            -- Blizzard's own buttons: nothing else skins them (see Skin.lua).
            -- After the resize, so the size-derived resets land on final sizes.
            if private.SkinAdoptedButton then
                private.SkinAdoptedButton(button, kind)
            end
        end
    end
    if vertical then
        holder:SetSize(size, _G.math.max(1, shown * (size + gap) - gap))
    else
        holder:SetSize(_G.math.max(1, shown * (size + gap) - gap), size)
    end
    if private.ReSkinAdoptedBar then
        private.ReSkinAdoptedBar(kind)
    end
end

local function EnsureHolder(name)
    local holder = _G.CreateFrame("Frame", name, _G.UIParent, "SecureHandlerStateTemplate")
    private.SetupVisibility(holder)
    return holder
end

function private.BuildStanceBar()
    local db = AB.dbStanceBar.profile
    if not db.enabled then
        if stanceBar then
            _G.UnregisterStateDriver(stanceBar, "vis")
            stanceBar:Hide()
        end
        return
    end

    stanceBar = stanceBar or EnsureHolder("RealUI_AB_Stance")
    stanceBar._ruiConfig = db
    stanceBar._ruiAlpha = 1
    stanceBar:ClearAllPoints()
    -- Grow-corner anchoring, consistent with Bar.lua: LEFT growth hangs the
    -- bar off its top-right corner.
    local corner = (db.growHorizontal == "LEFT") and "TOPRIGHT" or "TOPLEFT"
    stanceBar:SetPoint(corner, _G.UIParent, db.position.point,
        db.position.x, db.position.y)

    local numForms = _G.GetNumShapeshiftForms() or 0
    AdoptButtons(stanceBar, "StanceButton", "Stance", _G.math.max(numForms, 1),
        db.buttonSize, db.padding, db.growHorizontal)

    if numForms > 0 then
        private.ApplyVisibility(stanceBar, db.visibility)
    else
        _G.UnregisterStateDriver(stanceBar, "vis")
        stanceBar:Hide()
    end
end

function private.BuildPetBar()
    local db = AB.dbPetBar.profile
    if not db.enabled then
        if petBar then
            _G.UnregisterStateDriver(petBar, "vis")
            petBar:Hide()
        end
        return
    end

    petBar = petBar or EnsureHolder("RealUI_AB_Pet")
    petBar._ruiConfig = db
    petBar._ruiAlpha = 1
    petBar:ClearAllPoints()
    petBar:SetPoint("TOPLEFT", _G.UIParent, db.position.point,
        db.position.x, db.position.y)

    -- Vertical column (the shipped RealUI look: rows = 10).
    AdoptButtons(petBar, "PetActionButton", "Pet", 10, db.buttonSize, db.padding, nil, "DOWN")
    private.ApplyVisibility(petBar, db.visibility)
end

local layoutHooksInstalled
local function InstallRelayoutHooks()
    -- Blizzard's parked bar containers still run their own layout code on
    -- events and re-anchor/re-size the buttons we adopted; re-adopt whenever
    -- that happens.
    if layoutHooksInstalled then return end
    layoutHooksInstalled = true
    for frameName, rebuild in _G.next, {
        StanceBar = private.BuildStanceBar,
        PetActionBar = private.BuildPetBar,
    } do
        local frame = _G[frameName]
        if frame then
            for _, method in _G.ipairs({ "Layout", "UpdateGridLayout" }) do
                if _G.type(frame[method]) == "function" then
                    _G.hooksecurefunc(frame, method, function()
                        private.QueueSecure(rebuild)
                    end)
                end
            end
        end
    end
end

function private.BuildStancePetBars()
    private.BuildStanceBar()
    private.BuildPetBar()
    InstallRelayoutHooks()
end
