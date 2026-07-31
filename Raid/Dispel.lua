local AddonName, ns = ...



local LibBG = ns.LibBG
local L = ns.L
local AddTexture = ns.AddTexture
local Round = ns.Round
local GetClassRGB = ns.GetClassRGB

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")

local mainFrame, list, db, db2
local dispel = {}
local typeName = {
    { name = L["魔法"], color = "66ccff" },
    { name = L["诅咒"], color = "9966cc" },
    { name = L["疾病"], color = "cccccc" },
    { name = L["中毒"], color = "66cc66" },
    { name = L["激怒"], color = "cc6666" },
}

local SumSpell = {}
TJ.Init(function()
    TuanJian.dispel = TuanJian.dispel or {}
    local dispelSaved = TuanJian.dispel

    local function IsDispelFrameDetached()
        local detached = dispelSaved.detached
        return detached == 1 or detached == true
    end

    local function UpdateDispelFrameLayout()
        if not mainFrame then return end
        if mainFrame.f then
            mainFrame.f:SetHeight(mainFrame:GetHeight() - 35)
        end
        if mainFrame.sendButton and mainFrame.f then
            local resizeWidth = IsDispelFrameDetached() and mainFrame.resizeHandle:GetWidth()-5 or 3
            local width = mainFrame:GetWidth() - mainFrame.f:GetWidth() - 15 - resizeWidth
            local shortWidth = width * .3
            mainFrame.sendButton:SetWidth(shortWidth)
            if mainFrame.chooseAllButton then
                mainFrame.chooseAllButton:SetWidth(shortWidth)
            end
            if mainFrame.cancelAllButton then
                mainFrame.cancelAllButton:SetWidth(width * .4)
            end
        end
        if mainFrame.spellButtons and mainFrame.spellScroll then
            local textWidth = max(1, mainFrame.spellScroll:GetWidth() - 20)
            for _, bt in ipairs(mainFrame.spellButtons) do
                if bt.Text then
                    bt.Text:SetWidth(min(bt.Text:GetStringWidth(), textWidth))
                    bt:SetHitRectInsets(0, -bt.Text:GetWidth(), 0, 0)
                end
            end
            if mainFrame.spellChild then
                local childWidth = max(1, mainFrame.spellScroll:GetWidth() - 0)
                local childHeight = max(1, mainFrame.spellScroll:GetHeight(), #mainFrame.spellButtons * 20)
                mainFrame.spellChild:SetSize(childWidth, childHeight)
            end
        end
    end

    local function UpdateDispelFrameSize()
        if not mainFrame then return end
        mainFrame:SetScale(1)
        if IsDispelFrameDetached() then
            local width = min(mainFrame.maxWidth, max(mainFrame.minWidth, tonumber(dispelSaved.width) or mainFrame.defaultWidth))
            local height = min(mainFrame.maxHeight, max(mainFrame.minHeight, tonumber(dispelSaved.height) or mainFrame.defaultHeight))
            mainFrame:SetSize(width, height)
            mainFrame:SetResizable(true)
            if mainFrame.resizeHandle then
                mainFrame.resizeHandle:Show()
            end
        else
            mainFrame:SetSize(mainFrame.defaultWidth, mainFrame.defaultHeight)
            mainFrame:SetResizable(false)
            if mainFrame.resizeHandle then
                mainFrame.resizeHandle:Hide()
            end
        end
        UpdateDispelFrameLayout()
    end

    local function SaveDispelFrameSize()
        dispelSaved.width = floor(min(mainFrame.maxWidth, max(mainFrame.minWidth, mainFrame:GetWidth())) + .5)
        dispelSaved.height = floor(min(mainFrame.maxHeight, max(mainFrame.minHeight, mainFrame:GetHeight())) + .5)
    end

    local function SaveDispelFramePoint()
        local point, _, relativePoint, x, y = mainFrame:GetPoint(1)
        dispelSaved.point = {
            point = point or "CENTER",
            relativePoint = relativePoint or point or "CENTER",
            x = x or 0,
            y = y or 0,
        }
    end

    function TJ.UpdateDispelFramePoint()
        if not mainFrame then return end
        mainFrame:ClearAllPoints()
        if IsDispelFrameDetached() then
            mainFrame:SetParent(UIParent)
            mainFrame:SetMovable(true)
            mainFrame:SetClampedToScreen(true)
            local point = dispelSaved.point
            if point then
                mainFrame:SetPoint(point.point or "CENTER", UIParent, point.relativePoint or point.point or "CENTER", point.x or 0, point.y or 0)
            else
                mainFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            end
        else
            mainFrame:SetParent(TJ.dispelButton)
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            if TJ.dispelFB[FB] == "RIGHT" or (TJ.frame[FB] and TJ.frame[FB][bossIndex] and TJ.frame[FB][bossIndex].board) then
                mainFrame:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT", 1, 0)
            else
                mainFrame:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPLEFT", -1, 0)
            end
        end
        if mainFrame.toggleModeButton then
            mainFrame.toggleModeButton:SetText(IsDispelFrameDetached() and L["合并"] or L["拆分"])
        end
        UpdateDispelFrameSize()
    end

    function TJ.SetDispelFrameDetached(detached)
        dispelSaved.detached = detached and 1 or 0
        if mainFrame then
            TJ.UpdateDispelFramePoint()
        end
    end

    function TJ.AddDispelInfo(spellID, typeID, FB, bossIndex)
        local spellIDs
        if type(spellID) == "number" then
            spellIDs = { spellID }
        else
            spellIDs = spellID
        end
        SumSpell[FB] = SumSpell[FB] or 0
        for _, spellID in ipairs(spellIDs) do
            SumSpell[FB] = SumSpell[FB] + 1
            TJ.OnSpellLoad(spellID, function()
                local icon = C_Spell.GetSpellTexture(spellID)
                local link = C_Spell.GetSpellLink(spellID)
                TJ.dispelInfo[spellID] = {
                    type = typeID,
                    icon = icon,
                    link = link,
                    FB = FB,
                    bossIndex = bossIndex,
                }
            end)
        end
    end

    function TJ.CreateDispelButton()
        local bt = TJ.CreateButton(TJ.raidMainFrame)
        bt:SetSize(80, 22)
        bt:SetText(L["驱散统计"])
        bt:SetPoint("BOTTOMRIGHT", TJ.raidChild, "TOPRIGHT", 0, 0)
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            local show = TJ.dispelFrame:IsVisible()
            if not show then
                TJ.UpdateDispelFramePoint()
            end
            TJ.dispelFrame:SetShown(not show)
            TuanJian.dispel.show = show and 0 or 1
        end)
        TJ.dispelButton = bt
    end

    function TJ.UpdateDispelButton()
        if not TJ.dispelButton then
            TJ.CreateDispelButton()
            TJ.CreateDispelFrame()
        end
        if TJ.dispelFB[TuanJian.FB] then
            TJ.dispelButton:Show()
            TJ.dispelFrame:Hide()
            TJ.UpdateDispelFramePoint()
            if TuanJian.dispel.show == 1 then
                TJ.dispelFrame:Show()
            end
        else
            TJ.dispelButton:Hide()
            TJ.dispelFrame:Hide()
        end
    end

    local buttonWidth = 250
    function TJ.CreateDispelFrame()
        local titleInfo = {
            { name = L["序号"], width = 30, },
            { name = L["玩家"], width = 90, },
            { name = L["次数"], width = 40, },
        }
        local offset = 5
        local totalWidth = 0
        for i, v in ipairs(titleInfo) do
            totalWidth = totalWidth + v.width
        end
        local defaultWidth = totalWidth + buttonWidth + 40
        local defaultHeight = 400
        local minWidth = defaultWidth - 100
        local minHeight = 200
        local maxWidth = 1200
        local maxHeight = 1000

        mainFrame = CreateFrame("Frame", nil, TJ.dispelButton, "BackdropTemplate")
        do
            mainFrame:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            mainFrame:SetBackdropColor(0, 0, 0, 0.8)
            local r, g, b = ns.GetClassRGB(nil, "player")
            mainFrame:SetBackdropBorderColor(r, g, b, TJ.borderAlpha)
            mainFrame:SetSize(defaultWidth, defaultHeight)
            mainFrame.defaultWidth = defaultWidth
            mainFrame.defaultHeight = defaultHeight
            mainFrame.minWidth = minWidth
            mainFrame.minHeight = minHeight
            mainFrame.maxWidth = maxWidth
            mainFrame.maxHeight = maxHeight
            if mainFrame.SetResizeBounds then
                mainFrame:SetResizeBounds(minWidth, minHeight, maxWidth, maxHeight)
            else
                mainFrame:SetMinResize(minWidth, minHeight)
                mainFrame:SetMaxResize(maxWidth, maxHeight)
            end
            mainFrame:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT", 1, 0)
            mainFrame:SetFrameLevel(112)
            mainFrame:EnableMouse(true)
            mainFrame:SetMovable(true)
            mainFrame:SetClampedToScreen(IsDispelFrameDetached())
            mainFrame.titles = {}
            mainFrame.buttons = {}
            mainFrame.spellButtons = {}
            TJ.dispelFrame = mainFrame
            mainFrame:SetScript("OnMouseDown", function(self)
                if TJ.lastfocus then
                    TJ.lastfocus:ClearFocus()
                end
                if TJ.FramePlayerList then
                    TJ.FramePlayerList:Hide()
                end
                if IsDispelFrameDetached() then
                    self:StartMoving()
                else
                    TJ.MainFrame:StartMoving()
                end
            end)
            mainFrame:SetScript("OnMouseUp", function(self)
                if IsDispelFrameDetached() then
                    self:StopMovingOrSizing()
                    SaveDispelFramePoint()
                else
                    TJ.MainFrame:StopMovingOrSizing()
                end
            end)
            mainFrame:SetScript("OnShow", function(self)
                dispel:UpdateList()
                TJ.UpdateDispelFramePoint()
            end)

            mainFrame.CloseButton = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
            mainFrame.CloseButton:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", 4, 4)
            mainFrame.CloseButton:HookScript("OnClick", function()
                TuanJian.dispel.show = 0
            end)

            mainFrame.resizeHandle = CreateFrame("Button", nil, mainFrame)
            mainFrame.resizeHandle:SetSize(15, 15)
            mainFrame.resizeHandle:SetPoint("BOTTOMRIGHT", 0, 0)
            mainFrame.resizeHandle:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
            mainFrame.resizeHandle:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
            mainFrame.resizeHandle:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
            mainFrame.resizeHandle:SetShown(IsDispelFrameDetached())
            mainFrame.resizeHandle:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" and IsDispelFrameDetached() then
                    self:GetParent():StartSizing("BOTTOMRIGHT")
                end
            end)
            mainFrame.resizeHandle:SetScript("OnMouseUp", function(self)
                local parent = self:GetParent()
                parent:StopMovingOrSizing()
                SaveDispelFrameSize()
                SaveDispelFramePoint()
            end)
            mainFrame:SetScript("OnSizeChanged", function()
                UpdateDispelFrameLayout()
            end)

            local bt = TJ.CreateButton(mainFrame)
            bt:SetSize(55, 22)
            bt:SetPoint("RIGHT", mainFrame.CloseButton, "LEFT", -2, 0)
            bt:SetText(IsDispelFrameDetached() and L["合并"] or L["拆分"])
            mainFrame.toggleModeButton = bt
            bt:SetScript("OnClick", function(self)
                TJ.PlaySound(1)
                local detached = not IsDispelFrameDetached()
                TJ.SetDispelFrameDetached(detached)
                TuanJian.dispel.show = 1
                if detached then
                    TJ.MainFrame:Hide()
                else
                    TJ.MainFrame:Show()
                end
            end)

            local text = mainFrame:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            text:SetPoint("CENTER", mainFrame, "TOP", 0, -12)
            mainFrame.title = text

            local f = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
            f:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            f:SetBackdropColor(.3, .3, .3, 0.2)
            f:SetBackdropBorderColor(1, 1, 1, .3)
            f:SetSize(totalWidth + offset * 2, mainFrame:GetHeight() - 35)
            f:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", offset, -30)
            mainFrame.f = f
            local scroll = CreateFrame("ScrollFrame", nil, f, "UIPanelScrollFrameTemplate")
            scroll:SetPoint("TOPLEFT", 0, -35)
            scroll:SetPoint("BOTTOMRIGHT", -0, 0)
            scroll.ScrollBar.scrollStep = 100
            scroll.ScrollBar:Hide()
            TJ.HookScrollBarShowOrHide(scroll, true)
            mainFrame.scroll = scroll
            local child = CreateFrame("Frame", nil, scroll)
            child:SetSize(1, 1)
            mainFrame.child = child
            scroll:SetScrollChild(child)

            local t = mainFrame:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("TOP", scroll, "TOP", 0, 0)
            t:SetTextColor(.5, .5, .5)
            t:SetText(L["没有数据。"])
            mainFrame.notText = t

            local spellScroll = CreateFrame("ScrollFrame", nil, mainFrame, "UIPanelScrollFrameTemplate")
            spellScroll:SetPoint("TOPLEFT", f, "TOPRIGHT", 5, -5)
            spellScroll:SetPoint("BOTTOMRIGHT", mainFrame, "BOTTOMRIGHT", -5, 40)
            spellScroll.ScrollBar.scrollStep = 100
            spellScroll.ScrollBar:Hide()
            TJ.HookScrollBarShowOrHide(spellScroll, true)
            mainFrame.spellScroll = spellScroll
            local spellChild = CreateFrame("Frame", nil, spellScroll)
            spellChild:SetSize(1, 1)
            mainFrame.spellChild = spellChild
            spellScroll:SetScrollChild(spellChild)
        end

        for i, v in ipairs(titleInfo) do
            local f = CreateFrame("Frame", nil, mainFrame)
            f:SetSize(v.width, 20)
            if not next(mainFrame.titles) then
                f:SetPoint("TOPLEFT", mainFrame.f, "TOPLEFT", offset, -10)
            else
                f:SetPoint("LEFT", mainFrame.titles[#mainFrame.titles], "RIGHT", 0, 0)
            end
            tinsert(mainFrame.titles, f)
            local t = f:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            t:SetPoint('CENTER')
            t:SetTextColor(1, 1, 1)
            t:SetText(v.name)
        end
        ns.CreateLine(mainFrame.titles[1], 0, totalWidth - 0)

        local function OnEnter(self)
            local FB = TuanJian.FB
            local guid = self.guid
            local tbl = {}
            for spellID, count in pairs(db[guid].spell) do
                if not TuanJian.dispel[FB][spellID] then
                    tinsert(tbl, {
                        spellID = spellID,
                        count = count,
                    })
                end
            end
            sort(tbl, function(a, b)
                return a.count > b.count
            end)

            GameTooltip:SetOwner(self[2], "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self[2]:GetText(), self[2]:GetTextColor())
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(L["法术"], L["驱散次数"])
            for i, vv in ipairs(tbl) do
                local link
                for k, v in pairs(list) do
                    if v.spellID == vv.spellID then
                        link = dispel.SetDispelLink(v.link, v.type, v.icon)
                        break
                    end
                end
                GameTooltip:AddDoubleLine(link, vv.count)
            end
            GameTooltip:Show()
            self.ds:Show()
        end
        local function CreateButton(index)
            local f = CreateFrame("Frame", nil, mainFrame.child)
            f:SetSize(totalWidth, 20)
            if not next(mainFrame.buttons) then
                f:SetPoint("TOPLEFT", mainFrame.child, "TOPLEFT", offset, 0)
            else
                f:SetPoint("TOPLEFT", mainFrame.buttons[#mainFrame.buttons], "BOTTOMLEFT", 0, 0)
            end
            tinsert(mainFrame.buttons, f)
            local tex = f:CreateTexture(nil, "BACKGROUND")
            tex:SetAllPoints()
            tex:SetColorTexture(1, 1, 1, 0.2)
            tex:Hide()
            f.ds = tex
            for i, v in ipairs(titleInfo) do
                f[i] = f:CreateFontString()
                f[i]:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
                f[i]:SetWidth(v.width)
                f[i]:SetTextColor(1, 1, 1)
                f[i]:SetWordWrap(false)
                if i == 1 then
                    f[i]:SetPoint("LEFT", f, "LEFT", 0, 0)
                    f[i]:SetText(index)
                else
                    f[i]:SetPoint("LEFT", f[i - 1], "RIGHT", 0, 0)
                end
                f:SetScript("OnEnter", OnEnter)
                f:SetScript("OnLeave", function(self)
                    self.ds:Hide()
                    GameTooltip_Hide()
                end)
            end
        end

        for index = 1, 40 do
            CreateButton(index)
        end

        local bt = TJ.CreateButton(mainFrame)

        bt:SetSize(buttonWidth * .3, 25)
        bt:SetPoint("BOTTOMLEFT", mainFrame.f, "BOTTOMRIGHT", 5, 0)
        bt:SetText(L["通报"])
        mainFrame.sendButton = bt
        function bt:GetSendText(OnEnter)
            local tbl = {}
            tinsert(tbl, { L["——通报驱散统计——"] })
            tinsert(tbl, { (OnEnter and "|cffffffff" or "") .. L["统计以下法术："] })
            local spell = {}
            for i, bt in ipairs(mainFrame.spellButtons) do
                if bt:GetChecked() then
                    spell[bt.bossIndex] = spell[bt.bossIndex] or {
                        bossName = bt.bossName,
                        text = "",
                    }
                    spell[bt.bossIndex] = spell[bt.bossIndex] or ""
                    spell[bt.bossIndex].text = spell[bt.bossIndex].text .. (OnEnter and bt.colorLink or bt.link)
                end
            end
            for i = 1, 20 do
                local bt = spell[i]
                if bt then
                    tinsert(tbl, { format(L["%s号%s：%s"], i, bt.bossName, bt.text) })
                end
            end
            tinsert(tbl, { (OnEnter and "|cffffffff" or "") .. L["驱散次数："] })
            local yes
            for i, f in ipairs(mainFrame.buttons) do
                if f:IsVisible() then
                    yes = true
                    tinsert(tbl, { format(L["%s、%s %s次"], i, (OnEnter and ns.RGB_16(f[2]) or TJ.ClearCode(f[2]:GetText())), f[3]:GetText()) })
                end
            end
            return tbl, yes
        end

        bt:SetScript("OnEnter", function(self)
            local tbl, yes = bt:GetSendText(true)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            for i in ipairs(tbl) do
                for i, text in ipairs(tbl[i]) do
                    GameTooltip:AddLine(text)
                end
            end
            if not yes then
                GameTooltip:AddLine(L["统计数据是空的。"], 1, 0, 0)
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnClick", function(self)
            if not IsInRaid(1) then
                ns.SendSystemMessage(L["你没有团队，无法通报。"])
                return
            end
            local tbl, yes = bt:GetSendText()
            if not yes then return end
            if self:Disable() then return end
            After(2, function() self:Enable() end)
            tinsert(tbl, { L["—感谢使用TuanJian插件—"] })
            local t = TJ.SendMsgToRaid(tbl)
            TJ.PlaySound(2)
        end)

        local bt = TJ.CreateButton(mainFrame)
        bt:SetSize(buttonWidth * .3, 25)
        bt:SetPoint("LEFT", mainFrame.sendButton, "RIGHT", 0, 0)
        bt:SetText(L["全选"])
        mainFrame.chooseAllButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            local FB = TuanJian.FB
            for _, bt in pairs(mainFrame.spellButtons) do
                bt:SetChecked(true)
                TuanJian.dispel[FB][bt.id] = nil
            end
            dispel:UpdateChild()
        end)

        local bt = TJ.CreateButton(mainFrame)
        bt:SetSize(buttonWidth * .4, 25)
        bt:SetPoint("LEFT", mainFrame.chooseAllButton, "RIGHT", 0, 0)
        bt:SetText(L["取消全选"])
        mainFrame.cancelAllButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            local FB = TuanJian.FB
            for _, bt in pairs(mainFrame.spellButtons) do
                bt:SetChecked(false)
                TuanJian.dispel[FB][bt.id] = true
            end
            dispel:UpdateChild()
        end)
        UpdateDispelFrameLayout()
    end

    function TJ.UpdateDispelFrameDelay()
        if TJ.dispelFrame:IsVisible() then
            TJ.dispelFrame.t = 0
            TJ.dispelFrame:SetScript("OnUpdate", function(self, t)
                self.t = self.t + t
                if self.t >= 1 then
                    self:SetScript("OnUpdate", nil)
                    dispel:UpdateList()
                end
            end)
        end
    end

    function dispel:CreateSpellButton(v)
        local FB = TuanJian.FB
        local bt = CreateFrame("CheckButton", nil, mainFrame.spellChild, "ChatConfigCheckButtonTemplate")
        bt:SetSize(20, 20)
        if next(mainFrame.spellButtons) then
            bt:SetPoint("TOPLEFT", mainFrame.spellButtons[#mainFrame.spellButtons], "BOTTOMLEFT", 0, 0)
        else
            bt:SetPoint("TOPLEFT", mainFrame.spellChild, "TOPLEFT", 0, 0)
        end
        bt:SetChecked(not TuanJian.dispel[FB][v.spellID])
        bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        bt.Text:ClearAllPoints()
        bt.Text:SetPoint("LEFT", bt, "RIGHT")
        bt.Text:SetWordWrap(false)
        bt.id = v.spellID
        bt.bossIndex = v.bossIndex
        bt.bossName = v.bossName
        bt.link = v.link
        bt.colorLink = dispel.SetDispelLink(v.link, v.type, v.icon)
        bt.Text:SetText(format(L["%s %s次|cffbbbbbb（%s:%s）"], bt.colorLink, db2[v.spellID] or 0, v.bossIndex, v.bossName))
        bt.Text:SetWidth(min(bt.Text:GetStringWidth(), max(1, mainFrame.spellScroll:GetWidth() - 40)))
        bt:SetHitRectInsets(0, -bt.Text:GetWidth(), 0, 0)
        tinsert(mainFrame.spellButtons, bt)
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if self:GetChecked() then
                TuanJian.dispel[FB][self.id] = nil
            else
                TuanJian.dispel[FB][self.id] = true
            end
            dispel:UpdateChild()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self.Text, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:SetSpellByID(self.id)
            GameTooltip:AddLine(" ")
            GameTooltip:AddDoubleLine(L["玩家"], L["驱散次数"])
            local has = false
            local tbl1 = {}
            for guid, v in pairs(db) do
                for spellID, count in pairs(v.spell) do
                    if spellID == self.id then
                        tbl1[guid] = tbl1[guid] or {
                            sum = 0,
                            name = v.name,
                            class = v.class,
                            guid = guid,
                        }
                        tbl1[guid].sum = tbl1[guid].sum + count
                    end
                end
            end
            local tbl2 = {}
            for k, v in pairs(tbl1) do
                tinsert(tbl2, v)
            end
            sort(tbl2, function(a, b)
                return a.sum > b.sum
            end)
            for i, v in ipairs(tbl2) do
                local r, g, b = 1, 1, 1
                if v.class then
                    r, g, b = GetClassColor(v.class)
                end
                has = true
                GameTooltip:AddDoubleLine(TJ.GetIconFormName(v.name), v.sum, r, g, b, 1, 1, 1)
            end
            if not has then
                GameTooltip:AddDoubleLine(L["无人驱散"], 0, .5, .5, .5, .5, .5, .5)
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
    end

    function dispel:UpdateList()
        local FB = TuanJian.FB
        local tbl = {}
        local count = 0
        for spellID, v in pairs(TJ.dispelInfo) do
            if v.FB == FB then
                count = count + 1
                tinsert(tbl, {
                    bossName = TJ.FBinfo[FB][v.bossIndex].name,
                    bossIndex = v.bossIndex,
                    icon = v.icon,
                    link = v.link,
                    type = v.type,
                    spellID = spellID,
                })
            end
        end
        if count == SumSpell[FB] then
            sort(tbl, function(a, b)
                return a.bossIndex < b.bossIndex
            end)
            list = tbl

            dispel:UpdateChild()

            for i, bt in ipairs(mainFrame.spellButtons) do
                bt:Hide()
            end
            wipe(mainFrame.spellButtons)
            for i, v in ipairs(list) do
                dispel:CreateSpellButton(v)
            end
            UpdateDispelFrameLayout()
        else
            After(.5, function()
                dispel:UpdateList()
            end)
        end
        mainFrame.title:SetFormattedText(L["驱散统计（%s）"], TJ.FBinfo[FB].localName)
    end

    function dispel:UpdateListDispelSum()
    end

    function dispel:GetDB()
        local playerCount = {}
        local spellCount = {}
        local boss = {}
        for i, combatLog in ipairs(TuanJian.combatLog) do
            if combatLog.FB == TuanJian.FB and combatLog.dispel and not boss[combatLog.FB .. combatLog.bossIndex] then
                boss[combatLog.FB .. combatLog.bossIndex] = true
                for spellID in pairs(combatLog.dispel) do
                    spellCount[spellID] = spellCount[spellID] or 0
                    for guid, count in pairs(combatLog.dispel[spellID]) do
                        spellCount[spellID] = spellCount[spellID] + count
                        guid = TJ.GetGUID(guid, combatLog)
                        if not playerCount[guid] then
                            local name = combatLog.guid[guid] and combatLog.guid[guid].name or UNKNOWN
                            local class = combatLog.guid[guid] and combatLog.guid[guid].class
                            playerCount[guid] = {
                                sum = 0,
                                name = name,
                                class = class,
                                spell = {},
                            }
                        end
                        playerCount[guid].sum = playerCount[guid].sum + count
                        playerCount[guid].spell[spellID] = playerCount[guid].spell[spellID] or 0
                        playerCount[guid].spell[spellID] = playerCount[guid].spell[spellID] + count
                    end
                end
            end
        end
        return playerCount, spellCount
    end

    function dispel:UpdateChild()
        db, db2 = dispel:GetDB()
        local FB = TuanJian.FB
        for i, bt in ipairs(mainFrame.buttons) do
            bt:Hide()
        end
        local tbl = {}
        for guid, v in pairs(db) do
            local t = CopyTable(v)
            t.guid = guid
            local sum = 0
            for spellID, count in pairs(v.spell) do
                if not TuanJian.dispel[FB][spellID] then
                    sum = sum + count
                end
            end
            t.sum = sum
            tinsert(tbl, t)
        end
        sort(tbl, function(a, b)
            return a.sum > b.sum
        end)
        local yes
        for i, v in ipairs(tbl) do
            if v.sum > 0 then
                yes = true
                local f = mainFrame.buttons[i]
                f.guid = v.guid
                f:Show()
                f[2]:SetText(TJ.GetIconFormName(v.name))
                local r, g, b = GetClassColor(v.class)
                if r then
                    f[2]:SetTextColor(r, g, b)
                end
                f[3]:SetText(TJ.GetIconFormName(v.sum))
            end
        end
        mainFrame.notText:SetShown(not yes)
    end

    function dispel.SetDispelLink(link, type, icon)
        link = TJ.ClearCode(link):gsub("%[", ""):gsub("%]", "")
        local color = typeName[type] and typeName[type].color or "ffffff"
        return AddTexture(icon) .. "|cff" .. color .. link .. "|r"
    end
end)
