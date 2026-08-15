local _, private = ...
local AB = private.AB

local LAB = _G.LibStub("LibActionButton-1.0")

--[[ Bar object: a SecureHandlerStateTemplate frame owning 12 LAB action
     buttons. Layout math (rows/padding/grow, negative padding legal) and the
     hookable Layout() live here; per-button behavior is all LAB's. ]]--

local function BuildButtonConfig(barDB, keyBoundTarget)
    -- Negative padding overlaps buttons; text must anchor inside the VISUAL
    -- cell (inset by half the overlap), or hotkeys render beside the
    -- neighboring icon. LAB's config merge is recursive, so supplying only
    -- position overrides keeps its font/color defaults.
    local inset = _G.math.max(0, -(barDB.padding or 0) / 2)
    return {
        outOfRangeColoring = "button",
        tooltip = "enabled",
        showGrid = barDB.showgrid,
        flyoutDirection = barDB.flyoutDirection or "UP",
        hideElements = {
            macro = barDB.hidemacrotext,
            hotkey = false,
            equipped = false,
        },
        keyBoundTarget = keyBoundTarget,
        colors = {
            range = { 0.8, 0.1, 0.1 },
            mana = { 0.5, 0.5, 1 },
        },
        text = {
            hotkey = {
                font = { size = 11 },
                position = {
                    anchor = "TOPRIGHT", relAnchor = "TOPRIGHT",
                    offsetX = -(2 + inset), offsetY = -(2 + inset),
                },
            },
            count = {
                font = { size = 12 },
                position = {
                    anchor = "BOTTOMRIGHT", relAnchor = "BOTTOMRIGHT",
                    offsetX = -(2 + inset), offsetY = 2 + inset,
                },
            },
            macro = {
                position = {
                    anchor = "BOTTOM", relAnchor = "BOTTOM",
                    offsetX = 0, offsetY = 2 + inset,
                },
            },
        },
    }
end

local barMixin = {}

function barMixin:GetDB()
    return AB.dbActionBars.profile.actionbars[self.id]
end

-- Grid layout from the bar's config. Insecure sizing/anchoring on our own
-- frame + LAB buttons: legal out of combat; callers queue via QueueSecure.
function barMixin:Layout()
    local db = self:GetDB()
    local shown = db.buttons or 12
    local rows = _G.math.max(1, _G.math.min(db.rows or 1, shown))
    local perRow = _G.math.ceil(shown / rows)
    local size, pad = db.buttonSize or 26, db.padding or 2

    local dirH = (db.growHorizontal == "LEFT") and -1 or 1
    local dirV = (db.growVertical == "UP") and 1 or -1
    local corner = ((dirV == -1) and "TOP" or "BOTTOM") .. ((dirH == 1) and "LEFT" or "RIGHT")

    self:SetSize(perRow * (size + pad) - pad, rows * (size + pad) - pad)

    for i = 1, 12 do
        local button = self.buttons[i]
        button:ClearAllPoints()
        if i > shown then
            button:Hide()
        else
            local col = (i - 1) % perRow
            local row = _G.math.floor((i - 1) / perRow)
            button:SetSize(size, size)
            button:SetPoint(corner, self, corner,
                col * (size + pad) * dirH,
                row * (size + pad) * dirV)
            button:Show()
        end
    end
end

function barMixin:ApplyConfig()
    local db = self:GetDB()

    self._ruiConfig = db
    self._ruiAlpha = db.alpha or 1
    self:SetAlpha(db.alpha or 1)

    -- Scale BEFORE anchoring: SetPoint offsets live in the frame's scaled
    -- space, so setting scale afterwards would shift the bar.
    self:SetScale(db.scale or 1)
    -- BT4-semantics anchoring (what the RealUI geometry was written for): the
    -- bar's GROW-ORIGIN CORNER anchors to the named UIParent point at (x, y) —
    -- not the frame's own matching point.
    local cornerV = (db.growVertical == "UP") and "BOTTOM" or "TOP"
    local cornerH = (db.growHorizontal == "LEFT") and "RIGHT" or "LEFT"
    self:ClearAllPoints()
    self:SetPoint(cornerV .. cornerH, _G.UIParent, db.position.point,
        db.position.x, db.position.y)

    -- Negative padding = overlapping buttons; inset the skin's visual cell by
    -- half the overlap so cells tile seamlessly (Masque handles its own).
    local inset = _G.math.max(0, -(db.padding or 0) / 2)
    for i = 1, 12 do
        local button = self.buttons[i]
        button.config = BuildButtonConfig(db, button.config and button.config.keyBoundTarget)
        button:UpdateConfig(button.config)
        if not private.usingMasque then
            private.ApplyButtonInset(button, inset)
        end
    end

    self:Layout()
    private.ApplyVisibility(self, db.enabled and db.visibility or nil)
    if not db.enabled then
        _G.UnregisterStateDriver(self, "vis")
        self:Hide()
    end
end

function private.CreateBar(id)
    local bar = _G.CreateFrame("Frame", "RealUI_AB_Bar" .. id, _G.UIParent,
        "SecureHandlerStateTemplate")
    _G.Mixin(bar, barMixin)
    bar.id = id
    bar.buttons = {}

    private.SetupVisibility(bar)

    local db = AB.dbActionBars.profile.actionbars[id]
    for i = 1, 12 do
        -- Bar 1 mirrors Blizzard's main bar, so its buttons display (and are
        -- pressed by) the user's ACTIONBUTTON bindings. Other bars use custom
        -- click bindings (Bindings.lua).
        local keyBoundTarget = (id == 1) and ("ACTIONBUTTON" .. i) or nil
        local button = LAB:CreateButton(i, bar:GetName() .. "B" .. i, bar,
            BuildButtonConfig(db, keyBoundTarget))

        if id == 1 then
            -- Paged: state N = action page N (the state driver in ActionBars.lua
            -- flips the header state; LAB routes it to the buttons).
            for page = 1, 18 do
                button:SetState(page, "action", (page - 1) * 12 + i)
            end
            button:SetState(0, "action", i)
        else
            button:SetState(0, "action", (id - 1) * 12 + i)
        end

        bar.buttons[i] = button
    end

    return bar
end
