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

local realmID = GetRealmID()
local player = UnitName("player")
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

local logo = "TuanJian: "

TJ.Init(function()
    if not TJ.IsMOP then return end
    
    local mainFrame = TJ.tjMainFrame
    local FB = "TJ"
    local bossIndex = 1
    local parent = TJ.frame[FB][bossIndex]

    -- 导出至MRT
    do
        local bt = CreateFrame("Button", nil, TJ.MainFrame)
        bt:SetNormalFontObject(TJ.FontGreen15)
        bt:SetDisabledFontObject(TJ.FontDis15)
        bt:SetHighlightFontObject(TJ.FontWhite15)
        bt:SetFrameLevel(10)
        bt:SetText(L["导出至MRT"])
        bt:SetSize(bt:GetFontString():GetWidth(), 20)
        bt:Hide()
        TJ.SetTextHighlightTexture(bt)
        TJ.exportTJButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            TJ.exportTJFrame:SetShown(not TJ.exportTJFrame:IsVisible())
        end)

        local frame = TJ.CreateMainFrame(nil, L["导出(MRT战术板格式)"])
        frame:ClearAllPoints()
        frame:SetParent(TJ.exportTJButton)
        frame.width = 200
        frame:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT")
        frame:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", frame.width, 0)
        frame:SetShown(TuanJian.MOPTJ.showMRT == 1)
        frame:SetScript("OnMouseUp", function(self)
            TJ.MainFrame:GetScript("OnMouseUp")(TJ.MainFrame)
        end)
        frame:SetScript("OnMouseDown", function(self)
            TJ.MainFrame:GetScript("OnMouseDown")(TJ.MainFrame)
        end)
        frame:SetScript("OnShow", function(self)
            TuanJian.MOPTJ.showMRT = self:IsShown() and 1 or 0
            TJ.exportTJFrame:UpdateText()
        end)
        frame:SetScript("OnHide", function(self)
            TuanJian.MOPTJ.showMRT = self:IsShown() and 1 or 0
        end)
        TJ.exportTJFrame = frame

        local function FormatText(text)
            return text:gsub("|", "||")
        end
        function TJ.exportTJFrame:UpdateText()
            if self:IsVisible() then
                self.t = 0
                self:SetScript("OnUpdate", function(self, t)
                    self.t = self.t + t
                    if self.t >= 0.05 then
                        self:SetScript("OnUpdate", nil)
                        local text = ""
                        local parent = self.parent
                        if self.frameType == "TJ" then
                            for i, v in ipairs(parent.all) do
                                local players = {}
                                local playerCount = 0
                                for _, vv in ipairs(v.edits) do
                                    local player = vv.playerEdit:GetText()
                                    local spell = vv.spellEdit:GetText()
                                    if player ~= "" and spell ~= "" then
                                        local spellStr = ""
                                        local icon = spell:match("|T(.-):.-|t")
                                        if icon then
                                            spellStr = format("{icon:%s}", icon)
                                        end
                                        local playerStr = FormatText(TJ.ClearCode(ns.RGB_16(vv.playerEdit), true))
                                        playerCount = playerCount + 1
                                        players[playerStr] = players[playerStr] or {
                                            count = playerCount,
                                            playerStr = playerStr,
                                            spellStr = {},
                                        }
                                        tinsert(players[playerStr].spellStr, spellStr)
                                    end
                                end
                                if next(players) then
                                    local newTbl = {}
                                    for k, v in pairs(players) do
                                        tinsert(newTbl, v)
                                    end
                                    sort(newTbl, function(a, b)
                                        return a.count < b.count
                                    end)

                                    local t = v.titleName
                                    for i, v in ipairs(newTbl) do
                                        local spellStr = ""
                                        for _, _spellStr in ipairs(v.spellStr) do
                                            spellStr = spellStr .. _spellStr
                                        end
                                        t = t .. (i == 1 and "" or " ") .. v.playerStr .. spellStr
                                    end
                                    text = text .. t .. "\n"
                                end
                            end
                        elseif self.frameType == "DPS" then
                            for i = 1, #parent.all[1].edits do
                                local smEdit = parent.all[1].edits[i].edit
                                local sm = smEdit:GetText()
                                local zsEdit = parent.all[2].edits[i].edit
                                local zs = zsEdit:GetText()
                                if sm ~= "" or zs ~= "" then
                                    local t = i .. L["增伤："]
                                    for ii, edit in ipairs({ smEdit, zsEdit }) do
                                        if edit:GetText() ~= "" then
                                            t = t .. (ii == 1 and "" or " ") .. FormatText(TJ.ClearCode(ns.RGB_16(edit), true))
                                        end
                                    end
                                    text = text .. t .. "\n"
                                end
                            end
                        elseif self.frameType == "board" then
                            for id, child in ipairs(parent.child) do
                                local _text = ""
                                local boardTypeName = TJ.ClearCode(parent.tabButton[id]:GetText())
                                for i, v in ipairs(child.all) do
                                    local players = {}
                                    local playerCount = 0
                                    for _, vv in ipairs(v.edits) do
                                        local player = vv.playerEdit:GetText()
                                        local spell = vv.spellEdit:GetText()
                                        if player ~= "" and spell ~= "" then
                                            local spellStr = ""
                                            local icon = spell:match("|T(.-):.-|t")
                                            if icon then
                                                spellStr = format("{icon:%s}", icon)
                                            end
                                            local playerStr = FormatText(TJ.ClearCode(ns.RGB_16(vv.playerEdit), true))
                                            playerCount = playerCount + 1
                                            players[playerStr] = players[playerStr] or {
                                                count = playerCount,
                                                playerStr = playerStr,
                                                spellStr = {},
                                            }
                                            tinsert(players[playerStr].spellStr, spellStr)
                                        end
                                    end
                                    if next(players) then
                                        local newTbl = {}
                                        for k, v in pairs(players) do
                                            tinsert(newTbl, v)
                                        end
                                        sort(newTbl, function(a, b)
                                            return a.count < b.count
                                        end)

                                        local t = v.titleName
                                        for i, v in ipairs(newTbl) do
                                            local spellStr = ""
                                            for _, _spellStr in ipairs(v.spellStr) do
                                                spellStr = spellStr .. _spellStr
                                            end
                                            t = t .. (i == 1 and "" or " ") .. v.playerStr .. spellStr
                                        end
                                        _text = _text .. t .. "\n"
                                    end
                                end
                                if _text ~= "" then
                                    text = text .. (text == "" and "" or "\n") .. boardTypeName .. "\n" .. _text
                                end
                            end
                        end
                        self.edit:SetText(text)
                        if self.edit:HasFocus() then
                            self.edit:HighlightText()
                        end
                    end
                end)
            end
        end

        do
            local f = CreateFrame("Frame", nil, frame, "BackdropTemplate")
            f:SetBackdropColor(0, 0, 0, 0)
            f:SetBackdropBorderColor(0, 0, 0, 0)
            f:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -20)
            f:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -0, 30)
            f:EnableMouse(true)
            local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -5)
            scroll:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT", -25, 5)
            scroll.ScrollBar.scrollStep = TJ.scrollStep
            f.scroll = scroll
            TJ.CreateSrollBarBackdrop(scroll.ScrollBar)
            TJ.HookScrollBarShowOrHide(scroll)
            local edit
            edit = CreateFrame("EditBox", nil, scroll)
            edit:SetWidth(scroll:GetWidth())
            edit:SetAutoFocus(false)
            edit:EnableMouse(true)
            edit:SetMultiLine(true)
            edit:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
            TJ.exportTJFrame.edit = edit
            scroll:SetScrollChild(edit)
            edit:SetScript("OnTextChanged", function(self)
                if self:GetText() == "" then
                    self:ClearFocus()
                end
            end)
            edit:SetScript("OnEscapePressed", function(self)
                self:ClearFocus()
            end)
            edit:HookScript("OnEditFocusGained", function(self)
                TJ.lastfocus = self
                self:HighlightText()
            end)
            edit:HookScript("OnEditFocusLost", function(self)
                self:ClearHighlightText()
            end)
            edit:HookScript("OnMouseDown", function(self, button)
                if button == "RightButton" then
                    self:SetEnabled(false)
                    self:SetText("")
                end
            end)
            edit:HookScript("OnMouseUp", function(self, enter)
                if enter == "RightButton" then
                    self:SetEnabled(true)
                end
            end)
            scroll:SetScript("OnMouseDown", function(self)
                edit:SetFocus()
            end)
        end

        local bt = TJ.CreateButton(frame)
        bt:SetSize(frame:GetWidth() - 4, 25)
        bt:SetPoint("BOTTOM", 0, 2)
        bt:SetText(L["打开MRT战术板"])
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            local MRT = GMRT
            if MRT then
                MRT.Options:Open(MRT.ModulesOptions[1])
            else
                ns.SendSystemMessage(L["你没有安装MRT插件。"])
            end
        end)


        function TJ.CreateMRT(parent, points, buttonName, points2, points3,
                                dbName)
            local bt = CreateFrame("Button", nil, parent)
            bt:SetPoint(unpack(points))
            bt:SetNormalFontObject(TJ.FontGreen15)
            bt:SetDisabledFontObject(TJ.FontDis15)
            bt:SetHighlightFontObject(TJ.FontWhite15)
            bt:SetText(L["导出至MRT"])
            bt:SetSize(bt:GetFontString():GetWidth(), 20)
            bt:Hide()
            TJ.SetTextHighlightTexture(bt)
            TJ[buttonName] = bt
            bt:SetScript("OnClick", function(self)
                TJ.PlaySound(1)
                TJ.exportTJFrame:SetShown(not TJ.exportTJFrame:IsVisible())
            end)

            local frame = TJ.CreateMainFrame(nil, L["导出（MRT战术板格式）"])
            frame:ClearAllPoints()
            frame:SetParent(TJ[buttonName])
            frame:SetPoint(unpack(points2))
            frame:SetPoint(unpack(points3))
            frame:SetShown(TuanJian.MOPTJ[dbName] == 1)
            frame:SetScript("OnMouseUp", function(self)
                TJ.MainFrame:GetScript("OnMouseUp")(TJ.MainFrame)
            end)
            frame:SetScript("OnMouseDown", function(self)
                TJ.MainFrame:GetScript("OnMouseDown")(TJ.MainFrame)
            end)
            frame:SetScript("OnShow", function(self)
                TuanJian.MOPTJ[dbName] = self:IsShown() and 1 or 0
                TJ.exportTJFrame:UpdateText()
            end)
            frame:SetScript("OnHide", function(self)
                TuanJian.MOPTJ[dbName] = self:IsShown() and 1 or 0
            end)
            TJ.exportTJFrame = frame
        end
    end

    -- 保存方案
    local maxSave = 10
    do
        local dropDown = LibBG:Create_UIDropDownMenu(nil, mainFrame)

        local bt = CreateFrame("Button", nil, mainFrame)
        bt:SetPoint("RIGHT", TJ.exportTJButton, "LEFT", -10, 0)
        bt:SetNormalFontObject(TJ.FontGreen15)
        bt:SetDisabledFontObject(TJ.FontDis15)
        bt:SetHighlightFontObject(TJ.FontWhite15)
        bt:SetText(L["读取方案"])
        bt:SetSize(bt:GetFontString():GetWidth(), 20)
        bt:RegisterForClicks("AnyUp")
        TJ.SetTextHighlightTexture(bt)
        TJ.loadTJButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if TJ.DropDownListIsVisible(self) then
                _G.L_DropDownList1:Hide()
            else
                local menu = {}
                for i, v in ipairs(TuanJian.MOPTJ.history) do
                    tinsert(menu, {
                        text = L["%s、%s轮%s减伤 "]:format(i, v.num, v.type == "physics" and L["物理"] or L["魔法"]),
                        notCheckable = true,
                        arg1 = i,
                        func = function()
                            bt:LoadTJ(v)
                        end
                    })
                end
                tinsert(menu,
                    {
                        text = "   ",
                        isTitle = true,
                        notCheckable = true,
                    }
                )
                tinsert(menu,
                    {
                        text = CANCEL,
                        notCheckable = true,
                        func = function(self)
                            LibBG:CloseDropDownMenus()
                        end,
                    }
                )
                LibBG:EasyMenu(menu, dropDown, self, 0, 0, "MENU", 2)
            end
        end)

        for i = 1, L_UIDROPDOWNMENU_MAXBUTTONS do
            local button = _G["L_DropDownList1Button" .. i]
            button:HookScript("OnEnter", function()
                if L_DropDownList1.dropdown ~= dropDown then return end
                if not button.deleteTJ then
                    local bt = CreateFrame("Button", nil, button)
                    bt:SetSize(15, 15)
                    bt:SetPoint("RIGHT", -2, 0)
                    bt:SetNormalTexture("interface/raidframe/readycheck-notready")
                    bt:SetHighlightTexture("interface/raidframe/readycheck-notready")
                    bt:RegisterForClicks("AnyUp")
                    bt.num = i
                    bt:Hide()
                    button.deleteTJ = bt
                    bt:SetScript("OnClick", function(self)
                        tremove(TuanJian.MOPTJ.history, self.arg1)
                        LibBG:CloseDropDownMenus()
                        TJ.loadTJButton:UpdateState()
                        TJ.loadTJButton:Click()
                    end)
                    bt:SetScript("OnEnter", function(self)
                        button.isOnEnter = true
                        LibBG:UIDropDownMenu_StopCounting(self:GetParent():GetParent())
                        button.Highlight:Show()
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
                        GameTooltip:ClearLines()
                        GameTooltip:AddLine(L["删除该方案"], 1, 1, 1, true)
                        GameTooltip:Show()
                    end)
                    bt:SetScript("OnLeave", function(self)
                        LibBG:UIDropDownMenu_StartCounting(self:GetParent():GetParent())
                        button.Highlight:Hide()
                        GameTooltip:Hide()
                    end)
                    bt:SetScript("OnHide", function(self)
                        self:Hide()
                    end)
                end
                button.isOnEnter = true
                for ii = 1, _G['L_DropDownList1'].numButtons do
                    local bt = _G["L_DropDownList1Button" .. ii]
                    if bt.deleteTJ then
                        bt.deleteTJ:Hide()
                    end
                end
                if button.arg1 then
                    button.deleteTJ:Show()
                end
            end)
            button:HookScript("OnLeave", function()
                if L_DropDownList1.dropdown ~= dropDown then return end
                button.isOnEnter = false
                After(0, function()
                    if not button.isOnEnter then
                        button.deleteTJ:Hide()
                    end
                end)
            end)
        end

        function bt:SetEdit(db, name)
            for _, v in ipairs(TJ.frame[FB][bossIndex].all) do
                for _, vv in ipairs(v.edits) do
                    for _, edit in pairs({ vv.playerEdit, vv.spellEdit }) do
                        if edit.name == name then
                            edit:Load(db)
                            return
                        end
                    end
                end
            end
        end

        function bt:LoadTJ(tj)
            TJ.ClearTJ()
            TuanJian.MOPTJ.num = tj.num
            TuanJian.MOPTJ.type = tj.type
            parent.UpdateChooseFrame()
            for name, db in pairs(tj.info) do
                bt:SetEdit(db, name)
            end
            parent.UpdateShowCount()
        end

        function TJ.loadTJButton:UpdateState()
            self:SetEnabled(next(TuanJian.MOPTJ.history))
        end

        TJ.loadTJButton:UpdateState()

        local bt = CreateFrame("Button", nil, mainFrame)
        bt:SetPoint("RIGHT", TJ.loadTJButton, "LEFT", -10, 0)
        bt:SetNormalFontObject(TJ.FontGreen15)
        bt:SetDisabledFontObject(TJ.FontDis15)
        bt:SetHighlightFontObject(TJ.FontWhite15)
        bt:SetText(L["保存方案"])
        bt:SetSize(bt:GetFontString():GetWidth(), 20)
        TJ.SetTextHighlightTexture(bt)
        TJ.saveTJButton = bt
        bt:SetScript("OnClick", function(self)
            self:Disable()
            After(1, function()
                self:Enable()
            end)
            TJ.PlaySound(2)
            _G.L_DropDownList1:Hide()
            local saveTbl = {
                time = GetServerTime(),
                num = TuanJian.MOPTJ.num,
                type = TuanJian.MOPTJ.type,
                info = {},
            }
            for _, v in ipairs(TJ.frame[FB][bossIndex].all) do
                for _, vv in ipairs(v.edits) do
                    saveTbl.info[vv.playerEdit.name] = vv.playerEdit:GetDB()
                    saveTbl.info[vv.spellEdit.name] = vv.spellEdit:GetDB()
                end
            end
            tinsert(TuanJian.MOPTJ.history, 1, saveTbl)
            while #TuanJian.MOPTJ.history > maxSave do
                tremove(TuanJian.MOPTJ.history)
            end
            TJ.loadTJButton:UpdateState()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            GameTooltip:AddLine(L["最多可以保存%s个方案。"]:format(maxSave), 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    parent.UpdateShowCount()
end)


