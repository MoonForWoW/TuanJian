local AddonName, ns = ...

local LibBG         = ns.LibBG
local L             = ns.L
local AddTexture    = ns.AddTexture
local Round         = ns.Round
local GetClassRGB   = ns.GetClassRGB

local pt            = print
local After         = C_Timer.After
local BG            = TJ

local realmID       = GetRealmID()
local player        = UnitName("player")

local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded
local LoadAddOn     = LoadAddOn or C_AddOns.LoadAddOn


-- 接收器
TJ.Init2(function()
    TJ.BoardVerFrame = {}
    local BoardBiaoGeVer = "v2.2.4"
    local UpdateBoardVers
    local function GetBiaoGePreviewStatus()
        local BiaoGe = _G.BG
        if not (TJ.IsLoadBiaoGe() and BiaoGe) then
            return nil, "missing"
        end
        if type(BiaoGe.GetVerNum) ~= "function" or type(BiaoGe.ver) ~= "string" or
            type(BiaoGe.MoveBoardReceiver) ~= "function" or type(BiaoGe.OpenMapOptions) ~= "function" then
            return BiaoGe, "outdated"
        end
        local currentOK, currentVer = pcall(BiaoGe.GetVerNum, BiaoGe.ver)
        local requiredOK, requiredVer = pcall(BiaoGe.GetVerNum, BoardBiaoGeVer)
        if not currentOK or not requiredOK or not currentVer or not requiredVer or currentVer < requiredVer then
            return BiaoGe, "outdated"
        end
        return BiaoGe, "supported"
    end

    -- 减伤链接收器UI
    do
        local myVerFrame = CreateFrame("Frame")
        myVerFrame:SetSize(1, 18)
        myVerFrame:Hide()
        TJ.BoardVerFrame.myVerFrame = myVerFrame

        local warning = myVerFrame:CreateFontString(nil, "OVERLAY")
        warning:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
        warning:SetTextColor(1, 0, 0)
        warning:SetJustifyH("CENTER")
        warning:SetText(L["未安装%s插件，减伤链无法生效"]:format(ns.BiaoGeName))
        warning:Hide()
        TJ.BoardVerFrame.missingAddonText = warning
    end

    -- 通报减伤链
    do
        local function GetBoardTypeName(OnEnter)
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            local board = TJ.frame[FB][bossIndex].board
            if board.GetPlanName then return TJ.ClearCode(board:GetPlanName(), nil, OnEnter) end
            local boardID = TuanJian[FB][bossIndex].lastBoard
            local boardType = TJ.ClearCode(board.tabButton[boardID]:GetText(), nil, OnEnter)
            return boardType
        end

        local bt = TJ.CreateButton(TJ.BoardVerFrame.myVerFrame)
        bt:SetPoint("BOTTOMLEFT", TJ.BoardVerFrame.myVerFrame, "BOTTOMLEFT", 0, 2)
        bt:SetText(L["通报减伤链"])
        bt:SetSize(110, 25)
        TJ.BoardVerFrame.sendButton = bt
        bt:SetScript("OnClick", function(self)
            if self.isdoing then return end
            self.isdoing = true
            After(2, function() self.isdoing = nil end)
            TJ.PlaySound(1)
            local tbl = TJ.GetBoardQuestText()
            local tbl, playerTbl = TJ.GetAllQuestText()
            if next(tbl[1]) then
                tinsert(tbl, 1, { format(L["——通报减伤链：%s——"], GetBoardTypeName()) })
                if #tbl > 5 then
                    tinsert(tbl, { L["—感谢使用TuanJian插件—"] })
                end
                local t = TJ.SendMsgToRaid(tbl)
                TJ.StartWhisper(t, playerTbl)
                TJ.PlaySound(2)
            end
        end)
        bt:SetScript("OnEnter", function(self)
            self.isEnter = true
            local tbl = TJ.GetAllQuestText(true)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(format(L["通报减伤链：%s"], GetBoardTypeName(true)), 1, 1, 1, true)
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
                GameTooltip:AddLine(L["减伤链是空的。"], 1, 0, 0, true)
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", function(self)
            self.isEnter = nil
        end)

        function TJ.GetBoardQuestText(OnEnter)
            local tbl = {}
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            local board = TJ.frame[FB][bossIndex].board
            if board.GetQuestText then return board:GetQuestText(OnEnter) end
            local boardID = TuanJian[FB][bossIndex].lastBoard
            local boardType = TJ.ClearCode(board.tabButton[boardID]:GetText(), nil, OnEnter)
            if not OnEnter then
                tinsert(tbl, { format(L["——通报减伤链：%s——"], boardType) })
            else
                tinsert(tbl, { format(L["通报减伤链：%s"], boardType) })
            end
            local yes
            for i, v in ipairs(board.child[boardID].all) do
                local players = {}
                for arrange, vv in pairs(v.edits) do
                    local r, g, b = vv.playerEdit:GetTextColor()
                    local player = vv.playerEdit:GetText()
                    player = ns.RGB_16(player, r, g, b)
                    local player = TJ.ClearCode(player, nil, OnEnter)
                    local link = TJ.ClearCode(vv.spellEdit:GetText(), true, OnEnter)
                    if player ~= "" and link ~= "" then
                        if not players[player] then
                            players[player] = {}
                        end
                        tinsert(players[player], link)
                    end
                end
                if next(players) then
                    local text = ""
                    local first = true
                    for player in pairs(players) do
                        text = text .. (first and "" or " + ") .. player
                        for _, link in pairs(players[player]) do
                            text = text .. link
                        end
                        first = nil
                    end
                    tinsert(tbl, { v.titleName .. text })
                    yes = true
                end
            end
            -- if yes then
            return tbl
            -- end
        end
    end

    -- 测试减伤链
    --[=[     do
        TJ.boardTestFrame = CreateFrame("Frame")

        local bt = TJ.CreateButton(TJ.BoardVerFrame.myVerFrame)
        bt:SetPoint("LEFT", TJ.BoardVerFrame.sendButton, "RIGHT", 10, 0)
        bt:SetText(L["测试"])
        bt:SetSize(60, 25)
        TJ.BoardVerFrame.testButton = bt
        bt:SetScript("OnClick", function(self)
            if self.isdoing then return end
            self.isdoing = true
            After(1, function() self.isdoing = nil end)
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            if IsInRaid(1) and not InCombatLockdown() and TJ.IsLeader() and TJ.frame[FB][bossIndex].Board_test then
                TJ.PlaySound(1)
                if TJ.isBoardTesting then
                    TJ.StopTestBoard()
                else
                    TJ.isBoardTesting = true
                    TJ.BoardVerFrame.testButton:SetText(L["测试中"])
                    ns.SendSystemMessage(L["|cff00ff00已开始测试减伤链。"])
                    TJ.frame[FB][bossIndex].Board_test()
                end
            end
        end)
        bt:SetScript("OnEnter", function(self)
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["测试减伤链"], 1, 1, 1)
            if TJ.frame[FB][bossIndex].Board_test then
                GameTooltip:AddLine(L["需要在团队中、非战斗中、你是团长或助理，才能测试。"], 1, .82, 0, true)
                GameTooltip:AddLine(" ")
                GameTooltip:AddLine(L["测试前需安装好接收器WA、设置好减伤链玩家和技能，否则测试时什么都不会显示。"], 1, .82, 0, true)
            else
                GameTooltip:AddLine(L["该BOSS暂不支持测试减伤链。"], 1, 0, 0, true)
            end
            GameTooltip:Show()
        end)

        bt:SetScript("OnHide", function(self)
            if TJ.isBoardTesting then
                TJ.StopTestBoard()
            end
        end)

        function TJ.StopTestBoard()
            TJ.isBoardTesting = nil
            TJ.BoardVerFrame.testButton:SetText(L["测试"])
            ns.SendSystemMessage(L["|cffff0000已停止测试减伤链。"])
            TJ.Board_ENCOUNTER_END()
            TJ.Board_HideAllBar()
            After(.8, TJ.Board_HideAllBar)
            TJ.boardTestFrame:SetScript("OnUpdate", nil)
        end
    end ]=]

    TJ.boardTestFrame = CreateFrame("Frame")
    function TJ.StopTestBoard()
        TJ.isBoardTesting = nil
        TJ.BoardVerFrame.testButton:SetText(L["预览"])
        ns.SendSystemMessage(L["|cffff0000已停止测试减伤链。"])
        TJ.Board_ENCOUNTER_END()
        TJ.Board_HideAllBar()
        TJ.boardTestFrame:SetScript("OnUpdate", nil)
    end

    -- 预览减伤链进度条
    do
        local bt = TJ.CreateButton(TJ.BoardVerFrame.myVerFrame)
        bt:SetPoint("LEFT", TJ.BoardVerFrame.sendButton, "RIGHT", 5, 0)
        bt:SetText(L["预览"])
        bt:SetSize(50, 25)
        bt:RegisterForClicks("AnyUp")
        TJ.BoardVerFrame.testButton = bt
        bt:SetScript("OnHide", function(self)
            if TJ.isBoardTesting and BGDEBUG then
                TJ.StopTestBoard()
            end
        end)
        bt:SetScript("OnClick", function(self, button)
            if InCombatLockdown() then
                ns.SendSystemMessage(L["战斗中禁止使用减伤链进度条预览。"])
                return
            end
            if button == 'LeftButton' then
                local BiaoGe, status = GetBiaoGePreviewStatus()
                if status == "supported" then
                    BiaoGe.MoveBoardReceiver()
                end
            elseif button == 'RightButton' and BGDEBUG then
                if self.isdoing then return end
                self.isdoing = true
                After(1, function() self.isdoing = nil end)
                local FB = TuanJian.FB
                local bossIndex = TuanJian.bossIndex
                if IsInRaid(1) and not InCombatLockdown() and TJ.IsLeader() and TJ.frame[FB][bossIndex].Board_test then
                    if TJ.isBoardTesting then
                        TJ.StopTestBoard()
                    else
                        TJ.isBoardTesting = true
                        TJ.BoardVerFrame.testButton:SetText(L["测试中"])
                        ns.SendSystemMessage(L["|cff00ff00已开始测试减伤链。"])
                        TJ.frame[FB][bossIndex].Board_test()
                    end
                end
            end
            TJ.PlaySound(1)
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["预览减伤链进度条"], 1, 1, 1)
            GameTooltip:AddLine(L["预览并调整减伤链进度条的位置。"], 1, .82, 0, true)
            if InCombatLockdown() then
                GameTooltip:AddLine(L["战斗中禁止使用减伤链进度条预览。"], 1, 0, 0, true)
            end
            local _, status = GetBiaoGePreviewStatus()
            if status == "missing" then
                GameTooltip:AddLine(L["你没有安装%s插件，无法预览减伤链进度条。"]:format(ns.BiaoGeName), 1, 0, 0, true)
            elseif status == "outdated" then
                GameTooltip:AddLine(format(L["你的%s插件版本低于%s，无法预览减伤链进度条。"], ns.BiaoGeName, BoardBiaoGeVer), 1, 0, 0, true)
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    -- 设置
    do
        local setting = TJ.CreateButton(TJ.BoardVerFrame.myVerFrame)
        setting:SetPoint("LEFT", TJ.BoardVerFrame.testButton, "RIGHT", 5, 0)
        setting:SetText(L["设置"])
        setting:SetSize(50, 25)
        TJ.BoardVerFrame.settingButton = setting
        setting:SetScript("OnClick", function()
            local BiaoGe, status = GetBiaoGePreviewStatus()
            if status == "supported" then
                BiaoGe.OpenMapOptions()
            end
            TJ.PlaySound(1)
        end)
        setting:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["减伤链设置"], 1, 1, 1)
            GameTooltip:AddLine(L["打开减伤链设置。"], 1, .82, 0, true)
            local _, status = GetBiaoGePreviewStatus()
            if status == "missing" then
                GameTooltip:AddLine(L["你没有安装%s插件，无法打开减伤链设置。"]:format(ns.BiaoGeName), 1, 0, 0, true)
            elseif status == "outdated" then
                GameTooltip:AddLine(format(L["你的%s插件版本低于%s，无法打开减伤链设置。"], ns.BiaoGeName, BoardBiaoGeVer), 1, 0, 0, true)
            end
            GameTooltip:Show()
        end)
        setting:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end

    -- 团员版本
    do
        local raidVerFrame = CreateFrame("Frame", nil, TJ.BoardVerFrame.myVerFrame)
        raidVerFrame:SetSize(1, 20)
        raidVerFrame:SetPoint("LEFT", TJ.BoardVerFrame.settingButton, "RIGHT", 10, 0)
        raidVerFrame.title = L["团员已装："]
        raidVerFrame.t = 0
        raidVerFrame.text = raidVerFrame:CreateFontString()
        raidVerFrame.text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        raidVerFrame.text:SetPoint("LEFT")
        raidVerFrame:SetScript("OnEnter", function(self)
            self.isOnEnter = true
            if not IsInRaid(1) then
                return
            end
            local line = 3
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["减伤链"], 1, 1, 1)
            GameTooltip:AddLine(L["团员的%s插件版本高于或等于|cffffffff%s|r，才能看到减伤进度条。"]:format(ns.BiaoGeName, BoardBiaoGeVer),
                1, .82, 0, true)
            GameTooltip:AddLine(" ")
            local BiaoGe = _G.BG
            if not (TJ.IsLoadBiaoGe() and BiaoGe) then
                GameTooltip:AddLine(L["你没有安装%s插件，无法使用此功能。"]:format(ns.BiaoGeName), 1, 0, 0, true)
                GameTooltip:Show()
                return
            end
            local raid = BiaoGe.SortRaidRosterInfo()
            for i, v in ipairs(raid) do
                local name = v.name
                local Ver = BiaoGe.raidBiaoGeVersion[name]
                local unKnown
                local out = ""
                if not Ver then
                    if v.online then
                        Ver = L["无"]
                    else
                        Ver = L["未知"]
                    end
                    unKnown = true
                elseif BiaoGe.GetVerNum(BoardBiaoGeVer) > BiaoGe.GetVerNum(Ver) then
                    out = L["（不支持）"]
                    unKnown = true
                end
                local role = ""
                if v.rank == 2 then
                    role = role .. AddTexture("interface/groupframe/ui-group-leadericon")
                elseif v.rank == 1 then
                    role = role .. AddTexture("interface/groupframe/ui-group-assistanticon")
                end
                if v.isML then
                    role = role .. AddTexture("interface/groupframe/ui-group-masterlooter")
                end
                local c1, c2, c3 = GetClassRGB(name)
                GameTooltip:AddDoubleLine(name .. role, Ver .. out, c1, c2, c3, 1, 1, 1)
                if unKnown then
                    local alpha = 0.4
                    if _G["GameTooltipTextLeft" .. (i + line)] then
                        _G["GameTooltipTextLeft" .. (i + line)]:SetAlpha(alpha)
                    end
                    if _G["GameTooltipTextRight" .. (i + line)] then
                        _G["GameTooltipTextRight" .. (i + line)]:SetAlpha(alpha)
                    end
                end
            end
            GameTooltip:Show()
        end)
        raidVerFrame:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            self.isOnEnter = false
        end)
        raidVerFrame:SetScript("OnUpdate", function(self, elapsed)
            self.t = self.t + elapsed
            if self.t >= 3 then
                self.t = 0
                UpdateBoardVers()
            end
        end)
        raidVerFrame:SetScript("OnSHow", function(self)
            UpdateBoardVers()
        end)
        TJ.BoardVerFrame.raidVerFrame = raidVerFrame
    end

    function TJ.UpdateBoardVerFramePoint()
        local FB = TuanJian.FB
        local bossIndex = TuanJian.bossIndex
        local board = TJ.frame[FB][bossIndex].board
        if board then
            TJ.BoardVerFrame.myVerFrame:Show()
            TJ.BoardVerFrame.myVerFrame:SetParent(board)
            TJ.BoardVerFrame.myVerFrame:ClearAllPoints()
            TJ.BoardVerFrame.myVerFrame:SetPoint("BOTTOMLEFT", board, "BOTTOMLEFT", 10, 5)
            local warning = TJ.BoardVerFrame.missingAddonText
            warning:ClearAllPoints()
            warning:SetPoint("BOTTOMLEFT", board, "BOTTOMLEFT", 10, 45)
            warning:SetWidth(board:GetWidth() - 50)
            warning:SetShown(not TJ.IsLoadBiaoGe())
        else
            TJ.BoardVerFrame.myVerFrame:Hide()
        end
    end

    UpdateBoardVers = function()
        local BiaoGe = _G.BG
        if IsInRaid(1) and TJ.IsLoadBiaoGe() and BiaoGe then
            local raid = BiaoGe.SortRaidRosterInfo()
            local minVer = BiaoGe.GetVerNum(BoardBiaoGeVer)
            local count = 0
            for _, v in ipairs(raid) do
                local ver = BiaoGe.raidBiaoGeVersion[v.name]
                if ver and BiaoGe.GetVerNum(ver) >= minVer then
                    count = count + 1
                end
            end
            TJ.BoardVerFrame.raidVerFrame.text:SetText(TJ.BoardVerFrame.raidVerFrame.title
                .. format("%s/%s", count, #raid))
            TJ.BoardVerFrame.raidVerFrame.text:SetTextColor(0, 1, 0)
        elseif IsInRaid(1) then
            TJ.BoardVerFrame.raidVerFrame.text:SetText(TJ.BoardVerFrame.raidVerFrame.title
                .. format("0/%s", GetNumGroupMembers(1)))
            TJ.BoardVerFrame.raidVerFrame.text:SetTextColor(.5, .5, .5)
        else
            TJ.BoardVerFrame.raidVerFrame.text:SetText("")
            TJ.BoardVerFrame.raidVerFrame.text:SetTextColor(.5, .5, .5)
        end
        TJ.BoardVerFrame.raidVerFrame:SetWidth(TJ.BoardVerFrame.raidVerFrame.text:GetWidth() + 5)
    end
end)
