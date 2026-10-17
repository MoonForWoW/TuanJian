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

-- 面板和其内部控件按历史最大用量复用；不进入 SavedVariables。
local combatPanels = {}
local analysisGeneration = 0
local activeBuild
local profileTime = debugprofilestop or function() return 0 end

-- UI 创建和排序使用协程续接；一次回调最多约 2ms 或 50 个工作单位。
local function YieldCombatWork(weight)
    if not activeBuild then return end
    activeBuild.units = activeBuild.units + (weight or 1)
    if activeBuild.units >= 50 or profileTime() - activeBuild.started >= 2 then
        coroutine.yield()
    end
end
TJ.YieldCombatWork = YieldCombatWork

-- 大数组用可暂停的归并排序，避免在 table.sort 的 C 调用中尝试 yield。
local function SortCombatWork(tbl, less)
    local n = #tbl
    if not activeBuild or n <= 64 then return sort(tbl, less) end
    local source, target, width = tbl, {}, 1
    while width < n do
        for first = 1, n, width * 2 do
            local middle, last = min(first + width - 1, n), min(first + width * 2 - 1, n)
            local left, right = first, middle + 1
            for i = first, last do
                if right > last or (left <= middle and not less(source[right], source[left])) then
                    target[i] = source[left]; left = left + 1
                else
                    target[i] = source[right]; right = right + 1
                end
                YieldCombatWork(1 / 32)
            end
        end
        source, target, width = target, source, width * 2
    end
    if source ~= tbl then
        for i = 1, n do
            tbl[i] = source[i]; YieldCombatWork(1 / 32)
        end
    end
end
TJ.SortCombatWork = SortCombatWork

local function RunCombatBuild(frame, valid, work, complete)
    local state = { frame = frame, valid = valid, complete = complete, thread = coroutine.create(work) }
    work, complete, valid = nil, nil, nil
    local function Cancel()
        state.thread, state.complete, state.valid, state.frame = nil, nil, nil, nil
    end
    frame._combatCancelTasks = frame._combatCancelTasks or {}
    frame._combatCancelTasks[#frame._combatCancelTasks + 1] = Cancel
    local function Step()
        if not state.thread then return end
        if not state.valid() then
            Cancel(); return
        end
        TJ.combatFrame = state.frame
        state.units, state.started = 0, profileTime()
        activeBuild = state
        local ok, err = coroutine.resume(state.thread)
        activeBuild = nil
        if not ok then
            Cancel(); error(err)
        end
        if coroutine.status(state.thread) == "dead" then
            local callback = state.complete
            Cancel()
            if callback then callback() end
        else
            After(0, Step)
        end
    end
    After(0, Step)
end
local poolScripts = { "OnEnter", "OnLeave", "OnClick", "OnHide", "OnShow", "OnUpdate",
    "OnMouseDown", "OnMouseUp", "OnMouseWheel" }
local poolFields = { "v", "playerText", "guidTbl", "playerTextGUID", "tooltip", "tooltipText", "frame",
    "stackText", "ds", "name", "name2", "color", "GUID", "sourceGUID", "destGUID", "index", "Text",
    "barTbl", "barInfo", "info", "count", "text", "damageFriendCount", "damageFriendPlayers", "ownerTitle",
    "dpsTbl", "titleText", "titleName", "frameName", "tipsText", "CloseButton", "ToolCombatSettingButton",
    "click", "hasClickFrame", "isMany", "_combatHoverBars", "_combatHoverDirty", "_combatHoveredBars",
    "_combatHealthIndex", "_combatHealthCache", "_combatHealCache", "_combatDamageCache" }

local function ResetCombatWidget(widget)
    widget:Hide()
    for _, script in ipairs(poolScripts) do
        if widget:HasScript(script) then widget:SetScript(script, nil) end
    end
    widget:ClearAllPoints()
    widget:SetScale(1)
    widget:SetAlpha(1)
    widget:StopMovingOrSizing()
    widget:EnableMouse(false)
    widget:EnableMouseWheel(false)
    widget:SetMovable(false)
    if widget.SetBackdrop then widget:SetBackdrop(nil) end
    if widget.moneyFrame then
        widget.moneyFrame:Hide()
        widget.moneyFrame = nil
    end
    for _, field in ipairs(poolFields) do widget[field] = nil end
    if widget._combatRegions then
        for _, pool in pairs(widget._combatRegions) do
            local used = pool.used
            pool.used = 0
            for i = 1, used do
                local region = pool[i]
                region:Hide()
                region:ClearAllPoints()
                if region.SetText then region:SetText("") end
            end
        end
    end
end

local function AcquireCombatPanel(parent)
    local f
    for _, panel in ipairs(combatPanels) do
        if not panel._combatInUse then
            f = panel; break
        end
    end
    if not f then
        f = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        f._combatWidgets = {}
        combatPanels[#combatPanels + 1] = f
    end
    f._combatInUse = true
    f._combatGeneration = analysisGeneration
    f._combatOwner = f
    f:SetParent(parent)
    return f
end

local function AcquireCombatWidget(kind, parent, template)
    local owner = parent._combatOwner
    local key = kind .. ":" .. (template or "")
    local pool = owner._combatWidgets[key]
    if not pool then
        pool = { used = 0 }; owner._combatWidgets[key] = pool
    end
    pool.used = pool.used + 1
    local widget = pool[pool.used]
    if not widget then
        widget = CreateFrame(kind, nil, parent, template)
        widget._combatOwner = owner
        pool[pool.used] = widget
    end
    widget:SetParent(parent)
    widget:SetFrameLevel(parent:GetFrameLevel() + 1)
    widget:EnableMouse(kind == "Button" or kind == "StatusBar")
    if widget.Enable then widget:Enable() end
    widget:Show()
    return widget
end

local function AcquireCombatRegion(parent, kind, layer)
    local pools = parent._combatRegions
    if not pools then
        pools = {}; parent._combatRegions = pools
    end
    local key = kind .. ":" .. (layer or "")
    local pool = pools[key]
    if not pool then
        pool = { used = 0 }; pools[key] = pool
    end
    pool.used = pool.used + 1
    local region = pool[pool.used]
    if not region then
        region = parent["Create" .. kind](parent, nil, layer)
        pool[pool.used] = region
    end
    region:SetAlpha(1)
    if kind == "FontString" then
        region:SetTextColor(1, 1, 1)
        region:SetJustifyH("LEFT")
        region:SetJustifyV("MIDDLE")
        region:SetWordWrap(true)
        region:SetSize(0, 0)
    elseif kind == "Texture" then
        region:SetTexCoord(0, 1, 0, 1)
        region:SetVertexColor(1, 1, 1, 1)
        region:SetDesaturated(false)
    end
    region:Show()
    return region
end

-- 供 boss 自定义分析附加文字使用，与主面板一起回收。
function TJ.CreateCombatFontString(parent, layer)
    return AcquireCombatRegion(parent, "FontString", layer)
end

local function ReleaseCombatPanels()
    for _, f in ipairs(combatPanels) do
        if f._combatInUse then
            f._combatInUse = false
            f._combatPlayerNames = nil
            if f._combatCancelTasks then
                for _, cancel in ipairs(f._combatCancelTasks) do cancel() end
                f._combatCancelTasks = nil
            end
            -- 首先隐藏整组，避免重置鼠标或文本时继续显示旧分析。
            f:Hide()
            if f._combatTextLog then
                f._combatTextLog:Hide()
                f._combatTextChild:SetText("")
                f._combatTextChild:EnableMouse(false)
                f._combatTextChild:SetHyperlinksEnabled(false)
                f._combatTextChild:SetScript("OnHyperlinkEnter", nil)
                f._combatTextChild:SetScript("OnHyperlinkLeave", nil)
                f._combatTextChild:SetScript("OnEditFocusGained", nil)
                f._combatTextChild:ClearFocus()
            end
            if f._combatTargetLog then
                f._combatTargetLog:Hide()
                f._combatTargetLines = nil
                for _, row in ipairs(f._combatTargetRows) do
                    row.line = nil
                    row.time:SetText("")
                    row.message:SetText("")
                    row:Hide()
                end
            end
            if f._combatSendButton then
                f._combatSendButton:Hide()
                f._combatSendButton:SetScript("OnClick", nil)
            end
            for _, pool in pairs(f._combatWidgets) do
                local used = pool.used
                pool.used = 0
                for i = 1, used do ResetCombatWidget(pool[i]) end
            end
            -- boss 自定义分析创建的子控件也要隐藏；不改写其内部模板。
            for _, child in ipairs({ f:GetChildren() }) do
                if not child._combatOwner then child:Hide() end
            end
            -- 仅回收 _combatRegions；背景模板纹理不能 Hide，SetBackdrop 不会重新 Show 它们。
            -- OnSizeChanged 也保留给背景模板更新纹理坐标。
            ResetCombatWidget(f)
            f:SetParent(UIParent)
        end
    end
end

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

local function GetNameByGUID(GUID, combat)
    combat = combat or TJ.GetCombatLog()
    local unit = combat and combat.guid and combat.guid[GUID]
    return unit and unit.name or ""
end

-- -- 创建Bar
local function GetHoverBars(playerText)
    if not playerText._combatHoverBars or playerText._combatHoverDirty then
        local bars = {}
        for i, bar in ipairs(playerText.barTbl or {}) do
            bars[i] = bar
            YieldCombatWork(1 / 32)
        end
        SortCombatWork(bars, function(a, b)
            return (a.v.frameLevel or 0) > (b.v.frameLevel or 0)
        end)
        playerText._combatHoverBars, playerText._combatHoverDirty = bars, nil
    end
    return playerText._combatHoverBars
end

local function CreateBar(f, v, playerText)
    local combatLog = TJ.GetCombatLog()
    local deathEvents = v.diedGUID and TJ.GetCombatLogEvent()
    local duration = combatLog.duration
    local guidTbl = combatLog.guid
    local index = playerText.index
    local barTbl = playerText.barTbl

    local bar = AcquireCombatWidget("StatusBar", f, "BackdropTemplate")
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
        local t = AcquireCombatRegion(bar, "FontString")
        t:SetFont(BIAOGE_TEXT_FONT, 10, "OUTLINE")
        t:SetPoint("CENTER", 0, 0)
        t:SetHeight(bar:GetHeight())
        t:SetText(v.stackCount)
        bar.stackText = t
    end
    if v.barText then
        local t = AcquireCombatRegion(bar, "FontString")
        t:SetFont(BIAOGE_TEXT_FONT, 11, "OUTLINE")
        t:SetPoint("LEFT", bar, "RIGHT", 0, 0)
        t:SetText(v.barText(v.spellID))
    end
    if not v.isdead then
        local tbl = {}
        if bar.tooltip:match("HLKwuran") then
            local t = AcquireCombatRegion(bar, "FontString")
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
    playerText._combatHoverDirty = true
    bar:SetScript("OnEnter", function(self)
        TJ.ResetCombatTooltipBars()
        GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
        GameTooltip:ClearLines()
        local i = 0
        local frameScale = f:GetScale()
        local uiScale, _x, _y = UIParent:GetEffectiveScale(), GetCursorPosition()
        local x, y = (_x / uiScale), (_y / uiScale)
        local offSet = .01
        local highlighted = {}
        self._combatHoveredBars = highlighted
        for _, bar in ipairs(GetHoverBars(playerText)) do
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
                highlighted[#highlighted + 1] = bar
                if v.tooltip == "Heal" or v.tooltip:match("health") or v.tooltip:match("died") then
                    break
                end
            end
        end
        if v.diedGUID then
            GameTooltip:AddLine(" ")
            GameTooltip:AddLine(L["%s查看死者施法　%s查看治疗施法"]:format(AddTexture('LEFT'), AddTexture('RIGHT')), 1, .82, 0)
        end
        GameTooltip:Show()

        if not self.ds then
            local tex = AcquireCombatRegion(f, "Texture")
            tex:SetPoint("TOPLEFT", playerText, "TOPLEFT", 0, 0)
            tex:SetPoint("BOTTOMRIGHT", playerText, "BOTTOMRIGHT", f.lwidth, 0)
            tex:SetColorTexture(1, 1, 1, 0.2)
            self.ds = tex
        end
        self.ds:Show()
    end)
    bar:SetScript("OnLeave", function(self)
        for _, bar in ipairs(self._combatHoveredBars or {}) do
            bar:SetBackdropBorderColor(1, 1, 1, 0)
        end
        self._combatHoveredBars = nil
        GameTooltip:Hide()
        if self.ds then
            self.ds:Hide()
        end
    end)
    if v.diedGUID then
        bar:EnableMouse(true)
        bar:SetScript("OnMouseDown", function() end)
        bar:SetScript("OnMouseUp", function(_, button)
            if button ~= "LeftButton" and button ~= "RightButton" then return end
            for _, panel in ipairs(TJ.combatFrameMany) do TJ.SetCombatFrameIsClick(panel) end
            GameTooltip:Hide()
            TJ.OpenCastRecordsForDeath(f, combatLog, deathEvents, v.diedGUID, v.endTime, button == "RightButton")
        end)
    end
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
        local tex = AcquireCombatRegion(bar, "Texture", "OVERLAY")
        tex:SetPoint("LEFT")
        tex:SetSize(btHeight - 2, btHeight - 2)
        tex:SetTexture(v.icon)
        tex:SetTexCoord(unpack(TJ.iconTexCoord))
        bar:SetFrameLevel(f:GetFrameLevel() + #barTbl)
    else
        bar:SetFrameLevel(f:GetFrameLevel() + v.frameLevel)
    end
    YieldCombatWork()
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
        edit:SetText((TJ.ClearCode(parent:GetParent().titleName ..
            (parent.info and parent.info.dead and format(L["(%s)"], TJ.bossNameText:GetText()) or ""), true)))
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
    local playerText = AcquireCombatWidget("Frame", f)
    playerText:EnableMouse(true)
    playerText:SetSize(f.leftWidth - 10, btHeight)
    playerText:SetPoint("TOPRIGHT", f, "TOPLEFT", f.leftWidth, f.topHeight - (index - 1) * btHeight)
    playerText:SetFrameLevel(TJ.combatFrame:GetFrameLevel() + 10)
    playerText.name = name
    playerText.name2 = f._combatPlayerNames and f._combatPlayerNames[name] or TJ.GetIconFormName(name)
    playerText.color = { r, g, b }
    local t = AcquireCombatRegion(playerText, "FontString")
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
            local tex = AcquireCombatRegion(f, "Texture")
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
    YieldCombatWork()
    return playerText
end
local function CreateCountNum(playerText, num)
    local t = AcquireCombatRegion(playerText, "FontString")
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
            SortCombatWork(auraTbl[index], function(a, b)
                return a.time < b.time
            end)
            tbl = func(aura)
            if aura.durTimeMin then
                for i = #tbl, 1, -1 do
                    YieldCombatWork(1 / 16)
                    if tbl[i].endTime - tbl[i].startTime <= aura.durTimeMin then
                        tremove(tbl, i)
                    end
                end
            end
        else
            SortCombatWork(auraTbl[index], function(a, b)
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
        YieldCombatWork(1 / 32)
    end
    SortCombatWork(newTbl, function(a, b)
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
    local generation = combatFrame._combatGeneration
    After(.5, function()
        if generation ~= analysisGeneration or combatFrame._combatGeneration ~= generation
            or not combatFrame:IsVisible() then
            return
        end
        local f, child = combatFrame._combatTextLog, combatFrame._combatTextChild
        if not f then
            f, child = TJ.CreateScrollFrame(combatFrame, 350, combatFrame:GetHeight(), true)
            combatFrame._combatTextLog, combatFrame._combatTextChild = f, child
        end
        f:SetSize(350, combatFrame:GetHeight())
        if f.scroll then
            f.scroll:SetWidth(f:GetWidth() - 31)
            f.scroll:SetHeight(f:GetHeight() - 9)
            f.scroll:SetVerticalScroll(0)
            child:SetWidth(f.scroll:GetWidth())
            child:SetHeight(f.scroll:GetHeight())
        end
        f:ClearAllPoints()
        f:Show()
        f:SetBackdrop(combatFrame:GetBackdrop())
        f:SetBackdropColor(combatFrame:GetBackdropColor())
        f:SetBackdropBorderColor(combatFrame:GetBackdropBorderColor())
        child:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        f:SetPoint("TOPLEFT", combatFrame, "TOPRIGHT", 1, 0)
        local lines = {}
        local function GetName(guidTbl, GUID)
            local name = guidTbl[GUID].name
            if guidTbl[GUID].class then
                name = "|c" .. select(4, GetClassColor(guidTbl[GUID].class)) .. name .. "|r"
            end
            return name
        end
        for _, bar in ipairs(db) do
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
                lines[#lines + 1] = format('%s %s', TJ.STC_dis(TJ.SecondsToTime(v.endTime, 2)), text)
            end
        end
        child:SetText(table.concat(lines, "\n"))
        if #lines == 0 then
            f:Hide()
        end
    end)
end

-- 按目标 GUID 分组的伤害复盘；只引用原始事件，不另存战斗日志。
local function TargetDamageLess(a, b)
    if a.time ~= b.time then return a.time < b.time end
    return (a.event.i or 0) < (b.event.i or 0)
end

local function TargetDamageOwner(context, guid)
    local seen = {}
    while guid and context.log.guid[guid] and context.log.guid[guid].ownerGUID and not seen[guid] do
        seen[guid] = true
        guid = context.log.guid[guid].ownerGUID
    end
    return guid
end

local function TargetDamagePlayer(context, guid, roster)
    local owner = TargetDamageOwner(context, guid)
    local unit = context.log.guid[owner] or {}
    local name = unit.name or UNKNOWN
    local member = roster[name]
    local class = unit.class or (member and member.class)
    local icon = member and TJ.talentIcon[class] and TJ.talentIcon[class][member.talent]
    if not icon and member then icon = member.combatRole end
    local r, g, b, hex = 1, 1, 1, "ffffffff"
    if class then r, g, b, hex = GetClassColor(class) end
    name = (icon and AddTexture(icon) or "") .. "|c" .. hex .. name .. "|r"
    if guid ~= owner then
        name = name .. format(L["（宠物：%s）"], (context.log.guid[guid] or {}).name or UNKNOWN)
    end
    return name, r, g, b
end

local function TargetDamageText(record, context, roster)
    local v = record.event
    local centiseconds = floor(record.time * 100 + .5)
    local time = format("%d:%02d.%02d ", floor(centiseconds / 6000),
        floor(centiseconds / 100) % 60, centiseconds % 100)
    if record.subevent == "UNIT_DIED" then
        return time .. L["坍缩星死亡"], time, L["坍缩星死亡"]
    end
    local name = TargetDamagePlayer(context, context:GetGUID(v[4]), roster)
    local swing = record.subevent == "SWING_DAMAGE"
    local amountIndex = swing and 12 or 15
    local amount = max(0, (v[amountIndex] or 0) - max(0, v[amountIndex + 1] or 0))
    local skill = AddTexture("Interface\\Icons\\ability_steelmelee") .. "[" .. L["平砍"] .. "]"
    if not swing then
        local id = v[12]
        skill = AddTexture(context:GetSpellIcon(id)) ..
            (C_Spell.GetSpellLink(id) or ("[" .. (v[13] or UNKNOWN) .. "]"))
    end
    local text = format(L["%s的%s造成%s点伤害"], name, skill, format("%d", amount))
    if record.subevent == "SPELL_PERIODIC_DAMAGE" then text = text .. L["（持续伤害）"] end
    if (v[amountIndex + 1] or 0) > 0 then
        text = text .. "|cffff0000" .. format(L["（过量：%s）"], format("%d", v[amountIndex + 1])) .. "|r"
    end
    return time .. text, time, text
end

-- 只创建可见行，时间和正文使用独立文本，避免长日志创建大量控件。
local targetDamageLineHeight = 16
local function UpdateTargetDamageLines(f)
    local scroll, child = f._combatTargetLog, f._combatTargetChild
    local lines = f._combatTargetLines or {}
    local lineHeight, timeWidth = targetDamageLineHeight, 70
    local first = floor(scroll.scroll:GetVerticalScroll() / lineHeight) + 1
    local count = math.ceil(scroll.scroll:GetHeight() / lineHeight) + 1
    for i = 1, count do
        local row = f._combatTargetRows[i]
        if not row then
            row = CreateFrame("Frame", nil, child)
            row:SetHyperlinksEnabled(true)
            row:EnableMouse(true)
            row.time = row:CreateFontString(nil, "OVERLAY")
            row.message = row:CreateFontString(nil, "OVERLAY")
            for _, text in ipairs({ row.time, row.message }) do
                text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
                text:SetJustifyH("LEFT")
                text:SetWordWrap(false)
            end
            row.time:SetPoint("LEFT")
            row.time:SetSize(timeWidth, lineHeight)
            row.time:SetTextColor(.6, .6, .6)
            row.message:SetPoint("LEFT", row, "LEFT", timeWidth, 0)
            row:SetScript("OnHyperlinkEnter", function(self, link)
                GameTooltip:SetOwner(self, "ANCHOR_CURSOR")
                GameTooltip:SetHyperlink(link)
                GameTooltip:Show()
            end)
            row:SetScript("OnHyperlinkLeave", GameTooltip_Hide)
            row:SetScript("OnLeave", GameTooltip_Hide)
            f._combatTargetRows[i] = row
        end
        local index = first + i - 1
        row.line = lines[index]
        if row.line then
            row:SetSize(child:GetWidth(), lineHeight)
            row:ClearAllPoints()
            row:SetPoint("TOPLEFT", child, "TOPLEFT", 0, -(index - 1) * lineHeight)
            row.message:SetSize(max(1, child:GetWidth() - timeWidth), lineHeight)
            row.time:SetText(row.line.time)
            row.message:SetText(row.line.text)
            row:Show()
        else
            row:Hide()
        end
    end
    for i = count + 1, #f._combatTargetRows do f._combatTargetRows[i]:Hide() end
end

local function CreateTargetDamageTimeline(f, targets, context, valid)
    local rows, roster = {}, {}
    for _, member in ipairs(context.log.raidMember or {}) do roster[member.name] = member end
    for _, target in pairs(targets) do
        SortCombatWork(target.records, TargetDamageLess)
        rows[#rows + 1] = target
        YieldCombatWork()
    end
    SortCombatWork(rows, function(a, b)
        if a.firstTime ~= b.firstTime then return a.firstTime < b.firstTime end
        return a.guid < b.guid
    end)
    local rowHeight, detailHeight = btHeight, 300
    f:SetHeight(-f.topHeight + #rows * rowHeight + 10)
    local detail = f._combatTargetDetail
    if not detail then
        detail = CreateFrame("Frame", nil, f, "BackdropTemplate")
        f._combatTargetDetail = detail
        detail:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        detail:SetBackdropColor(0, 0, 0, .9)
        detail:SetBackdropBorderColor(.8, .8, .8, 1)
        detail.heading = detail:CreateFontString(nil, "OVERLAY")
        detail.heading:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        detail.heading:SetPoint("TOPLEFT", 10, -8)
        detail.heading:SetTextColor(1, 1, 1)
    end
    detail:ClearAllPoints()
    detail:SetPoint("BOTTOMLEFT", f, "TOPLEFT", 0, 5)
    detail:SetSize(f:GetWidth(), detailHeight + 32)
    detail:SetFrameLevel(f:GetFrameLevel() + 1)
    detail:Hide()
    local heading = detail.heading

    local scroll, child = f._combatTargetLog, f._combatTargetChild
    if not scroll then
        scroll, child = TJ.CreateScrollFrame(detail, f:GetWidth() - 20, detailHeight)
        f._combatTargetLog, f._combatTargetChild = scroll, child
        f._combatTargetRows = {}
        scroll.scroll:HookScript("OnVerticalScroll", function() UpdateTargetDamageLines(f) end)
    end
    scroll:SetParent(detail)
    scroll:SetFrameLevel(detail:GetFrameLevel() + 1)
    scroll:ClearAllPoints()
    scroll:SetPoint("TOPLEFT", detail, "TOPLEFT", 10, -27)
    scroll:SetSize(f:GetWidth() - 20, detailHeight)
    scroll:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,
    })
    scroll:SetBackdropColor(0, 0, 0, .8)
    scroll:SetBackdropBorderColor(.5, .5, .5, 1)
    scroll.scroll:SetSize(scroll:GetWidth() - 31, detailHeight - 9)
    child:SetWidth(scroll.scroll:GetWidth())
    child:SetHeight(scroll.scroll:GetHeight())
    f._combatTargetLines = {}
    scroll.scroll:SetVerticalScroll(0)
    UpdateTargetDamageLines(f)
    scroll:Show()
    local selection = 0
    local highlights = {}
    local function SelectTarget(target, index)
        if not valid() then return end
        -- 点击目标即固定面板，否则移出分析入口时面板会消失。
        if not f.click then TJ.SetCombatFrameIsClick(f) end
        detail:Show()
        selection = selection + 1
        local request = selection
        for i, highlight in ipairs(highlights) do highlight:SetShown(i == index) end
        heading:SetText(TJ.GetRTIcon(target.raidTarget) .. format(L["坍缩星%d 伤害记录"], index))
        f._combatTargetLines = { { time = "", text = L["正在整理伤害记录…"] } }
        scroll.scroll:SetVerticalScroll(0)
        UpdateTargetDamageLines(f)
        RunCombatBuild(f, function() return valid() and selection == request end, function()
            local lines = {}
            for _, record in ipairs(target.records) do
                local _, time, text = TargetDamageText(record, context, roster)
                lines[#lines + 1] = { time = time, text = text }
                YieldCombatWork()
            end
            if valid() and selection == request then
                f._combatTargetLines = lines
                child:SetHeight(max(scroll.scroll:GetHeight(), #lines * targetDamageLineHeight))
                scroll.scroll:UpdateScrollChildRect()
                scroll.scroll:SetVerticalScroll(max(0, scroll.scroll:GetVerticalScrollRange()))
                UpdateTargetDamageLines(f)
            end
        end)
    end
    for index, target in ipairs(rows) do
        local row = AcquireCombatWidget("Button", f)
        row:SetSize(f:GetWidth() - 20, rowHeight)
        row:SetPoint("TOPLEFT", 10, f.topHeight - (index - 1) * rowHeight)
        local label = AcquireCombatRegion(row, "FontString")
        label:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        label:SetPoint("LEFT")
        label:SetText(TJ.GetRTIcon(target.raidTarget) .. format(L["坍缩星%d"], index))
        label:SetTextColor(1, .82, 0)
        local highlight = AcquireCombatRegion(row, "Texture", "BACKGROUND")
        highlight:SetAllPoints()
        highlight:SetColorTexture(1, 1, 1, .12)
        highlight:Hide()
        highlights[index] = highlight
        local function Select() SelectTarget(target, index) end
        row:SetScript("OnClick", Select)
        -- 同一玩家同一像素列合并成一个命中区域；明细始终保留全部事件。
        local buckets, ordered = {}, {}
        local duration = max(context.log.duration, .01)
        for _, record in ipairs(target.records) do
            local x = min(f.lwidth - 4, max(0, f.lwidth * record.time / duration))
            local owner = TargetDamageOwner(context, context:GetGUID(record.event[4]))
            local key = record.subevent == "UNIT_DIED" and "death" or
                tostring(floor(x / 4)) .. ":" .. tostring(owner)
            local bucket = buckets[key]
            if not bucket then
                bucket = { x = x, records = {}, death = record.subevent == "UNIT_DIED" }
                buckets[key] = bucket
                ordered[#ordered + 1] = bucket
            end
            bucket.records[#bucket.records + 1] = record
            YieldCombatWork(1 / 16)
        end
        for _, bucket in ipairs(ordered) do
            local marker = AcquireCombatWidget("Button", row)
            marker:SetSize(bucket.death and 7 or 4, btHeight - 4)
            marker:SetPoint("LEFT", row, "LEFT", f.leftWidth - 10 + bucket.x, 0)
            local tex = AcquireCombatRegion(marker, "Texture")
            tex:SetAllPoints()
            local _, r, g, b = TargetDamagePlayer(context, context:GetGUID(bucket.records[1].event[4]), roster)
            if bucket.death then r, g, b = 1, .3, 0 end
            tex:SetColorTexture(r, g, b, .9)
            marker:SetScript("OnClick", Select)
            marker:SetScript("OnEnter", function(self)
                GameTooltip:SetOwner(self, "ANCHOR_TOP")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(label:GetText(), 1, .82, 0)
                for i = 1, min(#bucket.records, 8) do
                    GameTooltip:AddLine(TargetDamageText(bucket.records[i], context, roster), 1, .82, 0)
                end
                GameTooltip:AddLine(L["点击查看该星的全部伤害记录"], .7, .7, .7)
                GameTooltip:Show()
            end)
            marker:SetScript("OnLeave", GameTooltip_Hide)
            YieldCombatWork()
        end
    end
    heading:SetText(L["点击坍缩星，查看逐条伤害记录"])
end

-- 通报
local function UpdateSendButtonPoint()
    TJ.combatFrameSendButton:SetParent(TJ.combatFrame)
    TJ.combatFrameSendButton:ClearAllPoints()
    TJ.combatFrameSendButton:SetPoint("BOTTOMRIGHT", TJ.combatFrame, "BOTTOMRIGHT", -10, 5)
end
local function CreateSendButton(info, playerTbl, bt, isRefresh)
    if isRefresh and TJ.combatFrameSendButton then
        TJ.combatFrameSendButton:Hide()
    end
    local f = TJ.combatFrame
    local combatLog = TJ.GetCombatLog()
    local guidTbl = combatLog.guid
    local button = f._combatSendButton
    if not button then
        button = TJ.CreateButton(f)
        f._combatSendButton = button
    end
    button:Enable()
    button:Show()
    button:SetSize(100, 25)
    TJ.combatFrameSendButton = button
    UpdateSendButtonPoint()
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
        local generation = f._combatGeneration
        After(2, function()
            if f._combatInUse and generation == analysisGeneration and f._combatGeneration == generation then
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
    local combatLog = TJ.GetCombatLog()
    local r, g, b = GetClassColor(v.class)
    local bar = AcquireCombatWidget("StatusBar", f, "BackdropTemplate")
    bar:SetPoint("TOPLEFT", f, "TOPLEFT",
        f.leftWidth,
        f.topHeight - (i - 1) * btHeight - 2)
    bar:SetPoint("BOTTOMRIGHT", f, "TOPLEFT",
        f.leftWidth + f.lwidth * (maxDamage > 0 and v.damage / maxDamage or 0),
        f.topHeight - btHeight - (i - 1) * btHeight + 2)
    bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
    bar:SetStatusBarColor(r, g, b, .8)

    if v.petDamage and v.petDamage > 0 then
        local parent = bar
        local bar = AcquireCombatWidget("StatusBar", parent, "BackdropTemplate")
        bar:SetSize(v.petDamage / v.damage * parent:GetWidth(), parent:GetHeight())
        bar:SetPoint("RIGHT")
        bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
        bar:SetStatusBarColor(.4, .8, .94, .8)
        bar:SetStatusBarColor(ns.RGB("66CCFF"))
        bar:SetFrameLevel(parent:GetFrameLevel())
    end

    local damageText = AcquireCombatRegion(bar, "FontString")
    damageText:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
    damageText:SetPoint("LEFT", 2, 0)
    damageText:SetText(TJ.FormatNumber(v.damage))
    damageText:SetJustifyH("LEFT")

    bar:SetScript("OnEnter", function(self)
        if not v.detail then return end
        TJ.ResetCombatTooltipBars()
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
                petName = GetNameByGUID(vv.petGUID, combatLog)
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
    YieldCombatWork()
end
local function GetDamage(infoType, tbl, v, subevent, GUID, isSpell, petGUID, destGUID, class, combatLog, context)
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
        local detail = tbl[GUID].detail[spellID]
        icon = detail and detail.icon or context:GetSpellIcon(spellID)
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
        local destName = GetNameByGUID(destGUID, combatLog)
        tbl[GUID].destUnit[destName] = tbl[GUID].destUnit[destName] or { destGUID = destGUID, damage = 0 }
        tbl[GUID].destUnit[destName].damage = tbl[GUID].destUnit[destName].damage + amount
    end
    if petGUID then
        local petName = GetNameByGUID(petGUID, combatLog)
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
    TJ.combatFrameDropDown:SetPoint("BOTTOM", TJ.combatFrame, "BOTTOM", 0, 7)
    TJ.combatFrameDropDown:Show()
end
local function CreateDropDown(dropDownInfo, isRefresh)
    if not TJ.combatFrameDropDown then
        TJ.combatFrameDropDownInfo = {}
        local dropDown = LibBG:Create_UIDropDownMenu(nil, TJ.combatFrame)
        dropDown:SetWidth(150)
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "BOTTOM", dropDown, "TOP")
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

    local button = AcquireCombatWidget("Button", f)
    button:SetSize(25, 25)
    button:SetPoint("TOPRIGHT", f, "TOPRIGHT", -25, 1)
    button.ownerTitle = bt

    local tex = AcquireCombatRegion(button, "Texture", "ARTWORK")
    tex:SetPoint('CENTER')
    tex:SetSize(18, 18)
    tex:SetTexture("Interface\\Buttons\\UI-OptionsButton")
    button:SetNormalTexture(tex)
    local tex = AcquireCombatRegion(button, "Texture", "ARTWORK")
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

            LibBG:UIDropDownMenu_AddButton({ separator = true, notCheckable = true })

            local info = LibBG:UIDropDownMenu_CreateInfo()
            info.text = L["全部勾选"]
            info.notCheckable = true
            info.keepShownOnClick = true
            info.func = function()
                wipe(filter)
                LibBG:Refresh()
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
            info.func = LibBG.CloseDropDownMenus
            LibBG:UIDropDownMenu_AddButton(info)
        end)
    end

    button:SetScript("OnClick", function(self)
        TJ.toolCombatFrameDropDownOwner = self.ownerTitle
        self.items = TJ.toolCombatFrameDropDown.items
        LibBG:UIDropDownMenu_SetAnchor(self, 0, 0, "TOPLEFT", self, "BOTTOMLEFT")
        LibBG:ToggleDropDownMenu(1, nil, self)
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

local function ShowDamageFriendCount(playerTbl, info, infoType, context)
    local f = TJ.combatFrame
    local generation = f._combatGeneration
    local bars, sources, lists, events = {}, {}, {}, {}
    local event = TJ.GetCombatLogEvent()
    local swingKey, unknownSpell = {}, {}
    local offset = infoType == "damageFriend" and offsetTime2 or offsetTime
    local active = true
    local eventIndex, recordIndex, sortIndex, barIndex = 1, 1, 1, 1
    local stage = "build"
    local queryLists, queryIndex, queryRecord, count, players

    for _, playerText in ipairs(playerTbl) do
        for _, bar in ipairs(playerText.barTbl) do
            if bar.tooltip:match(infoType) then
                bars[#bars + 1] = bar
                if bar.v.sourceGUID then sources[bar.v.sourceGUID] = {} end
            end
        end
    end
    if #bars == 0 then return end
    for subevent in pairs(event) do
        if TJ.CombatFiterEvent("damage", subevent, info[infoType]) then
            events[#events + 1] = { name = subevent, swing = subevent:match("^SWING_") ~= nil }
        end
    end

    local function Cancel()
        active = false
        bars, sources, lists, events, event, queryLists, players, context = nil, nil, nil, nil, nil, nil, nil, nil
    end
    f._combatCancelTasks = f._combatCancelTasks or {}
    f._combatCancelTasks[#f._combatCancelTasks + 1] = Cancel

    local function LowerBound(list, time)
        local lo, hi = 1, #list + 1
        while lo < hi do
            local mid = math.floor((lo + hi) / 2)
            if list[mid][1] < time then lo = mid + 1 else hi = mid end
        end
        return lo
    end
    local function Process()
        if not active then return end
        if generation ~= analysisGeneration or f._combatGeneration ~= generation or not f:IsVisible() then
            Cancel()
            return
        end
        local remaining = 1000
        while remaining > 0 do
            if stage == "build" then
                local descriptor = events[eventIndex]
                if not descriptor then
                    stage = "sort"
                else
                    local v = event[descriptor.name][recordIndex]
                    if not v then
                        eventIndex, recordIndex = eventIndex + 1, 1
                    else
                        recordIndex = recordIndex + 1
                        remaining = remaining - 1
                        local sourceGUID = context:GetGUID(v[4])
                        local buckets = sources[sourceGUID]
                        if buckets then
                            local destGUID = context:GetGUID(v[8])
                            local dest = context:GetUnit(destGUID)
                            local valid = dest.npcType == "Player"
                            if infoType == "damageFriend" then
                                valid = valid and v.hp and sourceGUID ~= destGUID
                                    and context:GetUnit(sourceGUID).npcType == "Player"
                            end
                            if valid then
                                local key = descriptor.swing and swingKey or (v[12] or unknownSpell)
                                local list = buckets[key]
                                if not list then
                                    list = {}; buckets[key] = list; lists[#lists + 1] = list
                                end
                                if #list > 0 and list[#list][1] > v[1] then list.unsorted = true end
                                list[#list + 1] = v
                            end
                        end
                    end
                end
            elseif stage == "sort" then
                local list = lists[sortIndex]
                if not list then
                    stage = "query"
                    -- 查询只保留需要的事件引用，不再持有整个事件表。
                    event, events, lists = nil, nil, nil
                else
                    sortIndex = sortIndex + 1
                    if list.unsorted then
                        sort(list, function(a, b) return a[1] < b[1] end)
                        list.unsorted = nil
                        break -- 一次回调最多排序一个桶。
                    end
                end
            else
                local bar = bars[barIndex]
                if not bar then
                    Cancel(); return
                end
                if not bar:IsVisible() then
                    Cancel(); return
                end
                if not queryLists then
                    queryLists, queryIndex, count, players = {}, 1, 0, {}
                    local buckets = sources[bar.v.sourceGUID]
                    if buckets then
                        if bar.v.spellID then
                            if buckets[swingKey] then queryLists[#queryLists + 1] = buckets[swingKey] end
                            if buckets[bar.v.spellID] then queryLists[#queryLists + 1] = buckets[bar.v.spellID] end
                        else
                            for _, list in pairs(buckets) do queryLists[#queryLists + 1] = list end
                        end
                    end
                end
                local list = queryLists[queryIndex]
                if not list then
                    bar.damageFriendCount = count
                    bar.damageFriendPlayers = players
                    local text = AcquireCombatRegion(bar, "FontString")
                    text:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
                    text:SetPoint("RIGHT", bar, "LEFT", 1, 0)
                    text:SetHeight(bar:GetHeight())
                    text:SetText(count)
                    barIndex = barIndex + 1
                    queryLists, queryRecord = nil, nil
                    remaining = remaining - 1
                else
                    -- 留出浮点边界余量，再用原来的 abs 判断，保持计数一致。
                    queryRecord = queryRecord or LowerBound(list, bar.v.endTime - offset - 0.000001)
                    local v = list[queryRecord]
                    if not v or v[1] > bar.v.endTime + offset + 0.000001 then
                        queryIndex, queryRecord = queryIndex + 1, nil
                    else
                        queryRecord = queryRecord + 1
                        remaining = remaining - 1
                        if math.abs(v[1] - bar.v.endTime) <= offset then
                            if infoType == "damageFriend" then
                                count = count + 1
                            else
                                local destGUID = context:GetGUID(v[8])
                                if not players[destGUID] then
                                    players[destGUID] = true; count = count + 1
                                end
                            end
                        end
                    end
                end
            end
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
            YieldCombatWork(1 / 16)
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
    analysisGeneration = analysisGeneration + 1
    ReleaseCombatPanels()
    wipe(TJ.combatFrameMany)
    wipe(TJ.combatFrameProcessors)
end

local batch = 1000
local batch2 = 1000

function TJ.CreateCombatFrame(...)
    local bt, processorKey, info, updateTitleColor, manyIndex, allInfo, click, isRefresh = ...
    if info and info.castRecords then
        TJ.CreateCastRecordsFrame(bt, updateTitleColor, click, processorKey)
        return
    end
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
    local startIndex, eventIndex, infoIndex = 1, 1, 1
    local infos = {}
    local generation = analysisGeneration
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
    local context = TJ.CreateCombatAnalysisContext(combatLog, TJ.combatFrameDropDownPahse)
    local function GetGUID(index) return context:GetGUID(index) end
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

    local f = not updateTitleColor and AcquireCombatPanel(parent) or {}
    if not updateTitleColor then
        -- 使用该场战斗的专精快照，避免离队或切换专精后影响历史分析。
        f._combatPlayerNames = {}
        for _, member in ipairs(combatLog.raidMember or {}) do
            local icons = TJ.talentIcon[member.class]
            local icon = icons and icons[member.talent]
            if not icon then icon = member.combatRole or member.role end
            f._combatPlayerNames[member.name] = (icon and AddTexture(icon) or "") .. member.name
        end
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
    end

    -- 标题和关闭按钮
    if not updateTitleColor then
        local t = AcquireCombatRegion(f, "FontString")
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
        f.titleText = t

        f.CloseButton = AcquireCombatWidget("Button", f, "UIPanelCloseButton")
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
            local t = AcquireCombatRegion(f, "FontString")
            t:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            t:SetPoint("TOPRIGHT", -5, -5)
            t:SetTextColor(1, .82, 0)
            t:SetText(AddTexture("LEFT") .. L["固定该面板，查看细节"])
            f.tipsText = t
        end
    end

    -- 时间轴
    if not updateTitleColor and not info.dps and not info.hps and not info.dps_friend then
        local l = AcquireCombatRegion(f, "Line")
        l:SetColorTexture(.5, .5, .5)
        l:SetStartPoint("TOPLEFT", leftWidth, topHeight)
        l:SetEndPoint("TOPRIGHT", rightWidth, topHeight)
        l:SetThickness(1.5)

        local l1 = AcquireCombatRegion(f, "Line")
        l1:SetColorTexture(.5, .5, .5)
        l1:SetStartPoint("TOPLEFT", leftWidth, topHeight + 5)
        l1:SetEndPoint("TOPLEFT", leftWidth, topHeight)
        l1:SetThickness(1.5)

        local t = AcquireCombatRegion(f, "FontString", "OVERLAY")
        t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
        t:SetPoint("BOTTOM", l1, "TOP", 0, 0)
        t:SetTextColor(1, 0.82, 0)
        t:SetText("0:00")

        local l2 = AcquireCombatRegion(f, "Line")
        l2:SetColorTexture(.5, .5, .5)
        l2:SetStartPoint("TOPLEFT", leftWidth + lwidth, topHeight + 5)
        l2:SetEndPoint("TOPLEFT", leftWidth + lwidth, topHeight)
        l2:SetThickness(1.5)

        local t = AcquireCombatRegion(f, "FontString", "OVERLAY")
        t:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
        t:SetPoint("BOTTOM", l2, "TOP", 0, 0)
        t:SetTextColor(1, 0.82, 0)
        t:SetText(TJ.SecondsToTime(duration))

        -- BOSS阶段时间轴
        for _, v in pairs(combatLog.otherTime) do
            if type(v) == "table" and v.time and v.time <= duration + 1 then
                local per = v.time / duration
                local l = AcquireCombatRegion(f, "Line")
                l:SetColorTexture(.5, .5, .5)
                l:SetStartPoint("TOPLEFT", f.leftWidth + f.lwidth * per, f.topHeight + 10)
                l:SetEndPoint("TOPLEFT", f.leftWidth + f.lwidth * per, f.topHeight)
                l:SetThickness(1.5)

                local t = AcquireCombatRegion(f, "FontString", "OVERLAY")
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
                    local l = AcquireCombatRegion(f, "Line", "OVERLAY")
                    l:SetColorTexture(0, 1, 0)
                    l:SetStartPoint("TOPLEFT", startWidth, f.topHeight + 0)
                    l:SetEndPoint("TOPLEFT", endWidth, f.topHeight + 0)
                    l:SetThickness(1.5)

                    local l1 = AcquireCombatRegion(f, "Line", "OVERLAY")
                    l1:SetColorTexture(0, 1, 0)
                    l1:SetStartPoint("TOPLEFT", startWidth, topHeight + 5)
                    l1:SetEndPoint("TOPLEFT", startWidth, topHeight)
                    l1:SetThickness(1.5)

                    local l2 = AcquireCombatRegion(f, "Line", "OVERLAY")
                    l2:SetColorTexture(0, 1, 0)
                    l2:SetStartPoint("TOPLEFT", endWidth, topHeight + 5)
                    l2:SetEndPoint("TOPLEFT", endWidth, topHeight)
                    l2:SetThickness(1.5)

                    local t = AcquireCombatRegion(f, "FontString")
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
    local damageTargets = {}
    if info.targetDamage then
        local events = { "SPELL_SUMMON", "UNIT_DIED", "SWING_DAMAGE", "SPELL_DAMAGE",
            "SPELL_PERIODIC_DAMAGE", "RANGE_DAMAGE", "DAMAGE_SHIELD", "DAMAGE_SPLIT" }
        local function GetInfo(v, subevent)
            local guid = GetGUID(v[8])
            if context:GetUnit(guid).npcID ~= info.targetDamage.npcID then return end
            if not TJ.CombatInfoFilter(info, v, "targetDamage", context) then return end
            local isDamage = subevent ~= "UNIT_DIED" and subevent ~= "SPELL_SUMMON"
            if isDamage then
                local owner = TargetDamageOwner(context, GetGUID(v[4]))
                local unit = owner and guidTbl[owner]
                if not unit or not unit.class then return end
            end
            haveAura = true
            if updateTitleColor then return true end
            local target = damageTargets[guid]
            if not target then
                target = { guid = guid, firstTime = v[1], records = {} }
                damageTargets[guid] = target
            end
            target.firstTime = min(target.firstTime, v[1])
            -- 不同事件分类分批处理，按时间保留最近一次非空的目标标记。
            if v[11] and (not target.raidTargetTime or v[1] > target.raidTargetTime
                    or (v[1] == target.raidTargetTime and (v.i or 0) > target.raidTargetIndex)) then
                target.raidTarget = v[11]
                target.raidTargetTime = v[1]
                target.raidTargetIndex = v.i or 0
            end
            if subevent ~= "SPELL_SUMMON" then
                target.records[#target.records + 1] = { event = v, subevent = subevent, time = v[1] }
            end
        end
        tinsert(infos, { infoType = "targetDamage", events = events, GetInfo = GetInfo })
    end
    -- DPS/HPS排名
    for _, infoType in ipairs({ "dps", "hps", "dps_friend" }) do
        if info[infoType] then
            f.dpsTbl = {}
            local function GetInfo(v, subevent)
                if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
                local GUID
                local petGUID
                local yes
                if info[infoType].type == "d" then -- 显示承伤
                    GUID = GetGUID(v[8])
                    yes = true
                    if info[infoType].spell then
                        yes = nil
                        for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
                            local npcType = context:GetUnit(GUID).npcType
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
                            combatLog.guid[GUID].class, combatLog, context)
                    else
                        GetDamage(infoType, f.dpsTbl, v, subevent, GUID, true, petGUID, destGUID, combatLog.guid[GUID]
                            .class, combatLog, context)
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "d"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
                            YieldCombatWork(1 / 16)
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
            for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
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
                if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
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
                        for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
            local destGUID = GetGUID(v[8])
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            local yes
            for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
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
                for _, i in ipairs(context:GetSpellRules(info[infoType], v[15])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
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
                for _, i in ipairs(context:GetSpellRules(info[infoType], v[15])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
            local destGUID = GetGUID(v[8])
            if not destGUID and info[infoType].getDestGUID then
                destGUID = context:GetNPCGUID(info[infoType].getDestGUID)
            end
            local sourceGUID = GetGUID(v[4])
            local GUID = "s"
            if info[infoType].type == "d" then
                GUID = destGUID
            elseif info[infoType].type == "s" then
                GUID = sourceGUID
            end
            GUID = GUID or ""
            for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
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
                        for _, i in ipairs(context:GetSpellRules(info[infoType], v[12])) do
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
            if not TJ.CombatInfoFilter(info, v, infoType, context) then return end
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
        local textLog
        if haveAura and not updateTitleColor then
            if info.targetDamage then
                CreateTargetDamageTimeline(f, damageTargets, context, function()
                    return f._combatInUse and f._combatGeneration == generation and generation == analysisGeneration
                end)
            elseif info.dps or info.hps or info.dps_friend then
                local newTbl = {}
                for guid, v in pairs(f.dpsTbl) do
                    YieldCombatWork(1 / 16)
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
                SortCombatWork(newTbl, function(a, b)
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
                        local t = AcquireCombatRegion(f, "FontString")
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
                        YieldCombatWork(1 / 16)
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
                            YieldCombatWork(1 / 32)
                        end
                    end
                    SortCombatWork(db, function(a, b)
                        if a.v.endTime and b.v.endTime then
                            return a.v.endTime < b.v.endTime
                        end
                    end)
                    textLog = db
                end
                f:SetHeight((barCount + 1) * btHeight - topHeight)

                if info.SSpowerSpell then
                    SSpowerSpell(playerTbl)
                end
                for _, playerText in ipairs(playerTbl) do GetHoverBars(playerText) end
                TJ.PrepareCombatHealthIndex(f, playerTbl, event, context)
            end
            f:Show()
            if textLog then CreateTextLog(f, textLog) end
            if info.damageFriend or info.beDamage2 then
                ShowDamageFriendCount(playerTbl, info, info.damageFriend and "damageFriend" or "beDamage2", context)
            end
            if click then
                TJ.SetCombatFrameIsClick(f)
            end
        end
    end
    local function FinishAnalysis()
        if GoNextInfo() and updateTitleColor then GoNextUpdateTitleColor() end
    end
    local function CanContinue()
        if generation ~= analysisGeneration or not TJ.combatFrameProcessors[processorKey] then
            return false
        end
        if not updateTitleColor and not bt.isOnEnter and TJ.combatFrameMany[1] and not TJ.combatFrameMany[1].click then
            TJ.combatFrameMany[1]:Hide()
            return false
        end
        return true
    end
    local ProcessEvents
    local function AdvanceInfo()
        infoIndex = infoIndex + 1
        startIndex, eventIndex = 1, 1
        After(0, ProcessEvents)
    end
    ProcessEvents = function()
        if not CanContinue() then return end
        local infoType = infos[infoIndex] and infos[infoIndex].infoType
        if not infoType then
            -- 全部子战斗分析类型已经处理完成，结束
            if updateTitleColor then
                Success()
                FinishAnalysis()
            else
                RunCombatBuild(f, CanContinue, Success, FinishAnalysis)
            end
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
                    if updateTitleColor then
                        infos[infoIndex].StartCreatePlayerFrame()
                    else
                        RunCombatBuild(f, CanContinue, infos[infoIndex].StartCreatePlayerFrame, AdvanceInfo)
                        return
                    end
                end
                AdvanceInfo()
                return
            end
        end
        After(0, ProcessEvents)
    end
    ProcessEvents()
end
