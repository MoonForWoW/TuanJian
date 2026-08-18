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
    local mainFrame = TJ.raidTargetMainFrame
    local raidTargetTbl = {
        { num = 1, l = 0, r = 0.25, t = 0, b = 0.25 },
        { num = 2, l = 0.25, r = 0.50, t = 0, b = 0.25 },
        { num = 3, l = 0.5, r = 0.75, t = 0, b = 0.25 },
        { num = 4, l = 0.75, r = 1, t = 0, b = 0.25 },
        { num = 5, l = 0, r = 0.25, t = 0.25, b = 0.50 },
        { num = 6, l = 0.25, r = 0.50, t = 0.25, b = 0.50 },
        { num = 7, l = 0.50, r = 0.75, t = 0.25, b = 0.50 },
        { num = 8, l = 0.75, r = 1, t = 0.25, b = 0.50 },
    }
    local raidTargetOrderPlans = {
        { 2, 6, 1, 3, 4, 5, 7, 8 },
        { 1, 2, 3, 4, 5, 6, 7, 8 },
    }

    local function GetRaidTargetOrderPlan()
        return raidTargetOrderPlans[TuanJian.options.raidTargetOrder or 1] or raidTargetOrderPlans[1]
    end

    local function GetRaidTargetTexture(iconIndex, size)
        local icon = raidTargetTbl[iconIndex]
        return format([[|TInterface\TargetingFrame\UI-RaidTargetingIcons:%s:%s:0:0:100:100:%s:%s:%s:%s|t]],
            size or 0,
            size or 0,
            icon.l * 100,
            icon.r * 100,
            icon.t * 100,
            icon.b * 100)
    end

    local function GetRaidTargetOrderText(plan, size)
        local text = ""
        for _, iconIndex in ipairs(plan) do
            text = text .. GetRaidTargetTexture(iconIndex, size)
        end
        return text
    end

    local edits = {}
    local icons = {}
    mainFrame.edits = edits
    local function CreateButton(i)
        local tex = mainFrame:CreateTexture()
        if i == 1 then
            tex:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPLEFT", 100, -62)
        else
            tex:SetPoint("TOP", icons[i - 1], "BOTTOM", 0, -5)
        end
        tex:SetSize(25, 25)
        tex:SetTexture([[Interface\TargetingFrame\UI-RaidTargetingIcons]])
        tex:SetTexCoord(raidTargetTbl[i].l, raidTargetTbl[i].r, raidTargetTbl[i].t, raidTargetTbl[i].b)
        tinsert(icons, tex)

        local edit = CreateFrame("EditBox", nil, mainFrame, TJ.editTemplate)
        edit:SetSize(130, 20)
        edit:SetPoint("LEFT", tex, "RIGHT", 20, 0)
        edit:SetAutoFocus(false)
        edit:SetText(TuanJian.raidTarget[i] and TuanJian.raidTarget[i].text or "")
        if TuanJian.raidTarget[i] and TuanJian.raidTarget[i].class then
            local r, g, b = GetClassColor(TuanJian.raidTarget[i].class)
            edit:SetTextColor(r, g, b)
            edit.player = TuanJian.raidTarget[i].player
            edit.class = TuanJian.raidTarget[i].class
        end
        edit.i = i
        tinsert(edits, edit)

        function edit:Set(v)
            self:SetText(TJ.GetIconAndName(v))
            local r, g, b = GetClassColor(v.class)
            self:SetTextColor(r, g, b)
            self.player = v.name
            self.class = v.class
        end

        function edit:ClearAll()
            local i = self.i
            if self:GetText() ~= "" then
                self:SetText("")
            end
            self:SetTextColor(1, 1, 1)
            edit.player = nil
            edit.class = nil
            TuanJian.raidTarget[i] = nil
        end

        function edit:Save()
            local i = self.i
            TuanJian.raidTarget[i] = TuanJian.raidTarget[i] or {}
            TuanJian.raidTarget[i].text = self:GetText()
            TuanJian.raidTarget[i].player = self.player
            TuanJian.raidTarget[i].class = self.class
        end

        function edit:UpdateIcon()
            for i, v in ipairs(TJ.raidRosterInfo) do
                if self.player == v.name then
                    local text = TJ.GetIconAndName(v)
                    local r, g, b = GetClassColor(v.class)
                    self:SetTextColor(r, g, b)
                    self:SetText(text)
                    self:Save()
                    return
                end
            end
        end

        edit:SetScript("OnShow", function(self)
            self:UpdateIcon()
        end)
        edit:SetScript("OnTextChanged", function(self)
            if self:GetText() == "" then
                self:ClearAll()
            else
                self:Save()
            end
        end)
        edit:HookScript("OnEditFocusGained", function(self)
            TJ.lastfocus = self
            TJ.ListPlayer(self)
        end)
        edit:HookScript("OnEditFocusLost", function(self)
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
        end)
        edit:SetScript("OnMouseDown", function(self, enter)
            if enter == "RightButton" then
                self:SetEnabled(false)
                self:SetText("")
                self:ClearFocus()
                return
            end
        end)
        edit:SetScript("OnMouseUp", function(self, enter)
            self:SetEnabled(true)
        end)

        if i == 1 then
            local t = mainFrame:CreateFontString()
            t:SetPoint("BOTTOM", edit, "TOP", 0, 10)
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetText(L["标记锁定"])
            t:SetTextColor(1, 0.82, 0)
        end
    end
    for i, v in ipairs(raidTargetTbl) do
        CreateButton(i)
    end

    function mainFrame:GetAutoText()
        local plan = GetRaidTargetOrderPlan()
        local Texts = {
            L["把所有坦克依次安排为："] .. GetRaidTargetOrderText(plan)
        }
        local tbl = TJ.SortRaidRosterInfo(TJ.tankClass, "tank", true)
        for i, v in ipairs(tbl) do
            local iconIndex = plan[i]
            if iconIndex then
                tinsert(Texts, GetRaidTargetTexture(iconIndex) .. ns.SetClassCFF(v.name))
            end
        end
        return Texts
    end

    function mainFrame:SetAutoChoose()
        local self = mainFrame
        local plan = GetRaidTargetOrderPlan()
        for i, edit in ipairs(self.edits) do
            edit:ClearAll()
        end
        local tbl = TJ.SortRaidRosterInfo(TJ.tankClass, "tank", true)
        for i, v in ipairs(tbl) do
            local iconIndex = plan[i]
            if iconIndex then
                local edit = self.edits[iconIndex]
                edit:Set(v)
            end
        end
    end

    -- 一键安排标记顺序
    do
        local dropDown = LibBG:Create_UIDropDownMenu(nil, TJ.MainFrame)
        local option = TJ.CreateButton(mainFrame)
        option:SetPoint("LEFT", TJ.autoButton, "RIGHT", 0, 0)
        option:SetSize(23, TJ.autoButton:GetHeight())
        option:SetText("▼")
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "BOTTOMLEFT", option, "TOPLEFT")
        option:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if L_DropDownList1:IsVisible() and L_DropDownList1.dropdown == dropDown then
                L_DropDownList1:Hide()
            else
                local menu = {
                    {
                        text = L["标记顺序"],
                        isTitle = true,
                        notCheckable = true,
                    },
                }
                for i, plan in ipairs(raidTargetOrderPlans) do
                    local optionIndex = i
                    tinsert(menu, {
                        text = GetRaidTargetOrderText(plan, 13),
                        checked = (TuanJian.options.raidTargetOrder or 1) == optionIndex,
                        func = function()
                            TuanJian.options.raidTargetOrder = optionIndex
                        end,
                    })
                end
                tinsert(menu, {
                    text = CANCEL,
                    notCheckable = true,
                    func = function()
                        LibBG:CloseDropDownMenus()
                    end,
                })

                LibBG:EasyMenu(menu, dropDown, self, 0, 0, "MENU", 5)
            end
        end)
    end

    function TJ.UpdateEditIcon_RaidTarget()
        if mainFrame:IsVisible() then
            for i, edit in ipairs(mainFrame.edits) do
                edit:UpdateIcon()
            end
        end
    end

    function TJ.ClearRaidTarget(notClearRT)
        for i, edit in ipairs(mainFrame.edits) do
            edit:ClearAll()
        end
        if not notClearRT then
            for i = 1, GetNumGroupMembers(1) do
                local unit = "raid" .. i
                SetRaidTarget(unit, 0)
            end
        end
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
            TJ.ClearRaidTarget()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置"], 1, 1, 1, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    -- 启用
    do
        local bt = TJ.CreateButton(mainFrame)
        bt:SetSize(100, 25)
        bt:SetPoint("BOTTOM", TJ.MainFrame, "BOTTOM", 0, 20)
        bt:SetText(L["启用"])
        mainFrame.startButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if self.isStart then
                self.isStart = nil
                self:SetText(L["启用"])
                mainFrame:Stop()
            else
                self.isStart = true
                self:SetText(L["停用"])
                mainFrame:Start()
            end
        end)

        local updateFrame = CreateFrame("Frame")
        function mainFrame:Start()
            ns.SendSystemMessage(L["|cff00ff00已启用标记锁定！"])
            updateFrame.t = 1
            updateFrame:SetScript("OnUpdate", function(self, t)
                self.t = self.t + t
                if self.t >= 1 then
                    self.t = 0
                    for i, edit in ipairs(mainFrame.edits) do
                        local player = TJ.ClearCode(edit:GetText())
                        if player and player ~= '' then
                            local iconIndex = GetRaidTargetIndex(player)
                            if iconIndex ~= i then
                                SetRaidTarget(player, i)
                            end
                        end
                    end
                end
            end)
        end

        function mainFrame:Stop()
            ns.SendSystemMessage(L["|cffff0000已停用标记锁定！"])
            updateFrame:SetScript("OnUpdate", nil)
        end
    end
end)

-- 自动标记
do
    TJ.autoRaidTargetIcon1 = {
        [1] = true, -- 星星
        [2] = true, -- 大饼
        [3] = true, -- 紫菱
        [4] = true, -- 三角
        [5] = true, -- 月亮
        [6] = true, -- 方块
        [7] = true, -- 叉叉
        [8] = true, -- 骷髅
    }
    TJ.autoRaidTargetIcon2 = {
        [5] = true, -- 月亮
        [6] = true, -- 方块
        [7] = true, -- 叉叉
        [8] = true, -- 骷髅
    }
    TJ.autoRaidTargetIcon3 = {
        [1] = true, -- 星星
        [2] = true, -- 大饼
        [3] = true, -- 紫菱
        [4] = true, -- 三角
    }

    TJ.autoRaidTargetInfo = {}
    TJ.ActiveAutoRaidTarget = {}

    function TJ.WipeAutoRaidTargetActive()
        wipe(TJ.ActiveAutoRaidTarget)
    end

    local unit = "mouseover"

    local function SetTR(unit, isNamePlate)
        local guid = UnitGUID(unit)
        if guid and not UnitIsDead(unit) then
            local instanceID = select(8, GetInstanceInfo())
            local npcID = TJ.GetNPCID(guid)
            local info = TJ.autoRaidTargetInfo[instanceID]
            if info and info[npcID] then
                local i = GetRaidTargetIndex(unit)
                if i and info[npcID][i] then
                    TJ.ActiveAutoRaidTarget[i] = guid
                    return
                end
                if info[npcID].alawys then
                    for i = 8, 1, -1 do
                        if info[npcID][i] then
                            TJ.ActiveAutoRaidTarget[i] = guid
                            SetRaidTarget(unit, i)
                            return
                        end
                    end
                end
                if info[npcID].hpMin and (UnitHealth(unit) / UnitHealthMax(unit) < info[npcID].hpMin) then
                    return
                end
                if not TJ.ValueInTable(TJ.ActiveAutoRaidTarget, guid) then
                    if not isNamePlate or info[npcID].np then
                        for i = 8, 1, -1 do
                            if info[npcID][i] and not TJ.ActiveAutoRaidTarget[i] then
                                TJ.ActiveAutoRaidTarget[i] = guid
                                SetRaidTarget(unit, i)
                                return
                            end
                        end
                    end
                end
            end
        end
    end
    TJ.RegisterEvent("UPDATE_MOUSEOVER_UNIT", function(self, event)
        if TuanJian.options.autoRaidTarget == 1 and TJ.IsLeader()
            and (TJ.setRTinCombat or not InCombatLockdown()) then
            SetTR(unit)
        end
    end)

    TJ.RegisterEvent("NAME_PLATE_UNIT_ADDED", function(self, event, unit)
        if TuanJian.options.autoRaidTarget == 1 and TJ.IsLeader() then
            SetTR(unit, true)
        end
    end)

    TJ.RegisterEvent("PLAYER_REGEN_ENABLED", function(self)
        TJ.WipeAutoRaidTargetActive()
    end)

    local tex = [[Interface\TargetingFrame\UI-RaidTargetingIcons]]
    local RaidTargetingIcons = {
        "|T" .. tex .. ":0:0:0:0:100:100:0:25:0:25" .. "|t",
        "|T" .. tex .. ":0:0:0:0:100:100:25:50:0:25" .. "|t",
        "|T" .. tex .. ":0:0:0:0:100:100:55:75:0:25" .. "|t",
        "|T" .. tex .. ":0:0:0:0:100:100:75:100:0:25" .. "|t",
        "|T" .. tex .. ":0:0:0:0:100:100:0:25:25:50" .. "|t",
        "|T" .. tex .. ":0:0:0:0:100:100:25:50:25:50" .. "|t",
        "|T" .. tex .. ":0:0:0:0:100:100:50:75:25:50" .. "|t",
        "|T" .. tex .. ":0:0:0:0:100:100:75:100:25:50" .. "|t",
    }
    GameTooltip:HookScript("OnTooltipSetUnit", function(self)
        local guid = UnitGUID(unit)
        if TuanJian.options.autoRaidTarget == 1 and TJ.IsLeader()
            and (TJ.setRTinCombat or not InCombatLockdown()) and guid and not UnitIsDead(unit) then
            local instanceID = select(8, GetInstanceInfo())
            local npcID = TJ.GetNPCID(guid)
            local info = TJ.autoRaidTargetInfo[instanceID]
            if info and info[npcID] then
                local text = ""
                for i = 8, 1, -1 do
                    if info[npcID][i] then
                        text = text .. RaidTargetingIcons[i]
                    end
                end
                if text ~= "" then
                    GameTooltip:AddLine(L["TuanJian：自动标记为"] .. text, 1, .82, 0)
                    GameTooltip:Show()
                end
            end
        end
    end)
end
