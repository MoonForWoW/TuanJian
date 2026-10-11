local AddonName, ns = ...

local L = ns.L

function TJ.InitThanksPage()
    local frame = CreateFrame("Frame", nil, TJ.MainFrame)
    frame:Hide()
    frame:SetScript("OnShow", function()
        TJ.exportTJButton_UpdateShow()
    end)
    TJ.thanksMainFrame = frame

    local title = frame:CreateFontString()
    title:SetPoint("TOPLEFT", TJ.MainFrame, 20, -40)
    title:SetFont(BIAOGE_TEXT_FONT, 16, "OUTLINE")
    title:SetTextColor(1, .82, 0)
    title:SetText(L["感谢以下玩家支持："])

    local supporters = {
        "寒风",
        "突然掉线",
        "爱发电用户_eaef8",
        "心恋宝贝",
        "lumos",
        "爱发电用户_8b768",
        "爱发电用户_d18bc",
    }
    for i, name in ipairs(supporters) do
        local text = frame:CreateFontString()
        text:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -15 - (i - 1) * 20)
        text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        text:SetTextColor(1, 1, 1)
        text:SetText(name)
    end

    local footer = frame:CreateFontString()
    footer:SetPoint("BOTTOMLEFT", TJ.MainFrame, "BOTTOMLEFT", 50, 40)
    footer:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
    footer:SetTextColor(1, .82, 0)
    footer:SetText("|T" .. ns.Interface .. "Media\\icon\\AFD.tga:18:18|t 爱发电支持作者：")

    local url = "https://afdian.com/a/wow_biaoge"
    local edit = CreateFrame("EditBox", nil, frame, TJ.editTemplate)
    edit:SetSize(280, 22)
    edit:SetPoint("LEFT", footer, "RIGHT", 8, 0)
    edit:SetAutoFocus(false)
    edit:SetText(url)
    edit:SetScript("OnTextChanged", function(self)
        if self:GetText() ~= url then
            self:SetText(url)
        end
    end)
    edit:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEditFocusGained", function(self)
        TJ.lastfocus = self
    end)
    edit:HookScript("OnEditFocusLost", function(self)
        if TJ.lastfocus == self then
            TJ.lastfocus = nil
        end
    end)
    frame:SetScript("OnHide", function()
        edit:ClearFocus()
    end)
end
