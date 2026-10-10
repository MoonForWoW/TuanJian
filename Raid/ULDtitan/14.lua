local AddonName, ns = ...

local LibBG = ns.LibBG
local L = ns.L

local AddTexture = ns.AddTexture

local pt = print
local After = C_Timer.After
local BG = TJ

local realmID = GetRealmID()
local player = UnitName("player")


local T = {}
local FB = 'ULDtitan'
local bossIndex = 14
--[[
"DEATHKNIGHT"
"PALADIN"
"WARRIOR"
"SHAMAN"
"HUNTER"
"DRUID"
"ROGUE"
"MAGE"
"WARLOCK"
"PRIEST"
 ]]

TJ.Load[FB .. bossIndex] = function()
    local mainFrame = TJ.frame[FB][bossIndex]

    -- 固定时间轴方案：只绑定角色，技能组合沿用现有减伤链提醒。
    do
        local function ClassText(text, class)
            local r, g, b = GetClassColor(class)
            return ns.RGB_16(text, r, g, b)
        end

        TJ.CreateTimelineBoard(FB, bossIndex, {
            {
                id = 1,
                name = table.concat({
                    ClassText("DKT", "DEATHKNIGHT"),
                    ClassText(L["防骑"], "PALADIN"),
                    ClassText(L["1奶德"], "DRUID"),
                    ClassText(L["1奶骑"], "PALADIN"),
                    ClassText(L["1戒律牧"], "PRIEST"),
                }, "＋"),
                bossSpellID = 32871,
                roles = {
                    { key = "DKT", name = "DKT", class = "DEATHKNIGHT", role = "tank" },
                    { key = "FQ", name = L["防骑"], class = "PALADIN", role = "tank" },
                    { key = "DRUID", name = L["奶德"], class = "DRUID", role = "healer" },
                    { key = "NQ", name = L["奶骑"], class = "PALADIN", role = "healer" },
                    { key = "DISC", name = L["戒律牧"], class = "PRIEST", role = "healer", talent = 1 },
                },
                timeline = {
                    { legacyIndex = 1, time = 8, role = "DKT", spells = { 48792 } },
                    { legacyIndex = 2, time = 20, role = "DISC", spells = { 33206 }, targetRole = "DKT" },
                    { legacyIndex = 3, time = 28, role = "DRUID", spells = { 1283513 }, targetRole = "DKT" },
                    { legacyIndex = 4, time = 40, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { legacyIndex = 5, time = 52, role = "DKT", spells = { 55233 }, items = { 34428 } },
                    { legacyIndex = 6, time = 65, role = "FQ", spells = { 498 } },
                    { legacyIndex = 7, time = 77, role = "NQ", spells = { 6940, 642 }, targetRole = "FQ" },
                    { legacyIndex = 8, time = 89, role = "FQ", spells = {}, items = { 34428 } },
                    { time = 98, text = L["——大爆炸——"], displayOnly = true },
                    { legacyIndex = 9, time = 110, role = "DRUID", spells = { 1283513 }, targetRole = "FQ" },
                    { legacyIndex = 10, time = 128, role = "DKT", spells = { 48792 } },
                    { legacyIndex = 11, time = 140, role = "DKT", spells = { 55233 } },
                    { legacyIndex = 12, time = 160, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { legacyIndex = 13, time = 172, role = "DRUID", spells = { 1283513 }, targetRole = "DKT" },
                    { time = 188, text = L["——大爆炸——"], displayOnly = true },
                    { legacyIndex = 14, time = 198, role = "FQ", spells = { 498 } },
                    { legacyIndex = 15, time = 210, role = "NQ", spells = { 6940, 10278 }, targetRole = "FQ" },
                    { legacyIndex = 16, time = 222, role = "DISC", spells = { 33206 }, targetRole = "FQ" },
                    { legacyIndex = 17, time = 232, role = "DRUID", spells = { 1283513 }, targetRole = "FQ" },
                    { legacyIndex = 18, time = 244, role = "FQ", spells = {}, items = { 34428 } },
                    { legacyIndex = 19, time = 248, role = "DKT", spells = { 48792 } },
                    { legacyIndex = 20, time = 260, role = "DKT", spells = { 55233 } },
                    { time = 278, text = L["——大爆炸——"], displayOnly = true },
                    { legacyIndex = 21, time = 287, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { legacyIndex = 22, time = 299, role = "DRUID", spells = { 1283513 }, targetRole = "DKT" },
                    { legacyIndex = 23, time = 312, role = "DKT", spells = {}, items = { 34428 } },
                    { legacyIndex = 24, time = 318, role = "FQ", spells = { 498 } },
                    { legacyIndex = 25, time = 330, role = "NQ", spells = { 48788 }, targetRole = "FQ" },
                    { legacyIndex = 26, time = 345, role = "NQ", spells = { 64205 } },
                },
            },
            {
                id = 2,
                name = table.concat({
                    ClassText("DKT", "DEATHKNIGHT"),
                    ClassText(L["防骑"], "PALADIN"),
                    ClassText("2" .. L["奶骑"], "PALADIN"),
                    ClassText(L["戒律牧"], "PRIEST"),
                }, "＋"),
                bossSpellID = 32871,
                roles = {
                    { key = "DKT", name = "DKT", class = "DEATHKNIGHT", role = "tank" },
                    { key = "FQ", name = L["防骑"], class = "PALADIN", role = "tank" },
                    { key = "NQ", name = L["奶骑"] .. "1", class = "PALADIN", role = "healer" },
                    { key = "NQ2", name = L["奶骑"] .. "2", class = "PALADIN", role = "healer" },
                    { key = "DISC", name = L["戒律牧"], class = "PRIEST", role = "healer", talent = 1 },
                },
                timeline = {
                    { time = 8, role = "DKT", spells = { 48792 } },
                    { time = 20, role = "DISC", spells = { 33206 }, targetRole = "DKT" },
                    { time = 28, role = "DKT", spells = { 55233 } },
                    { time = 40, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { time = 52, role = "DKT", spells = {}, items = { 34428 } },
                    { time = 65, role = "FQ", spells = { 498 } },
                    { time = 77, role = "NQ", spells = { 6940, 642 }, targetRole = "FQ" },
                    { time = 89, role = "FQ", spells = {}, items = { 34428 } },
                    { time = 98, text = L["——大爆炸——"], displayOnly = true },
                    { time = 105, role = "NQ2", spells = { 6940, 642 }, targetRole = "FQ" },
                    { time = 128, role = "DKT", spells = { 48792 } },
                    { time = 140, role = "DKT", spells = { 55233 } },
                    { time = 160, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { time = 172, role = "DKT", spells = {}, items = { 34428 } },
                    { time = 188, text = L["——大爆炸——"], displayOnly = true },
                    { time = 198, role = "FQ", spells = { 498 } },
                    { time = 210, role = "NQ", spells = { 6940, 10278 }, targetRole = "FQ" },
                    { time = 222, role = "DISC", spells = { 33206 }, targetRole = "FQ" },
                    { time = 232, role = "NQ2", spells = { 6940, 10278 }, targetRole = "FQ" },
                    { time = 244, role = "FQ", spells = {}, items = { 34428 } },
                    { time = 248, role = "DKT", spells = { 48792 } },
                    { time = 260, role = "DKT", spells = { 55233 } },
                    { time = 278, text = L["——大爆炸——"], displayOnly = true },
                    { time = 287, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { time = 302, role = "DKT", spells = {}, items = { 34428 } },
                    { time = 318, role = "FQ", spells = { 498 } },
                    { time = 330, role = "NQ", spells = { 48788 }, targetRole = "FQ" },
                    { time = 345, role = "NQ2", spells = { 64205 } },
                },
            },
            {
                id = 3,
                name = table.concat({
                    ClassText("DKT", "DEATHKNIGHT"),
                    ClassText(L["防骑"], "PALADIN"),
                    ClassText("1" .. L["奶骑"], "PALADIN"),
                    ClassText("2" .. L["戒律牧"], "PRIEST"),
                }, "＋"),
                bossSpellID = 32871,
                roles = {
                    { key = "DKT", name = "DKT", class = "DEATHKNIGHT", role = "tank" },
                    { key = "FQ", name = L["防骑"], class = "PALADIN", role = "tank" },
                    { key = "NQ", name = L["奶骑"], class = "PALADIN", role = "healer" },
                    { key = "DISC", name = L["戒律牧"] .. "1", class = "PRIEST", role = "healer", talent = 1 },
                    { key = "DISC2", name = L["戒律牧"] .. "2", class = "PRIEST", role = "healer", talent = 1 },
                },
                timeline = {
                    { time = 8, role = "DKT", spells = { 48792 } },
                    { time = 20, role = "DISC", spells = { 33206 }, targetRole = "DKT" },
                    { time = 28, role = "DKT", spells = { 55233 } },
                    { time = 40, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { time = 52, role = "DKT", spells = {}, items = { 34428 } },
                    { time = 60, role = "DISC2", spells = { 33206 }, targetRole = "DKT" },
                    { time = 65, role = "FQ", spells = { 498 } },
                    { time = 77, role = "NQ", spells = { 6940, 642 }, targetRole = "FQ" },
                    { time = 98, text = L["——大爆炸——"], displayOnly = true },
                    { time = 104, role = "FQ", spells = {}, items = { 34428 } },
                    { time = 128, role = "DKT", spells = { 48792 } },
                    { time = 140, role = "DKT", spells = { 55233 } },
                    { time = 160, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { time = 172, role = "DKT", spells = {}, items = { 34428 } },
                    { time = 188, text = L["——大爆炸——"], displayOnly = true },
                    { time = 198, role = "FQ", spells = { 498 } },
                    { time = 210, role = "NQ", spells = { 6940, 10278 }, targetRole = "FQ" },
                    { time = 224, role = "DISC", spells = { 33206 }, targetRole = "FQ" },
                    { time = 232, role = "FQ", spells = {}, items = { 34428 } },
                    { time = 240, role = "DISC2", spells = { 33206 }, targetRole = "FQ" },
                    { time = 248, role = "DKT", spells = { 48792 } },
                    { time = 260, role = "DKT", spells = { 55233 } },
                    { time = 278, text = L["——大爆炸——"], displayOnly = true },
                    { time = 287, role = "FQ", spells = { 6940 }, targetRole = "DKT" },
                    { time = 302, role = "DKT", spells = {}, items = { 34428 } },
                    { time = 318, role = "FQ", spells = { 498 } },
                    { time = 330, role = "NQ", spells = { 48788 }, targetRole = "FQ" },
                    { time = 345, role = "NQ", spells = { 64205 } },
                },
            },
        })
        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
        end
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 坍缩星：按每颗星分行，点击查看全部玩家伤害记录。
    do
        local info = {
            targetDamage = { npcID = 32955 },
            notShowDead = true,
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "Spell_Arcane_StarFire",
            L["毛坍缩星"], nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 阶段时间轴：与 DBM 一致，Self Stun 施法成功时进入 P2。
    local recordedP2 = false
    local lastBigBangTime
    local function RecordP2()
        if recordedP2 or not TJ.startTime
            or TJ.combatLastFB ~= FB or TJ.combatLastBossIndex ~= bossIndex then
            return
        end
        local combatLog = TJ.GetNewCombatLog()
        if not combatLog or not combatLog.otherTime then return end
        recordedP2 = true
        tinsert(combatLog.otherTime, {
            time = TJ.GetDurTime(),
            name = "P2",
        })
    end
    mainFrame.ENCOUNTER_START = function()
        recordedP2 = false
        lastBigBangTime = nil
        -- 默认非首战，仅通过开场喊话确认首战；开战时消费标记。
        mainFrame.boardTimeOffset = TJ.algalonFirstPull and 18 or 0
        TJ.algalonFirstPull = nil
    end
    mainFrame.ENCOUNTER_END = function()
        mainFrame.boardTimeOffset = 0
    end
    -- 大爆炸：记录实际开始施法的时间，兼容两个难度的技能 ID。
    mainFrame.SPELL_CAST_START = function(...)
        local spellID = select(12, ...)
        if spellID ~= 64584 and spellID ~= 64443 then return end
        if not TJ.startTime or TJ.combatLastFB ~= FB
            or TJ.combatLastBossIndex ~= bossIndex
            or TJ.GetNPCID(select(4, ...)) ~= 32871 then
            return
        end
        local combatLog = TJ.GetNewCombatLog()
        if not combatLog or not combatLog.otherTime then return end
        local now = TJ.GetDurTime()
        if lastBigBangTime and now - lastBigBangTime < 1 then return end
        lastBigBangTime = now
        tinsert(combatLog.otherTime, {
            time = now,
            name = L["大爆炸"],
        })
    end
    mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(unit, spellID)
        if spellID == 65256 and TJ.GetNPCID(UnitGUID(unit)) == 32871 then
            RecordP2()
        end
    end
    -- DBM 也会通过转阶段喊话和同步进入 P2，补充本地未收到施法事件的情况。
    if DBM and DBM.RegisterCallback then
        DBM:RegisterCallback("DBM_SetStage", function(_, mod, modId, nextPhase)
            if modId == "Algalon" and nextPhase == 2 then RecordP2() end
        end)
    end
end
