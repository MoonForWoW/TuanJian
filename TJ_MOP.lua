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
    parent.all = {}

    local MAX_ROUNDS = 7
    local ROUND_SPACING = 68

    local scroll = CreateFrame("ScrollFrame", nil, parent, TJ.scrollTemplate)
    scroll:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 0, -40)
    scroll:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", -20, 120)
    scroll.ScrollBar.scrollStep = ROUND_SPACING
    TJ.CreateSrollBarBackdrop(scroll.ScrollBar)
    TJ.HookScrollBarShowOrHide(scroll)

    local scrollChild = CreateFrame("Frame", nil, scroll)
    scrollChild:SetSize(1, 1)
    scroll:SetScrollChild(scrollChild)
    parent.scroll = scroll
    parent.scrollChild = scrollChild

    local function UpdateScrollChildSize()
        scrollChild:SetWidth(scroll:GetWidth())
        local contentHeight = 60 + ROUND_SPACING * (TuanJian.MOPTJ.num - 1)
        scrollChild:SetHeight(max(scroll:GetHeight(), contentHeight))
    end
    scroll:HookScript("OnSizeChanged", UpdateScrollChildSize)

    local function CreateTitle(name)
        local f = CreateFrame("Frame", nil, scrollChild)
        f:SetSize(70, 20)
        if next(parent.all) then
            local last = parent.all[#parent.all].title
            f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -48)
        else
            f:SetPoint("TOPLEFT", scrollChild, "TOPLEFT", 5, -20)
        end
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetAllPoints()
        t:SetText(name .. L["团减："])
        t:SetJustifyH("RIGHT")
        t:SetWordWrap(false)
        tinsert(parent.all, {
            title = f,
            titleName = t:GetText(),
            edits = {},
        })
    end
    local function CreateEdit()
        local titleIndex = #parent.all
        local title = parent.all[titleIndex].title
        local edits = parent.all[titleIndex].edits

        local playerEdit = CreateFrame("EditBox", nil, title, TJ.editTemplate)
        do
            playerEdit:SetSize(100, 20)
            if #edits == 0 then
                playerEdit:SetPoint("LEFT", title, "RIGHT", 10, 0)
            else
                local t = title:CreateFontString()
                t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
                t:SetPoint("CENTER", edits[#edits].playerEdit, "RIGHT", 8, 0)
                t:SetTextColor(1, 0.82, 0)
                t:SetText("+")
                playerEdit:SetPoint("LEFT", edits[#edits].playerEdit, "RIGHT", 20, 0)
            end
            playerEdit:SetAutoFocus(false)
            playerEdit.FB = FB
            playerEdit.bossIndex = bossIndex
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
                TJ.exportTJFrame:UpdateText()
            end)
            playerEdit:HookScript("OnEditFocusGained", function(self)
                TJ.lastfocus = self
                TJ.ListPlayer(self, TJ.TJClass)
            end)
            playerEdit:HookScript("OnEditFocusLost", function(self)
                if TJ.FramePlayerList then
                    TJ.FramePlayerList:Hide()
                end
            end)

            function playerEdit:ClearAll()
                self:SetText("")
                self:SetTextColor(1, 1, 1)
                self.player = nil
                self.class = nil
                self.role = nil
                self.combatRole = nil
                self.talent = nil
                TuanJian[self.FB][self.bossIndex][self.name] = nil
            end

            function playerEdit:Save()
                TuanJian[self.FB][self.bossIndex][self.name] = {
                    text = self:GetText(),
                    player = self.player,
                    class = self.class,
                    role = self.role,
                    combatRole = self.combatRole,
                    talent = self.talent,
                }
            end

            function playerEdit:Load(db)
                local r, g, b = GetClassColor(db.class)
                playerEdit:SetText(db.text)
                playerEdit:SetTextColor(r, g, b)
                playerEdit.player = db.player
                playerEdit.class = db.class
                playerEdit.role = db.role
                playerEdit.combatRole = db.combatRole
                playerEdit.talent = db.talent
            end

            function playerEdit:GetDB()
                return TJ.Copy(TuanJian[self.FB][self.bossIndex][self.name])
            end

            local db = TuanJian[FB][bossIndex][playerEdit.name]
            if db then
                playerEdit:Load(db)
            end

            function playerEdit:SetPlayer(v)
                local r, g, b = GetClassColor(v.class)
                self:SetText(TJ.GetIconAndName(v))
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
            spellEdit.titleIndex = titleIndex
            spellEdit.i = #edits + 1
            spellEdit.type = "spell"
            spellEdit.spellTbl = ns.sp["团减"]
            spellEdit.name = spellEdit.titleIndex .. "-" .. spellEdit.i .. "-" .. spellEdit.type
            TJ.SetEditBaseClass(spellEdit)
            spellEdit:HookScript("OnTextChanged", function(self)
                if self:GetText() == "" then
                    self:ClearAll()
                else
                    self:Save()
                end
                TJ.exportTJFrame:UpdateText()
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
            spellEdit:HookScript("OnMouseDown", function(self)
                if IsShiftKeyDown() then
                    self:SetEnabled(false)
                    TJ.InsertLink(TJ.ClearCode(self:GetText(), true))
                end
            end)
            spellEdit:HookScript("OnMouseUp", function(self)
                self:SetEnabled(true)
            end)

            function spellEdit:ClearAll()
                self:SetText("")
                TuanJian[self.FB][self.bossIndex][self.name] = nil
            end

            function spellEdit:Save()
                TuanJian[self.FB][self.bossIndex][self.name] = {
                    text = self:GetText(),
                }
            end

            function spellEdit:Load(db)
                spellEdit:SetText(db.text)
                spellEdit:SetCursorPosition(0)
            end

            function spellEdit:GetDB()
                return TJ.Copy(TuanJian[self.FB][self.bossIndex][self.name])
            end

            local db = TuanJian[FB][bossIndex][spellEdit.name]
            if db then
                spellEdit:Load(db)
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
    for i = 1, MAX_ROUNDS do
        CreateTitle(i)
        for i = 1, 7 do
            CreateEdit()
        end
    end

    function TJ.PairAllEdit_TJPlayer(func)
        for _, v in ipairs(mainFrame.all) do
            for _, vv in ipairs(v.edits) do
                func(vv.playerEdit)
            end
        end
    end

    function TJ.PairAllEdit_TJ(func)
        for _, v in ipairs(mainFrame.all) do
            for _, vv in ipairs(v.edits) do
                func(vv.playerEdit)
                func(vv.spellEdit)
            end
        end
    end

    function TJ.UpdateEditIcon_TJ()
        if mainFrame and mainFrame:IsVisible() then
            for i, v in ipairs(TJ.raidRosterInfo) do
                TJ.PairAllEdit_TJPlayer(function(edit)
                    if edit.player == v.name then
                        local text = TJ.GetIconAndName(v, edit.talent)
                        edit:SetText(text)
                        local db = TuanJian[FB][bossIndex][edit.name]
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

    local tbl = {
        {
            title = L["减伤轮数："],
            dbKey = "num",
            list = {
                { name = L["2轮"], key = 2 },
                { name = L["3轮"], key = 3 },
                { name = L["4轮"], key = 4 },
                { name = L["5轮"], key = 5 },
                { name = L["6轮"], key = 6 },
                { name = L["7轮"], key = 7 },
            }
        },
        {
            title = L["减伤类型："],
            dbKey = "type",
            list = {
                { name = L["物理减伤"], key = "physics" },
                { name = L["魔法减伤"], key = "mage" },
            }
        },
    }
    local chooseButtons = {}
    for i, vv in ipairs(tbl) do
        local title = parent:CreateFontString()
        title:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        title:SetPoint("TOPLEFT", TJ.autoButton, "TOPLEFT", 0, 25 * i + 10)
        title:SetText(vv.title)

        local buttons = {}
        chooseButtons[i] = buttons
        for i, v in ipairs(vv.list) do
            local bt = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
            if i == 1 then
                bt:SetPoint("LEFT", title, "RIGHT", 5, 0)
            else
                bt:SetPoint("LEFT", buttons[i - 1], "RIGHT", buttons[i - 1].Text:GetWidth() + 5, 0)
            end
            bt:SetSize(15, 15)
            bt.key = vv.dbKey
            bt.value = v.key
            tinsert(buttons, bt)
            bt.Text = bt:CreateFontString()
            bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            bt.Text:SetPoint("LEFT", bt, "RIGHT", 0, 0)
            bt.Text:SetText(v.name)
            bt.Text:SetTextColor(1, .82, 0)
            bt:SetHitRectInsets(0, -bt.Text:GetWidth(), -5, -5)

            if v.key == TuanJian.MOPTJ[vv.dbKey] then
                bt:SetChecked(true)
                bt.Text:SetTextColor(0, 1, 0)
            end

            bt:SetScript("OnClick", function(self)
                TJ.PlaySound(1)
                bt:OnClick(vv.dbKey, v.key)
                parent.UpdateShowCount()
            end)

            function bt:OnClick(key, value)
                for _, radioButton in ipairs(buttons) do
                    if radioButton ~= self then
                        radioButton:SetChecked(false)
                        radioButton.Text:SetTextColor(1, .82, 0)
                    end
                end
                self:SetChecked(true)
                self.Text:SetTextColor(0, 1, 0)
                TuanJian.MOPTJ[key] = value
            end
        end
    end

    function parent.UpdateChooseFrame()
        for i = 1, 2 do
            local key = i == 1 and "num" or "type"
            for _, bt in ipairs(chooseButtons[i]) do
                if bt.value == TuanJian.MOPTJ[key] then
                    bt:OnClick(key, TuanJian.MOPTJ[key])
                    break
                end
            end
        end
    end

    function parent.UpdateShowCount()
        for i = 1, #parent.all do
            if i > TuanJian.MOPTJ.num then
                parent.all[i].title:Hide()
                for _, vv in ipairs(parent.all[i].edits) do
                    vv.playerEdit:ClearAll()
                    vv.spellEdit:ClearAll()
                end
            else
                parent.all[i].title:Show()
            end
        end
        UpdateScrollChildSize()
        TJ.exportTJFrame:UpdateText()
    end

    function parent.SetAutoChoose()
        TJ.ClearTJ()
        local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
        if TuanJian.MOPTJ.num == 2 then
            if TuanJian.MOPTJ.type == "mage" then
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s2)
                        TJ.SetBoardEditFormNum(v, 1, nil, s3)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s2)
                        TJ.SetBoardEditFormNum(v, 2, nil, s3)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        if not done[1] then
                            TJ.SetBoardEditFormNum(v, 1, nil, s5)
                            done[1] = true
                        elseif not done[2] then
                            TJ.SetBoardEditFormNum(v, 2, nil, s5)
                            done[2] = true
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s6)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s6)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s7)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s7)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s1)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s1)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s4)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s4)
                        done[2] = true
                    end
                end
            elseif TuanJian.MOPTJ.type == "physics" then
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s2)
                        TJ.SetBoardEditFormNum(v, 1, nil, s3)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s2)
                        TJ.SetBoardEditFormNum(v, 2, nil, s3)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        if not done[1] then
                            TJ.SetBoardEditFormNum(v, 1, nil, s5)
                            done[1] = true
                        elseif not done[2] then
                            TJ.SetBoardEditFormNum(v, 2, nil, s5)
                            done[2] = true
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s6)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s6)
                        done[2] = true
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if not done[1] then
                        TJ.SetBoardEditFormNum(v, 1, nil, s7)
                        done[1] = true
                    elseif not done[2] then
                        TJ.SetBoardEditFormNum(v, 2, nil, s7)
                        done[2] = true
                    end
                end
            end
        elseif TuanJian.MOPTJ.num == 3 then
            if TuanJian.MOPTJ.type == "mage" then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = 3, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s4)
                            done[i] = true
                            break
                        end
                    end
                end
            elseif TuanJian.MOPTJ.type == "physics" then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = 3, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 3, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end
            end
        elseif TuanJian.MOPTJ.num == 4 then
            if TuanJian.MOPTJ.type == "mage" then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local startIndex = #tbl + 1
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 4, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = 4, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 4, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = 4, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s4)
                            done[i] = true
                            break
                        end
                    end
                end
            elseif TuanJian.MOPTJ.type == "physics" then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local startIndex = #tbl + 1
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s7)
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, 4, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = 4, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = 4, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end
            end
        elseif TuanJian.MOPTJ.num >= 5 then
            if TuanJian.MOPTJ.type == "mage" then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local startIndex = #tbl + 1
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, TuanJian.MOPTJ.num, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s7)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, TuanJian.MOPTJ.num, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = TuanJian.MOPTJ.num, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = TuanJian.MOPTJ.num, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = TuanJian.MOPTJ.num, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s4)
                            done[i] = true
                            break
                        end
                    end
                end
            elseif TuanJian.MOPTJ.type == "physics" then
                local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
                for i, v in ipairs(tbl) do
                    TJ.SetBoardEditFormNum(v, i, nil, s2)
                    TJ.SetBoardEditFormNum(v, i, nil, s3)
                end

                local startIndex = #tbl + 1
                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, TuanJian.MOPTJ.num, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s7)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
                for i, v in ipairs(tbl) do
                    for i = startIndex, TuanJian.MOPTJ.num, 1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s6)
                            done[i] = true
                            break
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        for i = TuanJian.MOPTJ.num, 1, -1 do
                            if not done[i] then
                                TJ.SetBoardEditFormNum(v, i, nil, s5)
                                done[i] = true
                                break
                            end
                        end
                    end
                end

                local done = {}
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    for i = TuanJian.MOPTJ.num, 1, -1 do
                        if not done[i] then
                            TJ.SetBoardEditFormNum(v, i, nil, s1)
                            done[i] = true
                            break
                        end
                    end
                end
            end
        end
    end
end)
