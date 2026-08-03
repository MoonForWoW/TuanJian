local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L
local RGB = ns.RGB

local AddTexture = ns.AddTexture
local After = C_Timer.After
local player = UnitName("player")
local realmID = GetRealmID()

local pt = print
local r, g, b = GetClassColor(select(2, UnitClass("player")))
local BG = TJ

-- 1  "神圣抗性"
-- 2  "火焰抗性"
-- 3  "自然抗性"
-- 4  "冰霜抗性"
-- 5  "暗影抗性"
-- 6  "奥术抗性"
TJ.resistanceInfo = {}

local resistanceColor = {
    "ffff66",
    "ff3300",
    "339933",
    "1D93E2",
    "660099",
    "6666ff",
}

local function GetResistanceByItem(link)
    TJ.Tooltip_SetItemByLink(link)
    local tbl = { 0, 0, 0, 0, 0, 0, }
    for ii = 1, TuanJianTooltip:NumLines() do
        local text = _G["TuanJianTooltipTextLeft" .. ii]:GetText()
        if text and text ~= "" then
            if not text:find(WARDROBE_SETS) then
                for i = 1, 6 do
                    local key = "%+(%d+) " .. _G[format("RESISTANCE%s_NAME", i)]
                    local num = text:match(key)
                    if num then
                        tbl[i] = tbl[i] + tonumber(num)
                    end
                end
            end
        end
    end
    return tbl
end

function TJ.GetResistance(name)
    local tbl = { 0, 0, 0, 0, 0, 0, }
    local yes
    if TuanJian.itemInfo[name] then
        for slot, v in pairs(TuanJian.itemInfo[name]) do
            local link=v.link
            yes = true
            local r1, r2, r3, r4, r5, r6 = unpack(GetResistanceByItem(link))
            tbl[1] = tbl[1] + r1
            tbl[2] = tbl[2] + r2
            tbl[3] = tbl[3] + r3
            tbl[4] = tbl[4] + r4
            tbl[5] = tbl[5] + r5
            tbl[6] = tbl[6] + r6
        end
    end
    return yes and tbl
end

function TJ.UpdateRaidMemberFrame(name)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local parent = TJ.frame[FB][bossIndex]
    local raidFrame = parent.raidMemberFrame
    if raidFrame and raidFrame:IsVisible() then
        raidFrame:UpdateFrame(name)
    end
end

function TJ.CreateResistanceFrame(FB, bossIndex, icon, titleString, resistanceID, point)
    TJ.CreateTitle(FB, bossIndex, nil, icon, titleString)

    local parent = TJ.frame[FB][bossIndex]
    local all = parent.all
    local index = #all
    local title = all[index].title
    local bt = TJ.CreateButton(title)
    do
        bt:SetSize(100, 25)
        bt:SetPoint("LEFT", title, "RIGHT", 10, 0)
        parent.raidMemberButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if parent.raidMemberFrame:IsVisible() then
                parent.raidMemberFrame:Hide()
                TuanJian.options.showRaidMemberFrame = 0
            else
                parent.raidMemberFrame:Show()
                TuanJian.options.showRaidMemberFrame = 1
            end
        end)
        function bt:Update()
            if parent.raidMemberFrame:IsVisible() then
                bt:SetText(L["关闭界面"])
            else
                bt:SetText(L["打开界面"])
            end
        end
    end

    local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    do
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetBackdropBorderColor(0, 0, 0, 1)
        f:SetSize(405, 400)
        f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 1)
        if not point or point == "RIGHT" then
            f:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT", 1, 0)
            f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 4, 4)
        else
            f:SetPoint("TOPRIGHT", TJ.MainFrame, "TOPLEFT", -1, 0)
            f.CloseButton:SetPoint("TOPLEFT", f, "TOPLEFT", -3, 4)
        end
        f:EnableMouse(true)
        f.buttons = {}
        parent.raidMemberFrame = f
        f:SetScript("OnMouseDown", function(self)
            if TJ.lastfocus then
                TJ.lastfocus:ClearFocus()
            end
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
            TJ.MainFrame:StartMoving()
        end)
        f:SetScript("OnMouseUp", function(self)
            TJ.MainFrame:StopMovingOrSizing()
        end)

        local text = f:CreateFontString()
        text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        text:SetPoint("TOP", f, "TOP", 0, -5)
        f.title = text

        f.CloseButton:HookScript("OnClick", function()
            TuanJian.options.showRaidMemberFrame = 0
        end)
    end

    function f:CreateRaidButton(i)
        local f = CreateFrame("Frame", nil, self, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, .2)
        f:SetBackdropBorderColor(1, 1, 1, .2)
        f:SetSize(90, 30)
        if i == 1 then
            f:SetPoint("TOPLEFT", 15, -45)

            local text = f:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            text:SetPoint("BOTTOM", f, "TOP", 0, 2)
            text:SetText(1)
            text:SetTextColor(.5, .5, .5)
        elseif i == 21 then
            f:SetPoint("TOPLEFT", self.buttons[5], "BOTTOMLEFT", 0, -30)

            local text = f:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            text:SetPoint("BOTTOM", f, "TOP", 0, 2)
            text:SetText((i - 1) / 5 + 1)
            text:SetTextColor(.5, .5, .5)
        elseif (i - 1) % 5 == 0 then
            f:SetPoint("TOPLEFT", self.buttons[i - 5], "TOPRIGHT", 5, 0)

            local text = f:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
            text:SetPoint("BOTTOM", f, "TOP", 0, 2)
            text:SetText((i - 1) / 5 + 1)
            text:SetTextColor(.5, .5, .5)
        else
            f:SetPoint("TOPLEFT", self.buttons[i - 1], "BOTTOMLEFT", 0, -1)
        end
        f.index = i
        tinsert(self.buttons, f)

        local tex = f:CreateTexture(nil, "OVERLAY")
        tex:SetPoint("CENTER", f, "TOPLEFT", 2, -2)
        tex:SetSize(10, 10)
        f.icon = tex

        local tex = f:CreateTexture()
        tex:SetPoint("TOPLEFT", 2, -1)
        tex:SetSize(14, 14)
        f.talent = tex

        local text = f:CreateFontString()
        text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        text:SetPoint("LEFT", f.talent, "RIGHT", 0, 0)
        text:SetWidth(f:GetWidth() - f.talent:GetWidth() - 5)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(false)
        f.nameText = text

        local text = f:CreateFontString()
        text:SetFont(BIAOGE_TEXT_FONT, 13, "OUTLINE")
        text:SetPoint("BOTTOMLEFT", 2, 2)
        text:SetWidth(f:GetWidth() - 5)
        text:SetJustifyH("LEFT")
        text:SetWordWrap(false)
        text:SetTextColor(ns.RGB(resistanceColor[resistanceID] or "ffffff"))
        f.infoText = text

        function f:Reset()
            self.name = nil
            self.nameText:SetText("")
            self.infoText:SetText("")
            self.icon:SetTexture(nil)
            self.talent:SetTexture(nil)
            self.talent:SetAtlas(nil)
            self.talent:SetTexCoord(0, 1, 0, 1)
        end

        function f:Update(raidIndex)
            local v = TJ.raidRosterInfo[raidIndex]
            if not v then return end
            local name = v.name
            local color = "ffFFFFFF"
            if v.class then
                color = select(4, GetClassColor(v.class))
            end
            self.name = name
            self.nameText:SetText("|c" .. color .. name)
            if v.rank == 2 then
                self.icon:SetTexture("interface/groupframe/ui-group-leadericon")
            elseif v.role == "MAINTANK" then
                self.icon:SetTexture(132064)
            elseif v.role == "MAINASSIST" then
                self.icon:SetTexture(132063)
            elseif v.rank == 1 then
                self.icon:SetTexture("interface/groupframe/ui-group-assistanticon")
            end

            local talent = TuanJian.talentInfo[name]
            if talent then
                self.talent:SetTexture(TJ.talentIcon[v.class][talent])
                self.talent:SetTexCoord(unpack(TJ.iconTexCoord))
            else
                if v.combatRole == "TANK" then
                    self.talent:SetAtlas("ui-lfg-roleicon-tank")
                elseif v.combatRole == "HEALER" then
                    self.talent:SetAtlas("ui-lfg-roleicon-healer")
                elseif v.combatRole == "DAMAGER" then
                    self.talent:SetAtlas("ui-lfg-roleicon-dps")
                end
            end
            self:UpdateResistance()
        end

        function f:UpdateResistance()
            local name = self.name
            if name then
                local resistance = TJ.GetResistance(name)
                if resistance then
                    local text = resistance[resistanceID]
                    if text == 0 then
                        text = "|cff808080" .. text
                    end
                    self.infoText:SetText(format(L["%s"], text))
                else
                    self.infoText:SetText(format(L["|cff808080%s"], (L["距离太远"])))
                end
            end
        end
    end

    for i = 1, 40 do
        f:CreateRaidButton(i)
    end

    function f:UpdateFrame(name)
        if not self:IsVisible() then return end
        if name then
            for _, bt in ipairs(self.buttons) do
                if bt.name == name then
                    bt:UpdateResistance()
                end
            end
        else
            if IsInRaid(1) then
                f.title:SetText(titleString .. format(L["|cff808080（%s更新天赋按钮刷新数据）"], AddTexture("LEFT")))
            else
                f.title:SetText(titleString .. L["|cffff0000（需要在团队中才能查看）"])
            end
            for _, bt in ipairs(self.buttons) do
                bt:Reset()
            end
            if IsInRaid(1) then
                for i, v in ipairs(TJ.raidRosterInfo) do
                    local team = v.subgroup
                    local num
                    for ii = (team - 1) * 5 + 1, team * 5 do
                        local bt = self.buttons[ii]
                        local text = bt.nameText:GetText()
                        if not text or text == "" then
                            num = ii
                            break
                        end
                    end
                    self.buttons[num]:Update(i)
                end
            end
        end
    end

    function f:ShowOrHide()
        if TuanJian.options.showRaidMemberFrame == 1 then
            self:Show()
        else
            self:Hide()
        end
        bt:Update()
    end

    f:SetScript("OnShow", function(self)
        self:UpdateFrame()
        bt:Update()
    end)
    f:SetScript("OnHide", function(self)
        -- self:SetScript("OnUpdate", nil)
        bt:Update()
    end)

    f:ShowOrHide()
    f:UpdateFrame()
end
