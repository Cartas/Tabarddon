local _, ns = ...

local GetGuildFactionInfo = GetGuildFactionInfo
local GetFactionInfoByID = GetFactionInfoByID

local reputationColours = ns.reputationColours

local BAR_SPACING = 30

local factionBars = {}

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = "Tabarddon"
frame:Hide()

frame:SetScript("OnShow", function(self)
    self:CreateOptions()
    self:SetScript("OnShow", nil)
end)

local _BACKDROP = {
	bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
	edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
	tile = true, tileSize = 8, edgeSize = 16,
	insets = {left = 4, right = 4, top = 4, bottom = 4}
}

table.indexOf = function( t, object )
    local result

    for i=1,#t do
        if object == t[i] then
            result = i
            break
        end
    end

    return result
end

local function adjustFactionRanking(bar, downwards)
    local ranking = table.indexOf(factionBars, bar)
    local limit = 1
    if downwards then
        limit = table.getn(factionBars)
    end
    -- Too high up/down?  Don't go anywhere!
    if ranking == limit then
        return
    end

    local replaceRank = ranking - 1
    if downwards then
        replaceRank = ranking + 1
    end

    -- Swap the two factions' bars around in the display
    barToReplace = factionBars[replaceRank]

    local point, relativeTo, relativePoint, xOffset, yOffset = bar:GetPoint(1)
    local point, relativeTo, relativePoint, xOffset, replaceYOffset = barToReplace:GetPoint(1)

    if downwards then
        bar:SetPoint("TOPLEFT", 16, yOffset - BAR_SPACING)
        barToReplace:SetPoint("TOPLEFT", 16, replaceYOffset + BAR_SPACING)
    else
        bar:SetPoint("TOPLEFT", 16, yOffset + BAR_SPACING)
        barToReplace:SetPoint("TOPLEFT", 16, replaceYOffset - BAR_SPACING)
    end

    factionBars[replaceRank], factionBars[ranking] = factionBars[ranking], factionBars[replaceRank]

    -- Swap the two factions' ranks in the table
    FactionRanking[replaceRank], FactionRanking[ranking] = FactionRanking[ranking], FactionRanking[replaceRank]
end

local function createFactionBar(parent, factionName, factionStandingID, rank)
    local bar = CreateFrame("Frame", factionName, parent)
    bar:SetSize(300, 24)
    bar:SetBackdrop(_BACKDROP)

    factionBars[rank] = bar

    local colours = reputationColours[factionStandingID]
    
    bar:SetBackdropColor(colours[1], colours[2], colours[3], 1.0)
    bar:SetBackdropBorderColor(0.3, 0.3, 0.5)

    local name = bar:CreateFontString(nil, nil, "GameFontNormal")
    name:SetPoint("TOPLEFT", 10, -5)
    name:SetText(factionName)

    local upRank = CreateFrame("Button", "upRank", parent, "UIPanelButtonTemplate")
    upRank:SetSize(10, 12)
    upRank:SetPoint("TOPRIGHT", bar, 10, 0)
    upRank:SetText("U");
    upRank:SetScript("OnClick", function(self, button) adjustFactionRanking(bar, false) end)

    local downRank = CreateFrame("Button", "downRank", parent, "UIPanelButtonTemplate")
    downRank:SetSize(10, 12)
    downRank:SetPoint("TOPRIGHT", bar, 10, -12)
    downRank:SetText("D")
    downRank:SetScript("OnClick", function(self, button) adjustFactionRanking(bar, true) end)

    return bar
end

function frame:CreateOptions()
    local title = self:CreateFontString(nil, nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Tabarddon")

    local subtitle = self:CreateFontString(nil, nil, "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetPoint("RIGHT", self, -2, 0)
    subtitle:SetText("Prioritise your Factions!")
    
	local scrollchild = CreateFrame("Frame", nil, self)
	scrollchild:SetPoint"LEFT"
    scrollchild:SetWidth(412)
	scrollchild:SetHeight(1000)

    local scroll = CreateFrame("ScrollFrame", "scrollFrame", self, "UIPanelScrollFrameTemplate")
	scroll:SetPoint('TOPLEFT', subtitle, 'BOTTOMLEFT', 0, -8)
	scroll:SetPoint("BOTTOMRIGHT", -30, 4)
	scroll.scrollchild = scrollchild
    scroll:SetScrollChild(scrollchild)
    
    -- List all factions with rep.
    local yOffset = 0
    local ranking = 1

    for i, factionTabardObject in ipairs(FactionRanking) do
        local factionID = factionTabardObject[1]
        local tabardID = factionTabardObject[2]

        local factionName, _, factionStandingID, _, _, _, atWarWith, canToggleAtWar = GetFactionInfoByID(factionID)

        local factionRow = createFactionBar(scrollchild, factionName, factionStandingID, ranking)
        factionRow:SetPoint("TOPLEFT", 16, (-yOffset))

        yOffset = yOffset + BAR_SPACING
        ranking = ranking + 1
    end

	scrollchild:SetHeight(yOffset + BAR_SPACING)
	scroll:UpdateScrollChildRect()
	scroll:EnableMouseWheel(true)

	scroll.value = 0
	scroll:SetVerticalScroll(0)
	scrollchild:SetPoint('TOP', 0, 0)

    self:refresh()
end

InterfaceOptions_AddCategory(frame)

-- Opens options window on /tabarddon command
SLASH_TABARDDON_UI1 = '/tabarddon'
SlashCmdList['TABARDDON_UI'] = function()
	InterfaceOptionsFrame_OpenToCategory('Tabarddon')
end
