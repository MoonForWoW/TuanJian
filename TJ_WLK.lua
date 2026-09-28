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
    local mainFrame = TJ.tjMainFrame
    local FB = "TJ"
    local bossIndex = 1
    TJ[FB] = {}
    TJ.frame[FB] = {}
    TJ.frame[FB][bossIndex] = mainFrame
    TuanJian[FB] = TuanJian[FB] or {}
    TuanJian[FB][bossIndex] = TuanJian[FB][bossIndex] or {}

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

    if not TJ.verLess3 then return end


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


end)

