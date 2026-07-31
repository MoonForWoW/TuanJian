--[[

开始测试巫妖王战术板
/run TJ.Board_ENCOUNTER_START("ICC", 12)
寄生
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,70541)
冷酷严冬
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,68981)
地震
/run TJ.Board_SPELL_CAST_START(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,72262)
收割
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,69409)
进剑
/run TJ.Board_SPELL_CAST_SUCCESS(nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,73654)

-- 自定义变量
{
    expirationTime = true,
    isMe = 'bool',
}
 ]]
-- 初始化
aura_env.ver = "v2.0"
if not TJBoardVer then
    CreateFrame("Frame", "TJBoardVer")
end
TJBoardVer.ver = aura_env.ver
if TJ and TJ.UpdateBoardMyVer then
    TJ.UpdateBoardMyVer()
end
aura_env.iconSize = 25
aura_env.count = 0
aura_env.lastSound = nil
aura_env.lastSend = {}
aura_env.scheduledTimers = {}
aura_env.myName = GetUnitName("player", true)
local spellCached = {}
local itemCached = {}

C_ChatInfo.RegisterAddonMessagePrefix("TuanJianBoard2")
C_ChatInfo.RegisterAddonMessagePrefix("TuanJianBoardVer")
if IsInRaid(1) then
    C_ChatInfo.SendAddonMessage("TuanJianBoardVer", "MyVer-" .. aura_env.ver, "RAID")
    if TJ then
        C_ChatInfo.SendAddonMessage("TuanJianBoardVer", "VersionCheck", "RAID")
    end
end

function aura_env.SetColorName(player)
    local class = select(2, UnitClass(player))
    if class then
        local color = select(4, GetClassColor(class))
        return "|c" .. color .. player .. "|r"
    else
        return player
    end
end

function aura_env.HideOne(a, bossSpellID)
    for _, state in pairs(a) do
        if state.bossSpellID == bossSpellID then
            state.show = false
            state.changed = true
        end
    end
    local tbl = aura_env.scheduledTimers[bossSpellID]
    if tbl then
        for i = #tbl, 1, -1 do
            local timer = tbl[i]
            if timer then
                WeakAuras.timer:CancelTimer(timer)
                tremove(tbl, i)
            end
        end
    end
end

function aura_env.HideAll(a)
    for bossSpellID in pairs(aura_env.scheduledTimers) do
        for _, timer in pairs(aura_env.scheduledTimers[bossSpellID]) do
            WeakAuras.timer:CancelTimer(timer)
        end
    end
    wipe(aura_env.scheduledTimers)
    for _, state in pairs(a) do
        state.show = false
        state.changed = true
    end
end

local lastNum = 0
function aura_env.CanSend()
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

function aura_env.GetLinksAndIcons(spellIDs)
    local links = {}
    local icons = {}
    for _, str in pairs({ strsplit("^", spellIDs) }) do
        if str:find("s") then
            local spellID = tonumber(str:match("s(%d+)"))
            local icon = C_Spell.GetSpellTexture(spellID)
            tinsert(icons, icon)
            if spellCached[spellID] then
                tinsert(links, spellCached[spellID])
            else
                local spell = Spell:CreateFromSpellID(spellID)
                spell:ContinueOnSpellLoad(function()
                    local link = C_Spell.GetSpellLink(spellID)
                    spellCached[spellID] = link
                    tinsert(links, link)
                end)
            end
        elseif str:find("i") then
            local itemID = tonumber(str:match("i(%d+)"))
            local icon = select(5, GetItemInfoInstant(itemID))
            tinsert(icons, icon)
            if itemCached[itemID] then
                tinsert(links, itemCached[itemID])
            else
                local item = Item:CreateFromItemID(itemID)
                item:ContinueOnItemLoad(function()
                    local link = select(2, GetItemInfo(itemID))
                    itemCached[itemID] = link
                    tinsert(links, link)
                end)
            end
        end
    end
    local iconTexs = ""
    for _, icon in ipairs(icons) do
        iconTexs = iconTexs .. (format("|T%s:%s:%s:0:0:100:100:07:93:07:93|t",
            icon, aura_env.iconSize, aura_env.iconSize))
    end
    return links, iconTexs
end

local function SendMsg(player, link, delayTime, now)
    if now then
        SendChatMessage(format("提醒：你需立刻施放%s", link), "WHISPER", nil, player)
    else
        SendChatMessage(format("提醒: %s秒后你需施放%s", delayTime, link), "WHISPER", nil, player)
    end
end

function aura_env.SendMsg(player, link, delayTime, now)
    if delayTime > 0 then
        SendMsg(player, link, delayTime, now)
        if delayTime - 1 > 0 and not now then
            C_Timer.After(delayTime - 1, function()
                SendMsg(player, link, 1)
            end)
        end
    end
end

local realmName_chat = GetRealmName():gsub(" %- ", "")
function aura_env.GSN(name)
    if not name then return end
    local name, realm = strsplit("-", name)
    if not realm or realm == "" or realm == realmName_chat then
        return name
    else
        return name .. "-" .. realm
    end
end

function aura_env.IsLeader(player)
    player = aura_env.GSN(player)
    return BGDEBUG or UnitIsGroupLeader(player) or UnitIsGroupAssistant(player)
end

function aura_env.SetState(a, info)
    local tbl = {
        show = true,
        progressType = 'timed',
        changed = true,
        expirationTime = info.duration + GetTime(),
        totalTime = info.duration,
    }
    for k, v in pairs(info) do
        tbl[k] = v
    end
    a[info.count] = tbl
end

function aura_env.PlayerSound(text)
    if issecure then
        C_VoiceChat.SpeakText(0, text, 3, 100)
    else
        C_VoiceChat.SpeakText(0, text, Enum.VoiceTtsDestination.LocalPlayback, 3, 100)
    end
end

-- 条件
aura_env.state.sounded = true
C_Timer.After(0.3, function()
    aura_env.PlayerSound("交技能")
end)
aura_env.state.sounded = true
C_Timer.After(0.3, function()
    aura_env.PlayerSound("技能准备")
end)

aura_env.state.whispered = true
local sendWhisperTime = aura_env.state.sendWhisperTime
local player = aura_env.state.player
local now = aura_env.state.now
local links = ""
for _, link in ipairs(aura_env.state.links) do
    links = links .. link
end
aura_env.SendMsg(player, links, sendWhisperTime, now)


-- 触发器
a = function(a, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg, distType, _, sender = ...
        if prefix == "TuanJianBoard2" and distType == "RAID" and aura_env.IsLeader(sender) then
            local msgType, bossSpellID, index, player, duration,
            spellIDs, autoHide, now = strsplit(",", msg)
            bossSpellID             = tonumber(bossSpellID)
            index                   = tonumber(index)
            duration                = tonumber(duration)
            if msgType == "show" then
                if aura_env.myName ~= player then
                    if aura_env.config.whoShow == 1 and not aura_env.IsLeader("player") then
                        return true
                    end
                    if aura_env.config.whoShow == 3 then
                        return true
                    end
                end
                aura_env.count = aura_env.count + 1
                local links, iconTexs = aura_env.GetLinksAndIcons(spellIDs)
                local isMe = aura_env.myName == player
                local colorPlayer = aura_env.SetColorName(player)
                local canWhisper = aura_env.config.whisper and aura_env.IsLeader("player") and sender == aura_env.myName
                local sendWhisperTime
                if canWhisper then
                    if duration >= 5 then
                        sendWhisperTime = 5
                    elseif duration < 5 and duration >= 3 then
                        sendWhisperTime = 3
                    elseif duration < 3 and duration > 0 then
                        sendWhisperTime = 1
                    end
                end
                local info = {
                    count = aura_env.count,
                    autoHide = autoHide == "autoHide" and true or false,
                    duration = duration,
                    bossSpellID = bossSpellID,
                    index = index,
                    player = player,
                    colorPlayer = colorPlayer,
                    colorPlayer2 = isMe and "|cff00ff00>> 你 <<|r" or colorPlayer,
                    links = links,
                    iconTexs = iconTexs,
                    isMe = isMe,
                    sender = sender,
                    totalTime = duration,
                    sendWhisperTime = sendWhisperTime or -1,
                    canWhisper = canWhisper,
                    now = now == "now" and true or false,
                    sounded = false,
                    whispered = false,
                }
                if duration > aura_env.config.remainingTime then
                    info.duration = aura_env.config.remainingTime
                    local delay = duration - aura_env.config.remainingTime
                    local timer = WeakAuras.timer:ScheduleTimer(WeakAuras.ScanEvents, delay, 'TUANJIAN_BOARD_DELAY', info)
                    aura_env.scheduledTimers[bossSpellID] = aura_env.scheduledTimers[bossSpellID] or {}
                    tinsert(aura_env.scheduledTimers[bossSpellID], timer)
                else
                    aura_env.SetState(a, info)
                end
            elseif msgType == "hide" then
                aura_env.HideOne(a, bossSpellID)
            elseif msgType == "hideAll" then
                aura_env.HideAll(a)
            end
        end
    elseif event == "TUANJIAN_BOARD_DELAY" then
        local info = ...
        aura_env.SetState(a, info)
    elseif event == "ENCOUNTER_START" or event == "ENCOUNTER_END" or event == "RAID_INSTANCE_WELCOME" then
        aura_env.HideAll(a)
    end
    return true
end

a = {
    expirationTime  = true,
    autoHide        = 'bool',
    isMe            = 'bool',
    totalTime       = "number",
    canWhisper      = 'bool',
    sendWhisperTime = "number",
    now             = 'bool',
    sounded         = 'bool',
    whispered       = 'bool',
}

a = function(a, event, ...)
    if event == "CHAT_MSG_ADDON" then
        local prefix, msg, distType, _, sender = ...
        if prefix == "TuanJianBoardVer" and distType == "RAID" and msg == "VersionCheck" then
            C_ChatInfo.SendAddonMessage("TuanJianBoardVer", "MyVer-" .. aura_env.ver, "RAID")
        end
    elseif event == "GROUP_ROSTER_UPDATE" and IsInRaid(1) then
        if aura_env.CanSend() then
            C_Timer.After(1, function()
                if IsInRaid(1) then
                    C_ChatInfo.SendAddonMessage("TuanJianBoardVer", "MyVer-" .. aura_env.ver, "RAID")
                end
            end)
        end
    end
end

-- 图示
a = function()
    if WeakAuras.IsOptionsOpen() then
        return format("|T%s:%s:%s:0:0:100:100:07:93:07:93|t", 253400, aura_env.iconSize, aura_env.iconSize), "玩家姓名"
    else
        return aura_env.state.iconTexs, aura_env.state.colorPlayer2
    end
end

--[[
local bossSpellID = aura_env.state.bossSpellID
local sendWhisperTime = aura_env.state.sendWhisperTime
local now = aura_env.state.now
for name, v in pairs(aura_env.bossSpells[bossSpellID]) do
    local player, sender = strsplit(":", name)
    if sender == aura_env.myName then
        local links = ""
        for _, link in pairs(v) do
            links = links .. link
        end
        aura_env.SendMsg(player, links, sendWhisperTime, now)
    end
end

function aura_env.InsertLink(bossSpellID, player, sender, spellID, itemID)
    local name = player .. ":" .. sender
    aura_env.bossSpells[bossSpellID] = aura_env.bossSpells[bossSpellID] or {}
    aura_env.bossSpells[bossSpellID][name] = aura_env.bossSpells[bossSpellID][name] or {}
    local tbl = aura_env.bossSpells[bossSpellID][name]
    if spellID then
        if spellCached[spellID] then
            tinsert(tbl, spellCached[spellID])
        else
            local spell = Spell:CreateFromSpellID(spellID)
            spell:ContinueOnSpellLoad(function()
                local link = C_Spell.GetSpellLink(spellID)
                spellCached[spellID] = link
                tinsert(tbl, link)
            end)
        end
    elseif itemID then
        if itemCached[itemID] then
            tinsert(tbl, itemCached[itemID])
        else
            local item = Item:CreateFromItemID(itemID)
            item:ContinueOnItemLoad(function()
                local link = select(2, GetItemInfo(itemID))
                itemCached[itemID] = link
                tinsert(tbl, link)
            end)
        end
    end
end

function aura_env.RemoveLink(bossSpellID)
    if aura_env.bossSpells[bossSpellID] then
        wipe(aura_env.bossSpells[bossSpellID])
    end
end


/run C_VoiceChat.SpeakText(0, "交技能", 3, 100,true)


]]
