local AddonName, ns = ...
local LibBG = ns.LibBG
local L = ns.L

local ldb = LibStub:GetLibrary("LibDataBroker-1.1", true)
if not ldb then return end

local pt = print

local plugin = ldb:NewDataObject(AddonName, { text = AddonName, type = "data source", icon = "Interface\\AddOns\\TuanJian\\Media\\icon\\icon.tga" })

function plugin:OnClick(button) --function plugin.OnClick(self, button)
    if button == "LeftButton" then
        TJ.MainFrame:SetShown(not TJ.MainFrame:IsVisible())
    elseif button == "RightButton" then
        -- if SettingsPanel:IsVisible() then
        --     HideUIPanel(SettingsPanel)
        -- else
        --     ns.InterfaceOptionsFrame_OpenToCategory("|cff00BFFFBiaoGe|r")
        --     TJ.MainFrame:Hide()
        -- end
    end
    TJ.PlaySound(1)
end

function plugin:OnEnter(button)
    GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
    GameTooltip:ClearLines()
    GameTooltip:AddLine("<" .. AddonName .. ">" .. L["团减助手"], 0, .75, 1, true)
    GameTooltip:Show()
end

function plugin:OnLeave(button)
    GameTooltip:Hide()
end

TJ.Init3(function()
    local icon = LibStub("LibDBIcon-1.0", true)
    if not icon then return end
    icon:Register(AddonName, plugin, TuanJian)
end)