local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L
local RGB = ns.RGB

local After = C_Timer.After
local player = UnitName("player")
local realmID = GetRealmID()
local pt = print
local r, g, b = GetClassColor(select(2, UnitClass("player")))
local BG = TJ

local function Size(t)
    local s = 0
    for k, v in pairs(t) do
        if v ~= nil then
            s = s + 1
        end
    end
    return s
end
ns.Size = Size

local function RGB(hex, Alpha)
    local red = hex:sub(1, 2)
    local green = hex:sub(3, 4)
    local blue = hex:sub(5, 6)

    red = tonumber(red, 16) / 255
    green = tonumber(green, 16) / 255
    blue = tonumber(blue, 16) / 255

    if Alpha then
        return red, green, blue, Alpha
    else
        return red, green, blue
    end
end
ns.RGB = RGB

local function Round(number, decimal_places)
    local mult = 10 ^ (decimal_places or 0)
    return math.floor(number * mult + 0.5) / mult
end
ns.Round = Round

local function RGB_16(name, r, g, b)
    if not r then
        r, g, b = name:GetTextColor()
        name = name:GetText()
    end

    local r = string.format("%X", tonumber(r) * 255)
    if r and strlen(r) == 1 then
        r = "0" .. r
    end
    local g = string.format("%X", tonumber(g) * 255)
    if g and strlen(g) == 1 then
        g = "0" .. g
    end
    local b = string.format("%X", tonumber(b) * 255)
    if b and strlen(b) == 1 then
        b = "0" .. b
    end
    local c = r .. g .. b

    if name then
        return "|cff" .. c .. name .. "|r"
    else
        return c
    end
end
ns.RGB_16 = RGB_16

local function GetItemID(text)
    if not text then
        return
    end
    local h_item = "item:(%d+):"
    local item = tonumber(strmatch(text, h_item))
    return item
end
ns.GetItemID = GetItemID

local function GetClassRGB(name, unit, Alpha)
    local _, class
    if unit then
        _, class = UnitClass(unit)
    else
        _, class = UnitClass(TJ.GSN(name))
    end
    local c1, c2, c3 = 1, 1, 1
    if class then
        c1, c2, c3 = GetClassColor(class)
    end
    return c1, c2, c3, Alpha
end
ns.GetClassRGB = GetClassRGB

local function SetClassCFF(name, unit, type)
    if type then return name end
    local _, class
    if unit then
        _, class = UnitClass(unit)
        name = name or TJ.GN(unit)
    else
        _, class = UnitClass(TJ.GSN(name))
    end
    if class then
        local color = select(4, GetClassColor(class))
        return "|c" .. color .. name .. "|r", color
    else
        return name, ""
    end
end
ns.SetClassCFF = SetClassCFF

local function CreateLine(parent, y, width, height, color, alpha)
    local l = parent:CreateLine()
    l:SetColorTexture(RGB(color or "808080", alpha or 1))
    l:SetStartPoint("BOTTOMLEFT", 0, y)
    l:SetEndPoint("BOTTOMLEFT", width, y)
    l:SetThickness(height or 1.5)
    return l
end
ns.CreateLine = CreateLine

local classNameTbl = {
    WARRIOR = GetClassInfo(1),
    PALADIN = GetClassInfo(2),
    HUNTER = GetClassInfo(3),
    ROGUE = GetClassInfo(4),
    PRIEST = GetClassInfo(5),
    DEATHKNIGHT = GetClassInfo(6),
    SHAMAN = GetClassInfo(7),
    MAGE = GetClassInfo(8),
    WARLOCK = GetClassInfo(9),
    MONK = GetClassInfo(10),
    DRUID = GetClassInfo(11),
    DEMONHUNTER = GetClassInfo(12),
    EVOKER = GetClassInfo(13)
}
local function GetClassName(classFile)
    return classNameTbl[classFile]
end
ns.GetClassName = GetClassName

local function FormatNumber(num, notdo)
    if not tonumber(num) then
        return num
    end
    if notdo then
        return num
    end
    local formatted = tostring(num)
    formatted = formatted:reverse():gsub("(%d%d%d)", "%1,"):reverse():gsub("^,", "")
    return formatted
end
ns.FormatNumber = FormatNumber

function TJ.FormatNumber(num)
    if not tonumber(num) then return num end
    num = tostring(num)
    local len = strlen(num)
    if len < 5 then return num end
    num = Round(num / 1000) / 10
    return num .. L["万"]
end

local oldFuc = SendSystemMessage
local function SendSystemMessage(msg)
    oldFuc(TJ.STC_b1("<TuanJian>") .. " " .. msg)
end
ns.SendSystemMessage = SendSystemMessage

local function AddTexture(Texture, y, coord)
    if not Texture then
        return ""
    end
    local x = 0
    if not y then
        y = "-0"
    end
    local tex = ""
    local coord = coord or ""
    if Texture == "MAINTANK" then -- 主坦克
        -- tex = "132064"
        return "|A:ui-lfg-roleicon-tank:0:0|a"
    elseif Texture == "MAINASSIST" then                -- 主助理
        tex = "132063"
    elseif Texture == "TANK" then                      -- 坦克职责
        return "|A:ui-lfg-roleicon-tank:0:0|a"
    elseif Texture == "HEALER" then                    -- 治疗职责
        return "|A:ui-lfg-roleicon-healer:0:0|a"
    elseif Texture == "DAMAGER" then                   -- 输出职责
        return "|A:ui-lfg-roleicon-dps:0:0|a"
    elseif Texture == 137000 or Texture == 136998 then -- 战场荣誉
        coord = ":100:100:10:60:0:55"
        local t = "|T" .. Texture .. ":0:0:0:0" .. coord .. "|t"
        return t
    elseif Texture == "QUEST" then -- 黄色感叹号
        tex = "Interface\\GossipFrame\\AvailableQuestIcon"
    elseif Texture == "BOX" then
        tex = ns.Interface .. "Media\\icon\\BOX"
    elseif Texture == "DD" then
        tex = ns.Interface .. "Media\\icon\\DD"
    elseif Texture == "LEFT" then
        return "|A:NPE_LeftClick:0:0|a"
    elseif Texture == "RIGHT" then
        return "|A:NPE_RightClick:0:0|a"
    else
        tex = Texture
    end
    local t = "|T" .. tex .. ":0:0:" .. x .. ":" .. y .. coord .. "|t"
    return t
end
ns.AddTexture = AddTexture

------------------按键声音------------------
function TJ.PlaySound(id)
    if TJ["sound" .. id] then
        if id == 2 then
            PlaySoundFile(TJ["sound" .. id])
        else
            PlaySound(TJ["sound" .. id])
        end
    elseif type(id) == "string" and TJ.voice[id] then
        PlaySoundFile(TJ.voice[id], "Master")
    end
end

------------------计时器------------------
function TJ.OnUpdateTime(func)
    local updateFrame = CreateFrame("Frame")
    updateFrame.t = 0
    updateFrame:SetScript("OnUpdate", func)
    return updateFrame
end

--[[
TJ.OnUpdateTime(function(self,t)
    self.t=self.t+t
    if self.t then
        self:SetScript("OnUpdate",nil)
        self:Hide()
    end
end)
 ]]

function TJ.CreateSrollBarBackdrop(bar)
    if bar.ThumbButton then return end
    local tex = bar:CreateTexture()
    tex:SetPoint("TOPLEFT", bar.ScrollUpButton, -0, 0)
    tex:SetPoint("BOTTOMRIGHT", bar.ScrollDownButton, 0, -0)
    tex:SetColorTexture(0, 0, 0, 0.3)
end

----------高亮按钮----------
function TJ.SetTextHighlightTexture(bt)
    local tex = bt:CreateTexture()
    tex:SetPoint("TOPLEFT", bt, "TOPLEFT", -8, 0)
    tex:SetPoint("BOTTOMRIGHT", bt, "BOTTOMRIGHT", 8, 0)
    tex:SetTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")
    bt:SetHighlightTexture(tex)
end

-- 创建多选按钮
local function OnClick(self)
    if self:GetChecked() then
        TuanJian.options[self.name] = 1
    else
        TuanJian.options[self.name] = 0
    end
    TJ.PlaySound(1)
end
local function OnEnter(self)
    if not self.ontext then
        return
    end
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
local function OnLeave(self)
    GameTooltip:Hide()
end
function TJ.CreateCheckButton(name, text, parent, ontext)
    local bt = CreateFrame("CheckButton", nil, parent, "ChatConfigCheckButtonTemplate")
    bt:SetSize(30, 30)
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
    bt:SetScript("OnLeave", OnLeave)
    return bt
end

function TJ.ChangeDate(date)
    date = tostring(date)
    local month = date:sub(3, 4)
    if month:sub(1, 1) == "0" then
        month = month:sub(2, 2)
    end
    local day = date:sub(5, 6)
    if day:sub(1, 1) == "0" then
        day = day:sub(2, 2)
    end
    return month .. L["月"] .. day .. L["日"], month, day
end

function TJ.SendManyMsg(channel, tbl, t)
    local t = t or 0
    for i, v in ipairs(tbl) do
        After(t, function()
            for _, text in ipairs(tbl[i]) do
                SendChatMessage(text, channel, nil, UnitName("target"))
            end
        end)
        t = t + TJ.sendCD
    end
    return t
end

function TJ.ToGold(copper)
    return floor(copper / 10000)
end

function TJ.ToName(fullName)
    local _player, _relamName = strsplit("-", fullName)
    if not _relamName or _relamName == "" or _relamName == realmName_chat then
        return _player
    else
        return fullName
    end
end

function TJ.SetEditScript(edit)
    edit:SetScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    edit:SetScript("OnMouseDown", function(self, enter)
        if enter == "RightButton" then
            edit:SetEnabled(false)
            edit:SetText("")
        end
    end)
    edit:SetScript("OnMouseUp", function(self, enter)
        if enter == "RightButton" then
            edit:SetEnabled(true)
        end
    end)
end

function TJ.Once(name, dt, func)
    if TuanJian and TuanJian.options and TuanJian.options.SearchHistory then
        if not TuanJian.options.SearchHistory[name .. dt] then
            func()
            TuanJian.options.SearchHistory[name .. dt] = true
        end
    end
end

function TJ.CreateTitleBg(bt)
    local w = 4

    local left = bt:CreateTexture(nil, "BACKGROUND")
    left:SetPoint("TOPLEFT", bt, "TOPLEFT", 0, 0)
    left:SetPoint("BOTTOMRIGHT", bt, "BOTTOMLEFT", w, 1)
    left:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]])
    left:SetTexCoord(0, .078, 0, .75)

    local right = bt:CreateTexture(nil, "BACKGROUND")
    right:SetPoint("TOPLEFT", bt, "TOPRIGHT", -w, 0)
    right:SetPoint("BOTTOMRIGHT", bt, "BOTTOMRIGHT", 0, 1)
    right:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]])
    right:SetTexCoord(0.9, .97, 0, .75)

    local middle = bt:CreateTexture(nil, "BACKGROUND")
    middle:SetPoint("TOPLEFT", bt, "TOPLEFT", w, 0)
    middle:SetPoint("BOTTOMRIGHT", bt, "BOTTOMRIGHT", -w, 1)
    middle:SetTexture([[Interface\FriendsFrame\WhoFrame-ColumnTabs]])
    middle:SetTexCoord(.078, .9, 0, .75)

    bt:SetHighlightTexture("Interface/PaperDollInfoFrame/UI-Character-Tab-Highlight")

    local t = bt:GetFontString()
    local btWidth = bt:GetWidth()
    if btWidth then
        if btWidth <= 60 then
            t:SetWidth(btWidth - 5)
        else
            t:SetWidth(btWidth - 15)
        end
    end

    return left, right
end

function TJ.CreateMainFrame(name, titleText)
    local r, g, b = GetClassRGB(nil, "player")
    local f = CreateFrame("Frame", name, UIParent, "BackdropTemplate")
    f:SetBackdrop({
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,
    })
    f:SetBackdropBorderColor(r, g, b, TJ.borderAlpha)
    f:SetPoint("CENTER")
    f:SetMovable(true)
    f:SetToplevel(true)
    f:SetScript("OnMouseUp", function(self)
        self:StopMovingOrSizing()
    end)
    f:SetScript("OnMouseDown", function(self)
        self:StartMoving()
    end)

    local l = f:CreateLine()
    l:SetColorTexture(r, g, b, TJ.borderAlpha)
    l:SetStartPoint("TOPLEFT", 1, -21)
    l:SetEndPoint("TOPRIGHT", -1, -21)
    l:SetThickness(1)

    f.titleBg = f:CreateTexture(nil, "BACKGROUND", nil, 1)
    f.titleBg:SetPoint("TOPLEFT")
    f.titleBg:SetPoint("BOTTOMRIGHT", f, "TOPRIGHT", 0, -22)
    f.titleBg:SetTexture("Interface\\Buttons\\WHITE8x8")
    f.titleBg:SetGradient("VERTICAL", CreateColor(r, g, b, .2), CreateColor(r, g, b, .0))

    f.Bg = f:CreateTexture(nil, "BACKGROUND", nil, 0)
    f.Bg:SetAllPoints()
    f.Bg:SetColorTexture(.01, .01, .01, .8)

    f.CloseButton = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    f.CloseButton:SetPoint("TOPRIGHT", 5, 5)
    f.CloseButton:SetFrameLevel(f:GetFrameLevel() + 1)

    f.titleText = f:CreateFontString()
    f.titleText:SetPoint("TOP", 0, -4)
    f.titleText:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
    f.titleText:SetTextColor(RGB("00BFFF"))
    f.titleText:SetText(titleText)
    return f
end

function TJ.GetVerNum(ver)
    ver = ver:gsub("%s-[Bb]eta%d+", ""):gsub("%s-[Aa]lpha%d+", "")
    local lastString = tonumber(strsub(ver, strlen(ver), strlen(ver)))
    if lastString then
        ver = ver .. "0"
    end
    ver = ver:gsub("a", 1)
    ver = ver:gsub("b", 2)
    ver = ver:gsub("c", 3)
    ver = ver:gsub("d", 4)
    ver = ver:gsub("e", 5)
    ver = ver:gsub("f", 6)
    ver = ver:gsub("g", 7)
    ver = ver:gsub("h", 8)
    ver = ver:gsub("i", 9)
    local start, middle, last = strsplit(".", ver)
    if middle:len() == 1 then
        middle = "0" .. middle
    end
    ver = start .. middle .. last
    ver = ver:gsub("%D", "")
    ver = tonumber(ver)
    return ver
end

function TJ.dropDownToggle(dropDown)
    dropDown:SetScript("OnMouseDown", function(self)
        if dropDown.isDisabled then return end
        LibBG:ToggleDropDownMenu(nil, nil, self)
        TJ.PlaySound(1)
    end)
    TJ.SkinDropDown(dropDown)
end

function TJ.SkinDropDown(dropDown)
    local borderAlpha = 1
    local bt = dropDown.Button
    bt:Hide()
    dropDown.Left:Hide()
    dropDown.Middle:Hide()
    dropDown.Right:Hide()
    dropDown.Text:ClearAllPoints()
    dropDown.Text:SetPoint("TOPLEFT", 18, -8)
    dropDown.Text:SetPoint("TOPRIGHT", -40, -8)
    dropDown.Text:SetJustifyH("RIGHT")

    local f = CreateFrame("Frame", nil, dropDown, "BackdropTemplate")
    f:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,

    })
    f:SetBackdropColor(0, 0, 0, 0.5)
    f:SetBackdropBorderColor(.3, .3, .3, borderAlpha)
    f:SetPoint("TOPLEFT", 15, 0)
    f:SetPoint("BOTTOMRIGHT", -15, 7)
    f:SetFrameLevel(dropDown:GetFrameLevel())
    dropDown.bg = f

    local tex = dropDown:CreateTexture("OVERLAY")
    tex:SetPoint("TOPLEFT", bt, "TOPLEFT", 2, -2)
    tex:SetPoint("BOTTOMRIGHT", bt, "BOTTOMRIGHT", -2, 2)
    tex:SetTexture(ns.Interface .. "Media\\textures\\arrow.tga")
    tex:SetRotation(math.pi)
    dropDown:HookScript("OnEnter", function(self)
        if dropDown.isDisabled then return end
        f:SetBackdropColor(r, g, b, 0.3)
        f:SetBackdropBorderColor(r, g, b, borderAlpha)
    end)
    dropDown:HookScript("OnLeave", function(self)
        if dropDown.isDisabled then return end
        f:SetBackdropColor(0, 0, 0, 0.5)
        f:SetBackdropBorderColor(.3, .3, .3, borderAlpha)
    end)
end

function TJ.HookScrollBarShowOrHide(scroll, alwaysHide)
    if scroll.ScrollBar.ThumbButton then
        scroll.alwaysHideScrollBar = alwaysHide
        if scroll.ScrollBar:GetOrientation() == "HORIZONTAL" then
            TuanJian_ModernHorizontalScrollFrameTemplate_Update(scroll)
        else
            TuanJian_ModernScrollFrameTemplate_Update(scroll)
        end
        return
    end
    scroll.ScrollBar:Hide()
    scroll:HookScript("OnScrollRangeChanged", function(self, xrange, yrange)
        if alwaysHide then
            scroll.ScrollBar:Hide()
        else
            if yrange == 0 then
                self.ScrollBar:Hide()
            else
                self.ScrollBar:Show()
            end
        end
    end)
end

-- 玩家列表
local function CreateButton(f, i)
    local width = 100
    local maxCow = 10
    local bt = CreateFrame("EditBox", nil, f, TJ.editTemplate)
    bt:SetSize(width, 20)
    bt:SetAutoFocus(false)
    if i == 1 then
        bt:SetPoint("TOPLEFT", 10, -5)
    elseif (i - 1) % maxCow == 0 then
        bt:SetPoint("TOPLEFT", f.buttons[i - maxCow], "TOPRIGHT", 7, 0)
    else
        bt:SetPoint("TOPLEFT", f.buttons[i - 1], "BOTTOMLEFT", 0, 0)
    end
    tinsert(f.buttons, bt)

    local row = i >= maxCow and maxCow or i % maxCow
    local arrange = floor((i - 1) / maxCow) + 1
    f:SetSize(arrange * width + (arrange - 1) * 7 + 15, row * 20 + 10)

    bt:SetCursorPosition(0)

    bt.ds = bt:CreateTexture()
    bt.ds:SetPoint("TOPLEFT", -4, -2)
    bt.ds:SetPoint("BOTTOMRIGHT", 0, 0)
    bt.ds:SetColorTexture(1, 1, 1, TJ.onEnterAlpha)
    bt.ds:Hide()

    bt:SetScript("OnEnter", function(self)
        self.ds:Show()
    end)
    bt:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self.ds:Hide()
    end)

    return bt
end
local function AddButton(owner, f, i, v, mapIndex)
    local r, g, b = GetClassColor(v.class)
    local bt = CreateButton(f, i)
    bt:SetText(TJ.GetIconAndName(v))
    bt:SetTextColor(r, g, b)
    bt:SetScript("OnMouseDown", function(self)
        if mapIndex then
            TJ.PairAllMap(function(map)
                if not map.notIconSync or map.index == mapIndex then
                    for _, icon in pairs(map.icons) do
                        if icon.index == owner.index then
                            icon:SetPlayer(v)
                        end
                    end
                end
            end)
        elseif owner.spellEdit then
            owner:SetPlayer(v)
            owner:SetCursorPosition(0)
        else
            owner:SetTextColor(r, g, b)
            owner:SetText(self:GetText())
            owner:SetCursorPosition(0)
            owner.player = v.name
            owner.class = v.class
            owner.role = v.role
            owner.combatRole = v.combatRole
            owner.talent = TuanJian.talentInfo[v.name]
        end
        f:Hide()
        if TJ.lastfocus then
            TJ.lastfocus:ClearFocus()
        end
        if owner.spellEdit and owner.spellEdit:GetText() == "" and IsInRaid(1) then
            local spellID, highlightSpell
            if owner.spellEdit.spellTbl and #owner.spellEdit.spellTbl == 1 then
                spellID = owner.spellEdit.spellTbl[1]
            elseif TJ.IsWLK then
                if owner.spellEdit.spellTbl == TJ.Board_TJ1 and v.class == "PALADIN" then
                    if TuanJian.talentInfo[v.name] == 2 or TuanJian.talentInfo[v.name] == 4 then
                        spellID = 64205
                    elseif TuanJian.talentInfo[v.name] == 3 then
                        spellID = 31821
                    end
                end
            elseif TJ.IsMOP then
                if owner.spellEdit.spellTbl == TJ.Board_TJ1 then
                    if v.class == "PALADIN" then
                        spellID = 31821
                    elseif v.class == "DEATHKNIGHT" then
                        spellID = 51052
                    elseif v.class == "ROGUE" then
                        spellID = 76577
                    elseif v.class == "DRUID" then
                        spellID = 740
                    elseif v.class == "MONK" then
                        spellID = 115310
                    elseif v.class == "PRIEST" then
                        if TuanJian.talentInfo[v.name] == 1 then
                            spellID = 62618
                        elseif TuanJian.talentInfo[v.name] == 2 then
                            spellID = 64843
                        elseif TJ.Isdps(v) then
                            spellID = 15286
                        end
                    elseif v.class == "SHAMAN" then
                        if TJ.Isdps(v) then
                            highlightSpell = { 108280, 108281 }
                        elseif TJ.Ishealer(v) then
                            highlightSpell = { 98008, 114049, 108280, 108281 }
                        end
                    elseif v.class == "WARRIOR" then
                        highlightSpell = { 97462, 114203 }
                    end
                elseif owner.spellEdit.spellTbl == TJ.Board_TJ2 then
                    if v.class == "WARRIOR" then
                        spellID = 114030
                    elseif v.class == "PALADIN" then
                        spellID = 6940
                    elseif v.class == "PRIEST" then
                        if TuanJian.talentInfo[v.name] == 1 then
                            spellID = 33206
                        elseif TuanJian.talentInfo[v.name] == 2 then
                            spellID = 47788
                        end
                    elseif v.class == "DRUID" and TJ.Ishealer(v) then
                        spellID = 102342
                    elseif v.class == "MONK" and TJ.Ishealer(v) then
                        spellID = 116849
                    end
                end
            end

            if spellID then
                TJ.OnSpellLoad(spellID, function()
                    local spellIcon = C_Spell.GetSpellTexture(spellID)
                    local link = C_Spell.GetSpellLink(spellID)
                    owner.spellEdit:SetText(AddTexture(spellIcon) .. link)
                    owner.spellEdit:SetCursorPosition(0)
                end)
            else
                if highlightSpell then
                    TJ.highlightSpell = highlightSpell
                    After(0, function()
                        TJ.highlightSpell = nil
                    end)
                end
                owner.spellEdit:SetFocus()
            end
        end
    end)

    if mapIndex then
        local FB = TuanJian.FB
        local bossIndex = TuanJian.bossIndex
        local map = TJ.frame[FB][bossIndex]["map" .. mapIndex]
        for _, icon in pairs(map.icons) do
            if v.name == icon.name then
                bt:SetAlpha(.3)
                break
            end
        end
    end
end
local function AddTeamButton(owner, f, i, mapIndex)
    local bt = CreateButton(f, i)
    bt:SetText(i .. L["队"])
    bt:SetScript("OnMouseDown", function(self)
        owner:SetTeam(i)
        f:Hide()
        if TJ.lastfocus then
            TJ.lastfocus:ClearFocus()
        end
    end)

    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local map = TJ.frame[FB][bossIndex]["map" .. mapIndex]
    for _, icon in pairs(map.icons) do
        if i == icon.team then
            bt:SetAlpha(.3)
            break
        end
    end
end
local function AddListButton(owner, f, i, text)
    local bt = CreateButton(f, i)
    bt:SetText(text)
    bt:SetScript("OnMouseDown", function(self)
        owner:SetText(self:GetText())
        owner:SetCursorPosition(0)
        f:Hide()
        if TJ.lastfocus then
            TJ.lastfocus:ClearFocus()
        end
    end)
end
function TJ.ListPlayer(bt, classTbl, mapIndex, list)
    if TJ.FramePlayerList then TJ.FramePlayerList:Hide() end
    local f = CreateFrame("Frame", nil, TJ.MainFrame, "BackdropTemplate")
    f:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetBackdropColor(0, 0, 0, 0.8)
    f:SetPoint("TOPLEFT", bt, "BOTTOMLEFT", -9, 2)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f:SetFrameLevel(140)
    f.buttons = {}
    TJ.FramePlayerList = f
    if type(list) == "table" then
        for i, text in ipairs(list) do
            AddListButton(bt, f, i, text)
        end
    elseif list == "team" then
        for i = 1, 8 do
            AddTeamButton(bt, f, i, mapIndex)
        end
    else
        local tbl = TJ.SortRaidRosterInfo(classTbl)
        if next(tbl) then
            for i, v in ipairs(tbl) do
                AddButton(bt, f, i, v, mapIndex)
            end
        else
            local text
            if IsInRaid(1) then
                text = L["|cffff0000该任务只能选择以下职业\n但你团队里没有：|r\n\n"]
                for i, class in ipairs(classTbl) do
                    text = text .. "|c" .. select(4, GetClassColor(class)) .. GetClassName(class) .. "|r"
                    if i ~= #classTbl then
                        text = text .. "\n"
                    end
                end
            else
                text = L["|cffff0000需要在团队状态才能选择玩家|r\n"]
            end
            local t = f:CreateFontString()
            t:SetFont(BIAOGE_TEXT_FONT, 14, "OUTLINE")
            t:SetPoint("TOPLEFT", 8, -7)
            t:SetTextColor(1, 0.82, 0)
            t:SetText(text)
            t:SetJustifyH("LEFT")
            f:SetSize(t:GetWidth() + 16, t:GetHeight() + 15)
        end
    end
end

-- 技能列表
local function AddButton(owner, f, i, spellID)
    local width = 112
    local maxCow = 8
    local bt = CreateFrame("EditBox", nil, f, TJ.editTemplate)
    bt:SetSize(width, 20)
    bt:SetAutoFocus(false)
    if i == 1 then
        bt:SetPoint("TOPLEFT", 10, -5)
    elseif (i - 1) % maxCow == 0 then
        bt:SetPoint("TOPLEFT", f.buttons[i - maxCow], "TOPRIGHT", 7, 0)
    else
        bt:SetPoint("TOPLEFT", f.buttons[i - 1], "BOTTOMLEFT", 0, 0)
    end
    tinsert(f.buttons, bt)

    local row = i >= maxCow and maxCow or i % maxCow
    local arrange = floor((i - 1) / maxCow) + 1
    f:SetSize(arrange * width + (arrange - 1) * 7 + 15, row * 20 + 10)

    if TJ.highlightSpell then
        if not TJ.ValueInTable(TJ.highlightSpell, spellID) then
            bt:SetAlpha(.3)
        end
    end

    bt.ds = bt:CreateTexture()
    bt.ds:SetPoint("TOPLEFT", -4, -2)
    bt.ds:SetPoint("BOTTOMRIGHT", 0, 0)
    bt.ds:SetColorTexture(1, 1, 1, TJ.onEnterAlpha)
    bt.ds:Hide()

    bt:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE", 0, 0)
        GameTooltip:ClearLines()
        GameTooltip:SetPoint("TOPLEFT", f, "TOPRIGHT", -2, 0)
        if type(spellID) == "number" then
            GameTooltip:SetSpellByID(spellID)
        else
            GameTooltip:SetItemByID(tonumber(spellID))
        end
        GameTooltip:Show()
        self.ds:Show()
    end)
    bt:SetScript("OnLeave", function(self)
        GameTooltip:Hide()
        self.ds:Hide()
    end)
    bt:SetScript("OnMouseDown", function(self, enter)
        owner:SetText(AddTexture(self.icon) .. self.link)
        owner:SetCursorPosition(0)
        if TJ.lastfocus then
            TJ.lastfocus:ClearFocus()
        end
        if owner.playerEdit and owner.playerEdit:GetText() == "" and IsInRaid(1) then
            owner.playerEdit:SetFocus()
        end
    end)
    if type(spellID) == "number" then
        TJ.OnSpellLoad(spellID, function()
            local spellIcon = C_Spell.GetSpellTexture(spellID)
            local link = C_Spell.GetSpellLink(spellID)
            bt:SetText(AddTexture(spellIcon) .. link)
            bt:SetCursorPosition(0)
            bt.link = link
            bt.icon = spellIcon
        end)
    else
        local itemID = tonumber(spellID)
        local item = Item:CreateFromItemID(itemID)
        item:ContinueOnItemLoad(function()
            local _, link, _, _, _, _, _, _, _, icon = GetItemInfo(itemID)
            bt:SetText(AddTexture(icon) .. link)
            bt:SetCursorPosition(0)
            bt.link = link
            bt.icon = icon
        end)
    end
end
function TJ.ListSpell(bt, tbl)
    local f = CreateFrame("Frame", nil, TJ.MainFrame, "BackdropTemplate")
    f:SetBackdrop({
        bgFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
        edgeSize = 16,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    f:SetPoint("TOPLEFT", bt, "BOTTOMLEFT", -9, 2)
    f:SetBackdropColor(0, 0, 0, 0.8)
    f:SetWidth(130)
    f:SetHeight(8 + 22 * #tbl)
    f:SetFrameLevel(140)
    f:EnableMouse(true)
    f:SetClampedToScreen(true)
    f.buttons = {}
    TJ.FrameSpellList = f
    for i, spellID in ipairs(tbl) do
        AddButton(bt, f, i, spellID)
    end
end

function TJ.SortRaidRosterInfo(classTbl, role, filterMainassist)
    if role and role ~= "" then
        local newTbl = {}
        for _, v in ipairs(TJ.raidRosterInfo) do
            if not filterMainassist or v.role ~= "MAINASSIST" then -- 过滤主助理
                local roles
                if role:find("+") then
                    roles = { strsplit("+", role) }
                else
                    roles = { role }
                end
                for _, role in pairs(roles) do
                    if TJ["Is" .. role] and TJ["Is" .. role](v) then
                        local yes
                        if classTbl then
                            for _, class in ipairs(classTbl) do
                                if v.class == class then
                                    yes = true
                                    break
                                end
                            end
                        else
                            yes = true
                        end
                        if yes then
                            tinsert(newTbl, v)
                        end
                        break
                    end
                end
            end
        end
        return newTbl
    else
        local tbl = classTbl or {
            "DEATHKNIGHT", -- 死亡骑士,
            "PALADIN",     -- 圣骑士,
            "WARRIOR",     -- 战士,
            "EVOKER",      -- 唤魔师
            "SHAMAN",      -- 萨满祭司,
            "HUNTER",      -- 猎人,
            "DEMONHUNTER", -- 恶魔猎手
            "MONK",        -- 武僧
            "DRUID",       -- 德鲁伊,
            "ROGUE",       -- 潜行者,
            "MAGE",        -- 法师,
            "WARLOCK",     -- 术士,
            "PRIEST",      -- 牧师,
        }

        local newTbl = {}
        for _, class in ipairs(tbl) do
            for _, v in ipairs(TJ.raidRosterInfo) do
                if not filterMainassist or v.role ~= "MAINASSIST" then -- 过滤主助理
                    if v.class == class then
                        tinsert(newTbl, v)
                    end
                end
            end
        end
        return newTbl
    end
end

function TJ.GetIconAndName(v, _talent)
    local talent = TuanJian.talentInfo[v.name] or _talent
    if talent then
        return AddTexture(TJ.talentIcon[v.class][talent]) .. v.name
    elseif v.role then
        return AddTexture(v.role) .. v.name
    else
        return AddTexture(v.combatRole) .. v.name
    end
end

function TJ.GetIconFormName(name)
    local i = TJ.raidRosterName[name]
    if i then
        local v = TJ.raidRosterInfo[i]
        if v then
            local talent = TuanJian.talentInfo[v.name]
            if talent then
                return AddTexture(TJ.talentIcon[v.class][talent]) .. v.name
            elseif v.role then
                return AddTexture(v.role) .. v.name
            else
                return AddTexture(v.combatRole) .. v.name
            end
        end
    end
    return name
end

function TJ.SetEditText(v, title)
    for i, vv in ipairs(title.edits) do
        local edit = vv.edit
        if edit:GetText() == "" then
            edit:SetText(TJ.GetIconAndName(v))
            edit:SetCursorPosition(0)
            local r, g, b = GetClassColor(v.class)
            edit:SetTextColor(r, g, b)
            edit.player = v.name
            edit.class = v.class
            edit.role = v.role
            edit.combatRole = v.combatRole
            edit.talent = TuanJian.talentInfo[v.name]
            return
        end
    end
end

function TJ.SetEditTextFormNum(v, title, num)
    local edit = title.edits[num] and title.edits[num].edit
    if not (edit and edit:GetText() == "") then return end
    if type(v) == "table" then
        local r, g, b = GetClassColor(v.class)
        edit:SetText(TJ.GetIconAndName(v))
        edit:SetCursorPosition(0)
        edit:SetTextColor(r, g, b)
        edit.player = v.name
        edit.class = v.class
        edit.role = v.role
        edit.combatRole = v.combatRole
        edit.talent = TuanJian.talentInfo[v.name]
    else
        edit:SetText(v)
    end
    return true
end

function TJ.SetMapIconPlayer(v, indexMinMax, mapIndex)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    mapIndex = mapIndex or ""
    local mapName = "map" .. mapIndex
    local map = TJ.frame[FB][bossIndex][mapName]
    for i, f in ipairs(map.icons) do
        local yes = true
        if indexMinMax then
            if i < indexMinMax.min or i > indexMinMax.max then
                yes = nil
            end
        end
        if yes then
            if f:NoPlayer() then
                f:SetPlayer(v)
                return
            end
        end
    end
end

function TJ.SetMapIconPlayerFormNum(index, v, mapIndex)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    mapIndex = mapIndex or ""
    local mapName = "map" .. mapIndex
    local map = TJ.frame[FB][bossIndex][mapName]
    local f = map.icons[index]
    if f:NoPlayer() then
        f:SetPlayer(v)
    end
end

function TJ.SetMapIconTeamFormNum(index, team, mapIndex)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    mapIndex = mapIndex or ""
    local mapName = "map" .. mapIndex
    local map = TJ.frame[FB][bossIndex][mapName]
    local f = map.icons[index]
    if f:NoTeam() then
        f:SetTeam(team)
    end
end

function TJ.SetBoardEditFormNum(v, titleIndex, index, spell, id)
    local FB
    local bossIndex
    local child
    if TJ.tjMainFrame:IsVisible() and TJ.IsMOP then
        FB = "TJ"
        bossIndex = 1
        child = TJ.frame[FB][bossIndex]
    else
        FB = TuanJian.FB
        bossIndex = TuanJian.bossIndex
        id = id or 1
        child = TJ.frame[FB][bossIndex].board.child[id]
    end
    local playerEdit, spellEdit
    if not index then
        for i, v in ipairs(child.all[titleIndex].edits) do
            if v.playerEdit:GetText() == "" then
                playerEdit = v.playerEdit
                spellEdit = v.spellEdit
                break
            end
        end
    else
        playerEdit = child.all[titleIndex].edits[index].playerEdit
        spellEdit = child.all[titleIndex].edits[index].spellEdit
    end
    if not (playerEdit and playerEdit:GetText() == "") then return end
    playerEdit:SetPlayer(v)
    playerEdit:Save()
    spellEdit:SetText(spell)
    spellEdit:SetCursorPosition(0)
    spellEdit:Save()
    return true
end

-- 单棒、多轮减伤链的一键安排（MOP）
local function Board_AutoAssignMitigation(roundCount, arrange, isPhysical)
    local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
    local usedColumns = {}
    local nextSlot = {
        reduce = 1,
        heal = 1,
    }
    local function Assign(group, v, ...)
        local spellCount = select("#", ...)
        for offset = 0, roundCount - 1 do
            local slot = (nextSlot[group] + offset - 1) % roundCount + 1
            if (usedColumns[slot] or 0) + spellCount <= arrange then
                for i = 1, spellCount do
                    TJ.SetBoardEditFormNum(v, slot, nil, select(i, ...), 1)
                end
                usedColumns[slot] = (usedColumns[slot] or 0) + spellCount
                nextSlot[group] = slot % roundCount + 1
                return
            end
        end
    end

    local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
    for _, v in ipairs(tbl) do Assign("reduce", v, s2, s3) end
    local paladinRole = isPhysical and "healer" or nil
    local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, paladinRole, true)
    for _, v in ipairs(tbl) do Assign("reduce", v, s1) end
    local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "healer", true)
    for _, v in ipairs(tbl) do Assign("heal", v, s7, ns.s9, ns.s8) end
    local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
    for _, v in ipairs(tbl) do
        if TuanJian.talentInfo[v.name] == 1 then
            Assign("reduce", v, s5)
        else
            Assign("heal", v, ns.s13)
        end
    end
    if not isPhysical then
        local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
        for _, v in ipairs(tbl) do Assign("reduce", v, s4) end
    end
    local tbl = TJ.SortRaidRosterInfo({ "ROGUE" }, nil, true)
    for _, v in ipairs(tbl) do Assign("reduce", v, s6) end
    local tbl = TJ.SortRaidRosterInfo({ "SHAMAN" }, "dps", true)
    for _, v in ipairs(tbl) do Assign("heal", v, ns.s9, ns.s10) end
    local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
    for _, v in ipairs(tbl) do Assign("heal", v, ns.s12) end
    local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
    for _, v in ipairs(tbl) do Assign("heal", v, ns.s11) end
    local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "dps", true)
    for _, v in ipairs(tbl) do Assign("heal", v, ns.s14) end
end

-- 魔法伤害团减安排。
function TJ.Board_AutoAssignMitigation(roundCount, arrange)
    Board_AutoAssignMitigation(roundCount, arrange)
end

-- 物理伤害团减安排：不安排反魔法领域，虔诚光环只安排奶骑。
function TJ.Board_AutoAssignPhysicalMitigation(roundCount, arrange)
    Board_AutoAssignMitigation(roundCount, arrange, true)
end

-- 单体减伤、多轮减伤链的一键安排（MOP）
function TJ.Board_AutoAssignSingleTargetMitigation(roundCount, boardID)
    local vigilance = ns.s21
    local handOfSacrifice = ns.s22
    local painSuppression = ns.s23
    local guardianSpirit = ns.s24
    local ironbark = ns.s25
    local lifeCocoon = ns.s26
    local nextRound = 1
    local function Assign(v, spell)
        if nextRound > roundCount then return end
        if TJ.SetBoardEditFormNum(v, nextRound, 1, spell, boardID) then
            nextRound = nextRound + 1
        end
    end

    -- 输出战士：警戒。该技能为天赋，安排后仍需确认玩家已选择。
    local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, "dps", true)
    for _, v in ipairs(tbl) do Assign(v, vigilance) end

    -- 默认圣骑士选择仁慈，每人连续安排两轮牺牲之手。
    local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, "healer+dps", true)
    for _, v in ipairs(tbl) do
        Assign(v, handOfSacrifice)
        Assign(v, handOfSacrifice)
    end

    -- 恢复德鲁伊：铁木树皮。
    local tbl = TJ.SortRaidRosterInfo({ "DRUID" }, "healer", true)
    for _, v in ipairs(tbl) do Assign(v, ironbark) end

    -- 纪律牧师：痛苦压制；神圣牧师：守护之魂。
    local tbl = TJ.SortRaidRosterInfo({ "PRIEST" }, "healer", true)
    for _, v in ipairs(tbl) do
        local talent = TuanJian.talentInfo[v.name]
        if talent == 1 then
            Assign(v, painSuppression)
        elseif talent == 2 then
            Assign(v, guardianSpirit)
        end
    end

    -- 织雾武僧：作茧缚命。
    local tbl = TJ.SortRaidRosterInfo({ "MONK" }, "healer", true)
    for _, v in ipairs(tbl) do Assign(v, lifeCocoon) end
end

-- 角色职责/天赋
do
    local function GetMaxMana()
        if TJ.IsTBC then
            return 9000
        elseif TJ.IsWLK_80 then
            return 20000
        elseif TJ.IsTitan then
            return 15000
        elseif TJ.IsMOP then
            return 150000
        end
    end
    function TJ.Istank(v)
        local talent = v.talent or TuanJian.talentInfo[v.name]
        if talent then
            local role = TJ.talentToCombatRole[v.class] and TJ.talentToCombatRole[v.class][talent].role
            if role == "TANK" then
                return true
            elseif v.class == "DRUID" then
                if TJ.IsWLK then
                    if talent == 2 and v.combatRole == "TANK" then
                        return true
                    end
                end
            end
        else
            if v.role == "MAINTANK" or v.combatRole == "TANK" then
                return true
            end
        end
    end

    function TJ.Isdps(v)
        local talent = v.talent or TuanJian.talentInfo[v.name]
        if talent then
            local role = TJ.talentToCombatRole[v.class] and TJ.talentToCombatRole[v.class][talent].role
            if role == "DAMAGER" then
                return true
            elseif v.class == "DRUID" then
                if TJ.IsWLK then
                    if talent == 2 and v.combatRole == "DAMAGER" then
                        return true
                    end
                end
            end
        else
            if v.role ~= "MAINTANK" and v.combatRole == "DAMAGER" then
                return true
            end
        end
    end

    -- 近战
    function TJ.Isdps1(v)
        local talent = v.talent or TuanJian.talentInfo[v.name]
        if talent then
            local dps = TJ.talentToCombatRole[v.class] and TJ.talentToCombatRole[v.class][talent].dps
            if dps == 1 then
                return true
            elseif v.class == "DRUID" then
                if TJ.IsWLK then
                    if talent == 2 and v.combatRole == "DAMAGER" then
                        return true
                    end
                end
            end
        else
            if (v.class == "SHAMAN" or v.class == "DRUID") and UnitPowerMax(v.name, 0) < GetMaxMana() and v.combatRole == "DAMAGER" then
                return true
            end
            if v.role ~= "MAINTANK" and v.combatRole == "DAMAGER" and
                (v.class == "DEATHKNIGHT" or v.class == "PALADIN" or v.class == "WARRIOR" or v.class == "ROGUE") then
                return true
            end
        end
    end

    -- 远程
    function TJ.Isdps2(v)
        local talent = v.talent or TuanJian.talentInfo[v.name]
        if talent then
            local dps = TJ.talentToCombatRole[v.class] and TJ.talentToCombatRole[v.class][talent].dps
            if dps == 2 then
                return true
            end
        else
            if (v.class == "SHAMAN" or v.class == "DRUID") and (UnitPowerMax(v.name, 0) >= GetMaxMana() and v.combatRole == "DAMAGER") then
                return true
            end
            if v.role ~= "MAINTANK" and v.combatRole == "DAMAGER" and
                (v.class == "HUNTER" or v.class == "MAGE" or v.class == "WARLOCK" or v.class == "PRIEST") then
                return true
            end
        end
    end

    function TJ.Ishealer(v)
        local talent = v.talent or TuanJian.talentInfo[v.name]
        if talent then
            local role = TJ.talentToCombatRole[v.class] and TJ.talentToCombatRole[v.class][talent].role
            if role == "HEALER" then
                return true
            end
        else
            if v.role ~= "MAINTANK" and v.combatRole == "HEALER" then
                return true
            end
        end
    end
end

function TJ.CreateButton(parent)
    local blackup = CreateColor(.3, .3, .3, .7)
    local blackdown = CreateColor(0, 0, 0, .7)

    local classColorup = CreateColor(r, g, b, .7)
    local classColordown = CreateColor(r, g, b, .1)

    local disColorup = CreateColor(.5, .5, .5, .7)
    local disColordown = CreateColor(0, 0, 0, .3)

    local borderAlpha = 1

    local bt = CreateFrame("Button", nil, parent, "BackdropTemplate")
    bt:SetBackdrop({
        edgeFile = "Interface/ChatFrame/ChatFrameBackground",
        edgeSize = 1,
    })
    bt:SetBackdropBorderColor(0, 0, 0, borderAlpha)
    bt.bg = bt:CreateTexture(nil, "BACKGROUND")
    bt.bg:SetAllPoints()
    bt.bg:SetTexture("Interface\\Buttons\\WHITE8x8")
    bt.bg:SetGradient("VERTICAL", blackdown, blackup)
    local t = bt:CreateFontString()
    t:SetAllPoints()
    t:SetTextColor(1, .82, 0)
    t:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
    bt:SetFontString(t)

    hooksecurefunc(bt, "SetScript", function(arg1, arg2, ...)
        if arg2 == "OnEnter" then
            bt:HookScript("OnEnter", function()
                bt.bg:SetGradient("VERTICAL", classColordown, classColorup)
                bt:SetBackdropBorderColor(r, g, b, borderAlpha)
                bt:GetFontString():SetTextColor(1, 1, 1)
            end)
        elseif arg2 == "OnLeave" then
            bt:HookScript("OnLeave", function()
                GameTooltip:Hide()
                bt.bg:SetGradient("VERTICAL", blackdown, blackup)
                bt:SetBackdropBorderColor(0, 0, 0, borderAlpha)
                bt:GetFontString():SetTextColor(1, .82, 0)
            end)
        end
    end)
    hooksecurefunc(bt, "SetEnabled", function(arg1, arg2, ...)
        if arg2 == true then
            bt.bg:SetGradient("VERTICAL", blackdown, blackup)
            bt:GetFontString():SetTextColor(1, .82, 0)
        elseif arg2 == false then
            bt.bg:SetGradient("VERTICAL", disColordown, disColorup)
            bt:GetFontString():SetTextColor(.5, .5, .5)
        end
    end)
    function bt:Disable()
        self:SetEnabled(false)
    end

    function bt:Enable()
        self:SetEnabled(true)
    end

    bt:SetScript("OnEnter", nil)
    bt:SetScript("OnLeave", nil)
    return bt
end

-- 聊天长度按字节计算；链接整体换行，避免截断链接和中文字符。
function TJ.SplitChatMessage(text, prefix)
    prefix = prefix or ""
    if #prefix + #text <= 255 then
        return text ~= "" and { prefix .. text } or {}
    end
    local limit = 255 - #prefix
    local messages, parts = {}, {}
    local length = 0
    local function Append(token)
        if length + #token > limit then
            messages[#messages + 1] = prefix .. table.concat(parts)
            parts, length = {}, 0
        end
        parts[#parts + 1] = token
        length = length + #token
    end
    local i = 1
    while i <= #text do
        local rest = text:sub(i)
        local link = rest:match("^|c%x%x%x%x%x%x%x%x|H.-|h.-|h|r")
            or rest:match("^|H.-|h.-|h")
        if link then
            if #link <= limit then
                Append(link)
            else
                -- 极长链接改用显示文本，仍保留技能或物品名称。
                local label = link:match("|h(.-)|h") or ""
                text = text:sub(1, i - 1) .. label .. text:sub(i + #link)
                link = ""
            end
            i = i + #link
        elseif rest:match("^|c%x%x%x%x%x%x%x%x") then
            i = i + 10
        elseif rest:sub(1, 2) == "|r" then
            i = i + 2
        else
            local byte = text:byte(i)
            local size = byte >= 240 and 4 or byte >= 224 and 3 or byte >= 192 and 2 or 1
            Append(text:sub(i, i + size - 1))
            i = i + size
        end
    end
    if length > 0 then
        messages[#messages + 1] = prefix .. table.concat(parts)
    end
    return messages
end

function TJ.SendMsgToRaid(tbl)
    local sendCD = TJ.sendCD2
    local t = 0
    local function GetChannel()
        for _, v in ipairs(TJ.raidRosterInfo) do
            if v.name == player then
                if v.rank == 2 or v.rank == 1 then
                    return TuanJian.options.sendChannel
                else
                    return "RAID"
                end
            end
        end
    end
    local channel = GetChannel()
    for i, texts in ipairs(tbl) do
        for _, text in ipairs(texts) do
            for _, message in ipairs(TJ.SplitChatMessage(text)) do
                After(t, function()
                    SendChatMessage(message, i == 1 and channel or "RAID")
                end)
                t = t + sendCD
            end
        end
    end
    return t
end

function TJ.UpdateMainFrameSize()
    if not TJ.UpdateMainFrameSizeFrame then
        TJ.UpdateMainFrameSizeFrame = CreateFrame("Frame")
    end
    local f = TJ.UpdateMainFrameSizeFrame
    f:SetScript("OnUpdate", nil)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local h1 = floor(TJ.MainFrame:GetHeight())
    local w1 = floor(TJ.MainFrame:GetWidth())
    local h2 = TJ.FBinfo[FB][bossIndex].height
    local w2 = TJ.FBinfo[FB][bossIndex].width
    if TJ.tjMainFrame:IsVisible() then
        w2 = TJ.IsMOP and 930 or 650
    elseif TJ.dpsMainFrame:IsVisible() then
        w2 = 930
    end
    local TIME = .5
    local addW = max(w1, w2) - min(w1, w2)
    local addH = max(h1, h2) - min(h1, h2)
    if addW <= 5 and addH <= 5 then
        TJ.MainFrame:SetSize(w2, h2)
        return
    end
    if w1 > w2 then
        addW = -addW
    end
    if h1 > h2 then
        addH = -addH
    end
    f.t = 0
    f:SetScript("OnUpdate", function(self, t)
        self.t = self.t + t
        local per = self.t / TIME
        if per >= 1 then
            per = 1
        end
        TJ.MainFrame:SetWidth(w1 + addW * per)
        TJ.MainFrame:SetHeight(h1 + addH * per)
        if per >= 1 then
            self:SetScript("OnUpdate", nil)
        end
    end)
end

function TJ.ClearCode(text, onlyClearTex, notdo)
    if notdo then return text end
    if onlyClearTex then
        return text:gsub("|T.-|t", ""):gsub("|A.-|a", "")
    else
        return text:gsub("|T.-|t", ""):gsub("|A.-|a", ""):gsub("|cff......", ""):gsub("|r", "")
    end
end

function TJ.GetRaidPoint()
    local team = {}
    for _, v in pairs(TJ.raidRosterInfo) do
        if v.name then
            local name = v.name
            if not team[v.subgroup] then
                team[v.subgroup] = {}
            end
            tinsert(team[v.subgroup], name)
        end
    end

    local point = {}
    for subgroup in pairs(team) do
        for i, name in ipairs(team[subgroup]) do
            point[name] = subgroup .. "-" .. i
        end
    end
    return point
end

function TJ.GetRaidPointIndexByGUID()
    local team = {}
    for _, v in pairs(TJ.raidRosterInfo) do
        if v.guid then
            if not team[v.subgroup] then
                team[v.subgroup] = {}
            end
            tinsert(team[v.subgroup], v.guid)
        end
    end
    local point = {}
    local index = 0
    for subgroup in pairs(team) do
        for i, guid in ipairs(team[subgroup]) do
            index = index + 1
            point[guid] = index
        end
    end
    return point
end

function TJ.GetRaidPointByTeam(teamIndex)
    local team = {}
    for _, v in pairs(TJ.raidRosterInfo) do
        if v and v.subgroup == teamIndex then
            tinsert(team, v)
        end
    end
    return next(team) and team or nil
end

function TJ.SecondsToTime(time, type)
    if not time then return "" end
    local text = ""
    if not type then
        local m, s = math.modf(time / 60)
        s = format("%02d", s * 60)
        text = m .. ":" .. s
    elseif type == 2 then
        local ss = tostring(time):match("%.(%d+)")
        local m, s = math.modf(time / 60)
        if tostring(m):len() == 1 then
            m = "0" .. m
        end
        s = format("%02d", s * 60)
        text = m .. ":" .. s .. "." .. ss
    end
    return text
end

function TJ.Copy(table)
    if type(table) == "table" then
        local t = {}
        for k, v in pairs(table) do
            if type(v) == "table" then
                t[k] = TJ.Copy(v) -- 递归拷贝子表
            else
                t[k] = v
            end
        end
        return t
    else
        return table
    end
end

function TJ.SetSchoolColor(schoolID, spellName)
    if not schoolID then return spellName end
    local tbl = {
        [1] = { code = "FFFF00", color = { 255, 255, 0 } },    --Physical 物理
        [2] = { code = "FFE680", color = { 255, 230, 128 } },  --Holy 神圣	
        [4] = { code = "FF8000", color = { 255, 128, 0 } },    --Fire 火	
        [8] = { code = "4DFF4D", color = { 77, 255, 77 } },    --Nature 自然
        [16] = { code = "80FFFF", color = { 128, 255, 255 } }, --Frost 冰	
        [32] = { code = "8080FF", color = { 128, 128, 255 } }, --Shadow 暗	
        [64] = { code = "FF80FF", color = { 255, 128, 255 } }, --Arcane 奥	
    }
    if tbl[schoolID] then
        return "|cff" .. tbl[schoolID].code .. spellName .. "|r"
    else
        return spellName
    end
end

function TJ.MainFrameIsInRight()
    if TJ.MainFrame:GetCenter() > UIParent:GetWidth() * 0.5 + 10 then
        return true
    end
end

function TJ.InsertLink(text)
    if not GetCurrentKeyBoardFocus() then
        local edit = ChatEdit_ChooseBoxForSend()
        edit:SetText("")
        ChatEdit_ActivateChat(edit)
    end
    ChatEdit_InsertLink(text)
end

function TJ.OnEnterDelay(self, func, delay)
    delay = delay or .2
    self:SetScript("OnEnter", function(self)
        self.isOnEnter = true
        if func then
            self.t = 0
            self:SetScript("OnUpdate", function(self, t)
                self.t = self.t + t
                if self.t >= delay then
                    self:SetScript("OnUpdate", nil)
                    func(self)
                end
            end)
        end
    end)
end

function TJ.OnLeaveDelay(self, func)
    self:SetScript("OnLeave", function(self)
        self.isOnEnter = false
        self:SetScript("OnUpdate", nil)
        GameTooltip:Hide()
        TuanJianTooltip2:Hide()
        if func then
            func(self)
        end
    end)
end

function TJ.Tooltip_SetItemByLink(link)
    TuanJianTooltip:SetOwner(UIParent, "ANCHOR_NONE")
    TuanJianTooltip:ClearLines()
    TuanJianTooltip:SetHyperlink(link)
end

-- 滚动框
do
    function TJ.CreateScrollFrame(parent, w, h, isEdit, alwaysHide)
        local f = CreateFrame("Frame", nil, parent, "BackdropTemplate")
        f:SetBackdrop({
            bgFile = "Interface/ChatFrame/ChatFrameBackground",
            edgeFile = "Interface/Tooltips/UI-Tooltip-Border",
            edgeSize = 16,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        f:SetBackdropColor(0, 0, 0, 0.8)
        f:SetBackdropBorderColor(0, 0, 0, 0)
        if w and h then
            f:SetSize(w, h)
        end
        f:EnableMouse(true)

        local scroll = CreateFrame("ScrollFrame", nil, f, TJ.scrollTemplate)
        scroll:SetWidth(f:GetWidth() - 31)
        scroll:SetHeight(f:GetHeight() - 9)
        scroll:SetPoint("TOPLEFT", f, "TOPLEFT", 5, -5)
        scroll.ScrollBar.scrollStep = TJ.scrollStep
        f.scroll = scroll
        TJ.CreateSrollBarBackdrop(scroll.ScrollBar)
        TJ.HookScrollBarShowOrHide(scroll, alwaysHide)

        local child
        if isEdit then
            child = CreateFrame("EditBox", nil, scroll)
            child:SetWidth(scroll:GetWidth())
            child:SetHeight(scroll:GetHeight())
            child:SetAutoFocus(false)
            child:EnableMouse(false)
            child:SetMultiLine(true)
            child:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
        else
            child = CreateFrame("Frame", nil, scroll)
            child:SetWidth(scroll:GetWidth())
            child:SetHeight(scroll:GetHeight())
        end
        scroll:SetScrollChild(child)

        return f, child
    end
end

------------------现代滚动框模板------------------
do
    local c1 = { .4, .4, .4, .5 }
    local c2 = { .8, .8, .8, .5 }

    local function SetModernScrollThumbButtonColor(self, color)
        self.Top:SetColorTexture(unpack(color))
        self.Middle:SetColorTexture(unpack(color))
        self.Bottom:SetColorTexture(unpack(color))
    end

    function TuanJian_ModernScrollThumbButton_UpdateShape(self)
        local textureWidth = self.textureWidth or 8
        local radius = math.min(textureWidth / 2, self:GetHeight() / 2)

        self.Top:ClearAllPoints()
        self.Top:SetSize(textureWidth, radius)
        self.Top:SetPoint("TOP")

        self.Middle:ClearAllPoints()
        self.Middle:SetWidth(textureWidth)
        self.Middle:SetPoint("TOP", 0, -radius)
        self.Middle:SetPoint("BOTTOM", 0, radius)

        self.Bottom:ClearAllPoints()
        self.Bottom:SetSize(textureWidth, radius)
        self.Bottom:SetPoint("BOTTOM")

        if self.TopMask then
            self.TopMask:ClearAllPoints()
            self.TopMask:SetSize(textureWidth, radius * 2)
            self.TopMask:SetPoint("CENTER", self.Top, "BOTTOM")

            self.BottomMask:ClearAllPoints()
            self.BottomMask:SetSize(textureWidth, radius * 2)
            self.BottomMask:SetPoint("CENTER", self.Bottom, "TOP")
        end
    end

    function TuanJian_ModernScrollThumbButton_UpdatePosition(bar)
        local thumbButton = bar.ThumbButton
        if not thumbButton then return end

        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local ratio = 0
        if valueRange > 0 then
            ratio = (bar:GetValue() - minValue) / valueRange
        end

        local travel = math.max(0, bar:GetHeight() - 4 - thumbButton:GetHeight())
        thumbButton:ClearAllPoints()
        thumbButton:SetPoint("TOP", bar, "TOP", 0, -2 - travel * ratio)
    end

    function TuanJian_ModernScrollFrameTemplate_Update(self)
        local bar = self.ScrollBar
        if not bar then return end

        local trackHeight = bar:GetHeight() - 4
        if trackHeight <= 0 then return end

        local visibleExtent
        local totalExtent
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            visibleExtent = self.modernVisibleExtent
            totalExtent = self.modernTotalExtent
        else
            visibleExtent = self:GetHeight()
            totalExtent = visibleExtent + self:GetVerticalScrollRange()
        end

        local thumbHeight = trackHeight
        if totalExtent and totalExtent > 0 then
            thumbHeight = trackHeight * math.min(1, visibleExtent / totalExtent)
        end

        local minThumbHeight = self.minThumbHeight or 24
        thumbHeight = math.max(math.min(minThumbHeight, trackHeight), thumbHeight)
        thumbHeight = math.min(trackHeight, thumbHeight)
        bar:GetThumbTexture():SetHeight(thumbHeight)
        if bar.ThumbButton then
            bar.ThumbButton:SetWidth(bar:GetWidth())
            bar.ThumbButton:SetHeight(thumbHeight)
            TuanJian_ModernScrollThumbButton_UpdateShape(bar.ThumbButton)
            TuanJian_ModernScrollThumbButton_UpdatePosition(bar)
        end

        local _, maxValue = bar:GetMinMaxValues()
        local noOverflow
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            noOverflow = self.modernTotalExtent <= self.modernVisibleExtent
        else
            noOverflow = maxValue <= 1
        end
        if self.alwaysHideScrollBar or noOverflow then
            bar:Hide()
        else
            bar:Show()
        end
    end

    function TuanJian_ModernScrollFrameTemplate_SetScrollExtent(self, visibleExtent, totalExtent)
        self.modernVisibleExtent = visibleExtent
        self.modernTotalExtent = totalExtent
        TuanJian_ModernScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernScrollFrameTemplate_ClearScrollExtent(self)
        self.modernVisibleExtent = nil
        self.modernTotalExtent = nil
        TuanJian_ModernScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernScrollFrameTemplate_OnLoad(self)
        self:EnableMouse(true)
        self:EnableMouseWheel(true)
        self.SetScrollExtent = TuanJian_ModernScrollFrameTemplate_SetScrollExtent
        self.ClearScrollExtent = TuanJian_ModernScrollFrameTemplate_ClearScrollExtent
        self.ScrollBar.scrollStep = BG.scrollStep
        TuanJian_ModernScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernScrollFrameTemplate_OnScrollRangeChanged(self, xRange, yRange)
        if self.modernVisibleExtent ~= nil then
            TuanJian_ModernScrollFrameTemplate_Update(self)
            return
        end

        local bar = self.ScrollBar
        yRange = math.max(0, yRange or 0)

        self.modernScrollSyncing = true
        bar:SetMinMaxValues(0, yRange)
        local value = math.min(bar:GetValue(), yRange)
        bar:SetValue(value)
        self:SetVerticalScroll(value)
        self.modernScrollSyncing = nil

        TuanJian_ModernScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernScrollFrameTemplate_OnVerticalScroll(self, offset)
        if self.modernVisibleExtent ~= nil then return end
        if self.modernScrollSyncing then return end
        self.modernScrollSyncing = true
        self.ScrollBar:SetValue(offset)
        self.modernScrollSyncing = nil
    end

    function TuanJian_ModernScrollFrameTemplate_OnMouseWheel(self, delta)
        local bar = self.ScrollBar
        local minValue, maxValue = bar:GetMinMaxValues()
        local value = bar:GetValue() - delta * (bar.scrollStep or BG.scrollStep or 20)
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function TuanJian_ModernScrollBarTemplate_OnLoad(self)
        self:SetMinMaxValues(0, 0)
        self:SetValue(0)
        self:SetValueStep(1)
        self:EnableMouseWheel(true)
        self:Hide()
    end

    function TuanJian_ModernScrollBarTemplate_OnValueChanged(self, value)
        local scroll = self:GetParent()
        TuanJian_ModernScrollThumbButton_UpdatePosition(self)
        if scroll.modernVisibleExtent ~= nil then return end
        if scroll.modernScrollSyncing then return end
        scroll.modernScrollSyncing = true
        scroll:SetVerticalScroll(value)
        scroll.modernScrollSyncing = nil
    end

    function TuanJian_ModernScrollBarTemplate_OnMouseWheel(self, delta)
        TuanJian_ModernScrollFrameTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function TuanJian_ModernScrollBarTemplate_OnEnter(self)
        -- self:GetThumbTexture():SetColorTexture(unpack(c2))
    end

    function TuanJian_ModernScrollBarTemplate_OnLeave(self)
        -- self:GetThumbTexture():SetColorTexture(unpack(c1))
    end

    function TuanJian_ModernScrollTrackButton_OnLoad(self)
        self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1)
        self:EnableMouseWheel(true)
    end

    function TuanJian_ModernScrollTrackButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local bar = self:GetParent()
        local thumbButton = bar.ThumbButton
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = bar:GetHeight() - 4 - thumbButton:GetHeight()
        local top = bar:GetTop()
        if travel <= 0 or valueRange <= 0 or not top then return end

        local _, cursorY = GetCursorPosition()
        cursorY = cursorY / bar:GetEffectiveScale()
        local ratio = (top - 2 - thumbButton:GetHeight() / 2 - cursorY) / travel
        ratio = math.max(0, math.min(ratio, 1))
        bar:SetValue(minValue + ratio * valueRange)
    end

    function TuanJian_ModernScrollTrackButton_OnMouseWheel(self, delta)
        TuanJian_ModernScrollBarTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    local function ModernScrollThumbButton_StopDragging(self)
        self.modernDragging = nil
        self.modernStartCursorY = nil
        self.modernStartValue = nil
        self:SetScript("OnUpdate", nil)
        SetModernScrollThumbButtonColor(self, self:IsMouseOver() and c2 or c1)
    end

    local function ModernScrollThumbButton_OnUpdate(self)
        if not IsMouseButtonDown("LeftButton") then
            ModernScrollThumbButton_StopDragging(self)
            return
        end

        local bar = self:GetParent()
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = (bar:GetHeight() - 4 - self:GetHeight()) * bar:GetEffectiveScale()
        if travel <= 0 or valueRange <= 0 then return end

        local _, cursorY = GetCursorPosition()
        local deltaY = cursorY - self.modernStartCursorY
        local value = self.modernStartValue - deltaY / travel * valueRange
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function TuanJian_ModernScrollThumbButton_OnLoad(self)
        local bar = self:GetParent()
        self:SetFrameLevel(bar:GetFrameLevel() + 2)
        self:SetWidth(bar:GetWidth())

        self.TopMask = self:CreateMaskTexture()
        self.TopMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Top:AddMaskTexture(self.TopMask)

        self.BottomMask = self:CreateMaskTexture()
        self.BottomMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Bottom:AddMaskTexture(self.BottomMask)

        TuanJian_ModernScrollThumbButton_UpdateShape(self)
        TuanJian_ModernScrollThumbButton_UpdatePosition(bar)
        SetModernScrollThumbButtonColor(self, c1)
    end

    function TuanJian_ModernScrollThumbButton_OnEnter(self)
        if not self.modernDragging then
            SetModernScrollThumbButtonColor(self, c2)
        end
    end

    function TuanJian_ModernScrollThumbButton_OnLeave(self)
        if not self.modernDragging then
            SetModernScrollThumbButtonColor(self, c1)
        end
    end

    function TuanJian_ModernScrollThumbButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local _, cursorY = GetCursorPosition()
        self.modernDragging = true
        self.modernStartCursorY = cursorY
        self.modernStartValue = self:GetParent():GetValue()
        self:SetScript("OnUpdate", ModernScrollThumbButton_OnUpdate)
    end

    function TuanJian_ModernScrollThumbButton_OnMouseUp(self, button)
        if button == "LeftButton" and self.modernDragging then
            ModernScrollThumbButton_StopDragging(self)
        end
    end

    local function SetModernHorizontalScrollThumbButtonColor(self, color)
        self.Left:SetColorTexture(unpack(color))
        self.Middle:SetColorTexture(unpack(color))
        self.Right:SetColorTexture(unpack(color))
    end

    function TuanJian_ModernHorizontalScrollThumbButton_UpdateShape(self)
        local textureHeight = self.textureHeight or 8
        local radius = math.min(textureHeight / 2, self:GetWidth() / 2)

        self.Left:ClearAllPoints()
        self.Left:SetSize(radius, textureHeight)
        self.Left:SetPoint("LEFT")

        self.Middle:ClearAllPoints()
        self.Middle:SetHeight(textureHeight)
        self.Middle:SetPoint("LEFT", radius, 0)
        self.Middle:SetPoint("RIGHT", -radius, 0)

        self.Right:ClearAllPoints()
        self.Right:SetSize(radius, textureHeight)
        self.Right:SetPoint("RIGHT")

        if self.LeftMask then
            self.LeftMask:ClearAllPoints()
            self.LeftMask:SetSize(radius * 2, textureHeight)
            self.LeftMask:SetPoint("CENTER", self.Left, "RIGHT")

            self.RightMask:ClearAllPoints()
            self.RightMask:SetSize(radius * 2, textureHeight)
            self.RightMask:SetPoint("CENTER", self.Right, "LEFT")
        end
    end

    function TuanJian_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
        local thumbButton = bar.ThumbButton
        if not thumbButton then return end

        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local ratio = 0
        if valueRange > 0 then
            ratio = (bar:GetValue() - minValue) / valueRange
        end

        local travel = math.max(0, bar:GetWidth() - 4 - thumbButton:GetWidth())
        thumbButton:ClearAllPoints()
        thumbButton:SetPoint("LEFT", bar, "LEFT", 2 + travel * ratio, 0)
    end

    function TuanJian_ModernHorizontalScrollFrameTemplate_Update(self)
        local bar = self.ScrollBar
        if not bar then return end

        local trackWidth = bar:GetWidth() - 4
        if trackWidth <= 0 then return end

        local visibleExtent
        local totalExtent
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            visibleExtent = self.modernVisibleExtent
            totalExtent = self.modernTotalExtent
        else
            visibleExtent = self:GetWidth()
            totalExtent = visibleExtent + self:GetHorizontalScrollRange()
        end

        local thumbWidth = trackWidth
        if totalExtent and totalExtent > 0 then
            thumbWidth = trackWidth * math.min(1, visibleExtent / totalExtent)
        end

        local minThumbWidth = self.minThumbWidth or 24
        thumbWidth = math.max(math.min(minThumbWidth, trackWidth), thumbWidth)
        thumbWidth = math.min(trackWidth, thumbWidth)
        bar:GetThumbTexture():SetWidth(thumbWidth)
        if bar.ThumbButton then
            bar.ThumbButton:SetWidth(thumbWidth)
            bar.ThumbButton:SetHeight(bar:GetHeight())
            TuanJian_ModernHorizontalScrollThumbButton_UpdateShape(bar.ThumbButton)
            TuanJian_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
        end

        local _, maxValue = bar:GetMinMaxValues()
        local noOverflow
        if self.modernVisibleExtent ~= nil and self.modernTotalExtent ~= nil then
            noOverflow = self.modernTotalExtent <= self.modernVisibleExtent
        else
            noOverflow = maxValue <= 1
        end
        if self.alwaysHideScrollBar or noOverflow then
            bar:Hide()
        else
            bar:Show()
        end
    end

    function TuanJian_ModernHorizontalScrollFrameTemplate_SetScrollExtent(self, visibleExtent, totalExtent)
        self.modernVisibleExtent = visibleExtent
        self.modernTotalExtent = totalExtent
        TuanJian_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernHorizontalScrollFrameTemplate_ClearScrollExtent(self)
        self.modernVisibleExtent = nil
        self.modernTotalExtent = nil
        TuanJian_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernHorizontalScrollFrameTemplate_OnLoad(self)
        self:EnableMouse(true)
        self:EnableMouseWheel(true)
        self.SetScrollExtent = TuanJian_ModernHorizontalScrollFrameTemplate_SetScrollExtent
        self.ClearScrollExtent = TuanJian_ModernHorizontalScrollFrameTemplate_ClearScrollExtent
        self.ScrollBar.scrollStep = BG.scrollStep
        TuanJian_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernHorizontalScrollFrameTemplate_OnScrollRangeChanged(self, xRange, yRange)
        if self.modernVisibleExtent ~= nil then
            TuanJian_ModernHorizontalScrollFrameTemplate_Update(self)
            return
        end

        local bar = self.ScrollBar
        xRange = math.max(0, xRange or 0)

        self.modernScrollSyncing = true
        bar:SetMinMaxValues(0, xRange)
        local value = math.min(bar:GetValue(), xRange)
        bar:SetValue(value)
        self:SetHorizontalScroll(value)
        self.modernScrollSyncing = nil

        TuanJian_ModernHorizontalScrollFrameTemplate_Update(self)
    end

    function TuanJian_ModernHorizontalScrollFrameTemplate_OnHorizontalScroll(self, offset)
        if self.modernVisibleExtent ~= nil then return end
        if self.modernScrollSyncing then return end
        self.modernScrollSyncing = true
        self.ScrollBar:SetValue(offset)
        self.modernScrollSyncing = nil
    end

    function TuanJian_ModernHorizontalScrollFrameTemplate_OnMouseWheel(self, delta)
        local bar = self.ScrollBar
        local minValue, maxValue = bar:GetMinMaxValues()
        local value = bar:GetValue() - delta * (bar.scrollStep or BG.scrollStep or 20)
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function TuanJian_ModernHorizontalScrollBarTemplate_OnLoad(self)
        self:SetMinMaxValues(0, 0)
        self:SetValue(0)
        self:SetValueStep(1)
        self:EnableMouseWheel(true)
        self:Hide()
    end

    function TuanJian_ModernHorizontalScrollBarTemplate_OnValueChanged(self, value)
        local scroll = self:GetParent()
        TuanJian_ModernHorizontalScrollThumbButton_UpdatePosition(self)
        if scroll.modernVisibleExtent ~= nil then return end
        if scroll.modernScrollSyncing then return end
        scroll.modernScrollSyncing = true
        scroll:SetHorizontalScroll(value)
        scroll.modernScrollSyncing = nil
    end

    function TuanJian_ModernHorizontalScrollBarTemplate_OnMouseWheel(self, delta)
        TuanJian_ModernHorizontalScrollFrameTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function TuanJian_ModernHorizontalScrollTrackButton_OnLoad(self)
        self:SetFrameLevel(self:GetParent():GetFrameLevel() + 1)
        self:EnableMouseWheel(true)
    end

    function TuanJian_ModernHorizontalScrollTrackButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local bar = self:GetParent()
        local thumbButton = bar.ThumbButton
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = bar:GetWidth() - 4 - thumbButton:GetWidth()
        local left = bar:GetLeft()
        if travel <= 0 or valueRange <= 0 or not left then return end

        local cursorX = GetCursorPosition()
        cursorX = cursorX / bar:GetEffectiveScale()
        local ratio = (cursorX - left - 2 - thumbButton:GetWidth() / 2) / travel
        ratio = math.max(0, math.min(ratio, 1))
        bar:SetValue(minValue + ratio * valueRange)
    end

    function TuanJian_ModernHorizontalScrollTrackButton_OnMouseWheel(self, delta)
        TuanJian_ModernHorizontalScrollBarTemplate_OnMouseWheel(self:GetParent(), delta)
    end

    function TuanJian_ModernHorizontalScrollBarTemplate_OnSizeChanged(self)
        TuanJian_ModernHorizontalScrollFrameTemplate_Update(self:GetParent())
    end

    local function ModernHorizontalScrollThumbButton_StopDragging(self)
        self.modernDragging = nil
        self.modernStartCursorX = nil
        self.modernStartValue = nil
        self:SetScript("OnUpdate", nil)
        SetModernHorizontalScrollThumbButtonColor(self, self:IsMouseOver() and c2 or c1)
    end

    local function ModernHorizontalScrollThumbButton_OnUpdate(self)
        if not IsMouseButtonDown("LeftButton") then
            ModernHorizontalScrollThumbButton_StopDragging(self)
            return
        end

        local bar = self:GetParent()
        local minValue, maxValue = bar:GetMinMaxValues()
        local valueRange = maxValue - minValue
        local travel = (bar:GetWidth() - 4 - self:GetWidth()) * bar:GetEffectiveScale()
        if travel <= 0 or valueRange <= 0 then return end

        local cursorX = GetCursorPosition()
        local deltaX = cursorX - self.modernStartCursorX
        local value = self.modernStartValue + deltaX / travel * valueRange
        bar:SetValue(math.max(minValue, math.min(value, maxValue)))
    end

    function TuanJian_ModernHorizontalScrollThumbButton_OnLoad(self)
        local bar = self:GetParent()
        self:SetFrameLevel(bar:GetFrameLevel() + 2)
        self:SetHeight(bar:GetHeight())

        self.LeftMask = self:CreateMaskTexture()
        self.LeftMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Left:AddMaskTexture(self.LeftMask)

        self.RightMask = self:CreateMaskTexture()
        self.RightMask:SetTexture("Interface/CharacterFrame/TempPortraitAlphaMaskSmall")
        self.Right:AddMaskTexture(self.RightMask)

        TuanJian_ModernHorizontalScrollThumbButton_UpdateShape(self)
        TuanJian_ModernHorizontalScrollThumbButton_UpdatePosition(bar)
        SetModernHorizontalScrollThumbButtonColor(self, c1)
    end

    function TuanJian_ModernHorizontalScrollThumbButton_OnEnter(self)
        if not self.modernDragging then
            SetModernHorizontalScrollThumbButtonColor(self, c2)
        end
    end

    function TuanJian_ModernHorizontalScrollThumbButton_OnLeave(self)
        if not self.modernDragging then
            SetModernHorizontalScrollThumbButtonColor(self, c1)
        end
    end

    function TuanJian_ModernHorizontalScrollThumbButton_OnMouseDown(self, button)
        if button ~= "LeftButton" then return end

        local cursorX = GetCursorPosition()
        self.modernDragging = true
        self.modernStartCursorX = cursorX
        self.modernStartValue = self:GetParent():GetValue()
        self:SetScript("OnUpdate", ModernHorizontalScrollThumbButton_OnUpdate)
    end

    function TuanJian_ModernHorizontalScrollThumbButton_OnMouseUp(self, button)
        if button == "LeftButton" and self.modernDragging then
            ModernHorizontalScrollThumbButton_StopDragging(self)
        end
    end
end

function TJ.SetEditBaseClass(edit)
    edit:SetScript("OnEscapePressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEnterPressed", function(self)
        self:ClearFocus()
    end)
    edit:HookScript("OnEditFocusGained", function(self)
        TJ.lastfocus = self
    end)
    edit:HookScript("OnEditFocusLost", function(self)
        self:ClearHighlightText()
    end)
    edit:HookScript("OnMouseDown", function(self, button)
        if button == "RightButton" then
            self:SetEnabled(false)
            self:SetText("")
        end
    end)
    edit:HookScript("OnMouseUp", function(self, enter)
        if enter == "RightButton" then
            self:SetEnabled(true)
        end
    end)
end

function TJ.AddIconBySpellID(spellID)
    local spellIcon = C_Spell.GetSpellTexture(spellID)
    return AddTexture(spellIcon)
end

function TJ.ValueInTable(tbl, value)
    for k, v in pairs(tbl) do
        if v == value then
            return true
        end
    end
end

local lastNum = 0
function TJ.CanSend()
    local n
    local canSend = true
    if IsInRaid(1) then
        n = GetNumGroupMembers(1)
        if lastNum >= n then
            canSend = false
        end
    else
        canSend = false
        n = 0
    end
    lastNum = n
    return canSend
end

function TJ.GetGUID(guidIndex, combatLog)
    if type(guidIndex) == "number" then
        combatLog = combatLog or TJ.GetCombatLog()
        return combatLog.guidIndex[guidIndex] or combatLog.guidIndex[tostring(guidIndex)]
    else
        return guidIndex
    end
end

function TJ.GetNPCID(guid, onlyHarm)
    if guid then
        local npcType, _, _, _, _, npcID = strsplit("-", guid)
        if onlyHarm then
            if npcType == "Creature" or npcType == "Vehicle" then
                return tonumber(npcID) or 0, npcType
            end
        else
            return tonumber(npcID) or 0, npcType
        end
    end
    return "", ""
end

function TJ.FindTarget(npcID)
    local units = { "target", "focus" }
    for i in ipairs(C_NamePlate.GetNamePlates()) do
        tinsert(units, "nameplate" .. i)
    end
    for _, unit in ipairs(units) do
        local guid = UnitGUID(unit)
        if guid and TJ.GetNPCID(guid, true) == npcID then
            local unitTarget = unit .. "target"
            if UnitIsPlayer(unitTarget) then
                return UnitGUID(unitTarget), TJ.GN(unitTarget)
            end
            return false
        end
    end
end

function TJ.FormatNumber(num)
    if not tonumber(num) then return num end
    num = tonumber(num)
    if num >= 100000000 then
        return format(L["%.1f亿"], floor(num / 100000000 * 10) / 10)
    elseif num >= 100000 then
        return format(L["%d万"], floor(num / 10000 * 10) / 10)
    elseif num >= 10000 then
        return format(L["%.1f万"], floor(num / 10000 * 10) / 10)
    else
        return num
    end
end

-- 团队标记材质
local tex = [[Interface\TargetingFrame\UI-RaidTargetingIcons]]
local y = 0
local RaidTargetingIcons = {
    ["xingxing"] = { num = 1, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:0:25:0:25" .. "|t" },
    ["dabing"] = { num = 2, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:25:50:0:25" .. "|t" },
    ["ziling"] = { num = 3, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:55:75:0:25" .. "|t" },
    ["sanjiao"] = { num = 4, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:75:100:0:25" .. "|t" },
    ["yueliang"] = { num = 5, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:0:25:25:50" .. "|t" },
    ["fangkuai"] = { num = 6, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:25:50:25:50" .. "|t" },
    ["chacha"] = { num = 7, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:50:75:25:50" .. "|t" },
    ["kulou"] = { num = 8, tex = "|T" .. tex .. ":0:0:0:" .. y .. ":100:100:75:100:25:50" .. "|t" },
}
function TJ.SetRaidTargetingIcons(type, name)
    if type then
        return "{rt" .. RaidTargetingIcons[name].num .. "}"
    else
        return RaidTargetingIcons[name].tex
    end
end

function TJ.GsubRaidTargetingIcons(text)
    for k, v in pairs(RaidTargetingIcons) do
        text = text:gsub("{rt" .. v.num .. "}", v.tex)
    end
    return text
end

function TJ.SetRaidTargetingTex(...)
    -- if type == 0 then
    --     return RaidTargetingIcons["xingxing"].tex
    --         .. RaidTargetingIcons["dabing"].tex
    --         .. RaidTargetingIcons["ziling"].tex
    --         .. RaidTargetingIcons["sanjiao"].tex
    --         .. RaidTargetingIcons["yueliang"].tex
    --         .. RaidTargetingIcons["fangkuai"].tex
    --         .. RaidTargetingIcons["chacha"].tex
    --         .. RaidTargetingIcons["kulou"].tex
    -- elseif type == 1 then
    --     return RaidTargetingIcons["yueliang"].tex
    --         .. RaidTargetingIcons["fangkuai"].tex
    --         .. RaidTargetingIcons["chacha"].tex
    --         .. RaidTargetingIcons["kulou"].tex
    -- end
    local tbl = { ... }
    local text = ""
    for i, id in ipairs(tbl) do
        for k, v in pairs(RaidTargetingIcons) do
            if id == v.num then
                text = text .. v.tex
                break
            end
        end
    end
    return text
end

function TJ.IsLeader()
    return BGDEBUG or UnitIsGroupLeader("player") or UnitIsGroupAssistant("player")
end

function TJ.GetWarlockFuc(FB, bossIndex)
    local function updateFuc(index)
        local count = 0
        for i, v in ipairs(TJ.raidRosterInfo) do
            if count >= 3 then break end
            if v.role ~= "MAINASSIST" and v.class == "WARLOCK" then
                count = count + 1
                local name = "|c" .. select(4, GetClassColor(v.class)) .. TJ.GetIconAndName(v) .. "|r"
                TJ.CreateEdit(FB, bossIndex, name, index)
            end
        end
    end
    local info = {
        aura = {
            type = "d",
            spell = {
                {
                    spellID = ns.sp["灵魂石"],
                },
            },
        }
    }
    return updateFuc, info
end

function TJ.SetCD(self, time, key)
    if key then
        if self[key] then return true end
        self[key] = true
        After(time, function()
            self[key] = nil
        end)
    else
        if self.cd then return true end
        self.cd = true
        After(time, function()
            self.cd = nil
        end)
    end
end

-- 难度
function TJ.Is10Man()
    local diff = GetRaidDifficultyID()
    return diff == 5 or diff == 3 or diff == 193 or diff == 175
end

function TJ.IsH()
    local diff = GetRaidDifficultyID()
    return diff == 5 or diff == 6 or diff == 193 or diff == 194
end

function TJ.Is25H()
    local diff = GetRaidDifficultyID()
    return diff == 6 or diff == 194
end

function TJ.OnSpellLoad(spell, callback)
    if TJ.IsRetail then
        if C_Spell.DoesSpellExist(spell) then
            callback()
        else
            TJ.RegisterEvent("SPELL_DATA_LOAD_RESULT", function(self, event, spellID, success)
                if spellID == spell and success then
                    callback()
                end
            end)
            C_Spell.GetSpellInfo(spell)
        end
    else
        local spell = Spell:CreateFromSpellID(spell)
        spell:ContinueOnSpellLoad(callback)
    end
end

function TJ.GetDurTime()
    return Round(GetTime() - (TJ.startTime or 0), 3)
end

function TJ.DropDownListIsVisible(self)
    local _, parent = _G.L_DropDownList1:GetPoint()
    if parent == self and _G.L_DropDownList1:IsVisible() then
        return true
    end
end

function TJ.GetOwnerGUID(combatLog, GUID)
    if combatLog.guid[GUID].ownerGUID then
        GUID = combatLog.guid[GUID].ownerGUID
        local npcType = strsplit("-", GUID)
        if (npcType == "Creature" or npcType == "Vehicle") and combatLog.guid[GUID] then
            GUID = combatLog.guid[GUID].ownerGUID
        end
    end
    return GUID
end

function TJ.SetMixin(f, mixin)
    if type(f) == "table" then
        for k, v in pairs(mixin) do
            if f.HasScript and f:HasScript(k) then
                f:SetScript(k, v)
            else
                f[k] = v
            end
        end
    end
end

-- 创建右下角可拖动的缩放按钮
do
    local btMixin = {}
    local ag = 0.002 -- 灵敏度可调整
    local function SetValue(optionName, newScale)
        TuanJian.options[optionName] = tonumber(newScale) or newScale
        local optionButton = TJ.options["button" .. optionName]
        if optionButton and optionButton.SetValue then
            optionButton:SetValue(newScale)
            if optionButton.edit then
                optionButton.edit:SetText(newScale)
            end
        end
    end
    function btMixin:OnMouseDown(btn)
        if btn == "LeftButton" then
            self.isDragging = true
            self.startX = GetCursorPosition()
            self.startScale = self:GetParent():GetScale()
        elseif btn == "RightButton" then
            local newScale = TJ.options[self.optionName .. "reset"]
            if newScale then
                self:GetParent():SetScale(newScale)
                SetValue(self.optionName, newScale)
            end
        end
    end

    function btMixin:OnMouseUp()
        self.isDragging = false
    end

    function btMixin:OnUpdate()
        if not self.isDragging then return end
        local uiScale = UIParent:GetScale()
        local curX = GetCursorPosition()
        local deltaX = (curX - self.startX) / uiScale
        local newScale = self.startScale + deltaX * ag
        newScale = format("%.3f", math.max(self.minValue, math.min(newScale, self.maxValue)))
        self:GetParent():SetScale(newScale)
        SetValue(self.optionName, newScale)
    end

    function TJ.CreateFrameResizeHandle(parent, optionName, minValue, maxValue, size, x, y)
        size = size or 20
        x = x or 0
        y = y or 0
        local bt = CreateFrame("Button", nil, parent)
        bt:SetSize(size, size)
        bt:SetPoint("BOTTOMRIGHT", x, y)
        bt:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
        bt:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Highlight")
        bt:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
        bt.optionName = optionName
        bt.minValue = minValue
        bt.maxValue = maxValue
        TJ.SetMixin(bt, btMixin)
        return bt
    end
end

function TJ.CreateDropDownSeparator()
    return {
        text = " ",
        hasArrow = false,
        dist = 0,
        isTitle = true,
        isUninteractable = true,
        notCheckable = true,
        iconOnly = true,
        icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
        tCoordLeft = 0,
        tCoordRight = 1,
        tCoordTop = 0,
        tCoordBottom = 1,
        tSizeX = 0,
        tSizeY = 8,
        tFitDropDownSizeX = true,
        iconInfo = {
            tCoordLeft = 0,
            tCoordRight = 1,
            tCoordTop = 0,
            tCoordBottom = 1,
            tSizeX = 0,
            tSizeY = 8,
            tFitDropDownSizeX = true,
        },
    }
end

function TJ.ButtonIsInRight(self)
    if self:GetCenter() > UIParent:GetWidth() * 0.5 then
        return true
    end
end

function TJ.IsLoadBiaoGe()
    return C_AddOns.IsAddOnLoaded("BiaoGe") or C_AddOns.IsAddOnLoaded("BiaoGeX")
end
