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

local rowHeight = 18
local editHeight = 20

function TJ.GetToolCombatInfo(info)
    if not (info and info[1]) then return info end
    local filter = TuanJian.options and TuanJian.options.toolCombatFrameFilter
    if not (filter and next(filter)) then return info end

    local newInfo = {}
    for _, v in ipairs(info) do
        if not (v.key and filter[v.key]) then
            tinsert(newInfo, v)
        end
    end
    if not newInfo[1] then
        wipe(filter)
        return info
    end
    return newInfo
end

function TJ.CreateTitle(FB, bossIndex, AutoFuc, icon, name,
                          autoText, classTbl, updateFuc, info, tipsText,
                          showTitleName, arrange, cantSend)
    local parent = TJ.frame[FB][bossIndex]
    parent.all = parent.all or {}
    TuanJian[FB][bossIndex][#parent.all + 1] = TuanJian[FB][bossIndex][#parent.all + 1] or {}
    local f = CreateFrame("Frame", nil, parent)
    f:SetSize(150, editHeight)
    f.AutoFuc = AutoFuc
    f.autoText = autoText
    f.classTbl = classTbl
    f.row = 1
    f.arrange = arrange or 3
    if TJ.IsTBC and icon == "Spell_Deathknight_BloodPresence" then
        icon = "spell_holy_devotionaura"
    end
    f.icon = type(icon) == "string" and "Interface\\Icons\\" .. icon or icon
    f.name = name
    f.updateFuc = updateFuc
    f.info = info
    f.showTitleName = showTitleName
    f.canSend = not cantSend
    f.index = #parent.all + 1
    if next(parent.all) then
        local last = parent.all[#parent.all].title
        f:SetPoint("TOPLEFT", last, "BOTTOMLEFT", 0, -25 - (last.row - 1) * (rowHeight + editHeight))
    else
        f:SetPoint("TOPLEFT", TJ.raidChild, "TOPLEFT", 10, -25)
    end
    local t = f:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
    t:SetAllPoints()
    t:SetText("|T" .. f.icon .. ":18:18|t" .. name .. L["："])
    t:SetJustifyH("RIGHT")
    t:SetWordWrap(false)
    t.owner = f
    f.Text = t
    tinsert(parent.all, {
        title = f,
        titleName = name,
        edits = {},
    })
    f.edits = parent.all[#parent.all].edits

    if updateFuc then
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
        bt:SetPoint("RIGHT", f, "RIGHT", -t:GetUnboundedStringWidth() - 5, 0)
        bt:RegisterForClicks("AnyUp")
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(name, 1, 1, 1, true)
            GameTooltip:AddLine(tipsText or L["该项目在有合适的职业和天赋时才可选择。"], 1, 0.82, 0, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    TJ.OnEnterDelay(f, function(self)
        f = TJ.combatFrameMany[1]
        if not (f and f:IsVisible()) then
            self:SetCombatFrame()
        end
    end, 0.1)
    TJ.OnLeaveDelay(f, function(self)
        f = TJ.combatFrameMany[1]
        if f and not f.click then
            f:Hide()
        end
    end)
    f:HookScript("OnEnter", function(self)
        if not self.ds then
            self.ds = f:CreateTexture()
            self.ds:SetAllPoints()
            self.ds:SetColorTexture(0, 0, 0, 0.3)
            self.ds:Hide()
        end
        local event, eventInfo = TJ.GetCombatLogEvent()
        if eventInfo and eventInfo.titleColor and eventInfo.titleColor[self.index] == 1 then
            self.ds:Show()
        end
    end)
    f:HookScript("OnLeave", function(self)
        if self.ds then
            self.ds:Hide()
        end
    end)
    f:SetScript("OnMouseDown", function(self)
        local f = TJ.combatFrameMany[1]
        if f and f:IsVisible() then
            if f:GetParent() == self then
                if f.click then
                    f:Hide()
                else
                    for i, f in ipairs(TJ.combatFrameMany) do
                        TJ.SetCombatFrameIsClick(f)
                    end
                end
            else
                f:Hide()
                self:SetCombatFrame(true)
            end
        else
            self:SetCombatFrame(true)
        end
    end)

    function f:SetCombatFrame(click)
        local processorKey = GetTime()
        TJ.ReSetCombatFrame()
        TJ.combatFrameProcessors[processorKey] = true
        TJ.combatFrameDropDownPahse = nil
        local combatInfo = self.isToolCombat and TJ.GetToolCombatInfo(info) or info
        -- local combatInfo = info
        if combatInfo and combatInfo[1] then
            TJ.CreateCombatFrame(self, processorKey, combatInfo[1], nil, 1, combatInfo, click)
        else
            TJ.CreateCombatFrame(self, processorKey, combatInfo, nil, nil, nil, click)
        end
    end

    function f:UpdatePoint()
        if self.index ~= 1 then
            local upTitle = parent.all[self.index - 1].title
            self:ClearAllPoints()
            self:SetPoint("TOPLEFT", upTitle, "BOTTOMLEFT",
                0, -25 - (upTitle.row - 1) * (rowHeight + editHeight))
        end
    end

    function f.Text:UpdateColor(callback)
        local event, eventInfo = TJ.GetCombatLogEvent()
        if eventInfo and eventInfo.titleColor and eventInfo.titleColor[self.owner.index] then
            if eventInfo.titleColor[self.owner.index] == 1 then
                self:SetTextColor(0, 1, 0)
            else
                self:SetTextColor(1, 1, 1)
            end
            callback()
        else
            local tbl = {
                FB = FB,
                bossIndex = bossIndex,
                callback = callback,
            }
            self:SetTextColor(1, 1, 1)
            if eventInfo and eventInfo.titleColor then
                eventInfo.titleColor[self.owner.index] = 0
            end
            local processorKey = GetTime()
            TJ.ReSetCombatFrame()
            TJ.combatFrameProcessors[processorKey] = true
            TJ.combatFrameDropDownPahse = nil
            local combatInfo = self.owner.isToolCombat and TJ.GetToolCombatInfo(info) or info
            if combatInfo and combatInfo[1] then
                TJ.CreateCombatFrame(self.owner, processorKey, combatInfo[1], tbl, 1, combatInfo)
            else
                TJ.CreateCombatFrame(self.owner, processorKey, combatInfo, tbl)
            end
        end
    end

    function f.Text:ClearColor()
        self:SetTextColor(1, 1, 1)
    end

    return f
end

function TJ.CreateEdit(FB, bossIndex, name, index, list)
    local all = TJ.frame[FB][bossIndex].all
    index = index or #all
    local title = all[index].title
    local edits = all[index].edits
    local edit = CreateFrame("EditBox", nil, title, TJ.editTemplate)
    edit:SetSize(100, editHeight)
    if #edits == 0 then
        edit:SetPoint("LEFT", title, "RIGHT", 10, 0)
    elseif #edits % title.arrange == 0 then
        edit:SetPoint("TOPLEFT", edits[#edits - (title.arrange - 1)].edit, "BOTTOMLEFT", 0, -rowHeight)
    else
        edit:SetPoint("LEFT", edits[#edits].edit, "RIGHT", 10, 0)
    end
    edit:SetAutoFocus(false)
    edit.titleIndex = index
    edit.i = #edits + 1
    edit.titleName = all[index].titleName
    edit.myName = name
    edit.edits = edits
    edit.title = title
    title.row = floor(#edits / title.arrange) + 1
    title.list = list
    tinsert(edits, {
        edit = edit,
        editName = name,
    })
    local _index = edit.i
    if title.updateFuc then
        _index = TJ.ClearCode(name)
    end
    local db = TuanJian[FB][bossIndex][edit.titleIndex][_index]
    if db then
        local r, g, b = GetClassColor(db.class)
        edit:SetText(db.text)
        edit:SetCursorPosition(0)
        edit:SetTextColor(r, g, b)
        edit.player = db.player
        edit.class = db.class
        edit.role = db.role
        edit.combatRole = db.combatRole
        edit.talent = db.talent
    end
    edit:HookScript("OnTextChanged", function(self)
        if self:GetText() == "" then
            self:ClearAll()
        else
            self:Save()
        end
        if FB == "DPS" then
            TJ.exportTJFrame:UpdateText()
        end
    end)
    edit:HookScript("OnEditFocusGained", function(self)
        TJ.lastfocus = self
        TJ.ListPlayer(self, title.classTbl, nil, list)
    end)
    edit:HookScript("OnEditFocusLost", function(self)
        if TJ.FramePlayerList then
            TJ.FramePlayerList:Hide()
        end
    end)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnTabPressed", function(self)
        if edits[self.i + 1] then
            edits[self.i + 1].edit:SetFocus()
        elseif edits[1] then
            edits[1].edit:SetFocus()
        end
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

    function edit:ClearAll()
        self:SetText("")
        self:SetTextColor(1, 1, 1)
        self.player = nil
        self.class = nil
        self.role = nil
        self.combatRole = nil
        self.talent = nil
        local _index = self.i
        if self.title.updateFuc then
            _index = TJ.ClearCode(self.myName)
        end
        TuanJian[FB][bossIndex][self.titleIndex][_index] = nil
    end

    function edit:Save()
        local _index = self.i
        if title.updateFuc then
            _index = TJ.ClearCode(name)
        end
        TuanJian[FB][bossIndex][edit.titleIndex][_index] = {
            text = self:GetText(),
            player = self.player,
            class = self.class,
            role = self.role,
            combatRole = self.combatRole,
            talent = self.talent,
        }
    end

    if TJ.lastFocusSpecial then
        local i, ii = strsplit("-", TJ.lastFocusSpecial)
        if tonumber(i) == index and tonumber(ii) == edit.i then
            edit:SetFocus()
        end
    end

    local t = edit:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
    t:SetPoint("BOTTOM", edit, "TOP", 0, 0)
    t:SetSize(edit:GetWidth(), 15)
    t:SetTextColor(1, 0.82, 0)
    t:SetText(name)
    t:SetWordWrap(false)

    return edit
end

function TJ.CreateSPTitle(FB, bossIndex, destNPCID, func)
    -- 团减
    local info
    if TJ.IsWLK then
        info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            31821, -- 光掌
                        },
                        colorNum = 4
                    },
                    {
                        spellID = {
                            70940, -- 大牺牲

                        },
                        colorNum = 1
                    },
                    {
                        spellID = {
                            1282057, -- 集结
                        },
                        colorNum = 1
                    },
                },
                destNpcType = { "Player" },
                onlyShowMe = { 70940, 31821, 64843, 48447, 48446, 26983, 1282057 },
            },
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            64843,               -- 血歌
                            48447, 48446, 26983, -- 宁静
                        },
                        colorNum = 1
                    },
                },
            },
            notShowDead = true,
            title = { name = L["团减"], icon = "spell_holy_powerwordbarrier" }
        }
    elseif TJ.IsMOP then
        info = {
            castSuccess = {
                type = "s",
                spell = {
                    {
                        spellID = {
                            15286,  -- 吸血鬼
                            109964, -- 灵魂护壳
                            108281, -- 先祖指引
                        },
                        colorNum = 5
                    },
                    {
                        spellID = {
                            114049, -- 升腾
                        },
                        colorNum = 4,
                        combatRole = { "Ishealer" },
                    },
                    {
                        spellID = {
                            64843,  -- 血歌
                            740,    -- 宁静
                            108280, -- 治疗之潮图腾
                            115310, --  还魂术
                            97462,  -- 集结呐喊
                        },
                        colorNum = 4,
                    },
                    {
                        spellID = {
                            31821,  -- 虔诚光环
                            62618,  -- 真言术：障
                            114203, -- 挫志战旗
                            51052,  -- 反魔法领域
                            98008,  -- 灵魂链接图腾
                            76577,  -- 烟雾弹
                        },
                        colorNum = 1
                    },
                },
                showCount = true,
                showIcon = true,
            },
            notShowDead = true,
            title = { name = L["团减"], icon = "spell_holy_powerwordbarrier" }
        }
    end
    if info then
        TJ.combatInfoMore = info
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_powerwordbarrier", L["团减"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    else
        TJ.combatInfoMore = {}
    end
    -- 个减
    local info
    if TJ.verLess3 then
        info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        -- ZS
                        {
                            spellID = {
                                871,   -- 盾墙
                                12976, -- 破斧
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        {
                            spellID = {
                                46947, -- 捍卫
                            },
                            frameLevel = 4,
                            combatRole = { "Istank" },
                        },
                        -- XD
                        {
                            spellID = {
                                61336,          -- 生存本能
                                22812, 1283513, -- 树皮
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        -- FQ
                        {
                            spellID = {
                                498,   -- 圣佑
                                -- 1038,  -- 拯救
                                6940,  -- 小牺牲
                                20236, -- 圣疗
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        -- DK
                        {
                            spellID = {
                                48792,   -- 冰封
                                55233,   -- 吸血鬼
                                70654,   -- 4T10
                                42650,   -- 大军
                                1282315, -- 符文刃舞
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        {
                            spellID = {
                                48707, -- 反魔法护罩
                            },
                            frameLevel = 5,
                            combatRole = { "Istank" },
                        },
                        -- MS
                        {
                            spellID = {
                                33206, -- 压制
                                47788, -- 守护之魂
                            },
                            frameLevel = 3,
                            combatRole = { "Istank" },
                        },
                        -- 饰品
                        {
                            spellID = {
                                71638, 71635 -- 完美之牙
                            },
                            frameLevel = 2,
                            combatRole = { "Istank" },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["坦克个减"], icon = "spell_holy_restoration" }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                15359, 16237,
                            },
                            frameLevel = 1,
                            colorNum = 5,
                            combatRole = { "Istank" },
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["灵感"], icon = "spell_holy_layonhands" }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = {
                                64859,
                            },
                            frameLevel = 1,
                            colorNum = 5,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { name = L["利刃屏障"], icon = "ability_upgrademoonglaive" }
            },
            isMany = true
        }
    elseif TJ.IsMOP then
        info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        -- ZS
                        {
                            spellID = {
                                871,   -- 盾墙
                                12976, -- 破斧
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        {
                            spellID = {
                                114029, -- 捍卫
                                114030, -- 警戒
                            },
                            colorNum = 4,
                            frameLevel = 4,
                            combatRole = { "Istank" },
                        },
                        -- XD
                        {
                            spellID = {
                                22812, -- 树皮
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        {
                            spellID = {
                                61336, -- 生存本能
                            },
                            frameLevel = 2,
                            combatRole = { "Istank" },
                        },
                        -- FQ
                        {
                            spellID = {
                                498, -- 圣佑
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        -- QS
                        {
                            spellID = {
                                6940, -- 小牺牲
                            },
                            colorNum = 4,
                            frameLevel = 3,
                            combatRole = { "Istank" },
                        },
                        -- DK
                        {
                            spellID = {
                                48792, -- 冰封
                                55233, -- 吸血鬼
                                42650, -- 大军
                                81256, -- 符文刃舞
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        {
                            spellID = {
                                48707, -- 反魔法护罩
                            },
                            frameLevel = 2,
                            combatRole = { "Istank" },
                        },
                        -- MS
                        {
                            spellID = {
                                33206, -- 压制
                                47788, -- 守护之魂
                            },
                            colorNum = 4,
                            frameLevel = 3,
                            combatRole = { "Istank" },
                        },
                        -- 武僧
                        {
                            spellID = {
                                120954, -- 壮胆酒
                                122278, -- 躯不坏
                                122783, -- 散魔功
                            },
                            frameLevel = 1,
                            combatRole = { "Istank" },
                        },
                        {
                            spellID = {
                                116849, --  作茧缚命
                            },
                            colorNum = 4,
                            frameLevel = 3,
                            combatRole = { "Istank" },
                        },
                        -- 特殊BOSS给的技能
                        {
                            spellID = {
                                106466, -- 巨龙之魂8号梦境
                            },
                            colorNum = 6,
                            frameLevel = 10,
                            combatRole = { "Istank" },
                        },
                    },
                    notShowStackCount = true,
                    destNpcType = { "Player" },
                },
                title = { name = L["坦克个减"], icon = "spell_holy_restoration" }
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        -- DK
                        {
                            spellID = {
                                49222, -- 白骨之盾
                            },
                            colorNum = 5,
                            frameLevel = 0,
                            combatRole = { "Istank" },
                        },
                        -- 武僧
                        {
                            spellID = {
                                115307, -- 酒醒入定
                            },
                            colorNum = 5,
                            frameLevel = 0,
                            combatRole = { "Istank" },
                        },
                    },
                    notShowStackCount = true,
                    destNpcType = { "Player" },
                },
                title = { name = L["坦克常驻减伤"], icon = "ability_monk_shuffle" }
            },
        }
    end
    TJ.combatInfoTank = info
    local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_holy_restoration", TJ.IsTBC and L["坦克个减"] or L["个减"],
        nil, nil, nil, info)
    TJ.AddSPTitle(FB, bossIndex, f)
    -- 工具人
    local info
    if TJ.verLess3 then
        info = {
            {
                key = "sunder",
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["破甲"],
                        },
                    },
                    destNPCID = destNPCID,
                },
                func = func,
                title = { icon = 8647, name = L["破甲"] },
                notShowDead = true,
            },
            {
                key = "infusion_frenzy",
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["灌注"],
                        },
                        {
                            spellID = ns.sp["狂乱"],
                            colorNum = 4,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { icon = 10060, name = L["能量灌注 / %s狂乱"]:format(TJ.AddIconBySpellID(49016)) },
                notShowDead = true,
            },
            {
                key = "misdirect_tricks",
                aura = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["嫁祸"],
                        },
                        {
                            spellID = ns.sp["误导光环"],
                            colorNum = 4,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["误导"],
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { icon = 34477, name = L["误导 / %s嫁祸"]:format( TJ.AddIconBySpellID(57933)) },
                notShowDead = true,
            },
            {
                key = "faerie_fire",
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["精灵之火"],
                        },
                    },
                },
                title = { icon = 770, name = L["精灵之火"] },
                notShowDead = true,
            },
            {
                key = "innervate",
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["激活"],
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { icon = 29166, name = L["激活"] },
                notShowDead = true,
            },
            {
                key = "battle_res",
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["战复"],
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { icon = 48477, name = L["战复"] },
                notShowDead = true,
            },
            {
                key = "air_totem",
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = ns.sp["空气图腾"],
                        },
                    },
                    destNpcType = { "Player" },
                },
                title = { icon = 2895, name = L["空气图腾"] },
                notShowDead = true,
            },
        }
        if TJ.IsTitan then
            tinsert(info, 2, {
                key = "demonic_pact",
                trigger = {
                    type = "s",
                    spell = {
                        {
                            spellID = {
                                TJ.SSpowerSpell,
                            },
                            tooltipText = TJ.AddIconBySpellID(TJ.SSpowerSpell) .. L["恶魔契约"],
                        },
                    },
                },
                title = { icon = TJ.SSpowerSpell, name = L["恶魔契约"] },
                canSend = false,
                notShowDead = true,
                SSpowerSpell=true,
            })
        end
    elseif TJ.IsMOP then
        info = {
            {
                key = "damage_buff",
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["风暴之鞭"],
                            colorNum = "SM",
                        },
                        {
                            spellID = ns.sp["颅骨"],
                            colorNum = "ZS",
                        },
                    },
                    showCount = true,
                },
                title = { icon = 120668, name = L["增伤"] },
                notShowDead = true,
            },
            {
                key = "misdirect_tricks",
                aura = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["嫁祸"],
                        },
                        {
                            spellID = ns.sp["误导"],
                            colorNum = 1,
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { icon = 34477, name = L["误导 / %s嫁祸"]:format(TJ.AddIconBySpellID(57933)) },
                notShowDead = true,
            },
            {
                key = "battle_res",
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = ns.sp["战复"],
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                title = { icon = 20484, name = L["战复"] },
                notShowDead = true,
            },
        }
    end
    local f = TJ.CreateTitle(FB, bossIndex, nil, TJ.IsMOP and "ability_shaman_tranquilmindtotem" or "ability_warrior_riposte", L["工具人"],
        nil, nil, nil, info)
    f.isToolCombat = true
    f.toolCombatInfo = info
    TJ.AddSPTitle(FB, bossIndex, f)
    -- 爆发药水
    local info
    if TJ.IsTBC then
        info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            28714, -- 烈焰菇
                        },
                        colorNum = 2,
                    },
                    {
                        spellID = {
                            28506, -- 英雄药水
                        },
                        colorNum = 8,
                    },
                    {
                        spellID = {
                            28494, -- 疯狂力量药水
                        },
                        colorNum = 8,
                    },
                    {
                        spellID = {
                            28507, -- 加速药水
                        },
                        colorNum = 4,
                    },
                    {
                        spellID = {
                            28508, -- 毁灭药水
                        },
                        colorNum = 1,
                    },
                    {
                        spellID = {
                            28515, -- 铁盾药水
                        },
                        colorNum = 5,
                    },


                },
                showCount = true,
            },
            title = { name = L["爆发药水"], icon = 53908 },
            showRaidMember = L["未吃爆发药水"],
            canSend = "count",
            notShowDead = true,
        }
    elseif TJ.IsWLK then
        info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            28714, -- 烈焰菇
                        },
                        colorNum = 2,
                    },
                    {
                        spellID = {
                            53908, -- 速度药水
                        },
                        colorNum = 4,
                    },
                    {
                        spellID = {
                            53909, -- 狂野魔法药水
                        },
                        colorNum = 1,
                    },
                    {
                        spellID = {
                            53762, -- 不灭药水
                        },
                        colorNum = 5,
                    },
                    {
                        spellID = {
                            1282971, -- 狂野魔精 -- 时光服
                        },
                        colorNum = 6,
                    },
                },
                showCount = true,
            },
            title = { name = L["爆发药水"], icon = 53908 },
            showRaidMember = L["未吃爆发药水"],
            canSend = "count",
            notShowDead = true,
        }
    elseif TJ.IsCTM then
        info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            79634, 79633, 79476, 79475, -- 力量、敏捷、智力、护甲
                        },
                        colorNum = 1,
                    },
                },
                showCount = true,
            },
            title = { name = L["爆发药水"], icon = 53908 },
            showRaidMember = L["未吃爆发药水"],
            canSend = "count",
            notShowDead = true,
        }
    elseif TJ.IsMOP then
        info = {
            aura = {
                type = "d",
                spell = {
                    {
                        spellID = {
                            105706, 105697, 105702, 105698, -- 力量、敏捷、智力、护甲
                        },
                        colorNum = 1,
                    },
                },
                destNpcType = { "Player" },
                showCount = true,
            },
            title = { name = L["爆发药水"], icon = 53908 },
            showRaidMember = L["未吃爆发药水"],
            canSend = "count",
            notShowDead = true,
        }
    end
    local f = TJ.CreateTitle(FB, bossIndex, nil, TJ.IsTBC and "inv_potion_108" or "inv_alchemy_elixir_04", TJ.IsTBC and L["爆发药水"] or L["吃药"],
        nil, nil, nil, info)
    TJ.AddSPTitle(FB, bossIndex, f)
    -- 死亡
    local info = {
        dead = {
            destNpcType = { "Player" },
        }
    }
    local f = TJ.CreateTitle(FB, bossIndex, nil, "ability_rogue_feigndeath", L["死亡"],
        nil, nil, nil, info)
    TJ.AddSPTitle(FB, bossIndex, f)
end

local maxNum = TJ.IsTBC and 4 or 5
function TJ.AddSPTitle(FB, bossIndex, f)
    if not TJ.spChild[FB .. bossIndex] then
        TJ.spChild[FB .. bossIndex] = {}
    end
    f:ClearAllPoints()
    if next(TJ.spChild[FB .. bossIndex]) then
        local index = #TJ.spChild[FB .. bossIndex] + 1
        if index <= maxNum then
            f:SetPoint("LEFT", TJ.spChild[FB .. bossIndex][index - 1], "RIGHT", 0, 0)
        elseif index == maxNum + 1 then
            f:SetPoint("TOPLEFT", TJ.spChild[FB .. bossIndex][1], "BOTTOMLEFT", 0, -10)
        elseif (index - (maxNum + 1)) % 4 == 0 then
            f:SetPoint("TOPLEFT", TJ.spChild[FB .. bossIndex][index - 4], "BOTTOMLEFT", 0, -10)
        else
            f:SetPoint("LEFT", TJ.spChild[FB .. bossIndex][index - 1], "RIGHT", 0, 0)
        end
    else
        f:SetPoint("LEFT", TJ.spChild.title, "RIGHT", 0, 0)
    end
    f.Text:SetText("|T" .. f.icon .. ":18:18|t" .. f.name)
    f.Text:SetJustifyH("CENTER")
    f:SetWidth(f.Text:GetUnboundedStringWidth() + 10)
    tinsert(TJ.spChild[FB .. bossIndex], f)
end

--[[
/run TJ.spChild[TuanJian.FB .. TuanJian.bossIndex][1]:Show()
 ]]

function TJ.SetAutoChoose()
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    if TJ.tjMainFrame:IsVisible() then
        if TJ.IsMOP then
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
    TJ.PairAllMap(function(map)
        map:ClearAll()
    end)
    for i, v in ipairs(parent.all) do
        local title = v.title
        local edits = v.edits
        for i, vv in ipairs(edits) do
            vv.edit:SetText("")
        end
        if title.AutoFuc then
            title:AutoFuc()
        end
    end
    local board = parent.board
    if board then
        TJ.PairAllEdit_Board(function(edit)
            edit:ClearAll()
        end)
        board.AutoFuc()
    end
end
--[[ 
/dump TJ.frame['TOC'][6].board.AutoFuc
]]
function TJ.GetAllQuestText(OnEnter)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local isMOPTJ, isBoard
    if TJ.BoardVerFrame.sendButton.isEnter then
        isBoard = true
    elseif TJ.tjMainFrame:IsVisible() then
        if TJ.IsMOP then
            isMOPTJ = true
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
    local parent
    local tbl = { {} }
    local playerTbl = {}
    local point = TJ.GetRaidPoint()
    if isBoard then
        local board = TJ.frame[FB][bossIndex].board
        if board.GetAllQuestText then return board:GetAllQuestText(OnEnter) end
        local boardID = TuanJian[FB][bossIndex].lastBoard
        local boardType = TJ.ClearCode(board.tabButton[boardID]:GetText(), nil, OnEnter)
        parent = board.child[boardID]
    else
        parent = TJ.frame[FB][bossIndex]
    end
    if isMOPTJ or isBoard then
        for i, v in ipairs(parent.all) do
            local titleName = v.titleName
            local players = {}
            local playerCount = 0
            for _, vv in ipairs(v.edits) do
                local player = vv.playerEdit:GetText()
                local spell = vv.spellEdit:GetText()
                if player ~= "" and spell ~= "" then
                    if OnEnter then
                        local r, g, b = vv.playerEdit:GetTextColor()
                        player = ns.RGB_16(player, r, g, b)
                    else
                        player = TJ.ClearCode(player)
                    end
                    spell = TJ.ClearCode(spell, true)
                    playerCount = playerCount + 1
                    players[player] = players[player] or {
                        count = playerCount,
                        player = player,
                        spell = {},
                    }
                    tinsert(players[player].spell, spell)
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
                local nowI = 1
                local sum = #newTbl
                for _ = 1, 3 do
                    local isEnd
                    local text = "{rt1}" .. titleName
                    for i = nowI, sum do
                        nowI = i
                        local v = newTbl[i]
                        local spellStr = ""
                        for _, _spellStr in ipairs(v.spell) do
                            spellStr = spellStr .. _spellStr
                        end
                        local newText = text .. (i == 1 and "" or " + ") .. v.player .. spellStr
                        if not OnEnter then
                            local clear = newText:gsub("|c.-|Hspell:.-|h(%[.-%]|h|r)", "%1")
                            if #clear > 240 then
                                break
                            end
                        end
                        text = newText
                        tinsert(playerTbl, {
                            player = v.player,
                            quest = titleName .. spellStr,
                        })
                        if i == sum then
                            isEnd = true
                        end
                    end
                    tinsert(tbl[1], text)
                    if isEnd then
                        break
                    end
                end
            end
        end
    else
        for _, v in ipairs(parent.all) do
            local title = v.title
            if title.canSend then
                local notWhisper = title.list
                local titleName = v.titleName
                local edits = v.edits

                local nowI = 1
                local sum = #edits
                for _ = 1, 3 do
                    local isEnd
                    local text = "{rt1}"
                    local first = true
                    for i = nowI, sum do
                        nowI = i
                        local vv = edits[i]
                        local editName, editName_clear, playerEdit, player
                        editName = vv.editName
                        editName_clear = TJ.ClearCode(editName)
                        player = vv.edit:GetText()
                        playerEdit = vv.edit
                        local editNameIsNot = editName == ""
                        if player ~= "" then
                            if OnEnter then
                                local r, g, b = playerEdit:GetTextColor()
                                player = ns.RGB_16(player, r, g, b)
                            else
                                player = TJ.ClearCode(player)
                                editName = TJ.ClearCode(editName)
                            end
                            local newText = ""
                            if title.updateFuc then
                                if TJ.raidRosterName[editName_clear] then
                                    newText = text .. (first and titleName .. " " or L["，"]) .. player .. ":" .. editName
                                else
                                    newText = text .. (first and "" or L["，"]) .. editName .. ":" .. player
                                end
                            elseif first and title.showTitleName then
                                newText = text .. titleName .. L["："] .. (editNameIsNot and editName or editName .. ":") .. player
                            else
                                newText = text .. (first and "" or L["，"]) .. (editNameIsNot and editName or editName .. ":") .. player
                            end
                            if not OnEnter then
                                if #newText > 240 then
                                    break
                                end
                                if TJ.raidRosterName[player] and not notWhisper then
                                    if title.updateFuc then -- 动态生成的输入框
                                        if TJ.raidRosterName[editName] then
                                            tinsert(playerTbl, {
                                                player = editName,
                                                quest = titleName .. point[player] .. player,
                                            })
                                        else
                                            tinsert(playerTbl, {
                                                player = player,
                                                quest = editName,
                                            })
                                        end
                                    else
                                        tinsert(playerTbl, {
                                            player = player,
                                            quest = (title.showTitleName and titleName or "") .. editName,
                                        })
                                    end
                                end
                            end
                            text = newText
                            first = nil
                        end
                        if i == sum then
                            isEnd = true
                        end
                    end
                    if text ~= "{rt1}" then
                        tinsert(tbl[1], text)
                    end
                    if isEnd then
                        break
                    end
                end
            end
        end
    end
    return tbl, playerTbl
end

function TJ.PairAllEdit(func)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    if TJ.tjMainFrame:IsVisible() then
        if TJ.IsMOP then
            TJ.PairAllEdit_TJPlayer(func)
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
    if parent.all then
        for i, v in ipairs(parent.all) do
            local title = v.title
            local edits = v.edits
            for i, vv in ipairs(edits) do
                local edit = vv.edit
                func(edit, title)
            end
        end
    end
end

function TJ.UpdateEditIcon()
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    if TJ.tjMainFrame:IsVisible() then
        if TJ.IsMOP then
            TJ.UpdateEditIcon_TJ()
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
    if TJ.frame[FB][bossIndex]:IsVisible() then
        for i, v in ipairs(TJ.raidRosterInfo) do
            TJ.PairAllEdit(function(edit)
                if edit.player == v.name then
                    local text = TJ.GetIconAndName(v, edit.talent)
                    edit:SetText(text)
                    local name = TJ.ClearCode(edit.myName)
                    if TuanJian[FB][bossIndex][edit.titleIndex][name] then
                        TuanJian[FB][bossIndex][edit.titleIndex][name].text = text
                        TuanJian[FB][bossIndex][edit.titleIndex][name].role = v.role
                        TuanJian[FB][bossIndex][edit.titleIndex][name].combatRole = v.combatRole
                    end
                end
            end)
        end
    end
end

function TJ.UpdateSpecialEdit()
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    if TJ.tjMainFrame:IsVisible() then
        if TJ.IsMOP then
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
    if TJ.frame[FB][bossIndex]:IsVisible() then
        if TJ.frame[FB][bossIndex].all then
            TJ.lastFocusSpecial = nil
            local function func(FB, bossIndex)
                for i, v in ipairs(TJ.frame[FB][bossIndex].all) do
                    if v.title.updateFuc then
                        for ii, vv in ipairs(v.edits) do
                            if vv.edit:HasFocus() then
                                TJ.lastFocusSpecial = i .. "-" .. ii
                            end
                            vv.edit:Hide()
                        end
                        wipe(v.edits)
                        v.title.updateFuc(i)
                        v.title:UpdatePoint()
                    end
                end
            end
            func(FB, bossIndex)
        end
        -- local FB = TuanJian.FB
        -- local bossIndex = TuanJian.bossIndex
        -- if TJ.frame[FB][bossIndex].all then
        --     TJ.lastFocusSpecial = nil
        --     func(FB, bossIndex)
        -- end
        -- After(0, function()
        --     local FB = "TJ"
        --     local bossIndex = 1
        --     if TJ.frame[FB][bossIndex].all then
        --         TJ.lastFocusSpecial = nil
        --         func(FB, bossIndex)
        --     end
        -- end)
    end
end

local function UpdateCombatTitleText()
    local title = TJ.spChild.title
    local combatLog = TJ.GetCombatLog()
    if (combatLog and combatLog.event and next(combatLog.event)) or TJ.GetCombatLogEvent() then
        title.Text:SetText(L["战斗分析："])
    else
        title.Text:SetText(L["战斗分析（无）："])
    end
    title.tips:SetPoint("RIGHT", title, "RIGHT", -title.Text:GetUnboundedStringWidth() - 2, 0)
end
function TJ.UpdateTitleColor(FB, bossIndex)
    if not TJ.raidMainFrame:IsVisible() then return end
    UpdateCombatTitleText()
    local FB = FB or TuanJian.FB
    local bossIndex = bossIndex or TuanJian.bossIndex
    if FB == TJ.combatLastFB and bossIndex == TJ.combatLastBossIndex then return end
    local f = TJ.combatFrameMany[1]
    if f and f:IsVisible() then return end
    if TJ.GetCombatLogEvent() then
        local parent = TJ.frame[FB][bossIndex]
        local i = 1
        if parent.all[i] then
            local function callback()
                i = i + 1
                if i > #parent.all then return end
                local title = parent.all[i].title
                if title then
                    title.Text:UpdateColor(callback)
                end
            end
            parent.all[i].title.Text:UpdateColor(callback)
        end
    end
end

function TJ.ClearTitleColor(FB, bossIndex)
    local FB = FB or TuanJian.FB
    local bossIndex = bossIndex or TuanJian.bossIndex
    local parent = TJ.frame[FB][bossIndex]
    for i = 1, #parent.all do
        local title = parent.all[i].title
        if title then
            title.Text:ClearColor()
        end
    end
end

function TJ.ClearQuest(_FB, _bossIndex)
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
                    if parent and parent.all then
                        for i, v in ipairs(parent.all) do
                            local edits = v.edits
                            for i, vv in ipairs(edits) do
                                vv.edit:ClearAll()
                            end
                        end
                    end
                end
            end
        end
    end
end
