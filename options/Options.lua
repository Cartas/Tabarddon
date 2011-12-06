local _, ns = ...

local GetGuildFactionInfo = GetGuildFactionInfo
local GetFactionInfoByID = GetFactionInfoByID

local factions = ns.factions
local reputationColours = ns.reputationColours

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
	insets = {left = 2, right = 2, top = 2, bottom = 2}
}

local createFactionBar = function(parent, factionName, factionStandingID)
    local bar = CreateFrame("Frame", nil, parent)
    bar:SetSize(300, 24)
    bar:SetBackdrop(_BACKDROP)

    local colours = reputationColours[factionStandingID]
    
    bar:SetBackdropColor(colours[1], colours[2], colours[3], 1.0)
    bar:SetBackdropBorderColor(0.3, 0.3, 0.5)

    local name = bar:CreateFontString(nil, nil, "GameFontNormal")
    name:SetPoint("TOPLEFT", 10, -5)
    name:SetText(factionName)

    return bar
end

function frame:CreateOptions()
    local title = self:CreateFontString(nil, nil, "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText("Tabarddon")

    local subtitle = self:CreateFontString(nil, nil, "GameFontHighlight")
    subtitle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    subtitle:SetPoint("RIGHT", self, -32, 0)
    subtitle:SetText("Prioritise your Factions!")

    
	local scrollchild = CreateFrame("Frame", nil, self)
	scrollchild:SetPoint"LEFT"
    scrollchild:SetWidth(412)
	scrollchild:SetHeight(1000)

    local scroll = CreateFrame("ScrollFrame", "scrollFrame", self, "UIPanelScrollFrameTemplate")
	scroll:SetPoint('TOPLEFT', subtitle, 'BOTTOMLEFT', 0, -8)
	scroll:SetPoint("BOTTOMRIGHT", 0, 4)
	scroll.scrollchild = scrollchild
    scroll:SetScrollChild(scrollchild)
    
    local yOffset = 0

    local guildName, _, guildStandingID = GetGuildFactionInfo()

    if (guildName) then
        local guildRow = createFactionBar(scrollchild, guildName, guildStandingID)
        guildRow:SetPoint("TOPLEFT", 16, (-yOffset))

        yOffset = yOffset + 30
    end

    for factionID, tabardID in pairs(factions) do
        local factionName, _, factionStandingID = GetFactionInfoByID(factionID)

        local factionRow = createFactionBar(scrollchild, factionName, factionStandingID)
        factionRow:SetPoint("TOPLEFT", 16, (-yOffset))

        yOffset = yOffset + 30
    end

	scrollchild:SetHeight(yOffset + 30)
	scroll:UpdateScrollChildRect()
	scroll:EnableMouseWheel(true)

	scroll.value = 0
	scroll:SetVerticalScroll(0)
	scrollchild:SetPoint('TOP', 0, 0)

    self:refresh()
end

InterfaceOptions_AddCategory(frame)

SLASH_TABARDDON_UI1 = '/tabarddon'
SlashCmdList['TABARDDON_UI'] = function()
	InterfaceOptionsFrame_OpenToCategory('Tabarddon')
end
