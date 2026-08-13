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
local Round = ns.Round

local realmID = GetRealmID()
local player = UnitName("player")
local GetAddOnMetadata = GetAddOnMetadata or C_AddOns.GetAddOnMetadata
local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

local logo = "TuanJian: "

local O = {}
ns.O = O
local optionFrame

-- 多选按钮
do
    local function OnClick(self)
        if self:GetChecked() then
            TuanJian.options[self.name] = 1
        else
            TuanJian.options[self.name] = 0
        end
        if self.child then
            for _, f in pairs(self.child) do
                f:SetShown(self:GetChecked())
            end
        end
        TJ.PlaySound(1)
    end
    local function OnEnter(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
        GameTooltip:ClearLines()
        if type(self.ontext) == "table" then
            for i, text in ipairs(self.ontext) do
                if i == 1 then
                    GameTooltip:AddLine(text, 1, 1, 1, true)
                else
                    GameTooltip:AddLine(text, 1, 0.82, 0, true)
                end
                GameTooltip:Show()
            end
        else
            GameTooltip:SetText(self.ontext)
        end
    end
    function O.CreateCheckButton(name, text, parent, x, y, ontext)
        local bt = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
        bt:SetSize(30, 30)
        bt:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        bt.Text:SetText(text)
        bt:SetHitRectInsets(0, -bt.Text:GetWidth(), 0, 0)
        bt.name = name
        bt.ontext = ontext
        TJ.options["button" .. name] = bt
        if TuanJian.options[name] == 1 then
            bt:SetChecked(true)
        else
            bt:SetChecked(false)
        end
        bt:SetScript("OnClick", OnClick)
        bt:SetScript("OnEnter", OnEnter)
        bt:SetScript("OnLeave", GameTooltip_Hide)
        return bt
    end
end

-- 滑块
do
    local function OnValueChanged(self, value)
        value = Round(tonumber(value), 2)
        TuanJian.options[self.name] = value
        self.Text:SetText(value)
        local minValue, maxValue = self:GetMinMaxValues()
        if value == minValue then
            self.leftButton:Disable()
        else
            self.leftButton:Enable()
        end
        if value == maxValue then
            self.rightButton:Disable()
        else
            self.rightButton:Enable()
        end
    end
    local function Button_OnClick(self)
        local slider = self:GetParent()
        local value = slider:GetValue()
        if self.type == "left" then
            slider:SetValue(value - slider.step)
        else
            slider:SetValue(value + slider.step)
        end
        TJ.PlaySound(1)
    end
    function O.CreateSlider(name, text, parent, minValue, maxValue, step, x, y, ontext, width, isSmall)
        local f = CreateFrame("Frame", nil, parent)
        f:SetSize(30, 30)
        f:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", x, y)
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("CENTER")
        t:SetTextColor(1, 1, 1)
        t:SetText(text)
        f:SetWidth(t:GetStringWidth())
        f:SetScript("OnEnter", function(self)
            if ontext then
                GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
                GameTooltip:ClearLines()
                for i, text in ipairs(ontext) do
                    if i == 1 then
                        GameTooltip:AddLine(text, 1, 1, 1, true)
                    else
                        GameTooltip:AddLine(text, 1, 0.82, 0, true)
                    end
                end
                GameTooltip:Show()
            end
        end)
        f:SetScript("OnLeave", GameTooltip_Hide)
        f:SetScript("OnMouseDown", function(self, button)
            if button == "RightButton" and TJ.options[name .. "reset"] then
                self.slider:SetValue(TJ.options[name .. "reset"])
            end
        end)

        local slider = CreateFrame("Slider", nil, f, "MinimalSliderTemplate")
        slider:SetPoint("LEFT", f, "RIGHT", isSmall and 20 or 30, 0)
        slider:SetWidth(width or 150)
        slider:SetMinMaxValues(minValue, maxValue)
        slider:SetValueStep(step)
        slider:SetObeyStepOnDrag(true)
        slider:SetHitRectInsets(0, 0, 0, 0)
        slider:SetValue(TuanJian.options[name])
        slider.name = name
        slider.step = step
        f.slider = slider
        slider:SetScript("OnValueChanged", OnValueChanged)
        TJ.options["button" .. name] = slider

        local bt = CreateFrame("Button", nil, slider)
        bt:SetSize(13, 19)
        bt:SetPoint("RIGHT", slider, "LEFT", -4, 0)
        bt:RegisterForClicks("AnyUp")
        bt.type = "left"
        bt:SetNormalAtlas("Minimal_SliderBar_Button_Left")
        slider.leftButton = bt
        bt:SetScript("OnClick", Button_OnClick)

        local bt = CreateFrame("Button", nil, slider)
        bt:SetSize(13, 19)
        bt:SetPoint("LEFT", slider, "RIGHT", 4, 0)
        bt:RegisterForClicks("AnyUp")
        bt.type = "right"
        bt:SetNormalAtlas("Minimal_SliderBar_Button_Right")
        slider.rightButton = bt
        bt:SetScript("OnClick", Button_OnClick)

        local t = slider:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("LEFT", slider, "RIGHT", isSmall and 20 or 30, 0)
        t:SetTextColor(1, .82, 0)
        t:SetText(TuanJian.options[name])
        slider.Text = t

        return slider, f
    end
end

-- 快捷键
do
    function O.CreateBindKey(parent, x, y, wdith, bindKey, name)
        local bt = TJ.CreateButton(parent)
        bt:SetSize(wdith or 150, 25)
        bt.bindKey = bindKey
        bt:SetScript("OnClick", function(self)
            local category
            for i, v in pairs(SettingsPanel:GetAllCategories()) do
                if v.name == SETTINGS_KEYBINDINGS_LABEL then
                    category = v
                    break
                end
            end
            if category then
                ShowUIPanel(SettingsPanel)
                SettingsPanel:SelectCategory(category)
                SettingsPanel.Container.SettingsList.ScrollBox:ScrollToEnd()
                for _, f in pairs({ SettingsPanel.Container.SettingsList.ScrollBox.ScrollTarget:GetChildren() }) do
                    if f.Button and f.Button.Text and f.Button.Text:GetText() == AddonName then
                        local initializer = f:GetElementData()
                        local data = initializer.data
                        data.expanded = nil;
                        f.Button:Click()
                    end
                end
                After(0, function()
                    SettingsPanel.Container.SettingsList.ScrollBox:ScrollToEnd()
                end)
            end
        end)
        bt:SetScript("OnShow", function(self)
            local key1, key2 = GetBindingKey(self.bindKey)
            if key1 or key2 then
                bt:SetText(key1 or key2)
            else
                bt:SetText(L["无"])
            end
        end)
        local f = CreateFrame("Frame", nil, parent)
        f:SetSize(20, 20)
        f:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("CENTER")
        t:SetText(name)
        f:SetWidth(t:GetStringWidth())
        bt:SetPoint("LEFT", f, "RIGHT", 10, 0)
    end
end

local function SetParent(self, key)
    if TuanJian.options[key] ~= 1 then
        self:Hide()
    end
    local parent = TJ.options["button" .. key]
    parent.child = parent.child or {}
    tinsert(parent.child, self)
    if not parent.hookDisable then
        parent.hookDisable = true
        hooksecurefunc(parent, "Disable", function()
            if parent.Text then
                parent.Text:SetTextColor(.5, .5, .5)
            end
            for i, child in ipairs(parent.child) do
                child:Hide()
            end
        end)
    end
end

function TJ.InitOptions()
    TJ.options = {}
    TJ.options.dispelFrameScalereset = .9

    do
        local f = CreateFrame("Frame", nil, TJ.optionMainFrame, "BackdropTemplate")
        f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 0, -25)
        f:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", -25, 0)
        local scroll = CreateFrame("ScrollFrame", nil, f, TJ.scrollTemplate)
        scroll:SetPoint("TOPLEFT", f, 0, -0)
        scroll:SetPoint("BOTTOMRIGHT", f, 0, 5)
        TJ.HookScrollBarShowOrHide(scroll)
        optionFrame = CreateFrame("Frame", nil, f)
        optionFrame:SetSize(1, 1)
        scroll:SetScrollChild(optionFrame)
        TJ.optionMainFrame.frame = f
        TJ.optionMainFrame.scroll = scroll
        TJ.optionMainFrame.optionFrame = optionFrame
    end

    -- 站位图导出/导入
    TJ.ExportMapUI()

    local height = 0
    local h = 20
    -- 通报任务时密语责任人
    do
        local name = "sendWhisper"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["通报任务时密语责任人"],
            L["在团队频道通报完全部任务后，再单独对每个责任人密语相应任务。"],
        }
        local f = O.CreateCheckButton(name, (L["通报任务时密语责任人"]), optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f

        local name = "banSendWhisper"
        TJ.options[name .. "reset"] = 0
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["屏蔽我通报的密语"],
            L["在聊天框不显示你通报任务的密语，避免刷屏。但实际上密语已经发送给责任人，对方能看到。"],
        }
        local f = O.CreateCheckButton(name, (L["屏蔽我通报的密语"]), optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
        local parent = TJ.options["button" .. "sendWhisper"]
        f:ClearAllPoints()
        f:SetPoint("LEFT", parent, "RIGHT", parent.Text:GetWidth() + 20, 0)
        SetParent(f, "sendWhisper")
    end
    h = h + 30
    -- 通报BUFF时同步骑士祝福插件
    if TJ.IsWLK then
        local name = "sendBuffPally"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["通报BUFF时同步骑士祝福插件"],
            L["使PallyPower插件显示为你安排的祝福BUFF。"],
            " ",
            L["需要你是团长或助理时，该功能才生效。"],
        }
        local f = O.CreateCheckButton(name, (L["通报BUFF时同步骑士祝福插件（需要你是团长或助理）"]), optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
        h = h + 30
    end
    -- 发送补BUFF提醒
    if TJ.IsWLK then
        local name = "sendTips"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]

        local f = O.CreateCheckButton(name, (L["发送补BUFF提醒（需要你是团长或助理）"]), optionFrame, 30, height - h)
        TJ.options["button" .. name] = f
        f:SetScript("OnEnter", function(self)
            local ontext = {
                L["发送补BUFF提醒"],
                L["当团队频道有人打字缺少某BUFF，且该玩家确实缺少该BUFF时，会自动密语提醒相关负责人。"],
                " ",
                L["当团队里有人放鱼时，自动在RW频道发送提醒。"],
                " ",
                L["需要你是团长或助理时，该功能才会生效。"],
            }
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            for i, text in ipairs(ontext) do
                if i == 1 then
                    GameTooltip:AddLine(text, 1, 1, 1, true)
                else
                    GameTooltip:AddLine(text, 1, 0.82, 0, true)
                end
            end
            GameTooltip:Show()
        end)
        f:HookScript("OnClick", function(self)
            C_ChatInfo.SendAddonMessage("TuanJian", "checkSender", "RAID")
        end)
        h = h + 30
    end
    -- 自动标记小怪
    do
        local name = "autoRaidTarget"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动标记小怪"],
            L["非战斗中，且你是团长/助理，当鼠标划过部分小怪时，会自动标记。"],
        }
        local f = O.CreateCheckButton(name, L["自动标记小怪（需要你是团长或助理）"], optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f

        local bt = TJ.CreateButton(f)
        bt:SetSize(80, 22)
        bt:SetText(L["重置标记"])
        bt:SetPoint("LEFT", f.Text, "RIGHT", 10, 0)
        bt:SetScript("OnClick", function(self)
            if TJ.IsLeader() then
                TJ.PlaySound(1)
                TJ.WipeAutoRaidTargetActive()
                for i = 1, 8 do
                    SetRaidTarget("player", i)
                end
                SetRaidTarget("player", 0)
                After(0.3, function()
                    SetRaidTarget("player", 0)
                end)
                ns.SendSystemMessage(L["已重置全部标记。"])
            end
        end)
    end
    h = h + 30
    -- 自动更改团员战斗职责
    do
        local name = "autoSetRaidCombatRole"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动更改团员战斗职责"],
            L["如果团员的当前战斗职责不符合其天赋时，自动帮它修改为正确的职责。"],
            " ",
            L["需要你是团长且团员在你附近才会生效。"],
        }
        local f = O.CreateCheckButton(name, (L["自动更改团员战斗职责（需要你是团长）"]), optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
    end
    h = h + 30
    -- 分配方式
    do
        local name = "lootMasterlooter"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["自动切换队长分配"],
            L["在团队中，而且你是团长时，自动切换为队长分配。"],
        }
        local f = O.CreateCheckButton(name, L["自动切换队长分配（需要你是团长）"], optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f

        local name = "lootThreshold"
        TJ.options[name .. "reset"] = 4
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local tbl = {
            { id = 2, name = "|c" .. select(4, GetItemQualityColor(2)) .. L["分配品质："] .. BATTLE_PET_BREED_QUALITY3 },
            { id = 3, name = "|c" .. select(4, GetItemQualityColor(3)) .. L["分配品质："] .. BATTLE_PET_BREED_QUALITY4 },
            { id = 4, name = "|c" .. select(4, GetItemQualityColor(4)) .. L["分配品质："] .. BATTLE_PET_BREED_QUALITY5 },
        }
        local function SetDropDownText()
            for i, v in ipairs(tbl) do
                if v.id == TuanJian.options[name] then
                    return v.name
                end
            end
            return ""
        end
        local dropDown = LibBG:Create_UIDropDownMenu(nil, f)
        dropDown:SetPoint("LEFT", f, "RIGHT", f.Text:GetWidth() + 10, -2)
        LibBG:UIDropDownMenu_SetWidth(dropDown, 150)
        LibBG:UIDropDownMenu_SetText(dropDown, SetDropDownText())
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
        TJ.dropDownToggle(dropDown)
        TJ.options["button" .. name] = dropDown
        SetParent(dropDown, "lootMasterlooter")
        LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
            for _, v in pairs(tbl) do
                local info = LibBG:UIDropDownMenu_CreateInfo()
                info.text = v.name
                info.checked = TuanJian.options[name] == v.id
                info.func = function()
                    TuanJian.options[name] = v.id
                    LibBG:UIDropDownMenu_SetText(dropDown, SetDropDownText())
                end
                LibBG:UIDropDownMenu_AddButton(info)
            end
        end)

        local GetLootMethod = GetLootMethod or C_PartyInfo.GetLootMethod
        local SetLootMethod = SetLootMethod or C_PartyInfo.SetLootMethod
        local done
        TJ.RegisterEvent("GROUP_ROSTER_UPDATE", function(self, event, ...)
            After(0.5, function()
                if IsInRaid(1) then
                    if not done and UnitIsGroupLeader("player")
                        and TuanJian.options.lootMasterlooter == 1 and GetLootMethod() ~= 2 then
                        done = true
                        SendSystemMessage(L["已自动切为队长分配。"])
                        SetLootMethod(2, "player")
                        After(1, function()
                            if GetLootThreshold() ~= TuanJian.options.lootThreshold then
                                SetLootThreshold(TuanJian.options.lootThreshold)
                            end
                        end)
                        After(3, function()
                            if GetLootThreshold() ~= TuanJian.options.lootThreshold then
                                SetLootThreshold(TuanJian.options.lootThreshold)
                            end
                        end)
                    end
                else
                    done = nil
                end
            end)
        end)
    end
    h = h + 30
    -- 进本自动清空历史数据
    do
        local name = "autoClear"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["进本自动清空历史数据"],
            L["当你进入一个新CD团本时，会把之前的战斗分析数据清空。"],
        }
        local f = O.CreateCheckButton(name, L["进本自动清空历史战斗分析"], optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
    end
    h = h + 30
    -- 退团自动重置所有战术安排
    do
        local name = "autoClear_leaveRaid"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["退团自动重置所有战术安排"],
            L["退团自动重置所有战术安排（包括任务安排、减伤链、站位图安排、BUFF安排、团减、增伤、个减等等）"],
        }
        local f = O.CreateCheckButton(name, L["退团自动重置所有战术安排"], optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
    end
    h = h + 30
    -- 默认勾选高级战斗日志
    do
        local name = "advancedCombatLogging"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
        }
        local f = O.CreateCheckButton(name, L["默认勾选高级战斗日志"], optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
        if TuanJian.options[name] == 1 then
            SetCVar("advancedCombatLogging", "1")
        end
        f:HookScript("OnClick", function(self)
            if self:GetChecked() then
                SetCVar("advancedCombatLogging", "1")
            end
        end)
    end
    -- 团本里自动开启战斗日志
    do
        local name = "openCombatLogging"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["团本里自动开启战斗日志"],
            L["仅对当前资料片的团本有效，旧资料片团本无效。"],
            L["如果你在多个插件启动了相似功能，会导致战斗日志中途断开。"],
        }
        local f = O.CreateCheckButton(name, L["团本里自动开启战斗日志"], optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
        local parent = TJ.options["button" .. "advancedCombatLogging"]
        f:ClearAllPoints()
        f:SetPoint("LEFT", parent, "RIGHT", parent.Text:GetWidth() + 20, 0)
        SetParent(f, "advancedCombatLogging")

        local function CheckOtherAddon()
            if DBM and DBM.Options and DBM.Options.AutologBosses then
                return "DBM"
            end
            if VMRT and VMRT.Logging and VMRT.Logging.enabled then
                return "MRT"
            end
        end
        TJ.RegisterEvent("PLAYER_ENTERING_WORLD", function()
            if TuanJian.options['advancedCombatLogging'] == 1 and TuanJian.options[name] == 1 then
                if CheckOtherAddon() then return end
                After(2, function()
                    local name, instanceType, difficultyID, difficultyName, maxPlayers,
                    dynamicDifficulty, isDynamic, instanceID, instanceGroupSize, LfgDungeonID = GetInstanceInfo()
                    local yes
                    for _, v in pairs(TJ.FBinfo) do
                        if v.ID == instanceID then
                            yes = true
                            break
                        end
                    end
                    if yes and IsInInstance() then
                        LoggingCombat(true)
                        ns.SendSystemMessage(COMBATLOGENABLED)
                    elseif LoggingCombat() then
                        LoggingCombat(false)
                        ns.SendSystemMessage(COMBATLOGDISABLED)
                    end
                end)
            end
        end)
    end
    h = h + 30
    -- BOSS战成功后弹出界面
    do
        local name = "showUIAfterKillBossSuccess"
        TJ.options[name .. "reset"] = 0
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["BOSS战成功后弹出界面"],
            L["成功击杀BOSS后主动显示插件，方便你查看战斗分析。"],
        }
        local f = O.CreateCheckButton(name, (L["BOSS战成功后弹出界面"]), optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
    end
    -- BOSS战失败后弹出界面
    do
        local name = "showUIAfterKillBossFalse"
        TJ.options[name .. "reset"] = 0
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["BOSS战失败后弹出界面"],
            L["团灭后主动显示插件，方便你查看战斗分析。"],
        }
        local f = O.CreateCheckButton(name, (L["BOSS战失败后弹出界面"]), optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f
        local parent = TJ.options["button" .. "showUIAfterKillBossSuccess"]
        f:ClearAllPoints()
        f:SetPoint("LEFT", parent, "RIGHT", parent.Text:GetWidth() + 20, 0)
    end
    h = h + 30
    -- 密语自动邀请
    do
        local ConvertToRaid = ConvertToRaid or C_PartyInfo.ConvertToRaid

        local name = "autoInviteByWhisper"
        TJ.options[name .. "reset"] = 0
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["密语关键词自动邀请"],
            L["当有玩家密语你指定内容时，自动邀请对方进组。"],
            L["需要你是团长或助理时，该功能才会生效。"],
        }
        local f = O.CreateCheckButton(name, L["密语关键词自动邀请"], optionFrame, 30, height - h, ontext)
        TJ.options["button" .. name] = f

        local keywordName = "autoInviteKeyword"
        TuanJian.options[keywordName] = TuanJian.options[keywordName] or "123"
        local edit = CreateFrame("EditBox", nil, f, "TuanJian_InputBoxTemplate")
        edit:SetSize(100, 25)
        edit:SetPoint("LEFT", f.Text, "RIGHT", 10, 0)
        edit:SetAutoFocus(false)
        edit:SetText(TuanJian.options[keywordName])
        SetParent(edit, name)
        TJ.SetEditBaseClass(edit)
        edit:SetScript("OnTextChanged", function(self)
            TuanJian.options[keywordName] = self:GetText()
        end)

        -- 密语自动邀请
        TJ.RegisterEvent("CHAT_MSG_WHISPER", function(self, event, msg, sender, ...)
            if TuanJian.options.autoInviteByWhisper == 1 and TuanJian.options.autoInviteKeyword
                and TuanJian.options.autoInviteKeyword ~= ""
                and msg == TuanJian.options.autoInviteKeyword and TJ.IsLeader()
            then
                if not IsInRaid(1) and GetNumGroupMembers() == 5 then
                    ConvertToRaid()
                end
                C_PartyInfo.InviteUnit(sender)
            end
        end)

        TJ.RegisterEvent("CHAT_MSG_BN_WHISPER", function(self, event, ...)
            local msg, sender, _, _, _, _, _, _, _, _, _, _, bnSenderID = ...
            local _, BNcount                                            = BNGetNumFriends()
            for i = 1, BNcount do
                if senderBnetIDAccount == BNGetFriendInfo(i) then
                    local numGameAccounts = BNGetNumFriendGameAccounts(i)
                    for j = 1, numGameAccounts do
                        local hasFocus, characterName, client, realmName, realmID, faction, race, class, _, _,
                        level, _, _, _, _, bnetIDGameAccount = BNGetFriendGameAccountInfo(i, j)
                        if client == BNET_CLIENT_WOW and faction == UnitFactionGroup('player') then
                            BNInviteFriend(bnetIDGameAccount)
                        end
                    end
                    break
                end
            end
            if TuanJian.options.autoInviteByWhisper == 1 and TuanJian.options.autoInviteKeyword
                and TuanJian.options.autoInviteKeyword ~= ""
                and msg == TuanJian.options.autoInviteKeyword and TJ.IsLeader()
            then
                local bnetIDGameAccount = select(6, BNGetFriendInfoByID(bnSenderID))
                if bnetIDGameAccount then
                    if CanCooperateWithGameAccount(bnetIDGameAccount) then
                        if not IsInRaid(1) and GetNumGroupMembers() == 5 then
                            ConvertToRaid()
                        end
                        BNInviteFriend(bnetIDGameAccount)
                    end
                end
            end
        end)
    end
    h = h + 30
    -- 悬浮框
    do
        local name = "mainIcon"
        TJ.options[name .. "reset"] = 0
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local f = O.CreateCheckButton(name, AddTexture('QUEST') .. L["显示悬浮框"], optionFrame, 30, -h, {
            L["显示悬浮框"],
        })
        f:HookScript("OnClick", function(self)
            TJ.MainIcon:SetShown(self:GetChecked())
        end)

        local name = "mainIconScale"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = tonumber(TuanJian.options[name]) or TJ.options[name .. "reset"]
        local slider, f = O.CreateSlider(name, L["缩放"], optionFrame, .5, 1.5, .01, 30, -h, nil, 70, true)
        SetParent(f, "mainIcon")
        slider:HookScript("OnValueChanged", function(self, value)
            if TJ.MainIcon then
                TJ.MainIcon:SetScale(value)
            end
        end)
        f:ClearAllPoints()
        f:SetPoint('LEFT', TJ.options['buttonmainIcon'].Text, 'RIGHT', 20, 0)

        local name = "mainIconFrameLevel"
        TJ.options[name .. "reset"] = "HIGH"
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local f = CreateFrame("Frame", nil, f)
        f:SetSize(20, 20)
        f:SetPoint("LEFT", slider, "RIGHT", 80, 0)
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("CENTER")
        t:SetTextColor(1, 1, 1)
        t:SetText(L["层级："])
        f:SetWidth(t:GetStringWidth())
        local dropDown = LibBG:Create_UIDropDownMenu(nil, optionFrame)
        dropDown:SetPoint("LEFT", f, "RIGHT", -10, -2)
        LibBG:UIDropDownMenu_SetWidth(dropDown, 90)
        LibBG:UIDropDownMenu_SetText(dropDown, TuanJian.options[name])
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
        TJ.dropDownToggle(dropDown)
        TJ.options["button" .. name] = dropDown
        SetParent(dropDown, "mainIcon")
        LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
            for _, text in ipairs({ "BACKGROUND", "LOW", "MEDIUM", "HIGH", "DIALOG", "FULLSCREEN", "FULLSCREEN_DIALOG", "TOOLTIP" }) do
                local info = LibBG:UIDropDownMenu_CreateInfo()
                info.text = text
                info.func = function()
                    TuanJian.options[name] = text
                    LibBG:UIDropDownMenu_SetText(dropDown, text)
                    if TJ.MainIcon then
                        TJ.MainIcon:SetFrameStrata(text)
                    end
                end
                info.checked = TuanJian.options[name] == text
                LibBG:UIDropDownMenu_AddButton(info)
            end
        end)
    end
    h = h + 40
    -- 任务通报频道
    do
        local name = "sendChannel"
        TJ.options[name .. "reset"] = "RAID_WARNING"
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]

        local tbl = {
            RAID_WARNING = L["团队通知频道"],
            RAID = L["团队频道"],
        }

        local f = CreateFrame("Frame", nil, optionFrame)
        f:SetSize(20, 20)
        f:SetPoint("TOPLEFT", optionFrame, "TOPLEFT", 30, height - h)
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("CENTER")
        t:SetTextColor(1, 1, 1)
        t:SetText(L["任务通报频道："])
        f:SetWidth(t:GetStringWidth())

        local dropDown = LibBG:Create_UIDropDownMenu(nil, f)
        dropDown:SetPoint("LEFT", f, "RIGHT", 0, -2)
        LibBG:UIDropDownMenu_SetWidth(dropDown, 120)
        LibBG:UIDropDownMenu_SetText(dropDown, tbl[TuanJian.options[name]])
        LibBG:UIDropDownMenu_SetAnchor(dropDown, 0, 0, "TOP", dropDown, "BOTTOM")
        TJ.dropDownToggle(dropDown)
        TJ.options["button" .. name] = dropDown

        LibBG:UIDropDownMenu_Initialize(dropDown, function(self, level)
            for key, text in pairs(tbl) do
                local info = LibBG:UIDropDownMenu_CreateInfo()
                info.text = text
                info.func = function()
                    TuanJian.options[name] = key
                    LibBG:UIDropDownMenu_SetText(dropDown, tbl[TuanJian.options[name]])
                end
                if TuanJian.options[name] == key then
                    info.checked = true
                end
                LibBG:UIDropDownMenu_AddButton(info)
            end
        end)
    end
    h = h + 30
    -- 战斗分析保存数量
    do
        local name = "saveLogCount"
        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local ontext = {
            L["战斗分析保存数量"],
            L["可以查看最近多少场BOSS战记录。数值越高，占用的内存越高（但内存占用高不等于卡顿）。"],
            " ",
            L["16G内存的，建议选5个。32G或以上，可以无脑选最大值。"],
        }
        local f = O.CreateSlider(name, (L["战斗分析保存数量"]), optionFrame, 1, 20, 1, 30, height - h, ontext)
        TJ.options["button" .. name] = f
        f:HookScript("OnValueChanged", function(self)
            TJ.ClearOutCombatLog()
        end)
    end
    h = h + 40
    -- 快捷键
    O.CreateBindKey(optionFrame, 30, -h, nil, "TUANJIAN", L["打开/关闭快捷键："])



    h = h + 60
    optionFrame:SetHeight(h)
end
