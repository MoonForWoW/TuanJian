local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L
local AddTexture = ns.AddTexture
local Round = ns.Round
local GetGUID = TJ.GetGUID

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")

TJ.cacheCombatRole = {}

local width = 750
local height = 100
local leftWidth = 120
local rightWidth = -40
local topHeight = -45
local lwidth = width - leftWidth + rightWidth
local btHeight = 16
local offsetTime = 0.1
local offsetTime2 = 1

local alpha = .8
local colorTbl = {
    [1] = { 1, 1, 0, alpha },    -- 黄
    [2] = { 1, .6, .8, alpha },  -- 粉
    [3] = { 1, 0, 0, 1 },        -- 红
    [4] = { 1, .6, 0, alpha },   -- 橙
    [5] = { .6, .6, .6, alpha }, -- 灰
    [6] = { .2, .6, 1, alpha },  -- 蓝
    [7] = { 0, .5, 0, alpha },   -- 绿
    [8] = { .5, 0, 0, alpha },   -- 浅红
    [9] = { .8, .6, 1, alpha },  -- 浅紫
    ["ZS"] = { .78, .61, .43 },
    ["SM"] = { .14, .35, 1 },
}

--[[
战士 #C69B6D 198, 155, 109
萨满 #2359FF 35, 89, 255
]]

local function GetNameByGUID(GUID)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local combat = TJ.GetCombatLog()
    if combat.guid then
        return combat.guid[GUID].name or ""
    end
end

-- -- 创建Bar
local function CreateBar(f, v, playerText)
    local combatLog = TJ.GetCombatLog()
    local duration = combatLog.duration
    local guidTbl = combatLog.guid
    local index = playerText.index
    local barTbl = playerText.barTbl

    local bar = CreateFrame("StatusBar", nil, f, "BackdropTemplate")
    bar:SetBackdrop({
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 2,
    })
    bar:SetBackdropBorderColor(1, 1, 1, 0)
    bar:SetPoint("TOPLEFT", f, "TOPLEFT",
        f.leftWidth + f.lwidth * ((v.bar_startTime or v.startTime) / duration),
        f.topHeight - (index - 1) * btHeight - 2)
    bar:SetPoint("BOTTOMRIGHT", f, "TOPLEFT",
        f.leftWidth + f.lwidth * ((v.bar_endTime or v.endTime) / duration),
        f.topHeight - btHeight - (index - 1) * btHeight + 2)
    bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
    bar:SetStatusBarColor(unpack(colorTbl[v.colorNum]))
    bar.v = v
    bar.playerText = playerText
    bar.guidTbl = guidTbl
    bar.playerTextGUID = playerText.GUID
    bar.tooltip = v.tooltip
    bar.tooltipText = v.tooltipText
    bar.frame = f
    if v.stackCount and not v.notShowStackCount then
        local t = bar:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 10, "OUTLINE")
        t:SetPoint("CENTER", 0, 0)
        t:SetHeight(bar:GetHeight())
        t:SetText(v.stackCount)
        bar.stackText = t
    end
    if v.barText then
        local t = bar:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 11, "OUTLINE")
        t:SetPoint("LEFT", bar, "RIGHT", 0, 0)
        t:SetText(v.barText(v.spellID))
    end
    if not v.isdead then
        local tbl = {}
        if bar.tooltip:match("HLKwuran") then
            local t = bar:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
            t:SetPoint("LEFT", bar, "RIGHT", 2, 0)
            t:SetTextColor(1, 1, 1)
            local time = TJ.GetHLKwuran(bar) or L["没有使用"]
            t:SetText(time)
            tbl = {
                time = v.endTime,
                player = playerText.name,
                wuran = time,
            }
        end
        tinsert(playerText.barInfo, tbl)
    end
    tinsert(barTbl, bar)
    bar:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
        GameTooltip:ClearLines()
        local i = 0
        local frameScale = TJ.combatFrame:GetScale()
        local uiScale, _x, _y = UIParent:GetEffectiveScale(), GetCursorPosition()
        local x, y = (_x / uiScale), (_y / uiScale)
        local offSet = .01
        sort(barTbl, function(a, b)
            return a.v.frameLevel > b.v.frameLevel
        end)
        for _, bar in ipairs(barTbl) do
            local left = bar:GetLeft() * frameScale
            local right = bar:GetRight() * frameScale
            local top = bar:GetTop() * frameScale
            local bottom = bar:GetBottom() * frameScale
            if x >= left - offSet and x <= right + offSet and y <= top + offSet and y >= bottom - offSet then
                i = i + 1
                if i >= 2 then
                    GameTooltip:AddLine(" ")
                end
                TJ.CombatFrameAddText(bar)
                if v.tooltip == "Heal" or v.tooltip:match("health") or v.tooltip:match("died") then
                    break
                end
            end
        end
        GameTooltip:Show()

        if not self.ds then
            local tex = f:CreateTexture()
            tex:SetPoint("TOPLEFT", playerText, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", playerText, "BOTTOMRIGHT", f.lwidth, 0)
            tex:SetColorTexture(1, 1, 1, 0.2)
            self.ds = tex
        end
        self.ds:Show()
    end)
    bar:SetScript("OnLeave", function(self)
        for i, bar in ipairs(barTbl) do
            bar:SetBackdropBorderColor(1, 1, 1, 0)
        end
        GameTooltip:Hide()
        if self.ds then
            self.ds:Hide()
        end
    end)
    if type(v.spellID) == 'number' and v.spellID > 0 then
        if v.spellID == 1 then
            v.spellName = L["平砍"]
            v.icon = "Interface\\Icons\\ability_steelmelee"
        else
            v.icon = C_Spell.GetSpellTexture(v.spellID)
            TJ.OnSpellLoad(v.spellID, function()
                if not v.spellName then
                    v.spellName = C_Spell.GetSpellName(v.spellID)
                end
            end)
        end
    end
    if type(v.spellID2) == 'number' and v.spellID2 > 0 then
        if v.spellID2 == 1 then
            v.spellName2 = L["平砍"]
            v.icon2 = "Interface\\Icons\\ability_steelmelee"
        else
            v.icon2 = C_Spell.GetSpellTexture(v.spellID2)
            TJ.OnSpellLoad(v.spellID2, function()
                v.spellName2 = C_Spell.GetSpellName(v.spellID2)
            end)
        end
    end
    if v.showIcon and v.icon then
        local tex = bar:CreateTexture(nil, "OVERLAY")
        tex:SetPoint("LEFT")
        tex:SetSize(btHeight - 2, btHeight - 2)
        tex:SetTexture(v.icon)
        tex:SetTexCoord(unpack(TJ.iconTexCoord))
        bar:SetFrameLevel(f:GetFrameLevel() + #barTbl)
    else
        bar:SetFrameLevel(f:GetFrameLevel() + v.frameLevel)
    end
end

local function CreateMoneyFrame(parent, button)
    if TJ.combatFrame.moneyFrame then
        TJ.combatFrame.moneyFrame:Hide()
    end

    local type, r, g, b, Sure
    if button == "LeftButton" then
        type, r, g, b = 0, 1, 0, 0
    else
        type, r, g, b = 1, 0, 1, 0
    end

    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    do
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, 0.9)
        f:SetBackdropBorderColor(r, g, b, .8)
        f:SetSize(200, 130)
        f:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", 0, 0)
        f:SetClampedToScreen(true)
        f:EnableMouse(true)
        -- f:SetToplevel(true)
        f:SetMovable(true)
        f:SetFrameLevel(140)
        TJ.combatFrame.moneyFrame = f
        f:SetScript("OnMouseUp", function(self)
            self:StopMovingOrSizing()
        end)
        f:SetScript("OnMouseDown", function(self)
            if TJ.lastfocus then
                TJ.lastfocus:ClearFocus()
            end
            self:StartMoving()
        end)

        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("TOP", 0, -5)
        t:SetTextColor(parent.Text:GetTextColor())
        t:SetText(parent.Text:GetText())

        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 16, "OUTLINE")
        t:SetPoint("TOP", 5, -25)
        t:SetText(type == 0 and L[">>罚款<<"] or L[">>奖励<<(添加在支出项)"])
        t:SetTextColor(r, g, b)
    end
    -- 输入框
    do
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("TOPLEFT", 5, -50)
        t:SetText(L["缘由："])
        t:SetWidth(60)
        t:SetJustifyH("RIGHT")

        local edit = CreateFrame("EditBox", nil, f, TJ.editTemplate)
        edit:SetSize(f:GetWidth() - t:GetWidth() - 30, 20)
        edit:SetPoint("LEFT", t, "RIGHT", 5, 0)
        edit:SetText(parent:GetParent().titleName ..
            (parent.info and parent.info.dead and format(L["(%s)"], TJ.bossNameText:GetText()) or ""))
        edit:SetAutoFocus(false)
        f.nameEdit = edit
        edit:HookScript("OnEditFocusGained", function(self)
            TJ.lastfocus = self
        end)
        edit:HookScript("OnEnterPressed", function(self)
            f.moneyEdit:SetFocus()
        end)
        edit:HookScript("OnTabPressed", function(self)
            f.moneyEdit:SetFocus()
        end)

        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("TOPLEFT", 5, -70)
        t:SetText(L["金额："])
        t:SetWidth(60)
        t:SetJustifyH("RIGHT")

        local edit = CreateFrame("EditBox", nil, f, TJ.editTemplate)
        edit:SetSize(f:GetWidth() - t:GetWidth() - 30, 20)
        edit:SetPoint("LEFT", t, "RIGHT", 5, 0)
        edit:SetNumeric(true)
        edit:SetText(TuanJian.FKmoney)
        edit:SetAutoFocus(false)
        f.moneyEdit = edit
        edit:HookScript("OnTextChanged", function(self)
            TuanJian.FKmoney = self:GetText()
            f.sureButton:Update()
        end)
        edit:HookScript("OnEditFocusGained", function(self)
            TJ.lastfocus = self
        end)
        edit:SetScript("OnEscapePressed", function(self)
            self:ClearFocus()
        end)
        edit:HookScript("OnEnterPressed", function(self)
            Sure()
        end)
        edit:HookScript("OnTabPressed", function(self)
            f.nameEdit:SetFocus()
        end)
        edit:SetFocus()
    end

    local bt = TJ.CreateButton(f)
    bt:SetSize(80, 25)
    bt:SetPoint("BOTTOMRIGHT", f, "BOTTOM", -5, 10)
    bt:SetText(L["确定"])
    f.sureButton = bt
    bt:SetScript("OnClick", function(self)
        TJ.PlaySound(1)
        Sure()
    end)
    function bt:Update()
        local money = f.moneyEdit:GetText()
        if not money or money == "" then
            self:Disable()
        else
            self:Enable()
        end
    end

    f.sureButton:Update()

    local bt = TJ.CreateButton(f)
    bt:SetSize(80, 25)
    bt:SetPoint("BOTTOMLEFT", f, "BOTTOM", 5, 10)
    bt:SetText(CANCEL)
    bt:SetScript("OnClick", function(self)
        TJ.PlaySound(1)
        f:Hide()
    end)

    function Sure()
        if not f.sureButton:IsEnabled() then return end
        local name = f.nameEdit:GetText()
        local buyer = TJ.ClearCode(parent.Text:GetText())
        local color = { parent.Text:GetTextColor() }
        local money = f.moneyEdit:GetText()
        local FB = TJ.GetFB()
        local BG = _G.BG
        if type == 0 then
            local b = BG.Maxb[FB]
            for i = 1, BG.GetMaxi(FB, b) do
                local zhuangbei = BG.Frame[FB]["boss" .. b]["zhuangbei" .. i]
                local maijia = BG.Frame[FB]["boss" .. b]["maijia" .. i]
                local jine = BG.Frame[FB]["boss" .. b]["jine" .. i]
                if zhuangbei:GetText() == "" and maijia:GetText() == "" and jine:GetText() == "" and
                    not BiaoGe[FB]["boss" .. b]["qiankuan" .. i] then
                    zhuangbei:SetText(name)
                    maijia:SetText(buyer)
                    maijia:SetTextColor(unpack(color))
                    jine:SetText(money)
                    BiaoGe[FB]["boss" .. b]["zhuangbei" .. i] = name
                    BiaoGe[FB]["boss" .. b]["maijia" .. i] = buyer
                    BiaoGe[FB]["boss" .. b]["jine" .. i] = money
                    BiaoGe[FB]["boss" .. b]["qiankuan" .. i] = money
                    BG.Frame[FB]["boss" .. b]["qiankuan" .. i]:Show()
                    ns.SendSystemMessage(format(L["|cffff0000已增加罚款：|r%s %s %s"], name, ns.RGB_16(buyer, unpack(color)),
                        money))
                    f:Hide()
                    return
                end
            end
        else
            local b = BG.Maxb[FB] + 1
            for i = 1, BG.GetMaxi(FB, b) do
                local zhuangbei = BG.Frame[FB]["boss" .. b]["zhuangbei" .. i]
                local jine = BG.Frame[FB]["boss" .. b]["jine" .. i]
                if zhuangbei:GetText() == "" and jine:GetText() == "" then
                    zhuangbei:SetText(format("%s(%s) ", name, buyer))
                    jine:SetText(money)
                    BiaoGe[FB]["boss" .. b]["zhuangbei" .. i] = name
                    BiaoGe[FB]["boss" .. b]["jine" .. i] = money
                    ns.SendSystemMessage(format(L["|cff00ff00已增加支出：|r%s %s %s"], name, ns.RGB_16(buyer, unpack(color)),
                        money))
                    f:Hide()
                    return
                end
            end
        end
        f:Hide()
        ns.SendSystemMessage(format(L["|cffff0000错误：格子满了！"]))
    end
end
local function CreatePlayerText(index, name, class, num)
    local f = TJ.combatFrame
    local r, g, b = 1, .82, 0
    if class then
        r, g, b = GetClassColor(class)
    end
    local playerText = CreateFrame("Frame", nil, f)
    playerText:SetSize(f.leftWidth - 10, btHeight)
    playerText:SetPoint("TOPRIGHT", f, "TOPLEFT", f.leftWidth, f.topHeight - (index - 1) * btHeight)
    playerText:SetFrameLevel(TJ.combatFrame:GetFrameLevel() + 10)
    playerText.name = name
    playerText.name2 = TJ.GetIconFormName(name)
    playerText.color = { r, g, b }
    local t = playerText:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
    t:SetAllPoints()
    t:SetTextColor(r, g, b)
    t:SetText(playerText.name2)
    t:SetJustifyH("RIGHT")
    t:SetWordWrap(false)
    playerText.Text = t
    playerText:SetScript("OnMouseDown", function(self, button)
        if not (BiaoGe and _G.BG.Maxb and class and (button == "LeftButton" or button == "RightButton")) then return end
        CreateMoneyFrame(self, button)
    end)
    playerText:SetScript("OnEnter", function(self)
        if not class then return end
        GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(t:GetText(), r, g, b, true)
        GameTooltip:AddLine(AddTexture("LEFT") .. L["增加罚款"], 1, 1, 1, true)
        GameTooltip:AddLine(AddTexture("RIGHT") .. L["增加奖励"], 1, 1, 1, true)
        GameTooltip:Show()
        if not self.ds then
            local tex = f:CreateTexture()
            tex:SetPoint("TOPLEFT", self, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", f.lwidth, 0)
            tex:SetColorTexture(1, 1, 1, 0.2)
            self.ds = tex
        end
        self.ds:Show()
    end)
    playerText:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        if self.ds then
            self.ds:Hide()
        end
    end)
    return playerText
end
local function CreateCountNum(playerText, num)
    local t = playerText:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 11, "OUTLINE")
    t:SetPoint("LEFT", playerText, "RIGHT", -2, 0)
    t:SetTextColor(unpack(playerText.color))
    t:SetText(format("(%s)", num or ""))
    return num
end
local function UpdateRT(playerText, v)
    local ty
    if playerText.GUID == v.sourceGUID then
        ty = v.sourceRT
    elseif playerText.GUID == v.destGUID then
        ty = v.destRT
    end
    if ty then
        playerText.Text:SetText(TJ.GetRTIcon(ty) .. playerText.name2)
    end
end
local function CreatePlayerFrame(playerTbl, auraTbl, func, setNum)
    local combatLog = TJ.GetCombatLog()
    local guidTbl = combatLog.guid
    local f = TJ.combatFrame
    for index, aura in ipairs(auraTbl) do
        local GUID = aura.GUID
        local info = aura.info
        local playerText
        for _, _playerText in ipairs(playerTbl) do
            if info.onlyShowOnePlayer then
                if _playerText.name == guidTbl[GUID].name then
                    playerText = _playerText
                    break
                end
            else
                if _playerText.GUID == GUID then
                    playerText = _playerText
                    break
                end
            end
        end
        if not playerText then
            playerText = CreatePlayerText(#playerTbl + 1, guidTbl[GUID].name, guidTbl[GUID].class)
            playerText.GUID = GUID
            playerText.sourceGUID = aura.sourceGUID
            playerText.destGUID = aura.destGUID
            playerText.index = #playerTbl + 1
            playerText.barTbl = {}
            playerText.barInfo = {}
            playerText.info = aura.info
            tinsert(playerTbl, playerText)
        end

        local tbl
        if func then
            sort(auraTbl[index], function(a, b)
                return a.time < b.time
            end)
            tbl = func(aura)
            if aura.durTimeMin then
                for i = #tbl, 1, -1 do
                    if tbl[i].endTime - tbl[i].startTime <= aura.durTimeMin then
                        tremove(tbl, i)
                    end
                end
            end
        else
            sort(auraTbl[index], function(a, b)
                if a.startTime and b.startTime then
                    return a.startTime < b.startTime
                end
            end)
            tbl = aura
        end
        if setNum then
            local num
            if type(setNum) == "function" then
                num = setNum(tbl)
            else
                num = #tbl
            end
            playerText.count = CreateCountNum(playerText, num)
        end
        for _, v in ipairs(tbl) do
            if next(v) then
                CreateBar(f, v, playerText)
                UpdateRT(playerText, v)
            end
        end
    end
end

local function SortTbl(auraTbl)
    local newTbl = {}
    for _, aura in pairs(auraTbl) do
        tinsert(newTbl, aura)
    end
    sort(newTbl, function(a, b)
        return a.raidIndex < b.raidIndex
    end)
    return newTbl
end

local function ShowRaidMember_FiterCombatRole(v)
    if TJ.IsWLK then
        return not TJ.Ishealer(v)
    elseif TJ.IsMOP then
        return TJ.Isdps(v)
    end
end

local function CheckTime(infoType, lastTime, GUID, t)
    if (infoType == "beDamage2" or infoType == "damageFriend") and lastTime[GUID] then
        local offset = infoType == "beDamage2" and offsetTime or offsetTime2
        for _, _t in ipairs(lastTime[GUID]) do
            if math.abs(t - _t) <= offset then
                return false
            end
        end
    end
    return true
end

-- 文本列表
local function CreateTextLog(combatFrame, db)
    After(.5, function()
        if not (combatFrame and combatFrame:IsVisible()) then return end
        local f, child = TJ.CreateScrollFrame(combatFrame, 350, combatFrame:GetHeight(), true)
        f:SetBackdrop(combatFrame:GetBackdrop())
        f:SetBackdropColor(combatFrame:GetBackdropColor())
        f:SetBackdropBorderColor(combatFrame:GetBackdropBorderColor())
        child:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        f:SetPoint("TOPLEFT", combatFrame, "TOPRIGHT", 1, 0)
        local canShow
        local function GetName(guidTbl, GUID)
            local name = guidTbl[GUID].name
            if guidTbl[GUID].class then
                name = "|c" .. select(4, GetClassColor(guidTbl[GUID].class)) .. name .. "|r"
            end
            return name
        end
        for i, bar in ipairs(db) do
            local guidTbl = bar.guidTbl
            local v = bar.v
            local text
            if bar.tooltip == "beDamage" then
                local sourceName = GetName(guidTbl, v.sourceGUID)
                local destName = GetName(guidTbl, v.destGUID)
                local spellText = ""
                if v.spellID then
                    local icon = C_Spell.GetSpellTexture(v.spellID)
                    spellText = AddTexture(icon) .. v.spellName
                else
                    spellText = AddTexture("Interface\\Icons\\ability_steelmelee") .. L[" 平砍"]
                end
                local amount = 0
                if tonumber(v.amount) then
                    amount = TJ.STC_r1(v.amount)
                elseif _G[v.amount] then
                    amount = format(L["0(%s)"], _G[v.amount])
                end
                text = format(L["%s %s %s %s"], sourceName, spellText, destName, amount)
            elseif bar.tooltip:match("trigger") and v.spellID == TJ.SSpowerSpell then
                local sourceName = GetName(guidTbl, v.sourceGUID)
                text = format(L["%s获得恶魔契约（%s点法强）"], sourceName, v.stackCount)
            elseif bar.tooltip:match("castSuccess") then
                -- local sourceName = GetName(guidTbl, v.sourceGUID)
                -- local destName = GetName(guidTbl, v.destGUID)
                -- local spellText = ""
                -- if v.spellID then
                --     local icon = C_Spell.GetSpellTexture(v.spellID)
                --     spellText = AddTexture(icon) .. v.spellName
                -- else
                --     spellText = AddTexture("Interface\\Icons\\ability_steelmelee") .. L[" 平砍"]
                -- end
                -- local text = format(L["%s 施放%s→%s"], sourceName, spellText, destName)
            elseif bar.tooltip:match("died") then
                -- local destName = GetName(guidTbl, v.diedGUID)
                -- local text = format(L["%s 死亡"], destName)
            end
            if text then
                canShow = true
                child:Insert(format('%s %s%s', TJ.STC_dis(TJ.SecondsToTime(v.endTime, 2)),
                    text, (i ~= #db and "\n" or "")))
            end
        end
        if not canShow then
            f:Hide()
        end
    end)
end

-- 通报
local function UpdateSendButtonPoint()
    TJ.combatFrameSendButton:SetParent(TJ.combatFrame)
    TJ.combatFrameSendButton:SetPoint("BOTTOMRIGHT", TJ.combatFrame, "BOTTOMRIGHT", -10, 5)
end
local function CreateSendButton(info, playerTbl, bt, isRefresh)
    if isRefresh and TJ.combatFrameSendButton then
        TJ.combatFrameSendButton:Hide()
    end
    local f = TJ.combatFrame
    local combatLog = TJ.GetCombatLog()
    local guidTbl = combatLog.guid
    local button = TJ.CreateButton(f)
    button:SetSize(100, 25)
    button:SetPoint("BOTTOMRIGHT", -10, 5)
    TJ.combatFrameSendButton = button
    if info.canSend == "HLKwuran" then
        button:SetSize(180, 25)
        button:SetText(L["通报火箭靴反应时间"])
    else
        button:SetText(L["通报"])
    end
    button:SetScript("OnClick", function(self)
        if not IsInRaid(1) then
            ns.SendSystemMessage(L["需要在团队状态才能通报。"])
            return
        end
        self:Disable()
        After(2, function()
            if self then
                self:Enable()
            end
        end)
        TJ.PlaySound(2)
        local tbl = {}
        if info.canSend == "count" then
            for i, v in ipairs(playerTbl) do
                tinsert(tbl, {
                    GUID = v.GUID,
                    name = v.name,
                    text = v.count or 0,
                    -- text = v.barInfo and #v.barInfo or 0,
                })
            end
            sort(tbl, function(a, b)
                return a.text > b.text
            end)
        elseif info.canSend == "dps" or info.canSend == "hps" then
            for i, v in ipairs(playerTbl) do
                tinsert(tbl, {
                    GUID = v.GUID,
                    name = v.name,
                    text = v.text,
                })
            end
            sort(tbl, function(a, b)
                return a.text > b.text
            end)
            for i, v in ipairs(tbl) do
                tbl[i].text = TJ.FormatNumber(tbl[i].text)
            end
        elseif info.canSend == "HLKwuran" then
            for i, playerText in ipairs(playerTbl) do
                for i, v in ipairs(playerText.barInfo) do
                    if next(v) then
                        tinsert(tbl, {
                            GUID = playerText.GUID,
                            name = playerText.name,
                            text = v.wuran,
                            time = v.time,
                        })
                    end
                end
            end
            sort(tbl, function(a, b)
                return a.time < b.time
            end)
        end

        local title
        if info.canSend == "HLKwuran" then
            title = L["污染点名火箭靴反应时间"]
        elseif info.title then
            title = info.title.name
        else
            title = bt.name
        end
        local dropDownName = ""
        if TJ.combatFrameDropDown and TJ.combatFrameDropDown:IsVisible() then
            dropDownName = L["："] .. LibBG:UIDropDownMenu_GetText(TJ.combatFrameDropDown)
        end
        SendChatMessage(format(L["——通报%s——"], title .. dropDownName), "RAID")
        local t = TJ.sendCD
        for i, v in ipairs(tbl) do
            After(t, function()
                local name = v.GUID and guidTbl[v.GUID].name or v.name
                if info.canSend == "HLKwuran" then
                    SendChatMessage(format(L["%s %s：火箭靴%s"], TJ.SecondsToTime(v.time), name, v.text), "RAID")
                else
                    SendChatMessage(format(L["%s. %s：%s"], i, name, v.text), "RAID")
                end
            end)
            t = t + TJ.sendCD
        end
    end)
    if not IsInRaid(1) then
        button:Disable()
    end
end

-- 伤害排名
local function CreateDpsBar(v, i, maxDamage)
    local f = TJ.combatFrame
    local r, g, b = GetClassColor(v.class)
    local bar = CreateFrame("StatusBar", nil, f, "BackdropTemplate")
    bar:SetPoint("TOPLEFT", f, "TOPLEFT",
        f.leftWidth,
        f.topHeight - (i - 1) * btHeight - 2)
    bar:SetPoint("BOTTOMRIGHT", f, "TOPLEFT",
        f.leftWidth + f.lwidth * (v.damage / maxDamage),
        f.topHeight - btHeight - (i - 1) * btHeight + 2)
    bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
    bar:SetStatusBarColor(r, g, b, .8)

    if v.petDamage and v.petDamage > 0 then
        local parent = bar
        local bar = CreateFrame("StatusBar", nil, parent, "BackdropTemplate")
        bar:SetSize(v.petDamage / v.damage * parent:GetWidth(), parent:GetHeight())
        bar:SetPoint("RIGHT")
        bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
        bar:SetStatusBarColor(.4, .8, .94, .8)
        bar:SetStatusBarColor(ns.RGB("66CCFF"))
        bar:SetFrameLevel(parent:GetFrameLevel())
    end

    local damageText = bar:CreateFontString()
    damageText:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
    damageText:SetPoint("LEFT", 2, 0)
    damageText:SetText(TJ.FormatNumber(v.damage))
    damageText:SetJustifyH("LEFT")

    bar:SetScript("OnEnter", function(self)
        if not v.detail then return end
        local newTbl = {}
        for _, vv in pairs(v.detail) do
            tinsert(newTbl, vv)
        end
        sort(newTbl, function(a, b)
            return a.damage > b.damage
        end)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["伤害构成："], 1, 1, 1, true)
        for _, vv in ipairs(newTbl) do
            local petName = ""
            if vv.petGUID then
                petName = GetNameByGUID(vv.petGUID)
                if petName ~= "" then
                    petName = format(L["（%s）"], petName)
                end
            end
            GameTooltip:AddDoubleLine(format("%s%s%s", AddTexture(vv.icon), vv.spellName, petName),
                format("%s（%s%%）", TJ.FormatNumber(vv.damage), Round(vv.damage / v.damage, 2) * 100), 1, 0.82, 0, 1,
                0.82, 0)
        end

        if next(v.petDetail) then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["玩家/宠物："], 1, 1, 1, true)
            local damage = v.damage - v.petDamage
            GameTooltip:AddDoubleLine(ns.RGB_16(v.name, r, g, b),
                format(L["%s（%s%%）"], TJ.FormatNumber(damage), Round(damage / v.damage, 2) * 100))

            local newTbl = {}
            for petName, damage in pairs(v.petDetail) do
                tinsert(newTbl, { petName = petName, damage = damage, })
            end
            sort(newTbl, function(a, b)
                return a.damage > b.damage
            end)
            for _, vv in ipairs(newTbl) do
                GameTooltip:AddDoubleLine(ns.RGB_16(vv.petName, .4, .8, .94),
                    format(L["%s（%s%%）"], TJ.FormatNumber(vv.damage), Round(vv.damage / v.damage, 2) * 100))
            end
        end

        if next(v.destUnit) then
            local newTbl = {}
            for destName, vv in pairs(v.destUnit) do
                tinsert(newTbl, { destName = destName, destGUID = vv.destGUID, damage = vv.damage })
            end
            sort(newTbl, function(a, b)
                return a.damage > b.damage
            end)
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["目标："], 1, 1, 1, true)

            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            local combatLog = TJ.GetCombatLog()
            for _, vv in pairs(newTbl) do
                local r, g, b = 1, .82, 0
                if combatLog.guid[vv.destGUID].class then
                    r, g, b = GetClassColor(combatLog.guid[vv.destGUID].class)
                end
                GameTooltip:AddDoubleLine(ns.SetClassCFF(vv.destName),
                    format(L["%s（%s%%）"], TJ.FormatNumber(vv.damage), Round(vv.damage / v.damage, 2) * 100),
                    r, g, b)
            end
        end
        GameTooltip:Show()
    end)
    bar:SetScript("OnLeave", GameTooltip_Hide)
    bar:SetScript("OnMouseUp", function(self)
        TJ.combatFrameMany[1]:StopMovingOrSizing()
    end)
    bar:SetScript("OnMouseDown", function(self)
        TJ.combatFrameMany[1]:StartMoving()
    end)
end
local function GetDamage(infoType, tbl, v, subevent, GUID, isSpell, petGUID, destGUID, class)
    local num, spellID, spellName, icon
    local amount = 0
    tbl[GUID] = tbl[GUID] or {
        GUID = GUID,
        detail = {},
        damage = 0,
        petDetail = {},
        petDamage = 0,
        destUnit = {},
    }
    if isSpell then
        num = 15
        spellID = v[num - 3]
        spellName = v[num - 2]
        icon = C_Spell.GetSpellTexture(spellID)
    else
        num = 12
        spellID = petGUID or GUID
        spellName = L["平砍"]
        icon = "Interface\\Icons\\ability_steelmelee"
    end
    if infoType == "dps" or infoType == "dps_friend" then
        if subevent:match("_DAMAGE$") then
            local over = v[num + 1] == -1 and 0 or v[num + 1] -- 未过量时为-1
            amount = v[num] - over
        elseif subevent:match("_MISSED$") then
            if v[num] == "ABSORB" then
                amount = v[num + 2]
            end
        end
    elseif infoType == "hps" then
        if subevent:match("_HEAL$") then
            local over = v[num + 1] == -1 and 0 or v[num + 1] -- 未过量时为-1
            amount = v[15] - over
        elseif subevent:match("_HEAL_ABSORBED$") then
            amount = v[22]
        end
    end
    tbl[GUID].detail[spellID] = tbl[GUID].detail[spellID] or {
        damage = 0,
        spellID = spellID,
        spellName = spellName,
        icon = icon,
        petGUID = petGUID,
    }
    tbl[GUID].detail[spellID].damage = tbl[GUID].detail[spellID].damage + amount
    tbl[GUID].damage = tbl[GUID].damage + amount
    if destGUID then
        local destName = GetNameByGUID(destGUID)
        tbl[GUID].destUnit[destName] = tbl[GUID].destUnit[destName] or { destGUID = destGUID, damage = 0 }
        tbl[GUID].destUnit[destName].damage = tbl[GUID].destUnit[destName].damage + amount
    end
    if petGUID then
        local petName = GetNameByGUID(petGUID)
        tbl[GUID].petDetail[petName] = (tbl[GUID].petDetail[petName] or 0) + amount
        tbl[GUID].petDamage = tbl[GUID].petDamage + amount
    end
end

-- 选择每轮伤害
local function RefreshDps()
    local f = TJ.combatFrameMany[1]
    if f then
        f:Hide()
    end
    local processorKey = GetTime()
    TJ.ReSetCombatFrame()
    TJ.combatFrameProcessors[processorKey] = true
    local bt, _, info, updateTitleColor, manyIndex, allInfo = unpack(TJ.combatFrameLastArgs)
    TJ.CreateCombatFrame(bt, processorKey, info, updateTitleColor, manyIndex, allInfo, true, true)
end
local function UpdateDropDownPoint()
    TJ.combatFrameDropDown:SetParent(TJ.combatFrame)
    TJ.combatFrameDropDown:SetPoint("BOTTOM", TJ.combatFrame, "BOTTOM", 0, 0)
end
local function CreateDropDown(dropDownInfo, isRefresh)
    if not TJ.combatFrameDropDown then
        TJ.combatFrameDropDownInfo = {}
        local dropDown = LibBG:Create_UIDropDownMenu(nil, TJ.combatFrame)
        LibBG:UIDropDownMenu_SetWidth(dropDown, 150)
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "BOTTOM", dropDown, "TOP")
        TJ.dropDownToggle(dropDown)
        TJ.combatFrameDropDown = dropDown
        LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
            for _, v in ipairs(TJ.combatFrameDropDownInfo) do
                local info = LibBG:UIDropDownMenu_CreateInfo()
                local text = v.name
                info.text = text
                info.func = function()
                    TJ.combatFrameDropDownPahse = v.pahse
                    LibBG:UIDropDownMenu_SetText(TJ.combatFrameDropDown, v.name)
                    RefreshDps()
                end
                info.checked = LibBG:UIDropDownMenu_GetText(dropDown) == text
                LibBG:UIDropDownMenu_AddButton(info)
            end
        end)
    end
    UpdateDropDownPoint()
    if not isRefresh then
        local tbl = {}
        if dropDownInfo.key then
            for i, v in ipairs(TJ.GetCombatLog().otherTime) do
                if v.name then
                    local num = v.name:match(dropDownInfo.key)
                    if num then
                        tinsert(tbl, {
                            name = dropDownInfo.name:format(num) .. L["（%s）"]:format(TJ.SecondsToTime(v.startTime)),
                            pahse = v.name,
                        })
                    end
                end
            end
        end
        tinsert(tbl, {
            name = L["全程"],
            pahse = nil,
        })
        TJ.combatFrameDropDownInfo = tbl
        LibBG:UIDropDownMenu_SetText(TJ.combatFrameDropDown, L["全程"])
    end
end

-- 工具人过滤
local function RefreshToolCombatFrame(title)
    local event, eventInfo = TJ.GetCombatLogEvent()
    if title and eventInfo and eventInfo.titleColor then
        eventInfo.titleColor[title.index] = nil
    end
    local f = TJ.combatFrameMany[1]
    if f then
        f:Hide()
    end
    if title and title.SetCombatFrame then
        title:SetCombatFrame(true)
    end
end

local function GetToolCombatTitle(info)
    if type(info.title) == "table" then
        local tex = info.title.icon and
            (type(info.title.icon) == "string" and "Interface\\Icons\\" .. info.title.icon or
                C_Spell.GetSpellTexture(info.title.icon))
        return AddTexture(tex) .. (info.title.name or "")
    end
    return info.title or ""
end

local function NormalizeToolCombatFrameFilter(allInfo)
    if not (allInfo and allInfo[1]) then return end
    local filter = TuanJian.options and TuanJian.options.toolCombatFrameFilter
    if not filter then return end

    local count, hidden = 0, 0
    for _, v in ipairs(allInfo) do
        if v.key then
            count = count + 1
            if filter[v.key] then
                hidden = hidden + 1
            end
        end
    end
    if count > 0 and hidden >= count then
        wipe(filter)
    end
end

local function CreateToolCombatSettingButton(f, bt)
    if not (bt and bt.isToolCombat and bt.toolCombatInfo and bt.toolCombatInfo[1]) then return end
    -- manyIndex 是配置项序号；前面的配置没有战斗数据时，首个实际生成的面板
    -- 可能不是 manyIndex == 1。过滤按钮应挂在实际生成的第一个面板上。
    if TJ.combatFrameMany[1] ~= f then return end

    local button = CreateFrame("Button", nil, f)
    button:SetSize(25, 25)
    button:SetPoint("TOPRIGHT", f, "TOPRIGHT", -25, 1)
    button.ownerTitle = bt

    local tex = button:CreateTexture(nil, "ARTWORK")
    tex:SetPoint('CENTER')
    tex:SetSize(18, 18)
    tex:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    button:SetNormalTexture(tex)
    local tex = button:CreateTexture(nil, "ARTWORK")
    tex:SetPoint('CENTER')
    tex:SetSize(18, 18)
    tex:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    button:SetHighlightTexture(tex)

    button:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:AddLine(L["工具人"], 1, 1, 1, true)
        GameTooltip:AddLine(L["选择要显示的战斗分析。"], 1, .82, 0, true)
        GameTooltip:Show()
    end)
    button:SetScript("OnLeave", GameTooltip_Hide)

    if not TJ.toolCombatFrameDropDown then
        local dropDown = LibBG:Create_UIDropDownMenu(nil, f)
        TJ.toolCombatFrameDropDown = dropDown
        LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
            local ownerTitle = TJ.toolCombatFrameDropDownOwner
            local allInfo = ownerTitle and ownerTitle.toolCombatInfo
            if not (allInfo and allInfo[1]) then return end

            TuanJian.options = TuanJian.options or {}
            TuanJian.options.toolCombatFrameFilter = TuanJian.options.toolCombatFrameFilter or {}
            local filter = TuanJian.options.toolCombatFrameFilter

            for _, v in ipairs(allInfo) do
                if v.key then
                    local info = LibBG:UIDropDownMenu_CreateInfo()
                    info.text = GetToolCombatTitle(v)
                    info.checked = function()
                        return not filter[v.key]
                    end
                    info.isNotRadio = true
                    info.keepShownOnClick = true
                    info.func = function()
                        filter[v.key] = not filter[v.key] or nil
                        NormalizeToolCombatFrameFilter(allInfo)
                    end
                    LibBG:UIDropDownMenu_AddButton(info)
                end
            end

            LibBG:UIDropDownMenu_AddSeparator()

            local info = LibBG:UIDropDownMenu_CreateInfo()
            info.text = L["全部勾选"]
            info.notCheckable = true
            info.keepShownOnClick = true
            info.func = function()
                wipe(filter)
                LibBG:UIDropDownMenu_Refresh(dropDown, nil, 1)
            end
            LibBG:UIDropDownMenu_AddButton(info)

            local info = LibBG:UIDropDownMenu_CreateInfo()
            info.text = L["刷新战斗分析"]
            info.notCheckable = true
            info.func = function()
                RefreshToolCombatFrame(ownerTitle)
            end
            LibBG:UIDropDownMenu_AddButton(info)

            local info = LibBG:UIDropDownMenu_CreateInfo()
            info.text = CANCEL
            info.notCheckable = true
            info.func =LibBG.CloseDropDownMenus
            LibBG:UIDropDownMenu_AddButton(info)
        end)
    end

    button:SetScript("OnClick", function(self)
        TJ.toolCombatFrameDropDownOwner = self.ownerTitle
        TJ.toolCombatFrameDropDown:SetParent(f)
        LibBG:ToggleDropDownMenu(1, nil, TJ.toolCombatFrameDropDown, self, 0, 0)
        TJ.PlaySound(1)
    end)

    button:Hide()
    f.ToolCombatSettingButton = button
end

function TJ.SetCombatFrameIsClick(f)
    if f.hasClickFrame then return end
    f.click = true
    f.hasClickFrame = true
    f:EnableMouse(true)
    -- f:SetToplevel(true)
    f:SetMovable(true)
    if f.tipsText then
        f.tipsText:Hide()
    end
    if f.CloseButton then
        f.CloseButton:Show()
    end
    if f.ToolCombatSettingButton then
        f.ToolCombatSettingButton:Show()
    end
    f:SetScript("OnMouseUp", function(self)
        TJ.combatFrameMany[1]:StopMovingOrSizing()
    end)
    f:SetScript("OnMouseDown", function(self)
        TJ.combatFrameMany[1]:StartMoving()
    end)
    if not f.isMany then
        f:SetScript("OnMouseWheel", function(self, wheel)
            local a
            if wheel == 1 then
                a = .2
            else
                a = -.2
            end
            f:SetScale(min(max(f:GetScale() + a, 1), 2))
        end)
    else
        f:SetScript("OnMouseWheel", function(self, wheel)
        end)
    end
end

local function ShowDamageFriendCount(playerTbl, info, infoType)
    local batch = 5000
    local barIndex = 1
    local startIndex = 1
    local eventIndex = 1

    local bars = {}
    for i, playerText in ipairs(playerTbl) do
        for i, bar in ipairs(playerText.barTbl) do
            if bar.tooltip:match(infoType) then
                tinsert(bars, bar)
            end
        end
    end

    local event = TJ.GetCombatLogEvent()
    local events = {}
    for subevent in pairs(event) do
        if TJ.CombatFiterEvent("damage", subevent, info[infoType]) then
            tinsert(events, subevent)
        end
    end

    local function Process()
        local bar = bars[barIndex]
        if not bar or not bar:IsVisible() then
            return
        end
        bar.damageFriendCount = bar.damageFriendCount or 0
        bar.damageFriendPlayers = bar.damageFriendPlayers or {}
        local subevent = events[eventIndex]
        if subevent then
            for i = startIndex, batch + startIndex - 1 do
                local v = event[subevent] and event[subevent][i]
                if v then
                    if infoType == "damageFriend" then
                        if math.abs(v[1] - bar.v.endTime) <= offsetTime2 and v.hp then
                            local sourceGUID = GetGUID(v[4])
                            local destGUID = GetGUID(v[8])
                            if sourceGUID == bar.v.sourceGUID and sourceGUID ~= destGUID then
                                local sourceNpcType = strsplit("-", sourceGUID)
                                if sourceNpcType == "Player" then
                                    local destNpcType = strsplit("-", destGUID)
                                    if destNpcType == "Player" then
                                        if subevent:match("^SWING_") or
                                            not bar.v.spellID or bar.v.spellID and v[12] == bar.v.spellID then
                                            bar.damageFriendCount = bar.damageFriendCount + 1
                                        end
                                    end
                                end
                            end
                        end
                    elseif infoType == "beDamage2" then
                        if math.abs(v[1] - bar.v.endTime) <= offsetTime then
                            local sourceGUID = GetGUID(v[4])
                            if sourceGUID == bar.v.sourceGUID then
                                local destGUID = GetGUID(v[8])
                                local destNpcType = strsplit("-", destGUID)
                                if destNpcType == "Player" then
                                    if subevent:match("^SWING_") or
                                        not bar.v.spellID or bar.v.spellID and v[12] == bar.v.spellID then
                                        bar.damageFriendPlayers[destGUID] = true
                                    end
                                end
                            end
                        end
                    end
                    startIndex = startIndex + 1
                else
                    -- 当前事件已全部处理，处理下一个事件
                    eventIndex = eventIndex + 1
                    startIndex = 1
                    break
                end
            end
        else
            -- 全部事件已经处理完成
            if next(bar.damageFriendPlayers) then
                for k, v in pairs(bar.damageFriendPlayers) do
                    bar.damageFriendCount = bar.damageFriendCount + 1
                end
            end

            barIndex = barIndex + 1
            startIndex = 1
            eventIndex = 1

            local t = bar:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
            t:SetPoint("RIGHT", bar, "LEFT", 1, 0)
            t:SetHeight(bar:GetHeight())
            t:SetText(bar.damageFriendCount)
        end
        After(0, Process)
    end
    After(0, Process)
end

-- WLK恶魔契约
local function SSpowerSpell(playerTbl)
    local maxNum
    for _, playerText in ipairs(playerTbl) do
        local lastBar
        for i, bar in ipairs(playerText.barTbl) do
            if not maxNum then
                maxNum = bar.v.stackCount
            end
            maxNum = max(maxNum, (bar.v.stackCount or 0))
            if lastBar and bar.v.stackCount == lastBar.v.stackCount then
                bar:Hide()
            end
            lastBar = bar
        end
    end
    TJ.combatFrame.titleText:SetText(TJ.combatFrame.titleText:GetText() .. L['（最高%s点法强）']:format(maxNum))
end

TJ.combatFrameMany = {}
TJ.combatFrameProcessors = {}
TJ.combatFrameLastArgs = {}

function TJ.ReSetCombatFrame()
    wipe(TJ.combatFrameMany)
    wipe(TJ.combatFrameProcessors)
end

local batch = 1000
local batch2 = 1000
local startIndex = 1
local eventIndex = 1
local infoIndex = 1
local infos = {}

function TJ.CreateCombatFrame(...)
    local bt, processorKey, info, updateTitleColor, manyIndex, allInfo, click, isRefresh = ...
    local function GoNextUpdateTitleColor()
        updateTitleColor.callback()
    end
    if not info then
        if updateTitleColor then
            GoNextUpdateTitleColor()
        end
        return
    end
    TJ.combatFrameLastArgs = { ... }
    startIndex = 1
    eventIndex = 1
    infoIndex = 1
    wipe(infos)
    wipe(TJ.cacheCombatRole)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local combatLog = TJ.GetCombatLog()
    if not combatLog then return end
    local event, eventInfo = TJ.GetCombatLogEvent()
    local guidTbl = combatLog.guid
    local duration = combatLog.duration
    if not (duration and event) then
        if updateTitleColor then
            GoNextUpdateTitleColor()
        end
        return
    end
    local d = 60 * 5
    local addWidth = max((duration - d), 0)
    local width = width + addWidth
    local lwidth = lwidth + addWidth
    local duration2 = min(duration, d) + addWidth * 0.3

    local parent = bt
    if manyIndex then
        if next(TJ.combatFrameMany) and not TJ.combatFrameMany[#TJ.combatFrameMany]:IsVisible() then
            tremove(TJ.combatFrameMany, #TJ.combatFrameMany)
        end
        if next(TJ.combatFrameMany) then
            parent = TJ.combatFrameMany[#TJ.combatFrameMany]
        else
            parent = bt
        end
    end

    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    if not updateTitleColor then
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, 0.9)
        if manyIndex then
            f:SetBackdropBorderColor(1, 1, 1, 1)
        else
            f:SetBackdropBorderColor(.8, .8, .8, 1)
        end
        if isRefresh then
            f:SetSize(TJ.combatFrameLastWidth, TJ.combatFrameLastHeight)
        else
            f:SetSize(width, height)
        end
        f:SetFrameLevel(128)
        if next(TJ.combatFrameMany) then
            f:SetPoint("BOTTOM", TJ.combatFrameMany[#TJ.combatFrameMany], "TOP", 0, 0)
        else
            f:SetPoint("BOTTOM", bt, "TOP", 0, 5)
        end
        f.width = width
        f.height = height
        f.leftWidth = leftWidth
        f.rightWidth = rightWidth
        f.topHeight = topHeight
        f.lwidth = lwidth
        f.btHeight = btHeight
        f.info = info
        f.isMany = manyIndex
        f.click = click
        if not isRefresh then
            f:Hide()
        end
        TJ.combatFrame = f
        tinsert(TJ.combatFrameMany, f)
        f:SetScript("OnHide", function(self)
            self:Hide()
        end)
    end

    if isRefresh then
        UpdateDropDownPoint()
        UpdateSendButtonPoint()
    end

    -- 标题和关闭按钮
    if not updateTitleColor then
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("TOP", 0, -5)
        t:SetTextColor(1, 1, 1)
        if type(info.title) == "table" then
            local tex = info.title.icon and
                (type(info.title.icon) == "string" and "Interface\\Icons\\" .. info.title.icon or
                    C_Spell.GetSpellTexture(info.title.icon)) or bt.icon
            t:SetText(AddTexture(tex) .. info.title.name)
            f.titleName = info.title.name
            if info.title.color then
                t:SetTextColor(unpack(info.title.color))
            end
        else
            t:SetText(AddTexture(bt.icon) .. bt.name .. (info.title and format(L["（%s）"], info.title) or ""))
            f.titleName = bt.name
        end
        f.frameName = bt.name
        f.titleText=t

        f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 5, 5)
        f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 1)
        f.CloseButton:SetScript("OnClick", function(self)
            if TJ.combatFrameMany[1] and TJ.combatFrameMany[1]:IsVisible() then
                TJ.combatFrameMany[1]:Hide()
            elseif f and f:IsVisible() then
                f:Hide()
            end
        end)

        CreateToolCombatSettingButton(f, bt)

        if not isRefresh then
            f.CloseButton:Hide()
            local t = f:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            t:SetPoint("TOPRIGHT", -5, -5)
            t:SetTextColor(1, .82, 0)
            t:SetText(AddTexture("LEFT") .. L["固定该面板，查看细节"])
            f.tipsText = t
        end
    end

    -- 时间轴
    if not updateTitleColor and not info.dps and not info.hps and not info.dps_friend then
        local l = f:CreateLine()
        l:SetColorTexture(.5, .5, .5)
        l:SetStartPoint("TOPLEFT", leftWidth, topHeight)
        l:SetEndPoint("TOPRIGHT", rightWidth, topHeight)
        l:SetThickness(1.5)

        local l1 = f:CreateLine()
        l1:SetColorTexture(.5, .5, .5)
        l1:SetStartPoint("TOPLEFT", leftWidth, topHeight + 5)
        l1:SetEndPoint("TOPLEFT", leftWidth, topHeight)
        l1:SetThickness(1.5)

        local t = f:CreateFontString(nil, "OVERLAY")
        t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
        t:SetPoint("BOTTOM", l1, "TOP", 0, 0)
        t:SetTextColor(1, 0.82, 0)
        t:SetText("0:00")

        local l2 = f:CreateLine()
        l2:SetColorTexture(.5, .5, .5)
        l2:SetStartPoint("TOPLEFT", leftWidth + lwidth, topHeight + 5)
        l2:SetEndPoint("TOPLEFT", leftWidth + lwidth, topHeight)
        l2:SetThickness(1.5)

        local t = f:CreateFontString(nil, "OVERLAY")
        t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
        t:SetPoint("BOTTOM", l2, "TOP", 0, 0)
        t:SetTextColor(1, 0.82, 0)
        t:SetText(TJ.SecondsToTime(duration))

        -- BOSS阶段时间轴
        for _, v in pairs(combatLog.otherTime) do
            if type(v) == "table" and v.time and v.time <= duration + 1 then
                local per = v.time / duration
                local l = f:CreateLine()
                l:SetColorTexture(.5, .5, .5)
                l:SetStartPoint("TOPLEFT", f.leftWidth + f.lwidth * per, f.topHeight + 10)
                l:SetEndPoint("TOPLEFT", f.leftWidth + f.lwidth * per, f.topHeight)
                l:SetThickness(1.5)

                local t = f:CreateFontString(nil, "OVERLAY")
                t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
                t:SetPoint("BOTTOM", l, "TOP", 0, 0)
                t:SetTextColor(1, 0.82, 0)
                t:SetText(format("|cff00ff00%s|r ", v.name) .. TJ.SecondsToTime(v.time))
            end
        end
        if info.showPhase or TJ.frame[FB][bossIndex].showPhase then
            -- 特殊阶段时间轴，比如鲜血议会的暗王阶段
            for _, v in pairs(combatLog.otherTime) do
                if type(v) == "table" and v.startTime and v.endTime and v.endTime <= duration + 1 then
                    local startWidth = f.leftWidth + f.lwidth * v.startTime / duration + 2
                    local endWidth = f.leftWidth + f.lwidth * v.endTime / duration + 2
                    local l = f:CreateLine(nil, "OVERLAY")
                    l:SetColorTexture(0, 1, 0)
                    l:SetStartPoint("TOPLEFT", startWidth, f.topHeight + 0)
                    l:SetEndPoint("TOPLEFT", endWidth, f.topHeight + 0)
                    l:SetThickness(1.5)

                    local l1 = f:CreateLine(nil, "OVERLAY")
                    l1:SetColorTexture(0, 1, 0)
                    l1:SetStartPoint("TOPLEFT", startWidth, topHeight + 5)
                    l1:SetEndPoint("TOPLEFT", startWidth, topHeight)
                    l1:SetThickness(1.5)

                    local l2 = f:CreateLine(nil, "OVERLAY")
                    l2:SetColorTexture(0, 1, 0)
                    l2:SetStartPoint("TOPLEFT", endWidth, topHeight + 5)
                    l2:SetEndPoint("TOPLEFT", endWidth, topHeight)
                    l2:SetThickness(1.5)

                    local t = f:CreateFontString()
                    t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
                    t:SetPoint("BOTTOM", l, "TOP", 0, 5)
                    t:SetTextColor(1, 0.82, 0)
                    t:SetText(format("|cff00ff00%s|r %s-%s", v.name2 or "",
                        TJ.SecondsToTime(v.startTime), TJ.SecondsToTime(v.endTime)))
                end
            end
        end
    end

    local haveAura
    local playerTbl = {}
    local barCount = 0
    local pointTbl
    if not updateTitleColor then
        pointTbl = TJ.GetRaidPointIndexByGUID()
    end
    -- DPS/HPS排名
    for _, infoType in ipairs({ "dps", "hps", "dps_friend" }) do
        if info[infoType] then
            f.dpsTbl = {}
            local function GetInfo(v, subevent)
                if not TJ.CombatInfoFilter(info, v, infoType) then return end
                local GUID
                local petGUID
                local yes
                if info[infoType].type == "d" then -- 显示承伤
                    GUID = GetGUID(v[8])
                    yes = true
                    if info[infoType].spell then
                        yes = nil
                        for i in ipairs(info[infoType].spell) do
                            if info[infoType].spell[i].spellID then
                                for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                                    if v[12] == spellID then
                                        yes = true
                                        break
                                    end
                                end
                                if yes then break end
                            end
                        end
                    end
                else -- 造成伤害
                    GUID = GetGUID(v[4])
                    if combatLog.guid[GUID] then
                        if combatLog.guid[GUID].class then
                            yes = true
                        end
                        -- 把宠物伤害计算给主人
                        if combatLog.guid[GUID].ownerGUID then
                            yes = true
                            petGUID = GUID
                            GUID = combatLog.guid[GUID].ownerGUID
                            local npcType = strsplit("-", GUID)
                            if (npcType == "Creature" or npcType == "Vehicle") and combatLog.guid[GUID] then
                                GUID = combatLog.guid[GUID].ownerGUID
                            end
                        end
                    end
                end
                if yes then
                    haveAura = true
                    if updateTitleColor then return true end
                    local destGUID = GetGUID(v[8])
                    if subevent:match("^SWING_") then
                        GetDamage(infoType, f.dpsTbl, v, subevent, GUID, false, petGUID, destGUID,
                            combatLog.guid[GUID].class)
                    else
                        GetDamage(infoType, f.dpsTbl, v, subevent, GUID, true, petGUID, destGUID, combatLog.guid[GUID]
                            .class)
                    end
                end
            end
            local events = {}
            for subevent, v in pairs(event) do
                if TJ.CombatFiterEvent(infoType, subevent, info[infoType]) then
                    tinsert(events, subevent)
                end
            end
            tinsert(infos, {
                infoType = infoType,
                events = events,
                GetInfo = GetInfo,
                StartCreatePlayerFrame = nil,
            })
        end
    end
    if info.aura then -- 光环
        local auraTbl = {}
        local infoType = "aura"
        local function GetInfo(v, subevent)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "d"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            for i in ipairs(info[infoType].spell) do
                if info[infoType].spell[i].spellID then
                    for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                        if v[12] == spellID and TJ.CombatInfoFilter_combatRole(
                                guidTbl[GUID] and guidTbl[GUID].name,
                                info[infoType].spell[i].combatRole,
                                combatLog)
                        then
                            haveAura = true
                            if updateTitleColor then return true end
                            auraTbl[GUID] = auraTbl[GUID] or {
                                GUID       = GUID,
                                raidIndex  = pointTbl[GUID] or guidTbl[GUID].index or 50,
                                info       = info,
                                infoType   = infoType,
                                durTimeMin = info[infoType].durTimeMin,
                            }
                            tinsert(auraTbl[GUID], {
                                type = (subevent:match("APPLIED") or subevent:match("SPELL_AURA_REMOVED_DOSE"))
                                    and "add" or "remove",
                                time = v[1],
                                spellID = spellID,
                                tooltip = info[infoType].spell[i].tooltip or "aura",
                                colorNum = info[infoType].spell[i].colorNum or 1,
                                frameLevel = info[infoType].spell[i].frameLevel or i,
                                destGUID = destGUID,
                                sourceGUID = sourceGUID,
                                stackCount = subevent:match("DOSE") and v[16],
                                notShowStackCount = info[infoType].notShowStackCount,
                                destRT = v[11],
                                sourceRT = v[7],
                                showIcon = info[infoType].showIcon,
                            })
                            yes = true
                            break
                        end
                    end
                    if yes then break end
                end
            end
        end
        local events = { "SPELL_AURA_APPLIED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED", "SPELL_AURA_REMOVED_DOSE", }
        local function GetBaseTbl(v)
            return {
                destGUID = v.destGUID,
                sourceGUID = v.sourceGUID,
                spellID = v.spellID,
                tooltip = v.tooltip,
                colorNum = v.colorNum,
                frameLevel = v.frameLevel,
                stackCount = v.stackCount,
                notShowStackCount = v.notShowStackCount,
                destRT = v.destRT,
                sourceRT = v.sourceRT,
                showIcon = v.showIcon,
            }
        end
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                local function func(aura)
                    local tbl = {}
                    -- local first = true
                    while true do
                        local add
                        for i = 1, #aura do
                            local v = aura[i]
                            -- if i == 1 and not add and v.type == "remove" then
                            --     local tb = GetBaseTbl(v)
                            --     tb.i = i
                            --     tb.startTime = 0
                            --     tb.endTime = aura[i].time
                            --     tinsert(tbl, tb)
                            --     tremove(aura, i)
                            --     -- first = nil
                            --     break
                            -- end
                            if not add and v.type == "add" then
                                add = GetBaseTbl(v)
                                add.i = i
                            elseif add and v.sourceGUID == add.sourceGUID and v.spellID == add.spellID
                                and v.destGUID == add.destGUID and i ~= add.i then
                                local tb = GetBaseTbl(add)
                                tb.startTime = aura[add.i].time
                                tb.endTime = aura[i].time
                                tinsert(tbl, tb)
                                if v.type == "remove" then
                                    tremove(aura, i)
                                end
                                tremove(aura, add.i)
                                -- first = nil
                                break
                            end
                            if add and i == #aura then
                                local tb = GetBaseTbl(add)
                                tb.startTime = aura[add.i].time
                                tb.endTime = duration
                                tinsert(tbl, tb)
                                tremove(aura, add.i)
                                -- first = nil
                                break
                            end
                            if i == #aura then
                                add = nil
                            end
                            -- first = nil
                        end
                        if not add then break end
                    end
                    return tbl
                end
                local newTbl = SortTbl(auraTbl)
                CreatePlayerFrame(playerTbl, newTbl, func, info[infoType].showCount)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
    end
    if info.healingTotem then -- 回血图腾
        local auraTbl = {}
        local infoType = "healingTotem"
        local lastTime = {}
        local __time = 1
        local function GetInfo(v)
            if not v.hp then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            for i in ipairs(info[infoType].spell) do
                for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                    if v[12] == spellID and not (lastTime[sourceGUID] and v[1] - lastTime[sourceGUID] <= 1) then
                        haveAura = true
                        if updateTitleColor then return true end
                        auraTbl[GUID] = auraTbl[GUID] or {
                            GUID      = GUID,
                            raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                            info      = info,
                            infoType  = infoType,
                        }
                        tinsert(auraTbl[GUID], {
                            startTime = v[1] - __time,
                            endTime = v[1] + __time,
                            spellID = spellID,
                            tooltip = info[infoType].spell[i].tooltip or "Heal",
                            colorNum = info[infoType].spell[i].colorNum or 1,
                            frameLevel = info[infoType].spell[i].frameLevel or i,
                            destGUID = destGUID,
                            sourceGUID = sourceGUID,
                            destRT = v[11],
                            sourceRT = v[7],
                        })
                        lastTime[GUID] = v[1]
                        yes = true
                        break
                    end
                end
                if yes then break end
            end
        end
        local events = { "SPELL_PERIODIC_HEAL" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl))
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
    end
    if info.harmDied then -- 冰霜之球死亡
        local auraTbl = {}
        local infoType = "harmDied"
        local function GetInfo(v)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "d"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            haveAura = true
            if updateTitleColor then return true end
            auraTbl[GUID] = auraTbl[GUID] or {
                GUID      = GUID,
                raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                info      = info,
                infoType  = infoType,
            }
            tinsert(auraTbl[GUID], {
                startTime = max(v[1] - duration2 / 100, 0),
                endTime = v[1],
                tooltip = "died+health",
                colorNum = 1,
                frameLevel = 1,
                destGUID = destGUID,
                sourceGUID = sourceGUID,
                hideStartTime = true,
                destRT = v[11],
                sourceRT = v[7],
            })
        end
        local events = { "UNIT_DIED" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl))
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
    end
    -- 友方受到伤害（被鬼魂打到），友方受到伤害（多个玩家的受伤合并显示），误伤
    for _, infoType in ipairs({ "beDamage", "beDamage2", "damageFriend", "damageHarm" }) do
        if info[infoType] then
            local auraTbl = {}
            local lastTime = {}
            local barWidth = 75
            local function GetInfo(v, subevent)
                if not TJ.CombatInfoFilter(info, v, infoType) then return end
                local destGUID = GetGUID(v[8])
                local sourceGUID = GetGUID(v[4])
                local GUID = "d"
                if info[infoType].type == "d" then
                    GUID = destGUID
                elseif info[infoType].type == "s" then
                    GUID = sourceGUID
                end
                if subevent:match("^SWING_") then
                    haveAura = true
                    if updateTitleColor then return true end
                    auraTbl[GUID] = auraTbl[GUID] or {
                        GUID = GUID,
                        raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                        info = info,
                        infoType = infoType,
                    }
                    tinsert(auraTbl[GUID], {
                        startTime = max(v[1] - duration2 / barWidth, 0),
                        endTime = v[1],
                        bar_startTime = max(v[1] - duration2 / (barWidth * 2), 0),
                        bar_endTime = v[1] + duration2 / (barWidth * 2),
                        tooltip = infoType,
                        colorNum = info[infoType].attackColorNum or 1,
                        frameLevel = info[infoType].attackFrameLevel or 1,
                        destGUID = destGUID,
                        sourceGUID = sourceGUID,
                        hideStartTime = true,
                        info = info[infoType],
                        amount = v[12],
                        destRT = v[11],
                        sourceRT = v[7],
                    })
                else
                    local yes
                    if info[infoType].spell then
                        for i in ipairs(info[infoType].spell) do
                            for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                                if v[12] == spellID and CheckTime(infoType, lastTime, GUID, v[1])
                                    and TJ.CombatInfoFilter_combatRole(
                                        guidTbl[GUID] and guidTbl[GUID].name,
                                        info[infoType].spell[i].combatRole,
                                        combatLog) then
                                    haveAura = true
                                    if updateTitleColor then return true end
                                    auraTbl[GUID] = auraTbl[GUID] or {
                                        GUID      = GUID,
                                        raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                                        info      = info,
                                        infoType  = infoType,
                                    }
                                    tinsert(auraTbl[GUID], {
                                        startTime = max(v[1] - duration2 / barWidth, 0),
                                        endTime = v[1],
                                        bar_startTime = max(v[1] - duration2 / (barWidth * 2), 0),
                                        bar_endTime = v[1] + duration2 / (barWidth * 2),
                                        spellID = spellID,
                                        tooltip = info[infoType].spell[i].tooltip or infoType,
                                        colorNum = info[infoType].spell[i].colorNum or 1,
                                        frameLevel = info[infoType].spell[i].frameLevel or i,
                                        destGUID = destGUID,
                                        sourceGUID = sourceGUID,
                                        hideStartTime = true,
                                        info = info[infoType],
                                        amount = v[15],
                                        destRT = v[11],
                                        sourceRT = v[7],
                                    })
                                    lastTime[GUID] = lastTime[GUID] or {}
                                    tinsert(lastTime[GUID], v[1])
                                    yes = true
                                    break
                                end
                            end
                            if yes then break end
                        end
                    else
                        haveAura = true
                        if updateTitleColor then return true end
                        auraTbl[GUID] = auraTbl[GUID] or {
                            GUID      = GUID,
                            raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                            info      = info,
                            infoType  = infoType,
                        }
                        tinsert(auraTbl[GUID], {
                            startTime = max(v[1] - duration2 / barWidth, 0),
                            endTime = v[1],
                            bar_startTime = max(v[1] - duration2 / (barWidth * 2), 0),
                            bar_endTime = v[1] + duration2 / (barWidth * 2),
                            tooltip = infoType,
                            colorNum = 1,
                            frameLevel = 1,
                            destGUID = destGUID,
                            sourceGUID = sourceGUID,
                            hideStartTime = true,
                            info = info[infoType],
                            amount = v[15],
                            destRT = v[11],
                            sourceRT = v[7],
                        })
                    end
                end
            end
            local events = {}
            for subevent, v in pairs(event) do
                if TJ.CombatFiterEvent("damage", subevent, info[infoType]) then
                    tinsert(events, subevent)
                end
            end
            local function StartCreatePlayerFrame()
                if next(auraTbl) then
                    CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, true)
                end
            end
            tinsert(infos, {
                infoType = infoType,
                events = events,
                GetInfo = GetInfo,
                StartCreatePlayerFrame = StartCreatePlayerFrame
            })
        end
    end
    if info.castSuccess then -- 施法成功
        local auraTbl = {}
        local infoType = "castSuccess"
        local function GetInfo(v)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            for i in ipairs(info[infoType].spell) do
                for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                    if v[12] == spellID and TJ.CombatInfoFilter_combatRole(
                            guidTbl[GUID].name,
                            info[infoType].spell[i].combatRole,
                            combatLog)
                    then
                        haveAura = true
                        if updateTitleColor then return true end
                        auraTbl[GUID] = auraTbl[GUID] or {
                            GUID = GUID,
                            raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                            info = info,
                            infoType = infoType,
                        }
                        tinsert(auraTbl[GUID], {
                            startTime = max(v[1] - duration2 / 75, 0),
                            endTime = v[1],
                            bar_startTime = max(v[1] - duration2 / 125, 0),
                            bar_endTime = v[1] + duration2 / 125,
                            spellID = spellID,
                            spellName = v.spellName,
                            tooltip = info[infoType].spell[i].tooltip or "castSuccess",
                            colorNum = info[infoType].spell[i].colorNum or 1,
                            frameLevel = info[infoType].spell[i].frameLevel or i,
                            destGUID = destGUID,
                            sourceGUID = sourceGUID,
                            hideStartTime = true,
                            destRT = v[11],
                            sourceRT = v[7],
                            barText = info[infoType].barText,
                            showIcon = info[infoType].showIcon,
                        })
                        yes = true
                        break
                    end
                end
                if yes then break end
            end
        end
        local events = { "SPELL_CAST_SUCCESS" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, not info[infoType].notShowCount)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
    end
    if info.castFailed then -- 施法失败
        local auraTbl = {}
        local infoType = "castFailed"
        local function GetInfo(v)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            for i in ipairs(info[infoType].spell) do
                for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                    if v[12] == spellID and TJ.CombatInfoFilter_combatRole(
                            guidTbl[GUID].name,
                            info[infoType].spell[i].combatRole,
                            combatLog)
                    then
                        haveAura = true
                        if updateTitleColor then return true end
                        auraTbl[GUID] = auraTbl[GUID] or {
                            GUID = GUID,
                            raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                            info = info,
                            infoType = infoType,
                        }
                        tinsert(auraTbl[GUID], {
                            startTime = max(v[1] - duration2 / 75, 0),
                            endTime = v[1],
                            bar_startTime = max(v[1] - duration2 / 125, 0),
                            bar_endTime = v[1] + duration2 / 125,
                            spellID = spellID,
                            spellName = v.spellName,
                            tooltip = info[infoType].spell[i].tooltip or "castSuccess",
                            colorNum = info[infoType].spell[i].colorNum or 1,
                            frameLevel = info[infoType].spell[i].frameLevel or i,
                            destGUID = destGUID,
                            sourceGUID = sourceGUID,
                            hideStartTime = true,
                            destRT = v[11],
                            sourceRT = v[7],
                        })
                        yes = true
                        break
                    end
                end
                if yes then break end
            end
        end
        -- local events = { "SPELL_CAST_START" }
        local events = { "SPELL_CAST_FAILED" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, true)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
    end
    if info.dispel then -- 驱散
        local auraTbl = {}
        local infoType = "dispel"
        local function GetInfo(v)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            GUID = TJ.GetOwnerGUID(combatLog, GUID)
            local yes
            local function func(i)
                auraTbl[GUID] = auraTbl[GUID] or {
                    GUID = GUID,
                    raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                    info = info,
                    infoType = infoType,
                }
                tinsert(auraTbl[GUID], {
                    startTime  = max(v[1] - duration2 / 75, 0),
                    endTime    = v[1],
                    spellID    = v[15],
                    spellID2   = v[12],
                    tooltip    = infoType,
                    colorNum   = i and info[infoType].spell[i].colorNum or 1,
                    frameLevel = i and info[infoType].spell[i].frameLevel or 1,
                    destGUID   = destGUID,
                    sourceGUID = sourceGUID,
                    destRT     = v[11],
                    sourceRT   = v[7],
                })
            end
            if info[infoType].spell then
                for i in ipairs(info[infoType].spell) do
                    for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                        if v[15] == spellID and not TJ.ValueInTable(TJ.banDispel, v[12]) then
                            haveAura = true
                            if updateTitleColor then return true end
                            func(i)
                            yes = true
                            break
                        end
                    end
                    if yes then break end
                end
            else
                haveAura = true
                if updateTitleColor then return true end
                func()
            end
        end
        local events = info.dispel.notStolen and { "SPELL_DISPEL" } or { "SPELL_DISPEL", "SPELL_STOLEN" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, true)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
        if info.canSend == nil then
            info.canSend = "count"
        end
        info.notShowDead = true
    end
    if info.interrupt then -- 打断
        local auraTbl = {}
        local infoType = "interrupt"
        local function GetInfo(v)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            local function func(i)
                auraTbl[GUID] = auraTbl[GUID] or {
                    GUID      = GUID,
                    raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                    info      = info,
                    infoType  = infoType,
                }
                tinsert(auraTbl[GUID], {
                    startTime  = max(v[1] - duration2 / 75, 0),
                    endTime    = v[1],
                    spellID    = v[15],
                    spellID2   = v[12],
                    tooltip    = infoType,
                    colorNum   = i and info[infoType].spell[i].colorNum or 1,
                    frameLevel = i and info[infoType].spell[i].frameLevel or 1,
                    destGUID   = destGUID,
                    sourceGUID = sourceGUID,
                    destRT     = v[11],
                    sourceRT   = v[7],
                    showIcon   = info[infoType].showIcon,
                })
            end
            if info[infoType].spell[1].spellID then
                for i in ipairs(info[infoType].spell) do
                    for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                        if v[15] == spellID then
                            haveAura = true
                            if updateTitleColor then return true end
                            func(i)
                            yes = true
                            break
                        end
                    end
                    if yes then break end
                end
            else
                haveAura = true
                if updateTitleColor then return true end
                func()
            end
        end
        local events = { "SPELL_INTERRUPT" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, true)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
        if info.canSend == nil then
            info.canSend = "count"
        end
        info.notShowDead = true
    end
    if info.broken then -- 破控
        local auraTbl = {}
        local infoType = "broken"
        local function GetInfo(v, subevent)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            haveAura = true
            if updateTitleColor then return true end
            auraTbl[GUID] = auraTbl[GUID] or {
                GUID = GUID,
                raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                info = info,
                infoType = infoType,
            }
            tinsert(auraTbl[GUID], {
                startTime     = max(v[1] - duration2 / 75, 0),
                endTime       = v[1],
                spellID       = subevent == "SPELL_AURA_BROKEN" and 1 or v[15],
                spellID2      = v[12],
                tooltip       = infoType,
                colorNum      = info[infoType].colorNum or 1,
                frameLevel    = info[infoType].frameLevel or 1,
                destGUID      = destGUID,
                sourceGUID    = sourceGUID,
                hideStartTime = true,
                info          = info[infoType],
                destRT        = v[11],
                sourceRT      = v[7],
            })
        end
        local events = { "SPELL_AURA_BROKEN", "SPELL_AURA_BROKEN_SPELL" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, true)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
        if info.canSend == nil then
            info.canSend = "count"
        end
        info.notShowDead = true
    end
    if info.trigger then -- 特殊的触发事件
        local auraTbl = {}
        local infoType = "trigger"
        local function GetInfo(v)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            if not destGUID and info[infoType].getDestGUID then
                for guid in pairs(guidTbl) do
                    if TJ.GetNPCID(guid) == info[infoType].getDestGUID then
                        destGUID = guid
                    end
                end
            end
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            GUID = GUID or ""
            for i in ipairs(info[infoType].spell) do
                for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                    if v[12] == spellID then
                        haveAura = true
                        if updateTitleColor then return true end
                        auraTbl[GUID] = auraTbl[GUID] or {
                            GUID = GUID,
                            raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                            info = info,
                            infoType = infoType,
                        }
                        tinsert(auraTbl[GUID], {
                            startTime     = max(v[1] - duration2 / 100, 0),
                            endTime       = v[1],
                            bar_startTime = max(v[1] - duration2 / 150, 0),
                            bar_endTime   = v[1] + duration2 / 150,
                            spellID       = v[12],
                            tooltip       = info[infoType].spell[i].tooltip or "trigger",
                            tooltipText   = info[infoType].spell[i].tooltipText,
                            colorNum      = info[infoType].spell[i].colorNum or 1,
                            frameLevel    = info[infoType].spell[i].frameLevel or 1,
                            destGUID      = destGUID,
                            sourceGUID    = sourceGUID,
                            destRT        = v[11],
                            sourceRT      = v[7],
                            DestTarget    = info[infoType].getDestGUID,
                            stackCount    = v[15],
                        })
                        return
                    end
                end
            end
        end
        local events = { "TRIGGER" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, info[infoType].showCount)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
        if info.canSend == nil then
            info.canSend = "count"
        end
    end
    if info.parry then -- 招架
        local auraTbl = {}
        local infoType = "parry"
        local function GetInfo(v, subevent)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local num
            if subevent:match("^SWING_") then
                num = 12
                if v[num] == "PARRY" then
                    haveAura = true
                    if updateTitleColor then return true end
                    auraTbl[GUID] = auraTbl[GUID] or {
                        GUID      = GUID,
                        raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                        info      = info,
                        infoType  = infoType,
                    }
                    tinsert(auraTbl[GUID], {
                        startTime = max(v[1] - duration2 / 75, 0),
                        endTime = v[1],
                        bar_startTime = max(v[1] - duration2 / (75 * 2), 0),
                        bar_endTime = v[1] + duration2 / (75 * 2),
                        tooltip = infoType,
                        colorNum = 1,
                        frameLevel = 1,
                        destGUID = destGUID,
                        sourceGUID = sourceGUID,
                        hideStartTime = true,
                        info = info[infoType],
                        amount = v[num],
                        destRT = v[11],
                        sourceRT = v[7],
                    })
                end
            else
                num = 15
                if v[num] == "PARRY" and v[12] ~= 31803 then
                    local yes
                    if info[infoType].spell then
                        for i in ipairs(info[infoType].spell) do
                            for _, spellID in ipairs(info[infoType].spell[i].spellID) do
                                if v[12] == spellID and not lastTime[GUID .. v[1]] then
                                    haveAura = true
                                    if updateTitleColor then return true end
                                    auraTbl[GUID] = auraTbl[GUID] or {
                                        GUID = GUID,
                                        raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                                    }
                                    tinsert(auraTbl[GUID], {
                                        startTime = max(v[1] - duration2 / 75, 0),
                                        endTime = v[1],
                                        bar_startTime = max(v[1] - duration2 / (75 * 2), 0),
                                        bar_endTime = v[1] + duration2 / (75 * 2),
                                        spellID = v[12],
                                        tooltip = info[infoType].spell[i].tooltip or infoType,
                                        colorNum = 4,
                                        frameLevel = 1,
                                        destGUID = destGUID,
                                        sourceGUID = sourceGUID,
                                        hideStartTime = true,
                                        info = info[infoType],
                                        amount = v[num],
                                        destRT = v[11],
                                        sourceRT = v[7],
                                    })
                                    lastTime[GUID .. v[1]] = true
                                    yes = true
                                    break
                                end
                            end
                            if yes then break end
                        end
                    else
                        haveAura = true
                        if updateTitleColor then return true end
                        auraTbl[GUID] = auraTbl[GUID] or {
                            GUID = GUID,
                            raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                        }
                        tinsert(auraTbl[GUID], {
                            startTime = max(v[1] - duration2 / 75, 0),
                            endTime = v[1],
                            bar_startTime = max(v[1] - duration2 / (75 * 2), 0),
                            bar_endTime = v[1] + duration2 / (75 * 2),
                            spellID = v[12],
                            tooltip = infoType,
                            colorNum = 4,
                            frameLevel = 1,
                            destGUID = destGUID,
                            sourceGUID = sourceGUID,
                            hideStartTime = true,
                            info = info[infoType],
                            amount = v[num],
                            destRT = v[11],
                            sourceRT = v[7],
                        })
                    end
                end
            end
        end
        local events = {}
        for subevent, v in pairs(event) do
            if TJ.CombatFiterEvent(infoType, subevent, info[infoType]) then
                tinsert(events, subevent)
            end
        end
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, true)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
        if info.canSend == nil then
            info.canSend = "count"
        end
    end
    if info.dead then -- 死亡
        local auraTbl = {}
        local infoType = "dead"
        local function GetInfo(v, subevent)
            if not TJ.CombatInfoFilter(info, v, infoType) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = destGUID
            if v.hp and v.hp <= 0 then
                haveAura = true
                if updateTitleColor then return true end
                auraTbl[GUID] = auraTbl[GUID] or {
                    GUID      = GUID,
                    raidIndex = pointTbl[GUID] or guidTbl[GUID].index or 50,
                    info      = info,
                    infoType  = infoType,
                }
                tinsert(auraTbl[GUID], {
                    startTime     = max(v[1] - duration2 / 75, 0),
                    endTime       = v[1],
                    bar_startTime = v[1],
                    bar_endTime   = v[1] + duration2 / 50,
                    colorNum      = 3,
                    tooltip       = "died+health",
                    frameLevel    = 10,
                    diedGUID      = destGUID,
                    hideStartTime = true,
                    destRT        = v[11],
                    sourceRT      = v[7],
                })
            end
        end
        local events = { "UNIT_DIED" }
        local function StartCreatePlayerFrame()
            if next(auraTbl) then
                CreatePlayerFrame(playerTbl, SortTbl(auraTbl), nil, true)
            end
        end
        tinsert(infos, {
            infoType = infoType,
            events = events,
            GetInfo = GetInfo,
            StartCreatePlayerFrame = StartCreatePlayerFrame
        })
        if info.canSend == nil then
            info.canSend = "count"
        end
    end

    local function GoNextInfo()
        if allInfo and allInfo[manyIndex + 1] then
            TJ.CreateCombatFrame(bt, processorKey, allInfo[manyIndex + 1], updateTitleColor, manyIndex + 1, allInfo,
                click)
        else
            return true
        end
    end
    local function Success()
        if haveAura and not updateTitleColor then
            if info.dps or info.hps or info.dps_friend then
                local newTbl = {}
                for guid, v in pairs(f.dpsTbl) do
                    tinsert(newTbl, v)
                    newTbl[#newTbl].name = combatLog.guid[guid].name
                    newTbl[#newTbl].class = combatLog.guid[guid].class
                end
                if combatLog.raidMember and not info.hps and not info.notShowRaidMember then
                    local fitleFuc = info.raidMemberFiterFuc or ShowRaidMember_FiterCombatRole
                    for i, v in ipairs(combatLog.raidMember) do
                        if v.role ~= "MAINASSIST" and fitleFuc(v) then
                            local yes = true
                            for i, vv in pairs(newTbl) do
                                if v.name == vv.name then
                                    yes = nil
                                    break
                                end
                            end
                            if yes then
                                tinsert(newTbl, {
                                    name = v.name,
                                    class = v.class,
                                    damage = 0,
                                    detail = nil,
                                })
                            end
                        end
                    end
                end
                sort(newTbl, function(a, b)
                    return a.damage > b.damage
                end)
                local maxDamage = newTbl[1].damage
                f.topHeight = f.topHeight + 20
                f.lwidth = lwidth - (manyIndex and 0 or 200)
                local playerTbl = {}
                for i, v in ipairs(newTbl) do
                    local playerText = CreatePlayerText(i, v.name, v.class)
                    playerText.text = tonumber(v.damage)
                    tinsert(playerTbl, playerText)
                    CreateDpsBar(v, i, maxDamage)
                end
                if info.dps or info.dps_friend then
                    info.canSend = "dps"
                elseif info.hps then
                    info.canSend = "hps"
                end
                CreateSendButton(info, playerTbl, bt, isRefresh)
                local hasDropDown
                if info.dps and info.dps.showDropDown then
                    CreateDropDown(info.dps.showDropDown, isRefresh)
                    hasDropDown = true
                end
                local w = width - (manyIndex and 0 or 200)
                local h = (#newTbl + 1 + (hasDropDown and 1 or 0)) * btHeight - f.topHeight
                f:SetWidth(w)
                f:SetHeight(h)
                TJ.combatFrameLastWidth = w
                TJ.combatFrameLastHeight = h
            else
                if info.showRaidMember and combatLog.raidMember then
                    local fitleFuc = info.raidMemberFiterFuc or ShowRaidMember_FiterCombatRole
                    local tbl = {}
                    for i, v in ipairs(combatLog.raidMember) do
                        if v.role ~= "MAINASSIST" and fitleFuc(v) then
                            local yes = true
                            for i, playerText in ipairs(playerTbl) do
                                if v.name == (guidTbl[playerText.GUID] and guidTbl[playerText.GUID].name) then
                                    yes = false
                                    break
                                end
                            end
                            if yes then
                                tinsert(tbl, v)
                            end
                        end
                    end
                    local count = #playerTbl + 1
                    for i, v in ipairs(tbl) do
                        count = count + 1
                        local playerText = CreatePlayerText(count, v.name, v.class)
                        playerText.name = v.name
                        local t = f:CreateFontString()
                        t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
                        t:SetPoint("LEFT", playerText, "RIGHT", 0, 0)
                        t:SetTextColor(1, 0, 0)
                        t:SetText(format("%s. ", i) .. info.showRaidMember)
                        tinsert(playerTbl, playerText)
                    end
                    if next(tbl) then
                        barCount = barCount + 1
                    end
                end
                -- 死亡
                if not info.dead and event.UNIT_DIED and not info.notShowDead then
                    for _, v in ipairs(event.UNIT_DIED) do
                        if v.hp and v.hp <= 0 then
                            local diedGUID = GetGUID(v[8])
                            for _, playerText in pairs(playerTbl) do
                                if playerText.GUID == diedGUID then
                                    local v = {
                                        startTime     = max(v[1] - duration2 / 75, 0),
                                        endTime       = v[1],
                                        bar_startTime = v[1],
                                        bar_endTime   = v[1] + duration2 / 75,
                                        colorNum      = 3,
                                        tooltip       = "died+health",
                                        frameLevel    = 10,
                                        diedGUID      = diedGUID,
                                        hideStartTime = true,
                                        isdead        = true,
                                    }
                                    CreateBar(f, v, playerText)
                                end
                            end
                        end
                    end
                end
                barCount = barCount + #playerTbl
                if info.func then
                    barCount = barCount + info.func(f, bt, playerTbl, info)
                end
                if info.canSend then
                    barCount = barCount + 1
                    CreateSendButton(info, playerTbl, bt)
                end
                if info.showTextLog then
                    local db = {}
                    for _, playerText in pairs(playerTbl) do
                        for _, bar in pairs(playerText.barTbl) do
                            tinsert(db, bar)
                        end
                    end
                    sort(db, function(a, b)
                        if a.v.endTime and b.v.endTime then
                            return a.v.endTime < b.v.endTime
                        end
                    end)
                    CreateTextLog(f, db)
                end
                f:SetHeight((barCount + 1) * btHeight - topHeight)

                if info.damageFriend or info.beDamage2 then
                    ShowDamageFriendCount(playerTbl, info, info.damageFriend and "damageFriend" or "beDamage2")
                end
                if info.SSpowerSpell then
                    SSpowerSpell(playerTbl)
                end
            end
            TJ.combatFrame:Show()
            if click then
                TJ.SetCombatFrameIsClick(f)
            end
        end
        if GoNextInfo() and updateTitleColor then
            GoNextUpdateTitleColor()
        end
    end
    local function ProcessEvents()
        if not TJ.combatFrameProcessors[processorKey] then
            return
        end
        if not updateTitleColor and not bt.isOnEnter and TJ.combatFrameMany[1] and not TJ.combatFrameMany[1].click then
            TJ.combatFrameMany[1]:Hide()
            return
        end
        local infoType = infos[infoIndex] and infos[infoIndex].infoType
        if not infoType then
            -- 全部子战斗分析类型已经处理完成，结束
            Success()
            return
        end
        if info[infoType] then
            local subevent = infos[infoIndex].events[eventIndex]
            if subevent then
                local batch = updateTitleColor and batch2 or batch
                for i = startIndex, batch + startIndex - 1 do
                    local v = event[subevent] and event[subevent][i]
                    if v then
                        if infos[infoIndex].GetInfo(v, subevent) and updateTitleColor then
                            bt.Text:SetTextColor(0, 1, 0)
                            eventInfo.titleColor[bt.index] = 1
                            GoNextUpdateTitleColor()
                            return true
                        end
                        startIndex = startIndex + 1
                    else
                        -- 当前事件已全部处理，处理下一个事件
                        eventIndex = eventIndex + 1
                        startIndex = 1
                        break
                    end
                end
            else
                -- 全部事件已经处理完成，开始创建该战斗分析类型的UI
                if infos[infoIndex].StartCreatePlayerFrame then
                    infos[infoIndex].StartCreatePlayerFrame()
                end
                infoIndex = infoIndex + 1
                startIndex = 1
                eventIndex = 1
            end
        end
        After(0, ProcessEvents)
    end
    ProcessEvents()
end
