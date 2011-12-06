local _, ns = ...

-- Assign global functions to locals for optimisation.
local GetInventoryItemID = GetInventoryItemID
local GetInstanceInfo = GetInstanceInfo
local GetFactionInfoByID = GetFactionInfoByID
local EquipItemByName = EquipItemByName

local factions = ns.factions

-- UI Elements from XML
local frame = Tabarddon_Frame
local textArea = Tabarddon_Frame_Messages
local equipButton = Tabarddon_Frame_Suggested_Tabard

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
