
local addOnName = ...
local addOnVersion = GetAddOnMetadata(addOnName, "Version") or "0.0.1"

local clientVersionString = GetBuildInfo()
local clientBuildMajor = string.byte(clientVersionString, 1)
-- load only on classic/tbc/wotlk
if (clientBuildMajor < 49 or clientBuildMajor > 51 or string.byte(clientVersionString, 2) ~= 46) then
    return
end

assert(LibStub, "MicroItemLevel requires LibStub")
assert(LibStub:GetLibrary("LibClassicInspector", true), "MicroItemLevel requires LibClassicInspector")

_G[addOnName] = {}

local CI = LibStub("LibClassicInspector")

local GearScore = TT_GS
local L = MicroItemLevel_LOCALE
local TT = _G[addOnName]

function TT:GetDefaults()
    return {
        show_gs_character = true,
        show_avg_ilvl = true,
        character_gs_offset_x = 0,
        character_gs_offset_y = 0,
        character_ilvl_offset_x = 0,
        character_ilvl_offset_y = 0,
    }
end

local function resetCfg()
    MicroItemLevelConfig = TT:GetDefaults()
    if (PersonalGearScore) then
        PersonalGearScore:RefreshPosition()
    end
    if (PersonalGearScoreText) then
        PersonalGearScoreText:RefreshPosition()
    end
    if (PersonalAvgItemLvl) then
        PersonalAvgItemLvl:RefreshPosition()
    end
    if (PersonalAvgItemLvlText) then
        PersonalAvgItemLvlText:RefreshPosition()
    end
    if (TT.RefreshCharacterFrame and PaperDollFrame and PaperDollFrame:IsShown()) then
        TT:RefreshCharacterFrame()
    end
    if (TT.RefreshInspectFrame and InspectFrame and InspectFrame:IsShown()) then
        TT:RefreshInspectFrame()
    end
    --SetCVar("showItemLevel", "1")
end

if not MicroItemLevelConfig then
    resetCfg()
end

-- main frame
local frame = CreateFrame("Frame","MicroItemLevelOptions")
frame.name = addOnName
InterfaceOptions_AddCategory(frame)
frame:Hide()

frame:SetScript("OnShow", function(frame)
    local options = {}
    local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    title:SetPoint("TOPLEFT", 16, -16)
    title:SetText(addOnName .. " v" .. addOnVersion)

    local description = frame:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    description:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
    description:SetText(L["TEXT_OPT_DESC"])

    local function newCheckbox(name, label, description, onClick)
        local check = CreateFrame("CheckButton", "MicroItemLevelOptCheckBox" .. name, frame, "InterfaceOptionsCheckButtonTemplate")
        check:SetScript("OnClick", function(self)
            local tick = self:GetChecked()
            onClick(self, tick and true or false)
        end)
        check.SetDisabled = function(self, disable)
            if disable then
                self:Disable()
                _G[self:GetName() .. 'Text']:SetFontObject('GameFontDisable')
            else
                self:Enable()
                _G[self:GetName() .. 'Text']:SetFontObject('GameFontHighlight')
            end
        end
        check.label = _G[check:GetName() .. "Text"]
        check.label:SetText(label)
        if (description) then
            check.tooltipText = label
            check.tooltipRequirement = description
        end
        return check
    end

    local function newDropDown(name, values, callback)
        local dropDown = CreateFrame("Frame", "MicroItemLevelOptDropDown" .. name, frame, "UIDropDownMenuTemplate")
        UIDropDownMenu_Initialize(dropDown, function(frame, level, menuList)
            local info = UIDropDownMenu_CreateInfo()
            info.func = function(self)
                    UIDropDownMenu_SetSelectedValue(frame, self.value)
                    callback(self.value)
            end
            for i,selection in ipairs(values) do
                local text, desc = unpack(selection)
                info.text, info.checked, info.value = text, false, i
                if(desc) then
                    info.tooltipTitle = text
                    info.tooltipText = desc
                    info.tooltipOnButton = 1
                end
                UIDropDownMenu_AddButton(info)
            end
        end)
        dropDown.SetValue = function(self, value)
            self.selectedValue = value
            UIDropDownMenu_SetText(self, values[value][1])
        end
        return dropDown
    end

    local function newRadioButton(name, label, description, onClick)
        local check = CreateFrame("CheckButton", "TacoTipOptRadioButton" .. name, frame, "InterfaceOptionsCheckButtonTemplate, UIRadioButtonTemplate")
        check:SetScript("OnClick", function(self)
            if(not self:GetChecked()) then
                self:SetChecked(true)
            end
            onClick(self, true)
        end)
        check.SetDisabled = function(self, disable)
            if disable then
                self:Disable()
                _G[self:GetName() .. 'Text']:SetFontObject('GameFontDisable')
            else
                self:Enable()
                _G[self:GetName() .. 'Text']:SetFontObject('GameFontHighlight')
            end
        end
        check.label = _G[check:GetName() .. "Text"]
        check.label:SetText(label)
        if (description) then
            check.tooltipText = label
            check.tooltipRequirement = description
        end
        return check
    end

    local characterFrameText = frame:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    characterFrameText:SetPoint("TOPLEFT", description, "BOTTOMLEFT", 0, -216)
    characterFrameText:SetText(L["Character Frame"])

    options.gearScoreCharacter = newCheckbox(
        "GearScoreCharacter",
        "GearScore",
        L["Show GearScore in character frame"],
        function(self, value) 
            MicroItemLevelConfig.show_gs_character = value
            if (PaperDollFrame and PaperDollFrame:IsShown()) then
                TT:RefreshCharacterFrame()
            end
            if (InspectFrame and InspectFrame:IsShown()) then
                TT:RefreshInspectFrame()
            end
        end)
    options.gearScoreCharacter:SetPoint("TOPLEFT", characterFrameText, "BOTTOMLEFT", -2, -4)

    options.averageItemLevel = newCheckbox(
        "AverageItemLevel",
        L["Average iLvl"],
        L["Show Average Item Level in character frame"],
        function(self, value) 
            MicroItemLevelConfig.show_avg_ilvl = value
            if (PaperDollFrame and PaperDollFrame:IsShown()) then
                TT:RefreshCharacterFrame()
            end
            if (InspectFrame and InspectFrame:IsShown()) then
                TT:RefreshInspectFrame()
            end
        end)
    options.averageItemLevel:SetPoint("TOPLEFT", characterFrameText, "BOTTOMLEFT", 140, -4)

    local function getConfig()
        options.gearScoreCharacter:SetChecked(MicroItemLevelConfig.show_gs_character)
        options.averageItemLevel:SetChecked(MicroItemLevelConfig.show_avg_ilvl)
    end

    frame.Refresh = function()
        getConfig()
    end

    local resetcfg = CreateFrame("Button", "MicroItemLevelOptButtonResetCfg", frame, "UIPanelButtonTemplate")
    resetcfg:SetText(L["Reset configuration"])
    resetcfg:SetWidth(177)
    resetcfg:SetHeight(24)
    resetcfg:SetPoint("TOPLEFT", extraText, "BOTTOMLEFT", 0, -152)
    resetcfg:SetScript("OnClick", function()
        resetCfg()
        frame:Refresh()
    end)

    getConfig()
    options.exampleTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
    showExampleTooltip()

    frame:SetScript("OnShow", function()
        getConfig()
        options.exampleTooltip:RegisterEvent("MODIFIER_STATE_CHANGED")
        showExampleTooltip()
    end)
    frame:SetScript("OnHide", function()
        options.exampleTooltip:UnregisterEvent("MODIFIER_STATE_CHANGED")
    end)
end)

SLASH_MILTIP1 = "/MicroItemLevel";
SLASH_MILTIP2 = "/mil";
SLASH_MILTIP3 = "/gs";
SLASH_MILTIP4 = "/gearscore";
SlashCmdList["MicroItemLevel"] = function(msg)
    local cmd = strlower(msg)
    if (cmd == "reset") then
        resetCfg()
        if (frame:IsShown()) then
            frame:Refresh()
        end
        print("|cff59f0dcMicroItemLevel:|r "..L["Configuration has been reset to default."])
    else
        InterfaceOptionsFrame_OpenToCategory(addOnName)
        InterfaceOptionsFrame_OpenToCategory(addOnName)
    end
end
