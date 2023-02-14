--[[

    MicroItemLevel by murrm
    for Classic/TBC/WOTLK

    Minimalist Item Level & GearScore addon for Character Frame
    Based on TacoTip by kebabstorm & original GearScoreLite by Mirrikat45 & others

--]]

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

local CI = LibStub("LibClassicInspector")
local GearScore = TT_GS
local L = MICROITEMLEVEL_LOCALE
local TT = _G[addOnName]

local playerClass = select(2, UnitClass("player"))

function TT:InitCharacterFrame()
    CharacterModelFrame:CreateFontString("PersonalGearScore")
    PersonalGearScore:SetFont(L["CHARACTER_FRAME_GS_VALUE_FONT"], L["CHARACTER_FRAME_GS_VALUE_FONT_SIZE"])
    PersonalGearScore:SetText("0")
    PersonalGearScore.RefreshPosition = function()
        PersonalGearScore:SetPoint("BOTTOMLEFT",PaperDollFrame,"BOTTOMLEFT",L["CHARACTER_FRAME_GS_VALUE_XPOS"] + (MicroItemLevelConfig.character_gs_offset_x or 0),L["CHARACTER_FRAME_GS_VALUE_YPOS"] + (MicroItemLevelConfig.character_gs_offset_y or 0))
    end
    PersonalGearScore:RefreshPosition()

    CharacterModelFrame:CreateFontString("PersonalGearScoreText")
    PersonalGearScoreText:SetFont(L["CHARACTER_FRAME_GS_TITLE_FONT"], L["CHARACTER_FRAME_GS_TITLE_FONT_SIZE"])
    PersonalGearScoreText:SetText("GearScore")
    PersonalGearScoreText.RefreshPosition = function()
        PersonalGearScoreText:SetPoint("BOTTOMLEFT",PaperDollFrame,"BOTTOMLEFT",L["CHARACTER_FRAME_GS_TITLE_XPOS"] + (MicroItemLevelConfig.character_gs_offset_x or 0),L["CHARACTER_FRAME_GS_TITLE_YPOS"] + (MicroItemLevelConfig.character_gs_offset_y or 0))
    end
    PersonalGearScoreText:RefreshPosition()

    CharacterModelFrame:CreateFontString("PersonalAvgItemLvl")
    PersonalAvgItemLvl:SetFont(L["CHARACTER_FRAME_ILVL_VALUE_FONT"], L["CHARACTER_FRAME_ILVL_VALUE_FONT_SIZE"])
    PersonalAvgItemLvl:SetText("0")
    PersonalAvgItemLvl.RefreshPosition = function()
        PersonalAvgItemLvl:SetPoint("BOTTOMLEFT",PaperDollFrame,"BOTTOMLEFT",L["CHARACTER_FRAME_ILVL_VALUE_XPOS"] + (MicroItemLevelConfig.character_ilvl_offset_x or 0),L["CHARACTER_FRAME_ILVL_VALUE_YPOS"] + (MicroItemLevelConfig.character_ilvl_offset_y or 0))
    end
    PersonalAvgItemLvl:RefreshPosition()

    CharacterModelFrame:CreateFontString("PersonalAvgItemLvlText")
    PersonalAvgItemLvlText:SetFont(L["CHARACTER_FRAME_ILVL_TITLE_FONT"], L["CHARACTER_FRAME_ILVL_TITLE_FONT_SIZE"])
    PersonalAvgItemLvlText:SetText("iLvl")
    PersonalAvgItemLvlText.RefreshPosition = function()
        PersonalAvgItemLvlText:SetPoint("BOTTOMLEFT",PaperDollFrame,"BOTTOMLEFT",L["CHARACTER_FRAME_ILVL_TITLE_XPOS"] + (MicroItemLevelConfig.character_ilvl_offset_x or 0),L["CHARACTER_FRAME_ILVL_TITLE_YPOS"] + (MicroItemLevelConfig.character_ilvl_offset_y or 0))
    end
    PersonalAvgItemLvlText:RefreshPosition()

    PaperDollFrame:HookScript("OnShow", TT.RefreshCharacterFrame)
end

function TT:RefreshCharacterFrame()
    if (TT.InitCharacterFrame) then
        TT:InitCharacterFrame()
        TT.InitCharacterFrame = nil
    end
    local MyGearScore, MyAverageScore, r, g, b = 0,0,0,0,0
    if (MicroItemLevelConfig.show_gs_character or MicroItemLevelConfig.show_avg_ilvl) then
        MyGearScore, MyAverageScore = GearScore:GetScore("player")
        r, g, b = GearScore:GetQuality(MyGearScore)
    end
    if (MicroItemLevelConfig.show_gs_character) then
        PersonalGearScore:SetText(MyGearScore);
        PersonalGearScore:SetTextColor(r, g, b, 1)
        PersonalGearScore:Show()
        PersonalGearScoreText:Show()
        if (MicroItemLevelConfig.unlock_info_position) then
            if (not PersonalGearScoreText.mover) then
                PersonalGearScoreText.mover = CreateMover(PaperDollFrame, PersonalGearScore, PersonalGearScoreText, function(ofx, ofy)
                    MicroItemLevelConfig.character_gs_offset_x = ofx-L["CHARACTER_FRAME_GS_TITLE_XPOS"]
                    MicroItemLevelConfig.character_gs_offset_y = ofy-L["CHARACTER_FRAME_GS_TITLE_YPOS"]
                    PersonalGearScore:RefreshPosition()
                    PersonalGearScoreText:RefreshPosition()
                end)
            end
            PersonalGearScoreText.mover:Show()
        elseif (PersonalGearScoreText.mover) then 
            PersonalGearScoreText.mover:Hide()
        end
    else
        PersonalGearScore:Hide()
        PersonalGearScoreText:Hide()
        if (PersonalGearScoreText.mover) then
            PersonalGearScoreText.mover:Hide()
        end
    end
    if (MicroItemLevelConfig.show_avg_ilvl) then
        PersonalAvgItemLvl:SetText(MyAverageScore);
        PersonalAvgItemLvl:SetTextColor(r, g, b, 1)
        PersonalAvgItemLvl:Show()
        PersonalAvgItemLvlText:Show()
        if (MicroItemLevelConfig.unlock_info_position) then
            if (not PersonalAvgItemLvlText.mover) then
                PersonalAvgItemLvlText.mover = CreateMover(PaperDollFrame, PersonalAvgItemLvl, PersonalAvgItemLvlText, function(ofx, ofy)
                    MicroItemLevelConfig.character_ilvl_offset_x = ofx-L["CHARACTER_FRAME_ILVL_TITLE_XPOS"]
                    MicroItemLevelConfig.character_ilvl_offset_y = ofy-L["CHARACTER_FRAME_ILVL_TITLE_YPOS"]
                    PersonalAvgItemLvl:RefreshPosition()
                    PersonalAvgItemLvlText:RefreshPosition()
                end)
            end
            PersonalAvgItemLvlText.mover:Show()
        elseif (PersonalAvgItemLvlText.mover) then
            PersonalAvgItemLvlText.mover:Hide()
        end
    else
        PersonalAvgItemLvl:Hide()
        PersonalAvgItemLvlText:Hide()
        if (PersonalAvgItemLvlText.mover) then
            PersonalAvgItemLvlText.mover:Hide()
        end
    end
end

local function onEvent(self, event, ...)
    if (event == "PLAYER_EQUIPMENT_CHANGED") then
        if (PaperDollFrame and PaperDollFrame:IsShown()) then
            TT:RefreshCharacterFrame()
        end
    elseif (event == "MODIFIER_STATE_CHANGED") then
        local _, unit = GameTooltip:GetUnit()
        if (unit and UnitIsPlayer(unit)) then
            GameTooltip:SetUnit(unit)
        end
    elseif (event == "UNIT_TARGET") then
        local unit = ...
        if (unit) then
            local _, ttUnit = GameTooltip:GetUnit()
            if (ttUnit and UnitIsUnit(unit, ttUnit)) then
                GameTooltip:SetUnit(unit)
            end
        end
    elseif (event == "ADDON_LOADED") then
        local addon = ...
        if (addon == addOnName) then
            self:UnregisterEvent("ADDON_LOADED")
            if (CharacterModelFrame and PaperDollFrame) then
                TT:RefreshCharacterFrame()
            end
            local first_login = (MicroItemLevelConfig.conf_version ~= addOnVersion)
            if (first_login) then
                for k,v in pairs(TT:GetDefaults()) do
                    if (MicroItemLevelConfig[k] == nil) then
                        MicroItemLevelConfig[k] = v
                    end
                end
                MicroItemLevelConfig.conf_version = addOnVersion
            end
        end
    end
end

do
    local f = CreateFrame("Frame")
    f:SetScript("OnEvent", onEvent)
    f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
    f:RegisterEvent("ADDON_LOADED")
    CI.RegisterCallback(addOnName, "INVENTORY_READY", function(...) onEvent(f, ...) end)
    CI.RegisterCallback(addOnName, "TALENTS_READY", function(...) onEvent(f, ...) end)
    TT.frame = f
end