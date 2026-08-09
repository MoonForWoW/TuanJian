local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local Size = ns.Size
local RGB = ns.RGB
local AddTexture = ns.AddTexture
local SendSystemMessage = ns.SendSystemMessage
local SetClassCFF = ns.SetClassCFF

local pt = print
local After = C_Timer.After
local BG = TJ
local Round = ns.Round

local realmID = GetRealmID()
local player = UnitName("player")
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

local logo = "TuanJian: "

TJ.Init(function()
    local mainFrame = TJ.equipMainFrame
    local slots = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18 }
    local buttons = {}

    -- 拖拽调队相关
    local MOVING_EQUIP_BUTTON = nil
    local EQUIP_TARGET_INDEX = nil
    local assignmentMenu = nil
    local EQUIP_MENU_UNIT = nil

    local bg1 = { .5, .5, .5, .7 }
    local bg2 = { 1, 1, 0, .5 }

    -- 独立的 OnUpdate 帧（不挂在 mainFrame 上，避免冲突）
    local dragUpdateFrame = CreateFrame("Frame")
    dragUpdateFrame:Hide()

    ------------------------------------------------------
    -- 所有按钮锚定到 mainFrame，互不依赖（便于拖拽）
    ------------------------------------------------------
    local BT_W, BT_H = 125, 32 -- 按钮宽/高

    -- 独立的高亮帧，置于最高层级，拖拽时覆盖在目标按钮上
    local highlightFrame = CreateFrame("Frame", nil, mainFrame, "BackdropTemplate")
    highlightFrame:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,
    })
    highlightFrame:SetBackdropColor(unpack(bg2))
    highlightFrame:SetBackdropBorderColor(1, 1, 1, .2)
    highlightFrame:SetSize(BT_W, BT_H)
    highlightFrame:Hide()
    local COL_GAP, ROW_GAP = 5, 0           -- 列间距、行间距
    local START_X, START_Y = 22, -55        -- 第一个按钮偏移
    local COL_W            = BT_W + COL_GAP -- 列宽（含间距）
    local ROW_H            = BT_H + ROW_GAP -- 行高（含间距）
    -- 第二排 Y 偏移：4 行按钮 + 最后一个按钮高度 + 25px 小队间距
    local ROW2_Y_OFFSET    = 4 * ROW_H + BT_H + 25

    local function GetButtonPoint(i)   -- i = 1..40
        local col = floor((i - 1) / 5) -- 0-7（小队编号）
        local row = (i - 1) % 5        -- 0-4（小队内位置）
        -- 前4小队在第一排，后4小队在第二排
        local x = START_X + (col % 4) * COL_W
        local y = START_Y - row * ROW_H - (col >= 4 and ROW2_Y_OFFSET or 0)
        return "TOPLEFT", TJ.MainFrame, "TOPLEFT", x, y
    end

    local function RestoreButtonPosition(bt)
        bt:ClearAllPoints()
        bt:SetPoint(GetButtonPoint(bt.index))
    end

    local function HideEquipFrame()
        if _G.BG and _G.BG.equipFrame and not _G.BG.equipFrame.click then
            _G.BG.equipFrame:Hide()
        end
    end

    local function HideAssignmentMenu()
        if assignmentMenu then
            assignmentMenu.mainTankButton._assignmentMenuFrame = nil
            assignmentMenu.mainAssistButton._assignmentMenuFrame = nil
            assignmentMenu.demoteButton._assignmentMenuFrame = nil
        end
        if InCombatLockdown() then return end
        if assignmentMenu then
            assignmentMenu.mainTankButton:Hide()
            assignmentMenu.mainAssistButton:Hide()
            assignmentMenu.demoteButton:Hide()
        end
    end

    local function CreateAssignmentButton(name, text)
        local bt = CreateFrame("Button", name, UIParent, "SecureActionButtonTemplate,BackdropTemplate")
        bt:SetSize(125, 20)
        bt:SetAttribute("type1", "macro")
        bt:SetHighlightTexture("Interface/QuestFrame/UI-QuestTitleHighlight", "ADD")
        bt:RegisterForClicks("AnyUp", "AnyDown")
        RegisterStateDriver(bt, "visibility", "[combat] hide; nop")
        local fs = bt:CreateFontString(nil, "OVERLAY")
        fs:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
        fs:SetPoint("LEFT", bt, "LEFT", 0, 0)
        fs:SetText(text)
        fs:SetTextColor(1, 1, 1)
        bt.Text = fs
        bt:Hide()
        return bt
    end

    local function GetAssignmentButtons()
        if not assignmentMenu then
            assignmentMenu = {}
            assignmentMenu.mainTankButton = CreateAssignmentButton("TuanJianEquipMainTankButton", L["提升为主坦克"])
            assignmentMenu.mainAssistButton = CreateAssignmentButton("TuanJianEquipMainAssistButton", L["提升为主助理"])
            assignmentMenu.demoteButton = CreateAssignmentButton("TuanJianEquipDemoteButton", L["降职"])
        end
        return assignmentMenu.mainTankButton, assignmentMenu.mainAssistButton, assignmentMenu.demoteButton
    end

    local function SetAssignmentButtonMacro(bt, macro)
        bt:SetAttribute("macrotext", macro)
    end

    local function CreateAssignmentMenuButton(description, bt, macro)
        local buttonDescription = description:CreateFrame()
        buttonDescription:AddInitializer(function(frame)
            SetAssignmentButtonMacro(bt, macro)
            bt._assignmentMenuFrame = frame
            bt:SetScript("PostClick", function(_, buttonName)
                TJ.PlaySound(1)
                buttonDescription:Pick(MenuInputContext.MouseButton, buttonName)
            end)
            C_Timer.After(0, function()
                if InCombatLockdown() or bt._assignmentMenuFrame ~= frame or not frame:IsShown() then return end
                local left, top = frame:GetLeft(), frame:GetTop()
                if not (left and top) then return end
                bt:ClearAllPoints()
                bt:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left, top)
                bt:SetSize(frame:GetWidth(), frame:GetHeight())
                bt:SetFrameStrata(frame:GetFrameStrata())
                bt:SetFrameLevel(frame:GetFrameLevel() + 1)
                bt:Show()
            end)
            return 125, 20
        end)
        buttonDescription:SetResponse(MenuResponse.CloseAll)
        buttonDescription:SetResponder(function()
            return MenuResponse.CloseAll
        end)
        buttonDescription:AddResetter(function(frame)
            if bt._assignmentMenuFrame ~= frame then return end
            bt._assignmentMenuFrame = nil
            if InCombatLockdown() then return end
            bt:Hide()
            bt:SetScript("PostClick", nil)
            bt:ClearAllPoints()
        end)
    end

    local function CreateAssignmentMenuButtons(description, unit)
        if InCombatLockdown() then return end
        if not (TJ.IsLeader() and unit and UnitIsPlayer(unit)) then return end

        local mainTankCommand = _G.SLASH_MAINTANKON1 or "/maintank"
        local mainAssistCommand = _G.SLASH_MAINASSISTON1 or "/mainassist"
        local mainTankOffCommand = _G.SLASH_MAINTANKOFF1 or "/maintankoff"
        local mainAssistOffCommand = _G.SLASH_MAINASSISTOFF1 or "/mainassistoff"

        local mainTankMacro = mainTankCommand .. " " .. unit
        local mainAssistMacro = mainAssistCommand .. " " .. unit

        local isMainTank = GetPartyAssignment("MAINTANK", unit)
        local isMainAssist = GetPartyAssignment("MAINASSIST", unit)
        local showMainTank = not isMainTank
        local showMainAssist = not isMainAssist
        local demoteMacro
        if isMainTank then
            demoteMacro = mainTankOffCommand .. " " .. unit
        elseif isMainAssist then
            demoteMacro = mainAssistOffCommand .. " " .. unit
        end
        if not (showMainTank or showMainAssist or demoteMacro) then return end

        local mainTankButton, mainAssistButton, demoteButton = GetAssignmentButtons()
        description:CreateDivider()
        if showMainTank then
            CreateAssignmentMenuButton(description, mainTankButton, mainTankMacro)
        end
        if showMainAssist then
            CreateAssignmentMenuButton(description, mainAssistButton, mainAssistMacro)
        end
        if demoteMacro then
            CreateAssignmentMenuButton(description, demoteButton, demoteMacro)
        end
    end

    -- 交换两个按钮的显示数据（异队换位后立即刷新，无需等待 GROUP_ROSTER_UPDATE）
    local function SwapButtonDisplay(btA, btB)
        btA.unit, btB.unit = btB.unit, btA.unit
        btA.name, btB.name = btB.name, btA.name
        btA.class, btB.class = btB.class, btA.class
        btA.iLevel, btB.iLevel = btB.iLevel, btA.iLevel

        local tmp = btA.nameText:GetText()
        btA.nameText:SetText(btB.nameText:GetText() or "")
        btB.nameText:SetText(tmp or "")

        tmp = btA.infoText:GetText()
        local tmpColor = { btA.infoText:GetTextColor() }
        btA.infoText:SetText(btB.infoText:GetText() or "")
        btA.infoText:SetTextColor(btB.infoText:GetTextColor())
        btB.infoText:SetText(tmp or "")
        btB.infoText:SetTextColor(unpack(tmpColor))

        tmp = btA.enchantText:GetText()
        btA.enchantText:SetText(btB.enchantText:GetText() or "")
        btB.enchantText:SetText(tmp or "")

        local tmpTex = btA.icon:GetTexture()
        btA.icon:SetTexture(btB.icon:GetTexture())
        btB.icon:SetTexture(tmpTex)

        tmpTex = btA.master:GetTexture()
        btA.master:SetTexture(btB.master:GetTexture())
        btB.master:SetTexture(tmpTex)

        local btATex = btA.talent:GetTexture()
        local btAAtlas = btA.talent:GetAtlas()
        local btBTex = btB.talent:GetTexture()
        local btBAtlas = btB.talent:GetAtlas()
        if btBTex and btBTex ~= 5171843 then
            btA.talent:SetTexture(btBTex)
            btA.talent:SetTexCoord(unpack(TJ.iconTexCoord))
        else
            btA.talent:SetAtlas(btBAtlas)
            btA.talent:SetTexCoord(0, 1, 0, 1)
        end
        if btATex and btATex ~= 5171843 then
            btB.talent:SetTexture(btATex)
            btB.talent:SetTexCoord(unpack(TJ.iconTexCoord))
        else
            btB.talent:SetAtlas(btAAtlas)
            btB.talent:SetTexCoord(0, 1, 0, 1)
        end
    end

    local function GetGroupFirstIndex(group)
        for i = (group - 1) * 5 + 1, group * 5 do
            local bt = buttons[i]
            if not bt.unit then
                return i
            end
        end
        return group * 5
    end

    local btMixin = {}
    do
        function btMixin:Reset()
            self.unit = nil
            self.name = nil
            self.class = nil
            self.iLevel = nil
            self.nameText:SetText("")
            self.infoText:SetText("")
            self.enchantText:SetText("")
            self.icon:SetTexture(nil)
            self.master:SetTexture(nil)
            self.talent:SetTexture(nil)
            self.talent:SetAtlas(nil)
            self.talent:SetTexCoord(0, 1, 0, 1)
        end

        function btMixin:FullUpdate(i, name, rank, class, role, combatRole, isML)
            if name then
                local color = "ffFFFFFF"
                if class then
                    color = select(4, GetClassColor(class))
                end
                self.unit = "raid" .. i
                self.name = name
                self.class = class
                self.nameText:SetText("|c" .. color .. name)
                if rank == 2 then
                    self.icon:SetTexture("interface/groupframe/ui-group-leadericon")
                elseif role == "MAINTANK" then
                    self.icon:SetTexture(132064)
                elseif role == "MAINASSIST" then
                    self.icon:SetTexture(132063)
                elseif rank == 1 then
                    self.icon:SetTexture("interface/groupframe/ui-group-assistanticon")
                end
                if isML then
                    self.master:SetTexture("Interface/GroupFrame/UI-Group-MasterLooter")
                    self.master:ClearAllPoints()
                    if self.icon:GetTexture() then
                        self.master:SetPoint("LEFT", self.icon, "RIGHT", 0, 0)
                    else
                        self.master:SetPoint("CENTER", self, "TOPLEFT", 2, -2)
                    end
                end
                if combatRole == "TANK" then
                    self.talent:SetAtlas("ui-lfg-roleicon-tank")
                elseif combatRole == "HEALER" then
                    self.talent:SetAtlas("ui-lfg-roleicon-healer")
                else
                    self.talent:SetAtlas("ui-lfg-roleicon-dps")
                end
            end
            self:SubUpdate()
        end

        function btMixin:SubUpdate()
            local name = self.name
            if name then
                local talent = TuanJian.talentInfo[name]
                if talent then
                    local class = self.class
                    self.talent:SetTexture(TJ.talentIcon[class] and TJ.talentIcon[class][talent])
                    self.talent:SetTexCoord(unpack(TJ.iconTexCoord))
                end
                local iLevel = TJ.GetPlayerItemsLevel(name)
                if iLevel and TuanJian.itemInfo[name] and next(TuanJian.itemInfo[name]) then
                    self.iLevel = iLevel
                    self.infoText:SetText(Round(iLevel, 0))
                    self.infoText:SetTextColor(1, 1, 1)
                    self:UpdateEnchant()
                else
                    self.iLevel = nil
                    self.infoText:SetText(L["距离太远"])
                    self.infoText:SetTextColor(.5, .5, .5)
                end
            end
        end

        function btMixin:UpdateEnchant()
            local name = self.name
            if name and _G.BG and _G.BG.GetEnchantInfo then
                local esum, gsum = 0, 0
                local isFull = true
                for _, slot in pairs(slots) do
                    local v = TuanJian.itemInfo[name][slot]
                    if v and v.link then
                        local hasChant, maxChant, hasGem, maxGem, equipLoc = _G.BG.GetEnchantInfo(v.link)
                        if not hasChant and maxChant then
                            esum = esum + 1
                            isFull = false
                        end
                        local g = maxGem - #hasGem
                        if g > 0 then
                            isFull = false
                            gsum = gsum + g
                        end
                    end
                end
                if not isFull then
                    local eText = 0
                    local gText = 0
                    if esum ~= 0 then
                        eText = "|cffff0000-" .. esum .. "|r"
                    end
                    if gsum ~= 0 then
                        gText = "|cffff0000-" .. gsum .. "|r"
                    end
                    self.enchantText:SetText(L["%s/%s"]:format(eText, gText))
                end
            end
        end

        function btMixin:OnClick(button)
            if button == "LeftButton" and self.unit then
                HideAssignmentMenu()
                self:ShowEquipFrame(true)
            end
        end

        function btMixin:OnMouseDown(button)
            if button == "RightButton" and self.unit then
                EQUIP_MENU_UNIT = self.unit
                CompactUnitFrame_OpenMenu(self, self.unit)
                EQUIP_MENU_UNIT = nil
                HideEquipFrame()
            elseif button == "LeftButton" and self.unit then
                -- 精确记录单击点相对按钮中心的偏移（在 OnDragStart 之前触发）
                local cx, cy = GetCursorPosition()
                local scale = UIParent:GetEffectiveScale()
                cx, cy = cx / scale, cy / scale
                local bx, by = self:GetCenter()
                self._dragOffsetX = bx - cx
                self._dragOffsetY = by - cy
            end
        end

        function btMixin:OnDragStart()
            if not (TJ.IsLeader() and self.unit) then return end
            if UnitAffectingCombat("player") or UnitAffectingCombat(self.unit) then return end
            HideAssignmentMenu()
            MOVING_EQUIP_BUTTON = self
            -- 保留当前屏幕坐标，切换到 UIParent（防止父框架裁剪，并提升层级）
            local centerX, centerY = self:GetCenter()
            self:ClearAllPoints()
            self:SetParent(UIParent)
            self:SetFrameStrata("HIGH")
            self:SetPoint("CENTER", UIParent, "BOTTOMLEFT", centerX, centerY)
            self:SetBackdropColor(unpack(bg1))
            local lastTarget = nil
            dragUpdateFrame:SetScript("OnUpdate", function(frame, elapsed)
                if not MOVING_EQUIP_BUTTON then return end
                HideEquipFrame()
                local x, y = GetCursorPosition()
                local scale = UIParent:GetEffectiveScale()
                x, y = x / scale, y / scale
                local ox = MOVING_EQUIP_BUTTON._dragOffsetX or 0
                local oy = MOVING_EQUIP_BUTTON._dragOffsetY or 0
                MOVING_EQUIP_BUTTON:ClearAllPoints()
                MOVING_EQUIP_BUTTON:SetPoint("CENTER", UIParent, "BOTTOMLEFT", x + ox, y + oy)
                -- 检测光标下的目标按钮
                local target = nil
                for _, bt in ipairs(buttons) do
                    if bt ~= MOVING_EQUIP_BUTTON and bt:IsVisible() then
                        local left, right, top, bottom = bt:GetLeft(), bt:GetRight(), bt:GetTop(), bt:GetBottom()
                        if left and x >= left and x <= right and y <= top and y >= bottom then
                            target = bt
                            break
                        end
                    end
                end
                -- 战斗中或同队且有一方是团长时，不显示高亮（互换无效）
                local showHighlight = true
                local srcIdx = MOVING_EQUIP_BUTTON.index
                local srcGroup = floor((srcIdx - 1) / 5) + 1
                local tgtIdx, tgtGroup
                if target then
                    tgtIdx = target.index
                    tgtGroup = floor((tgtIdx - 1) / 5) + 1
                end
                if UnitAffectingCombat("player") or (MOVING_EQUIP_BUTTON.unit and UnitAffectingCombat(MOVING_EQUIP_BUTTON.unit)) then
                    showHighlight = false
                elseif target then
                    if srcGroup == tgtGroup then
                        if not target.unit or UnitIsGroupLeader(MOVING_EQUIP_BUTTON.unit) or (target.unit and UnitIsGroupLeader(target.unit)) then
                            showHighlight = false
                        end
                    end
                end
                if lastTarget ~= target then
                    if target and showHighlight then
                        if not target.unit and srcGroup ~= tgtGroup then
                            target = buttons[GetGroupFirstIndex(tgtGroup)]
                        end
                        -- 使用目标按钮的屏幕坐标（跨父框架），高亮帧在UIParent上
                        local tleft = target:GetLeft()
                        local tbottom = target:GetBottom()
                        if tleft and tbottom then
                            highlightFrame:ClearAllPoints()
                            highlightFrame:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", tleft, tbottom + BT_H)
                            highlightFrame:Show()
                        end
                    else
                        highlightFrame:Hide()
                    end
                    lastTarget = target
                end
            end)
            dragUpdateFrame:Show()
        end

        function btMixin:OnDragStop()
            dragUpdateFrame:Hide()
            dragUpdateFrame:SetScript("OnUpdate", nil)
            local source = MOVING_EQUIP_BUTTON
            if source then
                source:SetBackdropColor(0, 0, 0, 0)
            end
            -- 查找释放时光标所在的目标按钮
            local target = nil
            if source then
                local x, y = GetCursorPosition()
                local scale = UIParent:GetEffectiveScale()
                x, y = x / scale, y / scale
                for _, bt in ipairs(buttons) do
                    if bt ~= source and bt:IsVisible() then
                        local left, right, top, bottom = bt:GetLeft(), bt:GetRight(), bt:GetTop(), bt:GetBottom()
                        if left and x >= left and x <= right and y <= top and y >= bottom then
                            target = bt
                            break
                        end
                    end
                end
            end
            -- 恢复所有高亮
            for _, bt in ipairs(buttons) do
                bt:SetBackdropColor(0, 0, 0, 0)
            end
            highlightFrame:Hide()
            -- 还原按钮到原始位置
            if source then
                source:SetAlpha(1)
                source:SetParent(mainFrame)
                source:SetFrameStrata("MEDIUM")
                RestoreButtonPosition(source)
            end
            if source and target and source ~= target and source.unit
                and not (UnitAffectingCombat("player") or UnitAffectingCombat(source.unit) or (target.unit and UnitAffectingCombat(target.unit))) then
                local srcIdx = tonumber(source.unit:match("raid(%d+)"))
                if srcIdx then
                    local srcGroup = floor((source.index - 1) / 5) + 1
                    local tgtGroup = floor((target.index - 1) / 5) + 1
                    if target.unit then
                        local tgtIdx = tonumber(target.unit:match("raid(%d+)"))
                        if tgtIdx then
                            -- 同队且一方是队长（第一位），互换无效，跳过
                            if srcGroup == tgtGroup then
                                if UnitIsGroupLeader(source.unit) or (target.unit and UnitIsGroupLeader(target.unit)) then
                                    return
                                end
                                -- 同小队交换：借用一个其他小队的玩家作为桥梁（同队交换的逻辑来自MRT插件）
                                local bridgeIdx = nil
                                for _, bt in ipairs(buttons) do
                                    if bt.unit and not UnitIsGroupLeader(bt.unit)
                                        and bt ~= source and bt ~= target then
                                        local bg = floor((bt.index - 1) / 5) + 1
                                        if bg ~= srcGroup then
                                            local bidx = tonumber(bt.unit:match("raid(%d+)"))
                                            if bidx then
                                                bridgeIdx = bidx
                                                break
                                            end
                                        end
                                    end
                                end
                                if bridgeIdx then
                                    SwapRaidSubgroup(srcIdx, bridgeIdx)
                                    SwapRaidSubgroup(bridgeIdx, tgtIdx)
                                    SwapRaidSubgroup(srcIdx, bridgeIdx)
                                    SwapButtonDisplay(source, target)
                                end
                            else
                                -- 不同小队，直接交换
                                SwapRaidSubgroup(srcIdx, tgtIdx)
                                SwapButtonDisplay(source, target)
                            end
                        end
                    else
                        -- 目标位置为空，将源玩家移动到目标小队
                        SetRaidSubgroup(srcIdx, tgtGroup)
                        if srcGroup ~= tgtGroup then
                            SwapButtonDisplay(source, buttons[GetGroupFirstIndex(tgtGroup)])
                        end
                    end
                end
            end
            MOVING_EQUIP_BUTTON = nil
            EQUIP_TARGET_INDEX = nil
        end

        function btMixin:OnEnter(button)
            local f = _G.BG and _G.BG.equipFrame
            if not (f and f:IsVisible()) and TuanJian.options.onEnterShowEquip == 1 then
                self:ShowEquipFrame()
            end
            if self.unit then
                self:SetBackdropColor(unpack(bg1))
            end
        end

        function btMixin:OnLeave(button)
            HideEquipFrame()
            GameTooltip:Hide()
            self:SetBackdropColor(0, 0, 0, 0)
        end

        function btMixin:ShowEquipFrame(click)
            local unit = self.unit
            local name = self.name
            if unit and self.class and self.iLevel and TuanJian.itemInfo[name] and _G.BG and _G.BG.ShowEquipFrame then
                local level = UnitLevel(unit) or 0
                local iLevel = self.iLevel or 0
                _G.BG.ShowEquipFrame(click, self, nil, nil, name,
                    SetClassCFF(name), level, self.class, iLevel, TuanJian.itemInfo[name],
                    TuanJian.talentInfo[name]
                -- ,{'TOPRIGHT',TJ.MainFrame,'TOPLEFT',0,-20}
                -- ,{ 'TOPLEFT', TJ.MainFrame, 'TOPRIGHT', 0, -20 }
                )
            end
        end
    end

    local function CreateRaidButton(i)
        local bt = CreateFrame("Button", nil, mainFrame, "BackdropTemplate")
        bt:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        bt:SetBackdropColor(0, 0, 0, 0)
        bt:SetBackdropBorderColor(1, 1, 1, .2)
        bt:SetSize(BT_W, BT_H)
        local sp, spf, srp, sx, sy = GetButtonPoint(i)
        bt:SetPoint(sp, spf, srp, sx, sy)
        if (i - 1) % 5 == 0 then
            -- 小队编号独立锚定，与按钮使用同一个父框架和坐标系统
            local text = mainFrame:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            text:SetPoint("BOTTOM", spf, srp, sx + BT_W / 2, sy + 2)
            text:SetText((i - 1) / 5 + 1)
            text:SetTextColor(.5, .5, .5)
        end
        bt.index = i
        TJ.SetMixin(bt, btMixin)
        bt:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        bt:RegisterForDrag("LeftButton")
        bt:SetScript("OnMouseDown", btMixin.OnMouseDown)
        bt:SetScript("OnDragStart", btMixin.OnDragStart)
        bt:SetScript("OnDragStop", btMixin.OnDragStop)
        bt:SetScript("OnClick", btMixin.OnClick)
        tinsert(buttons, bt)

        local tex = bt:CreateTexture(nil, "OVERLAY") -- 队长/助理
        tex:SetPoint("CENTER", bt, "TOPLEFT", 2, -2)
        tex:SetSize(12, 12)
        bt.icon = tex

        local tex = bt:CreateTexture(nil, "OVERLAY") -- 拾取
        tex:SetSize(12, 12)
        bt.master = tex

        local tex = bt:CreateTexture() -- 天赋
        tex:SetPoint("TOPLEFT", 2, -2)
        tex:SetPoint("BOTTOMRIGHT", bt, "BOTTOMLEFT", bt:GetHeight() - 2, 2)
        bt.talent = tex

        local text = bt:CreateFontString()
        text:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
        text:SetPoint("TOPLEFT", bt.talent, "TOPRIGHT", 2, 0)
        text:SetWidth(bt:GetWidth() - bt.talent:GetWidth() - 5)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(false)
        bt.nameText = text

        local text = bt:CreateFontString()
        text:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
        text:SetPoint("BOTTOMLEFT", bt.talent, "BOTTOMRIGHT", 2, 0)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(false)
        bt.infoText = text

        local text = bt:CreateFontString()
        text:SetFont(BIAOGE_TEXT_FONT, 12, "OUTLINE")
        text:SetPoint("LEFT", bt.infoText, "RIGHT", 2, 0)
        bt.enchantText = text

        return bt
    end
    for i = 1, 40 do
        CreateRaidButton(i)
    end

    -- 右键菜单
    do
        local menus = {
            "MENU_UNIT_SELF",
            "MENU_UNIT_TARGET",
            "MENU_UNIT_PLAYER",
            "MENU_UNIT_FRIEND",
            "MENU_UNIT_PARTY",
            "MENU_UNIT_RAID_PLAYER",
        }
        for _, menu in ipairs(menus) do
            Menu.ModifyMenu(menu, function(owner, description, contextData)
                local unit = contextData and contextData.unit or owner and owner.unit
                if not (unit and EQUIP_MENU_UNIT and unit == EQUIP_MENU_UNIT) then return end
                CreateAssignmentMenuButtons(description, unit)
            end)
        end
    end

    -- 其他按钮和文本
    local UpdateTipsText
    do
        UpdateTipsText = function()
            local combatTip = mainFrame.CombatTipsText
            After(.5, function()
                if not IsInRaid(1) then
                    combatTip:SetText(L["在团队中才能查看全团装等"])
                    combatTip:SetTextColor(1, 0, 0)
                    combatTip:Show()
                    return
                end
                if not (IsInRaid(1) and TJ.IsLeader()) then
                    combatTip:Hide()
                    return
                end
                combatTip:Show()
                if InCombatLockdown() then
                    combatTip:SetText(L["提示：战斗中无法拖动队伍"])
                    combatTip:SetTextColor(1, 0, 0)
                else
                    combatTip:SetText(L["提示：框架支持拖动调队"])
                    combatTip:SetTextColor(1, 1, 1)
                end
            end)
        end

        local bt = CreateFrame("CheckButton", nil, mainFrame, "ChatConfigCheckButtonTemplate")
        bt:SetSize(30, 30)
        bt:SetPoint("TOPLEFT", TJ.MainFrame, 20, -405)
        bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        bt.Text:SetText(L['鼠标悬停在玩家框架时显示装备详情'])
        bt:SetHitRectInsets(0, -80, 0, 0)
        bt:SetChecked(TuanJian.options.onEnterShowEquip == 1)
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            TuanJian.options.onEnterShowEquip = self:GetChecked() and 1 or 0
        end)

        -- 战斗状态提示（红色文本，位于按钮上方）
        local combatTip = mainFrame:CreateFontString()
        combatTip:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        combatTip:SetPoint("TOPRIGHT", TJ.MainFrame, -20, -410)
        mainFrame.CombatTipsText = combatTip
        UpdateTipsText()
    end

    function TJ.UpdateEquipFrame(name)
        if not mainFrame:IsVisible() then return end
        if name then
            for _, bt in ipairs(buttons) do
                if bt.name == name then
                    bt:SubUpdate()
                end
            end
        else
            for _, bt in ipairs(buttons) do
                bt:Reset()
            end
            if IsInRaid(1) then
                for i = 1, GetNumGroupMembers() do
                    local name, rank, subgroup, level, class2, class, zone, online, isDead, role, isML, combatRole =
                        GetRaidRosterInfo(i)
                    if name then
                        local team = subgroup
                        local num
                        for ii = (team - 1) * 5 + 1, team * 5 do
                            local bt = buttons[ii]
                            local text = bt.nameText:GetText()
                            if not text or text == "" then
                                num = ii
                                break
                            end
                        end
                        buttons[num]:FullUpdate(i, name, rank, class, role, combatRole, isML)
                    end
                end
            else
                buttons[1]:FullUpdate()
            end
        end
        UpdateTipsText()
        if TJ.UpdateRaidDamageBuffFrame then
            TJ.UpdateRaidDamageBuffFrame()
        end
    end

    -- 计算平均装等
    do
        local slots1 = { 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15 }
        local rangeIDs = { 2, 3, 18 } --2弓、3枪、18弩

        local function GetSlotInfo(v)
            local level = 0
            local equipLoc, subClassID, _
            if v then
                level = v.level or level
                if v.link then
                    equipLoc, _, _, subClassID = select(4, GetItemInfoInstant(v.link))
                end
            end
            return level, equipLoc, subClassID
        end
        local function Is2Weapon(equipLoc, subClassID)
            return (equipLoc == "INVTYPE_2HWEAPON") or
                (equipLoc == "INVTYPE_RANGEDRIGHT" or equipLoc == "INVTYPE_RANGED" and TJ.ValueInTable(rangeIDs, subClassID))
        end
        local function GetWeaponLevel(name)
            local mainLevel, mainEquipLoc, mainSubClassID = GetSlotInfo(TuanJian.itemInfo[name][16])
            local offLevel, offEquipLoc, offSubClassID = GetSlotInfo(TuanJian.itemInfo[name][17])
            local mainIs2Weapon = Is2Weapon(mainEquipLoc, mainSubClassID)
            local offIs2Weapon = Is2Weapon(offEquipLoc, offSubClassID)
            -- 主副手都是双手武器
            if mainIs2Weapon and offIs2Weapon then
                return max(mainLevel, offLevel) * 2
            end
            -- 主手是双手武器、副手是空的
            if mainIs2Weapon and not offIs2Weapon then
                if mainLevel >= offLevel then
                    return max(mainLevel, offLevel) * 2
                end
            end
            -- 主手是空的、副手是双手武器
            if offIs2Weapon and not mainIs2Weapon then
                if offLevel >= mainLevel then
                    return max(mainLevel, offLevel) * 2
                end
            end
            return mainLevel + offLevel
        end

        function TJ.GetPlayerItemsLevel(name)
            if TuanJian.itemInfo[name] then
                local sum = 0
                for _, slot in pairs(slots1) do
                    local level = GetSlotInfo(TuanJian.itemInfo[name][slot])
                    sum = sum + level
                end
                local wLevel = GetWeaponLevel(name)
                sum = sum + wLevel
                return Round(sum / 16, 3)
            end
        end
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("GROUP_ROSTER_UPDATE")
    f:RegisterEvent("PLAYER_ENTERING_WORLD")
    f:RegisterEvent("PLAYER_REGEN_DISABLED")
    f:RegisterEvent("PLAYER_REGEN_ENABLED")
    f:SetScript("OnEvent", function(self, event, ...)
        if event == "GROUP_ROSTER_UPDATE" then
            TJ.UpdateEquipFrame()
            After(.6, function()
                if TJ.UpdateRaidDamageBuffFrame then
                    TJ.UpdateRaidDamageBuffFrame()
                end
            end)
        elseif event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
            UpdateTipsText()
        elseif event == "PLAYER_ENTERING_WORLD" then
            self:UnregisterEvent("PLAYER_ENTERING_WORLD")
            After(4, function()
                TJ.UpdateEquipFrame()
            end)
        end
    end)

    -- 一键调队
    do
        local tank, healer, dps1, dps2
        local delay = 1

        local chooseInfo = {
            L["自动把坦克放1队，治疗5队，近战1/2队，远程3/4队。"],
            L["自动把坦克放1队，治疗2队，近战1/3队，远程4/5队。"],
            L["自动把坦克放1队，治疗2队，近战1/5队，远程3/4队。"],
            L["自动把坦克放1队，治疗3队，近战1/2队，远程4/5队。"],
            L["自动把坦克放1队，治疗4队，近战1/2队，远程3/5队。"],
        }
        TJ.autoSetTeamChooseInfo = chooseInfo

        local moveTeamPlans = {
            {
                clearHealerSource = { 5, 4 },
                clearHealerTarget = { 8, 7, 6 },
                clearHealerRoles = function() return { tank, dps1, dps2 } end,
                healer = { { 5 }, { 4, { 5 } } },
                clearDpsSource = { 2, 1, 3 },
                clearDpsTarget = { 8, 7, 6, 5, 4 },
                clearDpsRoles = function() return { healer, dps2 } end,
                dps1 = { { 2 }, { 1, { 2 } }, { 3, { 2, 1 } } },
                dps2 = { { 4 }, { 3, { 4 } }, { 5, { 4, 3 } }, { 2, { 5, 4, 3 } } },
            },
            {
                clearHealerSource = { 2, 1 },
                clearHealerTarget = { 8, 7, 6 },
                clearHealerRoles = function() return { dps1, dps2 } end,
                healer = { { 2 }, { 1, { 2 } } },
                clearDpsSource = { 3, 1, 2, 4 },
                clearDpsTarget = { 8, 7, 6, 5 },
                clearDpsRoles = function() return { dps2 } end,
                dps1 = { { 1 }, { 3, { 1 } }, { 2, { 3, 1 } }, { 4, { 3, 2, 1 } } },
                dps2 = { { 4 }, { 5, { 4 } }, { 3, { 4, 5 } }, { 2, { 3, 4, 5 } } },
            },
            {
                clearHealerSource = { 2, 1 },
                clearHealerTarget = { 8, 7, 6 },
                clearHealerRoles = function() return { dps1, dps2 } end,
                healer = { { 2 }, { 1, { 2 } } },
                clearDpsSource = { 3, 1, 2, 4 },
                clearDpsTarget = { 8, 7, 6, 5 },
                clearDpsRoles = function() return { dps2 } end,
                dps1 = { { 1 }, { 5, { 1 } }, { 2, { 5, 1 } }, { 3, { 5, 2, 1 } } },
                dps2 = { { 3 }, { 4, { 3 } }, { 5, { 4, 3 } }, { 2, { 3, 4, 5 } } },
            },
            {
                clearHealerSource = { 3, 1 },
                clearHealerTarget = { 8, 7, 6 },
                clearHealerRoles = function() return { dps1, dps2 } end,
                healer = { { 3 }, { 1, { 3 } } },
                clearDpsSource = { 1, 2, 4 },
                clearDpsTarget = { 8, 7, 6, 5 },
                clearDpsRoles = function() return { dps2 } end,
                dps1 = { { 2 }, { 1, { 2 } }, { 4, { 2, 1 } } },
                dps2 = { { 4 }, { 5, { 4 } }, { 3, { 4, 5 } }, { 2, { 3, 4, 5 } } },
            },
            {
                clearHealerSource = { 4, 5 },
                clearHealerTarget = { 8, 7, 6 },
                clearHealerRoles = function() return { dps1, dps2 } end,
                healer = { { 4 }, { 5, { 4 } } },
                clearDpsSource = { 1, 2, 3 },
                clearDpsTarget = { 8, 7, 6, 5 },
                clearDpsRoles = function() return { dps2 } end,
                dps1 = { { 2 }, { 1, { 2 } }, { 3, { 2, 1 } } },
                dps2 = { { 3 }, { 5, { 3 } }, { 2, { 3, 5 } }, { 4, { 2, 3, 5 } } },
            },
        }

        local function CanMove()
            if TJ.IsLeader() and not InCombatLockdown() then
                return true
            elseif TJ.autoButton then
                TJ.autoButton:SetEnabled(true)
            end
        end

        local function GetSupgroupEmpty()
            local emptyTbl = {}
            for i = 1, 8 do
                emptyTbl[i] = 5
            end
            for id = 1, GetNumGroupMembers() do
                local _, _, subgroup = GetRaidRosterInfo(id)
                if subgroup then
                    emptyTbl[subgroup] = emptyTbl[subgroup] - 1
                end
            end
            return emptyTbl
        end

        local function GetAllRole()
            local tank, healer, dps1, dps2 = {}, {}, {}, {}
            for i = 1, GetNumGroupMembers() do
                local name, _, _, _, _, fileName, _, _, _, role, _, combatRole = GetRaidRosterInfo(i)
                if name then
                    local v = {
                        name = name,
                        class = fileName,
                        role = role,
                        combatRole = combatRole,
                    }
                    if TJ.Istank(v) then
                        tank[name] = true
                    elseif TJ.Ishealer(v) then
                        healer[name] = true
                    elseif TJ.Isdps2(v) then
                        dps2[name] = true
                    elseif TJ.Isdps1(v) then
                        dps1[name] = true
                    end
                end
            end
            return tank, healer, dps1, dps2
        end

        local function MoveTeamTo(tbl, targetTeam)
            if not CanMove() then return end
            local emptypTeams = {}
            local emptyTbl = GetSupgroupEmpty()
            for _, teamIndex in ipairs(targetTeam) do
                for _ = 1, emptyTbl[teamIndex] do
                    tinsert(emptypTeams, teamIndex)
                end
            end
            for i, id in ipairs(tbl) do
                if emptypTeams[i] then
                    SetRaidSubgroup(id, emptypTeams[i])
                end
            end
        end

        local function MoveRoleToTeam(role, targetTeam, notTeams, callback)
            if not CanMove() then return end
            local oldNotTeams = notTeams
            notTeams = {}
            if oldNotTeams then
                for _, teamIndex in ipairs(oldNotTeams) do
                    tinsert(notTeams, teamIndex)
                end
            end
            tinsert(notTeams, targetTeam)
            local tbl = {}
            for id = 1, GetNumGroupMembers() do
                local name, _, subgroup = GetRaidRosterInfo(id)
                if name and role[name] and not TJ.ValueInTable(notTeams, subgroup) then
                    tinsert(tbl, id)
                end
            end
            if next(tbl) then
                local emptyTbl = GetSupgroupEmpty()
                if emptyTbl[targetTeam] > 0 then
                    for i = 1, emptyTbl[targetTeam] do
                        local id = tbl[i]
                        if id then
                            SetRaidSubgroup(id, targetTeam)
                        end
                    end
                    if callback then
                        After(delay, callback)
                    end
                    return true
                end
            end
            if callback then
                callback()
            end
        end

        local function IsRole(roles, name)
            for _, role in pairs(roles) do
                if role[name] then
                    return true
                end
            end
        end

        local function ClearRoleToTeam(sourceTeam, targetTeam, roles, callback)
            if not CanMove() then return end
            local tbl = {}
            for _, teamIndex in ipairs(sourceTeam) do
                for id = 1, GetNumGroupMembers() do
                    local name, _, subgroup = GetRaidRosterInfo(id)
                    if name and (subgroup == teamIndex) and IsRole(roles, name) then
                        tinsert(tbl, id)
                    end
                end
            end
            if next(tbl) then
                MoveTeamTo(tbl, targetTeam)
                After(delay, callback)
            else
                callback()
            end
        end

        local function Finish()
            SendSystemMessage(L["队伍调整已完成。"])
            if TJ.autoButton then
                TJ.autoButton:SetEnabled(true)
            end
            PlaySoundFile("Interface\\AddOns\\TuanJian\\Media\\sound\\other\\done.mp3", "Master")
        end

        local function GetTeamRosterIDs(teamIndex)
            local tbl = {}
            for id = 1, GetNumGroupMembers() do
                local _, _, subgroup = GetRaidRosterInfo(id)
                if subgroup == teamIndex then
                    tinsert(tbl, id)
                end
            end
            return tbl
        end

        local function IsTankRosterID(id)
            local name = GetRaidRosterInfo(id)
            return name and tank[name]
        end

        local function FindSameTeamSwapBridge(sourceID, targetID, teamIndex)
            for id = 1, GetNumGroupMembers() do
                if id ~= sourceID and id ~= targetID and not UnitIsGroupLeader("raid" .. id) then
                    local _, _, subgroup = GetRaidRosterInfo(id)
                    if subgroup and subgroup ~= teamIndex then
                        return id
                    end
                end
            end
        end

        local function SwapSameTeam(sourceID, targetID, teamIndex)
            if UnitIsGroupLeader("raid" .. sourceID) or UnitIsGroupLeader("raid" .. targetID) then
                return
            end
            local bridgeID = FindSameTeamSwapBridge(sourceID, targetID, teamIndex)
            if bridgeID then
                SwapRaidSubgroup(sourceID, bridgeID)
                SwapRaidSubgroup(bridgeID, targetID)
                SwapRaidSubgroup(sourceID, bridgeID)
                return true
            end
        end

        local function MoveTankToFront(callback)
            local targetIndex = 1
            local function Next()
                if not CanMove() then return end
                local teamIDs = GetTeamRosterIDs(1)
                local targetID = teamIDs[targetIndex]
                if not targetID then
                    callback()
                    return
                end
                if IsTankRosterID(targetID) then
                    targetIndex = targetIndex + 1
                    Next()
                    return
                end
                local tankID
                for i = targetIndex + 1, #teamIDs do
                    if IsTankRosterID(teamIDs[i]) and not UnitIsGroupLeader("raid" .. teamIDs[i]) then
                        tankID = teamIDs[i]
                        break
                    end
                end
                if tankID and SwapSameTeam(tankID, targetID, 1) then
                    After(delay, Next)
                else
                    targetIndex = targetIndex + 1
                    Next()
                end
            end
            Next()
        end

        local function RunMoveList(role, moves, callback)
            local index = 1
            local function RunNext()
                local move = moves[index]
                index = index + 1
                if move then
                    MoveRoleToTeam(role, move[1], move[2], RunNext)
                elseif callback then
                    callback()
                end
            end
            RunNext()
        end

        function TJ.StartMoveTeam()
            if not IsInRaid(1) or GetNumGroupMembers() > 30 or not CanMove() then
                if TJ.autoButton then
                    TJ.autoButton:SetEnabled(true)
                end
                return
            end

            local plan = moveTeamPlans[TuanJian.options.autoSetTeam or 1] or moveTeamPlans[1]
            tank, healer, dps1, dps2 = GetAllRole()

            local function MoveDps2()
                RunMoveList(dps2, plan.dps2, function()
                    MoveTankToFront(Finish)
                end)
            end
            local function MoveDps1()
                RunMoveList(dps1, plan.dps1, MoveDps2)
            end
            local function ClearNotDps1()
                ClearRoleToTeam(plan.clearDpsSource, plan.clearDpsTarget, plan.clearDpsRoles(), MoveDps1)
            end
            local function MoveHealer()
                RunMoveList(healer, plan.healer, ClearNotDps1)
            end
            local function ClearNotHealer()
                ClearRoleToTeam(plan.clearHealerSource, plan.clearHealerTarget, plan.clearHealerRoles(), MoveHealer)
            end
            local function MoveTank()
                MoveRoleToTeam(tank, 1, { 1 }, ClearNotHealer)
            end
            local function ClearNotTank()
                ClearRoleToTeam({ 1 }, { 8 }, { healer, dps1, dps2 }, MoveTank)
            end
            local function Clear78()
                local tbl = {}
                for id = 1, GetNumGroupMembers() do
                    local _, _, subgroup = GetRaidRosterInfo(id)
                    if subgroup == 7 or subgroup == 8 then
                        tinsert(tbl, id)
                    end
                end
                if next(tbl) then
                    MoveTeamTo(tbl, { 1, 2, 3, 4, 5, 6 })
                    After(delay, ClearNotTank)
                else
                    ClearNotTank()
                end
            end

            Clear78()
        end

        if TJ.autoButton and not TJ.autoSetTeamOptionButton then
            local dropDown = LibBG:Create_UIDropDownMenu(nil, TJ.MainFrame)
            local option = TJ.CreateButton(TJ.equipMainFrame)
            option:SetPoint("LEFT", TJ.autoButton, "RIGHT", 0, 0)
            option:SetSize(23, TJ.autoButton:GetHeight())
            option:SetText('▼')
            TJ.autoSetTeamOptionButton = option
            LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "BOTTOMLEFT", option, "TOPLEFT")
            option:SetScript("OnClick", function(self)
                TJ.PlaySound(1)
                if L_DropDownList1:IsVisible() and L_DropDownList1.dropdown == dropDown then
                    L_DropDownList1:Hide()
                else
                    local menu = {
                        {
                            text = L["调队方案"],
                            isTitle = true,
                            notCheckable = true,
                        },
                    }
                    for i, text in ipairs(chooseInfo) do
                        tinsert(menu, {
                            text = text,
                            checked = (TuanJian.options.autoSetTeam or 1) == i,
                            func = function()
                                TuanJian.options.autoSetTeam = i
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
    end

    -- 团队增伤覆盖
    if TJ.IsWLK then
        local YES = 1
        local MAYBE = 2

        local function TalentIn(talent, talents)
            if not talent then return end
            for _, v in ipairs(talents) do
                if talent == v then
                    return true
                end
            end
        end

        local function IsMelee(v)
            return TJ.Isdps1(v)
        end

        local function IsCaster(v)
            return TJ.Isdps2(v)
        end

        local function IsFeral(v)
            return TJ.Isdps1(v) or TJ.Istank(v)
        end

        local function IsDeathKnightRole(v)
            return TJ.Isdps1(v) or TJ.Istank(v)
        end

        local function Provider(class, talents, fallback, possible, talentSpellIDs)
            return {
                class = class,
                talents = talents,
                fallback = fallback,
                possible = possible,
                talentSpellIDs = talentSpellIDs,
            }
        end

        local function GetTalentName(spellID)
            local name
            if C_Spell and C_Spell.GetSpellName then
                name = C_Spell.GetSpellName(spellID)
            end
            if not name and GetSpellInfo then
                name = GetSpellInfo(spellID)
            end
            return name
        end

        local function MatchSavedTalent(v, provider)
            if not provider.talentSpellIDs then return end
            local treeInfo = TuanJian.talentTreeInfo and TuanJian.talentTreeInfo[v.name]
            if not treeInfo or treeInfo.class ~= v.class or not treeInfo.talents then return end
            if v.guid and treeInfo.guid ~= v.guid then return end

            for _, spellID in ipairs(provider.talentSpellIDs) do
                local talentName = GetTalentName(spellID)
                local talentInfo = talentName and treeInfo.talents[talentName]
                if talentInfo and talentInfo.maxRank > 0 and talentInfo.rank >= talentInfo.maxRank then
                    return true, true
                end
            end
            return true, false
        end

        local function MatchProvider(v, provider)
            if v.class ~= provider.class then return end
            if not provider.talents then
                return YES
            end

            local inspected, hasTalent = MatchSavedTalent(v, provider)
            if inspected then
                return hasTalent and YES or nil
            end

            local talent = TuanJian.talentInfo[v.name]
            if talent then
                return TalentIn(talent, provider.talents) and YES or nil
            end
            if provider.fallback and provider.fallback(v) then
                return YES
            end
            if provider.possible and provider.possible(v) then
                return MAYBE
            end
        end

        local abominationsMightDeathKnight = Provider("DEATHKNIGHT", { 1, 4 }, TJ.Istank, IsDeathKnightRole,
            { 53138 })
        local trueshotAuraHunter = Provider("HUNTER", { 2 }, nil, IsCaster, { 19506 })
        local unleashedRageShaman = Provider("SHAMAN", { 2 }, IsMelee, nil, { 30809 })
        local improvedIcyTalonsDeathKnight = Provider("DEATHKNIGHT", { 2 }, nil, IsDeathKnightRole, { 55610 })
        local improvedWindfuryShaman = Provider("SHAMAN", { 2 }, IsMelee, nil, { 29193 })
        local rampageWarrior = Provider("WARRIOR", { 2 }, nil, IsMelee, { 29801 })
        local leaderOfThePackDruid = Provider("DRUID", { 2 }, IsFeral, nil, { 17007 })
        local bloodFrenzyWarrior = Provider("WARRIOR", { 1 }, nil, IsMelee, { 29859 })
        local savageCombatRogue = Provider("ROGUE", { 2 }, nil, IsMelee, { 58413 })
        local traumaWarrior = Provider("WARRIOR", { 1 }, nil, IsMelee, { 46855 })
        local mangleDruid = Provider("DRUID", { 2 }, IsFeral, nil, { 33917 })

        local demonicPactWarlock = Provider("WARLOCK", { 2 }, nil, IsCaster, { 47240 })
        local totemOfWrathShaman = Provider("SHAMAN", { 1 }, IsCaster, nil, { 30706 })
        local moonkinFormDruid = Provider("DRUID", { 1 }, IsCaster, nil, { 24858 })
        local elementalOathShaman = Provider("SHAMAN", { 1 }, IsCaster, nil, { 51470 })
        local improvedFaerieFireDruid = Provider("DRUID", { 1 }, IsCaster, nil, { 33602 })
        local miseryPriest = Provider("PRIEST", { 3 }, IsCaster, nil, { 33193 })
        local earthAndMoonDruid = Provider("DRUID", { 1 }, IsCaster, nil, { 48511 })
        local ebonPlagueDeathKnight = Provider("DEATHKNIGHT", { 3 }, nil, IsDeathKnightRole, { 51161 })
        local cryptFeverDeathKnight = Provider("DEATHKNIGHT", { 3 }, nil, IsDeathKnightRole, { 49632 })
        local spellCritMage = Provider("MAGE", { 1, 2, 3 }, IsCaster, nil, { 12873, 28593 })
        local improvedShadowBoltWarlock = Provider("WARLOCK", { 1, 2, 3 }, IsCaster, nil, { 17803 })

        local sanctifiedRetributionPaladin = Provider("PALADIN", { 3, 4 }, IsMelee, nil, { 31869 })
        local ferociousInspirationHunter = Provider("HUNTER", { 1 }, nil, IsCaster, { 34460 })
        local arcaneEmpowermentMage = Provider("MAGE", { 1 }, nil, IsCaster, { 31583 })
        local swiftRetributionPaladin = Provider("PALADIN", { 3, 4 }, IsMelee, nil, { 53379 })
        local improvedMoonkinFormDruid = Provider("DRUID", { 1 }, IsCaster, nil, { 48396 })
        local heartOfTheCrusaderPaladin = Provider("PALADIN", { 3, 4 }, IsMelee, nil, { 20337 })
        local masterPoisonerRogue = Provider("ROGUE", { 1 }, nil, IsMelee, { 58410 })

        local anyDeathKnight = Provider("DEATHKNIGHT")
        local anyRogue = Provider("ROGUE")
        local anyShaman = Provider("SHAMAN")
        local anyWarlock = Provider("WARLOCK")
        local anyWarrior = Provider("WARRIOR")

        local function ClassSource(class, text)
            local color = select(4, GetClassColor(class)) or "ffffffff"
            return "|c" .. color .. text .. "|r"
        end

        local function JoinSources(...)
            return table.concat({ ... }, "/")
        end

        local function ClearSourceColor(text)
            return text:gsub("|c%x%x%x%x%x%x%x%x", ""):gsub("|r", "")
        end

        local buffGroups = {
            {
                title = L["物理"],
                color = { 1, .55, .2 },
                x = 5,
                headerY = -35,
                entries = {
                    {
                        spellID = 53138,
                        text = L["10%攻强"],
                        source = JoinSources(ClassSource("DEATHKNIGHT", L["血DK"]), ClassSource("SHAMAN", L["增强萨"]), ClassSource("HUNTER", L["射击猎"])),
                        providers = { abominationsMightDeathKnight, unleashedRageShaman, trueshotAuraHunter, },
                    },
                    {
                        spellID = 55610,
                        text = L["20%近战急速"],
                        source = JoinSources(ClassSource("DEATHKNIGHT", L["冰DK"]), ClassSource("SHAMAN", L["增强萨"])),
                        providers = { improvedIcyTalonsDeathKnight, improvedWindfuryShaman },
                    },
                    {
                        spellID = 47467,
                        text = L["20%破甲"],
                        source = JoinSources(ClassSource("WARRIOR", L["战士"]), ClassSource("ROGUE", L["盗贼"])),
                        providers = { anyWarrior, anyRogue },
                    },
                    {
                        spellID = 57623,
                        text = L["力量敏捷"],
                        source = JoinSources(ClassSource("DEATHKNIGHT", L["死亡骑士"]), ClassSource("SHAMAN", L["萨满"])),
                        providers = { anyDeathKnight, anyShaman },
                    },
                    {
                        spellID = 29801,
                        text = L["5%物理暴击"],
                        source = JoinSources(ClassSource("WARRIOR", L["狂暴战"]), ClassSource("DRUID", L["野德"])),
                        providers = { rampageWarrior, leaderOfThePackDruid },
                    },
                    {
                        spellID = 29859,
                        text = L["4%物理易伤"],
                        source = JoinSources(ClassSource("WARRIOR", L["武器战"]), ClassSource("ROGUE", L["战斗贼"])),
                        providers = { bloodFrenzyWarrior, savageCombatRogue },
                    },
                    {
                        spellID = 46856,
                        text = L["30%流血易伤"],
                        source = JoinSources(ClassSource("WARRIOR", L["武器战"]), ClassSource("DRUID", L["野德"])),
                        providers = { traumaWarrior, mangleDruid },
                    },

                },
            },
            {
                title = L["法系"],
                color = { .35, .7, 1 },
                x = 152,
                headerY = -35,
                entries = {
                    {
                        spellID = 47240,
                        text = L["法强"],
                        source = JoinSources(ClassSource("WARLOCK", L["恶魔术"]), ClassSource("SHAMAN", L["元素萨"])),
                        providers = { demonicPactWarlock, totemOfWrathShaman },
                    },
                    {
                        spellID = 24907,
                        text = L["5%法术暴击"],
                        source = JoinSources(ClassSource("DRUID", L["鸟德"]), ClassSource("SHAMAN", L["元素萨"])),
                        providers = { moonkinFormDruid, elementalOathShaman },
                    },
                    {
                        spellID = 3738,
                        text = L["5%法术急速"],
                        source = ClassSource("SHAMAN", L["萨满"]),
                        providers = { anyShaman },
                    },
                    {
                        spellID = 33198,
                        text = L["3%法术命中"],
                        source = JoinSources(ClassSource("DRUID", L["鸟德"]), ClassSource("PRIEST", L["暗牧"])),
                        providers = { improvedFaerieFireDruid, miseryPriest },
                    },
                    {
                        spellID = 22959,
                        text = L["5%法术易暴"],
                        source = JoinSources(ClassSource("MAGE", L["法师"]), ClassSource("WARLOCK", L["术士"])),
                        providers = { spellCritMage, improvedShadowBoltWarlock },
                    },
                    {
                        spellID = 60433,
                        text = L["13%法术易伤"],
                        source = JoinSources(ClassSource("DRUID", L["鸟德"]), ClassSource("DEATHKNIGHT", L["邪DK"]),
                            ClassSource("WARLOCK", L["术士"])),
                        providers = { earthAndMoonDruid, ebonPlagueDeathKnight, anyWarlock },
                    },
                    {
                        spellID = 49632,
                        text = L["30%疾病易伤"],
                        source = ClassSource("DEATHKNIGHT", L["邪DK"]),
                        providers = { cryptFeverDeathKnight },
                    },
                },
            },
            {
                title = L["全系"],
                color = { .45, 1, .45 },
                x = 5,
                headerY = -295,
                entries = {
                    {
                        spellID = 31869,
                        text = L["3%伤害"],
                        source = JoinSources(ClassSource("PALADIN", L["惩戒骑"]), ClassSource("HUNTER", L["兽王猎"]),
                            ClassSource("MAGE", L["奥法"])),
                        providers = { sanctifiedRetributionPaladin, ferociousInspirationHunter,
                            arcaneEmpowermentMage, },
                    },
                    {
                        spellID = 53379,
                        text = L["3%急速"],
                        source = JoinSources(ClassSource("PALADIN", L["惩戒骑"]), ClassSource("DRUID", L["鸟德"])),
                        providers = { swiftRetributionPaladin, improvedMoonkinFormDruid, },
                    },
                    {
                        spellID = 20337,
                        text = L["3%易暴"],
                        source = JoinSources(ClassSource("PALADIN", L["惩戒骑"]), ClassSource("SHAMAN", L["元素萨"]),
                            ClassSource("ROGUE", L["刺杀贼"])),
                        providers = { heartOfTheCrusaderPaladin, totemOfWrathShaman, masterPoisonerRogue, },
                    },
                },
            },
        }

        local function GetSpellIcon(spellID)
            if C_Spell and C_Spell.GetSpellTexture then
                return C_Spell.GetSpellTexture(spellID)
            elseif GetSpellTexture then
                return GetSpellTexture(spellID)
            end
        end

        local function AddMember(tbl, cache, v)
            if cache[v.name] then return end
            cache[v.name] = true
            tinsert(tbl, v)
        end

        local function Evaluate(entry)
            local confirmed, possible = {}, {}
            local confirmedCache, possibleCache = {}, {}
            for _, v in ipairs(TJ.raidRosterInfo) do
                for _, provider in ipairs(entry.providers) do
                    local result = MatchProvider(v, provider)
                    if result == YES then
                        AddMember(confirmed, confirmedCache, v)
                        break
                    elseif result == MAYBE then
                        AddMember(possible, possibleCache, v)
                    end
                end
            end
            if next(confirmed) then
                return YES, confirmed, possible
            elseif next(possible) then
                return MAYBE, confirmed, possible
            end
            return nil, confirmed, possible
        end

        local function FormatMember(v)
            local color = v.class and select(4, GetClassColor(v.class)) or "ffffffff"
            return "|c" .. color .. v.name .. "|r"
        end

        local function JoinMembers(tbl)
            local texts = {}
            for _, v in ipairs(tbl) do
                tinsert(texts, FormatMember(v))
            end
            return table.concat(texts, L["、"])
        end

        -- 主界面
        local frame = TJ.CreateMainFrame(nil, L["团队增伤覆盖"])
        do
            frame:SetParent(mainFrame)
            frame.CloseButton:Hide()
            frame:ClearAllPoints()
            frame:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT", 1, 0)
            frame:SetPoint("BOTTOMLEFT", TJ.MainFrame, "BOTTOMRIGHT", 1, 0)
            frame:SetWidth(300)
            local r, g, b = ns.GetClassRGB(nil, "player")
            frame:SetBackdropBorderColor(r, g, b, TJ.borderAlpha)
            frame:EnableMouse(true)
            frame:SetMovable(true)
            frame:SetScript("OnMouseUp", function()
                TJ.MainFrame:StopMovingOrSizing()
            end)
            frame:SetScript("OnMouseDown", function()
                TJ.MainFrame:StartMoving()
            end)
            frame.rows = {}
        end

        local function CreateRow(entry, index, x, headerY)
            local row = CreateFrame("Button", nil, frame, "BackdropTemplate")
            row:SetPoint("TOPLEFT", x, headerY - 21 - (index - 1) * 32)
            row:SetSize(143, 30)
            row:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeFile = "Interface/ChatFrame/ChatFrameBackground",
                edgeSize = 1,
            })
            row:SetBackdropColor(.05, .05, .05, .65)
            row:SetBackdropBorderColor(.25, .25, .25, .8)
            row:RegisterForDrag("LeftButton")
            row:SetScript("OnDragStart", function()
                TJ.MainFrame:StartMoving()
            end)
            row:SetScript("OnDragStop", function()
                TJ.MainFrame:StopMovingOrSizing()
            end)
            row.entry = entry

            local icon = row:CreateTexture(nil, "ARTWORK")
            icon:SetPoint("LEFT", 4, 0)
            icon:SetSize(26, 26)
            icon:SetTexture(GetSpellIcon(entry.spellID) or 134400)
            icon:SetTexCoord(unpack(TJ.iconTexCoord))
            row.icon = icon

            local nameText = row:CreateFontString(nil, "OVERLAY")
            nameText:SetPoint("TOPLEFT", icon, "TOPRIGHT", 4, 0)
            nameText:SetSize(88, 14)
            nameText:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            nameText:SetJustifyH("LEFT")
            nameText:SetWordWrap(false)
            nameText:SetText(entry.text)
            row.nameText = nameText

            local stateText = row:CreateFontString(nil, "OVERLAY")
            stateText:SetPoint("TOPRIGHT", -5, -3)
            stateText:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            row.stateText = stateText

            local sourceText = row:CreateFontString(nil, "OVERLAY")
            sourceText:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 4, 0)
            sourceText:SetSize(109, 11)
            sourceText:SetFont(BIAOGE_TEXT_FONT, 11, "OUTLINE")
            sourceText:SetJustifyH("LEFT")
            sourceText:SetWordWrap(false)
            row.sourceText = sourceText

            row:SetScript("OnEnter", function(self)
                if self.hasBuff then
                    self:SetBackdropColor(0, .6, .08, .9)
                else
                    self:SetBackdropColor(.18, .18, .18, .85)
                end
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                GameTooltip:AddLine(self.entry.text, 1, 1,1)
                GameTooltip:AddLine(L["来源："] .. self.entry.source, 1, 1, 1)
                if next(self.confirmed or {}) then
                    GameTooltip:AddLine(L["当前拥有："] .. JoinMembers(self.confirmed), 0, 1, 0)
                end
                if next(self.possible or {}) then
                    GameTooltip:AddLine(L["待确认："] .. JoinMembers(self.possible), 1, .82, 0)
                end
                if not next(self.confirmed or {}) and not next(self.possible or {}) then
                    GameTooltip:AddLine(L["当前团队缺失该效果"], 1, .2, .2)
                end
                GameTooltip:Show()
            end)
            row:SetScript("OnLeave", function(self)
                if self.hasBuff then
                    self:SetBackdropColor(0, .5, .05, .8)
                else
                    self:SetBackdropColor(.05, .05, .05, .65)
                end
                GameTooltip:Hide()
            end)

            tinsert(frame.rows, row)
        end

        for _, group in ipairs(buffGroups) do
            local header = frame:CreateFontString(nil, "OVERLAY")
            header:SetPoint("TOPLEFT", group.x, group.headerY)
            header:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
            header:SetText(group.title)
            header:SetTextColor(unpack(group.color))
            for index, entry in ipairs(group.entries) do
                CreateRow(entry, index, group.x, group.headerY)
            end
        end

        function TJ.UpdateRaidDamageBuffFrame()
            if not mainFrame:IsVisible() then return end
            for _, row in ipairs(frame.rows) do
                local state, confirmed, possible = Evaluate(row.entry)
                row.confirmed = confirmed
                row.possible = possible
                row.hasBuff = state == YES
                if state == YES then
                    row:SetBackdropColor(0, .5, .05, .8)
                    row.stateText:SetText("√")
                    row.stateText:SetTextColor(0, 1, 0)
                    row.nameText:SetTextColor(.75, 1, .75)
                    row.icon:SetDesaturated(false)
                    row.sourceText:SetText(JoinMembers(confirmed))
                    row.sourceText:SetTextColor(.65, .9, .65)
                elseif state == MAYBE then
                    row:SetBackdropColor(.05, .05, .05, .65)
                    row.stateText:SetText("?")
                    row.stateText:SetTextColor(1, .8, 0)
                    row.nameText:SetTextColor(1, .85, .35)
                    row.icon:SetDesaturated(true)
                    row.sourceText:SetText(L["待确认："] .. JoinMembers(possible))
                    row.sourceText:SetTextColor(1, .75, .2)
                else
                    row:SetBackdropColor(.05, .05, .05, .65)
                    row.stateText:SetText("×")
                    row.stateText:SetTextColor(1, .15, .15)
                    row.nameText:SetTextColor(1, .45, .45)
                    row.icon:SetDesaturated(true)
                    row.sourceText:SetText(L["缺："] .. ClearSourceColor(row.entry.source))
                    row.sourceText:SetTextColor(.75, .55, .55)
                end
            end
        end
    end
end)
