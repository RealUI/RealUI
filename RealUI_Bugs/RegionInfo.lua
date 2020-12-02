local _, private = ...

-- luacheck: globals select type tostring
-- luacheck: globals table tinsert ipairs

local coords4 = "    |cff00ffffL:(%.2f), R:(%.2f), T:(%.2f), B:(%.2f)|r"
local coords8 = "    |cff00ffffUL:(%.2f, %.2f), BL:(%.2f, %.2f), UR:(%.2f, %.2f), BR:(%.2f, %.2f)|r"
local function AreTexCoordsValid(...)
    local coordCount = select("#", ...)
    for i = 1, coordCount do
        if type(select(i, ...)) ~= "number" then
            return false
        end
    end

    return coordCount == 8
end
local function GetTexCoord(...)
    if AreTexCoordsValid(...) then
        local ulX, ulY, blX, blY, urX, urY, brX, brY = ...

        if ulX == 0 and ulY == 0 and blX == 0 and blY == 1 and
                urX == 1 and urY == 0 and brX == 1 and brY == 1 then
            return
        elseif ulX == blX and urX == brX and
                ulY == urY and blY == brY then
            return coords4:format(ulX, urX, ulY, blY)
        else
            return coords8:format(ulX, ulY, blX, blY, urX, urY, brX, brY)
        end
    end

    return "invalid coordinates"
end
local function GetAssetInfo(obj)
    local assetName = obj:GetAtlas()
    local assetType = "Atlas"

    if not assetName then
        assetName = obj:GetTextureFilePath()
        assetType = "File"
    end

    if not assetName then
        assetName = obj:GetTextureFileID()
        assetType = "FileID"
    end

    if not assetName then
        assetName = "UnknownAsset"
        assetType = "Unknown"
    end

    local layer, subLayer = obj:GetDrawLayer()

    local ulX, ulY, blX, blY, urX, urY, brX, brY = obj:GetTexCoord()
    return assetName, assetType, layer, subLayer, ulX, ulY, blX, blY, urX, urY, brX, brY
end

local assetFile = "    |c%s%s|r: %s"
local assetLayer = "    |cffff00ff%s|r, %d"
local function FormatAssetInfo(assetName, assetType, layer, subLayer, ...)
    assetName = tostring(assetName)

    local assetColor = "ffff0000"
    if assetType == "Atlas" then
        assetColor = "ff00ff00"
    end

    return assetFile:format(assetColor, assetType, assetName), assetLayer:format(layer, subLayer), GetTexCoord(...)
end
local function GetTextureRegions(...)
    local assets = {}
    local textureName
    for i = 1, select("#", ...) do
        local region = select(i, ...)
        if not region:IsForbidden() then
            if region:GetObjectType() == "Texture" and region:IsMouseOver() then
                textureName = region:GetDebugName()..":"
                --print("region", i, textureName)
                tinsert(assets, {textureName, FormatAssetInfo(GetAssetInfo(region))})
            end
        end
    end

    return assets
end
local function GetTextureInfo(self, obj)
    if obj.GetRegions then
        return GetTextureRegions(obj:GetRegions())
    else
        return GetTextureRegions(obj)
    end
end

function private.SetFramestack(self, highlightFrame)
    if not self.showTextureInfo then return end
    if not self.highlightFrame or self.highlightFrame:IsForbidden() then return end

    local lineNum, fsobj
    for i = self:NumLines(), 1, -1 do
        local line = _G["FrameStackTooltipTextLeft"..i]
        local text = line:GetText()
        if text then
            if text:find("<%d+>") then
                lineNum = i + 1
                break
            elseif text:find("fsobj") then
                fsobj = line:GetText()
            end
        end
    end

    _G["FrameStackTooltipTextLeft"..lineNum]:SetText("\n")

    local assets = GetTextureInfo(self, self.highlightFrame)
    for index, asset in ipairs(assets) do
        lineNum = lineNum + 1

        local line = _G["FrameStackTooltipTextLeft"..lineNum]
        if line then
            line:SetText(table.concat(asset, "\n"))
        else
            self:AddLine(table.concat(asset, "\n"))
        end
    end

    if fsobj then
        if #assets == 0 then
            _G["FrameStackTooltipTextLeft"..lineNum]:SetText(fsobj)
        else
            self:AddLine(fsobj)
        end
    end

end

