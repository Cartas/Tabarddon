local _, ns = ...

-- Assign global functions to locals for optimisation.
local GetInventoryItemID = GetInventoryItemID
local GetInstanceInfo = GetInstanceInfo
local GetFactionInfoByID = GetFactionInfoByID
local EquipItemByName = EquipItemByName

local factions = ns.factions

local _BACKDROP = {
    bgFile = [[Interface\Tooltips\UI-Tooltip-Background]],
    edgeFile = [[Interface\Tooltips\UI-Tooltip-Border]],
    tile = true, tileSize = 8, edgeSize = 16,
    insets = {left = 4, right = 4, top = 4, bottom = 4}
}

local frame = CreateFrame("Frame", nil, UIParent, InterfaceOptionsFramePanelContainer)
frame:SetSize(400, 65)
frame:SetPoint("LEFT")
frame:SetBackdrop(_BACKDROP)
frame:SetBackdropColor(0.3, 0.3, 0.3, 1.0)
frame:SetBackdropBorderColor(0.3, 0.3, 0.5)

local textArea = frame:CreateFontString(nil, nil)
textArea:SetFont("Fonts\\ARIALN.TTF", 12)
textArea:SetPoint("TOP", 0, -10)

local equipButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
equipButton:SetPoint("BOTTOM", 0, 10)
equipButton:SetSize(100, 22)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local function showUI(self)
    frame:Show()
    textArea:Show()
    equipButton:Show()
end

local function hideUI(self)
    frame:Hide()
    textArea:Hide()
    equipButton:Hide()
end

local function showOrHideUI(self, event, ...)
    local _, type = GetInstanceInfo()
    
    if (type == "party" or type == "raid") then
        local equippedTabardID = GetInventoryItemID("player", 19)
        for factionID, tabardID in pairs(factions) do
            local factionName, _, factionStandingID = GetFactionInfoByID(factionID)
            if (equippedTabardID == tabardID and factionStandingID < 8) then
                hideUI()
                return
            end
        end

        textArea:SetText("You're currently wearing a tabard that gives you no benefits!")
        showUI()
    else
        hideUI()
    end
end

frame:SetScript("OnEvent", showOrHideUI)

local function equipTabard(self, mouseButton)
    if (mouseButton == "LeftButton") then
        EquipItemByName(earthenRingTabardID)
        hideUI()
    end
end

equipButton:SetScript("OnClick", equipTabard)