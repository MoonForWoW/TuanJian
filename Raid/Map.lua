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

local prefix = "BiaoGeAIMap"
local prefixCount = 10
local prefixIndex = 0

local function GetNextMapChannel()
    prefixIndex = prefixIndex % prefixCount + 1
    return prefix .. prefixIndex
end

local IsAddOnLoaded = IsAddOnLoaded or C_AddOns.IsAddOnLoaded

TJ.maxMapNum = 5

local function CreateOptionFrame()
    local f = CreateFrame("Frame", nil, nil, "BackdropTemplate")
    do
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        f:SetBackdropColor(0, 0, 0, 0.9)
        f:SetBackdropBorderColor(.3, .3, .3, 1)
        f:SetSize(400, 90)
        f:SetToplevel(true)
        f:SetPoint("BOTTOMLEFT", TJ.MainFrame, "TOPRIGHT", 0, 0)
        f:Hide()
        f:SetScript("OnHide", function(self)
            self:Hide()
        end)
        TJ.mapOptionFrame = f

        f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
        f.CloseButton:SetPoint("TOPRIGHT", f, "TOPRIGHT", 2, 2)
        f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 1)
    end

    local h = -20
    -- 站位图缩放
    do
        local name = "mapScale"
        TJ.options[name .. "reset"] = .8
        local ontext = {
            L["站位图缩放"],
            L["默认值为0.8。"],
        }
        local f, title = ns.O.CreateSlider(name, (L["站位图缩放"]), TJ.mapOptionFrame, 0.5, 1.5, 0.01, 20, h, ontext)
        title:ClearAllPoints()
        title:SetPoint("TOPLEFT", TJ.mapOptionFrame, "TOPLEFT", 20, -20)
        f:HookScript("OnValueChanged", function(self)
            TJ.PairAllMap(function(map)
                map:SetScale(TuanJian.options[name] * map.baseScale)
            end)
        end)
        f:HookScript("OnShow", function(self)
            self:SetValue(TuanJian.options[name])
        end)
    end

    -- 图标缩放
    do
        h = h - 35
        local name = "mapIconScale"
        TJ.options[name .. "reset"] = 1
        local ontext = {
            L["图标缩放"],
            L["默认值为1。"],
        }
        local f, title = ns.O.CreateSlider(name, (L["图标缩放"]), TJ.mapOptionFrame, 0.5, 1.5, 0.01, 20, h, ontext)
        title:ClearAllPoints()
        title:SetPoint("TOPLEFT", TJ.mapOptionFrame, "TOPLEFT", 20, -50)
        f:HookScript("OnValueChanged", function(self)
            TJ.PairAllMap(function(map)
                for i, icon in ipairs(map.icons) do
                    local value = TuanJian.options[name] / map.baseScale
                    icon:SetScale(value)
                    icon:ClearAllPoints()
                    icon:SetPoint("CENTER", icon:GetParent(), "TOPLEFT",
                        icon.x / value, icon.y / value)
                end
            end)
        end)
        f:HookScript("OnShow", function(self)
            self:SetValue(TuanJian.options[name])
        end)
    end
end

function TJ.CreateMap(FB, bossIndex, iconTbl, width, height,
                        mapIndex, baseScale, isTeam, BiaoGeVer, childIndex,
                        notIconSync, mapBossIndex)
    local r, g, b = GetClassRGB(nil, "player")
    mapIndex = mapIndex or ""
    TuanJian[FB][bossIndex].lastMap = TuanJian[FB][bossIndex].lastMap or mapIndex
    local mapName = "map" .. mapIndex
    local parent = TJ.frame[FB][bossIndex]
    local all = parent.all
    local index = #all
    local title = all[index].title
    BiaoGeVer = BiaoGeVer or (TJ.IsTBC and "v1.28.6" or "v1.26.1")

    -- 打开站位图
    local openButton = TJ.CreateButton(title)
    do
        openButton:SetSize(100, 25)
        openButton:SetPoint("LEFT", title, "RIGHT", 10, 0)
        openButton:SetText(L["打开站位图"])
        openButton:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            TJ.PairAllMap(function(map)
                if map.index ~= mapIndex then
                    map:Hide()
                end
            end)
            if parent[mapName]:IsVisible() then
                parent[mapName]:Hide()
                TuanJian.options.showMap = 0
            else
                parent[mapName]:Show()
                TuanJian.options.showMap = 1
            end
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
        end)
        function openButton:Update()
            if parent[mapName]:IsVisible() then
                openButton:SetText(L["关闭站位图"])
            else
                openButton:SetText(L["打开站位图"])
            end
        end
    end

    -- 创建地图
    local map = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    do
        map:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeSize = 1,
        })
        map:SetBackdropColor(0, 0, 0, 0)
        local r, g, b = ns.GetClassRGB(nil, "player")
        map:SetBackdropBorderColor(r, g, b, TJ.borderAlpha)
        map:SetSize(width or 800, height or 450)
        map:EnableMouse(true)
        map.BiaoGeVer = BiaoGeVer
        map.baseScale = baseScale or 1
        map:SetScale(TuanJian.options.mapScale * map.baseScale)
        map.icons = {}
        map.index = mapIndex
        map.name = mapName
        map.openButton = openButton
        map:Hide()
        parent[mapName] = map
        map.iconTbl = iconTbl
        map.titleName = title.name
        map.notIconSync = notIconSync

        local tex = map:CreateTexture()
        tex:SetPoint("TOPLEFT", 1, -1)
        tex:SetPoint("BOTTOMRIGHT", -1, 1)
        tex:SetTexture(format("Interface\\AddOns\\TuanJian\\Media\\icon\\%s\\m%s.png", FB, (mapBossIndex or bossIndex) .. (childIndex or "")))

        map:SetScript("OnMouseDown", function(self)
            if TJ.lastfocus then
                TJ.lastfocus:ClearFocus()
            end
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
            if not TJ.mapLock then
                TJ.MainFrame:StartMoving()
            end
        end)
        map:SetScript("OnMouseUp", function(self)
            TJ.MainFrame:StopMovingOrSizing()
        end)
        map:SetScript("OnShow", function(self)
            TuanJian[FB][bossIndex].lastMap = self.index
            self:SetScale(TuanJian.options.mapScale * self.baseScale)
            TJ.UpdateMapIcon()
            TJ.UpdateMapAddon()
            self:ClearAllPoints()
            self:UpdatePoint()
            if self.bjText then
                self.bjText:SetShown(TJ.mapLock)
            end
            self.openButton:Update()
            if self.needUpdateIconPoint then
                for _, icon in pairs(self.icons) do
                    icon:PointUpdate()
                end
                self.needUpdateIconPoint = nil
            end
            if self.tab then
                self.tab:SetParent(self)
                self.tab:Show()
                self.tab:ClearAllPoints()
                self.tab:SetPoint(self.tab.point, 5, -5)
                TJ.PairAllMap(function(map)
                    if map.index ~= self.index then
                        map.tabButton:Enable()
                    end
                end)
                self.tabButton:Disable()
            end
        end)
        map:SetScript("OnHide", function(self)
            StaticPopup_Hide("TuanJian_ResetBJ")
            self.openButton:Update()
            if TJ.mapOptionFrame then
                TJ.mapOptionFrame:Hide()
            end
        end)

        function map:ClearAll()
            for _, icon in pairs(map.icons) do
                icon:Reset()
            end
        end

        function map:ShowOrHide()
            if TuanJian.options.showMap == 1 and TuanJian[FB][bossIndex].lastMap == self.index then
                self:Show()
            else
                self:Hide()
            end
        end

        function map:UpdatePoint()
            self:SetPoint("TOPLEFT", TJ.MainFrame, "TOPRIGHT", 1, 0)
        end

        map:ShowOrHide()
        map:UpdatePoint()
    end
    TJ.CreateFrameResizeHandle(map, "mapScale", .5, 1.5, nil, nil, nil)

    -- 重置位置
    do
        local bt = TJ.CreateButton(map)
        bt:SetSize(90, 25)
        bt:SetPoint("TOPLEFT", map, "BOTTOMLEFT", 0, -1)
        bt:SetText(L["重置布局"])
        bt:SetScale(1.25 / map.baseScale)
        bt.map = map
        map.resetButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if not StaticPopupDialogs["TuanJian_ResetBJ"] then
                StaticPopupDialogs["TuanJian_ResetBJ"] = {
                    text = L["确定把当前站位布局还原为初始位置？"],
                    button1 = YES,
                    button2 = NO,
                    OnCancel = function()
                    end,
                    selectCallbackByIndex = true,
                    timeout = 10,
                    whileDead = true,
                    hideOnEscape = true,
                }
            end
            StaticPopupDialogs["TuanJian_ResetBJ"].OnAccept = function()
                for i, icon in pairs(self.map.icons) do
                    icon:PointReset()
                end
            end
            StaticPopup_Show("TuanJian_ResetBJ")
        end)
        bt:SetScript("OnHide", function(self)
            StaticPopup_Hide("TuanJian_ResetBJ")
        end)
    end

    -- 解锁
    do
        local bt = TJ.CreateButton(map)
        bt:SetSize(110, 25)
        -- bt:SetSize(map.resetButton:GetSize())
        bt:SetPoint("LEFT", map.resetButton, "RIGHT", 2, 0)
        bt:SetText(L["进入布局模式"])
        bt:SetScale(map.resetButton:GetScale())
        bt.map = map
        map.bjButton = bt
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if TJ.mapLock then
                TJ.mapLock = nil
            else
                TJ.mapLock = true
            end
            self:Update()
        end)

        function bt:Update()
            if TJ.mapLock then
                self:SetText(L["退出布局模式"])
                self.map.bjText:Show()
                map:SetBackdropBorderColor(0, 1, 0, 1)
            else
                self:SetText(L["进入布局模式"])
                self.map.bjText:Hide()
                local r, g, b = ns.GetClassRGB(nil, "player")
                map:SetBackdropBorderColor(r, g, b, TJ.borderAlpha)
            end
        end

        bt:SetScript("OnShow", function(self)
            TJ.mapLock = nil
            bt:Update()
        end)
    end

    -- 清空
    do
        local bt = CreateFrame("Button", nil, map)
        bt:SetSize(25, 25)
        bt:SetPoint("TOPRIGHT", map, "BOTTOMRIGHT", 0, -3)
        bt:SetNormalTexture("interface/raidframe/readycheck-notready")
        bt:SetHighlightTexture("interface/raidframe/readycheck-notready")
        bt:RegisterForClicks("AnyUp")
        map.clearButton = bt
        bt:SetScript("OnClick", function(self, button)
            TJ.PlaySound(1)
            if button == "LeftButton" then
                TJ.ClearMap(FB, bossIndex, mapIndex)
            elseif button == "RightButton" then
                local FB = TuanJian.FB
                for bossIndex in ipairs(TJ.FBinfo[FB]) do
                    TJ.ClearMap(FB, bossIndex)
                end
            end
        end)
        bt:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["重置站位图"], 1, 1, 1, true)
            local c = 0
            for i = 1, TJ.maxMapNum do
                local mapIndex = i == 1 and "" or i
                local mapName = "map" .. mapIndex
                local map = parent[mapName]
                if map then
                    c = c + 1
                end
            end
            if c > 1 then
                GameTooltip:AddLine(AddTexture("LEFT") .. L["重置"] .. map.titleName, 1, .82, 0, true)
                GameTooltip:AddLine(AddTexture("RIGHT") .. L["重置该BOSS所有站位图"], 1, .82, 0, true)
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", GameTooltip_Hide)
    end

    -- 设置
    do
        if not TJ.mapOptionFrame then
            CreateOptionFrame()
        end
        local option = CreateFrame("Button", nil, map)
        option:SetPoint("RIGHT", map.clearButton, "LEFT", -2, 0)
        option:SetSize(25, 25)
        option:SetNormalTexture([[Interface\Buttons\UI-OptionsButton]])
        option:SetHighlightTexture([[Interface\Buttons\UI-OptionsButton]])
        option:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            if TJ.mapOptionFrame:IsVisible() then
                TJ.mapOptionFrame:Hide()
            else
                TJ.mapOptionFrame:Show()
                TJ.mapOptionFrame:SetParent(parent)
            end
        end)
    end

    -- 发送
    do
        local bt = TJ.CreateButton(map)
        bt:SetSize(100, 25)
        bt:SetPoint("LEFT", map.bjButton, "RIGHT", 2, 0)
        bt:SetText(L["发送"])
        bt:SetScale(1.25 / map.baseScale)
        bt.t = 0
        bt.map = map
        map.sendButton = bt
        bt:SetScript("OnClick", function(self)
            if not IsAddOnLoaded("BiaoGe") then
                ns.SendSystemMessage(L["你没有安装BiaoGe插件，无法使用此功能。"])
                return
            end
            if not (IsInRaid(1) and TJ.IsLeader()) then
                ns.SendSystemMessage(L["你不是团长/助理，无法发送。"])
                return
            end
            self:SetEnabled(false)
            After(TJ.IsTitan and 8 or 5, function()
                self:SetEnabled(true)
            end)
            TJ.SendMap(FB, bossIndex, mapIndex, childIndex, mapBossIndex, map)
            TJ.PlaySound(2)
        end)
        local BG = _G.BG
        bt:SetScript("OnEnter", function(self)
            TJ.isOnEnterMapSendButton = self

            local line = 4
            GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 0)
            GameTooltip:ClearLines()
            GameTooltip:AddLine(L["发送"], 1, 1, 1)
            GameTooltip:AddLine(L["把站位图发送到团队。"]:format(BiaoGeVer), 1, .82, 0, true)
            GameTooltip:AddLine(L["需要团员的BiaoGe插件版本高于或等于|cffffffff%s|r。"]:format(BiaoGeVer), 1, .82, 0, true)
            GameTooltip:AddLine(" ")
            if not IsAddOnLoaded("BiaoGe") then
                GameTooltip:AddLine(L["你没有安装BiaoGe插件，无法使用此功能。"], 1, 0, 0, true)
                GameTooltip:Show()
                return
            end
            if not (IsInRaid(1) and TJ.IsLeader()) then
                GameTooltip:AddLine(L["你不是团长/助理，无法发送。"], 1, 0, 0, true)
                line = line + 1
            end

            local raid = BG.SortRaidRosterInfo()
            for i, v in ipairs(raid) do
                local name = v.name
                local Ver = BG.raidBiaoGeVersion[name]
                local r, g, b = 1, 1, 1
                local unKnown
                local out = ""
                if not Ver then
                    if v.online then
                        Ver = L["无"]
                    else
                        Ver = L["未知"]
                    end
                    unKnown = true
                else
                    if BG.GetVerNum(BiaoGeVer) > BG.GetVerNum(Ver) then
                        out = L["（不支持）"]
                        unKnown = true
                    end
                end
                local role = ""
                if v.rank == 2 then
                    role = role .. AddTexture("interface/groupframe/ui-group-leadericon")
                elseif v.rank == 1 then
                    role = role .. AddTexture("interface/groupframe/ui-group-assistanticon")
                end
                if v.isML then
                    role = role .. AddTexture("interface/groupframe/ui-group-masterlooter")
                end
                local c1, c2, c3 = GetClassRGB(name)
                GameTooltip:AddDoubleLine(name .. role, Ver .. out, c1, c2, c3, r, g, b)
                if unKnown then
                    local alpha = 0.4
                    if _G["GameTooltipTextLeft" .. (i + line)] then
                        _G["GameTooltipTextLeft" .. (i + line)]:SetAlpha(alpha)
                    end
                    if _G["GameTooltipTextRight" .. (i + line)] then
                        _G["GameTooltipTextRight" .. (i + line)]:SetAlpha(alpha)
                    end
                end
            end
            GameTooltip:Show()
        end)
        bt:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
            TJ.isOnEnterMapSendButton = nil
        end)
        bt:SetScript("OnUpdate", function(self, t)
            self.t = self.t + t
            if self.t >= 3 then
                self.t = 0
                TJ.UpdateMapAddon()
            end
        end)

        local f = CreateFrame("Frame", nil, bt)
        f:SetSize(100, 20)
        f:SetPoint("LEFT", bt, "RIGHT", 5, 0)
        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("CENTER")
        t:SetTextColor(0, 1, 0)
        bt.addonFrame = f
        bt.addonText = t
    end

    local t = map:CreateFontString()
    do
        t:SetFont(BIAOGE_TEXT_FONT, 20, "OUTLINE")
        t:SetPoint("BOTTOM", map, "TOP", 0, 0)
        t:SetTextColor(0, 1, 0)
        t:SetText(L["现在是布局模式，你可以拖动图标来调整位置"])
        t:Hide()
        t:SetScale(1 / map.baseScale)
        map.bjText = t
    end

    map.defaluePoint = iconTbl

    for i, v in pairs(iconTbl) do
        TJ.CreateMapIcon(FB, bossIndex, i, v, nil, mapIndex, isTeam)
    end
    return map
end

function TJ.CreateMapIcon(FB, bossIndex, index, v, width,
                            mapIndex, isTeam)
    mapIndex = mapIndex or ""
    local mapName = "map" .. mapIndex
    TuanJian[FB][bossIndex][mapName][index] = TuanJian[FB][bossIndex][mapName][index] or {}
    local x, y = v.xy[1], v.xy[2]
    if TuanJian[FB][bossIndex][mapName][index].point then
        x, y = TuanJian[FB][bossIndex][mapName][index].point.x, TuanJian[FB][bossIndex][mapName][index].point.y
    end
    x = x or 0
    y = y or 0
    if y > 0 then y = -y end
    local map = TJ.frame[FB][bossIndex][mapName]
    width = width or v.size or (v.isNPC_help and 40) or (v.isNPC and 50) or 32

    local f = CreateFrame("Frame", nil, map)
    do
        f:SetSize(width, width)
        f.index = index
        f.x = x
        f.y = y
        f.isNPC = v.isNPC

        local value = TuanJian.options.mapIconScale / map.baseScale
        f:SetScale(value)
        f:ClearAllPoints()
        f:SetFrameLevel(map:GetFrameLevel() + (v.isNPC and 1 or index + 1))
        f:SetPoint("CENTER", f:GetParent(), "TOPLEFT",
            f.x / value, f.y / value)

        local mask = f:CreateMaskTexture()
        mask:SetPoint("CENTER")
        mask:SetSize(width - 4, width - 4)
        mask:SetTexture([[Interface\CharacterFrame\TempPortraitAlphaMask]], "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")

        local baseicon = f:CreateTexture()
        baseicon:SetPoint("CENTER")
        baseicon:SetSize(width + 6, width + 6)
        baseicon:AddMaskTexture(mask)
        baseicon.alpha = .5
        baseicon:SetAlpha(baseicon.alpha)
        f.baseicon = baseicon
        if v.baseicon then
            baseicon:SetAtlas(v.baseicon)
        end

        local icon = f:CreateTexture()
        icon:SetPoint("CENTER")
        icon:SetSize(width + 6, width + 6)
        f.icon = icon
        if v.coord then
            f.icon.hasCoord = true
            f.icon:SetTexCoord(unpack(v.coord))
        end

        local broder = f:CreateTexture()
        broder:SetAllPoints()
        broder:SetTexture([[Interface\AddOns\TuanJian\Media\icon\broder.png]])
        f.broder = broder

        if v.notMask then
            broder:Hide()
        else
            icon:AddMaskTexture(mask)
        end

        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("CENTER", 1, 0)
        t:SetText(f.index)
        f.numText = t

        local t = f:CreateFontString()
        t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        t:SetPoint("TOP", f, "BOTTOM", 0, 0)
        t:SetTextColor(1, 1, 1)
        f.playerText = t

        if v.isNPC then
            if v.isNPC_icon then
                if TJ.IsTBC and v.isNPC_icon == "Interface\\Icons\\Spell_Deathknight_BloodPresence" then
                    v.isNPC_icon = "Interface\\Icons\\spell_holy_devotionaura"
                end
                f.icon:SetTexture(v.isNPC_icon)
            else
                f.icon:SetTexture(format("Interface\\AddOns\\TuanJian\\Media\\icon\\%s\\%s.png", FB, v.isNPC))
                f.isBoss = true
            end
            f.numText:SetText(v.index or v.isNPC_text or nil)

            if v.isNPC_help then
                f.broder:SetVertexColor(.5, .5, .5)
            else
                f.broder:SetVertexColor(1, 0, 0)
            end
        end

        tinsert(map.icons, f)
    end

    f:SetScript("OnMouseDown", function(self, button)
        if button == "LeftButton" then
            if TJ.mapLock then
                self:SetScript("OnUpdate", self.Update)
            else
                if not self.isNPC then
                    TJ.ListPlayer(self, nil, mapIndex, isTeam)
                end
            end
        else
            if TJ.mapLock then
                self:PointReset()
            else
                if not self.isNPC then
                    TJ.PairAllMap(function(map)
                        if not map.notIconSync or map.index == mapIndex then
                            for _, icon in pairs(map.icons) do
                                if icon.index == self.index then
                                    icon:Reset()
                                end
                            end
                        end
                    end)
                end
            end
        end
    end)
    f:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" or not TJ.mapLock then return end
        self:SetScript("OnUpdate", nil)
        self:ClearAllPoints()
        local uiScale, _x, _y = UIParent:GetEffectiveScale(), GetCursorPosition()
        local mapScale = TuanJian.options.mapScale * map.baseScale
        local iconScale = TuanJian.options.mapIconScale / map.baseScale
        local x, y = _x / uiScale, _y / uiScale
        local fx = map:GetLeft() * mapScale
        local fy = map:GetTop() * mapScale
        local ix = Round((x - fx) / mapScale)
        local iy = Round((y - fy) / mapScale)
        self.x = ix
        self.y = iy
        self:SetPoint("CENTER", map, "TOPLEFT", self.x / iconScale, self.y / iconScale)
        TuanJian[FB][bossIndex][mapName][index].point = { x = ix, y = iy }
    end)
    f:SetScript("OnShow", function(self)
        local value = TuanJian.options.mapIconScale / map.baseScale
        self:SetScale(value)
        self:ClearAllPoints()
        self:SetPoint("CENTER", self:GetParent(), "TOPLEFT",
            self.x / value, self.y / value)
    end)

    function f:Update()
        local uiScale, _x, _y = UIParent:GetEffectiveScale(), GetCursorPosition()
        local mapScale = TuanJian.options.mapScale * map.baseScale
        local iconScale = TuanJian.options.mapIconScale / map.baseScale
        local x = _x / uiScale / mapScale
        local y = _y / uiScale / mapScale
        self:ClearAllPoints()
        self:SetPoint("CENTER", nil, "BOTTOMLEFT", x / iconScale, y / iconScale)
    end

    function f:PointUpdate()
        local iconScale = TuanJian.options.mapIconScale / map.baseScale
        local x, y = TuanJian[FB][bossIndex][mapName][index].point.x, TuanJian[FB][bossIndex][mapName][index].point.y
        self.x = x
        self.y = y
        self:ClearAllPoints()
        self:SetPoint("CENTER", map, "TOPLEFT", self.x / iconScale, self.y / iconScale)
    end

    function f:PointReset()
        local iconScale = TuanJian.options.mapIconScale / map.baseScale
        local x = map.defaluePoint[self.index].xy[1]
        local y = map.defaluePoint[self.index].xy[2]
        if y > 0 then y = -y end
        self:ClearAllPoints()
        self.x = x
        self.y = y
        self:SetPoint("CENTER", map, "TOPLEFT", self.x / iconScale, self.y / iconScale)
        TuanJian[FB][bossIndex][mapName][self.index].point = nil
    end

    function f:Reset(notClearDB)
        if self.isNPC then return end
        if isTeam then
            self.broder:SetVertexColor(.5, .5, .5)
            self.numText:SetText(self.index)
            self.numText:SetTextColor(.5, .5, .5)
            self.playerText:SetText("")
            self.baseicon:SetAlpha(self.baseicon.alpha)
            self.team = nil
            if not notClearDB then
                TuanJian[FB][bossIndex][mapName][self.index].team = nil
            end
        else
            self.baseicon:SetAtlas(nil)
            self.icon:SetAtlas(nil)
            self.broder:SetVertexColor(.5, .5, .5)
            self.numText:SetTextColor(.5, .5, .5)
            self.playerText:SetText("")
            self.name = nil
            self.class = nil
            self.combatRole = nil
            self.talent = nil
            if not notClearDB then
                TuanJian[FB][bossIndex][mapName][self.index].player = nil
            end
        end
    end

    function f:SetPlayer(v)
        if self.isNPC then return end
        local r, g, b = GetClassColor(v.class)
        self.broder:SetVertexColor(r, g, b)
        self.playerText:SetText(v.name)
        self.playerText:SetTextColor(r, g, b)
        self.numText:SetTextColor(1, 1, 1)
        local talent = TuanJian.talentInfo and TuanJian.talentInfo[v.name] or v.talent
        if talent then
            self.icon:SetTexture(TJ.talentIcon[v.class][talent])
        else
            self.icon:SetAtlas("ui-lfg-roleicon-" .. v.combatRole:gsub("DAMAGER", "dps"))
        end
        self.name = v.name
        self.class = v.class
        self.combatRole = v.combatRole
        self.talent = talent

        local tbl = TJ.Copy(v)
        tbl.talent = talent
        TuanJian[FB][bossIndex][mapName][self.index].player = tbl
    end

    function f:NoPlayer()
        return not self.name
    end

    function f:SetTalentIcon()
        if self.isNPC then return end
        local name = self.name
        if self:NoPlayer() then return end
        local talent = TuanJian.talentInfo and TuanJian.talentInfo[name]
        if talent then
            self.icon:SetTexture(TJ.talentIcon[self.class][talent])
        end
    end

    function f:NoTeam()
        return not self.team
    end

    function f:SetTeam(index)
        self.broder:SetVertexColor(1, 1, 1)
        self.numText:SetText("")
        self.numText:SetTextColor(1, 1, 1)
        self.playerText:SetText(index .. L["队"])
        self.baseicon:SetAlpha(1)
        self.team = index
        TuanJian[FB][bossIndex][mapName][self.index].team = index
    end

    f:Reset(true)
    if isTeam then
        local index = TuanJian[FB][bossIndex][mapName][f.index].team
        if index then
            f:SetTeam(index)
        end
    else
        local v = TuanJian[FB][bossIndex][mapName][f.index].player
        if v then
            f:SetPlayer(v)
        end
    end
    return f
end

function TJ.UpdateMapIcon()
    TJ.PairAllMap(function(map)
        if map:IsVisible() then
            for _, v in ipairs(TJ.raidRosterInfo) do
                for _, f in pairs(map.icons) do
                    if not f.isNPC and v.name == f.name then
                        f:SetPlayer(v)
                    end
                end
            end
        end
    end)
end

function TJ.PairAllMap(func, FB, bossIndex)
    local FB = FB or TuanJian.FB
    local bossIndex = bossIndex or TuanJian.bossIndex
    for i = 1, TJ.maxMapNum do
        local mapIndex = i == 1 and "" or i
        local mapName = "map" .. mapIndex
        local map = TJ.frame[FB][bossIndex][mapName]
        if map then
            func(map)
        end
    end
end

function TJ.UpdateMapAddon()
    local BG = _G.BG
    TJ.PairAllMap(function(map)
        local addonText = map.sendButton.addonText
        if (IsAddOnLoaded("BiaoGe") and IsInRaid(1)) then
            addonText:Show()
        else
            addonText:Hide()
            return
        end
        local BiaoGeVer = map.BiaoGeVer
        local raid = BG.SortRaidRosterInfo()
        local count = 0
        local names = {}
        for i, v in ipairs(raid) do
            local name = v.name
            local Ver = BG.raidBiaoGeVersion[name]
            if Ver and BG.GetVerNum(Ver) >= BG.GetVerNum(BiaoGeVer) then
                count = count + 1
            else
                tinsert(names, name)
            end
        end
        addonText:SetText(L["%s/%s"]:format(count, #raid))
        map.sendButton.addonFrame:SetWidth(addonText:GetStringWidth())
        if count < #raid then
            map.verInfo = {
                ver = BiaoGeVer,
                names = names,
            }
        else
            map.verInfo = nil
        end
    end)
    if TJ.isOnEnterMapSendButton then
        TJ.isOnEnterMapSendButton:GetScript("OnEnter")(TJ.isOnEnterMapSendButton)
    end
end

-- 1级分隔：^^ 基本信息 表格内容 拍卖记录
-- 2级分割：&&
-- 3级分割：¦
local function BuildCode(FB, bossIndex, mapIndex, childIndex, mapBossIndex)
    local mapName = "map" .. mapIndex
    local map = TJ.frame[FB][bossIndex][mapName]

    local mapWidth, mapHeight = map:GetSize()
    mapWidth = floor(mapWidth)
    mapHeight = floor(mapHeight)
    local bossName = TJ.FBinfo[FB][bossIndex].name
    local str = format("%s&&%s&&%s&&%s&&%s&&%s^^", FB, (mapBossIndex or bossIndex), mapWidth, mapHeight, childIndex or "",
        bossName)

    local iconStr = ""
    for _, self in pairs(map.icons) do
        local hasPlayer, inMap
        if self.isNPC or not self:NoPlayer() then
            hasPlayer = true
        end
        if hasPlayer then
            local scale = self:GetScale()
            local _, _, _, x, y = self:GetPoint()
            x = x * scale
            y = y * scale
            if x >= 0 and x <= mapWidth and y <= 0 and y >= -mapHeight then
                inMap = true
            end
        end
        if hasPlayer and inMap then
            local level = self:GetFrameLevel() or 1
            local x = self.x
            local y = self.y
            local width = format("%.0f", self:GetWidth())

            local iconType, iconTex = "", ""
            if self.isBoss then
                iconType = "boss"
                iconTex = self.isNPC
            else
                local tex = self.icon:GetAtlas()
                if tex then
                    iconType = "atlas"
                    iconTex = tex
                else
                    tex = self.icon:GetTexture()
                    if tex then
                        iconType = "tex"
                        iconTex = tex
                    end
                end
            end
            local left, right, top, bottom, _
            if self.icon.hasCoord then
                left, top, _, bottom, right = self.icon:GetTexCoord()
            else
                left, right, top, bottom = "", "", "", ""
            end

            local broderShow = self.broder:IsVisible() and 1 or 0
            local broder_r, broder_g, broder_b = self.broder:GetVertexColor()
            broder_r, broder_g, broder_b = format("%.2f", broder_r), format("%.2f", broder_g), format("%.2f", broder_b)

            local numText = self.numText:GetText() or ""
            local num_r, num_g, num_b = self.numText:GetTextColor()
            num_r, num_g, num_b = format("%.2f", num_r), format("%.2f", num_g), format("%.2f", num_b)

            local playerText = self.playerText:GetText() or ""
            local player_r, player_g, player_b = self.playerText:GetTextColor()
            player_r, player_g, player_b = format("%.2f", player_r), format("%.2f", player_g), format("%.2f", player_b)

            iconStr = iconStr .. format("%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s¦%s&&",
                level,
                x,
                y,
                width,
                width,
                iconType,
                iconTex,
                left,
                right,
                top,
                bottom,
                broderShow,
                broder_r,
                broder_g,
                broder_b,
                numText,
                num_r,
                num_g,
                num_b,
                playerText,
                player_r,
                player_g,
                player_b
            )
        end
    end
    str = str .. iconStr
    str = C_EncodingUtil.CompressString(str)
    return ns.Encode(str)
end
function TJ.SendMap(FB, bossIndex, mapIndex, childIndex, mapBossIndex, map)
    local code = BuildCode(FB, bossIndex, mapIndex, childIndex, mapBossIndex)
    local END_MARK = "!END!"
    local END_MARK_LEN = string.len(END_MARK)
    local MAX_LENGTH = 255
    code = "!AIMAP!" .. code .. END_MARK
    local totalLen = string.len(code)
    local currentPos = 1
    local endMarkStart = string.find(code, END_MARK, 1, true)
    local endMarkEnd = endMarkStart + END_MARK_LEN - 1
    local msgs = {}
    while currentPos <= totalLen do
        local targetEndPos = currentPos + MAX_LENGTH - 1
        if targetEndPos >= endMarkStart and targetEndPos < endMarkEnd then
            targetEndPos = endMarkStart - 1
        end
        local sendStr = string.sub(code, currentPos, math.min(targetEndPos, totalLen))
        tinsert(msgs, sendStr)
        currentPos = targetEndPos + 1
    end
    for _, msg in ipairs(msgs) do
        C_ChatInfo.SendAddonMessage(GetNextMapChannel(), msg, "RAID")
    end
    if TJ.IsTitan then
        local delay = 1.5
        local time = 0
        for i, msg in ipairs(msgs) do
            After(time, function()
                C_ChatInfo.SendAddonMessage(prefix, msg, "RAID")
            end)
            time = time + delay
        end
        ns.SendSystemMessage(L["正在发送站位图，大约需要%s秒。"]:format(delay * (#msgs - 1)))
    else
        for i, msg in ipairs(msgs) do
            ChatThrottleLib:SendAddonMessage("NORMAL", prefix, msg, "RAID")
        end
    end
    if map.verInfo then
        local str = ''
        for i, name in ipairs(map.verInfo.names) do
            str = str .. ns.SetClassCFF(name) .. (i ~= #map.verInfo.names and ' ' or '')
        end
        ns.SendSystemMessage(L["该站位图需要BiaoGe插件%s，有%s名玩家由于插件版本太旧无法接收：%s。"]:format(
            map.verInfo.ver, #map.verInfo.names, str))
    end
end

function TJ.CreateMapTab(mainFrame, FB, bossIndex, point)
    local last
    local f = CreateFrame("Frame", nil, mainFrame)
    f:SetSize(1, 20)
    f:Hide()
    f.point = point or "TOPLEFT"
    f.buttons = {}
    TJ.PairAllMap(function(map)
        local bt = CreateFrame("Button", nil, f)
        bt:SetFrameLevel(f:GetFrameLevel())
        bt:SetNormalFontObject(TJ.FontBlue20)
        bt:SetDisabledFontObject(TJ.FontWhite25)
        bt:SetHighlightFontObject(TJ.FontWhite20)
        bt:SetHighlightTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")
        bt:SetText(map.titleName)
        bt:SetSize(bt:GetFontString():GetWidth() + 10, 25)
        f:SetWidth(f:GetWidth() + bt:GetWidth() + 5)
        if not last then
            bt:SetPoint("TOPLEFT", 5, -2)
        else
            bt:SetPoint("LEFT", last, "RIGHT", 5, 0)
        end
        last = bt
        bt.map = map
        map.tab = f
        map.tabButton = bt
        tinsert(f.buttons, bt)
        bt:SetScript("OnClick", function(self)
            TJ.PlaySound(1)
            TJ.PairAllMap(function(map)
                if map.index ~= self.map.index then
                    map:Hide()
                end
            end)
            self.map:Show()
            if TJ.FramePlayerList then
                TJ.FramePlayerList:Hide()
            end
        end)
    end, FB, bossIndex)
end

function TJ.ClearMap(_FB, _bossIndex, mapID)
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
                    if parent then
                        for i = 1, TJ.maxMapNum do
                            local mapIndex = i == 1 and "" or i
                            if not mapID or mapID == mapIndex then
                                local mapName = "map" .. mapIndex
                                local map = parent[mapName]
                                if map then
                                    map:ClearAll()
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if TJ.exportTJFrame then
        TJ.exportTJFrame:UpdateText()
    end
end
