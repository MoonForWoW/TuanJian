local AddonName, ns = ...
local L, LibBG = ns.L, ns.LibBG
local floor, min, max = math.floor, math.min, math.max
local eventsToRead = { "SPELL_CAST_START", "SPELL_CAST_SUCCESS", "SPELL_INTERRUPT", "SPELL_MISSED" }
local backdrop = {
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeSize = 1
}

local function IsHealer(member)
    -- 只读战斗快照，不能用当前天赋推断历史职责。
    local talents = TJ.talentToCombatRole and TJ.talentToCombatRole[member.class]
    local talent = talents and member.talent and talents[member.talent]
    if talent then return talent.role == "HEALER" end
    return member.combatRole == "HEALER" and member.role ~= "MAINTANK"
end

local function PlayerRoleOrder(member, class)
    local talents = TJ.talentToCombatRole and TJ.talentToCombatRole[class]
    local talent = talents and talents[member.talent]
    local role = talent and talent.role
    if not role then
        role = member.role == "MAINTANK" and "TANK" or member.combatRole
    end
    if role == "TANK" then return 1 end
    if role == "HEALER" then return 2 end
    if talent and talent.dps == 1 then return 3 end
    if talent and talent.dps == 2 then return 4 end
    -- 旧版本野德共用专精，按战斗快照中的职责区分熊和猫。
    if class == "DRUID" and member.talent == 2 and role == "DAMAGER" then return 3 end
    if class == "WARRIOR" or class == "ROGUE" or class == "DEATHKNIGHT"
        or class == "PALADIN" or class == "MONK" then
        return 3
    end
    if class == "HUNTER" or class == "MAGE" or class == "WARLOCK" or class == "PRIEST" then return 4 end
    return 5 -- 缺少专精的混合职业无法确认远近，放在已知职责之后。
end

local function TauntSpells()
    local ids = { [31789] = true } -- 正义防御（旧版本）
    for _, key in ipairs({ "单嘲", "群嘲", "单嘲+群嘲" }) do
        for _, id in ipairs(ns.sp and ns.sp[key] or {}) do ids[id] = true end
    end
    return ids
end

-- 与 UI 分离；按各事件表的原始时间顺序归并，不修改存档或日志缓存。
-- yieldWork 由 UI 提供，长战斗解析分帧执行。
function TJ.BuildCastRecords(log, events, yieldWork)
    local data = { records = {}, players = {}, playerList = {}, targets = {}, spells = {} }
    local members, pending, recent, positions, lists = {}, {}, {}, {}, {}
    local taunts = TauntSpells()
    for _, member in ipairs(log.raidMember or {}) do members[member.name] = member end
    local function GUID(index)
        local guid = TJ.GetGUID(index, log)
        return guid ~= "UNKNOWN" and guid or nil
    end
    for guid, unit in pairs(log.guid or {}) do
        if unit.class and guid:match("^Player%-") then
            local member = members[unit.name] or {}
            local icons = TJ.talentIcon and TJ.talentIcon[unit.class]
            local player = {
                guid = guid,
                name = unit.name or UNKNOWN,
                class = unit.class,
                icon = (icons and icons[member.talent]) or member.combatRole,
                healer = IsHealer(member),
                roleOrder = PlayerRoleOrder(member, unit.class),
                index = unit.index or 100
            }
            data.players[guid] = player
            data.playerList[#data.playerList + 1] = player
        end
    end
    table.sort(data.playerList, function(a, b)
        if a.roleOrder ~= b.roleOrder then return a.roleOrder < b.roleOrder end
        if a.index ~= b.index then return a.index < b.index end
        return a.name < b.name
    end)
    for i, kind in ipairs(eventsToRead) do positions[i], lists[i] = 1, events[kind] or {} end
    local function Spell(id, name)
        if not data.spells[id] then
            data.spells[id] = { name = type(name) == "string" and name or tostring(id) }
        end
        return data.spells[id]
    end
    local function SetTarget(row, guid)
        row.target = guid
        local unit = guid and log.guid[guid]
        local name = unit and unit.name
        row.targetName = name and name ~= UNKNOWN and name ~= L["未知"] and name or ""
        if guid and row.targetName ~= "" then data.targets[guid] = row.targetName end
    end
    while true do
        local nextEvent, eventType, selected
        for i, kind in ipairs(eventsToRead) do
            local event = lists[i][positions[i]]
            if event and (not nextEvent or event[1] < nextEvent[1]
                    or (event[1] == nextEvent[1] and (event.i or i) < (nextEvent.i or selected))) then
                nextEvent, eventType, selected = event, kind, i
            end
        end
        if not nextEvent then break end
        positions[selected] = positions[selected] + 1
        local v = nextEvent
        local source, target, spellID = GUID(v[4]), GUID(v[8]), v[12]
        local player = data.players[source]
        if eventType == "SPELL_INTERRUPT" then
            local row = pending[target]
            if row and row.spellID == v[15] then
                row.status, row.finish, row.reason = "interrupted", v[1], (log.guid[source] or {}).name
                pending[target] = nil
            end
        elseif player and spellID then
            if eventType == "SPELL_MISSED" then
                local row = recent[source] and recent[source][spellID]
                -- 只关联同一来源、技能、目标的短时间内结果，不猜测换坦成功。
                if row and row.target == target and v[1] >= row.finish and v[1] - row.finish <= 0.5 then
                    row.miss = v[15]
                end
            else
                local row = pending[source]
                if eventType == "SPELL_CAST_START" or not row or row.spellID ~= spellID then
                    row = {
                        time = v[1],
                        source = source,
                        spellID = spellID,
                        spell = Spell(spellID, v[13]),
                        taunt = taunts[spellID],
                        status = "canceled",
                        reason = L["未匹配到施法成功事件。"]
                    }
                    SetTarget(row, target)
                    data.records[#data.records + 1] = row
                end
                if eventType == "SPELL_CAST_START" then
                    row.start = v[1]
                    pending[source] = row
                else
                    row.finish = v[1]
                    -- 同一玩家最近一次对应读条匹配到 SUCCESS 才算成功；瞬发成功独立成行。
                    row.status, row.reason = "success", nil
                    if target then SetTarget(row, target) end
                    -- 自动射击等其他技能的成功事件可能穿插在读条期间，不能清掉该读条。
                    if pending[source] == row then pending[source] = nil end
                    if row.taunt and row.status == "success" then
                        recent[source] = recent[source] or {}
                        recent[source][spellID] = row
                    end
                end
            end
        end
        if yieldWork then yieldWork() end
    end
    return data
end

local function TimeText(time)
    local ms = floor((time or 0) * 1000 + 0.5)
    return string.format("%02d:%02d.%03d", floor(ms / 60000), floor(ms / 1000) % 60, ms % 1000)
end

local function Status(row)
    if row.miss then
        local reason = row.miss == "IMMUNE" and L["免疫"] or row.miss == "RESIST" and L["抵抗"]
            or row.miss == "MISS" and L["未命中"] or _G["ACTION_SPELL_MISSED_" .. row.miss] or _G[row.miss] or row.miss
        return reason, 1, .35, .3
    end
    if row.status == "success" then
        return row.taunt and L["已施放"] or L["成功"], .35, 1, .45
    elseif row.status == "canceled" then
        return L["已取消"], 1, .45, .2
    elseif row.status == "interrupted" then
        return L["被打断"], 1, .35, .3
    end
    return L["未见完成"], 1, .82, 0
end

local function NameText(name, class, icon)
    local prefix = icon and ns.AddTexture(icon) or ""
    local color = RAID_CLASS_COLORS[class or ""]
    if color then return prefix .. string.format("|cff%02x%02x%02x%s|r", floor(color.r * 255), floor(color.g * 255), floor(color.b * 255), name) end
    return prefix .. name
end

local function Label(parent, text, x, y, width, size)
    local fs = parent:CreateFontString(nil, "OVERLAY")
    fs:SetFont(BIAOGE_TEXT_FONT, size or 13, "OUTLINE")
    fs:SetPoint("TOPLEFT", x, y)
    if width then
        fs:SetSize(width, 22)
    end
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(false)
    fs:SetText(text)
    return fs
end

-- 只补充被列宽截断的文字，不显示施法详情。
local function ShowTruncatedText(owner, texts)
    local shown = false
    for _, fs in ipairs(texts) do
        local text = fs:GetText()
        if text and text ~= "" and fs:IsTruncated() then
            if not shown then
                GameTooltip:SetOwner(owner, "ANCHOR_RIGHT")
                GameTooltip:ClearLines()
                shown = true
            end
            GameTooltip:AddLine(text, 1, 1, 1, true)
        end
    end
    if shown then GameTooltip:Show() end
end

local Refresh, DrawRows, DrawPlayers
local rowHeight = 22
local headerHeight = 70
local timelineHeight = 80
local visiblePlayers, playerRowHeight = 20, 18
-- 左侧包含固定的“所有”行；按玩家行数推导两侧面板及窗口高度。
local visibleRows = math.ceil((visiblePlayers * playerRowHeight + 6 - 26) / rowHeight)
local panelHeight = 26 + visibleRows * rowHeight
local windowWidth, windowHeight, tableLeft, tableWidth = 702, headerHeight + timelineHeight + panelHeight + 10, 164, 502
local timelineMarkTop, timelineMarkHeight = -20, 13

local function TimelineTime(time)
    return string.format("%d:%02d", floor(time / 60), floor(time) % 60)
end

local function UpdateTimeline(f)
    local t = f.timeline
    local duration = t.duration or 0
    local function X(time) return duration > 0 and time / duration * t.width or 0 end
    local first, last = f.rangeStart, f.rangeEnd
    t.reset:SetShown(first ~= nil or f.seekTime ~= nil)
    t.selection:SetShown(first ~= nil)
    t.leftHandle:SetShown(first ~= nil)
    t.rightHandle:SetShown(first ~= nil)
    if first then
        t.selection:SetPoint("TOPLEFT", X(first), timelineMarkTop)
        t.selection:SetSize(max(1, X(last) - X(first)), timelineMarkHeight)
        t.leftHandle:SetPoint("TOPLEFT", X(first) - 2, timelineMarkTop + 4)
        t.rightHandle:SetPoint("TOPLEFT", X(last) - 2, timelineMarkTop + 4)
    end
    t.cursor:SetShown(f.seekTime ~= nil)
    if f.seekTime then t.cursor:SetPoint("TOPLEFT", X(f.seekTime), timelineMarkTop) end
    t.deathMarker:SetShown(f.deathTime ~= nil)
    if f.deathTime then t.deathMarker:SetPoint("TOPLEFT", X(f.deathTime) - 1, timelineMarkTop - 1) end
    local caption = first and (TimeText(first) .. " — " .. TimeText(last))
        or (f.seekTime and TimeText(f.seekTime) or L["整场战斗"])
    if f.deathTime then
        caption = caption .. "  |cffff5555" .. L["死亡"] .. " " .. TimeText(f.deathTime) .. "|r"
        local player = f.deathGUID and ((f.data and f.data.players[f.deathGUID])
            or (f.log and f.log.guid and f.log.guid[f.deathGUID]))
        if player then caption = caption .. "  " .. NameText(player.name, player.class, player.icon) end
    end
    t.caption:SetText(caption)
end

local function LoadTimeline(f, log)
    local t = f.timeline
    t.drag = nil
    t:SetScript("OnUpdate", nil)
    f.rangeStart, f.rangeEnd, f.seekTime, f.seekRecord = nil, nil, nil, nil
    f.deathTime, f.deathGUID = nil, nil
    t.duration = max(0, tonumber(log and log.duration) or 0)
    for _, marker in ipairs(t.markers) do marker:Hide() end
    for _, label in ipairs(t.phaseLabels) do label:Hide() end
    t.phases = {}
    for _, phase in pairs(log and log.otherTime or {}) do
        if type(phase) == "table" then
            local time = phase.time or phase.startTime
            if type(time) == "number" and time >= 0 and time <= t.duration then
                t.phases[#t.phases + 1] = { time = time, name = phase.name or phase.name2 or L["阶段"], finish = phase.endTime }
            end
        end
    end
    table.sort(t.phases, function(a, b) return a.time < b.time end)
    for i, phase in ipairs(t.phases) do
        local marker = t.markers[i] or t:CreateTexture(nil, "ARTWORK")
        t.markers[i] = marker
        marker:SetColorTexture(.2, 1, .3)
        marker:SetSize(2, timelineMarkHeight)
        local x = t.duration > 0 and phase.time / t.duration * t.width or 0
        marker:SetPoint("TOPLEFT", x, timelineMarkTop)
        marker:Show()
        local label = t.phaseLabels[i] or Label(t, "", 0, 0, nil, 11)
        t.phaseLabels[i] = label
        label:ClearAllPoints()
        label:SetPoint("TOP", t, "TOPLEFT", x + 1, 0)
        label:SetJustifyH("CENTER")
        label:SetTextColor(.2, 1, .3)
        label:SetText(phase.name .. " " .. TimelineTime(phase.time))
        label:Show()
    end
    -- 常规刻度只保留战斗起止时间，重点展示绿色阶段时间点。
    for i, tick in ipairs(t.ticks) do
        tick:SetText(TimelineTime(t.duration * (i - 1)))
    end
    UpdateTimeline(f)
end

local function CreateTimeline(f)
    local panel = CreateFrame("Frame", nil, f, "BackdropTemplate")
    panel:SetPoint("TOPLEFT", 10, -headerHeight)
    panel:SetSize(windowWidth - 20, 70)
    panel:SetBackdrop(backdrop)
    panel:SetBackdropBorderColor(.35, .35, .4)
    panel:SetBackdropColor(.04, .04, .04, .8)
    local t = CreateFrame("Frame", nil, panel)
    f.timeline = t
    t.width, t.markers, t.ticks = windowWidth - 44, {}, {}
    t.phaseLabels = {}
    t:SetPoint("TOPLEFT", 12, -27)
    t:SetSize(t.width, 38)
    t:EnableMouse(true)
    t.caption = Label(panel, "", 10, -4, windowWidth - 100, 12)
    t.caption:SetTextColor(1, .82, 0)
    local reset = TJ.CreateButton(panel)
    t.reset = reset
    reset:SetPoint("TOPRIGHT", -6, -3)
    reset:SetSize(54, 22)
    reset:SetText(L["重置"])
    reset:SetScript("OnClick", function()
        t.drag = nil; t:SetScript("OnUpdate", nil)
        f.rangeStart, f.rangeEnd, f.seekTime = nil, nil, nil
        UpdateTimeline(f); Refresh(f)
    end)
    local line = t:CreateTexture(nil, "BACKGROUND")
    line:SetColorTexture(.5, .5, .5)
    line:SetPoint("TOPLEFT", 0, -26)
    line:SetSize(t.width, 1)
    for i = 1, 2 do
        local x = (i - 1) * t.width
        local tick = t:CreateTexture(nil, "ARTWORK")
        tick:SetColorTexture(.6, .6, .6)
        tick:SetPoint("TOPLEFT", x, -22)
        tick:SetSize(1, 9)
        local label = Label(t, "", 0, 0, nil, 11)
        label:ClearAllPoints()
        label:SetPoint(i == 1 and "TOPLEFT" or "TOPRIGHT", t, "TOPLEFT", x, 0)
        t.ticks[i] = label
    end
    t.selection = t:CreateTexture(nil, "BACKGROUND")
    t.selection:SetColorTexture(1, .82, 0, .22)
    for _, key in ipairs({ "leftHandle", "rightHandle", "cursor" }) do
        t[key] = t:CreateTexture(nil, "OVERLAY")
        t[key]:SetColorTexture(1, .82, 0)
        t[key]:SetSize(key == "cursor" and 1 or 4, timelineMarkHeight + (key == "cursor" and 0 or 8))
    end
    t.deathMarker = t:CreateTexture(nil, "OVERLAY", nil, 1)
    t.deathMarker:SetColorTexture(1, .15, .15)
    t.deathMarker:SetSize(2, timelineMarkHeight - 2)
    local function MouseTime()
        local x = GetCursorPosition() / t:GetEffectiveScale() - t:GetLeft()
        return min(1, max(0, x / t.width)) * (t.duration or 0)
    end
    local function Move()
        local drag = t.drag
        if not drag then return end
        local time = MouseTime()
        if math.abs(time - drag.start) / t.duration * t.width >= 4 then drag.moved = true end
        if drag.moved then
            f.rangeStart, f.rangeEnd = min(drag.anchor, time), max(drag.anchor, time)
            f.seekTime = nil
            UpdateTimeline(f)
        end
    end
    local function Finish()
        local drag = t.drag
        if not drag then return end
        Move()
        if not drag.moved then
            f.seekTime = MouseTime()
            -- 点击区间外时恢复整场，才能定位到该时间的记录。
            if f.rangeStart and (f.seekTime < f.rangeStart or f.seekTime > f.rangeEnd) then
                f.rangeStart, f.rangeEnd = nil, nil
            end
        end
        t.drag = nil; t:SetScript("OnUpdate", nil)
        UpdateTimeline(f); Refresh(f)
    end
    t:SetScript("OnMouseDown", function(_, button)
        if button ~= "LeftButton" or not f.data or t.duration <= 0 then return end
        GameTooltip:Hide()
        local time, anchor = MouseTime()
        anchor = time
        local tolerance = t.duration * 6 / t.width
        if f.rangeStart and math.abs(time - f.rangeStart) <= tolerance then
            anchor = f.rangeEnd
        elseif f.rangeEnd and math.abs(time - f.rangeEnd) <= tolerance then
            anchor = f.rangeStart
        end
        t.drag = { start = time, anchor = anchor }
        t:SetScript("OnUpdate", function()
            if not IsMouseButtonDown("LeftButton") then Finish() else Move() end
        end)
    end)
    t:SetScript("OnMouseUp", function(_, button) if button == "LeftButton" then Finish() end end)
end

local function SavedMode()
    local mode = TuanJian.options.castRecordsMode
    if mode == "all" or mode == "heal" or mode == "taunt" then return mode end
end

local function UpdateModeTabs(f)
    for _, button in ipairs(f.modeButtons) do
        local selected = button.mode == f.mode
        button.selected:SetShown(selected)
        if selected then
            button.text:SetTextColor(1, 1, 1)
        else
            button.text:SetTextColor(.65, .65, .65)
        end
    end
end

-- 使用当前滚动模板的虚拟范围，保留模板的滑块、轨道和滚轮行为。
local function CreateListScroll(parent, x, y, width, height, count, changed)
    local scroll = CreateFrame("ScrollFrame", nil, parent, TJ.scrollTemplate)
    scroll:SetPoint("TOPLEFT", x, y)
    scroll:SetSize(width, height)
    scroll:SetScrollExtent(count, count)
    scroll.ScrollBar.scrollStep = 3
    scroll.ScrollBar:SetObeyStepOnDrag(true)
    scroll.ScrollBar:HookScript("OnValueChanged", function(_, value)
        changed(floor(value + .5))
    end)
    return scroll
end

local function UpdateListScroll(scroll, count, total, offset)
    scroll:SetScrollExtent(count, max(count, total))
    scroll.ScrollBar:SetMinMaxValues(0, max(0, total - count))
    scroll.ScrollBar:SetValue(offset)
end

DrawRows = function(f)
    local rows = f.filtered or {}
    local maxOffset = max(0, #rows - visibleRows)
    f.offset = min(maxOffset, max(0, f.offset or 0))
    UpdateListScroll(f.recordScroll, visibleRows, #rows, f.offset)
    for i, widget in ipairs(f.rows) do
        local row = rows[i + f.offset]
        widget.record = row
        widget.located:SetShown(row ~= nil and row == f.seekRecord)
        widget:SetShown(row ~= nil)
        if row then
            local player = f.data.players[row.source]
            local target = row.target and f.log.guid[row.target]
            local targetPlayer = row.target and f.data.players[row.target]
            widget.cells[1]:SetText(TimeText(row.time))
            widget.cells[2]:SetText(NameText(player.name, player.class, player.icon))
            widget.icon:SetTexture(row.spell.icon or 134400)
            widget.cells[3]:SetText(row.spell.name)
            widget.cells[4]:SetText(row.targetName ~= "" and NameText(row.targetName, target and target.class, targetPlayer and targetPlayer.icon) or "")
            local text, r, g, b = Status(row)
            widget.cells[5]:SetText(text)
            widget.cells[5]:SetTextColor(r, g, b)
        end
    end
end

DrawPlayers = function(f)
    GameTooltip:Hide()
    local players = f.visiblePlayers or {}
    f.playerOffset = min(max(0, #players - (visiblePlayers - 1)), max(0, f.playerOffset or 0))
    UpdateListScroll(f.playerScroll, visiblePlayers - 1, #players, f.playerOffset)
    local width = #players > visiblePlayers - 1 and 116 or 134
    for i, button in ipairs(f.playerButtons) do
        local player = i > 1 and players[i - 1 + f.playerOffset]
        button.guid = player and player.guid
        button:SetShown(i == 1 or player ~= nil)
        button:SetWidth(width)
        button.selected:SetShown((i == 1 and not f.player) or (player and f.player == player.guid) or false)
        if i == 1 then
            button.text:SetText(L["所有"])
        elseif player then
            button.text:SetText(NameText(player.name, player.class, player.icon))
        end
    end
end

-- 过滤也分帧，连续切换筛选或战斗时通过 generation 丢弃旧任务。
Refresh = function(f)
    if not f.data then return end
    GameTooltip:Hide()
    f.filterGeneration = (f.filterGeneration or 0) + 1
    local generation = f.filterGeneration
    local mode, player, target, data = f.mode, f.player, f.target, f.data
    local targetName = f.targetName
    local rangeStart, rangeEnd = f.rangeStart, f.rangeEnd
    f.seekRecord = nil
    local rows, players, playerSet, index = {}, {}, {}, 1
    f.filtered = {}
    DrawRows(f)
    f.statusText:SetText(L["正在筛选施法记录…"])
    local function Step()
        if not f:IsShown() or generation ~= f.filterGeneration or data ~= f.data then return end
        local limit = min(index + 999, #data.records)
        for i = index, limit do
            local row = data.records[i]
            local unit = data.players[row.source]
            local inMode = mode == "all" or (mode == "heal" and unit.healer) or (mode == "taunt" and row.taunt)
            if inMode then
                playerSet[row.source] = true
                if (not player or player == row.source) and (not target or target == row.target)
                    and (not targetName or (not data.players[row.target] and data.targets[row.target] == targetName))
                    and (not rangeStart or (row.time >= rangeStart and row.time <= rangeEnd)) then
                    rows[#rows + 1] = row
                end
            end
        end
        index = limit + 1
        if index <= #data.records then
            C_Timer.After(0, Step); return
        end
        for _, unit in ipairs(data.playerList) do
            if playerSet[unit.guid] then players[#players + 1] = unit end
        end
        f.filtered, f.visiblePlayers, f.offset = rows, players, 0
        if f.player then
            for i, unit in ipairs(players) do
                if unit.guid == f.player then
                    local offset = f.playerOffset or 0
                    if i <= offset or i > offset + visiblePlayers - 1 then f.playerOffset = i - 1 end
                    break
                end
            end
        end
        if f.seekTime and #rows > 0 then
            local lo, hi = 1, #rows
            while lo < hi do
                local mid = floor((lo + hi) / 2)
                if rows[mid].time < f.seekTime then lo = mid + 1 else hi = mid end
            end
            f.offset, f.seekRecord = lo - 1, rows[lo]
        end
        DrawPlayers(f)
        DrawRows(f)
        f.statusText:SetText(#rows == 0 and L["当前条件下没有施法记录。"] or "")
    end
    C_Timer.After(0, Step)
end

local function CreateWindow()
    local f = CreateFrame("Frame", "TuanJianCastRecordsFrame", UIParent, "BackdropTemplate")
    TJ.castRecordsFrame = f
    f:Hide()
    f:SetSize(windowWidth, windowHeight)
    f:SetBackdrop(backdrop)
    f:SetBackdropColor(.025, .03, .035, .98)
    f:SetBackdropBorderColor(.45, .45, .45)
    f:SetToplevel(true)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:SetScript("OnMouseDown", f.StartMoving)
    f:SetScript("OnMouseUp", f.StopMovingOrSizing)
    tinsert(UISpecialFrames, "TuanJianCastRecordsFrame")
    Label(f, L["施法记录"], 10, -8, nil, 16):SetTextColor(1, 1, 1)
    f.contextText = Label(f, "", 200, -10, nil, 14)
    f.contextText:ClearAllPoints()
    f.contextText:SetPoint('TOPRIGHT', -40, -8)
    f.contextText:SetJustifyH("RIGHT")
    f.contextText:SetTextColor(.7, .7, .7)
    local divider = f:CreateTexture(nil, "BACKGROUND")
    divider:SetPoint("TOPLEFT", 10, -29)
    divider:SetSize(windowWidth - 20, 1.5)
    divider:SetColorTexture(1, 1, 1, .15)
    local close = CreateFrame("Button", nil, f, "UIPanelCloseButton")
    close:SetPoint("TOPRIGHT", 0, 0)
    close:SetScript("OnClick", function() f:Hide() end)
    f.modeButtons = {}
    local tabWidth = 94
    local tabGroup = CreateFrame("Frame", nil, f, "BackdropTemplate")
    tabGroup:SetPoint("TOPLEFT", 10, -36)
    tabGroup:SetSize(286, 26)
    tabGroup:SetBackdrop(backdrop)
    tabGroup:SetBackdropColor(16 / 255, 18 / 255, 20 / 255, .96)
    tabGroup:SetBackdropBorderColor(65 / 255, 69 / 255, 72 / 255, 1)
    for i, item in ipairs({ { "all", L["全部"] }, { "heal", L["治疗施法"] }, { "taunt", L["嘲讽"] } }) do
        local mode, text = item[1], item[2]
        local b = CreateFrame("Button", nil, tabGroup)
        b:SetPoint("TOPLEFT", 2 + (i - 1) * tabWidth, -2)
        b:SetSize(tabWidth, 22)
        b.text = Label(b, text, 0, 0, tabWidth, 14)
        b.text:SetAllPoints()
        b.text:SetJustifyH("CENTER")
        b.selected = b:CreateTexture(nil, "BACKGROUND")
        b.selected:SetAllPoints()
        b.selected:SetColorTexture(.23, .24, .25, 1)
        local hover = b:CreateTexture(nil, "HIGHLIGHT")
        hover:SetAllPoints()
        hover:SetColorTexture(1, 1, 1, .06)
        b:SetScript("OnClick", function()
            f.mode, f.player, f.playerOffset = mode, nil, 0
            TuanJian.options.castRecordsMode = mode
            UpdateModeTabs(f)
            Refresh(f)
        end)
        b.mode, b.label = mode, text
        f.modeButtons[i] = b
    end
    f.targetMenu = LibBG:Create_UIDropDownMenu(nil, f)
    f.targetButton = f.targetMenu
    f.targetMenu:SetPoint("TOPRIGHT", f, "TOPRIGHT", -10, -36)
    f.targetMenu:SetSize(152, 26)
    f.targetMenu:SetText("|cffffffff" .. L["全部目标"] .. "|r")
    local targetLabel = Label(f, L["施法目标："], 0, 0, 100, 14)
    targetLabel:ClearAllPoints()
    targetLabel:SetPoint("RIGHT", f.targetMenu, "LEFT", -5, 0)
    targetLabel:SetJustifyH("RIGHT")
    targetLabel:SetTextColor(1, 1, 1)
    LibBG:UIDropDownMenu_SetAnchor(f.targetMenu, 0, 0, "TOP", f.targetMenu, "BOTTOM")
    LibBG:UIDropDownMenu_Initialize(f.targetMenu, function()
        local function TargetOption(text, guid, name)
            local info = LibBG:UIDropDownMenu_CreateInfo()
            info.text, info.checked = text, f.target == guid and f.targetName == name
            info.func = function()
                f.target, f.targetName = guid, name
                f.targetButton:SetText(text)
                Refresh(f)
            end
            return info
        end
        LibBG:UIDropDownMenu_AddButton(TargetOption("|cffffffff" .. L["全部目标"] .. "|r"))
        local groups = {}
        for _, target in ipairs(f.targetList or {}) do
            if not target.isPlayer then
                local name = target.sortText
                groups[name] = groups[name] or {}
                groups[name][#groups[name] + 1] = TargetOption(target.text, target.guid)
            end
        end
        local added = {}
        for _, target in ipairs(f.targetList or {}) do
            local group = not target.isPlayer and groups[target.sortText]
            if group and #group > 1 then
                if not added[target.sortText] then
                    table.insert(group, 1, TargetOption("|cffffffff" .. target.sortText .. L["（全部）"] .. "|r", nil, target.sortText))
                    local info = LibBG:UIDropDownMenu_CreateInfo()
                    info.text = "|cffffffff" .. target.sortText .. "|r"
                    info.notCheckable = true
                    info.menuList = group
                    LibBG:UIDropDownMenu_AddButton(info)
                    added[target.sortText] = true
                end
            else
                LibBG:UIDropDownMenu_AddButton(TargetOption(target.text, target.guid))
            end
        end
    end)
    CreateTimeline(f)
    -- 与玩家列表一致的细边框，覆盖表头、记录和右侧滚动条。
    f.recordPanel = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.recordPanel:SetPoint("TOPLEFT", tableLeft - 4, -headerHeight - timelineHeight)
    f.recordPanel:SetSize(windowWidth - (tableLeft - 4) - 10, panelHeight)
    f.recordPanel:SetBackdrop({ edgeFile = "Interface\\ChatFrame\\ChatFrameBackground", edgeSize = 1 })
    f.recordPanel:SetBackdropBorderColor(.35, .35, .4)
    f.recordPanel:EnableMouse(false)
    -- 只在加载、空结果或错误时在列表内显示状态，不占常驻说明行。
    f.statusText = Label(f, "", tableLeft, -headerHeight - 84 - timelineHeight, tableWidth, 15)
    f.statusText:SetJustifyH("CENTER")
    f.statusText:SetTextColor(.7, .7, .7)
    -- 13 号字：姓名列等宽并预留专精图标，列间留 2 像素。
    local columns = { { L["时间"], 0, 91 }, { L["施法者"], 93, 112 },
        { L["技能"], 226, 92, 207 }, { L["目标"], 320, 112 }, { L["状态"], 434, 60 } }
    for _, column in ipairs(columns) do
        -- 技能列的左边缘包含图标，表头不能只对齐图标后的文字。
        local left = column[4] or column[2]
        Label(f, column[1], tableLeft + left, -headerHeight - timelineHeight, column[3] + column[2] - left):SetTextColor(1, .82, 0)
    end
    f.recordScroll = CreateListScroll(f, tableLeft, -headerHeight - rowHeight - 3 - timelineHeight, tableWidth, visibleRows * rowHeight, visibleRows, function(value)
        if f.offset ~= value then
            f.offset = value
            GameTooltip:Hide()
            DrawRows(f)
        end
    end)
    f.scrollBar = f.recordScroll.ScrollBar
    f.rows = {}
    for i = 1, visibleRows do
        local row = CreateFrame("Button", nil, f.recordScroll)
        row:SetPoint("TOPLEFT", 0, -(i - 1) * rowHeight)
        row:SetSize(tableWidth, rowHeight)
        local bg = row:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(); bg:SetColorTexture(1, 1, 1, i % 2 == 1 and .10 or .015)
        row.located = row:CreateTexture(nil, "BACKGROUND", nil, 1)
        row.located:SetAllPoints()
        row.located:SetColorTexture(1, .82, 0, .16)
        row.located:Hide()
        row:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        row.cells = {}
        for j, column in ipairs(columns) do row.cells[j] = Label(row, "", column[2], 0, column[3], 13) end
        row.icon = row:CreateTexture(nil, "ARTWORK")
        row.icon:SetPoint("TOPLEFT", columns[3][4], -2)
        row.icon:SetSize(16, 16)
        row:SetScript("OnEnter", function(self) ShowTruncatedText(self, self.cells) end)
        row:SetScript("OnLeave", GameTooltip_Hide)
        row:EnableMouseWheel(true)
        row:SetScript("OnMouseWheel", function(_, delta)
            f.offset = (f.offset or 0) - delta * 3
            GameTooltip:Hide(); DrawRows(f)
        end)
        row:Hide()
        f.rows[i] = row
    end
    f.playerPanel = CreateFrame("Frame", nil, f, "BackdropTemplate")
    f.playerPanel:SetPoint("TOPLEFT", 10, -headerHeight - timelineHeight)
    f.playerPanel:SetSize(140, panelHeight)
    f.playerPanel:SetBackdrop({
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        edgeFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeSize = 1
    })
    f.playerPanel:SetBackdropColor(.06, .05, .08, .95)
    f.playerPanel:SetBackdropBorderColor(.35, .35, .4)
    f.playerScroll = CreateListScroll(f.playerPanel, 3, -3, 134, panelHeight - 6, visiblePlayers - 1, function(value)
        if f.playerOffset ~= value then
            f.playerOffset = value; DrawPlayers(f)
        end
    end)
    f.playerScroll.ScrollBar:ClearAllPoints()
    f.playerScroll.ScrollBar:SetPoint("TOPRIGHT", f.playerScroll, "TOPRIGHT", 0, 0)
    f.playerScroll.ScrollBar:SetPoint("BOTTOMRIGHT", f.playerScroll, "BOTTOMRIGHT", 0, 0)
    f.playerButtons = {}
    for i = 1, visiblePlayers do
        local b = CreateFrame("Button", nil, f.playerScroll)
        b:SetPoint("TOPLEFT", 0, -(i - 1) * playerRowHeight)
        b:SetSize(134, playerRowHeight)
        b.text = Label(b, "", 3, 0, 128, 13)
        b.text:ClearAllPoints()
        b.text:SetPoint("TOPLEFT", 3, 0)
        b.text:SetPoint("BOTTOMRIGHT", -3, 0)
        b.selected = b:CreateTexture(nil, "BACKGROUND")
        b.selected:SetAllPoints()
        b.selected:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        b.selected:SetBlendMode("ADD")
        b.selected:Hide()
        b:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
        b:SetScript("OnEnter", function(self) ShowTruncatedText(self, { self.text }) end)
        b:SetScript("OnLeave", GameTooltip_Hide)
        b:SetScript("OnClick", function(self)
            f.player = self.guid
            DrawPlayers(f)
            Refresh(f)
        end)
        b:EnableMouseWheel(true)
        b:SetScript("OnMouseWheel", function(_, delta)
            f.playerOffset = (f.playerOffset or 0) - delta * 3
            DrawPlayers(f)
        end)
        b:Hide()
        f.playerButtons[i] = b
    end
    f:SetScript("OnHide", function(self)
        self.timeline.drag = nil
        self.timeline:SetScript("OnUpdate", nil)
        self.seekRecord = nil
        self.generation = (self.generation or 0) + 1
        self.filterGeneration = (self.filterGeneration or 0) + 1
        self.data, self.log, self.filtered, self.visiblePlayers, self.targetList = nil, nil, nil, nil, nil
        for _, row in ipairs(self.rows) do
            row.record = nil; row:Hide()
        end
        for _, button in ipairs(self.playerButtons) do
            button.guid = nil; button:Hide()
        end
        self.scrollBar:Hide()
        self.playerScroll.ScrollBar:Hide()
        GameTooltip:Hide()
        LibBG:CloseDropDownMenus()
    end)
    return f
end

function TJ.CreateCastRecordsFrame(owner, updateTitleColor, click, processorKey, request)
    local log = request and request.log or TJ.GetCombatLog()
    local events, eventInfo
    if request then events = request.events else events, eventInfo = TJ.GetCombatLogEvent() end
    if updateTitleColor then
        -- 只检查是否存在可显示的玩家施法，不构建窗口或解析完整记录。
        local kinds, kindIndex, index = { "SPELL_CAST_START", "SPELL_CAST_SUCCESS" }, 1, 1
        local function Finish(found)
            owner.Text:SetTextColor(found and 0 or 1, 1, found and 0 or 1)
            if eventInfo then
                eventInfo.titleColor = eventInfo.titleColor or {}
                eventInfo.titleColor[owner.index] = found and 1 or 0
            end
            updateTitleColor.callback()
        end
        local function Step()
            if TJ.GetCombatLog() ~= log or TJ.GetCombatLogEvent() ~= events then return end
            if processorKey and not TJ.combatFrameProcessors[processorKey] then return end
            if not log or not events then
                Finish(false); return
            end
            for _ = 1, 1000 do
                local kind = kinds[kindIndex]
                if not kind then
                    Finish(false); return
                end
                local event = events[kind] and events[kind][index]
                if event then
                    local guid = TJ.GetGUID(event[4], log)
                    local unit = guid and log.guid and log.guid[guid]
                    if event[12] and unit and unit.class and guid:match("^Player%-") then
                        Finish(true); return
                    end
                    index = index + 1
                else
                    kindIndex, index = kindIndex + 1, 1
                end
            end
            C_Timer.After(0, Step)
        end
        Step()
        return
    end
    if not click then return end
    local f = TJ.castRecordsFrame or CreateWindow()
    -- 保持独立窗口；每次从入口打开时，与其他战斗分析一样定位到按钮上方。
    f:Hide()
    f:SetScale(min(1, (UIParent:GetWidth() - 30) / windowWidth, (UIParent:GetHeight() - 30) / windowHeight))
    f:SetClampedToScreen(true)
    do
        f:ClearAllPoints()
        if request then
            local scale = owner:GetEffectiveScale()
            local frameScale = f:GetEffectiveScale()
            local left, right = (owner:GetLeft() or 0) * scale, (owner:GetRight() or 0) * scale
            local x = (left + right) / 2
            local y = (owner:GetTop() or 0) * scale + frameScale
            local point = "BOTTOM"
            local screenHeight = UIParent:GetHeight() * UIParent:GetEffectiveScale()
            if y + windowHeight * frameScale > screenHeight then
                point = "TOP"
                y = (owner:GetBottom() or 0) * scale - frameScale
            end
            -- 位置换算到屏幕坐标，避免绑定会回收复用的分析面板。
            f:SetPoint(point, UIParent, "BOTTOMLEFT", x / frameScale, y / frameScale)
        else
            f:SetPoint("BOTTOM", owner, "TOP", 0, 5)
        end
    end
    f.click, f.hasClickFrame = true, true
    f.log, f.data, f.filtered = log, nil, nil
    f.mode = request and request.mode or SavedMode() or "heal"
    UpdateModeTabs(f)
    f.player, f.target, f.playerOffset, f.offset = nil, nil, 0, 0
    f.targetName = nil
    LoadTimeline(f, log)
    if request then
        f.player = request.player
        f.target = request.target
        f.deathGUID = request.deathGUID
        f.deathTime = min(f.timeline.duration, max(0, request.time))
        f.rangeStart, f.rangeEnd = max(0, f.deathTime - 6), f.deathTime
        UpdateTimeline(f)
    end
    f.targetButton:SetText("|cffffffff" .. L["全部目标"] .. "|r")
    local selectedTarget = f.target and log and log.guid and log.guid[f.target]
    if selectedTarget then f.targetButton:SetText(NameText(selectedTarget.name, selectedTarget.class)) end
    local boss = log and TJ.FBinfo[log.FB] and TJ.FBinfo[log.FB][log.bossIndex]
    f.contextText:SetText(log and ((boss and boss.name or owner.name or owner.titleName or L["施法记录"]) .. "  " ..
        (log.time and date("%m-%d %H:%M", log.time) or "") .. "（" .. TJ.SecondsToTime(log.duration or 0) .. "）") or "")
    f.statusText:SetText(L["正在读取施法记录…"])
    f.generation = (f.generation or 0) + 1
    local generation = f.generation
    f:Show()
    if not log or not events then
        f.statusText:SetText(L["暂无可用战斗日志，请先选择已加载的历史战斗。"])
        return
    end
    local units, started = 0, 0
    local thread = coroutine.create(function()
        local function Yield()
            units = units + 1
            if units >= 500 or debugprofilestop() - started >= 2 then coroutine.yield() end
        end
        local data = TJ.BuildCastRecords(log, events, Yield)
        for id, spell in pairs(data.spells) do
            local info = C_Spell.GetSpellInfo(id)
            if info then spell.name, spell.icon = info.name, info.iconID end
            Yield()
        end
        return data
    end)
    local function Step()
        if not f:IsShown() or generation ~= f.generation then return end
        units, started = 0, debugprofilestop()
        local ok, result = coroutine.resume(thread)
        if not ok then
            f.statusText:SetText(L["施法记录读取失败。"])
            geterrorhandler()(result)
            return
        end
        if coroutine.status(thread) ~= "dead" then
            C_Timer.After(0, Step); return
        end
        f.data = result
        UpdateTimeline(f)
        local hasHealer = false
        for _, unit in ipairs(result.playerList) do if unit.healer then hasHealer = true end end
        -- 点击标签时立即保存；读取期间的新选择也不会被默认分类覆盖。
        if not request then
            f.mode = SavedMode() or (hasHealer and "heal" or "all")
            TuanJian.options.castRecordsMode = f.mode
        end
        UpdateModeTabs(f)
        f.targetList = {}
        -- 联动死者即使没有被记录为施法目标，也保留菜单选项以明确当前筛选。
        local selectedUnit = f.target and log.guid and log.guid[f.target]
        if selectedUnit and selectedUnit.name then result.targets[f.target] = selectedUnit.name end
        local nameCounts = {}
        for _, name in pairs(result.targets) do nameCounts[name] = (nameCounts[name] or 0) + 1 end
        for guid, name in pairs(result.targets) do
            f.targetList[#f.targetList + 1] = {
                guid = guid,
                sortText = name,
                isPlayer = result.players[guid] ~= nil
            }
        end
        table.sort(f.targetList, function(a, b)
            if a.isPlayer ~= b.isPlayer then return not a.isPlayer end
            if a.sortText ~= b.sortText then return a.sortText < b.sortText end
            return a.guid < b.guid
        end)
        -- 同名目标按完整 GUID 稳定编号，截取 GUID 尾部不能保证唯一。
        local nameIndices = {}
        for _, target in ipairs(f.targetList) do
            local name = target.sortText
            nameIndices[name] = (nameIndices[name] or 0) + 1
            local text = nameCounts[name] > 1 and (name .. nameIndices[name]) or name
            local player = result.players[target.guid]
            target.text = player and NameText(text, player.class, player.icon) or ("|cffffffff" .. text .. "|r")
            if target.guid == f.target then f.targetButton:SetText(target.text) end
        end
        Refresh(f)
    end
    C_Timer.After(0, Step)
end

function TJ.OpenCastRecordsForDeath(source, log, events, guid, time, healing)
    if not log or not events or not guid or type(time) ~= "number" then return end
    TJ.CreateCastRecordsFrame(source, nil, true, nil, {
        log = log, events = events, time = time, deathGUID = guid,
        mode = healing and "heal" or "all", player = not healing and guid or nil,
        target = healing and guid or nil
    })
end
