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

local auraInstanceIDTbl = {}
local guidIndex = 100
local SaveGUID
local summon = {}
local lastStartTime = {}
local lastEndTime = {}

local newLog, newEvent, newTime
TJ.combatLogEvent = {}
TJ.boardEvent = {}
local boardEvent = TJ.boardEvent

local cacheAccess = 0
local function TouchCombatLogCache(entry)
    cacheAccess = cacheAccess + 1
    entry.lastUsed = cacheAccess
end

function TJ.TrimCombatLogCache()
    local limit = math.max(1, math.min(20,
        math.floor(tonumber(TuanJian.options.combatLogCacheCount) or 3)))
    local selectedLog = TuanJian.combatLog[TJ.combatLogIndex]
    local selectedTime = selectedLog and selectedLog.time
    local count = 0
    for _, entry in pairs(TJ.combatLogEvent) do
        if entry.persisted then count = count + 1 end
    end
    while count > limit do
        local oldestTime, oldestAccess
        for eventTime, entry in pairs(TJ.combatLogEvent) do
            -- 未保存完成的事件表不计入限额，当前查看/记录的日志不能被淘汰。
            if entry.persisted and eventTime ~= selectedTime and eventTime ~= newTime then
                local access = entry.lastUsed or 0
                if not oldestAccess or access < oldestAccess then
                    oldestTime, oldestAccess = eventTime, access
                end
            end
        end
        if not oldestTime then break end
        TJ.combatLogEvent[oldestTime] = nil
        count = count - 1
    end
end

local function ForgetCombatLogCache(eventTime)
    local state = TJ._decompressState
    if state and state.eventTime == eventTime then
        TJ.CancelDecompress(state.FB, state.bossIndex)
    end
    TJ.combatLogEvent[eventTime] = nil
end

local function GetEncounterID(bossID)
    for i, vv in ipairs(TJ.FBtbl) do
        local FB = vv.FB
        for bossIndex, v in ipairs(TJ.FBinfo[FB]) do
            for _, encounterID in ipairs(v.encounterID) do
                if encounterID == bossID and not v.hide then
                    return FB, bossIndex
                end
            end
        end
    end
end
local function GetBossName(bossID)
    for i, vv in ipairs(TJ.FBtbl) do
        local FB = vv.FB
        for bossIndex, v in ipairs(TJ.FBinfo[FB]) do
            for _, encounterID in ipairs(v.encounterID) do
                if encounterID == bossID then
                    return v.name
                end
            end
        end
    end
    return ""
end

-- 获取战斗日志
do
    function TJ.GetNewCombatLog()
        return newLog or { otherTime = {} }
    end

    function TJ.GetNewEvent()
        return newEvent
    end

    function TJ.GetCombatLog(combatLogIndex)
        return TuanJian.combatLog[combatLogIndex or TJ.combatLogIndex]
    end

    function TJ.GetCombatLogEvent(combatLogIndex)
        local combatLog = TuanJian.combatLog[combatLogIndex or TJ.combatLogIndex]
        if combatLog and combatLog.time and TJ.combatLogEvent[combatLog.time] then
            local entry = TJ.combatLogEvent[combatLog.time]
            TouchCombatLogCache(entry)
            return entry.event, entry
        end
    end
end

-- 清空战斗日志
function TJ.ClearCombatLog(FB, bossIndex, combatLogTime)
    for i = #TuanJian.combatLog, 1, -1 do
        local combatLog = TuanJian.combatLog[i]
        if combatLog.FB == FB and (not bossIndex or combatLog.bossIndex == bossIndex)
            and (not combatLogTime or combatLog.time == combatLogTime) then
            ForgetCombatLogCache(combatLog.time)
            tremove(TuanJian.combatLog, i)
        end
    end
    TJ.TrimCombatLogCache()
    TJ.UpdateDispelFrameDelay()
end

function TJ.ClearOutCombatLog()
    -- 先清空特殊日志
    local logs = {}
    local needDeleteLog = {}
    for i, v in ipairs(TuanJian.combatLog) do
        logs[v.FB .. v.bossIndex] = logs[v.FB .. v.bossIndex] or 0
        logs[v.FB .. v.bossIndex] = logs[v.FB .. v.bossIndex] + 1
        if (logs[v.FB .. v.bossIndex] > 3 and (v.FB == TuanJian.FB and v.bossIndex == TuanJian.bossIndex))
            or (logs[v.FB .. v.bossIndex] > 1 and not (v.FB == TuanJian.FB and v.bossIndex == TuanJian.bossIndex))
        then
            tinsert(needDeleteLog, i)
        end
    end
    if next(needDeleteLog) then
        for i = #TuanJian.combatLog, 1, -1 do
            local combatLog = TuanJian.combatLog[i]
            if TJ.ValueInTable(needDeleteLog, i) then
                ForgetCombatLogCache(combatLog.time)
                tremove(TuanJian.combatLog, i)
            end
        end
    end
    -- 再清空常规日志
    local saveLogCount = TuanJian.options.saveLogCount
    for i = #TuanJian.combatLog, 1, -1 do
        local combatLog = TuanJian.combatLog[i]
        if i > saveLogCount then
            ForgetCombatLogCache(combatLog.time)
            tremove(TuanJian.combatLog, i)
        end
    end
    TJ.TrimCombatLogCache()
end

local auraType = { HELPFUL = 40, HARMFUL = 20 }
local function SaveRaidAura(FB, bossIndex)
    if IsInRaid(1) then
        local combatLog = TJ.GetNewCombatLog()
        for i = 1, GetNumGroupMembers(1) do
            -- 记录已有光环
            local unit = "raid" .. i
            for auraType, auraCount in pairs(auraType) do
                for auraIndex = 1, auraCount do
                    local aura = C_UnitAuras.GetAuraDataByIndex(unit, auraIndex, auraType)
                    if not aura then break end
                    local sourceGUID = aura.sourceUnit and UnitGUID(aura.sourceUnit) or "UNKNOWN"
                    local destGUID = UnitGUID(unit)
                    tinsert(newEvent.SPELL_AURA_APPLIED, {
                        0,
                        nil,
                        nil,
                        sourceGUID,
                        nil,
                        nil,
                        nil,
                        destGUID,
                        nil,
                        nil,
                        nil,
                        aura.spellId,
                    })
                    if TJ.frame[FB][bossIndex].saveAura then
                        for _, spellID in ipairs(TJ.frame[FB][bossIndex].saveAura) do
                            if spellID == aura.spellId then
                                auraInstanceIDTbl[destGUID] = auraInstanceIDTbl[destGUID] or {}
                                auraInstanceIDTbl[destGUID][aura.auraInstanceID] = {
                                    sourceGUID = sourceGUID,
                                    spellID = spellID,
                                }
                                break
                            end
                        end
                    end
                end
            end
            -- 记录团员成员
            local name, rank, subgroup, level, class2, class, zone, online, isDead, role, isML, combatRole =
                GetRaidRosterInfo(i)
            if name and online then
                tinsert(combatLog.raidMember, {
                    name = name,
                    class = class,
                    role = role,
                    combatRole = combatRole,
                    talent = TuanJian.talentInfo[name],
                })
            end
            -- 记录宠物信息
            local unit = "raidpet" .. i
            local petGUID = UnitGUID(unit)
            if petGUID then
                guidIndex = guidIndex + 1
                combatLog.guid[petGUID] = {
                    name = UnitName(unit),
                    ownerGUID = UnitGUID(unit:gsub("pet", "")),
                    ownerName = GetUnitName(unit:gsub("pet", ""), true),
                    index = guidIndex,
                }
                combatLog.guidIndex[tostring(guidIndex)] = petGUID
            end
        end
    end
end
--[[
/run TJ.ENCOUNTER_START(nil,nil,729)
/run TJ.ENCOUNTER_END(nil,nil,729)
]]
function TJ.ENCOUNTER_START(self, event, bossID, bossName, difficultyID, groupSize, _, isDBM)
    if BGDEBUG and IsInRaid(1) then
        print("ENCOUNTER_START", bossID, bossName, difficultyID, groupSize, isDBM)
    end
    if not bossID then return end
    if lastStartTime[bossID] and GetTime() - lastStartTime[bossID] < 5 then
        return
    end
    lastStartTime[bossID] = GetTime()
    if lastEndTime[bossID] and GetTime() - lastEndTime[bossID] < 5 then
        return
    end
    if TJ.startTime then return end
    if TJ.StartBurstPotionMonitor then
        TJ.StartBurstPotionMonitor()
    end
    local FB, bossIndex = GetEncounterID(bossID)
    if FB then
        newTime = time()
        newLog = {
            FB = FB,
            bossIndex = bossIndex,
            time = newTime,
            duration = 0,
            guid = {
                UNKNOWN = { name = L["未知"] },
            },
            guidIndex = {},
            otherTime = {},
            event = {},
            raidMember = {},
            dispel = {},
        }
        tinsert(TuanJian.combatLog, 1, newLog)

        guidIndex = 100
        wipe(auraInstanceIDTbl)
        TuanJian.FB = FB
        TJ.UpdateBossChooseFrame()
        TJ.UpdateBossFrame(bossIndex)
        TJ.ClearTitleColor(FB, bossIndex)
        TJ.lastChooseLog = newTime
        TJ.MainFrame:Hide()
        TJ.startTime = GetTime()
        TJ.eventCount = 0
        TJ.combatLastFB = FB
        TJ.combatLastBossIndex = bossIndex
        TJ.combatLastBossID = bossID
        TJ.CancelDecompress(FB, bossIndex)

        newEvent = {}
        newEvent.SPELL_AURA_APPLIED = {}

        TJ.combatLogEvent[newTime] = {
            FB = FB,
            bossIndex = bossIndex,
            time = newTime,
            titleColor = {},
            event = newEvent,
        }
        TouchCombatLogCache(TJ.combatLogEvent[newTime])

        TJ.ClearOutCombatLog()

        local frame = TJ.frame[FB][bossIndex]
        if frame.autoRT then
            TJ.setRTinCombat = TuanJian.options[frame.autoRT] == 1
        end
        if frame.ENCOUNTER_START then
            frame.ENCOUNTER_START(difficultyID, isDBM)
        end
        TJ.Board_ENCOUNTER_START(FB, bossIndex)
        -- 记录已有光环、团队成员、宠物信息
        SaveRaidAura(FB, bossIndex)
        -- 记录BOSS战前提前召唤的守护者（图腾、大军之类）
        for guid, v in pairs(summon) do
            SaveGUID(FB, bossIndex, guid, v.name)
        end
    end
end

function TJ.ENCOUNTER_END(self, event, bossID, bossName, difficultyID, groupSize, success, isDBM)
    if BGDEBUG and IsInRaid(1) then
        print("ENCOUNTER_END", bossID, bossName, difficultyID, groupSize, success, isDBM)
    end
    if not bossID then return end
    if TJ.ScheduleBurstPotionMonitorReset then
        TJ.ScheduleBurstPotionMonitorReset()
    end
    lastEndTime[bossID] = GetTime()
    local FB, bossIndex = GetEncounterID(bossID)
    if TJ.startTime and FB then
        TJ.combatLastFB = nil
        TJ.combatLastBossIndex = nil
        TJ.combatLastBossID = nil
        TJ.setRTinCombat = nil
        wipe(summon)
        local combatLog = TJ.GetNewCombatLog()
        if combatLog.otherTime.END then
            combatLog.duration = combatLog.otherTime.END
            combatLog.otherTime.END = nil
        else
            combatLog.duration = TJ.GetDurTime()
        end
        if TJ.frame[FB][bossIndex].ENCOUNTER_END then
            TJ.frame[FB][bossIndex].ENCOUNTER_END(success)
        end
        if success == 1 then
            if TuanJian.options.showUIAfterKillBossSuccess == 1 then
                After(3, function()
                    TJ.MainFrame:Show()
                    if TuanJian.lastFrameNum ~= TJ.raidMainFrameTabNum then
                        TJ.ClickTabButton(TJ.raidMainFrameTabNum)
                    end
                end)
            end
        else
            if TuanJian.options.showUIAfterKillBossFalse == 1 and TJ.GetDurTime() >= 10 then
                After(2, function()
                    TJ.MainFrame:Show()
                    if TuanJian.lastFrameNum ~= TJ.raidMainFrameTabNum then
                        TJ.ClickTabButton(TJ.raidMainFrameTabNum)
                    end
                end)
            end
        end
        TJ.SaveCombatEvents(FB, bossIndex)
        TJ.Board_ENCOUNTER_END()
        TJ.startTime = nil
        newLog = nil
        newEvent = nil
        newTime = nil
        TJ.TrimCombatLogCache()
    end
end

TJ.RegisterEvent("ENCOUNTER_START", TJ.ENCOUNTER_START)
TJ.RegisterEvent("ENCOUNTER_END", TJ.ENCOUNTER_END)

TJ.Init2(function()
    if DBM then
        local DBMCallback = function(event, id, msg, duration, icon, timerType, spellID)
            for _, func in ipairs(TJ.DBMCallback) do
                func(event, id, msg, duration, icon, timerType, spellID)
            end
        end
        DBM:RegisterCallback("DBM_TimerBegin", DBMCallback)
        DBM:RegisterCallback("DBM_TimerStart", DBMCallback)
        DBM:RegisterCallback("DBM_TimerStop", DBMCallback)

        DBM:RegisterCallback("DBM_Pull", function(self, mod, delay, synced, startHp)
            local bossID = mod.combatInfo.eId
            TJ.ENCOUNTER_START(nil, nil, bossID, nil, nil, nil, nil, true)
        end)
        DBM:RegisterCallback("DBM_Wipe", function(self, mod)
            local bossID = mod.combatInfo.eId
            TJ.ENCOUNTER_END(nil, nil, bossID, nil, nil, nil, 0, true)
        end)
        DBM:RegisterCallback("DBM_Kill", function(self, mod)
            local bossID = mod.combatInfo.eId
            TJ.ENCOUNTER_END(nil, nil, bossID, nil, nil, nil, 1, true)
        end)
    end
end)

-- 战斗日志事件
do
    TJ.allEvent = { all = {}, lookup1 = {}, lookup2 = {} }
    -- 要保存当前血量的事件
    TJ.allEvent.spEvent2 = {
        "_DAMAGE$", "DAMAGE_SPLIT", "_HEAL$", "_MISSED$", "UNIT_DIED",
    }
    -- 光环事件
    TJ.allEvent.spEvent4 = {
        "SPELL_AURA_APPLIED", "SPELL_AURA_REMOVED", "SPELL_AURA_APPLIED_DOSE", "SPELL_AURA_REMOVED_DOSE",
    }
    -- 驱散事件
    TJ.allEvent.spEvent5 = {
        "SPELL_DISPEL", "SPELL_STOLEN",
    }
    -- 打断事件
    TJ.allEvent.spEvent6 = {
        "SPELL_INTERRUPT",
    }
    -- 施法事件
    TJ.allEvent.spEvent7 = {
        "SPELL_CAST_SUCCESS", "SPELL_CAST_START", "SPELL_CAST_FAILED",
    }
    -- 破控事件
    TJ.allEvent.spEvent8 = {
        "SPELL_AURA_BROKEN", "SPELL_AURA_BROKEN_SPELL",
    }
    -- 要保存的所有事件
    for tblName, v in pairs(TJ.allEvent) do
        if tblName ~= "all" then
            for _, event in pairs(TJ.allEvent[tblName]) do
                tinsert(TJ.allEvent.all, event)
            end
        end
    end
    for _, event in ipairs(TJ.allEvent.all) do
        if event:sub(-1) == "$" then
            local suffix = event:sub(1, -2) -- 去掉 $
            TJ.allEvent.lookup2[suffix] = true
        else
            TJ.allEvent.lookup1[event] = true
        end
    end
end

SaveGUID = function(FB, bossIndex, guid, name)
    if not guid then return end
    local combatLog = TJ.GetNewCombatLog()
    if TJ.raidRosterGUID[guid] then
        if not combatLog.guid[guid] then
            guidIndex = guidIndex + 1
            combatLog.guid[guid] = {
                name = TJ.raidRosterGUID[guid].name,
                class = TJ.raidRosterGUID[guid].class,
                index = guidIndex,
            }
            combatLog.guidIndex[tostring(guidIndex)] = guid
        end
    elseif not combatLog.guid[guid] then
        guidIndex = guidIndex + 1
        local owner = summon[guid]
        if owner then
            combatLog.guid[guid] = {
                name = name or UNKNOWN,
                ownerName = owner.ownerName,
                ownerGUID = owner.ownerGUID,
                index = guidIndex,
            }
        else
            combatLog.guid[guid] = {
                name = name or UNKNOWN,
                index = guidIndex,
            }
        end
        combatLog.guidIndex[tostring(guidIndex)] = guid
    end
    return combatLog.guid[guid].index
end

local function SaveHP(tbl, destGUID, destName, subevent)
    local yes, boss
    if TJ.raidRosterGUID[destGUID] then
        yes = true
    end
    if not yes then
        local npcType, _, _, _, _, npcID = strsplit("-", destGUID)
        if npcType == "Creature" or npcType == "Vehicle" then
            npcID = tonumber(npcID)
            if npcID == 36789 then -- ICC绿龙也要记录血量
                boss = "boss1"
            end
        end
    end
    if yes or boss then
        for _, key in pairs(TJ.allEvent.spEvent2) do
            if subevent:match(key) then
                tbl.hp = UnitHealth(boss or destName)
                tbl.maxhp = UnitHealthMax(boss or destName)
                break
            end
        end
    end
end

local function CheckFlags(flags)
    if type(flags) == "number" then
        local raidTarget = bit.band(flags, COMBATLOG_OBJECT_RAIDTARGET_MASK)
        if (raidTarget == 0) then
            return nil
        end
        if (raidTarget == COMBATLOG_OBJECT_RAIDTARGET1) then
            return 1
        elseif (raidTarget == COMBATLOG_OBJECT_RAIDTARGET2) then
            return 2
        elseif (raidTarget == COMBATLOG_OBJECT_RAIDTARGET3) then
            return 3
        elseif (raidTarget == COMBATLOG_OBJECT_RAIDTARGET4) then
            return 4
        elseif (raidTarget == COMBATLOG_OBJECT_RAIDTARGET5) then
            return 5
        elseif (raidTarget == COMBATLOG_OBJECT_RAIDTARGET6) then
            return 6
        elseif (raidTarget == COMBATLOG_OBJECT_RAIDTARGET7) then
            return 7
        elseif (raidTarget == COMBATLOG_OBJECT_RAIDTARGET8) then
            return 8
        end
    end
end

local function SaveDispel(subevent, spellID, Guid, sourceSpellID)
    if TJ.ValueInTable(TJ.allEvent.spEvent5, subevent) and TJ.dispelInfo[spellID]
        and not TJ.ValueInTable(TJ.banDispel, sourceSpellID) then
        local combatLog = TJ.GetNewCombatLog()
        while combatLog.guid[Guid] and combatLog.guid[Guid].ownerGUID do
            Guid = combatLog.guid[Guid].ownerGUID
        end
        combatLog.dispel[spellID] = combatLog.dispel[spellID] or {}
        combatLog.dispel[spellID][Guid] = combatLog.dispel[spellID][Guid] or 0
        combatLog.dispel[spellID][Guid] = combatLog.dispel[spellID][Guid] + 1
        if TJ.UpdateDispelFrameDelay then
            TJ.UpdateDispelFrameDelay()
        end
    end
end

local lookup1 = TJ.allEvent.lookup1
local lookup2 = TJ.allEvent.lookup2
local function COMBAT_LOG_EVENT_UNFILTERED(_, _, ...)
    -- pt(...)
    local FB = TJ.combatLastFB
    local bossIndex = TJ.combatLastBossIndex
    local _, subevent, _, sourceGUID, sourceName, _, sourceRaidFlags, destGUID, destName, _, destRaidFlags = ...
    if subevent == "SPELL_SUMMON" and select(2, IsInInstance()) == "raid" then
        summon[destGUID] = {
            ownerName = sourceName,
            ownerGUID = sourceGUID,
            name = destName,
        }
        if FB and bossIndex then
            SaveGUID(FB, bossIndex, destGUID, destName)
        end
    end

    if subevent == 'UNIT_DIED' and destGUID then
        local delete = {}
        for i, guid in pairs(TJ.ActiveAutoRaidTarget) do
            if guid == destGUID then
                delete[i] = true
            end
        end
        for i in pairs(delete) do
            TJ.ActiveAutoRaidTarget[i] = nil
        end
    end

    if not (FB and bossIndex and TJ.startTime) then return end
    local now = TJ.GetDurTime()
    TJ.GetNewCombatLog().duration = now

    local frame = TJ.frame[FB][bossIndex]
    if frame[subevent] then
        frame[subevent](...)
    end
    if not (TJ.combatLastFB and TJ.combatLastBossIndex and TJ.startTime) then return end

    if frame.board and boardEvent[subevent] then
        boardEvent[subevent](...)
    end

    local yes = lookup1[subevent]
    if not yes then
        for suffix in pairs(lookup2) do
            if subevent:sub(- #suffix) == suffix then
                yes = true
                break
            end
        end
    end
    if not yes then return end

    local sourceGuidIndex = SaveGUID(FB, bossIndex, sourceGUID, sourceName)
    local destGuidIndex = SaveGUID(FB, bossIndex, destGUID, destName)
    -- 直接构造保留字段；第12项起的事件参数仍使用原始索引。
    local tbl = {
        now,
        nil,
        nil,
        sourceGuidIndex,
        nil,
        nil,
        CheckFlags(sourceRaidFlags),
        destGuidIndex,
        nil,
        nil,
        CheckFlags(destRaidFlags),
        select(12, ...),
    }
    TJ.eventCount = TJ.eventCount + 1
    tbl.i = TJ.eventCount
    SaveHP(tbl, destGUID, destName, subevent)
    SaveDispel(subevent, tbl[15], sourceGUID, tbl[12])
    newEvent[subevent] = newEvent[subevent] or {}
    tinsert(newEvent[subevent], tbl)
end

-- 事件
do
    TJ.RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", COMBAT_LOG_EVENT_UNFILTERED)

    local function UNIT_SPELLCAST_SUCCEEDED(_, _, unit, _, spellID)
        -- pt(unit, TJ.GN(unit), spellID, GetSpellLink(spellID))
        if TJ.startTime and TJ.combatLastFB and TJ.combatLastBossIndex then
            local frame = TJ.frame[TJ.combatLastFB][TJ.combatLastBossIndex]
            if frame and frame.UNIT_SPELLCAST_SUCCEEDED then
                frame.UNIT_SPELLCAST_SUCCEEDED(unit, spellID)
            end
        end
    end
    TJ.RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UNIT_SPELLCAST_SUCCEEDED)

    local function UNIT_SPELLCAST_INTERRUPTED(_, _, unit, castGUID, spellID)
        if TJ.startTime and TJ.combatLastFB and TJ.combatLastBossIndex then
            local frame = TJ.frame[TJ.combatLastFB][TJ.combatLastBossIndex]
            if frame and frame.UNIT_SPELLCAST_INTERRUPTED then
                frame.UNIT_SPELLCAST_INTERRUPTED(unit, spellID, castGUID)
            end
        end
    end
    TJ.RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)

    local function INSTANCE_ENCOUNTER_ENGAGE_UNIT(_, _)
        if TJ.startTime and TJ.combatLastFB and TJ.combatLastBossIndex then
            local frame = TJ.frame[TJ.combatLastFB][TJ.combatLastBossIndex]
            if frame and frame.INSTANCE_ENCOUNTER_ENGAGE_UNIT then
                frame.INSTANCE_ENCOUNTER_ENGAGE_UNIT()
            end
        end
    end
    TJ.RegisterEvent("INSTANCE_ENCOUNTER_ENGAGE_UNIT", INSTANCE_ENCOUNTER_ENGAGE_UNIT)

    local function GetAuraText(unit, auraInstanceID)
        for i = 1, 60 do
            local info = C_UnitAuras.GetAuraDataByIndex(unit, i, 'HELPFUL')
            if info and info.auraInstanceID == auraInstanceID then
                TuanJianTooltip:SetOwner(UIParent, "ANCHOR_NONE")
                TuanJianTooltip:ClearLines()
                TuanJianTooltip:SetUnitBuff(unit, i, 'HELPFUL')
                local text = TuanJianTooltipTextLeft2
                local str = text and text:GetText()
                if str then
                    local num = str:match(L['(%d+)'])
                    num = tonumber(num)
                    local _unit = unit:gsub("pet", "")
                    TJ.GetNewEvent()["TRIGGER"] =
                        TJ.GetNewEvent()["TRIGGER"] or {}
                    local tbl = {
                        TJ.GetDurTime(),
                        "TRIGGER",
                        nil,
                        UnitGUID(_unit),
                        TJ.GN(_unit),
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        nil,
                        TJ.SSpowerSpell,
                        nil,
                        nil,
                        num,
                    }
                    tbl.i = 1
                    tinsert(TJ.GetNewEvent()["TRIGGER"], tbl)
                end
                return
            end
        end
    end
    local function UNIT_AURA(_, _, unit, info)
        if not TJ.startTime or info.isFullUpdate then return end
        local FB = TJ.combatLastFB
        local bossIndex = TJ.combatLastBossIndex
        if FB and bossIndex then
            local destGUID = UnitGUID(unit)
            -- 记录图腾抗性
            local saveAura = TJ.frame[FB][bossIndex].saveAura
            if saveAura and unit:match("raid%d+$") then
                if info.addedAuras then
                    for _, v in pairs(info.addedAuras) do
                        if saveAura[v.spellId] then
                            local sourceGUID = v.sourceUnit and UnitGUID(v.sourceUnit) or "UNKNOWN"
                            auraInstanceIDTbl[destGUID] = auraInstanceIDTbl[destGUID] or {}
                            auraInstanceIDTbl[destGUID][v.auraInstanceID] = {
                                sourceGUID = sourceGUID,
                                spellID = v.spellId,
                            }
                            tinsert(newEvent.SPELL_AURA_APPLIED, {
                                TJ.GetDurTime(),
                                nil,
                                nil,
                                sourceGUID,
                                nil,
                                nil,
                                nil,
                                destGUID,
                                nil,
                                nil,
                                nil,
                                v.spellId,
                            })
                            break
                        end
                    end
                end
                if info.removedAuraInstanceIDs then
                    for _, auraInstanceID in pairs(info.removedAuraInstanceIDs) do
                        local tbl = auraInstanceIDTbl[destGUID] and auraInstanceIDTbl[destGUID][auraInstanceID]
                        if tbl then
                            newEvent.SPELL_AURA_REMOVED = newEvent.SPELL_AURA_REMOVED or {}
                            tinsert(newEvent.SPELL_AURA_REMOVED, {
                                TJ.GetDurTime(),
                                nil,
                                nil,
                                tbl.sourceGUID,
                                nil,
                                nil,
                                nil,
                                destGUID,
                                nil,
                                nil,
                                nil,
                                tbl.spellID,
                            })
                        end
                    end
                end
            end
            -- 恶魔契约
            if TJ.SSpowerSpell and unit:match("raidpet%d+") then
                if info.addedAuras then
                    for _, aura in pairs(info.addedAuras) do
                        if aura.spellId == TJ.SSpowerSpell then
                            if destGUID == UnitGUID(aura.sourceUnit) then
                                GetAuraText(unit, aura.auraInstanceID)
                            end
                            return
                        end
                    end
                end
                if info.updatedAuraInstanceIDs then
                    for _, auraInstanceID in pairs(info.updatedAuraInstanceIDs) do
                        local aura = C_UnitAuras.GetAuraDataByAuraInstanceID(unit, auraInstanceID)
                        if aura and aura.spellId == TJ.SSpowerSpell then
                            if destGUID == UnitGUID(aura.sourceUnit) then
                                GetAuraText(unit, aura.auraInstanceID)
                            end
                            return
                        end
                    end
                end
            end
            -- 提前结束战斗记录
            if unit == "player" and info.addedAuras then
                for _, v in pairs(info.addedAuras) do
                    if v.spellId == 8326 then -- 阿尔萨斯拔尖
                        TJ.ENCOUNTER_END(nil, nil, TJ.combatLastBossID)
                        return
                    end
                end
            end
        end
    end
    TJ.RegisterEvent("UNIT_AURA", UNIT_AURA)
end

-- BOSS喊话
do
    local f = CreateFrame("Frame")
    f:RegisterEvent("CHAT_MSG_MONSTER_YELL")
    f:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
    f:RegisterEvent("CHAT_MSG_MONSTER_SAY")
    f:RegisterEvent("CHAT_MSG_MONSTER_WHISPER")
    f:RegisterEvent("CHAT_MSG_RAID_BOSS_EMOTE")
    f:RegisterEvent("CHAT_MSG_RAID_BOSS_WHISPER")
    f:RegisterEvent("RAID_BOSS_EMOTE")
    f:RegisterEvent("RAID_BOSS_WHISPER")
    f:SetScript("OnEvent", function(self, event, msg, ...)
        if TJ.startTime and TJ.combatLastFB and TJ.combatLastBossIndex then
            local FB = TJ.combatLastFB
            local bossIndex = TJ.combatLastBossIndex
            if TJ.frame[FB][bossIndex] and TJ.frame[FB][bossIndex].BOSS_SAY then
                TJ.frame[FB][bossIndex].BOSS_SAY(msg, ...)
            end
        end
        if msg == L['很好，我会制造一个空间来隔离你们的腐蚀。'] and TJ.IsMOP then
            TJ.ENCOUNTER_START(nil, nil, 1624, nil, nil, nil, nil, nil)
        end
        if not TJ.startTime and select(8, GetInstanceInfo()) == 603 then
            if msg and (msg:find("我不是来这里跟你们打架的", 1, true)
                or msg:find("如果我的分析结果表明", 1, true)) then
                TJ.algalonFirstPull = true
            end
        end
    end)
end

-- 压缩并保存战斗事件
do
    local recordsPerFrame = 10  -- 保持原来的每帧转换上限。
    local recordsPerBlock = 500 -- 文本缓冲达到上限就压缩，不积累整场文本。
    local saveQueue = {}
    local activeSave

    local function IsLogRetained(combatLog)
        for _, log in ipairs(TuanJian.combatLog) do
            if log == combatLog then return true end
        end
        return false
    end

    local function TblToString(tbl, fields)
        wipe(fields)
        for k, v in pairs(tbl) do
            if k and v then
                if type(v) == "boolean" then
                    v = "t"
                end
                fields[#fields + 1] = k .. "^" .. v .. "!"
            end
        end
        return table.concat(fields)
    end

    local function FlushBlock(state)
        if #state.buffer == 0 then return end
        local text = table.concat(state.buffer, "~")
        tinsert(state.saved[state.currentEvent], C_EncodingUtil.CompressString(text))
        wipe(state.buffer)
    end

    local function ProcessSaveFrame()
        local state = activeSave
        if not state then return end
        local finished = not IsLogRetained(state.log)
        local processed = 0
        while not finished and processed < recordsPerFrame do
            if not state.currentEvent then
                state.currentEvent = state.eventNames[state.eventIndex]
                if not state.currentEvent then
                    state.log.event = state.saved
                    local entry = TJ.combatLogEvent[state.log.time]
                    if entry then entry.persisted = true end
                    finished = true
                    break
                end
                state.saved[state.currentEvent] = {}
                state.recordIndex = 1
            end

            local records = state.source[state.currentEvent]
            if state.recordIndex <= #records then
                state.buffer[#state.buffer + 1] = TblToString(records[state.recordIndex], state.fields)
                state.recordIndex = state.recordIndex + 1
                processed = processed + 1
                if #state.buffer >= recordsPerBlock then
                    FlushBlock(state)
                end
            else
                FlushBlock(state)
                state.currentEvent = nil
                state.eventIndex = state.eventIndex + 1
            end
        end

        if finished then
            local FB, bossIndex = state.FB, state.bossIndex
            local retained = IsLogRetained(state.log)
            -- 保留缓存中的原始事件，只释放保存任务自身的临时引用。
            state.source = nil
            state.log = nil
            state.saved = nil
            state.buffer = nil
            state.fields = nil
            state.eventNames = nil
            activeSave = tremove(saveQueue, 1)
            if retained then
                TJ.TrimCombatLogCache()
                TJ.UpdateTitleColor(FB, bossIndex)
            end
        end
        if activeSave then
            After(0, ProcessSaveFrame)
        end
    end

    function TJ.SaveCombatEvents(FB, bossIndex)
        if not (newEvent and newTime and newLog) then return end
        if activeSave and activeSave.log == newLog then return end
        for _, state in ipairs(saveQueue) do
            if state.log == newLog then return end
        end
        local eventNames = {}
        for eventName in pairs(newEvent) do
            tinsert(eventNames, eventName)
        end
        local state = {
            FB = FB,
            bossIndex = bossIndex,
            log = newLog,
            source = newEvent,
            eventNames = eventNames,
            eventIndex = 1,
            saved = {},
            buffer = {},
            fields = {},
        }
        if activeSave then
            -- 连续战斗的日志依次保存，避免新任务取消上一份尚未保存的日志。
            tinsert(saveQueue, state)
        else
            activeSave = state
            After(0, ProcessSaveFrame)
        end
    end
end

-- 解压战斗事件
do
    local DECOMPRESS_BATCH = {
        eventPerFrame = 1,  -- 每帧处理的事件数量
        textPerEvent = 10,  -- 每个事件下每帧处理的文本数量
        blockPerText = 2000 -- 每个文本下每帧处理的分隔块数量（~分隔的块）
        -- blockPerText = 10000 -- 每个文本下每帧处理的分隔块数量（~分隔的块）
    }
    local function SetProcessText(FB, bossIndex, title, num)
        if not TJ["processText" .. FB .. bossIndex] then
            local f = CreateFrame("Frame", nil, TJ.frame[FB][bossIndex], "BackdropTemplate")
            f:SetBackdrop({
                bgFile = "Interface/ChatFrame/ChatFrameBackground",
            })
            f:SetBackdropColor(0, 0, 0, 0.9)
            f:SetPoint("TOPLEFT", TJ.spChild, "TOPLEFT", 0, 0)
            f:SetPoint("BOTTOMRIGHT", TJ.spChild, "BOTTOMRIGHT", 0, 0)
            f:SetFrameLevel(TJ.spChild:GetFrameLevel() + 5)
            f:EnableMouse(true)
            TJ["processText" .. FB .. bossIndex] = f
            local title = f:CreateFontString()
            title:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            title:SetPoint("CENTER", f, "CENTER", 0, 0)
            f.title = title
            local text = f:CreateFontString()
            text:SetFont(BIAOGE_TEXT_FONT, 15, "OUTLINE")
            text:SetPoint("LEFT", title, "RIGHT", 0, 0)
            f.text = text
        end
        TJ["processText" .. FB .. bossIndex]:Show()
        TJ["processText" .. FB .. bossIndex].title:SetText(title)
        TJ["processText" .. FB .. bossIndex].text:SetText(num)
    end
    -- 分帧处理状态管理（避免全局变量污染，用闭包保存）
    local function createDecompressState(FB, bossIndex, eventTime)
        local sourceData = TJ.GetCombatLog().event -- 源压缩数据
        local targetTbl = {}                       -- 最终输出的解压结果表（对应原TJ["event"..FB..bossIndex]）

        -- 提取所有事件名并转为数组（便于分帧遍历）
        local eventList = {}
        for eventName in pairs(sourceData) do
            tinsert(eventList, eventName)
        end

        return {
            FB = FB,
            bossIndex = bossIndex,
            eventTime = eventTime,
            source = sourceData,   -- 源数据：{事件名: [文本1, 文本2,...]}
            eventList = eventList, -- 事件名列表（按顺序分帧处理）
            eventIdx = 1,          -- 当前处理的事件索引
            textIdx = 1,           -- 当前事件下处理的文本索引
            target = targetTbl,    -- 最终结果表
            currentEvent = nil,    -- 当前正在处理的事件名
            currentText = nil,     -- 当前正在处理的文本
            currentTextTbl = nil,  -- 当前文本对应的解析结果表（对应原tbl1）
            -- StringToTbl内部迭代器状态
            strParseState = {
                iter1 = nil, -- 第一层迭代器（~分割）
                state1 = nil,
                start1 = nil,
                part1 = nil, -- 当前~分割块
                pos1 = nil,
                iter2 = nil, -- 第二层迭代器（!分割）
                state2 = nil,
                start2 = nil,
                part2 = nil,      -- 当前!分割块
                pos2 = nil,
                currentTbl1 = nil -- 当前~块对应的子表（对应原tbl1）
            },
            isComplete = false,   -- 整体处理完成标记
        }
    end

    local function ReleaseDecompressState(state)
        state.isComplete = true
        if TJ._decompressState == state then
            TJ._decompressState = nil
        end
        state.source = nil
        state.target = nil
        state.eventList = nil
        state.currentEvent = nil
        state.currentText = nil
        state.currentTextTbl = nil
        state.strParseState = nil
    end

    -- 核心：分帧处理解压与解析的单步逻辑
    local function processDecompressFrame(state)
        -- 1. 检查是否已取消或处理完成
        if not state or state.isComplete or TJ._decompressState ~= state then
            return
        end

        local processedCount = 0 -- 本帧已处理的"块"数量（控制每帧工作量）

        -- 2. 初始化当前事件（如果还未初始化）
        if not state.currentEvent then
            -- 所有事件已处理完成
            if state.eventIdx > #state.eventList then
                -- 赋值最终结果
                TJ.combatLogEvent[state.eventTime] = {
                    FB = state.FB,
                    bossIndex = state.bossIndex,
                    time = state.eventTime,
                    titleColor = {},
                    event = state.target,
                    persisted = true,
                }
                TouchCombatLogCache(TJ.combatLogEvent[state.eventTime])
                TJ.TrimCombatLogCache()
                local FB, bossIndex = state.FB, state.bossIndex
                ReleaseDecompressState(state)
                -- 延迟回调只保留界面位置，不再引用整个解压状态。
                After(1, function()
                    local active = TJ._decompressState
                    if active and active.FB == FB and active.bossIndex == bossIndex then return end
                    if TJ["processText" .. FB .. bossIndex] then
                        TJ["processText" .. FB .. bossIndex]:Hide()
                    end
                end)
                TJ.UpdateTitleColor()
                return
            end

            -- 切换到下一个事件
            state.currentEvent = state.eventList[state.eventIdx]
            local eventTexts = state.source[state.currentEvent] or {}
            -- 初始化当前事件的结果表（对应原tbl1）
            state.target[state.currentEvent] = state.target[state.currentEvent] or {}
            state.currentTextTbl = state.target[state.currentEvent]
            state.textIdx = 1 -- 重置当前事件的文本索引
        end

        -- 3. 处理当前事件下的文本（每帧处理textPerEvent个文本）
        local eventTexts = state.source[state.currentEvent] or {}
        while state.textIdx <= #eventTexts and processedCount < DECOMPRESS_BATCH.textPerEvent do
            -- 初始化当前文本（如果还未初始化）
            if not state.currentText then
                state.currentText = eventTexts[state.textIdx]
                -- 文本是字符串：执行解压
                local decompressedText = C_EncodingUtil.DecompressString(state.currentText)
                -- 初始化第一层迭代器（~分割，对应原StringToTbl第一层迭代）
                local iter1, state1, start1 = string.gmatch(decompressedText, "([^~]+)()")
                local part1, pos1 = iter1(state1, start1)
                -- 保存迭代器状态到state
                state.strParseState = {
                    iter1 = iter1,
                    state1 = state1,
                    start1 = start1,
                    part1 = part1,
                    pos1 = pos1,
                    iter2 = nil,
                    state2 = nil,
                    start2 = nil,
                    part2 = nil,
                    pos2 = nil,
                    currentTbl1 = nil
                }
            end

            -- 4. 解析当前文本的字符串（分帧处理分隔块，对应原StringToTbl嵌套迭代）
            local strState = state.strParseState
            while strState.part1 and processedCount < DECOMPRESS_BATCH.blockPerText do
                -- 初始化当前~块的子表（对应原tbl1）
                if not strState.currentTbl1 then
                    strState.currentTbl1 = {}
                end

                -- 初始化第二层迭代器（!分割，对应原StringToTbl第二层迭代）
                if not strState.iter2 then
                    local iter2, state2, start2 = string.gmatch(strState.part1, "([^!]+)()")
                    local part2, pos2 = iter2(state2, start2)
                    strState.iter2 = iter2
                    strState.state2 = state2
                    strState.start2 = start2
                    strState.part2 = part2
                    strState.pos2 = pos2
                end

                -- 处理!分割的键值对块
                if strState.part2 then
                    -- 解析k^v键值对（对应原string.match逻辑）
                    local k, v = string.match(strState.part2, "([^^]+)%^(.*)")
                    if k and v then
                        -- 数字转换（保留原逻辑）
                        if tonumber(k) then k = tonumber(k) end
                        if tonumber(v) then v = tonumber(v) end
                        strState.currentTbl1[k] = v
                    end

                    -- 推进第二层迭代器
                    strState.part2, strState.pos2 = strState.iter2(strState.state2, strState.pos2)
                    processedCount = processedCount + 1
                else
                    -- 当前~块的!分割处理完成
                    if next(strState.currentTbl1) then -- 非空表才插入（保留原逻辑）
                        tinsert(state.currentTextTbl, strState.currentTbl1)
                    end
                    -- 重置第二层迭代器状态，推进第一层迭代器
                    strState.iter2 = nil
                    strState.part2 = nil
                    strState.currentTbl1 = nil
                    strState.part1, strState.pos1 = strState.iter1(strState.state1, strState.pos1)
                    processedCount = processedCount + 1
                end
            end

            -- 5. 检查当前文本是否解析完成
            if not strState.part1 then
                state.currentText = nil           -- 标记当前文本处理完成
                state.strParseState = nil
                state.textIdx = state.textIdx + 1 -- 切换到下一个文本
            end
        end

        -- 6. 检查当前事件是否处理完成
        if state.textIdx > #eventTexts then
            state.currentEvent = nil            -- 标记当前事件处理完成
            state.currentTextTbl = nil
            state.eventIdx = state.eventIdx + 1 -- 切换到下一个事件
        end

        -- 7. 计算并更新进度（可选，提升用户体验）
        local totalEvents = #state.eventList
        local processedEvents = state.eventIdx - 1
        -- 计算当前事件的处理进度（文本处理比例）
        if state.currentEvent then
            local totalTexts = #(state.source[state.currentEvent] or {})
            local processedTexts = state.textIdx - 1
            -- 计算当前文本的解析进度（块处理比例）
            local textProgress = 0
            if state.currentText and totalTexts > 0 then
                local strState = state.strParseState
                if strState.part1 then
                    textProgress = 0.5 -- 粗略估计：文本解析中
                else
                    textProgress = 1   -- 文本解析完成
                end
            end
            processedEvents = processedEvents + (processedTexts + textProgress) / math.max(totalTexts, 1)
        end
        local overallProgress = math.floor(min(processedEvents / math.max(totalEvents, 1), 1) * 100)
        -- 更新进度UI（对应原SetProcessText逻辑，若有）
        SetProcessText(state.FB, state.bossIndex, "解压数据中: ", overallProgress .. "%")
        -- 8. 安排下一帧继续处理
        After(0, function() processDecompressFrame(state) end)
    end

    -- 初始化
    function TJ.DeCompressCombatEvents(FB, bossIndex)
        -- 先终止实际正在进行的旧任务，避免提前返回时旧任务继续运行
        local oldState = TJ._decompressState
        if oldState then
            TJ.CancelDecompress(oldState.FB, oldState.bossIndex)
        end

        local combatLog = TJ.GetCombatLog()
        if not combatLog then
            TJ.TrimCombatLogCache()
            return
        end
        -- 如果已经解压过，则直接返回
        local eventTime = combatLog.time
        if TJ.combatLogEvent[eventTime] then
            TouchCombatLogCache(TJ.combatLogEvent[eventTime])
            TJ.TrimCombatLogCache()
            return
        end

        -- 创建新的分帧处理状态
        local newState = createDecompressState(FB, bossIndex, eventTime)
        TJ._decompressState = newState -- 保存状态到全局（用于后续终止）
        processDecompressFrame(newState)
    end

    -- 停止解压
    function TJ.CancelDecompress(FB, bossIndex)
        if TJ._decompressState and TJ._decompressState.FB == FB and TJ._decompressState.bossIndex == bossIndex then
            ReleaseDecompressState(TJ._decompressState)
            if TJ["processText" .. FB .. bossIndex] then
                TJ["processText" .. FB .. bossIndex]:Hide()
            end
        end
    end
end

function TJ.ClearBoss(FB, bossIndex)
    FB = FB or TuanJian.FB
    bossIndex = bossIndex or TuanJian.bossIndex
    TJ.LoadBoss(FB, bossIndex, true)
    TJ.ClearQuest(FB, bossIndex)
    TJ.ClearBoard(FB, bossIndex)
    TJ.ClearMap(FB, bossIndex)
end

-- 自动清空数据
local notCheckMaxPlayer = TJ.verOver4
local needCheck
TJ.RegisterEvent("RAID_INSTANCE_WELCOME", function(self, event, ...)
    if TuanJian.options["autoClear"] ~= 1 then return end
    needCheck = true
    RequestRaidInfo()
end)
TJ.RegisterEvent("UPDATE_INSTANCE_INFO", function()
    if needCheck then
        needCheck = nil
        After(3, function()
            local _, _, _, _, maxPlayers, _, _, instanceID = GetInstanceInfo()
            local FB
            for _, v in pairs(TJ.FBinfo) do
                if v.ID == instanceID then
                    FB = v.FB
                    break
                end
            end
            if not (FB and IsInInstance()) then return end

            -- 如果有CD则不清空
            for i = 1, GetNumSavedInstances() do
                local _, _, _, _, locked, _, _, _, _maxPlayers, _, _, _, _, _instanceID = GetSavedInstanceInfo(i)
                if locked and (instanceID == _instanceID)
                    and (notCheckMaxPlayer or maxPlayers == _maxPlayers)
                then
                    return
                end
            end

            -- 战斗数据数量大于1个时才清空
            local hasCount = 0
            local bossCount = {}
            for i, v in ipairs(TuanJian.combatLog) do
                if v.FB == FB and not bossCount[v.bossIndex] then
                    bossCount[v.bossIndex] = true
                    hasCount = hasCount + 1
                end
            end

            if #TJ.FBinfo[FB] > 1 or hasCount > 1 then
                TJ.ClearCombatLog(FB)
                for bossIndex in ipairs(TJ.FBinfo[FB]) do
                    TJ.ClearTitleColor(FB, bossIndex)
                end
                ns.SendSystemMessage(L["已清空本副本的历史战斗分析。"])
            end
        end)
    end
end)
