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
frame:SetSize(200, 65)
frame:SetPoint("TOP")
frame:SetBackdrop(_BACKDROP)
frame:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
frame:SetBackdropBorderColor(0.5, 0.5, 0.5)

local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
closeButton:SetPoint("TOPRIGHT", 0, 0)

local textArea = frame:CreateFontString(nil, nil)
textArea:SetFont("Fonts\\ARIALN.TTF", 12)
textArea:SetPoint("TOP", 0, -10)

local equipButton = CreateFrame("Button", nil, frame, "UIPanelButtonTemplate")
equipButton:SetPoint("BOTTOM", 0, 10)
equipButton:SetSize(110, 22)

frame:RegisterEvent("PLAYER_ENTERING_WORLD")

local wantedTabardID

local function showOrHideUI(self, event, ...)   
    print(FactionRanking)
    if not FactionRanking then
        FactionRanking = {}

        for i, factionTabardObject in ipairs(factions) do
            local factionID = factionTabardObject[1]
            local tabardID = factionTabardObject[2]

            local factionName, _, factionStandingID, _, _, _, atWarWith, canToggleAtWar = GetFactionInfoByID(factionID)

            print(factionName)
            print(atWarWith)
            print(canToggleAtWar)

            -- Only show factions we can possible befriend
            if not (atWarWith and not canToggleAtWar) then
                table.insert(FactionRanking, {factionID, tabardID})
            end
        end
    end
 
    local _, instanceType = GetInstanceInfo()
    
    if (instanceType == "party" or instanceType == "raid") then
        local equippedTabardID = GetInventoryItemID("player", 19)
        for i, factionTabardObject in ipairs(FactionRanking) do
            local factionID = factionTabardObject[1]
            local tabardID = factionTabardObject[2]

            local factionName, _, factionStandingID = GetFactionInfoByID(factionID)

            -- Hides the recommendation if you're already using the right tabard
            if (equippedTabardID == tabardID and factionStandingID < 8) then
                frame:Hide()
                return
            end

            if factionStandingID < 8 then
                equipButton:SetText(factionName)
                wantedTabardID = tabardID
                break
            end
        end

        textArea:SetText("Tabard Suggestion:")
        frame:Show()
    else
        frame:Hide()
    end
end

frame:SetScript("OnEvent", showOrHideUI)

local function equipTabard(self, mouseButton)
    if (mouseButton == "LeftButton") then
        EquipItemByName(wantedTabardID)
        frame:Hide()
    end
end

equipButton:SetScript("OnClick", equipTabard)
