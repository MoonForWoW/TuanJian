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

local info          = {}
TJ.Board_info     = info
local boardChannelPrefix = "TuanJianBoard"
local boardChannelCount = 5
local boardChannelIndex = 0

for i = 1, boardChannelCount do
    C_ChatInfo.RegisterAddonMessagePrefix(boardChannelPrefix .. i)
end
C_ChatInfo.RegisterAddonMessagePrefix("D5")

local function GetNextBoardChannel()
    boardChannelIndex = boardChannelIndex % boardChannelCount + 1
    return boardChannelPrefix .. boardChannelIndex
end

local load = 0
TJ.boardCallback = {}
local function Callback()
    TJ.boardInited = true
    for _, func in pairs(TJ.boardCallback) do
        func()
    end
end
TJ.Init2(function()
    if TJ.IsWLK then
        --[[
    s1 大牺
    s2 光掌
    s3 吸血鬼
    s4 魔法罩
    s5 冰封
    s6 小牺
    s7 压制
    s8 天使
    s9 圣疗
    s10 圣佑
    s11 拯救
    s12
    s13
    ]]
        TJ.Board_TJ1 = { 64205, 31821, }                                                       -- 团减
        if TJ.IsTitan then
            tinsert(TJ.Board_TJ1, 1282056)                                                     -- 集结
            tinsert(TJ.Board_TJ1, 48447)                                                       -- 宁静
            tinsert(TJ.Board_TJ1, 64843)                                                       -- 赞美诗
        end
        TJ.Board_TJ2 = { "50364", 55233, 48707, 48792, 6940, 33206, 47788, 48788, 498, 1038, } -- 单体减伤
        TJ.Board_TJ3 = { 55233, 48792, 498, 1038, 6940, 48788, 33206, 47788, 64205, 31821, }   -- 单体减伤
        TJ.Board_TJ4 = { 1044 }                                                                -- 自由
        TJ.Board_TJ5 = {
            6940,                                                                                -- 小牺
            33206,                                                                               -- 压制
            47788,                                                                               -- 守护之魂
            1283513,                                                                             -- 树皮
        }
        TJ.Board_TJ6 = { 31821 }                                                               -- 光掌
        local sum = 0
        local itemCount = 0
        for j = 1, 10 do
            if TJ["Board_TJ" .. j] then
                sum = sum + #TJ["Board_TJ" .. j]
            end
        end
        for j = 1, 10 do
            if TJ["Board_TJ" .. j] then
                for i, s in ipairs(TJ["Board_TJ" .. j]) do
                    if type(s) == "number" then
                        local startNum = (j == 1 and 0 or j) * 10
                        TJ.OnSpellLoad(s, function()
                            local spellIcon = C_Spell.GetSpellTexture(s)
                            local link = C_Spell.GetSpellLink(s)
                            ns["s" .. (startNum + i)] = AddTexture(spellIcon) .. link
                            load = load + 1
                            if load >= sum then
                                ns.isLoaded = true
                                Callback()
                            end
                        end)
                    else
                        s = tonumber(s)
                        itemCount = itemCount + 1
                        local currCount = itemCount
                        local item = Item:CreateFromItemID(s)
                        item:ContinueOnItemLoad(function()
                            local _, link, _, _, _, _, _, _, _, icon = GetItemInfo(s)
                            ns["i" .. currCount] = AddTexture(icon) .. link
                            load = load + 1
                            if load >= sum then
                                ns.isLoaded = true
                                Callback()
                            end
                        end)
                    end
                end
            end
        end
    elseif TJ.IsMOP then
        TJ.Board_TJ1 = ns.sp["团减"]
        TJ.Board_TJ2 = ns.sp["单体减伤"]
        TJ.Board_TJ6 = { 8143 }   -- 战栗
        TJ.Board_TJ7 = { 108199 } -- 群拉
        TJ.Board_TJ8 = { 102359 } -- 群缠

        local sum = 0
        local itemCount = 0
        for j = 1, 10 do
            if TJ["Board_TJ" .. j] then
                sum = sum + #TJ["Board_TJ" .. j]
            end
        end
        for j = 1, 10 do
            if TJ["Board_TJ" .. j] then
                for i, s in ipairs(TJ["Board_TJ" .. j]) do
                    if type(s) == "number" then
                        local startNum = (j == 1 and 0 or j) * 10
                        TJ.OnSpellLoad(s, function()
                            local spellIcon = C_Spell.GetSpellTexture(s)
                            local link = C_Spell.GetSpellLink(s)
                            ns["s" .. (startNum + i)] = AddTexture(spellIcon) .. link
                            load = load + 1
                            if load >= sum then
                                ns.isLoaded = true
                                Callback()
                            end
                        end)
                    else
                        s = tonumber(s)
                        itemCount = itemCount + 1
                        local currCount = itemCount
                        local item = Item:CreateFromItemID(s)
                        item:ContinueOnItemLoad(function()
                            local _, link, _, _, _, _, _, _, _, icon = GetItemInfo(s)
                            ns["i" .. currCount] = AddTexture(icon) .. link
                            load = load + 1
                            if load >= sum then
                                ns.isLoaded = true
                                Callback()
                            end
                        end)
                    end
                end
            end
        end
    end
end)
function TJ.AddBoard(mainFrame, func)
    local function init()
        mainFrame.isBoardLoad = true
        func()
    end
    tinsert(TJ.boardCallback, init)
    if TJ.boardInited and not mainFrame.isBoardLoad then init() end
end

function TJ.CreateBoard(FB, bossIndex, spellInfo)
    TuanJian[FB][bossIndex].lastBoard = TuanJian[FB][bossIndex].lastBoard or 1

    local arrange = 0
    for k, v in ipairs(spellInfo) do
        arrange = max(arrange, v.arrange)
    end

    -- 主界面
    local parent = TJ.frame[FB][bossIndex]
    local mainFrame = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    do
        mainFrame:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        mainFrame:SetBackdropColor(0, 0, 0, 0.8)
        local r, g, b = ns.GetClassRGB(nil, "player")
        mainFrame:SetBackdropBorderColor(r, g, b, TJ.borderAlpha)
        -- mainFrame:SetBackdropBorderColor(0, 0, 0, 1)
        mainFrame:SetSize(130 + min(3, max(2, arrange)) * 120, TJ.FBinfo[FB][bossIndex].height)
        mainFrame:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPLEFT", -1, 0)
        mainFrame:EnableMouse(true)
        mainFrame.tabButton = {}
        mainFrame.frame = {}
        mainFrame.child = {}
        mainFrame.AutoFuc = spellInfo.AutoFuc
        mainFrame.tooltip = spellInfo.tooltip
        parent.board = mainFrame

        local t = mainFrame:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 16, "OUTLINE")
        t:SetPoint("TOP", 0, -5)
        t:SetTextColor(1, 1, 1)
        t:SetText(L["减伤链"])

        -- 说明书
        local tbl = {
            L["|cffffffff减伤链使用教程"],
            " ",
            L["|cffffffff设置减伤链：|r团长/助理可以手动设置减伤链，也可以点击[一键安排]按钮来自动设置减伤链。"],
            " ",
            L["|cffffffff使用效果"],
            " ",
            L["|cffffffff团员：|r已安装%s插件的团员如果该轮减伤是他自己，屏幕上方会显示一个倒计时进度条，方便他知道什么时候交减伤。剩余时间少于3秒时还会有\"叮叮叮\"音效提醒。"]:format(ns.BiaoGeName),
            " ",
            L["|cffffffff团长/助理：|r你能看到所有人每一轮的倒计时进度条。剩余时间少于5秒时会自动密语相应责任人，提醒他开减伤，即使对方没有安装%s插件。"]:format(ns.BiaoGeName),
        }
        local f = CreateFrame("Frame", nil, mainFrame)
        f:SetPoint("TOPLEFT", 5, -1)
        f:SetHitRectInsets(0, 0, 0, 0)
        local t = f:CreateFontString()
        t:SetPoint("CENTER")
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetJustifyH("LEFT")
        t:SetText(L["教程"])
        t:SetTextColor(0, 1, 0)
        f:SetSize(t:GetStringWidth(), 20)
        mainFrame.boardTipsText = f
        f:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_NONE")
            GameTooltip:SetPoint("TOPLEFT", self, "BOTTOMLEFT")
            GameTooltip:ClearLines()
            for _, text in ipairs(tbl) do
                GameTooltip:AddLine(text, 1, .82, 0, true)
            end
            GameTooltip:Show()
            t:SetTextColor(1, 1, 1)
        end)
        f:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            t:SetTextColor(0, 1, 0)
        end)

        mainFrame:SetScript("OnShow", function(self)
            TJ.UpdateBoardVerFramePoint()
        end)
        mainFrame:SetScript("OnMouseDown", function(self)
            if TJ.lastfocus then
                TJ.lastfocus:ClearFocus()
            end
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
            TJ.MainFrame:StartMoving()
        end)
        mainFrame:SetScript("OnMouseUp", function(self)
            TJ.MainFrame:StopMovingOrSizing()
        end)
    end

    -- 战术类别
    local tabFrame = CreateFrame("Frame", nil, mainFrame)
    tabFrame:SetPoint("BOTTOM", mainFrame, "TOP", 0, -60)
    tabFrame:SetSize(1, 20)
    local last
    for i, v in ipairs(spellInfo) do
        TuanJian[FB][bossIndex].board[v.id] = TuanJian[FB][bossIndex].board[v.id] or {}
        -- 按钮和容器
        do
            local bt = CreateFrame("Button", nil, tabFrame)
            bt:SetNormalFontObject(TJ.FontBlue13)
            bt:SetDisabledFontObject(TJ.FontWhite15)
            bt:SetHighlightFontObject(TJ.FontWhite13)
            bt:SetHighlightTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")
            bt.id = v.id
            bt.icon = type(v.icon) == "string" and "Interface\\Icons\\" .. v.icon or v.icon
            bt:SetText("|T" .. bt.icon .. ":16:16|t" .. v.name)
            bt:SetSize(bt:GetFontString():GetStringWidth(), 25)
            if not last then
                bt:SetPoint("LEFT")
            else
                bt:SetPoint("LEFT", last, "RIGHT", 15, 0)
            end
            tabFrame:SetWidth(tabFrame:GetWidth() + bt:GetWidth())
            last = bt
            mainFrame.tabButton[v.id] = bt
            bt:SetScript("OnClick", function(self)
                self:OnClick()
                TJ.PlaySound(1)
            end)
            function bt:OnClick()
                TuanJian[FB][bossIndex].lastBoard = self.id
                for _, bt in pairs(mainFrame.tabButton) do
                    bt:Enable()
                    mainFrame.frame[bt.id]:Hide()
                end
                self:Disable()
                mainFrame.frame[bt.id]:Show()
            end
        end

        do
            local f, child = TJ.CreateScrollFrame(mainFrame, mainFrame:GetWidth() - 20, mainFrame:GetHeight() - 100, nil)
            f:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            f:SetBackdropColor(.3, .3, .3, 0.2)
            f:SetBackdropBorderColor(1, 1, 1, .3)
            f:SetPoint("TOPLEFT", 10, -60)
            f:Hide()
            for key, value in pairs(v) do
                child[key] = value
            end
            child.mainFrame = mainFrame
            child.maxIndex = child.maxIndex or 100
            child.step = child.step or 1
            child.name = nil
            mainFrame.frame[v.id] = f
            mainFrame.child[v.id] = child
            child:SetScript("OnMouseDown", mainFrame:GetScript("OnMouseDown"))
            child:SetScript("OnMouseUp", mainFrame:GetScript("OnMouseUp"))
        end

        local id = v.id
        local arrange = v.arrange
        for i, v in ipairs(v.spell) do
            TJ.CreateBoardSpellTitle(FB, bossIndex, id, v.title, v.onlyTitle)
            for ii = 1, arrange do
                TJ.CreateBoardSpellEdit(FB, bossIndex, id, v)
            end
        end
    end
    if mainFrame.tabButton[TuanJian[FB][bossIndex].lastBoard] then
        mainFrame.tabButton[TuanJian[FB][bossIndex].lastBoard]:OnClick()
    else
        mainFrame.tabButton[1]:OnClick()
    end

    -- 重置按钮
    do
        local bt = CreateFrame("Button", nil, mainFrame)
        bt:SetSize(18, 18)
        bt:SetPoint("TOPRIGHT", mainFrame, "BOTTOMRIGHT", -10, 40)
        bt:SetNormalTexture("interface/raidframe/readycheck-notready")
        bt:SetHighlightTexture("interface/raidframe/readycheck-notready")
        bt:RegisterForClicks("AnyUp")
        bt:SetScript("OnClick", function(self, button)
            TJ.PlaySound(1)
            if button == "LeftButton" then
                TJ.ClearBoard(FB, bossIndex, TuanJian[FB][bossIndex].lastBoard)
            elseif button == "RightButton" then
                TJ.ClearBoard(FB, bossIndex)
            end
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置减伤链"], 1, 1, 1, true)
            local now = mainFrame.tabButton[TuanJian[FB][bossIndex].lastBoard]:GetText()
            if #spellInfo > 1 then
                GameTooltip:AddLine(AddTexture("LEFT") .. L["重置"] .. now, 1, .82, 0, true)
                GameTooltip:AddLine(AddTexture("RIGHT") .. L["重置该BOSS所有减伤链"], 1, .82, 0, true)
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end
end

function TJ.UpdateBoardSpellType(child, spellTbl)
    for i, v in ipairs(spellTbl) do
        TJ.CreateBoardSpellTitle(child, v.title)
    end
end

function TJ.CreateBoardSpellTitle(FB, bossIndex, id, titleName, onlyTitle)
    local child = TJ.frame[FB][bossIndex].board.child[id]
    child.all = child.all or {}

    local f = CreateFrame("Frame", nil, child)
    f:SetSize(80, 20)
    if next(child.all) then
        local last = child.all[#child.all].title
        f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -40 - (last.row - 1) * 60)
    else
        f:SetPoint("TOPLEFT", child, "TOPLEFT", 5, -25)
    end
    local t = f:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
    t:SetAllPoints()
    t:SetText(onlyTitle and titleName .. L["："] or titleName .. L["轮："])
    t:SetJustifyH("RIGHT")
    t:SetWordWrap(false)
    tinsert(child.all, {
        title = f,
        titleName = t:GetText(),
        edits = {},
    })
end

function TJ.CreateBoardSpellEdit(FB, bossIndex, id, v)
    local child = TJ.frame[FB][bossIndex].board.child[id]
    local titleIndex = #child.all
    local title = child.all[titleIndex].title
    local edits = child.all[titleIndex].edits

    local playerEdit = CreateFrame("EditBox", nil, title, TJ.editTemplate)
    do
        playerEdit:SetSize(100, 20)
        if #edits == 0 then
            playerEdit:SetPoint("LEFT", title, "RIGHT", 10, 0)
            title.row = 1
        else
            local t = title:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetPoint("CENTER", playerEdit, "LEFT", -12, 0)
            t:SetTextColor(1, 0.82, 0)
            t:SetText("+")
            if (#edits) % 3 == 0 then
                playerEdit:SetPoint("TOPLEFT", edits[#edits - 2].playerEdit, "BOTTOMLEFT", 0, -38)
                title.row = title.row + 1
            else
                playerEdit:SetPoint("LEFT", edits[#edits].playerEdit, "RIGHT", 20, 0)
            end
        end
        playerEdit:SetAutoFocus(false)
        playerEdit.FB = FB
        playerEdit.bossIndex = bossIndex
        playerEdit.boardID = id
        playerEdit.titleIndex = titleIndex
        playerEdit.i = #edits + 1
        playerEdit.type = "player"
        playerEdit.name = playerEdit.titleIndex .. "-" .. playerEdit.i .. "-" .. playerEdit.type
        TJ.SetEditBaseClass(playerEdit)
        playerEdit:HookScript("OnTextChanged", function(self)
            if self:GetText() == "" then
                self:ClearAll()
            else
                self:Save()
            end
            if TJ.exportTJFrame then
                TJ.exportTJFrame:UpdateText()
            end
        end)
        playerEdit:HookScript("OnEditFocusGained", function(self)
            TJ.lastfocus = self
            TJ.ListPlayer(self, v.class)
        end)
        playerEdit:HookScript("OnEditFocusLost", function(self)
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
        end)

        local db = TuanJian[FB][bossIndex].board[playerEdit.boardID][playerEdit.name]
        if db then
            local r, g, b = GetClassColor(db.class)
            playerEdit:SetText(db.text)
            playerEdit:SetCursorPosition(0)
            playerEdit:SetTextColor(r, g, b)
            playerEdit.player = db.player
            playerEdit.class = db.class
            playerEdit.role = db.role
            playerEdit.combatRole = db.combatRole
            playerEdit.talent = db.talent
        end

        function playerEdit:ClearAll()
            self:SetText("")
            self:SetTextColor(1, 1, 1)
            self.player = nil
            self.class = nil
            self.role = nil
            self.combatRole = nil
            self.talent = nil
            TuanJian[self.FB][self.bossIndex].board[self.boardID][self.name] = nil
        end

        function playerEdit:Save()
            TuanJian[self.FB][self.bossIndex].board[self.boardID][self.name] = {
                text = self:GetText(),
                player = self.player,
                class = self.class,
                role = self.role,
                combatRole = self.combatRole,
                talent = self.talent,
            }
        end

        function playerEdit:SetPlayer(v)
            local r, g, b = GetClassColor(v.class)
            self:SetText(TJ.GetIconAndName(v))
            self:SetCursorPosition(0)
            self:SetTextColor(r, g, b)
            self.player = v.name
            self.class = v.class
            self.role = v.role
            self.combatRole = v.combatRole
            self.talent = TuanJian.talentInfo[v.name]
        end
    end

    local spellEdit = CreateFrame("EditBox", nil, title, TJ.editTemplate)
    do
        spellEdit:SetSize(100, 20)
        spellEdit:SetPoint("TOPLEFT", playerEdit, "BOTTOMLEFT", 0, -0)
        spellEdit:SetAutoFocus(false)
        spellEdit.FB = FB
        spellEdit.bossIndex = bossIndex
        spellEdit.boardID = id
        spellEdit.titleIndex = titleIndex
        spellEdit.i = #edits + 1
        spellEdit.type = "spell"
        spellEdit.spellTbl = v.spell
        spellEdit.name = spellEdit.titleIndex .. "-" .. spellEdit.i .. "-" .. spellEdit.type
        TJ.SetEditBaseClass(spellEdit)
        spellEdit:HookScript("OnTextChanged", function(self)
            if self:GetText() == "" then
                self:ClearAll()
            else
                self:Save()
            end
            if TJ.exportTJFrame then
                TJ.exportTJFrame:UpdateText()
            end
        end)
        spellEdit:HookScript("OnEditFocusGained", function(self)
            TJ.lastfocus = self
            TJ.ListSpell(self, self.spellTbl)
        end)
        spellEdit:HookScript("OnEditFocusLost", function(self)
            if TJ.FrameSpellList then
                TJ.FrameSpellList:Hide()
            end
        end)

        local db = TuanJian[FB][bossIndex].board[spellEdit.boardID][spellEdit.name]
        if db then
            spellEdit:SetText(db.text)
            spellEdit:SetCursorPosition(0)
        end

        function spellEdit:ClearAll()
            self:SetText("")
            TuanJian[self.FB][self.bossIndex].board[self.boardID][self.name] = nil
        end

        function spellEdit:Save()
            TuanJian[self.FB][self.bossIndex].board[self.boardID][self.name] = {
                text = self:GetText(),
            }
            --[[
            TuanJian.MSV[1].board[1]={
                ["1-1-player"]="苍刃",
                ["1-1-spell"]="大牺牲",
            }
            ]]
        end
    end

    local t = playerEdit:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
    t:SetPoint("BOTTOM", playerEdit, "TOP", 0, 0)
    t:SetSize(playerEdit:GetWidth(), 15)
    t:SetTextColor(1, 0.82, 0)
    t:SetText(L["玩家/技能"])
    t:SetWordWrap(false)

    spellEdit.playerEdit = playerEdit
    playerEdit.spellEdit = spellEdit

    tinsert(edits, {
        playerEdit = playerEdit,
        spellEdit = spellEdit,
    })
end

function TJ.Board_SetBar(bossSpellID, index, player, durTime, spellIDs, autoHide, now, target)
    if not IsInRaid(1) then return end
    if not TJ.IsLeader() then return end
    local msg
    durTime = durTime + 0.01
    durTime = format("%.2f", durTime)
    autoHide = autoHide and "autoHide" or ""
    now = now and "now" or ""
    target = target or ""
    player = TJ.GFN(player)
    msg = "show" .. ","
        .. bossSpellID .. ","
        .. index .. ","
        .. player .. ","
        .. durTime .. ","
        .. spellIDs .. ","
        .. autoHide .. ","
        .. now .. ","
        .. target
    -- pt(msg)
    C_ChatInfo.SendAddonMessage(GetNextBoardChannel(), msg, "RAID")
end

local function SetBar(tbl, arrange, bossSpellID, index, durationTime, autoHide, now, target)
    local players = {}
    for i = 1, arrange do
        local player = TJ.ClearCode(tbl.edits[i].playerEdit:GetText())
        local link = tbl.edits[i].spellEdit:GetText()
        local spellID = link:match("spell:(%d+)")
        if spellID then
            spellID = "s" .. spellID
        else
            spellID = link:match("item:(%d+)")
            if spellID then
                spellID = "i" .. spellID
            end
        end
        if player ~= "" and spellID then
            players[player] = players[player] or ""
            players[player] = players[player] .. spellID .. "^"
        end
    end
    for player, spellIDs in pairs(players) do
        TJ.Board_SetBar(bossSpellID, index, player, durationTime, spellIDs, autoHide, now, target)
    end
end

function TJ.Board_HideBar(bossSpellID)
    if not TJ.IsLeader() then return end
    local msg = format("%s,%s", "hide", bossSpellID)
    C_ChatInfo.SendAddonMessage(GetNextBoardChannel(), msg, "RAID")
end

function TJ.Board_HideAllBar()
    if not TJ.IsLeader() then return end
    local msg = format("%s", "hideAll")
    C_ChatInfo.SendAddonMessage(GetNextBoardChannel(), msg, "RAID")
end

function TJ.Board_NextSpell(bossSpellID)
    TJ.Board_HideBar(bossSpellID)
    if info[bossSpellID] then
        info[bossSpellID].canUpdate = nil
        info[bossSpellID].updateFrame.t = 0
    end
    local delay = .5
    After(delay, function()
        if info[bossSpellID] then
            info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
            info[bossSpellID].canUpdate = true
            info[bossSpellID].updateFrame.t = delay
        end
    end)
    TJ.Board_RunSpecial(bossSpellID)
end

function TJ.Board_RunSpecial(bossSpellID, specialID)
    specialID = specialID or ""
    local specialName = 'special' .. specialID
    if info[bossSpellID] and info[bossSpellID][specialName] then
        local special = info[bossSpellID][specialName]
        local child = info[bossSpellID].child.mainFrame.child[special.id]
        local index = info[bossSpellID].index
        local turnNum = #info[bossSpellID].spell
        local durationTime = special.time
        local showIndex = index
        index = (index - 1) % turnNum + 1
        SetBar(
            child.all[index],
            special.arrange or info[bossSpellID].arrange,
            special.bossSpellID,
            showIndex,
            durationTime,
            true,
            info[bossSpellID].now,
            info[bossSpellID].target
        )
    end
end

function TJ.Board_HideNextSpell(bossSpellID)
    TJ.Board_HideBar(bossSpellID)
    info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
    info[bossSpellID].canUpdate = nil
    info[bossSpellID].updateFrame.t = 0
end

local timer = {}
function TJ.AddTimer(delay, func)
    local t = GetTime()
    timer[t] = true
    After(delay, function()
        if timer[t] then
            func()
        end
    end)
end

function TJ.Board_ENCOUNTER_START(FB, bossIndex, isTest)
    local board = TJ.frame[FB][bossIndex].board
    if not board then return end
    if not isTest and TJ.isBoardTesting then
        TJ.StopTestBoard()
    else
        TJ.Board_ENCOUNTER_END()
    end
    info.FB = FB
    info.bossIndex = bossIndex
    if TJ.frame[FB][bossIndex].Board_ENCOUNTER_START then
        TJ.frame[FB][bossIndex].Board_ENCOUNTER_START(info)
    end
    for _, child in pairs(board.child) do
        if not child.notSetInfo then
            local bossSpellID = child.bossSpellID
            local arrange = child.arrange
            info[bossSpellID] = {
                child = child,
                FB = FB,
                bossIndex = bossIndex,
                index = child.startIndex,
            }
            for key, value in pairs(child) do
                info[bossSpellID][key] = value
            end
            if type(info[bossSpellID].bossTime) == "function" then
                info[bossSpellID].bossTime = info[bossSpellID].bossTime()
            end
            if not child.H or TJ.IsH() then
                local updateFrame = CreateFrame("Frame")
                updateFrame.t = 0
                updateFrame:SetScript("OnUpdate", function(updateFrame, t)
                    updateFrame.t = updateFrame.t + t
                    local index = info[bossSpellID].index
                    local maxIndex = info[bossSpellID].maxIndex
                    if index > 0 and index <= maxIndex then
                        local child = info[bossSpellID].child
                        local bossTime = info[bossSpellID].bossTime
                        local nextTime = bossTime[index] or bossTime[#bossTime]
                        if info[bossSpellID].canUpdate and nextTime - updateFrame.t <= TuanJian.options.boardTipsTime then
                            info[bossSpellID].canUpdate = nil
                            local durationTime = nextTime - updateFrame.t
                            local turnIndex = (index - 1) % #child.all + 1
                            local tbl = child.all[turnIndex]
                            if tbl then
                                SetBar(tbl, arrange, bossSpellID, index, durationTime
                                , info[bossSpellID].autoHide, info[bossSpellID].now, info[bossSpellID].target)
                            end
                        end
                        if (info[bossSpellID].timeEndNextSpell or info[bossSpellID]["timeEndNextSpell" .. index])
                            and updateFrame.t >= nextTime then
                            TJ.Board_NextSpell(bossSpellID)
                        end
                    end
                end)
                info[bossSpellID].updateFrame = updateFrame
            end
        end
    end
end

function TJ.Board_ENCOUNTER_END()
    for bossSpellID in pairs(info) do
        if type(info[bossSpellID]) == "table" and info[bossSpellID].updateFrame then
            info[bossSpellID].updateFrame:SetScript("OnUpdate", nil)
            info[bossSpellID].updateFrame:Hide()
        end
    end
    wipe(info)
    wipe(timer)
end

TJ.RegisterEvent("RAID_INSTANCE_WELCOME", function()
    TJ.Board_ENCOUNTER_END()
end)

function TJ.Board_SPELL_CAST_SUCCESS(...)
    if not next(info) then return end
    local tbl = { ... }
    local FB = info.FB
    local bossIndex = info.bossIndex
    -- 处理BOSS的特殊时间轴
    local frame = TJ.frame[FB][bossIndex]
    if frame.Board_SPELL_CAST_SUCCESS then
        frame.Board_SPELL_CAST_SUCCESS(info, ...)
    end
    -- 如果施放的法术是减伤链的BOSS技能，则开始下一轮计时
    local bossSpellID = tbl[12]
    if info[bossSpellID] and info[bossSpellID].autoNextSpell
        and info[bossSpellID].event == "SPELL_CAST_SUCCESS" then
        TJ.Board_NextSpell(bossSpellID)
    end
end

function TJ.Board_SPELL_CAST_START(...)
    if not next(info) then return end
    local tbl = { ... }
    local FB = info.FB
    local bossIndex = info.bossIndex
    -- 处理BOSS的特殊时间轴
    local frame = TJ.frame[FB][bossIndex]
    if frame.Board_SPELL_CAST_START then
        frame.Board_SPELL_CAST_START(info, ...)
    end
    -- 如果施放的法术是战术板的BOSS技能，则开始下一轮计时
    local bossSpellID = tbl[12]
    if info[bossSpellID] and info[bossSpellID].autoNextSpell
        and info[bossSpellID].event == "SPELL_CAST_START" then
        TJ.Board_NextSpell(bossSpellID)
    end
end

function TJ.Board_SPELL_AURA_APPLIED(...)
    if not next(info) then return end
    local FB = info.FB
    local bossIndex = info.bossIndex
    -- 处理BOSS的特殊时间轴
    local frame = TJ.frame[FB][bossIndex]
    if frame.Board_SPELL_AURA_APPLIED then
        frame.Board_SPELL_AURA_APPLIED(info, ...)
    end
end

for _, event in ipairs({ 'SPELL_CAST_SUCCESS', 'SPELL_CAST_START', 'SPELL_AURA_APPLIED' }) do
    TJ.boardEvent[event] = TJ['Board_' .. event]
end

function TJ.PairAllEdit_BoardPlayer(func, FB, bossIndex)
    local FB = FB or TuanJian.FB
    local bossIndex = bossIndex or TuanJian.bossIndex
    local board = TJ.frame[FB][bossIndex].board
    if board then
        for _, child in pairs(board.child) do
            for _, v in ipairs(child.all) do
                for _, vv in ipairs(v.edits) do
                    func(vv.playerEdit)
                end
            end
        end
    end
end

function TJ.PairAllEdit_Board(func, FB, bossIndex)
    local FB = FB or TuanJian.FB
    local bossIndex = bossIndex or TuanJian.bossIndex
    local board = TJ.frame[FB][bossIndex].board
    if board then
        for _, child in pairs(board.child) do
            for _, v in ipairs(child.all) do
                for _, vv in ipairs(v.edits) do
                    func(vv.playerEdit)
                    func(vv.spellEdit)
                end
            end
        end
    end
end

function TJ.UpdateEditIcon_Board()
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local board = TJ.frame[FB][bossIndex].board
    if board and board:IsVisible() then
        for i, v in ipairs(TJ.raidRosterInfo) do
            TJ.PairAllEdit_BoardPlayer(function(edit)
                if edit.player == v.name then
                    local text = TJ.GetIconAndName(v, edit.talent)
                    edit:SetText(text)
                    local db = TuanJian[FB][bossIndex].board[edit.boardID][edit.name]
                    if db then
                        db.text = text
                        db.role = v.role
                        db.combatRole = v.combatRole
                    end
                end
            end)
        end
    end
end

function TJ.ClearBoard(_FB, _bossIndex, boardID)
    for i, v in ipairs(TJ.FBtbl) do
        if not _FB or _FB == v.FB then
            local FB = v.FB
            if not TJ.tabFrame[FB] then
                TJ.UpdateBossChooseFrame(FB)
            end
            for bossIndex in ipairs(TJ.FBinfo[FB]) do
                if not _bossIndex or _bossIndex == bossIndex then
                    local parent = TJ.frame[FB][bossIndex]
                    if not parent then
                        TJ.LoadBoss(FB, bossIndex, true)
                    end
                    if parent then
                        local board = parent.board
                        if board then
                            if boardID then
                                local child = board.child[boardID]
                                for _, v in ipairs(child.all) do
                                    for _, vv in ipairs(v.edits) do
                                        vv.playerEdit:ClearAll()
                                        vv.spellEdit:ClearAll()
                                    end
                                end
                            else
                                TJ.PairAllEdit_Board(function(edit)
                                    edit:ClearAll()
                                end, FB, bossIndex)
                            end
                        end
                    end
                end
            end
        end
    end
    if TJ.exportTJFrame then
        TJ.exportTJFrame:UpdateText()
    end
end
