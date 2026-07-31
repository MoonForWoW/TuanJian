local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L
local AddTexture = ns.AddTexture
local GetClassRGB = ns.GetClassRGB
local SetClassCFF = ns.SetClassCFF
local RGB = ns.RGB
local Round = ns.Round

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

TJ.Init(function()
    -- 主界面
    do
        local f = TJ.CreateMainFrame("TJ.MainFrame", "<" .. AddonName .. "> " .. L["团减助手"])
        f.titleText:ClearAllPoints()
        f.titleText:SetPoint("TOP", -0, -4)
        f:SetSize(500, 500)
        f.IsForbidden = nil
        TJ.MainFrame = f
        f:HookScript("OnMouseDown", function(self)
            if TJ.lastfocus then
                TJ.lastfocus:ClearFocus()
            end
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
            LibBG:CloseDropDownMenus()
        end)
        TJ.dropDown = LibBG:Create_UIDropDownMenu(nil, TJ.MainFrame)

        local VerText = TJ.MainFrame:CreateFontString()
        VerText:SetPoint("BOTTOMLEFT", f.titleText, "BOTTOMRIGHT", 0, 0)
        VerText:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
        VerText:SetTextColor(RGB("00BFFF"))
        VerText:SetText(TJ.ver)
        TJ.VerText = VerText

        -- 说明书
        local f = CreateFrame("Frame", nil, TJ.MainFrame)
        f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 8, -1)
        f:SetHitRectInsets(0, 0, 0, 0)
        local t = f:CreateFontString()
        t:SetPoint("CENTER")
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetJustifyH("LEFT")
        t:SetText(L["说明书"])
        t:SetTextColor(0, 1, 0)
        f:SetSize(t:GetStringWidth(), 20)
        TJ.ShuoMingShu = f
        TJ.ShuoMingShuText = t
        local function OnEnter(self)
            self.OnEnter = true
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
            GameTooltip:ClearLines()
            for _, text in ipairs(ns.instructionsText) do
                GameTooltip:AddLine(text)
            end
            for _, text in ipairs(ns.updateText_now) do
                GameTooltip:AddLine(text)
            end
            for _, text in ipairs(ns.updateText_before) do
                GameTooltip:AddLine(text)
            end
            GameTooltip:Show()
            t:SetTextColor(1, 1, 1)
        end
        f:SetScript("OnEnter", OnEnter)
        f:SetScript("OnLeave", function(self)
            self.OnEnter = false
            GameTooltip:Hide()
            t:SetTextColor(0, 1, 0)
        end)

        TJ.raidMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.raidMainFrame:Hide()
        TJ.raidMainFrame:HookScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            After(0, TJ.UpdateMainFrameSize)
        end)

        TJ.raidTargetMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.raidTargetMainFrame:Hide()
        TJ.raidTargetMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            TJ.UpdateEditIcon_RaidTarget()
        end)

        TJ.tjMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.tjMainFrame:Hide()
        TJ.tjMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            TJ.UpdateSpecialEdit()
            TJ.UpdateEditIcon()
            After(0, TJ.UpdateMainFrameSize)
        end)

        TJ.dpsMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.dpsMainFrame:Hide()
        TJ.dpsMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            TJ.UpdateSpecialEdit()
            TJ.UpdateEditIcon()
            After(0, TJ.UpdateMainFrameSize)
        end)

        TJ.ssMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.ssMainFrame:Hide()
        TJ.ssMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            TJ.UpdateSpecialEdit()
            TJ.UpdateEditIcon()
        end)

        TJ.buffMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.buffMainFrame:Hide()
        TJ.buffMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            TJ.UpdateEditIcon_Buff()
        end)

        TJ.gjMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.gjMainFrame:Hide()
        TJ.gjMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            TJ.UpdateSpecialEdit()
            TJ.UpdateEditIcon()
        end)

        TJ.equipMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.equipMainFrame:Hide()
        TJ.equipMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            TJ.UpdateEquipFrame()
        end)

        TJ.optionMainFrame = CreateFrame("Frame", nil, TJ.MainFrame)
        TJ.optionMainFrame:Hide()
        TJ.optionMainFrame:SetScript("OnShow", function(self)
            TJ.exportTJButton_UpdateShow()
            self.optionFrame:SetWidth(self.scroll:GetWidth())
        end)

        -- 更新日记窗口
        TJ.Init2(function()
            -- TuanJian.options.SearchHistory[ns.updateText_now[1]] = nil
            if next(ns.updateText_now) and not TuanJian.options.SearchHistory[ns.updateText_now[1]] then
                TuanJian.options.SearchHistory[ns.updateText_now[1]] = true
                if TuanJian.options.lastVer then
                    local f = TJ.CreateMainFrame()
                    f:SetSize(450, 1)
                    f:SetFrameStrata("HIGH")
                    f.titleText:SetText("<" .. AddonName .. "> " .. L["团减助手"])
                    f.texts = {}
                    TJ.updateFrame = f
                    local bgFrame = _G.BG and _G.BG.updateFrame
                    if bgFrame and bgFrame:IsVisible() then
                        f:ClearAllPoints()
                        f:SetPoint("TOP", bgFrame, "BOTTOM", 0, -10)
                    end
                    local w = 15
                    for i, text in ipairs(ns.updateText_now) do
                        local t = f:CreateFontString()
                        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                        t:SetText(text)
                        t:SetWidth(f:GetWidth() - w * 2)
                        if i == 1 then
                            t:SetPoint("TOPLEFT", w, -35)
                            t:SetJustifyH("CENTER")
                        else
                            t:SetPoint("TOPLEFT", f.texts[i - 1], "BOTTOMLEFT", 0, -15)
                            t:SetJustifyH("LEFT")
                        end
                        t:SetTextColor(1, .82, 0)
                        tinsert(f.texts, t)
                    end
                    f:SetHeight(f:GetTop() - f.texts[#f.texts]:GetBottom())
                end
            end
            TuanJian.options.lastVer = TJ.ver
        end)
    end
    tinsert(UISpecialFrames, "TJ.MainFrame")

    -- 版本号显示
    TJ.Init3(function()
        TJ.raidVersion = {}

        local function SendMyVer()
            C_ChatInfo.SendAddonMessage("TuanJian", format("MyVer-%s-%s",
                TJ.ver, ""), "RAID")
        end
        local f = CreateFrame("Frame")
        f:RegisterEvent("GROUP_ROSTER_UPDATE")
        f:RegisterEvent("CHAT_MSG_SYSTEM")
        f:RegisterEvent("CHAT_MSG_ADDON")
        f:RegisterEvent("PLAYER_ENTERING_WORLD")
        f:SetScript("OnEvent", function(self, event, ...)
            if event == "GROUP_ROSTER_UPDATE" then
                if TJ.CanSend() then
                    After(1, function()
                        if IsInRaid(1) then
                            SendMyVer()
                        end
                    end)
                end
            elseif event == "CHAT_MSG_SYSTEM" then
                local text = ...
                local leave = ERR_RAID_MEMBER_REMOVED_S:gsub("%%s", "(.+)")
                local name = strmatch(text, leave)
                if name then
                    TJ.raidVersion[name] = nil
                end
            elseif event == "CHAT_MSG_ADDON" then
                local prefix, msg, distType, _, sender = ...
                if prefix ~= "TuanJian" then return end
                if distType == "RAID" then
                    if msg == "VersionCheck" then
                        SendMyVer()
                    elseif strfind(msg, "MyVer") then
                        local _, version = strsplit("-", msg)
                        TJ.raidVersion[sender] = version
                    end
                end
            elseif event == "PLAYER_ENTERING_WORLD" then
                self:UnregisterEvent("PLAYER_ENTERING_WORLD")
                After(5, function()
                    if IsInRaid(1) then
                        C_ChatInfo.SendAddonMessage("TuanJian", "VersionCheck", "RAID")
                    end
                end)
            end
        end)
    end)

    -- 模块切换
    do
        -- TJ.canUseTips = true
        TuanJian.lastFrameNum = TuanJian.lastFrameNum or (TJ.canUseTips and 1 or 2)

        TJ.tabButtons = {}
        TJ.raidMainFrameTabNum = 1
        TJ.raidTargetMainFrameTabNum = 2
        TJ.tjMainFrameTabNum = 3
        TJ.buffMainFrameTabNum = 4
        TJ.optionMainFrameTabNum = 5
        TJ.dpsMainFrameTabNum = 6
        TJ.ssMainFrameTabNum = 7
        TJ.gjMainFrameTabNum = 8
        TJ.equipMainFrameTabNum = 9

        local r, g, b = GetClassRGB(nil, "player")
        local blackup = CreateColor(.3, .3, .3, .7)
        local blackdown = CreateColor(0, 0, 0, .7)
        local classColorup = CreateColor(r, g, b, .7)
        local classColordown = CreateColor(r, g, b, .1)
        local function SetColor(bt, isOnEnter)
            local alpha = .8
            local r, g, b
            if isOnEnter then
                r, g, b = GetClassRGB(nil, "player")
            else
                r, g, b = 0, 0, 0
            end
            bt.bg:SetColorTexture(r, g, b)
            bt.bg:SetAlpha(alpha)
        end
        function TJ.ClickTabButton(num)
            LibBG:CloseDropDownMenus()
            TuanJian.lastFrameNum = num
            local yes
            for _, v in ipairs(TJ.tabButtons) do
                local bt = v.button
                if v.num ~= num then
                    bt:Enable()
                    SetColor(bt, false)
                    bt:GetFontString():SetTextColor(1, .82, 0)
                    v.frame:Hide()
                end
            end
            for _, v in ipairs(TJ.tabButtons) do
                local bt = v.button
                if v.num == num then
                    yes = true
                    bt:Disable()
                    SetColor(bt, true)
                    bt:GetFontString():SetTextColor(1, 1, 1)
                    v.frame:Show()
                    TJ.sendButton:UpdateParent(v.frame)
                    TJ.autoButton:UpdateParent(v.frame)
                    TJ.talentButton:UpdateParent(v.frame)
                    break
                end
            end
            if not TJ.canUseTips then
                TJ.raidMainFrame:Hide()
            end
            if not yes then
                TJ.ClickTabButton(1)
            end
        end

        function TJ.Create_TabButton(num, text, frame, width)
            local bt = CreateFrame("Button", nil, TJ.MainFrame, "BackdropTemplate")
            bt:SetBackdrop({
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            bt:SetBackdropBorderColor(GetClassRGB(nil, "player", TJ.borderAlpha))
            bt:SetSize(width or 70, 28)
            if #TJ.tabButtons == 0 then
                bt:SetPoint("TOPLEFT", TJ.MainFrame, "BOTTOMLEFT", 20, 1)
            else
                bt:SetPoint("LEFT", TJ.tabButtons[#TJ.tabButtons].button, "RIGHT", TJ.IsWLK and 3 or 5, 0)
            end
            bt.bg = bt:CreateTexture(nil, "BACKGROUND")
            bt.bg:SetAllPoints()
            bt.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
            local t = bt:CreateFontString()
            t:SetAllPoints()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetText(text)
            t:SetWordWrap(false)
            bt:SetFontString(t)
            tinsert(TJ.tabButtons, {
                button = bt,
                frame = frame,
                num = num,
            })
            bt:SetScript("OnClick", function(self)
                TJ.ClickTabButton(num)
                TJ.PlaySound(1)
            end)
            bt:SetScript("OnEnter", function(self)
                SetColor(bt, true)
            end)
            bt:SetScript("OnLeave", function(self)
                GameTooltip:Hide()
                SetColor(bt)
            end)
            return bt
        end

        -- local bt = TJ.Create_TabButton(TJ.raidMainFrameTabNum, L["战术"], TJ.raidMainFrame)
        local bt = TJ.Create_TabButton(TJ.raidTargetMainFrameTabNum, L["锁标"], TJ.raidTargetMainFrame)
        local bt = TJ.Create_TabButton(TJ.tjMainFrameTabNum, TJ.IsTBC and L["个减"] or L["团减"], TJ.tjMainFrame)
        if TJ.IsMOP then
            local bt = TJ.Create_TabButton(TJ.dpsMainFrameTabNum, L["增伤"], TJ.dpsMainFrame)
            local bt = TJ.Create_TabButton(TJ.gjMainFrameTabNum, L["个减"], TJ.gjMainFrame)
        end
        if TJ.IsWLK then
            local bt = TJ.Create_TabButton(TJ.ssMainFrameTabNum, L["灵魂石"], TJ.ssMainFrame)
            local bt = TJ.Create_TabButton(TJ.buffMainFrameTabNum, L["BUFF"], TJ.buffMainFrame)
        end
        local bt = TJ.Create_TabButton(TJ.equipMainFrameTabNum, L["团队"], TJ.equipMainFrame)
        local bt = TJ.Create_TabButton(TJ.optionMainFrameTabNum, L["设置"], TJ.optionMainFrame)

        After(0, function()
            TJ.ClickTabButton(TuanJian.lastFrameNum)
        end)
    end

    -- 设置
    TJ.InitOptions()

    -- 副本选择
    do
        local dropDown = LibBG:Create_UIDropDownMenu(nil, TJ.raidMainFrame)
        dropDown:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", -5, -30)
        LibBG:UIDropDownMenu_SetWidth(dropDown, 110)
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
        dropDown.Text:SetJustifyH("LEFT")
        TJ.dropDownToggle(dropDown)
        TJ.FBDropDown = dropDown
        for _, v in pairs(TJ.FBtbl) do
            if TuanJian.FB == v.FB then
                LibBG:UIDropDownMenu_SetText(dropDown, v.localName)
                break
            end
        end
        LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
            for _, v in ipairs(TJ.FBtbl) do
                local info = LibBG:UIDropDownMenu_CreateInfo()
                local text = (v.phase and v.phase ~= TJ.nowPhase and "|cffaaaaaa" or "")
                    .. (v.phase and v.phase .. L["："] or "") .. v.localName
                info.text = text
                info.func = function()
                    TuanJian.FB = v.FB
                    TJ.UpdateBossChooseFrame()
                    TJ.UpdateBossFrame(TuanJian[TuanJian.FB].lastBoss or 1)
                end
                info.checked = text:find(LibBG:UIDropDownMenu_GetText(dropDown))
                LibBG:UIDropDownMenu_AddButton(info)
            end
        end)
    end

    -- 内容
    do
        local f = CreateFrame("Frame", nil, TJ.raidMainFrame)
        f:SetPoint("TOP", TJ.MainFrame, 0, -70)
        f:SetHeight(20)
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 16, "OUTLINE")
        t:SetPoint("CENTER")
        t:SetTextColor(1, 1, 1)
        t:SetJustifyH("LEFT")
        t.owner = f
        TJ.bossNameText = t

        local f = CreateFrame("Frame", nil, TJ.raidMainFrame, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        f:SetBackdropColor(.3, .3, .3, 0.2)
        f:SetBackdropBorderColor(1, 1, 1, .3)
        f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 10, -92)
        f:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", -10, 60)
        TJ.raidChild = f

        local f = CreateFrame("Frame", nil, TJ.raidChild, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
        })
        f:SetBackdropColor(.5, .5, .5, 0.5)
        TJ.spChild = f
        function f:UpdateSize()
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            self:ClearAllPoints()
            local count = #TJ.spChild[FB .. bossIndex]
            local cow
            if count <= 5 then
                cow = 1
            else
                cow = floor((count - 6) / 4) + 2
            end
            self:SetPoint("TOPLEFT", TJ.raidChild, "BOTTOMLEFT", 10, 10 + cow * 30)
            self:SetPoint("BOTTOMRIGHT", TJ.raidChild, "BOTTOMRIGHT", -10, 10)
        end

        -- 战斗分析
        do
            local f = CreateFrame("Frame", nil, TJ.spChild, "BackdropTemplate")
            f:SetSize(150, 20)
            f:SetPoint("TOPLEFT", TJ.spChild, "TOPLEFT", 0, -5)
            local t = f:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("BOTTOMRIGHT")
            t:SetSize(f:GetSize())
            t:SetText(L["战斗分析："])
            t:SetJustifyH("RIGHT")
            t:SetWordWrap(false)
            f.Text = t
            TJ.spChild.title = f

            local bt = CreateFrame("Button", nil, f)
            bt:SetSize(18, 18)
            local tex = bt:CreateTexture()
            tex:SetPoint("CENTER")
            tex:SetSize(bt:GetWidth() + 10, bt:GetHeight() + 10)
            tex:SetTexture(616343)
            local tex = bt:CreateTexture()
            tex:SetPoint("CENTER")
            tex:SetSize(bt:GetWidth() + 10, bt:GetHeight() + 10)
            tex:SetTexture(616343)
            bt:SetHighlightTexture(tex)
            f.tips = bt
            bt:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine(L["战斗分析"], 1, 1, 1, true)
                GameTooltip:AddLine(L["BOSS战结束后，任务名字会变成绿色，点击查看其战斗分析。"], 1, 0.82, 0, true)
                GameTooltip:Show()
            end)
            bt:SetScript("OnLeave", GameTooltip_Hide)
        end

        -- 重置按钮
        do
            local bt = CreateFrame("Button", nil, TJ.raidChild)
            bt:SetSize(18, 18)
            bt:SetPoint("TOPRIGHT", TJ.raidChild, "BOTTOMRIGHT", 0, 0)
            bt:SetNormalTexture("interface/raidframe/readycheck-notready")
            bt:SetHighlightTexture("interface/raidframe/readycheck-notready")
            bt:RegisterForClicks("AnyUp")
            TJ.raidChild.resetButton = bt
            bt:SetScript("OnClick", function(self, button)
                TJ.PlaySound(1)
                if button == "LeftButton" then
                    TJ.ClearBoss()
                elseif button == "RightButton" then
                    local FB = TuanJian.FB
                    for bossIndex in ipairs(TJ.FBinfo[FB]) do
                        TJ.ClearBoss(FB, bossIndex)
                    end
                end
            end)
            bt:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine(L["重置任务/减伤链/站位图"], 1, 1, 1, true)
                GameTooltip:AddLine(AddTexture("LEFT") .. L["重置当前BOSS"], 1, .82, 0, true)
                GameTooltip:AddLine(AddTexture("RIGHT") .. L["重置所有BOSS"], 1, .82, 0, true)
                GameTooltip:Show()
            end)
            bt:SetScript("OnLeave", GameTooltip_Hide)
        end
    end

    -- 选择日志
    do
        local dropDown = LibBG:Create_UIDropDownMenu(nil, TJ.raidMainFrame)
        dropDown:SetPoint("BOTTOMLEFT", TJ.raidChild, "TOPLEFT", -15, -5)
        LibBG:UIDropDownMenu_SetWidth(dropDown, 180)
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
        dropDown.Text:SetJustifyH("LEFT")
        dropDown:SetScale(.85)
        TJ.dropDownToggle(dropDown)
        TJ.logDropDown = dropDown

        function dropDown:FormatText(v, i)
            return format("%s%s |cff808080(%s)|r",
                i and i .. L["、"] or "",
                date("%H:%M:%S", v.time),
                TJ.SecondsToTime(v.duration))
        end

        LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
            local logs = {}
            for _, v in ipairs(TuanJian.combatLog) do
                if v.FB == TuanJian.FB and v.bossIndex == TuanJian.bossIndex then
                    tinsert(logs, { time = v.time, duration = v.duration })
                end
            end
            if not TJ.lastChooseLog and next(logs) then
                TJ.lastChooseLog = logs[1].time
            end
            for i, v in ipairs(logs) do
                local info = LibBG:UIDropDownMenu_CreateInfo()
                local text = dropDown:FormatText(v, i)
                info.text = text
                info.func = function()
                    TJ.lastChooseLog = v.time
                    LibBG:UIDropDownMenu_SetText(dropDown, text)
                    TJ.LoadCombatLog()
                end
                info.checked = TJ.lastChooseLog == v.time
                LibBG:UIDropDownMenu_AddButton(info)
            end
        end)

        function TJ.UpdateLogDropDown()
            local logs = {}
            for _, v in ipairs(TuanJian.combatLog) do
                if v.FB == TuanJian.FB and v.bossIndex == TuanJian.bossIndex then
                    tinsert(logs, { time = v.time, duration = v.duration })
                end
            end
            if #logs > 0 then
                dropDown:Show()
                local yes
                if TJ.lastChooseLog then
                    for i, v in ipairs(logs) do
                        if v.time == TJ.lastChooseLog then
                            yes = true
                            LibBG:UIDropDownMenu_SetText(dropDown, dropDown:FormatText(v, #logs > 1 and i))
                            break
                        end
                    end
                end
                if not yes then
                    if #logs > 1 then
                        TJ.lastChooseLog = logs[1].time
                    end
                    LibBG:UIDropDownMenu_SetText(dropDown, dropDown:FormatText(logs[1], #logs > 1 and 1))
                end
                if #logs == 1 then
                    LibBG:UIDropDownMenu_DisableDropDown(dropDown)
                    dropDown:SetAlpha(.6)
                else
                    LibBG:UIDropDownMenu_EnableDropDown(dropDown)
                    dropDown:SetAlpha(1)
                end
            else
                dropDown:Hide()
            end
        end

        After(0, TJ.UpdateLogDropDown)
    end

    -- 副本切换
    do
        local CreateNextBossButton
        do
            local nextBossMixin = {}
            local function GetNextBossButton(self)
                for i, v in ipairs(self.buttons) do
                    if v.bossIndex == TuanJian.bossIndex then
                        if self.buttons[i + 1] then
                            return self.buttons[i + 1].bt
                        else
                            return self.buttons[1].bt
                        end
                    end
                end
            end
            function nextBossMixin:OnEnter()
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                GameTooltip:ClearLines()
                GameTooltip:AddLine(L["切换到下一个BOSS"], 1, 1, 1, true)
                local bt = GetNextBossButton(self)
                GameTooltip:AddLine(format("%s. %s", bt.bossIndex, bt.bossName), 1, .82, 0, true)
                GameTooltip:Show()
            end

            function nextBossMixin:OnLeave()
                GameTooltip_Hide()
            end

            function nextBossMixin:OnClick()
                GetNextBossButton(self):Click()
                self:GetScript("OnEnter")(self)
            end

            function CreateNextBossButton(lastButton, buttons)
                local bt = CreateFrame("Button", nil, lastButton)
                bt:SetSize(25, 25)
                bt:SetNormalTexture("interface/buttons/ui-spellbookicon-nextpage-up")
                bt:SetPushedTexture("interface/buttons/ui-spellbookicon-nextpage-down")
                bt:SetHighlightTexture("Interface/Buttons/UI-Common-MouseHilight")
                bt:SetPoint("LEFT", lastButton, "RIGHT", 0, 0)
                bt.buttons = buttons
                TJ.SetMixin(bt, nextBossMixin)
            end
        end
        function TJ.UpdateBossChooseFrame(FB)
            local onlyLoad = FB
            if not onlyLoad then
                for _, f in pairs(TJ.tabFrame) do
                    f:Hide()
                end
                for _, v in pairs(TJ.FBtbl) do
                    if TuanJian.FB == v.FB then
                        LibBG:UIDropDownMenu_SetText(TJ.FBDropDown, v.localName)
                        break
                    end
                end
            end
            local FB = FB or TuanJian.FB
            if not TJ.tabFrame[FB] then
                TJ.frame[FB] = {}
                local f = CreateFrame("Frame", nil, TJ.raidMainFrame, "BackdropTemplate")
                f:SetPoint("LEFT", TJ.FBDropDown, "RIGHT", 0, 0)
                f:SetSize(1, 30)
                f:Hide()
                TJ.tabFrame[FB] = f
                local last
                local buttons = {}
                for bossIndex, v in ipairs(TJ.FBinfo[FB]) do
                    if not v.hide then
                        TJ.LoadBoss(FB, bossIndex, true)

                        local bt = CreateFrame("Button", nil, f)
                        bt:SetNormalFontObject(TJ.FontBlue15)
                        bt:SetDisabledFontObject(TJ.FontWhite15)
                        bt:SetHighlightFontObject(TJ.FontWhite15)
                        bt:SetSize(25, f:GetHeight())
                        bt:SetHighlightTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")
                        bt:SetText(bossIndex)
                        bt.bossIndex = bossIndex
                        bt.bossName = v.name
                        if not last then
                            bt:SetPoint("LEFT", -5, 2)
                        else
                            bt:SetPoint("LEFT", TJ.tabFrame[FB][last], "RIGHT", 0, 0)
                        end
                        TJ.tabFrame[FB][bossIndex] = bt
                        last = bossIndex
                        bt:SetScript("OnEnter", function(self)
                            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                            GameTooltip:ClearLines()
                            GameTooltip:AddLine(v.name, 1, 1, 1, true)
                            if v.notFinish then
                                GameTooltip:AddLine(L["施工中...请等待后续更新"], 1, 0, 0, true)
                            end
                            GameTooltip:Show()
                        end)
                        bt:SetScript("OnLeave", GameTooltip_Hide)
                        bt:SetScript("OnClick", function(self)
                            TJ.UpdateBossFrame(bossIndex)
                            TJ.PlaySound(1)
                        end)
                        tinsert(buttons, { bossIndex = bossIndex, bt = bt })

                        if #TJ.FBinfo[FB] > 1 and bossIndex == #TJ.FBinfo[FB] then
                            CreateNextBossButton(bt, buttons)
                        end
                    end
                end
            end
            if not onlyLoad then
                TJ.tabFrame[FB]:Show()
            end
        end

        function TJ.LoadCombatLog(FB, bossIndex)
            FB = TuanJian.FB
            bossIndex = TuanJian.bossIndex
            TJ.combatLogIndex = nil
            local logs = {}
            for i, v in ipairs(TuanJian.combatLog) do
                if v.FB == FB and v.bossIndex == bossIndex then
                    tinsert(logs, { log = v, logIndex = i })
                end
            end
            if #logs > 1 then
                local yes
                if TJ.lastChooseLog then
                    for i, v in ipairs(logs) do
                        if v.log.time == TJ.lastChooseLog then
                            TJ.combatLogIndex = v.logIndex
                            yes = true
                            break
                        end
                    end
                end
                if not yes then
                    TJ.combatLogIndex = logs[1].logIndex
                end
            elseif #logs == 1 then
                TJ.combatLogIndex = logs[1].logIndex
            end

            TJ.UpdateLogDropDown()
            TJ.DeCompressCombatEvents(FB, bossIndex) -- 解压日志战斗事件

            if TJ.combatFrame then
                TJ.combatFrame:Hide()
            end

            After(0, function()
                TJ.UpdateTitleColor()
            end)
        end

        function TJ.LoadBoss(FB, bossIndex, hide)
            if not TJ.frame[FB][bossIndex] then
                local f = CreateFrame("Frame", nil, TJ.tabFrame[FB])
                if hide then
                    f:Hide()
                end
                TJ.frame[FB][bossIndex] = f
                if TJ.Load[FB .. bossIndex] then
                    TJ.Load[FB .. bossIndex]()
                    if ns.tt then
                        TJ.frame[FB][bossIndex].saveAura = TJ.frame[FB][bossIndex].saveAura or {}
                        for _, spellID in ipairs(ns.tt) do
                            TJ.frame[FB][bossIndex].saveAura[spellID] = true
                        end
                    end
                end
                f:SetScript("OnShow", function(self)
                    TJ.UpdateEditIcon()
                    TJ.UpdateEditIcon_Board()
                    TJ.UpdateSpecialEdit()
                    TJ.ReSetCombatFrame()
                    TJ.LoadCombatLog(FB, bossIndex)
                end)
            end
        end

        TJ.UpdateBossChooseFrame()

        TJ.RegisterEvent("RAID_INSTANCE_WELCOME", function(_, _, mapname, timeLeft, locked, extended)
            After(2, function()
                local instanceID = select(8, GetInstanceInfo())
                for i, v in ipairs(TJ.FBtbl) do
                    if v.ID == instanceID and v.FB ~= TuanJian.FB then
                        TuanJian.FB = v.FB
                        TJ.UpdateBossChooseFrame()
                        TJ.UpdateBossFrame(1)
                        return
                    end
                end
            end)
        end)
    end

    -- BOSS选择
    do
        function TJ.UpdateBossFrame(bossIndex)
            if TJ.lastFrame then
                TJ.lastFrame:Hide()
            end
            local FB = TuanJian.FB
            if not TJ.FBinfo[TuanJian.FB][bossIndex] then
                bossIndex = 1
            end
            TuanJian.bossIndex = bossIndex
            TuanJian[FB].lastBoss = bossIndex
            for i, bt in pairs(TJ.tabFrame[FB]) do
                if type(i) == "number" and i > 0 then
                    bt:Disable()
                end
            end
            After(.5, function()
                for i, bt in pairs(TJ.tabFrame[FB]) do
                    if type(i) == "number" and i > 0 then
                        if bossIndex == i then
                            bt:Disable()
                        else
                            bt:Enable()
                        end
                    end
                end
            end)
            TJ.UpdateMainFrameSize()
            TJ.bossNameText:SetText(TJ.FBinfo[FB][bossIndex].name)
            TJ.bossNameText.owner:SetWidth(TJ.bossNameText:GetWidth())
            TJ.frame[FB][bossIndex]:Show()
            TJ.lastFrame = TJ.frame[FB][bossIndex]
            TJ.spChild:UpdateSize()
            TJ.PairAllMap(function(map)
                map:ShowOrHide()
            end)
            TJ.UpdateDispelButton()
            if TJ.exportTJButton_UpdateShow then
                TJ.exportTJButton_UpdateShow()
            end
        end

        TJ.UpdateBossFrame(TuanJian.bossIndex)
    end

    -- 通报
    do
        local bar
        function TJ.StartWhisper(t, playerTbl)
            if TuanJian.options.sendWhisper == 1 then
                After(t, function()
                    local newTbl = {}
                    for i, v in ipairs(playerTbl) do
                        if (BGDEBUG or v.player ~= player) and UnitInRaid(v.player) then
                            if not newTbl[v.player] then
                                newTbl[v.player] = v.quest
                            else
                                newTbl[v.player] = newTbl[v.player] .. L["，"] .. v.quest
                            end
                        end
                    end
                    local maxCount = ns.Size(newTbl)
                    if maxCount ~= 0 then
                        bar:Start(maxCount)
                        local t = 0
                        local count = 0
                        for player, quest in pairs(newTbl) do
                            After(t, function()
                                count = count + 1
                                local msg = format(L["通知: 你的任务=>%s"], quest)
                                SendChatMessage(msg, "WHISPER", nil, TJ.GFN(player))
                                bar:SetValue(count)
                                bar.rightText:SetText(format("%s/%s", count, maxCount))
                                if count == maxCount then
                                    After(1, function()
                                        bar:AlphaHide()
                                    end)
                                end
                            end)
                            t = t + 0.5
                        end
                    end
                end)
            end
        end

        local function Ban(self, event, msg, _, l, cs, t, flag, channelId, ...)
            if TuanJian.options.banSendWhisper == 1 then
                if msg:find(L["通知: 你的任务=>"]) then
                    if event ~= "CHAT_MSG_WHISPER" or t == player then
                        return true
                    end
                end
            end
        end
        ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Ban)
        ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Ban)

        local bt = TJ.CreateButton(TJ.raidMainFrame)
        bt:SetSize(100, 25)
        bt:SetPoint("BOTTOM", TJ.MainFrame, "BOTTOM", 0, 20)
        bt:SetText(L["通报任务"])
        TJ.sendButton = bt
        bt:SetScript("OnClick", function(self)
            if not IsInRaid(1) then return end
            if self.isdoing then return end
            self.isdoing = true
            After(2, function() self.isdoing = nil end)
            local tbl, playerTbl = self.GetAllQuestText()
            if next(tbl[1]) then
                if TJ.raidMainFrame:IsVisible() then
                    tinsert(tbl, 1, { L["——通报任务安排——"] })
                elseif TJ.tjMainFrame:IsVisible() then
                    tinsert(tbl, 1, { L["——通报团减安排——"] })
                elseif TJ.ssMainFrame:IsVisible() then
                    tinsert(tbl, 1, { L["——通报灵魂石任务——"] })
                elseif TJ.dpsMainFrame:IsVisible() then
                    tinsert(tbl, 1, { L["——通报增伤安排——"] })
                elseif TJ.buffMainFrame:IsVisible() then
                    tinsert(tbl, 1, { L["——通报BUFF任务——"] })
                elseif TJ.gjMainFrame:IsVisible() then
                    tinsert(tbl, 1, { L["——通报个减任务——"] })
                end
                if #tbl > 5 then
                    tinsert(tbl, { L["—感谢使用TuanJian插件—"] })
                end
                local t = TJ.SendMsgToRaid(tbl)
                TJ.StartWhisper(t, playerTbl)
                TJ.PlaySound(2)
            end
        end)
        TJ.OnEnterDelay(bt, function(self)
            local tbl = self.GetAllQuestText(true)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            if not IsInRaid(1) then
                GameTooltip:AddLine(L["只有在团队中才能通报。"], 1, 0, 0, true)
            end
            if tbl[1] and next(tbl[1]) then
                for _, v in ipairs(tbl) do
                    for _, text in ipairs(v) do
                        GameTooltip:AddLine(TJ.GsubRaidTargetingIcons(text), 1, 0.82, 0)
                    end
                end
            else
                GameTooltip:AddLine(L["任务是空的。"], 1, 0, 0, true)
            end
            GameTooltip:Show()
        end)
        TJ.OnLeaveDelay(bt)

        function bt:UpdateParent(parent)
            if parent ~= TJ.raidTargetMainFrame and parent ~= TJ.optionMainFrame and parent ~= TJ.equipMainFrame then
                self:SetParent(parent)
                if parent == TJ.buffMainFrame then
                    self.GetAllQuestText = TJ.GetAllQuestText_Buff
                else
                    self.GetAllQuestText = TJ.GetAllQuestText
                end
            end
        end

        -- 密语进度条
        do
            bar = CreateFrame("StatusBar", nil, UIParent, "BackdropTemplate")
            bar:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 2,
            })
            bar:SetBackdropColor(0, 0, 0, 0.8)
            bar:SetBackdropBorderColor(0, 0, 0, 1)
            bar:SetPoint("TOP", 0, -200)
            bar:SetSize(300, 30)
            bar:SetFrameStrata("HIGH")
            bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
            bar:SetStatusBarColor(1, 1, 0, 1)
            bar:SetToplevel(true)
            bar:SetMovable(true)
            bar:Hide()
            bar:SetScript("OnMouseUp", function(self)
                self:StopMovingOrSizing()
            end)
            bar:SetScript("OnMouseDown", function(self)
                self:StartMoving()
            end)
            function bar:Start(maxCount)
                bar:Show()
                bar:SetAlpha(1)
                bar:SetMinMaxValues(0, maxCount)
            end

            function bar:AlphaHide()
                bar.t = 1
                bar:SetScript("OnUpdate", function(self, t)
                    self.t = self.t - t
                    if self.t <= 0 then
                        self:SetScript("OnUpdate", nil)
                        self:Hide()
                    else
                        self:SetAlpha(self.t)
                    end
                end)
            end

            local t = bar:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("LEFT", 10, 0)
            t:SetTextColor(1, 1, 1)
            t:SetText(L["密语发送中"])

            local t = bar:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("RIGHT", -10, 0)
            t:SetTextColor(1, 1, 1)
            bar.rightText = t
        end
    end

    -- 一键安排
    do
        local bt = TJ.CreateButton(TJ.raidMainFrame)
        bt:SetSize(100, 25)
        bt:SetPoint("RIGHT", TJ.sendButton, "LEFT", -20, 0)
        bt:SetText(L["一键安排"])
        TJ.autoButton = bt
        bt:SetScript("OnClick", function(self)
            if not IsInRaid(1) then return end
            TJ.PlaySound(1)
            if TJ.buffMainFrame:IsVisible() then
                TJ.SetAutoChoose_Buff()
            elseif TJ.raidTargetMainFrame:IsVisible() then
                TJ.raidTargetMainFrame.SetAutoChoose()
            elseif TJ.tjMainFrame:IsVisible() and TJ.IsMOP then
                TJ.tjMainFrame.SetAutoChoose()
            elseif TJ.equipMainFrame:IsVisible() then
                self:SetEnabled(false)
                if TJ.StartMoveTeam then
                    TJ.StartMoveTeam()
                else
                    self:SetEnabled(true)
                end
            else
                TJ.SetAutoChoose()
            end
        end)
        TJ.OnEnterDelay(bt, function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            if not TJ.equipMainFrame:IsVisible() then
                GameTooltip:AddLine(L["根据团员的天赋/职责和以下原则自动安排全部任务。如果安排不正确，请点击更新天赋按钮。"], 1, 0.82, 0, true)
                if not IsInRaid(1) then
                    GameTooltip:AddLine(L["只有在团队中才能一键安排。"], 1, 0, 0, true)
                end
            end

            if TJ.buffMainFrame:IsVisible() then
                GameTooltip:Show()
                return
            elseif TJ.raidTargetMainFrame:IsVisible() then
                GameTooltip:AddLine(" ", 1, 0.82, 0, true)
                for i, text in ipairs(TJ.raidTargetMainFrame:GetAutoText()) do
                    GameTooltip:AddLine(text, 1, .82, 0, true)
                end
                GameTooltip:Show()
                return
            elseif TJ.equipMainFrame:IsVisible() then
                local chooseInfo = TJ.autoSetTeamChooseInfo
                if chooseInfo then
                    GameTooltip:AddLine(L['当前调队方案：'] .. chooseInfo[TuanJian.options.autoSetTeam or 1], 1, .82, 0, true)
                end
                if not IsInRaid(1) then
                    GameTooltip:AddLine(L["只有在团队中才能使用。"], 1, 0, 0, true)
                end
                if not TJ.IsLeader() then
                    GameTooltip:AddLine(L["你不是团长或助理，该功能无法使用。"], 1, 0, 0, true)
                end
                if InCombatLockdown() then
                    GameTooltip:AddLine(L["战斗中，该功能无法使用。"], 1, 0, 0, true)
                end
                if GetNumGroupMembers() > 30 then
                    GameTooltip:AddLine(L["团队人数超过30人，该功能无法使用。"], 1, 0, 0, true)
                end
                GameTooltip:Show()
                return
            end
            GameTooltip:AddLine(" ", 1, 0.82, 0, true)
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            if TJ.tjMainFrame:IsVisible() then
                if TJ.IsMOP then
                    local tbl = {
                        all = L["全部"],
                        mage = L["魔法"],
                        physics = L["物理"],
                    }
                    GameTooltip:AddLine(format(L["当前团减类型：|cffffffff%s"], tbl[TuanJian.MOPTJ.type]), 1, .82, 0, true)
                    GameTooltip:AddLine(format(L["当前团减轮数：|cffffffff%s"], TuanJian.MOPTJ.num), 1, .82, 0, true)
                    GameTooltip:Show()
                    return
                end
                FB = "TJ"
                bossIndex = 1
            elseif TJ.ssMainFrame:IsVisible() then
                FB = "SS"
                bossIndex = 1
            elseif TJ.dpsMainFrame:IsVisible() then
                FB = "DPS"
                bossIndex = 1
            elseif TJ.gjMainFrame:IsVisible() then
                FB = "GJ"
                bossIndex = 1
            end
            local parent = TJ.frame[FB][bossIndex]
            local board = parent.board
            if board then
                GameTooltip:AddLine(L["|cffffffff减伤链：|r"] .. L["根据当前阵容安排合适的减伤顺序。"], 1, .82, 0, true)
            end
            for i, v in ipairs(parent.all) do
                local icon = v.title.icon
                local titleName = v.titleName
                local autoText = v.title.autoText
                if autoText then
                    if type(autoText) == "string" then
                        GameTooltip:AddLine(AddTexture(icon) .. TJ.STC_w1(titleName .. L["："]) .. autoText, 1, 0.82, 0, true)
                    else
                        GameTooltip:AddLine(AddTexture(icon) .. TJ.STC_w1(titleName .. L["："]))
                        for i, text in ipairs(autoText) do
                            GameTooltip:AddLine(text, 1, 0.82, 0, true)
                        end
                    end
                end
            end
            GameTooltip:Show()
        end)
        TJ.OnLeaveDelay(bt)

        function bt:UpdateParent(parent)
            if parent ~= TJ.optionMainFrame then
                self:SetParent(parent)
            end
            self:ClearAllPoints()
            if parent == TJ.raidTargetMainFrame then
                self:SetWidth(100)
                self:SetText(L["一键安排"])
                self:SetPoint("RIGHT", parent.startButton, "LEFT", -40, 0)
            elseif parent == TJ.equipMainFrame then
                self:SetWidth(100)
                self:SetText(L["一键调队"])
                self:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOM", -70, 20)
            else
                self:SetWidth(100)
                self:SetText(L["一键安排"])
                self:SetPoint("RIGHT", TJ.sendButton, "LEFT", -20, 0)
            end
        end
    end

    -- 天赋按钮
    do
        local bt = TJ.CreateButton(TJ.raidMainFrame)
        bt:SetSize(100, 25)
        bt:SetPoint("LEFT", TJ.sendButton, "RIGHT", 20, 0)
        bt:SetText(L["更新天赋"])
        TJ.talentButton = bt
        bt:SetScript("OnClick", function(self)
            if self.isdoing then return end
            self.isdoing = true
            After(2, function() self.isdoing = nil end)
            TJ.PlaySound(1)
            TJ.GetTalentInfo(true)
        end)
        TJ.OnEnterDelay(bt, function(self)
            self:ShowRaidMember()
            self.isOnEnter = true
        end)
        TJ.OnLeaveDelay(bt, function(self)
            if self.raidMemberFrame then
                self.raidMemberFrame:Hide()
            end
            self.isOnEnter = nil
            GameTooltip:Hide()
        end)

        function bt:ShowRaidMember()
            if TJ.equipMainFrame:IsVisible() then return end

            if not self.raidMemberFrame then
                local mainFrame = CreateFrame("Frame", nil, self, "BackdropTemplate")
                mainFrame:SetBackdrop({
                    bgFile = "Interface/ChatFrame/ChatFrameBackground",
                    edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                    edgeSize = 1,
                })
                mainFrame:SetBackdropColor(0, 0, 0, .9)
                mainFrame:SetBackdropBorderColor(1, 1, 1, .8)
                mainFrame:SetSize(405, 295)
                mainFrame:SetPoint("BOTTOM", self, "TOP", 0, 5)
                mainFrame:SetFrameLevel(150)
                mainFrame:Hide()
                mainFrame.buttons = {}
                self.raidMemberFrame = mainFrame

                local function CreateRaidButton(i)
                    local f = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
                    f:SetBackdrop({
                        bgFile = "Interface/ChatFrame/ChatFrameBackground",
                        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                        edgeSize = 1,
                    })
                    f:SetBackdropColor(0, 0, 0, .2)
                    f:SetBackdropBorderColor(1, 1, 1, .2)
                    f:SetSize(90, 22)
                    if i == 1 then
                        f:SetPoint("TOPLEFT", 15, -25)

                        local text = f:CreateFontString()
                        text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
                        text:SetPoint("BOTTOM", f, "TOP", 0, 2)
                        text:SetText(1)
                        text:SetTextColor(.5, .5, .5)
                    elseif i == 21 then
                        f:SetPoint("TOPLEFT", mainFrame.buttons[5], "BOTTOMLEFT", 0, -30)

                        local text = f:CreateFontString()
                        text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
                        text:SetPoint("BOTTOM", f, "TOP", 0, 2)
                        text:SetText((i - 1) / 5 + 1)
                        text:SetTextColor(.5, .5, .5)
                    elseif (i - 1) % 5 == 0 then
                        f:SetPoint("TOPLEFT", mainFrame.buttons[i - 5], "TOPRIGHT", 5, 0)

                        local text = f:CreateFontString()
                        text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
                        text:SetPoint("BOTTOM", f, "TOP", 0, 2)
                        text:SetText((i - 1) / 5 + 1)
                        text:SetTextColor(.5, .5, .5)
                    else
                        f:SetPoint("TOPLEFT", mainFrame.buttons[i - 1], "BOTTOMLEFT", 0, -1)
                    end
                    tinsert(mainFrame.buttons, f)

                    local tex = f:CreateTexture()
                    tex:SetPoint("LEFT", 2, 0)
                    tex:SetSize(15, 15)
                    f.talent = tex

                    local text = f:CreateFontString()
                    text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
                    text:SetPoint("LEFT", f.talent, "RIGHT", 0, 0)
                    text:SetWidth(f:GetWidth() - f.talent:GetWidth() - 5)
                    text:SetJustifyH("LEFT")
                    text:SetWordWrap(false)
                    f.nameText = text

                    local tex = f:CreateTexture(nil, "OVERLAY")
                    tex:SetPoint("CENTER", f, "TOPLEFT", 2, -2)
                    tex:SetSize(10, 10)
                    f.icon = tex
                end

                for i = 1, 40 do
                    CreateRaidButton(i)
                end
            end

            local mainFrame = self.raidMemberFrame
            mainFrame:Show()
            for i = 1, 40 do
                local bt = mainFrame.buttons[i]
                bt.nameText:SetText("")
                bt.icon:SetTexture(nil)
                bt.talent:SetTexture(nil)
                bt.talent:SetAtlas(nil)
                bt.talent:SetTexCoord(0, 1, 0, 1)
            end

            for i, v in ipairs(TJ.raidRosterInfo) do
                local team = v.subgroup
                local num
                for ii = (team - 1) * 5 + 1, team * 5 do
                    local bt = mainFrame.buttons[ii]
                    local text = bt.nameText:GetText()
                    if not text or text == "" then
                        num = ii
                        break
                    end
                end
                local bt = mainFrame.buttons[num]
                local name = v.name
                local color = "ffFFFFFF"
                if v.class then
                    color = select(4, GetClassColor(v.class))
                end
                bt.nameText:SetText("|c" .. color .. name)
                if v.rank == 2 then
                    bt.icon:SetTexture("interface/groupframe/ui-group-leadericon")
                elseif v.role == "MAINTANK" then
                    bt.icon:SetTexture(132064)
                elseif v.role == "MAINASSIST" then
                    bt.icon:SetTexture(132063)
                elseif v.rank == 1 then
                    bt.icon:SetTexture("interface/groupframe/ui-group-assistanticon")
                end

                local talent = TuanJian.talentInfo[name]
                if talent then
                    bt.talent:SetTexture(TJ.talentIcon[v.class][talent])
                    bt.talent:SetTexCoord(unpack(TJ.iconTexCoord))
                else
                    if v.combatRole == "TANK" then
                        bt.talent:SetAtlas("ui-lfg-roleicon-tank")
                    elseif v.combatRole == "HEALER" then
                        bt.talent:SetAtlas("ui-lfg-roleicon-healer")
                    elseif v.combatRole == "DAMAGER" then
                        bt.talent:SetAtlas("ui-lfg-roleicon-dps")
                    end
                end
            end
        end

        function bt:UpdateParent(parent)
            self:Show()
            if parent ~= TJ.optionMainFrame then
                self:SetParent(parent)
            end
            self:ClearAllPoints()
            if parent == TJ.raidTargetMainFrame then
                self:SetPoint("LEFT", parent.startButton, "RIGHT", 20, 0)
            elseif parent == TJ.equipMainFrame then
                self:SetPoint("BOTTOMLEFT", TJ.MainFrame, "BOTTOM", 70, 20)
            else
                self:SetPoint("LEFT", TJ.sendButton, "RIGHT", 20, 0)
            end
        end
    end

    -- 读取天赋
    do
        local talentUpdateFrame = CreateFrame("Frame")
        local canInspect
        local num = 1
        local equipDelay = 0.2

        local function InspectFrameIsShow()
            return InspectFrame and InspectFrame:IsVisible()
        end

        function TJ.GetTalentInfo(OnClick)
            if IsInRaid(1) and not InCombatLockdown()
            -- and not BGDEBUG
            then
                if OnClick then
                    TJ.talentButton:SetText(L["正在更新"])
                    if InspectFrame then
                        HideUIPanel(InspectFrame)
                    end
                else
                    if InspectFrameIsShow() then return end
                end
                ClearInspectPlayer()
                local updateTime = 1.5
                local i, add
                if num == 1 then
                    i = 0
                    add = 1
                else
                    i = 41
                    add = -1
                end
                num = (num + 1) % 2
                TJ.talentButton.isUpdating = true
                talentUpdateFrame:SetScript("OnUpdate", nil)
                talentUpdateFrame.t = updateTime
                talentUpdateFrame:SetScript("OnUpdate", function(self, t)
                    self.t = self.t + t
                    if self.t >= updateTime then
                        i = i + add
                        if InCombatLockdown() or InspectFrameIsShow() or i < 1 or i > 40 then
                            self:SetScript("OnUpdate", nil)
                            After(1, function()
                                TJ.talentButton.isUpdating = nil
                                TJ.talentButton:SetText(L["更新天赋"])
                            end)
                            return
                        else
                            local unit = "raid" .. i
                            if UnitName(unit) then
                                if CheckInteractDistance(unit, 1) then
                                    self.t = 0
                                    NotifyInspect(unit)
                                else
                                    self.t = updateTime
                                end
                            end
                        end
                    end
                end)
            end
        end

        local function UpdateEditTalent(lastUpdatePlayer)
            TJ.PairAllEdit(function(edit)
                if edit.player == lastUpdatePlayer then
                    local talent = TuanJian.talentInfo[lastUpdatePlayer]
                    edit.talent = talent
                    edit:SetText(AddTexture(TJ.talentIcon[edit.class][talent]) .. lastUpdatePlayer)
                end
            end)
            if TJ.PairAllEdit_Buff then
                TJ.PairAllEdit_Buff(function(edit)
                    if edit.player == lastUpdatePlayer then
                        local talent = TuanJian.talentInfo[lastUpdatePlayer]
                        edit.talent = talent
                        edit:SetText(AddTexture(TJ.talentIcon[edit.class][talent]) .. lastUpdatePlayer)
                    end
                end)
            end
            TJ.PairAllEdit_BoardPlayer(function(edit)
                if edit.player == lastUpdatePlayer then
                    local talent = TuanJian.talentInfo[lastUpdatePlayer]
                    edit.talent = talent
                    edit:SetText(AddTexture(TJ.talentIcon[edit.class][talent]) .. lastUpdatePlayer)
                end
            end)
        end

        local matchStr = ITEM_LEVEL:gsub("%%d", "(%%d+)")
        local function GetMOPLevel(unit, slot, level)
            if TJ.IsMOP then
                TuanJianTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                TuanJianTooltip:ClearLines()
                TuanJianTooltip:SetInventoryItem(unit, slot)
                for i = 1, 5 do
                    local text = _G["TuanJianTooltipTextLeft" .. i]:GetText()
                    if text then
                        local level = tonumber(text:match(matchStr))
                        if level then
                            return level
                        end
                    end
                end
            end
            return level
        end

        local slots = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }
        local function GetAllLink(unit, name)
            local itemCount = 0
            for _, slot in ipairs(slots) do
                local icon = GetInventoryItemTexture(unit, slot)
                itemCount = itemCount + (icon and 1 or 0)
            end
            local links = {}
            for _, slot in ipairs(slots) do
                local link = GetInventoryItemLink(unit, slot)
                if link then
                    tinsert(links, { slot = slot, link = link })
                end
            end
            if itemCount == #links then
                for _, v in ipairs(links) do
                    local slot = v.slot
                    local link = v.link
                    local _, _, quality, level = GetItemInfo(link)
                    level = GetMOPLevel(unit, slot, level)
                    TuanJian.itemInfo[name][slot] = {
                        link = link,
                        itemID = ns.GetItemID(link),
                        level = level,
                        quality = quality,
                    }
                end
                return true
            end
        end
        local function DoCallbacks(callbacks, name)
            for _, callback in pairs(callbacks) do
                callback(name)
            end
        end
        local function GetRaidMemberItemInfo(name, index, guid, callbacks)
            if not index then return end
            local unit = "raid" .. index
            TuanJian.itemInfo[name] = {}
            if GetAllLink(unit, name) then
                DoCallbacks(callbacks, name)
            else
                After(equipDelay, function()
                    if UnitGUID(unit) == guid then
                        if GetAllLink(unit, name) then
                            DoCallbacks(callbacks, name)
                        else
                            After(equipDelay, function()
                                if UnitGUID(unit) == guid then
                                    if GetAllLink(unit, name) then
                                        DoCallbacks(callbacks, name)
                                    end
                                end
                            end)
                        end
                    end
                end)
            end
        end

        local cd = {}
        local function UpdateTargetCombatRole(name)
            if not (TuanJian.options.autoSetRaidCombatRole == 1 and TJ.ImLeader) then return end
            if InCombatLockdown() then return end
            if cd[name] then return end
            local role = UnitGroupRolesAssigned(name)
            local talent = TuanJian.talentInfo[name]
            local class = select(2, UnitClass(name))
            if talent and class then
                local yesRole = TJ.talentToCombatRole[class] and TJ.talentToCombatRole[class][talent].role
                if yesRole and yesRole ~= role then
                    cd[name] = true
                    After(2, function()
                        cd[name] = nil
                    end)
                    ns.SendSystemMessage(format(L["已把%s的战斗职责修改为正确的职责。"], SetClassCFF(name)))
                    UnitSetRole(name, yesRole)
                end
            end
        end
        local function CheckOtherTalent(name, ii)
            if select(2, UnitClass(name)) == "DEATHKNIGHT" and ii == 1 then -- DPS血DK
                ii = 4
                -- 如果学了大墓地就是DKT，没学就是DPSDK
                for i = 1, 31 do
                    local name, iconTexture, tier, column, rank, maxRank = GetTalentInfo(1, i, true, nil, GetActiveTalentGroup(true))
                    if name and tier == 9 and column == 1 and maxRank > 0 and rank > 0 then
                        ii = 1
                        break
                    end
                end
            elseif select(2, UnitClass(name)) == "PALADIN" and ii == 3 then -- 检查惩戒骑是大牺牲还是光掌
                for i = 1, 31 do
                    local name, iconTexture, tier, column, rank, maxRank = GetTalentInfo(2, i, true, nil, GetActiveTalentGroup(true))
                    if name and tier == 3 and column == 1 and maxRank > 0 and rank > 0 then
                        ii = 4
                        break
                    end
                end
            elseif select(2, UnitClass(name)) == "WARRIOR" and ii == 1 then -- 复仇战
                -- 如果学了强化复仇，就是复仇战
                for i = 1, 31 do
                    local name, iconTexture, tier, column, rank, maxRank = GetTalentInfo(3, i, true, nil, GetActiveTalentGroup(true))
                    if name and tier == 3 and column == 2 and maxRank > 0 and rank > 0 then
                        ii = 3
                        break
                    end
                end
            end
            return ii
        end

        local function SaveInspectTalentTree(name, guid)
            local talents = {}
            local trees = {}
            local talentGroup = GetActiveTalentGroup(true)
            for tab = 1, 3 do
                trees[tab] = select(5, GetTalentTabInfo(tab, true, nil, talentGroup)) or 0
                for index = 1, 31 do
                    local talentName, _, _, _, rank, maxRank = GetTalentInfo(tab, index, true, nil, talentGroup)
                    if talentName and rank and rank > 0 then
                        talents[talentName] = {
                            rank = rank,
                            maxRank = maxRank or 0,
                        }
                    end
                end
            end
            TuanJian.talentTreeInfo[name] = {
                guid = guid,
                class = TJ.raidRosterGUID[guid] and TJ.raidRosterGUID[guid].class,
                updateTime = time(),
                trees = trees,
                talents = talents,
            }
        end

        local tbl = {}
        TJ.RegisterEvent("INSPECT_READY", function(self, event, guid)
            if InCombatLockdown() or not canInspect then return end
            local name = TJ.raidRosterGUID[guid] and TJ.raidRosterGUID[guid].name
            if not (IsInRaid(1) and name) then return end
            local _time = time()
            if tbl[name] and _time - tbl[name] <= 1 then return end
            tbl[name] = _time
            local specIndex
            if TJ.verLess3 then
                local maxNum = 0
                for i = 1, 3 do
                    local num = select(5, GetTalentTabInfo(i, true, nil, GetActiveTalentGroup(true)))
                    if num and num >= maxNum then
                        maxNum = num
                        specIndex = i
                    end
                end
                -- 检查特殊天赋
                if TJ.IsWLK then
                    SaveInspectTalentTree(name, guid)
                    specIndex = CheckOtherTalent(name, specIndex)
                end
            elseif TJ.IsMOP then
                local specID = GetInspectSpecialization(name)
                if specID == 0 then return end
                local classID = select(3, UnitClass(name))
                for i = 1, C_SpecializationInfo.GetNumSpecializationsForClassID(classID) do
                    if GetSpecializationInfoForClassID(classID, i) == specID then
                        specIndex = i
                        break
                    end
                end
            end
            if not specIndex then return end
            TuanJian.talentInfo[name] = specIndex
            UpdateEditTalent(name, specIndex)
            UpdateTargetCombatRole(name)
            GetRaidMemberItemInfo(name, TJ.raidRosterGUID[guid] and TJ.raidRosterGUID[guid].i, guid,
                { TJ.UpdateEquipFrame, TJ.UpdateRaidMemberFrame })
            if TJ.talentButton.isOnEnter then
                TJ.talentButton:ShowRaidMember()
            end
            TJ.UpdateSpecialEdit()
            TJ.UpdateMapIcon()
            TJ.UpdateEditIcon_RaidTarget()
            if TJ.UpdateRaidDamageBuffFrame then
                TJ.UpdateRaidDamageBuffFrame()
            end
        end)

        local updateFrame = CreateFrame("Frame")
        TJ.RegisterEvent("ROLE_CHANGED_INFORM", function(self, event, targetName)
            if TJ.talentButton.isUpdating then return end
            if BGDEBUG then return end
            updateFrame.t = 0
            updateFrame:SetScript("OnUpdate", function(self, t)
                self.t = self.t + t
                if self.t >= 2 then
                    if not InspectFrameIsShow() then
                        NotifyInspect(targetName)
                    end
                    self:SetScript("OnUpdate", nil)
                end
            end)
        end)

        TJ.Init2(function()
            if IsAddOnLoaded("MRT") then
                C_Timer.NewTicker(65, function()
                    if not InCombatLockdown() and not InspectFrameIsShow() then
                        NotifyInspect("player")
                    end
                end)
            else
                C_Timer.NewTicker(65, function()
                    TJ.GetTalentInfo()
                end)
            end
            After(5, TJ.GetTalentInfo)
        end)

        hooksecurefunc("NotifyInspect", function(unit)
            canInspect = true
        end)
        hooksecurefunc("ClearInspectPlayer", function()
            canInspect = false
        end)
    end
end)

-- 团队成员
do
    TJ.raidRosterInfo = {}
    TJ.raidRosterName = {}
    TJ.raidRosterGUID = {}
    TJ.ImLeader = nil
    local updateFrame = CreateFrame("Frame")
    function TJ.UpdateRaidRosterInfo()
        wipe(TJ.raidRosterInfo)
        wipe(TJ.raidRosterName)
        wipe(TJ.raidRosterGUID)
        TJ.ImLeader = nil
        if IsInRaid(1) then
            for i = 1, GetNumGroupMembers(1) do
                local name, rank, subgroup, level, class2, class, zone, online, isDead, role, isML, combatRole =
                    GetRaidRosterInfo(i)
                if name then
                    local guid = UnitGUID("raid" .. i)
                    local v = {
                        name = name,
                        rank = rank,
                        subgroup = subgroup,
                        level = level,
                        class2 = class2,
                        class = class,
                        zone = zone,
                        online = online,
                        isDead = isDead,
                        role = role,
                        isML = isML,
                        combatRole = combatRole,
                        guid = guid,
                    }
                    tinsert(TJ.raidRosterInfo, v)
                    TJ.raidRosterName[name] = i
                    if name == player and rank == 2 then
                        TJ.ImLeader = true
                    end
                    if guid then
                        TJ.raidRosterGUID[guid] = {
                            name = name,
                            class = class,
                            i = i,
                        }
                    end
                end
            end
            if not TJ.raidTargetMainFrame.startButton:IsEnabled() then
                TJ.raidTargetMainFrame.startButton:Enable()
            end
        else
            if TJ.raidTargetMainFrame.startButton:IsEnabled() then
                TJ.raidTargetMainFrame.startButton:Disable()
            end

            wipe(TuanJian.talentInfo)
            wipe(TuanJian.itemInfo)
            if TuanJian.talentTreeInfo then
                wipe(TuanJian.talentTreeInfo)
            end
            TJ.ClearRaidTarget(true)
            if TuanJian.options.autoClear_leaveRaid == 1 then
                TJ.ClearQuest()
                TJ.ClearMap()
                TJ.ClearBoard()
                if TJ.ClearTJ then
                    TJ.ClearTJ()
                end
                if TJ.ClearSS then
                    TJ.ClearSS()
                end
                if TJ.ClearDPS then
                    TJ.ClearDPS()
                end
                if TJ.ClearBuff then
                    TJ.ClearBuff()
                end
                if TJ.ClearGJ then
                    TJ.ClearGJ()
                end
            end
        end
        updateFrame.t = 0
        updateFrame:SetScript("OnUpdate", function(self, t)
            self.t = self.t + t
            if self.t >= .5 then
                self:SetScript("OnUpdate", nil)
                TJ.UpdateEditIcon()
                if TJ.UpdateEditIcon_Buff then
                    TJ.UpdateEditIcon_Buff()
                end
                TJ.UpdateEditIcon_Board()
                TJ.UpdateEditIcon_RaidTarget()
                TJ.UpdateSpecialEdit()
                TJ.UpdateMapIcon()
                TJ.UpdateMapAddon()
                TJ.UpdateRaidMemberFrame()
            end
        end)
    end

    TJ.Init2(function()
        After(1, TJ.UpdateRaidRosterInfo)
    end)
    TJ.RegisterEvent("GROUP_ROSTER_UPDATE", function(self, event, ...)
        After(0.5, function()
            TJ.UpdateRaidRosterInfo()
        end)
    end)
end

-- 插件命令
do
    SlashCmdList["TUANJIAN"] = function()
        TJ.MainFrame:SetShown(not TJ.MainFrame:IsVisible())
    end
    SLASH_TUANJIAN1 = "/tuanjian"
    SLASH_TUANJIAN2 = "/tj"

    SlashCmdList["TUANJIANDPS"] = function()
        TJ.StartSendDPSTips()
    end
    SLASH_TUANJIANDPS1 = "/tjdps"
    SLASH_TUANJIANDPS2 = "/tuanjiandps"
end

-- 鼠标提示工具美化
TJ.Init2(function()
    local color
    if IsAddOnLoaded("NDui") then
        color = { 0, 0, 0, 0.6 }
    elseif IsAddOnLoaded("ElvUI") then
        color = { .05, .05, .05, 0.6 }
    end
    if IsAddOnLoaded("NDui") or IsAddOnLoaded("ElvUI") then
        if TuanJianTooltip2.NineSlice then TuanJianTooltip2.NineSlice:SetAlpha(0) end
        if TuanJianTooltip2.SetBackdrop then TuanJianTooltip2:SetBackdrop(nil) end

        local f = CreateFrame("Frame", nil, TuanJianTooltip2, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        f:SetBackdropColor(unpack(color))
        f:SetBackdropBorderColor(0, 0, 0, 1)
        f:SetAllPoints()
        f:SetFrameLevel(f:GetParent():GetFrameLevel())
    end
end)
