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
local FB = "SOO"
local bossIndex = 2
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

    -- 黑暗冥想减伤链
    local bossSpellID = 143546
    TJ.AddBoard(mainFrame, function()
        local s1, s2, s3, s4, s5, s6, s7 = ns.s1, ns.s2, ns.s3, ns.s4, ns.s5, ns.s6, ns.s7
        local bossSpellID2 = bossSpellID * 10 + 1
        local bossSpellID3 = bossSpellID * 10 + 2
        local arrange = 6
        local spellTbl = {
            {
                title = L["1-1"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
            {
                title = L["2-1"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
        }
        local spellTbl2 = {
            {
                title = L["1-2"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
            {
                title = L["2-2"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
        }
        local spellTbl3 = {
            {
                title = L["1-3"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
            {
                title = L["2-3"],
                class = nil,
                spell = TJ.Board_TJ1,
                onlyTitle = true,
            },
        }
        local function AutoFuc()
            local slots = {
                { round = 1, boardID = 1 },
                { round = 1, boardID = 2 },
                { round = 1, boardID = 3 },
                { round = 2, boardID = 1 },
                { round = 2, boardID = 2 },
                { round = 2, boardID = 3 },
            }
            local usedColumns = {}
            local nextSlot = {
                reduce = 1,
                heal = 1,
            }
            local function Assign(group, v, ...)
                local spellCount = select("#", ...)
                for offset = 0, #slots - 1 do
                    local slotIndex = (nextSlot[group] + offset - 1) % #slots + 1
                    if (usedColumns[slotIndex] or 0) + spellCount <= arrange then
                        local slot = slots[slotIndex]
                        for i = 1, spellCount do
                            TJ.SetBoardEditFormNum(v, slot.round, nil, select(i, ...), slot.boardID)
                        end
                        usedColumns[slotIndex] = (usedColumns[slotIndex] or 0) + spellCount
                        nextSlot[group] = slotIndex % #slots + 1
                        return
                    end
                end
            end

            local tbl = TJ.SortRaidRosterInfo({ "WARRIOR" }, nil, true)
            for _, v in ipairs(tbl) do Assign("reduce", v, s2, s3) end
            local tbl = TJ.SortRaidRosterInfo({ "PALADIN" }, nil, true)
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
            local tbl = TJ.SortRaidRosterInfo({ "DEATHKNIGHT" }, "dps", true)
            for _, v in ipairs(tbl) do Assign("reduce", v, s4) end
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

        local cd1 = 5
        local tbl = {
            {
                name = L["黑暗冥想第1棒"],
                bossSpellID = bossSpellID,
                arrange = arrange,
                icon = 236170,
                id = 1,
                spell = spellTbl,
                event = "SPELL_AURA_APPLIED",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 2,
                bossTime = { cd1, cd1 },
                autoHide = true,
                special = {
                    id = 2,
                    bossSpellID = bossSpellID2,
                    time = 9.5,
                },
                special2 = {
                    id = 3,
                    bossSpellID = bossSpellID3,
                    time = 9.5,
                },
            },
            {
                name = L["黑暗冥想第2棒"],
                bossSpellID = bossSpellID2,
                arrange = arrange,
                icon = 236170,
                id = 2,
                spell = spellTbl2,
                event = "SPELL_AURA_APPLIED",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 2,
                bossTime = { 10, 10 },
                autoHide = true,
            },
            {
                name = L["黑暗冥想第3棒"],
                bossSpellID = bossSpellID3,
                arrange = arrange,
                icon = 236170,
                id = 3,
                spell = spellTbl3,
                event = "SPELL_AURA_APPLIED",
                canUpdate = nil,
                autoNextSpell = nil,
                startIndex = 1,
                maxIndex = 2,
                bossTime = { 10, 10 },
                autoHide = true,
            },
            AutoFuc = AutoFuc,
        }

        mainFrame.Board_SPELL_AURA_APPLIED = function(info, ...)
            local tbl = { ... }
            local spellID = tbl[12]
            if spellID == bossSpellID then
                info[bossSpellID].canUpdate = true
                info[bossSpellID].updateFrame.t = 0
                TJ.AddTimer(cd1 + 0.5, function()
                    TJ.Board_RunSpecial(bossSpellID)
                end)
                TJ.AddTimer(cd1 + 10.5, function()
                    if info[bossSpellID] then
                        TJ.Board_RunSpecial(bossSpellID, 2)
                        info[bossSpellID].index = info[bossSpellID].index + info[bossSpellID].step
                    end
                end)
            end
        end

        mainFrame.Board_test = function()
            TJ.Board_ENCOUNTER_START(FB, bossIndex, true)
            TJ.Board_info[bossSpellID].canUpdate = true
            TJ.AddTimer(cd1 + 0.5, function()
                TJ.Board_RunSpecial(bossSpellID)
            end)
            TJ.AddTimer(cd1 + 10.5, function()
                TJ.Board_RunSpecial(bossSpellID, 2)
            end)
        end
        --[[
/run TJ.Board_ENCOUNTER_START("SOO", 2) TJ.Board_SPELL_AURA_APPLIED(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,143546)
/run TJ.Board_SPELL_AURA_APPLIED(nil,nil,nil,"1",nil,nil,nil,"1-2-3-4-5-70235",nil,nil,nil,143546)
        ]]

        TJ.CreateBoard(FB, bossIndex, tbl)
    end)

    TJ.CreateSPTitle(FB, bossIndex, nil, nil)

    -- 凿击
    do
        local info = {
            {
                aura = {
                    type = "d",
                    spell = {
                        {
                            spellID = { 143301 },
                        },
                    },
                    destNpcType = { "Player" },
                    showCount = true,
                },
                canSend = "count",
                notShowDead = true,
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'ability_gouge', L["凿击"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 腐蚀冲击
    do
        local info = {
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 143958 },
                        },
                    },
                },
                title = { name = L["漏打断腐蚀震击"], color = { 1, 0, 0 }, icon = 143958 },
                notShowDead = true,
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 143958 },
                            colorNum = 1,
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["成功打断腐蚀震击"], icon = 143958 },
            },
            {
                castSuccess = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 143423 },
                        },
                    },
                },
                title = { name = L["漏打断煞能灼烧"], color = { 1, 0, 0 }, icon = 143423 },
                notShowDead = true,
            },
            {
                interrupt = {
                    type = "s",
                    spell = {
                        {
                            spellID = { 143423 },
                            colorNum = 1,
                        },
                    },
                },
                notShowDead = true,
                title = { name = L["成功打断煞能灼烧"], icon = 143423 },
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 136050, L["打断"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 团减
    do
        local info = {
            {
                aura = {
                    type = "s",
                    spell = {
                        {
                            spellID = { bossSpellID, },
                            colorNum = 2,
                        },
                    },
                },
                title = { name = L["Boss施放%s"]:format(L["黑暗冥想"]) }
            },
        }
        tinsert(info, TJ.combatInfoMore)

        local f = TJ.CreateTitle(FB, bossIndex, nil, 236170, L["黑暗冥想"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71476, 71481, 71477 },
                },
                showRaidMember = true,
                canSend = "dps",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'achievement_worldevent_brewmaster', L["转火酒仙化身"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- 转火
    do
        local info = {
            {
                dps = {
                    type = "s",
                    destNPCID = { 71482, 71474 },
                },
                showRaidMember = true,
                canSend = "dps",
            },
        }
        local f = TJ.CreateTitle(FB, bossIndex, nil, 'spell_shadow_shadowform', L["转火暗牧化身"],
            nil, nil, nil, info)
        TJ.AddSPTitle(FB, bossIndex, f)
    end

    -- mainFrame.BOSS_SAY = function(msg)
    --     if msg:match("") then
    --         tinsert(TJ.GetNewCombatLog().otherTime, {
    --             time = TJ.GetDurTime(),
    --             name = "P2",
    --         })
    --         return
    --     end
    -- end
end
