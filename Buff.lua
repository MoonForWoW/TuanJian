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
    if not TJ.IsWLK then return end
    C_ChatInfo.RegisterAddonMessagePrefix("PLPWR")

    local EXPIRE_TIME = 60 * 3

    -- 团队BUFF
    local buffTbl
    buffTbl = {
        { id = { [25899] = true, [20911] = true }, displayID = 25899, class = { "PALADIN" }, Pally = "4444444444", tipKey = L["庇护"], monitor = true, }, -- 庇护
        { id = { [48934] = true, [48932] = true }, displayID = 48934, class = { "PALADIN" }, Pally = "22n222n222", tipKey = L["力量"], monitor = true, monitorFilter = "physical", monitorPet = true, }, -- 力量
        { id = { [25898] = true, [20217] = true }, displayID = 25898, class = { "PALADIN" }, Pally = "3333333333", tipKey = L["王者"], monitor = true, monitorPet = true, }, -- 王者
        { id = { [48938] = true, [48936] = true }, displayID = 48938, class = { "PALADIN" }, Pally = "nn1111111n", tipKey = L["智慧 回蓝"], shortName = L["智慧"], monitor = true, monitorFilter = "wisdom", }, -- 智慧
        { id = { [48170] = true, [48169] = true }, displayID = 48170, class = { "PRIEST" }, tipKey = L["暗抗"], }, -- 暗抗
        { id = { [48162] = true, [48161] = true }, displayID = 48162, class = { "PRIEST" }, tipKey = L["耐力"], monitor = true, monitorPet = true, }, -- 耐力
        { id = { [48074] = true, [48073] = true }, displayID = 48074, class = { "PRIEST" }, tipKey = L["精神"], monitor = true, monitorFilter = "caster", }, -- 精神
        { id = { [48470] = true, [48469] = true }, displayID = 48470, class = { "DRUID" }, tipKey = L["爪子"], monitor = true, monitorPet = true, }, -- 爪子
        { id = { [43002] = true, [42995] = true, [61024] = true, [61316] = true }, displayID = 43002, class = { "MAGE" }, tipKey = L["智力"], monitor = true, monitorFilter = "mana", }, -- 智力
        { id = { [58659] = true }, displayID = 58659, class = { "MAGE" }, tipKey = L["大餐 桌子 吃喝"], }, -- 桌子
        { id = { [43015] = true }, displayID = 43015, auraID = { [57399] = true }, monitorDisplayID = 57399, auraName = L["进食充分"], class = nil, isItem = true, tipKey = L["鱼"], shortName = L["食物"], monitor = true, noBroadcast = true, noWhisper = true, whisperMissing = true, }, -- 放鱼
    }
    TuanJian.Buff = TuanJian.Buff or {}
    TuanJian.Buff.edit = TuanJian.Buff.edit or {}
    TuanJian.Buff.monitor = TuanJian.Buff.monitor or {}
    for i, v in ipairs(buffTbl) do
        TuanJian.Buff.edit[i] = TuanJian.Buff.edit[i] or {}
    end
    TJ.Buff = {}

    do
        local t = TJ.buffMainFrame:CreateFontString()
        t:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPLEFT", 170, -40)
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetText(L["团队BUFF"])
        t:SetTextColor(1, 0.82, 0)
        TJ.Buff.topTitle = t

        After(0, function()
            local t = TJ.buffMainFrame:CreateFontString()
            t:SetPoint("BOTTOM", TJ.Buff[1].edit, "TOP", 0, 10)
            -- t:SetPoint("BOTTOMLEFT", TJ.Buff[1].edit, "TOPLEFT", 0, 5)
            t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            t:SetText(L["负责人"])
            t:SetTextColor(1, 0.82, 0)
        end)

        local bt = CreateFrame("Button", nil, TJ.buffMainFrame)
        bt:SetSize(18, 18)
        bt:SetPoint("BOTTOMRIGHT", TJ.MainFrame, "BOTTOMRIGHT", -20, 23)
        bt:SetNormalTexture("interface/raidframe/readycheck-notready")
        bt:SetHighlightTexture("interface/raidframe/readycheck-notready")
        bt:RegisterForClicks("AnyUp")
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            TJ.ClearBuff()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置"], 1, 1, 1, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)

        local monitorToggle = TJ.CreateButton(TJ.buffMainFrame)
        monitorToggle:SetSize(120, 25)
        monitorToggle:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPRIGHT", -20, -35)
        monitorToggle:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if TJ.SetBuffMonitorShown then
                TJ.SetBuffMonitorShown(TuanJian.Buff.monitor.show ~= 1)
            end
        end)
        monitorToggle:SetScript("OnEnter", function(self)
            if IsInRaid(1) then return end
            GameTooltip:SetOwner(self, "ANCHOR_BOTTOM", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(self:GetText(), 1, 1, 1, true)
            GameTooltip:AddLine(L["你当前不在团队中，监控界面不会显示。"], 1, .2, .2, true)
            GameTooltip:Show()
        end)
        monitorToggle:SetScript("OnLeave", GameTooltip_Hide)
        function monitorToggle:Update()
            if TuanJian.Buff.monitor.show == 1 then
                self:SetText(AddTexture('QUEST') .. L["关闭监控界面"])
            else
                self:SetText(AddTexture('QUEST') .. L["打开监控界面"])
            end
        end

        monitorToggle:Update()
        TJ.BuffMonitorToggleButton = monitorToggle
    end

    local function CreateSpellFrame(ID, isItem)
        local f = CreateFrame("Frame", nil, TJ.buffMainFrame)
        if #TJ.Buff == 0 then
            f:SetPoint("TOPRIGHT", TJ.Buff.topTitle, "BOTTOMRIGHT", 0, -10)
        else
            f:SetPoint("TOPRIGHT", TJ.Buff[#TJ.Buff].title, "BOTTOMRIGHT", 0, -10)
        end
        f:SetSize(0, 20)
        f.ID = ID
        local t = f:CreateFontString()
        t:SetAllPoints()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetJustifyH("RIGHT")
        t:SetWordWrap(false)
        tinsert(TJ.Buff, { title = f })
        f:SetScript("OnMouseDown", function(self)
            if IsShiftKeyDown() then
                TJ.PlaySound(1)
                TJ.InsertLink(self.link)
            end
        end)
        f:SetScript("OnEnter", function(self)
            if not self.ds then
                local tex = self:CreateTexture(nil, "BACKGROUND")
                tex:SetPoint("CENTER")
                tex:SetSize(t:GetWrappedWidth() + 3, 20)
                tex:SetColorTexture(1, 1, 1, 0.2)
                self.ds = tex
            end
            self.ds:Show()
            GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
            GameTooltip:ClearLines()
            if isItem then
                GameTooltip:SetItemByID(ID)
            else
                GameTooltip:SetSpellByID(ID)
            end
            GameTooltip:Show()
        end)
        f:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            self.ds:Hide()
        end)
        if isItem then
            local item = Item:CreateFromItemID(ID)
            item:ContinueOnItemLoad(function()
                local icon = select(5, GetItemInfoInstant(ID))
                local link = select(2, GetItemInfo(ID))
                f.link = link
                t:SetText("|T" .. icon .. ":18:18|t" .. link)
                f:SetWidth(t:GetUnboundedStringWidth() + 10)
            end)
        else
            TJ.OnSpellLoad(ID, function()
                local icon = C_Spell.GetSpellTexture(ID)
                local link = C_Spell.GetSpellLink(ID)
                f.link = link
                t:SetText("|T" .. icon .. ":18:18|t" .. link)
                f:SetWidth(t:GetUnboundedStringWidth() + 10)
            end)
        end

        return f
    end

    local function CreateEdit()
        local i = #TJ.Buff
        local edit = CreateFrame("EditBox", nil, TJ.Buff[i].title, "TuanJian_InputBoxTemplate")
        edit:SetSize(130, 20)
        edit:SetAutoFocus(false)
        edit:SetPoint("LEFT", TJ.Buff[i].title, "RIGHT", 15, 0)
        edit.i = i
        edit.Pally = buffTbl[i].Pally
        edit.spell = TJ.Buff[i].title
        local db = TuanJian.Buff.edit[i]
        if db then
            local r, g, b = GetClassColor(db.class)
            edit:SetText(db and db.text or "")
            edit:SetTextColor(r, g, b)
            edit.player = db.player
            edit.class = db.class
            edit.role = db.role
            edit.combatRole = db.combatRole
            edit.talent = db.talent
        end
        TJ.Buff[i].edit = edit

        function edit:ClearAll()
            local i = self.i
            if self:GetText() ~= "" then
                self:SetText("")
            end
            self:SetTextColor(1, 1, 1)
            self.player = nil
            self.class = nil
            self.role = nil
            self.combatRole = nil
            self.talent = nil
            wipe(TuanJian.Buff.edit[i])
        end

        function edit:Save()
            local i = self.i
            TuanJian.Buff.edit[i].text = self:GetText()
            TuanJian.Buff.edit[i].player = self.player
            TuanJian.Buff.edit[i].class = self.class
            TuanJian.Buff.edit[i].role = self.role
            TuanJian.Buff.edit[i].combatRole = self.combatRole
            TuanJian.Buff.edit[i].talent = self.talent
        end

        edit:SetScript("OnTextChanged", function(self)
            if self:GetText() == "" then
                self:ClearAll()
            else
                self:Save()
            end
        end)
        edit:HookScript("OnEditFocusGained", function(self)
            TJ.lastfocus = self
            TJ.ListPlayer(self, buffTbl[i].class)
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
    end

    for i, v in ipairs(buffTbl) do
        CreateSpellFrame(v.displayID, v.isItem)
        CreateEdit()
    end

    -- 通报
    function TJ.GetAllQuestText_Buff(OnEnter)
        local tbl = {}
        local playerTbl = {}
        local text = "{rt1}"
        TJ.PairAllEdit_Buff(function(edit)
            if edit:GetText() ~= "" then
                local spell = edit.spell
                if OnEnter then
                    local r, g, b = edit:GetTextColor()
                    local player = ns.RGB_16(edit:GetText(), r, g, b)
                    tinsert(tbl, { text .. spell.link .. L["："] .. player })
                else
                    tinsert(tbl, { text .. spell.link .. L["："] .. TJ.ClearCode(edit:GetText()) })
                end
                tinsert(playerTbl, {
                    player = TJ.ClearCode(edit:GetText()),
                    quest = spell.link,
                })
            end
        end)
        if not OnEnter then
            TJ.SendPally()
        end
        return tbl, playerTbl
    end

    -- 发送祝福通讯消息
    do
        function TJ.SendPally()
            if TuanJian.options.sendBuffPally == 1 and IsInRaid(1) and TJ.IsLeader() then
                TJ.PairAllEdit_Buff(function(edit)
                    if edit:GetText() ~= "" and edit.Pally then
                        local msg = format("PASSIGN %s@%s", TJ.ClearCode(edit:GetText()), edit.Pally)
                        ChatThrottleLib:SendAddonMessage("NORMAL", "PLPWR", msg, "RAID")
                    end
                end)
            end
        end

        TJ.Init2(function()
            if IsAddOnLoaded("PallyPower") then
                TJ.RegisterEvent("CHAT_MSG_ADDON", function(self, event, ...)
                    local prefix, msg, distType, _, sender = ...
                    if prefix == "PLPWR" and sender == TJ.playerName and strfind(msg, "^PASSIGN") then
                        local _, _, name, assign = strfind(msg, "^PASSIGN (.*)@([0-9n]*)")
                        name = TJ.GSN(name)
                        if not PallyPower_Assignments[name] then
                            PallyPower_Assignments[name] = {}
                        end
                        if assign then
                            for i = 1, PALLYPOWER_MAXCLASSES do
                                local tmp = strsub(assign, i, i)
                                if tmp == "n" or tmp == "" then
                                    tmp = 0
                                end
                                PallyPower_Assignments[name][i] = tmp + 0
                            end
                        end
                        PallyPower:UpdateLayout()
                    end
                end)

                -- 禁用PallyPower插件自身的同步功能
                local PallyPower = LibStub("AceAddon-3.0"):GetAddon("PallyPower", "AceConsole-3.0", "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")
                if PallyPower then
                    PallyPower.SendMessage = function() end
                end
            end
        end)
    end

    -- 一键安排BUFF
    local function SetEditTextFormNum(v, i)
        local edit = TJ.Buff[i].edit
        if edit:GetText() == "" then
            edit:SetText(TJ.GetIconAndName(v))
            local r, g, b = GetClassColor(v.class)
            edit:SetTextColor(r, g, b)
            edit.player = v.name
            edit.class = v.class
            edit.role = v.role
            edit.combatRole = v.combatRole
            edit.talent = TuanJian.talentInfo[v.name]
        end
    end
    function TJ.SetAutoChoose_Buff()
        TJ.PairAllEdit_Buff(function(edit)
            edit:ClearAll()
        end)

        local tbl_fq = TJ.SortRaidRosterInfo({ "PALADIN" }, "tank", true)
        for i, v in ipairs(tbl_fq) do
            SetEditTextFormNum(v, 1)
        end
        local tbl_nq = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer", true)
        local tbl_cjq = TJ.SortRaidRosterInfo({ "PALADIN" }, "dps", true)
        if #tbl_nq == 1 and #tbl_cjq >= 2 then
            local done = {}
            for _, v in ipairs(tbl_cjq) do
                for _, i in ipairs({ 2, 3 }) do
                    if not done[i] then
                        SetEditTextFormNum(v, i)
                        done[i] = true
                        break
                    end
                end
            end
            for i, v in ipairs(tbl_nq) do
                SetEditTextFormNum(v, 4)
            end
        elseif #tbl_nq == 0 then
            local done = {}
            for _, v in ipairs(tbl_cjq) do
                for _, i in ipairs({ 2, 3, 4 }) do
                    if not done[i] then
                        SetEditTextFormNum(v, i)
                        done[i] = true
                        break
                    end
                end
            end
        else
            local done = {}
            for _, v in ipairs(tbl_nq) do
                for _, i in ipairs({ 3, 4 }) do
                    if not done[i] then
                        SetEditTextFormNum(v, i)
                        done[i] = true
                        break
                    end
                end
            end
            for i, v in ipairs(tbl_cjq) do
                SetEditTextFormNum(v, 2)
            end
        end

        local tbl_am = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
        local tbl_nm = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
        if next(tbl_am) then
            for i, v in ipairs(tbl_am) do
                SetEditTextFormNum(v, 5)
            end
            if #tbl_nm >= 2 then
                local done = {}
                for _, v in ipairs(tbl_nm) do
                    for _, i in ipairs({ 6, 7 }) do
                        if not done[i] then
                            SetEditTextFormNum(v, i)
                            done[i] = true
                            break
                        end
                    end
                end
            else
                for _, v in ipairs(tbl_nm) do
                    SetEditTextFormNum(v, 6)
                    SetEditTextFormNum(v, 7)
                    break
                end
            end
        else
            if #tbl_nm >= 3 then
                local done = {}
                for _, v in ipairs(tbl_nm) do
                    for _, i in ipairs({ 5, 6, 7 }) do
                        if not done[i] then
                            SetEditTextFormNum(v, i)
                            done[i] = true
                            break
                        end
                    end
                end
            elseif #tbl_nm == 2 then
                for i, v in ipairs(tbl_nm) do
                    SetEditTextFormNum(v, 6)
                    SetEditTextFormNum(v, 7)
                    tremove(tbl_nm, i)
                    break
                end
                for i, v in ipairs(tbl_nm) do
                    SetEditTextFormNum(v, 5)
                end
            else
                for _, v in ipairs(tbl_nm) do
                    SetEditTextFormNum(v, 5)
                    SetEditTextFormNum(v, 6)
                    SetEditTextFormNum(v, 7)
                    break
                end
            end
        end

        local tbl_xd = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
        for _, v in pairs(CopyTable(TJ.SortRaidRosterInfo({ "DRUID", }, "dps", true))) do
            tinsert(tbl_xd, v)
        end
        for i, v in ipairs(tbl_xd) do
            SetEditTextFormNum(v, 8)
        end

        local tbl_fs = TJ.SortRaidRosterInfo({ "MAGE" }, "", true)
        if #tbl_fs == 1 then
            for i, v in ipairs(tbl_fs) do
                SetEditTextFormNum(v, 9)
                SetEditTextFormNum(v, 10)
            end
        elseif #tbl_fs >= 2 then
            local done = {}
            for _, v in ipairs(tbl_fs) do
                for _, i in ipairs({ 9, 10 }) do
                    if not done[i] then
                        SetEditTextFormNum(v, i)
                        done[i] = true
                        break
                    end
                end
            end
        end
    end

    function TJ.PairAllEdit_Buff(func)
        for i, v in ipairs(TJ.Buff) do
            func(v.edit)
        end
    end

    function TJ.UpdateEditIcon_Buff()
        if TJ.buffMainFrame:IsVisible() then
            for i, v in ipairs(TJ.raidRosterInfo) do
                TJ.PairAllEdit_Buff(function(edit)
                    if edit.player == v.name then
                        local text = TJ.GetIconAndName(v, edit.talent)
                        edit:SetText(text)
                        edit:Save()
                    end
                end)
            end
        end
    end

    function TJ.ClearBuff()
        TJ.PairAllEdit_Buff(function(edit)
            edit:ClearAll()
        end)
    end

    -- 发送提醒
    do
        local blackList = {
            "|H",
            "检测",
            "检查",
            "交易",
            "光环",
            "宝宝",
            "BB",
            '鱼肉筵席',
            --'',
            --'',
            --'',
        }

        local CD = 8
        local sended = {}
        local function SaveSended(player, buffID)
            local CD = CD
            if player == "" then
                CD = 60
            end
            sended[player .. buffID] = true
            After(CD, function()
                sended[player .. buffID] = nil
            end)
        end
        local function GetAura(unit, spellIDs)
            for i = 1, 60 do
                local name, icon, count, dispelType, duration, expirationTime, source,
                isStealable, nameplateShowPersonal, spellID = UnitBuff(unit, i)
                if not spellID then break end
                if spellIDs[spellID] then
                    return expirationTime - GetTime(), spellID
                end
            end
        end

        local fishFeastSpellID = 57426
        TJ.RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(self, event, ...)
            if not (TuanJian.options.sendTips == 1 and TJ.IsLeader() and IsInRaid(1)) then return end
            local _, subevent, _, _, sourceName, _, _, _, _, _, _, spellID = ...
            if subevent ~= "SPELL_CAST_SUCCESS" or spellID ~= fishFeastSpellID or not sourceName then return end
            local name = TJ.GSN(sourceName)
            if not UnitInRaid(name) then return end
            SendChatMessage(format(L["%s放鱼了，大家快吃！"], name), "RAID_WARNING")
        end)

        local f = CreateFrame("Frame")
        f:RegisterEvent("CHAT_MSG_RAID")
        f:RegisterEvent("CHAT_MSG_RAID_LEADER")
        f:SetScript("OnEvent", function(self, event, msg, playerName, ...)
            if not (TJ.IsLeader() and IsInRaid(1)) then return end
            for i, text in ipairs(blackList) do
                if strfind(msg, text, 1, true) then
                    return
                end
            end
            playerName = TJ.GSN(playerName)
            -- 查找关键词是否匹配
            for i, v in pairs(buffTbl) do
                local fullText = v.tipKey
                for _, text in ipairs({ strsplit(" ", fullText) }) do
                    if text and strfind(msg, text) then
                        local buffMan = TJ.ClearCode(TJ.Buff[i].edit:GetText())
                        if buffMan ~= "" and UnitInRaid(buffMan) then
                            local num = TJ.raidRosterName[playerName]
                            if num then
                                local expirationTime, spellID
                                if not v.isItem then
                                    expirationTime, spellID = GetAura("raid" .. num, v.id)
                                end
                                local buff = spellID and C_Spell.GetSpellLink(spellID) or TJ.Buff[i].title.link
                                local buffID
                                if v.isItem then
                                    buffID = buff:match("item:(%d+):")
                                    if not sended[buffID] then
                                        local text = format(logo .. L["部分团员缺少%s"], buff)
                                        SendChatMessage(text, "WHISPER", nil, TJ.GFN(buffMan))
                                        SaveSended("", buffID)
                                    end
                                else
                                    buffID = buff:match("spell:(%d+):")
                                    if not sended[playerName .. buffID] then
                                        if not (expirationTime and expirationTime >= EXPIRE_TIME) then
                                            local team = TJ.GetRaidPoint()
                                            if team[playerName] then
                                                if expirationTime then
                                                    local text = format(logo .. L["%s%s的%s只剩%s分钟了"], team[playerName], playerName, buff, floor(expirationTime / 60) + 1)
                                                    SendChatMessage(text, "WHISPER", nil, TJ.GFN(buffMan))
                                                else
                                                    local text = format(logo .. L["%s%s缺少%s"], team[playerName], playerName, buff)
                                                    SendChatMessage(text, "WHISPER", nil, TJ.GFN(buffMan))
                                                end
                                                SaveSended(playerName, buffID)
                                            end
                                        end
                                    end
                                end
                            end
                            break
                        end
                    end
                end
            end
        end)
    end

    -- 团队BUFF常驻监控
    do
        local CLICK_ALL_CD = 12
        local CLICK_CD = 8
        local BURST_POTION_RESET_DELAY = 60 * 2 -- 战斗后爆发药水重置时间 
        local monitorSaved = TuanJian.Buff.monitor or {}
        if monitorSaved.layout ~= 2 and monitorSaved.layout ~= 3 then
            monitorSaved.layout = 1
        end
        local frameStrataOptions = {
            { value = "BACKGROUND", text = L["BACKGROUND"] },
            { value = "LOW", text = L["LOW"] },
            { value = "MEDIUM", text = L["MEDIUM"] },
            { value = "HIGH", text = L["HIGH"] },
            { value = "DIALOG", text = L["DIALOG"] },
            { value = "FULLSCREEN", text = L["FULLSCREEN"] },
            { value = "FULLSCREEN_DIALOG", text = L["FULLSCREEN_DIALOG"] },
            { value = "TOOLTIP", text = L["TOOLTIP"] },
        }
        local validFrameStrata = {}
        for _, option in ipairs(frameStrataOptions) do
            validFrameStrata[option.value] = true
        end
        if not validFrameStrata[monitorSaved.frameStrata] then
            monitorSaved.frameStrata = "MEDIUM"
        end
        local frameScaleOptions = { 80, 85, 90, 95, 100, 105, 110, 115, 120 }
        local validFrameScale = {}
        for _, percent in ipairs(frameScaleOptions) do
            validFrameScale[percent / 100] = true
        end
        if not validFrameScale[monitorSaved.scale] then
            monitorSaved.scale = 1
        end
        monitorSaved.filters = monitorSaved.filters or {}
        local rows = {}
        local clickCD = {}
        local broadcastCD
        local missingWhisperCD = {}
        local burstPotionUsed = {}
        local burstPotionActive
        local burstPotionResetPending
        local burstPotionResetGeneration = 0
        local SendMissingWhisper, OpenMonitorMenu, GetResponsibilityUnit, UpdateMonitorLayout, UpdateMonitor
        local IsMonitorRowEnabled
        local StartMonitorMoving, StopMonitorMoving
        local title, broadcastButton, monitorFrame
        local flaskInfo = {
            auraID = {
                [53755] = true, -- 冰霜巨龙合剂
                [53758] = true, -- 石血合剂
                [53760] = true, -- 无尽怒气合剂
                [54212] = true, -- 纯净魔精合剂
                [53752] = true, -- 次级坚韧合剂
                [62380] = true, -- 次级抗性合剂
                [60347] = true, -- 强效思维 45智力
                [17627] = true, -- 精炼智慧合剂
            },
            monitorDisplayID = 53755,
            monitorKey = "flask",
            shortName = L["合剂"],
            monitor = true,
            noBroadcast = true,
            noWhisper = true,
            whisperMissing = true,
        }
        local burstPotionInfo = {
            auraID = {
                [28714] = true,   -- 烈焰菇
                [53908] = true,   -- 速度药水
                [53909] = true,   -- 狂野魔法药水
                [53762] = true,   -- 不灭药水
                [1282971] = true, -- 狂野魔精
                -- [20217] = true,   -- test
            },
            monitorDisplayID = 53908,
            monitorKey = "burst_potion",
            shortName = L["吃药"],
            monitor = true,
            noBroadcast = true,
            noWhisper = true,
            countMode = "burstPotion",
            missingTitle = L["未使用："],
            inactiveText = L["等待下一轮首领战"],
        }
        local focusMagicInfo = {
            auraID = { [54646] = true },
            monitorDisplayID = 54646,
            monitorKey = "focus_magic",
            shortName = L["专注"],
            monitor = true,
            noBroadcast = true,
            noWhisper = true,
            countMode = "casterClass",
            casterClass = "MAGE",
            missingTitle = L["未使用："],
        }
        local personalBuffInfo = {
            monitorDisplayID = 25780,
            monitorKey = "personal_buff",
            shortName = L["常驻"],
            monitor = true,
            noBroadcast = true,
            noWhisper = true,
            whisperMissing = true,
            countMode = "personalBuff",
            ignoreExpiration = true,
        }
        local personalBuffRules = {
            MAGE = {
                id = { [43046] = true, [43045] = true, [30482] = true },
                displayID = 43046, -- 熔岩护甲
                ignoreExpiration = true,
            },
            WARLOCK = {
                id = { [47893] = true },
                displayID = 47893, -- 邪甲术
                ignoreExpiration = true,
            },
            HUNTER = {
                id = { [61847] = true, [34074] = true, [5118] = true }, -- 龙鹰、蝰蛇、猎豹守护
                displayID = 61847,                                      -- 龙鹰守护
                ignoreExpiration = true,
            },
            PRIEST = {
                id = { [48168] = true },
                displayID = 48168, -- 心灵之火
                ignoreExpiration = true,
            },
        }
        local paladinPersonalBuffRule = {
            id = { [25780] = true },
            displayID = 25780, -- 正义之怒
            ignoreExpiration = true,
        }
        OpenMonitorMenu = function(anchor)
            local filterMenu = {}
            for _, row in ipairs(rows) do
                local filterRow = row
                tinsert(filterMenu, {
                    text = AddTexture(filterRow.icon:GetTexture()) .. filterRow.name,
                    checked = function()
                        return IsMonitorRowEnabled(filterRow)
                    end,
                    isNotRadio = true,
                    keepShownOnClick = true,
                    func = function(button, _, _, checked)
                        if not checked then
                            local enabledCount = 0
                            for _, otherRow in ipairs(rows) do
                                if IsMonitorRowEnabled(otherRow) then
                                    enabledCount = enabledCount + 1
                                end
                            end
                            if enabledCount <= 5 then
                                UIErrorsFrame:AddMessage(L["至少需要保留5种BUFF监控"], 1, 0, 0)
                                button.checked = true
                                _G[button:GetName() .. "Check"]:Show()
                                _G[button:GetName() .. "UnCheck"]:Hide()
                                return
                            end
                            monitorSaved.filters[filterRow.monitorKey] = 0
                        else
                            monitorSaved.filters[filterRow.monitorKey] = nil
                        end
                        UpdateMonitorLayout()
                        UpdateMonitor()
                    end,
                })
            end
            local frameStrataMenu = {}
            for _, option in ipairs(frameStrataOptions) do
                local strata = option.value
                tinsert(frameStrataMenu, {
                    text = option.text,
                    checked = function()
                        return monitorSaved.frameStrata == strata
                    end,
                    func = function()
                        monitorSaved.frameStrata = strata
                        monitorFrame:SetFrameStrata(strata)
                        LibBG:CloseDropDownMenus()
                    end,
                })
            end
            local frameScaleMenu = {}
            for _, percent in ipairs(frameScaleOptions) do
                local scale = percent / 100
                tinsert(frameScaleMenu, {
                    text = format(L["%s%%"], percent),
                    checked = function()
                        return monitorSaved.scale == scale
                    end,
                    func = function()
                        monitorSaved.scale = scale
                        monitorFrame:SetScale(scale)
                        LibBG:CloseDropDownMenus()
                    end,
                })
            end
            local menu = {
                {
                    text = L["团队BUFF常驻监控"],
                    isTitle = true,
                    notCheckable = true,
                },
                {
                    text = monitorSaved.lock == 1 and L["解锁界面"] or L["锁定界面"],
                    notCheckable = true,
                    func = function()
                        monitorSaved.lock = monitorSaved.lock == 1 and 0 or 1
                        LibBG:CloseDropDownMenus()
                    end,
                },
                {
                    text = L["隐藏界面"],
                    notCheckable = true,
                    func = function()
                        TJ.SetBuffMonitorShown(false)
                        LibBG:CloseDropDownMenus()
                    end,
                },
                TJ.CreateDropDownSeparator(),
                {
                    text = L["重置爆发药水记录"],
                    notCheckable = true,
                    func = function()
                        if TJ.ResetBurstPotionMonitor then
                            TJ.ResetBurstPotionMonitor()
                        end
                        LibBG:CloseDropDownMenus()
                    end,
                },
                {
                    text = L["BUFF过滤"],
                    hasArrow = true,
                    notCheckable = true,
                    menuList = filterMenu,
                },
                {
                    text = L["框架层级"],
                    hasArrow = true,
                    notCheckable = true,
                    menuList = frameStrataMenu,
                },
                {
                    text = L["界面缩放"],
                    hasArrow = true,
                    notCheckable = true,
                    menuList = frameScaleMenu,
                },

                TJ.CreateDropDownSeparator(),
                {
                    text = L["布局"],
                    isTitle = true,
                    notCheckable = true,
                },
                {
                    text = L["单列布局"],
                    checked = monitorSaved.layout == 1,
                    func = function()
                        monitorSaved.layout = 1
                        UpdateMonitorLayout()
                        LibBG:CloseDropDownMenus()
                    end,
                },
                {
                    text = L["双列布局"],
                    checked = monitorSaved.layout == 2,
                    func = function()
                        monitorSaved.layout = 2
                        UpdateMonitorLayout()
                        LibBG:CloseDropDownMenus()
                    end,
                },
                {
                    text = L["单行布局"],
                    checked = monitorSaved.layout == 3,
                    func = function()
                        monitorSaved.layout = 3
                        UpdateMonitorLayout()
                        LibBG:CloseDropDownMenus()
                    end,
                },

                TJ.CreateDropDownSeparator(),
                {
                    text = CANCEL,
                    notCheckable = true,
                    func = function()
                        LibBG:CloseDropDownMenus()
                    end,
                }
            }
            LibBG:EasyMenu(menu, TJ.dropDown, "cursor", 0, 0, "MENU", 2)
        end

        -- 主界面
        monitorFrame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
        do
            monitorFrame:SetSize(150, 28)
            monitorFrame:SetScale(monitorSaved.scale)
            monitorFrame:SetFrameStrata(monitorSaved.frameStrata)
            monitorFrame:SetClampedToScreen(true)
            monitorFrame:SetMovable(true)
            monitorFrame:EnableMouse(true)
            monitorFrame:SetBackdrop({
                bgFile = "Interface\\Buttons\\WHITE8x8",
                edgeFile = "Interface\\Buttons\\WHITE8x8",
                edgeSize = 1,
            })
            monitorFrame:SetFrameLevel(20)
            monitorFrame:SetToplevel(true)
            monitorFrame:SetBackdropColor(.02, .02, .02, .85)
            local r, g, b = ns.GetClassRGB(nil, "player")
            monitorFrame:SetBackdropBorderColor(r, g, b, TJ.borderAlpha)
            TJ.BuffMonitorFrame = monitorFrame

            local savedPoint = monitorSaved.point
            if savedPoint then
                monitorFrame:SetPoint(savedPoint.point or "CENTER", UIParent,
                    savedPoint.relativePoint or savedPoint.point or "CENTER", savedPoint.x or 0, savedPoint.y or 0)
            else
                monitorFrame:SetPoint("LEFT", UIParent, "LEFT", 0, 0)
            end

            StartMonitorMoving = function()
                LibBG.CloseDropDownMenus()
                monitorFrame.isMoving = true
                monitorFrame:StartMoving()
            end
            StopMonitorMoving = function()
                if not monitorFrame.isMoving then return end
                monitorFrame.isMoving = nil
                monitorFrame:StopMovingOrSizing()
                local point, _, relativePoint, x, y = monitorFrame:GetPoint(1)
                monitorSaved.point = { point = point, relativePoint = relativePoint, x = x, y = y }
            end

            monitorFrame:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" and (monitorSaved.lock ~= 1 or IsShiftKeyDown()) then
                    StartMonitorMoving()
                end
            end)
            monitorFrame:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" and self.isMoving then
                    StopMonitorMoving()
                elseif button == "RightButton" then
                    OpenMonitorMenu(self)
                end
            end)
            monitorFrame:SetScript("OnLeave", GameTooltip_Hide)

            title = monitorFrame:CreateFontString(nil, "OVERLAY")
            title:SetPoint("TOPLEFT", 7, -5)
            title:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            title:SetText(L["团队BUFF"])
            title:SetTextColor(1, .82, 0)
            title:SetWidth(title:GetStringWidth() + 10)
            title:SetWordWrap(false)
            title:SetJustifyH("LEFT")

            -- 批量密语
            broadcastButton = CreateFrame("Button", nil, monitorFrame)
            do
                broadcastButton:SetSize(20, 20)
                broadcastButton:SetPoint("TOPRIGHT", monitorFrame, "TOPRIGHT", -3, -2)
                broadcastButton:SetNormalTexture("Interface\\Common\\VoiceChat-Speaker")
                broadcastButton:SetPushedTexture("Interface\\Common\\VoiceChat-Speaker")
                broadcastButton:SetHighlightTexture("Interface\\Common\\VoiceChat-Speaker")
                broadcastButton:SetScript("OnClick", function()
                    if broadcastCD then
                        UIErrorsFrame:AddMessage(L["批量提醒正在冷却中"], 1, 0, 0)
                        return
                    end
                    local hasReminder
                    for _, row in ipairs(rows) do
                        local buffInfo = row.buffInfo
                        if IsMonitorRowEnabled(row) and not buffInfo.noBroadcast and row.missing and #row.missing > 0 then
                            hasReminder = true
                            SendMissingWhisper(row, true)
                        end
                    end
                    if hasReminder then
                        broadcastCD = true
                        After(CLICK_ALL_CD, function()
                            broadcastCD = nil
                        end)
                    end
                end)
                broadcastButton:SetScript("OnEnter", function(self)
                    if TJ.ButtonIsInRight(self) then
                        GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
                    else
                        GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
                    end
                    GameTooltip:AddLine(L["批量提醒"], 1, 1, 1)
                    GameTooltip:AddLine(L["密语提醒所有团队BUFF的负责人（不含食物）。"], 1, .82, 0, true)
                    local c = 0
                    for _, row in ipairs(rows) do
                        if IsMonitorRowEnabled(row) and not row.buffInfo.noBroadcast and row.missing and #row.missing > 0 then
                            local responsibility, responsibilityUnit = GetResponsibilityUnit(row.buffIndex)
                            if responsibility then
                                if c == 0 then
                                    GameTooltip:AddLine(' ')
                                end
                                local icon = AddTexture(row.icon:GetTexture())
                                local buffLink = row.buffLink or TJ.Buff[row.buffIndex].title.link or row.name
                                GameTooltip:AddLine(format(L["%s%s：%s"], icon, buffLink, ns.SetClassCFF(responsibility)), 1, .82, 0)
                                c = c + 1
                            end
                        end
                    end
                    GameTooltip:Show()
                end)
                broadcastButton:SetScript("OnLeave", GameTooltip_Hide)
            end
        end

        GetResponsibilityUnit = function(buffIndex)
            if not buffIndex then return end
            local edit = TJ.Buff[buffIndex].edit
            local responsibility = edit.player or TJ.ClearCode(edit:GetText())
            if not responsibility or responsibility == "" then return end
            local raidIndex = TJ.raidRosterName[responsibility]
            if not raidIndex then
                responsibility = TJ.GSN(responsibility)
                raidIndex = TJ.raidRosterName[responsibility]
            end
            if not raidIndex then return responsibility end
            return responsibility, "raid" .. raidIndex
        end

        local function GetMissingClassSuffix(row)
            if not row.buffInfo.Pally then return "" end
            local classAdded = {}
            local classNames = {}
            for _, missing in ipairs(row.missing) do
                local class = missing.class
                if class and not classAdded[class] then
                    classAdded[class] = true
                    tinsert(classNames, ns.GetClassName(class) or class)
                end
            end
            if #classNames == 0 then return "" end
            return format(L["（职业：%s）"], table.concat(classNames, L["、"]))
        end

        SendMissingWhisper = function(row, ignoreClickCD)
            if not IsInRaid(1) then return end
            if clickCD[row.buffIndex] and not ignoreClickCD then
                UIErrorsFrame:AddMessage(L["该BUFF提醒正在冷却中"], 1, 0, 0)
                return
            end
            if not row.missing or #row.missing == 0 then
                return
            end

            local responsibility, responsibilityUnit = GetResponsibilityUnit(row.buffIndex)
            if not responsibility then
                return
            elseif not responsibilityUnit then
                UIErrorsFrame:AddMessage(format(L["%s已不在团队中"], ns.SetClassCFF(responsibility)), 1, 0, 0)
                return
            elseif not UnitIsConnected(responsibilityUnit) then
                UIErrorsFrame:AddMessage(format(L["%s当前离线"], ns.SetClassCFF(responsibility)), 1, 0, 0)
                return
            end

            local buffLink = row.buffLink or TJ.Buff[row.buffIndex].title.link or row.name
            local message
            if #row.missing > 5 then
                message = format(L["有%s名玩家缺少%s"], #row.missing, buffLink)
            else
                local players = {}
                for _, missing in ipairs(row.missing) do
                    tinsert(players, missing.point .. missing.name)
                end
                message = format(L["有%s名玩家缺少%s：%s"], #row.missing, buffLink, table.concat(players, L["，"]))
            end
            message = message .. GetMissingClassSuffix(row)
            SendChatMessage(message, "WHISPER", nil, TJ.GFN(responsibility))
            clickCD[row.buffIndex] = true
            After(CLICK_CD, function()
                clickCD[row.buffIndex] = nil
            end)
        end
        local function SendMissingPlayersWhisper(row)
            if not IsInRaid(1) or not row.missing or #row.missing == 0 or #row.missing > 5 then return end
            if missingWhisperCD[row.buffInfo] then
                UIErrorsFrame:AddMessage(format(L["%s提醒正在冷却中"], row.name), 1, 0, 0)
                return
            end
            for _, missing in ipairs(row.missing) do
                local missingBuff = missing.expected and TJ.ClearCode(missing.expected, true) or row.name
                SendChatMessage(format(L["你缺少%s，请及时补充。"], missingBuff), "WHISPER", nil, TJ.GFN(missing.name))
            end
            missingWhisperCD[row.buffInfo] = true
            After(CLICK_CD, function()
                missingWhisperCD[row.buffInfo] = nil
            end)
        end

        local burstPotionOrder = { 28714, 53908, 53909, 53762, 1282971 }
        local function GetMonitorMemberRGB(member)
            if member.class then
                return GetClassColor(member.class)
            end
            return ns.GetClassRGB(member.name)
        end

        local function GetBurstPotionUsageText(used)
            local texts = {}
            local added = {}
            local function AddSpell(spellID)
                local count = used.potions[spellID]
                if not count then return end
                added[spellID] = true
                local c = C_Spell.GetSpellTexture(spellID)
                local icon = AddTexture(c)
                local spell = C_Spell.GetSpellLink(spellID) or GetSpellInfo(spellID) or spellID
                tinsert(texts, format(L["%s%s|cffffffff×%s|r"], icon, spell, count))
            end
            for _, spellID in ipairs(burstPotionOrder) do
                AddSpell(spellID)
            end
            for spellID in pairs(used.potions) do
                if not added[spellID] then
                    AddSpell(spellID)
                end
            end
            return table.concat(texts, L["，"])
        end

        local function AddMonitorMemberLine(member, suffix)
            local r, g, b = GetMonitorMemberRGB(member)
            GameTooltip:AddLine("    " .. member.point .. member.name .. (suffix or ""), r, g, b)
        end

        local function OnEnter(self)
            if TJ.ButtonIsInRight(self) then
                GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, 0)
            else
                GameTooltip:SetOwner(self, "ANCHOR_RIGHT", 0, 0)
            end
            GameTooltip:AddLine(AddTexture(self.icon:GetTexture()) .. self.name, 1, 1, 1)
            local show = false
            if self.buffInfo.countMode == "burstPotion" and self.isActive then
                if #self.used > 0 then
                    GameTooltip:AddLine(L["已使用："], .2, 1, .2)
                    for _, used in ipairs(self.used) do
                        AddMonitorMemberLine(used, L["："] .. GetBurstPotionUsageText(used))
                    end
                    show = true
                end
                if #self.missing > 0 then
                    if show then
                        GameTooltip:AddLine(" ")
                    end
                    GameTooltip:AddLine(self.buffInfo.missingTitle, 1, .2, .2)
                    for _, missing in ipairs(self.missing) do
                        AddMonitorMemberLine(missing)
                    end
                    show = true
                end
            elseif #self.missing > 0 then
                local missingTitle = self.buffInfo.missingTitle or
                    (self.buffInfo.ignoreExpiration and L["缺少："] or L["缺少（含不足%s分钟）："]:format(floor(EXPIRE_TIME / 60)))
                GameTooltip:AddLine(missingTitle, 1, .2, .2)
                for _, v in ipairs(self.missing) do
                    local text = '    ' .. v.point .. v.name
                    if v.expected and v.expected ~= "" then
                        text = text .. L["："] .. v.expected
                    end
                    local r, g, b = GetMonitorMemberRGB(v)
                    GameTooltip:AddLine(text, r, g, b)
                end
                show = true
            end
            if self.buffInfo.inactiveText and not self.isActive then
                GameTooltip:AddLine(self.buffInfo.inactiveText, .7, .7, .7)
                show = true
            end
            if self.buffInfo.whisperMissing and #self.missing > 0 then
                GameTooltip:AddLine(' ')
                if #self.missing <= 5 then
                    GameTooltip:AddLine(format(L["左键密语缺少%s的玩家"], self.name), 1, .82, 0)
                else
                    GameTooltip:AddLine(format(L["缺少%s的人数太多，无法密语。"], self.name), 1, .2, .2, true)
                end
            elseif not self.buffInfo.noWhisper then
                local responsibility, responsibilityUnit = GetResponsibilityUnit(self.buffIndex)
                if responsibility then
                    GameTooltip:AddLine(' ')
                    GameTooltip:AddLine(format(L["左键密语责任人：%s"], ns.SetClassCFF(responsibility)), 1, .82, 0)
                end
            end
            if show then
                GameTooltip:Show()
            end
        end

        local monitorEntries = {}
        for buffIndex, buffInfo in ipairs(buffTbl) do
            if buffInfo.monitor then
                tinsert(monitorEntries, { buffIndex = buffIndex, buffInfo = buffInfo })
            end
        end
        tinsert(monitorEntries, { buffInfo = flaskInfo })
        tinsert(monitorEntries, { buffInfo = personalBuffInfo })
        tinsert(monitorEntries, { buffInfo = focusMagicInfo })
        tinsert(monitorEntries, { buffInfo = burstPotionInfo })

        -- 条目
        for _, entry in ipairs(monitorEntries) do
            local buffIndex = entry.buffIndex
            local buffInfo = entry.buffInfo
            local row = CreateFrame("Frame", nil, monitorFrame)
            row:SetHeight(20)
            row:EnableMouse(true)
            row.buffIndex = buffIndex
            row.buffInfo = buffInfo
            row.monitorKey = tostring(buffInfo.monitorKey or buffInfo.displayID or buffInfo.monitorDisplayID)
            row.name = buffInfo.shortName or buffInfo.tipKey
            if buffInfo.monitorDisplayID then
                row.buffLink = C_Spell.GetSpellLink(buffInfo.monitorDisplayID)
            end
            row.missing = {}
            row.used = {}
            row.unknown = {}

            row.icon = row:CreateTexture(nil, "OVERLAY")
            row.icon:SetSize(row:GetHeight(), row:GetHeight())
            row.icon:SetPoint("LEFT", 1, 0)
            row.icon:SetTexCoord(unpack(TJ.iconTexCoord))
            local displayID = buffInfo.monitorDisplayID or buffInfo.displayID
            if buffInfo.auraID or not buffInfo.isItem then
                row.icon:SetTexture(C_Spell.GetSpellTexture(displayID))
            else
                row.icon:SetTexture(select(5, GetItemInfoInstant(displayID)))
            end

            row.bar = CreateFrame("StatusBar", nil, row)
            row.bar:SetPoint("LEFT", row.icon, "RIGHT", 0, 0)
            row.bar:SetPoint("RIGHT", row, "RIGHT", 0, 0)
            row.bar:SetHeight(row:GetHeight())
            row.bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
            row.bar:SetMinMaxValues(0, 1)
            row.bar:SetValue(0)

            row.bar.bg = row.bar:CreateTexture(nil, "BACKGROUND")
            row.bar.bg:SetAllPoints()
            row.bar.bg:SetColorTexture(.12, .12, .12, .8)

            row.highlight = row.bar:CreateTexture(nil, "OVERLAY")
            row.highlight:SetAllPoints()
            row.highlight:SetColorTexture(1, 1, 1, .12)
            row.highlight:Hide()

            row.label = row.bar:CreateFontString(nil, "OVERLAY")
            row.label:SetPoint("LEFT", row.icon, "RIGHT", 3, 0)
            row.label:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            row.label:SetJustifyH("LEFT")
            row.label:SetText(row.name)

            row.count = row.bar:CreateFontString(nil, "OVERLAY")
            row.count:SetPoint("RIGHT", row.bar, "RIGHT", -3, 0)
            row.count:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            row:SetScript("OnMouseDown", function(self, button)
                if button == "LeftButton" and IsShiftKeyDown() then
                    self.isDraggingMonitor = true
                    StartMonitorMoving()
                end
            end)
            row:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" then
                    if self.isDraggingMonitor then
                        self.isDraggingMonitor = nil
                        StopMonitorMoving()
                        return
                    end
                    if self.buffInfo.whisperMissing then
                        SendMissingPlayersWhisper(self)
                    elseif not self.buffInfo.noWhisper then
                        SendMissingWhisper(self)
                    end
                elseif button == "RightButton" then
                    OpenMonitorMenu(self)
                end
            end)
            row:SetScript("OnEnter", function(self)
                self.highlight:Show()
                OnEnter(self)
            end)
            row:SetScript("OnLeave", function(self)
                self.highlight:Hide()
                GameTooltip_Hide()
            end)
            tinsert(rows, row)
        end

        IsMonitorRowEnabled = function(row)
            return monitorSaved.filters[row.monitorKey] ~= 0
        end

        UpdateMonitorLayout = function()
            title:ClearAllPoints()
            broadcastButton:ClearAllPoints()
            local visibleRows = {}
            for _, row in ipairs(rows) do
                if IsMonitorRowEnabled(row) then
                    row:Show()
                    tinsert(visibleRows, row)
                else
                    row:Hide()
                end
            end
            if monitorSaved.layout == 3 then
                title:SetPoint("LEFT", monitorFrame, "LEFT", 7, 0)
                broadcastButton:SetPoint("LEFT", title, "RIGHT", 3, 0)
                local rowWidth = 100
                local rowGap = 2
                local previousRow
                for _, row in ipairs(visibleRows) do
                    row:ClearAllPoints()
                    if previousRow then
                        row:SetPoint("LEFT", previousRow, "RIGHT", rowGap, 0)
                    else
                        row:SetPoint("LEFT", broadcastButton, "RIGHT", 3, 0)
                    end
                    row:SetWidth(rowWidth)
                    previousRow = row
                end
                local titleWidth = max(55, title:GetWidth())
                local frameWidth = 5 + titleWidth + 3 + broadcastButton:GetWidth() + 3 +
                    #visibleRows * rowWidth + max(0, #visibleRows - 1) * rowGap + 5
                monitorFrame:SetSize(frameWidth, 24)
                return
            end

            title:SetPoint("TOPLEFT", monitorFrame, "TOPLEFT", 7, -5)
            broadcastButton:SetPoint("TOPRIGHT", monitorFrame, "TOPRIGHT", -3, -2)
            local columns = monitorSaved.layout == 2 and 2 or 1
            local frameWidth = columns == 2 and 240 or 150
            local columnGap = 2
            local columnWidth = (frameWidth - 10 - columnGap * (columns - 1)) / columns
            for index, row in ipairs(visibleRows) do
                local column = (index - 1) % columns
                local line = floor((index - 1) / columns)
                row:ClearAllPoints()
                row:SetPoint("TOPLEFT", monitorFrame, "TOPLEFT",
                    5 + column * (columnWidth + columnGap), -25 - line * 22)
                row:SetWidth(columnWidth)
            end
            local lineCount = floor((#visibleRows + columns - 1) / columns)
            monitorFrame:SetSize(frameWidth, 30 + lineCount * 22 - 2)
        end
        UpdateMonitorLayout()

        local manaClass = {
            PALADIN = true,
            HUNTER = true,
            PRIEST = true,
            SHAMAN = true,
            MAGE = true,
            WARLOCK = true,
            DRUID = true,
        }
        local petClassByOwnerClass = {
            DEATHKNIGHT = "ROGUE",
            HUNTER = "WARRIOR",
            WARLOCK = "PALADIN",
        }
        local FELGUARD_NPC_ID = 17252
        local function ShouldCountMember(buffInfo, rosterInfo)
            local filter = buffInfo.monitorFilter
            if not filter then return true end
            if not rosterInfo then return false end
            if filter == "physical" then
                return TJ.Istank(rosterInfo) or TJ.Isdps1(rosterInfo) or rosterInfo.class == "HUNTER"
            elseif filter == "wisdom" then
                if rosterInfo.class == "DEATHKNIGHT" or rosterInfo.class == "WARRIOR" or
                    rosterInfo.class == "ROGUE" then
                    return false
                elseif rosterInfo.class == "DRUID" then
                    local talent = rosterInfo.talent or TuanJian.talentInfo[rosterInfo.name]
                    if talent then
                        return talent ~= 2
                    end
                    return not (TJ.Istank(rosterInfo) or TJ.Isdps1(rosterInfo))
                end
                return true
            elseif filter == "caster" then
                return TJ.Ishealer(rosterInfo) or
                    (rosterInfo.class ~= "HUNTER" and TJ.Isdps2(rosterInfo))
            elseif filter == "mana" then
                return manaClass[rosterInfo.class] == true
            end
            return true
        end

        local auraInfoBySpellID = {}
        local auraInfoByName = {}
        local registeredAuraInfo = {}
        local function RegisterAuraInfo(buffInfo)
            if not buffInfo or registeredAuraInfo[buffInfo] then return end
            registeredAuraInfo[buffInfo] = true
            if buffInfo.auraName then
                auraInfoByName[buffInfo.auraName] = auraInfoByName[buffInfo.auraName] or {}
                tinsert(auraInfoByName[buffInfo.auraName], buffInfo)
                return
            end
            for spellID in pairs(buffInfo.auraID or buffInfo.id or {}) do
                auraInfoBySpellID[spellID] = auraInfoBySpellID[spellID] or {}
                tinsert(auraInfoBySpellID[spellID], buffInfo)
            end
        end
        for _, row in ipairs(rows) do
            RegisterAuraInfo(row.buffInfo)
        end
        for _, rule in pairs(personalBuffRules) do
            RegisterAuraInfo(rule)
        end
        RegisterAuraInfo(paladinPersonalBuffRule)

        local function ScanUnitAuras(unit, focusMagicCasters)
            local matchedAuraInfo = {}
            local now = GetTime()
            for auraIndex = 1, 60 do
                local auraName, _, _, _, duration, expirationTime, source, _, _, spellID = UnitBuff(unit, auraIndex)
                if not auraName then break end
                if focusMagicCasters and spellID == focusMagicInfo.monitorDisplayID and source then
                    local sourceGUID = UnitGUID(source)
                    if sourceGUID then
                        focusMagicCasters[sourceGUID] = true
                    end
                end
                local valid = not duration or duration == 0 or not expirationTime or expirationTime == 0 or
                    expirationTime - now >= EXPIRE_TIME
                local infos = auraInfoByName[auraName]
                if infos then
                    for _, buffInfo in ipairs(infos) do
                        if valid or buffInfo.ignoreExpiration then
                            matchedAuraInfo[buffInfo] = true
                        end
                    end
                end
                if spellID then
                    infos = auraInfoBySpellID[spellID]
                    if infos then
                        for _, buffInfo in ipairs(infos) do
                            if valid or buffInfo.ignoreExpiration then
                                matchedAuraInfo[buffInfo] = true
                            end
                        end
                    end
                end
            end
            return matchedAuraInfo
        end

        local function GetAuraState(auraState, buffInfo)
            return auraState[buffInfo] == true
        end

        local function GetPersonalBuffRule(rosterInfo)
            if not rosterInfo then return end
            if rosterInfo.class == "PALADIN" then
                return TJ.Istank(rosterInfo) and paladinPersonalBuffRule or nil
            end
            return personalBuffRules[rosterInfo.class]
        end

        local function GetPersonalBuffText(rule)
            if rule.expectedText then return rule.expectedText end
            local function GetIconAndLink(spellID)
                local o = C_Spell.GetSpellTexture(spellID)
                local icon = AddTexture(o)
                local link = C_Spell.GetSpellLink(spellID) or GetSpellInfo(spellID) or ""
                return icon .. link
            end
            if rule.displayID then
                return GetIconAndLink(rule.displayID)
            end
            local texts = {}
            for _, spellID in ipairs(rule.displayIDs or {}) do
                tinsert(texts, GetIconAndLink(spellID))
            end
            return table.concat(texts, "/")
        end

        UpdateMonitor = function()
            if monitorSaved.show ~= 1 or not IsInRaid(1) then
                monitorFrame:Hide()
                return
            end
            monitorFrame:Show()
            local raidPoint = TJ.GetRaidPoint()
            local members = {}
            local petMembers = {}
            local burstPotionMembers = {}
            local auraStateByRaidIndex = {}
            local focusMagicCasters = {}
            for raidIndex = 1, GetNumGroupMembers() do
                local unit = "raid" .. raidIndex
                if UnitExists(unit) and UnitIsConnected(unit) then
                    auraStateByRaidIndex[raidIndex] = ScanUnitAuras(unit, focusMagicCasters)
                    if not GetPartyAssignment("MAINASSIST", unit) then
                        local name = TJ.GSN(UnitName(unit))
                        local pointText = raidPoint[name] or "?-"
                        local subgroup, subgroupIndex = strmatch(pointText, "^(%d+)%-(%d+)$")
                        tinsert(burstPotionMembers, {
                            guid = UnitGUID(unit),
                            name = name,
                            point = pointText .. " ",
                            class = select(2, UnitClass(unit)),
                            sortIndex = subgroup and tonumber(subgroup) * 10 + tonumber(subgroupIndex) or 999,
                        })
                    end
                end
            end
            for raidIndex = 1, GetNumGroupMembers() do
                local unit = "raid" .. raidIndex
                if UnitExists(unit) and UnitIsConnected(unit) and not UnitIsDeadOrGhost(unit) and
                    not GetPartyAssignment("MAINASSIST", unit) then
                    local name = TJ.GSN(UnitName(unit))
                    local rosterInfo = TJ.raidRosterInfo[raidIndex]
                    local pointText = raidPoint[name] or "?-"
                    local subgroup, subgroupIndex = strmatch(pointText, "^(%d+)%-(%d+)$")
                    local sortIndex = subgroup and tonumber(subgroup) * 10 + tonumber(subgroupIndex) or 999
                    local point = pointText .. " "
                    tinsert(members, {
                        rosterInfo = rosterInfo,
                        guid = UnitGUID(unit),
                        name = name,
                        point = point,
                        auraState = auraStateByRaidIndex[raidIndex],
                        class = rosterInfo and rosterInfo.class or select(2, UnitClass(unit)),
                        sortIndex = sortIndex,
                    })
                    local petClass = rosterInfo and petClassByOwnerClass[rosterInfo.class]
                    local petUnit = "raidpet" .. raidIndex
                    local isValidPet = petClass and UnitExists(petUnit) and not UnitIsDeadOrGhost(petUnit)
                    if isValidPet and rosterInfo.class == "WARLOCK" then
                        isValidPet = TJ.GetNPCID(UnitGUID(petUnit)) == FELGUARD_NPC_ID
                    end
                    if isValidPet then
                        local petName = TJ.GSN(UnitName(petUnit))
                        if petName then
                            tinsert(petMembers, {
                                rosterInfo = {
                                    name = petName,
                                    class = petClass,
                                    combatRole = "DAMAGER",
                                },
                                name = petName,
                                displayName = format(L["宠物:%s(%s)"], petName, name),
                                point = "",
                                auraState = ScanUnitAuras(petUnit),
                                isPet = true,
                                class = petClass,
                                sortIndex = sortIndex,
                            })
                        end
                    end
                end
            end
            table.sort(members, function(a, b)
                return a.sortIndex < b.sortIndex
            end)
            table.sort(burstPotionMembers, function(a, b)
                return a.sortIndex < b.sortIndex
            end)
            table.sort(petMembers, function(a, b)
                return a.sortIndex < b.sortIndex
            end)
            for _, member in ipairs(petMembers) do
                tinsert(members, member)
            end
            for _, row in ipairs(rows) do
                wipe(row.missing)
                wipe(row.used)
                wipe(row.unknown)
                row.has = nil
                row.total = nil
                if IsMonitorRowEnabled(row) then
                    local buffInfo = row.buffInfo
                    row.isActive = nil
                    if buffInfo.countMode == "burstPotion" and not burstPotionActive then
                        local total = #burstPotionMembers
                        row.has = 0
                        row.total = total
                        row.count:SetText("0/" .. total)
                        row.bar:SetMinMaxValues(0, max(1, total))
                        row.bar:SetValue(0)
                        row.bar:SetStatusBarColor(.35, .35, .35, .6)
                        row.count:SetTextColor(.5, .5, .5)
                    else
                        row.isActive = true
                        local has, total = 0, 0
                        if buffInfo.countMode == "burstPotion" then
                            for _, member in ipairs(burstPotionMembers) do
                                total = total + 1
                                local potions = burstPotionUsed[member.guid]
                                if potions then
                                    has = has + 1
                                    tinsert(row.used, {
                                        name = member.name,
                                        point = member.point,
                                        class = member.class,
                                        potions = potions,
                                    })
                                else
                                    tinsert(row.missing, {
                                        name = member.name,
                                        point = member.point,
                                        class = member.class,
                                    })
                                end
                            end
                        else
                            for _, member in ipairs(members) do
                                local rosterInfo = member.rosterInfo
                                if member.isPet and not buffInfo.monitorPet then
                                    -- 宠物只参与力量、王者、耐力和爪子监控。
                                elseif buffInfo.countMode == "casterClass" then
                                    if rosterInfo and rosterInfo.class == buffInfo.casterClass then
                                        total = total + 1
                                        if member.guid and focusMagicCasters[member.guid] then
                                            has = has + 1
                                        else
                                            tinsert(row.missing, {
                                                name = member.name,
                                                point = member.point,
                                                class = member.class,
                                            })
                                        end
                                    end
                                elseif buffInfo.countMode == "personalBuff" then
                                    local rule = GetPersonalBuffRule(rosterInfo)
                                    if rule then
                                        total = total + 1
                                        if GetAuraState(member.auraState, rule) then
                                            has = has + 1
                                        else
                                            tinsert(row.missing, {
                                                name = member.name,
                                                point = member.point,
                                                expected = GetPersonalBuffText(rule),
                                                class = member.class,
                                            })
                                        end
                                    end
                                elseif ShouldCountMember(buffInfo, rosterInfo) then
                                    total = total + 1
                                    if GetAuraState(member.auraState, buffInfo) then
                                        has = has + 1
                                    else
                                        tinsert(row.missing, {
                                            name = member.displayName or member.name,
                                            point = member.point,
                                            class = member.class,
                                        })
                                    end
                                end
                            end
                        end
                        row.has = has
                        row.total = total
                        row.count:SetText(has .. "/" .. total)
                        if total == 0 then
                            row.bar:SetMinMaxValues(0, 1)
                            row.bar:SetValue(0)
                            row.bar:SetStatusBarColor(.35, .35, .35, .6)
                            row.count:SetTextColor(.5, .5, .5)
                        elseif has >= total then
                            row.bar:SetMinMaxValues(0, 1)
                            row.bar:SetValue(1)
                            row.bar:SetStatusBarColor(0, 1, 0, .6)
                            row.count:SetTextColor(1, 1, 1)
                        else
                            row.bar:SetMinMaxValues(0, total)
                            row.bar:SetValue(has)
                            row.bar:SetStatusBarColor(1, 1, 0, .6)
                            row.count:SetTextColor(1, 1, 1)
                        end
                    end
                end
            end
        end

        function TJ.SetBuffMonitorShown(shown)
            monitorSaved.show = shown and 1 or 0
            if TJ.BuffMonitorToggleButton then
                TJ.BuffMonitorToggleButton:Update()
            end
            UpdateMonitor()
        end

        local function CancelBurstPotionMonitorReset()
            burstPotionResetGeneration = burstPotionResetGeneration + 1
            burstPotionResetPending = nil
        end

        local function ClearBurstPotionMonitor()
            wipe(burstPotionUsed)
            burstPotionActive = nil
            UpdateMonitor()
        end

        function TJ.StartBurstPotionMonitor()
            if burstPotionResetPending then
                CancelBurstPotionMonitorReset()
                wipe(burstPotionUsed)
            end
            burstPotionActive = true
            UpdateMonitor()
        end

        function TJ.ResetBurstPotionMonitor()
            CancelBurstPotionMonitorReset()
            ClearBurstPotionMonitor()
        end

        function TJ.ScheduleBurstPotionMonitorReset()
            burstPotionResetGeneration = burstPotionResetGeneration + 1
            local generation = burstPotionResetGeneration
            burstPotionResetPending = true
            After(BURST_POTION_RESET_DELAY, function()
                if not burstPotionResetPending or burstPotionResetGeneration ~= generation then return end
                burstPotionResetPending = nil
                ClearBurstPotionMonitor()
            end)
        end

        TJ.RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", function(self, event, ...)
            if not IsInRaid(1) then return end
            local _, subevent, _, _, _, _, _, destGUID, _, _, _, spellID = ...
            if (subevent ~= "SPELL_AURA_APPLIED" and subevent ~= "SPELL_AURA_REFRESH") or
                not burstPotionInfo.auraID[spellID] or not TJ.raidRosterGUID[destGUID] then
                return
            end
            if burstPotionResetPending then
                CancelBurstPotionMonitorReset()
                wipe(burstPotionUsed)
            end
            burstPotionUsed[destGUID] = burstPotionUsed[destGUID] or {}
            local potions = burstPotionUsed[destGUID]
            potions[spellID] = (potions[spellID] or 0) + 1
            burstPotionActive = true
            UpdateMonitor()
        end)

        UpdateMonitor()
        C_Timer.NewTicker(1, UpdateMonitor)
    end
end)
--[[
C_ChatInfo.SendAddonMessage("PLPWR", "PASSIGN 苍骑士@2211111111", "RAID")
 ]]
