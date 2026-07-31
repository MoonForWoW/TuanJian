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
    local mainFrame = TJ.tjMainFrame
    local FB = "TJ"
    local bossIndex = 1
    TJ[FB] = {}
    TJ.frame[FB] = {}
    TJ.frame[FB][bossIndex] = mainFrame
    TuanJian[FB] = TuanJian[FB] or {}
    TuanJian[FB][bossIndex] = TuanJian[FB][bossIndex] or {}
    if TJ.verLess3 then
        -- 神圣牺牲
        if TJ.IsWLK then
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local text = L["优先安排奶骑，其次防骑。"]
            local f = TJ.CreateTitle("TJ", 1, AutoFuc, "spell_holy_powerwordbarrier", L["神圣牺牲"],
                text, { "PALADIN" }, nil, nil, nil,
                nil, 4)
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 20, -50)
            TJ.CreateEdit(FB, bossIndex, L["1大牺"])
            TJ.CreateEdit(FB, bossIndex, L["2大牺"])
            TJ.CreateEdit(FB, bossIndex, L["3大牺"])
            TJ.CreateEdit(FB, bossIndex, L["4大牺"])
        end

        -- 光环掌握
        if TJ.IsWLK then
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local text = L["优先安排奶骑，其次惩戒骑。"]
            TJ.CreateTitle("TJ", 1, AutoFuc, "spell_holy_auramastery", L["光环掌握"],
                text, { "PALADIN" }, nil, nil, nil,
                nil, 4)
            TJ.CreateEdit(FB, bossIndex, L["1光掌"])
            TJ.CreateEdit(FB, bossIndex, L["2光掌"])
            TJ.CreateEdit(FB, bossIndex, L["3光掌"])
            TJ.CreateEdit(FB, bossIndex, L["4光掌"])
        end

        -- 牺牲之手
        do
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local text = L["优先安排奶骑，其次防骑/惩戒骑。"]
            local f = TJ.CreateTitle("TJ", 1, AutoFuc, "spell_holy_sealofsacrifice", L["牺牲之手"],
                text, { "PALADIN" }, nil, nil, nil,
                nil, 4)
            if TJ.IsTBC then
                f:ClearAllPoints()
                f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 20, -50)
            end
            TJ.CreateEdit(FB, bossIndex, L["1小牺"])
            TJ.CreateEdit(FB, bossIndex, L["2小牺"])
            TJ.CreateEdit(FB, bossIndex, L["3小牺"])
            TJ.CreateEdit(FB, bossIndex, L["4小牺"])
        end

        -- 神圣赞美诗
        if TJ.IsWLK then
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local text = L["优先安排奶牧，其次暗牧。"]
            TJ.CreateTitle("TJ", 1, AutoFuc, "spell_holy_divinehymn", L["神圣赞美诗"],
                text, { "PRIEST" }, nil, nil, nil,
                nil, 4)
            TJ.CreateEdit(FB, bossIndex, L["1血歌"])
            TJ.CreateEdit(FB, bossIndex, L["2血歌"])
            TJ.CreateEdit(FB, bossIndex, L["3血歌"])
            TJ.CreateEdit(FB, bossIndex, L["4血歌"])
        end

        -- 压制
        do
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    if TuanJian.talentInfo[v.name] == 1 then
                        TJ.SetEditText(v, title)
                    end
                end
            end
            local text = L["安排戒律牧。"]
            TJ.CreateTitle("TJ", 1, AutoFuc, "spell_holy_painsupression", L["痛苦压制"],
                text, { "PRIEST" }, nil, nil, nil,
                nil, 4)
            TJ.CreateEdit(FB, bossIndex, L["1压制"])
            TJ.CreateEdit(FB, bossIndex, L["2压制"])
            TJ.CreateEdit(FB, bossIndex, L["3压制"])
            TJ.CreateEdit(FB, bossIndex, L["4压制"])
        end

        -- 宁静
        if TJ.IsTitan then
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps2", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps1", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local text = L["优先安排奶德，其次鸟德/猫德。"]
            TJ.CreateTitle("TJ", 1, AutoFuc, "spell_nature_tranquility", L["宁静"],
                text, { "DRUID" }, nil, nil, nil,
                nil, 4)
            TJ.CreateEdit(FB, bossIndex, L["1宁静"])
            TJ.CreateEdit(FB, bossIndex, L["2宁静"])
            TJ.CreateEdit(FB, bossIndex, L["3宁静"])
            TJ.CreateEdit(FB, bossIndex, L["4宁静"])
        end

        -- 树皮
        if TJ.IsTitan then
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local text = L["安排奶德。"]
            TJ.CreateTitle("TJ", 1, AutoFuc, "spell_nature_stoneclawtotem", L["树皮术"],
                text, { "DRUID" }, nil, nil, nil,
                nil, 4)
            TJ.CreateEdit(FB, bossIndex, L["1树皮"])
            TJ.CreateEdit(FB, bossIndex, L["2树皮"])
            TJ.CreateEdit(FB, bossIndex, L["3树皮"])
            TJ.CreateEdit(FB, bossIndex, L["4树皮"])
        end

        -- 战复
        do
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps2", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps1", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local text = L["优先安排奶德，其次鸟德/猫德。"]
            TJ.CreateTitle("TJ", 1, AutoFuc, "spell_nature_reincarnation", L["战复"],
                text, { "DRUID" }, nil, nil, nil,
                nil, 4)
            TJ.CreateEdit(FB, bossIndex, L["1战复"])
            TJ.CreateEdit(FB, bossIndex, L["2战复"])
            TJ.CreateEdit(FB, bossIndex, L["3战复"])
            TJ.CreateEdit(FB, bossIndex, L["4战复"])
        end

        -- 激活
        do
            local function AutoFuc(title)
                local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
                local tbl = TJ.SortRaidRosterInfo({ "PRIEST", "SHAMAN" }, "healer", true)
                for i, v in ipairs(tbl) do
                    TJ.SetEditText(v, title)
                end
            end
            local function updateFuc(index)
                local count = 0
                local tbl1 = {}
                local tbl2 = {}
                local tbl3 = {}
                for i, v in ipairs(TJ.raidRosterInfo) do
                    if count >= 4 then break end
                    if v.role ~= "MAINASSIST" and v.class == "DRUID" then
                        if TJ.Isdps2(v) then
                            count = count + 1
                            tinsert(tbl2, v)
                        elseif TJ.Ishealer(v) then
                            count = count + 1
                            tinsert(tbl3, v)
                        elseif TJ.Isdps1(v) then
                            count = count + 1
                            tinsert(tbl1, v)
                        end
                    end
                end
                local function Set(tbl)
                    for i, v in ipairs(tbl) do
                        local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                        TJ.CreateEdit(FB, bossIndex, name, index)
                    end
                end
                Set(tbl2)
                Set(tbl3)
                Set(tbl1)
            end
            local text = L["优先给奶骑，其次其他治疗。"]
            TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_lightning", L["激活"],
                text, TJ.healerClass, updateFuc, nil, nil,
                nil, 4)
        end
    elseif TJ.IsMOP then
        local parent = TJ.frame[FB][bossIndex]
        parent.all = {}
        local function CreateTitle(name)
            local f = CreateFrame("Frame", nil, parent)
            f:SetSize(70, 20)
            if next(parent.all) then
                local last = parent.all[#parent.all].title
                f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -48)
            else
                f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 10, -50)
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

            local playerEdit = CreateFrame("EditBox", nil, title, "TuanJian_InputBoxTemplate")
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

            local spellEdit = CreateFrame("EditBox", nil, title, "TuanJian_InputBoxTemplate")
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
        for i = 1, 5 do
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
            elseif TuanJian.MOPTJ.num == 5 then
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
                        for i = startIndex, 5, 1 do
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
                        for i = startIndex, 5, 1 do
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
                            for i = 5, 1, -1 do
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
                        for i = 5, 1, -1 do
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
                        for i = 5, 1, -1 do
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
                        for i = startIndex, 5, 1 do
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
                        for i = startIndex, 5, 1 do
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
                            for i = 5, 1, -1 do
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
                        for i = 5, 1, -1 do
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
                                        text = text ..(text=="" and "" or "\n").. boardTypeName .. "\n" .. _text
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
    end

    -- 重置
    do
        local bt = CreateFrame("Button", nil, mainFrame)
        bt:SetSize(18, 18)
        bt:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", -20, 23)
        bt:SetNormalTexture("interface/raidframe/readycheck-notready")
        bt:SetHighlightTexture("interface/raidframe/readycheck-notready")
        bt:RegisterForClicks("AnyUp")
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            TJ.ClearTJ()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置"], 1, 1, 1, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    function TJ.ClearTJ()
        for _, v in ipairs(TJ.frame[FB][bossIndex].all) do
            for _, vv in ipairs(v.edits) do
                if TJ.IsWLK then
                    vv.edit:ClearAll()
                elseif TJ.IsMOP then
                    vv.playerEdit:ClearAll()
                    vv.spellEdit:ClearAll()
                end
            end
        end
    end

    function TJ.exportTJButton_UpdateShow()
        if not TJ.exportTJButton then return end
        local width = TJ.exportTJFrame.width
        if TJ.tjMainFrame:IsVisible() then
            TJ.exportTJButton:ClearAllPoints()
            TJ.exportTJButton:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPRIGHT", -30, -1)
            TJ.exportTJButton:Show()

            TJ.exportTJFrame:ClearAllPoints()
            TJ.exportTJFrame:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT")
            TJ.exportTJFrame:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", width, 0)
            TJ.exportTJFrame.CloseButton:ClearAllPoints()
            TJ.exportTJFrame.CloseButton:SetPoint("TOPRIGHT", 5, 5)
            TJ.exportTJFrame.parent = TJ.frame["TJ"][1]
            TJ.exportTJFrame.frameType = "TJ"
        elseif TJ.dpsMainFrame:IsVisible() then
            TJ.exportTJButton:Show()
            TJ.exportTJButton:ClearAllPoints()
            TJ.exportTJButton:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPRIGHT", -30, -1)

            TJ.exportTJFrame:ClearAllPoints()
            TJ.exportTJFrame:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT")
            TJ.exportTJFrame:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", width, 0)
            TJ.exportTJFrame.CloseButton:ClearAllPoints()
            TJ.exportTJFrame.CloseButton:SetPoint("TOPRIGHT", 5, 5)
            TJ.exportTJFrame.parent = TJ.frame["DPS"][1]
            TJ.exportTJFrame.frameType = "DPS"
        elseif TJ.raidMainFrame:IsVisible() then
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            local board = TJ.frame[FB][bossIndex].board
            if board then
                TJ.exportTJButton:ClearAllPoints()
                TJ.exportTJButton:SetPoint("LEFT", board.boardTipsText, "RIGHT", 10, 0)
                TJ.exportTJButton:Show()

                TJ.exportTJFrame:ClearAllPoints()
                TJ.exportTJFrame:SetPoint("TOPLEFT", board, "TOPLEFT", -width, 0)
                TJ.exportTJFrame:SetPoint("BOTTOMRIGHT", board, "BOTTOMLEFT", 0, 0)
                TJ.exportTJFrame.CloseButton:ClearAllPoints()
                TJ.exportTJFrame.CloseButton:SetPoint("TOPLEFT", -5, 5)
                TJ.exportTJFrame.parent = board
                TJ.exportTJFrame.frameType = "board"
            else
                TJ.exportTJButton:Hide()
            end
        else
            TJ.exportTJButton:Hide()
        end
        TJ.exportTJFrame:UpdateText()
    end
end)


--[[
        local bt = TJ.CreateButton(mainFrame)
        bt:SetSize(25, 25)
        bt:SetPoint("RIGHT", TJ.autoButton, "LEFT", -0, 0)
        bt:SetText("▼")
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if TJ.DropDownListIsVisible(self) then
                _G.L_DropDownList1:Hide()
            else
                local tbl1 = {
                    -- { name = L["全减伤"], key = "all" },
                    { name = L["物理减伤"], key = "physics" },
                    { name = L["魔法减伤"], key = "mage" },
                }
                local menu = {}
                tinsert(menu,
                    {
                        text = L["减伤类型"],
                        isTitle = true,
                        notCheckable = true,
                    }
                )
                for i, v in ipairs(tbl1) do
                    tinsert(menu, {
                        text = v.name,
                        checked = TuanJian.MOPTJ.type == v.key,
                        func = function()
                            TuanJian.MOPTJ.type = v.key
                        end
                    })
                end
                tinsert(menu,
                    {
                        text = L["减伤轮数"],
                        isTitle = true,
                        notCheckable = true,
                    }
                )
                for i = 2, #parent.all do
                    tinsert(menu, {
                        text = i .. L["轮"],
                        checked = TuanJian.MOPTJ.num == i,
                        func = function()
                            TuanJian.MOPTJ.num = i
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
                LibBG:EasyMenu(menu, TJ.dropDown, self, 0, 0, "MENU", 2)
            end
        end)
 ]]
