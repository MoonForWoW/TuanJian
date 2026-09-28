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

local logo = AddonName .. ': '

TJ.Init(function()
    if not TJ.IsMOP then return end
    local mainFrame = TJ.dpsMainFrame
    local FB = "DPS"
    local bossIndex = 1
    TJ[FB] = {}
    TJ.frame[FB] = {}
    TJ.frame[FB][bossIndex] = mainFrame
    TuanJian[FB] = TuanJian[FB] or {}
    TuanJian[FB][bossIndex] = TuanJian[FB][bossIndex] or {}
    -- 风暴之鞭
    do
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
        local text = L["优先安排奶萨，其次元素/增强萨。"]
        local f = TJ.CreateTitle("DPS", 1, AutoFuc, "ability_shaman_tranquilmindtotem", L["风暴之鞭"],
            text, { "SHAMAN" }, nil, nil, nil,
            nil, 4)
        f:ClearAllPoints()
        f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 20, -50)
        TJ.CreateEdit(FB, bossIndex, L["1风暴"])
        TJ.CreateEdit(FB, bossIndex, L["2风暴"])
        TJ.CreateEdit(FB, bossIndex, L["3风暴"])
        TJ.CreateEdit(FB, bossIndex, L["4风暴"])
        TJ.CreateEdit(FB, bossIndex, L["5风暴"])
        TJ.CreateEdit(FB, bossIndex, L["6风暴"])
        TJ.CreateEdit(FB, bossIndex, L["7风暴"])
        TJ.CreateEdit(FB, bossIndex, L["8风暴"])
    end
    -- 颅骨战旗
    do
        local function AutoFuc(title)
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "tank", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
            local tbl = TJ.SortRaidRosterInfo(title.classTbl, "dps", true)
            for i, v in ipairs(tbl) do
                TJ.SetEditText(v, title)
            end
        end
        local text = L["优先安排防战，其次武器/狂暴战。"]
        local f = TJ.CreateTitle("DPS", 1, AutoFuc, "warrior_skullbanner", L["颅骨战旗"],
            text, { "WARRIOR" }, nil, nil, nil,
            nil, 4)
        TJ.CreateEdit(FB, bossIndex, L["1颅骨"])
        TJ.CreateEdit(FB, bossIndex, L["2颅骨"])
        TJ.CreateEdit(FB, bossIndex, L["3颅骨"])
        TJ.CreateEdit(FB, bossIndex, L["4颅骨"])
        TJ.CreateEdit(FB, bossIndex, L["5颅骨"])
        TJ.CreateEdit(FB, bossIndex, L["6颅骨"])
        TJ.CreateEdit(FB, bossIndex, L["7颅骨"])
        TJ.CreateEdit(FB, bossIndex, L["8颅骨"])
    end

    local bt = CreateFrame("CheckButton", nil, mainFrame, "ChatConfigCheckButtonTemplate")
    bt:SetSize(30, 30)
    bt:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 80, -210)
    bt.Text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
    bt.Text:SetText(L["英勇/嗜血时自动开始密语（需要你是团长或助理）"])
    bt:SetHitRectInsets(0, -bt.Text:GetWidth(), 0, 0)
    bt:SetChecked(TuanJian.MOPdpstips == 1)
    bt:SetScript("OnClick", function(self)
        TuanJian.MOPdpstips = self:GetChecked() and 1 or 0
    end)

    local t = mainFrame:CreateFontString()
    t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
    t:SetPoint("TOPLEFT", TJ.MainFrame, "TOPLEFT", 80, -270)
    t:SetJustifyH("LEFT")
    t:SetTextColor(1, .82, 0)
    t:SetText(L[
    [[
自动密语提醒相应团员使用风暴之鞭/颅骨战旗：

默认情况：每当施放英勇/嗜血，就会自动激活密语。
你也可以手动激活密语，使用宏命令 |cff00ff00/tjdps|r

第0秒密语提醒第1个责任人
第10秒密语提醒第2个责任人
第20秒密语提醒第3个责任人
第30秒密语提醒第4个责任人
以此类推...
    ]]
    ])
    t:SetWidth(400)

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
            TJ.ClearDPS()
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置"], 1, 1, 1, true)
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    function TJ.ClearDPS()
        for _, v in ipairs(TJ.frame[FB][bossIndex].all) do
            for _, vv in ipairs(v.edits) do
                vv.edit:ClearAll()
            end
        end
    end

    -- 自动密语提醒
    do
        local auraTbl = {
            32182, -- 英勇
            2825,  -- 嗜血
            80353, -- 时间扭曲
            -- 18499, 6673,
        }
        local links = {}
        for i, s in ipairs({ 120668, 114207 }) do -- 风暴之鞭，颅骨战旗
            local i = i
            TJ.OnSpellLoad(s, function()
                links[i] = C_Spell.GetSpellLink(s)
            end)
        end

        local function Send(playerIndex)
            for spellIndex = 1, 2 do
                local player = TJ.ClearCode(mainFrame.all[spellIndex].edits[playerIndex].edit:GetText())
                if player ~= "" and UnitInRaid(player) then
                    local fullName = TJ.GFN(player)
                    if playerIndex == 1 then
                        SendChatMessage(format(L["提醒: 你需立刻施放%s"], links[spellIndex]), "WHISPER", nil,
                            fullName)
                    else
                        SendChatMessage(format(L["提醒: %s秒后你需施放%s"], 5, links[spellIndex]), "WHISPER", nil,
                            fullName)
                        After(4, function()
                            SendChatMessage(format(L["提醒: %s秒后你需施放%s"], 1, links[spellIndex]), "WHISPER", nil,
                                fullName)
                        end)
                    end
                end
            end
        end
        local function EditHasPlayer()
            for i, v in ipairs(mainFrame.all) do
                local edits = v.edits
                for i, vv in ipairs(edits) do
                    local edit = vv.edit
                    if edit:GetText() ~= "" then
                        return true
                    end
                end
            end
        end
        local f = CreateFrame("Frame")
        local times = {
            0, 5, 15, 25, 35, 45,
        }

        function TJ.StartSendDPSTips()
            f:SetScript("OnUpdate", nil)
            if not IsInRaid(1) then
                ns.SendSystemMessage(L["需要在团队里才能使用增伤提醒功能。"])
                return
            end
            if not TJ.IsLeader() then
                ns.SendSystemMessage(L["需要团长或助理才能使用增伤提醒功能。"])
                return
            end
            if not EditHasPlayer() then
                ns.SendSystemMessage(L["尚未设置增伤链，无法使用。"])
                return
            end
            ns.SendSystemMessage(L["开始密语提醒增伤责任人。"])
            f.t = 0
            f.send = {}
            f:SetScript("OnUpdate", function(self, t)
                self.t = self.t + t
                for index = #times, 1, -1 do
                    local t = times[index]
                    if self.t >= t and not self.send[index] then
                        self.send[index] = true
                        Send(index)
                        if index >= #times then
                            self:SetScript("OnUpdate", nil)
                        end
                        return
                    end
                end
            end)
        end

        TJ.RegisterEvent("UNIT_AURA", function(_, _, unit, info)
            if TuanJian.MOPdpstips == 1 and unit == "player" and IsInRaid(1) and TJ.IsLeader()
                and not info.isFullUpdate then
                if info.addedAuras then
                    for _, v in pairs(info.addedAuras) do
                        for _, spellID in ipairs(auraTbl) do
                            if v.spellId == spellID then
                                if EditHasPlayer() then
                                    TJ.StartSendDPSTips()
                                end
                                return
                            end
                        end
                    end
                end
            end
        end)
        TJ.RegisterEvent("ENCOUNTER_END", function()
            f:SetScript("OnUpdate", nil)
        end)
    end
end)
