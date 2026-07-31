local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local Size = ns.Size
local RGB = ns.RGB
local AddTexture = ns.AddTexture
local SendSystemMessage = ns.SendSystemMessage

local pt = print
local After = C_Timer.After
local BG = TJ
local Round = ns.Round

local realmID = GetRealmID()
local player = UnitName("player")
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

local logo = "TuanJian: "

-- 站位图导出/导入
function TJ.ExportMapUI()
    local optionFrame = TJ.optionMainFrame.optionFrame

    local function CreateScroll(bt)
        local frame, scroll, child
        local bg = CreateFrame("Frame", nil, TJ.optionMainFrame, "BackdropTemplate")
        do
            bg:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            bg:SetBackdropColor(0, 0, 0, 0.8)
            bg:SetBackdropBorderColor(1, 1, 1, .6)
            bg:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT", 0, 0)
            bg:SetSize(250, 250)
            bg:SetFrameLevel(130)
            bg:EnableMouse(true)
            bg:Hide()
            bt.bg = bg
            local t = bg:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("TOP", 0, -8)
            t:SetTextColor(1, 1, 1)
            t:SetText(bt:GetText())
        end

        frame = CreateFrame("Frame", nil, bg, "BackdropTemplate")
        do
            frame:SetBackdrop({
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            frame:SetBackdropBorderColor(1, 1, 1, 0.5)
            frame:SetPoint("TOPLEFT", 8, -28)
            frame:SetSize(bg:GetWidth() - 16, bg:GetHeight() - 70)
            scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", 5, -4)
            scroll:SetPoint("BOTTOMRIGHT", -27, 4)
            bt.scroll = scroll
            TJ.CreateSrollBarBackdrop(scroll.ScrollBar)
            TJ.HookScrollBarShowOrHide(scroll)
            child = CreateFrame("EditBox", nil, scroll)
            child:SetWidth(scroll:GetWidth())
            child:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            child:SetMultiLine(true)
            child:SetAutoFocus(false)
            child:EnableMouse(true)
            bt.child = child
            scroll:SetScrollChild(child)
            child:SetScript("OnEscapePressed", function(self)
                bg:Hide()
            end)
            child:SetScript("OnTextChanged", function(self)
                if bt.sureButton then
                    if self:GetText() == "" then
                        bt.sureButton:Disable()
                    else
                        bt.sureButton:Enable()
                    end
                end
            end)
            scroll:SetScript("OnMouseDown", function(self)
                child:SetFocus()
            end)
        end

        local bt = TJ.CreateButton(bg)
        do
            bt:SetSize(110, 25)
            bt:SetPoint("BOTTOMRIGHT", -8, 10)
            bt:SetText(CANCEL)
            bt:SetScript("OnClick", function(self)
                bg:Hide()
            end)
        end
    end

    local bt = CreateFrame("Button", nil, optionFrame)
    bt:SetPoint("TOPRIGHT", optionFrame, "TOPRIGHT", -10, 0)
    bt:SetNormalFontObject(TJ.FontGreen15)
    bt:SetDisabledFontObject(TJ.FontDis15)
    bt:SetHighlightFontObject(TJ.FontWhite15)
    bt:SetText(L["导入站位"])
    bt:SetSize(bt:GetFontString():GetWidth(), 30)
    TJ.SetTextHighlightTexture(bt)
    TJ.optionMainFrame.importButton = bt
    CreateScroll(bt)
    bt:SetScript("OnClick", function(self)
        TJ.PlaySound(1)
        if self.bg:IsVisible() then
            self.bg:Hide()
        else
            TJ.optionMainFrame.importButton.bg:Show()
            TJ.optionMainFrame.exportButton.bg:Hide()
            self.child:SetText("")
            self.child:SetFocus()
        end
    end)
    local sure = TJ.CreateButton(bt.bg)
    sure:SetSize(110, 25)
    sure:SetPoint("BOTTOMLEFT", 8, 10)
    sure:SetText(OKAY)
    bt.sureButton = sure
    sure:SetScript("OnClick", function(self)
        local text = bt.child:GetText()
        if ns.IsBase64(text) then
            text = ns.Decode(text)
        else
            ns.SendSystemMessage(format(TJ.STC_r1(L["代码错误！识别失败！"])))
            TJ.PlaySound(1)
            return
        end

        for _, FBtext in ipairs({ strsplit("^", text) }) do
            local FB, bady = strsplit("!", FBtext)
            if FB and bady then
                for _, mapText in ipairs({ strsplit("#", bady) }) do
                    local arg1, arg2 = strsplit("$", mapText)
                    if arg1 and arg2 then
                        local bossIndex, mapName = strsplit(":", arg1)
                        bossIndex = tonumber(bossIndex)
                        for _, pointText in ipairs({ strsplit(",", arg2) }) do
                            local index, x, y = strsplit(":", pointText)
                            index = tonumber(index)
                            x = tonumber(x) or 0
                            y = tonumber(y) or 0
                            if TuanJian[FB] and
                                TuanJian[FB][bossIndex] and
                                TuanJian[FB][bossIndex][mapName] and
                                TuanJian[FB][bossIndex][mapName][index] then
                                TuanJian[FB][bossIndex][mapName][index].point = { x = x, y = y }
                            end
                        end
                    end
                end
            end
        end
        for i, v in ipairs(TJ.FBtbl) do
            local FB = v.FB
            if TJ.frame[FB] then
                for bossIndex in ipairs(TJ.FBinfo[FB]) do
                    if TJ.frame[FB][bossIndex] and TJ.frame[FB][bossIndex].map then
                        TJ.PairAllMap(function(map)
                            map.needUpdateIconPoint = true
                        end, FB, bossIndex)
                    end
                end
            end
        end

        ns.SendSystemMessage(format(TJ.STC_g1(L["站位导入成功！"])))
        bt.bg:Hide()
        TJ.PlaySound(2)
    end)

    local bt = CreateFrame("Button", nil, optionFrame)
    bt:SetPoint("RIGHT", TJ.optionMainFrame.importButton, "LEFT", -7, 0)
    bt:SetNormalFontObject(TJ.FontGreen15)
    bt:SetDisabledFontObject(TJ.FontDis15)
    bt:SetHighlightFontObject(TJ.FontWhite15)
    bt:SetText(L["导出站位"])
    bt:SetSize(bt:GetFontString():GetWidth(), 30)
    TJ.SetTextHighlightTexture(bt)
    TJ.optionMainFrame.exportButton = bt
    CreateScroll(bt)
    bt:SetScript("OnClick", function(self)
        TJ.PlaySound(1)
        if self.bg:IsVisible() then
            self.bg:Hide()
        else
            TJ.optionMainFrame.importButton.bg:Hide()
            TJ.optionMainFrame.exportButton.bg:Show()

            -- TuanJian[FB][bossIndex][mapName][index].point = { x = ix, y = iy }
            -- "ICC!1:map$1:x:y,2:x:y#1:map2$1:x:y,2:x:y#2:map$1:x:y,2:x:y,^TOC"
            local text = ""
            for i, v in ipairs(TJ.FBtbl) do
                local FB = v.FB
                text = text .. FB .. "!"
                for bossIndex in ipairs(TJ.FBinfo[FB]) do
                    if not TJ.tabFrame[FB] then
                        TJ.UpdateBossChooseFrame(FB)
                    end
                    TJ.LoadBoss(FB, bossIndex, true)
                    if TJ.frame[FB][bossIndex].map then
                        TJ.PairAllMap(function(map)
                            local mapName = map.name
                            local tbl = map.defaluePoint
                            text = text .. bossIndex .. ":" .. mapName .. "$"
                            for index, v in pairs(tbl) do
                                local x, y
                                if TuanJian[FB][bossIndex][mapName][index] and TuanJian[FB][bossIndex][mapName][index].point then
                                    x = TuanJian[FB][bossIndex][mapName][index].point.x
                                    y = TuanJian[FB][bossIndex][mapName][index].point.y
                                else
                                    x = v.xy[1]
                                    y = v.xy[2]
                                end
                                text = text .. index .. ":" .. x .. ":" .. y .. ","
                            end
                            text = text .. "#"
                        end, FB, bossIndex)
                    end
                end
                text = text .. "^"
            end
            self.child:SetText(ns.Encode(text))
            self.child:SetFocus()
            self.child:HighlightText()
            self.child:SetCursorPosition(0)
        end
    end)
end
