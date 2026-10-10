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
local bossIndex = 13
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

    -- 站位图
    do
        local tbl = {
            { point = "TOPLEFT", xy = { 390, -156 } },
            { point = "TOPLEFT", xy = { 439, -220 } },
            { point = "TOPLEFT", xy = { 439, -299 } },
            { point = "TOPLEFT", xy = { 398, -370 } },
            { point = "TOPLEFT", xy = { 295, -415 } },
            { point = "TOPLEFT", xy = { 185, -368 } },
            { point = "TOPLEFT", xy = { 154, -291 } },
            { point = "TOPLEFT", xy = { 163, -205 } },
            { point = "TOPLEFT", xy = { 215, -149 } },
            { point = "TOPLEFT", xy = { 301, -125 } },

            [100] = { xy = { 296, -271 }, isNPC = "b" .. bossIndex, size = 250, },
        }

        --[[


]]

        local function AutoFuc()
            local healers = TJ.SortRaidRosterInfo(nil, "dps1", true)
            for _, v in ipairs(healers) do
                TJ.SetMapIconPlayer(v)
            end
            local rangedDps = TJ.SortRaidRosterInfo(nil, "dps2", true)
            for _, v in ipairs(rangedDps) do
                TJ.SetMapIconPlayer(v)
            end
        end
        local text = L["优先安排近战DPS，其次远程DPS。"]

        TJ.CreateTitle(FB, bossIndex, AutoFuc, "spell_nature_wispsplode", L["P2进门"],
            text)
        local width = 600
        local map = TJ.CreateMap(FB, bossIndex, tbl, width, width / 1020 * 910, nil, nil, nil, "v3.0.2")
    end

    -- 自动标记
    local name = "rt" .. FB .. bossIndex
    do
        mainFrame.autoRT = name
        local instanceID = TJ.FBinfo[FB].ID
        TJ.autoRaidTargetInfo[instanceID] = TJ.autoRaidTargetInfo[instanceID] or {}
        TJ.autoRaidTargetInfo[instanceID][33136] = {
            [8] = true,
            [7] = true,
            [6] = true,
            [5] = true,
            np = true,
        }

        TJ.options[name .. "reset"] = 1
        TuanJian.options[name] = TuanJian.options[name] or TJ.options[name .. "reset"]
        local icon = TJ.SetRaidTargetingTex(8, 7, 6, 5)
        local ontext = {
        }
        local f = ns.O.CreateCheckButton(name, format(L["战斗中把P1小怪标记为%s（需要团长/助理）"], icon),
            mainFrame, 40, -150, ontext)
        f:ClearAllPoints()
        f:SetPoint("BOTTOMLEFT", TJ.spChild.title, "TOPRIGHT", 0, 15)
        f:SetHitRectInsets(0, 0, 0, 0)
    end

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 理智：按玩家显示光环持续时间和层数变化。
    do
        local info = {
            {
                aura = {
                    type = "d",
                    startTime = "P2",
                    endTime = "duration",
                    spell = {
                        { spellID = { 63050 }, colorNum = 1 },
                    },
                },
                notShowDead = true,
                title = { name = L["理智"] },
            },
            {
                aura = {
                    type = "d",
                    spell = {
                        { spellID = { 63120 }, colorNum = 4 }, -- 疯狂：理智耗尽后被心控
                    },
                },
                title = { name = L["疯狂"], icon = 63120 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(63050), L["理智"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 进内场：通过单位施法事件记录传送成功，按玩家显示进入时间和次数。
    do
        local info = {
            trigger = {
                type = "s",
                showCount = true,
                spell = {
                    { spellID = { 51347 }, colorNum = 1, tooltipText = L["进内场"] },
                },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, C_Spell.GetSpellTexture(57687), L["进内场"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)

        local lastStartTime
        local lastEntry = {}
        mainFrame.UNIT_SPELLCAST_SUCCEEDED = function(unit, spellID)
            if spellID ~= 51347 or not TJ.startTime
                or TJ.combatLastFB ~= FB or TJ.combatLastBossIndex ~= bossIndex then
                return
            end
            local guid = UnitGUID(unit)
            if not guid or not TJ.raidRosterGUID[guid] then return end
            local combatLog = TJ.GetNewCombatLog()
            local newEvent = TJ.GetNewEvent()
            local playerInfo = combatLog and combatLog.guid[guid]
            if not newEvent or not playerInfo then return end
            if lastStartTime ~= TJ.startTime then
                lastStartTime = TJ.startTime
                wipe(lastEntry)
            end
            local now = TJ.GetDurTime()
            -- 同一玩家可能通过 player、raid 等单位标识重复收到事件。
            if lastEntry[guid] and now - lastEntry[guid] < 1 then return end
            lastEntry[guid] = now
            combatLog.duration = now
            TJ.eventCount = TJ.eventCount + 1
            newEvent.TRIGGER = newEvent.TRIGGER or {}
            tinsert(newEvent.TRIGGER, {
                [1] = now,
                [4] = playerInfo.index,
                [7] = GetRaidTargetIndex(unit),
                [12] = spellID,
                i = TJ.eventCount,
            })
        end
    end

    -- 转火尤格萨隆大脑
    do
        local info = {
            dps = {
                type = "s",
                destNPCID = { 33890 }, -- 尤格萨隆大脑
            },
            title = { name = L["输出尤格萨隆的大脑"] },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, "spell_shadow_brainwash", L["输出大脑"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 阶段时间轴
    do
        -- 阶段时间轴：暗影屏障获得时进入P2，移除时进入P3。
        local phase = 1
        local function RecordPhase(nextPhase)
            if nextPhase <= phase then return end
            phase = nextPhase
            tinsert(TJ.GetNewCombatLog().otherTime, {
                time = TJ.GetDurTime(),
                name = "P" .. nextPhase,
            })
        end
        mainFrame.ENCOUNTER_START = function()
            phase = 1
        end
        mainFrame.SPELL_AURA_APPLIED = function(...)
            local destGUID = select(8, ...)
            local spellID = select(12, ...)
            if spellID == 63894 and TJ.GetNPCID(destGUID) == 33288 then
                RecordPhase(2)
            end
        end
        mainFrame.SPELL_AURA_REMOVED = function(...)
            local destGUID = select(8, ...)
            local spellID = select(12, ...)
            if spellID == 63894 and TJ.GetNPCID(destGUID) == 33288 then
                RecordPhase(3)
            end
        end
        -- DBM收到Phase3同步后也会触发阶段回调，补上大脑房间收不到的外场事件。
        if DBM and DBM.RegisterCallback then
            DBM:RegisterCallback("DBM_SetStage", function(_, mod, modId, nextPhase)
                if modId ~= "YoggSaron" or not TJ.startTime
                    or TJ.combatLastFB ~= FB or TJ.combatLastBossIndex ~= bossIndex then
                    return
                end
                if nextPhase == 2 or nextPhase == 3 then
                    RecordPhase(nextPhase)
                end
            end)
        end
    end
end
