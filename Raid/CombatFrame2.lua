local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L
local AddTexture = ns.AddTexture
local Round = ns.Round
local GetGUID = TJ.GetGUID

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")

local width = 750
local height = 100
local leftWidth = 120
local rightWidth = -40
local topHeight = -45
local lwidth = width - leftWidth + rightWidth
local btHeight = 16
local offsetTime = 0.1
local offsetTime2 = 1

--[[
战士 #C69B6D 198, 155, 109
萨满 #2359FF 35, 89, 255
]]

-- 标记
local tex = [[Interface\TargetingFrame\UI-RaidTargetingIcons]]
local raidTargetIconTbl = {
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:0:25:0:25" .. "|t",
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:25:50:0:25" .. "|t",
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:55:75:0:25" .. "|t",
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:75:100:0:25" .. "|t",
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:0:25:25:50" .. "|t",
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:25:50:25:50" .. "|t",
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:50:75:25:50" .. "|t",
    "|T" .. tex .. ":0:0:0:0" .. ":100:100:75:100:25:50" .. "|t",
}
function TJ.GetRTIcon(id)
    if id then
        return raidTargetIconTbl[id] or ""
    else
        return ""
    end
end

-- 过滤
function TJ.CombatFiterEvent(type, subevent, info, ...)
    if subevent:match("DURABILITY") then return end
    if type == "damage" then
        local yes
        if subevent:match("SPELL_PERIODIC_DAMAGE") then
            if info and info.notPeriodicDamage then
                return false
            end
        end
        if subevent:match("_MISSED$") then
            if info and info.notMiss then
                return false
            end
            yes = true
        end
        if subevent:match("^SWING_") then
            if info and info.attack then
                return true
            else
                return false
            end
        end
        if subevent:match("_DAMAGE$") then
            return true
        end
        return yes
    elseif type == "health" then
        if subevent:match("_MISSED$") then
            return true
        end
        if subevent:match("_DAMAGE$") or subevent == "DAMAGE_SPLIT" then
            return true
        end
        if subevent:match("_HEAL$") then
            return true
        end
        -- if subevent:match("_HEAL_ABSORBED$") then
        --     return true
        -- end
    elseif type == "health_onlyHeal" then
        if subevent:match("_HEAL$") then
            return true
        end
    elseif type == "dps" or type == "dps_friend" then
        if subevent:match("_MISSED$") then
            return true
        end
        if subevent:match("_DAMAGE$") then
            return true
        end
    elseif type == "hps" then
        if subevent:match("_HEAL$") then
            return true
        end
        if subevent:match("_HEAL_ABSORBED$") then
            return true
        end
    elseif type == "parry" then
        if subevent:match("_MISSED$") then
            return true
        end
    end
end

function TJ.CombatInfoFilter(info, v, infoType)
    local combatLog = TJ.GetCombatLog()
    if not v[1] or v[1] > combatLog.duration then return end
    local sourceGUID = GetGUID(v[4])
    local destGUID = GetGUID(v[8])
    if infoType == "damageFriend" then
        if sourceGUID == destGUID then return end
        local sourceNpcType = strsplit("-", sourceGUID)
        if sourceNpcType ~= "Player" then return end
        local destNpcType = strsplit("-", destGUID)
        if destNpcType ~= "Player" then return end
    elseif infoType == "dps_friend" then
        if sourceGUID == destGUID then return end
        local sourceNpcType = strsplit("-", sourceGUID)
        if not (sourceNpcType == "Player" or sourceNpcType == "Pet") then return end
        local destNpcType = strsplit("-", destGUID)
        if destNpcType ~= "Player" then return end
    end
    local _info = info[infoType]
    if _info.onlyShowMe then
        local yes
        for i, spellID in ipairs(_info.onlyShowMe) do
            if spellID == v[12] then
                yes = true
                break
            end
        end
        if yes and GetGUID(v[8]) ~= GetGUID(v[4]) then
            return
        end
    end
    if _info.destNPCID and destGUID then
        local yes
        local npcType, _, _, _, _, npcID = strsplit("-", destGUID)
        if npcType == "Creature" or npcType == "Vehicle" then
            npcID = tonumber(npcID)
            for _, NPCID in pairs(_info.destNPCID) do
                if npcID == NPCID then
                    yes = true
                    break
                end
            end
        end
        if not yes then return end
    end
    if _info.sourceNPCID and sourceGUID then
        local yes
        local npcType, _, _, _, _, npcID = strsplit("-", sourceGUID)
        if npcType == "Creature" or npcType == "Vehicle" then
            npcID = tonumber(npcID)
            for _, NPCID in pairs(_info.sourceNPCID) do
                if npcID == NPCID then
                    yes = true
                    break
                end
            end
        end
        if not yes then return end
    end
    if _info.destNpcType and destGUID then
        local yes
        local npcType = strsplit("-", destGUID)
        for _, NPCType in ipairs(_info.destNpcType) do
            if npcType == NPCType then
                yes = true
                break
            end
        end
        if not yes then return end
    end
    if _info.sourceNpcType and sourceGUID then
        local yes
        local npcType = strsplit("-", sourceGUID)
        for _, NPCType in ipairs(_info.sourceNpcType) do
            if npcType == NPCType then
                yes = true
                break
            end
        end
        if not yes then return end
    end
    if _info.banSpell then
        if type(v[12]) == "number" and TJ.ValueInTable(_info.banSpell, v[12]) then
            return
        end
    end
    if _info.startTime and _info.endTime then
        local function ChangeTime(t)
            if type(t) == "string" then -- 具体哪个阶段
                if t == "duration" then
                    return combatLog.duration
                else
                    for k, v in pairs(combatLog.otherTime) do
                        if v.name == t then
                            return v.time
                        end
                    end
                end
            elseif type(t) == "number" then
                return t
            end
        end
        local s = ChangeTime(_info.startTime) or ChangeTime(_info.startTime2)
        local e = ChangeTime(_info.endTime) or ChangeTime(_info.endTime2)
        if (s and e and not (v[1] >= s and v[1] <= e)) or not (s and e) then
            return
        end
    end
    if _info.phase or (_info.showDropDown and TJ.combatFrameDropDownPahse) then
        local phase = _info.phase or TJ.combatFrameDropDownPahse
        if type(phase) == "table" then
            for k, vv in pairs(combatLog.otherTime) do
                if vv.startTime then -- 含有phase标记
                    for _, phaseName in pairs(phase) do
                        if vv.name == phaseName then
                            local s, e = vv.startTime, vv.endTime
                            if s and e and (v[1] >= s and v[1] <= e) then
                                return true
                            end
                        end
                    end
                end
            end
        else
            if combatLog.otherTime[phase] then
                local phase = combatLog.otherTime[phase]
                local s, e = phase.startTime, phase.endTime
                if s and e and (v[1] >= s and v[1] <= e) then
                    return true
                end
            else
                for k, vv in pairs(combatLog.otherTime) do
                    if vv.startTime then -- 含有phase标记
                        if vv.name == phase then
                            local s, e = vv.startTime, vv.endTime
                            if s and e and (v[1] >= s and v[1] <= e) then
                                return true
                            end
                        end
                    end
                end
            end
        end
        return false
    end
    return true
end

function TJ.CombatInfoFilter_combatRole(name, combatRoleTbl, combat)
    if not combatRoleTbl then return true end
    if TJ.cacheCombatRole[name] then
        for _, _combatRole in ipairs(combatRoleTbl) do
            if TJ.cacheCombatRole[name] == _combatRole then
                return true
            end
        end
    else
        for _, _combatRole in ipairs(combatRoleTbl) do
            for i, v in ipairs(combat.raidMember) do
                if v.name == name and v.role ~= "MAINASSIST"
                    and TJ[_combatRole] and TJ[_combatRole](v) then
                    TJ.cacheCombatRole[v.name] = _combatRole
                    return true
                end
            end
        end
    end
end

-- 鼠标提示工具
local function _GetHealth(self, tbl, v, subevent, isSpell, isEnvironmental)
    local num = isEnvironmental and 13 or (isSpell and 15 or 12)
    local _sourceGUID = GetGUID(v[4])
    local __tbl = {
        time = format("%.1f", Round(self.v.endTime - v[1], 1)),
        endTime = v[1],
        hp = v.hp,
        maxhp = v.maxhp,
        sourceGUID = _sourceGUID and _sourceGUID ~= "" and _sourceGUID or "UNKNOWN",
        spellID = v[num - 3],
        spellName = v[num - 2],
        i = v.i,
    }
    if subevent:match("_DAMAGE$") or subevent == "DAMAGE_SPLIT" then
        __tbl.type = "damage"
        __tbl.amount = v[num]
        __tbl.over = v[num + 1] == -1 and 0 or v[num + 1] -- 未过量时为-1
        __tbl.school = v[num + 2]                         -- 伤害类型
        __tbl.resisted = v[num + 3]                       -- 被抵抗的伤害值（目标通过抗性减少的伤害）
        __tbl.blocked = v[num + 4]                        -- 被格挡的伤害值（仅对物理攻击有效，若法术可格挡则为0）
        __tbl.absorbed = v[num + 5]                       -- 被吸收的伤害值（护盾或增益吸收的伤害）
        __tbl.critical = v[num + 6]                       -- 暴击
        __tbl.glancing = v[num + 7]                       -- 是否偏斜（仅物理攻击有效，true=偏斜，法术攻击恒为 false）
        __tbl.crushing = v[num + 8]                       -- 是否碾压（仅物理攻击有效，true=碾压，法术攻击恒为 false）
        __tbl.environmentalType = isEnvironmental and v[12] or nil
    elseif subevent:match("_HEAL$") then
        __tbl.type = "heal"
        __tbl.spellID = v[num - 3]
        __tbl.spellName = v[num - 2]
        __tbl.school = v[num - 1]
        __tbl.amount = v[num]
        __tbl.over = v[num + 1]     -- 过量治疗（目标血量溢出部分的无效治疗值，例如目标满血时全部为过量治疗）
        __tbl.absorbed = v[num + 2] -- 被吸收的治疗量（如目标有吸收盾时，治疗量被护盾吸收的部分）
        __tbl.critical = v[num + 3] -- 暴击
    elseif subevent:match("_MISSED$") then
        if v[num] == "ABSORB" then
            __tbl.type = "absorbed"
            __tbl.amount = v[num + 2]
        else
            __tbl.type = "missed"
            __tbl.missType = v[num]
        end
    end
    tinsert(tbl, __tbl)
end
local function GetHealth(self, health_onlyHeal, durTime, destTarget)
    local event = TJ.GetCombatLogEvent()
    local tbl = {}
    local f_event = health_onlyHeal and "health_onlyHeal" or "health"
    local startTime = durTime or 7
    for subevent in pairs(event) do
        if TJ.CombatFiterEvent(f_event, subevent) then
            for i, v in ipairs(event[subevent]) do
                if v[1] <= self.v.endTime and self.v.endTime - v[1] <= startTime
                    and GetGUID(v[8]) == (destTarget and self.v.destGUID or self.playerTextGUID) then
                    if subevent:match("^ENVIRONMENTAL_") then
                        _GetHealth(self, tbl, v, subevent, false,true)
                    elseif subevent:match("^SWING_") then
                        _GetHealth(self, tbl, v, subevent, false)
                    else
                        _GetHealth(self, tbl, v, subevent, true)
                    end
                end
            end
        end
    end
    for i = #tbl, 1, -1 do
        local v = tbl[i]
        if v.type == "heal" and v.amount < 100 then
            tremove(tbl, i)
        end
    end
    sort(tbl, function(a, b)
        if a.i and b.i then
            return a.i < b.i
        end
    end)
    local maxLine = 25
    if #tbl > maxLine then
        for i = 1, #tbl - maxLine do
            tremove(tbl, 1)
        end
    end
    return tbl
end

local function _GetHeal(self, tbl, v)
    if v[1] >= self.v.startTime and v[1] <= self.v.endTime
        and GetGUID(v[4]) == self.v.sourceGUID and v[12] == self.v.spellID and v.hp
    then
        local _destGUID = GetGUID(v[8])
        local __tbl = {
            hp = v.hp,
            maxhp = v.maxhp,
            destGUID = _destGUID and _destGUID ~= "" and _destGUID or "UNKNOWN",
            amount = v[15]
        }
        tinsert(tbl, __tbl)
    end
end
local function GetHeal(self)
    local FB = TuanJian.FB
    local bossIndex = TuanJian.bossIndex
    local event = TJ.GetCombatLogEvent()
    local tbl = {}
    for subevent in pairs(event) do
        if subevent:match("SPELL_PERIODIC_HEAL$") then
            for i, v in ipairs(event[subevent]) do
                _GetHeal(self, tbl, v, subevent)
            end
        end
    end
    return tbl
end

local function _GetDamage(self, tbl, v, subevent, isSpell, isEnvironmental)
    local num = isEnvironmental and 13 or (isSpell and 15 or 12)
    local __tbl = {
        time = v[1],
        hp = v.hp,
        maxhp = v.maxhp,
        sourceGUID = GetGUID(v[4]),
        destGUID = GetGUID(v[8]),
        amount = v[num],
        spellID = isSpell and v[12],
        spellName = isSpell and v[13],
        i = v.i,
    }
    if subevent:match("_DAMAGE$") then
        __tbl.type = "damage"
        __tbl.amount = v[num]
        __tbl.over = v[num + 1] == -1 and 0 or v[num + 1] -- 未过量时为-1
        __tbl.resisted = v[num + 3]                       -- 被抵抗的伤害值（目标通过抗性减少的伤害）
        __tbl.blocked = v[num + 4]                        -- 被格挡的伤害值（仅对物理攻击有效，若法术可格挡则为0）
        __tbl.absorbed = v[num + 5]                       -- 被吸收的伤害值（护盾或增益吸收的伤害）
        __tbl.critical = v[num + 6]                       -- 暴击
        __tbl.environmentalType = isEnvironmental and v[12] or nil
    elseif subevent:match("_MISSED$") then
        if v[num] == "ABSORB" then
            __tbl.type = "absorbed"
            __tbl.amount = v[num + 2]
        else
            __tbl.type = "missed"
            __tbl.missType = v[num]
        end
    end
    tinsert(tbl, __tbl)
end
local function GetDamage(self)
    local event = TJ.GetCombatLogEvent()
    local tooltip = self.tooltip
    local tbl = {}
    -- local testTime = debugprofilestop()
    -- local count = 0
    for subevent in pairs(event) do
        if TJ.CombatFiterEvent("damage", subevent, self.v.info) then
            for i, v in ipairs(event[subevent]) do
                -- count = count + 1
                local yes
                if tooltip == "beDamage" or tooltip:match("damageHarm") then
                    if v[1] == self.v.endTime then
                        local sourceGUID = GetGUID(v[4])
                        local destGUID = GetGUID(v[8])
                        if sourceGUID == self.v.sourceGUID and destGUID == self.v.destGUID then
                            yes = true
                        end
                    end
                elseif tooltip:match("beDamage2") then
                    if math.abs(v[1] - self.v.endTime) <= offsetTime then
                        local sourceGUID = GetGUID(v[4])
                        local destGUID = GetGUID(v[8])
                        if sourceGUID == self.v.sourceGUID then
                            local destNpcType = strsplit("-", destGUID)
                            if destNpcType == "Player" then
                                yes = true
                            end
                        end
                    end
                elseif tooltip:match("damageFriend") then
                    if math.abs(v[1] - self.v.endTime) <= offsetTime2 and v.hp then
                        local sourceGUID = GetGUID(v[4])
                        local destGUID = GetGUID(v[8])
                        if sourceGUID == self.v.sourceGUID and sourceGUID ~= destGUID then
                            local sourceNpcType = strsplit("-", sourceGUID)
                            if sourceNpcType == "Player" then
                                local destNpcType = strsplit("-", destGUID)
                                if destNpcType == "Player" then
                                    yes = true
                                end
                            end
                        end
                    end
                end
                if yes then
                    if subevent:match("^ENVIRONMENTAL_") then
                        _GetDamage(self, tbl, v, subevent, false, true)
                    elseif subevent:match("^SWING_") then
                        _GetDamage(self, tbl, v, subevent, false)
                    else
                        if not self.v.spellID or self.v.spellID and v[12] == self.v.spellID then
                            _GetDamage(self, tbl, v, subevent, true)
                        end
                    end
                end
            end
        end
    end
    -- pt(count, (debugprofilestop() - testTime) / 1000)
    if tooltip:match("beDamage2") or tooltip:match("damageFriend") then
        -- 同一个玩家的多个战斗日志合并为一个，比如一条日志为吸收伤害，一条日志为受到伤害
        local players = {}
        for i, v in ipairs(tbl) do
            if not players[v.destGUID] then
                players[v.destGUID] = {}
            end
            tinsert(players[v.destGUID], v)
        end
        local newTbl = {}
        for destGUID in pairs(players) do
            local time
            local hp = nil
            local maxhp = 0
            local amount = 0
            local over = 0
            local resisted = 0
            local blocked = 0
            local absorbed = 0
            local critical = nil
            local spellID
            local spellName

            for _, v in ipairs(players[destGUID]) do
                if not hp then
                    hp = v.hp
                end
                if hp and v.hp then
                    hp = min(hp, v.hp)
                end
                maxhp = v.maxhp
                time = v.time
                spellID = v.spellID
                spellName = v.spellName
                if v.type == "damage" then
                    amount = amount + v.amount
                end
                if v.over then
                    over = over + v.over
                end
                if v.resisted then
                    resisted = resisted + v.resisted
                end
                if v.blocked then
                    blocked = blocked + v.blocked
                end
                if v.type == "absorbed" then
                    absorbed = absorbed + v.amount
                end
                if v.absorbed then
                    absorbed = absorbed + v.absorbed
                end
                if v.type == "damage" and v.critical then
                    critical = v.critical
                end
            end
            local type = amount > 0 and "damage" or "absorbed"
            tinsert(newTbl, {
                type = type,
                time = time,
                hp = hp,
                maxhp = maxhp,
                destGUID = destGUID,
                amount = type == "damage" and amount or absorbed,
                over = over,
                resisted = resisted ~= 0 and resisted,
                blocked = blocked ~= 0 and blocked,
                absorbed = absorbed ~= 0 and absorbed,
                critical = critical,
                spellID = spellID,
                spellName = spellName,
            })
            sort(newTbl, function(a, b)
                local a_maxhp = a.maxhp or 0
                local b_maxhp = b.maxhp or 0
                return a_maxhp > b_maxhp
            end)
        end
        return newTbl
    end
    return tbl
end

function TJ.GetHLKwuran(self)
    local event = TJ.GetCombatLogEvent()
    if event.SPELL_AURA_APPLIED then
        for i, v in ipairs(event.SPELL_AURA_APPLIED) do
            local startTime = self.v.endTime - 2
            local destGUID = GetGUID(v[8])
            if v[1] >= startTime and v[1] - startTime <= 3
                and destGUID == self.v.destGUID and v[12] == 54861 then
                return Round((v[1] - startTime), 2) .. "s"
            end
        end
    end
end

function TJ.CombatFrameAddText(self)
    local guidTbl = self.guidTbl
    local function GetGUIDInfo(GUID)
        local name = ""
        local r, g, b = 1, .82, 0
        if guidTbl[GUID] then
            name = guidTbl[GUID].name
            if guidTbl[GUID].class then
                r, g, b = GetClassColor(guidTbl[GUID].class)
            end
        end
        return name, r, g, b
    end
    local destName, dr, dg, db = GetGUIDInfo(self.v.destGUID)
    local sourceName, sr, sg, sb = GetGUIDInfo(self.v.sourceGUID)
    local destRT = TJ.GetRTIcon(self.v.destRT)
    local sourceRT = TJ.GetRTIcon(self.v.sourceRT)
    if self.tooltip:match("trigger") then
        local text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
        local stackCountText=''
        if self.v.stackCount then
            -- stackCountText = L['|cffFFD100（%s点法强）|r']:format(self.v.stackCount)
            stackCountText = L['|cffFFD100%s点|r']:format(self.v.stackCount)
        end
        GameTooltip:AddLine(self.tooltipText .. text, 1, 1, 1)
        GameTooltip:AddLine(sourceRT .. TJ.GetIconFormName(sourceName) .. stackCountText, sr, sg, sb)
    end
    if self.tooltip:match("aura") then
        local spellName = self.v.spellName
        local icon = self.v.icon
        local countText = ""
        if self.v.stackCount then
            countText = format("(%s)", self.v.stackCount)
        end
        local text = ""
        if self.v.startTime and self.v.endTime then
            text = format("|cff808080（%s - %s）|r", TJ.SecondsToTime(self.v.startTime),
                TJ.SecondsToTime(self.v.endTime))
        end
        GameTooltip:AddLine(L["光环"] .. text, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["光环"], AddTexture(icon) .. spellName .. countText)
        GameTooltip:AddDoubleLine(L["施法者"], sourceRT .. TJ.GetIconFormName(sourceName), 1, .82, 0, sr, sg, sb)
        GameTooltip:AddDoubleLine(L["施法目标"], destRT .. TJ.GetIconFormName(destName), 1, .82, 0, dr, dg, db)
        GameTooltip:AddDoubleLine(L["持续时间"], TJ.SecondsToTime(Round(self.v.endTime, 1) - Round(self.v.startTime, 1)),
            1, .82, 0, 1, .82, 0)
    end
    if self.tooltip:match("dispel") then
        local text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
        GameTooltip:AddLine(L["驱散"] .. text, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["驱散者"], sourceRT .. TJ.GetIconFormName(sourceName), 1, .82, 0, sr, sg, sb)
        GameTooltip:AddDoubleLine(L["驱散法术"], AddTexture(self.v.icon2) .. self.v.spellName2)
        GameTooltip:AddDoubleLine(L["被驱散者"], destRT .. TJ.GetIconFormName(destName), 1, .82, 0, dr, dg, db)
        GameTooltip:AddDoubleLine(L["被驱散法术"], AddTexture(self.v.icon) .. self.v.spellName, 1, .82, 0, 1, 1, 1)
    end
    if self.tooltip:match("interrupt") then
        local text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
        GameTooltip:AddLine(L["打断"] .. text, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["打断者"], sourceRT .. TJ.GetIconFormName(sourceName), 1, .82, 0, sr, sg, sb)
        GameTooltip:AddDoubleLine(L["打断法术"], AddTexture(self.v.icon2) .. self.v.spellName2)
        GameTooltip:AddDoubleLine(L["被打断者"], destRT .. TJ.GetIconFormName(destName), 1, .82, 0, dr, dg, db)
        GameTooltip:AddDoubleLine(L["被打断法术"], AddTexture(self.v.icon) .. self.v.spellName, 1, .82, 0, 1, 1, 1)
    end
    if self.tooltip:match("broken") then
        local text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
        GameTooltip:AddLine(L["破控"] .. text, 1, 1, 1)
        GameTooltip:AddDoubleLine(L["破控者"], sourceRT .. TJ.GetIconFormName(sourceName), 1, .82, 0, sr, sg, sb)
        GameTooltip:AddDoubleLine(L["破控法术"], AddTexture(self.v.icon2) .. self.v.spellName2)
        GameTooltip:AddDoubleLine(L["被破控者"], destRT .. TJ.GetIconFormName(destName), 1, .82, 0, dr, dg, db)
        GameTooltip:AddDoubleLine(L["被破控法术"], AddTexture(self.v.icon) .. self.v.spellName, 1, .82, 0, 1, 1, 1)
    end
    if self.tooltip:match("health") then
        local durTime
        if self.tooltip:match("aura") then
            durTime = self.v.endTime - self.v.startTime
        elseif self.v.DestTarget then
            durTime = 1
        end
        local tbl = GetHealth(self, self.tooltip:match("health_onlyHeal"), durTime, self.v.DestTarget)
        local lines = GameTooltip:NumLines()
        if lines ~= 0 and _G["GameTooltipTextLeft" .. lines]:GetText() ~= " " then
            GameTooltip:AddLine(" ")
        end
        local text = ""
        if self.v and self.v.startTime and self.v.endTime then
            if self.v.hideStartTime then
                text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
            else
                text = format("|cff808080（%s - %s）|r", TJ.SecondsToTime(self.v.startTime),
                    TJ.SecondsToTime(self.v.endTime))
            end
        end
        GameTooltip:AddDoubleLine(L["事件"] .. text, not next(tbl) and "" or tbl[1].hp and L["剩余血量"] or L["造成伤害"], 1, .82,
            0, 1, .82, 0)
        if next(tbl) then
            for i, v in ipairs(tbl) do
                local left
                local right = v.hp and format(L["（%s%%）"], Round(v.hp / v.maxhp, 2) * 100) or ""
                local barColor = { 1, 1, 1 }
                local time = format("-%ss", v.time)
                local sourceName = guidTbl[v.sourceGUID].name
                if guidTbl[v.sourceGUID].class then
                    sourceName = "|c" .. select(4, GetClassColor(guidTbl[v.sourceGUID].class)) .. sourceName .. "|r"
                end
                sourceName = format(L["（%s）"], sourceName)
                local iconText
                if v.spellID then
                    local icon = C_Spell.GetSpellTexture(v.spellID)
                    iconText = AddTexture(icon)
                elseif v.environmentalType then
                    iconText = AddTexture("Interface\\Icons\\spell_magic_featherfall")
                else
                    iconText = AddTexture("Interface\\Icons\\ability_steelmelee")
                end
                local spellText = ""
                if v.spellID then
                    spellText = " " .. v.spellName
                elseif v.environmentalType then
                    spellText = " " .. v.environmentalType
                    sourceName = L["（环境伤害）"]
                else
                    spellText = " " .. L["平砍"]
                end
                if v.type == "damage" then
                    local value = TJ.FormatNumber(v.amount)
                    local overText = ""
                    if v.over and v.over > 0 then
                        overText = format(TEXT_MODE_A_STRING_RESULT_OVERKILLING, TJ.FormatNumber(v.over))
                    end
                    local resistedText = ""
                    if v.resisted then -- 抵抗
                        resistedText = format(TEXT_MODE_A_STRING_RESULT_RESIST, TJ.FormatNumber(v.resisted))
                    end
                    local blockedText = ""
                    if v.blocked then -- 格挡
                        blockedText = format(TEXT_MODE_A_STRING_RESULT_BLOCK, TJ.FormatNumber(v.blocked))
                    end
                    local absorbedText = ""
                    if v.absorbed then -- 吸收
                        absorbedText = format(TEXT_MODE_A_STRING_RESULT_ABSORB, TJ.FormatNumber(v.absorbed))
                    end
                    local criticalText = ""
                    if v.critical then
                        criticalText = format("|cffff0000%s|r", TEXT_MODE_A_STRING_RESULT_CRITICAL_SPELL)
                    end
                    local glancingText = ""
                    if v.glancing then
                        glancingText = TEXT_MODE_A_STRING_RESULT_GLANCING
                    end
                    local crushingText = ""
                    if v.crushing then
                        crushingText = TEXT_MODE_A_STRING_RESULT_CRUSHING
                    end
                    left = format("%s%s%s%s", iconText, time, spellText, sourceName)
                    right = format("|cffff0000-%s%s|r%s%s%s%s%s%s", value, overText,
                        resistedText, blockedText, absorbedText,
                        criticalText, glancingText, crushingText) .. right
                    barColor = { 1, 0, 0 }
                    GameTooltip:AddDoubleLine(left, right, 1, .82, 0, 1, .82, 0)
                elseif v.type == "heal" then
                    local value = TJ.FormatNumber(v.amount)
                    local absorbedText = ""
                    if v.absorbed > 0 then
                        absorbedText = format(TEXT_MODE_A_STRING_RESULT_ABSORB, TJ.FormatNumber(v.absorbed))
                    end
                    left = format("%s%s%s%s", iconText, time, spellText, sourceName)
                    right = format("|cff00ff00+%s|r%s", value, absorbedText) .. right
                    barColor = { 0, 1, 0 }
                    GameTooltip:AddDoubleLine(left, right, 1, .82, 0, 1, .82, 0)
                elseif v.type == "absorbed" then
                    local value = format(TEXT_MODE_A_STRING_RESULT_ABSORB, TJ.FormatNumber(v.amount))
                    left = format("%s%s %s%s", iconText, time, spellText, sourceName)
                    right = format("|cffffffff0|r%s", value) .. right
                    barColor = { 1, 1, 1 }
                    GameTooltip:AddDoubleLine(left, right, 1, .82, 0, 1, .82, 0)
                elseif v.type == "missed" then
                    local value = format(L["（%s）"], _G[v.missType])
                    left = format("%s%s%s%s", iconText, time, spellText, sourceName)
                    right = format("|cffffffff0|r%s", value) .. right
                    barColor = { 1, 1, 1 }
                    GameTooltip:AddDoubleLine(left, right, 1, .82, 0, 1, .82, 0)
                end

                if v.hp then
                    local r, g, b = unpack(barColor)
                    local num = GameTooltip:NumLines()
                    local bar = CreateFrame("StatusBar", nil, GameTooltip)
                    bar:SetPoint("TOPLEFT", _G["GameTooltipTextLeft" .. num], "TOPLEFT", 0, 0)
                    bar:SetPoint("BOTTOMRIGHT", _G["GameTooltipTextRight" .. num], "BOTTOMRIGHT", 0, 0)
                    bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
                    bar:SetStatusBarColor(r, g, b, .25)
                    bar:SetFrameLevel(GameTooltip:GetFrameLevel())
                    bar:SetMinMaxValues(0, 10000)
                    bar:SetValue((v.hp / v.maxhp * 10000))
                    bar:SetScript("OnHide", function(self)
                        self:Hide()
                        self:SetParent(nil)
                    end)
                end
            end
        else
            GameTooltip:AddLine(L["此期间没有受到伤害或治疗"], .5, .5, .5)
        end
    end
    if self.tooltip:match("Heal") then
        local tbl = GetHeal(self)
        if next(tbl) then
            local text = ""
            if self.v and self.v.startTime and self.v.endTime then
                text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime - 1))
            end
            GameTooltip:AddDoubleLine(L["玩家"] .. text, L["剩余血量"], 1, .82, 0, 1, .82, 0)
            for i, v in ipairs(tbl) do
                local destName = guidTbl[v.destGUID].name
                if guidTbl[v.destGUID].class then
                    destName = "|c" .. select(4, GetClassColor(guidTbl[v.destGUID].class)) .. destName .. "|r"
                end
                local right = format(L["（%s%%）"], Round(v.hp / v.maxhp, 2) * 100)
                right = format("|cff00ff00+%s|r", TJ.FormatNumber(v.amount)) .. right
                GameTooltip:AddDoubleLine(destName, right, 1, .82, 0, 1, .82, 0)
            end
        end
    end
    if self.tooltip:match("castAll") then
        local event = TJ.GetCombatLogEvent()
        local tbl = {}
        if event.SPELL_CAST_SUCCESS then
            local fiter_destNPCID = tonumber(self.tooltip:match("castAll:destNPCID|(%d+)"))
            for i, v in ipairs(event.SPELL_CAST_SUCCESS) do
                if v[1] >= self.v.startTime and v[1] <= self.v.endTime and GetGUID(v[4]) == self.v.destGUID
                    and (not fiter_destNPCID or TJ.GetNPCID(GetGUID(v[8])) == fiter_destNPCID) then
                    local __tbl = {
                        time = v[1],
                        destName = guidTbl[GetGUID(v[8])].name,
                        spellID = v[12],
                        spellName = v[13],
                        amount = v[15],
                    }
                    tinsert(tbl, __tbl)
                end
            end
        end
        if next(tbl) then
            local lines = GameTooltip:NumLines()
            if lines ~= 0 and _G["GameTooltipTextLeft" .. lines]:GetText() ~= " " then
                GameTooltip:AddLine(" ")
            end
            local castName = ns.RGB_16(destRT .. TJ.GetIconFormName(destName), dr, dg, db)
            GameTooltip:AddDoubleLine(format(L["施法者（%s）"], castName), L["施法目标"], 1, 1, 1, 1, 1, 1)
            for i, v in ipairs(tbl) do
                local iconText = ""
                if v.spellID then
                    local icon = C_Spell.GetSpellTexture(v.spellID)
                    iconText = AddTexture(icon)
                else
                    iconText = AddTexture("Interface\\Icons\\ability_steelmelee")
                end
                local left = format("%s%s %s", iconText, TJ.SecondsToTime(v.time), v.spellName)
                GameTooltip:AddDoubleLine(left, v.destName, 1, .82, 0, 1, .82, 0)
            end
        end
    end
    if self.tooltip == "beDamage" or self.tooltip:match("beDamage2") or self.tooltip:match("damageFriend")
        or self.tooltip:match("damageHarm") then
        local tbl = GetDamage(self)
        if next(tbl) then
            local lines = GameTooltip:NumLines()
            if lines ~= 0 and _G["GameTooltipTextLeft" .. lines]:GetText() ~= " " then
                GameTooltip:AddLine(" ")
            end
            local text = ""
            if self.v and self.v.endTime then
                text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
            end
            if self.tooltip == "beDamage" then
                GameTooltip:AddDoubleLine(L["受到伤害"] .. text,
                    tbl[1].hp and L["剩余血量"] or L["造成伤害"], 1, 0, 0, 1, .82, 0)
            else
                local title
                if self.tooltip:match("damageFriend") then
                    title = format(L["误伤队友%s人"], #tbl)
                elseif self.tooltip == "damageHarm" then
                    title = format(L["造成伤害"], #tbl)
                else
                    title = format(L["造成伤害%s人"], #tbl)
                end
                GameTooltip:AddDoubleLine(title .. text, L["剩余血量"], 1, 0, 0, 1, .82, 0)
            end

            for i, v in ipairs(tbl) do
                local GUID
                if self.tooltip == "beDamage" or self.tooltip == "damageHarm" then
                    GUID = v.sourceGUID
                elseif self.tooltip:match("beDamage2") or self.tooltip:match("damageFriend") then
                    GUID = v.destGUID
                end
                local name = guidTbl[GUID].name
                if guidTbl[GUID].class then
                    name = "|c" .. select(4, GetClassColor(guidTbl[GUID].class)) .. name .. "|r"
                end
                local spellText = ""
                if v.spellID then
                    local icon = C_Spell.GetSpellTexture(v.spellID)
                    spellText = AddTexture(icon) .. v.spellName
                elseif v.environmentalType then
                    spellText = v.environmentalType
                    name = L["环境伤害"]
                else
                    spellText = AddTexture("Interface\\Icons\\ability_steelmelee") .. L[" 平砍"]
                end
                local left = format("%s（%s）", spellText, name)
                local right = v.hp and format(L["（%s%%）"], Round(v.hp / v.maxhp, 2) * 100) or ""
                if v.type == "damage" then
                    local value = TJ.FormatNumber(v.amount)
                    local overText = ""
                    if v.over > 0 then
                        overText = format(TEXT_MODE_A_STRING_RESULT_OVERKILLING, TJ.FormatNumber(v.over))
                    end
                    local resistedText = ""
                    if v.resisted then -- 抵抗
                        resistedText = format(TEXT_MODE_A_STRING_RESULT_RESIST, TJ.FormatNumber(v.resisted))
                    end
                    local blockedText = ""
                    if v.blocked then -- 格挡
                        blockedText = format(TEXT_MODE_A_STRING_RESULT_BLOCK, TJ.FormatNumber(v.blocked))
                    end
                    local absorbedText = ""
                    if v.absorbed then -- 吸收
                        absorbedText = format(TEXT_MODE_A_STRING_RESULT_ABSORB, TJ.FormatNumber(v.absorbed))
                    end
                    local criticalText = ""
                    if v.critical then
                        criticalText = format("|cffff0000%s|r", TEXT_MODE_A_STRING_RESULT_CRITICAL_SPELL)
                    end
                    right = format("|cffff0000-%s%s|r%s%s%s%s", value, overText,
                        resistedText, blockedText, absorbedText, criticalText) .. right
                elseif v.type == "absorbed" then
                    local value = format(TEXT_MODE_A_STRING_RESULT_ABSORB, TJ.FormatNumber(v.amount))
                    right = format("|cffffffff0|r%s", value) .. right
                elseif v.type == "missed" then
                    local value = format(L["（%s）"], _G[v.missType])
                    right = format("|cffffffff0|r%s", value) .. right
                end
                GameTooltip:AddDoubleLine(left, right, 1, .82, 0, 1, .82, 0)

                if v.hp and v.maxhp and v.maxhp ~= 0 then
                    local r, g, b = 1, 0, 0
                    local num = GameTooltip:NumLines()
                    local bar = CreateFrame("StatusBar", nil, GameTooltip)
                    bar:SetPoint("TOPLEFT", _G["GameTooltipTextLeft" .. num], "TOPLEFT", 0, 0)
                    bar:SetPoint("BOTTOMRIGHT", _G["GameTooltipTextRight" .. num], "BOTTOMRIGHT", 0, 0)
                    bar:SetStatusBarTexture("Interface/ChatFrame/ChatFrameBackground")
                    bar:SetStatusBarColor(r, g, b, .25)
                    bar:SetFrameLevel(GameTooltip:GetFrameLevel())
                    bar:SetMinMaxValues(0, 10000)
                    bar:SetValue(v.hp / v.maxhp * 10000)
                    bar:SetScript("OnHide", function(self)
                        self:Hide()
                        self:SetParent(nil)
                    end)
                end
            end
        end
    end
    if self.tooltip:match("castSuccess") then
        local spellID = tonumber(self.tooltip:match("castSuccess:(%d+)"))
        if spellID then
            local FB = TuanJian.FB
            local bossIndex = TuanJian.bossIndex
            local event = TJ.GetCombatLogEvent()
            local tbl = {}
            if event.SPELL_CAST_SUCCESS then
                for i, v in ipairs(event.SPELL_CAST_SUCCESS) do
                    if GetGUID(v[8]) == self.v.destGUID
                        and math.abs(v[1] - self.v.startTime) <= .1
                        and v[12] == spellID then
                        local __tbl = {
                            time = v[1],
                            sourceGUID = GetGUID(v[4]),
                            sourceName = guidTbl[GetGUID(v[4])].name,
                            sourceRT = v[7],
                            destName = guidTbl[GetGUID(v[8])].name,
                            spellID = v[12],
                            spellName = v[13],
                            amount = v[15],
                        }
                        tinsert(tbl, __tbl)
                    end
                end
            end
            if next(tbl) then
                local lines = GameTooltip:NumLines()
                if lines ~= 0 and _G["GameTooltipTextLeft" .. lines]:GetText() ~= " " then
                    GameTooltip:AddLine(" ")
                end

                GameTooltip:AddDoubleLine(format(L["光环层数实际来源"]), L["施法目标"], 1, 1, 1, 1, 1, 1)
                for i, v in ipairs(tbl) do
                    local sourceName, r, g, b = GetGUIDInfo(v.sourceGUID)
                    local RT = TJ.GetRTIcon(v.sourceRT)
                    local colorName = ns.RGB_16(RT .. TJ.GetIconFormName(sourceName), r, g, b)
                    local iconText = ""
                    if v.spellID then
                        local icon = C_Spell.GetSpellTexture(v.spellID)
                        iconText = AddTexture(icon)
                    else
                        iconText = AddTexture("Interface\\Icons\\ability_steelmelee")
                    end
                    local left = format("%s%s（%s）", iconText, v.spellName, colorName)
                    GameTooltip:AddDoubleLine(left, v.destName, 1, .82, 0, 1, .82, 0)
                end
            end
        else
            local text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
            GameTooltip:AddLine(L["施法"] .. text, 1, 1, 1)
            GameTooltip:AddDoubleLine(L["技能"], AddTexture(self.v.icon) .. self.v.spellName)
            GameTooltip:AddDoubleLine(L["施法者"], sourceRT .. TJ.GetIconFormName(sourceName), 1, .82, 0, sr, sg, sb)
            GameTooltip:AddDoubleLine(L["施法目标"], destRT .. TJ.GetIconFormName(destName), 1, .82, 0, dr, dg, db)
        end
    end
    if self.tooltip:match("HLKwuran") then
        local time = TJ.GetHLKwuran(self)
        if time then
            GameTooltip:AddDoubleLine(L["火箭靴反应时间"], time)
        else
            GameTooltip:AddDoubleLine(L["火箭靴反应时间"], L["没有使用"], 1, .82, 0, .5, .5, .5)
        end
    end
    if self.tooltip:match("parry") then
        local text = format("|cff808080（%s）|r", TJ.SecondsToTime(self.v.endTime))
        local spellText
        if self.v.spellName then
            spellText = AddTexture(self.v.icon) .. self.v.spellName
        else
            spellText = AddTexture("Interface\\Icons\\ability_steelmelee") .. L["平砍"]
        end
        GameTooltip:AddLine(spellText .. text, 1, 1, 1, true)
        GameTooltip:AddDoubleLine(L["招架来源"], sourceRT .. TJ.GetIconFormName(sourceName), 1, .82, 0, sr, sg, sb)
        GameTooltip:AddDoubleLine(L["招架目标"], destRT .. TJ.GetIconFormName(destName), 1, .82, 0, dr, dg, db)
    end
    if self.tooltip:match("died") then
        if not self.tooltip:match("health") then
            local lines = GameTooltip:NumLines()
            if lines ~= 0 and _G["GameTooltipTextLeft" .. lines]:GetText() ~= " " then
                GameTooltip:AddLine(" ")
            end
        end
        GameTooltip:AddLine("|A:DungeonSkull:0:0|a" .. L["死亡"], 1, .82, 0)
    end
    self:SetBackdropBorderColor(1, 1, 1, 1)
end
